module riscv_core_top
(
    // Global inputs
    input  wire i_riscv_core_clk,
    input  wire i_riscv_core_rst_n,
    input  wire i_riscv_core_external_interrupt_m,
    input  wire i_riscv_core_external_interrupt_s,
    output wire o_riscv_core_ack
);
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
    ,.mem_read_address(o_riscv_core_dcache_raddr_axi)
    ,.o_mem_write_data(o_riscv_core_dcache_wdata)
    ,.o_mem_write_address(o_riscv_core_dcache_waddr)
    ,.mem_read_req(o_riscv_core_dcache_raddr_valid)
    ,.o_mem_write_valid(o_riscv_core_dcache_wvalid)
    ,.mem_read_done(i_riscv_core_dcache_rready)
    ,.i_mem_write_done(i_riscv_core_dcache_wresp)
    ,.i_block_from_axi_data_cache(i_riscv_core_dcache_rdata)
    ,.o_mem_write_strobe(o_riscv_core_dcache_wstrb)
  //INSTR_CACHE
    ,.o_addr_from_control_to_axi(o_riscv_core_icache_raddr_axi)
    ,.o_mem_req(o_riscv_core_icache_raddr_valid)
    ,.i_mem_done(i_riscv_core_icache_rready)
    ,.i_block_from_axi_i_cache(i_riscv_core_icache_rdata)
);

data_mem_top
u_main_mem_data
(
    .i_clk(i_riscv_core_clk)
    ,.i_rst_n(i_riscv_core_rst_n)
    // Interface with READ CHANNEL //
    ,.i_mem_read_address(o_riscv_core_dcache_raddr_axi)
    ,.i_mem_read_req(o_riscv_core_dcache_raddr_valid)
    ,.o_mem_read_done(i_riscv_core_dcache_rready)
    ,.o_cache_line(i_riscv_core_dcache_rdata)
    // Interface with WRITE CHANNEL //
    ,.o_mem_write_done(i_riscv_core_dcache_wresp)
    ,.i_mem_write_valid(o_riscv_core_dcache_wvalid)
    ,.i_mem_write_data(o_riscv_core_dcache_wdata)
    ,.i_mem_write_address(o_riscv_core_dcache_waddr)
    ,.i_write_strobe(o_riscv_core_dcache_wstrb)
);

instr_main_mem
u_instr_main_mem
(
    .i_clk(i_riscv_core_clk)
    // Interface with READ CHANNEL //
    ,.i_mem_read_address(o_riscv_core_icache_raddr_axi)
    ,.i_mem_read_req(o_riscv_core_icache_raddr_valid)
    ,.o_mem_read_done(i_riscv_core_icache_rready)
    ,.o_cache_line(i_riscv_core_icache_rdata)
);


endmodule