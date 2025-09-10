module fsm_reaction_timer(
    input wire clk,
    input wire reset,
    input wire tick_1ms,
    input wire start_button,        // From debouncer
    input wire reaction_button,     // From debouncer
    input wire [7:0] random_value,  // From LFSR
    output reg [6:0] state_out,     // One-hot state output for debugging
    output reg signal_led,          // Visual signal (LED)
    output reg [15:0] reaction_time,// Current reaction time in ms
    output reg [15:0] average_time, // Average of 3 attempts
    output reg game_complete,       // All 3 attempts done
    output reg false_start,         // Early button press detected
    output wire [15:0] debug_counter, // Debug: expose counter
    // 7-segment display outputs
    output wire [6:0] seg0,  
    output wire [6:0] seg1,  
    output wire [6:0] seg2,  
    output wire [6:0] seg3,
    output reg [3:0] digit_enable // Enable signals for multiplexed display
);

// One-hot state encoding
parameter IDLE         = 7'b0000001;
parameter WAIT_RANDOM  = 7'b0000010;
parameter SHOW_SIGNAL  = 7'b0000100;
parameter MEASURE_TIME = 7'b0001000;
parameter FALSE_START  = 7'b0010000;
parameter SHOW_RESULT  = 7'b0100000;
parameter FINAL_RESULT = 7'b1000000;

// State register
reg [6:0] current_state;

// Internal counters and registers
reg [15:0] random_delay_counter;    // Countdown for random delay (ms)
reg [15:0] reaction_counter;        // Counts reaction time (ms)
reg [2:0] attempt_counter;          // Counts attempts (0-2)
reg [15:0] total_time;              // Sum of all reaction times

// Generate random delay - very short for testing
wire [15:0] random_delay_ms;
assign random_delay_ms = 2;  // Fixed 2ms delay for testing

// Expose counter for debugging
assign debug_counter = random_delay_counter;

// SIMPLIFIED: Use button directly without edge detection for now
reg start_triggered, reaction_triggered;

// Main FSM
always @(posedge clk or posedge reset) begin
    if (reset) begin
        current_state <= IDLE;
        signal_led <= 0;
        reaction_time <= 0;
        average_time <= 0;
        game_complete <= 0;
        false_start <= 0;
        random_delay_counter <= 0;
        reaction_counter <= 0;
        attempt_counter <= 0;
        total_time <= 0;
        state_out <= IDLE;
        start_triggered <= 0;
        reaction_triggered <= 0;
    end
    else if (tick_1ms) begin
        state_out <= current_state;
        
        case (current_state)
            IDLE: begin
                signal_led <= 0;
                false_start <= 0;
                game_complete <= 0;
                reaction_counter <= 0;
                
                // Use button level instead of edge for testing
                if (start_button && !start_triggered) begin
                    current_state <= WAIT_RANDOM;
                    random_delay_counter <= random_delay_ms;
                    start_triggered <= 1;
                end
                else if (!start_button) begin
                    start_triggered <= 0;
                end
            end
            
            WAIT_RANDOM: begin
                signal_led <= 0;
                false_start <= 0;
                start_triggered <= 0; // Reset trigger
                
                // Check for false start first
                if (reaction_button && !reaction_triggered) begin
                    current_state <= FALSE_START;
                    false_start <= 1;
                    reaction_triggered <= 1;
                end
                else if (!reaction_button) begin
                    reaction_triggered <= 0;
                end
                
                // Handle counter countdown separately - this should always execute
                if (random_delay_counter == 0) begin
                    current_state <= SHOW_SIGNAL;
                    signal_led <= 1;
                end
                else if (random_delay_counter > 0) begin
                    random_delay_counter <= random_delay_counter - 1;
                end
            end
            
            SHOW_SIGNAL: begin
                signal_led <= 1;
                current_state <= MEASURE_TIME;
                reaction_counter <= 0;
            end
            
            MEASURE_TIME: begin
                signal_led <= 1;
                reaction_counter <= reaction_counter + 1;
                
                if (reaction_button && !reaction_triggered) begin
                    current_state <= SHOW_RESULT;
                    reaction_time <= reaction_counter;
                    total_time <= total_time + reaction_counter;
                    attempt_counter <= attempt_counter + 1;
                    reaction_triggered <= 1;
                end
                else if (!reaction_button) begin
                    reaction_triggered <= 0;
                end
            end
            
            FALSE_START: begin
                signal_led <= 0;
                false_start <= 1;
                
                if (start_button && !start_triggered) begin
                    current_state <= WAIT_RANDOM;
                    random_delay_counter <= random_delay_ms;
                    false_start <= 0;
                    start_triggered <= 1;
                end
                else if (!start_button) begin
                    start_triggered <= 0;
                end
            end
            
            SHOW_RESULT: begin
                signal_led <= 0;
                false_start <= 0;
                
                if (attempt_counter >= 3) begin
                    current_state <= FINAL_RESULT;
                    average_time <= total_time / 3;
                    game_complete <= 1;
                end
                else if (start_button && !start_triggered) begin
                    current_state <= WAIT_RANDOM;
                    random_delay_counter <= random_delay_ms;
                    start_triggered <= 1;
                end
                else if (!start_button) begin
                    start_triggered <= 0;
                end
            end
            
            FINAL_RESULT: begin
                game_complete <= 1;
                
                if (start_button && !start_triggered) begin
                    current_state <= IDLE;
                    attempt_counter <= 0;
                    total_time <= 0;
                    reaction_time <= 0;
                    average_time <= 0;
                    game_complete <= 0;
                    start_triggered <= 1;
                end
                else if (!start_button) begin
                    start_triggered <= 0;
                end
            end
            
            default: current_state <= IDLE;
        endcase
    end
end

// Display control
reg [15:0] display_value;
reg [1:0] display_mode;

// Display modes
parameter DISP_OFF    = 2'b00;
parameter DISP_TIME   = 2'b01;
parameter DISP_AVG    = 2'b10;

// Choose display content based on state
always @(*) begin
    case (current_state)
        IDLE: begin
            display_value = 16'd0;
            display_mode = DISP_OFF;
            digit_enable = 4'b0000;
        end
        SHOW_RESULT: begin
            display_value = reaction_time;
            display_mode = DISP_TIME;
            digit_enable = 4'b1111;
        end
        FINAL_RESULT: begin
            display_value = average_time;
            display_mode = DISP_AVG;
            digit_enable = 4'b1111;
        end
        default: begin
            display_value = 16'd0;
            display_mode = DISP_OFF;
            digit_enable = 4'b0000;
        end
    endcase
end

// BCD conversion and display modules (same as above)
wire [15:0] bcd_out;
binary_to_bcd bcd_converter (.binary(display_value), .bcd(bcd_out));

seven_seg_decoder digit0 (.bcd(bcd_out[3:0]), .seg(seg0));
seven_seg_decoder digit1 (.bcd(bcd_out[7:4]), .seg(seg1));
seven_seg_decoder digit2 (.bcd(bcd_out[11:8]), .seg(seg2));
seven_seg_decoder digit3 (.bcd(bcd_out[15:12]), .seg(seg3));

endmodule