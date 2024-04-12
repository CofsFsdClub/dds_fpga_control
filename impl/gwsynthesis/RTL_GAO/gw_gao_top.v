module gw_gao(
    \addr_data[7] ,
    \addr_data[6] ,
    \addr_data[5] ,
    \addr_data[4] ,
    \addr_data[3] ,
    \addr_data[2] ,
    \addr_data[1] ,
    \addr_data[0] ,
    \cmd_data[7] ,
    \cmd_data[6] ,
    \cmd_data[5] ,
    \cmd_data[4] ,
    \cmd_data[3] ,
    \cmd_data[2] ,
    \cmd_data[1] ,
    \cmd_data[0] ,
    addr_data_valid,
    cmd_data_valid,
    \uart_rec_decode/byte_rec[7] ,
    \uart_rec_decode/byte_rec[6] ,
    \uart_rec_decode/byte_rec[5] ,
    \uart_rec_decode/byte_rec[4] ,
    \uart_rec_decode/byte_rec[3] ,
    \uart_rec_decode/byte_rec[2] ,
    \uart_rec_decode/byte_rec[1] ,
    \uart_rec_decode/byte_rec[0] ,
    clk_in,
    tms_pad_i,
    tck_pad_i,
    tdi_pad_i,
    tdo_pad_o
);

input \addr_data[7] ;
input \addr_data[6] ;
input \addr_data[5] ;
input \addr_data[4] ;
input \addr_data[3] ;
input \addr_data[2] ;
input \addr_data[1] ;
input \addr_data[0] ;
input \cmd_data[7] ;
input \cmd_data[6] ;
input \cmd_data[5] ;
input \cmd_data[4] ;
input \cmd_data[3] ;
input \cmd_data[2] ;
input \cmd_data[1] ;
input \cmd_data[0] ;
input addr_data_valid;
input cmd_data_valid;
input \uart_rec_decode/byte_rec[7] ;
input \uart_rec_decode/byte_rec[6] ;
input \uart_rec_decode/byte_rec[5] ;
input \uart_rec_decode/byte_rec[4] ;
input \uart_rec_decode/byte_rec[3] ;
input \uart_rec_decode/byte_rec[2] ;
input \uart_rec_decode/byte_rec[1] ;
input \uart_rec_decode/byte_rec[0] ;
input clk_in;
input tms_pad_i;
input tck_pad_i;
input tdi_pad_i;
output tdo_pad_o;

wire \addr_data[7] ;
wire \addr_data[6] ;
wire \addr_data[5] ;
wire \addr_data[4] ;
wire \addr_data[3] ;
wire \addr_data[2] ;
wire \addr_data[1] ;
wire \addr_data[0] ;
wire \cmd_data[7] ;
wire \cmd_data[6] ;
wire \cmd_data[5] ;
wire \cmd_data[4] ;
wire \cmd_data[3] ;
wire \cmd_data[2] ;
wire \cmd_data[1] ;
wire \cmd_data[0] ;
wire addr_data_valid;
wire cmd_data_valid;
wire \uart_rec_decode/byte_rec[7] ;
wire \uart_rec_decode/byte_rec[6] ;
wire \uart_rec_decode/byte_rec[5] ;
wire \uart_rec_decode/byte_rec[4] ;
wire \uart_rec_decode/byte_rec[3] ;
wire \uart_rec_decode/byte_rec[2] ;
wire \uart_rec_decode/byte_rec[1] ;
wire \uart_rec_decode/byte_rec[0] ;
wire clk_in;
wire tms_pad_i;
wire tck_pad_i;
wire tdi_pad_i;
wire tdo_pad_o;
wire tms_i_c;
wire tck_i_c;
wire tdi_i_c;
wire tdo_o_c;
wire [9:0] control0;
wire gao_jtag_tck;
wire gao_jtag_reset;
wire run_test_idle_er1;
wire run_test_idle_er2;
wire shift_dr_capture_dr;
wire update_dr;
wire pause_dr;
wire enable_er1;
wire enable_er2;
wire gao_jtag_tdi;
wire tdo_er1;

IBUF tms_ibuf (
    .I(tms_pad_i),
    .O(tms_i_c)
);

IBUF tck_ibuf (
    .I(tck_pad_i),
    .O(tck_i_c)
);

IBUF tdi_ibuf (
    .I(tdi_pad_i),
    .O(tdi_i_c)
);

OBUF tdo_obuf (
    .I(tdo_o_c),
    .O(tdo_pad_o)
);

GW_JTAG  u_gw_jtag(
    .tms_pad_i(tms_i_c),
    .tck_pad_i(tck_i_c),
    .tdi_pad_i(tdi_i_c),
    .tdo_pad_o(tdo_o_c),
    .tck_o(gao_jtag_tck),
    .test_logic_reset_o(gao_jtag_reset),
    .run_test_idle_er1_o(run_test_idle_er1),
    .run_test_idle_er2_o(run_test_idle_er2),
    .shift_dr_capture_dr_o(shift_dr_capture_dr),
    .update_dr_o(update_dr),
    .pause_dr_o(pause_dr),
    .enable_er1_o(enable_er1),
    .enable_er2_o(enable_er2),
    .tdi_o(gao_jtag_tdi),
    .tdo_er1_i(tdo_er1),
    .tdo_er2_i(1'b0)
);

gw_con_top  u_icon_top(
    .tck_i(gao_jtag_tck),
    .tdi_i(gao_jtag_tdi),
    .tdo_o(tdo_er1),
    .rst_i(gao_jtag_reset),
    .control0(control0[9:0]),
    .enable_i(enable_er1),
    .shift_dr_capture_dr_i(shift_dr_capture_dr),
    .update_dr_i(update_dr)
);

ao_top_0  u_la0_top(
    .control(control0[9:0]),
    .trig0_i({\cmd_data[7] ,\cmd_data[6] ,\cmd_data[5] ,\cmd_data[4] ,\cmd_data[3] ,\cmd_data[2] ,\cmd_data[1] ,\cmd_data[0] ,cmd_data_valid,\uart_rec_decode/byte_rec[7] ,\uart_rec_decode/byte_rec[6] ,\uart_rec_decode/byte_rec[5] ,\uart_rec_decode/byte_rec[4] ,\uart_rec_decode/byte_rec[3] ,\uart_rec_decode/byte_rec[2] ,\uart_rec_decode/byte_rec[1] ,\uart_rec_decode/byte_rec[0] }),
    .data_i({\addr_data[7] ,\addr_data[6] ,\addr_data[5] ,\addr_data[4] ,\addr_data[3] ,\addr_data[2] ,\addr_data[1] ,\addr_data[0] ,\cmd_data[7] ,\cmd_data[6] ,\cmd_data[5] ,\cmd_data[4] ,\cmd_data[3] ,\cmd_data[2] ,\cmd_data[1] ,\cmd_data[0] ,addr_data_valid,cmd_data_valid,\uart_rec_decode/byte_rec[7] ,\uart_rec_decode/byte_rec[6] ,\uart_rec_decode/byte_rec[5] ,\uart_rec_decode/byte_rec[4] ,\uart_rec_decode/byte_rec[3] ,\uart_rec_decode/byte_rec[2] ,\uart_rec_decode/byte_rec[1] ,\uart_rec_decode/byte_rec[0] }),
    .clk_i(clk_in)
);

endmodule
