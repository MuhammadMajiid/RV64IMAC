module riscv_core_top 
(
  // Global inputs
  input  logic i_riscv_core_clk,
  input  logic i_riscv_core_rst_n,
  input  logic i_riscv_core_external_interrupt,
  output logic o_riscv_core_ack
);
//-------------Local Parameters-------------//

//-------------IF Intermediate Signals-------------//
logic [63:0] if_id_pipe_pc;
logic [63:0] if_pipe_pcf_new;
logic [63:0] compressed_offset;
logic [63:0] if_id_pipe_pc_plus_offset;
logic [31:0] if_id_pipe_instr;
logic [63:0] pcf;
logic [63:0] pc_plus_offset_if;
logic [63:0] mux_to_stg2;
logic [31:0] instr;
logic [31:0] c_ext_instr_out;
logic        instr_is_compressed;
logic        instr_is_illegal_comp;
logic        instr_is_illegal_comp_id;

//-------------ID Intermediate Signals-------------//
logic [63:0] id_ex_pipe_imm;
logic [63:0] id_ex_pipe_rd1;
logic [63:0] id_ex_pipe_rd2;
logic [63:0] id_ex_pipe_pc;
logic [63:0] id_ex_pipe_pc_plus_offset;
logic [4:0]  id_ex_pipe_rd;
logic [4:0]  id_ex_pipe_rs1;
logic [4:0]  id_ex_pipe_rs2;
logic [3:0]  id_ex_pipe_alu_control;
logic [2:0]  id_ex_pipe_funct3;
logic [1:0]  id_ex_pipe_resultsrc;
logic [1:0]  id_ex_pipe_size;
logic        id_ex_pipe_alu_srcb;
logic        id_ex_pipe_branch;
logic        id_ex_pipe_isword;
logic        id_ex_pipe_jump;
logic        id_ex_pipe_ldext;
logic        id_ex_pipe_uctrl;
logic        id_ex_pipe_memwrite;
logic        id_ex_pipe_regwrite;
logic [63:0] rd1_id;
logic [63:0] rd2_id;
logic [63:0] immext_id;
logic [3:0]  alu_control_id;
logic [2:0]  immsrc_id;
logic [1:0]  resultsrc_id;
logic [1:0]  size_id;
logic        alu_op_id;
logic        uctrl_id;
logic        regwrite_id;
logic        alusrc_id;
logic        memwrite_id;
logic        branch_id;
logic        jump_id;
logic        ldext_id;
logic        isword_id;
logic        bjreg_id;
logic        id_ex_pipe_bjreg;
logic        im_sel_id;
logic        id_ex_pipe_im_sel;
logic        new_mux_sel_id;
logic        id_ex_pipe_new_mux_sel;
logic [3:0]  id_main_decoder_amo_op;
logic        id_main_decoder_amo;
logic        id_main_decoder_lr;
logic        id_main_decoder_sc;
logic        id_cahce_read;


//-------------EX Intermediate Signals-------------//
logic [63:0] ex_mem_pipe_alu_result;
logic [63:0] ex_mem_pipe_wd;
logic [63:0] ex_mem_pipe_pc_plus_offset;
logic [4:0]  ex_mem_pipe_rd;
logic [1:0]  ex_mem_pipe_resultsrc;
logic [1:0]  ex_mem_pipe_size;
logic        ex_mem_pipe_memwrite;
logic        ex_mem_pipe_ldext;
logic        ex_mem_pipe_regwrite;
logic [63:0] src_a_ex;
logic [63:0] src_b_ex;
logic [63:0] src_b_out;
logic [63:0] alu_result_ex;
logic [63:0] m_ext_res;
logic [63:0] arith_result_ex;
logic [63:0] pc_plus_imm;
logic [63:0] auipc;
logic        istaken_ex;
logic        pcsrc_ex;
logic        m_ext_done;
logic        m_ext_busy;
logic        m_ext_divby0;
logic        m_ext_of;
logic [3:0]  ex_main_decoder_amo_op;
logic        ex_main_decoder_amo;
logic        ex_main_decoder_lr;
logic        ex_main_decoder_sc;
logic        ex_cahce_read;

logic [63:0] new_mux_out;

//-------------MEM Intermediate Signals------------//
logic [63:0] read_data_mem;
logic [63:0] read_data_mem_extnd;
logic [63:0] mem_wb_pipe_alu_result;
logic [63:0] mem_wb_pipe_read_data;
logic [63:0] mem_wb_pipe_pc_plus_offset;
logic [4:0]  mem_wb_pipe_rd;
logic [1:0]  mem_wb_pipe_resultsrc;
logic        mem_wb_pipe_regwrite; 
logic [3:0]  mem_main_decoder_amo_op;
logic        mem_main_decoder_amo;
logic        mem_main_decoder_lr;
logic        mem_main_decoder_sc;
logic        load_fault;
logic        store_fault;
logic        amo_fault;
logic        d_chache_stall;
logic        mem_cahce_read;

//-------------WB Intermediate Signals-------------//
logic [63:0] result_wb;

//-------------HU Intermediate Signals-------------//
logic [1:0]  hu_forward_a;
logic [1:0]  hu_forward_b;
logic        hu_stall_if;
logic        hu_stall_id;
logic        hu_stall_ex;
logic        hu_stall_mem;
logic        hu_stall_wb;
logic        hu_flush_id;
logic        hu_flush_ex;
logic        hu_flush_mem;
logic        hu_flush_wb;
//----------------CSR Signals------------------------//
//---FETCH STAGE---//
logic [63:0] mepc_if;
logic [63:0] trap_addr_if;
logic [63:0] PCF_NEW;
logic [63:0] TRAP_PC;

//---DECODE STAGE---//
logic csr_src_sel_id;
logic [1:0]  csr_op_id;
logic        ecall_id;
logic        ebreak_id;
logic        mret_id;
logic        illegal_input_to_csr;
logic        csr_wen_id;

//---EXECUTION STAGE---//
logic csr_src_sel_ex;
logic [31:0] instr_ex;
logic [1:0]  csr_op_ex;
logic [63:0] csr_src_ex;
logic        mret_ex;
logic        instr_addr_miss_ex;
logic        csr_wen_ex;

//---MEMORY STAGE---//
logic [1:0]  csr_op_mem;
logic [31:0] instr_mem;
logic        mret_mem;
logic [63:0] csr_src_mem;
logic [63:0] pc_mem;
logic        csr_wen_mem;

//---WRITE BACK STAGE---//
logic [1:0]  csr_op_wb;
logic [31:0] instr_wb;
logic        mret_wb;
logic [63:0] csr_src_wb;
logic        trap_cntrl_wb;
logic        pc_cntrl_wb;
logic [63:0] csr_rdata_wb;
logic        csr_mem_flush;
logic        csr_ex_flush;
logic        csr_id_flush;
logic        csr_if_flush;
logic [63:0] csr_pc_trap_stg1;
logic [63:0] csr_pc;
logic [31:0] csr_instr_stg1;
logic [31:0] csr_instr;
logic        csr_wen_wb;
logic        csr_store_fault;

////////////////////////////////////////////////////
logic [63:0] branch_target_if;
logic        branch_taken_if;
logic        branch_valid_if;

logic [63:0] if_id_branch_target;
logic        if_id_branch_taken;
logic        if_id_branch_valid;


logic [63:0] id_ex_branch_target;
logic        id_ex_branch_taken;
logic        id_ex_branch_valid;


logic mis_prediction;
logic [63:0] recovery_address;

///////////////////////////////////////////////////

//----------------------------------//
//-------------IF Stage-------------//
//----------------------------------//

riscv_core_mux2x1
#(
  .XLEN (64)
)
u_riscv_core_mux2x1_stg1
(
  .i_mux2x1_in0 (auipc)
  ,.i_mux2x1_in1(alu_result_ex)
  ,.i_mux2x1_sel(id_ex_pipe_bjreg)
  ,.o_mux2x1_out(mux_to_stg2)
);
////////////////////////////////////////////////////////// TO BE REPLACED BY NEXT LOGIC PC
/*


riscv_core_mux2x1
#(
  .XLEN (64)
)
u_riscv_core_mux2x1_stg2
(
  .i_mux2x1_in0 (pc_plus_offset_if)
  ,.i_mux2x1_in1(mux_to_stg2)
  ,.i_mux2x1_sel(pcsrc_ex)
  ,.o_mux2x1_out(pcf)
);


*/

riscv_core_next_PC_logic 
u_riscv_core_next_PC_logic 
(
.i_next_PC_logic_misprediction(mis_prediction)
,.i_next_PC_logic_valid(branch_valid_if)
,.i_next_PC_logic_isTaken_BP(branch_taken_if)
,.i_next_PC_logic_predictedAddr(branch_target_if)
,.i_next_PC_logic_recoveredAddr(recovery_address)
,.i_next_PC_logic_PC_plus_offset(pc_plus_offset_if)
,.o_next_PC_logic_next_PC(pcf)
);








