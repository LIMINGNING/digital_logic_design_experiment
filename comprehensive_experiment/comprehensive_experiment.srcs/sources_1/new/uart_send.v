`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/11/07 16:13:13
// Design Name: 
// Module Name: uart_send
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


module uart_send(
    input        clk,        
    input        rst,        
    input        valid,         /* Indicates data is valid （logic high (1)）, last one clock */
    input [7:0]  data,          /* Data to send */
    output reg   dout           /* Connect to usb_uart tx pin */
    );
    localparam IDLE  = 2'b00;   /* Idle state, sending high level */
    localparam START = 2'b01;   /* Start state, send start bit */
    localparam DATA  = 2'b10;   /* Data state, send out 8 bits of data */
    localparam STOP  = 2'b11;   /* Stop state, send stop bit */

    reg [2:0] current_state;
    reg [2:0] next_state;

    reg [3:0] count_data;
    wire count_data_end = (count_data >= 8) ? 1 : 0;

    reg [31:0] cnt;
    wire cnt_end = (cnt >= 10416) ? 1 : 0;

    reg [7:0] data_buffer;

    /* The first always block describes the migration from the next state to the current state */
    always @(posedge clk or posedge rst)
    begin
        if(rst)
            current_state <= IDLE;
        else
            current_state <= next_state;
    end

    /* Make the beat */
    always @(posedge clk or posedge rst)
    begin
        if (rst)
            cnt <= 0;
        else if (valid)
            cnt <= 0;
        else if (current_state != IDLE || valid)
            begin
                if (cnt_end)
                    cnt <= 0;
                else
                    cnt <= cnt + 1;
            end
        else
            cnt <= 0;
    end

    /* The second always block describes the state transition condition judgment */
    always @(*) begin
        case(current_state)
            IDLE:
                if (valid)
                    next_state = START;
                else
                    next_state = IDLE;
            START:
                if (cnt_end)
                    next_state = DATA;
                else
                    next_state = START;
            DATA:
                if (count_data_end && cnt_end)
                    next_state = STOP;
                else
                    next_state = DATA;
            STOP:
                if (cnt_end)
                    next_state = IDLE;
                else if (valid)
                    next_state = START;
                else
                    next_state = STOP;
            default:
                next_state = IDLE;
        endcase
    end

    /* Update the buffer */
    always @(posedge clk or posedge rst)
    begin
        if (rst)
            data_buffer <= 0;
        else if (valid)
            data_buffer <= data;
        else
            data_buffer <= data_buffer;
    end

    /* Update count_data */
    always @(posedge clk or posedge rst)
    begin
        if (rst)
            count_data <= 0;
        else if (current_state == IDLE)
        begin
            if (valid)
                count_data <= 0;
            else
                count_data <= count_data;
        end
        else if (current_state == START)
            count_data <= 0;
        else if (current_state == DATA)
        begin
            if (cnt == 0)
                count_data <= count_data + 1;
            else
                count_data <= count_data;
        end
        else if (current_state == STOP)
            count_data <= 0;
        else
            count_data <= count_data;
    end

    /* The third always block describes the output logic */
    always @(posedge clk or posedge rst)
    begin
        if (rst)
            dout <= 1;
        else
            begin
            case(current_state)
                IDLE:   
                    dout <= 1;
                START:  
                    dout <= 0;
                DATA:
                    if(cnt == 0)
                        dout <= data_buffer[count_data];
                    else
                        dout <= dout;
                STOP:
                    dout <= 1;
                default :   
                    dout <= 1;
            endcase
            end
    end
endmodule
