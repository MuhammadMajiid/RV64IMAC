module riscv_core_prediction_recovery #(
    parameter ALEN = 64
) 
(
    input logic              branch,
    input logic              jump,
    input logic              i_valid,
    input logic              i_btanch_Taken,            // branch predtion output
    input logic  [ALEN-1:0]  i_target_address,          // predicted address
    input logic  [ALEN-1:0]  i_ex_address,              // address from excution stage
    input logic  [ALEN-1:0]  i_pc_plus_offset,          // pc+4 || pc+2
    input logic              i_is_taken,                // branch unit output

    output logic             o_mis_prediction,
    output logic [ALEN-1:0]  o_recovery_address
);

    localparam branch_instr = 2'b10;
    localparam jump_instr   = 2'b01;

    logic       address_matched;
    logic [1:0] branch_jump;

    always_comb begin : recovery_proc

        case (branch_jump)
            branch_instr: begin
                if (i_valid) begin
                    if (i_btanch_Taken == 0 & i_is_taken == 0) begin
                        o_mis_prediction   = 1'b0;
                        o_recovery_address =  'b0;
                    end

                    else if (i_btanch_Taken == 0 & i_is_taken == 1) begin
                        o_mis_prediction   = 1'b1;
                        o_recovery_address = i_ex_address;
                    end

                    else if (i_btanch_Taken == 1 & i_is_taken == 0) begin
                        o_mis_prediction   = 1'b1;
                        o_recovery_address = i_pc_plus_offset;
                    end

                    else if (i_btanch_Taken == 1 & i_is_taken == 1) begin
                        if (address_matched) begin
                            o_mis_prediction   = 1'b0;
                            o_recovery_address =  'b0;
                        end 
                        else begin
                            o_mis_prediction   = 1'b1;
                            o_recovery_address = i_ex_address;
                        end
                    end

                    else begin
                        o_mis_prediction   = 1'b0;
                        o_recovery_address =  'b0;
                    end
                end
                else begin
                    if (i_is_taken) begin
                        o_mis_prediction   = 1'b1;
                        o_recovery_address = i_ex_address;
                    end else begin
                        o_mis_prediction   = 1'b0;
                        o_recovery_address =  'b0;
                    end
                end
            end

            jump_instr: begin
                if ((!i_btanch_Taken) || (i_btanch_Taken & !address_matched)) begin
                    o_mis_prediction   = 1'b1;
                    o_recovery_address = i_ex_address;
                end
                else begin
                    o_mis_prediction   = 1'b0;
                    o_recovery_address =  'b0;
                end
            end

            default: begin
                o_mis_prediction   = 1'b0;
                o_recovery_address = 'b0;
            end
        endcase
        
    end

    assign branch_jump = {branch,jump};
    assign address_matched = (i_ex_address == i_target_address) ? 1 : 0;

endmodule