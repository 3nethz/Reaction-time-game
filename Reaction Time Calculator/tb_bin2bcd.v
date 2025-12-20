`timescale 1ns / 1ps

module tb_bin2bcd;

    // Inputs
    reg clk;
    reg reset;
    reg start;
    reg [13:0] bin;
    
    // Outputs
    wire ready;
    wire done_tick;
    wire [3:0] bcd3, bcd2, bcd1, bcd0;
    
    // Instantiate the Unit Under Test (UUT)
    bin2bcd uut (
        .clk(clk),
        .reset(reset),
        .start(start),
        .bin(bin),
        .ready(ready),
        .done_tick(done_tick),
        .bcd3(bcd3),
        .bcd2(bcd2),
        .bcd1(bcd1),
        .bcd0(bcd0)
    );
    
    // Clock generation - 100 MHz (10 ns period)
    always #5 clk = ~clk;
    
    // Test stimulus
    initial begin
        // Initialize
        clk = 0;
        reset = 1;
        start = 0;
        bin = 0;
        
        // Display header
        $display("Time\t\tBin\tBCD3\tBCD2\tBCD1\tBCD0\tReady\tDone");
        $display("====================================================================");
        
        // Release reset
        #20;
        reset = 0;
        #20;
        
        // Test Case 1: Convert 0
        $display("\n--- Test Case 1: Binary 0 ---");
        bin = 14'd0;
        start = 1;
        #10;
        start = 0;
        wait(done_tick);
        #10;
        $display("%0t\t%d\t%d\t%d\t%d\t%d\t%b\t%b", 
                 $time, bin, bcd3, bcd2, bcd1, bcd0, ready, done_tick);
        if (bcd3 == 0 && bcd2 == 0 && bcd1 == 0 && bcd0 == 0)
            $display("PASS: 0 -> 0000");
        else
            $display("FAIL: Expected 0000, got %d%d%d%d", bcd3, bcd2, bcd1, bcd0);
        #50;
        
        // Test Case 2: Convert 347 (typical reaction time)
        $display("\n--- Test Case 2: Binary 347 ---");
        bin = 14'd347;
        start = 1;
        #10;
        start = 0;
        wait(done_tick);
        #10;
        $display("%0t\t%d\t%d\t%d\t%d\t%d\t%b\t%b", 
                 $time, bin, bcd3, bcd2, bcd1, bcd0, ready, done_tick);
        if (bcd3 == 0 && bcd2 == 3 && bcd1 == 4 && bcd0 == 7)
            $display("PASS: 347 -> 0347");
        else
            $display("FAIL: Expected 0347, got %d%d%d%d", bcd3, bcd2, bcd1, bcd0);
        #50;
        
        // Test Case 3: Convert 1234
        $display("\n--- Test Case 3: Binary 1234 ---");
        bin = 14'd1234;
        start = 1;
        #10;
        start = 0;
        wait(done_tick);
        #10;
        $display("%0t\t%d\t%d\t%d\t%d\t%d\t%b\t%b", 
                 $time, bin, bcd3, bcd2, bcd1, bcd0, ready, done_tick);
        if (bcd3 == 1 && bcd2 == 2 && bcd1 == 3 && bcd0 == 4)
            $display("PASS: 1234 -> 1234");
        else
            $display("FAIL: Expected 1234, got %d%d%d%d", bcd3, bcd2, bcd1, bcd0);
        #50;
        
        // Test Case 4: Convert 9999 (maximum)
        $display("\n--- Test Case 4: Binary 9999 (Maximum) ---");
        bin = 14'd9999;
        start = 1;
        #10;
        start = 0;
        wait(done_tick);
        #10;
        $display("%0t\t%d\t%d\t%d\t%d\t%d\t%b\t%b", 
                 $time, bin, bcd3, bcd2, bcd1, bcd0, ready, done_tick);
        if (bcd3 == 9 && bcd2 == 9 && bcd1 == 9 && bcd0 == 9)
            $display("PASS: 9999 -> 9999");
        else
            $display("FAIL: Expected 9999, got %d%d%d%d", bcd3, bcd2, bcd1, bcd0);
        #50;
        
        // Test Case 5: Convert 5678
        $display("\n--- Test Case 5: Binary 5678 ---");
        bin = 14'd5678;
        start = 1;
        #10;
        start = 0;
        wait(done_tick);
        #10;
        $display("%0t\t%d\t%d\t%d\t%d\t%d\t%b\t%b", 
                 $time, bin, bcd3, bcd2, bcd1, bcd0, ready, done_tick);
        if (bcd3 == 5 && bcd2 == 6 && bcd1 == 7 && bcd0 == 8)
            $display("PASS: 5678 -> 5678");
        else
            $display("FAIL: Expected 5678, got %d%d%d%d", bcd3, bcd2, bcd1, bcd0);
        #50;
        
        $display("\n====================================================================");
        $display("Testbench completed!");
        $finish;
    end
    
endmodule
