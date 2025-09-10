module lfsr_8bit(
    input wire clk,
    input wire reset,
    input wire enable,      // Enable signal (connect to tick_1ms later)
    output reg [7:0] random_out,
    output wire [7:0] random_value  // Combinational output
);

// LFSR register
reg [7:0] lfsr_reg;

// Feedback polynomial for 8-bit LFSR: x^8 + x^6 + x^5 + x^4 + 1
// Tap positions: bits 7, 5, 4, 3 (0-indexed)
wire feedback;
assign feedback = lfsr_reg[7] ^ lfsr_reg[5] ^ lfsr_reg[4] ^ lfsr_reg[3];

// Combinational output
assign random_value = lfsr_reg;

always @(posedge clk or posedge reset) begin
    if (reset) begin
        lfsr_reg <= 8'b10101010;  // Non-zero seed (avoid all-zeros state)
        random_out <= 8'b10101010;
    end
    else if (enable) begin
        lfsr_reg <= {lfsr_reg[6:0], feedback};  // Shift left, insert feedback
        random_out <= {lfsr_reg[6:0], feedback};
    end
end

endmodule