`timescale 1ns/1ns

module testbench();

    reg clk = 0;
    always #5 clk = ~clk;

    reg sig = 0;
    always #1 sig = ~sig;
    wire inv1;
    wire inv2;

    reg [128:0] count = -1;
    wire [32:0] next_count = count + 1;

    always @(posedge clk) begin
        //count <= count + 1;
        $display("%d %d %d", count, count+2, next_count);
    end

    initial begin
        $dumpfile("testbench.fst");
        $dumpvars(0, testbench);
        #200;
        $finish;
    end

endmodule

module invert(input clk, input sig, output inv1, output reg inv2);

    assign inv1 = ~sig;
    always @(*) begin
        inv2 <= ~sig;
    end

endmodule

module valid_ready(
    input clk,
    input reset,
    input [7:0] data_in,
    output [7:0] data_out,
    output valid_out,
    input ready_in
);

    reg [7:0] data_out_reg;
    reg valid_out_reg;

    // 状态机的定义
    localparam IDLE = 2'b00;
    localparam READY = 2'b01;
    localparam SEND = 2'b10;
    reg [1:0] state_reg;
    always @(posedge clk, posedge reset) begin
        if(reset) begin
            state_reg <= IDLE;
        end
        else begin
            case(state_reg)
                IDLE: begin
                    valid_out_reg <= 0;
                    if(ready_in) begin
                        state_reg <= READY;
                    end
                end
                READY: begin
                    valid_out_reg <= 1;
                    if(!ready_in) begin
                        state_reg <= IDLE;
                    end
                    else begin
                        state_reg <= SEND;
                    end
                end
                SEND: begin
                    valid_out_reg <= 0;
                    data_out_reg <= data_in;
                    state_reg <= IDLE;
                end
                default: state_reg <= IDLE;
            endcase
        end
    end

    assign data_out = data_out_reg;
    assign valid_out = valid_out_reg;

endmodule

module memory();
    parameter DEPTH = 128;
    parameter WORD_WIDTH = 32;
    parameter BYTES = WORD_WIDTH / 8;
    parameter ADDR_WIDTH = $clog2(DEPTH);

endmodule
