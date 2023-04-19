`timescale 1ns/1ns

module testbench();

    reg clk = 0;
    always #1 clk = ~clk;
    reg rst;
    reg ready;
    wire valid;
    wire [1:0] data;
    reg rx;

    uart_receiver #(
        .BAUD_LENGTH_IN_CYCLES(1),
        .DATA_WIDTH(2),
        .STOP_BIT(1)) ur (
        .clk(clk),
        .rst(rst),
        .ready(ready),
        .valid(valid),
        .data(data),
        .uart_rx(rx)
    );

    // always @(posedge clk) begin
    //     $display("%t data_ready=%b, busy=%b, tx=%b", $time, data_ready, busy, tx);
    // end

    initial begin
        $dumpfile("testbench.fst");
        $dumpvars(0, testbench);
        rst = 1;
        rx = 1;
        ready = 0;
        @(posedge clk); #1;
        rst = 0;
        @(posedge clk); #1;
        rx = 0;
        @(posedge clk); #1;
        rx = 1;
        @(posedge clk); #1;
        rx = 0;
        @(posedge clk); #1;
        rx = 1;
        @(posedge clk); #1;
        assert(valid == 1) else $error ("should be valid but %d", valid);
        assert(data == 2'b01) else $error ("should be 01 but %d", data);
        // start second word
        rx = 0;
        @(posedge clk); #1;
        rx = 0;
        @(posedge clk); #1;
        rx = 1;
        @(posedge clk); #1;
        ready = 1;
        rx = 1; // stop bit
        @(posedge clk); #1;
        assert(valid == 1) else $error ("should be valid but %d", valid);
        assert(data == 2'b10) else $error ("should be 10 but %d", data);
        @(posedge clk); #1;

        @(posedge clk); #1;
        $finish();
    end

endmodule
