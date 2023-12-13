`timescale 1ns/1ns

module testbench();

    initial begin
        // $dumpfile("testbench.fst");
        // $dumpvars(0, testbench);
        fork
            begin
                $display("[1] time: %t", $time);
                #1;
                $display("[1]time: %t", $time);
                #1;
                $display("[1]time: %t", $time);
            end
            begin
                $display("[2] time: %t", $time);
                #2;
                $display("[2]time: %t", $time);
            end
        join
        $finish;
    end

endmodule
