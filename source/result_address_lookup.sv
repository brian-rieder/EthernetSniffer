// File name:   result_address_lookup.sv
// Updated:     19 November 2015
// Authors:     Brian Rieder 
//              Catie Cowden 
//              Shaughan Gladden
// Description: result_address_lookup

module result_address_lookup
(
  // port declaration
  input wire clk,
  input wire n_rst,
  input reg inc_addr,
  output reg [31:0] addr_out,
  output reg write_enable
);

reg [31:0] result_address_buffer [0:4] = {32'h00000000, 32'h0000060E, 32'h00000C1C, 32'h0000122A, 32'h00001838};
reg [2:0] counter_index = '0;
reg next_write_enable;

always_comb begin
  next_write_enable = 0;
  if (inc_addr == 1'b1) begin
    counter_index += 1;
    next_write_enable = 1;
  end
  if (counter_index > 4) begin
    counter_index = 0;
  end
end

always_ff @ (posedge clk, negedge n_rst) begin
  if (n_rst == 0) begin
    addr_out <= 32'b0;
    write_enable <= 1'b0;
  end else begin
    addr_out <= result_address_buffer[counter_index];
    write_enable <= next_write_enable;
  end
end

endmodule
