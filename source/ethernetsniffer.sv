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
input wire [1:0] empty,
input wire [5:0] error,
input wire valid,
input wire ready,
input wire sop,
input wire [15:0] flagged_port,
input wire [31:0] flagged_ip,
input wire [47:0] flagged_mac,
input wire [0:16][7:0] flagged_string,
input wire update_done, //from A/S
input wire [4:0] strlen,
output wire [31:0] addr_out,
output wire write_enable,
output wire [31:0] data_out,
output reg [63:0] port_hits, ip_hits, mac_hits, url_hits);

wire clear;
//wire [4:0] strlen;
wire url_match;
wire mac_match;
wire ip_match;
wire port_match;
wire inc_addr;


string_comparator SC(.clk, .n_rst, .clear(clear), .flagged_string, .strlen, .data_in, .match(url_match), .data_out());

mac_comparator MC (.clk, .n_rst, .clear(clear), .flagged_mac, .data_in, .match(mac_match), .data_out);

ip_comparator IC (.clk, .n_rst, .clear(clear), .flagged_ip, .data_in, .match(ip_match), .data_out());

port_comparator PC (.clk, .n_rst, .clear(clear), .flagged_port, .data_in, .match(port_match), .data_out());

result_address_fsm RAFSM (.clk, .n_rst, .inc_addr, .addr_out, .write_enable);

controller CTRLR (.clk, .n_rst, .url_match(url_match), .port_match(port_match), .mac_match(mac_match), .ip_match(ip_match), .update_done, .ready, .valid, .eop, .error, .empty, .inc_addr, .port_hits, .ip_hits, .mac_hits, .url_hits, .clear(clear), .sop);

endmodule
