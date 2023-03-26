module z1top(
    input CLK_125MHZ_FPGA,
    input RESET,
    output [3:0] LEDS
);

    wire pulse;
    reg [3:0] count;
    assign LEDS = count;

    async_reset_pulse_generator #(.CYCLE(125000000)) pulse_gen(
        .clk(CLK_125MHZ_FPGA),
        .reset(RESET),
        .out(pulse)
    );

    always @(posedge pulse, posedge RESET) begin
        if (RESET)
            count <= 0;
        else
            count <= count + 1;
    end

endmodule

module sync_reset_pulse_generator
    #(parameter CYCLE = 8)
    (
        input clk,
        input reset,
        output out
    );

    parameter WIDTH = $clog2(CYCLE);

    reg [WIDTH-1:0] count = 0;
    reg pulse;
    assign out = pulse;

    always @(posedge clk) begin
        if (reset) begin
            count <= 0;
            pulse <= 0;
        end
        else begin
            if (count == CYCLE - 1) begin
                count <= 0;
                pulse <= 1;
            end
            else begin
                count <= count + 1;
                pulse <= 0;
            end
        end
    end
endmodule

module async_reset_pulse_generator
    #(parameter CYCLE = 8)
    (
        input clk,
        input reset,
        output out
    );

    parameter WIDTH = $clog2(CYCLE);

    reg [WIDTH-1:0] count = 0;
    reg pulse;
    assign out = pulse;

    always @(posedge clk, posedge reset) begin
        if (reset) begin
            count <= 0;
            pulse <= 0;
        end
        else begin
            if (count == CYCLE - 1) begin
                count <= 0;
                pulse <= 1;
            end
            else begin
                count <= count + 1;
                pulse <= 0;
            end
        end
    end
endmodule