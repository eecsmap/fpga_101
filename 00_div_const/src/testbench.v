`timescale 1ns/1ns

module testbench();
    reg clk = 0;
    always #(5/2) clk = ~clk;

    initial begin
        $dumpfile("testbench.fst");
        $dumpvars(0, testbench);
        $display("5/2 = %f", 5/2);
        $display("-5/2 = %f", -5/2);
        $display("5/-2 = %f", 5/-2);
        $display("-5/-2 = %f", -5/-2);
        repeat (10) @(posedge clk);
        $finish;
    end
endmodule
