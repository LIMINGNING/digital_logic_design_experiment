`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/11/07 15:25:33
// Design Name: 
// Module Name: uart_recv_tb
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

module uart_receive_tb();

    localparam CLK_FREQ = 100_000_000;          // clock frequency: 100 MHz
    localparam PERIOD   = 1e9/CLK_FREQ;         // clock cycle: 10ns
    localparam BAUD_RATE = 9600;      
    localparam DIVIDER = CLK_FREQ / BAUD_RATE;  // clocks for one bit, should be 10416

    reg         clk;
    reg         rst;
    reg         din;
    wire        valid;
    wire [7:0]  data;
     
    uart_recv u_uart_recv (
        .clk(clk),
        .rst(rst),
        .din(din),
        .valid(valid),
        .data(data)
    );

    always #(PERIOD/2) clk = ~clk;

    reg [7:0] test_data[0:9];   // 10 test cases
    integer i;                 
    integer err_num;

    initial begin
        $display("Uart baud rate = %d, freq divider = %d",BAUD_RATE, DIVIDER);

        test_data[0] = 8'h55;  // 0101_0101
        test_data[1] = 8'hA3;  // 1010_0011
        test_data[2] = 8'h0F;  // 0000_1111
        test_data[3] = 8'hF0;  // 1111_0000
        test_data[4] = 8'h33;  // 0011_0011
        test_data[5] = 8'hCC;  // 1100_1100
        test_data[6] = 8'hFF;  // 1111_1111
        test_data[7] = 8'h00;  // 0000_0000
        test_data[8] = 8'h5A;  // 0101_1010
        test_data[9] = 8'hA5;  // 1010_0101
        
        #(200*DIVIDER*PERIOD)
        $display("Test failed: Timeout ");
        $finish;
    end

    initial begin
        clk = 0;
        rst = 1;
        din = 1; 
        err_num = 0;
        #(10*PERIOD) rst = 0; 
        
        for (i = 0; i < 10; i = i + 1) begin
            send_byte(test_data[i]);  

            wait (valid == 1);
            if (data === test_data[i]) begin
                $display("Test case:%2d success, Received expected data = 0x%h", i, data);
            end else begin
                err_num = err_num + 1;
                $display("Test case:%2d failed, Expected 0x%h, but received 0x%h", i, test_data[i], data);
            end
            #(DIVIDER*PERIOD/2);
        end

        if(err_num == 0)  $display("All test cases passed.");
        else              $display("%2d test cases failed.", err_num);
        
        #(10*PERIOD)
        $finish;
    end


    task send_byte(input [7:0] byte);
        integer j;
        begin
            din = 0;  // start bit
            #(DIVIDER*PERIOD);

            for (j = 0; j < 8; j = j + 1) begin    // 8bit data
                din = byte[j];
                #(DIVIDER*PERIOD);
            end

            din = 1;    // stop bit
            #(DIVIDER*PERIOD/2);
        end
    endtask

endmodule