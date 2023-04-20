module z1top (
    input sysclk,
    input rst,
    input UART_RX,
    output UART_TX,
    output [3:0] led
);

    // wire controller_data_in_valid;
    // wire [7:0] controller_data_in;
    // wire controller_data_in_ready;
    
    // wire controller_data_out_valid;
    // wire [7:0] controller_data_out;
    // wire controller_data_out_ready;


    // controller c (
    //     .clk(sysclk),
    //     .rst(rst),
    //     .data_in(controller_data_in),
    //     .data_in_valid(controller_data_in_valid),
    //     .data_in_ready(controller_data_in_ready),
    //     .data_out(controller_data_out),
    //     .data_out_valid(controller_data_out_valid),
    //     .data_out_ready(controller_data_out_ready),
    //     .status(led[3])
    // );

    wire data_valid;
    wire [7:0] data;
    wire data_ready;

    reg [7:0] next_data;
    always @(*) begin
        if (data >= 8'h41 && data <= 8'h5A) begin
            next_data = data + 8'h20;
        end else if (data >= 8'h61 && data <= 8'h7A) begin
            next_data = data - 8'h20;
        end else begin
            next_data = data;
        end
    end
    
    uart_receiver ur (
        .clk(sysclk),
        .rst(rst),
        .ready(data_ready),
        .valid(data_valid),
        .data(data),
        .uart_rx(UART_RX),
        .status(led[2])
    );

    uart_transmitter ut (
        .clk(sysclk),
        // .rst(rst),
        .ready(data_ready),
        .valid(data_valid),
        .data(next_data),
        .uart_tx(UART_TX),
        .status(led[1])
    );

endmodule

module controller(
    input clk,
    input rst,
    output data_in_ready,
    input data_in_valid,
    input [7:0] data_in,
    input data_out_ready,
    output reg data_out_valid,
    output reg [7:0] data_out,
    output status
);
    reg [7:0] data;
    reg data_read = 0;
    assign data_in_ready = !data_read;
    assign status = data_read;

    reg [7:0] next_data;
    always @(*) begin
        if (data >= 8'h41 && data <= 8'h5A) begin
            next_data = data + 8'h20;
        end else if (data >= 8'h61 && data <= 8'h7A) begin
            next_data = data - 8'h20;
        end else begin
            next_data = data;
        end
    end

    always @(posedge clk) begin
        if (rst) begin
            data_out_valid <= 0;
            data_read <= 0;
            data_out <= 0;
        end else begin
            // if (!data_read && data_in_valid && data_out_ready) begin
            //     data_out <= data_in;
            //     data_out_valid <= 1;
            //     data_in_ready <= 1;
            // end if (!data_read && data_in_valid && !data_out_ready) begin
            if (!data_read && data_in_valid) begin
                data <= data_in;
                data_read <= 1;
            end
            if (data_read && data_out_ready) begin
                data_out <= next_data;
                data_read <= 0;
                data_out_valid <= 1;
            end
            if (!data_read && data_out_ready) begin
                data_out_valid <= 0;
            end
        end
    end
endmodule

