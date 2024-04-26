module riscv_core_booth
#(
  parameter XLEN = 64
)
(
  input  logic [XLEN-1:0]   i_booth_multiplicand,
  input  logic [XLEN-1:0]   i_booth_multilpier,
  input  logic              i_booth_en,
  input  logic              i_booth_clk,
  input  logic              i_booth_rstn,
  output logic              o_booth_done,
  output logic [2*XLEN-1:0] o_booth_product
);
typedef enum logic {IDLE, MUL} State;

State state_reg, state_next;

logic [XLEN-1:0]        multiplier_reg, multiplier_next;          // M reg
logic [XLEN-1:0]        accumulator_reg, accumulator_next;  // A reg
logic                   carry_reg;
logic [$clog2(XLEN):0]  cnt_reg, cnt_next;                  // n counter
    
always_ff @(posedge i_booth_clk, negedge i_booth_rstn)
  begin: state_register_proc
    if (!i_booth_rstn) 
      begin
        state_reg <= IDLE;
        multiplier_reg <= 0;
        accumulator_reg <= 0;
        cnt_reg <= 64;
      end
    else
      begin
        state_reg <= state_next;
        multiplier_reg <= multiplier_next;
        accumulator_reg <= accumulator_next;
        cnt_reg <= cnt_next;
      end
  end

always_comb
  begin: next_state_logic_proc
    multiplier_next = multiplier_reg;
    accumulator_next = accumulator_reg;
    carry_reg = 0;
    state_next = state_reg;
    cnt_next = cnt_reg;
    o_booth_done = 1'b0;
    o_booth_product = 0;
    case (state_reg)
      IDLE:
        begin
          if (i_booth_en)
            begin
              multiplier_next = i_booth_multilpier;
              accumulator_next = 0;
              carry_reg = 0;
              cnt_next = 64;
              state_next = MUL;
            end
          else
            begin
              state_next = IDLE;
            end
        end
      MUL:
        begin
          if (multiplier_reg[0])
            begin
              {carry_reg, accumulator_next} = accumulator_reg + i_booth_multiplicand;
              {carry_reg, accumulator_next, multiplier_next} = {carry_reg, accumulator_next, multiplier_reg} >>> 1;
            end
          else
            begin
              {carry_reg, accumulator_next, multiplier_next} = {carry_reg, accumulator_reg, multiplier_reg} >>> 1;
            end
          cnt_next = cnt_reg - 1;
          if (cnt_next == 0) 
            begin
              state_next = IDLE;
              o_booth_done = 1'b1;
              o_booth_product = {accumulator_next, multiplier_next};
            end
          else
            begin
              state_next = MUL;
            end
        end
      default:
        begin
          state_next = IDLE;
        end
    endcase
  end

endmodule