//////////////////////////////////////////////////
riscv_core_mux2x1
#(
  .XLEN (64)
)
u_riscv_core_mux2x1_TRAP_MUX
(
  .i_mux2x1_in0 (trap_addr_if)
  ,.i_mux2x1_in1(mepc_if)
  ,.i_mux2x1_sel(trap_cntrl_wb)
  ,.o_mux2x1_out(TRAP_PC)
);

riscv_core_mux2x1
#(
  .XLEN (64)
)
u_riscv_core_mux2x1_stg3
(
  .i_mux2x1_in0 (pcf)
  ,.i_mux2x1_in1(TRAP_PC)
  ,.i_mux2x1_sel(pc_cntrl_wb)
  ,.o_mux2x1_out(PCF_NEW)
);

riscv_core_pipe //pc FF
#(
  .W_PIPE_BUS (64)
)
u_riscv_core_pipe_pcf_if
(
  .i_pipe_clk    (i_riscv_core_clk)
  ,.i_pipe_rst_n (i_riscv_core_rst_n)
  ,.i_pipe_clr   (1'b0)
  ,.i_pipe_en_n  (hu_stall_if)
  ,.i_pipe_in    (PCF_NEW)
  ,.o_pipe_out   (if_pipe_pcf_new)
);

riscv_core_mux2x1
#(
  .XLEN (64)
)
u_riscv_core_compressed_offset
(
  .i_mux2x1_in0 (64'd4)
  ,.i_mux2x1_in1(64'd2)
  ,.i_mux2x1_sel(instr_is_compressed)
  ,.o_mux2x1_out(compressed_offset)
);

riscv_core_64bit_adder
#(
  .XLEN (64)
)
u_riscv_core_64bit_adder_pc_if
(
  .i_64bit_adder_srcA   (if_pipe_pcf_new)
  ,.i_64bit_adder_srcB  (compressed_offset)
  ,.o_64bit_adder_result(pc_plus_offset_if)
);

riscv_core_imem
#(
  .ALEN (64)
  ,.ILEN(32)
  ,.MWID(8)
  ,.MLEN(13000)
)
u_riscv_core_imem
(
  .i_imem_rst_n    (i_riscv_core_rst_n)
  ,.i_imem_address (if_pipe_pcf_new)
  ,.o_imem_rdata   (instr)
);

riscv_core_compressed_decoder
u_riscv_core_compressed_decoder
(
  .i_compressed_decoder_instr         (instr)
  ,.o_compressed_decoder_instr        (c_ext_instr_out)
  ,.o_compressed_decoder_is_compressed(instr_is_compressed)
  ,.o_compressed_decoder_illegal_instr(instr_is_illegal_comp)    // flag for illegal instr handling
);

///////////////////////////////////////////////////////////////////// HERE TO PUT THE BRANCH PREDICTON
riscv_core_branch_prediction 
u_riscv_core_branch_prediction
(
.i_clk(i_riscv_core_clk)
,.i_rst_n(i_riscv_core_rst_n)
,.i_if_pc(if_pipe_pcf_new)
,.o_branch_target(branch_target_if)
,.o_branch_taken(branch_taken_if)
,.o_branch_valid(branch_valid_if)
,.i_ex_pc(id_ex_pipe_pc)
,.i_update_branch_target(mux_to_stg2)
,.i_valid_branch_update(id_ex_pipe_branch)
,.i_valid_branch_taken_update(istaken_ex)
,.i_jump(id_ex_pipe_jump)
);



///////////////////////////////////////////////////////////////////////





//----------------------------------//
//------------IF/ID Pipe------------//
//----------------------------------//

riscv_core_pipe 
#(
  .W_PIPE_BUS (1)
)
u_riscv_core_pipe_instr_illigal_compressed_if_id
(
  .i_pipe_clk    (i_riscv_core_clk)
  ,.i_pipe_rst_n (i_riscv_core_rst_n)
  ,.i_pipe_clr   (hu_flush_id)
  ,.i_pipe_en_n  (hu_stall_id)
  ,.i_pipe_in    (instr_is_illegal_comp)
  ,.o_pipe_out   (instr_is_illegal_comp_id)
);


riscv_core_pipe 
#(
  .W_PIPE_BUS (64)
)
u_riscv_core_pipe_pc_if_id
(
  .i_pipe_clk    (i_riscv_core_clk)
  ,.i_pipe_rst_n (i_riscv_core_rst_n)
  ,.i_pipe_clr   (hu_flush_id)
  ,.i_pipe_en_n  (hu_stall_id)
  ,.i_pipe_in    (if_pipe_pcf_new)
  ,.o_pipe_out   (if_id_pipe_pc)
);

riscv_core_pipe 
#(
  .W_PIPE_BUS (32)
)
u_riscv_core_pipe_instr_if_id
(
  .i_pipe_clk    (i_riscv_core_clk)
  ,.i_pipe_rst_n (i_riscv_core_rst_n)
  ,.i_pipe_clr   (hu_flush_id)
  ,.i_pipe_en_n  (hu_stall_id)
  ,.i_pipe_in    (c_ext_instr_out)  // output of compressed decoder
  ,.o_pipe_out   (if_id_pipe_instr)
);

riscv_core_pipe 
#(
  .W_PIPE_BUS (64)
)
u_riscv_core_pipe_pc_plus_offset_if_id
(
  .i_pipe_clk    (i_riscv_core_clk)
  ,.i_pipe_rst_n (i_riscv_core_rst_n)
  ,.i_pipe_clr   (hu_flush_id)
  ,.i_pipe_en_n  (hu_stall_id)
  ,.i_pipe_in    (pc_plus_offset_if)
  ,.o_pipe_out   (if_id_pipe_pc_plus_offset)
);


riscv_core_pipe 
#(
  .W_PIPE_BUS (64)
)
u_riscv_core_pipe_if_id_branch_target
(
  .i_pipe_clk    (i_riscv_core_clk)
  ,.i_pipe_rst_n (i_riscv_core_rst_n)
  ,.i_pipe_clr   (hu_flush_id)
  ,.i_pipe_en_n  (hu_stall_id)
  ,.i_pipe_in    (branch_target_if)
  ,.o_pipe_out   (if_id_branch_target)
);


riscv_core_pipe 
#(
  .W_PIPE_BUS (1)
)
u_riscv_core_pipe_if_id_branch_valid
(
  .i_pipe_clk    (i_riscv_core_clk)
  ,.i_pipe_rst_n (i_riscv_core_rst_n)
  ,.i_pipe_clr   (hu_flush_id)
  ,.i_pipe_en_n  (hu_stall_id)
  ,.i_pipe_in    (branch_valid_if)
  ,.o_pipe_out   (if_id_branch_valid)
);


riscv_core_pipe 
#(
  .W_PIPE_BUS (1)
)
u_riscv_core_pipe_if_id_branch_taken
(
  .i_pipe_clk    (i_riscv_core_clk)
  ,.i_pipe_rst_n (i_riscv_core_rst_n)
  ,.i_pipe_clr   (hu_flush_id)
  ,.i_pipe_en_n  (hu_stall_id)
  ,.i_pipe_in    (branch_taken_if)
  ,.o_pipe_out   (if_id_branch_taken)
);

//----------------------------------//
//-------------ID Stage-------------//
//----------------------------------//

riscv_core_alu_decoder 
u_riscv_core_alu_decoder
(
  .i_alu_decoder_funct3     (if_id_pipe_instr[14:12])
  ,.i_alu_decoder_aluop     (alu_op_id)
  ,.i_alu_decoder_funct7_5  (if_id_pipe_instr[30])
  ,.i_alu_decoder_funct7_0  (if_id_pipe_instr[25])
  ,.i_alu_decoder_opcode_5  (if_id_pipe_instr[5])
  ,.o_alu_decoder_alucontrol(alu_control_id)
);

riscv_core_main_decoder_top
u_riscv_core_main_decoder
(
  .i_instr(if_id_pipe_instr)
  ,.i_main_decoder_if_illegal(instr_is_illegal_comp_id)
    // CSR OUTPUTS //
  ,.o_csr_control_ecall(ecall_id)
  ,.o_csr_control_ebreak(ebreak_id)
  ,.o_csr_control_mret(mret_id)
  ,.o_csr_control_csr_wen(csr_wen_id)
    // Main Decoder Outputs //
  ,.o_main_decoder_imsrc(immsrc_id)
  ,.o_main_decoder_UCtrl(uctrl_id)
  ,.o_main_decoder_resultsrc(resultsrc_id)
  ,.o_main_decoder_regwrite(regwrite_id)
  ,.o_main_decoder_alusrcB(alusrc_id)
  ,.o_main_decoder_memwrite(memwrite_id)
  ,.o_main_decoder_branch(branch_id)
  ,.o_main_decoder_jump(jump_id)
  ,.o_main_decoder_bjreg(bjreg_id)
  ,.o_main_decoder_size(size_id)
  ,.o_main_decoder_LdExt(ldext_id)
  ,.o_main_decoder_isword(isword_id)
  ,.o_main_decoder_aluop(alu_op_id)
  ,.o_main_decoder_imsel(im_sel_id)
  ,.o_main_decoder_new_mux_sel(new_mux_sel_id)
  ,.o_main_decoder_amo(id_main_decoder_amo)//////////////////////for atomic  connected
  ,.o_main_decoder_amo_op(id_main_decoder_amo_op)//////////////////for atomic  connected
  ,.o_main_decoder_lr(id_main_decoder_lr)//////////////////////for atomic  connected
  ,.o_main_decoder_sc(id_main_decoder_sc)//////////////////////for atomic  connected
  ,.o_main_decoder_src_sel(csr_src_sel_id)
  ,.o_main_decoder_op(csr_op_id)
  ,.o_main_decoder_illegal(illegal_input_to_csr)
  ,.o_main_decoder_read(id_cahce_read)
);

