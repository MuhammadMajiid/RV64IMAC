//--------------------------module instantiation--------------------------
/*
riscv_core_mux2x1
#(
  .XLEN ()
)
u_riscv_core_mux2x1
(
  .i_mux2x1_in0 ()
  ,.i_mux2x1_in1()
  ,.i_mux2x1_sel()
  ,.o_mux2x1_out()
);
*/
//////////////////////////////////////////////////////////////////////////
module riscv_core_mux2x1
#(
  parameter XLEN = 64
)
(
  input  logic [XLEN-1:0] i_mux2x1_in0,
  input  logic [XLEN-1:0] i_mux2x1_in1,
  input  logic            i_mux2x1_sel,
  output logic [XLEN-1:0] o_mux2x1_out
);

assign o_mux2x1_out = i_mux2x1_sel? i_mux2x1_in1 : i_mux2x1_in0;
endmodule