`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   21:50:49 10/09/2013
// Design Name:   ftdiController
// Module Name:   C:/Documents and Settings/Administrator/Desktop/helloworld/ftdi_test.v
// Project Name:  helloworld
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: ftdiController
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module ftdi_testbench;

    // Include functions builtins redefinition for which XST is missing support.
    `include "builtins_redefined.v"
	// Inputs
	reg sim_clk;
	reg in_reset_n;

	// Outputs
    reg rx_enabled;
    wire [7:0]  data_rx;
    wire [7:0] data_tx;
    wire [7:0] io_ftdi_data;
    wire rx_req;
    reg  rx_ack;
    reg  tx_req;
    wire tx_ack;

///////////////////////////////////////////////////////////////////
    // FTDI Wires for logic conversion to FTDI modules.
    wire in_ftdi_txe_p;
    wire in_ftdi_rxf_p;
    wire in_reset_p;
    wire out_ftdi_wr_p;
    wire out_ftdi_rd_p;

    //FTDI Wires conversion logic.
    assign in_ftdi_txe_p = !in_ftdi_txe_n;
    assign in_ftdi_rxf_p = !in_ftdi_rxf_n;
    assign in_reset_p    = !in_reset_n;

    assign out_ftdi_wr_n = !out_ftdi_wr_p;
    assign out_ftdi_rd_n = !out_ftdi_rd_p;
    
	// Instantiate the Implementation Under Test (IUT)
    ftdiController iut (.in_clk(sim_clk),
                      .in_rst(in_reset_p),
                      .in_ftdi_txe(in_ftdi_txe_p), 
                      .in_ftdi_rxf(in_ftdi_rxf_p),
                      .io_ftdi_data(io_ftdi_data), 
                      .out_ftdi_wr(out_ftdi_wr_p), 
                      .out_ftdi_rd(out_ftdi_rd_p),
                      .in_rx_en(rx_enabled),
                      .in_tx_hsk_req(tx_req),
                      .out_tx_hsk_ack(tx_ack),
                      .in_tx_data(data_tx),
                      .out_rx_data(data_rx),
                      .out_rx_hsk_req(rx_req),
                      .in_rx_hsk_ack(rx_ack));