riscv_core_rf
u_riscv_core_rf
(
	.i_rf_clk	 (i_riscv_core_clk)
	,.i_rf_we3 (mem_wb_pipe_regwrite)
	,.i_rf_a1  (if_id_pipe_instr[19:15])
	,.i_rf_a2  (if_id_pipe_instr[24:20])
	,.i_rf_a3  (mem_wb_pipe_rd)
	,.i_rf_wd3 (result_wb)
	,.o_rf_rd1 (rd1_id)
	,.o_rf_rd2 (rd2_id)
);


riscv_core_immextend
u_riscv_core_immextend
(
  .i_immextend_imm     (if_id_pipe_instr[31:7]) //instruction [31:7]
  ,.i_immextend_immsrc (immsrc_id)              //cotrol from MAin decoder
  ,.o_immextend_out    (immext_id)              //extended output
);



//----------------------------------//
//------------ID/EX Pipe------------//
//----------------------------------//


//-----------Data Signals-----------//
riscv_core_pipe 
#(
  .W_PIPE_BUS (64)
)
u_riscv_core_pipe_rf_rd1_id_ex
(
  .i_pipe_clk    (i_riscv_core_clk)
  ,.i_pipe_rst_n (i_riscv_core_rst_n)
  ,.i_pipe_clr   (hu_flush_ex)
  ,.i_pipe_en_n  (hu_stall_ex)
  ,.i_pipe_in    (rd1_id)
  ,.o_pipe_out   (id_ex_pipe_rd1)
);

riscv_core_pipe 
#(
  .W_PIPE_BUS (64)
)
u_riscv_core_pipe_rf_rd2_id_ex
(
  .i_pipe_clk    (i_riscv_core_clk)
  ,.i_pipe_rst_n (i_riscv_core_rst_n)
  ,.i_pipe_clr   (hu_flush_ex)
  ,.i_pipe_en_n  (hu_stall_ex)
  ,.i_pipe_in    (rd2_id)
  ,.o_pipe_out   (id_ex_pipe_rd2)
);

riscv_core_pipe 
#(
  .W_PIPE_BUS (3)
)
u_riscv_core_pipe_funct3_id_ex
(
  .i_pipe_clk    (i_riscv_core_clk)
  ,.i_pipe_rst_n (i_riscv_core_rst_n)
  ,.i_pipe_clr   (hu_flush_ex)
  ,.i_pipe_en_n  (hu_stall_ex)
  ,.i_pipe_in    (if_id_pipe_instr[14:12]) // funct3
  ,.o_pipe_out   (id_ex_pipe_funct3)
);

riscv_core_pipe 
#(
  .W_PIPE_BUS (64)
)
u_riscv_core_pipe_pc_id_ex
(
  .i_pipe_clk    (i_riscv_core_clk)
  ,.i_pipe_rst_n (i_riscv_core_rst_n)
  ,.i_pipe_clr   (hu_flush_ex)
  ,.i_pipe_en_n  (hu_stall_ex)
  ,.i_pipe_in    (if_id_pipe_pc)
  ,.o_pipe_out   (id_ex_pipe_pc)
);

riscv_core_pipe 
#(
  .W_PIPE_BUS (32)
)
u_riscv_core_pipe_csr_addr_id_ex_pipe
(
  .i_pipe_clk    (i_riscv_core_clk)
  ,.i_pipe_rst_n (i_riscv_core_rst_n)
  ,.i_pipe_clr   (hu_flush_ex)
  ,.i_pipe_en_n  (hu_stall_ex)
  ,.i_pipe_in    (if_id_pipe_instr)
  ,.o_pipe_out   (instr_ex)
);

riscv_core_pipe 
#(
  .W_PIPE_BUS (5)
)
u_riscv_core_pipe_rs1_id_ex
(
  .i_pipe_clk    (i_riscv_core_clk)
  ,.i_pipe_rst_n (i_riscv_core_rst_n)
  ,.i_pipe_clr   (hu_flush_ex)
  ,.i_pipe_en_n  (hu_stall_ex)
  ,.i_pipe_in    (if_id_pipe_instr[19:15]) // rs1D
  ,.o_pipe_out   (id_ex_pipe_rs1)
);

riscv_core_pipe 
#(
  .W_PIPE_BUS (5)
)
u_riscv_core_pipe_rs2_id_ex
(
  .i_pipe_clk    (i_riscv_core_clk)
  ,.i_pipe_rst_n (i_riscv_core_rst_n)
  ,.i_pipe_clr   (hu_flush_ex)
  ,.i_pipe_en_n  (hu_stall_ex)
  ,.i_pipe_in    (if_id_pipe_instr[24:20]) // rs2D
  ,.o_pipe_out   (id_ex_pipe_rs2)
);

riscv_core_pipe 
#(
  .W_PIPE_BUS (5)
)
u_riscv_core_pipe_rd_id_ex
(
  .i_pipe_clk    (i_riscv_core_clk)
  ,.i_pipe_rst_n (i_riscv_core_rst_n)
  ,.i_pipe_clr   (hu_flush_ex)
  ,.i_pipe_en_n  (hu_stall_ex)
  ,.i_pipe_in    (if_id_pipe_instr[11:7]) // rdD
  ,.o_pipe_out   (id_ex_pipe_rd)
);

riscv_core_pipe 
#(
  .W_PIPE_BUS (64)
)
u_riscv_core_pipe_pc_plus_offset_id_ex
(
  .i_pipe_clk    (i_riscv_core_clk)
  ,.i_pipe_rst_n (i_riscv_core_rst_n)
  ,.i_pipe_clr   (hu_flush_ex)
  ,.i_pipe_en_n  (hu_stall_ex)
  ,.i_pipe_in    (if_id_pipe_pc_plus_offset) // (pc+4)D
  ,.o_pipe_out   (id_ex_pipe_pc_plus_offset)
);

riscv_core_pipe 
#(
  .W_PIPE_BUS (64)
)
u_riscv_core_pipe_immext_id_ex
(
  .i_pipe_clk    (i_riscv_core_clk)
  ,.i_pipe_rst_n (i_riscv_core_rst_n)
  ,.i_pipe_clr   (hu_flush_ex)
  ,.i_pipe_en_n  (hu_stall_ex)
  ,.i_pipe_in    (immext_id)
  ,.o_pipe_out   (id_ex_pipe_imm)
);



//---------Control Signals----------//
riscv_core_pipe 
#(
  .W_PIPE_BUS (2)
)
u_riscv_core_pipe_resultsrc_id_ex
(
  .i_pipe_clk    (i_riscv_core_clk)
  ,.i_pipe_rst_n (i_riscv_core_rst_n)
  ,.i_pipe_clr   (hu_flush_ex)
  ,.i_pipe_en_n  (hu_stall_ex)
  ,.i_pipe_in    (resultsrc_id)
  ,.o_pipe_out   (id_ex_pipe_resultsrc)
);


riscv_core_pipe 
#(
  .W_PIPE_BUS (1)
)
u_riscv_core_pipe_csr_src_sel_id_ex
(
  .i_pipe_clk    (i_riscv_core_clk)
  ,.i_pipe_rst_n (i_riscv_core_rst_n)
  ,.i_pipe_clr   (hu_flush_ex)
  ,.i_pipe_en_n  (hu_stall_ex)
  ,.i_pipe_in    (csr_src_sel_id)
  ,.o_pipe_out   (csr_src_sel_ex)
);




riscv_core_pipe 
#(
  .W_PIPE_BUS (4)
)
u_riscv_core_pipe_amo_op_id_ex
(
  .i_pipe_clk    (i_riscv_core_clk)
  ,.i_pipe_rst_n (i_riscv_core_rst_n)
  ,.i_pipe_clr   (hu_flush_ex)
  ,.i_pipe_en_n  (hu_stall_ex)
  ,.i_pipe_in    (id_main_decoder_amo_op)
  ,.o_pipe_out   (ex_main_decoder_amo_op)
);


riscv_core_pipe 
#(
  .W_PIPE_BUS (1)
)
u_riscv_core_pipe_amo_id_ex
(
  .i_pipe_clk    (i_riscv_core_clk)
  ,.i_pipe_rst_n (i_riscv_core_rst_n)
  ,.i_pipe_clr   (hu_flush_ex)
  ,.i_pipe_en_n  (hu_stall_ex)
  ,.i_pipe_in    (id_main_decoder_amo)
  ,.o_pipe_out   (ex_main_decoder_amo)
);


