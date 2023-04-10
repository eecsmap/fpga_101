
// to 
module z1top(
    input sysclk,
    input button,
    output status,
    output tx
);
    // I want to detect button press event and toggle the status
    // whenever button is pressed, send a 'A' to the UART transmitter
    wire synchronized_button;
    synchronizer sync(
        .clk(sysclk),
        .button(button),
        .synchronized(synchronized_button)
    );

    wire debounced_button;
    debauncer #(
        .DEBOUNCE_CYCLES(125000000/10) // 10Hz (100ms)
    ) debounce(
        .clk(sysclk),
        .button(synchronized_button),
        .debounced(debounced_button)
    );

    wire edge_detected;
    edge_detector edge_detector(
        .clk(sysclk),
        .signal(debounced_button),
        .edge_detected(edge_detected)
    );

    reg status_reg = 0;
    always @(posedge sysclk) begin
        if (edge_detected) begin
            status_reg <= ~status_reg;
        end
    end

    assign status = status_reg;

    wire busy;
    uart_transmitter transmitter (
        .sysclk(sysclk),
        .data_ready(edge_detected),
        .busy(busy),
        .UART_TX(tx)
    );

endmodule

module synchronizer (
    input clk,
    input button,
    output reg synchronized
);

    reg internal;
    always @(posedge clk) begin
        internal <= button;
        synchronized <= internal;
    end

endmodule

module debauncer
    #(
        parameter DEBOUNCE_CYCLES = 125000000/10 // 10Hz (100ms)
    )
    (
    input clk,
    input button,
    output debounced
);
    // only output 1 when button is pressed for N cycles
    localparam STATE_IDLE = 2'b00;
    localparam STATE_DEBOUNCING = 2'b01;
    localparam STATE_PRESSED = 2'b10;

    reg [$clog2(DEBOUNCE_CYCLES):0] count = 0, next_count = 0;
    reg [1:0] state, next_state;

    always @(posedge clk) begin
        state <= next_state;
        count <= next_count;
    end

    always @(*) begin
        next_state = state;
        next_count = count;
        case (state)
            STATE_IDLE:
                begin
                    if (button) begin
                        next_state = STATE_PRESSED;
                        next_count = 0;
                    end
                end
            STATE_PRESSED:
                begin
                    if (button) begin
                        next_count = count + 1;
                        if (next_count == DEBOUNCE_CYCLES) begin
                            next_count = 0;
                            next_state = STATE_DEBOUNCING;
                        end
                    end else begin
                        next_state = STATE_IDLE;
                        next_count = 0;
                    end
                end
            STATE_DEBOUNCING:
                begin
                    if (!button) begin
                        next_state = STATE_IDLE;
                        next_count = 0;
                    end
                end
        endcase
    end

    assign debounced = (state == STATE_DEBOUNCING);

endmodule

module edge_detector (
    input clk,
    input signal,
    output edge_detected
);
    reg delayed;
    always @(posedge clk)
        delayed <= signal;
    assign edge_detected = signal && !delayed;
endmodule

module uart_transmitter #(
    parameter BAUD_LENGTH_IN_CYCLES = 125000000/115200,
    parameter DATA = 8'b01000001 // 'A'
)
(
    input sysclk,
    input data_ready,
    //input [7:0] data,
    output busy, // sending existing data, not accepting new data
    output UART_TX
);
    localparam MAX_BIT_SENT = 10;

    reg [$clog2(BAUD_LENGTH_IN_CYCLES):0] count = 0, next_count;
    reg [9:0] shifting_data, next_shifting_data;
    reg [3:0] bit_sent = 0, next_bit_sent;

    localparam STATE_IDLE = 1'b0;
    localparam STATE_BUSY = 1'b1;
    reg state = STATE_IDLE, next_state;
    reg all_sent;

    always @(*) begin
        next_state = state;
        if (state == STATE_IDLE && data_ready)
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
                    next_shifting_data = { 1'd1, DATA, 1'd0 };
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

    always @(posedge sysclk) begin
        count <= next_count;
        shifting_data <= next_shifting_data;
        bit_sent <= next_bit_sent;
        state <= next_state;
    end

    assign UART_TX = state == STATE_BUSY ? shifting_data[0] : 1'b1;
    assign busy = state == STATE_BUSY;

endmodule
