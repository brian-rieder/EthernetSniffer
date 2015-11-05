// File name:   result_address_fsm.sv
// Created:     05 November 2015
// Authors:     Brian Rieder 
//              Catie Cowden 
//              Shaughan Gladden
// Description: result_address_fsm

module result_address_fsm
(
  // port declaration
  input inc_addr,
  output [32:0] addr_out
);

typedef enum logic [2:0] {
  ADDR1, ADDR2, ADDR3, ADDR4, ADDR5
} state_type;

state_type state, nextstate;
reg next_addr_out;

// NEXT STATE ASSIGNMENT
always_comb begin
  nextstate = state;
  case(state)
    ADDR1: begin
      if (inc_addr == 1'b1)
        nextstate = ADDR2;
    end
    ADDR2: begin
      if (inc_addr == 1'b1)
        nextstate = ADDR3;
    end
    ADDR3: begin 
      if (inc_addr == 1'b1)
        nextstate = ADDR4;
    end
    ADDR4: begin 
      if (inc_addr == 1'b1)
        nextstate = ADDR5;
    end
    ADDR5: begin 
      if (inc_addr == 1'b1)
        nextstate = ADDR1;
    end
  endcase
end

// STATE REGISTERING
always_ff @ (posedge clk, negedge n_rst) begin
  if (n_rst == 0) begin
    state <= ADDR_1;
  end else begin
    state <= nextstate;
  end
end

// OUTPUT ASSIGNMENT
// TODO: populate these addresses to not be null -- bpr
always_comb begin
  next_addr_out = addr_out;
  case(nextstate)
    ADDR1: begin
      next_addr_out = 32'b0;
    end
    ADDR2: begin
      next_addr_out = 32'b0;
    end
    ADDR3: begin
      next_addr_out = 32'b0;
    end
    ADDR4: begin
      next_addr_out = 32'b0;
    end
    ADDR5: begin
      next_addr_out = 32'b0;
    end
  endcase
end

endmodule
