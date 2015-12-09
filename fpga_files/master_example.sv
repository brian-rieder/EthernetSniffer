module master_example ( 
	input logic CLOCK_50,
	input logic [17:0] SW, 
	input logic [3:0] KEY,
	output logic [8:0] LEDG, 
	output logic [17:0]LEDR,
	// DRAM signals
	// output logic [11:0]DRAM_ADDR,
	// output logic [1:0]DRAM_BA,
	// output logic DRAM_CAS_N,
	// output logic DRAM_CKE,
	// output logic DRAM_CLK,
	// output logic DRAM_CS_N,
	// inout	logic  [31:0] DRAM_DQ,
	// output logic [3:0] DRAM_DQM,
	// output logic DRAM_RAS_N,
	// output logic DRAM_WE_N,
	
	// HEX 7 SEG DISPLAY
	output logic [6:0] HEX0,
	output logic [6:0] HEX1,
	output logic [6:0] HEX2,
	output logic [6:0] HEX3,
	output logic [6:0] HEX4,
	output logic [6:0] HEX5,
	output logic [6:0] HEX6,
	output logic [6:0] HEX7,
	// PCIE signals
	input logic PCIE_PERST_N,
	input logic PCIE_REFCLK_P,
	input logic PCIE_RX_P,
	output logic PCIE_TX_P,
	output logic PCIE_WAKE_N,
	inout logic FAN_CTRL,

	// Ethernet signals
	output logic ENET_GTX_CLK,
	input logic ENET_INT_N,
	input logic ENET_LINK100,
	output logic ENET_MDC,
	(* useioff = 1 *) inout logic ENET_MDIO,
	output logic ENET_RST_N,
	input logic ENET_RX_CLK,
	input logic ENET_RX_COL,
	input logic ENET_RX_CRS,
	input logic [3:0] ENET_RX_DATA,
	input logic ENET_RX_DV,
	input logic ENET_RX_ER,
	input logic ENET_TX_CLK,
	output logic [3:0] ENET_TX_DATA,
	output logic ENET_TX_EN,
	output logic ENET_TX_ER
);		

//parameter ADDRESSWIDTH = 32 ;
parameter ADDRESSWIDTH = 28;
parameter DATAWIDTH = 32;

logic soc_clk;


logic [31:0] display_data;
/* 
pll pll_inst(
	.inclk0( CLOCK_50) ,
	.c1( temp_vga_clk ) ,
	.c0(DRAM_CLK ) ,	
	.c2( soc_clk) );
*/
	
assign FAN_CTRL = 1'b0;
assign PCIE_WAKE_N = 1'b1;

assign soc_clk = CLOCK_50;


assign DRAM_CLK = CLOCK_50;
	
always_ff @(posedge CLOCK_50) begin
	if(!KEY[0]) begin
		LEDG <= 0; 
	end else begin
	end
end	

//IB//amm_master_qsys_custom_with_bfm u0 (
//IB//        .clk_clk                            (soc_clk), 
//IB//        .reset_reset_n                      (KEY[0]), 
//IB//        .custom_module_conduit_rdwr_cntl    (SW[17]), 
//IB//        .custom_module_conduit_n_action     (KEY[1]), 
//IB//        .custom_module_conduit_add_data_sel (SW[16]),
//IB//        .custom_module_conduit_rdwr_address (SW[15:0])
//IB//    );




