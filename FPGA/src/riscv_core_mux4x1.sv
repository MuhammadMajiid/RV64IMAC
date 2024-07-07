//--------------------------module instantiation--------------------------
/*
riscv_core_mux4x1
#(
  .XLEN ()
)
u_riscv_core_mux4x1
(
  .i_mux4x1_in0 ()
  ,.i_mux4x1_in1()
  ,.i_mux4x1_in2()
  ,.i_mux4x1_in3()
  ,.i_mux4x1_sel()
  ,.o_mux4x1_out()
);
*/
//////////////////////////////////////////////////////////////////////////
module riscv_core_mux4x1
#(
  parameter XLEN = 64
)
(
  input  logic [XLEN-1:0] i_mux4x1_in0,
  input  logic [XLEN-1:0] i_mux4x1_in1,
  input  logic [XLEN-1:0] i_mux4x1_in2,
  input  logic [XLEN-1:0] i_mux4x1_in3,
  input  logic [1:0]      i_mux4x1_sel,
  output logic [XLEN-1:0] o_mux4x1_out
);

always_comb
  begin: out_proc
    case (i_mux4x1_sel)
      2'b00:   o_mux4x1_out = i_mux4x1_in0;
      2'b01:   o_mux4x1_out = i_mux4x1_in1;
      2'b10:   o_mux4x1_out = i_mux4x1_in2;
      2'b11:   o_mux4x1_out = i_mux4x1_in3;
      default: o_mux4x1_out = 'bx;
    endcase
  end
endmodule