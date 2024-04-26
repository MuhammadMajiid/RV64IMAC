module riscv_core_csr_control_signals (
    input logic [31:0]  i_csr_control_instr,
    output logic  o_csr_control_ecall,
    output logic  o_csr_control_ebreak,
    output logic  o_csr_control_mret,
    output logic  o_csr_control_sret,
    output logic  o_csr_control_csr_wen,
    output logic  o_csr_illegal
);
    

assign o_csr_control_mret   = (i_csr_control_instr==32'h30200073);

assign o_csr_control_sret   = (i_csr_control_instr==32'h10200073);


assign o_csr_control_ecall  = (i_csr_control_instr==32'h00000073);

assign o_csr_control_ebreak = (i_csr_control_instr==32'h00100073);

assign o_csr_control_csr_wen = ((i_csr_control_instr[6:0]==7'b1110011));

always_comb begin : illegal_csr

if(i_csr_control_instr[14:12] == 3'b000 && i_csr_control_instr[6:0] == 7'h73)
begin
    if((i_csr_control_instr==32'h10200073) || (i_csr_control_instr==32'h30200073) || (i_csr_control_instr==32'h00000073) || (i_csr_control_instr==32'h00100073) )
    o_csr_illegal = 0;
    else
    o_csr_illegal = 1;
end
else if(i_csr_control_instr[6:0] == 6'h73)
o_csr_illegal = 0;
else
o_csr_illegal = 0;

end

endmodule