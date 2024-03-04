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
    parameter AXI_DATA_WIDTH    = 256
) (


    // Interface with CORE//
  
    input logic                         i_clk,
    input logic                         i_rst_n,
    input logic [CORE_DATA_WIDTH-1 : 0] i_data_from_core ,
    input logic [ADDR_WIDTH-1      : 0] i_addr_from_core ,
    input logic                         i_read,
    input logic                         i_write,
    input logic                 [1:0]   i_size,
    output logic                        o_stall,
    output logic                        o_store_fault,
    output logic                        o_load_fault,
    


    // Interface with CACHE MEM //

    output logic                         o_rd_en,
    output logic                         o_wr_en,
    output logic                         o_block_replace,

    // Interface with AXI READ CHANNEL //

    output logic [ADDR_WIDTH-1     : 0] o_mem_read_address,
    output logic                        o_mem_read_req,
    input  logic                        i_mem_read_done,

    // Interface with AXI WRITE CHANNEL //

    input logic                           i_mem_write_done,
    output logic                          o_mem_write_valid,
    output logic [CORE_DATA_WIDTH-1 : 0]  o_mem_write_data,
    output logic [     ADDR_WIDTH-1 : 0]  o_mem_write_address,
    output logic [                7 : 0]  o_mem_write_strobe
   




);

///////////////////////////////////////////////
//             LOCAL PARAMETERS              //
///////////////////////////////////////////////

localparam CACHE_DEPTH = 2**INDEX_WIDTH ;


///////////////////////////////////////////////
//      INTERNAL REGISTERS AND MEMORIES      //
///////////////////////////////////////////////


logic [  TAG_WIDTH-1 : 0  ] TAG_MEM  [0:CACHE_DEPTH-1];
logic                      VALID_MEM [0:CACHE_DEPTH-1];


