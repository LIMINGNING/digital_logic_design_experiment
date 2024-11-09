`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/11/07 08:54:27
// Design Name: 
// Module Name: counter
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


module counter#(
    parameter COUNTING_TIMES = 99999
    )
    (
    input clk,
    input rst,
    output wire counter_end
    );

    reg [31:0] counter;
    assign counter_end = (counter == COUNTING_TIMES) ? 1 : 0;

    always @(posedge clk or posedge rst)
    begin
        if (rst)
            counter <= 0;
        else if (counter_end)    
            counter <= 0;
        else
            counter <= counter + 1;
    end
endmodule
