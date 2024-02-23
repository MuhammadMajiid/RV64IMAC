`define TAG 63:12
`define INDEX 11:5
`define BLOCK_OFFSET 4:3
`define BYTE_OFFSET 2:0
`define OFFSET 5


module riscv_core_dcache_controller #(
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
    output logic                        o_stall,


    // Interface with CACHE MEM //

    output logic                         o_rd_en,
    output logic                         o_wr_en,
    output logic                         o_block_replace,

    // Interface with AXI Module //

    output logic [ADDR_WIDTH-1     : 0] o_addr_from_control_to_axi,
    output logic                        o_mem_req,
    input  logic                        i_mem_done,
    
    // Interface with FIFO      //

    input logic                           i_fifo_full,
    output logic                          o_fifo_push,
    output logic [FIFO_ENTRY_WIDTH-1 : 0] o_fifo_entry




);

///////////////////////////////////////////////
//             LOCAL PARAMETERS              //
///////////////////////////////////////////////

localparam CACHE_DEPTH = $pow(2,INDEX_WIDTH) ;


///////////////////////////////////////////////
//      INTERNAL REGISTERS AND MEMORIES      //
///////////////////////////////////////////////


logic [  TAG_WIDTH-1 : 0  ] TAG_MEM  [CACHE_DEPTH];
logic                      VALID_MEM [CACHE_DEPTH];


enum logic [1:0] {
    IDLE           = 2'b00,
    MEM_REQ        = 2'b01,
    UPDATE_CACHE   = 2'b10,
    WAIT_FIFO      = 2'b11} STATE , NEXT ;

logic                      update_en;
logic                      tag_hit;

/////////////////////////////////////////////////
//    ASSIGNING NEXT STATE AND UPDATE BLOCK    //
/////////////////////////////////////////////////

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

/////////////////////////////////////////////////
//            TAG COMPARISON BLOCK             //
/////////////////////////////////////////////////

assign   tag_hit    = (TAG_MEM[  i_addr_from_core[`INDEX]   ] == i_addr_from_core[`TAG]) &&  VALID_MEM[  i_addr_from_core[`INDEX]   ]; 







/////////////////////////////////////////////////
//            FSM TRANSITION BLOCK             //
/////////////////////////////////////////////////

always_comb begin : FSM_TRANSITION_BLOCK


// DEFAULT VALUES //

o_rd_en = 0;
o_wr_en = 0;
o_block_replace = 0;
o_fifo_push = 0;
o_fifo_entry = 'b0;
o_stall = 0;
o_addr_from_control_to_axi = {i_addr_from_core[`TAG] , i_addr_from_core[`INDEX],`OFFSET'b0};
o_mem_req = 0;
update_en = 0;

NEXT = STATE ;


case (STATE)
    IDLE   : begin
        // DEFAULT VALUES FOR IDLE//

        o_rd_en = 0;
        o_wr_en = 0;
        o_block_replace = 0;
        o_fifo_push = 0;
        o_fifo_entry = 'b0;
        o_stall = 0;
        o_addr_from_control_to_axi = {i_addr_from_core[`TAG] , i_addr_from_core[`INDEX],`OFFSET'b0};
        o_mem_req = 0;
        update_en = 0;
        

        // READ INSTRUCTIONS //

            if (i_read) begin
                if (tag_hit) begin // READ HIT
                    o_rd_en = 1;
                end
                else begin // READ MISS

                    o_stall = 1;
                    o_mem_req = 1;
                    o_addr_from_control_to_axi = {i_addr_from_core[`TAG] , i_addr_from_core[`INDEX],`OFFSET'b0};
                    NEXT = MEM_REQ;
                end    
            end

        // WRITE INSTRUCTIONS //

            else if(i_write) begin
                if (tag_hit) begin
                    if (!i_fifo_full) begin // WRITE HIT and FIFO NOT FULL
                       o_wr_en = 1;
                       o_fifo_push = 1;
                       o_fifo_entry = {i_addr_from_core , i_data_from_core};  
                    end
                    else begin // WRITE HIT and FIFO FULL 
                       o_stall = 1;
                       NEXT = WAIT_FIFO;
                    end    
                end
                else begin // WRITE MISS

                    o_stall = 1;
                    o_mem_req = 1;
                    o_addr_from_control_to_axi = {i_addr_from_core[`TAG] , i_addr_from_core[`INDEX],`OFFSET'b0};
                    NEXT = MEM_REQ;
                end 
            end      
            end 




     MEM_REQ : begin

        o_rd_en = 0;
        o_wr_en = 0;
        o_block_replace = 0;
        o_fifo_push = 0;
        o_fifo_entry = 'b0;
        o_stall = 1;
        o_addr_from_control_to_axi = {i_addr_from_core[`TAG] , i_addr_from_core[`INDEX],`OFFSET'b0};
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
        o_fifo_push = 0;
        o_fifo_entry = 'b0;
        o_stall = 1;
        o_addr_from_control_to_axi = {i_addr_from_core[`TAG] , i_addr_from_core[`INDEX],`OFFSET'b0};
        o_mem_req = 0;
        update_en = 1;
        NEXT = IDLE;
                    end 


       WAIT_FIFO : begin

        o_rd_en = 0;
        o_wr_en = 0;
        o_block_replace = 0;
        o_fifo_push = 0;
        o_fifo_entry = 'b0;
        o_stall = 1;
        o_addr_from_control_to_axi = {i_addr_from_core[`TAG] , i_addr_from_core[`INDEX],`OFFSET'b0};
        o_mem_req = 0;
        update_en = 0;
        

        if (!i_fifo_full) begin
            NEXT = IDLE;
        end
               end               

    default: begin
        o_rd_en = 0;
        o_wr_en = 0;
        o_block_replace = 0;
        o_fifo_push = 0;
        o_fifo_entry = 'b0;
        o_stall = 0;
        o_addr_from_control_to_axi = {i_addr_from_core[`TAG] , i_addr_from_core[`INDEX],`OFFSET'b0};
        o_mem_req = 0;
        update_en = 0;
        NEXT = IDLE;

             end

endcase









end



endmodule