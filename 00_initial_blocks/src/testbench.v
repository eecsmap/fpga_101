`timescale 1ns/1ns

module testbench();

    reg clk = 0;
    always #1 clk = ~clk;

    integer i, j;
    initial begin
        $dumpfile("testbench.fst");
        $dumpvars(0, testbench);
        
        for (i = 0; i < 10; i = i + 1) begin
            $display("[1] time : %t", $time);
            @(posedge clk);
        end
    end

    initial begin
        for (j = 0; j < 10; j += 1) begin
            $display("[2] time : %t", $time);
            @(posedge clk);
        end
        $finish;
    end
endmodule
