vlog riscv_core_64bit_adder.sv riscv_core_alu_decoder.sv riscv_core_alu.sv riscv_core_branch_unit.sv riscv_core_data_mem.sv riscv_core_hazard_unit.sv riscv_core_imem.sv riscv_core_immextend.sv riscv_core_main_decoder.sv riscv_core_mux2x1.sv riscv_core_mux3x1.sv riscv_core_mux4x1.sv riscv_core_pcsrc.sv riscv_core_pipe.sv riscv_core_rf.sv riscv_core_top.sv
vlog  tb_rv_sw.sv //put the test file here
vsim -debugdb tb
add wave -position insertpoint  \
sim:/tb/XLEN \
sim:/tb/REGS \
sim:/tb/MEMS \
sim:/tb/rst_n \
sim:/tb/clk \
sim:/tb/fd \
sim:/tb/rv
add wave -position insertpoint  \
sim:/tb/c1/i_riscv_core_clk \
sim:/tb/c1/i_riscv_core_rst_n \
sim:/tb/c1/if_id_pipe_pc \
sim:/tb/c1/if_id_pipe_pcf_new \
sim:/tb/c1/if_id_pipe_pc_plus_4 \
sim:/tb/c1/if_id_pipe_instr \
sim:/tb/c1/pcf \
sim:/tb/c1/pc_plus_4_if \
sim:/tb/c1/mux_to_stg2 \
sim:/tb/c1/instr \
sim:/tb/c1/id_ex_pipe_imm \
sim:/tb/c1/id_ex_pipe_rd1 \
sim:/tb/c1/id_ex_pipe_rd2 \
sim:/tb/c1/id_ex_pipe_pc \
sim:/tb/c1/id_ex_pipe_pc_plus_4 \
sim:/tb/c1/id_ex_pipe_rd \
sim:/tb/c1/id_ex_pipe_rs1 \
sim:/tb/c1/id_ex_pipe_rs2 \
sim:/tb/c1/id_ex_pipe_alu_control \
sim:/tb/c1/id_ex_pipe_funct3 \
sim:/tb/c1/id_ex_pipe_resultsrc \
sim:/tb/c1/id_ex_pipe_size \
sim:/tb/c1/id_ex_pipe_alu_srcb \
sim:/tb/c1/id_ex_pipe_branch \
sim:/tb/c1/id_ex_pipe_isword \
sim:/tb/c1/id_ex_pipe_jump \
sim:/tb/c1/id_ex_pipe_ldext \
sim:/tb/c1/id_ex_pipe_uctrl \
sim:/tb/c1/id_ex_pipe_memwrite \
sim:/tb/c1/id_ex_pipe_regwrite \
sim:/tb/c1/rd1_id \
sim:/tb/c1/rd2_id \
sim:/tb/c1/immext_id \
sim:/tb/c1/alu_control_id \
sim:/tb/c1/immsrc_id \
sim:/tb/c1/resultsrc_id \
sim:/tb/c1/size_id \
sim:/tb/c1/alu_op_id \
sim:/tb/c1/uctrl_id \
sim:/tb/c1/regwrite_id \
sim:/tb/c1/alusrc_id \
sim:/tb/c1/memwrite_id \
sim:/tb/c1/branch_id \
sim:/tb/c1/jump_id \
sim:/tb/c1/ldext_id \
sim:/tb/c1/isword_id \
sim:/tb/c1/bjreg_id \
sim:/tb/c1/id_ex_pipe_bjreg \
sim:/tb/c1/ex_mem_pipe_alu_result \
sim:/tb/c1/ex_mem_pipe_wd \
sim:/tb/c1/ex_mem_pipe_auipc \
sim:/tb/c1/ex_mem_pipe_pc_plus_4 \
sim:/tb/c1/ex_mem_pipe_rd \
sim:/tb/c1/ex_mem_pipe_resultsrc \
sim:/tb/c1/ex_mem_pipe_size \
sim:/tb/c1/ex_mem_pipe_memwrite \
sim:/tb/c1/ex_mem_pipe_ldext \
sim:/tb/c1/ex_mem_pipe_regwrite \
sim:/tb/c1/src_a_ex \
sim:/tb/c1/src_b_ex \
sim:/tb/c1/src_b_out \
sim:/tb/c1/alu_result_ex \
sim:/tb/c1/pc_plus_imm \
sim:/tb/c1/auipc \
sim:/tb/c1/istaken_ex \
sim:/tb/c1/pcsrc_ex \
sim:/tb/c1/read_data_mem \
sim:/tb/c1/mem_wb_pipe_alu_result \
sim:/tb/c1/mem_wb_pipe_read_data \
sim:/tb/c1/mem_wb_pipe_auipc \
sim:/tb/c1/mem_wb_pipe_pc_plus_4 \
sim:/tb/c1/mem_wb_pipe_rd \
sim:/tb/c1/mem_wb_pipe_resultsrc \
sim:/tb/c1/mem_wb_pipe_regwrite \
sim:/tb/c1/result_wb \
sim:/tb/c1/hu_forward_a \
sim:/tb/c1/hu_forward_b \
sim:/tb/c1/hu_stall_if \
sim:/tb/c1/hu_stall_id \
sim:/tb/c1/hu_flush_id \
sim:/tb/c1/hu_flush_ex
run
force -freeze sim:/tb/clk 1 0, 0 {50 ns} -r 100