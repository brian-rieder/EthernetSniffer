// File name:   tb_ip_comparator.sv
// Updated:     19 November 2015
// Authors:     Brian Rieder 
//              Catie Cowden 
//              Shaughan Gladden
// Description: Test Bench for the IP comparator.

`timescale 1ns/10ps

module tb_ip_comparator();

reg clk;
reg n_rst;
reg [31:0] ip_in;
reg [31:0] data_in;
reg [31:0] data_out;
reg match;
reg clear;

reg [31:0] expected_data_out;
reg expected_match;

reg [31:0] sample_data;
reg [31:0] sample_data_shift1;
reg [31:0] sample_data_shift1_2;
reg [31:0] sample_data_shift2;
reg [31:0] sample_data_shift2_2;
reg [31:0] sample_data_shift3;
reg [31:0] sample_data_shift3_2;

ip_comparator COMP(.clk, .n_rst, .clear, .ip_in, .data_in, .match, .data_out);

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
	output ipin = ip_in;
	output c = clear;
	input datao = data_out;
	input m = match;
endclocking

initial
begin
	sample_data = 32'hC0A80101; //192.168.001.001
	sample_data_shift1 = 32'h01000000;
	sample_data_shift1_2 = 32'h00C0A801;
	sample_data_shift2 = 32'h01010000;
	sample_data_shift2_2 = 32'h0000C0A8;
	sample_data_shift3 = 32'hA8010100;
	sample_data_shift3_2 = 32'h000000C0;
	data_in = 32'h0000;
	clear = '0;

	//Reset Test Case
	cb.n_rst <= 1'b1;
	@cb; cb.n_rst <= 1'b0; @cb;
	expected_data_out = '0;
	expected_match = '0;
	assert(expected_data_out == cb.datao)
	else $error("1: Reset Test Case: Incorrect Data_Out");
	assert(expected_match == cb.m)
	else $error("1: Reset Test Case: Incorrect Match Flag");
	cb.n_rst <= 1'b1;
	@cb; @cb;
	
	//*******************Test Case 2.1 No Shift*********************//
	ip_in = sample_data; 	
	data_in = sample_data; 
	expected_data_out = 32'h0000;
	expected_match = '0;
	@cb; @cb;
	assert(expected_data_out == cb.datao)
	else $error("2.1: Successful Match: Incorrect Data_Out");
	assert(expected_match == cb.m)
	else $error("2.1: Successful Match: Incorrect Match Flag");

	@cb;

	//Test Case 2.2
	data_in = 32'h0000; 
	expected_data_out = sample_data;
	expected_match = 1'b1;
	@cb; @cb;
	assert(expected_data_out == cb.datao)
	else $error("2.2: Successful Match: Incorrect Data_Out");
	assert(expected_match == cb.m)
	else $error("2.2: Successful Match: Incorrect Match Flag");

	@cb; clear = 1'b1; @cb; clear = 1'b0;

	//*******************Test Case 3.1: One Shift*********************//
	data_in = sample_data_shift1;
	expected_data_out = 32'h0000;
	expected_match = '0;
	@cb; @cb;
	assert(expected_data_out == cb.datao)
	else $error("3.1: Successful Match: Incorrect Data_Out");
	assert(expected_match == cb.m)
	else $error("3.1: Successful Match: Incorrect Match Flag");

	@cb;

	//Test Case 3.2
	data_in = sample_data_shift1_2;
	expected_data_out = sample_data_shift1;
	expected_match = 1'b0;
	@cb; @cb;
	assert(expected_data_out == cb.datao)
	else $error("3.2: Successful Match: Incorrect Data_Out");
	assert(expected_match == cb.m)
	else $error("3.2: Successful Match: Incorrect Match Flag");

	@cb;
	
	//Test Case 3.3
	data_in = 32'h0000;
	expected_data_out = sample_data_shift1_2;
	expected_match = 1'b1;
	@cb; @cb;
	assert(expected_data_out == cb.datao)
	else $error("3.3: Successful Match: Incorrect Data_Out");
	assert(expected_match == cb.m)
	else $error("3.3: Successful Match: Incorrect Match Flag");
	

	@cb; clear = 1'b1; @cb; clear = 1'b0;

	//*******************Test Case 4.1: Two Shift*********************//
	data_in = sample_data_shift2;
	expected_data_out = 32'h0000;
	expected_match = '0;
	@cb; @cb;
	assert(expected_data_out == cb.datao)
	else $error("4.1: Successful Match: Incorrect Data_Out");
	assert(expected_match == cb.m)
	else $error("4.1: Successful Match: Incorrect Match Flag");

	@cb;

	//Test Case 4.2
	data_in = sample_data_shift2_2;
	expected_data_out = sample_data_shift2;
	expected_match = 1'b0;
	@cb; @cb;
	assert(expected_data_out == cb.datao)
	else $error("4.2: Successful Match: Incorrect Data_Out");
	assert(expected_match == cb.m)
	else $error("4.2: Successful Match: Incorrect Match Flag");

	@cb;
	
	//Test Case 4.3
	data_in = 32'h0000;
	expected_data_out = sample_data_shift2_2;
	expected_match = 1'b1;
	@cb; @cb;
	assert(expected_data_out == cb.datao)
	else $error("4.3: Successful Match: Incorrect Data_Out");
	assert(expected_match == cb.m)
	else $error("4.3: Successful Match: Incorrect Match Flag");
	
	@cb; clear = 1'b1; @cb;

		@cb; clear = 1'b1; @cb; clear = 1'b0;

	//*******************Test Case 5.1: Two Shift*********************//
	data_in = sample_data_shift3;
	expected_data_out = 32'h0000;
	expected_match = '0;
	@cb; @cb;
	assert(expected_data_out == cb.datao)
	else $error("5.1: Successful Match: Incorrect Data_Out");
	assert(expected_match == cb.m)
	else $error("5.1: Successful Match: Incorrect Match Flag");

	@cb;

	//Test Case 5.2
	data_in = sample_data_shift3_2;
	expected_data_out = sample_data_shift3;
	expected_match = 1'b0;
	@cb; @cb;
	assert(expected_data_out == cb.datao)
	else $error("5.2: Successful Match: Incorrect Data_Out");
	assert(expected_match == cb.m)
	else $error("5.2: Successful Match: Incorrect Match Flag");

	@cb;
	
	//Test Case 5.3
	data_in = 32'h0000;
	expected_data_out = sample_data_shift3_2;
	expected_match = 1'b1;
	@cb; @cb;
	assert(expected_data_out == cb.datao)
	else $error("5.3: Successful Match: Incorrect Data_Out");
	assert(expected_match == cb.m)
	else $error("5.3: Successful Match: Incorrect Match Flag");
	
	@cb; clear = 1'b1; @cb;

	$stop;

end
endmodule