riscv_core_pipe 
#(
  .W_PIPE_BUS (1)
)
u_riscv_core_pipe_cache_read_id_ex
(
  .i_pipe_clk    (i_riscv_core_clk)
  ,.i_pipe_rst_n (i_riscv_core_rst_n)
  ,.i_pipe_clr   (hu_flush_ex)
  ,.i_pipe_en_n  (hu_stall_ex)
  ,.i_pipe_in    (id_cahce_read)
  ,.o_pipe_out   (ex_cahce_read)
);


riscv_core_pipe 
#(
  .W_PIPE_BUS (1)
)
u_riscv_core_pipe_lr_id_ex
(
  .i_pipe_clk    (i_riscv_core_clk)
  ,.i_pipe_rst_n (i_riscv_core_rst_n)
  ,.i_pipe_clr   (hu_flush_ex)
  ,.i_pipe_en_n  (hu_stall_ex)
  ,.i_pipe_in    (id_main_decoder_lr)
  ,.o_pipe_out   (ex_main_decoder_lr)
);


riscv_core_pipe 
#(
  .W_PIPE_BUS (1)
)
u_riscv_core_pipe_sc_id_ex
(
  .i_pipe_clk    (i_riscv_core_clk)
  ,.i_pipe_rst_n (i_riscv_core_rst_n)
  ,.i_pipe_clr   (hu_flush_ex)
  ,.i_pipe_en_n  (hu_stall_ex)
  ,.i_pipe_in    (id_main_decoder_sc)
  ,.o_pipe_out   (ex_main_decoder_sc)
);



riscv_core_pipe 
#(
  .W_PIPE_BUS (2)
)
u_riscv_core_pipe_cre_op_id_ex
(
  .i_pipe_clk    (i_riscv_core_clk)
  ,.i_pipe_rst_n (i_riscv_core_rst_n)
  ,.i_pipe_clr   (hu_flush_ex)
  ,.i_pipe_en_n  (hu_stall_ex)
  ,.i_pipe_in    (csr_op_id)
  ,.o_pipe_out   (csr_op_ex)
);


riscv_core_pipe 
#(
  .W_PIPE_BUS (2)
)
u_riscv_core_pipe_size_id_ex
(
  .i_pipe_clk    (i_riscv_core_clk)
  ,.i_pipe_rst_n (i_riscv_core_rst_n)
  ,.i_pipe_clr   (hu_flush_ex)
  ,.i_pipe_en_n  (hu_stall_ex)
  ,.i_pipe_in    (size_id)
  ,.o_pipe_out   (id_ex_pipe_size)
);

riscv_core_pipe 
#(
  .W_PIPE_BUS (4)
)
u_riscv_core_pipe_alucontrol_id_ex
(
  .i_pipe_clk    (i_riscv_core_clk)
  ,.i_pipe_rst_n (i_riscv_core_rst_n)
  ,.i_pipe_clr   (hu_flush_ex)
  ,.i_pipe_en_n  (hu_stall_ex)
  ,.i_pipe_in    (alu_control_id)
  ,.o_pipe_out   (id_ex_pipe_alu_control)
);

riscv_core_pipe 
#(
  .W_PIPE_BUS (1)
)
u_riscv_core_pipe_bjreg_id_ex
(
  .i_pipe_clk    (i_riscv_core_clk)
  ,.i_pipe_rst_n (i_riscv_core_rst_n)
  ,.i_pipe_clr   (hu_flush_ex)
  ,.i_pipe_en_n  (hu_stall_ex)
  ,.i_pipe_in    (bjreg_id)
  ,.o_pipe_out   (id_ex_pipe_bjreg)
);

riscv_core_pipe 
#(
  .W_PIPE_BUS (1)
)
u_riscv_core_pipe_mret_id_ex
(
  .i_pipe_clk    (i_riscv_core_clk)
  ,.i_pipe_rst_n (i_riscv_core_rst_n)
  ,.i_pipe_clr   (hu_flush_ex)
  ,.i_pipe_en_n  (hu_stall_ex)
  ,.i_pipe_in    (mret_id)
  ,.o_pipe_out   (mret_ex)
);

riscv_core_pipe 
#(
  .W_PIPE_BUS (1)
)
u_riscv_core_pipe_regwrite_id_ex
(
  .i_pipe_clk    (i_riscv_core_clk)
  ,.i_pipe_rst_n (i_riscv_core_rst_n)
  ,.i_pipe_clr   (hu_flush_ex)
  ,.i_pipe_en_n  (hu_stall_ex)
  ,.i_pipe_in    (regwrite_id)
  ,.o_pipe_out   (id_ex_pipe_regwrite)
);

riscv_core_pipe 
#(
  .W_PIPE_BUS (1)
)
u_riscv_core_pipe_branch_id_ex
(
  .i_pipe_clk    (i_riscv_core_clk)
  ,.i_pipe_rst_n (i_riscv_core_rst_n)
  ,.i_pipe_clr   (hu_flush_ex)
  ,.i_pipe_en_n  (hu_stall_ex)
  ,.i_pipe_in    (branch_id)
  ,.o_pipe_out   (id_ex_pipe_branch)
);

riscv_core_pipe 
#(
  .W_PIPE_BUS (1)
)
u_riscv_core_pipe_jump_id_ex
(
  .i_pipe_clk    (i_riscv_core_clk)
  ,.i_pipe_rst_n (i_riscv_core_rst_n)
  ,.i_pipe_clr   (hu_flush_ex)
  ,.i_pipe_en_n  (hu_stall_ex)
  ,.i_pipe_in    (jump_id)
  ,.o_pipe_out   (id_ex_pipe_jump)
);


riscv_core_pipe 
#(
  .W_PIPE_BUS (1)
)
u_riscv_core_pipe_memwrite_id_ex
(
  .i_pipe_clk    (i_riscv_core_clk)
  ,.i_pipe_rst_n (i_riscv_core_rst_n)
  ,.i_pipe_clr   (hu_flush_ex)
  ,.i_pipe_en_n  (hu_stall_ex)
  ,.i_pipe_in    (memwrite_id)
  ,.o_pipe_out   (id_ex_pipe_memwrite)
);

riscv_core_pipe 
#(
  .W_PIPE_BUS (1)
)
u_riscv_core_pipe_alusrc_id_ex
(
  .i_pipe_clk    (i_riscv_core_clk)
  ,.i_pipe_rst_n (i_riscv_core_rst_n)
  ,.i_pipe_clr   (hu_flush_ex)
  ,.i_pipe_en_n  (hu_stall_ex)
  ,.i_pipe_in    (alusrc_id)
  ,.o_pipe_out   (id_ex_pipe_alu_srcb)
);

riscv_core_pipe 
#(
  .W_PIPE_BUS (1)
)
u_riscv_core_pipe_ldext_id_ex
(
  .i_pipe_clk    (i_riscv_core_clk)
  ,.i_pipe_rst_n (i_riscv_core_rst_n)
  ,.i_pipe_clr   (hu_flush_ex)
  ,.i_pipe_en_n  (hu_stall_ex)
  ,.i_pipe_in    (ldext_id)
  ,.o_pipe_out   (id_ex_pipe_ldext)
);

riscv_core_pipe 
#(
  .W_PIPE_BUS (1)
)
u_riscv_core_pipe_uctrl_id_ex
(
  .i_pipe_clk    (i_riscv_core_clk)
  ,.i_pipe_rst_n (i_riscv_core_rst_n)
  ,.i_pipe_clr   (hu_flush_ex)
  ,.i_pipe_en_n  (hu_stall_ex)
  ,.i_pipe_in    (uctrl_id)
  ,.o_pipe_out   (id_ex_pipe_uctrl)
);

riscv_core_pipe 
#(
  .W_PIPE_BUS (1)
)
u_riscv_core_pipe_isword_id_ex
(
  .i_pipe_clk    (i_riscv_core_clk)
  ,.i_pipe_rst_n (i_riscv_core_rst_n)
  ,.i_pipe_clr   (hu_flush_ex)
  ,.i_pipe_en_n  (hu_stall_ex)
  ,.i_pipe_in    (isword_id)
  ,.o_pipe_out   (id_ex_pipe_isword)
);

riscv_core_pipe 
#(
  .W_PIPE_BUS (1)
)
u_riscv_core_pipe_imul_id_ex
(
  .i_pipe_clk    (i_riscv_core_clk)
  ,.i_pipe_rst_n (i_riscv_core_rst_n)
  ,.i_pipe_clr   (hu_flush_ex)
  ,.i_pipe_en_n  (hu_stall_ex)
  ,.i_pipe_in    (im_sel_id)
  ,.o_pipe_out   (id_ex_pipe_im_sel)
);

riscv_core_pipe 
#(
  .W_PIPE_BUS (1)
)
u_riscv_core_pipe_new_mux_id_ex
(
  .i_pipe_clk    (i_riscv_core_clk)
  ,.i_pipe_rst_n (i_riscv_core_rst_n)
  ,.i_pipe_clr   (hu_flush_ex)
  ,.i_pipe_en_n  (hu_stall_ex)
  ,.i_pipe_in    (new_mux_sel_id)
  ,.o_pipe_out   (id_ex_pipe_new_mux_sel)
);

