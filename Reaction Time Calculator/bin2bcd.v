// Binary to BCD converter (shift-add-3 algorithm)
// Adapted from Pong P. Chu, "FPGA Prototyping by Verilog Examples"
module bin2bcd (
    input wire clk, reset, start,
    input wire [13:0] bin,
    output reg ready, done_tick,
    output wire [3:0] bcd3, bcd2, bcd1, bcd0
);

    localparam [1:0] idle = 2'b00, op = 2'b01, done = 2'b10;
    reg [1:0] state_reg, state_next;
    reg [29:0] p2s_reg, p2s_next;  // 30 bits: 16 BCD + 14 binary
    reg [4:0] n_reg, n_next;
    wire [3:0] d3, d2, d1, d0;

    // Extract BCD digits from the upper 16 bits
    assign d3 = p2s_reg[29:26];
    assign d2 = p2s_reg[25:22];
    assign d1 = p2s_reg[21:18];
    assign d0 = p2s_reg[17:14];
    
    // Output assignments
    assign bcd3 = d3;
    assign bcd2 = d2;
    assign bcd1 = d1;
    assign bcd0 = d0;

    always @(posedge clk, posedge reset)
        if (reset) begin
            state_reg <= idle;
            p2s_reg <= 0;
            n_reg <= 0;
        end else begin
            state_reg <= state_next;
            p2s_reg <= p2s_next;
            n_reg <= n_next;
        end

    always @* begin
        ready = 1'b0;
        done_tick = 1'b0;
        p2s_next = p2s_reg;
        n_next = n_reg;
        state_next = state_reg;

        case (state_reg)
            idle: begin
                ready = 1'b1;
                if (start) begin
                    // Load binary in lower 14 bits, clear upper 16 bits for BCD
                    p2s_next = {16'b0, bin};
                    n_next = 5'd14;
                    state_next = op;
                end
            end
            op: begin
                // Apply add-3 correction BEFORE shift to each BCD digit if >= 5
                p2s_next = p2s_reg;
                if (d3 >= 5) p2s_next[29:26] = d3 + 3;
                if (d2 >= 5) p2s_next[25:22] = d2 + 3;
                if (d1 >= 5) p2s_next[21:18] = d1 + 3;
                if (d0 >= 5) p2s_next[17:14] = d0 + 3;
                
                // Then shift left
                p2s_next = {p2s_next[28:0], 1'b0};
                n_next = n_reg - 1;
                
                if (n_next == 0) state_next = done;
            end
            done: begin
                state_next = idle;
                done_tick = 1'b1;
            end
        endcase
    end

endmodule
