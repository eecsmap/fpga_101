module edge_detector #(
    parameter WIDTH = 1
)(
    input clk,
    input [WIDTH-1:0] signal_in,
    output [WIDTH-1:0] edge_detect_pulse
);
    // TODO: implement a multi-bit edge detector that detects a rising edge of 'signal_in[x]'
    // and outputs a one-cycle pulse 'edge_detect_pulse[x]' at the next clock edge
    // Feel free to use as many number of registers you like

    reg [WIDTH-1:0] delayed_signal;
    reg [WIDTH-1:0] edge_detect;
    always @(posedge clk) begin
        delayed_signal <= signal_in;
        edge_detect <= ~delayed_signal & signal_in;
    end
    assign edge_detect_pulse = edge_detect;

    // the following might work but no a good idea since it is combinational logic
    // and instantly changes when signal_in changes
    // also, the edge_detect_pulse should be a pulse of 1 clock cycle shown in the next clock edge
    // which this code does not do, it is a pulse of 1 clock cycle shown in the same clock edge
    // assign edge_detect_pulse = ~delayed_signal & signal_in;

    // Remove this line once you create your edge detector
    // assign edge_detect_pulse = 0;
endmodule
