module riscv_core_mul_out
#(
  parameter XLEN = 64
)
( 
  input   logic [XLEN-1:0]   i_mul_out_srcA,
  input   logic [XLEN-1:0]   i_mul_out_srcB,
  input   logic [1:0]        i_mul_out_control,
  input   logic              i_mul_out_isword,
  input   logic              i_mul_out_en,
  input   logic [2*XLEN-1:0] i_mul_out_product,
  output  logic [XLEN-1:0]   o_mul_out_result
);

logic [XLEN-1:0]   result;              // lower or upper 64-bit result
logic [2*XLEN-1:0] product;             // full 128-bit product
logic [2*XLEN-1:0] comp_product;        // complemented full 128-bit product for negative operands

logic [1:0] srcA_srcB_sign;             // sign-bit of muld & mulr
logic [1:0] srcA_srcB_word_sign;        // sign-bit of w_muld & w_mulr

localparam [1:0] MUL    = 2'b00;        //XLEN-bit x XLEN-bit multiplication of signed rs1 by signed rs2 and places the *lower* XLEN bits in the destination register.
localparam [1:0] MULH   = 2'b01;        //XLEN-bit x XLEN-bit multiplication of signed rs1 by signed rs2 and places the *upper* XLEN bits in the destination register.
localparam [1:0] MULHSU = 2'b10;        //XLEN-bit x XLEN-bit multiplication of *signed* rs1 by *unsigned* rs2 and places the *upper* XLEN bits in the destination register.
localparam [1:0] MULHU  = 2'b11;        //XLEN-bit x XLEN-bit multiplication of *unsigned* rs1 by *unsigned* rs2 and places the *upper* XLEN bits in the destination register.
localparam [1:0] MULW   = 2'b00;        //multiplies the lower 32 bits of the source registers, placing the sign-extension of the lower 32 bits of the result into the destination register.

assign product = i_mul_out_product;
assign comp_product = ~i_mul_out_product + 1'b1;

assign srcA_srcB_sign = {i_mul_out_srcA[XLEN-1], i_mul_out_srcB[XLEN-1]};
assign srcA_srcB_word_sign = {i_mul_out_srcA[XLEN/2-1], i_mul_out_srcB[XLEN/2-1]};

always_comb
  begin: enable_proc
    if (i_mul_out_en)
      begin
        o_mul_out_result = result;
      end
    else
      begin
        o_mul_out_result = 0;
      end
  end

always_comb
  begin: instr_proc
    if (!i_mul_out_isword) 
      begin
        case (i_mul_out_control)
          MUL:
            begin
              if (^srcA_srcB_sign)
                begin
                  result = comp_product[XLEN-1:0];
                end
              else
                begin
                  result = product[XLEN-1:0];
                end
            end
          MULH:
            begin
              if (^srcA_srcB_sign)
                begin
                  result = comp_product[2*XLEN-1:XLEN];
                end
              else
                begin
                  result = product[2*XLEN-1:XLEN];
                end
            end
          MULHSU:
            begin
              casex (srcA_srcB_sign)
                2'b0x:
                  begin
                    result = product[2*XLEN-1:XLEN];
                  end 
                2'b1x:
                  begin
                    result = comp_product[2*XLEN-1:XLEN];
                  end
                default:
                  begin
                    result = product[2*XLEN-1:XLEN];
                  end
              endcase
            end
          MULHU:
            begin
              result = product[2*XLEN-1:XLEN];
            end
          default:
            begin
              result = product[XLEN-1:0];
            end
        endcase
      end
    else
      begin
        case (i_mul_out_control)
          MULW:
            begin
              if (^srcA_srcB_word_sign)
                begin
                  result = {{(XLEN/2){comp_product[XLEN/2-1]}}, {comp_product[XLEN/2-1:0]}};
                end
              else
                begin
                  result = {{(XLEN/2){product[XLEN/2-1]}}, {product[XLEN/2-1:0]}};
                end
            end
          default:
            begin
              result = {{(XLEN/2){product[XLEN/2-1]}}, product[XLEN/2-1:0]};
            end
        endcase
      end
  end

endmodule