`define TAG 63:12
`define INDEX 11:5
`define BLOCK_OFFSET 4:2
`define BYTE_OFFSET 1:0

module riscv_core_icache_top#(
    parameter BLOCK_OFFSET_WIDTH = 2,
    parameter INDEX_WIDTH        = 7,
    parameter TAG_WIDTH          = 20,
    parameter CORE_DATA_WIDTH    = 32,
    parameter ADDR_WIDTH         = 64,
    parameter AXI_DATA_WIDTH     = 256
) (
    // Interface with CORE//
    input logic                         i_clk,
    input logic                         i_rst_n,
    input logic [ADDR_WIDTH-1      : 0] i_addr_from_core ,
    output logic                        o_stall,
    output logic [ CORE_DATA_WIDTH-1  :  0  ]  o_data_to_core,

    // Interface with AXI Module //
    output logic [ADDR_WIDTH-1     : 0] o_addr_from_control_to_axi,
    output logic                        o_mem_req,
    input  logic                        i_mem_done,
    input  logic [AXI_DATA_WIDTH-1 : 0] i_block_from_axi
);
//      INTERNAL REGISTERS    //
logic                         control_to_mem_rd_en;
logic                         control_to_mem_wr_en;
logic                         control_to_mem_block_replace;
logic                         control_to_mem_offset;
//      BLOCK INSTANTIATION   //
riscv_core_icache_controller #(.TAG_WIDTH(TAG_WIDTH)) icache_controller (
    .i_clk(i_clk),
    .i_rst_n(i_rst_n),
    .i_addr_from_core (i_addr_from_core),
    .o_stall(o_stall),
    .o_rd_en(control_to_mem_rd_en),
    .o_wr_en(control_to_mem_wr_en),
    .o_block_replace(control_to_mem_block_replace),
    .o_addr_from_control_to_axi(o_addr_from_control_to_axi),
    .o_mem_req(o_mem_req),
    .i_mem_done(i_mem_done),
    .o_offset(control_to_mem_offset));
riscv_core_icache_memory #(.TAG_WIDTH(TAG_WIDTH)) icache_memory (
    .i_clk(i_clk),
    .i_rst_n(i_rst_n),
    .i_addr_from_core (i_addr_from_core),
    .o_data_to_core(o_data_to_core),
    .i_block_from_axi(i_block_from_axi),
    .i_rd_en(control_to_mem_rd_en),
    .i_wr_en(control_to_mem_wr_en),
    .i_block_replace(control_to_mem_block_replace),
    .i_offset(control_to_mem_offset));
endmodule