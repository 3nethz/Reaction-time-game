`timescale 1ns / 1ps

module tb_button_debouncer_simple;

    // Testbench signals
    reg clk;
    reg reset;
    reg tick_1ms;
    reg button_raw;
    wire button_pressed;
    wire button_stable;
    
    // Clock generation (100MHz)
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // 10ns period = 100MHz
    end
    
    // 1ms tick generation (every 100,000 clock cycles for 100MHz)
    // For simulation, we'll use a much faster rate
    initial begin
        tick_1ms = 0;
        forever #500 tick_1ms = ~tick_1ms; // 1us period for faster sim
    end
    
    // Instantiate the DUT
    button_debouncer_simple uut (
        .clk(clk),
        .reset(reset),
        .tick_1ms(tick_1ms),
        .button_raw(button_raw),
        .button_pressed(button_pressed),
        .button_stable(button_stable)
    );
    
    // Test sequence
    initial begin
        // Initialize signals
        reset = 1;
        button_raw = 0;
        
        $display("Starting simulation at time %0t", $time);
        
        // Release reset
        #100;
        reset = 0;
        $display("Reset released at time %0t", $time);
        
        // Wait a bit
        #2000;
        
        // Test 1: Simple button press
        $display("Test 1: Button press at time %0t", $time);
        button_raw = 1;
        #50000; // Hold for 50us 
        $display("Button release at time %0t", $time);
        button_raw = 0;
        #50000;
        
        // Test 2: Another button press
        $display("Test 2: Button press at time %0t", $time);
        button_raw = 1;
        #30000;
        $display("Button release at time %0t", $time);
        button_raw = 0;
        #30000;
        
        // End simulation
        $display("Ending simulation at time %0t", $time);
        #10000;
        $finish;
    end
    
    // Monitor outputs
    initial begin
        $monitor("Time=%0t reset=%b button_raw=%b button_stable=%b button_pressed=%b", 
                 $time, reset, button_raw, button_stable, button_pressed);
    end

endmodule