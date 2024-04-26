//--------------------------module instantiation--------------------------
/*
riscv_core_alu
#(
  .XLEN ()
)
u_riscv_core_alu
(
  .i_alu_srcA    ()
  ,.i_alu_srcB   ()
  ,.i_alu_control()
  ,.i_alu_isword ()
  ,.i_alu_isword ()
  ,.o_alu_result ()
);
*/
//////////////////////////////////////////////////////////////////////////
module riscv_core_alu 
#(parameter XLEN = 64)
(
  input  logic [XLEN-1:0] i_alu_srcA,
  input  logic [XLEN-1:0] i_alu_srcB,
  input  logic [3:0]      i_alu_control,
  input  logic            i_alu_isword,
  output logic [XLEN-1:0] o_alu_result
);
logic [31:0] o_alu_resultword;
always_comb
  begin: result_proc
    if(!i_alu_isword)
      begin
        case (i_alu_control)
          4'b0000: o_alu_result = i_alu_srcA + i_alu_srcB;                      // add/addi
          4'b0001: o_alu_result = i_alu_srcA - i_alu_srcB;                      // sub
          4'b0110: o_alu_result = i_alu_srcA ^ i_alu_srcB;                      // xor/xori
          4'b0011: o_alu_result = i_alu_srcA | i_alu_srcB;                      // or/ori
          4'b0010: o_alu_result = i_alu_srcA & i_alu_srcB;                      // and/andi
          4'b0100: o_alu_result = $signed(i_alu_srcA) << i_alu_srcB[5:0];       // sll/slli
          4'b0111: o_alu_result = $signed(i_alu_srcA) >> i_alu_srcB[5:0];       // srl/srli
          4'b1111: o_alu_result = $signed(i_alu_srcA) >>> i_alu_srcB[5:0];      // sra/srai
          4'b0101: o_alu_result = $signed(i_alu_srcA) < $signed(i_alu_srcB);    // slt/slti
          4'b1000: o_alu_result = $unsigned(i_alu_srcA) < $unsigned(i_alu_srcB);// sltu/sltiu
          default: o_alu_result = 'hxxxx_xxxx_xxxx_xxxx;
        endcase
      end
    else
      begin
        case (i_alu_control)
          4'b0000: o_alu_resultword = i_alu_srcA + i_alu_srcB;                  // addw/addwi
          4'b0001: o_alu_resultword = i_alu_srcA - i_alu_srcB;                  // subw
          4'b0100: o_alu_resultword = $signed(i_alu_srcA[31:0]) << i_alu_srcB[4:0];   // sllw/sllwi
          4'b0111: o_alu_resultword = $signed(i_alu_srcA[31:0]) >> i_alu_srcB[4:0];   // srlw/srlwi
          4'b1111: o_alu_resultword = $signed(i_alu_srcA[31:0]) >>> i_alu_srcB[4:0];  // sraw/srawi
          default: o_alu_resultword = 'hxxxx_xxxx;
        endcase
        o_alu_result = {{32{o_alu_resultword[31]}}, o_alu_resultword};
      end
  end
endmodule