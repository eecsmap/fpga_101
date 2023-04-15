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

    initial begin
        $dumpfile("testbench.fst");
        $dumpvars(0, testbench);

        $display("test case 1: read and write when empty");
        rst = 1;
        @(posedge clk); #1; rst = 0;
        assert(full == 0);
        assert(empty == 1);

        din = 1;
        wr_en = 1; rd_en = 1;
        @(posedge clk); #1;
        assert(full == 0);
        assert(empty == 0);
        assert(dout == 1);

        $display("test case 2: write when not full");
        rd_en = 0;
        din = 2;
        @(posedge clk); #1;
        assert(full == 1);
        assert(empty == 0);
        assert(dout == 1);

        $display("test case 3: write when full");
        din = 3;
        @(posedge clk); #1;
        assert(full == 1);
        assert(empty == 0);
        assert(dout == 1);

        $display("test case 4: read and write when full");
        rd_en = 1;
        din = 4;
        @(posedge clk); #1;
        assert(full == 0);
        assert(empty == 0);
        assert(dout == 2);

        $display("test case 5: read and write when not empty and not full");
        din = 5;
        @(posedge clk); #1;
        assert(full == 0);
        assert(empty == 0);
        assert(dout == 5);

        $display("test case 6: read when not empty");
        wr_en = 0;
        @(posedge clk); #1;
        assert(full == 0);
        assert(empty == 1);
        assert(dout == 2);

        $display("test case 7: read when empty");
        @(posedge clk); #1;
        assert(full == 0);
        assert(empty == 1);
        assert(dout == 2);
        rd_en = 0;

        $finish;
    end
endmodule
