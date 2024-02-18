`define TAG 63:12
`define INDEX 11:5
`define BLOCK_OFFSET 4:3
`define BYTE_OFFSET 2:0


module riscv_core_dcache_top#(
    parameter BLOCK_OFFSET      = 2,
    parameter INDEX_WIDTH       = 7,
    parameter TAG_WIDTH         = 52,
    parameter CORE_DATA_WIDTH   = 64,
    parameter ADDR_WIDTH        = 64,
    parameter AXI_DATA_WIDTH    = 256,
    parameter FIFO_ENTRY_WIDTH  = 128
) (


    // Interface with CORE//
  
    input logic                         i_clk,
    input logic                         i_rst_n,
    input logic [CORE_DATA_WIDTH-1 : 0] i_data_from_core ,
    input logic [ADDR_WIDTH-1      : 0] i_addr_from_core ,
    input logic                         i_read,
    input logic                         i_write,
    input logic           [  1 :  0  ]  i_size,
    output logic                        o_stall,
    output logic [ CORE_DATA_WIDTH-1  :  0  ]  o_data_to_core,




    // Interface with AXI Module //

    output logic [ADDR_WIDTH-1     : 0] o_addr_from_control_to_axi,
    output logic                        o_mem_req,
    input  logic                        i_mem_done,
    input  logic [AXI_DATA_WIDTH-1 : 0] i_block_from_axi,
    
    // Interface with FIFO      //

    input logic                           i_fifo_full,
    output logic                          o_fifo_push,
    output logic [FIFO_ENTRY_WIDTH-1 : 0] o_fifo_entry




);

////////////////////////////////
//      INTERNAL REGISTERS    //
////////////////////////////////

logic                         control_to_mem_rd_en;
logic                         control_to_mem_wr_en;
logic                         control_to_mem_block_replace;



////////////////////////////////
//      BLOCK INSTANTIATION   //
////////////////////////////////

riscv_core_dcache_controller dcache_controller (
    .i_clk(i_clk),
    .i_rst_n(i_rst_n),
    .i_data_from_core (i_data_from_core),
    .i_addr_from_core (i_addr_from_core),
    .i_read(i_read),
    .i_write(i_write),
    .o_stall(o_stall),
    .o_rd_en(control_to_mem_rd_en),
    .o_wr_en(control_to_mem_wr_en),
    .o_block_replace(control_to_mem_block_replace),
    .o_addr_from_control_to_axi(o_addr_from_control_to_axi),
    .o_mem_req(o_mem_req),
    .i_mem_done(i_mem_done),
    .i_fifo_full(i_fifo_full),
    .o_fifo_push(o_fifo_push),
    .o_fifo_entry(o_fifo_entry) );
    
    
riscv_core_dcache_memory dcache_memory (
    .i_clk(i_clk),
    .i_rst_n(i_rst_n),
    .i_data_from_core (i_data_from_core),
    .i_addr_from_core (i_addr_from_core),
    .i_size(i_size),
    .o_data_to_core(o_data_to_core),
    .i_block_from_axi(i_block_from_axi),
    .i_rd_en(control_to_mem_rd_en),
    .i_wr_en(control_to_mem_wr_en),
    .i_block_replace(control_to_mem_block_replace) );


endmodule