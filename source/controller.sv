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
  input wire match,
  input wire shift_enable,
  input wire update_done,
  input wire eop,
  input wire error,
  input wire fifo_eop,
  output reg rdreq,
  output reg read,
  output reg inc_addr,
  output reg addr
);

typedef enum logic [3:0] {
  RESET, LOAD_COMP_REG, IDLE, LOAD_INPUT_FIFO, LOAD_COMPARATORS, COMPARE_CONTENTS, MATCH_FOUND, LOAD_MEMORY, ERROR  
} state_type;

state_type state, next_state;
reg next_rdreq, next_read, next_inc_addr, next_addr

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
      if(ready) begin
        next_state = LOAD_INPUT_FIFO;
      end
    end
    
    LOAD_INPUT_FIFO: begin
      if(eop) begin
        next_state = LOAD_COMPARATORS;
      end
      
      else if(error) begin
        next_state = ERROR;
      end
    end
    
    LOAD_COMPARATORS: begin
      if(fifo_eop) begin
        next_state = COMPARE_CONTENTS;
      end
    end
    
    COMPARE_CONTENTS: begin
      if(comp_done) begin
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
always_comb begin
  next_rdreq = rdreq;
  next_read = read;
  next_inc_addr = inc_addr;
  next_addr = addr;
  
  case(next_state)
    RESET: begin

    end
    
    LOAD_COMP_REG: begin
      next_rdreq = 0;
      next_read = 0;
      next_inc_addr = 0;
      next_addr = 1;
    end
    
    IDLE: begin
      next_rdreq = 0;
      next_read = 0;
      next_inc_addr = 0;
      next_addr = 1;
    end
    
    LOAD_INPUT_FIFO: begin
      next_rdreq = 0;
      next_read = 0;
      next_inc_addr = 0;
      next_addr = 1;
    end
    
    LOAD_COMPARATORS: begin
      next_rdreq = 0;
      next_read = 0;
      next_inc_addr = 0;
      next_addr = 1;
    end
    
    COMPARE_CONTENTS: begin
      next_rdreq = 0;
      next_read = 0;
      next_inc_addr = 0;
      next_addr = 1;
    end
    
    MATCH_FOUND: begin
      next_rdreq = 0;
      next_read = 0;
      next_inc_addr = 0;
      next_addr = 1;
    end
    
    LOAD_MEMORY: begin
      next_rdreq = 0;
      next_read = 0;
      next_inc_addr = 0;
      next_addr = 1;
    end
    
    ERROR: begin
      next_rdreq = 0;
      next_read = 0;
      next_inc_addr = 0;
      next_addr = 1;
    end
  endcase
end

// STATE REGISTERING
always_ff @ (posedge clk, negedge n_rst) begin
  if (!n_rst) begin
    state <= RESET;
    next_rdreq <= 0;
    next_read <= 0;
    next_inc_addr <= 0;
    next_addr <= 0;
  end 
  
  else begin
    state <= next_state;
    rdreq <= next_rdreq;
    read <= next_read;
    inc_addr <= next_inc_addr;
    addr <= next_addr;
  end
end
endmodule
