module button_debouncer(
    input wire clk,
    input wire reset,
    input wire tick_1ms,        // 1ms tick from clock divider
    input wire button_raw,      // Raw button input (noisy)
    output reg button_pressed,  // Clean single pulse output
    output reg button_stable    // Stable debounced state
);

// Debounce parameters
parameter DEBOUNCE_TIME = 20;   // 20ms debounce window

// Internal registers
reg [7:0] debounce_counter;     // Counter for debounce timing
reg button_sync1, button_sync2; // Synchronizer flip-flops
reg button_prev;                // Previous stable state

// Synchronize the button input to clock domain
always @(posedge clk or posedge reset) begin
    if (reset) begin
        button_sync1 <= 0;
        button_sync2 <= 0;
    end
    else begin
        button_sync1 <= button_raw;
        button_sync2 <= button_sync1;
    end
end

// Debounce logic
always @(posedge clk or posedge reset) begin
    if (reset) begin
        debounce_counter <= 0;
        button_stable <= 0;
        button_prev <= 0;
        button_pressed <= 0;
    end
    else begin
        // Always update previous state and clear pressed pulse
        button_prev <= button_stable;
        button_pressed <= 0;  // Default to 0, set to 1 only when needed
        
        if (tick_1ms) begin
            // If button state changed from stable state, start/continue counting
            if (button_sync2 != button_stable) begin
                if (debounce_counter < DEBOUNCE_TIME) begin
                    debounce_counter <= debounce_counter + 1;
                end
                else begin
                    // Debounce time elapsed, update stable state
                    button_stable <= button_sync2;
                    debounce_counter <= 0;
                    
                    // Generate pulse on rising edge (0->1 transition)
                    if (button_sync2 == 1 && button_stable == 0) begin
                        button_pressed <= 1;
                    end
                end
            end
            else begin
                // Button state matches stable state, reset counter
                debounce_counter <= 0;
            end
        end
    end
end

endmodule