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
reg [31:0] sample_data_3;
reg [31:0] sample_data_4;
reg [31:0] sample_data_5;
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
	strlen = 14;
	sample_data = "www.";
        sample_data_2 = "goog";
	sample_data_3 = "le.c";
	sample_data_4 = "om  ";
	sample_data_5 = "    ";
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
	
	compare(sample_data, sample_data_2, sample_data_3, sample_data_4, sample_data_5);
	
	sample_data = " www";
	sample_data_2 = ".goo";
	sample_data_3 = "gle.";
	sample_data_4 = "com ";
	sample_data_5 = "    ";
	compare(sample_data, sample_data_2, sample_data_3, sample_data_4, sample_data_5);

	sample_data = "  ww";
	sample_data_2 = "w.go";
	sample_data_3 = "ogle";
	sample_data_4 = ".com";
	sample_data_5 = "    ";
	compare(sample_data, sample_data_2, sample_data_3, sample_data_4, sample_data_5);

	sample_data = "   w";
	sample_data_2 = "ww.g";
	sample_data_3 = "oogl";
	sample_data_4 = "e.co";
	sample_data_5 = "m   ";
	compare(sample_data, sample_data_2, sample_data_3, sample_data_4, sample_data_5);

	$stop;

end

task compare;
	input [31:0] sample_data;
	input [31:0] sample_data_2;
	input [31:0] sample_data_3;
	input [31:0] sample_data_4;
	input [31:0] sample_data_5;
	begin
	data_in = sample_data; 
	expected_data_out = 32'h0000;
	expected_match = '0;
	@cb;

	data_in = sample_data_2; @cb;

	data_in = sample_data_3; @cb;

	data_in = sample_data_4; @cb;
	
	data_in = sample_data_5; @cb;

	data_in = 32'h0000; @cb;

	// DATA OUT
	expected_match = 1'b1;
	assert(expected_match == cb.m)
	else $error("2.4: Successful Match: Incorrect Match Flag");
	@cb;
	expected_data_out = sample_data;
	assert(expected_data_out == cb.datao)
	else $error("2.4: Successful Match: Incorrect Data_Out");
	expected_match = 1'b0;
	assert(expected_match == cb.m)
	else $error("2.4: Successful Match: Incorrect Match Flag");
	@cb;
	expected_data_out = sample_data_2;
	assert(expected_data_out == cb.datao)
	else $error("2.5: Successful Match: Incorrect Data_Out");
	@cb;
	expected_data_out = sample_data_3;
	assert(expected_data_out == cb.datao)
	else $error("2.6: Successful Match: Incorrect Data_Out");
	@cb;
	expected_data_out = sample_data_4;
	assert(expected_data_out == cb.datao)
	else $error("2.7: Successful Match: Incorrect Data_Out");
	@cb;
	expected_data_out = sample_data_5;
	assert(expected_data_out == cb.datao)
	else $error("2.8: Successful Match: Incorrect Data_Out");
	
	@cb; @cb; @cb; @cb;
	clear = 1'b1; @cb; clear = 1'b0;
	end	
endtask

endmodule
