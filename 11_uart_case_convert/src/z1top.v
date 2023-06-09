module z1top (
    input sysclk,
    input rst,
    input UART_RX,
    output UART_TX,
    output [3:0] led
);
    wire [7:0] data_in;    
    wire data_in_valid;
    wire data_in_ready;

    wire [7:0] data_out;
    wire data_out_valid;
    wire data_out_ready;

    // assign data_out = data_in;
    // assign data_out_valid = data_in_valid;
    // assign data_in_ready = data_out_ready;

    controller c (
        .clk(sysclk),
        .rst(rst),
        .data_in(data_in),
        .data_in_valid(data_in_valid),
        .data_in_ready(data_in_ready),
        .data_out(data_out),
        .data_out_valid(data_out_valid),
        .data_out_ready(data_out_ready),
        .status(led[3])
    );

    wire [7:0] data;
    assign data = data_out;

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
        .ready(data_in_ready),
        .valid(data_in_valid),
        .data(data_in),
        .uart_rx(UART_RX)
    );

    uart_transmitter2 ut (
        .clk(sysclk),
        .rst(rst),
        .ready(data_out_ready),
        .valid(data_out_valid),
        .data(next_data),
        .uart_tx(UART_TX)
    );

endmodule

module controller(
    input clk,
    input rst,
    output reg data_in_ready,
    input data_in_valid,
    input [7:0] data_in,
    input data_out_ready,
    output reg data_out_valid,
    output reg [7:0] data_out,
    output status
);
    reg [7:0] data;
    reg data_read = 0;
    // assign data_in_ready = !data_read;
    assign status = data_read;

    always @(posedge clk) begin
        if (rst) begin
            data_in_ready <= 0;
            data_out_valid <= 0;
            data_out <= 0;
            data_read <= 0; // problem, long hold rst can consume data
        end else begin
            if (!data_read && data_in_valid && data_out_ready) begin // directly pass through
                data_out <= data_in;
                data_out_valid <= 1;
                data_in_ready <= 1;
            end 
            if (!data_read && data_in_valid && !data_out_ready) begin
            // if (!data_read && data_in_valid) begin
                data <= data_in;
                data_read <= 1;
                data_in_ready <= 0;
            end
            if (!data_read && !data_in_valid && data_out_ready) begin
                data_out_valid <= 0;
            end
            if (data_read && data_out_ready) begin
                data_out <= data;
                data_read <= 0;
                data_in_ready <= 1;
                data_out_valid <= 1;
            end

        end
    end
endmodule

