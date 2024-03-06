`define TAG 63:12
`define INDEX 11:5
`define BLOCK_OFFSET 4:3
`define BYTE_OFFSET 2:0


module riscv_core_dcache_memory #(
    parameter BLOCK_OFFSET      = 2,
    parameter INDEX_WIDTH       = 7,
    parameter TAG_WIDTH         = 52,
    parameter CORE_DATA_WIDTH   = 64,
    parameter ADDR_WIDTH        = 64,
    parameter AXI_DATA_WIDTH    = 256,
    parameter FIFO_ENTRY_WIDTH  = 128
) (


// Interface with CORE//
input logic                                i_clk,
input logic                                i_rst_n,
input logic [ ADDR_WIDTH-1        :  0  ]  i_addr_from_core,
input logic [ CORE_DATA_WIDTH-1   :  0  ]  i_data_from_core,
input logic                  [  1 :  0  ]  i_size,
input logic [ CORE_DATA_WIDTH-1   :  0  ]  i_amo_alu_result,
output logic [ CORE_DATA_WIDTH-1  :  0  ]  o_data_to_core,



// Interface with AXI Module //

input logic [AXI_DATA_WIDTH-1     : 0  ]   i_block_from_axi,


// Interface with CACHE Controller //

input logic                                i_rd_en,
input logic                                i_wr_en,
input logic                                i_amo_wr,
input logic                                i_block_replace
);




///////////////////////////////////////////////
//             LOCAL PARAMETERS              //
///////////////////////////////////////////////

localparam CACHE_DEPTH = 2**INDEX_WIDTH ;
localparam BLOCK_SIZE  = 2**BLOCK_OFFSET ;

///////////////////////////////////////////////
//      INTERNAL REGISTERS AND MEMORIES      //
///////////////////////////////////////////////

logic [BLOCK_SIZE-1:0][7:0][7:0] DATA_MEM [0: CACHE_DEPTH-1];


///////////////////////////////////////////////
//        WRITE AND REPLACEMENT BLOCK        //
///////////////////////////////////////////////

always_ff @( posedge i_clk , negedge i_rst_n ) begin : FLUSH_WRITE_REPLACEMENT_BLOCK

if (!i_rst_n) begin
    // Clear ALL Entries //


        for ( int i = 0 ; i < CACHE_DEPTH  ; i=i+1 ) begin
             DATA_MEM[i] <= 'b0;
        end
end

