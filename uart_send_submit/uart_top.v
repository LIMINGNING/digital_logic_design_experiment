`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/11/01 15:50:59
// Design Name: 
// Module Name: uart_top
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


module uart_top(
    input clk,
    input rst,
    output dout
    );
reg valid;
reg [7:0] data;

reg [31:0] counter;
wire counter_end = (counter == 10416) ? 1 : 0;

reg [3:0] id_index;

reg [7:0] my_id [9:0];
reg [31:0] state;

uart_send u_uart_send(
    .clk(clk),
    .rst(rst),
    .data(data),
    .valid(valid),
    .dout(dout)
);

/* 10146 */
always @(posedge clk or posedge rst)
begin
    if(rst)
        counter <= 0;
    else if (counter_end)
        counter <= 0;
    else
        counter <= counter + 1;
end

always @(posedge clk or posedge rst)
begin
    if(rst)
    begin
        my_id[0] <= 8'h32;  /* 2 */
        my_id[1] <= 8'h30;  /* 0 */
        my_id[2] <= 8'h32;  /* 2 */
        my_id[3] <= 8'h33;  /* 3 */
        my_id[4] <= 8'h33;  /* 3 */
        my_id[5] <= 8'h31;  /* 1 */
        my_id[6] <= 8'h31;  /* 1 */
        my_id[7] <= 8'h34;  /* 4 */
        my_id[8] <= 8'h32;  /* 2 */
        my_id[9] <= 8'h33;  /* 3 */
    end
end

always @(posedge clk or posedge rst)
begin
    if (rst)
        id_index <= 0;
    else if (id_index > 9)
        id_index <= 0;
    else if (state == 970 && counter_end)
        id_index <= id_index + 1;
    else
        id_index <= id_index;
end

always @(posedge clk or posedge rst)
begin
    if(rst)
        state <= 0;
    else if (counter_end)
        begin
            if (state <= 970)
                state <= state + 1;
            else
                state <= 0;
        end
end

always @(posedge clk)
begin
    if (state == 0)
    begin
        if(counter == 0)
            valid <= 1;
        else
            valid <= 0;
    end
    else
        valid <= 0;
end

always @(posedge clk)
begin
    if (state == 0)
        data <= my_id[id_index];
    else
        data <= data;
end

endmodule