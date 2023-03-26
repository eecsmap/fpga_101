`timescale 1ns/1ns

module test_module();
    reg x;
    reg y;
    wire z;

    top_module top(x, y, z);

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

        x = 1'd0;
        y = 1'd0;
        #(1); // let pass one time unit (1ns in this case)
        assert(z == 1'd0); // it will print an error message otherwise

        x = 1'd0;
        y = 1'd1;
        #(2); // let go 2 time units
        assert(z == 1'd1) else $display("Expected z to be 1, actual value: %d", z); // no line number in error though

        x = 1'd1;
        y = 1'd0;
        #(2);
        if (z != 1'd1) begin
            $error("Expected z to be 1, actual value: %d", z);
            // $fatal(1); // to stop execution
        end 

        x = 1'd1;
        y = 1'd1;
        #(1);
        if (z != 1'd0) begin
            $error("Expected z to be 0, actual value: %d", z);
            $fatal(1); // to stop execution
        end

        $finish();
    end
endmodule
