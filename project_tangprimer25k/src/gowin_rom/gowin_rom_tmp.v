//Copyright (C)2014-2026 Gowin Semiconductor Corporation.
//All rights reserved.
//File Title: Template file for instantiation
//Tool Version: V1.9.12.02_SP2
//IP Version: 1.0
//Part Number: GW5A-EV25UG256CES
//Device: GW5A-25
//Device Version: A
//Created Time: Fri May 15 16:29:32 2026

//Change the instance name and port connections to the signal names
//--------Copy here to design--------

    Gowin_ROM your_instance_name(
        .dout(dout), //output [7:0] dout
        .clk(clk), //input clk
        .oce(oce), //input oce
        .ce(ce), //input ce
        .reset(reset), //input reset
        .ad(ad) //input [10:0] ad
    );

//--------Copy end-------------------
