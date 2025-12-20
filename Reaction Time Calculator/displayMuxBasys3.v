// Simple 4-digit 7-segment display driver for Basys 3
module displayMuxBasys3 (
    input wire clk,
    input wire [3:0] hex3, hex2, hex1, hex0,
    input wire [3:0] dp_in,
    output reg [3:0] an,
    output reg [7:0] sseg
);

    reg [1:0] sel;
    reg [3:0] hex_in;
    reg dp;
    reg [16:0] refresh_counter = 0;  // Initialize to 0 for simulation

    // 100MHz / 2^17 ≈ 763Hz per digit
    always @(posedge clk)
        refresh_counter <= refresh_counter + 1;

    always @* begin
        sel = refresh_counter[16:15];
        case (sel)
            2'b00: begin an = 4'b1110; hex_in = hex0; dp = dp_in[0]; end
            2'b01: begin an = 4'b1101; hex_in = hex1; dp = dp_in[1]; end
            2'b10: begin an = 4'b1011; hex_in = hex2; dp = dp_in[2]; end
            2'b11: begin an = 4'b0111; hex_in = hex3; dp = dp_in[3]; end
        endcase
    end

    always @* begin
        case (hex_in)
            4'h0: sseg[6:0] = 7'b0000001;
            4'h1: sseg[6:0] = 7'b1001111;
            4'h2: sseg[6:0] = 7'b0010010;
            4'h3: sseg[6:0] = 7'b0000110;
            4'h4: sseg[6:0] = 7'b1001100;
            4'h5: sseg[6:0] = 7'b0100100;
            4'h6: sseg[6:0] = 7'b0100000;
            4'h7: sseg[6:0] = 7'b0001111;
            4'h8: sseg[6:0] = 7'b0000000;
            4'h9: sseg[6:0] = 7'b0000100;
            4'hA: sseg[6:0] = 7'b0001000;
            4'hB: sseg[6:0] = 7'b1100000;
            4'hC: sseg[6:0] = 7'b0110001;
            4'hD: sseg[6:0] = 7'b1000010;
            4'hE: sseg[6:0] = 7'b0110000;
            4'hF: sseg[6:0] = 7'b0111000;
            default: sseg[6:0] = 7'b1111111;
        endcase
        sseg[7] = dp;
    end
endmodule
