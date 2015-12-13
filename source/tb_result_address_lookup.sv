// File name:   tb_result_address_fsm.sv
// Updated:     19 November 2015
// Authors:     Brian Rieder 
//              Catie Cowden 
//              Shaughan Gladden
// Description: Test Bench for the Result Address FSM.

`timescale 1ns/10ps

module tb_result_address_lookup();

reg inc_addr;
reg [31:0] addr_out;
reg write_enable;

reg clk;
reg n_rst;

reg [31:0] expected_addr_out;
reg expected_write_enable;

result_address_lookup RAL(.clk, .n_rst, .inc_addr, .addr_out, .write_enable);

//CHECK THIS?
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
	output ia = inc_addr;
	input ao = addr_out;
	input we = write_enable;
endclocking

initial
begin

	inc_addr = 0;
	cb.n_rst <= 1'b1;

	expected_addr_out = 32'h0000;
	expected_write_enable = 0;

	@cb; //RESET
	cb.n_rst <= 1'b0;

	@cb; @cb;
	assert(expected_write_enable == cb.we)
	else $error("0: ERROR: Write enable is incorrect.");
	assert(expected_addr_out == cb.ao)
	else $error("0: ERROR: Addr Out is incorrect.");
	@cb; cb.n_rst <= 1'b1;

	//TEST CASE SET 1
	expected_addr_out = 32'h0000;
	expected_write_enable = 0;
	@cb; @cb;
	assert(expected_write_enable == cb.we)
	else $error("1:0 ERROR: Write enable is incorrect.");
	assert(expected_addr_out == cb.ao)
	else $error("1:0 ERROR: Addr Out is incorrect.");

	//IDLE1
	@cb;
	expected_addr_out = 32'h0000;
	expected_write_enable = 0;
	@cb; @cb;
	assert(expected_write_enable == cb.we)
	else $error("1:1 ERROR: Write enable is incorrect.");
	assert(expected_addr_out == cb.ao)
	else $error("1:1 ERROR: Addr Out is incorrect.");

	//ADDR2
	@cb; inc_addr = 1'b1;
	expected_addr_out = 32'h060E;
	expected_write_enable = 1;
	@cb; inc_addr = 1'b0; @cb;
	assert(expected_write_enable == cb.we)
	else $error("1:2 ERROR: Write enable is incorrect.");
	assert(expected_addr_out == cb.ao)
	else $error("1:2 ERROR: Addr Out is incorrect.");
	
	//IDLE2
	@cb;
	expected_addr_out = 32'h060E;
	expected_write_enable = 0;
	@cb; @cb;
	assert(expected_write_enable == cb.we)
	else $error("1:3 ERROR: Write enable is incorrect.");
	assert(expected_addr_out == cb.ao)
	else $error("1:3 ERROR: Addr Out is incorrect.");

	//ADDR3
	@cb; inc_addr = 1'b1;
	expected_addr_out = 32'h0C1C;
	expected_write_enable = 1;
	@cb; inc_addr = 1'b0; @cb;
	assert(expected_write_enable == cb.we)
	else $error("1:4 ERROR: Write enable is incorrect.");
	assert(expected_addr_out == cb.ao)
	else $error("1:4 ERROR: Addr Out is incorrect.");

	//IDLE3
	@cb;
	expected_addr_out = 32'h0C1C;
	expected_write_enable = 0;
	@cb; @cb;
	assert(expected_write_enable == cb.we)
	else $error("1:5 ERROR: Write enable is incorrect.");
	assert(expected_addr_out == cb.ao)
	else $error("1:5 ERROR: Addr Out is incorrect.");

	//ADDR4
	@cb; inc_addr = 1'b1;
	expected_addr_out = 32'h0122A;
	expected_write_enable = 1;
	@cb; inc_addr = 1'b0; @cb;
	assert(expected_write_enable == cb.we)
	else $error("1:6 ERROR: Write enable is incorrect.");
	assert(expected_addr_out == cb.ao)
	else $error("1:6 ERROR: Addr Out is incorrect.");

	//IDLE4
	@cb;
	expected_addr_out = 32'h0122A;
	expected_write_enable = 0;
	@cb; @cb;
	assert(expected_write_enable == cb.we)
	else $error("1:7 ERROR: Write enable is incorrect.");
	assert(expected_addr_out == cb.ao)
	else $error("1:7 ERROR: Addr Out is incorrect.");

	//ADDR5
	@cb; inc_addr = 1'b1;
	expected_addr_out = 32'h1838;
	expected_write_enable = 1;
	@cb; inc_addr = 1'b0; @cb;
	assert(expected_write_enable == cb.we)
	else $error("1:8 ERROR: Write enable is incorrect.");
	assert(expected_addr_out == cb.ao)
	else $error("1:8 ERROR: Addr Out is incorrect.");

	//IDLE5
	@cb;
	expected_addr_out = 32'h1838;
	expected_write_enable = 0;
	@cb; @cb;
	assert(expected_write_enable == cb.we)
	else $error("1:9 ERROR: Write enable is incorrect.");
	assert(expected_addr_out == cb.ao)
	else $error("1:9 ERROR: Addr Out is incorrect.");

	//TO BE ADDED: TEST CASE SET 2. Change inc_addr value to verify functionality.

	$stop;
end
endmodule
