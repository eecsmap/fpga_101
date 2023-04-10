module z1top #(
    parameter CYCLES_PER_BOUNCE = 125_000_000
) (
    input sysclk,
    input reset,
    output [3:0] led
);
    // configuration
    localparam PHASE_COUNT = 3;
    localparam BOUNCE_COUNT_PER_PHASE = 5;

    reg [$clog2(PHASE_COUNT):0] phase = 0, next_phase;
    reg [$clog2(CYCLES_PER_BOUNCE):0] cycle_count = 0, next_cycle_count;
    reg [$clog2(BOUNCE_COUNT_PER_PHASE):0] bounce_count = 0, next_bounce_count;

    always @(posedge sysclk) begin
        phase <= next_phase;
        cycle_count <= next_cycle_count;
        bounce_count <= next_bounce_count;
    end

    always @(*) begin
        next_phase = phase;
        next_cycle_count = cycle_count + 1;
        next_bounce_count = bounce_count;
        if (reset) begin
            next_phase = 0;
            next_cycle_count = 0;
            next_bounce_count = 0;
        end
        if (next_cycle_count == CYCLES_PER_BOUNCE) begin
            next_cycle_count = 0;
            next_bounce_count = bounce_count + 1;
            if (next_bounce_count == BOUNCE_COUNT_PER_PHASE) begin
                next_bounce_count = 0;
                next_phase = phase + 1;
                if (next_phase == PHASE_COUNT) begin
                    next_phase = 0;
                end
            end
        end
    end

    assign led = cycle_count < CYCLES_PER_BOUNCE / 10 * 9 ? 0 : 1 << phase;

endmodule
