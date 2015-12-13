// File name:   tb_controller.sv
// Updated:     30 November 2015
// Authors:     Brian Rieder 
//              Catie Cowden 
//              Shaughan Gladden
// Description: This test bench is used to test the functionality of the controller block. The controller block manages signals entering and leaving the design. It is the brain behind when data is compared, when it is stored, and when the design is idle.

`timescale 1ns/10ps

module tb_controller();

reg clk;
reg n_rst;
reg port_hits, ip_hits, mac_hits, url_hits;
reg eop, valid, sop, ready, update_done, inc_addr;
reg [1:0] empty;
reg [5:0] error;
reg port_match, ip_match, mac_match, url_match, clear;

controller CTRLR(.clk, .n_rst, .port_match, .ip_match, .url_match, .mac_match, .update_done, .sop, .eop, .error, .valid, .empty, .ready, .inc_addr, .clear, .port_hits, .ip_hits. mac_hits, .url_hits);

localparam CLK_PERIOD = 10;

//Clock generation block
always
begin
	clk = 1'b0;
	#(CLK_PERIOD/2.0);
	clk = 1'b1;
	#(CLK_PERIOD/2.0);
end

clocking cb @(posedge clk);
	default input #1step output #100ps;
	output #800ps n_rst = n_rst;
	input ia = inc_addr;
	input clr = clear;
	input uh = url_hits;
	input ph = port_hits;
	input ih = ip_hits;
	input mh = mac_hits;
	input rdy = ready;
	output e = eop;
	output s = sop;
	output v = valid;
	output emp = empty;
	output pm = port_match;
	output im = ip_match;
	output mm = mac_match;
	output um = url_match;
	output ud = update_done;
	output err = error;
endclocking

initial
begin
	
	//*******************Test Case 1:*********************//
	
	$stop;

end

endmodule
