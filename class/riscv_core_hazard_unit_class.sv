class riscv_core_hazard_unit_class;
// RV64I Detection
rand logic [4:0] i_riscv_core_rs1_id;
rand logic [4:0] i_riscv_core_rs2_id;
rand logic [4:0] i_riscv_core_rd_ex;

    function new();
        this.i_riscv_core_rs1_id = 5'b0;
        this.i_riscv_core_rs2_id = 5'b0;
        this.i_riscv_core_rd_ex  = 5'b0;
    endfunction //new()
endclass //riscv_core_hazard_unit_class