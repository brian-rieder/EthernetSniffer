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
reg empty;
reg error;
reg valid;
reg ready;
reg sop;
reg rdempty; //from Input FIFO??
reg [15:0] flagged_port;
reg [31:0] flagged_ip;
reg [47:0] flagged_mac;
reg [0:16][7:0] flagged_string;
reg [31:0] addr_out;
reg wr_en;
reg addr_as;
reg rdreq;
reg [31:0] data_out;

reg [31:0] expected_data_out;
reg [31:0] expected_addr_out;
reg expected_wr_en;
reg expected_addr_as;
reg expected_rdreq;

reg [10396:0] live_data;
reg [31:0] sample_data;
reg [31:0] sample_data_2;
reg [31:0] sample_data_3;
reg [31:0] sample_data_4;
reg [31:0] sample_data_5;
reg clear;
int unsigned strlen;
int unsigned i, j;

ethernetsniffer sniff(.clk, .n_rst, .data_in, .eop, .empty, .error, .valid, .ready, .sop, .rdempty, .flagged_port, .flagged_ip, .flagged_mac, .flagged_string, .data_out, .rdreq, .addr_as, .wr_en, .addr_out);

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
	output rdy = ready;
	output cbsop = sop;
	output rdemp = rdempty;
	output flagport = flagged_port;
	output flagmac = flagged_mac;
	output flagip = flagged_ip;
	output flagstr = flagged_string;
	input aout = addr_out;
	input wren = wr_en;
	input addras = addr_as;
	input rreq = rdreq;
	input datao = data_out;
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
	empty = 1'b0;
	error = 1'b0;
	valid = 1'b0;
	ready = 1'b0;
	sop = 1'b0;
	rdempty = 1'b0;

	//Reset Test Case
	cb.n_rst <= 1'b1;
	@cb; n_rst = 1'b0; @cb;
	expected_data_out = 32'h000;
	expected_addr_out = 1'b0;
	expected_wr_en = 1'b0;
	expected_addr_as = 1'b0;
	expected_rdreq = 1'b0;
	assert(expected_data_out == cb.datao)
	else $error("1: Reset Test Case: Incorrect Data_Out");
	assert(expected_addr_out == cb.aout)
	else $error("1: Reset Test Case: Incorrect addr_out");
	assert(expected_wr_en == cb.wren)
	else $error("1: Reset Test Case: Incorrect write enable");
	assert(expected_addr_as == cb.addras)
	else $error("1: Reset Test Case: Incorrect addr_as");
	assert(expected_rdreq == cb.rreq)
	else $error("1: Reset Test Case: Incorrect rdreq");
	@cb; @cb;

	@cb; clear = 1'b1; @cb; clear = 1'b0;

	//*******************Test Case 1:*********************//
	live_data = 10396'h641225eb1080809b203d147408004500029df7f740004006ac6b0aba00a480d207c89b160050602b1fe50b1d5a1e8018721028eb00000101080a007ee81269c4828a474554202f20485454502f312e310d0a486f73743a207777772e7075726475652e6564750d0a557365722d4167656e743a204d6f7a696c6c612f352e3020285831313b205562756e74753b204c696e7578207838365f36343b2072763a34312e3029204765636b6f2f32303130303130312046697265666f782f34312e300d0a4163636570743a20746578742f68746d6c2c6170706c69636174696f6e2f7868746d6c2b786d6c2c6170706c69636174696f6e2f786d6c3b713d302e392c2a2f2a3b713d302e380d0a4163636570742d4c616e67756167653a20656e2d55532c656e3b713d302e350d0a4163636570742d456e636f64696e673a20677a69702c206465666c6174650d0a436f6f6b69653a205f5f75746d613d3134313232383333392e3634383636353639382e313433313836393238322e313434353839303937392e313434353930393839302e333b205f5f75746d7a3d3134313232383333392e313433313836393238322e312e312e75746d6373723d676f6f676c657c75746d63636e3d286f7267616e6963297c75746d636d643d6f7267616e69637c75746d6374723d286e6f7425323070726f7669646564293b205f67613d4741312e322e3634383636353639382e313433313836393238323b206b6d5f75713d3b206b6d5f6c763d783b206b6d5f61693d323635353835363b206b6d5f6e693d323635353835363b2042494769705365727665727e5745427e706f6f6c5f6c707077656261706130312e697461702e7075726475652e6564755f7765623d333137303839363339342e302e303030300d0a436f6e6e656374696f6e3a206b6565702d616c6976650d0a0d0a;
	
	flagged_string = "www.purdue.edu"; 	
	strlen = 14;

	if ($bits(live_data) < 160) begin
		$info("Sample data must be at least 160 bits long");		
		$stop;
	end

	for (i = 10320-32; i > 128; i = i - 32) begin
		sample_data   = live_data [i     +: 32];
		sample_data_2 = live_data [i-32  +: 32];
		sample_data_3 = live_data [i-64  +: 32];
		sample_data_4 = live_data [i-96  +: 32];
		sample_data_5 = live_data [i-128 +: 32];
		compare(sample_data, sample_data_2, sample_data_3, sample_data_4, sample_data_5);
	end

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

	data_in = 32'h0000; @cb;

	// DATA OUT
	@cb;
	expected_data_out = sample_data;
	assert(expected_data_out == cb.datao)
	else $error("2.2: Incorrect Data_Out");
	@cb;
	expected_data_out = sample_data_2;
	assert(expected_data_out == cb.datao)
	else $error("2.3:Incorrect Data_Out");
	@cb;
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
	clear = 1'b1; @cb; clear = 1'b0;
	end	
endtask

endmodule
