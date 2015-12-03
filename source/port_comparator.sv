// File name:   ip_comparator.sv
// Updated:     19 November 2015
// Authors:     Brian Rieder 
//              Catie Cowden 
//              Shaughan Gladden
// Description: Comparator designed for IP address matching based on predefined IP 
//              address programmed from the Atom.

module port_comparator
(
  // port declaration
  input wire clk,
  input wire n_rst,
  input wire clear,
  input reg [31:0] flagged_port,
  input reg [31:0] data_in,
  output reg match,
  output reg [31:0] data_out
);

reg [31:0] a1, a2 = '0; // four byte comparator buffers
reg next_match = '0;

always_comb begin
  next_match = match;
  // check if original matches
  if (flagged_port == a2[15:0]) begin
    next_match = 1;
  end
  // shifted one over
  else if (flagged_port == a2[23:8]) begin
    next_match = 1;
  end
  // shifted two over
  else if (flagged_port == a2[31:16]) begin
    next_match = 1;
  end
  // shifted three over
  else if (flagged_port == {a1[7:0], a2[31:24]}) begin
    next_match = 1;
  end
  // shifted four over
  else if (flagged_port == a1[15:0]) begin
    next_match = 1;
  end
  // shifted five over
  else if (flagged_port == a1[23:8]) begin
    next_match = 1;
  end
  // shifted six over
  else if (flagged_port == a1[31:16]) begin
    next_match = 1;
  end
end

always_ff @ (posedge clk, negedge n_rst) begin
  //Can only have one condition in if statement at a time for mapped compilation.
  //Separate clear == 1 and reset == 0 to two statements.
  if (n_rst == 1'b0) begin
    a1 <= '0;
    a2 <= '0;
    data_out <= '0;
    match <= '0;
  end else if (clear == 1'b1) begin
    a1 <= '0;
    a2 <= '0;
    data_out <= '0;
    match <= '0;
  end else begin
    a1 <= data_in;
    a2 <= a1;
    data_out <= a2;
    match <= next_match;
  end
end

endmodule
