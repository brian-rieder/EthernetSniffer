// File name:   rx_fifo.sv
// Updated:     6 October 2015
// Author:      Brian Rieder
// Description: FIFO Block

module rx_fifo
(
  // port declaration
);

fifo RX_FIFO (.r_clk(), .w_clk(), .n_rst(), .r_enable(), 
              .w_enable(), .w_data(), .r_data(), .empty(), .full());

endmodule