module uart_receiver #(
    parameter BAUD_LENGTH_IN_CYCLES = 125000000/115200, // at least 3 cycle so that we don't need to sample the first cycle of the start bit
    parameter DATA_WIDTH = 8, // support 1 to 8 bits 
    parameter STOP_BIT = 1 // support 1 or 2 stop bits
)(
    input clk,
    input rst,
    input ready,
    output reg valid,
    output [DATA_WIDTH-1:0] data,
    input uart_rx,
    output status
);

    // necessary state to keep track of the samples
    localparam SAMPLES_MAX_COUNT = DATA_WIDTH + STOP_BIT + 1; // 1 for start bit
    localparam SAMPLES_COUNT_WIDTH = $clog2(SAMPLES_MAX_COUNT);
    reg [SAMPLES_COUNT_WIDTH-1:0] samples_count = 0;
    wire [SAMPLES_COUNT_WIDTH-1:0] next_samples_count = samples_count + 1 == SAMPLES_MAX_COUNT ? 0 : samples_count + 1;

    // necessary state to keep track of the cycles
    localparam CYCLE_MAX_COUNT = BAUD_LENGTH_IN_CYCLES; // >= 3
    localparam CYCLE_COUNT_WIDTH = $clog2(CYCLE_MAX_COUNT);
    reg [CYCLE_COUNT_WIDTH-1:0] cycle_count = 0;
    wire [CYCLE_COUNT_WIDTH-1:0] next_cycle_count = cycle_count + 1 != CYCLE_MAX_COUNT ? cycle_count + 1 : 0;
    wire sample_now = cycle_count == (CYCLE_MAX_COUNT + 1) / 2 - 1; // at least (ceil) half of the cycles have passed

    // storage for the samples
    reg [SAMPLES_MAX_COUNT-1:0] samples = 0;

    assign data = samples[SAMPLES_MAX_COUNT-STOP_BIT-1:1];

    // status
    reg scanning = 0;
    reg error = 0;
    assign status = error;
    always @(posedge clk) begin
        if (rst) begin
            scanning <= 0;
            samples <= 0;
            samples_count <= 0;
            cycle_count <= 0;
            valid <= 0;
            error <= 0;
        end else begin
            if (valid && ready) begin
                valid <= 0;
            end
            if (scanning) begin
                cycle_count <= next_cycle_count;
                if (sample_now) begin
                    samples <= { uart_rx, samples[SAMPLES_MAX_COUNT-1:1] };
                    samples_count <= next_samples_count;
                    if (samples_count == SAMPLES_MAX_COUNT - 1) begin
                        if (uart_rx != 1) begin
                            error <= 1;
                        end
                        scanning <= 0;
                        valid <= 1;
                    end
                end
            end else begin
                if (uart_rx == 0) begin
                    valid <= 0;
                    scanning <= 1;
                    cycle_count <= 1;//next_cycle_count; // the first cycle is already passed
                    samples <= 0;
                    samples_count <= 0;
                end
            end
        end
    end

endmodule

module uart_transmitter #(
    parameter BAUD_LENGTH_IN_CYCLES = 125000000/115200
)(
    input clk,
    input valid,
    input [7:0] data,
    output ready, // sending existing data, not accepting new data
    output uart_tx,
    output status
);
    localparam MAX_BIT_SENT = 10;

    reg [$clog2(BAUD_LENGTH_IN_CYCLES):0] count = 0, next_count;
    reg [9:0] shifting_data, next_shifting_data;
    reg [3:0] bit_sent = 0, next_bit_sent;

    localparam STATE_IDLE = 1'b0;
    localparam STATE_BUSY = 1'b1;
    reg state = STATE_IDLE, next_state;
    reg all_sent;

    assign status = state == STATE_BUSY;
    always @(*) begin
        next_state = state;
        if (state == STATE_IDLE && valid)
            next_state = STATE_BUSY;
        else if (state == STATE_BUSY && all_sent)
            next_state = STATE_IDLE;
    end

    always @(*) begin
        all_sent = 0;
        case (state)
            STATE_IDLE:
                begin
                    next_count = 0;
                    next_shifting_data = { 1'd1, data, 1'd0 };
                    next_bit_sent = 0;
                end
            STATE_BUSY:
                begin
                    next_count = count + 1;
                    next_shifting_data = shifting_data;
                    next_bit_sent = bit_sent;
                    if (next_count == BAUD_LENGTH_IN_CYCLES) begin
                        next_count = 0;
                        next_shifting_data = shifting_data >> 1;
                        next_bit_sent = bit_sent + 1;
                        if (next_bit_sent == MAX_BIT_SENT) begin
                            next_bit_sent = 0;
                            all_sent = 1;
                        end
                    end
                end
        endcase
    end

    always @(posedge clk) begin
        count <= next_count;
        shifting_data <= next_shifting_data;
        bit_sent <= next_bit_sent;
        state <= next_state;
    end

    assign uart_tx = state == STATE_BUSY ? shifting_data[0] : 1'b1;
    assign ready = state == STATE_IDLE;

endmodule
