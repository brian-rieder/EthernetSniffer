// File name:   mac_comparator.sv
// Updated:     19 November 2015
// Authors:     Brian Rieder 
//              Catie Cowden 
//              Shaughan Gladden
// Description: Comparator designed for MAC address matching based on predefined MAC 
//              address programmed from the Atom.

module mac_comparator
(
  // port declaration
  input wire clk,
  input wire n_rst,
  input wire clear,
  input reg [47:0] flagged_mac,
  input reg [31:0] data_in,
  output reg match,
  output reg [31:0] data_out
);

reg [31:0] a1, a2, a3; // four byte comparator buffers
reg next_match;

always_comb begin
  next_match = match;
  // check if original matches
  if (flagged_mac == {a2[15:0], a3[31:0]}) begin
    next_match = 1;
  end
  // shifted one over
  else if (flagged_mac == {a2[23:0], a3[31:8]}) begin
    next_match = 1;
  end
  // shifted two over
  else if (flagged_mac == {a2[31:0], a3[31:16]}) begin
    next_match = 1;
  end
  // shifted three over
  else if (flagged_mac == {a1[7:0], a2[31:0], a3[31:24]}) begin
    next_match = 1;
  end
end

always_ff @ (posedge clk, negedge n_rst) begin
  if (n_rst == 1'b0) begin
    a1 <= '0;
    a2 <= '0;
    a3 <= '0;
    data_out <= '0;
    match <= '0;
  end else if (clear == 1'b1) begin
    a1 <= '0;
    a2 <= '0;
    a3 <= '0;
    data_out <= '0;
    match <= '0;
  end else begin
    a1 <= data_in;
    a2 <= a1;
    a3 <= a2;
    data_out <= a3;
    match <= next_match;
  end
end

endmodule