enum logic [1:0] {
    IDLE           = 2'b00,
    MEM_REQ        = 2'b01,
    UPDATE_CACHE   = 2'b10,
    MEM_WRITE      = 2'b11} STATE , NEXT ;

logic                      update_en;
logic                      tag_hit;
logic                      fault;

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
o_stall = 0;
o_mem_read_address = {i_addr_from_core[`TAG] , i_addr_from_core[`INDEX],`OFFSET'b0};
o_mem_read_req = 0;
update_en = 0;

o_mem_write_data = i_data_from_core;
o_mem_write_address = i_addr_from_core;
o_mem_write_valid = 0;

NEXT = STATE ;


case (STATE)
    IDLE   : begin
        // DEFAULT VALUES FOR IDLE//

        o_rd_en = 0;
        o_wr_en = 0;
        o_block_replace = 0;
        o_stall = 0;
        o_mem_read_address = {i_addr_from_core[`TAG] , i_addr_from_core[`INDEX],`OFFSET'b0};
        o_mem_read_req = 0;
        update_en = 0;

        o_mem_write_data = i_data_from_core;
        o_mem_write_address = i_addr_from_core;
        o_mem_write_valid = 0;
        

        // READ INSTRUCTIONS //

            if (i_read) begin
                if (tag_hit) begin // READ HIT
                    if (!fault)
                    o_rd_en = 1;
                    else
                    o_rd_en = 0;
                end
                else begin // READ MISS

                    o_stall = 1;
                    o_mem_read_req = 1;
                    o_mem_read_address = {i_addr_from_core[`TAG] , i_addr_from_core[`INDEX],`OFFSET'b0};
                    NEXT = MEM_REQ;
                end    
            end

        // WRITE INSTRUCTIONS //

            else if(i_write) begin
                if (tag_hit) begin
                       if (!fault) begin
                       o_wr_en = 1;
                       o_mem_write_valid = 1;
                       o_stall = 1;
                       NEXT = MEM_WRITE;
                       end
                       else 
                       begin
                       o_wr_en = 0;
                       end 
                    end  
                else begin // WRITE MISS

                    o_stall = 1;
                    o_mem_read_req = 1;
                    o_mem_read_address = {i_addr_from_core[`TAG] , i_addr_from_core[`INDEX],`OFFSET'b0};
                    NEXT = MEM_REQ;
                end 
            end      
    end





     MEM_REQ : begin

        o_rd_en = 0;
        o_wr_en = 0;
        o_block_replace = 0;
        o_stall = 1;
        o_mem_read_address = {i_addr_from_core[`TAG] , i_addr_from_core[`INDEX],`OFFSET'b0};
        o_mem_read_req = 1;
        update_en = 0;

        o_mem_write_data = i_data_from_core;
        o_mem_write_address = i_addr_from_core;
        o_mem_write_valid = 0;

        if (i_mem_read_done) begin
            o_mem_read_req = 0;
            NEXT = UPDATE_CACHE;
        end
               end


      UPDATE_CACHE : begin

        o_rd_en = 0;
        o_wr_en = 1;
        o_block_replace = 1;
        o_stall = 1;
        o_mem_read_address = {i_addr_from_core[`TAG] , i_addr_from_core[`INDEX],`OFFSET'b0};
        o_mem_read_req = 0;
        update_en = 1;

        o_mem_write_data = i_data_from_core;
        o_mem_write_address = i_addr_from_core;
        o_mem_write_valid = 0;
        
        NEXT = IDLE;
                    end 


      MEM_WRITE : begin

        o_rd_en = 0;
        o_wr_en = 0;
        o_block_replace = 0;
        o_stall = 1;
        o_mem_read_address = {i_addr_from_core[`TAG] , i_addr_from_core[`INDEX],`OFFSET'b0};
        o_mem_read_req = 0;
        update_en = 0;
        
        o_mem_write_data = i_data_from_core;
        o_mem_write_address = i_addr_from_core;
        o_mem_write_valid = 1;

        if (i_mem_write_done) begin
            o_mem_write_valid = 0;
            o_stall =0 ;
            NEXT = IDLE;
        end
               end               

    default: begin
        o_rd_en = 0;
        o_wr_en = 0;
        o_block_replace = 0;
        o_stall = 0;
        o_mem_read_address = {i_addr_from_core[`TAG] , i_addr_from_core[`INDEX],`OFFSET'b0};
        o_mem_read_req = 0;
        update_en = 0;
        NEXT = IDLE;

        o_mem_write_data = i_data_from_core;
        o_mem_write_address = i_addr_from_core;
        o_mem_write_valid = 0;

             end

endcase

end


/////////////////////////////////////////////////
//            FAULT DETECTION BLOCK            //
/////////////////////////////////////////////////


always_comb begin : FAULT_DETECTION
    fault = 1'b0;
    case (i_size)
        2'b00 : fault = 1'b0;
        2'b01 : begin
                    if(i_addr_from_core[`BYTE_OFFSET] == 3'b111)
                    fault = 1'b1;
                    else
                    fault = 1'b0;
                end
        2'b10 : begin
                    if(i_addr_from_core[`BYTE_OFFSET] == 3'b111 || i_addr_from_core[`BYTE_OFFSET] == 3'b110 || i_addr_from_core[`BYTE_OFFSET] == 3'b101)
                    fault = 1'b1;
                    else
                    fault = 1'b0;
                end
        2'b11 : begin
                    if(i_addr_from_core[`BYTE_OFFSET] == 3'b000)
                    fault = 1'b0;
                    else
                    fault = 1'b1;
                end              
        default: fault = 1'b0;
    endcase
end


assign o_load_fault = fault & i_read;
assign o_store_fault = fault & i_write;


/////////////////////////////////////////////////
//            MEM WRITE STROBE DECODER         //
/////////////////////////////////////////////////


always_comb begin : mem_write_strobe_decoder
    o_mem_write_strobe = 8'b0;
    case (i_size)
        2'b00: o_mem_write_strobe = 8'b0000_0001;
        2'b01: o_mem_write_strobe = 8'b0000_0011;
        2'b10: o_mem_write_strobe = 8'b0000_1111;
        2'b11: o_mem_write_strobe = 8'b1111_1111;
        default: o_mem_write_strobe = 8'b0;
    endcase
end


endmodule