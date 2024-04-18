/*
    S_AXI4-Stream UART-Tx Interface
    ______________
    |PARTYP| Type |
    |-------------|
    |2'b00 | NONE |
    |-------------|
    |2'b01 | ODD  |            
    |-------------|
    |2'b00 | EVEN |
    |-------------|
    |2'b01 | NONE |
    |-------------|
*/

`timescale 1ns/1ps
module uart_txrx #
(
    parameter DWIDTH = 4'd8,
    parameter PARTYP = 2'b01 
) 
(
    // Global
    input wire               uart_clk,
    input wire               uart_rst_n,

    // AXI-stream Intrface Rx
    input  wire [DWIDTH-1:0] s_axis_tdata,
    input  wire              s_axis_tvalid,
    input  wire              s_axis_tlast,

    // AXI-stream Intrface Tx
    output wire [DWIDTH-1:0] m_axis_tdata,
    output wire              m_axis_tvalid,
    output wire              m_axis_tlast,

    // UART-Rx Interface
    input  wire              i_uart_rx,
    output wire              uart_rx_busy,
    output wire              uart_parity_err,
    output wire              uart_frame_err,

    // UART-Tx Interface
    output wire              o_uart_tx,
    output wire              uart_tx_busy
);

wire s_axis_tready_w;
wire tx_rx_w;

uart_tx #(
    .DWIDTH (DWIDTH)
    ,.PARTYP(PARTYP)
) tx (
    .uart_clk      (uart_clk)
    ,.uart_rst_n   (uart_rst_n)
    ,.s_axis_tdata (s_axis_tdata)
    ,.s_axis_tvalid(s_axis_tvalid)
    ,.s_axis_tready(s_axis_tready_w)
    ,.s_axis_tlast (s_axis_tlast)
    ,.uart_txd     (o_uart_tx)
    ,.uart_busy    (uart_tx_busy)
);

uart_rx #(
    .DWIDTH (DWIDTH)
    ,.PARTYP(PARTYP)
) rx (
    .uart_clk        (uart_clk)
    ,.uart_rst_n     (uart_rst_n)
    ,.m_axis_tdata   (m_axis_tdata)
    ,.m_axis_tvalid  (m_axis_tvalid)
    ,.m_axis_tready  (s_axis_tready_w)
    ,.m_axis_tlast   (m_axis_tlast)
    ,.uart_rxd       (i_uart_rx)
    ,.uart_busy      (uart_rx_busy)
    ,.uart_parity_err(uart_parity_err)
    ,.uart_frame_err (uart_frame_err)
);
    
endmodule