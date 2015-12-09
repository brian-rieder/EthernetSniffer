// File name:   controller.sv
// Updated:     04 November 2015
// Authors:     Brian Rieder 
//              Catie Cowden 
//              Shaughan Gladden
// Description: Controller state machine -- determines the outputs and 
//              functionality of the system by outputting signals to indicate
//              readiness of subsystems.

module controller
(
  // port declaration
  input wire clk,
  input wire n_rst,
  input wire port_match, //match flag from port comparator
  input wire ip_match,   //match flag from ip comparator
  input wire mac_match,  //match flag from mac comparator
  input wire url_match,  //match flag from string comparator
  //input wire shift_enable,	//??From "valid" signal from MAC fifo
  input wire update_done,	//??from Avalon Slave
  input wire ready, 	//ready signal from the MAC
  input wire eop, 	//eop from MAC
  input wire error, 	//error from MAC
  input wire valid,	//Used with ready to signify good packet
  input wire rdempty, 	//empty signal from Input FIFO
  output reg rdreq, 	//read request signal to Input FIFO
  //output reg wrreq, 	//write request signal to Input FIFO
  output reg inc_addr, 	//signal to address buffer to increment address
  output reg addr, 	//signal to avalon slave controller
  output reg clear, 	//signal to comparators to clear the match flag
  output reg [63:0] port_hits, ip_hits, mac_hits, url_hits
  //double check the state that the clear flag should be raised in
);

typedef enum logic [3:0] {
  RESET, LOAD_COMP_REG, IDLE, LOAD_INPUT_FIFO, COMPARE, MATCH_FOUND, LOAD_MEMORY, ERROR,
  WAIT1, WAIT2, WAIT3, WAIT4  
} state_type;

state_type state, next_state;
reg next_rdreq, /*next_wrreq,*/ next_inc_addr, next_addr, next_clear, weighted_match, next_weighted_match;
reg [63:0] next_port_hits, next_ip_hits, next_mac_hits, next_url_hits;
// reg [2:0] counter, next_counter;
reg [3:0] wmatch;

// NEXT STATE ASSIGNMENT
// State diagram must be updated to reflect new flags
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
      // if(ready & valid) begin
      //   next_state = LOAD_INPUT_FIFO;
      // end
      if(sop & ready & valid) begin
        next_state = COMPARE;
      end
    end
    
    // LOAD_INPUT_FIFO: begin
    //   // if(counter > '0) begin 
    //     // next_state = COMPARE;
    //   // end
    //   if(eop) begin
    //     next_state = COMPARE;
    //   end
      
    //   else if(error) begin
    //     next_state = ERROR;
    //   end
    // end
    
    COMPARE: begin
      // BPR: we won't receive rdempty if the FIFO is being written to, it will never
      // be completely empty. This signal was being treated as "devoid of previous packet"
      // CEC: what he said
      // if(rdempty) begin
        // next_state = WAIT1;
      // end
      if(eop) begin
        next_state = WAIT1;
      else if(error) begin
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
  next_rdreq = rdreq;
  //next_wrreq = wrreq;
  next_inc_addr = inc_addr;
  next_addr = addr;
  next_clear = clear;
  next_port_hits = port_hits;
  next_ip_hits = ip_hits;
  next_mac_hits = mac_hits;
  next_url_hits = url_hits;
  // next_counter = counter;
  
  case(next_state)
    RESET: begin

    end
    
    LOAD_COMP_REG: begin
      next_rdreq = 0;
      //next_wrreq = 0;
      next_inc_addr = 0;
      next_addr = 1;
      next_clear = 0;
    end
    
    IDLE: begin
      next_rdreq = 0;
      //next_wrreq = 0;
      next_inc_addr = 0;
      next_addr = 0;
      next_clear = 1;
    end
    
    // LOAD_INPUT_FIFO: begin
    //   next_rdreq = 1;
    //   //next_wrreq = 0;
    //   next_inc_addr = 0;
    //   next_addr = 0;
    //   next_clear = 0;
    // end
    
    COMPARE: begin
      next_rdreq = 0;
      //next_wrreq = 1;
      next_inc_addr = 0;
      next_addr = 0;
      next_clear = 0;
    end
    
    MATCH_FOUND: begin
      next_rdreq = 0;
      //next_wrreq = 0;
      next_inc_addr = 0;
      next_addr = 0;
      next_clear = 1;
      
      // if(counter > '0) begin
      //   next_counter = next_counter - 1;
      // end
      
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
      next_rdreq = 0;
      //next_wrreq = 0;
      next_inc_addr = 1;
      next_addr = 0;
      next_clear = 0;
    end
    
    ERROR: begin
      next_rdreq = 0;
      //next_wrreq = 0;
      next_inc_addr = 0;
      next_addr = 0;
      next_clear = 0;
    end
  endcase
  
  // if(eop) begin
    // next_counter = next_counter + 1;
  // end
end

//weighting
always_comb begin
  next_weighted_match = 0;
  
  wmatch = port_match*2 + ip_match*2 + mac_match*1 + url_match*4;
  if(wmatch >= 4)begin
    next_weighted_match = 1;
  end
end

// STATE REGISTERING
always_ff @ (posedge clk, negedge n_rst) begin
  if (!n_rst) begin
    state <= RESET;
    rdreq <= 0;
    //wrreq <= 0;
    inc_addr <= 0;
    addr <= 0;
    clear <= 0;
    port_hits <= '0;
    ip_hits <= '0;
    mac_hits <= '0;
    url_hits <= '0;
    weighted_match <= 0;
    // counter <= 0;
  end 
  
  else begin
    state <= next_state;
    rdreq <= next_rdreq;
    //wrreq <= next_wrreq;
    inc_addr <= next_inc_addr;
    addr <= next_addr;
    clear <= next_clear;
    port_hits <= next_port_hits;
    ip_hits <= next_ip_hits;
    mac_hits <= next_mac_hits;
    url_hits <= next_url_hits;
    weighted_match <= next_weighted_match;
    // counter <= next_counter;
  end
end
endmodule
