`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/10/11 14:12:13
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


`timescale 1ns/1ps
module testbench (
);

reg clk;
reg clr;
reg en;
reg [2:0] wsel;
reg [2:0] rsel;
reg [7:0] d;
wire[7:0] q;

initial begin
    clr = 1'b1;   
    en  = 1'b0;
    clk = 0;
    d   = 8'b0;

    #10;          
    clr = 1'b0;
    en  = 1'b1;
    wsel= 3'b001;
    d   = 8'b11111111;
    #10;
    wsel= 3'b111;
    d   = 8'b00000010;

    #10;            
    en = 1'b0;
    rsel = 3'b001;
    #5;
    rsel = 3'b111;

    #5;           
    clr = 1'b1;
    rsel = 3'b001;
    #5;
    rsel = 3'b111;
    #200;
    $finish;
end

always #5 clk = ~clk;  

reg8file u_reg8file(
    .clk(clk),
    .clr(clr),
    .en(en),
    .wsel(wsel),
    .rsel(rsel),
    .d(d),
    .q(q)
);

endmodule