riscv_core_pipe 
#(
  .W_PIPE_BUS (1)
)
u_riscv_core_pipe_csr_wen_id_ex
(
  .i_pipe_clk    (i_riscv_core_clk)
  ,.i_pipe_rst_n (i_riscv_core_rst_n)
  ,.i_pipe_clr   (hu_flush_ex)
  ,.i_pipe_en_n  (hu_stall_ex)
  ,.i_pipe_in    (csr_wen_id)
  ,.o_pipe_out   (csr_wen_ex)
);

//////////////////////////////// Branch prediction pipes/////////////////////////// //




riscv_core_pipe 
#(
  .W_PIPE_BUS (64)
)
u_riscv_core_pipe_id_ex_branch_target
(
  .i_pipe_clk    (i_riscv_core_clk)
  ,.i_pipe_rst_n (i_riscv_core_rst_n)
  ,.i_pipe_clr   (hu_flush_id)
  ,.i_pipe_en_n  (hu_stall_id)
  ,.i_pipe_in    (if_id_branch_target)
  ,.o_pipe_out   (id_ex_branch_target)
);


riscv_core_pipe 
#(
  .W_PIPE_BUS (1)
)
u_riscv_core_pipe_id_ex_branch_valid
(
  .i_pipe_clk    (i_riscv_core_clk)
  ,.i_pipe_rst_n (i_riscv_core_rst_n)
  ,.i_pipe_clr   (hu_flush_id)
  ,.i_pipe_en_n  (hu_stall_id)
  ,.i_pipe_in    (if_id_branch_valid)
  ,.o_pipe_out   (id_ex_branch_valid)
);


riscv_core_pipe 
#(
  .W_PIPE_BUS (1)
)
u_riscv_core_pipe_id_ex_branch_taken
(
  .i_pipe_clk    (i_riscv_core_clk)
  ,.i_pipe_rst_n (i_riscv_core_rst_n)
  ,.i_pipe_clr   (hu_flush_id)
  ,.i_pipe_en_n  (hu_stall_id)
  ,.i_pipe_in    (if_id_branch_taken)
  ,.o_pipe_out   (id_ex_branch_taken)
);














//----------------------------------//
//-------------EX Stage-------------//
//----------------------------------//
//////////////////////////////////////////////////////////////////////////////////////////
riscv_core_mux2x1
#(
  .XLEN (64)
)
u_riscv_core_mux2x1_csr_src
(
  .i_mux2x1_in0 (src_a_ex)
  ,.i_mux2x1_in1(id_ex_pipe_imm)
  ,.i_mux2x1_sel(csr_src_sel_ex)
  ,.o_mux2x1_out(csr_src_ex)
);

riscv_core_mux3x1
#(
  .XLEN (64)
)
u_riscv_core_mux3x1_srca
(
  .i_mux3x1_in0 (id_ex_pipe_rd1)
  ,.i_mux3x1_in1(result_wb)
  ,.i_mux3x1_in2(ex_mem_pipe_alu_result)
  ,.i_mux3x1_sel(hu_forward_a)
  ,.o_mux3x1_out(src_a_ex)
);

riscv_core_mux3x1
#(
  .XLEN (64)
)
u_riscv_core_mux3x1_srcb
(
  .i_mux3x1_in0 (id_ex_pipe_rd2)
  ,.i_mux3x1_in1(result_wb)
  ,.i_mux3x1_in2(ex_mem_pipe_alu_result)
  ,.i_mux3x1_sel(hu_forward_b)
  ,.o_mux3x1_out(src_b_out)
);

riscv_core_mux2x1
#(
  .XLEN (64)
)
u_riscv_core_mux2x1_srcb
(
  .i_mux2x1_in0 (src_b_out)
  ,.i_mux2x1_in1(id_ex_pipe_imm)
  ,.i_mux2x1_sel(id_ex_pipe_alu_srcb)
  ,.o_mux2x1_out(src_b_ex)
);

riscv_core_alu
#(
  .XLEN (64)
)
u_riscv_core_alu
(
  .i_alu_srcA    (src_a_ex)
  ,.i_alu_srcB   (src_b_ex)
  ,.i_alu_control(id_ex_pipe_alu_control)
  ,.i_alu_isword (id_ex_pipe_isword)
  ,.o_alu_result (alu_result_ex)
);

riscv_core_mul_div
#(
  .XLEN(64)
)
u_riscv_core_mul_div
(
  .i_mul_div_clk         (i_riscv_core_clk)
  ,.i_mul_div_rstn       (i_riscv_core_rst_n)
  ,.i_mul_div_srcA       (src_a_ex)
  ,.i_mul_div_srcB       (src_b_out)
  ,.i_mul_div_control    (id_ex_pipe_alu_control)
  ,.i_mul_div_isword     (id_ex_pipe_isword)
  ,.i_mul_div_en         (id_ex_pipe_im_sel) // is_MulE
  ,.o_mul_div_result     (m_ext_res)
  ,.o_mul_div_busy       (m_ext_busy)
  ,.o_mul_div_done       (m_ext_done)
  ,.o_mul_div_overflow   (m_ext_of)
  ,.o_mul_div_div_by_zero(m_ext_divby0)/////////////////for csr direct
);

riscv_core_mux2x1
#(
  .XLEN (64)
)
u_riscv_core_mux2x1_arith_out
(
  .i_mux2x1_in0 (alu_result_ex) 
  ,.i_mux2x1_in1(m_ext_res)// M out
  ,.i_mux2x1_sel(id_ex_pipe_im_sel) // is_mulE
  ,.o_mux2x1_out(arith_result_ex) 
);

riscv_core_branch_unit
#(
  .XLEN (64)
)
u_riscv_core_branch_unit
(
  .i_branch_unit_srcA    (src_a_ex)
  ,.i_branch_unit_srcB   (src_b_out)
  ,.i_branch_unit_funct3 (id_ex_pipe_funct3)
  ,.o_branch_unit_istaken(istaken_ex)
  ,.i_branch_unit_targetPC(mux_to_stg2[1:0])
  ,.i_branch_unit_enable(id_ex_pipe_branch)
  ,.o_branch_unit_addr_mismatch(instr_addr_miss_ex) ////////////////for CSR direct
);
///////////////////////////////////////////////////// HERE TO ADD THE RECOVERY MODULE

riscv_core_prediction_recovery
u_riscv_core_prediction_recovery
(
.branch(id_ex_pipe_branch)
,.jump(id_ex_pipe_jump)
,.i_valid(id_ex_branch_valid)
,.i_btanch_Taken(id_ex_branch_taken)
,.i_target_address(id_ex_branch_target)
,.i_ex_address(mux_to_stg2)
,.i_pc_plus_offset(id_ex_pipe_pc_plus_offset)
,.i_is_taken(istaken_ex)
,.o_mis_prediction(mis_prediction)
,.o_recovery_address(recovery_address)
);







///////////////////////////////////////////////////////


//////////////////////////////////////////////////// TO BE REMOVED AND REPLACED BY AN "OR" GATE
/*

riscv_core_pcsrc 
u_riscv_core_pcsrc
(
  .i_pcsrc_istaken   (istaken_ex)
  ,.i_pcsrc_branch_ex(id_ex_pipe_branch)
  ,.i_pcsrc_jump_ex  (id_ex_pipe_jump)
  ,.o_pcsrc_pcsrc_ex (pcsrc_ex)
);


*/
/////////////////////////////////////////////////////
riscv_core_64bit_adder
#(
  .XLEN (64)
)
u_riscv_core_64bit_adder_target_pc_ex
(
  .i_64bit_adder_srcA   (id_ex_pipe_pc)
  ,.i_64bit_adder_srcB  (id_ex_pipe_imm)
  ,.o_64bit_adder_result(pc_plus_imm)
);

riscv_core_mux2x1
#(
  .XLEN (64)
)
u_riscv_core_mux2x1_imm
(
  .i_mux2x1_in0 (pc_plus_imm)
  ,.i_mux2x1_in1(id_ex_pipe_imm)
  ,.i_mux2x1_sel(id_ex_pipe_uctrl)
  ,.o_mux2x1_out(auipc)
);


riscv_core_mux2x1
#(
  .XLEN (64)
)
u_riscv_core_mux2x1_new_mux
(
  .i_mux2x1_in0 (arith_result_ex)
  ,.i_mux2x1_in1(auipc)
  ,.i_mux2x1_sel(id_ex_pipe_new_mux_sel)
  ,.o_mux2x1_out(new_mux_out)
);

//----------------------------------//
//-----------EX/MEM Pipe------------//
//----------------------------------//

//-----------Data Signals-----------//
riscv_core_pipe 
#(
  .W_PIPE_BUS (64)
)
u_riscv_core_pipe_alu_result_ex_mem
(
  .i_pipe_clk    (i_riscv_core_clk)
  ,.i_pipe_rst_n (i_riscv_core_rst_n)
  ,.i_pipe_clr   (hu_flush_mem)
  ,.i_pipe_en_n  (hu_stall_mem)
  ,.i_pipe_in    (new_mux_out)
  ,.o_pipe_out   (ex_mem_pipe_alu_result)
);

