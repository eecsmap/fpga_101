module z1top(
    input sysclk,
    input data_ready,
    //input [7:0] data,
    output busy, // sending existing data, not accepting new data
    output UART_TX
);
    localparam DATA = 8'b01000001; // A

    localparam MAX_BIT_SENT = 10;
    localparam SYS_CLK_FREQ = 125000000;
    localparam BAUD_RATE = 115200;
    localparam BAUD_LENGTH_IN_CYCLES = 3;//SYS_CLK_FREQ / BAUD_RATE;

    reg [$clog2(BAUD_LENGTH_IN_CYCLES)-1:0] count;
    reg [3:0] bit_sent; // wide enough to hold MAX_BIT_SENT
    reg [9:0] shifting_data;

    localparam STATE_IDLE = 1'b0;
    localparam STATE_BUSY = 1'b1;
    reg state = STATE_IDLE;

    wire baud_end = state == STATE_BUSY && count == BAUD_LENGTH_IN_CYCLES - 1 ? 1 : 0; // level signal

    wire [$clog2(BAUD_LENGTH_IN_CYCLES)-1:0] next_count = state == STATE_BUSY ? count == BAUD_LENGTH_IN_CYCLES - 1 ? 0 : count + 1 : 0;

    wire [3:0] next_bit_sent = state == STATE_BUSY ? baud_end ? bit_sent == MAX_BIT_SENT - 1 ? 0 : bit_sent + 1 : bit_sent : 0;

    wire [9:0] next_data = state == STATE_BUSY ? baud_end ? all_sent ? shifting_data : shifting_data >> 1 : shifting_data >> 1 : { 1'd1, DATA, 1'd0 };
    wire all_sent = state == STATE_BUSY && baud_end && bit_sent == MAX_BIT_SENT - 1 ? 1 : 0;
    wire next_state = state == STATE_IDLE ? data_ready : !all_sent;

    always @(posedge sysclk) begin
        count <= next_count;
        bit_sent <= next_bit_sent;
        shifting_data <= next_data;
        state <= next_state;
    end

    assign UART_TX = state == STATE_IDLE ? 1'b1 : shifting_data[0];
    assign busy = state;

endmodule
