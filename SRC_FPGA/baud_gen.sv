/*
    Author : Mohamed Maged
*/
module baud_gen
#(
    parameter CLK_RATE  = 100000000, // board internal clock (def == 100MHz)
    parameter BAUD_RATE = 115200
)
(
    input  logic i_rst_n,
    input  logic i_clk,    // board clock
    output logic o_rx_clk, // baud rate for rx
    output logic o_tx_clk  // baud rate for tx
);

localparam RX_MAX_RATE = CLK_RATE / (2 * BAUD_RATE * 16); // 16x oversample
localparam TX_MAX_RATE = CLK_RATE / (2 * BAUD_RATE);
localparam RX_WIDTH = $clog2(RX_MAX_RATE);
localparam TX_WIDTH = $clog2(TX_MAX_RATE);

logic [RX_WIDTH - 1:0] rx_ticks;
logic [TX_WIDTH - 1:0] tx_ticks;


always @(posedge i_clk, negedge i_rst_n) begin
    if (!i_rst_n) begin
        o_rx_clk = 1'b0;
        o_tx_clk = 1'b0;
        rx_ticks <= 0;
        tx_ticks <= 0;
    end
    else begin
        /* TX CLOCK */
        if (tx_ticks == TX_MAX_RATE) begin
            tx_ticks  <= 0;
            o_tx_clk  <= ~o_tx_clk;
        end else begin
            tx_ticks <= tx_ticks + 1'b1;
        end
        /* RX CLOCK */
        if (rx_ticks == RX_MAX_RATE) begin
            rx_ticks <= 0;
            o_rx_clk <= ~o_rx_clk;
        end else begin
            rx_ticks <= rx_ticks + 1'b1;
        end
    end
end

endmodule