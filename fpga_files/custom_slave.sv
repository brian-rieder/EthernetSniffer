// File name : custom_slave.sv
// Author : Ishaan Biswas
// Created : 03/29/2015
// Version 1.0 
// Description : Demo example to illustrate slave interface usage


module custom_slave #(
	parameter MASTER_ADDRESSWIDTH = 26 ,  	// ADDRESSWIDTH specifies how many addresses the Master can address 
	parameter SLAVE_ADDRESSWIDTH = 3 ,  	// ADDRESSWIDTH specifies how many addresses the slave needs to be mapped to. log(NUMREGS)
	parameter DATAWIDTH = 32 ,    		// DATAWIDTH specifies the data width. Default 32 bits
	parameter NUMREGS = 8 ,       		// Number of Internal Registers for Custom Logic
	parameter REGWIDTH = 32       		// Data Width for the Internal Registers. Default 32 bits
)	
(	
	input logic  clk,
  input logic  reset_n,
	
	// Interface to Top Level
	// input logic rdwr_cntl,					// Control Read or Write to a slave module.
	// input logic n_action,					// Trigger the Read or Write. Additional control to avoid continuous transactions. Not a required signal. Can and should be removed for actual application.
	// input logic add_data_sel,				// Interfaced to switch. Selects either Data or Address to be displayed on the Seven Segment Displays.
	// input logic [MASTER_ADDRESSWIDTH-1:0] rdwr_address,	// read_address if required to be sent from another block. Can be unused if consecutive reads are required.
  output logic [DATAWIDTH-1:0] display_data,

	// Bus Slave Interface
  input logic [SLAVE_ADDRESSWIDTH-1:0] slave_address,
  input logic [DATAWIDTH-1:0] slave_writedata,
  input logic  slave_write,
  input logic  slave_read,
  input logic  slave_chipselect,
  // input logic  slave_readdatavalid, 			// These signals are for variable latency reads. 
  // output logic slave_waitrequest,   			// See the Avalon Specifications for details  on how to use them.
  output logic [DATAWIDTH-1:0] slave_readdata,

	// Bus Master Interface
  output logic [MASTER_ADDRESSWIDTH-1:0] master_address,
  output logic [DATAWIDTH-1:0] master_writedata,
  output logic  master_write,
  output logic  master_read,
  input logic [DATAWIDTH-1:0] master_readdata,
  input logic  master_readdatavalid,
  input logic  master_waitrequest,

  // BPR: Avalon streaming sink signals
  input logic [31:0] data_mac,
  input logic data_valid_mac,
  input logic eop_mac,
  input logic [1:0] channel_mac,
  output logic ready_mac,
  input logic sop_mac,
  input logic [5:0] error_mac,

  // BPR: PCIe signals
  input logic pcie_tx_data,
  output logic pcie_rx_data,

  // output signals
  output logic [31:0] debug_data,
  output logic debug_sop
);


parameter START_BYTE = 32'hF00BF00B;
parameter STOP_BYTE = 32'hDEADF00B;
parameter SDRAM_ADDR = 32'h08000000;

logic [MASTER_ADDRESSWIDTH-1:0] address, nextAddress;
logic [DATAWIDTH-1:0] nextRead_data, read_data;
logic [DATAWIDTH-1:0] nextData, wr_data;
logic [NUMREGS-1:0][REGWIDTH-1:0] csr_registers;  		// Command and Status Registers (CSR) for custom logic 
logic [NUMREGS-1:0] reg_index, nextRegIndex;
typedef enum {RULE_ENTERING, PACKET_TRANSMISSION} state_t;
state_t state, nextState;

// BPR assignments
reg [6299:0] purdue_data, wired_data, extech_data;
reg [31:0] data_stream;
reg [13:0] count, nextcount;
reg sim_eop, sim_sop;
reg next_eop, next_sop;

//assign wr_data = 32'hdeadbeef;

// Slave side 
always_ff @ ( posedge clk ) begin 
  if(!reset_n)
  	begin
    	slave_readdata <= 32'h0;
 	    csr_registers <= '0;
  	end
  else 
  	begin
  	  if(slave_write && slave_chipselect && (slave_address >= 0) && (slave_address < NUMREGS))
  	  	begin
  	  	  csr_registers[slave_address] <= slave_writedata;  // Write a value to a CSR register
  	  	end
  	  else if(slave_read && slave_chipselect  && (slave_address >= 0) && (slave_address < NUMREGS)) // reading a CSR Register
  	    	begin
       		  // Send a value being requested by a master. 
       		  // If the computation is small you may compute directly and send it out to the master directly from here.
  	    	   slave_readdata <= csr_registers[slave_address];
  	    	end
  	 end
end

