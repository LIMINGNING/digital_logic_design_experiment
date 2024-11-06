`timescale 1ns / 1ps

module uart_send_tb;

reg clk;
reg rst;
reg valid;
reg [7:0] data;
wire dout;

uart_send u_uart_send (
    .clk(clk),
    .rst(rst),
    .valid(valid),
    .data(data),
    .dout(dout)
);

localparam CLOCK_FREQ = 100*1e6;         //clock freq: 100MHz
localparam PERIOD     = 1e9/CLOCK_FREQ;  // clock ycle: 10ns
localparam BAUD_RATE  = 9600;
localparam DIVIDER    = CLOCK_FREQ / BAUD_RATE -1; // 9600:10416, 115200:867,


always #(PERIOD/2) clk = ~clk;


integer bit_index = 0;    
reg [9:0] expected_bits; 
reg [3:0] all_check_error; 
reg check_error;         


initial begin
    clk   = 0;
    rst   = 1'b1;
    valid = 1'b0;
    data  = 8'h00;
    check_error     = 1'b0; 
    all_check_error = 1'b0; 
    expected_bits   = 10'h0;
    #(10*PERIOD);

    rst = 1'b0;
    #(2*PERIOD);

    // test case1: 8'hA5 (10100101)
    data  = 8'hA5;
    valid = 1'b1;
    expected_bits = {1'b1, data, 1'b0}; 
    #PERIOD;     // valid should last one clock
    valid = 1'b0;
    check_uart_output(8'hA5);   
    #(100*PERIOD);

    // test case2: 8'h3C (00111100)
    data  = 8'h3C;
    valid = 1'b1;
    expected_bits = {1'b1, data, 1'b0};  
    #PERIOD;
    valid = 1'b0;
    check_uart_output(data);   
    #(20000*PERIOD);

    // test case3: 8'hFF (11111111)
    data  = 8'hFF;
    valid = 1'b1;
    expected_bits = {1'b1, data, 1'b0}; 
    #PERIOD;
    valid = 1'b0;
    data  = 8'h00;
    check_uart_output(8'hFF);   
    #(10000*PERIOD);

    // test case4: 8'h00 (00000000)
    data  = 8'h00;
    valid = 1'b1;
    expected_bits = {1'b1, data, 1'b0}; 
    #PERIOD;
    valid = 1'b0;
    check_uart_output(data);   
    #(10*PERIOD);  

    // test case5: 8'h5A (01011010)
    data  = 8'h5A;
    valid = 1'b1;
    expected_bits = {1'b1, data, 1'b0}; 
    #PERIOD;
    valid = 1'b0;
    check_uart_output(data);   
    #(100*PERIOD);

    if (!all_check_error)
        $display("All tests passed successfully!");
    else
        $display("%d test failed!", all_check_error);

    $display("Uart baud rate = %d, freq divider = %d",BAUD_RATE, DIVIDER);
    $finish;
end


task check_uart_output;
    input [7:0]       i_data ;
    begin
        $display("Test case :%x start", i_data);
        bit_index   = 0;
        check_error = 0;
        repeat (10) begin         // total 10 bits
            #(DIVIDER*PERIOD);    // time for one bit
            if (dout !== expected_bits[bit_index]) begin
                $display("Error at time %t, %d th bit: Expected %b, Got %b", $time, bit_index, expected_bits[bit_index], dout);
                check_error = 1'b1;
            end
            bit_index = bit_index + 1; 
        end
        if (check_error) begin
            all_check_error = all_check_error + 1'b1; 
            $display("Test case %x failed\n", i_data);
        end 
        else $display("Test case %x success\n", i_data);
    end
endtask

endmodule