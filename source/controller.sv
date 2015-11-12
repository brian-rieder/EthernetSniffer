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
  input wire [32:0] data_in,
  input wire match,
  input wire shift_enable,
  output wire rdreq,
  output wire read,
  output wire inc_addr,
  output wire addr
);

typedef enum logic [3:0] {
  RESET, LOAD_COMP_REG, IDLE, LOAD_INPUT_FIFO, LOAD_COMPARATORS, COMPARE_CONTENTS, MATCH_FOUND, LOAD_MEMORY, ERROR  
} state_type;

state_type state, nextstate;

endmodule
