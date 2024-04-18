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
    parameter CLK_FREQ = 50,			/* 模块时钟输入，单位为MHz */
	parameter SPI_CLK = 10000,		    /* SPI时钟频率，单位为KHz */
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
    
    output reg[REG_CMD_LENGTH_3-1:0] pulse_position, //设置扫频方向
    output reg pulse_position_done,
    output reg[REG_CMD_LENGTH_3-1:0] triger_pulse, //设置脉宽
    output reg triger_pulse_done,
    
    output	    SCK_O,			/* SPI模块时钟输出 */
	output	    MOSI_O,			/* MOSI_O */
	input	    MISO_I,			/* MISO_I  */
	output		CS_O
    );
reg [REG_CMD_LENGTH_1-1 : 0] cfr1;
reg cfr1_done;
reg [REG_CMD_LENGTH_1-1 : 0] cfr2;
reg cfr2_done;
reg [REG_CMD_LENGTH_1-1 : 0] cfr3;
reg cfr3_done;
reg [REG_CMD_LENGTH_1-1 : 0] asf;
reg asf_done;

reg[REG_CMD_LENGTH_2-1:0] digital_ramp_limit;   
reg digital_ramp_limit_done;
reg[REG_CMD_LENGTH_2-1:0] digital_ramp_step;    
reg digital_ramp_step_done;
reg[REG_CMD_LENGTH_1-1:0] digital_ramp_rate; 
reg digital_ramp_rate_done;
reg[REG_CMD_LENGTH_2-1:0] pfofile0; 
reg pfofile0_done;
    
wire [REG_CMD_LENGTH_1-1 : 0] ad9910_reg40;
wire ad9910_reg40_valid;
wire [REG_CMD_LENGTH_2-1 : 0] ad9910_reg72;
wire ad9910_reg72_valid;
//wire [REG_CMD_LENGTH_3-1 : 0] ad9910_reg16;
//wire ad9910_reg16_valid;

//-------spi 完成一次传输下降沿 检测标志----------//
//wire Req16_Ndg;
//reg [1:0]Req16_reg;
//always@(posedge sys_clk)begin
//    if(sys_rst)begin
//        Req16_reg <= 'b0;
//    end
//    else begin
//        Req16_reg <= {Req16_reg[0],spi_busy16};
//    end
//end
//assign Req16_Ndg = Req16_reg[1]&~Req16_reg[0];//下降沿

wire Req40_Ndg;
reg [1:0]Req40_reg;
always@(posedge sys_clk)begin
    if(sys_rst)begin
        Req40_reg <= 'b0;
    end
    else begin
        Req40_reg <= {Req40_reg[0],spi_busy40};
    end
end
assign Req40_Ndg = Req40_reg[1]&~Req40_reg[0];//下降沿

wire Req72_Ndg;
reg [1:0]Req72_reg;
always@(posedge sys_clk)begin
    if(sys_rst)begin
        Req72_reg <= 'b0;
    end
    else begin
        Req72_reg <= {Req72_reg[0],spi_busy72};
    end
