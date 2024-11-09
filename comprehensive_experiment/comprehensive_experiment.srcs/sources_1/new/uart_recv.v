`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/11/07 08:53:20
// Design Name: 
// Module Name: uart_data
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


module uart_recv(
    input clk,
    input rst,
    input din,              /* Connect to usb_uart rx pin */
    output reg valid,       /* Indicate data is valid logic high , last one clock */
    output reg [7:0] data   
    );

    reg [2:0] current_state;
    reg [2:0] next_state;

    localparam IDLE  = 2'b00;
    localparam START = 2'b01;
    localparam DATA  = 2'b10;
    localparam STOP  = 2'b11;

    /* The first always block describes the migration from the next state to the current state */
    always @(posedge clk or posedge rst)
    begin
        if (rst)
            current_state <= IDLE;
        else
            current_state <= next_state;
    end

    /* Get count_half and count_end */
    reg [31:0] counter;
    assign counter_end  = (counter == 10416) ? 1 : 0;    /* A counter generates two signals counter_end and counter_half */
    assign counter_half = (counter == 5208)  ? 1 : 0;
    
    always @(posedge clk or posedge rst)
    begin
        if (rst)
            counter <= 0;
        else if (current_state == IDLE)
            counter <= 0;
        else if (counter_end)
            counter <= 0;
        else
            counter <= counter + 1;
    end

    /* Tracking whether all data was received */
    reg [3:0] counter_data;
    assign counter_data_end = (counter_data == 8) ? 1 : 0;

    always @(posedge clk or posedge rst)
    begin
        if (rst)
            counter_data <= 0;
        else if (current_state == IDLE)
            counter_data <= 0;
        else if (current_state == START)
            counter_data <= 0;
        else if (current_state == DATA)                 /* Assign value to counter_data only in data state */
            begin
                if (counter_half)
                    counter_data <= counter_data + 1;
                else
                    counter_data <= counter_data;
            end
        else if (current_state == STOP)
            counter_data <= 0;
        else
            counter_data <= counter_data;
    end

    /* Three-stage state transition conditions */
    always @(*) begin
        case(current_state)
            IDLE:
                if (!din)
                    next_state = START;
                else
                    next_state = IDLE;
            START:
                if (counter_end)
                    next_state = DATA;
                else
                    next_state = START;
            DATA:
                if (counter_data_end && counter_end)
                    next_state = STOP;
                else
                    next_state = DATA;
            STOP:
                if (counter_end)
                    next_state = IDLE;
                else
                    next_state = STOP;
            default:
                next_state = IDLE;
        endcase
    end

    /* Signal capture and recognition */
    always @(posedge clk or posedge rst)
    begin
        if (rst)
            data <= 8'b11111111;
        else if (valid)
            data <= 8'b11111111;
        else
            begin
            case(current_state)
                IDLE:
                begin
                    data <= data;
                end
                START:
                begin
                    if (counter_half)
                        data <= {din,data[7:1]};
                    else
                        data <= data;
                end
                DATA:
                    if (counter_half && !counter_data_end)
                        data <= {din,data[7:1]};
                    else
                        data <= data;
                STOP:
                    data <= data;
                default : 
                    data <= data;
            endcase
            end
    end

    /* valid assignment conditions */
    always @(posedge clk or posedge rst)
    begin
        if (rst)
            valid <= 0;
        else if (current_state == STOP && counter_half)
            valid <= 1;
        else
            valid <= 0;
    end
endmodule
