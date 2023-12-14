`timescale 1ns/1ns

module testbench();

    reg clk = 0;
    always #5 clk = ~clk;

    reg [2:0] value = 0;
    reg x = 1;
    always @(posedge clk) begin
        value <= value ^ {3{1'b1}};
        $display("value : %d", value);
    end

    initial begin
        $dumpfile("testbench.fst");
        $dumpvars(0, testbench);
        @(posedge clk) #1 $display("[out] value : %d", value);
        @(posedge clk) #1 $display("[out] value : %d", value);
        $finish;
    end

endmodule
