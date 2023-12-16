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

    reg [2:0] a=0;
    reg [2:0] b;

    always @(posedge sysclk) begin
        a <= 1;
        a <= 2;
        $display("1 %t a=%b, b=%b", $time, a, b);
        b <= a + 1;
        if (b == 1)
            $display("2 %t a=%b, b=%b", $time, a, b);
        else begin
            a = b + 1;
            b = a + 1;
            a = b + 1;
            $display("3 %t a=%b, b=%b", $time, a, b);
        end
    end

    assign UART_TX = a;
    assign busy = b;

endmodule
