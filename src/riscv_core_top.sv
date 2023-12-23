module riscv_core_top 
(
    // Global inputs
    input logic i_riscv_core_clk,
    input logic i_riscv_core_rst_n
);
//-------------Local Parameters-------------//
localparam EX_XLEN  = 64;
localparam REG_XLEN = 5;
localparam PC_XLEN  = 32;

//-------------IF Intermediate Signals-------------//
logic [63:0] if_id_pipe_pc;
logic [63:0] if_id_pipe_pcf_new;
logic [63:0] if_id_pipe_pc_plus_4;
logic [31:0] if_id_pipe_instr;
logic [63:0] pc;
logic [63:0] pcf;
logic [63:0] pc_plus_4_if;
logic [31:0] instr;

//-------------ID Intermediate Signals-------------//
logic [63:0] id_ex_pipe_imm;
logic [63:0] id_ex_pipe_rd1;
logic [63:0] id_ex_pipe_rd2;
logic [63:0] id_ex_pipe_pc;
logic [63:0] id_ex_pipe_pc_plus_4;
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
logic [63:0] resultsrc_id;
logic [3:0]  alu_control_id
logic [2:0]  immsrc_id;
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

//-------------EX Intermediate Signals-------------//
logic [63:0] ex_mem_pipe_alu_result;
logic [63:0] ex_mem_pipe_wd;
logic [63:0] ex_mem_pipe_auipc;
logic [63:0] ex_mem_pipe_pc_plus_4;
logic [4:0]  ex_mem_pipe_rd;
logic [1:0]  ex_mem_pipe_resultsrc;
logic [1:0]  ex_mem_pipe_size;
logic        ex_mem_pipe_memwrite;
logic        ex_mem_pipe_ldext;
logic        ex_mem_pipe_regwrite;
logic [63:0] wb_forward_a;
logic [63:0] wb_forward_b;
logic [63:0] src_a_ex;
logic [63:0] src_b_ex;
logic [63:0] src_b_out;
logic [63:0] alu_result_ex;
logic [63:0] pc_plus_imm;
logic [63:0] auipc;
logic        istaken_ex;
logic        pcsrc_ex;

//-------------MEM Intermediate Signals------------//
logic [63:0] read_data_mem;
logic [63:0] mem_wb_pipe_alu_result;
logic [63:0] mem_wb_pipe_read_data;
logic [63:0] mem_wb_pipe_auipc;
logic [63:0] mem_wb_pipe_pc_plus_4;
logic [4:0]  mem_wb_pipe_rd;
logic [1:0]  mem_wb_pipe_resultsrc;
logic        mem_wb_pipe_regwrite; 

//-------------WB Intermediate Signals-------------//
logic [63:0] result_wb;

//-------------HU Intermediate Signals-------------//
logic        hu_froward_a;
logic        hu_froward_b;
logic        hu_stall_if;
logic        hu_stall_id;
logic        hu_flush_id;
logic        hu_flush_ex;

//----------------------------------//
//-------------IF Stage-------------//
//----------------------------------//



//----------------------------------//
//------------IF/ID Pipe------------//
//----------------------------------//

riscv_core_pipe 
#(
  .W_PIPE_BUS (64)
)
u_riscv_core_pipe_pcf_if_id
(
  .i_pipe_clk    (i_riscv_core_clk)
  ,.i_pipe_rst_n (i_riscv_core_rst_n)
  ,.i_pipe_clr   (1'b0)
  ,.i_pipe_en_n  (hu_stall_if)
  ,.i_pipe_in    (pcf)
  ,.o_pipe_out   (if_id_pipe_pcf_new)
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
  ,.i_pipe_in    (pc)
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
  ,.i_pipe_in    (instr)
  ,.o_pipe_out   (if_id_pipe_instr)
);

riscv_core_pipe 
#(
  .W_PIPE_BUS (64)
)
u_riscv_core_pipe_pc_plus_4_if_id
(
  .i_pipe_clk    (i_riscv_core_clk)
  ,.i_pipe_rst_n (i_riscv_core_rst_n)
  ,.i_pipe_clr   (hu_flush_id)
  ,.i_pipe_en_n  (hu_stall_id)
  ,.i_pipe_in    (pc_plus_4_if)
  ,.o_pipe_out   (if_id_pipe_pc_plus_4)
);

//----------------------------------//
//-------------ID Stage-------------//
//----------------------------------//

riscv_core_alu_decoder 
u_riscv_core_alu_decoder
(
  .i_alu_decoder_funct3     (if_id_pipe_instr[:])
  ,.i_alu_decoder_aluop     (alu_op_id)
  ,.i_alu_decoder_funct7_5  (if_id_pipe_instr[:])
  ,.i_alu_decoder_opcode_5  (if_id_pipe_instr[:])
  ,.o_alu_decoder_alucontrol(alu_control_id)
);

