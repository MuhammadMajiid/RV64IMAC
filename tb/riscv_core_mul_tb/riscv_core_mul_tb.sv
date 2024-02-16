`timescale 1ns / 1ps
module riscv_core_mul_tb();

parameter XLEN = 64;
parameter TEST_CASES = 20;

logic [XLEN-1:0] i_mul_srcA;
logic [XLEN-1:0] i_mul_srcB;
logic [1:0]      i_mul_control;
logic            i_mul_isword;
logic [XLEN-1:0] o_mul_result;

logic [XLEN-1:0] TEST_SRCA [TEST_CASES-1:0];
logic [XLEN-1:0] TEST_SRCB [TEST_CASES-1:0];
logic [1:0] TEST_CTRL [TEST_CASES-1:0];
logic [0:0] TEST_ISWORD [TEST_CASES-1:0];
logic [XLEN-1:0] EXPECTED_RESULT [TEST_CASES-1:0];

integer Operation;

initial 
  begin
    $dumpfile("riscv_core_mul_tb_DUMP.vcd");       
    $dumpvars;

    $readmemh("D:/RISC-V GP/M-Extension/Multiplier/64-bit Radix-16 Multiplier/TEST_SRCA_h.txt", TEST_SRCA);
    $readmemh("D:/RISC-V GP/M-Extension/Multiplier/64-bit Radix-16 Multiplier/TEST_SRCB_h.txt", TEST_SRCB);
    $readmemb("D:/RISC-V GP/M-Extension/Multiplier/64-bit Radix-16 Multiplier/TEST_CTRL_b.txt", TEST_CTRL);
    $readmemb("D:/RISC-V GP/M-Extension/Multiplier/64-bit Radix-16 Multiplier/TEST_ISWORD_b.txt", TEST_ISWORD);
    $readmemh("D:/RISC-V GP/M-Extension/Multiplier/64-bit Radix-16 Multiplier/EXPECTED_RESULT_h.txt", EXPECTED_RESULT);

    for (Operation = 0; Operation < TEST_CASES; Operation = Operation + 1)
      begin
          do_oper(TEST_SRCA[Operation], TEST_SRCB[Operation], TEST_CTRL[Operation], TEST_ISWORD[Operation]);  // do_mul_opeartion
          check_out(TEST_SRCA[Operation], TEST_SRCB[Operation], TEST_CTRL[Operation], TEST_ISWORD[Operation], Operation);                           // check_mul_result
          $display("muld %d mulr %d",$signed(u_riscv_core_mul.multiplicand), $signed(u_riscv_core_mul.multiplier));
          $display("128-bit product = srcA x srcB = %h x %h = %h",u_riscv_core_mul.i_mul_srcA, u_riscv_core_mul.i_mul_srcB, u_riscv_core_mul.product);
          $display("pp1 %h pp2 %h pp3 %h pp4 %h pp5 %h pp6 %h pp7 %h pp8 %h pp9 %h pp10 %h pp11 %h pp12 %h pp13 %h pp14 %h pp15 %h pp16 %h pp17 %h",
          u_riscv_core_mul.extended_pp[0],
          u_riscv_core_mul.extended_pp[1],
          u_riscv_core_mul.extended_pp[2],
          u_riscv_core_mul.extended_pp[3],
          u_riscv_core_mul.extended_pp[4],
          u_riscv_core_mul.extended_pp[5],
          u_riscv_core_mul.extended_pp[6],
          u_riscv_core_mul.extended_pp[7],
          u_riscv_core_mul.extended_pp[8],
          u_riscv_core_mul.extended_pp[9],
          u_riscv_core_mul.extended_pp[10],
          u_riscv_core_mul.extended_pp[11],
          u_riscv_core_mul.extended_pp[12],
          u_riscv_core_mul.extended_pp[13],
          u_riscv_core_mul.extended_pp[14],
          u_riscv_core_mul.extended_pp[15],
          u_riscv_core_mul.extended_pp[16]);
      end
    $stop;
  end

task do_oper;
  input [XLEN-1:0] srcA;
  input [XLEN-1:0] srcB;
  input [1:0] ctrl;
  input isword;
  begin     
      #10; 
      i_mul_srcA = srcA;
      i_mul_srcB = srcB;
      i_mul_control = ctrl;
      i_mul_isword = isword;
      #10;
  end
endtask

task check_out; 
  input [XLEN-1:0] srcA;
  input [XLEN-1:0] srcB;
  input [1:0] ctrl;
  input isword;
  //input [XLEN-1:0] expec_result;
  input integer Oper_Num;
  reg [XLEN-1:0] gener_result;
  reg [XLEN-1:0] expected_result;
  begin
    gener_result = o_mul_result;
    expected_result = expec_result(srcA, srcB, ctrl, isword);
    if(gener_result == expected_result) 
      begin
        $display("Test Case %0d is succeeded, gener_result = %h, expec_result = %h",Oper_Num+1, gener_result, expected_result);
      end
    else
      begin
        $display("Test Case %0d is failed, gener_result = %h, expec_result = %h",Oper_Num+1, gener_result, expected_result);
      end
  end
endtask

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
  .o_mul_result(o_mul_result)
);
endmodule