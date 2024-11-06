`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/10/16 13:11:32
// Design Name: 
// Module Name: flowing_water_lights
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
//Flowing lights realization
module flowing_water_lights#(
    parameter FREQ0 = 32'd1000000,
    parameter FREQ1 = 32'd10000000,
    parameter FREQ2 = 32'd25000000,
    parameter FREQ3 = 32'd50000000
)
(
    input clk,                  /* Clock signal */
    input rst,                  /* Reset */
    input button,               /* Switch */
    input [1:0] freq_set,       /* SW1-SW0 switch the frequency */
    input dir_set,              /* SW23 choose direction */
    output reg [7:0] led        /* LED output */
    );

    wire neg_edge_freq_set_1;   /* Falling edge of freq_set_1 */
    wire neg_edge_freq_set_2;   /* Falling edge of freq_set_2 */
    wire pos_edge;              /* Posedge of button (whether button is pressed) */
    reg clk_div;                /* Frequency division signal */
    reg [2:0] shift_reg [2:0];  /* 3 register with a bit width of 3 */
    reg running;                /* Record whether system is working */
    reg [31:0] cnt;             /* Record count number */
    reg [31:0] max_cnt;         /* Maximum value of count */

    /* 3 register capture the button rising edge signal */
    always @(posedge clk or posedge rst)
    begin
        if(rst)
            shift_reg[0] <= 3'b000;
        else
            shift_reg[0] <= {shift_reg[0][1:0],button};
    end

    assign pos_edge = ~shift_reg[0][2] & shift_reg[0][1] & shift_reg[0][0];
    
    /* Shift_reg[1] capture the freq_set[0] falling edge signal */
    always @(posedge clk or posedge rst)
    begin
        if(rst)
            shift_reg[1] <= 3'b000;
        else
            shift_reg[1] <= {shift_reg[1][1:0],freq_set[0]};
    end

    assign neg_edge_freq_set_1 = shift_reg[1][2] & shift_reg[1][1] & ~shift_reg[1][0];

    /* Shift_reg[2] capture the freq_set[0] falling edge signal */
    always @(posedge clk or posedge rst)
    begin
        if(rst)
            shift_reg[2] <= 3'b000;
        else
            shift_reg[2] <= {shift_reg[2][1:0],freq_set[1]};
    end

    assign neg_edge_freq_set_2 = ~shift_reg[2][2] & shift_reg[2][1] & shift_reg[2][0];

    /* Determine whether to run based on the running itself and the rising edge signal of button */
    always @(posedge clk or posedge rst)
    begin
        if(rst)
            running <= 0;
        else if(running)
            running <= running & ~pos_edge;
        else
            running <= ~running & pos_edge;
    end

    /* DIP switch for frequency selection */
    always @(*)
    begin
        case(freq_set)
            2'b00:max_cnt = FREQ0;
            2'b01:max_cnt = FREQ1;
            2'b10:max_cnt = FREQ2;
            2'b11:max_cnt = FREQ3;
            default: ;
        endcase
    end

    /* Devide the clock signal */
    wire cnt_end = running & (cnt >= max_cnt/2 - 1);

    always @(posedge clk or posedge rst)
    begin
        if(rst)
            cnt <= 0;
        else if (neg_edge_freq_set_1 | neg_edge_freq_set_2)
            cnt <= 0;
        else if(cnt_end)
            cnt <= 0;
        else if(running)
            cnt <= cnt + 1;
    end

    always @(posedge clk or posedge rst)
    begin
        if(rst)
            clk_div <= 0;
        else if(cnt_end)
            clk_div <= ~clk_div;
        else if(running)
            clk_div <= clk_div;
    end
    
    /* Realize the effect of flowing lights (shift) */
    always @(posedge clk_div or posedge rst)
    begin
        if(rst)
            led <= 8'b00000001;
        else if(running)
        begin
            if(dir_set)
                led <= {led[6:0],led[7]};
            else
                led <= {led[0],led[7:1]};
        end
    end
endmodule
