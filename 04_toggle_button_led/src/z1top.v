module z1top(
    input CLK_125MHZ_FPGA,
    input BUTTON,
    output LED
);

    reg is_on = 0;

    // this solution does not work well, but it is interesting to analyze the behavior
    // if you hold the button down, the LED will half way light up (it frequently toggles on and off which you cannot tell)
    // and when you release the button, the LED will stay on or off depending on the last state sampled by clock
    always @(posedge CLK_125MHZ_FPGA) begin
        is_on <= BUTTON ? ~is_on : is_on;
    end

    assign LED = is_on;

endmodule
