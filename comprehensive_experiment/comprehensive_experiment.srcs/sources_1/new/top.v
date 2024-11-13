`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/11/07 18:56:41
// Design Name: 
// Module Name: top
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


module top(
    input wire clk,
    input wire rst,
    input wire button,
    input wire uart_rx,
    input wire [7:0] data_in,
    output wire uart_tx,
    output [7:0] led_cx,
    output [7:0] led_en
    );
    
    wire tx;
    wire [7:0] data;
    wire valid_send;
    wire valid_recv;
    wire [7:0] u_led_cx;
    wire [7:0] u_led_en;

    uart_recv u_uart_recv(
        .rst(rst),
        .clk(clk),
        .valid(valid_recv),
        .data(data),
        .din(uart_rx)
    );

    button_debounce u_button_debounce(
        .rst(rst),
        .clk(clk),
        .valid(valid_send),
        .button(button)
    );

    uart_send u_uart_send (
        .rst(rst),
        .clk(clk),
        .valid(valid_send),
        .data(data_in),
        .dout(tx)
    );

    led_display u_led_display (
        .rst(rst),
        .clk(clk),
        .valid(valid_recv),
        .data(data),
        .led_cx(u_led_cx),
        .led_en(u_led_en)
    );

    assign tx = uart_tx;
    assign led_cx = u_led_cx;
    assign led_en = u_led_en; 
endmodule
