`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/11/07 16:25:50
// Design Name: 
// Module Name: led_display
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


module led_display#(
    parameter ZERO              = 8'h03,
    parameter ONE               = 8'h9f,
    parameter TWO               = 8'h25,
    parameter THREE             = 8'h0d,
    parameter FOUR              = 8'h99,
    parameter FIVE              = 8'h49,
    parameter SIX               = 8'h41,
    parameter SEVEN             = 8'h1f,
    parameter EIGHT             = 8'h01,
    parameter NINE              = 8'h09,
    parameter TEN               = 8'h11,
    parameter ELEVEN            = 8'hc1,
    parameter TWELVE            = 8'he5,
    parameter THIRTEEN          = 8'h85,
    parameter FOURTEEN          = 8'h61,
    parameter FIFTEEN           = 8'h71,
    parameter NOTHING           = 8'hff,
    parameter FREQ_CLK_DIV      = 99999         /* 99999 */
)
(
    input wire clk,
    input wire rst,
    input wire valid,
    input wire [7:0] data,
    output reg [7:0] led_en,
    output reg [7:0] led_cx 
    );

    reg [7:0] led_data;
    always @(*)
    begin
        case (data)
            8'h00: led_data = ZERO;         /* ASCII '0' */
            8'h01: led_data = ONE;          /* ASCII '1' */
            8'h02: led_data = TWO;          /* ASCII '2' */
            8'h03: led_data = THREE;        /* ASCII '3' */
            8'h04: led_data = FOUR;         /* ASCII '4' */
            8'h05: led_data = FIVE;         /* ASCII '5' */
            8'h06: led_data = SIX;          /* ASCII '6' */
            8'h07: led_data = SEVEN;        /* ASCII '7' */
            8'h08: led_data = EIGHT;        /* ASCII '8' */
            8'h09: led_data = NINE;         /* ASCII '9' */
            8'h0a: led_data = TEN;          /* ASCII 'A' */
            8'h0b: led_data = ELEVEN;       /* ASCII 'B' */
            8'h0c: led_data = TWELVE;       /* ASCII 'C' */
            8'h0d: led_data = THIRTEEN;     /* ASCII 'D' */
            8'h0e: led_data = FOURTEEN;     /* ASCII 'E' */
            8'h0f: led_data = FIFTEEN;      /* ASCII 'F' */
            default: led_data = NOTHING;    /* 非数字或字母字符 */
        endcase
    end

    reg [7:0] display_buffer [7:0];
    always @(posedge clk or posedge rst)
    begin
        if (rst)
        begin
            display_buffer[0] <= NOTHING;
            display_buffer[1] <= NOTHING;
            display_buffer[2] <= NOTHING;
            display_buffer[3] <= NOTHING;
            display_buffer[4] <= NOTHING;
            display_buffer[5] <= NOTHING;
            display_buffer[6] <= NOTHING;
            display_buffer[7] <= NOTHING;
        end
        else if (valid)
        begin
            display_buffer[7] <= display_buffer[6];
            display_buffer[6] <= display_buffer[5];
            display_buffer[5] <= display_buffer[4];
            display_buffer[4] <= display_buffer[3];
            display_buffer[3] <= display_buffer[2];
            display_buffer[2] <= display_buffer[1];
            display_buffer[1] <= display_buffer[0];
            display_buffer[0] <= led_data;
        end
    end

    /* Counter implementation 2ms */
    reg clk_div;
    wire cnt_end;

    counter #(FREQ_CLK_DIV) u_counter(
        .clk(clk),
        .rst(rst),
        .counter_end(cnt_end)
    );

    always @(posedge clk or posedge rst)
    begin
        if (rst)
            clk_div <= 0;
        else if(cnt_end)
            clk_div <= ~clk_div;
        else
            clk_div <= clk_div;
    end

    /* Display realization of digital tube */
    always @(posedge clk_div or posedge rst)
    begin
        if (rst)
            led_en <= 8'b11111110;
        else
            led_en <= {led_en[0],led_en[7:1]};
    end

    always @(posedge clk_div or posedge rst)
    begin
        if (rst)
            led_cx <= NOTHING;
        else begin
            case (led_en)
                8'b11111110: led_cx <= display_buffer[7];
                8'b11111101: led_cx <= display_buffer[0];
                8'b11111011: led_cx <= display_buffer[1];
                8'b11110111: led_cx <= display_buffer[2];
                8'b11101111: led_cx <= display_buffer[3];
                8'b11011111: led_cx <= display_buffer[4];
                8'b10111111: led_cx <= display_buffer[5];
                8'b01111111: led_cx <= display_buffer[6];
                default: led_cx <= NOTHING;
            endcase
        end
    end
endmodule
