module riscv_core_div 
#(
  parameter XLEN = 64
)
(
  input  logic [XLEN-1:0] i_div_srcA,
  input  logic [XLEN-1:0] i_div_srcB,
  input  logic [1:0]      i_div_control,
  input  logic            i_div_isword,
  input  logic            i_div_en,
  input  logic            i_div_clk,
  input  logic            i_div_rstn,
  output logic            o_div_done,
  output logic [XLEN-1:0] o_div_result
);

logic [XLEN-1:0] dividend;
logic [XLEN-1:0] divisor;
logic [XLEN-1:0] quotient;      
logic [XLEN-1:0] remainder;
logic            done;

riscv_core_div_in
#(
  .XLEN(XLEN)
)
u_riscv_core_div_in
(
  .i_div_in_srcA(i_div_srcA),
  .i_div_in_srcB(i_div_srcB),
  .i_div_in_control(i_div_control),
  .i_div_in_isword(i_div_isword),
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
  .i_non_restoring_en(i_div_en),
  .i_non_restoring_clk(i_div_clk),
  .i_non_restoring_rstn(i_div_rstn),
  .o_non_restoring_done(done),
  .o_non_restoring_quotient(quotient),
  .o_non_restoring_remainder(remainder)
);


riscv_core_div_out
#(
  .XLEN(XLEN)
)
u_riscv_core_div_out
(
  .i_div_out_srcA(i_div_srcA),
  .i_div_out_srcB(i_div_srcB),
  .i_div_out_control(i_div_control),
  .i_div_out_isword(i_div_isword),
  .i_div_out_clk(i_div_clk),
  .i_div_out_rstn(i_div_rstn),
  .i_div_out_done(done),
  .i_div_out_quotient(quotient),
  .i_div_out_remainder(remainder),
  .o_div_out_done(o_div_done),
  .o_div_out_result(o_div_result)
);

endmodule