`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/10/23 18:46:34
// Design Name: 
// Module Name: led_display_ctrl
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

module led_display_ctrl#(
    parameter ZERO              = 8'h03,
    parameter ONE               = 8'h9f,
    parameter TWO               = 8'h25,
    parameter THREE             = 8'h0d,
    parameter FOUR              = 8'h99,
    parameter FIVE              = 8'h49,
    parameter SIX               = 8'h41,
    parameter SEVEN             = 8'h1f,
    parameter EIGHT             = 8'h01,
    parameter NINE              = 8'h09,
    parameter FREQ_CLK_DIV      = 99999,         /* 99999 */
    parameter FREQ_S2           = 9999999        /* 9999999 */
)
(
    input wire clk,
    input wire rst,
    input wire s_3,
    input wire s_2,
    input wire [7:0] dip_switch,
    output reg [7:0] led_en,
    output reg [7:0] led_cx
    );

    wire    pos_edge_s3;                /* The rising edge of s3 */
    wire    pos_edge_s2;                /* The rising edge of s2 */
    reg     clk_div;                    /* 2ms */
    reg     [31:0] cnt;                 /* To achieve 2ms */
    reg     [31:0] cnt_s3;              /* Record the number of times you press */
    wire    [3:0]  cnt_s3_units;        
    wire    [3:0]  cnt_s3_tens;
    reg     [31:0] cnt_s2;              /* To achieve 0.1s */
    reg     [7:0]  cnt_s2_1;            /* Count 1-20 */
    wire    [3:0]  cnt_s2_1_units;
    wire    [3:0]  cnt_s2_1_tens;
    reg     [7:0]  dk_4;
    reg     [7:0]  dk_3;
    reg     [7:0]  dk_2;
    reg     [7:0]  dk_1;
    reg     [7:0]  dk_0;

    /* Capture the rising edge of s2 */
    reg [2:0] shift_reg_s2;
    always @(posedge clk or posedge rst)
    begin
        if (rst)
            shift_reg_s2 <= 3'b000;
        else
            shift_reg_s2 <= {shift_reg_s2[1:0],s_2};
    end

    assign pos_edge_s2 = ~shift_reg_s2[2] & shift_reg_s2[1] & shift_reg_s2[0];

    /* Counter implementation 0.1s */
    wire cnt_s2_end = (cnt_s2 >= FREQ_S2) ? 1 : 0;
    always @(posedge clk or posedge rst)
    begin
        if (rst)
            cnt_s2 <= 0;
        else if (cnt_s2_end)        
            cnt_s2 <= 0;
        else
            cnt_s2 <= cnt_s2 + 1;
    end

    /* Count 1-20 */
    wire cnt_s2_end_1 = (cnt_s2_1 >= 20) ? 1 : 0;
    always @(posedge clk or posedge rst) 
    begin
        if(rst)
            cnt_s2_1 <= 0;
        else if (pos_edge_s2)
            cnt_s2_1 <= 0;
        else if (cnt_s2_end_1)
            cnt_s2_1 <= cnt_s2_1;       /* Hold after counting to 20 */
        else if (cnt_s2_end)
            cnt_s2_1 <= cnt_s2_1 + 1;   /* Add 1 every 0.1s */
        else
            cnt_s2_1 <= cnt_s2_1;
    end

    assign cnt_s2_1_units = cnt_s2_1 % 10;
    assign cnt_s2_1_tens = (cnt_s2_1 / 10) % 10;

    always @(posedge clk or posedge rst)
    begin
        if (rst)
            dk_0 <= ZERO;
        else 
        begin
            case (cnt_s2_1_units)
                0:dk_0 <= ZERO;
                1:dk_0 <= ONE;
                2:dk_0 <= TWO;
                3:dk_0 <= THREE;
                4:dk_0 <= FOUR;
                5:dk_0 <= FIVE;
                6:dk_0 <= SIX;
                7:dk_0 <= SEVEN;
                8:dk_0 <= EIGHT;
                9:dk_0 <= NINE;
                default: dk_0 <= ZERO;
            endcase
        end  
    end

    always @(posedge clk or posedge rst)
    begin
        if(rst)
            dk_1 <= ZERO;
        else
        begin
            case (cnt_s2_1_tens)
                0:dk_1 <= ZERO;
                1:dk_1 <= ONE;
                2:dk_1 <= TWO;
                3:dk_1 <= THREE;
                4:dk_1 <= FOUR;
                5:dk_1 <= FIVE;
                6:dk_1 <= SIX;
                7:dk_1 <= SEVEN;
                8:dk_1 <= EIGHT;
                9:dk_1 <= NINE;
            default: dk_1 <= ZERO;
            endcase
        end
    end

    /* Capture the rising edge of s3 and debounce*/
    reg  [31:0] s3_counter;                                          /* Debounce counter */
    wire [31:0] s3_counter_end = (s3_counter >= 2999999) ? 1 : 0;    /* Count 30ms 2999999 */
    reg  [2:0]  shift_reg_s3;                                        /* Capture register */
    reg  count_flag;                                                 /* Record whether there was a rising edge before */

    always @(posedge clk or posedge rst) 
    begin
        if (rst)
            s3_counter <= 0;
        else if (pos_edge_s3)
            s3_counter <= 0;
        else if (s3_counter_end)
            s3_counter <= 0;
        else
            s3_counter <= s3_counter + 1;
    end

    always @(posedge clk or posedge rst)
    begin
        if (rst)
            count_flag <= 0;
        else if (pos_edge_s3)
            count_flag <= 0;
        else if (s3_counter_end)
            begin
                if (shift_reg_s3[0])
                    count_flag <= 1;
                else
                    count_flag <= count_flag;
            end
        else
            count_flag <= count_flag;
    end

    always @(posedge clk or posedge rst)
    begin
        if (rst)
            shift_reg_s3 <= 3'b000;
        else
            shift_reg_s3 <= {shift_reg_s3[1:0],s_3};
    end

    assign pos_edge_s3 = ~shift_reg_s3[2] & shift_reg_s3[1] & shift_reg_s3[0];

    /* Record the total number of presses */
    wire cnt_s3_end = (cnt_s3 > 99) ? 1 : 0;
    always @(posedge clk or posedge rst)
    begin
        if (rst)
            cnt_s3 <= 0;
        else if (cnt_s3_end)
            cnt_s3 <= 0;
        else if (s3_counter_end)
            begin
                if(shift_reg_s3[0] && !count_flag)
                    cnt_s3 <= cnt_s3 + 1;
                else
                    cnt_s3 <= cnt_s3;
            end
        else
            cnt_s3 <= cnt_s3;
    end

    assign cnt_s3_units = cnt_s3 % 10;
    assign cnt_s3_tens = (cnt_s3 / 10) % 10;

    always @(posedge clk or posedge rst)
    begin
        if (rst)
            dk_2 <= ZERO;
        else 
        begin
            case (cnt_s3_units)
                0:dk_2 <= ZERO;
                1:dk_2 <= ONE;
                2:dk_2 <= TWO;
                3:dk_2 <= THREE;
                4:dk_2 <= FOUR;
                5:dk_2 <= FIVE;
                6:dk_2 <= SIX;
                7:dk_2 <= SEVEN;
                8:dk_2 <= EIGHT;
                9:dk_2 <= NINE;
                default:dk_2 <= ZERO;
            endcase   
        end
    end

    always @(posedge clk or posedge rst)
    begin
        if (rst)
            dk_3 <= ZERO;
        else
            begin
            case (cnt_s3_tens)
                0:dk_3 <= ZERO;
                1:dk_3 <= ONE;
                2:dk_3 <= TWO;
                3:dk_3 <= THREE;
                4:dk_3 <= FOUR;
                5:dk_3 <= FIVE;
                6:dk_3 <= SIX;
                7:dk_3 <= SEVEN;
                8:dk_3 <= EIGHT;
                9:dk_3 <= NINE;
                default:dk_3 <= ZERO;
            endcase
        end
    end

    /* Count the number of 1 */
    wire [3:0] num = dip_switch[0] + dip_switch[1] + dip_switch[2] + dip_switch[3] + dip_switch[4] + dip_switch[5] + dip_switch[6] + dip_switch[7];
    always @(posedge clk or posedge rst)
    begin
        if (rst)
            dk_4 <= ZERO;
        else
        begin
            case (num)
                4'h0000:dk_4 <= ZERO;
                4'b0001:dk_4 <= ONE;
                4'b0010:dk_4 <= TWO;
                4'b0011:dk_4 <= THREE;
                4'b0100:dk_4 <= FOUR;
                4'b0101:dk_4 <= FIVE;
                4'b0110:dk_4 <= SIX;
                4'b0111:dk_4 <= SEVEN;
                4'b1000:dk_4 <= EIGHT;
                default:dk_4 <= ZERO;
            endcase
        end
    end

    /* Counter implementation 2ms */
    wire cnt_end = (cnt > FREQ_CLK_DIV) ? 1 : 0;
    always @(posedge clk or posedge rst)
    begin
        if (rst)
            cnt <= 0;
        else if (cnt_end)        
            cnt <= 0;
        else
            cnt <= cnt + 1;
    end

    always @(posedge clk or posedge rst)
    begin
        if (rst)
            clk_div <= 0;
        else if(cnt_end)
            clk_div <= ~clk_div;
        else
            clk_div <= clk_div;
    end

    always @(posedge clk_div or posedge rst)
    begin
        if(rst)
            led_cx <= ZERO;
        else 
        begin
            case (led_en)
                8'b01111111:led_cx <= THREE;
                8'b10111111:led_cx <= ZERO;
                8'b11011111:led_cx <= dk_4;
                8'b11101111:led_cx <= dk_3;
                8'b11110111:led_cx <= dk_2;
                8'b11111011:led_cx <= dk_1;
                8'b11111101:led_cx <= dk_0;
                8'b11111110:led_cx <= TWO;
                default:led_cx <= ZERO;
            endcase
        end
    end

    /* Display realization of digital tube */
    always @(posedge clk_div or posedge rst)
    begin
        if (rst)
            led_en <= 8'b11111110;
        else
            led_en <= {led_en[0],led_en[7:1]};
    end
endmodule