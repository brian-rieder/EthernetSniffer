// File name:   tb_mac_comparator.sv
// Updated:     30 November 2015
// Authors:     Brian Rieder 
//              Catie Cowden 
//              Shaughan Gladden
// Description: Test Bench for the String comparator. Iteratively applies inputs and
// checks outputs for appropriate recognition of flagged string.

`timescale 1ns/10ps

module tb_string_comparator();

reg clk;
reg n_rst;
reg [0:16][7:0] flagged_string;
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

string_comparator COMP(.clk, .n_rst, .clear, .flagged_string, .strlen, .data_in, .match, .data_out);

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
	output #800ps n_rst  = n_rst;
	output datai         = data_in;
	output flaggedstring = flagged_string;
	output stringlen     = strlen;
	output c             = clear;
	input datao          = data_out;
	input m              = match;
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
	data_in = '0;
	flagged_string = "www.google.com";
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

	//*******************Test Case 1: Regular URL, shifted *********************//
	
	compare(sample_data, sample_data_2, sample_data_3, sample_data_4, sample_data_5, 1'b1);
	
	sample_data = " www";
	sample_data_2 = ".goo";
	sample_data_3 = "gle.";
	sample_data_4 = "com ";
	sample_data_5 = "    ";
	compare(sample_data, sample_data_2, sample_data_3, sample_data_4, sample_data_5, 1'b1);

	sample_data = "  ww";
	sample_data_2 = "w.go";
	sample_data_3 = "ogle";
	sample_data_4 = ".com";
	sample_data_5 = "    ";
	compare(sample_data, sample_data_2, sample_data_3, sample_data_4, sample_data_5, 1'b1);

	sample_data = "   w";
	sample_data_2 = "ww.g";
	sample_data_3 = "oogl";
	sample_data_4 = "e.co";
	sample_data_5 = "m   ";
	compare(sample_data, sample_data_2, sample_data_3, sample_data_4, sample_data_5, 1'b1);

	//*******************Test Case 2: Short string, all positions *********************//
	flagged_string = "abc"; 
	strlen = 3;	

	sample_data = "abc ";
	sample_data_2 = "    ";
	sample_data_3 = "    ";
	sample_data_4 = "    ";
	sample_data_5 = "    ";
	compare(sample_data, sample_data_2, sample_data_3, sample_data_4, sample_data_5, 1'b1);

	sample_data = "    ";
	sample_data_2 = "abc ";
	sample_data_3 = "    ";
	sample_data_4 = "    ";
	sample_data_5 = "    ";
	compare(sample_data, sample_data_2, sample_data_3, sample_data_4, sample_data_5, 1'b1);

	sample_data = "    ";
	sample_data_2 = "    ";
	sample_data_3 = "abc ";
	sample_data_4 = "    ";
	sample_data_5 = "    ";
	compare(sample_data, sample_data_2, sample_data_3, sample_data_4, sample_data_5, 1'b1);

	sample_data = "    ";
	sample_data_2 = "    ";
	sample_data_3 = "    ";
	sample_data_4 = " abc";
	sample_data_5 = "    ";
	compare(sample_data, sample_data_2, sample_data_3, sample_data_4, sample_data_5, 1'b1);

	sample_data = "    ";
	sample_data_2 = "    ";
	sample_data_3 = "    ";
	sample_data_4 = "    ";
	sample_data_5 = " abc";
	compare(sample_data, sample_data_2, sample_data_3, sample_data_4, sample_data_5, 1'b1);

//*******************Test Case 3: Length of 17 *********************//
	flagged_string= "www.linkedin.com/"; 
	strlen = 17;	

	sample_data = "www.";
	sample_data_2 = "link";
	sample_data_3 = "edin";
	sample_data_4 = ".com";
	sample_data_5 = "/   ";
	compare(sample_data, sample_data_2, sample_data_3, sample_data_4, sample_data_5, 1'b1);

//*******************Test Case 4: All ones *********************//
	flagged_string = '1; 
	strlen = 17;	

	sample_data = '1;
	sample_data_2 = '1;
	sample_data_3 = '1;
	sample_data_4 = '1;
	sample_data_5 = '1;
	compare(sample_data, sample_data_2, sample_data_3, sample_data_4, sample_data_5, 1'b1);

//*******************Test Case 5: All zeroes *******************//
	flagged_string = '0; 
	strlen = 17;	

	sample_data = '0;
	sample_data_2 = '0;
	sample_data_3 = '0;
	sample_data_4 = '0;
	sample_data_5 = '0;
	compare(sample_data, sample_data_2, sample_data_3, sample_data_4, sample_data_5, 1'b1);

//*******************Test Case 6: Start "correct" but change to incorrect in the middle *******************//
	flagged_string = "www.google.com"; 
	strlen = 14;	

	sample_data = "www.";
	sample_data_2 = "goog";
	sample_data_3 = "book";
	sample_data_4 = ".com";
	sample_data_5 = "    ";
	compare(sample_data, sample_data_2, sample_data_3, sample_data_4, sample_data_5, 1'b0);

	$stop;

end

task compare;
	input [31:0] sample_data;
	input [31:0] sample_data_2;
	input [31:0] sample_data_3;
	input [31:0] sample_data_4;
	input [31:0] sample_data_5;
	input reg expected_matchFlag; // Variable to indicate whether or not to expect a match
	begin
	data_in = sample_data; 
	expected_data_out = '0;
	expected_match = '0;
	
	// DATA IN
	@cb; data_in = sample_data_2;
	@cb; data_in = sample_data_3;
	@cb; data_in = sample_data_4;
	@cb; data_in = sample_data_5;
	@cb; data_in = '0;
	@cb; @cb;

	// DATA OUT
	expected_data_out = sample_data;
	assert(expected_data_out == cb.datao)
	else $error("2.2: Successful Match: Incorrect Data_Out");
	@cb; expected_data_out = sample_data_2;
	assert(expected_data_out == cb.datao)
	else $error("2.3: Successful Match: Incorrect Data_Out");
	@cb; expected_data_out = sample_data_3;
	assert(expected_data_out == cb.datao)
	else $error("2.4: Successful Match: Incorrect Data_Out");
	@cb; expected_data_out = sample_data_4;
	assert(expected_data_out == cb.datao)
	else $error("2.5: Successful Match: Incorrect Data_Out");
	@cb; expected_data_out = sample_data_5;
	assert(expected_data_out == cb.datao)
	else $error("2.6: Successful Match: Incorrect Data_Out");
	expected_match = expected_matchFlag;
	assert(expected_match == cb.m)
	else $error("2.1: Successful Match: Incorrect Match Flag");
	
	@cb; expected_match = 1'b0;
	@cb; @cb; @cb; clear = 1'b1;
	@cb; clear = 1'b0;
	end	
endtask

endmodule
