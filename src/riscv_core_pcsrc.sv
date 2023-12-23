module riscv_core_pcsrc (
    input logic i_pcsrc_istaken,
    input logic i_pcsrc_branch_ex,
    input logic i_pcsrc_jump_ex,

    output logic o_pcsrc_pcsrc_ex
);
//--------Intermediate signal---------//
logic branch_and_istaken;

assign branch_and_istaken = (i_pcsrc_branch_ex && i_pcsrc_istaken);
assign o_pcsrc_pcsrc_ex = (i_pcsrc_jump_ex || branch_and_istaken);
    
endmodule