`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/11/09 16:29:12
// Design Name: 
// Module Name: tbbutton_debounce
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

module tb_button_debounce;

    // Inputs
    reg clk;
    reg rst;
    reg button;

    // Outputs
    wire valid;

    // Instantiate the button_debounce module
    button_debounce u_button_debounve (
        .clk(clk),
        .rst(rst),
        .button(button),
        .valid(valid)
    );

    // Clock generation
    always begin
        clk = 1'b0;
        #5 clk = 1'b1;  // 100 MHz clock
        #5 clk = 1'b0;
    end

    // Stimulus generation
    initial begin
        // Initialize inputs
        rst = 1'b1;
        button = 1'b0;
        
        // Apply reset
        #10 rst = 1'b0;  // Release reset after 10 ns
        
        // Simulate button press with debounce
        #20 button = 1'b1; 
        #30 button = 1'b0; // Release button after 3000 ns (simulate debounce time)

        #50

        #20 button = 1'b1;
        #50 button = 1'b0;
        
        #10000 button = 1'b1; // Press button again after 10 us
        #1000000 button = 1'b0;  // Release button after 1000 ns
        
        #50000 $finish; // End simulation after 50 us
    end

    // Monitor the signals
    initial begin
        $monitor("At time %t, rst = %b, button = %b, valid = %b", $time, rst, button, valid);
    end

endmodule
