module my_uart_rx(
   rst_n    ,
   clk      ,
   uart_rx  ,
   baud_set ,
   data     ,
   rx_done  
);
parameter   DATA_W   =  8;    //��������λ��
parameter   BAUD_W   =  10;   //�����ʼ�����λ��
parameter   SYNC_W   =  3;    //���ؼ���ź�λ��
parameter   SAMP_N   =  16;   //���������,ÿ������16��������
parameter   SAMP_W   =  4;    //������λ��
parameter   BYTE_W   =  4;    //���ؼ�����λ��
parameter   BYTE_N   =  9;    //���ؼ���������,����Ҫ�Կ���λ���д���
parameter   BAUDS_W  =  3;    //��������������λ��


input                   rst_n;
input                   clk;
input                   uart_rx;
input    [BAUDS_W-1:0]  baud_set;
output   [DATA_W-1:0]   data;
output                  rx_done;

reg      [DATA_W-1:0]   data;
reg                     rx_done;

reg      [BAUD_W-1:0]   cnt_baud;
wire                    add_cnt_baud;
wire                    end_cnt_baud;

reg      [SAMP_W-1:0]   cnt_sample;
wire                    add_cnt_sample;
wire                    end_cnt_sample;

reg      [BYTE_W-1:0]   cnt_byte;
wire                    add_cnt_byte;
wire                    end_cnt_byte;


reg      [BAUD_W-1:0]   baud;
reg      [SYNC_W-1:0]   uart_sync;

//�Ĵ������飬��ʾ9��λ��Ϊ3�ļĴ���,������Ų�����
reg      [2:0]          data_tmp[8:0];
wire                    nedge_flag;

reg                     add_flag;

//�����ʼ�����
always @(posedge clk or negedge rst_n)begin
   if(!rst_n)
      cnt_baud <= 0;
   else if(add_cnt_baud)begin
      if(end_cnt_baud)
         cnt_baud <= 0;
      else
         cnt_baud <= cnt_baud + 1'b1;
   end
end
assign add_cnt_baud = add_flag;
assign end_cnt_baud = add_cnt_baud && cnt_baud == baud - 1;

//�����������
always @(posedge clk or negedge rst_n)begin
   if(!rst_n)
      cnt_sample <= 0;
   else if(add_cnt_sample)begin
      if(end_cnt_sample)
         cnt_sample <= 0;
      else
         cnt_sample <= cnt_sample + 1'b1;
   end
end
assign add_cnt_sample   =  end_cnt_baud;
assign end_cnt_sample   =  add_cnt_sample && cnt_sample == SAMP_N - 1;

//���ؼ�����
always @(posedge clk or negedge rst_n)begin
   if(!rst_n)
      cnt_byte <= 0;
   else if(add_cnt_byte)begin
      if(end_cnt_byte)
         cnt_byte <= 0;
      else
         cnt_byte <= cnt_byte + 1'b1;
   end
end
assign add_cnt_byte = end_cnt_sample;
assign end_cnt_byte = add_cnt_byte && cnt_byte == BYTE_N - 1;

//ȡ1bit�����м��7������в�������
always @(posedge clk or negedge rst_n)begin
   if(!rst_n)begin
      data_tmp[0] <= 0; 
      data_tmp[1] <= 0; 
      data_tmp[2] <= 0; 
      data_tmp[3] <= 0; 
      data_tmp[4] <= 0; 
      data_tmp[5] <= 0; 
      data_tmp[6] <= 0; 
      data_tmp[7] <= 0; 
      data_tmp[8] <= 0; 
   end
   else if(cnt_baud==((baud>>2) - 1) && add_cnt_baud)begin
      case(cnt_sample)
         5,6,7,8,9,10,11:data_tmp[cnt_byte] <= data_tmp[cnt_byte] + uart_rx;
         default:data_tmp[cnt_byte] <= data_tmp[cnt_byte];
      endcase
   end
   else if(end_cnt_byte)begin
      data_tmp[0] <= 0; 
      data_tmp[1] <= 0; 
      data_tmp[2] <= 0; 
      data_tmp[3] <= 0; 
      data_tmp[4] <= 0; 
      data_tmp[5] <= 0; 
      data_tmp[6] <= 0; 
      data_tmp[7] <= 0; 
      data_tmp[8] <= 0; 
   end
end

//�жϲ�����0,1�ĸ������һ������λ�ɵ�1�ĸ�����0�࣬��ô���1���������0
always @(posedge clk or negedge rst_n)begin
   if(!rst_n)
      data <= 0;
   else if(end_cnt_sample && cnt_byte >= 1 && cnt_byte < 9)
      data[cnt_byte-1] <= (data_tmp[cnt_byte] >= 4);
end

// ������ѡ������16�����
// (1/baud_rate)*50MHz/16
always @(*)begin
   case(baud_set)
      3'd0:baud = 5208;//600bps
      3'd1:baud = 2604;//1200bps 
      3'd2:baud = 1302;//2400bps 
      3'd3:baud = 651 ;//4800bps
      3'd4:baud = 325 ;//9600bps 
      3'd5:baud = 163 ;//19200bps 
      3'd6:baud = 81  ;//38400bps 
      3'd7:baud = 54  ;//57600bps
      default:baud = 325;
   endcase
end

//���ؼ��
always @(posedge clk or negedge rst_n)begin
   if(!rst_n)
      uart_sync <= 3'b111;
   else
      uart_sync <= {uart_sync[1:0],uart_rx};
end
assign nedge_flag = uart_sync[2:1]==2'b10;

always @(posedge clk or negedge rst_n)begin
   if(!rst_n)
      rx_done <= 0;
   else if(end_cnt_byte)
      rx_done <= 1;
   else
      rx_done <= 0;
end

always @(posedge clk or negedge rst_n)begin
   if(!rst_n)
      add_flag <= 0;
   else if(nedge_flag)
      add_flag <= 1;
   else if(end_cnt_byte)
      add_flag <= 0;
end

endmodule
