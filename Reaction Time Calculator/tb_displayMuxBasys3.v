`timescale 1ns / 1ps

module tb_displayMuxBasys3;

    // Inputs
    reg clk;
    reg [3:0] hex3, hex2, hex1, hex0;
    reg [3:0] dp_in;
    
    // Outputs
    wire [3:0] an;
    wire [7:0] sseg;
    
    // Instantiate the Unit Under Test (UUT)
    displayMuxBasys3 uut (
        .clk(clk),
        .hex3(hex3),
        .hex2(hex2),
        .hex1(hex1),
        .hex0(hex0),
        .dp_in(dp_in),
        .an(an),
        .sseg(sseg)
    );
    
    // Clock generation - 100 MHz (10 ns period)
    always #5 clk = ~clk;
    
    // Monitor which digit is active
    reg [3:0] active_digit;
    always @* begin
        case (an)
            4'b1110: active_digit = hex0;
            4'b1101: active_digit = hex1;
            4'b1011: active_digit = hex2;
            4'b0111: active_digit = hex3;
            default: active_digit = 4'hF;
        endcase
    end
    
    // Test stimulus
    initial begin
        // Initialize
        clk = 0;
        hex3 = 4'd0;
        hex2 = 4'd3;
        hex1 = 4'd4;
        hex0 = 4'd7;
        dp_in = 4'b0111;  // Decimal point after hex1 (shows "0.347")
        
        $display("Testing 7-Segment Display Multiplexer");
        $display("Display value: %d.%d%d%d (0.347 seconds)", hex3, hex2, hex1, hex0);
        $display("======================================================");
        $display("Note: Refresh counter uses bits [16:15] for digit selection");
        $display("      Each digit displays for ~327us (32768 clock cycles)");
        $display("      Waiting for digit transitions...\n");
        $display("Time\t\tAN\tActive\tSSEG\t\tDP");
        
        // Wait enough time to see digit transitions
        // Need at least 350us to see all 4 digits cycle once
        #350000;  // 350 microseconds
        
        // Now sample outputs periodically to catch different digits
        repeat(20) begin
            #20000;  // Sample every 20us
            $display("%0t\t%b\t%h\t%b\t%b", 
                     $time, an, active_digit, sseg[6:0], sseg[7]);
        end
        
        #1000000;  // Wait 1ms to see multiple digit cycles
        
        $display("\n--- Test Case 2: Display 9.999 (maximum reaction time) ---");
        hex3 = 4'd9;
        hex2 = 4'd9;
        hex1 = 4'd9;
        hex0 = 4'd9;
        
        #1000000;  // Wait 1ms
        
        $display("\n--- Test Case 3: Display 1.234 ---");
        hex3 = 4'd1;
        hex2 = 4'd2;
        hex1 = 4'd3;
        hex0 = 4'd4;
        
        #1000000;  // Wait 1ms
        
        $display("\n--- Test Case 4: All segments test (8888) ---");
        hex3 = 4'd8;
        hex2 = 4'd8;
        hex1 = 4'd8;
        hex0 = 4'd8;
        dp_in = 4'b1111;  // All decimal points on
        
        #1000000;  // Wait 1ms
        
        $display("\nTestbench completed!");
        $display("Note: For full verification, view waveform to see multiplexing");
        $finish;
    end
    
    // Verification: Check that each digit gets displayed
    integer digit0_count = 0, digit1_count = 0, digit2_count = 0, digit3_count = 0;
    
    always @(posedge clk) begin
        case (an)
            4'b1110: digit0_count = digit0_count + 1;
            4'b1101: digit1_count = digit1_count + 1;
            4'b1011: digit2_count = digit2_count + 1;
            4'b0111: digit3_count = digit3_count + 1;
        endcase
    end
    
    initial begin
        #5000000;  // Wait 5ms
        $display("\n=== Multiplexing Statistics (5ms observation) ===");
        $display("Digit 0 active cycles: %d", digit0_count);
        $display("Digit 1 active cycles: %d", digit1_count);
        $display("Digit 2 active cycles: %d", digit2_count);
        $display("Digit 3 active cycles: %d", digit3_count);
        if (digit0_count > 0 && digit1_count > 0 && digit2_count > 0 && digit3_count > 0)
            $display("PASS: All digits are being multiplexed");
        else
            $display("FAIL: Some digits not active");
    end
    
endmodule
