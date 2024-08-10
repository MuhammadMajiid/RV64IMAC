module riscv_core_mul_in
#(
  parameter XLEN = 64
)
( 
  input   logic [XLEN-1:0] i_mul_in_srcA,
  input   logic [XLEN-1:0] i_mul_in_srcB,
  input   logic [1:0]      i_mul_in_control,
  input   logic            i_mul_in_isword,
  output  logic [XLEN-1:0] o_mul_in_multiplicand,
  output  logic [XLEN-1:0] o_mul_in_multiplier
);

logic [1:0] srcA_srcB_sign;             // sign-bit of muld & mulr
logic [1:0] srcA_srcB_word_sign;        // sign-bit of w_muld & w_mulr

logic [XLEN-1:0] srcA_comp;
logic [XLEN-1:0] srcB_comp;

logic [XLEN-1:0] wsrcA_comp;
logic [XLEN-1:0] wsrcB_comp;

localparam [1:0] MUL    = 2'b00;        //XLEN-bit x XLEN-bit multiplication of signed rs1 by signed rs2 and places the *lower* XLEN bits in the destination register.
localparam [1:0] MULH   = 2'b01;        //XLEN-bit x XLEN-bit multiplication of signed rs1 by signed rs2 and places the *upper* XLEN bits in the destination register.
localparam [1:0] MULHSU = 2'b10;        //XLEN-bit x XLEN-bit multiplication of *signed* rs1 by *unsigned* rs2 and places the *upper* XLEN bits in the destination register.
localparam [1:0] MULHU  = 2'b11;        //XLEN-bit x XLEN-bit multiplication of *unsigned* rs1 by *unsigned* rs2 and places the *upper* XLEN bits in the destination register.
localparam [1:0] MULW   = 2'b00;        //multiplies the lower 32 bits of the source registers, placing the sign-extension of the lower 32 bits of the result into the destination register.

assign srcA_srcB_sign = {i_mul_in_srcA[XLEN-1], i_mul_in_srcB[XLEN-1]};
assign srcA_srcB_word_sign = {i_mul_in_srcA[XLEN/2-1], i_mul_in_srcB[XLEN/2-1]};

assign srcA_comp = ~i_mul_in_srcA + 1'b1;
assign srcB_comp = ~i_mul_in_srcB + 1'b1;

assign wsrcA_comp = ~i_mul_in_srcA[XLEN/2-1:0] + 1'b1;
assign wsrcB_comp = ~i_mul_in_srcB[XLEN/2-1:0] + 1'b1;

always_comb
  begin: instr_proc
    if (!i_mul_in_isword) 
      begin
        case (i_mul_in_control)
          MUL:
            begin
              case (srcA_srcB_sign)
                2'b00:
                  begin
                    o_mul_in_multiplicand = i_mul_in_srcA;
                    o_mul_in_multiplier = i_mul_in_srcB;
                  end 
                2'b01:
                  begin
                    o_mul_in_multiplicand = i_mul_in_srcA;
                    o_mul_in_multiplier = srcB_comp;
                  end
                2'b10:
                  begin
                    o_mul_in_multiplicand = srcA_comp;
                    o_mul_in_multiplier = i_mul_in_srcB;
                  end
                2'b11:
                  begin
                    o_mul_in_multiplicand = srcA_comp;
                    o_mul_in_multiplier = srcB_comp;
                  end
                default:
                  begin
                    o_mul_in_multiplicand = i_mul_in_srcA;
                    o_mul_in_multiplier = i_mul_in_srcB;
                  end
              endcase
            end
          MULH:
            begin
              case (srcA_srcB_sign)
                2'b00:
                  begin
                    o_mul_in_multiplicand = i_mul_in_srcA;
                    o_mul_in_multiplier = i_mul_in_srcB;
                  end 
                2'b01:
                  begin
                    o_mul_in_multiplicand = i_mul_in_srcA;
                    o_mul_in_multiplier = srcB_comp;
                  end
                2'b10:
                  begin
                    o_mul_in_multiplicand = srcA_comp;
                    o_mul_in_multiplier = i_mul_in_srcB;
                  end
                2'b11:
                  begin
                    o_mul_in_multiplicand = srcA_comp;
                    o_mul_in_multiplier = srcB_comp;
                  end
                default:
                  begin
                    o_mul_in_multiplicand = i_mul_in_srcA;
                    o_mul_in_multiplier = i_mul_in_srcB;
                  end
              endcase
            end
          MULHSU:
            begin
              casex (srcA_srcB_sign)
                2'b0x:
                  begin
                    o_mul_in_multiplicand = i_mul_in_srcA;
                    o_mul_in_multiplier = i_mul_in_srcB;
                  end 
                2'b1x:
                  begin
                    o_mul_in_multiplicand = srcA_comp;
                    o_mul_in_multiplier = i_mul_in_srcB;
                  end
                default:
                  begin
                    o_mul_in_multiplicand = i_mul_in_srcA;
                    o_mul_in_multiplier = i_mul_in_srcB;
                  end
              endcase
            end
          MULHU:
            begin
              o_mul_in_multiplicand = i_mul_in_srcA;
              o_mul_in_multiplier = i_mul_in_srcB;
            end
          default:
            begin
              o_mul_in_multiplicand = i_mul_in_srcA;
              o_mul_in_multiplier = i_mul_in_srcB;
            end
        endcase
      end
    else
      begin
        case (i_mul_in_control)
          MULW:
            begin
              case (srcA_srcB_word_sign)
                2'b00:
                  begin
                    o_mul_in_multiplicand = i_mul_in_srcA[XLEN/2-1:0];
                    o_mul_in_multiplier = i_mul_in_srcB[XLEN/2-1:0];
                  end 
                2'b01:
                  begin
                    o_mul_in_multiplicand = i_mul_in_srcA[XLEN/2-1:0];
                    o_mul_in_multiplier = wsrcB_comp;
                  end
                2'b10:
                  begin
                    o_mul_in_multiplicand = wsrcA_comp;
                    o_mul_in_multiplier = i_mul_in_srcB[XLEN/2-1:0];
                  end
                2'b11:
                  begin
                    o_mul_in_multiplicand = wsrcA_comp;
                    o_mul_in_multiplier = wsrcB_comp;
                  end
                default:
                  begin
                    o_mul_in_multiplicand = i_mul_in_srcA[XLEN/2-1:0];
                    o_mul_in_multiplier = i_mul_in_srcB[XLEN/2-1:0];
                  end
              endcase
            end
          default:
            begin
              o_mul_in_multiplicand = i_mul_in_srcA[XLEN/2-1:0];
              o_mul_in_multiplier = i_mul_in_srcB[XLEN/2-1:0];
            end
        endcase
      end
  end

endmodule