riscv_core_pipe 
#(
  .W_PIPE_BUS (64)
)
u_riscv_core_pipe_wd_ex_mem
(
  .i_pipe_clk    (i_riscv_core_clk)
  ,.i_pipe_rst_n (i_riscv_core_rst_n)
  ,.i_pipe_clr   (hu_flush_mem)
  ,.i_pipe_en_n  (hu_stall_mem)
  ,.i_pipe_in    (src_b_out)
  ,.o_pipe_out   (ex_mem_pipe_wd)
);

riscv_core_pipe 
#(
  .W_PIPE_BUS (64)
)
u_riscv_core_pipe_csr_src_ex_mem
(
  .i_pipe_clk    (i_riscv_core_clk)
  ,.i_pipe_rst_n (i_riscv_core_rst_n)
  ,.i_pipe_clr   (hu_flush_mem)
  ,.i_pipe_en_n  (hu_stall_mem)
  ,.i_pipe_in    (csr_src_ex)
  ,.o_pipe_out   (csr_src_mem)
);



riscv_core_pipe 
#(
  .W_PIPE_BUS (5)
)
u_riscv_core_pipe_rd_ex_mem
(
  .i_pipe_clk    (i_riscv_core_clk)
  ,.i_pipe_rst_n (i_riscv_core_rst_n)
  ,.i_pipe_clr   (hu_flush_mem)
  ,.i_pipe_en_n  (hu_stall_mem)
  ,.i_pipe_in    (id_ex_pipe_rd)
  ,.o_pipe_out   (ex_mem_pipe_rd)
);

riscv_core_pipe 
#(
  .W_PIPE_BUS (64)
)
u_riscv_core_pipe_pc_plus_ex_mem
(
  .i_pipe_clk    (i_riscv_core_clk)
  ,.i_pipe_rst_n (i_riscv_core_rst_n)
  ,.i_pipe_clr   (hu_flush_mem)
  ,.i_pipe_en_n  (hu_stall_mem)
  ,.i_pipe_in    (id_ex_pipe_pc_plus_offset)
  ,.o_pipe_out   (ex_mem_pipe_pc_plus_offset)
);

riscv_core_pipe 
#(
  .W_PIPE_BUS (32)
)
u_riscv_core_pipe_instruction_ex_mem
(
  .i_pipe_clk    (i_riscv_core_clk)
  ,.i_pipe_rst_n (i_riscv_core_rst_n)
  ,.i_pipe_clr   (hu_flush_mem)
  ,.i_pipe_en_n  (hu_stall_mem)
  ,.i_pipe_in    (instr_ex)
  ,.o_pipe_out   (instr_mem)
);

riscv_core_pipe 
#(
  .W_PIPE_BUS (64)
)
u_riscv_core_pipe_pc_ex_mem
(
  .i_pipe_clk    (i_riscv_core_clk)
  ,.i_pipe_rst_n (i_riscv_core_rst_n)
  ,.i_pipe_clr   (hu_flush_mem)
  ,.i_pipe_en_n  (hu_stall_mem)
  ,.i_pipe_in    (id_ex_pipe_pc)
  ,.o_pipe_out   (pc_mem)
);

//---------Control Signals----------//
riscv_core_pipe 
#(
  .W_PIPE_BUS (2)
)
u_riscv_core_pipe_resultsrc_ex_mem
(
  .i_pipe_clk    (i_riscv_core_clk)
  ,.i_pipe_rst_n (i_riscv_core_rst_n)
  ,.i_pipe_clr   (hu_flush_mem)
  ,.i_pipe_en_n  (hu_stall_mem)
  ,.i_pipe_in    (id_ex_pipe_resultsrc)
  ,.o_pipe_out   (ex_mem_pipe_resultsrc)
);

riscv_core_pipe 
#(
  .W_PIPE_BUS (4)
)
u_riscv_core_pipe_amo_op_ex_mem
(
  .i_pipe_clk    (i_riscv_core_clk)
  ,.i_pipe_rst_n (i_riscv_core_rst_n)
  ,.i_pipe_clr   (hu_flush_mem)
  ,.i_pipe_en_n  (hu_stall_mem)
  ,.i_pipe_in    (ex_main_decoder_amo_op)
  ,.o_pipe_out   (mem_main_decoder_amo_op)
);

riscv_core_pipe 
#(
  .W_PIPE_BUS (1)
)
u_riscv_core_pipe_amo_ex_mem
(
  .i_pipe_clk    (i_riscv_core_clk)
  ,.i_pipe_rst_n (i_riscv_core_rst_n)
  ,.i_pipe_clr   (hu_flush_mem)
  ,.i_pipe_en_n  (hu_stall_mem)
  ,.i_pipe_in    (ex_main_decoder_amo)
  ,.o_pipe_out   (mem_main_decoder_amo)
);

riscv_core_pipe 
#(
  .W_PIPE_BUS (1)
)
u_riscv_core_pipe_cache_read_ex_mem
(
  .i_pipe_clk    (i_riscv_core_clk)
  ,.i_pipe_rst_n (i_riscv_core_rst_n)
  ,.i_pipe_clr   (hu_flush_mem)
  ,.i_pipe_en_n  (hu_stall_mem)
  ,.i_pipe_in    (ex_cahce_read)
  ,.o_pipe_out   (mem_cahce_read)
);

riscv_core_pipe 
#(
  .W_PIPE_BUS (1)
)
u_riscv_core_pipe_lr_ex_mem
(
  .i_pipe_clk    (i_riscv_core_clk)
  ,.i_pipe_rst_n (i_riscv_core_rst_n)
  ,.i_pipe_clr   (hu_flush_mem)
  ,.i_pipe_en_n  (hu_stall_mem)
  ,.i_pipe_in    (ex_main_decoder_lr)
  ,.o_pipe_out   (mem_main_decoder_lr)
);


riscv_core_pipe 
#(
  .W_PIPE_BUS (1)
)
u_riscv_core_pipe_sc_ex_mem
(
  .i_pipe_clk    (i_riscv_core_clk)
  ,.i_pipe_rst_n (i_riscv_core_rst_n)
  ,.i_pipe_clr   (hu_flush_mem)
  ,.i_pipe_en_n  (hu_stall_mem)
  ,.i_pipe_in    (ex_main_decoder_sc)
  ,.o_pipe_out   (mem_main_decoder_sc)
);


riscv_core_pipe 
#(
  .W_PIPE_BUS (1)
)
u_riscv_core_pipe_memwrite_ex_mem
(
  .i_pipe_clk    (i_riscv_core_clk)
  ,.i_pipe_rst_n (i_riscv_core_rst_n)
  ,.i_pipe_clr   (hu_flush_mem)
  ,.i_pipe_en_n  (hu_stall_mem)
  ,.i_pipe_in    (id_ex_pipe_memwrite)
  ,.o_pipe_out   (ex_mem_pipe_memwrite)
);


riscv_core_pipe 
#(
  .W_PIPE_BUS (1)
)
u_riscv_core_pipe_mret_ex_mem
(
  .i_pipe_clk    (i_riscv_core_clk)
  ,.i_pipe_rst_n (i_riscv_core_rst_n)
  ,.i_pipe_clr   (hu_flush_mem)
  ,.i_pipe_en_n  (hu_stall_mem)
  ,.i_pipe_in    (mret_ex)
  ,.o_pipe_out   (mret_mem)
);


riscv_core_pipe 
#(
  .W_PIPE_BUS (2)
)
u_riscv_core_pipe_size_ex_mem
(
  .i_pipe_clk    (i_riscv_core_clk)
  ,.i_pipe_rst_n (i_riscv_core_rst_n)
  ,.i_pipe_clr   (hu_flush_mem)
  ,.i_pipe_en_n  (hu_stall_mem)
  ,.i_pipe_in    (id_ex_pipe_size)
  ,.o_pipe_out   (ex_mem_pipe_size)
);

riscv_core_pipe 
#(
  .W_PIPE_BUS (2)
)
u_riscv_core_pipe_csr_op_ex_mem
(
  .i_pipe_clk    (i_riscv_core_clk)
  ,.i_pipe_rst_n (i_riscv_core_rst_n)
  ,.i_pipe_clr   (hu_flush_mem)
  ,.i_pipe_en_n  (hu_stall_mem)
  ,.i_pipe_in    (csr_op_ex)
  ,.o_pipe_out   (csr_op_mem)
);


riscv_core_pipe 
#(
  .W_PIPE_BUS (1)
)
u_riscv_core_pipe_ldext_ex_mem
(
  .i_pipe_clk    (i_riscv_core_clk)
  ,.i_pipe_rst_n (i_riscv_core_rst_n)
  ,.i_pipe_clr   (hu_flush_mem)
  ,.i_pipe_en_n  (hu_stall_mem)
  ,.i_pipe_in    (id_ex_pipe_ldext)
  ,.o_pipe_out   (ex_mem_pipe_ldext)
);