always_comb begin
  purdue_data = 6300'h641225eb1080809b203d14740800450002fb9e6b4000400600410aba05fd80d207c8cc89005066fd81a57610e49e80187210a46800000101080a01091fd77893c23f474554202f20485454502f312e310d0a486f73743a207777772e7075726475652e6564750d0a557365722d4167656e743a204d6f7a696c6c612f352e3020285831313b205562756e74753b204c696e7578207838365f36343b2072763a34312e3029204765636b6f2f32303130303130312046697265666f782f34312e300d0a4163636570743a20746578742f68746d6c2c6170706c69636174696f6e2f7868746d6c2b786d6c2c6170706c69636174696f6e2f786d6c3b713d302e392c2a2f2a3b713d302e380d0a4163636570742d4c616e67756167653a20656e2d55532c656e3b713d302e350d0a4163636570742d456e636f64696e673a20677a69702c206465666c6174650d0a436f6f6b69653a205f5f75746d613d3134313232383333392e3634383636353639382e313433313836393238322e313434353839303937392e313434353930393839302e333b205f5f75746d7a3d3134313232383333392e313433313836393238322e312e312e75746d6373723d676f6f676c657c75746d63636e3d286f7267616e6963297c75746d636d643d6f7267616e69637c75746d6374723d286e6f7425323070726f7669646564293b205f67613d4741312e322e3634383636353639382e313433313836393238323b206b6d5f75713d3b206b6d5f6c763d783b206b6d5f61693d323635353835363b206b6d5f6e693d323635353835363b2042494769705365727665727e5745427e706f6f6c5f6c707077656261706130312e697461702e7075726475652e6564755f7765623d333033363637383636362e302e303030300d0a436f6e6e656374696f6e3a206b6565702d616c6976650d0a49662d4d6f6469666965642d53696e63653a204d6f6e2c203233204e6f7620323031352032313a31353a343120474d540d0a49662d4e6f6e652d4d617463683a20223837303066322d343962392d35323533626261333662393430220d0a0d0a000000000000000000000;
  wired_data  = 6300'h641225eb1080809b203d14740800450001572a0d40004006c35c0aba00a417eb28efd0cc00505e627fbc6ae78611801800e5014c00000101080a007255b95eae8bfc474554202f20485454502f312e310d0a486f73743a207777772e77697265642e636f6d0d0a557365722d4167656e743a204d6f7a696c6c612f352e3020285831313b205562756e74753b204c696e7578207838365f36343b2072763a34312e3029204765636b6f2f32303130303130312046697265666f782f34312e300d0a4163636570743a20746578742f68746d6c2c6170706c69636174696f6e2f7868746d6c2b786d6c2c6170706c69636174696f6e2f786d6c3b713d302e392c2a2f2a3b713d302e380d0a4163636570742d4c616e67756167653a20656e2d55532c656e3b713d302e350d0a4163636570742d456e636f64696e673a20677a69702c206465666c6174650d0a436f6e6e656374696f6e3a206b6565702d616c6976650d0a0d0a000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000;
  extech_data = 6300'h641225eb1080809b203d147408004500028e4e3040004006bd200aba0eac1700fcb3db71005034659269b1f7b37d801800e533cf00000101080a018edc497d660bdd474554202f20485454502f312e310d0a486f73743a207777772e65787472656d65746563682e636f6d0d0a557365722d4167656e743a204d6f7a696c6c612f352e3020285831313b205562756e74753b204c696e7578207838365f36343b2072763a34312e3029204765636b6f2f32303130303130312046697265666f782f34312e300d0a4163636570743a20746578742f68746d6c2c6170706c69636174696f6e2f7868746d6c2b786d6c2c6170706c69636174696f6e2f786d6c3b713d302e392c2a2f2a3b713d302e380d0a4163636570742d4c616e67756167653a20656e2d55532c656e3b713d302e350d0a4163636570742d456e636f64696e673a20677a69702c206465666c6174650d0a436f6f6b69653a205f63625f6c733d313b205f5f75746d613d3130363831303936372e3935313333303339352e313434373631373230372e313434373631373230372e313434373631373230372e313b205f5f75746d7a3d3130363831303936372e313434373631373230372e312e312e75746d6373723d28646972656374297c75746d63636e3d28646972656374297c75746d636d643d286e6f6e65293b207a6462623d3874544c694835355379796647553341315a677671673b20685f7a6462623d66326434636238383765373934623263396631393464633064353938326661613b205f5f61747576633d3625374334363b205f636861727462656174323d535a33674677345455506d7539344f2e313434373631373232333636322e313434373631373538333332372e310d0a436f6e6e656374696f6e3a206b6565702d616c6976650d0a0d0a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000;
end

always_comb begin
  nextState = state;
  case(state) 
    RULE_ENTERING: begin
      if(csr_registers[4] == '1)
        nextState = PACKET_TRANSMISSION;
    end
  endcase
end

always_comb begin
  nextcount = 0;
  if(state == PACKET_TRANSMISSION) begin
    nextcount = count + 1;
  end
end

always_ff @ (posedge clk) begin
  if(state == PACKET_TRANSMISSION) begin
    count <= nextcount;
    data_stream <= live_data[count*32+31 -: 31]; // -: 32?
  end
  else begin
    count <= '0;
    data_stream <= 32'h12345678;
  end
end

assign display_data = data_stream;
ethernetsniffer ESNIFF (
  // inputs
  .clk(clk),
  .n_rst(n_rst),
  .data_in(data_stream),
  .eop(sim_eop),
  .empty(0),
  .error('0),
  .valid(1),
  .sop(sim_sop),
  .flagged_port(csr_registers[2]),
  .flagged_ip(csr_registers[0]),
  .flagged_mac(csr_registers[1]),
  .flagged_string(csr_registers[3]),
  .update_done(),
  .strlen(),
  // outputs
  .ready(),
  .addr_out(),
  .write_enable(),
  .data_out(),
  .port_hits(),
  .ip_hits(),
  .mac_hits(),
  .url_hits()
);

endmodule