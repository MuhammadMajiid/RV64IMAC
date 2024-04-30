`define TAG 63:12
`define INDEX 11:5
`define BLOCK_OFFSET 4:2
`define BYTE_OFFSET 1:0

module riscv_core_icache_memory #(
    parameter BLOCK_OFFSET_WIDTH = 3,
    parameter INDEX_WIDTH        = 7,
    parameter TAG_WIDTH          = 52,
    parameter CORE_DATA_WIDTH    = 32,
    parameter ADDR_WIDTH         = 64,
    parameter AXI_DATA_WIDTH     = 256
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
input logic                                i_block_replace,
input logic                                i_offset //indicate which block index to write in
);
//             LOCAL PARAMETERS              //
localparam CACHE_DEPTH = 2**INDEX_WIDTH ;
localparam BLOCK_SIZE  = 2**BLOCK_OFFSET_WIDTH ;
logic [ADDR_WIDTH-1      : 0] i_addr_from_core_1 , i_addr_from_core_2 , i_addr_from_core_3; //internal adresses
//      INTERNAL REGISTERS AND MEMORIES      //
logic [BLOCK_SIZE-1:0][3:0][7:0] INSTR_MEM [0:CACHE_DEPTH-1];
//          assign internal addresses   //
assign i_addr_from_core_1 = i_addr_from_core + 1'b1;
assign i_addr_from_core_2 = i_addr_from_core + 2'b10;
assign i_addr_from_core_3 = i_addr_from_core + 2'b11;
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
        if (i_wr_en && i_block_replace) begin
            if(!i_offset)
                INSTR_MEM [  i_addr_from_core[`INDEX]        ] <= i_block_from_axi;
            else
                INSTR_MEM [  i_addr_from_core_2[`INDEX]      ] <= i_block_from_axi;
        end
    end    
end
//          READ FROM MEMORY BLOCK           //
always_comb begin : READ_MEMORY_BLOCK
    o_data_to_core = 'b0;
    if (i_rd_en) begin
        // READ WORD
        o_data_to_core =   {INSTR_MEM [ i_addr_from_core_3[`INDEX] ][ i_addr_from_core_3[`BLOCK_OFFSET] ][ i_addr_from_core_3[`BYTE_OFFSET]] ,
                            INSTR_MEM [ i_addr_from_core_2[`INDEX] ][ i_addr_from_core_2[`BLOCK_OFFSET] ][ i_addr_from_core_2[`BYTE_OFFSET]] , 
                            INSTR_MEM [ i_addr_from_core_1[`INDEX] ][ i_addr_from_core_1[`BLOCK_OFFSET] ][ i_addr_from_core_1[`BYTE_OFFSET]] ,
                            INSTR_MEM [ i_addr_from_core  [`INDEX] ][ i_addr_from_core  [`BLOCK_OFFSET] ][ i_addr_from_core  [`BYTE_OFFSET]]};
    end
end
endmodule