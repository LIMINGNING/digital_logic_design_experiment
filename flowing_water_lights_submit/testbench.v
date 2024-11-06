`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/10/16 20:35:09
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


`timescale 1ns / 1ps

module testbench();
    reg clk;
    reg rst;
    reg button;
    reg [1:0] freq_set;
    reg dir_set;
    wire [7:0] led;

    flowing_water_lights #(100, 1000, 2500, 5000) u_flowing_water_lights (
        .clk(clk),
        .rst(rst),
        .button(button),
        .freq_set(freq_set),
        .dir_set(dir_set),
        .led(led)
    );

    //100 MHz clock
    always #5 clk = ~clk;

    initial 
    begin
        clk = 0;
        rst = 0;
        button = 0;
        freq_set = 2'b00;
        dir_set = 0;

        //Reset the system
        rst = 1;
        #20
        rst = 0;
        #1000

        //Start the running light
        button = 1;
        #20;
        button = 0;
        #100000

        //Switch the frequence
        freq_set = 2'b11;
        #1000000

        //Change the frequence
        freq_set = 2'b00;
        #100000

        //Change the direction of flowing lights
        dir_set = 1;
        #100000

        //Pause the running light
        button = 1;
        #20;
        button = 0;
        #100000

        $finish;
    end
endmodule
