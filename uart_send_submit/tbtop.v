`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/11/04 10:33:16
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


module tbtop(
    );
    
    reg clk;
    reg rst;
    wire dout;
    
    uart_top u_uart_top (
        .clk(clk),
        .rst(rst),
        .dout(dout)
    );
    
    always #5 clk = ~clk;
    
    initial begin
        clk = 0;
        rst = 1;
        #10;
        rst = 0;
        
        #1000000000;
        $finish;
    end
    endmodule