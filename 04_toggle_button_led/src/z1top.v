module z1top(
    input BUTTON,
    output LED
);

    reg is_on = 0;

    // we naively assume that the button is not bouncing
    // yet this still cause warning/error in Vivado, addressed in constraints
    always @(posedge BUTTON) begin
        is_on <= ~is_on;
    end

    assign LED = is_on;

endmodule
