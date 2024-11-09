`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/11/07 20:40:41
// Design Name: 
// Module Name: tbtop
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

module top_tb();

    reg clk;
    reg rst;
    reg button;
    reg [7:0] data;
    wire [7:0] led_cx;
    wire [7:0] led_en;

    top u_top(
        .clk(clk),
        .rst(rst),
        .button(button),
        .data_in(data),
        .led_cx(led_cx),
        .led_en(led_en)
    );

    always #5 clk = ~clk;

    initial begin
        clk = 0;
        rst = 1;
        data <= 8'b00000000;
        button <= 0;
        #10;

        rst = 0;

        #1000;
//1
        data <= 8'b00000011;
        button <= 1;
        #1000000
        button <= 0;

        #10000000;
//2
        data <= 8'b00000010;
        button <= 1;
        #1000000
        button <= 0;

        #10000000;
//3
        data <= 8'b00000111;
        button <= 1;
        #1000000
        button <= 0;

        #10000000;
//4
        data <= 8'b00000101;
        button <= 1;
        #1000000
        button <= 0;

        #10000000;
//5
        data <= 8'b00000110;
        button <= 1;
        #1000000
        button <= 0;

        #10000000;
//6
        data <= 8'b00000111;
        button <= 1;
        #1000000
        button <= 0;

        #10000000;
//7
        data <= 8'b00001111;
        button <= 1;
        #1000000
        button <= 0;

//8
        #10000000;

        data <= 8'b00001000;
        button <= 1;
        #1000000
        button <= 0;
//9
        #10000000;

        data <= 8'b00001011;
        button <= 1;
        #1000000
        button <= 0;

        #3000000



        $finish;
    end

endmodule

