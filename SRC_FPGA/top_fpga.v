/*
    Authors : Mohamed Maged & Ali Elruby & Ali Khaled
*/
/*
    Terminal Configuration:
    - 8 bit data width
    - 2 stop bits
    - No parity bit
    - BAUD RATE as in the Top module
*/

module riscv_core_top#(
    parameter DATA_WIDTH = 64,
    parameter ADDR_WIDTH = 64,
    parameter CACHE_LINE_WIDTH = 256,
    parameter DWIDTH = 4'd8,
    parameter CLK_RATE  = 100000000, // board internal clock (def == 100MHz)
    parameter BAUD_RATE = 115200,
    parameter block_WIDTH = 8
)(
    // Global inputs
    input  wire i_riscv_core_clk,
    input  wire i_riscv_core_rst_n,
    input  wire i_riscv_core_external_interrupt_m,
    input  wire i_riscv_core_external_interrupt_s,
    output wire o_riscv_core_ack,
    ///uart
    output wire o_riscv_core_uart_tx,
    output wire o_riscv_core_uart_tx_busy
);

// UART
wire [DWIDTH-1:0] core_txdata;
wire              core_txvalid;
wire              ready_to_core;

//Data_Cache
wire [63:0] o_riscv_core_dcache_raddr_axi;
wire [63:0] o_riscv_core_dcache_wdata;
wire [63:0] o_riscv_core_dcache_waddr;
wire o_riscv_core_dcache_raddr_valid;
wire o_riscv_core_dcache_wvalid;
wire i_riscv_core_dcache_rready;
wire i_riscv_core_dcache_wresp;
wire [255:0] i_riscv_core_dcache_rdata;
wire [ 7 : 0] o_riscv_core_dcache_wstrb;

//INSTR_CACHE
wire [63:0] o_riscv_core_icache_raddr_axi;
wire o_riscv_core_icache_raddr_valid;
wire i_riscv_core_icache_rready;
wire [255:0] i_riscv_core_icache_rdata;

//Memory translator
wire [ADDR_WIDTH-1     : 0] o_mem_read_address;
wire                        o_mem_read_req;
wire                        i_mem_read_done;
wire [CACHE_LINE_WIDTH-1 : 0] i_cache_line;
         // Interface with WRITE CHANNEL //
wire                         i_mem_write_done;
wire                          o_mem_write_valid;
wire [     DATA_WIDTH-1 : 0]  o_mem_write_data;
wire [     ADDR_WIDTH-1 : 0]  o_mem_write_address;
wire [                7 : 0]  o_write_strobe;

riscv_core_top_2
u_riscv_core_top_2 
(
    // Global inputs
    .i_riscv_core_clk(i_riscv_core_clk)
    ,.i_riscv_core_rst_n(i_riscv_core_rst_n)
    ,.i_riscv_core_external_interrupt_m(i_riscv_core_external_interrupt_m)
    ,.i_riscv_core_external_interrupt_s(i_riscv_core_external_interrupt_s)
    ,.o_riscv_core_ack(o_riscv_core_ack)
    //Data_Cache
    ,.mem_read_address(o_riscv_core_dcache_raddr_axi)/////
    ,.o_mem_write_data(o_riscv_core_dcache_wdata)/////
    ,.o_mem_write_address(o_riscv_core_dcache_waddr)////
    ,.mem_read_req(o_riscv_core_dcache_raddr_valid)////
    ,.o_mem_write_valid(o_riscv_core_dcache_wvalid)/////
    ,.mem_read_done(i_riscv_core_dcache_rready)//////
    ,.i_mem_write_done(i_riscv_core_dcache_wresp)//////
    ,.i_block_from_axi_data_cache(i_riscv_core_dcache_rdata)//////
    ,.o_mem_write_strobe(o_riscv_core_dcache_wstrb)//////
  //INSTR_CACHE
    ,.o_addr_from_control_to_axi(o_riscv_core_icache_raddr_axi)/////
    ,.o_mem_req(o_riscv_core_icache_raddr_valid)/////
    ,.i_mem_done(i_riscv_core_icache_rready)/////
    ,.i_block_from_axi_i_cache(i_riscv_core_icache_rdata)/////
    ,.uart_ready(ready_to_core)
    ,.uart_out_data(core_txdata)
    ,.uart_valid(core_txvalid)
);

