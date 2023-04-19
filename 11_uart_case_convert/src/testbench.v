`timescale 1ns/1ns

module testbench();

    reg clk = 0;
    always #1 clk = ~clk;
    reg rst;
    reg ready;
    wire valid;
    wire [7:0] data;
    reg rx;

    uart_receiver #(
        .BAUD_LENGTH_IN_CYCLES(3)
    ) ur (
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
        rx = 0;
        @(posedge clk); #1;
        rx = 0;
        @(posedge clk); #1;
        rx = 0; // [0]
        @(posedge clk); #1;
        rx = 0; // [0]
        @(posedge clk); #1;
        rx = 0; // [0]
        @(posedge clk); #1;
        rx = 1;
        @(posedge clk); #1;
        rx = 1;
        @(posedge clk); #1;
        rx = 1;
        @(posedge clk); #1;
        rx = 0;
        @(posedge clk); #1;
        rx = 0;
        @(posedge clk); #1;
        rx = 0;
        @(posedge clk); #1;
        rx = 0;
        @(posedge clk); #1;
        rx = 0;
        @(posedge clk); #1;
        rx = 0;
        @(posedge clk); #1;
        rx = 0;
        @(posedge clk); #1;
        rx = 0;
        @(posedge clk); #1;
        rx = 0;
        @(posedge clk); #1;
        rx = 0;
        @(posedge clk); #1;
        rx = 0;
        @(posedge clk); #1;
        rx = 0;
        @(posedge clk); #1;
        rx = 1;
        @(posedge clk); #1;
        rx = 1;
        @(posedge clk); #1;
        rx = 1;
        @(posedge clk); #1;
        rx = 0;
        @(posedge clk); #1;
        rx = 0;
        @(posedge clk); #1;
        rx = 0;
        @(posedge clk); #1;
        rx = 1; // stop bit
        @(posedge clk); #1;
        rx = 1; // stop bit
        @(posedge clk); #1;
        rx = 1; // stop bit
        @(posedge clk); #1;
        assert(valid == 1) else $error ("should be valid but %d", valid);
        assert(data == 8'b01000010) else $error ("data is %d", data);
        // start second word

        $finish();
    end

endmodule
