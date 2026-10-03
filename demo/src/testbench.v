`timescale 1ns/1ps
module testbench ();
    reg        clk = 0;
    reg  [7:0] a   = 0;
    wire [7:0] b, rb, c;

    z1top uut (.clk(clk), .a(a), .b(b), .rb(rb), .c(c));

    always #5 clk = ~clk;

    initial begin
        $dumpfile("testbench.vcd");
        $dumpvars(0, testbench);
        $monitor("t=%0t a=%0d b=%0d rb=%0d c=%0d", $time, a, b, rb, c);
        repeat (8) begin
            @(negedge clk) a = a + 8'd3;
        end
        @(negedge clk) a = 8'd16;   // 256 -> b wraps to 0
        @(negedge clk) a = 8'd255;
        #20 $finish;
    end
endmodule
