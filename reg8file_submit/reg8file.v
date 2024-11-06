`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/10/11 14:10:10
// Design Name: 
// Module Name: reg8file
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


module reg8file(
    input clk,  //时钟信号
    input clr,  //异步复位信号
    input en,  //写入使能端
    input [2:0] wsel,  //三位写入地址
    input [2:0] rsel,  //三位读取地址
    input [7:0] d,  //八位写入数据
    output reg [7:0] q  //八位输出数据
    );
    
    reg [7:0] regfile [7:0];  //八个八位寄存器
    
    always @(posedge clk or posedge clr)  //3-8译码器进行选择
    begin
        if(clr)  //异步复位，清空寄存器
        begin
            regfile[0]<=8'b00000000;
            regfile[1]<=8'b00000000;
            regfile[2]<=8'b00000000;
            regfile[3]<=8'b00000000;
            regfile[4]<=8'b00000000;
            regfile[5]<=8'b00000000;
            regfile[6]<=8'b00000000;
            regfile[7]<=8'b00000000;
        end
        else if(en)
        begin
            case(wsel)
                3'b000:regfile[0]<=d;
                3'b001:regfile[1]<=d;
                3'b010:regfile[2]<=d;
                3'b011:regfile[3]<=d;
                3'b100:regfile[4]<=d;
                3'b101:regfile[5]<=d;
                3'b110:regfile[6]<=d;
                3'b111:regfile[7]<=d;
                default: ;
            endcase
        end
    end
    
    always @(*)  //八选一数据选择器
    begin
        case(rsel)
            3'b000:q=regfile[0];
            3'b001:q=regfile[1];
            3'b010:q=regfile[2];
            3'b011:q=regfile[3];
            3'b100:q=regfile[4];
            3'b101:q=regfile[5];
            3'b110:q=regfile[6];
            3'b111:q=regfile[7];
            default:q=8'b00000000;
        endcase
    end
endmodule
