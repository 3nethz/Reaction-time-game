`timescale 1ns / 1ps

module tb_fsm_reaction_timer;

reg clk, reset, tick_1ms;
reg start_button, reaction_button;
reg [7:0] random_value;
wire [6:0] state_out;
wire signal_led;
wire [15:0] reaction_time, average_time;
wire game_complete, false_start;
wire [15:0] debug_counter;

fsm_reaction_timer uut (
    .clk(clk),
    .reset(reset),
    .tick_1ms(tick_1ms),
    .start_button(start_button),
    .reaction_button(reaction_button),
    .random_value(random_value),
    .state_out(state_out),
    .signal_led(signal_led),
    .reaction_time(reaction_time),
    .average_time(average_time),
    .game_complete(game_complete),
    .false_start(false_start),
    .debug_counter(debug_counter)
);
// Clock generation
always #5 clk = ~clk;

// Tick generation (fast for simulation)
reg [6:0] tick_counter;
always @(posedge clk or posedge reset) begin
    if (reset) begin
        tick_counter <= 0;
        tick_1ms <= 0;
    end
    else begin
        if (tick_counter == 99) begin
            tick_counter <= 0;
            tick_1ms <= 1;
        end
        else begin
            tick_counter <= tick_counter + 1;
            tick_1ms <= 0;
        end
    end
end


// State name function for display
function [127:0] get_state_name;
    input [6:0] state;
    begin
        case (state)
            7'b0000001: get_state_name = "IDLE";
            7'b0000010: get_state_name = "WAIT_RANDOM";
            7'b0000100: get_state_name = "SHOW_SIGNAL";
            7'b0001000: get_state_name = "MEASURE_TIME";
            7'b0010000: get_state_name = "FALSE_START";
            7'b0100000: get_state_name = "SHOW_RESULT";
            7'b1000000: get_state_name = "FINAL_RESULT";
            default: get_state_name = "UNKNOWN";
        endcase
    end
endfunction

// Test stimulus
initial begin
    clk = 0;
    reset = 1;
    start_button = 0;
    reaction_button = 0;
    random_value = 8'h42;  // Fixed value for predictable delay
    
    $display("=== FSM Reaction Timer Testbench Started ===");
    $display("Time: %0t - Initializing system", $time);
    
    #200;
    reset = 0;
    $display("Time: %0t - Reset released", $time);
    $display("Random value set to: 0x%02h (%0d)", random_value, random_value);
    
    // Wait for IDLE state
    #1000;
    $display("Time: %0t - Current state: %s", $time, get_state_name(state_out));
    
    // Test normal game flow
    $display("\n=== Starting Game Test ===");
    $display("Time: %0t - Pressing start button", $time);
    start_button = 1;
    #200;
    start_button = 0;
    $display("Time: %0t - Start button released", $time);
    
    // Wait for state change and monitor
    #500;
    $display("Time: %0t - Current state: %s", $time, get_state_name(state_out));
    
    // Wait for signal LED
    $display("Time: %0t - Waiting for signal LED...", $time);
    wait(signal_led == 1);
    $display("Time: %0t - SIGNAL LED ON! Current state: %s", $time, get_state_name(state_out));
    
    // Reaction delay
    #500;
    $display("Time: %0t - Reacting to signal (pressing reaction button)", $time);
    reaction_button = 1;
    #200;
    reaction_button = 0;
    $display("Time: %0t - Reaction button released", $time);
    
    // Check results
    #300;
    $display("Time: %0t - Current state: %s", $time, get_state_name(state_out));
    $display("Time: %0t - Reaction time: %0d ms", $time, reaction_time);
    $display("Time: %0t - Game complete: %b", $time, game_complete);
    $display("Time: %0t - False start: %b", $time, false_start);
    
    #2000;
    $display("\n=== Test Completed Successfully ===");
    $finish;
end

// Monitor state changes
reg [6:0] prev_state = 7'b0000001;
always @(posedge tick_1ms) begin
    if (state_out != prev_state) begin
        $display("STATE CHANGE: %s -> %s at time %0t", 
                 get_state_name(prev_state), 
                 get_state_name(state_out), 
                 $time);
        prev_state <= state_out;
    end
end

// Monitor signal changes
always @(posedge signal_led) begin
    $display("*** SIGNAL LED TURNED ON at time %0t ***", $time);
end

always @(negedge signal_led) begin
    $display("*** SIGNAL LED TURNED OFF at time %0t ***", $time);
end

// Monitor button presses
always @(posedge start_button) begin
    $display(">>> START BUTTON PRESSED at time %0t <<<", $time);
end

always @(posedge reaction_button) begin
    $display(">>> REACTION BUTTON PRESSED at time %0t <<<", $time);
end

// Monitor false start
always @(posedge false_start) begin
    $display("!!! FALSE START DETECTED at time %0t !!!", $time);
end

// Monitor game completion
always @(posedge game_complete) begin
    $display("*** GAME COMPLETED at time %0t ***", $time);
    $display("    Final average time: %0d ms", average_time);
end

// Periodic status report
always @(posedge tick_1ms) begin
    if (tick_counter == 0) begin  // Every 100 ticks
        $display("[%0t] Status: State=%s, LED=%b, RT=%0d, Counter=%0d", 
                 $time, get_state_name(state_out), signal_led, 
                 reaction_time, debug_counter);
    end
end

endmodule