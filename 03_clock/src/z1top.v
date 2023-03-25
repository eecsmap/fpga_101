module z1top(
    input CLK_125MHZ_FPGA,
    input RESET,
    output [3:0] LEDS
);

    reg [3:0] count;
    reg [31:0] internal_count;
    assign LEDS = count;

    always @(posedge CLK_125MHZ_FPGA) begin
        // synchronous reset
        if (RESET) begin
            // easy way to double check these values get set on all paths, here
            internal_count <= 0;
            count <= 0;
        end
        else begin
            if (internal_count == 125000000 - 1) begin
                // also here
                internal_count <= 0;
                count <= count + 1;
            end
            else begin
                // and here
                internal_count <= internal_count + 1;
                count <= count;
            end
        end
    end

endmodule
