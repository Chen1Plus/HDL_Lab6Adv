// Copyright 1986-2019 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2019.2 (win64) Build 2708876 Wed Nov  6 21:40:23 MST 2019
// Date        : Tue Nov 26 00:52:54 2024
// Host        : Aaron-PC running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode synth_stub c:/Users/1plus/Documents/HWD/Lab6Adv/src/ip/Clk8MHz/Clk8MHz_stub.v
// Design      : Clk8MHz
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7a35tcpg236-1
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
module Clk8MHz(c8MHz, reset, clk)
/* synthesis syn_black_box black_box_pad_pin="c8MHz,reset,clk" */;
  output c8MHz;
  input reset;
  input clk;
endmodule
