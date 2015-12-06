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
input wire [31:0] data_in,
input wire eop,
input wire empty,
input wire error,
input wire valid,
input wire ready,
input wire sop,
input wire rdempty, //from Input FIFO??
input reg [15:0] flagged_port,
input reg [31:0] flagged_ip,
input reg [47:0] flagged_mac,
input reg [0:16][7:0] flagged_string,
output wire [31:0] addr_out,
output wire wr_en,
output wire addr_as,
output wire rdreq,
output wire [31:0] data_out);

wire clear;
wire [4:0] strlen;
wire url_match;
wire mac_match;
wire ip_match;
wire port_match;
wire inc_addr;
wire write_enable;

string_comparator SC(.clk, .n_rst, .clear, .flagged_string, .strlen, .data_in, .match(url_match), .data_out());

mac_comparator MC (.clk, .n_rst, .clear, .flagged_mac, .data_in, .match(mac_match), .data_out());

ip_comparator IC (.clk, .n_rst, .clear, .flagged_ip, .data_in, .match(ip_match), .data_out());

port_comparator PC (.clk, .n_rst, .clear, .flagged_port, .data_in, .match(port_match), .data_out);

result_address_fsm RAFSM (.clk, .n_rst, .inc_addr, .addr_out, .write_enable);

controller CTRLR (.clk, .n_rst, .url_match, .port_match, .mac_match, .ip_match, .shift_enable(valid), .update_done (eop), .ready, .eop, .error, .rdempty, .rdreq, .inc_addr, .addr(addr_as), .clear);

endmodule
