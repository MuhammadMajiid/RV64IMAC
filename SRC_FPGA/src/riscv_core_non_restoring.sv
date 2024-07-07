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
  output logic            o_non_restoring_done,
  output logic [XLEN-1:0] o_non_restoring_quotient,
  output logic [XLEN-1:0] o_non_restoring_remainder
);
typedef enum logic {IDLE, DIVIDE} State;

State state_reg, state_next;

logic [XLEN-1:0]        dividend_reg, dividend_next;        // Q reg
logic [XLEN:0]          accumulator_reg, accumulator_next;  // A reg
logic [$clog2(XLEN):0]  cnt_reg, cnt_next;                  // n counter

    
always_ff @(posedge i_non_restoring_clk, negedge i_non_restoring_rstn)
  begin: state_register_proc
    if (!i_non_restoring_rstn) 
      begin
        state_reg <= IDLE;
        dividend_reg <= 0;
        accumulator_reg <= 0;
        cnt_reg <= 64;
      end
    else
      begin
        state_reg <= state_next;
        dividend_reg <= dividend_next;
        accumulator_reg <= accumulator_next;
        cnt_reg <= cnt_next;
      end
  end

always_comb
  begin: next_state_logic_proc
    dividend_next = dividend_reg;
    accumulator_next = accumulator_reg;
    cnt_next = cnt_reg;
    o_non_restoring_done = 1'b0;
    o_non_restoring_quotient = 0;
    o_non_restoring_remainder = 0;
    case (state_reg)
      IDLE:
        begin
          if (i_non_restoring_en)
            begin
              dividend_next = i_non_restoring_dividend;
              accumulator_next = 0;
              cnt_next = 64;
              state_next = DIVIDE;
            end
          else
            begin
              state_next = IDLE;
            end
        end
      DIVIDE:
        begin
          if (accumulator_reg[XLEN])
            begin
              {accumulator_next, dividend_next} = {accumulator_reg, dividend_reg, 1'b0};
              accumulator_next = accumulator_next + i_non_restoring_divisor;
            end
          else
            begin
              {accumulator_next, dividend_next} = {accumulator_reg, dividend_reg, 1'b0};
              accumulator_next = accumulator_next - i_non_restoring_divisor;
            end
          if (accumulator_next[XLEN])
            begin
              dividend_next[0] = 1'b0;
            end
          else
            begin
              dividend_next[0] = 1'b1;
            end
          cnt_next = cnt_reg - 1;
          if (cnt_next == 0) 
            begin
              if (accumulator_next[XLEN])
                begin
                  accumulator_next = accumulator_next + i_non_restoring_divisor;
                end
              else
                begin
                  accumulator_next = accumulator_reg;
                end
              o_non_restoring_done = 1'b1;
              o_non_restoring_quotient = dividend_next;
              o_non_restoring_remainder = accumulator_next;
              state_next = IDLE;
            end
          else
            begin
              state_next = DIVIDE;
            end
        end
      default:
        begin
          state_next = IDLE;
        end
    endcase
  end

endmodule