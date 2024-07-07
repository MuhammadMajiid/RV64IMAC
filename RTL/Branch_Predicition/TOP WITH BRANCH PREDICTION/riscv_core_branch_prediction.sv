`define INDEX_BP 9:1
`define TAG_BP 63:10

module riscv_core_branch_prediction #(
    parameter PC_LEN = 64,
    parameter TAG_WIDTH = 54,
    parameter BP_DEPTH = 9
) (
    // GLOBAL PINS 

    input logic i_clk,
    input logic i_rst_n,

    // READ PORTS 

    input  logic  [PC_LEN - 1 : 0]   i_if_pc,
    output logic  [PC_LEN - 1 : 0]   o_branch_target,
    output logic                     o_branch_taken,
    output logic                     o_branch_valid,

    // WRITE PORTS 

    input  logic  [PC_LEN - 1 : 0]  i_ex_pc,
    input  logic  [PC_LEN - 1 : 0]  i_update_branch_target,
    input  logic                    i_valid_branch_update,
    input  logic                    i_valid_branch_taken_update,
    input  logic                    i_jump
);
    

    // BRANCH PREDICTION ENTRY DEFINITION // 

typedef struct packed {
    bit valid;
    bit [1:0] saturation_bits;
    logic [PC_LEN-1:0] branch_target;
    logic [TAG_WIDTH-1:0] branch_tag;
} bp_entry;

localparam  BP_SIZE = 2**BP_DEPTH - 1;

bp_entry bp_mem [0:BP_SIZE];
bp_entry bp_next [0:BP_SIZE];


// READ LOGIC (PREDICTION LOGIC) //

always_comb begin : PREDICTION_LOGIC
    if(i_if_pc[`TAG_BP] === bp_mem[i_if_pc[`INDEX_BP]].branch_tag && bp_mem[i_if_pc[`INDEX_BP]].valid)
    begin
        o_branch_valid = 1;
        o_branch_target = bp_mem[i_if_pc[`INDEX_BP]].branch_target;
        o_branch_taken = bp_mem[i_if_pc[`INDEX_BP]].saturation_bits[1];
    end
    else
    begin
        o_branch_valid = 0;
        o_branch_target = bp_mem[i_if_pc[`INDEX_BP]].branch_target;
        o_branch_taken = bp_mem[i_if_pc[`INDEX_BP]].saturation_bits[1]; 
    end
end



// UPDATE PREDICTION LOGIC //


always_comb begin : UPDATE_PREDICTION_LOGIC
    bp_next = bp_mem;

    if (i_valid_branch_update)
    begin
        if(i_ex_pc[`TAG_BP] === bp_mem[i_ex_pc[`INDEX_BP]].branch_tag  && bp_mem[i_ex_pc[`INDEX_BP]].valid)
        begin
            bp_next[i_ex_pc[`INDEX_BP]].branch_target = i_update_branch_target;
            // UPDATING BRANCH 2-BIT SATURATION
            if(i_valid_branch_taken_update)
            begin
                if(bp_mem[i_ex_pc[`INDEX_BP]].saturation_bits == 2'b11)
                bp_next[i_ex_pc[`INDEX_BP]].saturation_bits = 2'b11;
                else
                bp_next[i_ex_pc[`INDEX_BP]].saturation_bits = bp_mem[i_ex_pc[`INDEX_BP]].saturation_bits + 1 ;
            end
            else
            begin
                if(bp_mem[i_ex_pc[`INDEX_BP]].saturation_bits == 2'b00)
                bp_next[i_ex_pc[`INDEX_BP]].saturation_bits = 2'b00;
                else
                bp_next[i_ex_pc[`INDEX_BP]].saturation_bits = bp_mem[i_ex_pc[`INDEX_BP]].saturation_bits - 1 ;
            end
        end
        else
        begin
            bp_next[i_ex_pc[`INDEX_BP]].branch_target = i_update_branch_target;
            bp_next[i_ex_pc[`INDEX_BP]].saturation_bits = (i_valid_branch_taken_update) ? 2'b01: 2'b00;
            bp_next[i_ex_pc[`INDEX_BP]].valid = 1 ;
            bp_next[i_ex_pc[`INDEX_BP]].branch_tag = i_ex_pc[`TAG_BP];
        end
    end
    else if(i_jump)
    begin
            bp_next[i_ex_pc[`INDEX_BP]].branch_target = i_update_branch_target;
            bp_next[i_ex_pc[`INDEX_BP]].saturation_bits = 2'b11;
            bp_next[i_ex_pc[`INDEX_BP]].valid = 1 ;
            bp_next[i_ex_pc[`INDEX_BP]].branch_tag = i_ex_pc[`TAG_BP];    
    end

end

// RESET AND WRITE LOGIC 

always_ff @( posedge i_clk , negedge i_rst_n ) begin : RESET_AND_WRITE_LOGIC
    if(!i_rst_n)
    begin
        for (int i = 0 ;i <= BP_SIZE ;i=i + 1) begin
            bp_mem[i].saturation_bits <= 2'b00;
            bp_mem[i].valid <= 0 ; 
        end
    end
    else
    begin
        bp_mem <= bp_next;
    end
end
endmodule