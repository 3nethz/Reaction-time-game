// Top module to display numbers
module vga_number_top(
    input wire clk, reset,
    output wire hsync, vsync,
    output wire [11:0] rgb
);

    wire video_on;
    wire [9:0] x, y;

    // VGA timing
    vga_sync sync_unit (
        .clk(clk),
        .reset(reset),
        .hsync(hsync),
        .vsync(vsync),
        .video_on(video_on),
        .p_tick(),
        .x(x),
        .y(y)
    );

    // Display numbers
    vga_number_display number_unit (
        .x(x),
        .y(y),
        .video_on(video_on),
        .rgb(rgb)
    );

endmodule

// Number display module
module vga_number_display (
    input  wire [9:0] x, y,
    input  wire video_on,
    output reg [11:0] rgb
);

    wire [3:0] d3 = 1;
    wire [3:0] d2 = 2;
    wire [3:0] d1 = 3;
    wire [3:0] d0 = 4;

    // Scaling factor
    localparam SCALE = 8;
    localparam DIGIT_WIDTH = 8;
    localparam DIGIT_HEIGHT = 8;
    localparam NUM_DIGITS = 4;

    // Center position
    localparam X0 = (640 - (DIGIT_WIDTH*NUM_DIGITS*SCALE)) / 2;
    localparam Y0 = (480 - (DIGIT_HEIGHT*SCALE)) / 2;
    
    // Map screen pixel to font pixel
    wire [9:0] dx = x - X0;
    wire [9:0] dy = y - Y0;
    wire [2:0] px = dx / SCALE;  // scale down
    wire [2:0] py = dy / SCALE;  // scale down

    reg [3:0] current_digit;
    wire [7:0] font_row;

    always @* begin
        if (x >= X0 && x < X0 + DIGIT_WIDTH*NUM_DIGITS*SCALE &&
            y >= Y0 && y < Y0 + DIGIT_HEIGHT*SCALE) begin
            if      (dx < 8*SCALE)  current_digit = d3;
            else if (dx < 16*SCALE) current_digit = d2;
            else if (dx < 24*SCALE) current_digit = d1;
            else                      current_digit = d0;
        end else begin
            current_digit = 0;
        end
    end

    digit_font font_unit (
        .digit(current_digit),
        .row(py),
        .row_pixels(font_row)
    );

    always @* begin
        if (video_on && x >= X0 && x < X0 + DIGIT_WIDTH*NUM_DIGITS*SCALE &&
            y >= Y0 && y < Y0 + DIGIT_HEIGHT*SCALE) begin
            if (font_row[7 - px])
                rgb = 12'hF00;  // red
            else
                rgb = 12'h000;  // background
        end else
            rgb = 12'h000;
    end

endmodule


// Simple 8x8 font for digits 0-9
module digit_font(
    input  wire [3:0] digit,
    input  wire [2:0] row,
    output reg  [7:0] row_pixels
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
        default: row_pixels = 8'b00000000;
    endcase
end

endmodule
