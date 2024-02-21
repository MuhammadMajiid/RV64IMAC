module riscv_core_non_restoring
#(
  parameter XLEN = 64
)
(
  input  logic [XLEN-1:0] i_non_restoring_dividend,
  input  logic [XLEN-1:0] i_non_restoring_divisor,
  input  logic            i_non_restoring_en,
  input  logic            i_non_restoring_clk,
  input  logic            i_non_restoring_rstn,
  output logic            o_non_restoring_busy,
  output logic            o_non_restoring_done,
  output logic            o_non_restoring_start,
  output logic [XLEN-1:0] o_non_restoring_quotient,
  output logic [XLEN-1:0] o_non_restoring_remainder
);
typedef enum logic [1:0] {IDLE, DIVIDE, DONE} State;

State state_reg, state_next;

logic [XLEN-1:0]        dividend_reg, dividend_next;        // Q reg
logic [XLEN:0]          divisor_reg, divisor_next;          // M reg
logic [XLEN:0]          accumulator_reg, accumulator_next;  // A reg
logic [$clog2(XLEN):0]  cnt_reg, cnt_next;                  // n counter

logic                   start_reg, start_next;

always_ff @(posedge i_non_restoring_clk, negedge i_non_restoring_rstn)
  begin
    if (!i_non_restoring_rstn) 
      begin
        start_reg <= 0;
      end
    else
      begin
        start_reg <= start_next;
      end
    end
    
always_ff @(posedge i_non_restoring_clk, negedge i_non_restoring_rstn)
  begin: state_register_proc
    if (!i_non_restoring_rstn) 
      begin
        state_reg <= IDLE;
        dividend_reg <= i_non_restoring_dividend;
        divisor_reg <= i_non_restoring_divisor;
        accumulator_reg <= 0;
        cnt_reg <= 0;
      end
    else
      begin
        state_reg <= state_next;
        dividend_reg <= dividend_next;
        divisor_reg <= divisor_next;
        accumulator_reg <= accumulator_next;
        cnt_reg <= cnt_next;
      end
  end

always_comb
  begin: next_state_logic_proc
    state_next = state_reg;
    dividend_next = dividend_reg;
    divisor_next = divisor_reg;
    accumulator_next = accumulator_reg;
    cnt_next = cnt_reg;
    start_next = 1'b0;
    case (state_reg)
      IDLE:
        begin
          if (i_non_restoring_en)
            begin
              dividend_next = i_non_restoring_dividend;
              divisor_next = i_non_restoring_divisor;
              accumulator_next = 0;
              cnt_next = 0;
              start_next = 1'b1;
              state_next = DIVIDE;
            end
          else
            begin
              start_next = 1'b0;
              state_next = IDLE;
            end
        end
      DIVIDE:
        begin
          if (accumulator_reg[XLEN])
            begin
              {accumulator_next, dividend_next} = {accumulator_reg, dividend_reg, 1'b0};
              accumulator_next = accumulator_next + divisor_reg;
            end
          else
            begin
              {accumulator_next, dividend_next} = {accumulator_reg, dividend_reg, 1'b0};
              accumulator_next = accumulator_next - divisor_reg;
            end
          if (accumulator_next[XLEN])
            begin
              dividend_next[0] = 1'b0;
            end
          else
            begin
              dividend_next[0] = 1'b1;
            end
          cnt_next = cnt_reg + 1;
          if (cnt_reg == XLEN-1) 
            begin
              if (accumulator_reg[XLEN])
                begin
                  accumulator_next = accumulator_next + divisor_reg;
                end
              else
                begin
                  accumulator_next = accumulator_reg;
                end
              state_next = DONE;
            end
          else
            begin
              state_next = DIVIDE;
            end
        end
      DONE:
        begin
          state_next = IDLE;
        end
      default:
        begin
          state_next = IDLE;
        end
    endcase
  end

always_comb
  begin: out_logic_proc
    o_non_restoring_done = 1'b0;
    o_non_restoring_busy = 1'b0;
    o_non_restoring_quotient = 'b0;
    o_non_restoring_remainder = 'b0;
    case (state_reg)
      IDLE:
        begin
          o_non_restoring_done = 1'b0;
          o_non_restoring_busy = 1'b0;
          o_non_restoring_quotient = 'b0;
          o_non_restoring_remainder = 'b0;
        end
      DIVIDE:
        begin
          o_non_restoring_done = 1'b0;
          o_non_restoring_busy = 1'b1;
          o_non_restoring_quotient = 0;
          o_non_restoring_remainder = 0;
        end
      DONE:
        begin
          o_non_restoring_done = 1'b1;
          o_non_restoring_busy = 1'b1;
          o_non_restoring_quotient = dividend_reg;
          o_non_restoring_remainder = accumulator_reg;
        end
      default:
        begin
          o_non_restoring_done = 1'b0;
          o_non_restoring_busy = 1'b0;
          o_non_restoring_quotient = 0;
          o_non_restoring_remainder = 0;
        end
    endcase
  end
  
assign o_non_restoring_start = start_reg;

endmodule