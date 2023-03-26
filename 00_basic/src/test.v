`timescale 1ns/1ns
// timescale (simulation time unit)/(simulation resolution)
// so if we have timescale 1ns/1ps, then we can specify interval as 1.001
// if we have timescale 1ns/1ns, then we can specify interval as integers

`define NS_PER_SEC 1000000000
// you can define macros like this

// this is the top module for simulation, normally named as testbench
module test_module();
    // define input and output ports
    reg x;
    reg y = 0; // we can set initial value here
    wire z;

    //top_module top(x, y, z);
    top_module top(.a(x), .b(y), .c(z)); // this is preferred way to connect ports

    initial begin

        `ifdef DEBUG
            $display("DEBUG is defined");
            $display("You can print messages this way ...");
        `else
            $display("DEBUG is not defined");
        `endif

        $dumpfile("test.fst");

        // 0, dump no variables
        // 1, dump all variables in the scope
        // 2, dump all variables in the scope and all subscopes
        // if not specified, default to 1
        $dumpvars(2, test_module);

        x = 1'b0;
        y = 1'b0;
        #(1); // let pass one time unit (1ns in this case)
        assert(z == 1'b0); // it will print an error message otherwise

        x = 1'b0;
        y = 1'b1;
        #(2); // let go 2 time units
        assert(z == 1'b1) else $display("Expected z to be 1, actual value: %d", z); // no line number in error though

        x = 1'b1;
        y = 1'b0;
        #(2);
        if (z != 1'b1) begin
            $error("Expected z to be 1, actual value: %d", z);
            // $fatal(1); // to stop execution
        end 

        x = 1'b1;
        y = 1'b1;
        #(1);
        if (z != 1'b0) begin
            $error("Expected z to be 0, actual value: %d", z);
            $fatal(1); // to stop execution
        end

        $finish();
    end
endmodule
