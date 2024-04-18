//Copyright (C)2014-2024 Gowin Semiconductor Corporation.
//All rights reserved.
//File Title: IP file
//Tool Version: V1.9.9.02
//Part Number: GW5A-LV25MG121NC1/I0
//Device: GW5A-25
//Device Version: A
//Created Time: Sun Apr 14 17:25:22 2024

module Gowin_DCE (clkout, clkin, ce);

output clkout;
input clkin;
input ce;

DCE dce_inst (
    .CLKOUT(clkout),
    .CLKIN(clkin),
    .CE(ce)
);

endmodule //Gowin_DCE
