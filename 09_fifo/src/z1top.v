module z1top();
endmodule

module fifo #(
    parameter ADDR_WIDTH = 4,
    parameter DATA_WIDTH = 8
)(
    input clk,
    input rst,
    input wr_en,
    input [DATA_WIDTH-1:0] din,
    input rd_en,
    output [DATA_WIDTH-1:0] dout,
    output empty,
    output full
);

    localparam SIZE = 1 << ADDR_WIDTH;
    reg [DATA_WIDTH-1:0] mem [0:SIZE-1];
    reg [ADDR_WIDTH-1:0] wr_ptr;
    reg [ADDR_WIDTH-1:0] rd_ptr;
    reg [ADDR_WIDTH:0] cnt;

    always @(posedge clk) begin
        if (rst) begin
            wr_ptr <= 0;
            rd_ptr <= 0;
            cnt <= 0;
        end else begin
            if (rd_en && wr_en && !full && !empty) begin
                mem[wr_ptr] <= din;
                wr_ptr <= wr_ptr + 1;
                rd_ptr <= rd_ptr + 1;
            end else if (wr_en && !full) begin
                mem[wr_ptr] <= din;
                wr_ptr <= wr_ptr + 1;
                cnt <= cnt + 1;
            end else if (rd_en && !empty) begin
                rd_ptr <= rd_ptr + 1;
                cnt <= cnt - 1;
            end
        end
    end

    assign full = (cnt == SIZE);
    assign empty = (cnt == 0);
    assign dout = mem[rd_ptr];
endmodule