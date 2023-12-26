module riscv_core_branch_unit_tb();

parameter XLEN = 64;
parameter TEST_CASES = 6;

logic [XLEN-1:0] i_branch_unit_srcA;
logic [XLEN-1:0] i_branch_unit_srcB;
logic [2:0]      i_branch_unit_funct3;
logic            o_branch_unit_istaken;

logic [XLEN-1:0] TEST_SRCA [TEST_CASES-1:0];
logic [XLEN-1:0] TEST_SRCB [TEST_CASES-1:0];
logic [2:0] TEST_FUNCT3 [TEST_CASES-1:0];
logic [0:0] EXPECTED_ISTAKEN [TEST_CASES-1:0];

integer Operation;

initial 
  begin
    $dumpfile("riscv_core_branch_unit_tb_DUMP.vcd");       
    $dumpvars;

    $readmemh("TEST_SRCA_h.txt", TEST_SRCA);
    $readmemh("TEST_SRCB_h.txt", TEST_SRCB);
    $readmemb("TEST_FUNCT3_b.txt", TEST_FUNCT3);
    $readmemb("EXPECTED_ISTAKEN_b.txt", EXPECTED_ISTAKEN);

    for (Operation = 0; Operation < TEST_CASES; Operation = Operation + 1)
      begin
          do_oper(TEST_SRCA[Operation], TEST_SRCB[Operation], TEST_FUNCT3[Operation]);  // do_branch_opeartion
          check_out(EXPECTED_ISTAKEN[Operation], Operation);                            // check_alu_result
      end
    $stop;
  end

  task do_oper;
  input [XLEN-1:0] srcA;
  input [XLEN-1:0] srcB;
  input [2:0] funct3;
  begin      
    i_branch_unit_srcA = srcA;
    i_branch_unit_srcB = srcB;
    i_branch_unit_funct3 = funct3;
    #10;
  end
endtask

task check_out; 
  input expec_istaken;
  input integer Oper_Num;
  logic gener_istaken;
  begin
    gener_istaken = o_branch_unit_istaken;
    if(gener_istaken == expec_istaken) 
      begin
        $display("Test Case %0d is succeeded, IsTaken = %0b",Oper_Num, gener_istaken);
      end
    else
      begin
        $display("Test Case %0d is failed, IsTaken = %0b",Oper_Num, gener_istaken);
      end
  end
endtask

riscv_core_branch_unit
#(
  .XLEN(XLEN)
)
u_riscv_core_branch_unit
(
  .i_branch_unit_srcA(i_branch_unit_srcA)
  ,.i_branch_unit_srcB(i_branch_unit_srcB)
  ,.i_branch_unit_funct3(i_branch_unit_funct3)
  ,.o_branch_unit_istaken(o_branch_unit_istaken)
);
endmodule