///////////////////////////////////////////////////////////////////
    localparam FT2232H_BUFFER_SIZE = 128;
    localparam BUFFERS_WIDTH = _clog2(FT2232H_BUFFER_SIZE);

    reg [(FT2232H_BUFFER_SIZE * 8) - 1 : 0]  lt_ft2232h_usb_tx_data;
    wire [(FT2232H_BUFFER_SIZE * 8) - 1 : 0] lt_ft2232h_usb_rx_data;
    reg [BUFFERS_WIDTH - 1 : 0] lt_ft2232h_usb_tx_size;
    reg [BUFFERS_WIDTH - 1 : 0] lt_ft2232h_usb_rx_size;
    reg lt_ft2232h_usb_tx_start;
    reg lt_ft2232h_usb_rx_start;
    wire lt_ft2232h_usb_rx_done;

    wire [BUFFERS_WIDTH - 1 : 0] txbuffer_addr_a;
    reg  [BUFFERS_WIDTH - 1 : 0] txbuffer_addr_b;
    wire [7 : 0] txbuffer_din_a;
    reg  [7 : 0] txbuffer_din_b;
    wire [7 : 0] txbuffer_dout_a;
    wire [7 : 0] txbuffer_dout_b;
    wire txbuffer_wr_a;
    reg  txbuffer_wr_b;
    
    wire [BUFFERS_WIDTH - 1 : 0] rxbuffer_addr_a;
    wire [BUFFERS_WIDTH - 1 : 0] rxbuffer_addr_b;
    wire [7 : 0] rxbuffer_din_a;
    wire [7 : 0] rxbuffer_din_b;
    wire [7 : 0] rxbuffer_dout_a;
    wire [7 : 0] rxbuffer_dout_b;
    wire rxbuffer_wr_a;
    wire rxbuffer_wr_b;
    
    /* FT2232H: lower tester */
    ft2232h_device #(.BUFFERS_WIDTH(BUFFERS_WIDTH))
            lt_ft2232h (
                 .in_clk (sim_clk),
                 .in_rd_n (out_ftdi_rd_n),
                 .in_wr_n (out_ftdi_wr_n),
                 .out_txe_n (in_ftdi_txe_n),
                 .out_rxf_n (in_ftdi_rxf_n),
                 .io_data   (io_ftdi_data),
                 .usb_tx_size (lt_ft2232h_usb_tx_size),
                 .usb_txbuffer_addr(txbuffer_addr_a),
                 .usb_txbuffer_data(txbuffer_dout_a),
                 .usb_rx_size (lt_ft2232h_usb_rx_size),
                 .usb_rxbuffer_addr(rxbuffer_addr_a),
                 .usb_rxbuffer_data(rxbuffer_din_a),
                 .usb_rxbuffer_wr(rxbuffer_wr_a),
                 .usb_tx_start (lt_ft2232h_usb_tx_start),
                 .usb_rx_start (lt_ft2232h_usb_rx_start),
                 .usb_rx_done (lt_ft2232h_usb_rx_done));

    /* TX and RX BUFFERS */
    assign txbuffer_wr_a = 0;
    assign txbuffer_din_a = 0;
    ram_dualport #(.RAM_ADDR_WIDTH(BUFFERS_WIDTH),
                   .RAM_DATA_WIDTH(8))
                 txbuffer_ram (.in_clk(sim_clk),
                              .in_addr_a(txbuffer_addr_a),
                              .in_addr_b(txbuffer_addr_b),
                              .out_data_a(txbuffer_dout_a),
                              .out_data_b(txbuffer_dout_b),
                              .in_data_a(txbuffer_din_a),
                              .in_data_b(txbuffer_din_b),
                              .in_wr_a  (txbuffer_wr_a),
                              .in_wr_b  (txbuffer_wr_b));
    
    assign rxbuffer_wr_b = 0;
    assign rxbuffer_din_b = 0;
    ram_dualport #(.RAM_ADDR_WIDTH(BUFFERS_WIDTH),
                   .RAM_DATA_WIDTH(8))
                 rxbuffer_ram (.in_clk(sim_clk),
                              .in_addr_a(rxbuffer_addr_a),
                              .in_addr_b(rxbuffer_addr_b),
                              .out_data_a(rxbuffer_dout_a),
                              .out_data_b(rxbuffer_dout_b),
                              .in_data_a(rxbuffer_din_a),
                              .in_data_b(rxbuffer_din_b),
                              .in_wr_a  (rxbuffer_wr_a),
                              .in_wr_b  (rxbuffer_wr_b));
///////////////////////////////////////////////////////////////////
	initial begin
		// Initialize Inputs
		#0
		sim_clk = 0;
		in_reset_n = 1;

		#10
		in_reset_n = 0;
		
		#50
		in_reset_n = 1;
       
        #50
        Iut_Test_Seq();

        // Wait 100 ns for global reset to finish
		#10000;
	end

    //66MHz
	always #7.5 sim_clk = !sim_clk; 
   

    task Iut_Test_Seq;
    begin

        lt_ft2232h_usb_tx_size = 4;
        lt_ft2232h_usb_rx_size = 4;

        txbuffer_addr_b = 'h00;
        
        @ (posedge sim_clk)
        wait (sim_clk == 0);
        //Fill txbuffer with data.
        txbuffer_din_b  = 'h00;
        txbuffer_wr_b   = 1;
        // data will be written at next positive edge.

        @ (posedge sim_clk)
        wait (sim_clk == 0);
        txbuffer_addr_b = txbuffer_addr_b + 1;
        //Fill txbuffer with data.
        txbuffer_din_b  = 'h01; 
        // data will be written at next positive edge.

        @ (posedge sim_clk)
        wait (sim_clk == 0);
        txbuffer_addr_b = txbuffer_addr_b + 1;
        //Fill txbuffer with data.
        txbuffer_din_b  = 'h02; 
        // data will be written at next positive edge.

        @ (posedge sim_clk)
        wait (sim_clk == 0);
        txbuffer_addr_b = txbuffer_addr_b + 1;
        //Fill txbuffer with data.
        txbuffer_din_b  = 'h03; 
        // data will be written at next positive edge.

        @ (posedge sim_clk)
        wait (sim_clk == 0);
        txbuffer_wr_b   = 0;

        lt_ft2232h_usb_tx_start = 1;
        #1
        lt_ft2232h_usb_rx_start = 1;
        lt_ft2232h_usb_tx_start = 0;
        #1
        lt_ft2232h_usb_rx_start = 0;
        wait(lt_ft2232h_usb_rx_done);
    end
    endtask

