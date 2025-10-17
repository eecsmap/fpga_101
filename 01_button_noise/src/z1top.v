// demo the button noise issue where no debounce is done
// you will find that pressing the button may toggle the LED multiple times

module z1top(
    input BUTTON,
    output LED
);
    reg is_on;
    always @(posedge BUTTON) begin
        is_on <= ~is_on;
    end
    assign LED = is_on;
endmodule
