`define TAG 63:12
`define INDEX 11:5
`define BLOCK_OFFSET 4:3
`define BYTE_OFFSET 2:0

module riscv_core_icache_memory #(
    parameter BLOCK_OFFSET      = 2,
    parameter INDEX_WIDTH       = 7,
    parameter TAG_WIDTH         = 52,
    parameter CORE_DATA_WIDTH   = 32,
    parameter ADDR_WIDTH        = 64,
    parameter AXI_DATA_WIDTH    = 256
) (
// Interface with CORE//
input logic                                i_clk,
input logic                                i_rst_n,
input logic [ ADDR_WIDTH-1        :  0  ]  i_addr_from_core,
output logic [ CORE_DATA_WIDTH-1  :  0  ]  o_data_to_core,
// Interface with AXI Module //
input logic [AXI_DATA_WIDTH-1     : 0  ]   i_block_from_axi,
// Interface with CACHE Controller //
input logic                                i_rd_en,
input logic                                i_wr_en,
input logic                                i_block_replace
);
//             LOCAL PARAMETERS              //
localparam CACHE_DEPTH = $pow(2,INDEX_WIDTH) ;
localparam BLOCK_SIZE  = $pow(2,BLOCK_OFFSET) ;
//      INTERNAL REGISTERS AND MEMORIES      //
logic [BLOCK_SIZE-1:0][7:0][7:0] INSTR_MEM [CACHE_DEPTH];
//        WRITE AND REPLACEMENT BLOCK        //
always @( posedge i_clk , negedge i_rst_n ) begin : FLUSH_WRITE_REPLACEMENT_BLOCK
    if (!i_rst_n) begin
        // Clear ALL Entries //
            for ( int i = 0 ; i < CACHE_DEPTH  ; i=i+1 ) begin
                INSTR_MEM[i] <= 'b0;
            end
    end
    else begin
        // BLOCK REPLACEMENT // 
        if (i_wr_en && i_block_replace)
        begin
            INSTR_MEM [  i_addr_from_core[`INDEX]      ] <= i_block_from_axi;
        end
    end    
end
//          READ FROM MEMORY BLOCK           //
always_comb begin : READ_MEMORY_BLOCK
    o_data_to_core = 'b0;
    if (i_rd_en) begin
        // READ WORD
        o_data_to_core =   {INSTR_MEM [ i_addr_from_core[`INDEX] ][ i_addr_from_core[`BLOCK_OFFSET] ][ i_addr_from_core[`BYTE_OFFSET] + 3 ] ,
                            INSTR_MEM [ i_addr_from_core[`INDEX] ][ i_addr_from_core[`BLOCK_OFFSET] ][ i_addr_from_core[`BYTE_OFFSET] + 2 ] , 
                            INSTR_MEM [ i_addr_from_core[`INDEX] ][ i_addr_from_core[`BLOCK_OFFSET] ][ i_addr_from_core[`BYTE_OFFSET] + 1 ] ,
                            INSTR_MEM [ i_addr_from_core[`INDEX] ][ i_addr_from_core[`BLOCK_OFFSET] ][ i_addr_from_core[`BYTE_OFFSET]    ]};
    end
end
endmodule