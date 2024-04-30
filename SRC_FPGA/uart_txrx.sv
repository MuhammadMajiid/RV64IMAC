/*
    Author : Mohamed Maged
*/
/*
    Terminal Configuration:
    - 8 bit data width
    - 2 stop bits
    - No parity bit
    - BAUD RATE as in the Top module
*/
module uart_txrx #
(
    parameter DWIDTH = 4'd8,
    parameter CLK_RATE  = 100000000, // board internal clock (def == 100MHz)
    parameter BAUD_RATE = 115200
) 
(
    // Global
    input logic               uart_clk,
    input logic               uart_rst_n,

    // Core-to-UART
     input  logic [DWIDTH-1:0] core_txdata,
     input  logic              core_txvalid,
     output logic              ready_to_core,

    // UART-to-Core
    // output logic [DWIDTH-1:0] core_rxdata,
    // output logic              core_rxvalid,
    // input  logic              ready_from_core,

    // // UART-Rx Interface
    // input  logic              i_uart_rx,
    // output logic              o_uart_rx_busy,

    // UART-Tx Interface
    output logic              o_uart_tx,
    output logic              o_uart_tx_busy
);

logic tx_clk;
logic rx_clk;
//logic core_txvalid, ready_to_core;
//logic [7:0] core_txdata;


baud_gen #(
    .CLK_RATE(CLK_RATE)
    ,.BAUD_RATE(BAUD_RATE)
) bgen (
    .i_clk(uart_clk)
    ,.i_rst_n(uart_rst_n)
    ,.o_tx_clk(tx_clk)
    ,.o_rx_clk(rx_clk)
);

//rom hello (
//    .i_clk(tx_clk)
//    ,.i_rst_n(uart_rst_n)
//    ,.i_en(ready_to_core)
//    ,.o_valid(core_txvalid)
//    ,.o_data(core_txdata)
//);

uart_tx #(
    .DWIDTH (DWIDTH)
) tx (
    .uart_clk      (tx_clk)
    ,.uart_rst_n   (uart_rst_n)
    ,.core_data    (core_txdata)
    ,.core_valid   (core_txvalid)
    ,.ready_to_core(ready_to_core)
    ,.uart_txd     (o_uart_tx)
    ,.uart_busy    (o_uart_tx_busy)
);

// uart_rx #(
//     .DWIDTH (DWIDTH)
// ) rx (
//     .uart_clk        (rx_clk)
//     ,.uart_rst_n     (uart_rst_n)
//     ,.core_data      (core_rxdata)
//     ,.core_valid     (core_rxvalid)
//     ,.ready_from_core(ready_from_core)
//     ,.uart_rxd       (o_uart_tx)
//     ,.uart_busy      (o_uart_rx_busy)
// );
    
endmodule