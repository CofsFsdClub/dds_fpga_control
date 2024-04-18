module gw_gao(
    \triger_pulse[15] ,
    \triger_pulse[14] ,
    \triger_pulse[13] ,
    \triger_pulse[12] ,
    \triger_pulse[11] ,
    \triger_pulse[10] ,
    \triger_pulse[9] ,
    \triger_pulse[8] ,
    \triger_pulse[7] ,
    \triger_pulse[6] ,
    \triger_pulse[5] ,
    \triger_pulse[4] ,
    \triger_pulse[3] ,
    \triger_pulse[2] ,
    \triger_pulse[1] ,
    \triger_pulse[0] ,
    pulse_position,
    osk,
    drctl,
    drover,
    io_update,
    clk_500m,
    tms_pad_i,
    tck_pad_i,
    tdi_pad_i,
    tdo_pad_o
);

input \triger_pulse[15] ;
input \triger_pulse[14] ;
input \triger_pulse[13] ;
input \triger_pulse[12] ;
input \triger_pulse[11] ;
input \triger_pulse[10] ;
input \triger_pulse[9] ;
input \triger_pulse[8] ;
input \triger_pulse[7] ;
input \triger_pulse[6] ;
input \triger_pulse[5] ;
input \triger_pulse[4] ;
input \triger_pulse[3] ;
input \triger_pulse[2] ;
input \triger_pulse[1] ;
input \triger_pulse[0] ;
input pulse_position;
input osk;
input drctl;
input drover;
input io_update;
input clk_500m;
input tms_pad_i;
input tck_pad_i;
input tdi_pad_i;
output tdo_pad_o;

wire \triger_pulse[15] ;
wire \triger_pulse[14] ;
wire \triger_pulse[13] ;
wire \triger_pulse[12] ;
wire \triger_pulse[11] ;
wire \triger_pulse[10] ;
wire \triger_pulse[9] ;
wire \triger_pulse[8] ;
wire \triger_pulse[7] ;
wire \triger_pulse[6] ;
wire \triger_pulse[5] ;
wire \triger_pulse[4] ;
wire \triger_pulse[3] ;
wire \triger_pulse[2] ;
wire \triger_pulse[1] ;
wire \triger_pulse[0] ;
wire pulse_position;
wire osk;
wire drctl;
wire drover;
wire io_update;
wire clk_500m;
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
    .trig0_i({\triger_pulse[15] ,\triger_pulse[14] ,\triger_pulse[13] ,\triger_pulse[12] ,\triger_pulse[11] ,\triger_pulse[10] ,\triger_pulse[9] ,\triger_pulse[8] ,\triger_pulse[7] ,\triger_pulse[6] ,\triger_pulse[5] ,\triger_pulse[4] ,\triger_pulse[3] ,\triger_pulse[2] ,\triger_pulse[1] ,\triger_pulse[0] ,pulse_position,osk,drctl,io_update}),
    .data_i({\triger_pulse[15] ,\triger_pulse[14] ,\triger_pulse[13] ,\triger_pulse[12] ,\triger_pulse[11] ,\triger_pulse[10] ,\triger_pulse[9] ,\triger_pulse[8] ,\triger_pulse[7] ,\triger_pulse[6] ,\triger_pulse[5] ,\triger_pulse[4] ,\triger_pulse[3] ,\triger_pulse[2] ,\triger_pulse[1] ,\triger_pulse[0] ,pulse_position,osk,drctl,drover,io_update}),
    .clk_i(clk_500m)
);

endmodule
