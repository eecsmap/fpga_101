`timescale 1ns/1ns

module testbench();

    reg logger = 0;
    always #1 logger = ~logger;

    reg clk = 0;
    always #5 clk = ~clk;

    reg rst;
    reg [7:0] din;
    reg wr_en;
    reg rd_en;
    wire full;
    wire empty;
    wire [7:0] dout;


    fifo #(.ADDR_WIDTH(1), .DATA_WIDTH(8)) a_fifo(
        .clk(clk),
        .rst(rst),
        .din(din),
        .wr_en(wr_en),
        .rd_en(rd_en),
        .full(full),
        .empty(empty),
        .dout(dout)
    );

    // always @(posedge clk) begin
    //     $display("time=%t clk=%b rst=%b din=%b wr_en=%b rd_en=%b full=%b empty=%b dout=%b",
    //         $time, clk, rst, din, wr_en, rd_en, full, empty, dout);
    // end

    initial begin
        $dumpfile("testbench.fst");
        $dumpvars(0, testbench);

        `include "testsuite_01.v"
        $finish;
    end
endmodule
