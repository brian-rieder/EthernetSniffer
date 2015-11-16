// File name:   tb_result_address_fsm.sv
// Updated:     12 November 2015
// Authors:     Brian Rieder 
//              Catie Cowden 
//              Shaughan Gladden
// Description: Test Bench for the Result Address FSM.

`timescale 1ns/10ps

module tb_result_address_fsm();

wire tb_clk;
wire tb_n_rst;
reg tb_inc_addr;
reg tb_addr_out;
reg tb_write_enable;

reg tmp_clk;
reg tmp_n_rst;

reg expected_addr_out;
reg expected_write_enable;

result_address_fsm RAF(.clk(tb_clk), .n_rst(tb_n_rst), .inc_addr(tb_inc_addr), .addr_out(tb_addr_out), .write_enable(tb_write_enable));

assign tb_clk = tmp_clk;
assign tb_n_rst = tmp_n_rst;

//CHECK THIS?
localparam CLK_PERIOD = 2.5;

//Clock generation block
always
begin
	tmp_clk = 1'b0;
	#(CLK_PERIOD/2.0);
	tmp_clk = 1'b1;
	#(CLK_PERIOD/2.0);
end

clocking cb @(posedge tb_clk);
	default input #1step output #100ps;
	output #800ps n_rst = tmp_n_rst;
	output ia = tb_inc_addr;
	input ao = tb_addr_out;
	input we = tb_write_enable;
endclocking

initial
begin

	tb_inc_addr = 0;
	tmp_n_rst = 1'b1;

	expected_addr_out = 32'h1838;
	expected_write_enable = 0;

	@cb; //RESET
	tmp_n_rst = 1'b0;
	assert(expected_write_enable == cb.we)
	else $error("0: ERROR: Write enable is incorrect.");
	assert(expected_addr_out == cb.ao)
	else $error("0: ERROR: Addr Out is incorrect.");
	@cb; tmp_n_rst = 1'b1;

	//TEST CASE SET 1: LEAVE INC_ADDR HIGH THE ENTIRE TIME
	tb_inc_addr = 1'b1;
	expected_addr_out = 32'h1838;
	expected_write_enable = 0;

	@cb;
	assert(expected_write_enable == cb.we)
	else $error("1:0 ERROR: Write enable is incorrect.");
	assert(expected_addr_out == cb.ao)
	else $error("1:0 ERROR: Addr Out is incorrect.");

	//IDLE1
	expected_addr_out = 32'h0000;
	expected_write_enable = 1;

	@cb;
	assert(expected_write_enable == cb.we)
	else $error("1:1 ERROR: Write enable is incorrect.");
	assert(expected_addr_out == cb.ao)
	else $error("1:1 ERROR: Addr Out is incorrect.");

	//ADDR2
	expected_addr_out = 32'h0000;
	expected_write_enable = 0;

	@cb;
	assert(expected_write_enable == cb.we)
	else $error("1:2 ERROR: Write enable is incorrect.");
	assert(expected_addr_out == cb.ao)
	else $error("1:2 ERROR: Addr Out is incorrect.");
	
	//IDLE2
	expected_addr_out = 32'h060E;
	expected_write_enable = 1;

	@cb;
	assert(expected_write_enable == cb.we)
	else $error("1:3 ERROR: Write enable is incorrect.");
	assert(expected_addr_out == cb.ao)
	else $error("1:3 ERROR: Addr Out is incorrect.");

	//ADDR3
	expected_addr_out = 32'h060E;
	expected_write_enable = 0;

	@cb;
	assert(expected_write_enable == cb.we)
	else $error("1:4 ERROR: Write enable is incorrect.");
	assert(expected_addr_out == cb.ao)
	else $error("1:4 ERROR: Addr Out is incorrect.");

	//IDLE3
	expected_addr_out = 32'h0C1C;
	expected_write_enable = 1;

	@cb;
	assert(expected_write_enable == cb.we)
	else $error("1:5 ERROR: Write enable is incorrect.");
	assert(expected_addr_out == cb.ao)
	else $error("1:5 ERROR: Addr Out is incorrect.");

	//ADDR4
	expected_addr_out = 32'h0C1C;
	expected_write_enable = 0;

	@cb;
	assert(expected_write_enable == cb.we)
	else $error("1:6 ERROR: Write enable is incorrect.");
	assert(expected_addr_out == cb.ao)
	else $error("1:6 ERROR: Addr Out is incorrect.");

	//IDLE4
	expected_addr_out = 32'h0122A;
	expected_write_enable = 1;

	@cb;
	assert(expected_write_enable == cb.we)
	else $error("1:7 ERROR: Write enable is incorrect.");
	assert(expected_addr_out == cb.ao)
	else $error("1:7 ERROR: Addr Out is incorrect.");

	//ADDR5
	expected_addr_out = 32'h122A;
	expected_write_enable = 0;

	@cb;
	assert(expected_write_enable == cb.we)
	else $error("1:8 ERROR: Write enable is incorrect.");
	assert(expected_addr_out == cb.ao)
	else $error("1:8 ERROR: Addr Out is incorrect.");

	//IDLE5
	expected_addr_out = 32'h1838;
	expected_write_enable = 1;

	@cb;
	assert(expected_write_enable == cb.we)
	else $error("1:9 ERROR: Write enable is incorrect.");
	assert(expected_addr_out == cb.ao)
	else $error("1:9 ERROR: Addr Out is incorrect.");

	//TO BE ADDED: TEST CASE SET 2. Change inc_addr value to verify functionality.
end
endmodule