module uart_receiver #(
    parameter BAUD_LENGTH_IN_CYCLES = 125000000/115200, // at least 3 cycle so that we don't need to sample the first cycle of the start bit
    parameter DATA_WIDTH = 8, // usually 8, but could be any positive integer
    parameter STOP_BITS = 1 // support positive integer, usually 1 or 2 stop bits, 1.5 stop bits is not supported
)(
    input clk,
    input rst,
    input ready,
    output reg valid,
    output [DATA_WIDTH-1:0] data,
    input uart_rx
);
    localparam SAMPLES_MAX_COUNT = DATA_WIDTH + STOP_BITS + 1; // 1 for start bit
    localparam SAMPLES_COUNT_WIDTH = $clog2(SAMPLES_MAX_COUNT);
    reg [SAMPLES_COUNT_WIDTH-1:0] samples_count = 0;
    wire [SAMPLES_COUNT_WIDTH-1:0] next_samples_count = samples_count + 1 == SAMPLES_MAX_COUNT ? 0 : samples_count + 1;

    localparam CYCLE_MAX_COUNT = BAUD_LENGTH_IN_CYCLES; // >= 3
    localparam CYCLE_COUNT_WIDTH = $clog2(CYCLE_MAX_COUNT);
    reg [CYCLE_COUNT_WIDTH-1:0] cycle_count = 0;
    wire [CYCLE_COUNT_WIDTH-1:0] next_cycle_count = cycle_count + 1 == CYCLE_MAX_COUNT ? 0 : cycle_count + 1;
    wire sample_now = cycle_count == (CYCLE_MAX_COUNT + 1) / 2 - 1; // at least (ceil) half of the cycles have passed

    reg [SAMPLES_MAX_COUNT-1:0] samples = 0;
    assign data = samples[SAMPLES_MAX_COUNT-STOP_BITS-1-:DATA_WIDTH];

    reg scanning = 0;
    always @(posedge clk) begin
        if (rst) begin
            scanning <= 0;
            samples <= 0;
            samples_count <= 0;
            cycle_count <= 0;
            valid <= 0;
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
                        scanning <= 0;
                        valid <= 1;
                        cycle_count <= 0;
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
    parameter BAUD_LENGTH_IN_CYCLES = 125000000/115200, // at least 3 cycle so that we don't need to sample the first cycle of the start bit
    parameter DATA_WIDTH = 8, // usually 8, but could be any positive integer
    parameter STOP_BITS = 1 // support positive integer, usually 1 or 2 stop bits, 1.5 stop bits is not supported
)(
    input clk,
    input rst,
    input valid,
    input [7:0] data,
    output reg ready,
    output reg uart_tx
);
    localparam SAMPLES_MAX_COUNT = DATA_WIDTH + STOP_BITS + 1; // 1 for start bit
    localparam SAMPLES_COUNT_WIDTH = $clog2(SAMPLES_MAX_COUNT);
    reg [SAMPLES_COUNT_WIDTH-1:0] samples_count = 0;
    wire [SAMPLES_COUNT_WIDTH-1:0] next_samples_count = samples_count + 1 == SAMPLES_MAX_COUNT ? 0 : samples_count + 1;

    localparam CYCLE_MAX_COUNT = BAUD_LENGTH_IN_CYCLES; // >= 3
    localparam CYCLE_COUNT_WIDTH = $clog2(CYCLE_MAX_COUNT);
    reg [CYCLE_COUNT_WIDTH-1:0] cycle_count = 0;
    wire [CYCLE_COUNT_WIDTH-1:0] next_cycle_count = cycle_count + 1 == CYCLE_MAX_COUNT ? 0 : cycle_count + 1;

    reg [SAMPLES_MAX_COUNT-1:0] samples = { SAMPLES_MAX_COUNT{1'b1} };

    reg sending = 0;
    always @(posedge clk) begin
        if (rst) begin
            sending <= 0;
            samples <= { SAMPLES_MAX_COUNT{1'b1} };
            samples_count <= 0;
            cycle_count <= 0;
            uart_tx <= 1;
            ready <= 0;
        end else begin
            if (ready && valid) begin
                ready <= 0;
                samples <= { {STOP_BITS{1'b1}}, data, 1'b0 };
                sending <= 1;
                samples_count <= 0;
                cycle_count <= 0;
                uart_tx <= 0;
            end
            if (sending) begin
                cycle_count <= next_cycle_count;
                if (cycle_count == CYCLE_MAX_COUNT - 1) begin
                    samples_count <= next_samples_count;
                    uart_tx <= samples[next_samples_count];
                    if (samples_count == SAMPLES_MAX_COUNT - 1) begin
                        sending <= 0;
                        ready <= 1;
                        cycle_count <= 0;
                        samples <= { SAMPLES_MAX_COUNT{1'b1} };
                        samples_count <= 0;
                        uart_tx <= 1;
                    end
                end
            end else begin
                if (!ready) begin
                    ready <= 1;
                end
            end
        end
    end

endmodule

module uart_transmitter2 #(
    parameter BAUD_LENGTH_IN_CYCLES = 125000000/115200, // at least 3 cycle so that we don't need to sample the first cycle of the start bit
    parameter DATA_WIDTH = 8, // usually 8, but could be any positive integer
    parameter STOP_BITS = 1 // support positive integer, usually 1 or 2 stop bits, 1.5 stop bits is not supported
)(
    input clk,
    input rst,
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
