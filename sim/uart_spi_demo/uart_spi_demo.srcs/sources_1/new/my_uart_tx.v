`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/04/10 16:48:49
// Design Name: 
// Module Name: my_uart_tx
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


module my_uart_tx(
   clk      ,
   rst_n    ,
   rx_done  ,
   data     ,
   ctr      ,
   tim
);
parameter   DATA_W   =  8;
parameter   CTR_W    =  8;
parameter   TIM_W    =  32;
parameter   CNTD_N   =  8; //一串完整数据所包含字节的个数，两个起始校验字节+5个数据字节+1个终值校验字节
parameter   CNTD_W   =  3; //字节计数器位宽

input                   clk;
input                   rst_n;
input                   rx_done;
input    [DATA_W-1:0]   data;

output   [CTR_W-1:0]    ctr;
output   [TIM_W-1:0]    tim;

reg      [CTR_W-1:0]    ctr;
reg      [TIM_W-1:0]    tim;

reg      [CNTD_W-1:0]   cnt_data;
wire                    add_cnt_data;
wire                    end_cnt_data;

//8个8位的寄存器，用来存放串口发送的完整数据
reg      [7:0]          data_save[7:0];
reg                     data_done;

//串口发送字节计数器
always @(posedge clk or negedge rst_n)begin
   if(!rst_n)
      cnt_data <= 0;
   else if(add_cnt_data)begin
      if(end_cnt_data)
         cnt_data <= 0;
      else
         cnt_data <= cnt_data + 1'b1;
   end
end
assign add_cnt_data = rx_done;
assign end_cnt_data = add_cnt_data && cnt_data == CNTD_N - 1;

always @(posedge clk or negedge rst_n)begin
   if(!rst_n)begin 
      data_save[0] <= 0;
      data_save[1] <= 0;
      data_save[2] <= 0;
      data_save[3] <= 0;
      data_save[4] <= 0;
      data_save[5] <= 0;
      data_save[6] <= 0;
      data_save[7] <= 0;
   end
   else if(rx_done)
      data_save[cnt_data] <= data;
end

always @(posedge clk or negedge rst_n)begin
   if(!rst_n)
      {ctr,tim} <= 40'b0;
   else if(data_done && (data_save[0]== 8'hAA && data_save[1] == 8'h55 && data_save[7] == 8'hCE))begin
      ctr <= data_save[2];
      tim[7:0]    <= data_save[6];
      tim[15:8]   <= data_save[5];
      tim[23:16]  <= data_save[4];
      tim[31:24]  <= data_save[3];
   end
end

always @(posedge clk or negedge rst_n)begin
   if(!rst_n)
      data_done <= 0;
   else if(end_cnt_data)
      data_done <= 1;
   else
      data_done <= 0;
end

endmodule