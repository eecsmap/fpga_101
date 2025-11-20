module z1top(
    input CLK_125MHZ_FPGA,
    input [3:0] BUTTONS,
    output [3:0] LEDS,
    output [3:0] vga_r,
    output [3:0] vga_g,
    output [3:0] vga_b,
    output vga_hs,
    output vga_vs
);

    // VGA 640x480 @ 60Hz timing
    // Pixel clock: 25.175 MHz (standard), we'll use 125/5 = 25 MHz
    
    // Clock divider: 125 MHz / 5 = 25 MHz (very close to 25.175 MHz)
    reg [2:0] clk_count;
    reg pixel_clk_en;
    
    always @(posedge CLK_125MHZ_FPGA) begin
        if (clk_count == 4) begin
            clk_count <= 0;
            pixel_clk_en <= 1;
        end else begin
            clk_count <= clk_count + 1;
            pixel_clk_en <= 0;
        end
    end
    
    // VGA timing counters
    reg [9:0] h_count;
    reg [9:0] v_count;
    
    // VGA 640x480 @ 60Hz timing parameters
    localparam H_DISPLAY = 640;
    localparam H_FRONT = 16;
    localparam H_SYNC = 96;
    localparam H_BACK = 48;
    localparam H_TOTAL = 800;   // 640+16+96+48
    
    localparam V_DISPLAY = 480;
    localparam V_FRONT = 10;
    localparam V_SYNC = 2;
    localparam V_BACK = 29;
    localparam V_TOTAL = 521;   // 480+10+2+29
    
    // Horizontal and vertical counters
    always @(posedge CLK_125MHZ_FPGA) begin
        if (pixel_clk_en) begin
            if (h_count == H_TOTAL - 1) begin
                h_count <= 0;
                // Vertical counter
                if (v_count == V_TOTAL - 1)
                    v_count <= 0;
                else
                    v_count <= v_count + 1;
            end else begin
                h_count <= h_count + 1;
            end
        end
    end
    
    // Sync signals (negative polarity for 640x480@60Hz)
    assign vga_hs = ~((h_count >= (H_DISPLAY + H_FRONT)) && 
                      (h_count < (H_DISPLAY + H_FRONT + H_SYNC)));
    assign vga_vs = ~((v_count >= (V_DISPLAY + V_FRONT)) && 
                      (v_count < (V_DISPLAY + V_FRONT + V_SYNC)));
    
    // Display enable
    wire display_enable;
    assign display_enable = (h_count < H_DISPLAY) && (v_count < V_DISPLAY);
    
    // Pattern selection based on button
    wire [1:0] pattern_sel;
    assign pattern_sel = {BUTTONS[1], BUTTONS[0]};
    
    // Pattern generation
    reg [3:0] red, green, blue;
    
    always @(*) begin
        if (!display_enable) begin
            red = 4'b0000;
            green = 4'b0000;
            blue = 4'b0000;
        end else begin
            case (pattern_sel)
                2'b00: begin // Color bars (scaled for 640 width)
                    if (h_count < 80) begin
                        red = 4'hF; green = 4'hF; blue = 4'hF; // White
                    end else if (h_count < 160) begin
                        red = 4'hF; green = 4'hF; blue = 4'h0; // Yellow
                    end else if (h_count < 240) begin
                        red = 4'h0; green = 4'hF; blue = 4'hF; // Cyan
                    end else if (h_count < 320) begin
                        red = 4'h0; green = 4'hF; blue = 4'h0; // Green
                    end else if (h_count < 400) begin
                        red = 4'hF; green = 4'h0; blue = 4'hF; // Magenta
                    end else if (h_count < 480) begin
                        red = 4'hF; green = 4'h0; blue = 4'h0; // Red
                    end else if (h_count < 560) begin
                        red = 4'h0; green = 4'h0; blue = 4'hF; // Blue
                    end else begin
                        red = 4'h0; green = 4'h0; blue = 4'h0; // Black
                    end
                end
                
                2'b01: begin // Gradient
                    red = h_count[9:6];
                    green = v_count[9:6];
                    blue = (h_count[9:6] + v_count[9:6]) >> 1;
                end
                
                2'b10: begin // Checkerboard
                    if ((h_count[5] ^ v_count[5]) == 1'b1) begin
                        red = 4'hF; green = 4'hF; blue = 4'hF;
                    end else begin
                        red = 4'h0; green = 4'h0; blue = 4'h0;
                    end
                end
                
                2'b11: begin // Red/Green grid
                    if (h_count[5:0] == 0 || v_count[5:0] == 0) begin
                        red = 4'hF; green = 4'hF; blue = 4'hF; // White grid
                    end else if (v_count < 240) begin
                        red = 4'hF; green = 4'h0; blue = 4'h0; // Red top
                    end else begin
                        red = 4'h0; green = 4'hF; blue = 4'h0; // Green bottom
                    end
                end
            endcase
        end
    end
    
    assign vga_r = red;
    assign vga_g = green;
    assign vga_b = blue;
    
    // LED indicators (only 4 LEDs available due to pin conflicts)
    assign LEDS[3:0] = BUTTONS;

endmodule
