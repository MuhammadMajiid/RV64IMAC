module riscv_core_div_out
#(
  parameter XLEN = 64
)
(
  input  logic            i_div_out_srcA_Dsign,
  input  logic            i_div_out_srcB_Dsign,
  input  logic            i_div_out_srcA_Wsign,
  input  logic            i_div_out_srcB_Wsign,
  input  logic [1:0]      i_div_out_control,
  input  logic            i_div_out_isword,
  input  logic [XLEN-1:0] i_div_out_quotient,
  input  logic [XLEN-1:0] i_div_out_remainder,
  output logic [XLEN-1:0] o_div_out_result
);

logic [1:0] srcA_srcB_sign;             // sign-bit of dividend & divisor
logic [1:0] srcA_srcB_word_sign;        // sign-bit of w_dividend & w_divisor

logic [XLEN-1:0] quotient;
logic [XLEN-1:0] comp_quotient;
logic [XLEN-1:0] remainder;
logic [XLEN-1:0] comp_remainder;


localparam [1:0] DIV    = 2'b00;        
localparam [1:0] DIVU   = 2'b01;        
localparam [1:0] REM    = 2'b10;        
localparam [1:0] REMU   = 2'b11; 

localparam [1:0] DIVW   = 2'b00;        
localparam [1:0] DIVUW  = 2'b01;        
localparam [1:0] REMW   = 2'b10;        
localparam [1:0] REMUW  = 2'b11;       


assign srcA_srcB_sign = {i_div_out_srcA_Dsign, i_div_out_srcB_Dsign};
assign srcA_srcB_word_sign = {i_div_out_srcA_Wsign, i_div_out_srcB_Wsign};

assign quotient = i_div_out_quotient;
assign comp_quotient = ~i_div_out_quotient + 1;
assign remainder = i_div_out_remainder;
assign comp_remainder = ~i_div_out_remainder + 1;

always_comb
  begin: instr_proc
    if (!i_div_out_isword) 
      begin
        case (i_div_out_control)
          DIV:
            begin
              if (^srcA_srcB_sign)
                begin
                  o_div_out_result = comp_quotient;
                end
              else
                begin
                  o_div_out_result = quotient;
                end
            end    
          DIVU:
            begin
              o_div_out_result  = quotient;
            end
          REM:
            begin
              if (srcA_srcB_sign[1])
                begin
                  o_div_out_result  = comp_remainder;
                end
              else
                begin
                  o_div_out_result  = remainder;
                end
            end
          REMU:
            begin
              o_div_out_result  = remainder;
            end
          default:
            begin
              o_div_out_result  = quotient;
            end
        endcase
      end
    else
      begin
        case (i_div_out_control)
          DIVW:
            begin
              if (^srcA_srcB_word_sign)
                begin
                  o_div_out_result = {{(XLEN/2){comp_quotient[XLEN/2-1]}}, comp_quotient[XLEN/2-1:0]};
                end
              else
                begin
                  o_div_out_result = {{(XLEN/2){quotient[XLEN/2-1]}}, quotient[XLEN/2-1:0]};
                end
            end    
          DIVUW:
            begin
              o_div_out_result  = {{(XLEN/2){quotient[XLEN/2-1]}}, quotient[XLEN/2-1:0]};
            end
          REMW:
            begin
              if (srcA_srcB_word_sign[1])
                begin
                  o_div_out_result  = {{(XLEN/2){comp_remainder[XLEN/2-1]}}, comp_remainder[XLEN/2-1:0]};
                end
              else
                begin
                  o_div_out_result  = {{(XLEN/2){remainder[XLEN/2-1]}}, remainder[XLEN/2-1:0]};
                end
            end
          REMUW:
            begin
              o_div_out_result  = {{(XLEN/2){remainder[XLEN/2-1]}}, remainder[XLEN/2-1:0]};
            end
          default:
            begin
              o_div_out_result  = {{(XLEN/2){quotient[XLEN/2-1]}}, quotient[XLEN/2-1:0]};
            end
        endcase
      end
  end

endmodule