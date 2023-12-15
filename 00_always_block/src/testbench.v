`timescale 1ns/1ns

module testbench();

    reg clk = 0;
    always #1 clk = ~clk;

    reg [7:0] in = 0;
    reg [7:0] out = 0;

    // always @(*) begin
    always @(posedge clk) begin
        out <= in + 1;
        $display("time: %t, in: %d, out: %d", $time, in, out);
        out = out + 2;
        $display("time: %t, in: %d, out: %d", $time, in, out);
    end

    // time:                    2, in:   1, out:   0
    // time:                    2, in:   1, out:   2
    // time:                    4, in:   2, out:   2
    // time:                    4, in:   2, out:   3
    // time:                    6, in:   3, out:   3
    // time:                    6, in:   3, out:   4
    // time:                    8, in:   4, out:   4
    // time:                    8, in:   4, out:   5
    // time:                   10, in:   5, out:   5
    // time:                   10, in:   5, out:   6
    // time:                   12, in:   6, out:   6
    // time:                   12, in:   6, out:   7
    // time:                   14, in:   7, out:   7
    // time:                   14, in:   7, out:   8
    // time:                   16, in:   8, out:   8
    // time:                   16, in:   8, out:   9
    // this is because at time 2, first in change, and it prints 1, 0
    // then at the same cycle, out is updated to 2, then it prints 1, 2
    // always @(*) begin
    //     out <= in + 1;
    //     $display("time: %t, in: %d, out: %d", $time, in, out);
    // end

    integer i, j;
    initial begin
        $dumpfile("testbench.fst");
        $dumpvars(0, testbench);
        
        for (i = 1; i < 10; i = i + 1) begin
            @(posedge clk); #1 in = i;
        end
        $finish;
    end
endmodule
