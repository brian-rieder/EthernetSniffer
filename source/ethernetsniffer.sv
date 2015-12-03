// $Id:
// File name:   ethernetsniffer.sv
// Created:     10/5/2015
// Author:      Caitlin Cowden
// Lab Section: 337-07
// Version:     1.0  Initial Design Entry
// Description: wrapper file

module ethernetsniffer(
input wire clk,
input wire n_rst,
input wire [31:0] dataIn,
input wire eop,
input wire empty,
input wire err,
input wire valid,
input wire ready,
input wire sop,
input reg [15:0] flagged_port,
input reg [31:0] flagged_ip,
input reg [47:0] flagged_mac,
input reg [0:16][7:0] flagged_string;
output wire addr_toAM,
output wire wr_en,
output wire addr_toAS,
output wire rdreq,
output wire [31:0] dataOut
);

wire shift_enable, eop, d_orig;
wire d_edge, byte_received, d_minus_sync, d_plus_sync, w_enable;
wire [7:0] rcv_data;

decode DECODE(.clk(clk), .n_rst(n_rst), .d_plus(d_plus_sync), 
.shift_enable(shift_enable), .eop(eop), .d_orig(d_orig));


endmodule
