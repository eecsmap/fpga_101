`timescale 1ns/1ns

module testbench();

    reg clk = 0;
    always #5 clk = ~clk;

    demo dut(clk);

    initial begin
        $dumpfile("testbench.fst");
        $dumpvars(2, testbench);
        $display("testbench started");

        #1000;
        $finish();
    end

endmodule

module demo (
    input clk
);

    reg [7:0] count = 0;
    always @(posedge clk) begin
        $display("clk = %d", clk); // always 1
        $display("count_0 = %d", count); // print count before ff
        count = count + 1;  // blocking assignment, still before ff
        $display("count_1 = %d", count); // print count before ff
        count <= count + 1; // non-blocking assignment, in ff
    end

endmodule
