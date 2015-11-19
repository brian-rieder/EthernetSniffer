// File name:   comparator.sv
// Updated:     19 November 2015
// Authors:     Brian Rieder 
//              Catie Cowden 
//              Shaughan Gladden
// Description: Comparator designed for IP address matching based on predefined IP 
//              address programmed from the Atom.

module ip_comparator
(
  // port declaration
  input wire clk,
  input wire n_rst,
  input wire clear,
  input reg [31:0] ip_in,
  input reg [31:0] data_in,
  output reg match,
  output reg [31:0] data_out
);

reg [31:0] a1, a2; // four byte comparator buffers
reg next_match;

always_comb begin
  next_match = 0;
  if (match || (ip_in == a1) || (ip_in == a2)) begin
    next_match = 1;
  end
end

always_ff @ (posedge clk, negedge n_rst) begin
  if ((n_rst == 1'b0) || (clear == 1'b1)) begin
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
