module z1top (
    input            clk,
    input      [7:0] a,
    output     [7:0] b,
    output reg [7:0] rb,
    output     [7:0] c
);
    assign b = a * a;      // low 8 bits of the 16-bit square
    assign c = rb + 8'd1;

    always @(posedge clk)
        rb <= b;
endmodule
