`timescale 1ns/1ns

module testbench();

    reg clk = 0;
    always #1 clk = ~clk;

    reg [7:0] in = 0;
    reg [7:0] out = 0;

    reg B, C, D;
    wire A = in;
    // time:                    2, A: 1, B: x, C: x, D: x
    // time:                    2, A: 1, B: 1, C: x, D: x
    // time:                    2, A: 1, B: 1, C: 1, D: x
    // time:                    2, A: 1, B: 1, C: 1, D: 1
    // time:                    4, A: 0, B: 1, C: 1, D: 1
    // time:                    4, A: 0, B: 0, C: 1, D: 1
    // time:                    4, A: 0, B: 0, C: 0, D: 1
    // time:                    4, A: 0, B: 0, C: 0, D: 0
    // always @(*) begin
    //     B <= A;
    //     C <= B;
    //     D <= C;
    //     $display("time: %t, A: %d, B: %d, C: %d, D: %d", $time, A, B, C, D);
    // end

    // time:                    2, A: 1, B: 1, C: 1, D: 1
    // time:                    4, A: 0, B: 0, C: 0, D: 0
    // time:                    6, A: 1, B: 1, C: 1, D: 1
    // time:                    8, A: 0, B: 0, C: 0, D: 0
    // time:                   10, A: 1, B: 1, C: 1, D: 1
    // time:                   12, A: 0, B: 0, C: 0, D: 0
    // time:                   14, A: 1, B: 1, C: 1, D: 1
    // time:                   16, A: 0, B: 0, C: 0, D: 0
    always @(*) begin
        B = A;
        C = B;
        D = C;
        $display("time: %t, A: %d, B: %d, C: %d, D: %d", $time, A, B, C, D);
    end

    // always @(*) begin
    //     out <= in + 1;
    //     $display("[1] time: %t, in: %d, out: %d", $time, in, out);
    //     out = out + 2;
    //     $display("[2] time: %t, in: %d, out: %d", $time, in, out);
    // end
    // [1] 2, 1, 0 ->2
    // [2] 2, 1, 2
    // [1] 4, 2, 2 ->3
    // [2] 4, 2, 4
    // [1] 4, 2, 3
    // [2] 4, 2, 5
    // [1] 4, 2, 3
    // [2] 4, 2, 5
    // [1] 4, 2, 3
    // [2] 4, 2, 5
    // ...

    // [1] time:                    1, in:   0, out:   0
    // [2] time:                    1, in:   0, out:   2
    // [1] time:                    3, in:   1, out:   1
    // [2] time:                    3, in:   1, out:   3
    // [1] time:                    5, in:   2, out:   2
    // [2] time:                    5, in:   2, out:   4
    // [1] time:                    7, in:   3, out:   3
    // [2] time:                    7, in:   3, out:   5
    // [1] time:                    9, in:   4, out:   4
    // [2] time:                    9, in:   4, out:   6
    // [1] time:                   11, in:   5, out:   5
    // [2] time:                   11, in:   5, out:   7
    // [1] time:                   13, in:   6, out:   6
    // [2] time:                   13, in:   6, out:   8
    // [1] time:                   15, in:   7, out:   7
    // [2] time:                   15, in:   7, out:   9
    // [1] time:                   17, in:   8, out:   8
    // [2] time:                   17, in:   8, out:  10
    // always @(posedge clk) begin
    //     out <= in + 1;
    //     $display("[1] time: %t, in: %d, out: %d", $time, in, out);
    //     out = out + 2;
    //     $display("[2] time: %t, in: %d, out: %d", $time, in, out);
    // end

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