uart_ssh#(
    .block_WIDTH(block_WIDTH),
    .CLK_RATE(CLK_RATE),
    .BAUD_RATE(BAUD_RATE)
)                                                                                                           
u_uart_ssh                                                                                                                           
(                                                                                                               
    .clk(i_riscv_core_clk)                                                                                  
    ,.rst(i_riscv_core_rst_n)                                                                                                                                                              
    ,.tx_data(core_txdata)                                   
    ,.tx_valid(core_txvalid)                                    
    ,.tx_ready(ready_to_core)
    /*
     * AXI output
     */
    ,.rx_data()
    ,.rx_valid()
    ,.rx_ready(1'b1)
    /*
     * UART interface
     */
    ,.rxd(1'b1)
    ,.txd(o_riscv_core_uart_tx)
    /*
     * Status
     */
    ,.tx_busy(o_riscv_core_uart_tx_busy)
    ,.rx_busy()
    ,.rx_overrun_error()
    ,.rx_frame_error()
    /*
     * Configuration
     */
    //,.prescale(16'h0003)

);

mem_translator
u_mem_translator
(
    .i_clk(i_riscv_core_clk)
    // DATA CACHE PORT //
    ,.i_dcache_write_data(o_riscv_core_dcache_wdata)
    ,.i_dcache_write_address(o_riscv_core_dcache_waddr)
    ,.i_dcache_write_valid(o_riscv_core_dcache_wvalid)
    ,.i_dcache_write_strobe(o_riscv_core_dcache_wstrb)
    ,.i_dcache_read_req(o_riscv_core_dcache_raddr_valid)
    ,.i_dcache_read_address(o_riscv_core_dcache_raddr_axi)
    ,.o_dcache_cache_line(i_riscv_core_dcache_rdata)
    ,.o_dcache_read_done(i_riscv_core_dcache_rready)
    ,.o_dcache_write_done(i_riscv_core_dcache_wresp)
    // INST CACHE PORT //
    ,.i_icache_read_req(o_riscv_core_icache_raddr_valid)
    ,.i_icache_read_address(o_riscv_core_icache_raddr_axi)
    ,.o_icache_cache_line(i_riscv_core_icache_rdata)
    ,.o_icache_read_done(i_riscv_core_icache_rready)
    // MEMORY PORT //
    // Interface with READ CHANNEL //
    ,.o_mem_read_address(o_mem_read_address)
    ,.o_mem_read_req(o_mem_read_req)
    ,.i_mem_read_done(i_mem_read_done)
    ,.i_cache_line(i_cache_line)
    // Interface with WRITE CHANNEL //
    ,.i_mem_write_done(i_mem_write_done)
    ,.o_mem_write_valid(o_mem_write_valid)
    ,.o_mem_write_data(o_mem_write_data)
    ,.o_mem_write_address(o_mem_write_address)
    ,.o_write_strobe(o_write_strobe)
);

data_mem_top
u_main_mem_data
(
    .i_clk(i_riscv_core_clk)
    ,.i_rst_n(i_riscv_core_rst_n)
    // Interface with READ CHANNEL //
    ,.i_mem_read_address(o_mem_read_address)
    ,.i_mem_read_req(o_mem_read_req)
    ,.o_mem_read_done(i_mem_read_done)
    ,.o_cache_line(i_cache_line)
    // Interface with WRITE CHANNEL //
    ,.o_mem_write_done(i_mem_write_done)
    ,.i_mem_write_valid(o_mem_write_valid)
    ,.i_mem_write_data(o_mem_write_data)
    ,.i_mem_write_address(o_mem_write_address)
    ,.i_write_strobe(o_write_strobe)
);

/*
data_mem_top
u_instr_main_mem
(
    .i_clk(i_riscv_core_clk)
    ,.i_rst_n(i_riscv_core_rst_n)
    // Interface with READ CHANNEL //
    ,.i_mem_read_address(o_riscv_core_icache_raddr_axi)
    ,.i_mem_read_req(o_riscv_core_icache_raddr_valid)
    ,.o_mem_read_done(i_riscv_core_icache_rready)
    ,.o_cache_line(i_riscv_core_icache_rdata)
    // Interface with WRITE CHANNEL //
    ,.o_mem_write_done(o_mem_write_done_dummy)
    ,.i_mem_write_valid(i_mem_write_valid_dummy)
    ,.i_mem_write_data(i_mem_write_data_dummy)
    ,.i_mem_write_address(i_mem_write_address_dummy)
    ,.i_write_strobe(i_write_strobe_dummy)
);

assign i_mem_write_valid_dummy    = 1'b0 ;
assign i_mem_write_data_dummy     = 64'b0;
assign i_mem_write_address_dummy  = 64'b0;
assign i_write_strobe_dummy       = 8'b0 ;
*/

endmodule