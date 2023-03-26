`timescale 1ns/1ns

module testbench();

    // task as a function
    task say_a_n_times(input [31:0] n);
        for (int i = 0; i < n; i = i + 1) begin
            #1;
            $display("a @ %t", $time);
        end
    endtask

    task say_b_n_times(input [31:0] n);
        for (int i = 0; i < n; i = i + 1) begin
            #1;
            $display("b @ %t", $time);
        end
    endtask

    initial begin
        fork
            say_a_n_times(3); // this line
            say_b_n_times(5); // and this line will be executed in parallel
        join
        // this line will be executed after the above
        fork
            say_a_n_times(2);
        join
        $finish();
    end

endmodule
