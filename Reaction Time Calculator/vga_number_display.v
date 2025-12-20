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
    localparam SCALE = 4;
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