//amm_master_qsys amm_master_inst  ( 
 // amm_master_qsys_with_pcie amm_master_inst  ( 
 // 	.clk_clk				(soc_clk),  				  // clk.clk
 // 	.reset_reset_n				(KEY[0]),                  	          // reset.reset_n
 // //	.altpll_sdram_clk               	(DRAM_CLK),
 // 	.sdram_addr				(DRAM_ADDR),         			  // new_sdram_controller_0_wire.addr
 // 	.sdram_ba				(DRAM_BA),           			  // ba
 // 	.sdram_cas_n				(DRAM_CAS_N),        			  // cas_n
 // 	.sdram_cke				(DRAM_CKE),          			  // cke
 // 	.sdram_cs_n				(DRAM_CS_N),         			  // cs_n
 // 	.sdram_dq				(DRAM_DQ),           			  // dq
 // 	.sdram_dqm				(DRAM_DQM),          			  // dqm
 // 	.sdram_ras_n				(DRAM_RAS_N),        			  // ras_n
 // 	.sdram_we_n				(DRAM_WE_N),         			  // we_n 
	// //.custom_module_conduit_rdwr_cntl    	(SW[17]),
	// //.custom_module_conduit_n_action     	(KEY[1]),
	// //.custom_module_conduit_add_data_sel 	(SW[16]),
	// //.custom_module_conduit_rdwr_address 	(SW[15:0]),
 // 	.pcie_ip_refclk_export           	(PCIE_REFCLK_P),                      // pcie_ip_refclk.export
 // 	.pcie_ip_pcie_rstn_export        	(PCIE_PERST_N),             	  // pcie_ip_pcie_rstn.export
 // 	.pcie_ip_rx_in_rx_datain_0       	(PCIE_RX_P),                          // pcie_ip_rx_in.rx_datain_0
 // 	.pcie_ip_tx_out_tx_dataout_0     	(PCIE_TX_P)                           // pcie_ip_tx_out.tx_dataout_0
 // );

logic rgmii_125Mhz_clk;
logic rgmii_25Mhz_clk;
logic rgmii_2500hz_clk;
mii_pll	mii_pll_inst (
	.areset (),
	.inclk0 (CLOCK_50),
	.c0 (rgmii_125Mhz_clk),
	.c1 (rgmii_25Mhz_clk),
	.c2 (rgmii_2500hz_clk)
	);

// https://www.altera.com/content/dam/altera-www/global/en_US/pdfs/literature/ug/ug_ethernet.pdf

// amm_master_qsys_with_pcie u0 (
//     .clk_clk                                     (CLOCK_50),
//     .reset_reset_n                               (KEY[0]),
//     .pcie_ip_refclk_export                       (PCIE_REFCLK_P),
//     .pcie_ip_pcie_rstn_export                    (PCIE_PERST_N),
//     .pcie_ip_rx_in_rx_datain_0                   (PCIE_RX_P),
//     .pcie_ip_tx_out_tx_dataout_0                 (PCIE_TX_P),

//     .eth_tse_0_mac_misc_connection_ff_tx_crc_fwd (0), // If this signal is set to 1, the user application is expected to provide the CRC.
//     // these signals are potentially unused? these are FIFO status signals
//     .eth_tse_0_mac_misc_connection_ff_tx_septy   (),
//     .eth_tse_0_mac_misc_connection_tx_ff_uflow   (),
//     .eth_tse_0_mac_misc_connection_ff_tx_a_full  (),
//     .eth_tse_0_mac_misc_connection_ff_tx_a_empty (),
//     .eth_tse_0_mac_misc_connection_rx_err_stat   (),
//     .eth_tse_0_mac_misc_connection_rx_frm_type   (),
//     .eth_tse_0_mac_misc_connection_ff_rx_dsav    (),
//     .eth_tse_0_mac_misc_connection_ff_rx_a_full  (),
//     .eth_tse_0_mac_misc_connection_ff_rx_a_empty (),

//     .rgmii_rgmii_in                              (ENET_RX_DATA),
//     .rgmii_rgmii_out                             (ENET_TX_DATA),
//     .rgmii_rx_control                            (ENET_RX_EN),
//     .rgmii_tx_control                            (ENET_TX_EN),

//     // Figure 4-13, Pg 57 (4-27)
//     // note: I believe when eth_mode and ena_10 are 0, it will operate in 100 mode
//     .rgmii_status_set_10                         (0),
//     .rgmii_status_set_1000                       (0),
//     .rgmii_status_eth_mode                       (), // clock divider?
//     .rgmii_status_ena_10                         (0), // clock divider? note: this could be wrong

//     // what are the drivers for these clocks?
//     .tx_clk_clk                                  (),
//     .tx_rst_reset_n                              (),
//     .rx_clk_clk                                  (),
//     .rx_rst_reset_n                              ()
// );

