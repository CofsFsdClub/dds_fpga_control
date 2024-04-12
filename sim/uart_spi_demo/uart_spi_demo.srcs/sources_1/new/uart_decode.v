`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/04/10 17:07:22
// Design Name: 
// Module Name: uart_decode
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
//串口只会解析 A6|num|addr|cmd|CE的代码 1+0+1+7+1
//最终只需要获得addr 和 cmd的数值
module uart_decode#
(
    parameter UART_BPS = 115200,
    parameter CLK_FREQ = 50_000_000,
    parameter ADDR_WIDTH = 8, //地址字节
    parameter CMD_WIDTH = 8, //指令字节 最大
    parameter HEAD_FREAME = 8'hA6, //定义头帧
    parameter END_FREAME = 8'hCE//定义尾帧
)(
	input 			sys_clk,			//50M系统时钟
	input 			sys_rst_n,			//系统复位
	
	input           uart_rxd,          //串口接收引脚

	output[ADDR_WIDTH - 1:0] addr_data,
	output[CMD_WIDTH - 1:0]  cmd_data,
	output addr_data_valid,
	output cmd_data_valid,
	
	output data_done, //完成一次数据解析的标志
	output byte_valid
    );
    
//串口接收字节
wire uart_rx_valid;
wire [7:0] byte_rec;
wire rx_done;
uart_rx #
(
	.BPS				(UART_BPS),
	.SYS_CLK_FRE		(CLK_FREQ)
)
u_uart_rx(
	.sys_clk			(sys_clk),
	.sys_rst_n		    (sys_rst_n),
	
	.uart_rxd		    (uart_rxd),	
	.uart_rx_valid	    (uart_rx_valid),//每当接收到一个数据，uart_rx_valid会置高一个周期
	.uart_rx_data	    (byte_rec),
	.rx_done(rx_done)
);
assign byte_valid = uart_rx_valid;

localparam REC_IDLE = 3'b000;//等待字符接收 获取头帧
localparam NUM_STATE = 3'b001;//检索字符串指令有多少个字节
localparam ADDR_STATE= 3'b010;//检索地址
localparam CMD_STATE = 3'b100;//获取指令
localparam END_STATE = 3'b101;//等待字符接收 获取尾帧
localparam ERROR_STATE = 3'b111;

reg [2:0]rec_state;
reg [2:0]rec_state_nxt;
always @(posedge sys_clk)begin
    if(sys_rst_n)begin 
        rec_state_nxt <= REC_IDLE;
    end
    else
        rec_state_nxt <= rec_state;
end 

reg[7:0] byte_cnt_max;
reg[7:0] byte_cnt;
always @(posedge sys_clk)begin
    case(rec_state_nxt)
        REC_IDLE:begin
            if(rx_done&&byte_rec == HEAD_FREAME)begin//检测到头帧，开始接收字符串
                rec_state <= NUM_STATE;
             end
        end
        NUM_STATE:begin
            if(rx_done)begin
                rec_state <= ADDR_STATE;
             end
        end
        ADDR_STATE:begin
            if(rx_done&&(byte_cnt < byte_cnt_max))begin
                rec_state <= CMD_STATE;
            end
        end
        CMD_STATE:begin
            if(rx_done&&(byte_cnt == byte_cnt_max))begin
                rec_state <= END_STATE;
            end        
        end
        END_STATE:begin
          if(rx_done&&byte_rec == END_FREAME)begin//检测到尾帧，等待开始下一次指令接收
                rec_state <= REC_IDLE;
          end  
        end
        ERROR_STATE:begin
        end
        default:rec_state <= REC_IDLE;
    endcase
end 
//有效参数解析
reg [ADDR_WIDTH - 1:0] addr_data_reg;
reg [CMD_WIDTH - 1:0]  cmd_data_reg;
reg [7:0] byte_cnt_all;
reg addr_rec_flag; //接收字节有效标志
reg cmd_rec_flag; //接收字节有效标志
always @(posedge sys_clk)begin
    if(rec_state_nxt == REC_IDLE)begin
        addr_data_reg <= 'b0;
        cmd_data_reg <= 'b0;
        byte_cnt_max <= 'b0;
        byte_cnt <= 'b0;
        byte_cnt_all <= 'b0;
        addr_rec_flag <= 1'b0;
        cmd_rec_flag <= 1'b0;
    end
    else if(rx_done&&rec_state_nxt == NUM_STATE)begin
        byte_cnt_max <= byte_rec - 1'b1;
        byte_cnt_all <= byte_cnt_all + 1'b1;
        addr_rec_flag <= 1'b0;
        cmd_rec_flag <= 1'b0;
    end
    else if(rx_done&&rec_state_nxt == ADDR_STATE)begin
        addr_data_reg = byte_rec;
        byte_cnt <= byte_cnt + 1'b1;
        byte_cnt_all <= byte_cnt_all + 1'b1; 
        addr_rec_flag <= 1'b1;
        cmd_rec_flag <= 1'b0;
    end
    else if(rx_done&&rec_state_nxt == CMD_STATE)begin
        byte_cnt <= byte_cnt + 1'b1;
        cmd_data_reg <= byte_rec;
        byte_cnt_all <= byte_cnt_all + 1'b1; 
        addr_rec_flag <= 1'b1;
        cmd_rec_flag <= 1'b1;
    end
    else if(rx_done&&rec_state_nxt == END_STATE)begin
        byte_cnt <= 'b0;
        byte_cnt_all <= byte_cnt_all + 1'b1;   
        addr_rec_flag <= 1'b1;
        cmd_rec_flag <= 1'b1;  
    end
    else if(rx_done&&rec_state_nxt == ERROR_STATE)begin
    
    end
end
assign addr_data = addr_data_reg;
assign cmd_data = cmd_data_reg;

assign data_done = rx_done&&byte_cnt_all == byte_cnt_max + 2;
assign addr_data_valid = rx_done&&addr_rec_flag;
assign cmd_data_valid = rx_done&&cmd_rec_flag;
endmodule
