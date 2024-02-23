`define TAG 63:12
`define INDEX 11:5
`define BLOCK_OFFSET 4:3
`define BYTE_OFFSET 2:0
`define OFFSET 5

module riscv_core_icache_controller #(
    parameter BLOCK_OFFSET      = 2,
    parameter INDEX_WIDTH       = 7,
    parameter TAG_WIDTH         = 52,
    parameter CORE_DATA_WIDTH   = 32,
    parameter ADDR_WIDTH        = 64,
    parameter AXI_DATA_WIDTH    = 256
) (
    // Interface with CORE//
    input logic                         i_clk,
    input logic                         i_rst_n,
    input logic [ADDR_WIDTH-1      : 0] i_addr_from_core ,
    output logic                        o_stall,
    // Interface with CACHE MEM //
    output logic                         o_rd_en,
    output logic                         o_wr_en,
    output logic                         o_block_replace,
    // Interface with AXI Module //
    output logic [ADDR_WIDTH-1     : 0] o_addr_from_control_to_axi,
    output logic                        o_mem_req,
    input  logic                        i_mem_done
);
//             LOCAL PARAMETERS              //
localparam CACHE_DEPTH = $pow(2,INDEX_WIDTH) ;
//      INTERNAL REGISTERS AND MEMORIES      //
logic [  TAG_WIDTH-1 : 0  ] TAG_MEM  [CACHE_DEPTH];
logic                      VALID_MEM [CACHE_DEPTH];
enum logic [1:0] {
    IDLE           = 2'b00,
    MEM_REQ        = 2'b01,
    UPDATE_CACHE   = 2'b10} STATE , NEXT ;
logic                      update_en;
logic                      tag_hit;
//    ASSIGNING NEXT STATE AND UPDATE BLOCK    //
always_ff @( posedge i_clk , negedge i_rst_n ) begin : NEXT_STATE_ASSIGN_FLUSH_UPDATE_BLOCK
    if (!i_rst_n) begin
        // Clear ALL Valid Entries //
        for ( int i = 0 ; i < CACHE_DEPTH  ; i=i+1 ) begin
            VALID_MEM[i] <= 0;
        end
        STATE <= IDLE;
    end
    else 
    begin
        STATE <= NEXT ;
        // UPDATE TAG and VALID MEM in case of BLOCK REPLACEMENT //
        if (update_en) begin
            TAG_MEM       [  i_addr_from_core[`INDEX]   ] <= i_addr_from_core[`TAG];
            VALID_MEM     [  i_addr_from_core[`INDEX]   ] <= 1'b1;
        end
    end
end
//            TAG COMPARISON BLOCK             //
assign tag_hit = ((TAG_MEM[i_addr_from_core[`INDEX]] == i_addr_from_core[`TAG]) &&  VALID_MEM[i_addr_from_core[`INDEX]]); 
//            FSM TRANSITION BLOCK             //
always_comb begin : FSM_TRANSITION_BLOCK
// DEFAULT VALUES //
o_rd_en = 0;
o_wr_en = 0;
o_block_replace = 0;
o_stall = 0;
o_addr_from_control_to_axi = {i_addr_from_core[`TAG],i_addr_from_core[`INDEX],`OFFSET'b0};
o_mem_req = 0;
update_en = 0;
NEXT = STATE;
case (STATE)
    IDLE   : begin //always read no write from core
        // DEFAULT VALUES FOR IDLE//
        o_rd_en = 0;
        o_wr_en = 0;
        o_block_replace = 0;
        o_stall = 0;
        o_mem_req = 0;
        update_en = 0;
        // READING SCINARIOs //
            if (tag_hit) begin // READ HIT
                o_rd_en = 1;
            end
            else begin // READ MISS
                o_stall = 1;
                o_mem_req = 1;
                o_addr_from_control_to_axi = {i_addr_from_core[`TAG],i_addr_from_core[`INDEX],`OFFSET'b0};
                NEXT = MEM_REQ;
            end        
    end
    MEM_REQ : begin
        o_rd_en = 0;
        o_wr_en = 0;
        o_block_replace = 0;
        o_stall = 1;
        o_addr_from_control_to_axi = {i_addr_from_core[`TAG],i_addr_from_core[`INDEX],`OFFSET'b0};
        o_mem_req = 1;
        update_en = 0;
        if (i_mem_done) begin
            o_mem_req = 0;
            NEXT = UPDATE_CACHE;
        end
    end
    UPDATE_CACHE : begin
        o_rd_en = 0;
        o_wr_en = 1;
        o_block_replace = 1;
        o_stall = 1;
        o_addr_from_control_to_axi = {i_addr_from_core[`TAG],i_addr_from_core[`INDEX],`OFFSET'b0};
        o_mem_req = 0;
        update_en = 1;
        NEXT = IDLE;
    end           
    default: begin
        o_rd_en = 0;
        o_wr_en = 0;
        o_block_replace = 0;
        o_stall = 0;
        o_addr_from_control_to_axi = {i_addr_from_core[`TAG],i_addr_from_core[`INDEX],`OFFSET'b0};
        o_mem_req = 0;
        update_en = 0;
        NEXT = IDLE;
        end
endcase
end
endmodule