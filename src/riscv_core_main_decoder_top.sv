module riscv_core_main_decoder_top (
    input logic [31:0]  i_instr,
    input logic         i_main_decoder_if_illegal,

    // CSR OUTPUTS //

    output logic  o_csr_control_ecall,
    output logic  o_csr_control_ebreak,
    output logic  o_csr_control_mret,
    output logic  o_csr_control_sret,
    output logic  o_csr_control_csr_wen,

    // Main Decoder Outputs //

    output logic [2:0] o_main_decoder_imsrc,
    output logic       o_main_decoder_UCtrl,
    output logic [1:0] o_main_decoder_resultsrc,
    output logic       o_main_decoder_regwrite,
    output logic       o_main_decoder_alusrcB,
    output logic       o_main_decoder_memwrite,
    output logic       o_main_decoder_branch,
    output logic       o_main_decoder_jump,
    output logic       o_main_decoder_bjreg,
    output logic [1:0] o_main_decoder_size,
    output logic       o_main_decoder_LdExt,
    output logic       o_main_decoder_isword,
    output logic       o_main_decoder_aluop,
    output logic       o_main_decoder_imsel,
    output logic       o_main_decoder_new_mux_sel,
    output logic       o_main_decoder_amo,
    output logic [3:0] o_main_decoder_amo_op,
    output logic       o_main_decoder_lr,
    output logic       o_main_decoder_sc,
    output logic       o_main_decoder_src_sel,
    output logic [1:0] o_main_decoder_op,
    output logic       o_main_decoder_illegal,
    output logic       o_main_decoder_read

);
    

    logic [6:0] i_main_decoder_opcode;
    logic [2:0] i_main_decoder_funct3;
    logic [6:0] i_main_decoder_funct7;

    assign i_main_decoder_opcode = i_instr[6:0];
    assign i_main_decoder_funct3 = i_instr[14:12];
    assign i_main_decoder_funct7 = i_instr[31:25];

    logic o_id_illegal;
    logic o_csr_illegal;


    riscv_core_main_decoder u1 (
    .i_main_decoder_opcode(i_main_decoder_opcode)
    ,.i_main_decoder_funct3(i_main_decoder_funct3)
    ,.i_main_decoder_funct7(i_main_decoder_funct7)
    ,.o_main_decoder_imsrc(o_main_decoder_imsrc)
    ,.o_main_decoder_UCtrl(o_main_decoder_UCtrl)
    ,.o_main_decoder_resultsrc(o_main_decoder_resultsrc)
    ,.o_main_decoder_regwrite(o_main_decoder_regwrite)
    ,.o_main_decoder_alusrcB(o_main_decoder_alusrcB)
    ,.o_main_decoder_memwrite(o_main_decoder_memwrite)
    ,.o_main_decoder_branch(o_main_decoder_branch)
    ,.o_main_decoder_jump(o_main_decoder_jump)
    ,.o_main_decoder_bjreg(o_main_decoder_bjreg)
    ,.o_main_decoder_size(o_main_decoder_size)
    ,.o_main_decoder_LdExt(o_main_decoder_LdExt)
    ,.o_main_decoder_isword(o_main_decoder_isword)
    ,.o_main_decoder_aluop(o_main_decoder_aluop)
    ,.o_main_decoder_imsel(o_main_decoder_imsel)
    ,.o_main_decoder_new_mux_sel(o_main_decoder_new_mux_sel)
    ,.o_main_decoder_amo(o_main_decoder_amo)
    ,.o_main_decoder_amo_op(o_main_decoder_amo_op)
    ,.o_main_decoder_lr(o_main_decoder_lr)
    ,.o_main_decoder_sc(o_main_decoder_sc)
    ,.o_main_decoder_src_sel(o_main_decoder_src_sel)
    ,.o_main_decoder_op(o_main_decoder_op)
    ,.o_main_decoder_illegal(o_id_illegal)
    ,.o_main_decoder_read(o_main_decoder_read)
    );

    assign o_main_decoder_illegal = o_id_illegal || i_main_decoder_if_illegal || o_csr_illegal;

    riscv_core_csr_control_signals u2 (
        .i_csr_control_instr(i_instr)
        ,.o_csr_control_csr_wen(o_csr_control_csr_wen)
        ,.o_csr_control_mret(o_csr_control_mret)
        ,.o_csr_control_sret(o_csr_control_sret)
        ,.o_csr_control_ecall(o_csr_control_ecall)
        ,.o_csr_control_ebreak(o_csr_control_ebreak)
        ,.o_csr_illegal(o_csr_illegal)
    );

endmodule