// File name:   result_address_fsm.sv
// Updated:     12 November 2015
// Authors:     Brian Rieder 
//              Catie Cowden 
//              Shaughan Gladden
// Description: Determines the write location for the output FIFO. Output addresses are
//              determined via hard-coding and are rotated when written to (per the
//              inc_addr trigger).

module result_address_fsm
(
  // port declaration
  input wire clk,
  input wire n_rst,
  input reg inc_addr,
  output reg [32:0] addr_out,
  output reg write_enable
);

typedef enum logic [3:0] {
  ADDR1, IDLE1, ADDR2, IDLE2, ADDR3, IDLE3, ADDR4, IDLE4, ADDR5, IDLE5
} state_type;

state_type state, nextstate;
reg next_addr_out, next_write_enable;

// NEXT STATE ASSIGNMENT
always_comb begin
  nextstate = state;
  case(state)
    ADDR1: begin
      nextstate = IDLE1;
    end
    IDLE1: begin
      if (inc_addr == 1'b1)
        nextstate = ADDR2;
    end
    ADDR2: begin
      nextstate = IDLE2;
    end
    IDLE2: begin
      if (inc_addr == 1'b1)
        nextstate = ADDR3;
    end
    ADDR3: begin 
      nextstate = IDLE3;
    end
    IDLE3: begin
      if (inc_addr == 1'b1)
        nextstate = ADDR4;
    end
    ADDR4: begin 
      nextstate = IDLE4;
    end
    IDLE4: begin
      if (inc_addr == 1'b1)
        nextstate = ADDR5;
    end
    ADDR5: begin 
      nextstate = IDLE5;
    end
    IDLE5: begin
      if (inc_addr == 1'b1)
        nextstate = ADDR1;
    end
  endcase
end

// STATE REGISTERING
always_ff @ (posedge clk, negedge n_rst) begin
  if (n_rst == 0) begin
    state <= ADDR1;
    addr_out <= 32'b0;
    write_enable <= 1'b0;
  end else begin
    state <= nextstate;
    addr_out <= next_addr_out;
    write_enable <= next_write_enable;
  end
end

// OUTPUT ASSIGNMENT
// TODO: populate these addresses to be less arbitrary -- bpr
// note: the current values are multiples of 1550
always_comb begin
  next_addr_out = addr_out;
  case(nextstate)
    ADDR1: begin
      next_addr_out = 32'h0000; // 0
      next_write_enable = 1;
    end
    IDLE1: begin
      next_addr_out = 32'h0000; // 0
      next_write_enable = 0;
    end
    ADDR2: begin
      next_addr_out = 32'h060E; // 1550
      next_write_enable = 1;
    end
    IDLE2: begin
      next_addr_out = 32'h060E; // 1550
      next_write_enable = 0;
    end
    ADDR3: begin
      next_addr_out = 32'h0C1C; // 3100
      next_write_enable = 1;
    end
    IDLE3: begin
      next_addr_out = 32'h0C1C; // 3100
      next_write_enable = 0;
    end
    ADDR4: begin
      next_addr_out = 32'h122A; // 4250
      next_write_enable = 1;
    end
    IDLE4: begin
      next_addr_out = 32'h122A; // 4250
      next_write_enable = 0;
    end
    ADDR5: begin
      next_addr_out = 32'h1838; // 5800
      next_write_enable = 1;
    end
    IDLE5: begin
      next_addr_out = 32'h1838; // 5800
      next_write_enable = 0;
    end
  endcase
end


endmodule
