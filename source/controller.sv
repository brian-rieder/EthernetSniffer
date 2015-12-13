// File name:   controller.sv
// Updated:     04 November 2015
// Authors:     Brian Rieder 
//              Catie Cowden 
//              Shaughan Gladden
// Description: Controller state machine -- The controller determines the outputs and 
//              functionality of the system by outputting signals to indicate
//              readiness of subsystems.

module controller
(
  input wire clk,
  input wire n_rst,
  input wire port_match, 	//match flag from port comparator
  input wire ip_match,   	//match flag from ip comparator
  input wire mac_match,  	//match flag from mac comparator
  input wire url_match,  	//match flag from string comparator
  input wire update_done,	//from Avalon Slave
  input wire sop,   		//sop from MAC
  input wire eop, 		//eop from MAC
  input wire [5:0] error, 	//error from MAC
  input wire valid,		//Used with ready to signify good packet
  input wire [1:0] empty, 	//empty signal from Input FIFO
  output reg ready, 		//ready signal to the Input FIFO
  output reg inc_addr, 		//signal to address buffer to increment address
  output reg clear, 		//signal to comparators to clear the match flag
  output reg [31:0] port_hits, ip_hits, mac_hits, url_hits //registers to hold the hit counts
);

typedef enum logic [3:0] {
  RESET, LOAD_COMP_REG, IDLE, LOAD_INPUT_FIFO, COMPARE, MATCH_FOUND, LOAD_MEMORY, ERROR,
  WAIT1, WAIT2, WAIT3, WAIT4  
} state_type;

state_type state, next_state;
reg next_inc_addr, next_clear, weighted_match, next_weighted_match, next_ready;
reg [63:0] next_port_hits, next_ip_hits, next_mac_hits, next_url_hits;
reg [3:0] wmatch;

// NEXT STATE ASSIGNMENT
always_comb begin
  next_state = state;
  
  case(state)
    RESET: begin
      next_state = LOAD_COMP_REG;
    end
    
    LOAD_COMP_REG: begin
      if(update_done) begin
        next_state = IDLE;
      end
    end
    
    IDLE: begin
      if(sop & valid) begin
        next_state = COMPARE;
      end
    end
    
    COMPARE: begin
      if(eop) begin
        next_state = WAIT1;
      end
      else if(error != '0) begin
        next_state = ERROR;
      end
    end
    
    WAIT1: begin
      next_state = WAIT2;
    end
    
    WAIT2: begin
      next_state = WAIT3;
    end
    
    WAIT3: begin
      next_state = WAIT4;
    end
    
    WAIT4: begin
      next_state = MATCH_FOUND;
    end
    
    MATCH_FOUND: begin
      if(weighted_match) begin
        next_state = LOAD_MEMORY;
      end
      else begin
        next_state = IDLE;
      end
    end
    
    LOAD_MEMORY: begin
      next_state = IDLE;
    end
    
    ERROR: begin
      if(eop) begin
        next_state = IDLE;
      end
    end
  endcase
end

// OUTPUT ASSIGNMENT
// Flags need to be changed
always_comb begin
  next_inc_addr = inc_addr;
  next_clear = clear;
  next_port_hits = port_hits;
  next_ip_hits = ip_hits;
  next_mac_hits = mac_hits;
  next_url_hits = url_hits;
  next_ready = ready;

  case(next_state)
    RESET: begin
    end
    
    LOAD_COMP_REG: begin
      next_inc_addr = 0;
      next_clear = 0;
      next_ready = 0;
    end
    
    IDLE: begin
      next_inc_addr = 0;
      next_clear = 1;
      if(empty < 3) begin
        next_ready = 1;
      end
    end
    
    COMPARE: begin
      next_inc_addr = 0;
      next_clear = 0;
      next_ready = 1;
    end
    
    WAIT1: begin
      next_inc_addr = 0;
      next_clear = 0;
      next_ready = 0;
    end
    
    WAIT2: begin
      next_inc_addr = 0;
      next_clear = 0;
      next_ready = 0;
    end
    
    WAIT3: begin
      next_inc_addr = 0;
      next_clear = 0;
      next_ready = 0;
    end
    
    WAIT4: begin
      next_inc_addr = 0;
      next_clear = 0;
      next_ready = 0;
    end
    
    MATCH_FOUND: begin
      next_inc_addr = 0;
      next_clear = 1;
      
      if(port_match) begin
        next_port_hits = next_port_hits + 1;
      end
      if(ip_match) begin
        next_ip_hits = next_ip_hits + 1;
      end
      if(mac_match) begin
        next_mac_hits = next_mac_hits + 1;
      end
      if(url_match) begin
        next_url_hits = next_url_hits + 1;
      end
      
    end
    
    LOAD_MEMORY: begin
      next_inc_addr = 1;
      next_clear = 0;
      next_ready = 0;
    end
    
    ERROR: begin
      next_inc_addr = 0;
      next_clear = 0;
      next_ready = 1;
    end
  endcase
  
end

//WEIGHTING
always_comb begin
  next_weighted_match = 0;
  // wmatch = port_match + ip_match*2 + mac_match*2 + url_match*4;
  wmatch = port_match;
  wmatch = wmatch + ip_match*2;
  wmatch = wmatch + mac_match*2;
  wmatch = wmatch + url_match*4;
  if(wmatch >= 4)begin
    next_weighted_match = 1;
  end
end

// STATE REGISTERING
always_ff @ (posedge clk, negedge n_rst) begin
  if (!n_rst) begin
    state <= RESET;
    ready <= 0;
    inc_addr <= '0;
    clear <= '0;
    port_hits <= '0;
    ip_hits <= '0;
    mac_hits <= '0;
    url_hits <= '0;
    weighted_match <= 0;
  end 
  
  else begin
    state <= next_state;
    ready <= next_ready;
    inc_addr <= next_inc_addr;
    clear <= next_clear;
    port_hits <= next_port_hits;
    ip_hits <= next_ip_hits;
    mac_hits <= next_mac_hits;
    url_hits <= next_url_hits;
    weighted_match <= next_weighted_match;
  end
end
endmodule