endmodule


/////////////////////////////////////////////////////////////////////////////////////////////
//
module ft2232h_device #(parameter BUFFERS_WIDTH = 7)
                     (input in_clk,
                      input in_rd_n,
                      input in_wr_n,
                      output reg out_txe_n,
                      output reg out_rxf_n,
                      inout  [7 : 0] io_data,
                      input  [BUFFERS_WIDTH - 1 : 0]     usb_tx_size,
                      output reg [BUFFERS_WIDTH - 1 : 0] usb_txbuffer_addr,
                      input      [7:0] usb_txbuffer_data,
                      input  [BUFFERS_WIDTH - 1 : 0] usb_rx_size,
                      output reg [BUFFERS_WIDTH - 1 : 0] usb_rxbuffer_addr,
                      output [7:0] usb_rxbuffer_data,
                      output reg usb_rxbuffer_wr,
                      input  usb_tx_start,
                      input  usb_rx_start,
                      output reg  usb_rx_done);

    wire [7:0] in_data;
    wire [7:0] out_data;
    reg        io_out_enable;
    reg [15:0] rcvd_data;

    assign in_data   = io_data;
    assign io_data   = io_out_enable ? out_data : 8'bz;

    reg usb_tx_in_progress;
    reg usb_rx_in_progress;

    reg [BUFFERS_WIDTH - 1 : 0] usb_tx_counter;
    reg [BUFFERS_WIDTH - 1 : 0] usb_rx_counter;

    // RX char
    assign usb_rxbuffer_data = in_data;
    assign out_data = usb_txbuffer_data;

    // HERE we are emulating the FT2332H!
	always 
    begin : usb_to_fpga_ctrl
        // Set io to input
        io_out_enable = 0;
        
        //Disable USB -> FPGA
        out_rxf_n         = 1;

        usb_tx_in_progress = 0;
        
        wait (usb_tx_start);
        usb_tx_in_progress = 0;

        /* Make it half-duplex */
        wait (!usb_rx_in_progress)
        begin
            usb_tx_in_progress = 1;
            
            // So we dont tx twice.
            wait(usb_tx_start == 0);
            //Enable USB -> FPGA
            out_rxf_n         = 0;
           
            usb_txbuffer_addr = 'h0;
            
            for (usb_tx_counter = 0; 
                 usb_tx_counter < usb_tx_size; 
                 usb_tx_counter = usb_tx_counter + 1)
            begin
                // TX char
                @(negedge in_rd_n)
                begin
                    io_out_enable = 1;
                end
                @(posedge in_rd_n)  io_out_enable = 0;
                
                wait (in_clk == 0);
                usb_txbuffer_addr = usb_txbuffer_addr + 1;
            end
        end
	end

    always 
    begin : fpga_to_usb_ctrl

        // Set io to input
		io_out_enable = 0;

        // Disable FPGA -> USB 
        out_txe_n         = 1;
       
        usb_rx_in_progress = 0;
        
        wait(usb_rx_start);
        usb_rx_done = 0;

        usb_rxbuffer_addr = 'h0;
        usb_rxbuffer_wr   = 'h0;

        /* Make it half-duplex */
        wait (!usb_tx_in_progress)
        begin
            usb_rx_in_progress = 1;

            // Enable FPGA -> USB 
            out_txe_n         = 0;

            for (usb_rx_counter = 0; 
                 usb_rx_counter < usb_rx_size; 
                 usb_rx_counter = usb_rx_counter + 1)
            begin
                @ (negedge in_wr_n)
                wait (in_clk == 0);
                usb_rxbuffer_wr = 1;

                @ (posedge in_clk)
                wait (in_clk == 0);
                usb_rxbuffer_wr = 0;
                usb_rxbuffer_addr = usb_rxbuffer_addr + 1;
            end

            usb_rx_done = 1;
        end
    end
endmodule