else begin
    // BLOCK REPLACEMENT // 

    if (i_wr_en && i_block_replace)
    begin
        DATA_MEM [  i_addr_from_core[`INDEX]      ] <= i_block_from_axi;
    end

    // WRITE ON MEMORY // 


    else if (i_wr_en && !i_block_replace)
    begin
        if (i_amo_wr) begin

            case (i_size)
         // WRITE WORD
         2'b10   :{DATA_MEM [ i_addr_from_core[`INDEX] ][ i_addr_from_core[`BLOCK_OFFSET] ][ i_addr_from_core[`BYTE_OFFSET] + 3 ],
                   DATA_MEM [ i_addr_from_core[`INDEX] ][ i_addr_from_core[`BLOCK_OFFSET] ][ i_addr_from_core[`BYTE_OFFSET] + 2 ], 
                   DATA_MEM [ i_addr_from_core[`INDEX] ][ i_addr_from_core[`BLOCK_OFFSET] ][ i_addr_from_core[`BYTE_OFFSET] + 1 ],
                   DATA_MEM [ i_addr_from_core[`INDEX] ][ i_addr_from_core[`BLOCK_OFFSET] ][ i_addr_from_core[`BYTE_OFFSET]     ]  } <= i_amo_alu_result[31:0];

         // WRITE DOUBLEWORD
         2'b11   : DATA_MEM [ i_addr_from_core[`INDEX] ][ i_addr_from_core[`BLOCK_OFFSET] ] <= i_amo_alu_result;


        endcase



        end

        else
         begin
        unique case (i_size)
        // WRITE BYTE
         2'b00   : DATA_MEM [ i_addr_from_core[`INDEX] ][ i_addr_from_core[`BLOCK_OFFSET] ][ i_addr_from_core[`BYTE_OFFSET] ] <= i_data_from_core[7:0];  

         // WRITE HALFWORD
         2'b01   : {DATA_MEM [ i_addr_from_core[`INDEX] ][ i_addr_from_core[`BLOCK_OFFSET] ][ i_addr_from_core[`BYTE_OFFSET] + 1] ,
                    DATA_MEM [ i_addr_from_core[`INDEX] ][ i_addr_from_core[`BLOCK_OFFSET] ][ i_addr_from_core[`BYTE_OFFSET]    ]  } <= i_data_from_core[15:0];

         // WRITE WORD
         2'b10   :{DATA_MEM [ i_addr_from_core[`INDEX] ][ i_addr_from_core[`BLOCK_OFFSET] ][ i_addr_from_core[`BYTE_OFFSET] + 3 ],
                   DATA_MEM [ i_addr_from_core[`INDEX] ][ i_addr_from_core[`BLOCK_OFFSET] ][ i_addr_from_core[`BYTE_OFFSET] + 2 ], 
                   DATA_MEM [ i_addr_from_core[`INDEX] ][ i_addr_from_core[`BLOCK_OFFSET] ][ i_addr_from_core[`BYTE_OFFSET] + 1 ],
                   DATA_MEM [ i_addr_from_core[`INDEX] ][ i_addr_from_core[`BLOCK_OFFSET] ][ i_addr_from_core[`BYTE_OFFSET]     ]  } <= i_data_from_core[31:0];

         // WRITE DOUBLEWORD
         2'b11   : DATA_MEM [ i_addr_from_core[`INDEX] ][ i_addr_from_core[`BLOCK_OFFSET] ] <= i_data_from_core;


        endcase
        end
    end

end    
end


///////////////////////////////////////////////
//          READ FROM MEMORY BLOCK           //
///////////////////////////////////////////////

always_comb begin : READ_MEMORY_BLOCK
o_data_to_core = 'b0;
if (i_rd_en) begin


    unique case (i_size)
        // READ BYTE
         2'b00   : o_data_to_core = DATA_MEM [ i_addr_from_core[`INDEX] ][ i_addr_from_core[`BLOCK_OFFSET] ][ i_addr_from_core[`BYTE_OFFSET] ];  

         // READ HALFWORD
         2'b01   : o_data_to_core = {DATA_MEM [ i_addr_from_core[`INDEX] ][ i_addr_from_core[`BLOCK_OFFSET] ][ i_addr_from_core[`BYTE_OFFSET] + 1 ] ,
                    DATA_MEM [ i_addr_from_core[`INDEX] ][ i_addr_from_core[`BLOCK_OFFSET] ][ i_addr_from_core[`BYTE_OFFSET]    ] };

         // READ WORD
         2'b10   : o_data_to_core = {DATA_MEM [ i_addr_from_core[`INDEX] ][ i_addr_from_core[`BLOCK_OFFSET] ][ i_addr_from_core[`BYTE_OFFSET] + 3 ] ,
                                     DATA_MEM [ i_addr_from_core[`INDEX] ][ i_addr_from_core[`BLOCK_OFFSET] ][ i_addr_from_core[`BYTE_OFFSET] + 2 ] , 
                                     DATA_MEM [ i_addr_from_core[`INDEX] ][ i_addr_from_core[`BLOCK_OFFSET] ][ i_addr_from_core[`BYTE_OFFSET] + 1 ] ,
                                     DATA_MEM [ i_addr_from_core[`INDEX] ][ i_addr_from_core[`BLOCK_OFFSET] ][ i_addr_from_core[`BYTE_OFFSET]     ]   };

         // READ DOUBLEWORD
         2'b11   : o_data_to_core =  DATA_MEM [ i_addr_from_core[`INDEX] ][ i_addr_from_core[`BLOCK_OFFSET] ];


        endcase
end
    
end




endmodule