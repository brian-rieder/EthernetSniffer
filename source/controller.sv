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
  input wire match, //match flag from comparators
  input wire shift_enable,
  input wire update_done,
  input wire eop, //eop from MAC
  input wire error, //error from MAC
  input wire rdempty, //empty signal from Input FIFO
  output reg rdreq, //read request signal to Input FIFO
  output reg wrreq, //write request signal to Input FIFO
  output reg inc_addr, //signal to address buffer to increment address
  output reg addr, //signal to avalon slave controller
  output reg clear //signal to comparators to clear the match flag
);

typedef enum logic [3:0] {
  RESET, LOAD_COMP_REG, IDLE, LOAD_INPUT_FIFO, COMPARE, MATCH_FOUND, LOAD_MEMORY, ERROR  
} state_type;

state_type state, next_state;
reg next_rdreq, next_wrreq, next_inc_addr, next_addr, next_clear

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
      if(ready) begin
        next_state = LOAD_INPUT_FIFO;
      end
    end
    
    LOAD_INPUT_FIFO: begin
      if(eop) begin
        next_state = COMPARE;
      end
      
      else if(error) begin
        next_state = ERROR;
      end
    end
    
    COMPARE: begin
      if(rdempty) begin
        next_state = MATCH_FOUND;
      end
    end
    
    MATCH_FOUND: begin
      if(match) begin
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
  next_wrreq = wrreq;
  next_inc_addr = inc_addr;
  next_addr = addr;
  next_clear = clear;
  
  case(next_state)
    RESET: begin

    end
    
    LOAD_COMP_REG: begin
      next_rdreq = 0;
      next_wrreq = 0;
      next_inc_addr = 0;
      next_addr = 1;
      next_clear = 0;
    end
    
    IDLE: begin
      next_rdreq = 0;
      next_wrreq = 0;
      next_inc_addr = 0;
      next_addr = 0;
      next_clear = 1;
    end
    
    LOAD_INPUT_FIFO: begin
      next_rdreq = 1;
      next_wrreq = 0;
      next_inc_addr = 0;
      next_addr = 0;
      next_clear = 0;
    end
    
    COMPARE: begin
      next_rdreq = 0;
      next_wrreq = 1;
      next_inc_addr = 0;
      next_addr = 0;
      next_clear = 0;
    end
    
    MATCH_FOUND: begin
      next_rdreq = 0;
      next_wrreq = 0;
      next_inc_addr = 0;
      next_addr = 0;
      next_clear = 0;
    end
    
    LOAD_MEMORY: begin
      next_rdreq = 0;
      next_wrreq = 0;
      next_inc_addr = 1;
      next_addr = 0;
      next_clear = 0;
    end
    
    ERROR: begin
      next_rdreq = 0;
      next_wrreq = 0;
      next_inc_addr = 0;
      next_addr = 0;
      next_clear = 0;
    end
  endcase
end

// STATE REGISTERING
always_ff @ (posedge clk, negedge n_rst) begin
  if (!n_rst) begin
    state <= RESET;
    rdreq <= 0;
    wrreq <= 0;
    inc_addr <= 0;
    addr <= 0;
    clear <= 0;
  end 
  
  else begin
    state <= next_state;
    rdreq <= next_rdreq;
    wrreq <= next_wrreq;
    inc_addr <= next_inc_addr;
    addr <= next_addr;
    clear <= next_clear;
  end
end
endmodule
