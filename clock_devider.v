`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/04/2025 06:26:05 PM
// Design Name: 
// Module Name: clock_devider
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module clock_divider #(
    parameter DIV_COUNT = 100000   // default: 1 ms tick at 100 MHz
)(
    input  wire clk,
    input  wire reset,
    output reg  tick
);

    // Ensure counter is wide enough
    reg [31:0] counter;  

    always @(posedge clk) begin
        if (reset) begin
            counter <= 0;
            tick    <= 0;
        end else begin
            if (counter == DIV_COUNT-1) begin
                counter <= 0;
                tick    <= 1;   // one-cycle pulse
            end else begin
                counter <= counter + 1;
                tick    <= 0;
            end
        end
    end

endmodule

