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
