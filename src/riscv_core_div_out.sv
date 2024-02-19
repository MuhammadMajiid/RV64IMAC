module riscv_core_div_out
#(
  parameter XLEN = 64
)
(
  input  logic [XLEN-1:0] i_div_out_srcA,
  input  logic [XLEN-1:0] i_div_out_srcB,
  input  logic [1:0]      i_div_out_control,
  input  logic            i_div_out_isword,
  input  logic            i_div_out_start,
  input  logic            i_div_out_clk,
  input  logic            i_div_out_rstn,
  input  logic            i_div_out_done,
  input  logic [XLEN-1:0] i_div_out_quotient,
  input  logic [XLEN-1:0] i_div_out_remainder,
  output logic            o_div_out_overflow,
  output logic            o_div_out_div_by_zero,
  output logic            o_div_out_done,
  output logic [XLEN-1:0] o_div_out_result
);

logic [1:0] srcA_srcB_sign;             // sign-bit of dividend & divisor
logic [1:0] srcA_srcB_word_sign;        // sign-bit of w_dividend & w_divisor
logic [XLEN-1:0] result;

logic [XLEN-1:0] quotient;
logic [XLEN-1:0] comp_quotient;
logic [XLEN-1:0] remainder;
logic [XLEN-1:0] comp_remainder;

logic div_by_zero;
logic overflow;

localparam [1:0] DIV    = 2'b00;        
localparam [1:0] DIVU   = 2'b01;        
localparam [1:0] REM    = 2'b10;        
localparam [1:0] REMU   = 2'b11; 

localparam [1:0] DIVW   = 2'b00;        
localparam [1:0] DIVUW  = 2'b01;        
localparam [1:0] REMW   = 2'b10;        
localparam [1:0] REMUW  = 2'b11;       

localparam [XLEN-1:0] OVERFLOW_SIGNED_A = 64'h8000_0000_0000_0000;
localparam [XLEN-1:0] OVERFLOW_SIGNED_B = -1;

assign srcA_srcB_sign = {i_div_out_srcA[XLEN-1], i_div_out_srcB[XLEN-1]};
assign srcA_srcB_word_sign = {i_div_out_srcA[XLEN/2-1], i_div_out_srcB[XLEN/2-1]};

assign quotient = i_div_out_quotient;
assign comp_quotient = ~i_div_out_quotient + 1;
assign remainder = i_div_out_remainder;
assign comp_remainder = ~i_div_out_remainder + 1;

