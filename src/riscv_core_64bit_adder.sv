//--------------------------module instantiation--------------------------
/*
riscv_core_64bit_adder
#(
  .XLEN ()
)
u_riscv_core_64bit_adder
(
  .i_64bit_adder_srcA   ()
  ,.i_64bit_adder_srcB  ()
  ,.o_64bit_adder_result()
);
*/
//////////////////////////////////////////////////////////////////////////
module riscv_core_64bit_adder
#(
  parameter XLEN = 64
)
(
  input  logic [XLEN-1:0] i_64bit_adder_srcA,
  input  logic [XLEN-1:0] i_64bit_adder_srcB,
  output logic [XLEN-1:0] o_64bit_adder_result
);

assign o_64bit_adder_result = i_64bit_adder_srcA + i_64bit_adder_srcB;
endmodule