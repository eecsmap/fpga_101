`timescale 1ns/1ns

module testbench();

    reg clk = 0;
    always #4 clk = ~clk;

    reg synchronized_signals;
    wire debounced_signals;
    debouncer # (
        .WIDTH(1),
        .SAMPLE_CNT_MAX(4),
        .PULSE_CNT_MAX(2)
    ) button_debouncer (
        .clk(clk),
        .glitchy_signal(synchronized_signals),
        .debounced_signal(debounced_signals)
    );

    initial begin
        $dumpfile("testbench.fst");
        $dumpvars(0, testbench);

        synchronized_signals = 1;
        @(posedge clk);
        synchronized_signals = 0;
        @(posedge clk);
        synchronized_signals = 1;
        repeat (3) @(posedge clk);
        synchronized_signals = 0;
        @(posedge clk);
        synchronized_signals = 1;
        repeat (4) @(posedge clk);
        synchronized_signals = 0;
        @(posedge clk);
        synchronized_signals = 1;
        repeat (8) @(posedge clk);
        synchronized_signals = 0;
        @(posedge clk);
        $finish;
    end

endmodule
