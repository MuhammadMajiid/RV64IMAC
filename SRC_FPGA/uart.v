module uart_ssh #                                                                                                           
(                                                                                                                       
    parameter block_WIDTH = 8,
    parameter CLK_RATE  = 100000000, // board internal clock (def == 100MHz)
    parameter BAUD_RATE = 115200                                                                                              
)                                                                                                                           
(                                                                                                               
    input  wire                   clk,                                                                                  
    input  wire                   rst,                                                                          

    /*                                                                                                  
     * AXI input                                                                                        
     */                                                                                         
    input  wire [block_WIDTH-1:0]  tx_data,                                         
    input  wire                   tx_valid,                                    
    output wire                   tx_ready,

    /*
     * AXI output
     */
    output wire [block_WIDTH-1:0]  rx_data,
    output wire                   rx_valid,
    input  wire                   rx_ready,

    /*
     * UART interface
     */
    input  wire                   rxd,
    output wire                   txd,

    /*
     * Status
     */
    output wire                   tx_busy,
    output wire                   rx_busy,
    output wire                   rx_overrun_error,
    output wire                   rx_frame_error

    /*
     * Configuration
     */
    //input  wire [15:0]            prescale

);
localparam prescale = CLK_RATE / BAUD_RATE;

uart_tx #(
    .block_WIDTH(block_WIDTH)
)
uart_tx_inst (
    .clk(clk),
    .rst(rst),
    // axi input
    .s_axis_tdata(tx_data),
    .s_axis_tvalid(tx_valid),
    .s_axis_tready(tx_ready),
    // output
    .txd(txd),
    // status
    .busy(tx_busy)
    // configuration
    //.prescale(prescale)
);
/*
uart_rx #(
    .block_WIDTH(block_WIDTH)
)
uart_rx_inst (
    .clk(clk),
    .rst(rst),
    // axi output
    .m_axis_tdata(rx_data),
    .m_axis_tvalid(rx_valid),
    .m_axis_tready(rx_ready),
    // input
    .rxd(rxd),
    // status
    .busy(rx_busy),
    .overrun_error(rx_overrun_error),
    .frame_error(rx_frame_error),
    // configuration
    .prescale(prescale)
);
*/
endmodule