module z1top(
    input [1:0] BUTTONS,
    output [3:0] LEDS
);

    assign LEDS[0] = BUTTONS[0] & BUTTONS[1];
    assign LEDS[1] = BUTTONS[0] | BUTTONS[1];
    assign LEDS[2] = BUTTONS[0] ^ BUTTONS[1];
    assign LEDS[3] = ~BUTTONS[0];

endmodule
