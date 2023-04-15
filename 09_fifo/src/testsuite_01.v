$display("test case 1: read and write when empty");
rst = 1;
@(posedge clk); #1; rst = 0;
assert(full == 0);
assert(empty == 1);

din = 1;
wr_en = 1; rd_en = 1;
@(posedge clk); #1;
assert(full == 0);
assert(empty == 10);
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
