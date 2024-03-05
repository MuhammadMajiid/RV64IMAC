module riscv_core_mul_div_ctrl
#(
  parameter XLEN = 64
)
(
  input   logic [XLEN-1:0] i_mul_div_ctrl_srcA,
  input   logic [XLEN-1:0] i_mul_div_ctrl_srcB,
  input   logic [2:0]      i_mul_div_ctrl_control,
  input   logic            i_mul_div_ctrl_en,
  input   logic            i_mul_div_ctrl_isword,
  input   logic            i_mul_div_ctrl_clk,
  input   logic            i_mul_div_ctrl_rstn,
  input   logic            i_mul_div_ctrl_mul_dn,
  input   logic            i_mul_div_ctrl_div_dn,
  input   logic [5:0]      i_mul_div_ctrl_mul_fast,
  input   logic [6:0]      i_mul_div_ctrl_div_fast,
  output  logic [XLEN-1:0] o_mul_div_ctrl_out_fast,
  output  logic            o_mul_div_ctrl_mul_start,
  output  logic            o_mul_div_ctrl_div_start,
  output  logic            o_mul_div_ctrl_busy,
  output  logic            o_mul_div_ctrl_done,
  output  logic            o_mul_div_ctrl_div_by_zero,
  output  logic            o_mul_div_ctrl_overflow,
  output  logic            o_mul_div_ctrl_mul_div_sel,
  output  logic            o_mul_div_ctrl_out_sel
);

typedef enum logic [1:0] {IDLE, FAST, MUL, DIV} State;

State state_reg, state_next;

logic [XLEN-1:0] out_fast;
logic            div_by_zero;
logic            overflow;

always_comb
  begin: fast_result_proc
    out_fast = 0;
    div_by_zero = 1'b0;
    overflow = 1'b0;
    if (i_mul_div_ctrl_control[2])
      begin
        if (i_mul_div_ctrl_control[1]) // REM/REMU
          begin
            case (i_mul_div_ctrl_div_fast)
              7'b1000001: 
                begin
                  if (i_mul_div_ctrl_control[0]) // REMU
                    begin
                      out_fast = 64'h8000_0000_0000_0000; 
                      overflow = 1'b0;
                    end
                  else // REM
                    begin
                      out_fast = 0; 
                      overflow = 1'b1;
                    end
                end
              7'b0000010: out_fast = 1;
              7'b0000100: out_fast = 0;
              7'b0001000: out_fast = -1;
              7'b0010000: out_fast = i_mul_div_ctrl_srcA;
              7'b0100000: 
                begin 
                  out_fast = i_mul_div_ctrl_srcA; 
                  div_by_zero = 1'b1;
                end
              7'b1000000: out_fast = ~i_mul_div_ctrl_srcA + 1;
              default: 
                out_fast = 0;
            endcase
          end
        else // DIV/DIVU
          begin
            case (i_mul_div_ctrl_div_fast)
              7'b1000001: 
              begin
                if (i_mul_div_ctrl_control[0]) // DIVU
                    begin
                      out_fast = 0; 
                      overflow = 1'b0;
                    end
                else // DIV
                  begin
                    out_fast = 64'h8000_0000_0000_0000; 
                    overflow = 1'b1;
                  end
              end
              7'b0000010: out_fast = 0;
              7'b0000100: out_fast = 0;
              7'b0001000: out_fast = 0;
              7'b0010000: out_fast = i_mul_div_ctrl_srcA;
              7'b0100000: 
              begin
                out_fast = 64'hFFFF_FFFF_FFFF_FFFF; 
                div_by_zero = 1'b1;
              end
              7'b1000000: out_fast = ~i_mul_div_ctrl_srcA + 1;
              default: out_fast = 0;
            endcase
          end
      end
    else
      begin
        case (i_mul_div_ctrl_mul_fast) // MUL/MULH/MULHSU/MULHU
          6'b000001: out_fast = i_mul_div_ctrl_srcB;
          6'b000010: out_fast = 0;
          6'b000100: out_fast = ~i_mul_div_ctrl_srcB + 1;
          6'b001000: out_fast = i_mul_div_ctrl_srcA;
          6'b010000: out_fast = 0;
          6'b100000: out_fast = ~i_mul_div_ctrl_srcA + 1;
          default: out_fast = 0;
        endcase
      end
  end

