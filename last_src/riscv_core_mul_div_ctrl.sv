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

localparam [6:0] OVERFLOW = 7'b0000001;
localparam [6:0] DIVBYZERO = 7'b0100000;

logic [6:0] fast_reg;
logic [6:0] fastw_reg;
logic       fast_sel;

logic [XLEN-1:0] out_fast;
logic            div_by_zero;
logic            overflow;

assign fast_reg = {(i_mul_div_ctrl_srcB == -1), (i_mul_div_ctrl_srcB == 1), (i_mul_div_ctrl_srcB == 0), (i_mul_div_ctrl_srcA == -1), (i_mul_div_ctrl_srcA == 1), (i_mul_div_ctrl_srcA == 0), (i_mul_div_ctrl_srcA == 64'h8000_0000_0000_0000)&(i_mul_div_ctrl_srcB == -1)&(i_mul_div_ctrl_control == 3'b1x0)};
assign fastw_reg = {(i_mul_div_ctrl_srcB[XLEN/2-1:0] == -1), (i_mul_div_ctrl_srcB[XLEN/2-1:0] == 1), (i_mul_div_ctrl_srcB[XLEN/2-1:0] == 0), (i_mul_div_ctrl_srcA[XLEN/2-1:0] == -1), (i_mul_div_ctrl_srcA[XLEN/2-1:0] == 1), (i_mul_div_ctrl_srcA[XLEN/2-1:0] == 0), (i_mul_div_ctrl_srcA[XLEN/2-1:0] == 32'h8000_0000)&(i_mul_div_ctrl_srcB[XLEN/2-1:0] == -1)};


always_comb
  begin: fast_result_proc
    out_fast = 0;
    div_by_zero = 1'b0;
    overflow = 1'b0;
    fast_sel = 1'b0;
    if (!i_mul_div_ctrl_isword)
      begin
        casex (fast_reg)
          7'b1000001: begin // overflow
            if (i_mul_div_ctrl_control[1]) // REM
              begin
                out_fast = 0;
              end
            else // DIV
              begin
                out_fast = 64'h8000_0000_0000_0000;
              end
            fast_sel = 1;
            overflow = 1;
          end
          7'b001xxx0: begin // A*0 -- A/0
            if (i_mul_div_ctrl_control[2]) // division by 0
              begin
                if (i_mul_div_ctrl_control[1]) // REM/REMU
                  begin
                    out_fast = i_mul_div_ctrl_srcA;
                  end
                else // DIV/DIVU
                  begin
                    out_fast = 64'hFFFF_FFFF_FFFF_FFFF;
                  end
              end
            else // multiplication by 0
              begin
                out_fast = 0;
              end
            fast_sel = 1;
            div_by_zero = 1;
          end
          7'bxx00010: begin // 0*B -- 0/B
            out_fast = 0;
            fast_sel = 1;
          end
          7'b1000000: begin // A*-1 -- A/-1
            if (i_mul_div_ctrl_control[2]) // division by -1
              begin
                if (i_mul_div_ctrl_control[1]) // REM/REMU
                  begin
                    out_fast = 0;
                    fast_sel = 1;
                  end
                else // DIV/DIVU
                  begin
                    out_fast = ~i_mul_div_ctrl_srcA + 1;
                    fast_sel = 0;
                  end
              end
            else // multiplication by -1
              begin
                if (i_mul_div_ctrl_control[1:0] == 2'b00) // MUL
                  begin
                    out_fast = ~i_mul_div_ctrl_srcA + 1;
                    fast_sel = 1;
                  end
                else // MULH/MULHSU/MULHU
                  begin
                    out_fast = 64'hFFFF_FFFF_FFFF_FFFF;
                    fast_sel = 0;
                  end
              end  
          end
          7'b0100000: begin // A*1 -- A/1
            if (i_mul_div_ctrl_control[2]) // division by 1
              begin
                if (i_mul_div_ctrl_control[1]) // REM/REMU
                  begin
                    out_fast = 0;
                  end
                else // DIV/DIVU
                  begin
                    out_fast = i_mul_div_ctrl_srcA;
                  end
              end
            else // multiplication by 1
              begin
                if (i_mul_div_ctrl_control[1:0] == 2'b00) // MUL
                  begin
                    out_fast = i_mul_div_ctrl_srcA;
                  end
                else // MULH/MULHSU/MULHU
                  begin
                    out_fast = 0;
                  end
              end
            fast_sel = 1;
          end
          7'b1001000: begin // -1*-1 -- -1/-1
            if (i_mul_div_ctrl_control[2]) // -1/-1
              begin
                if (i_mul_div_ctrl_control[1]) // REM/REMU
                  begin
                    out_fast = 0;
                    fast_sel = 1;
                  end
                else // DIV/DIVU
                  begin
                    out_fast = 1;
                    fast_sel = 1;
                  end
              end
            else // -1*-1
              begin
                if (i_mul_div_ctrl_control[1:0] == 2'b00) // MUL
                  begin
                    out_fast = 1;
                    fast_sel = 1;
                  end
                else if (i_mul_div_ctrl_control[1:0] == 2'b01)// MULH
                  begin
                    out_fast = 0;
                    fast_sel = 1;
                  end
                else // MULHSU/MULHU
                  begin
                    out_fast = 0;
                    fast_sel = 0;
                  end
              end
          end
          7'b0100100: begin // 1*1 -- 1/1
            if (i_mul_div_ctrl_control[2]) // 1/1
              begin
                if (i_mul_div_ctrl_control[1]) // REM/REMU
                  begin
                    out_fast = 0;
                  end
                else // DIV/DIVU
                  begin
                    out_fast = 1;
                  end
              end
            else // 1*1
              begin
                if (i_mul_div_ctrl_control[1:0] == 2'b00) // MUL
                  begin
                    out_fast = 1;
                  end
                else // MULH/MULHSU/MULHU
                  begin
                    out_fast = 0;
                  end
              end
            fast_sel = 1;
          end
          7'b1000100: begin // 1*-1 -- 1/-1
            if (i_mul_div_ctrl_control[2])
              begin
                if (i_mul_div_ctrl_control[1]) // REM/REMU
                  begin
                    out_fast = 0;
                    fast_sel = 1;
                  end
                else // DIV/DIVU
                  begin
                    out_fast = -1;
                    fast_sel = 0;
                  end
              end
            else 
              begin
                if (i_mul_div_ctrl_control[1:0] == 2'b00) // MUL
                  begin
                    out_fast = -1;
                    fast_sel = 1;
                  end
                else if (i_mul_div_ctrl_control[1:0] == 2'b01) // MULH
                  begin
                    out_fast = -1;
                    fast_sel = 1;
                  end
                else // MULHSU/MULHU
                  begin
                    out_fast = 0;
                    fast_sel = 1;
                  end
              end
          end
          7'b0101000: begin // -1*1 -- -1/1
            if (i_mul_div_ctrl_control[2])
              begin
                if (i_mul_div_ctrl_control[1]) // REM/REMU
                  begin
                    out_fast = 0;
                    fast_sel = 1;
                  end
                else // DIV/DIVU
                  begin
                    out_fast = -1;
                    fast_sel = 0;
                  end
              end
            else 
              begin
                if (i_mul_div_ctrl_control[1:0] == 2'b00) // MUL
                  begin
                    out_fast = -1;
                    fast_sel = 1;
                  end
                else if (i_mul_div_ctrl_control[1:0] == 2'b11) // MULHU
                  begin
                    out_fast = 0;
                    fast_sel = 1;
                  end
                else // MULH/MULHSU
                  begin
                    out_fast = -1;
                    fast_sel = 1;
                  end
              end
          end
          7'b0000100: begin // 1*B -- 1/B
            if (i_mul_div_ctrl_control[2]) // 1/B
              begin
                if (i_mul_div_ctrl_control[1]) // REM/REMU
                  begin
                    out_fast = 1;
                  end
                else // DIV/DIVU
                  begin
                    out_fast = 0;
                  end
              end
            else // 1*B
              begin
                if (i_mul_div_ctrl_control[1:0] == 2'b00) // MUL
                  begin
                    out_fast = i_mul_div_ctrl_srcB;
                  end
                else // MULH/MULHSU/MULHU
                  begin
                    out_fast = 0;
                  end
              end
            fast_sel = 1;
          end
          default: begin
            out_fast = 0;
            fast_sel = 0;
          end
        endcase
      end
    else
      begin
        casex (fastw_reg)
          7'b1000001: begin // overflow
            if (i_mul_div_ctrl_control[1]) // REM
              begin
                out_fast = 0;
              end
            else // DIV
              begin
                out_fast = 64'hFFFF_FFFF_8000_0000;
              end
            fast_sel = 1;
            overflow = 1;
          end
          7'b001xxx0: begin // A*0 -- A/0
            if (i_mul_div_ctrl_control[2]) // division by 0
              begin
                if (i_mul_div_ctrl_control[1]) // REM/REMU
                  begin
                    out_fast = {{(XLEN/2){i_mul_div_ctrl_srcA[XLEN/2-1]}}, i_mul_div_ctrl_srcA[XLEN/2-1:0]};
                  end
                else // DIV/DIVU
                  begin
                    out_fast = 64'hFFFF_FFFF_FFFF_FFFF;
                  end
              end
            else // multiplication by 0
              begin
                out_fast = 0;
              end
            fast_sel = 1;
            div_by_zero = 1;
          end
          7'bxx00010: begin // 0*B -- 0/B
            out_fast = 0;
            fast_sel = 1;
          end
          7'b1000000: begin // A*-1 -- A/-1
            if (i_mul_div_ctrl_control[2]) // division by -1
              begin
                if (i_mul_div_ctrl_control[1]) // REM/REMU
                  begin
                    out_fast = 0;
                    fast_sel = 1;
                  end
                else // DIV/DIVU
                  begin
                    out_fast = ~i_mul_div_ctrl_srcA + 1;
                    fast_sel = 0;
                  end
              end
            else // multiplication by -1
              begin
                if (i_mul_div_ctrl_control[1:0] == 2'b00) // MUL
                  begin
                    out_fast = ~i_mul_div_ctrl_srcA + 1;
                    fast_sel = 1;
                  end
                else // MULH/MULHSU/MULHU
                  begin
                    out_fast = 64'hFFFF_FFFF_FFFF_FFFF;
                    fast_sel = 0;
                  end
              end
          end
          7'b0100000: begin // A*1 -- A/1
            if (i_mul_div_ctrl_control[2]) // division by 1
              begin
                if (i_mul_div_ctrl_control[1]) // REM/REMU
                  begin
                    out_fast = 0;
                  end
                else // DIV/DIVU
                  begin
                    out_fast = {{(XLEN/2){i_mul_div_ctrl_srcA[XLEN/2-1]}}, i_mul_div_ctrl_srcA[XLEN/2-1:0]};
                  end
              end
            else // multiplication by 1
              begin
                if (i_mul_div_ctrl_control[1:0] == 2'b00) // MUL
                  begin
                    out_fast = {{(XLEN/2){i_mul_div_ctrl_srcA[XLEN/2-1]}}, i_mul_div_ctrl_srcA[XLEN/2-1:0]};
                  end
                else // MULH/MULHSU/MULHU
                  begin
                    out_fast = 0;
                  end
              end
            fast_sel = 1;
          end
          7'b1001000: begin // -1*-1 -- -1/-1
            if (i_mul_div_ctrl_control[2]) // -1/-1
              begin
                if (i_mul_div_ctrl_control[1]) // REM/REMU
                  begin
                    out_fast = 0;
                    fast_sel = 1;
                  end
                else // DIV/DIVU
                  begin
                    out_fast = 1;
                    fast_sel = 1;
                  end
              end
            else // -1*-1
              begin
                if (i_mul_div_ctrl_control[1:0] == 2'b00) // MUL
                  begin
                    out_fast = 1;
                    fast_sel = 1;
                  end
                else // MULH/MULHSU/MULHU
                  begin
                    out_fast = 0;
                    fast_sel = 0;
                  end
              end
          end
          7'b0100100: begin // 1*1 -- 1/1
            if (i_mul_div_ctrl_control[2]) // 1/1
              begin
                if (i_mul_div_ctrl_control[1]) // REM/REMU
                  begin
                    out_fast = 0;
                  end
                else // DIV/DIVU
                  begin
                    out_fast = 1;
                  end
              end
            else // 1*1
              begin
                if (i_mul_div_ctrl_control[1:0] == 2'b00) // MUL
                  begin
                    out_fast = 1;
                  end
                else // MULH/MULHSU/MULHU
                  begin
                    out_fast = 0;
                  end
              end
            fast_sel = 1;
          end
          7'b1000100: begin // 1*-1 -- 1/-1 
            if (i_mul_div_ctrl_control[2])
              begin
                if (i_mul_div_ctrl_control[1]) // REM/REMU
                  begin
                    out_fast = 0;
                    fast_sel = 1;
                  end
                else // DIV/DIVU
                  begin
                    out_fast = -1;
                    fast_sel = 0;
                  end
              end
            else 
              begin
                if (i_mul_div_ctrl_control[1:0] == 2'b00) // MUL
                  begin
                    out_fast = -1;
                    fast_sel = 1;
                  end
                else // MULH/MULHSU/MULHU
                  begin
                    out_fast = -1;
                    fast_sel = 0;
                  end
              end
          end
          7'b0101000: begin // -1*1 -- -1/1
            if (i_mul_div_ctrl_control[2])
              begin
                if (i_mul_div_ctrl_control[1]) // REM/REMU
                  begin
                    out_fast = 0;
                    fast_sel = 1;
                  end
                else // DIV/DIVU
                  begin
                    out_fast = -1;
                    fast_sel = 0;
                  end
              end
            else 
              begin
                if (i_mul_div_ctrl_control[1:0] == 2'b00) // MUL
                  begin
                    out_fast = -1;
                    fast_sel = 1;
                  end
                else // MULH/MULHSU/MULHU
                  begin
                    out_fast = -1;
                    fast_sel = 0;
                  end
              end
          end
          7'b0000100: begin // 1*B -- 1/B
            if (i_mul_div_ctrl_control[2]) // 1/B
              begin
                if (i_mul_div_ctrl_control[1]) // REM/REMU
                  begin
                    out_fast = 1;
                  end
                else // DIV/DIVU
                  begin
                    out_fast = 0;
                  end
              end
            else // 1*B
              begin
                if (i_mul_div_ctrl_control[1:0] == 2'b00) // MUL
                  begin
                    out_fast = i_mul_div_ctrl_srcB;
                  end
                else // MULH/MULHSU/MULHU
                  begin
                    out_fast = 0;
                  end
              end
            fast_sel = 1;
          end
          default: begin
            out_fast = 0;
            fast_sel = 0;
          end
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
            if (i_mul_div_ctrl_en & fast_sel)
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
assign o_mul_div_ctrl_out_sel = fast_sel;

endmodule