//--------------------------module instantiation--------------------------
/*
riscv_core_mux3x1
#(
  .XLEN ()
)
u_riscv_core_mux3x1
(
  .i_mux3x1_in0 ()
  ,.i_mux3x1_in1()
  ,.i_mux3x1_in2()
  ,.i_mux3x1_sel()
  ,.o_mux3x1_out()
);
*/
//////////////////////////////////////////////////////////////////////////
module riscv_core_mux3x1
#(
  parameter XLEN = 64
)
(
  input  logic [XLEN-1:0] i_mux3x1_in0,
  input  logic [XLEN-1:0] i_mux3x1_in1,
  input  logic [XLEN-1:0] i_mux3x1_in2,
  input  logic [1:0]      i_mux3x1_sel,
  output logic [XLEN-1:0] o_mux3x1_out
);

assign o_mux3x1_out = i_mux3x1_sel[1]? i_mux3x1_in2 : (i_mux3x1_sel[0]? i_mux3x1_in1 : i_mux3x1_in0);
endmodule