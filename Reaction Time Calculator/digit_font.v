module digit_font(
    input  wire [3:0] digit,   // 0-9
    input  wire [2:0] row,     // 0-7 (row index)
    output reg  [7:0] row_pixels // 8 pixels in this row
);

always @* begin
    case(digit)
        4'd0: case(row)
            3'd0: row_pixels = 8'b00111100;
            3'd1: row_pixels = 8'b01000010;
            3'd2: row_pixels = 8'b01000010;
            3'd3: row_pixels = 8'b01000010;
            3'd4: row_pixels = 8'b01000010;
            3'd5: row_pixels = 8'b01000010;
            3'd6: row_pixels = 8'b01000010;
            3'd7: row_pixels = 8'b00111100;
        endcase
        4'd1: case(row)
            3'd0: row_pixels = 8'b00011000;
            3'd1: row_pixels = 8'b00111000;
            3'd2: row_pixels = 8'b00011000;
            3'd3: row_pixels = 8'b00011000;
            3'd4: row_pixels = 8'b00011000;
            3'd5: row_pixels = 8'b00011000;
            3'd6: row_pixels = 8'b00011000;
            3'd7: row_pixels = 8'b01111110;
        endcase
        4'd2: case(row)
            3'd0: row_pixels = 8'b00111100;
            3'd1: row_pixels = 8'b01000010;
            3'd2: row_pixels = 8'b00000010;
            3'd3: row_pixels = 8'b00000100;
            3'd4: row_pixels = 8'b00001000;
            3'd5: row_pixels = 8'b00010000;
            3'd6: row_pixels = 8'b00100000;
            3'd7: row_pixels = 8'b01111110;
        endcase
        4'd3: case(row)
            3'd0: row_pixels = 8'b00111100;
            3'd1: row_pixels = 8'b01000010;
            3'd2: row_pixels = 8'b00000010;
            3'd3: row_pixels = 8'b00011100;
            3'd4: row_pixels = 8'b00000010;
            3'd5: row_pixels = 8'b00000010;
            3'd6: row_pixels = 8'b01000010;
            3'd7: row_pixels = 8'b00111100;
        endcase
        4'd4: case(row)
            3'd0: row_pixels = 8'b00000100;
            3'd1: row_pixels = 8'b00001100;
            3'd2: row_pixels = 8'b00010100;
            3'd3: row_pixels = 8'b00100100;
            3'd4: row_pixels = 8'b01000100;
            3'd5: row_pixels = 8'b01111110;
            3'd6: row_pixels = 8'b00000100;
            3'd7: row_pixels = 8'b00000100;
        endcase
        4'd5: case(row)
            3'd0: row_pixels = 8'b01111110;
            3'd1: row_pixels = 8'b01000000;
            3'd2: row_pixels = 8'b01000000;
            3'd3: row_pixels = 8'b01111100;
            3'd4: row_pixels = 8'b00000010;
            3'd5: row_pixels = 8'b00000010;
            3'd6: row_pixels = 8'b01000010;
            3'd7: row_pixels = 8'b00111100;
        endcase
        4'd6: case(row)
            3'd0: row_pixels = 8'b00111100;
            3'd1: row_pixels = 8'b01000010;
            3'd2: row_pixels = 8'b01000000;
            3'd3: row_pixels = 8'b01111100;
            3'd4: row_pixels = 8'b01000010;
            3'd5: row_pixels = 8'b01000010;
            3'd6: row_pixels = 8'b01000010;
            3'd7: row_pixels = 8'b00111100;
        endcase
        4'd7: case(row)
            3'd0: row_pixels = 8'b01111110;
            3'd1: row_pixels = 8'b00000010;
            3'd2: row_pixels = 8'b00000100;
            3'd3: row_pixels = 8'b00001000;
            3'd4: row_pixels = 8'b00010000;
            3'd5: row_pixels = 8'b00010000;
            3'd6: row_pixels = 8'b00010000;
            3'd7: row_pixels = 8'b00010000;
        endcase
        4'd8: case(row)
            3'd0: row_pixels = 8'b00111100;
            3'd1: row_pixels = 8'b01000010;
            3'd2: row_pixels = 8'b01000010;
            3'd3: row_pixels = 8'b00111100;
            3'd4: row_pixels = 8'b01000010;
            3'd5: row_pixels = 8'b01000010;
            3'd6: row_pixels = 8'b01000010;
            3'd7: row_pixels = 8'b00111100;
        endcase
        4'd9: case(row)
            3'd0: row_pixels = 8'b00111100;
            3'd1: row_pixels = 8'b01000010;
            3'd2: row_pixels = 8'b01000010;
            3'd3: row_pixels = 8'b00111110;
            3'd4: row_pixels = 8'b00000010;
            3'd5: row_pixels = 8'b01000010;
            3'd6: row_pixels = 8'b01000010;
            3'd7: row_pixels = 8'b00111100;
        endcase
        default: row_pixels = 8'b00000000;
    endcase
end

endmodule
