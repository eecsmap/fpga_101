`timescale 1ns/1ns

module testbench();

    reg clk = 0;
    always #5 clk = ~clk;

    reg reset;
    reg [3:0] led;

    z1top #(
        .CYCLES_PER_BOUNCE(5)
    ) top (
        .sysclk(clk),
        .reset(reset),
        .led(led)
    );

    initial begin
        $dumpfile("testbench.fst");
        $dumpvars(0, testbench);
        reset = 1;
        @(posedge clk); #1; reset = 0;
        #1000;
        $finish();
    end

endmodule
