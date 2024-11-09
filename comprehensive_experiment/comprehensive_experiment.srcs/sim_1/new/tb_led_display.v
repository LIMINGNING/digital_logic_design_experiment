`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/11/07 16:59:15
// Design Name: 
// Module Name: tb_led_display
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


`timescale 1ns / 1ps

module tb_led_display;

    // 输入信号
    reg clk;
    reg rst;
    reg valid;
    reg [7:0] data;

    // 输出信号
    wire [7:0] led_en;
    wire [7:0] led_cx;

    // 实例化被测模块
    led_display uut (
        .clk(clk),
        .rst(rst),
        .valid(valid),
        .data(data),
        .led_en(led_en),
        .led_cx(led_cx)
    );

    // 时钟周期为10ns
    initial begin
        clk = 0;
        forever #5 clk = ~clk;  // 100MHz 时钟
    end

    // 仿真过程
    initial begin
        // 初始化
        rst = 1;
        valid = 0;
        data = 8'h00;
        
        // 复位信号保持20ns
        #20 rst = 0;
        
        // 模拟输入数据，测试不同的显示内容
        #10 data = 8'h01; valid = 1; #10 valid = 0; // 输入 '0'
        #1000000; // 等待一些时间观察显示变化
        
        #10 data = 8'h02; valid = 1; #10 valid = 0; // 输入 '1'
        #1000000; 
        
        #10 data = 8'h03; valid = 1; #10 valid = 0; // 输入 '2'
        #1000000; 
        
        #10 data = 8'h04; valid = 1; #10 valid = 0; // 输入 '3'
        #1000000; 
        
        #10 data = 8'h05; valid = 1; #10 valid = 0; // 输入 'A'
        #1000000; 

        #10 data = 8'h06; valid = 1; #10 valid = 0; // 输入 'B'
        #1000000;
        
        #10 data = 8'h07; valid = 1; #10 valid = 0; // 输入 'C'
        #1000000;
        
        #10 data = 8'h08; valid = 1; #10 valid = 0; // 输入 'D'
        #30000000;
        
        // 再次复位观察显示是否清除
        
        rst = 1; #10 rst = 0;
        #1000000;
        
        // 结束仿真
        $stop;
    end
endmodule