riscv_core_main_decoder
u_riscv_core_main_decoder
(
  .i_main_decoder_opcode     (if_id_pipe_instr[:])
  ,.i_main_decoder_funct3    (if_id_pipe_instr[:])
  ,.o_main_decoder_imsrc     (immsrc_id)
  ,.o_main_decoder_UCtrl     (uctrl_id)
  ,.o_main_decoder_resultsrc (resultsrc_id)
  ,.o_main_decoder_regwrite  (regwrite_id)
  ,.o_main_decoder_alusrcB   (alusrc_id)
  ,.o_main_decoder_memwrite  (memwrite_id)
  ,.o_main_decoder_branch    (branch_id)
  ,.o_main_decoder_jump      (jump_id)
  ,.o_main_decoder_size      (size_id)
  ,.o_main_decoder_LdExt     (ldext_id)
  ,.o_main_decoder_isword    (isword_id)
  ,.o_main_decoder_aluop     (alu_op_id)
);

// TODO: RF Here.....................................

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
  ,.i_pipe_en_n  (1'b0)
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
  ,.i_pipe_en_n  (1'b0)
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
  ,.i_pipe_en_n  (1'b0)
  ,.i_pipe_in    (if_id_pipe_instr[:]) // funct3
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
  ,.i_pipe_en_n  (1'b0)
  ,.i_pipe_in    (if_id_pipe_pc)
  ,.o_pipe_out   (id_ex_pipe_pc)
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
  ,.i_pipe_en_n  (1'b0)
  ,.i_pipe_in    (if_id_pipe_instr[:]) // rs1D
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
  ,.i_pipe_en_n  (1'b0)
  ,.i_pipe_in    (if_id_pipe_instr[:]) // rs2D
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
  ,.i_pipe_en_n  (1'b0)
  ,.i_pipe_in    (if_id_pipe_instr[:]) // rdD
  ,.o_pipe_out   (id_ex_pipe_rd)
);

riscv_core_pipe 
#(
  .W_PIPE_BUS (5)
)
u_riscv_core_pipe_pc_plus_4_id_ex
(
  .i_pipe_clk    (i_riscv_core_clk)
  ,.i_pipe_rst_n (i_riscv_core_rst_n)
  ,.i_pipe_clr   (hu_flush_ex)
  ,.i_pipe_en_n  (1'b0)
  ,.i_pipe_in    (if_id_pipe_pc_plus_4) // (pc+4)D
  ,.o_pipe_out   (id_ex_pipe_pc_plus_4)
);

// TODO: RF PIPE Here.........................................

riscv_core_pipe 
#(
  .W_PIPE_BUS (64)
)
u_riscv_core_pipe_immext_id_ex
(
  .i_pipe_clk    (i_riscv_core_clk)
  ,.i_pipe_rst_n (i_riscv_core_rst_n)
  ,.i_pipe_clr   (hu_flush_ex)
  ,.i_pipe_en_n  (1'b0)
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
  ,.i_pipe_en_n  (1'b0)
  ,.i_pipe_in    (resultsrc_id)
  ,.o_pipe_out   (id_ex_pipe_resultsrc)
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
  ,.i_pipe_en_n  (1'b0)
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
  ,.i_pipe_en_n  (1'b0)
  ,.i_pipe_in    (alu_control_id)
  ,.o_pipe_out   (id_ex_pipe_alu_control)
);

riscv_core_pipe 
#(
  .W_PIPE_BUS (1)
)
u_riscv_core_pipe_regwrite_id_ex
(
  .i_pipe_clk    (i_riscv_core_clk)
  ,.i_pipe_rst_n (i_riscv_core_rst_n)
  ,.i_pipe_clr   (1'b0)
  ,.i_pipe_en_n  (1'b0)
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
  ,.i_pipe_clr   (1'b0)
  ,.i_pipe_en_n  (1'b0)
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
  ,.i_pipe_clr   (1'b0)
  ,.i_pipe_en_n  (1'b0)
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
  ,.i_pipe_clr   (1'b0)
  ,.i_pipe_en_n  (1'b0)
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
  ,.i_pipe_clr   (1'b0)
  ,.i_pipe_en_n  (1'b0)
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
  ,.i_pipe_clr   (1'b0)
  ,.i_pipe_en_n  (1'b0)
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
  ,.i_pipe_clr   (1'b0)
  ,.i_pipe_en_n  (1'b0)
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
  ,.i_pipe_clr   (1'b0)
  ,.i_pipe_en_n  (1'b0)
  ,.i_pipe_in    (isword_id)
  ,.o_pipe_out   (id_ex_pipe_isword)
);

//----------------------------------//
//-------------EX Stage-------------//
//----------------------------------//

riscv_core_mux3x1
#(
  .XLEN (EX_XLEN)
)
u_riscv_core_mux3x1_srca
(
  .i_mux3x1_in0 (id_ex_pipe_rd1)
  ,.i_mux3x1_in1(wb_forward_a)
  ,.i_mux3x1_in2(ex_mem_pipe_alu_result)
  ,.i_mux3x1_sel(hu_froward_a)
  ,.o_mux3x1_out(src_a_ex)
);

riscv_core_mux3x1
#(
  .XLEN (EX_XLEN)
)
u_riscv_core_mux3x1_srcb
(
  .i_mux3x1_in0 (id_ex_pipe_rd2)
  ,.i_mux3x1_in1(wb_forward_b)
  ,.i_mux3x1_in2(ex_mem_pipe_alu_result)
  ,.i_mux3x1_sel(hu_froward_b)
  ,.o_mux3x1_out(src_b_out)
);

riscv_core_mux2x1
#(
  .XLEN (EX_XLEN)
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
  .XLEN (EX_XLEN)
)
u_riscv_core_alu
(
  .i_alu_srcA    (src_a_ex)
  ,.i_alu_srcB   (src_b_ex)
  ,.i_alu_control(id_ex_pipe_alu_control)
  ,.i_alu_isword (id_ex_pipe_isword)
  ,.o_alu_result (alu_result_ex)
);

riscv_core_branch_unit
#(
  .XLEN (EX_XLEN)
)
u_riscv_core_branch_unit
(
  .i_branch_unit_srcA    (src_a_ex)
  ,.i_branch_unit_srcB   (src_b_out)
  ,.i_branch_unit_funct3 (id_ex_pipe_funct3)
  ,.o_branch_unit_istaken(istaken_ex)
);

riscv_core_pcsrc 
u_riscv_core_pcsrc
(
  .i_pcsrc_istaken   (istaken_ex)
  ,.i_pcsrc_branch_ex(id_ex_pipe_branch)
  ,.i_pcsrc_jump_ex  (id_ex_pipe_jump)
  ,.o_pcsrc_pcsrc_ex (pcsrc_ex)
);

riscv_core_64bit_adder
#(
  .XLEN (EX_XLEN)
)
u_riscv_core_64bit_adder
(
  .i_64bit_adder_srcA   (id_ex_pipe_pc)
  ,.i_64bit_adder_srcB  (id_ex_pipe_imm)
  ,.o_64bit_adder_result(pc_plus_imm)
);

riscv_core_mux2x1
#(
  .XLEN (EX_XLEN)
)
u_riscv_core_mux2x1_imm
(
  .i_mux2x1_in0 (pc_plus_imm)
  ,.i_mux2x1_in1(id_ex_pipe_imm)
  ,.i_mux2x1_sel(id_ex_pipe_uctrl)
  ,.o_mux2x1_out(auipc)
);

//----------------------------------//
//-----------EX/MEM Pipe------------//
//----------------------------------//

//-----------Data Signals-----------//
riscv_core_pipe 
#(
  .W_PIPE_BUS (EX_XLEN)
)
u_riscv_core_pipe_alu_result_ex_mem
(
  .i_pipe_clk    (i_riscv_core_clk)
  ,.i_pipe_rst_n (i_riscv_core_rst_n)
  ,.i_pipe_clr   (1'b0)
  ,.i_pipe_en_n  (1'b0)
  ,.i_pipe_in    (alu_result_ex)
  ,.o_pipe_out   (ex_mem_pipe_alu_result)
);

riscv_core_pipe 
#(
  .W_PIPE_BUS (EX_XLEN)
)
u_riscv_core_pipe_wd_ex_mem
(
  .i_pipe_clk    (i_riscv_core_clk)
  ,.i_pipe_rst_n (i_riscv_core_rst_n)
  ,.i_pipe_clr   (1'b0)
  ,.i_pipe_en_n  (1'b0)
  ,.i_pipe_in    (src_b_out)
  ,.o_pipe_out   (ex_mem_pipe_wd)
);

riscv_core_pipe 
#(
  .W_PIPE_BUS (EX_XLEN)
)
u_riscv_core_pipe_auipc_ex_mem
(
  .i_pipe_clk    (i_riscv_core_clk)
  ,.i_pipe_rst_n (i_riscv_core_rst_n)
  ,.i_pipe_clr   (1'b0)
  ,.i_pipe_en_n  (1'b0)
  ,.i_pipe_in    (auipc)
  ,.o_pipe_out   (ex_mem_pipe_auipc)
);

riscv_core_pipe 
#(
  .W_PIPE_BUS (REG_XLEN)
)
u_riscv_core_pipe_rd_ex_mem
(
  .i_pipe_clk    (i_riscv_core_clk)
  ,.i_pipe_rst_n (i_riscv_core_rst_n)
  ,.i_pipe_clr   (1'b0)
  ,.i_pipe_en_n  (1'b0)
  ,.i_pipe_in    (id_ex_pipe_rd)
  ,.o_pipe_out   (ex_mem_pipe_rd)
);

riscv_core_pipe 
#(
  .W_PIPE_BUS (PC_XLEN)
)
u_riscv_core_pipe_pc_ex_mem
(
  .i_pipe_clk    (i_riscv_core_clk)
  ,.i_pipe_rst_n (i_riscv_core_rst_n)
  ,.i_pipe_clr   (1'b0)
  ,.i_pipe_en_n  (1'b0)
  ,.i_pipe_in    (id_ex_pipe_pc_plus_4)
  ,.o_pipe_out   (ex_mem_pipe_pc_plus_4)
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
  ,.i_pipe_clr   (1'b0)
  ,.i_pipe_en_n  (1'b0)
  ,.i_pipe_in    (id_ex_pipe_resultsrc)
  ,.o_pipe_out   (ex_mem_pipe_resultsrc)
);

riscv_core_pipe 
#(
  .W_PIPE_BUS (1)
)
u_riscv_core_pipe_memwrite_ex_mem
(
  .i_pipe_clk    (i_riscv_core_clk)
  ,.i_pipe_rst_n (i_riscv_core_rst_n)
  ,.i_pipe_clr   (1'b0)
  ,.i_pipe_en_n  (1'b0)
  ,.i_pipe_in    (id_ex_pipe_memwrite)
  ,.o_pipe_out   (ex_mem_pipe_memwrite)
);

riscv_core_pipe 
#(
  .W_PIPE_BUS (2)
)
u_riscv_core_pipe_size_ex_mem
(
  .i_pipe_clk    (i_riscv_core_clk)
  ,.i_pipe_rst_n (i_riscv_core_rst_n)
  ,.i_pipe_clr   (1'b0)
  ,.i_pipe_en_n  (1'b0)
  ,.i_pipe_in    (id_ex_pipe_size)
  ,.o_pipe_out   (ex_mem_pipe_size)
);

riscv_core_pipe 
#(
  .W_PIPE_BUS (1)
)
u_riscv_core_pipe_ldext_ex_mem
(
  .i_pipe_clk    (i_riscv_core_clk)
  ,.i_pipe_rst_n (i_riscv_core_rst_n)
  ,.i_pipe_clr   (1'b0)
  ,.i_pipe_en_n  (1'b0)
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
  ,.i_pipe_clr   (1'b0)
  ,.i_pipe_en_n  (1'b0)
  ,.i_pipe_in    (id_ex_pipe_regwrite)
  ,.o_pipe_out   (ex_mem_pipe_regwrite)
);

//----------------------------------//
//-------------MEM Stage------------//
//----------------------------------//
riscv_core_data_mem
#(
  .XLEN (64)
  ,.MWID(8)
  ,.MLEN(256)
)
u_riscv_core_data_mem
(
  .i_data_mem_clk          (i_riscv_core_clk)
  ,.i_data_mem_rst_n       (i_riscv_core_rst_n)
  ,.i_data_mem_w_en        (ex_mem_pipe_memwrite)
  ,.i_data_mem_ld_extend   (ex_mem_pipe_ldext)
  ,.i_data_mem_r_w_size    (ex_mem_pipe_size)
  ,.i_data_mem_address     (ex_mem_pipe_alu_result)
  ,.i_data_mem_wdata       (ex_mem_pipe_wd)
  ,.o_data_mem_rdata       (read_data_mem)
);

//----------------------------------//
//-----------MEM/WB Pipe------------//
//----------------------------------//

//-----------Data Signals-----------//

riscv_core_pipe 
#(
  .W_PIPE_BUS (EX_XLEN)
)
u_riscv_core_pipe_alu_result_mem_wb
(
  .i_pipe_clk    (i_riscv_core_clk)
  ,.i_pipe_rst_n (i_riscv_core_rst_n)
  ,.i_pipe_clr   (1'b0)
  ,.i_pipe_en_n  (1'b0)
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
  ,.i_pipe_clr   (1'b0)
  ,.i_pipe_en_n  (1'b0)
  ,.i_pipe_in    (read_data_mem)
  ,.o_pipe_out   (mem_wb_pipe_read_data)
);

riscv_core_pipe 
#(
  .W_PIPE_BUS (64)
)
u_riscv_core_pipe_auipc_mem_wb
(
  .i_pipe_clk    (i_riscv_core_clk)
  ,.i_pipe_rst_n (i_riscv_core_rst_n)
  ,.i_pipe_clr   (1'b0)
  ,.i_pipe_en_n  (1'b0)
  ,.i_pipe_in    (ex_mem_pipe_auipc)
  ,.o_pipe_out   (mem_wb_pipe_auipc)
);

riscv_core_pipe 
#(
  .W_PIPE_BUS (64)
)
u_riscv_core_pipe_pc_mem_wb
(
  .i_pipe_clk    (i_riscv_core_clk)
  ,.i_pipe_rst_n (i_riscv_core_rst_n)
  ,.i_pipe_clr   (1'b0)
  ,.i_pipe_en_n  (1'b0)
  ,.i_pipe_in    (ex_mem_pipe_pc_plus_4)
  ,.o_pipe_out   (mem_wb_pipe_pc_plus_4)
);

riscv_core_pipe 
#(
  .W_PIPE_BUS (REG_XLEN)
)
u_riscv_core_pipe_rd_mem_wb
(
  .i_pipe_clk    (i_riscv_core_clk)
  ,.i_pipe_rst_n (i_riscv_core_rst_n)
  ,.i_pipe_clr   (1'b0)
  ,.i_pipe_en_n  (1'b0)
  ,.i_pipe_in    (ex_mem_pipe_rd)
  ,.o_pipe_out   (mem_wb_pipe_rd)
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
  ,.i_pipe_clr   (1'b0)
  ,.i_pipe_en_n  (1'b0)
  ,.i_pipe_in    (ex_mem_pipe_resultsrc)
  ,.o_pipe_out   (mem_wb_pipe_resultsrc)
);

riscv_core_pipe 
#(
  .W_PIPE_BUS (1)
)
u_riscv_core_pipe_regwrite_mem_wb
(
  .i_pipe_clk    (i_riscv_core_clk)
  ,.i_pipe_rst_n (i_riscv_core_rst_n)
  ,.i_pipe_clr   (1'b0)
  ,.i_pipe_en_n  (1'b0)
  ,.i_pipe_in    (ex_mem_pipe_regwrite)
  ,.o_pipe_out   (mem_wb_pipe_regwrite)
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
  ,.i_mux4x1_in2(mem_wb_pipe_auipc)
  ,.i_mux4x1_in3(mem_wb_pipe_pc_plus_4)
  ,.i_mux4x1_sel(mem_wb_pipe_resultsrc)
  ,.o_mux4x1_out(result_wb)
);


//----------------------------------//
//------------Hazard Unit-----------//
//----------------------------------//
riscv_core_hazard_unit
(
    // RV64I Detection inputs
    .i_hazard_unit_rs1_id         (if_id_pipe_instr[:]) // rs1D
    ,.i_hazard_unit_rs2_id        (if_id_pipe_instr[:]) // rs2D
    ,.i_hazard_unit_rs1_ex        (id_ex_pipe_rs1)
    ,.i_hazard_unit_rs2_ex        (id_ex_pipe_rs2)
    ,.i_hazard_unit_rd_ex         (id_ex_pipe_rd)
    ,.i_hazard_unit_rd_mem        (ex_mem_pipe_rd)
    ,.i_hazard_unit_rd_wb         (mem_wb_pipe_rd)
    // Control signals inputs
    ,.i_hazard_unit_regwrite_mem  (ex_mem_pipe_regwrite)
    ,.i_hazard_unit_regwrite_wb   (mem_wb_pipe_regwrite)
    ,.i_hazard_unit_resultsrc0_ex (id_ex_pipe_resultsrc[0])
    ,.i_hazard_unit_pcsrc_ex      (pcsrc_ex)
    // Forwarding outputs
    ,.o_hazard_unit_forwarda_ex   (hu_froward_a)
    ,.o_hazard_unit_forwardb_ex   (hu_froward_b)
    // Stall outputs
    ,.o_hazard_unit_stall_if      (hu_stall_if)
    ,.o_hazard_unit_stall_id      (hu_stall_id)
    // Flush outputs
    ,.o_hazard_unit_flush_id      (hu_flush_id)
    ,.o_hazard_unit_flush_ex      (hu_flush_ex)
);
//----------------------------------//

endmodule