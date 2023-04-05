module z1top(
    input sysclk,
    input data_ready,
    //input [7:0] data,
    output reg busy, // sending existing data, not accepting new data
    output UART_TX
);
    localparam DATA = 8'b01000001; // A
    localparam MAX_BIT_SENT = 10;
    localparam SYS_CLK_FREQ = 125000000;
    localparam BAUD_RATE = 115200;
    localparam BAUD_LENGTH_IN_CYCLES = SYS_CLK_FREQ / BAUD_RATE;

    reg [$clog2(BAUD_LENGTH_IN_CYCLES)-1:0] count = 0;
    reg [9:0] shifting_data;
    reg [3:0] bit_sent = 0;

    always @(posedge sysclk) begin
        // same question here, to avoid latch?
        if (busy) begin
            count <= count + 1;
            // Q: do I need to say shifting_data <= shifting_data here?
            // do I need to set count, shifting_data, bit_sent and busy here to avoid latch?
            if (count == BAUD_LENGTH_IN_CYCLES - 1) begin
                count <= 0;
                shifting_data <= shifting_data >> 1;
                if (bit_sent == MAX_BIT_SENT - 1) begin
                    busy <= 0;
                    bit_sent <= 0;
                end else begin
                    // Q: do I need to say busy <= 1 here?
                    bit_sent <= bit_sent + 1;
                end
            end
        end else begin
            // Q: same question here
            if (data_ready) begin // only check data_ready when not busy
                shifting_data <= { 1'd1, DATA, 1'd0 }; // start_bit as 0, stop_bit as 1
                busy <= 1;
                count <= 0;
                bit_sent <= 0;
            end
        end
    end

    assign UART_TX = busy ? shifting_data[0] : 1'b1;

endmodule
