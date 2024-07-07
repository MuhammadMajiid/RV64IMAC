module riscv_core_mul_div 
#(
  parameter XLEN = 64
)
(
  input   logic [XLEN-1:0] i_mul_div_srcA,
  input   logic [XLEN-1:0] i_mul_div_srcB,
  input   logic [2:0]      i_mul_div_control,
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
logic [XLEN-1:0] fast_result;
logic [XLEN-1:0] mul_div_result;

logic            mul_done;
logic            div_done;

logic            mul_start;
logic            div_start;

logic mul_div_sel;
logic out_sel;

logic [XLEN-1:0]   multiplicand;
logic [XLEN-1:0]   multiplier;
logic [2*XLEN-1:0] product;

logic [XLEN-1:0] dividend;
logic [XLEN-1:0] divisor;
logic [XLEN-1:0] quotient;      
logic [XLEN-1:0] remainder;

riscv_core_mul_div_ctrl
#(
  .XLEN(XLEN)
)
u_riscv_core_mul_div_ctrl
(
  .i_mul_div_ctrl_srcA(i_mul_div_srcA),
  .i_mul_div_ctrl_srcB(i_mul_div_srcB),
  .i_mul_div_ctrl_control(i_mul_div_control[2:0]),
  .i_mul_div_ctrl_en(i_mul_div_en),
  .i_mul_div_ctrl_isword(i_mul_div_isword),
  .i_mul_div_ctrl_clk(i_mul_div_clk),
  .i_mul_div_ctrl_rstn(i_mul_div_rstn),
  .i_mul_div_ctrl_mul_dn(mul_done),
  .i_mul_div_ctrl_div_dn(div_done),
  .o_mul_div_ctrl_out_fast(fast_result),
  .o_mul_div_ctrl_mul_start(mul_start),
  .o_mul_div_ctrl_div_start(div_start),
  .o_mul_div_ctrl_busy(o_mul_div_busy),
  .o_mul_div_ctrl_done(o_mul_div_done),
  .o_mul_div_ctrl_div_by_zero(o_mul_div_div_by_zero),
  .o_mul_div_ctrl_overflow(o_mul_div_overflow),
  .o_mul_div_ctrl_mul_div_sel(mul_div_sel),
  .o_mul_div_ctrl_out_sel(out_sel)
);

riscv_core_mul_in
#(
  .XLEN(XLEN)
)
u_riscv_core_mul_in
(
  .i_mul_in_srcA(i_mul_div_srcA),
  .i_mul_in_srcB(i_mul_div_srcB),
  .i_mul_in_control(i_mul_div_control[1:0]),
  .i_mul_in_isword(i_mul_div_isword),
  .o_mul_in_multiplicand(multiplicand),
  .o_mul_in_multiplier(multiplier)
);


riscv_core_booth
#(
  .XLEN(XLEN)
)
u_riscv_core_booth
(
  .i_booth_multiplicand(multiplicand),
  .i_booth_multilpier(multiplier),
  .i_booth_en(mul_start),
  .i_booth_clk(i_mul_div_clk),
  .i_booth_rstn(i_mul_div_rstn),
  .o_booth_done(mul_done),
  .o_booth_product(product)
);


riscv_core_mul_out
#(
  .XLEN(XLEN)
)
u_riscv_core_mul_out
(
  .i_mul_out_srcA_Dsign(i_mul_div_srcA[XLEN-1]),
  .i_mul_out_srcB_Dsign(i_mul_div_srcB[XLEN-1]),
  .i_mul_out_srcA_Wsign(i_mul_div_srcA[XLEN/2-1]),
  .i_mul_out_srcB_Wsign(i_mul_div_srcB[XLEN/2-1]),
  .i_mul_out_control(i_mul_div_control[1:0]),
  .i_mul_out_isword(i_mul_div_isword),
  .i_mul_out_product(product),
  .o_mul_out_result(mul_result)
);

riscv_core_div_in
#(
  .XLEN(XLEN)
)
u_riscv_core_div_in
(
  .i_div_in_srcA(i_mul_div_srcA),
  .i_div_in_srcB(i_mul_div_srcB),
  .i_div_in_control(i_mul_div_control[1:0]),
  .i_div_in_isword(i_mul_div_isword),
  .o_div_in_dividend(dividend),
  .o_div_in_divisor(divisor)
);


riscv_core_non_restoring
#(
  .XLEN(XLEN)
)
u_riscv_core_non_restoring
(
  .i_non_restoring_dividend(dividend),
  .i_non_restoring_divisor(divisor),
  .i_non_restoring_en(div_start),
  .i_non_restoring_clk(i_mul_div_clk),
  .i_non_restoring_rstn(i_mul_div_rstn),
  .o_non_restoring_done(div_done),
  .o_non_restoring_quotient(quotient),
  .o_non_restoring_remainder(remainder)
);


riscv_core_div_out
#(
  .XLEN(XLEN)
)
u_riscv_core_div_out
(
  .i_div_out_srcA_Dsign(i_mul_div_srcA[XLEN-1]),
  .i_div_out_srcB_Dsign(i_mul_div_srcB[XLEN-1]),
  .i_div_out_srcA_Wsign(i_mul_div_srcA[XLEN/2-1]),
  .i_div_out_srcB_Wsign(i_mul_div_srcB[XLEN/2-1]),
  .i_div_out_control(i_mul_div_control[1:0]),
  .i_div_out_isword(i_mul_div_isword),
  .i_div_out_quotient(quotient),
  .i_div_out_remainder(remainder),
  .o_div_out_result(div_result)
);


riscv_core_mux2x1
#(
  .XLEN (XLEN)
)
u_riscv_core_mux2x1_mul_div
(
  .i_mux2x1_in0 (mul_result)
  ,.i_mux2x1_in1(div_result)
  ,.i_mux2x1_sel(mul_div_sel)
  ,.o_mux2x1_out(mul_div_result)
);

riscv_core_mux2x1
#(
  .XLEN (XLEN)
)
u_riscv_core_mux2x1_out_sel
(
  .i_mux2x1_in0 (mul_div_result)
  ,.i_mux2x1_in1(fast_result)
  ,.i_mux2x1_sel(out_sel)
  ,.o_mux2x1_out(o_mul_div_result)
);

endmodule