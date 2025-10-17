module and2(
    input a,
    input b,
    output c
);

    assign c = a & b;

endmodule

module test();
    reg x;
    reg y;
    wire z;

    and2 uut (
        .a(x),
        .b(y),
        .c(z)
    );

    initial begin
        $monitor("time: %0t, a: %b, b: %b, c: %b", $time, x, y, z); // you have to put this first
        $dumpfile("and2.vcd");
        $dumpvars(0, test);
        x = 0;
        y = 0;
        #1 y = 1;
        #2 x = 1;
        #4 y = 0;
        #7 x = 0;
    end
endmodule
