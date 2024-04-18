module dds_cmd_set#
(
    parameter UART_BPS=115200,
    parameter CLK_FREQ=50000000,			/* 模块时钟输入，单位为MHz */
	parameter SPI_CLK=2000,		    /* SPI时钟频率，单位为KHz */
    parameter HEAD_FREAME_1=8'hAA, //定义头帧1
    parameter HEAD_FREAME_2=8'h55,//定义头帧2
    parameter END_FREAME=8'hCE //定义尾帧	
 )(
    input sys_clk,			//50M系统时钟
	input sys_rst,			//系统复位

    output reg pulse_position, //设置扫频方向 1正向 0负向
    output reg[16-1:0] triger_pulse, //设置脉宽
    input uart_rxd,
	output uart_txd,

    output SCK_O,
	output MOSI_O,
	input MISO_I,
	output CS_O
);

//- - - - - - - - - - DDS串口指令解析部分 - - - - - - - - - - - - -//
wire [7:0] addr_data;
wire [7:0] cmd_data;

wire addr_data_valid;
wire cmd_data_valid;
wire data_done;
uart_decode#(
    .UART_BPS(UART_BPS),
    .CLK_FREQ(CLK_FREQ),
    .HEAD_FREAME_1(HEAD_FREAME_1), //定义头帧1
    .HEAD_FREAME_2(HEAD_FREAME_2),//定义头帧2
    .END_FREAME(END_FREAME) //定义尾帧
)uart_rec_decode(
    .sys_clk(sys_clk),			//50M系统时钟
    .sys_rst_n(sys_rst),			//系统复位
    
    .uart_rxd(uart_rxd),          //串口接收引脚
    
    .addr_data(addr_data),
    .cmd_data(cmd_data),
    .addr_data_valid(addr_data_valid),
    .cmd_data_valid(cmd_data_valid),
    
    .data_done(data_done) //完成一次数据解析的标志 11字节
    //.byte_valid(rx_done)    //仅仿真的时候用 接收一个字节的标志 8bit
);

//放在这里测试用
uart_tx#(
	.BPS		    (UART_BPS),
	.SYS_CLK_FRE	(CLK_FREQ))
u_uart_tx(
	.sys_clk		(sys_clk),
	.sys_rst_n	    (sys_rst),
	.uart_tx_en		(cmd_data_valid),
	.uart_data	    (cmd_data),	
	.uart_txd	    (uart_txd)
);

//串口转SPI协议发送
wire [15:0]t_pulse_position;
wire t_pulse_position_done;
wire [15:0]t_triger_pulse;
wire t_triger_pulse_done;

 uart2spi_decode#(
    .CLK_FREQ(CLK_FREQ/1000000),			/* 模块时钟输入，单位为MHz */
	.SPI_CLK(SPI_CLK)		    /* SPI时钟频率，单位为KHz */	
 )uart2spi_decode(
    .sys_clk(sys_clk),			//50M系统时钟
	.sys_rst(sys_rst),			//系统复位

	.addr_data(addr_data),
	.cmd_data(cmd_data),
	.addr_data_valid(addr_data_valid),
	.cmd_data_valid(cmd_data_valid),
	.data_done(data_done),
	
	.pulse_position(t_pulse_position),
    .pulse_position_done(t_pulse_position_done),
    .triger_pulse(t_triger_pulse), //设置脉宽
    .triger_pulse_done(t_triger_pulse_done),
    
    .SCK_O(SCK_O),
	.MOSI_O(MOSI_O),
	.MISO_I(MISO_I),
	.CS_O(CS_O)
    );

always @(posedge sys_clk)begin
    if(sys_rst)begin
        pulse_position <= 1'b0;
    end
    else if(t_pulse_position_done)begin
        pulse_position <= t_pulse_position[0];
    end
end

always @(posedge sys_clk)begin
    if(sys_rst)begin
        triger_pulse <= 'b0;
    end
    else if(t_triger_pulse_done)begin
        triger_pulse <= t_triger_pulse;
    end
end


endmodule