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
reg [31:0] flagged_ip;
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

ip_comparator COMP(.clk, .n_rst, .clear, .flagged_ip, .data_in, .match, .data_out);

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
	output datai        = data_in;
	output flaggedip    = flagged_ip;
	output c            = clear;
	input datao         = data_out;
	input m             = match;
endclocking

initial
begin
	n_rst                = 1'b1;
  	sample_data          = 32'hC0A80101; //192.168.001.001
	sample_data_shift1   = 32'h01000000;
	sample_data_shift1_2 = 32'h00C0A801;
	sample_data_shift2   = 32'h01010000;
	sample_data_shift2_2 = 32'h0000C0A8;
	sample_data_shift3   = 32'hA8010100;
	sample_data_shift3_2 = 32'h000000C0;
	data_in              = '0;
	flagged_ip           = 32'h0000;
	clear                = '0;

	//*******************Test Case 1: Reset*********************//
	cb.n_rst <= 1'b1;
	@cb; n_rst = 1'b0; 
	@cb;
	expected_data_out = '0;
	expected_match = '0;
	assert(expected_data_out == cb.datao)
	else $error("1: Reset Test Case: Incorrect Data_Out");
	assert(expected_match == cb.m)
	else $error("1: Reset Test Case: Incorrect Match Flag");
	cb.n_rst <= 1'b1;
	@cb; @cb; @cb;

	clear = 1'b1; 
	@cb; clear = 1'b0;

	//*******************Test Case 2: No Shift*********************//
	flagged_ip = sample_data; 	
	data_in = sample_data; 
	@cb;

	data_in = '0; 
	@cb; expected_match = '0;
	assert(expected_match == cb.m)
	else $error("2.1: No shift: incorrect match flag");

	@cb; @cb; 
	expected_match = 1'b1;
	assert(expected_match == cb.m)
	else $error("2.2: No shift: Incorrect Match Flag");
	expected_data_out = sample_data;
	assert(expected_data_out == cb.datao)
	else $error("2.1: No shift: Incorrect Data_Out");

	@cb; expected_data_out = '0;
	assert(expected_data_out == cb.datao)
	else $error("2.2: No shift: Incorrect Data_Out");
	@cb; clear = 1'b1; @cb; clear = 1'b0;

	//*******************Test Case 3: One Shift*********************//
	data_in = sample_data_shift1_2;
	expected_match = '0;
	@cb;
	assert(expected_match == cb.m)
	else $error("3.1: One Shift: Incorrect Match Flag");

	data_in = sample_data_shift1;
	expected_match = 1'b0;
	@cb;
	assert(expected_match == cb.m)
	else $error("3.2: One Shift: Incorrect Match Flag");
	
	data_in = '0;
	@cb;
	expected_data_out = sample_data_shift1_2;
	expected_match = 1'b1;
	@cb;
	assert(expected_data_out == cb.datao)
	else $error("3.1: One Shift: Incorrect Data_Out");
	assert(expected_match == cb.m)
	else $error("3.3: One Shift: Incorrect Match Flag");

	@cb; 
	expected_data_out = sample_data_shift1;
	assert(expected_data_out == cb.datao)
	else $error("3.2: One Shift: Incorrect Data_Out");
	
	@cb; expected_data_out = '0;
	assert(expected_data_out == cb.datao)
	else $error("3.3: One Shift: Incorrect Data_Out");

	@cb; clear = 1'b1; 
	@cb; clear = 1'b0;

	//*******************Test Case 4: Two Shifts*********************//
	data_in = sample_data_shift2_2;
	expected_match = '0;
	@cb; 
	assert(expected_match == cb.m)
	else $error("4.1: Two Shifts: Incorrect Match Flag");

	//Test Case 4.2
	data_in = sample_data_shift2;
	expected_match = 1'b0;
	@cb;
	assert(expected_match == cb.m)
	else $error("4.2: Two Shifts: Incorrect Match Flag");
	
	//Test Case 4.3
	data_in = '0;
	expected_match = 1'b1;
	@cb;
	expected_data_out = sample_data_shift2_2;
	@cb;
	assert(expected_data_out == cb.datao)
	else $error("4.1: Two Shifts: Incorrect Data_Out");
	assert(expected_match == cb.m)
	else $error("4.3: Two Shifts: Incorrect Match Flag");
	
	@cb; expected_data_out = sample_data_shift2;
	assert(expected_data_out == cb.datao)
	else $error("4.2: Two Shifts: Incorrect Data_Out");

	@cb; expected_data_out = '0;
	assert(expected_data_out == cb.datao)
	else $error("4.3: Two Shifts: Incorrect Data_Out");

	@cb; clear = 1'b1;
	@cb; clear = 1'b0;

	//*******************Test Case 5.1: Three Shifts*********************//
	data_in = sample_data_shift3_2;
	expected_match = '0;
	@cb;
	assert(expected_match == cb.m)
	else $error("5.1: Three Shifts: Incorrect Match Flag");

	//Test Case 5.2
	data_in = sample_data_shift3;
	expected_match = 1'b0;
	@cb;
	assert(expected_match == cb.m)
	else $error("5.2: Three Shifts: Incorrect Match Flag");
	
	//Test Case 5.3
	data_in = '0;
	expected_match = 1'b1;
	@cb; expected_data_out = sample_data_shift3_2;
	@cb;
	assert(expected_data_out == cb.datao)
	else $error("5.1: Three Shifts: Incorrect Data_Out");
	assert(expected_match == cb.m)
	else $error("5.3: Three Shifts: Incorrect Match Flag");
	
	@cb; expected_data_out = sample_data_shift3;
	assert(expected_data_out == cb.datao)
	else $error("5.2: Three Shifts: Incorrect Data_Out");
	
	@cb; expected_data_out = '0;
	assert(expected_data_out == cb.datao)
	else $error("5.3: Three Shifts: Incorrect Data_Out");

	@cb; clear = 1'b1;
	@cb; clear = 1'b0;

