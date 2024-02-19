`timescale 1ns / 1ps

module riscv_core_div_tb();

parameter XLEN = 64;
parameter CLK_PERIOD = 5;
parameter TEST_CASES = 44;

logic [XLEN-1:0] i_div_srcA;
logic [XLEN-1:0] i_div_srcB;
logic [1:0]      i_div_control;
logic            i_div_isword;
logic            i_div_en;
logic            i_div_clk;
logic            i_div_rstn;
logic            o_div_busy;
logic            o_div_done;
logic            o_div_overflow;
logic            o_div_div_by_zero;
logic [XLEN-1:0] o_div_result;

logic [XLEN-1:0] TEST_SRCA    [TEST_CASES-1:0];
logic [XLEN-1:0] TEST_SRCB    [TEST_CASES-1:0];
logic [1:0]      TEST_CTRL    [TEST_CASES-1:0];
logic [0:0]      TEST_ISWORD  [TEST_CASES-1:0];

integer Operation;

initial 
  begin
    $dumpfile("riscv_core_div_tb_DUMP.vcd");       
    $dumpvars;

    $readmemh("C:/Users/hythe/Desktop/64-bit Non-Restoring Divider/TEST_SRCA_h.txt", TEST_SRCA);
    $readmemh("C:/Users/hythe/Desktop/64-bit Non-Restoring Divider/TEST_SRCB_h.txt", TEST_SRCB);
    $readmemb("C:/Users/hythe/Desktop/64-bit Non-Restoring Divider/TEST_CTRL_b.txt", TEST_CTRL);
    $readmemb("C:/Users/hythe/Desktop/64-bit Non-Restoring Divider/TEST_ISWORD_b.txt", TEST_ISWORD);
    
    initialize();
    reset();

    for (Operation = 0; Operation < TEST_CASES; Operation = Operation + 1)
      begin
          do_oper(TEST_SRCA[Operation], TEST_SRCB[Operation], TEST_CTRL[Operation], TEST_ISWORD[Operation]);  // do_div_opeartion
          #(CLK_PERIOD);
          check_out(TEST_SRCA[Operation], TEST_SRCB[Operation], TEST_CTRL[Operation], TEST_ISWORD[Operation], Operation);                           // check_div_result
      end
    $stop;
  end

task initialize;
  begin
    i_div_clk  = 1'b0;
    i_div_rstn = 1'b0; 
    i_div_en   = 1'b0;
  end
endtask

task reset;
  begin
    i_div_rstn  = 1'b1;
    #(CLK_PERIOD)
    i_div_rstn  = 1'b0;
    #(CLK_PERIOD)
    i_div_rstn  = 1'b1;
  end
endtask

task do_oper;
  input [XLEN-1:0] srcA;
  input [XLEN-1:0] srcB;
  input [1:0] ctrl;
  input isword;
  begin 
    i_div_en = 1'b1;
    i_div_srcA = srcA;
    i_div_srcB = srcB;
    i_div_control = ctrl;
    i_div_isword = isword;
    #(33*CLK_PERIOD);
    //i_div_en = 1'b0;
  end
endtask

task check_out; 
  input [XLEN-1:0] srcA;
  input [XLEN-1:0] srcB;
  input [1:0] ctrl;
  input isword;
  input integer Oper_Num;
  reg enable;
  reg [XLEN-1:0] gener_result;
  reg [XLEN-1:0] expected_result;
  begin
    enable = 1'b1;
    gener_result = o_div_result;
    expected_result = expec_result(srcA, srcB, ctrl, isword, enable);
    if(gener_result == expected_result) 
      begin
        $display("Test Case %0d is succeeded, gener_result = %h, expec_result = %h",Oper_Num+1, gener_result, expected_result);
      end
    else
      begin
        $display("Test Case %0d is failed, gener_result = %h, expec_result = %h",Oper_Num+1, gener_result, expected_result);
      end
      enable = 1'b0;
  end
endtask

function [XLEN-1:0] expec_result;
  input [XLEN-1:0] srcA;
  input [XLEN-1:0] srcB;
  input [1:0] ctrl;
  input isword;
  input en;
  reg [XLEN-1:0]   quotient_s;
  reg [XLEN-1:0]   quotient_u;
  reg [XLEN-1:0]   remainder_s;
  reg [XLEN-1:0]   remainder_u;
  reg [XLEN/2-1:0] quotientw_s;
  reg [XLEN/2-1:0] quotientw_u;
  reg [XLEN/2-1:0] remainderw_s;
  reg [XLEN/2-1:0] remainderw_u;
  begin
    if (srcB == 0)
      begin
        quotient_s  = 64'hFFFF_FFFF_FFFF_FFFF;
        quotient_u  = 64'hFFFF_FFFF_FFFF_FFFF;
        remainder_s = $signed(srcA);
        remainder_u = $signed({1'b0, srcA});

        quotientw_s  = 32'hFFFF_FFFF;
        quotientw_u  = 32'hFFFF_FFFF;
        remainderw_s = $signed(srcA[XLEN/2-1:0]);
        remainderw_u = $signed({1'b0, srcA[XLEN/2-1:0]});
      end
    else if (srcA == 64'h8000_0000_0000_0000 & srcB == -1)
      begin
        quotient_s  = 64'h8000_0000_0000_0000;
        remainder_s = 0;

        quotientw_s  = 32'h8000_0000;
        remainderw_s = 0;
      end
    else
      begin
        quotient_s  = $signed(srcA)         / $signed(srcB);
        quotient_u  = $signed({1'b0, srcA}) / $signed({1'b0, srcB});
        remainder_s = $signed(srcA)         % $signed({srcB});
        remainder_u = $signed({1'b0, srcA}) % $signed({1'b0, srcB});

        quotientw_s  = $signed(srcA[XLEN/2-1:0])         / $signed(srcB[XLEN/2-1:0]);
        quotientw_u  = $signed({1'b0, srcA[XLEN/2-1:0]}) / $signed({1'b0, srcB[XLEN/2-1:0]});
        remainderw_s = $signed(srcA[XLEN/2-1:0])         % $signed({srcB[XLEN/2-1:0]});
        remainderw_u = $signed({1'b0, srcA[XLEN/2-1:0]}) % $signed({1'b0, srcB[XLEN/2-1:0]});
      end
    
    if (en)
      begin
        case ({isword, ctrl})
          3'b000: expec_result = quotient_s;
          3'b001: expec_result = quotient_u;
          3'b010: expec_result = remainder_s;
          3'b011: expec_result = remainder_u;
          3'b100: expec_result = {{(XLEN/2){quotientw_s[XLEN/2-1]}}, {quotientw_s}};
          3'b101: expec_result = {{(XLEN/2){quotientw_u[XLEN/2-1]}}, {quotientw_u}};
          3'b110: expec_result = {{(XLEN/2){remainderw_s[XLEN/2-1]}}, {remainderw_s}};
          3'b111: expec_result = {{(XLEN/2){remainderw_u[XLEN/2-1]}}, {remainderw_u}};
          default:expec_result = quotient_s;
        endcase
      end
    else
      begin
        expec_result = 0;
      end
  end
endfunction

always #(CLK_PERIOD/2.0) i_div_clk = ~i_div_clk;

riscv_core_div
#(
  .XLEN(XLEN)
)
u_riscv_core_div
(
  .i_div_srcA(i_div_srcA),
  .i_div_srcB(i_div_srcB),
  .i_div_control(i_div_control),
  .i_div_isword(i_div_isword),
  .i_div_en(i_div_en),
  .i_div_clk(i_div_clk),
  .i_div_rstn(i_div_rstn),
  .o_div_busy(o_div_busy),
  .o_div_done(o_div_done),
  .o_div_overflow(o_div_overflow),
  .o_div_div_by_zero(o_div_div_by_zero),
  .o_div_result(o_div_result)
);
endmodule