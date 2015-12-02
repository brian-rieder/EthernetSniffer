// File name:   tb_mac_comparator.sv
// Updated:     30 November 2015
// Authors:     Brian Rieder 
//              Catie Cowden 
//              Shaughan Gladden
// Description: Test Bench for the String comparator.

`timescale 1ns/10ps

module tb_string_comparator();

reg clk;
reg n_rst;
reg [0:16][7:0] string_in;
reg [4:0] strlen;
reg [31:0] data_in;
reg [31:0] data_out;
reg match;
reg clear;

reg [31:0] expected_data_out;
reg expected_match;

reg [31:0] sample_data;
reg [31:0] sample_data_2;
reg [31:0] sample_data_shift1;
reg [31:0] sample_data_shift1_2;
reg [31:0] sample_data_shift2;
reg [31:0] sample_data_shift2_2;
reg [31:0] sample_data_shift3;
reg [31:0] sample_data_shift3_2;
reg [31:0] sample_data_shift3_3;

string_comparator COMP(.clk, .n_rst, .clear, .string_in, .strlen, .data_in, .match, .data_out);

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
	output stringin = string_in;
	output stringlen = strlen;
	output c = clear;
	input datao = data_out;
	input m = match;
endclocking

initial
begin
	n_rst = 1'b1;
	sample_data = "test";
        sample_data_2 = " tes";
	data_in = 32'h0000;
	string_in = 32'h0000;
	clear = '0;

	//Reset Test Case
	cb.n_rst <= 1'b1;
	@cb; n_rst = 1'b0; @cb;
	expected_data_out = '0;
	expected_match = '0;
	assert(expected_data_out == cb.datao)
	else $error("1: Reset Test Case: Incorrect Data_Out");
	assert(expected_match == cb.m)
	else $error("1: Reset Test Case: Incorrect Match Flag");
	cb.n_rst <= 1'b1;
	@cb; @cb;
	
	@cb; clear = 1'b1; @cb; clear = 1'b0;

	//*******************Test Case 2.1 No Shift*********************//
	string_in = "www.google.com"; 	
	data_in = sample_data; 
	expected_data_out = 32'h0000;
	expected_match = '0;
	@cb;
	assert(expected_data_out == cb.datao)
	else $error("2.1: Successful Match: Incorrect Data_Out");
	assert(expected_match == cb.m)
	else $error("2.1: Successful Match: Incorrect Match Flag");

	//Test Case 2.2
	data_in = sample_data_2; 
	expected_data_out = 32'h0000;
	expected_match = 1'b0;
	@cb;
	assert(expected_data_out == cb.datao)
	else $error("2.2: Successful Match: Incorrect Data_Out");
	assert(expected_match == cb.m)
	else $error("2.2: Successful Match: Incorrect Match Flag");

	//Test Case 2.3
	data_in = 32'h0000; 
	expected_data_out = 32'h0000; //(3)
	expected_match = 1'b0;
	@cb;
	assert(expected_data_out == cb.datao)
	else $error("2.3: Successful Match: Incorrect Data_Out");
	assert(expected_match == cb.m)
	else $error("2.3: Successful Match: Incorrect Match Flag");

	//Check Data_Out
	@cb;@cb;
	expected_data_out = sample_data;
	assert(expected_data_out == cb.datao)
	else $error("2.4: Successful Match: Incorrect Data_Out");
	expected_match = 1'b1;
	assert(expected_match == cb.m)
	else $error("2.3: Successful Match: Incorrect Match Flag");
	@cb;
	expected_data_out = sample_data_2;
	assert(expected_data_out == cb.datao)
	else $error("2.5: Successful Match: Incorrect Data_Out");
	@cb;
	expected_data_out = 32'h0000;
	assert(expected_data_out == cb.datao)
	else $error("2.6: Successful Match: Incorrect Data_Out");
	clear = 1'b1; @cb; clear = 1'b0;

	$stop;

end
endmodule
