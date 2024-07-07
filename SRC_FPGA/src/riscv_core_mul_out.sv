module riscv_core_mul_out
#(
  parameter XLEN = 64
)
(
  input  logic              i_mul_out_srcA_Dsign,
  input  logic              i_mul_out_srcB_Dsign,
  input  logic              i_mul_out_srcA_Wsign,
  input  logic              i_mul_out_srcB_Wsign,
  input  logic [1:0]        i_mul_out_control,
  input  logic              i_mul_out_isword,
  input  logic [2*XLEN-1:0] i_mul_out_product,
  output logic [XLEN-1:0]   o_mul_out_result
);

logic [1:0] srcA_srcB_sign;             
logic [1:0] srcA_srcB_word_sign;

logic [2*XLEN-1:0] product;
logic [2*XLEN-1:0] comp_product;

localparam [1:0] MUL    = 2'b00;        
localparam [1:0] MULH   = 2'b01;        
localparam [1:0] MULHSU = 2'b10;        
localparam [1:0] MULHU  = 2'b11;        
localparam [1:0] MULW   = 2'b00;

assign srcA_srcB_sign = {i_mul_out_srcA_Dsign, i_mul_out_srcB_Dsign};
assign srcA_srcB_word_sign = {i_mul_out_srcA_Wsign, i_mul_out_srcB_Wsign};

assign product = i_mul_out_product;
assign comp_product = ~i_mul_out_product + 1;

always_comb
  begin: instr_proc
    if (!i_mul_out_isword) 
      begin
        case (i_mul_out_control)
          MUL:
            begin
              if (^srcA_srcB_sign)
                begin
                  o_mul_out_result = comp_product[XLEN-1:0];
                end
              else
                begin
                  o_mul_out_result = product[XLEN-1:0];
                end
            end
          MULH:
            begin
              if (^srcA_srcB_sign)
                begin
                  o_mul_out_result = comp_product[2*XLEN-1:XLEN];
                end
              else
                begin
                  o_mul_out_result = product[2*XLEN-1:XLEN];
                end
            end
          MULHSU:
            begin
              casex (srcA_srcB_sign)
                2'b0x:
                  begin
                    o_mul_out_result = product[2*XLEN-1:XLEN];
                  end 
                2'b1x:
                  begin
                    o_mul_out_result = comp_product[2*XLEN-1:XLEN];
                  end
                default:
                  begin
                    o_mul_out_result = product[2*XLEN-1:XLEN];
                  end
              endcase
            end
          MULHU:
            begin
              o_mul_out_result = product[2*XLEN-1:XLEN];
            end
          default:
            begin
              o_mul_out_result = product[XLEN-1:0];
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
                  o_mul_out_result = {{(XLEN/2){comp_product[XLEN/2-1]}}, {comp_product[XLEN/2-1:0]}};
                end
              else
                begin
                  o_mul_out_result = {{(XLEN/2){product[XLEN/2-1]}}, {product[XLEN/2-1:0]}};
                end
            end
          default:
            begin
              o_mul_out_result = {{(XLEN/2){product[XLEN/2-1]}}, product[XLEN/2-1:0]};
            end
        endcase
      end
  end

endmodule