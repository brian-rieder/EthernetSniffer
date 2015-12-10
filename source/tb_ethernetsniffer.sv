// File name:   tb_mac_comparator.sv
// Updated:     30 November 2015
// Authors:     Brian Rieder 
//              Catie Cowden 
//              Shaughan Gladden
// Description: Test Bench for the String comparator.

`timescale 1ns/10ps

module tb_ethernetsniffer();

reg clk;
reg n_rst;
reg [31:0] data_in;
reg eop;
reg [1:0] empty;
reg [5:0] error;
reg valid;
reg ready;
reg sop;
reg [15:0] flagged_port;
reg [31:0] flagged_ip;
reg [47:0] flagged_mac;
reg [0:16][7:0] flagged_string;
reg [31:0] addr_out;
reg write_enable;
reg [31:0] data_out;

reg [31:0] expected_data_out;
reg [31:0] expected_addr_out;
reg expected_wr_en;

reg [6247:0] live_data; //6224
reg [31:0] sample_data;
reg [31:0] sample_data_2;
reg [31:0] sample_data_3;
reg [31:0] sample_data_4;
reg [31:0] sample_data_5;
reg [63:0] port_hits, ip_hits, mac_hits, url_hits;
reg update_done;
int unsigned strlen;
int unsigned i, j;

ethernetsniffer sniff(.clk, .n_rst, .data_in, .eop, .empty, .error, .valid, .update_done, .ready, .sop, .flagged_port, .flagged_ip, .flagged_mac,.flagged_string, .data_out, .write_enable, .addr_out, .port_hits, .ip_hits, .mac_hits, .url_hits);

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
	output data_i = data_in;
	output cbeop = eop;
	output emp = empty;
	output err = error;
	output val = valid;
	output ud = update_done;
	output rdy = ready;
	output cbsop = sop;
	output flagport = flagged_port;
	output flagmac = flagged_mac;
	output flagip = flagged_ip;
	output flagstr = flagged_string;
	input aout = addr_out;
	input wren = write_enable;
	input datao = data_out;
	input phits = port_hits;
	input mhits = mac_hits;
	input ihits = ip_hits;
	input uhits = url_hits;
endclocking

initial
begin
	//Initializations
	n_rst = 1'b1;
	strlen = 14;
	sample_data = 32'h0000;
        sample_data_2 = 32'h0000;
	sample_data_3 = 32'h0000;
	sample_data_4 = 32'h0000;
	sample_data_5 = 32'h0000;
	data_in = 32'h0000;
	flagged_string = 32'h0000;
	flagged_ip = 32'h0000;
	flagged_port = 16'h00;
	flagged_mac = 48'h000000;
	eop = 1'b0;
	empty = 2'b0;
	error = 6'b0;
	valid = 1'b0;
	update_done = 1'b0;
	ready = 1'b0;
	sop = 1'b0;
	flagged_string = "purdue.edu"; 
	flagged_ip = 32'h80D207C8; //128.210.7.200
	flagged_port = 16'h0050; //Port 80
	flagged_mac = 48'h641225eb1080; 	
	strlen = 10;

	//Reset Test Case
	cb.n_rst <= 1'b1;
	@cb; n_rst = 1'b0; @cb;
	expected_data_out = 32'h000;
	expected_addr_out = 1'b0;
	expected_wr_en = 1'b0;
	assert(expected_data_out == cb.datao)
	else $error("1: Reset Test Case: Incorrect Data_Out");
	assert(expected_addr_out == cb.aout)
	else $error("1: Reset Test Case: Incorrect addr_out");
	assert(expected_wr_en == cb.wren)
	else $error("1: Reset Test Case: Incorrect write enable");
	@cb; @cb;

	//*******************Test Case 1:*********************//
	live_data = 
6248'h641225eb1080809b203d14740800450002fb9e6b4000400600410aba05fd80d207c8cc89005066fd81a57610e49e80187210a46800000101080a01091fd77893c23f474554202f20485454502f312e310d0a486f73743a207777772e7075726475652e6564750d0a557365722d4167656e743a204d6f7a696c6c612f352e3020285831313b205562756e74753b204c696e7578207838365f36343b2072763a34312e3029204765636b6f2f32303130303130312046697265666f782f34312e300d0a4163636570743a20746578742f68746d6c2c6170706c69636174696f6e2f7868746d6c2b786d6c2c6170706c69636174696f6e2f786d6c3b713d302e392c2a2f2a3b713d302e380d0a4163636570742d4c616e67756167653a20656e2d55532c656e3b713d302e350d0a4163636570742d456e636f64696e673a20677a69702c206465666c6174650d0a436f6f6b69653a205f5f75746d613d3134313232383333392e3634383636353639382e313433313836393238322e313434353839303937392e313434353930393839302e333b205f5f75746d7a3d3134313232383333392e313433313836393238322e312e312e75746d6373723d676f6f676c657c75746d63636e3d286f7267616e6963297c75746d636d643d6f7267616e69637c75746d6374723d286e6f7425323070726f7669646564293b205f67613d4741312e322e3634383636353639382e313433313836393238323b206b6d5f75713d3b206b6d5f6c763d783b206b6d5f61693d323635353835363b206b6d5f6e693d323635353835363b2042494769705365727665727e5745427e706f6f6c5f6c707077656261706130312e697461702e7075726475652e6564755f7765623d333033363637383636362e302e303030300d0a436f6e6e656374696f6e3a206b6565702d616c6976650d0a49662d4d6f6469666965642d53696e63653a204d6f6e2c203233204e6f7620323031352032313a31353a343120474d540d0a49662d4e6f6e652d4d617463683a20223837303066322d343962392d35323533626261333662393430220d0a0d0a;

	if ($bits(live_data) < 160) begin
		$info("Sample data must be at least 160 bits long");		
		$stop;
	end
	
	@cb;
	update_done = 1'b1;
	@cb;
	update_done = 1'b0;
	//eop = 1'b1;
	ready = 1'b1;
	valid = 1'b1;
	sop = 1'b1;
	@cb; 
	sop = 1'b0; @cb;
	//eop = 1'b0;
	@cb; @cb; empty = 2'b01; @cb; empty = 2'b00; @cb;

	for (i = 6248-32; i > 128; i = i - 32) begin
		sample_data   = live_data [i     +: 32];
		sample_data_2 = live_data [i-32  +: 32];
		sample_data_3 = live_data [i-64  +: 32];
		sample_data_4 = live_data [i-96  +: 32];
		sample_data_5 = live_data [i-128 +: 32];
		compare(sample_data, sample_data_2, sample_data_3, sample_data_4, sample_data_5);
	end

	eop = 1'b1;
	empty = 2'b01;
	@cb; 
	eop = 1'b0;
	empty = 2'b01;
	@cb; @cb; @cb; @cb; @cb; @cb; @cb; @cb; @cb;

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
	@cb;

	data_in = sample_data_2; @cb;

	data_in = sample_data_3; @cb;

	data_in = sample_data_4; @cb;

	data_in = sample_data_5; @cb;

	// DATA OUT
	//@cb;
	expected_data_out = sample_data;
	assert(expected_data_out == cb.datao)
	else $error("2.2: Incorrect Data_Out");	

	@cb;
	expected_data_out = sample_data_2;
	assert(expected_data_out == cb.datao)
	else $error("2.3:Incorrect Data_Out");
	data_in = 32'h0000; @cb;


	//@cb;
	expected_data_out = sample_data_3;
	assert(expected_data_out == cb.datao)
	else $error("2.4:Incorrect Data_Out");

	@cb;
	expected_data_out = sample_data_4;
	assert(expected_data_out == cb.datao)
	else $error("2.5: Incorrect Data_Out");
	@cb;
	expected_data_out = sample_data_5;
	assert(expected_data_out == cb.datao)
	else $error("2.6: Incorrect Data_Out");
	
	@cb; @cb; @cb; @cb;
	//instead of clear, set eop
	//clear = 1'b1; @cb; clear = 1'b0;
	@cb;
	end	
endtask

endmodule
