`timescale 1ns / 1ps
module riscv_core_mul_tb();

parameter XLEN = 64;

logic [XLEN-1:0] i_mul_srcA;
logic [XLEN-1:0] i_mul_srcB;
logic [1:0]      i_mul_control;
logic            i_mul_isword;
logic            i_mul_en;
logic [XLEN-1:0] o_mul_result;


reg [XLEN-1:0] gener_result;
reg [XLEN-1:0] expected_result;
initial 
  begin
    $dumpfile("riscv_core_mul_tb_DUMP.vcd");       
    $dumpvars;
    repeat(1000)
      begin
        i_mul_en = 1'b1;
        #10;
        i_mul_srcA = {$random, $random};
        i_mul_srcB = {$random, $random};
        i_mul_isword = $random;
        if (i_mul_isword) 
          begin
            i_mul_control = 2'b00;
          end
        else
          begin
            i_mul_control = $random;
          end
        #10;
        i_mul_en = 1'b0;
        gener_result = o_mul_result;
        expected_result = expec_result(i_mul_srcA, i_mul_srcB, i_mul_control, i_mul_isword);
        if(gener_result == expected_result) 
          begin
            $display("Passed, i_mul_srcA = %h, i_mul_srcB = %h, i_mul_control = %b, i_mul_isword = %b, gener_result = %h, expec_result = %h", i_mul_srcA, i_mul_srcB, i_mul_control, i_mul_isword, gener_result, expected_result);
          end
        else
          begin
            $display("Failed, i_mul_srcA = %h, i_mul_srcB = %h, i_mul_control = %b, i_mul_isword = %b, gener_result = %h, expec_result = %h", i_mul_srcA, i_mul_srcB, i_mul_control, i_mul_isword, gener_result, expected_result);
          end
      end
    $stop;
  end

function [XLEN-1:0] expec_result;
  input [XLEN-1:0] srcA;
  input [XLEN-1:0] srcB;
  input [1:0] ctrl;
  input isword;
  reg [2*XLEN-1:0] product128_s;
  reg [2*XLEN-1:0] product128_u;
  reg [2*XLEN-1:0] product128_su;
  reg [XLEN-1:0] product64_s;
  begin
    product128_s  = $signed(srcA)               * $signed(srcB);
    product128_u  = $signed({1'b0, srcA})       * $signed({1'b0, srcB});
    product128_su = $signed(srcA)               * $signed({1'b0, srcB});
    product64_s   = $signed(srcA[XLEN/2-1:0])   * $signed(srcB[XLEN/2-1:0]);
    case ({isword, ctrl})
      3'b000: expec_result = product128_s[XLEN-1:0];
      3'b001: expec_result = product128_s[2*XLEN-1:XLEN];
      3'b010: expec_result = product128_su[2*XLEN-1:XLEN];
      3'b011: expec_result = product128_u[2*XLEN-1:XLEN];
      3'b100: expec_result = {{(XLEN/2){product64_s[XLEN/2-1]}}, {product64_s[XLEN/2-1:0]}};
      default:expec_result = product128_s[XLEN-1:0];
    endcase
  end
endfunction

riscv_core_mul
#(
  .XLEN(XLEN)
)
u_riscv_core_mul
(
  .i_mul_srcA(i_mul_srcA),
  .i_mul_srcB(i_mul_srcB),
  .i_mul_control(i_mul_control),
  .i_mul_isword(i_mul_isword),
  .i_mul_en(i_mul_en),
  .o_mul_result(o_mul_result)
);
endmodule