riscv_core_pipe 
#(
  .W_PIPE_BUS (1)
)
u_riscv_core_pipe_regwrite_ex_mem
(
  .i_pipe_clk    (i_riscv_core_clk)
  ,.i_pipe_rst_n (i_riscv_core_rst_n)
  ,.i_pipe_clr   (hu_flush_mem)
  ,.i_pipe_en_n  (hu_stall_mem)
  ,.i_pipe_in    (id_ex_pipe_regwrite)
  ,.o_pipe_out   (ex_mem_pipe_regwrite)
);

riscv_core_pipe 
#(
  .W_PIPE_BUS (1)
)
u_riscv_core_pipe_csr_wen_ex_mem
(
  .i_pipe_clk    (i_riscv_core_clk)
  ,.i_pipe_rst_n (i_riscv_core_rst_n)
  ,.i_pipe_clr   (hu_flush_mem)
  ,.i_pipe_en_n  (hu_stall_mem)
  ,.i_pipe_in    (csr_wen_ex)
  ,.o_pipe_out   (csr_wen_mem)
);

//----------------------------------//
//-------------MEM Stage------------//
//----------------------------------//

logic [63:0] mem_read_address,o_mem_write_data,o_mem_write_address;
logic [255:0] i_block_from_axi;
logic mem_read_req,mem_read_done,i_mem_write_done,o_mem_write_valid;
riscv_core_dcache_top#(
    .BLOCK_OFFSET(2)
    ,.INDEX_WIDTH(7)
    ,.TAG_WIDTH(20)
    ,.CORE_DATA_WIDTH(64)
    ,.ADDR_WIDTH(64)
    ,.AXI_DATA_WIDTH(256)
)
u_riscv_core_dcache_top
(
    // Interface with CORE//
    .i_clk(i_riscv_core_clk)
    ,.i_rst_n(i_riscv_core_rst_n)
    ,.i_data_from_core(ex_mem_pipe_wd)
    ,.i_addr_from_core(ex_mem_pipe_alu_result)
    ,.i_read(mem_cahce_read)
    ,.i_write(ex_mem_pipe_memwrite)
    ,.i_size(ex_mem_pipe_size)
    ,.i_amo_op(mem_main_decoder_amo_op)
    ,.i_amo(mem_main_decoder_amo)
    ,.i_lr(mem_main_decoder_lr)
    ,.i_sc(mem_main_decoder_sc)
    ,.o_stall(d_chache_stall)
    ,.o_data_to_core(read_data_mem)
    ,.o_store_fault(store_fault)
    ,.o_load_fault(load_fault)
    ,.o_amo_fault(amo_fault)
   // Interface with AXI READ CHANNEL //

    ,.o_mem_read_address(mem_read_address)
    ,.o_mem_read_req(mem_read_req)/////////////////////////////not connected yet
    ,.i_mem_read_done(mem_read_done)/////////////////////////////not connected yet
    ,.i_block_from_axi(i_block_from_axi)/////////////////////////////not connected yet
    
    // Interface with AXI WRITE CHANNEL //

    ,.i_mem_write_done(i_mem_write_done)/////////////////////////////not connected yet
    ,.o_mem_write_valid(o_mem_write_valid)/////////////////////////////not connected yet
    ,.o_mem_write_data(o_mem_write_data)/////////////////////////////not connected yet
    ,.o_mem_write_address(o_mem_write_address)/////////////////////////////not connected yet
    ,.o_mem_write_strobe()/////////////////////////////not connected yet
);

riscv_core_ldextend #(
    .XLEN(64)
    )
u_riscv_core_ldextend
(
  .i_ldextend_su_extend(ex_mem_pipe_ldext)
  ,.i_ldextend_r_w_size(ex_mem_pipe_size)
  ,.i_ldextend_rdata(read_data_mem)
  ,.o_ldextend_rdata(read_data_mem_extnd)
);



main_mem #(
    .MEM_DEPTH(12)
    ,.DATA_WIDTH(64)
    ,.ADDR_WIDTH(64)
    ,.AXI_DATA_WIDTH(256)
)
u_main_mem
(
    .i_clk(i_riscv_core_clk)
    ,.i_rst_n(i_riscv_core_rst_n)
    // Interface with AXI READ CHANNEL //
    ,.o_mem_read_address(mem_read_address)
    ,.o_mem_read_req(mem_read_req)
    ,.i_mem_read_done(mem_read_done)
    ,.i_block_from_axi(i_block_from_axi)
    // Interface with AXI WRITE CHANNEL //
    ,.i_mem_write_done(i_mem_write_done)
    ,.o_mem_write_valid(o_mem_write_valid)
    ,.o_mem_write_data(o_mem_write_data)
    ,.o_mem_write_address(o_mem_write_address)
    ,.i_size(ex_mem_pipe_size)
);


//----------------------------------//
//-----------MEM/WB Pipe------------//
//----------------------------------//

//-----------Data Signals-----------//

riscv_core_pipe 
#(
  .W_PIPE_BUS (64)
)
u_riscv_core_pipe_alu_result_mem_wb
(
  .i_pipe_clk    (i_riscv_core_clk)
  ,.i_pipe_rst_n (i_riscv_core_rst_n)
  ,.i_pipe_clr   (hu_flush_wb)
  ,.i_pipe_en_n  (hu_stall_wb)
  ,.i_pipe_in    (ex_mem_pipe_alu_result)
  ,.o_pipe_out   (mem_wb_pipe_alu_result)
);

riscv_core_pipe 
#(
  .W_PIPE_BUS (64)
)
u_riscv_core_pipe_read_data_mem_wb
(
  .i_pipe_clk    (i_riscv_core_clk)
  ,.i_pipe_rst_n (i_riscv_core_rst_n)
  ,.i_pipe_clr   (hu_flush_wb)
  ,.i_pipe_en_n  (hu_stall_wb)
  ,.i_pipe_in    (read_data_mem_extnd)
  ,.o_pipe_out   (mem_wb_pipe_read_data)
);


riscv_core_pipe 
#(
  .W_PIPE_BUS (64)
)
u_riscv_core_pipe_pc_mem_wb
(
  .i_pipe_clk    (i_riscv_core_clk)
  ,.i_pipe_rst_n (i_riscv_core_rst_n)
  ,.i_pipe_clr   (hu_flush_wb)
  ,.i_pipe_en_n  (hu_stall_wb)
  ,.i_pipe_in    (ex_mem_pipe_pc_plus_offset)
  ,.o_pipe_out   (mem_wb_pipe_pc_plus_offset)
);

riscv_core_pipe 
#(
  .W_PIPE_BUS (5)
)
u_riscv_core_pipe_rd_mem_wb
(
  .i_pipe_clk    (i_riscv_core_clk)
  ,.i_pipe_rst_n (i_riscv_core_rst_n)
  ,.i_pipe_clr   (hu_flush_wb)
  ,.i_pipe_en_n  (hu_stall_wb)
  ,.i_pipe_in    (ex_mem_pipe_rd)
  ,.o_pipe_out   (mem_wb_pipe_rd)
);

riscv_core_pipe 
#(
  .W_PIPE_BUS (32)
)
u_riscv_core_pipe_instruction_mem_wb
(
  .i_pipe_clk    (i_riscv_core_clk)
  ,.i_pipe_rst_n (i_riscv_core_rst_n)
  ,.i_pipe_clr   (hu_flush_wb)
  ,.i_pipe_en_n  (hu_stall_wb)
  ,.i_pipe_in    (instr_mem)
  ,.o_pipe_out   (instr_wb)
);

riscv_core_pipe 
#(
  .W_PIPE_BUS (64)
)
u_riscv_core_pipe_csr_src_mem_wb
(
  .i_pipe_clk    (i_riscv_core_clk)
  ,.i_pipe_rst_n (i_riscv_core_rst_n)
  ,.i_pipe_clr   (hu_flush_wb)
  ,.i_pipe_en_n  (hu_stall_wb)
  ,.i_pipe_in    (csr_src_mem)
  ,.o_pipe_out   (csr_src_wb)
);
//---------Control Signals----------//
riscv_core_pipe 
#(
  .W_PIPE_BUS (2)
)
u_riscv_core_pipe_resultsrc_mem_wb
(
  .i_pipe_clk    (i_riscv_core_clk)
  ,.i_pipe_rst_n (i_riscv_core_rst_n)
  ,.i_pipe_clr   (hu_flush_wb)
  ,.i_pipe_en_n  (hu_stall_wb)
  ,.i_pipe_in    (ex_mem_pipe_resultsrc)
  ,.o_pipe_out   (mem_wb_pipe_resultsrc)
);

riscv_core_pipe 
#(
  .W_PIPE_BUS (2)
)
u_riscv_core_pipe_csr_op_mem_wb
(
  .i_pipe_clk    (i_riscv_core_clk)
  ,.i_pipe_rst_n (i_riscv_core_rst_n)
  ,.i_pipe_clr   (hu_flush_wb)
  ,.i_pipe_en_n  (hu_stall_wb)
  ,.i_pipe_in    (csr_op_mem)
  ,.o_pipe_out   (csr_op_wb)
);

