module z1top #(
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
