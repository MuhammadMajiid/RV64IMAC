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
  input  logic [1:0]      i_branch_unit_targetPC,
  input  logic            i_branch_unit_enable,
  output logic            o_branch_unit_istaken,
  output logic            o_branch_unit_addr_mismatch
);

logic istaken;

always_comb
  begin: istaken_proc
  if(i_branch_unit_enable) begin
    case (i_branch_unit_funct3)
      3'b000:  istaken = $signed(i_branch_unit_srcA)   == $signed(i_branch_unit_srcB);   // beq
      3'b001:  istaken = $signed(i_branch_unit_srcA)   != $signed(i_branch_unit_srcB);   // bne
      3'b100:  istaken = $signed(i_branch_unit_srcA)    < $signed(i_branch_unit_srcB);   // blt
      3'b101:  istaken = $signed(i_branch_unit_srcA)   >= $signed(i_branch_unit_srcB);   // bge
      3'b110:  istaken = $unsigned(i_branch_unit_srcA)  < $unsigned(i_branch_unit_srcB); // bltu
      3'b111:  istaken = $unsigned(i_branch_unit_srcA) >= $unsigned(i_branch_unit_srcB); // bgeu
      default: istaken = 1'b0;
    endcase
  end
  else
    istaken = 1'b0;
  end

assign o_branch_unit_addr_mismatch = istaken && (i_branch_unit_targetPC[0]);
assign o_branch_unit_istaken = istaken;
endmodule