riscv_core_pipe 
#(
  .W_PIPE_BUS (1)
)
u_riscv_core_pipe_regwrite_mem_wb
(
  .i_pipe_clk    (i_riscv_core_clk)
  ,.i_pipe_rst_n (i_riscv_core_rst_n)
  ,.i_pipe_clr   (hu_flush_wb)
  ,.i_pipe_en_n  (hu_stall_wb)
  ,.i_pipe_in    (ex_mem_pipe_regwrite)
  ,.o_pipe_out   (mem_wb_pipe_regwrite)
);

riscv_core_pipe 
#(
  .W_PIPE_BUS (1)
)
u_riscv_core_pipe_mret_mem_wb
(
  .i_pipe_clk    (i_riscv_core_clk)
  ,.i_pipe_rst_n (i_riscv_core_rst_n)
  ,.i_pipe_clr   (hu_flush_wb)
  ,.i_pipe_en_n  (hu_stall_wb)
  ,.i_pipe_in    (mret_mem)
  ,.o_pipe_out   (mret_wb)
);

riscv_core_pipe 
#(
  .W_PIPE_BUS (1)
)
u_riscv_core_pipe_csr_wen_mem_wb
(
  .i_pipe_clk    (i_riscv_core_clk)
  ,.i_pipe_rst_n (i_riscv_core_rst_n)
  ,.i_pipe_clr   (hu_flush_wb)
  ,.i_pipe_en_n  (hu_stall_wb)
  ,.i_pipe_in    (csr_wen_mem)
  ,.o_pipe_out   (csr_wen_wb)
);


//----------------------------------//
//-------------WB Stage-------------//
//----------------------------------//
riscv_core_mux4x1
#(
  .XLEN (64)
)
u_riscv_core_mux4x1
(
  .i_mux4x1_in0 (mem_wb_pipe_alu_result)
  ,.i_mux4x1_in1(mem_wb_pipe_read_data)
  ,.i_mux4x1_in2(mem_wb_pipe_pc_plus_offset)
  ,.i_mux4x1_in3(csr_rdata_wb)
  ,.i_mux4x1_sel(mem_wb_pipe_resultsrc)
  ,.o_mux4x1_out(result_wb)
);

assign csr_store_fault = store_fault || amo_fault;

riscv_core_csr_unit
u_riscv_core_csr_unit
(
  .i_csr_unit_clk(i_riscv_core_clk)
  ,.i_csr_unit_rst_n(i_riscv_core_rst_n)
  ,.i_csr_unit_pc(csr_pc)
  ,.i_csr_unit_mem_wen(ex_mem_pipe_memwrite)
  ,.i_csr_unit_fault_addr(ex_mem_pipe_alu_result)
  ,.i_csr_unit_instr(csr_instr)
    //external interrupts
  ,.i_csr_unit_mexternal(i_riscv_core_external_interrupt)
  ,.o_csr_unit_ack(o_riscv_core_ack)
    //CSR instructions signals      
  ,.i_csr_unit_csr_wen(csr_wen_wb)
  ,.i_csr_unit_op(csr_op_wb)
  ,.i_csr_unit_src(csr_src_wb)
  ,.i_csr_unit_csr_addr(instr_wb[31:20])
  ,.o_csr_unit_csr_rdata(csr_rdata_wb)
    //exception handling signals
  ,.o_csr_unit_irq_handler(trap_addr_if)
  ,.o_csr_unit_mepc(mepc_if)
  ,.o_csr_unit_addr_ctrl(trap_cntrl_wb)
  ,.o_csr_unit_mux1(pc_cntrl_wb)
    //machine mode instructions
  ,.i_csr_unit_mret_wb(mret_wb)
  ,.i_csr_unit_ecall(ecall_id)
  ,.i_csr_unit_ebreak(ebreak_id)
    //exception signals
  ,.i_csr_unit_illegal_instr_id(illegal_input_to_csr)
  ,.i_csr_unit_illegal_instr_exe(1'b0)//still there's some editing here
  ,.i_csr_unit_instr_addr_misaligned(instr_addr_miss_ex)
  ,.i_csr_unit_lw_access_fault(load_fault)
  ,.i_csr_unit_sw_access_fault(csr_store_fault)
    //flush signals
  ,.o_csr_unit_if_flush(csr_if_flush)///////for hazard don't forget
  ,.o_csr_unit_id_flush(csr_id_flush)///////for hazard don't forget
  ,.o_csr_unit_exe_flush(csr_ex_flush)///////for hazard don't forget
  ,.o_csr_unit_mem_flush(csr_mem_flush)///////for hazard don't forget
);

riscv_core_mux2x1
#(
  .XLEN (64)
)
u_riscv_core_mux2x1_stg1_pc_trap
(
  .i_mux2x1_in0 (if_pipe_pcf_new)
  ,.i_mux2x1_in1(if_id_pipe_pc)
  ,.i_mux2x1_sel(csr_ex_flush)
  ,.o_mux2x1_out(csr_pc_trap_stg1)
);

//if_pipe_pcf_new
//if_id_pipe_pc
//id_ex_pipe_pc
//pc_mem
riscv_core_mux2x1
#(
  .XLEN (64)
)
u_riscv_core_mux2x1_stg2_pc_trap
(
  .i_mux2x1_in0 (csr_pc_trap_stg1)
  ,.i_mux2x1_in1(id_ex_pipe_pc)
  ,.i_mux2x1_sel(csr_mem_flush)
  ,.o_mux2x1_out(csr_pc)
);

riscv_core_mux2x1
#(
  .XLEN (32)
)
u_riscv_core_mux2x1_stg1_instr_csr
(
  .i_mux2x1_in0 (if_id_pipe_instr)
  ,.i_mux2x1_in1(instr_ex)
  ,.i_mux2x1_sel(csr_ex_flush)
  ,.o_mux2x1_out(csr_instr_stg1)
);

riscv_core_mux2x1
#(
  .XLEN (32)
)
u_riscv_core_mux2x1_stg2_instr_csr
(
  .i_mux2x1_in0 (csr_instr_stg1)
  ,.i_mux2x1_in1(instr_mem)
  ,.i_mux2x1_sel(csr_mem_flush)
  ,.o_mux2x1_out(csr_instr)
);



//----------------------------------//
//------------Hazard Unit-----------//
//----------------------------------//
riscv_core_hazard_unit
u_riscv_core_hazard_unit
(
    // RV64I Detection inputs
    .i_hazard_unit_rs1_id         (if_id_pipe_instr[19:15]) // rs1D
    ,.i_hazard_unit_rs2_id        (if_id_pipe_instr[24:20]) // rs2D
    ,.i_hazard_unit_rs1_ex        (id_ex_pipe_rs1)
    ,.i_hazard_unit_rs2_ex        (id_ex_pipe_rs2)
    ,.i_hazard_unit_rd_ex         (id_ex_pipe_rd)
    ,.i_hazard_unit_rd_mem        (ex_mem_pipe_rd)
    ,.i_hazard_unit_rd_wb         (mem_wb_pipe_rd)
    // Control signals inputs
    ,.i_hazard_unit_regwrite_mem  (ex_mem_pipe_regwrite)
    ,.i_hazard_unit_regwrite_wb   (mem_wb_pipe_regwrite)
    ,.i_hazard_unit_resultsrc_ex  (id_ex_pipe_resultsrc)
    ,.i_hazard_unit_pcsrc_ex      (mis_prediction)
    // C Extension
    //,.i_hazard_unit_illegal_instr (instr_is_illegal_comp)
    // M Extension
    ,.i_hazard_unit_mdone         (m_ext_done)
    ,.i_hazard_unit_mbusy         (m_ext_busy)
    // Caches requests
    ,.i_hazard_unit_dcache_stall(d_chache_stall)
    ,.i_hazard_unit_icache_stall(1'b0) /////////////////////////////not connected yet
    // Forwarding outputs
    ,.o_hazard_unit_forwarda_ex   (hu_forward_a)
    ,.o_hazard_unit_forwardb_ex   (hu_forward_b)
    // Stall outputs
    ,.o_hazard_unit_stall_if      (hu_stall_if)
    ,.o_hazard_unit_stall_id      (hu_stall_id)
    ,.o_hazard_unit_stall_ex      (hu_stall_ex)
    ,.o_hazard_unit_stall_mem     (hu_stall_mem)
    ,.o_hazard_unit_stall_wb      (hu_stall_wb)
    // Flush outputs
    ,.o_hazard_unit_flush_id      (hu_flush_id)
    ,.o_hazard_unit_flush_ex      (hu_flush_ex)
    ,.o_hazard_unit_flush_mem     (hu_flush_mem)
    ,.o_hazard_unit_flush_wb      (hu_flush_wb)
    //CSR inputs
    ,.i_hazard_unit_csr_flush_id  (csr_if_flush)
    ,.i_hazard_unit_csr_flush_ex  (csr_id_flush)
    ,.i_hazard_unit_csr_flush_mem (csr_ex_flush)
    ,.i_hazard_unit_csr_flush_wb  (csr_mem_flush)
);
//----------------------------------//

endmodule