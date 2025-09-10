`timescale 1ns/1ps
module tb_clock_divider;

    reg clk;
    reg reset;
    wire tick;

    // Use small divider for sim
    clock_divider #(.DIV_COUNT(10)) uut (
        .clk(clk),
        .reset(reset),
        .tick(tick)
    );

    always #5 clk = ~clk; // 100MHz clock

    initial begin
        clk = 0;
        reset = 1;

        // Release reset after 20 ns
        #20 reset = 0;

        // Run long enough to see several ticks
        #200;

        $finish;
    end

    initial begin
        $monitor("T=%0t | clk=%b reset=%b tick=%b", $time, clk, reset, tick);
    end

endmodule
