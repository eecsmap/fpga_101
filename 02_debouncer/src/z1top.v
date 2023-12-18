`define CLOCK_FREQ 125_000_000

module z1top(
    input clk,
    input [3:0] BUTTONS,
    output [3:0] led,
    output [1:0] status_led
);
    // Button parser test circuit
    // Sample the button signal every 500us
    localparam integer B_SAMPLE_CNT_MAX = $rtoi(0.0005 * `CLOCK_FREQ);
    // The button is considered 'pressed' after 100ms of continuous pressing
    localparam integer B_PULSE_CNT_MAX = $rtoi(0.100 / 0.0005);
    wire [3:0] buttons_pressed;
    button_parser #(
        .WIDTH(4),
        .SAMPLE_CNT_MAX(B_SAMPLE_CNT_MAX),
        .PULSE_CNT_MAX(B_PULSE_CNT_MAX)
    ) bp (
        .clk(clk),
        .in(BUTTONS),
        .out(buttons_pressed),
        .led(status_led)
    );

    reg [3:0] count = 0;
    always @(posedge clk) begin
        if (buttons_pressed[0]) begin
            count <= count + 1;
        end
    end
    assign led = count;

endmodule
