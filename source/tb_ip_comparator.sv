// File name:   result_address_fsm.sv
// Updated:     12 November 2015
// Authors:     Brian Rieder 
//              Catie Cowden 
//              Shaughan Gladden
// Description: Test Bench for the Result Address FSM.

`timescale 1ns/10ps

module tb_ip_comparator();

reg clk;
reg n_rst;
reg [31:0] tb_ip_in;
reg [31:0] data_in;
reg [31:0] data_out;

reg [31:0] expected_data_out;

ip_comparator COMP(.clk, .n_rst, .data_in, .data_out, .ip_in(tb_ip_in));

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
	output datai = data_in;
	output ipin = tb_ip_in;
	input datao = data_out;
endclocking

initial
begin
	tb_ip_in = 32'hC0A80101; //192.168.001.001
	$info(tb_ip_in);
	data_in = 0;
	cb.n_rst <= 1'b1;

	expected_data_out = 32'h0000;

	@cb; //RESET
	cb.n_rst <= 1'b0;

	@cb; @cb;
	assert(expected_data_out == cb.datao)
	else $error("0: ERROR: data_out is incorrect.");
	@cb; cb.n_rst <= 1'b1;

end
endmodule
