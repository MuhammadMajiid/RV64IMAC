module riscv_core_immextend(
    input  logic  [24:0] i_riscv_core_immextend_imm, //instruction [31:7]
    input  logic  [2:0]  i_riscv_core_immextend_immsrc, //cotrol from MAin decoder
    output logic  [63:0] i_riscv_core_immextend_out  //extended output
);
always_comb begin : imm_extender
    case(i_riscv_core_immextend_immsrc)
        3'b000:  i_riscv_core_immextend_out={{52{i_riscv_core_immextend_imm[24]}}, i_riscv_core_immextend_imm[24:13]};  //{{52{instr[31]}},instr[31:20]}
        3'b001:  i_riscv_core_immextend_out={{52{i_riscv_core_immextend_imm[24]}}, i_riscv_core_immextend_imm[24:18], i_riscv_core_immextend_imm[4:0]};//{{52{Instr[31]}}, Instr[31:25], Instr[11:7]}
        3'b010:  i_riscv_core_immextend_out={{52{i_riscv_core_immextend_imm[24]}}, i_riscv_core_immextend_imm[0], i_riscv_core_immextend_imm[23:18], i_riscv_core_immextend_imm[4:1], 1'b0}; //{{52{Instr[31]}}, Instr[7], Instr[30:25], Instr[11:8], 1’b0}
        3'b011:  i_riscv_core_immextend_out={{44{i_riscv_core_immextend_imm[24]}}, i_riscv_core_immextend_imm[12:5], i_riscv_core_immextend_imm[13], i_riscv_core_immextend_imm[23:14], 1'b0}; //{{44{Instr[31]}}, Instr[19:12], Instr[20], Instr[30:21], 1’b0}
        3'b100:  i_riscv_core_immextend_out={{32{i_riscv_core_immextend_imm[24]}}, i_riscv_core_immextend_imm[24:5], {12{1'b0}}}; //{32'(instr[31]) ,instr[31:12], {12{1'b0}}}
        default: i_riscv_core_immextend_out={64{1'b0}};
    endcase
end
endmodule