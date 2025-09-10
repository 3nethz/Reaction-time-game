module binary_to_bcd(
    input [15:0] binary,
    output reg [15:0] bcd
);

integer i;

always @(*) begin
    bcd = 0;
    for (i = 0; i < 16; i = i + 1) begin
        // Add 3 to columns >= 5
        if (bcd[3:0] >= 5)
            bcd[3:0] = bcd[3:0] + 3;
        if (bcd[7:4] >= 5)
            bcd[7:4] = bcd[7:4] + 3;
        if (bcd[11:8] >= 5)
            bcd[11:8] = bcd[11:8] + 3;
        if (bcd[15:12] >= 5)
            bcd[15:12] = bcd[15:12] + 3;
        
        // Shift left
        bcd = {bcd[14:0], binary[15-i]};
    end
end

endmodule