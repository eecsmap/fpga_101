module z1top #(
    parameter CYCLES_PER_BOUNCE = 125_000_000
) (
    input sysclk,
    input reset,
    output [3:0] leds
);
    // configuration
    localparam PHASE_COUNT = 4;
    localparam BOUNCE_COUNT_PER_PHASE = 4;

    reg [$clog2(PHASE_COUNT):0] phase = 0, next_phase;
    reg [$clog2(CYCLES_PER_BOUNCE):0] cycle_count = 0, next_cycle_count;
    reg [$clog2(BOUNCE_COUNT_PER_PHASE):0] bounce_count = 0, next_bounce_count;
    reg bounce = 0, next_bounce;

    always @(posedge sysclk) begin
        phase <= next_phase;
        cycle_count <= next_cycle_count;
        bounce_count <= next_bounce_count;
        bounce <= next_bounce;
    end

    always @(*) begin
        next_bounce = 0;
        next_phase = phase;
        next_cycle_count = cycle_count + 1;
        next_bounce_count = bounce_count;
        if (reset) begin
            next_bounce = 0;
            next_phase = 0;
            next_cycle_count = 0;
            next_bounce_count = 0;
        end
        if (next_cycle_count == CYCLES_PER_BOUNCE) begin
            next_cycle_count = 0;
            // next_bounce_count = bounce_count + 1; // NOTE: think why
            next_bounce = 1;
        end
        if (next_bounce_count == BOUNCE_COUNT_PER_PHASE) begin
            next_bounce_count = 0;
            next_phase = phase + 1;
        end
        if (next_phase == PHASE_COUNT) begin
            next_phase = 0;
        end
        // NOTE: think why
        if (bounce) begin
            next_bounce_count = bounce_count + 1;
        end
    end

    assign leds = bounce << phase;

endmodule
