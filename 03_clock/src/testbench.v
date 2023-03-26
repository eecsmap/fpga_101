`timescale 1ps/1ps

module testbench();

    // create a clock of 8 units per cycle
    reg clk = 1'b0;
    always #(4) clk = ~clk;

    wire out1, out2;
    reg rst = 1'b0;

    sync_reset_pulse_generator #(.CYCLE(8)) sync_reset_pulse_gen(
        .clk(clk),
        .reset(rst),
        .out(out1)
    );

    async_reset_pulse_generator #(.CYCLE(8)) async_reset_pulse_gen(
        .clk(clk),
        .reset(rst),
        .out(out2)
    );

    initial begin
        $dumpfile("testbench.fst");
        $dumpvars(2, testbench);

        // we can print module internal values like this
        $display("pulse_gen.CYCLE: %d", sync_reset_pulse_gen.CYCLE);
        $display("pulse_gen.WIDTH: %d", sync_reset_pulse_gen.WIDTH);
 
        #(5);
        rst = 1'b1;
        #(1);
        rst = 1'b0;

        //#(8 * 7); // after 7 cycles
        repeat (7) @(posedge clk);
        # 1; // wait for 1 cycle, this is necessary to allow the pulse to propagate
        $display("time: %t", $time);
        assert(out1 == 1'b1);
        assert(out2 == 1'b0);
        #8; // after 8 cycles
        $display("time: %t", $time);
        assert(out1 == 1'b0);
        assert(out2 == 1'b1);

        $finish();
    end

endmodule
