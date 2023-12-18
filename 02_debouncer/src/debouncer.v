module debouncer #(
    parameter WIDTH              = 1,
    parameter SAMPLE_CNT_MAX     = 62500,
    parameter PULSE_CNT_MAX      = 200,
    parameter WRAPPING_CNT_WIDTH = $clog2(SAMPLE_CNT_MAX), // enough to represent [0..SAMPLE_CNT_MAX-1]
    parameter SAT_CNT_WIDTH      = $clog2(PULSE_CNT_MAX) + 1 // enough to represent [0..PULSE_CNT_MAX]
    // it is +1 because we don't need to wrap it back to 0
) (
    input clk,
    input [WIDTH-1:0] glitchy_signal,
    output [WIDTH-1:0] debounced_signal,
    output [1:0] led
);
    // assign debounced_signal = glitchy_signal;

    reg [WRAPPING_CNT_WIDTH-1:0] sample_count = 0;

`define REG_PULSE
`ifdef REG_PULSE
    assign led = 1;
    reg pulse = 0;
    always @(posedge clk) begin
        sample_count <= sample_count + 1;
        pulse <= 0;
        /* verilator lint_off WIDTHEXPAND */
        if (sample_count == SAMPLE_CNT_MAX - 1) begin
            /* verilator lint_on WIDTHEXPAND */
            sample_count <= 0;
            pulse <= 1;
        end
    end
`else
    assign led = 2;
    /* verilator lint_off WIDTHEXPAND */
    wire pulse = sample_count == SAMPLE_CNT_MAX - 1;
    /* verilator lint_on WIDTHEXPAND */
    always @(posedge clk) begin
        sample_count <= sample_count + 1;
        /* verilator lint_off WIDTHEXPAND */
        if (sample_count == SAMPLE_CNT_MAX - 1)
            /* verilator lint_on WIDTHEXPAND */
            sample_count <= 0;
    end
`endif

    /* verilator lint_off MULTIDRIVEN */
    reg [SAT_CNT_WIDTH-1:0] saturating_counter [WIDTH-1:0];
    /* verilator lint_on MULTIDRIVEN */
    integer i;
    initial begin
        for (i = 0; i < WIDTH; i = i + 1) begin
            saturating_counter[i] = 0;
        end
    end

    generate
        for (genvar i = 0; i < WIDTH; i = i + 1) begin
            /* verilator lint_off WIDTHEXPAND */
            assign debounced_signal[i] = saturating_counter[i] == PULSE_CNT_MAX;
            /* verilator lint_on WIDTHEXPAND */
        end
    endgenerate

    wire [WIDTH-1:0] reset = ~glitchy_signal;
    generate
        for (genvar i = 0; i < WIDTH; i = i + 1) begin
            always @(posedge pulse or posedge reset[i]) begin
                if (reset[i])
                    saturating_counter[i] <= 0;
                /* verilator lint_off WIDTHEXPAND */
                else if (saturating_counter[i] < PULSE_CNT_MAX)
                /* verilator lint_on WIDTHEXPAND */
                    saturating_counter[i] <= saturating_counter[i] + 1;
            end
        end
    endgenerate

endmodule
