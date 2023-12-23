module z1top(
    input [1:0] BUTTON,
    output [1:0] LED,
    output [1:0] PIN
);
    assign LED = BUTTON;
    assign PIN = BUTTON;
endmodule
