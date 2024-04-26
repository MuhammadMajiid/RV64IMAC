`define INDEX 14:3

module main_mem #(
    parameter MEM_DEPTH  =  12,
    parameter DATA_WIDTH =  64,
    parameter ADDR_WIDTH =  64,
    parameter CACHE_LINE_WIDTH =  256
) (
    input logic i_clk,
    input logic i_rst_n,

    
    // Interface with READ CHANNEL //

    input logic [ADDR_WIDTH-1     : 0] i_mem_read_address,
    input logic                        i_mem_read_req,
    output  logic                        o_mem_read_done,
    output  logic [CACHE_LINE_WIDTH-1 : 0] o_cache_line,
    
    // Interface with WRITE CHANNEL //

    output logic                         o_mem_write_done,
    input logic                          i_mem_write_valid,
    input logic [     DATA_WIDTH-1 : 0]  i_mem_write_data,
    input logic [     ADDR_WIDTH-1 : 0]  i_mem_write_address,
    input logic [                7 : 0]  i_write_strobe
);


localparam MEM_SIZE = (2**MEM_DEPTH);

(* ram_style = "block" *) bit [63:0] MEM [0: MEM_SIZE-1];



always_ff @( posedge i_clk) begin : BLOCK_READ_and_DATA_WRITE
o_mem_read_done <=0;
o_mem_write_done <=0;

if(i_mem_read_req)
begin


o_cache_line <= { 
    MEM[i_mem_read_address[`INDEX] + 3],
    MEM[i_mem_read_address[`INDEX] + 2],
    MEM[i_mem_read_address[`INDEX] + 1],
    MEM[i_mem_read_address[`INDEX] + 0]};

    o_mem_read_done <= 1;
end

else if(i_mem_write_valid)
begin

if(i_write_strobe[0])
MEM[i_mem_write_address[`INDEX]][7:0] <= i_mem_write_data[7:0];

if(i_write_strobe[1])
MEM[i_mem_write_address[`INDEX]][15:8] <= i_mem_write_data[15:8];

if(i_write_strobe[2])
MEM[i_mem_write_address[`INDEX]][23:16] <= i_mem_write_data[23:16];

if(i_write_strobe[3])
MEM[i_mem_write_address[`INDEX]][31:24] <= i_mem_write_data[31:24];

if(i_write_strobe[4])
MEM[i_mem_write_address[`INDEX]][39:32] <= i_mem_write_data[39:32];

if(i_write_strobe[5])
MEM[i_mem_write_address[`INDEX]][47:40] <= i_mem_write_data[47:40];

if(i_write_strobe[6])
MEM[i_mem_write_address[`INDEX]][55:48] <= i_mem_write_data[55:48];

if(i_write_strobe[7])
MEM[i_mem_write_address[`INDEX]][63:56] <= i_mem_write_data[63:56];
    


    o_mem_write_done <=1;
end
/*
else if (!i_rst_n)
begin
    for (int i = 0 ; i < MEM_SIZE ;i=i+1 ) begin
        MEM[i] <= 'b0;
    end
end
*/
end
    
endmodule