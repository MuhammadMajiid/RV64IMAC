`timescale 1ns / 1ps

module riscv_core_alu_tb();

parameter XLEN = 64;
parameter TEST_CASES = 15;

logic [XLEN-1:0] i_alu_srcA;
logic [XLEN-1:0] i_alu_srcB;
logic [3:0]      i_alu_control;
logic            i_alu_isword;
logic [XLEN-1:0] o_alu_result;

logic [XLEN-1:0] TEST_SRCA [TEST_CASES-1:0];
logic [XLEN-1:0] TEST_SRCB [TEST_CASES-1:0];
logic [3:0] TEST_CTRL [TEST_CASES-1:0];
logic [0:0] TEST_ISWORD [TEST_CASES-1:0];
logic [XLEN-1:0] EXPECTED_RESULT [TEST_CASES-1:0];

integer Operation;

initial 
  begin
    $dumpfile("riscv_core_alu_tb_DUMP.vcd");       
    $dumpvars;

    $readmemh("TEST_SRCA_h.txt", TEST_SRCA);
    $readmemh("TEST_SRCB_h.txt", TEST_SRCB);
    $readmemb("TEST_CTRL_b.txt", TEST_CTRL);
    $readmemb("TEST_ISWORD_b.txt", TEST_ISWORD);
    $readmemh("EXPECTED_RESULT_h.txt", EXPECTED_RESULT);

    for (Operation = 0; Operation < TEST_CASES; Operation = Operation + 1)
      begin
          do_oper(TEST_SRCA[Operation], TEST_SRCB[Operation], TEST_CTRL[Operation], TEST_ISWORD[Operation]);  // do_alu_opeartion
          check_out(EXPECTED_RESULT[Operation], Operation);                           // check_alu_result
      end
    $stop;
  end

task do_oper;
  input [XLEN-1:0] srcA;
  input [XLEN-1:0] srcB;
  input [3:0] ctrl;
  input isword;
  begin     
      #10; 
      i_alu_srcA = srcA;
      i_alu_srcB = srcB;
      i_alu_control = ctrl;
      i_alu_isword = isword;
      #10;
  end
endtask

task check_out; 
  input [XLEN-1:0] expec_result;
  input integer Oper_Num;
  reg [XLEN-1:0] gener_result;
  begin
    gener_result = o_alu_result;
    if(gener_result == expec_result) 
      begin
        $display("Test Case %0d is succeeded, ALU_Result = %h",Oper_Num, gener_result);
      end
    else
      begin
        $display("Test Case %0d is failed, ALU_Result = %h",Oper_Num, gener_result);
      end
  end
endtask

riscv_core_alu
#(
  .XLEN(XLEN)
)
u_riscv_core_alu
(
  .i_alu_srcA    (i_alu_srcA)
  ,.i_alu_srcB   (i_alu_srcB)
  ,.i_alu_control(i_alu_control)
  ,.i_alu_isword (i_alu_isword)
  ,.o_alu_result (o_alu_result)
);
endmodule