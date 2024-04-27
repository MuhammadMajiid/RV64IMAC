`define DATA_PART_OFFSET 64'h0000000d000

module mem_translator #(
    parameter DATA_WIDTH = 64,
    parameter ADDR_WIDTH = 64,
    parameter CACHE_LINE_WIDTH = 256
) (
    input logic i_clk,

    // DATA CACHE PORT //

    input logic [DATA_WIDTH-1:0] i_dcache_write_data,
    input logic [ADDR_WIDTH-1:0] i_dcache_write_address,
    input logic                  i_dcache_write_valid,
    input logic [7:0]            i_dcache_write_strobe,

    input logic                  i_dcache_read_req,
    input logic [ADDR_WIDTH-1:0] i_dcache_read_address,

    output logic [CACHE_LINE_WIDTH-1:0] o_dcache_cache_line,
    output logic                        o_dcache_read_done,

    output logic                        o_dcache_write_done,



    // INST CACHE PORT //

    input logic                  i_icache_read_req,
    input logic [ADDR_WIDTH-1:0] i_icache_read_address,
    
    output logic [CACHE_LINE_WIDTH-1:0] o_icache_cache_line,
    output logic                        o_icache_read_done,


    // MEMORY PORT //

    // Interface with READ CHANNEL //

    output logic [ADDR_WIDTH-1     : 0] o_mem_read_address,
    output logic                        o_mem_read_req,
    input  logic                        i_mem_read_done,
    input  logic [CACHE_LINE_WIDTH-1 : 0] i_cache_line,
    
    // Interface with WRITE CHANNEL //

    input logic                         i_mem_write_done,
    output logic                          o_mem_write_valid,
    output logic [     DATA_WIDTH-1 : 0]  o_mem_write_data,
    output logic [     ADDR_WIDTH-1 : 0]  o_mem_write_address,
    output logic [                7 : 0]  o_write_strobe

);


assign o_dcache_write_done = i_mem_write_done;

assign o_mem_write_valid = i_dcache_write_valid;

assign o_write_strobe = i_dcache_write_strobe;

assign o_mem_write_data = i_dcache_write_data;


always_comb begin : MEM_WRITE_PORTS_ASSIGN
o_mem_write_address='b0;

    if(i_dcache_write_valid)
    begin
        o_mem_write_address = i_dcache_write_address + `DATA_PART_OFFSET;
    end

end

logic [1:0] counter ;
always_ff @( posedge i_clk ) begin : MEM_READ_PORTS_ASSIGN

if(i_icache_read_req)
begin

    o_mem_read_address <= i_icache_read_address;
    o_mem_read_req <= i_icache_read_req;

    o_icache_read_done <= i_mem_read_done;

    counter <= 1;
end
else if(i_dcache_read_req)
begin
    o_mem_read_address <= i_dcache_read_address + `DATA_PART_OFFSET;
    o_mem_read_req <= i_dcache_read_req;
    counter <= (counter == 0) ? 1'b0 : counter -1 ;

    o_dcache_read_done <= i_mem_read_done && (counter == 0);
end
else 
begin
o_mem_read_address <='b0;
o_mem_read_req <= 0;

o_dcache_read_done <= 0;

o_icache_read_done <= 0; 

end

end

always_ff @( posedge i_clk ) begin : CACHE_LINE_ASSIGN
    o_dcache_cache_line <= i_cache_line;
    o_icache_cache_line <= i_cache_line;
end


endmodule