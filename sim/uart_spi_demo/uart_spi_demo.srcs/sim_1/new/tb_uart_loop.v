`timescale 1ns/1ps	//����ʱ��̶�
//ģ�顢�ӿڶ���
module tb_uart_loop();
reg 		sys_clk;			
reg 		sys_rst_n;			
reg 		uart_rxd;
wire 	 	uart_txd;
 
 wire [7:0]  addr_data;
 wire [7:0] cmd_data;
 wire data_done;
 wire rx_done;
wire addr_data_valid;
wire cmd_data_valid;

uart_decode#(
    .UART_BPS(9600),
    .CLK_FREQ(50_000_000),
    .HEAD_FREAME(8'hA6), //8'hA6, //����ͷ֡
    .END_FREAME(8'hCE) //����β֡
) 

uart_rec_decode(
    .sys_clk(sys_clk),			//50Mϵͳʱ��
    .sys_rst_n(sys_rst_n),			//ϵͳ��λ
    
    .uart_rxd(uart_rxd),          //���ڽ�������
    
    .addr_data(addr_data),
    .cmd_data(cmd_data),
    .addr_data_valid(addr_data_valid),
    .cmd_data_valid(cmd_data_valid),
    .data_done(data_done), //���һ�����ݽ����ı�־ 11�ֽ�
    .byte_valid(rx_done)    //�������ʱ���� ����һ���ֽڵı�־ 8bit
);

//uart_tx#(
//	.BPS		    (9600),
//	.SYS_CLK_FRE	(50_000_000))
//u_uart_tx(
//	.sys_clk		(sys_clk),
//	.sys_rst_n	    (sys_rst_n),
//	.uart_tx_en		(cmd_data_valid),
//	.uart_data	    (cmd_data),	
//	.uart_txd	    (uart_txd)
//);
 
 
 
 uart2spi_decode uart2spi_decode(
    .sys_clk(sys_clk),			//50Mϵͳʱ��
	.sys_rst(sys_rst_n),			//ϵͳ��λ

	.addr_data(addr_data),
	.cmd_data(cmd_data),
	.addr_data_valid(addr_data_valid),
	.cmd_data_valid(cmd_data_valid),
	.data_done(data_done),
	.spi_data()
    );
    
    
parameter CYCLE   =  20;
initial begin
   sys_clk = 1;
   forever 
   #(CYCLE/2)
   sys_clk = ~sys_clk;
end

initial begin
   sys_rst_n = 0;
   #300
   sys_rst_n = 1;
   #(10*CYCLE)
   sys_rst_n = 0;
end

initial begin
   uart_rxd = 1'b1;
   @(posedge sys_rst_n);
   #100000;
   uart_tx(8'h11);//�����
   @(posedge rx_done);
   #100000;
   uart_tx(8'h52);//�����
   @(posedge rx_done);
   #100000;
   uart_tx(8'h37);//�����
   @(posedge rx_done);
   #100000;
   uart_tx(8'hA6);//ͷ֡
   @(posedge rx_done);
   #100000;
   uart_tx(8'h05);//ָ����� ��ַ+ָ��
   @(posedge rx_done);
   #100000;
   uart_tx(8'h01);//��ַ
   @(posedge rx_done);
   #400000;
   uart_tx(8'hA6);//����1
   @(posedge rx_done);
   #100000;
   uart_tx(8'h79);//����2
   @(posedge rx_done);
   #100000;
   uart_tx(8'h26);//����3
   @(posedge rx_done);
   #200000;
   uart_tx(8'hA4);//����4
   @(posedge rx_done);
   #100000;
//   uart_tx(8'hE9);//����5
//   @(posedge rx_done);
//   #100000;
//   uart_tx(8'hA6);//����6
//   @(posedge rx_done);
//   #100000;
//   uart_tx(8'hCE);//����7
//   @(posedge rx_done);
//   #100000;
//   uart_tx(8'h20);//����8
//   @(posedge rx_done);
//   #100000;
   uart_tx(8'hCE);// β֡
   @(posedge rx_done);
   #1000000;
   
   $stop;
end


task uart_tx;
   input [7:0] data_in;
   begin
      uart_rxd = 1'b0;
      #(5208*CYCLE);
      uart_rxd = data_in[0];
      #(5208*CYCLE);
      uart_rxd = data_in[1];
      #(5208*CYCLE);
      uart_rxd = data_in[2];
      #(5208*CYCLE);
      uart_rxd = data_in[3];
      #(5208*CYCLE);
      uart_rxd = data_in[4];
      #(5208*CYCLE);
      uart_rxd = data_in[5];
      #(5208*CYCLE);
      uart_rxd = data_in[6];
      #(5208*CYCLE);
      uart_rxd = data_in[7];
      #(5208*CYCLE);
      uart_rxd = 1'b1;
   end
endtask
endmodule