//*******************Test Case 6: All Ones*********************//
	flagged_ip = '1;
	data_in = '1;
	expected_match = 1'b0;

	//Test Case 6.2
	@cb; expected_match = 1'b0;
	
	//Test Case 6.3
	@cb; data_in = '0;
	expected_match = 1'b1;
	@cb; expected_data_out = '1; @cb;
	assert(expected_data_out == cb.datao)
	else $error("6.1: All Ones: Incorrect Data_Out");
	assert(expected_match == cb.m)
	else $error("6.3: All Ones: Incorrect Match Flag");
	
	@cb;
	assert(expected_data_out == cb.datao)
	else $error("6.2: All Ones: Incorrect Data_Out");
	
	@cb; expected_data_out = '0;
	assert(expected_data_out == cb.datao)
	else $error("6.3: All Ones: Incorrect Data_Out");

	@cb; clear = 1'b1;
	@cb; clear = 1'b0;

//*******************Test Case 7.1: All Zeros*********************//
	flagged_ip = '0;
	data_in = '0;
	expected_match = 1'b0;

	//Test Case 7.2
	@cb; expected_match = 1'b0;
	
	//Test Case 7.3
	@cb; data_in = '0;
	expected_match = 1'b1;
	@cb; expected_data_out = '0; @cb;
	assert(expected_data_out == cb.datao)
	else $error("7.1: All Zeros: Incorrect Data_Out");
	assert(expected_match == cb.m)
	else $error("7.3: All Zeros: Incorrect Match Flag");
	
	@cb;
	assert(expected_data_out == cb.datao)
	else $error("7.2: All Zeros: Incorrect Data_Out");
	
	@cb; expected_data_out = '0;
	assert(expected_data_out == cb.datao)
	else $error("7.3: All Zeros: Incorrect Data_Out");

	@cb; clear = 1'b1;
	@cb; clear = 1'b0;

	$stop;

end
endmodule
