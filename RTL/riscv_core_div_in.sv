module riscv_core_div_in
#(
  parameter XLEN = 64
)
(
  input  logic [XLEN-1:0] i_div_in_srcA,
  input  logic [XLEN-1:0] i_div_in_srcB,
  input  logic [1:0]      i_div_in_control,
  input  logic            i_div_in_isword,
  output logic [XLEN-1:0] o_div_in_dividend,
  output logic [XLEN-1:0] o_div_in_divisor
);

logic [1:0] srcA_srcB_sign;             // sign-bit of dividend & divisor
logic [1:0] srcA_srcB_word_sign;        // sign-bit of w_dividend & w_divisor

logic [XLEN-1:0] srcA_comp;
logic [XLEN-1:0] srcB_comp;

logic [XLEN-1:0] wsrcA_comp;
logic [XLEN-1:0] wsrcB_comp;

localparam [1:0] DIV    = 2'b00;        
localparam [1:0] DIVU   = 2'b01;        
localparam [1:0] REM    = 2'b10;        
localparam [1:0] REMU   = 2'b11; 

localparam [1:0] DIVW   = 2'b00;        
localparam [1:0] DIVUW  = 2'b01;        
localparam [1:0] REMW   = 2'b10;        
localparam [1:0] REMUW  = 2'b11;       

assign srcA_srcB_sign = {i_div_in_srcA[XLEN-1], i_div_in_srcB[XLEN-1]};
assign srcA_srcB_word_sign = {i_div_in_srcA[XLEN/2-1], i_div_in_srcB[XLEN/2-1]};

assign srcA_comp = ~i_div_in_srcA + 1'b1;
assign srcB_comp = ~i_div_in_srcB + 1'b1;

assign wsrcA_comp = ~i_div_in_srcA[XLEN/2-1:0] + 1'b1;
assign wsrcB_comp = ~i_div_in_srcB[XLEN/2-1:0] + 1'b1;

always_comb
  begin: instr_proc
    if (!i_div_in_isword) 
      begin
        case (i_div_in_control)
          DIV:
            begin
              case (srcA_srcB_sign)
                2'b00:
                  begin
                    o_div_in_dividend = i_div_in_srcA;
                    o_div_in_divisor = i_div_in_srcB;
                  end
                2'b01:
                  begin
                    o_div_in_dividend = i_div_in_srcA;
                    o_div_in_divisor = srcB_comp;
                  end
                2'b10:
                  begin
                    o_div_in_dividend = srcA_comp;
                    o_div_in_divisor = i_div_in_srcB;
                  end
                2'b11:
                  begin
                    o_div_in_dividend = srcA_comp;
                    o_div_in_divisor = srcB_comp;  
                  end
                default: 
                  begin
                    o_div_in_dividend = i_div_in_srcA;
                    o_div_in_divisor = i_div_in_srcB;
                  end
              endcase
            end    
          DIVU:
            begin
              o_div_in_dividend = i_div_in_srcA;
              o_div_in_divisor = i_div_in_srcB;
            end
          REM:
            begin
              case (srcA_srcB_sign)
                2'b00:
                  begin
                    o_div_in_dividend = i_div_in_srcA;
                    o_div_in_divisor = i_div_in_srcB;
                   end
                2'b01:
                  begin
                    o_div_in_dividend = i_div_in_srcA;
                    o_div_in_divisor = srcB_comp;
                  end
                2'b10:
                  begin
                    o_div_in_dividend = srcA_comp;
                    o_div_in_divisor = i_div_in_srcB;
                  end
                2'b11:
                  begin
                    o_div_in_dividend = srcA_comp;
                    o_div_in_divisor = srcB_comp;   
                  end
                default:
                  begin
                    o_div_in_dividend = i_div_in_srcA;
                    o_div_in_divisor = i_div_in_srcB;
                  end
              endcase
            end
          REMU:
            begin
              o_div_in_dividend = i_div_in_srcA;
              o_div_in_divisor = i_div_in_srcB;
            end
          default:
            begin
              o_div_in_dividend = i_div_in_srcA;
              o_div_in_divisor = i_div_in_srcB;
            end
        endcase
      end
    else
      begin
        case (i_div_in_control)
          DIVW:
            begin
              case (srcA_srcB_word_sign)
                2'b00:
                  begin
                    o_div_in_dividend = i_div_in_srcA[XLEN/2-1:0];
                    o_div_in_divisor = i_div_in_srcB[XLEN/2-1:0];
                  end
                2'b01:
                  begin
                    o_div_in_dividend = i_div_in_srcA[XLEN/2-1:0];
                    o_div_in_divisor = wsrcB_comp;
                  end
                2'b10:
                  begin
                    o_div_in_dividend = wsrcA_comp;
                    o_div_in_divisor = i_div_in_srcB[XLEN/2-1:0];
                  end
                2'b11:
                  begin
                    o_div_in_dividend = wsrcA_comp;
                    o_div_in_divisor = wsrcB_comp;  
                  end
                default: 
                  begin
                    o_div_in_dividend = i_div_in_srcA[XLEN/2-1:0];
                    o_div_in_divisor = i_div_in_srcB[XLEN/2-1:0];
                  end
              endcase
            end
          DIVUW:
            begin
              o_div_in_dividend = i_div_in_srcA[XLEN/2-1:0];
              o_div_in_divisor = i_div_in_srcB[XLEN/2-1:0];
            end
          REMW:
            begin
              case (srcA_srcB_sign)
                2'b00:
                  begin
                    o_div_in_dividend = i_div_in_srcA[XLEN/2-1:0];
                    o_div_in_divisor = i_div_in_srcB[XLEN/2-1:0];
                  end
                2'b01:
                  begin
                    o_div_in_dividend = i_div_in_srcA[XLEN/2-1:0];
                    o_div_in_divisor = wsrcB_comp;
                  end
                2'b10:
                  begin
                    o_div_in_dividend = wsrcA_comp;
                    o_div_in_divisor = i_div_in_srcB[XLEN/2-1:0];
                  end
                2'b11:
                  begin
                    o_div_in_dividend = wsrcA_comp;
                    o_div_in_divisor = wsrcB_comp;  
                  end
                default:
                  begin
                    o_div_in_dividend = i_div_in_srcA[XLEN/2-1:0];
                    o_div_in_divisor = i_div_in_srcB[XLEN/2-1:0];
                  end
              endcase
            end
          REMUW:
            begin
              o_div_in_dividend = i_div_in_srcA[XLEN/2-1:0];
              o_div_in_divisor = i_div_in_srcB[XLEN/2-1:0];
            end
          default: 
            begin
              o_div_in_dividend = i_div_in_srcA[XLEN/2-1:0];
              o_div_in_divisor = i_div_in_srcB[XLEN/2-1:0];
            end
        endcase
      end
  end
endmodule