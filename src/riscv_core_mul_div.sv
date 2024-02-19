module riscv_core_mul_div 
#(
  parameter XLEN = 64
)
(
  input   logic [XLEN-1:0] i_mul_div_srcA,
  input   logic [XLEN-1:0] i_mul_div_srcB,
  input   logic [3:0]      i_mul_div_control,
  input   logic            i_mul_div_en,
  input   logic            i_mul_div_isword,
  input   logic            i_mul_div_clk,
  input   logic            i_mul_div_rstn,
  output  logic            o_mul_div_busy,   
  output  logic            o_mul_div_done,
  output  logic            o_mul_div_overflow,
  output  logic            o_mul_div_div_by_zero,
  output  logic [XLEN-1:0] o_mul_div_result 
);

logic [XLEN-1:0] mul_result;
logic [XLEN-1:0] div_result;

riscv_core_mul
#(
  .XLEN(XLEN)
)
(
  .i_mul_srcA(i_mul_div_srcA),
  .i_mul_srcB(i_mul_div_srcB),
  .i_mul_control(i_mul_div_control[1:0]),
  .i_mul_isword(i_mul_div_isword),
  .i_mul_en(!i_mul_div_control[2] & i_mul_div_en),
  .o_mul_result(mul_result)
);

riscv_core_div
#(
  .XLEN(XLEN)
)
u_riscv_core_div
(
  .i_div_srcA(i_mul_div_srcA),
  .i_div_srcB(i_mul_div_srcB),
  .i_div_control(i_mul_div_control[1:0]),
  .i_div_isword(i_mul_div_isword),
  .i_div_en(i_mul_div_control[2] & i_mul_div_en),
  .i_div_clk(i_mul_div_clk),
  .i_div_rstn(i_mul_div_rstn),
  .o_div_busy(o_mul_div_busy),
  .o_div_done(o_mul_div_done),
  .o_div_overflow(o_mul_div_overflow),
  .o_div_div_by_zero(o_mul_div_div_by_zero),
  .o_div_result(div_result)
);

riscv_core_mux2x1
#(
  .XLEN (XLEN)
)
u_riscv_core_mux2x1
(
  .i_mux2x1_in0 (mul_result)
  ,.i_mux2x1_in1(div_result)
  ,.i_mux2x1_sel(i_mul_div_control[2])
  ,.o_mux2x1_out(o_mul_div_result)
);
endmodule