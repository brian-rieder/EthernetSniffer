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
reg [6299:0] live_data;
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
  nextState = state;
  case(state) 
    RULE_ENTERING: begin
      if(csr_registers[5] == '1)
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

always_ff @ (posedge clk, negedge n_rst) begin
  if(state == PACKET_TRANSMISSION) begin
    count <= nextcount;
    data_stream <= live_data[count*32+31 -: 31]; // -: 32?
  end
end

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