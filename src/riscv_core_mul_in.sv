module riscv_core_mul_in
#(
  parameter XLEN = 64
)
(
  input  logic [XLEN-1:0] i_mul_in_srcA,
  input  logic [XLEN-1:0] i_mul_in_srcB,
  input  logic [1:0]      i_mul_in_control,
  input  logic            i_mul_in_isword,
  output logic [5:0]      o_mul_in_fast,
  output logic [XLEN-1:0] o_mul_in_multiplicand,
  output logic [XLEN-1:0] o_mul_in_multiplier
);

logic [1:0] srcA_srcB_sign;             
logic [1:0] srcA_srcB_word_sign;        

localparam [1:0] MUL    = 2'b00;        
localparam [1:0] MULH   = 2'b01;        
localparam [1:0] MULHSU = 2'b10;        
localparam [1:0] MULHU  = 2'b11;        
localparam [1:0] MULW   = 2'b00;


assign srcA_srcB_sign = {i_mul_in_srcA[XLEN-1], i_mul_in_srcB[XLEN-1]};
assign srcA_srcB_word_sign = {i_mul_in_srcA[XLEN/2-1], i_mul_in_srcB[XLEN/2-1]};

assign o_mul_in_fast = {(i_mul_in_srcB == -1), (i_mul_in_srcB== 0), (i_mul_in_srcB == 1), (i_mul_in_srcA == -1), (i_mul_in_srcA == 0), (i_mul_in_srcA == 1)};

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
                    o_mul_in_multiplier = ~i_mul_in_srcB + 1'b1;
                  end
                2'b10:
                  begin
                    o_mul_in_multiplicand = ~i_mul_in_srcA + 1'b1;
                    o_mul_in_multiplier = i_mul_in_srcB;
                  end
                2'b11:
                  begin
                    o_mul_in_multiplicand = ~i_mul_in_srcA + 1'b1;
                    o_mul_in_multiplier = ~i_mul_in_srcB + 1'b1;
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
                    o_mul_in_multiplier = ~i_mul_in_srcB + 1'b1;
                  end
                2'b10:
                  begin
                    o_mul_in_multiplicand = ~i_mul_in_srcA + 1'b1;
                    o_mul_in_multiplier = i_mul_in_srcB;
                  end
                2'b11:
                  begin
                    o_mul_in_multiplicand = ~i_mul_in_srcA + 1'b1;
                    o_mul_in_multiplier = ~i_mul_in_srcB + 1'b1;
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
                    o_mul_in_multiplicand = ~i_mul_in_srcA + 1'b1;
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
                    o_mul_in_multiplier = ~i_mul_in_srcB[XLEN/2-1:0] + 1'b1;
                  end
                2'b10:
                  begin
                    o_mul_in_multiplicand = ~i_mul_in_srcA[XLEN/2-1:0] + 1'b1;
                    o_mul_in_multiplier = i_mul_in_srcB[XLEN/2-1:0];
                  end
                2'b11:
                  begin
                    o_mul_in_multiplicand = ~i_mul_in_srcA[XLEN/2-1:0] + 1'b1;
                    o_mul_in_multiplier = ~i_mul_in_srcB[XLEN/2-1:0] + 1'b1;
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