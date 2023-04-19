`timescale 1ns/1ns

module testbench();

    reg clk = 0;
    always #1 clk = ~clk;
    reg rst;
    wire data_in_ready;
    reg data_in_valid;
    reg [7:0] data_in;
    reg data_out_ready;
    wire data_out_valid;
    wire [7:0] data_out;

    controller c(
        .clk(clk),
        .rst(rst),
        .data_in_ready(data_in_ready),
        .data_in_valid(data_in_valid),
        .data_in(data_in),
        .data_out_ready(data_out_ready),
        .data_out_valid(data_out_valid),
        .data_out(data_out)
    );

    initial begin
        $dumpfile("testbench.fst");
        $dumpvars(0, testbench);

        rst = 1;
        @(posedge clk); #1;

        rst = 0;
        data_in_valid = 0;
        data_out_ready = 0;
        @(posedge clk); #1;

        // try to read and write at the same time
        data_in = 8'b00000001;
        data_in_valid = 1;
        data_out_ready = 1;

        @(posedge clk); #1;
        // after the first clock cycle, the data should be read
        // and it should inform the data to provide the next data
        assert(data_in_ready == 0) else $error ("data_in_ready should be 0 but %d", data_in_ready);

        @(posedge clk); // this could be optimized
        data_in = 8'b00000010; // provide the next data since data_in_ready
        #1;
        assert(data_out_valid == 1) else $error ("data_out_valid should be 1 but %d", data_out_valid);
        assert(data_out == 8'b00000001) else $error ("data_out should be 8'b00000001 but %d", data_out);

        @(posedge clk); #1;
        data_out_ready = 0; // allow consumer to consume the data

        @(posedge clk); #1;
        // provider put the third data
        data_in = 8'b00000011;
        data_in_valid = 1;

        @(posedge clk); #1;
        data_out_ready = 1; // consumer is ready to take the next data

        @(posedge clk); #1;
        assert(data_out_valid == 1) else $error ("data_out_valid should be 1 but %d", data_out_valid);
        assert(data_out == 8'b00000010) else $error ("data_out should be 8'b00000010 but %d", data_out);
        
        @(posedge clk); #1; // this could be optimized, allow data <= data_in
        data_in_valid = 0; // stop providing data

        @(posedge clk); #1; // data_out <= data
        assert(data_out == 8'b00000011) else $error ("data_out should be 8'b00000011 but %d", data_out);
        data_out_ready = 0; // consumer is not ready to take the next data
        assert(data_out_valid == 1) else $error ("data_out_valid should be 1 but %d", data_out_valid);
        @(posedge clk); #1;
        data_out_ready = 1;
        @(posedge clk); #1;
        assert(data_out_valid == 0) else $error ("data_out_valid should be 0 but %d", data_out_valid);
        $finish();
    end

endmodule
