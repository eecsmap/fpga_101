module z1top(
    input sysclk,
    input UART_RX,
    output UART_TX
);

    // // self test
    // assign UART_TX = UART_RX;

    // send 'A's
    // 'A' = 0100_0001
    localparam SYS_CLK_FREQ = 125000000;
    localparam BAUD_RATE = 115200;
    localparam BAUD_LENGTH = SYS_CLK_FREQ / BAUD_RATE;
    // start_bit as 0, bit[0], bit[1], ..., bit[7], stop_bit as 1
    localparam MAX_CODE_PHASE = 10;

    reg [$clog2(MAX_CODE_PHASE):0] code_phase = MAX_CODE_PHASE - 1;
    reg [$clog2(BAUD_LENGTH):0] count = 0;

    always @(posedge sysclk) begin
        code_phase <= code_phase;
        count <= count + 1;
        if (count == BAUD_LENGTH - 1) begin
            count <= 0;
            code_phase <= code_phase == MAX_CODE_PHASE - 1 ? 0 : code_phase + 1;
        end
    end

    assign UART_TX = 
        (code_phase == 0) ? 0 : // start_bit
        (code_phase == 1) ? 1 : // bit[0]
        (code_phase == 2) ? 0 : // bit[1]
        (code_phase == 3) ? 0 : // bit[2]
        (code_phase == 4) ? 0 : // bit[3]
        (code_phase == 5) ? 0 : // bit[4]
        (code_phase == 6) ? 0 : // bit[5]
        (code_phase == 7) ? 1 : // bit[6]
        (code_phase == 8) ? 0 : // bit[7]
        (code_phase == 9) ? 1 : // stop_bit
        1; // idle as 1

endmodule
