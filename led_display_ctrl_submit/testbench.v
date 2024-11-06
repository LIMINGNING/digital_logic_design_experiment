`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/10/24 09:15:29
// Design Name: 
// Module Name: testbench
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


module testbench();
    reg clk;
    reg rst;
    reg s_2;
    reg s_3;
    reg [7:0] dip_switch;
    wire [7:0] led_en;
    wire [7:0] led_cx;
    led_display_ctrl u_led_display_ctrl
    (
        .clk(clk),
        .rst(rst),
        .s_2(s_2),
        .s_3(s_3),
        .dip_switch(dip_switch),
        .led_en(led_en),
        .led_cx(led_cx)
    );

    always #5 clk = ~clk;

    initial
    begin
        clk = 0;
        rst = 0;
        s_2 = 0;
        s_3 = 0;
        dip_switch = 8'b00001111;

        rst = 1;
        #20;
        rst = 0;
        
        
        
        s_3 = 1;
        #20;
        s_3 = 0;

        #200;

        s_3 = 1;
        #1000100;
        s_3 = 0;

        #100

        s_3 = 1;
        #1000100;
        s_3 = 0;

        #100000;
      

        $finish;
    end
endmodule