always_comb
  begin: instr_proc
    div_by_zero = 1'b0;
    overflow = 1'b0;
    if (!i_div_out_isword) 
      begin
        case (i_div_out_control)
          DIV:
            begin
              if (i_div_out_srcB == 0)
                begin
                  result = 64'hFFFF_FFFF_FFFF_FFFF;
                  div_by_zero = 1'b1;
                end
              else if ((i_div_out_srcA == OVERFLOW_SIGNED_A) & (i_div_out_srcB == OVERFLOW_SIGNED_B))
                begin
                  result = OVERFLOW_SIGNED_A;
                  overflow = 1'b1;
                end
              else
                begin
                  if (^srcA_srcB_sign)
                    begin
                      result = comp_quotient;
                    end
                  else
                    begin
                      result = quotient;
                    end
                end
            end    
          DIVU:
            begin
              if (i_div_out_srcB == 0)
                begin
                  result = 64'hFFFF_FFFF_FFFF_FFFF;
                  div_by_zero = 1'b1;
                end
              else
                begin
                  result  = quotient;
                end
            end
          REM:
            begin
              if (i_div_out_srcB == 0)
                begin
                  result = i_div_out_srcA;
                  div_by_zero = 1'b1;
                end
              else if (i_div_out_srcA == OVERFLOW_SIGNED_A && i_div_out_srcB == OVERFLOW_SIGNED_B)
                begin
                  result = 0;
                  overflow = 1'b1;
                end
              else
                begin
                  if (srcA_srcB_sign[1])
                    begin
                      result  = comp_remainder;
                    end
                  else
                    begin
                      result  = remainder;
                    end
                end
            end
          REMU:
            begin
              if (i_div_out_srcB == 0)
                begin
                  result = i_div_out_srcA;
                  div_by_zero = 1'b1;
                end
              else
                begin
                  result  = remainder;
                end
            end
          default:
            begin
              result  = quotient;
            end
        endcase
      end
    else
      begin
        case (i_div_out_control)
          DIVW:
            begin
              if (i_div_out_srcB == 0)
                begin
                  result = 64'hFFFF_FFFF_FFFF_FFFF;
                  div_by_zero = 1'b1;
                end
              else if (i_div_out_srcA == OVERFLOW_SIGNED_A && i_div_out_srcB == OVERFLOW_SIGNED_B)
                begin
                  result = OVERFLOW_SIGNED_A;
                  overflow = 1'b1;
                end
              else
                begin
                  if (^srcA_srcB_word_sign)
                    begin
                      result = {{(XLEN/2){comp_quotient[XLEN/2-1]}}, comp_quotient[XLEN/2-1:0]};
                    end
                  else
                    begin
                      result = {{(XLEN/2){quotient[XLEN/2-1]}}, quotient[XLEN/2-1:0]};
                    end
                end
            end    
          DIVUW:
            begin
              if (i_div_out_srcB == 0)
                begin
                  result = 64'hFFFF_FFFF_FFFF_FFFF;
                  div_by_zero = 1'b1;
                end
              else
                begin
                  result  = {{(XLEN/2){quotient[XLEN/2-1]}}, quotient[XLEN/2-1:0]};
                end
            end
          REMW:
            begin
              if (i_div_out_srcB == 0)
                begin
                  result = i_div_out_srcA;
                  div_by_zero = 1'b1;
                end
              else if (i_div_out_srcA == OVERFLOW_SIGNED_A && i_div_out_srcB == OVERFLOW_SIGNED_B)
                begin
                  result = 0;
                  overflow = 1'b1;
                end
              else
                begin
                  if (srcA_srcB_word_sign[1])
                    begin
                      result  = {{(XLEN/2){comp_remainder[XLEN/2-1]}}, comp_remainder[XLEN/2-1:0]};
                    end
                  else
                    begin
                      result  = {{(XLEN/2){remainder[XLEN/2-1]}}, remainder[XLEN/2-1:0]};
                    end
                end
            end
          REMUW:
            begin
              if (i_div_out_srcB == 0)
                begin
                  result = i_div_out_srcA;
                  div_by_zero = 1'b1;
                end
              else
                begin
                  result  = {{(XLEN/2){remainder[XLEN/2-1]}}, remainder[XLEN/2-1:0]};
                end
            end
          default:
            begin
              result  = {{(XLEN/2){quotient[XLEN/2-1]}}, quotient[XLEN/2-1:0]};
            end
        endcase
      end
  end

always_ff @(posedge i_div_out_clk, negedge i_div_out_rstn)
  begin: result_proc
    if (!i_div_out_rstn) 
      begin
        o_div_out_result <= 0;
        o_div_out_div_by_zero <= 1'b0;
        o_div_out_overflow <= 1'b0;
        o_div_out_done <= 1'b0;
      end
    else if ((div_by_zero | overflow) & i_div_out_start)
      begin
        o_div_out_result <= result;
        o_div_out_done <= 1'b1;
        o_div_out_div_by_zero <= div_by_zero;
        o_div_out_overflow <= overflow;
      end
    else if (i_div_out_done)
        begin
          o_div_out_result <= result;
          o_div_out_done <= 1'b1;
          o_div_out_div_by_zero <= 1'b0;
          o_div_out_overflow <= 1'b0;
        end
    else
      begin
        o_div_out_done <= 1'b0;
        o_div_out_div_by_zero <= 1'b0;
        o_div_out_overflow <= 1'b0;
      end

  end
endmodule