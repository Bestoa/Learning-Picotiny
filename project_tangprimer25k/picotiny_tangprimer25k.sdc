//Copyright (C)2014-2021 GOWIN Semiconductor Corporation.
//All rights reserved.
//File Title: Timing Constraints file
//GOWIN Version: 1.9.9
//Created Time: 2024-05-15

create_clock -name clk_osc -period 20 -waveform {0 10} [get_ports {clk}]
