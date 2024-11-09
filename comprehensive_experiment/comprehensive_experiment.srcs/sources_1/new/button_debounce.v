`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/11/07 16:14:17
// Design Name: 
// Module Name: button_debounce
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


module button_debounce#(
    parameter COUNT = 999999
)
(
    input wire clk,
    input wire rst,
    input wire button,
    output reg valid
    );

    /* Capture the rising edge of button and debounce*/
    reg  [31:0] counter;                                            /* Debounce counter */
    wire [31:0] counter_end = (counter >= COUNT) ? 1 : 0;           /* Count 30ms 2999999 */
    reg  [2:0]  shift_reg;                                          /* Capture register */
    reg  count_flag;                                                /* Record whether there was a rising edge before */

    always @(posedge clk or posedge rst) 
    begin
        if (rst)
            counter <= 0;
        else if (pos_edge_button)
            counter <= 0;
        else if (counter_end)
            counter <= 0;
        else
            counter <= counter + 1;
    end

    always @(posedge clk or posedge rst)
    begin
        if (rst)
            count_flag <= 0;
        else if (pos_edge_button)
            count_flag <= 0;
        else if (counter_end)
            begin
                if (shift_reg[0])
                    count_flag <= 1;
                else
                    count_flag <= count_flag;
            end
        else
            count_flag <= count_flag;
    end

    always @(posedge clk or posedge rst)
    begin
        if (rst)
            shift_reg <= 3'b000;
        else
            shift_reg <= {shift_reg[1:0],button};
    end

    assign pos_edge_button = ~shift_reg[2] & shift_reg[1] & shift_reg[0];

    always @(posedge clk or posedge rst)
    begin
        if (rst)
            valid <= 0;
        else if (counter_end)
            valid <= shift_reg[0] && !count_flag;
        else
            valid <= 0; 
    end
endmodule