always_ff @(posedge i_mul_div_ctrl_clk, negedge i_mul_div_ctrl_rstn)
  begin: state_register_proc
    if (!i_mul_div_ctrl_rstn)
      begin
        state_reg <= IDLE;
      end
    else
      begin
        state_reg <= state_next;
      end
  end

always_comb
    begin: next_state_logic_proc
      o_mul_div_ctrl_mul_start = 1'b0;
      o_mul_div_ctrl_div_start = 1'b0;
      o_mul_div_ctrl_busy = 1'b0;
      case (state_reg)
        IDLE:
          begin
            if (i_mul_div_ctrl_en & (|{i_mul_div_ctrl_mul_fast, i_mul_div_ctrl_div_fast}))
              begin
                state_next = FAST;
                o_mul_div_ctrl_busy = 1'b1;
              end
            else if (i_mul_div_ctrl_en & !i_mul_div_ctrl_control[2])
              begin
                state_next = MUL;
                o_mul_div_ctrl_mul_start = 1'b1;
                o_mul_div_ctrl_busy = 1'b1;
              end
            else if (i_mul_div_ctrl_en & i_mul_div_ctrl_control[2])
              begin
                state_next = DIV;
                o_mul_div_ctrl_div_start = 1'b1;
                o_mul_div_ctrl_busy = 1'b1;
              end
            else
              begin
                o_mul_div_ctrl_busy = 1'b0;
                state_next = IDLE;
              end
          end
        FAST:
          begin
            state_next = IDLE;
            o_mul_div_ctrl_busy = 1'b1;
          end
        MUL:
          begin
            if (i_mul_div_ctrl_mul_dn) 
              begin
                state_next = IDLE;
                o_mul_div_ctrl_busy = 1'b0;
              end
            else
              begin
                state_next = MUL;
                o_mul_div_ctrl_busy = 1'b1;
              end
          end
        DIV:
          begin
            if (i_mul_div_ctrl_div_dn) 
              begin
                state_next = IDLE;
                o_mul_div_ctrl_busy = 1'b0;
              end
            else
              begin
                state_next = DIV;
                o_mul_div_ctrl_busy = 1'b1;
              end
          end
        default: 
          begin
            state_next = IDLE;
          end
      endcase
    end
  
always_comb
begin: output_logic_proc
  o_mul_div_ctrl_out_fast = 0;
  o_mul_div_ctrl_done = 1'b0;
  o_mul_div_ctrl_div_by_zero = 1'b0;
  o_mul_div_ctrl_overflow = 1'b0;
  case (state_reg)
    IDLE:
      begin
        o_mul_div_ctrl_out_fast = 0;
        o_mul_div_ctrl_div_by_zero = 0;
        o_mul_div_ctrl_overflow = 0;
      end
    FAST:
      begin
        o_mul_div_ctrl_out_fast = out_fast;
        o_mul_div_ctrl_div_by_zero = div_by_zero;
        o_mul_div_ctrl_overflow = overflow;
        o_mul_div_ctrl_done = 1'b1;
      end
    MUL:
      begin
        if (i_mul_div_ctrl_mul_dn) 
          begin
            o_mul_div_ctrl_done = 1'b1;
          end
        else
          begin
            o_mul_div_ctrl_done = 1'b0;
          end
      end
    DIV:
      begin
        if (i_mul_div_ctrl_div_dn) 
          begin
            o_mul_div_ctrl_done = 1'b1;
          end
        else
          begin
            o_mul_div_ctrl_done = 1'b0;
          end
      end
    default: 
      begin
        o_mul_div_ctrl_out_fast = 0;
        o_mul_div_ctrl_done = 1'b0;
        o_mul_div_ctrl_div_by_zero = 1'b0;
        o_mul_div_ctrl_overflow = 1'b0;
      end
  endcase
end

assign o_mul_div_ctrl_mul_div_sel = i_mul_div_ctrl_control[2];
assign o_mul_div_ctrl_out_sel = |{i_mul_div_ctrl_mul_fast, i_mul_div_ctrl_div_fast};

endmodule