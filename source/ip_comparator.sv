// File name:   comparator.sv
// Updated:     17 November 2015
// Authors:     Brian Rieder 
//              Catie Cowden 
//              Shaughan Gladden
// Description: comparator

module ip_comparator
(
  // port declaration
  input wire clk,
  input wire n_rst,
  input reg [31:0] data_in,
  output reg [31:0] data_out
);

reg [31:0] a1, a2, a3, a4, a5; // four byte comparator buffers

always_ff @ (posedge clk, negedge n_rst) begin
  if (n_rst == 0) begin
    a1 <= '0;
    a2 <= '0;
    a3 <= '0;
    a4 <= '0;
    a5 <= '0;
    data_out <= '0;
  end else begin
    a1 <= data_in;
    a2 <= a1;
    a3 <= a2;
    a4 <= a3;
    a5 <= a4;
    data_out <= a5;
  end
end

endmodule
