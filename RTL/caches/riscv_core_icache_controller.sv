`define TAG 63:12
`define INDEX 11:5
`define BLOCK_OFFSET 4:2
`define BYTE_OFFSET 1:0
`define OFFSET 5

module riscv_core_icache_controller #(
    parameter BLOCK_OFFSET_WIDTH = 2,
    parameter INDEX_WIDTH        = 7,
    parameter TAG_WIDTH          = 52,
    parameter CORE_DATA_WIDTH    = 32,
    parameter ADDR_WIDTH         = 64,
    parameter AXI_DATA_WIDTH     = 256
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
    input  logic                        i_mem_done,
    output logic                        o_offset
);
//             LOCAL PARAMETERS              //
localparam CACHE_DEPTH = 2**INDEX_WIDTH ;
//      INTERNAL REGISTERS AND MEMORIES      //
logic [(TAG_WIDTH-1):0] TAG_MEM  [0:CACHE_DEPTH-1];
logic                      VALID_MEM [0:CACHE_DEPTH-1];
enum logic [1:0] {
    IDLE           = 2'b00,
    MEM_REQ        = 2'b01,
    UPDATE_CACHE   = 2'b10} STATE , NEXT ;
logic                      update_en;
logic                      tag_hit_1 , tag_hit_2 , over_f , s1 , s2 , miss ;
logic [ADDR_WIDTH-1      : 0] i_addr_from_core_next_block;
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
            if(s1) begin
                TAG_MEM       [  i_addr_from_core[`INDEX]   ] <= i_addr_from_core[`TAG];
                VALID_MEM     [  i_addr_from_core[`INDEX]   ] <= 1'b1;
            end
            else if (s2) begin
                TAG_MEM       [  i_addr_from_core_next_block[`INDEX]   ] <= i_addr_from_core_next_block[`TAG];
                VALID_MEM     [  i_addr_from_core_next_block[`INDEX]   ] <= 1'b1;
            end
        end
    end
end
//            TAG COMPARISON BLOCK IF THE SAME BLOCK             //
assign tag_hit_1 = ((TAG_MEM[i_addr_from_core[`INDEX]] == i_addr_from_core[`TAG]) &&  VALID_MEM[i_addr_from_core[`INDEX]]); 
//            DETECT IF IT'S NEEDED TO TAKE TWO BYTES FROM THE NEXT BLOCK   //
assign over_f = ((i_addr_from_core[`BLOCK_OFFSET]==3'b111) && (i_addr_from_core[`BYTE_OFFSET]==2'b10));
//            ADD 2 TO GET THE NEW INDEX AND NEW TAG IN CASE OF OVER_F  //
assign i_addr_from_core_next_block = i_addr_from_core + 2'b10 ;
//             TAG COPARISON BLOCK IN CASE OF NEXT BLOCK        //
assign tag_hit_2 = ((TAG_MEM[i_addr_from_core_next_block[`INDEX]] == i_addr_from_core_next_block[`TAG]) &&  VALID_MEM[i_addr_from_core_next_block[`INDEX]]); 
//             s1 IS THE CONDITION OF CACHE MISS IN THE SAME BLOCK  //
assign s1 = !(tag_hit_1);
//             s2 IS THE CONDITION OF MISS IN THE NEXT BLOCK IN CASE OF OVER_F  //
assign s2 = (( over_f ) && !( tag_hit_2 ));
//             MISS CONDITION WILL HAPPEN IF S1 HAPPEN OR S2 HAPPEN //
assign miss = (s1) || (s2);
//            FSM TRANSITION BLOCK             //
always_comb begin : FSM_TRANSITION_BLOCK
// DEFAULT VALUES //
o_rd_en = 0;
o_wr_en = 0;
o_block_replace = 0;
o_stall = 0;
o_addr_from_control_to_axi = 64'b0;
o_mem_req = 0;
update_en = 0;
o_offset = 0;
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
            if (!miss) begin // READ HIT
                o_rd_en = 1;
            end
            else begin // READ MISS
                o_stall = 1;
                o_mem_req = 1;
                if(s1)      //if s1 then get the block from the start   //
                    o_addr_from_control_to_axi = {i_addr_from_core[`TAG],i_addr_from_core[`INDEX],`OFFSET'b0};
                else if (s2)    //if s2 then get the next block from the start  //
                    o_addr_from_control_to_axi = {i_addr_from_core_next_block[`TAG],i_addr_from_core_next_block[`INDEX],`OFFSET'b0};
                NEXT = MEM_REQ;
            end        
    end
    MEM_REQ : begin
        o_rd_en = 0;
        o_wr_en = 0;
        o_block_replace = 0;
        o_stall = 1;
        if(s1)      //if s1 then get the block from the start   //
            o_addr_from_control_to_axi = {i_addr_from_core[`TAG],i_addr_from_core[`INDEX],`OFFSET'b0};
        else if (s2)    //if s2 then get the next block from the start  //
            o_addr_from_control_to_axi = {i_addr_from_core_next_block[`TAG],i_addr_from_core_next_block[`INDEX],`OFFSET'b0};
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
        // to allocate which to write in //
        if(s1)
            o_offset = 0;
        else if (s2)
            o_offset = 1'b1;
        else 
            o_offset = 0;
        ///////////////////////////////////
        o_stall = 1;
        o_addr_from_control_to_axi = 64'b0;
        o_mem_req = 0;
        update_en = 1;
        NEXT = IDLE;
    end           
    default: begin
        o_rd_en = 0;
        o_wr_en = 0;
        o_block_replace = 0;
        o_stall = 0;
        o_addr_from_control_to_axi = 64'b0;
        o_mem_req = 0;
        update_en = 0;
        NEXT = IDLE;
        end
endcase
end
endmodule