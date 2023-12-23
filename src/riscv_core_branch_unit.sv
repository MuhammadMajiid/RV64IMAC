//--------------------------module instantiation--------------------------
/*
riscv_core_branch_unit
#(
  .XLEN ()
)
u_riscv_core_branch_unit
(
  .i_branch_unit_srcA    ()
  ,.i_branch_unit_srcB   ()
  ,.i_branch_unit_funct3 ()
  ,.o_branch_unit_istaken()
);
*/
//////////////////////////////////////////////////////////////////////////
module riscv_core_branch_unit
#(
  parameter XLEN = 64
)
(
  input  logic [XLEN-1:0] i_branch_unit_srcA,
  input  logic [XLEN-1:0] i_branch_unit_srcB,
  input  logic [2:0]      i_branch_unit_funct3,
  output logic            o_branch_unit_istaken
);
always_comb
  begin: istaken_proc
    case (i_branch_unit_funct3)
      3'b000:  o_branch_unit_istaken = $signed(i_branch_unit_srcA)   == $signed(i_branch_unit_srcB);   // beq
      3'b001:  o_branch_unit_istaken = $signed(i_branch_unit_srcA)   != $signed(i_branch_unit_srcB);   // bne
      3'b100:  o_branch_unit_istaken = $signed(i_branch_unit_srcA)    < $signed(i_branch_unit_srcB);   // blt
      3'b101:  o_branch_unit_istaken = $signed(i_branch_unit_srcA)   >= $signed(i_branch_unit_srcB);   // bge
      3'b110:  o_branch_unit_istaken = $unsigned(i_branch_unit_srcA)  < $unsigned(i_branch_unit_srcB); // bltu
      3'b111:  o_branch_unit_istaken = $unsigned(i_branch_unit_srcA) >= $unsigned(i_branch_unit_srcB); // bgeu
      default: o_branch_unit_istaken = 1'b0;
    endcase
  end
endmodule