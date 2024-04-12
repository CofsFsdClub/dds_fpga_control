//Copyright (C)2014-2024 GOWIN Semiconductor Corporation.
//All rights reserved.
//File Title: Timing Constraints file
//GOWIN Version: 1.9.9 Beta-4 Education
//Created Time: 2024-04-05 18:28:01
create_clock -name clk_in -period 20 -waveform {0 10} [get_ports {clk_in}]
//create_clock -name clk_500m -period 2 -waveform {0 1} [get_nets {clk_500m}]
//report_route_congestion -max_grids 10
//set_operating_conditions -grade c -model fast -speed 2 -setup -hold
