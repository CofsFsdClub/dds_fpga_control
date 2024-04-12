`timescale 1ns / 1ns
module my_uart_tx_tb();

parameter   CYCLE    =  20;
parameter   RST_TIME =  3;

reg         rst_n;
reg         clk;
reg         uart_rx;

wire rx_valid;
wire [7:0] byte_rec;
uart_rx #
(
	.BPS				(9600),
	.SYS_CLK_FRE		(50000000)
)
u_uart_rx(
	.sys_clk			(clk),
	.sys_rst_n		    (~rst_n),
	
	.uart_rxd		    (uart_rx),	
	.uart_rx_valid	    (rx_valid),//每当接收到一个数据，byte_rec_done会置高一个周期
	.uart_rx_data	    (byte_rec)
);

initial begin
   clk = 1;
   forever
   #(CYCLE/2)
   clk = ~clk;
end

initial begin
   rst_n = 1;
   #3;
   rst_n = 0;
   #(RST_TIME*CYCLE)
   rst_n = 1;
end

initial begin
   uart_rx = 1'b1;
   @(posedge rst_n);
   #(8*CYCLE);
   uart_tx(8'hAA);
   @(posedge rx_done);
   #100000;
   uart_tx(8'h78);
   @(posedge rx_done);
   #100000;
   uart_tx(8'h38);
   @(posedge rx_done);
   #100000;
   uart_tx(8'h47);
   @(posedge rx_done);
   #100000;
   $stop;
end

task uart_tx;
   input [7:0] data_in;
   begin
      uart_rx = 1'b0;
      #(5208*CYCLE);
      uart_rx = data_in[0];
      #(5208*CYCLE);
      uart_rx = data_in[1];
      #(5208*CYCLE);
      uart_rx = data_in[2];
      #(5208*CYCLE);
      uart_rx = data_in[3];
      #(5208*CYCLE);
      uart_rx = data_in[4];
      #(5208*CYCLE);
      uart_rx = data_in[5];
      #(5208*CYCLE);
      uart_rx = data_in[6];
      #(5208*CYCLE);
      uart_rx = data_in[7];
      #(5208*CYCLE);
      uart_rx = 1'b1;
   end
endtask

endmodule
