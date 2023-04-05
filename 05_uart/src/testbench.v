`timescale 1ns/1ns

module testbench();

    reg clk = 0;
    always #5 clk = ~clk;
    reg tx;
    reg rx;
    reg data_ready;
    reg busy;

    z1top dut(
        .sysclk(clk),
        .data_ready(data_ready),
        .busy(busy),
        .UART_TX(tx)
    );

    initial begin
        $dumpfile("testbench.fst");
        $dumpvars(2, testbench);

        data_ready = 1;
        # 6;
        data_ready = 0;
        #1000;
        $finish();
    end

endmodule