end
assign Req72_Ndg = Req72_reg[1]&~Req72_reg[0];//下降沿


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
// - - - - - - - - - - - - AD9910 专用命令- - - - - - - - - - - - - -//
//cfr1
always @(posedge sys_clk)begin
    if (sys_rst)begin
        cfr1 <= 'b0;
        cfr1_done <= 1'b0;
    end
    else if (addr_data_valid && (~cmd_data_valid) && (addr_data == 8'h00))begin
        cfr1 <= {cfr1,addr_data};
        cfr1_done <= 1'b0;
    end
    else if(cmd_data_valid && (addr_data == 8'h00))begin
        cfr1 <= {cfr1,cmd_data};
        if(end_cnt)begin
            cfr1_done <= 1'b1;
        end
    end
    else if(Req40_Ndg)begin
        cfr1_done <= 1'b0;
    end
end 
//cfr2
always @(posedge sys_clk)begin
    if (sys_rst)begin
        cfr2 <= 'b0;
        cfr2_done <= 1'b0;
    end
    else if (addr_data_valid && (~cmd_data_valid) && (addr_data == 8'h01))begin
        cfr2 <= {cfr2,addr_data};
        cfr2_done <= 1'b0;
    end
    else if(cmd_data_valid && (addr_data == 8'h01))begin
        cfr2 <= {cfr2,cmd_data};
        if(end_cnt)begin
            cfr2_done <= 1'b1;
        end
    end
    else if(Req40_Ndg)begin
        cfr2_done <= 1'b0;
    end
end 

//cfr3
always @(posedge sys_clk)begin
    if (sys_rst)begin
        cfr3 <= 'b0;
        cfr3_done <= 1'b0;
    end
    else if (addr_data_valid && (~cmd_data_valid) && (addr_data == 8'h02))begin
        cfr3 <= {cfr3,addr_data};
        cfr3_done <= 1'b0;
    end
    else if(cmd_data_valid && (addr_data == 8'h02))begin
        cfr3 <= {cfr3,cmd_data};
        if(end_cnt)begin
            cfr3_done <= 1'b1;
        end
    end
    else if(Req40_Ndg)begin
        cfr3_done <= 1'b0;
    end
end 

//asf
always @(posedge sys_clk)begin
    if (sys_rst)begin
        asf <= 'b0;
        asf_done <= 1'b0;
    end
    else if (addr_data_valid && (~cmd_data_valid) && (addr_data == 8'h09))begin
        asf <= {asf,addr_data};
        asf_done <= 1'b0;
    end
    else if(cmd_data_valid && (addr_data == 8'h09))begin
        asf <= {asf,cmd_data};
        if(end_cnt)begin
            asf_done <= 1'b1;
        end
    end
    else if(Req40_Ndg)begin
        asf_done <= 1'b0;
    end
end 
//digital_ramp_limit
always @(posedge sys_clk)begin
    if (sys_rst)begin
        digital_ramp_limit <= 'b0;
        digital_ramp_limit_done <= 1'b0;
    end
    else if (addr_data_valid && (~cmd_data_valid) && (addr_data == 8'h0B))begin
        digital_ramp_limit <= {digital_ramp_limit,addr_data};
        digital_ramp_limit_done <= 1'b0;
    end
    else if(cmd_data_valid && (addr_data == 8'h0B))begin
        digital_ramp_limit <= {digital_ramp_limit,cmd_data};
        if(end_cnt)begin
            digital_ramp_limit_done <= 1'b1;
        end
    end
    else if(Req72_Ndg)begin
        digital_ramp_limit_done <= 1'b0;
    end
end 

//digital_ramp_step
always @(posedge sys_clk)begin
    if (sys_rst)begin
        digital_ramp_step <= 'b0;
        digital_ramp_step_done <= 1'b0;
    end
    else if (addr_data_valid && (~cmd_data_valid) && (addr_data == 8'h0C))begin
        digital_ramp_step <= {digital_ramp_step,addr_data};
        digital_ramp_step_done <= 1'b0;
    end
    else if(cmd_data_valid && (addr_data == 8'h0C))begin
        digital_ramp_step <= {digital_ramp_step,cmd_data};
        if(end_cnt)begin
            digital_ramp_step_done <= 1'b1;
        end
    end
    else if(Req72_Ndg)begin
        digital_ramp_step_done <= 1'b0;
    end
end 
//digital_ramp_rate
always @(posedge sys_clk)begin
    if (sys_rst)begin
        digital_ramp_rate <= 'b0;
        digital_ramp_rate_done <= 1'b0;
    end
    else if (addr_data_valid && (~cmd_data_valid) && (addr_data == 8'h0D))begin
        digital_ramp_rate <= {digital_ramp_rate,addr_data};
        digital_ramp_rate_done <= 1'b0;
    end
    else if(cmd_data_valid && (addr_data == 8'h0D))begin
        digital_ramp_rate <= {digital_ramp_rate,cmd_data};
        if(end_cnt)begin
            digital_ramp_rate_done <= 1'b1;
        end
    end
    else if(Req40_Ndg)begin
        digital_ramp_rate_done <= 1'b0;
    end
end 

//pfofile0
always @(posedge sys_clk)begin
    if (sys_rst)begin
        pfofile0 <= 'b0;
        pfofile0_done <= 1'b0;
    end
    else if (addr_data_valid && (~cmd_data_valid) && (addr_data == 8'h0E))begin
        pfofile0 <= {pfofile0,addr_data};
        pfofile0_done <= 1'b0;
    end
    else if(cmd_data_valid && (addr_data == 8'h0E))begin
        pfofile0 <= {pfofile0,cmd_data};
        if(end_cnt)begin
            pfofile0_done <= 1'b1;
        end
    end
    else if(Req72_Ndg)begin
        pfofile0_done <= 1'b0;
    end
end 

// - - - - - - - - - - - - 其它通用命令- - - - - - - - - - - - - -//
//pulse_position
always @(posedge sys_clk)begin
    if (sys_rst)begin
        pulse_position <= 'b0;
        pulse_position_done <= 1'b0;
    end
    else if (addr_data_valid && (~cmd_data_valid) && (addr_data == 8'h20))begin
        pulse_position <= {pulse_position,addr_data};
        pulse_position_done <= 1'b0;
    end
    else if(cmd_data_valid && (addr_data == 8'h20))begin
        pulse_position <= {pulse_position,cmd_data};
        if(end_cnt)begin
            pulse_position_done <= 1'b1;
        end
    end
    else begin
        pulse_position_done <= 1'b0;
    end
end 
//triger_pulse
always @(posedge sys_clk)begin
    if (sys_rst)begin
        triger_pulse <= 'b0;
        triger_pulse_done <= 1'b0;
    end
    else if (addr_data_valid && (~cmd_data_valid) && (addr_data == 8'h21))begin
        triger_pulse <= {triger_pulse,addr_data};
        triger_pulse_done <= 1'b0;
    end
    else if(cmd_data_valid && (addr_data == 8'h21))begin
        triger_pulse <= {triger_pulse,cmd_data};
        if(end_cnt)begin
            triger_pulse_done <= 1'b1;
        end
    end
    else begin
        triger_pulse_done <= 1'b0;
    end
end 

//16位的数据发送暂时没用上
 assign ad9910_reg16_valid = 1'b0;
 assign ad9910_reg16 = 'b0;
 assign ad9910_reg40_valid = cfr1_done|
                             cfr2_done|
                             cfr3_done|
                             digital_ramp_rate_done|
                             asf_done;
 assign ad9910_reg40 = cfr1_done?cfr1:
                       cfr2_done?cfr2:
                       cfr3_done?cfr3:
                       asf_done?asf:
                       digital_ramp_rate_done?digital_ramp_rate:1'b0;
 assign ad9910_reg72_valid = digital_ramp_limit_done|
                             digital_ramp_step_done|
                             pfofile0_done;
 assign ad9910_reg72 = digital_ramp_limit_done?digital_ramp_limit:
                       digital_ramp_step_done?digital_ramp_step:
                       pfofile0_done?pfofile0:1'b0;
//16字节SPI发送    
//wire spi_busy16;
//wire spi_clk16;
//wire spi_mosi16;
//wire spi_miso16;
//wire spi_cs_n16;
//SPI_Master#(
//	.CLK_FREQ(CLK_FREQ),			/* 模块时钟输入，单位为MHz */
//	.SPI_CLK(SPI_CLK),		    /* SPI时钟频率，单位为KHz */
//	.CPOL(0),				/* SPI时钟极性控制 */
//	.CPHA(0),				/* SPI时钟相位控制 */
//	.DATA_WIDTH(16)			/* 数据宽度 */
//)spi_master_width16(
//	.Clk_I(sys_clk),		/* 模块时钟输入，应和CLK_FREQ一样 */
//	.RstP_I(sys_rst),			/* 异步复位信号，低电平有效 */
//	
//	.WrRdReq_I(ad9910_reg16_valid),		/* 读/写数据请求 */	
//	.Data_I(ad9910_reg16),		    /* 要写入的数据 */
//	.Data_O(),		    /* 读取到的数据 */
//	.DataValid_O(),	/* 读取数据有效，上升沿有效 */
//	.Busy_O(spi_busy16),			/* 模块忙信号 */

//	.SCK_O (spi_clk16),			/* SPI模块时钟输出 */
//	.MOSI_O(spi_mosi16),			/* MOSI_O */
//	.MISO_I(spi_miso16),			/* MISO_I  */
//	.CS_O  (spi_cs_n16)
//);

//40字节SPI发送    
wire spi_busy40;
wire spi_clk40;
wire spi_mosi40;
wire spi_miso40;
wire spi_cs_n40;
SPI_Master#(
	.CLK_FREQ(CLK_FREQ),			/* 模块时钟输入，单位为MHz */
	.SPI_CLK(SPI_CLK),		    /* SPI时钟频率，单位为KHz */
	.CPOL(0),				/* SPI时钟极性控制 */
	.CPHA(0),				/* SPI时钟相位控制 */
	.DATA_WIDTH(40)			/* 数据宽度 */
)spi_master_width40(
	.Clk_I(sys_clk),		/* 模块时钟输入，应和CLK_FREQ一样 */
	.RstP_I(sys_rst),			/* 异步复位信号，低电平有效 */
	
	.WrRdReq_I(ad9910_reg40_valid),		/* 读/写数据请求 */	
	.Data_I(ad9910_reg40),		    /* 要写入的数据 */
	.Data_O(),		    /* 读取到的数据 */
	.DataValid_O(),	/* 读取数据有效，上升沿有效 */
	.Busy_O(spi_busy40),			/* 模块忙信号 */

	.SCK_O (spi_clk40),			/* SPI模块时钟输出 */
	.MOSI_O(spi_mosi40),			/* MOSI_O */
	.MISO_I(spi_miso40),			/* MISO_I  */
	.CS_O  (spi_cs_n40)
);
 
//72字节SPI发送    
wire spi_busy72;
wire spi_clk72;
wire spi_mosi72;
wire spi_miso72;
wire spi_cs_n72;
SPI_Master#(
	.CLK_FREQ(CLK_FREQ),			/* 模块时钟输入，单位为MHz */
	.SPI_CLK(SPI_CLK),		    /* SPI时钟频率，单位为KHz */
	.CPOL(0),				/* SPI时钟极性控制 */
	.CPHA(0),				/* SPI时钟相位控制 */
	.DATA_WIDTH(72)			/* 数据宽度 */
)spi_master_width72(
	.Clk_I(sys_clk),		/* 模块时钟输入，应和CLK_FREQ一样 */
	.RstP_I(sys_rst),			/* 异步复位信号，低电平有效 */
	
	.WrRdReq_I(ad9910_reg72_valid),		/* 读/写数据请求 */	
	.Data_I(ad9910_reg72),		    /* 要写入的数据 */
	.Data_O(),		    /* 读取到的数据 */
	.DataValid_O(),	/* 读取数据有效，上升沿有效 */
	.Busy_O(spi_busy72),			/* 模块忙信号 */

	.SCK_O (spi_clk72),			/* SPI模块时钟输出 */
	.MOSI_O(spi_mosi72),			/* MOSI_O */
	.MISO_I(spi_miso72),			/* MISO_I  */
	.CS_O  (spi_cs_n72)
); 

//根据字节选择SPI发送字节的长度
 assign SCK_O = 
//ad9910_reg16_valid?spi_clk16:
                ad9910_reg40_valid?spi_clk40:
                ad9910_reg72_valid?spi_clk72:1'b0;
 assign MOSI_O = 
//ad9910_reg16_valid?spi_mosi16:
                 ad9910_reg40_valid?spi_mosi40:
                 ad9910_reg72_valid?spi_mosi72:1'b0;
 assign MISO_I = 
//ad9910_reg16_valid?spi_miso16:
                 ad9910_reg40_valid?spi_miso40:
                 ad9910_reg72_valid?spi_miso72:1'b0;
 assign CS_O = 
//ad9910_reg16_valid?spi_cs_n16:
               ad9910_reg40_valid?spi_cs_n40:
               ad9910_reg72_valid?spi_cs_n72:1'b1;
endmodule
