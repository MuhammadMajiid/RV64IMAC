module riscv_core_csr_control_signals (
    input logic [31:0]  i_csr_control_instr,
    output logic  o_csr_control_ecall,
    output logic  o_csr_control_ebreak,
    output logic  o_csr_control_mret,
    output logic  o_csr_control_csr_wen
);
    

assign o_csr_control_mret   = (i_csr_control_instr==32'h30200073);

assign o_csr_control_ecall  = (i_csr_control_instr==32'h00000073);

assign o_csr_control_ebreak = (i_csr_control_instr==32'h00100073);

assign o_csr_control_csr_wen = ((i_csr_control_instr[6:0]==7'b1110011));

endmodule