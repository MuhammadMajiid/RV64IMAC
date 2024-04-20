`define INDEX 14:3
`define BYTE_OFFSET 2:0

module main_mem #(
    parameter MEM_DEPTH  =  12,
    parameter DATA_WIDTH =  64,
    parameter ADDR_WIDTH =  64,
    parameter AXI_DATA_WIDTH =  256
) (
    input logic i_clk,
    input logic i_rst_n,
    
    // Interface with AXI READ CHANNEL //

    input logic [ADDR_WIDTH-1     : 0] o_mem_read_address,
    input logic                        o_mem_read_req,
    output  logic                        i_mem_read_done,
    output  logic [AXI_DATA_WIDTH-1 : 0] i_block_from_axi,
    
    // Interface with AXI WRITE CHANNEL //

    output logic                         i_mem_write_done,
    input logic                          o_mem_write_valid,
    input logic [     DATA_WIDTH-1 : 0]  o_mem_write_data,
    input logic [     ADDR_WIDTH-1 : 0]  o_mem_write_address,
    input logic [                1 : 0]  i_size
);


localparam MEM_SIZE = (2**MEM_DEPTH);

logic [7:0][7:0] MEM [0: MEM_SIZE-1];



always_ff @( posedge i_clk , negedge i_rst_n ) begin : BLOCK_READ_and_DATA_WRITE
i_mem_read_done <=0;
i_mem_write_done <=0;
if(! i_rst_n)
begin
    for (int i = 0 ; i< MEM_SIZE ;i=i+1 ) begin
        MEM[i] <= 'b0;
    end
end 
else if(o_mem_read_req)
begin
    i_block_from_axi <= { 
    MEM[o_mem_read_address[`INDEX] + 3 ],
    MEM[o_mem_read_address[`INDEX] + 2 ],
    MEM[o_mem_read_address[`INDEX] + 1 ],
    MEM[o_mem_read_address[`INDEX] + 0 ]};

    i_mem_read_done <= 1;
end

else if(o_mem_write_valid)
begin
    //
    unique case (i_size)
        // WRITE BYTE
         2'b00   : MEM [ o_mem_write_address[`INDEX] ][ o_mem_write_address[`BYTE_OFFSET] ] <= o_mem_write_data[7:0];  

         // WRITE HALFWORD
         2'b01   : {MEM [ o_mem_write_address[`INDEX] ][ o_mem_write_address[`BYTE_OFFSET] + 1] ,
                    MEM [ o_mem_write_address[`INDEX] ][ o_mem_write_address[`BYTE_OFFSET]    ]  } <= o_mem_write_data[15:0];

         // WRITE WORD
         2'b10   :{MEM [ o_mem_write_address[`INDEX] ][ o_mem_write_address[`BYTE_OFFSET] + 3 ],
                   MEM [ o_mem_write_address[`INDEX] ][ o_mem_write_address[`BYTE_OFFSET] + 2 ], 
                   MEM [ o_mem_write_address[`INDEX] ][ o_mem_write_address[`BYTE_OFFSET] + 1 ],
                   MEM [ o_mem_write_address[`INDEX] ][ o_mem_write_address[`BYTE_OFFSET]     ]  } <= o_mem_write_data[31:0];

         // WRITE DOUBLEWORD
         2'b11   : MEM [ o_mem_write_address[`INDEX] ] <= o_mem_write_data;


        endcase
    //

    i_mem_write_done <=1;
end


end
    
endmodule