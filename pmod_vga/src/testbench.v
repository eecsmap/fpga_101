`timescale 1ns / 1ps

module testbench();
    reg CLK_125MHZ_FPGA;
    reg [3:0] BUTTONS;
    wire [3:0] LEDS;
    wire [3:0] vga_r, vga_g, vga_b;
    wire vga_hs, vga_vs;
    
    // Instantiate DUT
    z1top dut(
        .CLK_125MHZ_FPGA(CLK_125MHZ_FPGA),
        .BUTTONS(BUTTONS),
        .LEDS(LEDS),
        .vga_r(vga_r),
        .vga_g(vga_g),
        .vga_b(vga_b),
        .vga_hs(vga_hs),
        .vga_vs(vga_vs)
    );
    
    // Clock generation: 125 MHz (8ns period)
    initial CLK_125MHZ_FPGA = 0;
    always #4 CLK_125MHZ_FPGA = ~CLK_125MHZ_FPGA;
    
    // Test different patterns
    initial begin
        $dumpfile("testbench.fst");
        $dumpvars(0, testbench);
        
        BUTTONS = 4'b0000;
        
        // Test pattern 0: Color bars
        #100000;
        $display("Testing pattern 0: Color bars");
        BUTTONS = 4'b0000;
        
        // Wait for a few frames (one frame @ 60Hz ~= 16.7ms = 16,700,000ns)
        #3000000;
        
        // Test pattern 1: Gradient
        $display("Testing pattern 1: Gradient");
        BUTTONS = 4'b0001;
        #3000000;
        
        // Test pattern 2: Checkerboard
        $display("Testing pattern 2: Checkerboard");
        BUTTONS = 4'b0010;
        #3000000;
        
        // Test pattern 3: Grid
        $display("Testing pattern 3: Grid");
        BUTTONS = 4'b0011;
        #3000000;
        
        $display("Testbench completed");
        $finish;
    end
    
    // Monitor VGA timing
    integer h_sync_count = 0;
    integer v_sync_count = 0;
    
    always @(negedge vga_hs) begin
        h_sync_count = h_sync_count + 1;
        if (h_sync_count % 525 == 0) begin
            $display("Time %t: Completed frame %0d", $time, h_sync_count / 525);
        end
    end
    
    always @(negedge vga_vs) begin
        v_sync_count = v_sync_count + 1;
        $display("Time %t: VSync pulse %0d", $time, v_sync_count);
    end

endmodule
