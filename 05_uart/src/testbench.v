`timescale 1ns/1ns

module testbench();

    reg clk = 0;
    always #5 clk = ~clk;
    reg tx;
    reg rx;

    z1top dut(
        .sysclk(clk),
        .UART_RX(rx),
        .UART_TX(tx)
    );

    initial begin
        $dumpfile("testbench.fst");
        $dumpvars(2, testbench);
        #1000;
        $finish();
    end

endmodule
