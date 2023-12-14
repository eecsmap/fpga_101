`timescale 1ns/1ns

module testbench();

    reg clk = 0;
    always #1 clk = ~clk;

    reg [2:0] value = 0;

    always @(posedge clk) begin
        value <= 1;
        $display("1 %t value=%b", $time, value);
        value <= 2;
        $display("2 %t value=%b", $time, value);
        value <= value + 1;
        $display("3 %t value=%b", $time, value);
        if (value == 1)
            $display("4 %t value=%b", $time, value);
        else begin
            value = value + 1;
            $display("5 %t value=%b", $time, value);
            value = value + 1;
            $display("6 %t value=%b", $time, value);
            value = value + 1;
            $display("7 %t value=%b", $time, value);
        end
    end

    initial begin
        $dumpfile("testbench.fst");
        $dumpvars(0, testbench);
        @(posedge clk) #1 $display("[out 1] value : %b", value);
        @(posedge clk) #1 $display("[out 2] value : %b", value);
        $finish;
    end

endmodule
