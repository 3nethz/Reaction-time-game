`timescale 1ns / 1ps

module tb_lfsr_8bit;

// Testbench signals
reg clk;
reg reset;
reg enable;
wire [7:0] random_out;
wire [7:0] random_value;

// Instantiate the LFSR
lfsr_8bit uut (
    .clk(clk),
    .reset(reset),
    .enable(enable),
    .random_out(random_out),
    .random_value(random_value)
);

// Clock generation (100 MHz)
initial begin
    clk = 0;
    forever #5 clk = ~clk;  // 10ns period = 100 MHz
end

// Test sequence
initial begin
    // Initialize signals
    reset = 1;
    enable = 0;
    
    // Display header
    $display("Time\t\tReset\tEnable\tRandom_Out\tRandom_Value");
    $display("----\t\t-----\t------\t----------\t------------");
    
    // Hold reset for 20ns
    #20;
    reset = 0;
    enable = 1;
    
    // Monitor output for 50 clock cycles
    repeat(50) begin
        @(posedge clk);
        $display("%0t ns\t\t%b\t%b\t0x%02h\t\t0x%02h", 
                 $time, reset, enable, random_out, random_value);
    end
    
    // Test reset functionality
    $display("\n--- Testing Reset ---");
    reset = 1;
    #10;
    reset = 0;
    
    repeat(10) begin
        @(posedge clk);
        $display("%0t ns\t\t%b\t%b\t0x%02h\t\t0x%02h", 
                 $time, reset, enable, random_out, random_value);
    end
    
    // Test enable/disable
    $display("\n--- Testing Enable Control ---");
    enable = 0;
    repeat(5) begin
        @(posedge clk);
        $display("%0t ns\t\t%b\t%b\t0x%02h\t\t0x%02h", 
                 $time, reset, enable, random_out, random_value);
    end
    
    enable = 1;
    repeat(5) begin
        @(posedge clk);
        $display("%0t ns\t\t%b\t%b\t0x%02h\t\t0x%02h", 
                 $time, reset, enable, random_out, random_value);
    end
    
    $display("\nSimulation completed successfully!");
    $finish;
end

// Optional: Check for all-zeros state (should never occur)
always @(posedge clk) begin
    if (!reset && random_value == 8'b00000000) begin
        $display("ERROR: LFSR entered forbidden all-zeros state at time %0t", $time);
        $finish;
    end
end

endmodule