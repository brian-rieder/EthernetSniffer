// File name:   tb_controller.sv
// Updated:     13 December 2015
// Authors:     Brian Rieder 
//              Catie Cowden 
//              Shaughan Gladden
// Description: This test bench is used to test the functionality of the controller block. The controller block manages signals entering and leaving the design. It is the brain behind when data is compared, when it is stored, and when the design is idle.

`timescale 1ns/10ps

module tb_controller();

reg clk;
reg n_rst;
reg [31:0] port_hits, ip_hits, mac_hits, url_hits;
reg eop, valid, sop, ready, update_done, inc_addr;
reg [1:0] empty;
reg [5:0] error;
reg port_match, ip_match, mac_match, url_match, clear;
integer test_case_num;

controller CTRLR(.clk, .n_rst, .port_match, .ip_match, .url_match, .mac_match, .update_done, .sop, .eop, .error, .valid, .empty, .ready, .inc_addr, .clear, .port_hits, .ip_hits, .mac_hits, .url_hits);

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
	//*******************Initializations***************************************//
	n_rst = 1'b0;	
	mac_match = 1'b0;
	ip_match = 1'b0;
	url_match = 1'b0;
	port_match = 1'b0;
	eop = 1'b0;
	sop = 1'b0;
	valid = 1'b0;
	empty = '0;
	error = 6'b0;
	update_done = 1'b0;
	test_case_num = 0;
	
	//*********************make_assertions task****************************//
	//Inputs: expected_port_hits, expected_mac_hits, expected_ip_hits, expected_url_hits
	//expected_ready, expected_clear, expected_inc_addr, test_case_num


	//*******************Test Case 0: Reset Test Case *********************//
	// All values should be zero.
	//cb.n_rst <= 1'b1;
	@cb; cb.n_rst <= 1'b0; @cb; cb.n_rst <= 1'b1;
	make_assertions('0, '0, '0, '0, '0, 1'b0, 1'b0, test_case_num);

	//*******************Test Case 1: Load Comp Reg state  ******************//
	// All values should still be zero.
	@cb; test_case_num = test_case_num + 1;
	make_assertions('0, '0, '0, '0, '0, 1'b0, 1'b0, test_case_num);
	update_done = 1'b1;

	//*******************Test Case 2: Idle State  ******************//
	// Toggle update_done to move into the Idle State. Ready and clear will go high immediately 
	// after this transition.
	@cb; 
	test_case_num = test_case_num + 1;
	make_assertions('0, '0, '0, '0, '0, '0, 1'b0, test_case_num);
	update_done = 1'b0;

	//*******************Test Case 3: Remain in Idle State  ******************//
	// Because sop & valid aren't asserted, we should remain in the Idle State.
	@cb;
	test_case_num = test_case_num + 1;
	make_assertions('0, '0, '0, '0, 1'b1, 1'b1, 1'b0, test_case_num);
	sop = 1'b1; valid = 1'b1;

	//*******************Test Case 4: Compare State  ******************//
	// Assert sop and valid. Move to compare state. Clear should go low, ready remains high.
	@cb;
	test_case_num = test_case_num + 1;
	make_assertions('0, '0, '0, '0, 1'b1, 1'b1, 1'b0, test_case_num);
	sop = 1'b0; mac_match = 1'b1; ip_match = 1'b1; 

	//*******************Test Case 5: Remain in Compare State  ******************//
	// Clear remains low, ready remains high.
	// Assert mac_match and ip_match for testing purposes.
	@cb; 
	test_case_num = test_case_num + 1;
	make_assertions('0, '0, '0, '0, 1'b1, 0, 1'b0, test_case_num);
	eop = 1'b1; 
	//*******************Test Case 6: Wait States  ******************//
	// Four wait states to allow data to shift all the way across.
	// All signals are low, including ready signal.
	@cb; eop = 1'b0; test_case_num = test_case_num + 1; 
	@cb; @cb; @cb;
	make_assertions('0, '0, '0, '0, '0, '0, 1'b0, test_case_num);

	//*******************Test Case 7: Match_Found State  ******************//
	// Mac and IP hits should increase by 1.
	// Clear and ready will remain low until the next cycle.
	@cb;
	test_case_num = test_case_num + 1;
	make_assertions('0, 0, 0, '0, 1'b0, 1'b0, 1'b0, test_case_num);

	//*******************Test Case 8: Load Memory  ******************//
	// Inc_addr signal should go high. Clear should say high from the match_found state and
	// ready should stay low.
	@cb;
	test_case_num = test_case_num + 1;
	make_assertions('0, 1, 1, '0, 1'b0, 1'b1, 1'b0, test_case_num);
	mac_match = 1'b0; ip_match = 1'b0;

	//*******************Test Case 9: Idle State  ******************//
	@cb; 
	test_case_num = test_case_num + 1;
	make_assertions('0, 1, 1, '0, 1'b0, 1'b0, 1'b1, test_case_num);
	update_done = 1'b0; sop = 1'b1; valid = 1'b1;

	//*******************Test Case 10: Compare State  ******************//
	@cb;
	test_case_num = test_case_num + 1;
	make_assertions('0, 1, 1, '0, 1'b1, 1'b1, 1'b0, test_case_num);
	error = '1;

	//*******************Test Case 11: Error State ******************//
	// Assert sop and valid. Move to compare state. Clear should go low, ready remains high.
	@cb;
	test_case_num = test_case_num + 1;
	make_assertions('0, 1, 1, '0, 1'b1, 1'b0, 1'b0, test_case_num);
	eop = 1'b1; error = '0;

	//*******************Test Case 12: Idle State ******************//
	// Assert sop and valid. Move to compare state. Clear should go low, ready remains high.
	@cb;
	test_case_num = test_case_num + 1;
	make_assertions('0, 1, 1, '0, 1'b1, 1'b0, 1'b0, test_case_num);
	sop = 1'b0; mac_match = 1'b1; ip_match = 1'b1; valid = 1'b0;
	@cb;
	$stop;

end

task make_assertions;
	input [31:0] expected_port_hits;
	input [31:0] expected_mac_hits;
	input [31:0] expected_ip_hits;
	input [31:0] expected_url_hits;
	input [5:0] expected_ready;
	input expected_clear;
	input expected_inc_addr;
	input integer test_case_num;
	begin
	
	assert(expected_port_hits == cb.ph)
	else $error(test_case_num, ": Incorrect Port hits");
	assert(expected_ip_hits == cb.ih)
	else $error(test_case_num, ": Incorrect IP hits");
	assert(expected_mac_hits == cb.mh)
	else $error(test_case_num, ": Incorrect MAC hits");
	assert(expected_url_hits == cb.uh)
	else $error(test_case_num, ": Incorrect Port hits");
	assert(expected_clear == cb.clr)
	else $error(test_case_num, ": Incorrect clear flag");
	assert(expected_ready == cb.rdy)
	else $error(test_case_num, ": Incorrect ready flag");
	assert(expected_inc_addr == cb.ia)
	else $error(test_case_num, ": Incorrect inc_addr flag");

	end	
endtask
endmodule
