// File name:   tb_ethernetsniffer.sv
// Updated:     30 November 2015
// Authors:     Brian Rieder 
//              Catie Cowden 
//              Shaughan Gladden
// Description: Test bench for the top level  module.

`timescale 1ns/10ps

module tb_ethernetsniffer();

reg clk = 0;
reg n_rst = 0;
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
reg [63:0] expected_mac_hits, expected_ip_hits, expected_port_hits, expected_url_hits;
reg expected_wr_en;

reg [6247:0] live_data;
reg [2855:0] live_data2;
reg [5351:0] live_data3;
reg [31:0] sample_data;
reg [31:0] sample_data_2;
reg [31:0] sample_data_3;
reg [31:0] sample_data_4;
reg [31:0] sample_data_5;
reg [63:0] port_hits, ip_hits, mac_hits, url_hits;
reg update_done;
reg [4:0] strlen;
int unsigned i, j;

ethernetsniffer sniff(.clk, .n_rst, .data_in, .eop, .empty, .error, .valid, .update_done, .ready, .sop, .flagged_port, .flagged_ip, .flagged_mac,.flagged_string, .data_out, .write_enable, .strlen, .addr_out, .port_hits, .ip_hits, .mac_hits, .url_hits);

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
	// Initializations
	sample_data = '0;
        sample_data_2 = '0;
	sample_data_3 = '0;
	sample_data_4 = '0;
	sample_data_5 = '0;
	data_in = '0;
	eop = 1'b0;
	empty = 2'b0;
	error = 6'b0;
	valid = 1'b0;
	update_done = 1'b0;
	ready = 1'b0;
	sop = 1'b0;
	expected_data_out = '0;
	expected_addr_out = '0;
	expected_wr_en = 1'b0;

	// "User programmed" test data
	strlen = 13;
	flagged_string = "www.wired.com";
	flagged_ip = 32'h80D207C8; //128.210.7.200
	flagged_port = 16'h0050; //Port 80
	flagged_mac = 48'h641225eb1080; 

	//*******************Test Case 0: Reset Test Case *********************//
	cb.n_rst <= 1'b1;
	@cb; cb.n_rst <= 1'b0; @cb; cb.n_rst <= 1'b1;
	assert(expected_data_out == cb.datao)
	else $error("1: Reset Test Case: Incorrect Data_Out");
	assert(expected_addr_out == cb.aout)
	else $error("1: Reset Test Case: Incorrect addr_out");
	assert(expected_wr_en == cb.wren)
	else $error("1: Reset Test Case: Incorrect write enable");
	@cb; @cb;

	//*******************Test Case 1: www.purdue.edu *********************//
	live_data = 
6248'h641225eb1080809b203d14740800450002fb9e6b4000400600410aba05fd80d207c8cc89005066fd81a57610e49e80187210a46800000101080a01091fd77893c23f474554202f20485454502f312e310d0a486f73743a207777772e7075726475652e6564750d0a557365722d4167656e743a204d6f7a696c6c612f352e3020285831313b205562756e74753b204c696e7578207838365f36343b2072763a34312e3029204765636b6f2f32303130303130312046697265666f782f34312e300d0a4163636570743a20746578742f68746d6c2c6170706c69636174696f6e2f7868746d6c2b786d6c2c6170706c69636174696f6e2f786d6c3b713d302e392c2a2f2a3b713d302e380d0a4163636570742d4c616e67756167653a20656e2d55532c656e3b713d302e350d0a4163636570742d456e636f64696e673a20677a69702c206465666c6174650d0a436f6f6b69653a205f5f75746d613d3134313232383333392e3634383636353639382e313433313836393238322e313434353839303937392e313434353930393839302e333b205f5f75746d7a3d3134313232383333392e313433313836393238322e312e312e75746d6373723d676f6f676c657c75746d63636e3d286f7267616e6963297c75746d636d643d6f7267616e69637c75746d6374723d286e6f7425323070726f7669646564293b205f67613d4741312e322e3634383636353639382e313433313836393238323b206b6d5f75713d3b206b6d5f6c763d783b206b6d5f61693d323635353835363b206b6d5f6e693d323635353835363b2042494769705365727665727e5745427e706f6f6c5f6c707077656261706130312e697461702e7075726475652e6564755f7765623d333033363637383636362e302e303030300d0a436f6e6e656374696f6e3a206b6565702d616c6976650d0a49662d4d6f6469666965642d53696e63653a204d6f6e2c203233204e6f7620323031352032313a31353a343120474d540d0a49662d4e6f6e652d4d617463683a20223837303066322d343962392d35323533626261333662393430220d0a0d0a;
	
	// When update_done is pulsed, a new packet may be read in as soon as an sop signal is received.
	@cb; update_done = 1'b1;
	@cb; update_done = 1'b0; ready = 1'b1; valid = 1'b1; sop = 1'b1; expected_addr_out = '0;
	assert(expected_addr_out == cb.aout)
	else $error("2: Incorrect addr out.");
	@cb; sop = 1'b0;
	@cb; @cb; 
	@cb; @cb; 
	empty = 2'b00; // There is data in the FIFO to be read.
	@cb;

	// Simulate input data operation. 4 bytes are read at a time beginning at the highest ordered data.
	for (i = 6248-32; i > 128; i = i - 32) begin
		sample_data   = live_data [i     +: 32];
		sample_data_2 = live_data [i-32  +: 32];
		sample_data_3 = live_data [i-64  +: 32];
		sample_data_4 = live_data [i-96  +: 32];
		sample_data_5 = live_data [i-128 +: 32];
		compare(sample_data, sample_data_2, sample_data_3, sample_data_4, sample_data_5);
	end

	// Eop is asserted at the end of a packet. The FIFO is now empty.
	eop = 1'b1; empty = 2'b01;
	@cb; eop = 1'b0;

	// Verify that, prior to checking the match flags, all hit totals are zero.
	expected_mac_hits = 0; expected_ip_hits = 0; expected_url_hits = 0; expected_port_hits = 0;
	assert(expected_mac_hits == cb.mhits)
	else $error("2: Incorrect mac match count.");
	assert(expected_ip_hits == cb.ihits)
	else $error("2: Incorrect ip match count.");
	assert(expected_url_hits == cb.uhits)
	else $error("2: Incorrect url match count.");
	assert(expected_port_hits == cb.phits)
	else $error("2: Incorrect port match count.");



	@cb; @cb; @cb; @cb; @cb; @cb; @cb; @cb; @cb;

	//*******************Test Case 2: www.wired.com *********************//
	live_data2 =
2856'h641225eb1080809b203d14740800450001572a0d40004006c35c0aba00a417eb28efd0cc00505e627fbc6ae78611801800e5014c00000101080a007255b95eae8bfc474554202f20485454502f312e310d0a486f73743a207777772e77697265642e636f6d0d0a557365722d4167656e743a204d6f7a696c6c612f352e3020285831313b205562756e74753b204c696e7578207838365f36343b2072763a34312e3029204765636b6f2f32303130303130312046697265666f782f34312e300d0a4163636570743a20746578742f68746d6c2c6170706c69636174696f6e2f7868746d6c2b786d6c2c6170706c69636174696f6e2f786d6c3b713d302e392c2a2f2a3b713d302e380d0a4163636570742d4c616e67756167653a20656e2d55532c656e3b713d302e350d0a4163636570742d456e636f64696e673a20677a69702c206465666c6174650d0a436f6e6e656374696f6e3a206b6565702d616c6976650d0a0d0a;

	@cb; update_done = 1'b1;
	@cb; update_done = 1'b0; ready = 1'b1; valid = 1'b1; sop = 1'b1; expected_addr_out = 32'h0000060E;
	assert(expected_addr_out == cb.aout)
	else $error("2: Incorrect addr out.");
	@cb; sop = 1'b0;
	@cb; @cb; 
	@cb; @cb; empty = 2'b00; @cb;

	for (i = 2856-32; i > 128; i = i - 32) begin
		sample_data   = live_data2 [i     +: 32];
		sample_data_2 = live_data2 [i-32  +: 32];
		sample_data_3 = live_data2 [i-64  +: 32];
		sample_data_4 = live_data2 [i-96  +: 32];
		sample_data_5 = live_data2 [i-128 +: 32];
		compare(sample_data, sample_data_2, sample_data_3, sample_data_4, sample_data_5);
	end

	eop = 1'b1; empty = 2'b01;
	@cb; eop = 1'b0;

	// Verify that, prior to checking the match flags, the ip, port, and mac were identified as hits.
	expected_mac_hits = 1; expected_ip_hits = 1; expected_url_hits = 0; expected_port_hits = 1;

	assert(expected_mac_hits == cb.mhits)
	else $error("3: Incorrect mac match count.");
	assert(expected_ip_hits == cb.ihits)
	else $error("3: Incorrect ip match count.");
	assert(expected_url_hits == cb.uhits)
	else $error("3: Incorrect url match count.");
	assert(expected_port_hits == cb.phits)
	else $error("3: Incorrect port match count.");


	@cb; @cb; @cb; @cb; @cb; @cb; @cb; @cb; @cb;

	//*******************Test Case 3: www.extremetech.com *********************//
live_data3 =
5352'h641225eb1080809b203d147408004500028e4e3040004006bd200aba0eac1700fcb3db71005034659269b1f7b37d801800e533cf00000101080a018edc497d660bdd474554202f20485454502f312e310d0a486f73743a207777772e65787472656d65746563682e636f6d0d0a557365722d4167656e743a204d6f7a696c6c612f352e3020285831313b205562756e74753b204c696e7578207838365f36343b2072763a34312e3029204765636b6f2f32303130303130312046697265666f782f34312e300d0a4163636570743a20746578742f68746d6c2c6170706c69636174696f6e2f7868746d6c2b786d6c2c6170706c69636174696f6e2f786d6c3b713d302e392c2a2f2a3b713d302e380d0a4163636570742d4c616e67756167653a20656e2d55532c656e3b713d302e350d0a4163636570742d456e636f64696e673a20677a69702c206465666c6174650d0a436f6f6b69653a205f63625f6c733d313b205f5f75746d613d3130363831303936372e3935313333303339352e313434373631373230372e313434373631373230372e313434373631373230372e313b205f5f75746d7a3d3130363831303936372e313434373631373230372e312e312e75746d6373723d28646972656374297c75746d63636e3d28646972656374297c75746d636d643d286e6f6e65293b207a6462623d3874544c694835355379796647553341315a677671673b20685f7a6462623d66326434636238383765373934623263396631393464633064353938326661613b205f5f61747576633d3625374334363b205f636861727462656174323d535a33674677345455506d7539344f2e313434373631373232333636322e313434373631373538333332372e310d0a436f6e6e656374696f6e3a206b6565702d616c6976650d0a0d0a00;
	
	@cb; update_done = 1'b1;
	@cb; update_done = 1'b0; ready = 1'b1; valid = 1'b1; sop = 1'b1; expected_addr_out = 32'h00000C1C;
	assert(expected_addr_out == cb.aout)
	else $error("2: Incorrect addr out.");
	@cb; sop = 1'b0;
	@cb; @cb; 
	@cb; @cb; empty = 2'b00; @cb;

	for (i = 5352-32; i > 128; i = i - 32) begin
		sample_data   = live_data3 [i     +: 32];
		sample_data_2 = live_data3 [i-32  +: 32];
		sample_data_3 = live_data3 [i-64  +: 32];
		sample_data_4 = live_data3 [i-96  +: 32];
		sample_data_5 = live_data3 [i-128 +: 32];
		compare(sample_data, sample_data_2, sample_data_3, sample_data_4, sample_data_5);
	end

	eop = 1'b1; empty = 2'b01;
	@cb; eop = 1'b0;

	// Verify that, prior to checking the match flags, the url, port, and mac hits have increased by one.
	expected_mac_hits = 2; expected_ip_hits = 1; expected_url_hits = 1; expected_port_hits = 2;
	assert(expected_mac_hits == cb.mhits)
	else $error("4: Incorrect mac match count.");
	assert(expected_ip_hits == cb.ihits)
	else $error("4: Incorrect ip match count.");
	assert(expected_url_hits == cb.uhits)
	else $error("4: Incorrect url match count.");
	assert(expected_port_hits == cb.phits)
	else $error("4: Incorrect port match count.");

	@cb; @cb; @cb; @cb; @cb; @cb; @cb; @cb; @cb;

	//*******************Test Case 4: www.extremetech.com with ERROR *********************//
live_data3 =
5352'h641225eb1080809b203d147408004500028e4e3040004006bd200aba0eac1700fcb3db71005034659269b1f7b37d801800e533cf00000101080a018edc497d660bdd474554202f20485454502f312e310d0a486f73743a207777772e65787472656d65746563682e636f6d0d0a557365722d4167656e743a204d6f7a696c6c612f352e3020285831313b205562756e74753b204c696e7578207838365f36343b2072763a34312e3029204765636b6f2f32303130303130312046697265666f782f34312e300d0a4163636570743a20746578742f68746d6c2c6170706c69636174696f6e2f7868746d6c2b786d6c2c6170706c69636174696f6e2f786d6c3b713d302e392c2a2f2a3b713d302e380d0a4163636570742d4c616e67756167653a20656e2d55532c656e3b713d302e350d0a4163636570742d456e636f64696e673a20677a69702c206465666c6174650d0a436f6f6b69653a205f63625f6c733d313b205f5f75746d613d3130363831303936372e3935313333303339352e313434373631373230372e313434373631373230372e313434373631373230372e313b205f5f75746d7a3d3130363831303936372e313434373631373230372e312e312e75746d6373723d28646972656374297c75746d63636e3d28646972656374297c75746d636d643d286e6f6e65293b207a6462623d3874544c694835355379796647553341315a677671673b20685f7a6462623d66326434636238383765373934623263396631393464633064353938326661613b205f5f61747576633d3625374334363b205f636861727462656174323d535a33674677345455506d7539344f2e313434373631373232333636322e313434373631373538333332372e310d0a436f6e6e656374696f6e3a206b6565702d616c6976650d0a0d0a00;
	
	@cb; update_done = 1'b1;
	@cb; update_done = 1'b0; ready = 1'b1; valid = 1'b1; sop = 1'b1;
	assert(expected_addr_out == cb.aout)
	else $error("2: Incorrect addr out.");
	@cb; sop = 1'b0;
	@cb; @cb; 
	@cb; @cb; empty = 2'b00; @cb;

	// Send approximatey half of the live_data3 data.
	for (i = 5352-32; i > 2016; i = i - 32) begin
		sample_data   = live_data3 [i     +: 32];
		sample_data_2 = live_data3 [i-32  +: 32];
		sample_data_3 = live_data3 [i-64  +: 32];
		sample_data_4 = live_data3 [i-96  +: 32];
		sample_data_5 = live_data3 [i-128 +: 32];
		compare(sample_data, sample_data_2, sample_data_3, sample_data_4, sample_data_5);
	end

	// Simulate an error.
	error = '1; valid = '0;

	// Continue sending the remainder of the packet.
	for (i = 2016-32; i > 128; i = i - 32) begin
		sample_data   = live_data3 [i     +: 32];
		sample_data_2 = live_data3 [i-32  +: 32];
		sample_data_3 = live_data3 [i-64  +: 32];
		sample_data_4 = live_data3 [i-96  +: 32];
		sample_data_5 = live_data3 [i-128 +: 32];
		compare(sample_data, sample_data_2, sample_data_3, sample_data_4, sample_data_5);
	end

	// Eop assertion while the error flag is high should send the controller back to the IDLE state.
	eop = 1'b1; empty = 2'b01;
	@cb; eop = 1'b0;

	// Verify that hit counts did not change due to invalid packet.
	expected_mac_hits = 3; expected_ip_hits = 1; expected_url_hits = 1; expected_port_hits = 3;
	assert(expected_mac_hits == cb.mhits)
	else $error("4: Incorrect mac match count.");
	assert(expected_ip_hits == cb.ihits)
	else $error("4: Incorrect ip match count.");
	assert(expected_url_hits == cb.uhits)
	else $error("4: Incorrect url match count.");
	assert(expected_port_hits == cb.phits)
	else $error("4: Incorrect port match count.");

	error = '0; valid = '1;
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
	
	@cb; data_in = sample_data_2;
	@cb; data_in = sample_data_3; 
	@cb; data_in = sample_data_4; 
	@cb; data_in = sample_data_5; 
	@cb;

	// DATA OUT
	expected_data_out = sample_data;
	assert(expected_data_out == cb.datao)
	else $error("2.2: Incorrect Data_Out");	

	@cb;
	expected_data_out = sample_data_2;
	assert(expected_data_out == cb.datao)
	else $error("2.3:Incorrect Data_Out");
	data_in = 32'h0000; @cb;

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
	
	@cb; @cb; @cb; @cb; @cb;
	end	
endtask

endmodule