amm_master_qsys_with_pcie u0 (
    .clk_clk                                     (CLOCK_50),
    .reset_reset_n                               (KEY[0]),
    .pcie_ip_refclk_export                       (PCIE_REFCLK_P),
    .pcie_ip_pcie_rstn_export                    (PCIE_PERST_N),
    .pcie_ip_rx_in_rx_datain_0                   (PCIE_RX_P),
    .pcie_ip_tx_out_tx_dataout_0                 (PCIE_TX_P),

    .mac_misc_ff_tx_crc_fwd                     (0), // If this signal is set to 1, the user application is expected to provide the CRC.
    // these signals are potentially unused? these are FIFO status signals
    .mac_misc_ff_tx_septy                       (),
    .mac_misc_tx_ff_uflow                       (),
    .mac_misc_ff_tx_a_full                      (),
    .mac_misc_ff_tx_a_empty                     (),
    .mac_misc_rx_err_stat                       (),
    .mac_misc_rx_frm_type                       (),
    .mac_misc_ff_rx_dsav                        (),
    .mac_misc_ff_rx_a_full                      (),
    .mac_misc_ff_rx_a_empty                     (),
    .mac_rx_clk_clk                             (),
    .mac_tx_clk_clk                             (),

    .rgmii_status_set_10                        (0),
    .rgmii_status_set_1000                      (0),
    .rgmii_status_eth_mode                      (), // clock divider?
    .rgmii_status_ena_10                        (0), // clock divider? note: this could be wrong

    // no rx_en?
    .mii_connection_mii_rx_d                    (ENET_RX_DATA),
    .mii_connection_mii_rx_dv                   (),
    .mii_connection_mii_rx_err                  (),
    .mii_connection_mii_tx_d                    (ENET_TX_DATA),
    .mii_connection_mii_tx_en                   (ENET_TX_EN),
    .mii_connection_mii_tx_err                  (),
    .mii_connection_mii_crs                     (),
    .mii_connection_mii_col                     (),

    // what are the drivers for these clocks?
    // .tx_clk_clk                                  (),
    // .tx_rst_reset_n                              (),
    // .rx_clk_clk                                  (),
    // .rx_rst_reset_n                              ()
);

// ethernetsniffer TOP_LEVEL (
//     .clk(),
//     .n_rst(),
//     .data_in(),
//     .eop(),
//     .empty(),
//     .error(),
//     .valid(),
//     .ready(),
//     .sop(),
//     .rdempty(),
//     .flagged_port(),
//     .flagged_ip(),
//     .flagged_mac(),
//     .flagged_string(),
//     .update_done(),
//     .addr_out(),
//     .write_enable(),
//     .addr_as(),
//     .rdreq(),
//     .data_out(),
//     .port_hits(),
//     .ip_hits(),
//     .mac_hits(),
//     .url_hits()
// );

 
 
 
//IB// SEG_HEX hex0(
//IB// 	   .iDIG(display_data[31:28]),         
//IB// 	   .oHEX_D(HEX7)
//IB//            );  
//IB// SEG_HEX hex1(                              
//IB//            .iDIG(display_data[27:24]),
//IB//            .oHEX_D(HEX6)
//IB//            );
//IB// SEG_HEX hex2(                           
//IB//            .iDIG(display_data[23:20]),
//IB//            .oHEX_D(HEX5)
//IB//            );
//IB// SEG_HEX hex3(                              
//IB//            .iDIG(display_data[19:16]),
//IB//            .oHEX_D(HEX4)
//IB//            );
//IB// SEG_HEX hex4(                               
//IB//            .iDIG(display_data[15:12]),
//IB//            .oHEX_D(HEX3)
//IB//            );
//IB// SEG_HEX hex5(                          
//IB//            .iDIG(display_data[11:8]), 
//IB//            .oHEX_D(HEX2)
//IB//            );
//IB// SEG_HEX hex6(                      
//IB//            .iDIG(display_data[7:4]),
//IB//            .oHEX_D(HEX1)
//IB//            );
//IB// SEG_HEX hex7(              
//IB//            .iDIG(display_data[3:0]) ,
//IB//            .oHEX_D(HEX0)
//IB//            );

endmodule 
