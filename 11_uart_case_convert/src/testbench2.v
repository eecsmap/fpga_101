`timescale 1ns/1ns

module testbench();

    reg clk = 0;
    always #5 clk = ~clk;
    reg tx;
    reg [7:0] data;
    reg data_ready;
    reg busy;

    localparam TEST_BAUD_LENGTH_IN_CYCLES = 4;
    uart_transmitter #(
        .BAUD_LENGTH_IN_CYCLES(TEST_BAUD_LENGTH_IN_CYCLES)
    ) ut (
        .sysclk(clk),
        .data(data),
        .data_ready(data_ready),
        .busy(busy),
        .UART_TX(tx)
    );

    // always @(posedge clk) begin
    //     $display("%t data_ready=%b, busy=%b, tx=%b", $time, data_ready, busy, tx);
    // end

    initial begin
        $dumpfile("testbench.fst");
        $dumpvars(0, testbench);
        
        fork
            begin
                // idle first
                data_ready = 0;
                @(posedge clk);
                #1;
                data_ready = 1;
                data = 8'b01011101;
                repeat (10 * TEST_BAUD_LENGTH_IN_CYCLES + 2) @(posedge clk); // make two test data send
                data_ready = 0;
                repeat (10 * TEST_BAUD_LENGTH_IN_CYCLES + 2) @(posedge clk);
            end
            while (data_ready == 1) begin
                //assert(busy == 0) else $error ("should be idle");
                assert(data_ready == 1) else $error ("should accept new data");
                @(posedge clk);
                assert(busy) else $error ("should be busy once data is accepted");
                assert(tx == 0) else $error ("start bit should be 0");
                repeat (TEST_BAUD_LENGTH_IN_CYCLES) @(posedge clk);
                assert(tx == 1) else $error ("data[0] 1");
                repeat (TEST_BAUD_LENGTH_IN_CYCLES) @(posedge clk);
                assert(tx == 0) else $error ("data[1] 0");
                repeat (TEST_BAUD_LENGTH_IN_CYCLES) @(posedge clk);
                assert(tx == 1) else $error ("data[2] 1");
                repeat (TEST_BAUD_LENGTH_IN_CYCLES) @(posedge clk);
                assert(tx == 1) else $error ("data[3] 1");
                repeat (TEST_BAUD_LENGTH_IN_CYCLES) @(posedge clk);
                assert(tx == 1) else $error ("data[4] 1");
                repeat (TEST_BAUD_LENGTH_IN_CYCLES) @(posedge clk);
                assert(tx == 0) else $error ("data[5] 0");
                repeat (TEST_BAUD_LENGTH_IN_CYCLES) @(posedge clk);
                assert(tx == 1) else $error ("data[6] 1");
                repeat (TEST_BAUD_LENGTH_IN_CYCLES) @(posedge clk);
                assert(tx == 0) else $error ("data[7] 0");
                repeat (TEST_BAUD_LENGTH_IN_CYCLES) @(posedge clk);
                assert(tx == 1) else $error ("stop bit should be 1");
                repeat (TEST_BAUD_LENGTH_IN_CYCLES) @(posedge clk);
                assert(busy == 0) else $error ("should be idle after stop bit");
            end
        join
        $finish();
    end

endmodule
