`define INDEX_I 14:3

module instr_main_mem #(
    parameter MEM_DEPTH  =  12,
    parameter DATA_WIDTH =  64,
    parameter ADDR_WIDTH =  64,
    parameter CACHE_LINE_WIDTH =  256
) (
    input logic i_clk,

    
    // Interface with READ CHANNEL //

    input logic [ADDR_WIDTH-1     : 0] i_mem_read_address,
    input logic                        i_mem_read_req,
    output  logic                        o_mem_read_done,
    output  logic [CACHE_LINE_WIDTH-1 : 0] o_cache_line
);

localparam MEM_SIZE = (2**MEM_DEPTH);


(* ram_style = "block" *) bit [63:0] MEM [0: MEM_SIZE-1];


always_ff @( posedge i_clk) begin : BLOCK_READ_and_DATA_WRITE
o_mem_read_done <=0;

if(i_mem_read_req)
begin


o_cache_line <= { 
    MEM[i_mem_read_address[`INDEX_I] + 3],
    MEM[i_mem_read_address[`INDEX_I] + 2],
    MEM[i_mem_read_address[`INDEX_I] + 1],
    MEM[i_mem_read_address[`INDEX_I] + 0]};

    o_mem_read_done <= 1;
end

end
    
endmodule