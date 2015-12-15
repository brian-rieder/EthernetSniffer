// File name:   tb_mac_comparator.sv
// Updated:     30 November 2015
// Authors:     Brian Rieder 
//              Catie Cowden 
//              Shaughan Gladden
// Description: Test Bench for the Mac comparator. Iteratively provides inputs and
// checks for appropriate matching of Mac address in that input.

`timescale 1ns/10ps

module tb_mac_comparator();

reg clk;
reg n_rst;
reg [47:0] flagged_mac;
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

mac_comparator COMP(.clk, .n_rst, .clear, .flagged_mac, .data_in, .match, .data_out);

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
	output flaggedmac   = flagged_mac;
	output c            = clear;
	input datao         = data_out;
	input m             = match;
endclocking

initial
begin
	n_rst = 1'b0;
	sample_data          = 32'hE5F60000; //E5:F6:00:00
        sample_data_2        = 32'h01B2C3D4; //01:B2:C3:D4
	sample_data_shift1   = 32'hD4E5F600;
	sample_data_shift1_2 = 32'h0001B2C3;
	sample_data_shift2   = 32'hC3D4E5F6;
	sample_data_shift2_2 = 32'h000001B2;
	sample_data_shift3   = 32'hF6000000;
	sample_data_shift3_2 = 32'hB2C3D4E5;
	sample_data_shift3_3 = 32'h00000001;
	data_in              = 32'h0000;
	flagged_mac          = 48'h01B2C3D4E5F6;
	clear                = '0;
	expected_data_out = '0;
	expected_match = '0;

	//*******************Test Case 1: Reset*********************// 	
	cb.n_rst <= 1'b0;
	@cb; n_rst = 1'b0; 
	@cb; expected_data_out = '0;
	expected_match = '0;
	assert(expected_data_out == cb.datao)
	else $error("1: Reset Test Case: Incorrect Data_Out");
	assert(expected_match == cb.m)
	else $error("1: Reset Test Case: Incorrect Match Flag");
	cb.n_rst <= 1'b1;
	@cb; @cb; @cb;
	clear = 1'b1; 
	@cb; clear = 1'b0;

	//*******************Test Case 2 No Shift*********************// 	
	data_in = sample_data_2; 
	@cb;
	assert(expected_data_out == cb.datao)
	else $error("2.1: No Shift: Incorrect Data_Out");
	assert(expected_match == cb.m)
	else $error("2.1: No Shift: Incorrect Match Flag");

	//Test Case 2.2
	data_in = sample_data; 
	expected_data_out = '0;
	expected_match = 1'b0;
	@cb;
	assert(expected_data_out == cb.datao)
	else $error("2.2: No Shift: Incorrect Data_Out");
	assert(expected_match == cb.m)
	else $error("2.2: No Shift: Incorrect Match Flag");

	//Test Case 2.3
	data_in = '0; 
	expected_data_out = '0;
	expected_match = 1'b0;
	@cb;
	assert(expected_data_out == cb.datao)
	else $error("2.3: No Shift: Incorrect Data_Out");
	assert(expected_match == cb.m)
	else $error("2.3: No Shift: Incorrect Match Flag");

	//Check Data_Out
	@cb;@cb; expected_data_out = sample_data_2;
	assert(expected_data_out == cb.datao)
	else $error("2.4: No Shift: Incorrect Data_Out");
	expected_match = 1'b1;
	assert(expected_match == cb.m)
	else $error("2.3: No Shift: Incorrect Match Flag");
	@cb; expected_data_out = sample_data;
	assert(expected_data_out == cb.datao)
	else $error("2.5: No Shift: Incorrect Data_Out");
	@cb; expected_data_out = 32'h0000;
	assert(expected_data_out == cb.datao)
	else $error("2.6: No Shift: Incorrect Data_Out");
	clear = 1'b1; 
	@cb; clear = 1'b0;

	//*******************Test Case 3: One Shift*********************//
	data_in = sample_data_shift1_2;
	expected_data_out = 32'h0000;
	expected_match = '0;
	@cb; 
	assert(expected_data_out == cb.datao)
	else $error("3.1: One Shift: Incorrect Data_Out");
	assert(expected_match == cb.m)
	else $error("3.1: One Shift: Incorrect Match Flag");

	//Test Case 3.2
	data_in = sample_data_shift1;
	expected_data_out = 32'h0000;
	expected_match = 1'b0;
	@cb; 
	assert(expected_data_out == cb.datao)
	else $error("3.2: One Shift: Incorrect Data_Out");
	assert(expected_match == cb.m)
	else $error("3.2: One Shift: Incorrect Match Flag");

	//Test Case 3.3
	data_in = '0;
	expected_data_out = '0;
	expected_match = 1'b0;
	@cb;
	assert(expected_data_out == cb.datao)
	else $error("3.3: One Shift Incorrect Data_Out");
	assert(expected_match == cb.m)
	else $error("3.3: One Shift: Incorrect Match Flag");
	
	@cb;@cb; expected_data_out = sample_data_shift1_2;
	assert(expected_data_out == cb.datao)
	else $error("3.4: One Shift: Incorrect Data_Out");
	expected_match = 1'b1;
	assert(expected_match == cb.m)
	else $error("2.3: One Shift: Incorrect Match Flag");
	@cb; expected_data_out = sample_data_shift1;
	assert(expected_data_out == cb.datao)
	else $error("3.5: One Shift: Incorrect Data_Out");
	@cb; expected_data_out = '0;
	assert(expected_data_out == cb.datao)
	else $error("3.6: One Shift: Incorrect Data_Out");

	clear = 1'b1;
	@cb; clear = 1'b0;

	//*******************Test Case 4: Two Shifts*********************//
	data_in = sample_data_shift2_2;
	expected_data_out = '0;
	expected_match = '0;
	@cb;
	assert(expected_data_out == cb.datao)
	else $error("4.1: Two Shifts: Incorrect Data_Out");
	assert(expected_match == cb.m)
	else $error("4.1: Two Shifts: Incorrect Match Flag");

	//Test Case 4.2
	data_in = sample_data_shift2;
	expected_data_out = '0;
	expected_match = 1'b0;
	@cb;
	assert(expected_data_out == cb.datao)
	else $error("4.2: Two Shifts: Incorrect Data_Out");
	assert(expected_match == cb.m)
	else $error("4.2: Two Shifts: Incorrect Match Flag");
	
	//Test Case 4.3
	data_in = '0;
	expected_data_out = '0;
	expected_match = 1'b0;
	@cb;
	assert(expected_data_out == cb.datao)
	else $error("4.3: Two Shifts: Incorrect Data_Out");
	assert(expected_match == cb.m)
	else $error("4.3: Two Shifts: Incorrect Match Flag");

	@cb;@cb;
	expected_data_out = sample_data_shift2_2;
	assert(expected_data_out == cb.datao)
	else $error("4.4: Two Shifts: Incorrect Data_Out");
	expected_match = 1'b1;
	assert(expected_match == cb.m)
	else $error("2.3: Two Shifts: Incorrect Match Flag");
	@cb; expected_data_out = sample_data_shift2;
	assert(expected_data_out == cb.datao)
	else $error("4.5: Two Shifts: Incorrect Data_Out");
	@cb; expected_data_out = '0;
	assert(expected_data_out == cb.datao)
	else $error("4.6: Two Shifts: Incorrect Data_Out");
	clear = 1'b1;
	@cb; clear = 1'b0;

	//*******************Test Case 5.1: Three Shifts*********************//
	data_in = sample_data_shift3_3;
	expected_data_out = '0;
	expected_match = '0;
	@cb;
	assert(expected_data_out == cb.datao)
	else $error("5.1: Three Shifts: Incorrect Data_Out");
	assert(expected_match == cb.m)
	else $error("5.1: Three Shifts: Incorrect Match Flag");

	//Test Case 5.2
	data_in = sample_data_shift3_2;
	expected_data_out = '0;
	expected_match = 1'b0;
	@cb;
	assert(expected_data_out == cb.datao)
	else $error("5.2: Three Shifts: Incorrect Data_Out");
	assert(expected_match == cb.m)
	else $error("5.2: Three Shifts: Incorrect Match Flag");
	
	//Test Case 5.3
	data_in = sample_data_shift3;
	expected_data_out ='0;
	expected_match = 1'b0;
	@cb; 
	assert(expected_data_out == cb.datao)
	else $error("5.3: Three Shifts: Incorrect Data_Out");
	assert(expected_match == cb.m)
	else $error("5.3: Three Shifts: Incorrect Match Flag");
	
	//Test Case 5.4
	data_in = '0;
	expected_data_out = '0;
	expected_match = 1'b0;
	@cb;
	assert(expected_data_out == cb.datao)
	else $error("5.4: Three Shifts: Incorrect Data_Out");
	assert(expected_match == cb.m)
	else $error("5.4: Three Shifts: Incorrect Match Flag");
	
	@cb; expected_data_out = sample_data_shift3_3;
	assert(expected_data_out == cb.datao)
	else $error("5.5: Three Shifts: Incorrect Data_Out");
	expected_match = 1'b1;
	assert(expected_match == cb.m)
	else $error("5.5: Three Shifts: Incorrect Match Flag");
	@cb; expected_data_out = sample_data_shift3_2;
	assert(expected_data_out == cb.datao)
	else $error("5.6: Three Shifts: Incorrect Data_Out");
	@cb; expected_data_out = sample_data_shift3;
	assert(expected_data_out == cb.datao)
	else $error("5.7: Three Shifts: Incorrect Data_Out");
	@cb; expected_data_out = '0;
	assert(expected_data_out == cb.datao)
	else $error("5.8: Three Shifts: Incorrect Data_Out");
	clear = 1'b1;
	@cb; clear = 1'b0;


//*******************Test Case 6.1: All Ones*********************//
	flagged_mac = '1;
	data_in = '1;
	expected_match = 1'b0;
	expected_data_out = '1;
	@cb;

	//Test Case 6.2
	@cb; @cb; @cb;
	
	data_in = '0;
	@cb; expected_data_out = '1;
	assert(expected_data_out == cb.datao)
	else $error("6.1: All Ones: Incorrect Data_Out");
	expected_match = 1'b1;
	assert(expected_match == cb.m)
	else $error("6.1: All Ones: Incorrect Match Flag");
	@cb;
	assert(expected_data_out == cb.datao)
	else $error("6.2: All Ones: Incorrect Data_Out");
	@cb;
	assert(expected_data_out == cb.datao)
	else $error("6.3: All Ones: Incorrect Data_Out");
	@cb;
	assert(expected_data_out == cb.datao)
	else $error("6.4: All Ones: Incorrect Data_Out");
	clear = 1'b1;
	@cb; clear = 1'b0;

//*******************Test Case 7.1: All Zeros*********************//
	flagged_mac = '0;
	data_in = '1;
	expected_match = 1'b0;
	expected_data_out = '1;

	//Test Case 6.2
	@cb; @cb; @cb; @cb;
	data_in = '0;
	@cb; expected_data_out = '1;
	assert(expected_data_out == cb.datao)
	else $error("7.1: All Zeros: Incorrect Data_Out");
	expected_match = 1'b1;
	assert(expected_match == cb.m)
	else $error("7.2: All Zeros: Incorrect Match Flag");
	@cb;
	assert(expected_data_out == cb.datao)
	else $error("7.3: All Zeros: Incorrect Data_Out");
	@cb;
	assert(expected_data_out == cb.datao)
	else $error("7.4: All Zeros: Incorrect Data_Out");
	@cb;
	assert(expected_data_out == cb.datao)
	else $error("7.5: All Zeros: Incorrect Data_Out");
	clear = 1'b1;
	@cb; clear = 1'b0;
	$stop;

end
endmodule
