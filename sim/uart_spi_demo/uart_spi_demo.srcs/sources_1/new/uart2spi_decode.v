`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/04/11 16:20:42
// Design Name: 
// Module Name: uart2spi_decode
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


module uart2spi_decode#
(
    parameter REG_CMD_LENGTH_1 = 40,//1 2 用于DDS指令控制
    parameter REG_CMD_LENGTH_2 = 72,
    parameter REG_CMD_LENGTH_3 = 16 //用于常规指令
)(
    input 			sys_clk,			//50M系统时钟
	input 			sys_rst,			//系统复位

	input[8 - 1:0] addr_data,
	input[8 - 1:0]  cmd_data,
	input addr_data_valid,
	input cmd_data_valid,
	input data_done,
	
    output reg [REG_CMD_LENGTH_1-1 : 0] cfr1,
    output reg [REG_CMD_LENGTH_1-1 : 0] cfr2,
    output reg [REG_CMD_LENGTH_1-1 : 0] cfr3,

    output reg[REG_CMD_LENGTH_2-1:0] digital_ramp_limit,   
    output reg[REG_CMD_LENGTH_2-1:0] digital_ramp_step,    
    output reg[REG_CMD_LENGTH_2-1:0] digital_ramp_rate, 
    
    output reg[REG_CMD_LENGTH_3-1:0] triger_freq, //设置重频
    output reg[REG_CMD_LENGTH_3-1:0] triger_pulse //设置脉宽
    );

//对每次获取的字节进行计数
reg[3:0]rec_byte_cnt; 
wire add_cnt;
wire end_cnt;
always @(posedge sys_clk)begin
    if(sys_rst)
        rec_byte_cnt <= 4'd0;
    else if(add_cnt)begin
        if(end_cnt)
            rec_byte_cnt <= 4'd0;
        else
            rec_byte_cnt <= rec_byte_cnt + 1'b1;
    end
    else
        rec_byte_cnt <= rec_byte_cnt;
end
assign add_cnt = addr_data_valid && cmd_data_valid;
assign end_cnt = data_done;
  
//cfr1
always @(posedge sys_clk)begin
    if (sys_rst)begin
        cfr1 <= 'b0;
    end
    else if (addr_data_valid &&(rec_byte_cnt == 0) && (addr_data == 8'h00))begin
        cfr1 <= {cfr2,addr_data};
    end
    else if(cmd_data_valid &&(rec_byte_cnt != 0) && (addr_data == 8'h00))begin
        cfr2 <= {cfr2,cmd_data};
    end
end 

//cfr2
always @(posedge sys_clk)begin
    if (sys_rst)begin
        cfr2 <= 'b0;
    end
    else if (addr_data_valid &&(rec_byte_cnt == 0) && (addr_data == 8'h01))begin
        cfr2 <= {cfr2,addr_data};
    end
    else if(cmd_data_valid &&(rec_byte_cnt != 0) && (addr_data == 8'h01))begin
        cfr2 <= {cfr2,cmd_data};
    end
end 

//cfr3
always @(posedge sys_clk)begin
    if (sys_rst)begin
        cfr3 <= 'b0;
    end
    else if (addr_data_valid &&(rec_byte_cnt == 0) && (addr_data == 8'h02))begin
        cfr3 <= {cfr3,addr_data};
    end
    else if(cmd_data_valid &&(rec_byte_cnt != 0) && (addr_data == 8'h02))begin
            cfr3 <= {cfr3,cmd_data};
    end
end 

//digital_ramp_limit
always @(posedge sys_clk)begin
    if (sys_rst)begin
        digital_ramp_limit <= 'b0;
    end
    else if (addr_data_valid &&(rec_byte_cnt == 0) && (addr_data == 8'h0B))begin
        digital_ramp_limit <= {digital_ramp_limit,addr_data};
    end
    else if(cmd_data_valid &&(rec_byte_cnt != 0) && (addr_data == 8'h0B))begin
            digital_ramp_limit <= {digital_ramp_limit,cmd_data};
    end
end 

//digital_ramp_step
always @(posedge sys_clk)begin
    if (sys_rst)begin
        digital_ramp_step <= 'b0;
    end
    else if (addr_data_valid &&(rec_byte_cnt == 0) && (addr_data == 8'h0C))begin
        digital_ramp_step <= {digital_ramp_step,addr_data};
    end
    else if(cmd_data_valid &&(rec_byte_cnt != 0) && (addr_data == 8'h0C))begin
            digital_ramp_step <= {digital_ramp_step,cmd_data};
    end
end 

//digital_ramp_rate
always @(posedge sys_clk)begin
    if (sys_rst)begin
        digital_ramp_rate <= 'b0;
    end
    else if (addr_data_valid &&(rec_byte_cnt == 0) && (addr_data == 8'h0D))begin
        digital_ramp_rate <= {digital_ramp_rate,addr_data};
    end
    else if(cmd_data_valid &&(rec_byte_cnt != 0) && (addr_data == 8'h0D))begin
            digital_ramp_rate <= {digital_ramp_rate,cmd_data};
    end
end 

//triger_freq
always @(posedge sys_clk)begin
    if (sys_rst)begin
        triger_freq <= 'b0;
    end
    else if (addr_data_valid &&(rec_byte_cnt == 0) && (addr_data == 8'h20))begin
        triger_freq <= {triger_freq,addr_data};
    end
    else if(cmd_data_valid &&(rec_byte_cnt != 0) && (addr_data == 8'h20))begin
            triger_freq <= {triger_freq,cmd_data};
    end
end 

//triger_pulse
always @(posedge sys_clk)begin
    if (sys_rst)begin
        triger_pulse <= 'b0;
    end
    else if (addr_data_valid &&(rec_byte_cnt == 0) && (addr_data == 8'h21))begin
        triger_pulse <= {triger_pulse,addr_data};
    end
    else if(cmd_data_valid &&(rec_byte_cnt != 0) && (addr_data == 8'h21))begin
            triger_pulse <= {triger_pulse,cmd_data};
    end
end 

endmodule
