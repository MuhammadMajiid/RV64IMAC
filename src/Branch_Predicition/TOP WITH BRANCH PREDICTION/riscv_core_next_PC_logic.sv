module riscv_core_next_PC_logic 
#(
  parameter ADDRLEN = 64
)
(
  input logic                  i_next_PC_logic_misprediction,
  input logic                  i_next_PC_logic_valid,
  input logic                  i_next_PC_logic_isTaken_BP,
  input logic  [ADDRLEN-1 : 0] i_next_PC_logic_predictedAddr,
  input logic  [ADDRLEN-1 : 0] i_next_PC_logic_recoveredAddr,
  input logic  [ADDRLEN-1 : 0] i_next_PC_logic_PC_plus_offset,
  output logic [ADDRLEN-1 : 0] o_next_PC_logic_next_PC
);

logic BP_sel;
assign BP_sel = i_next_PC_logic_valid & i_next_PC_logic_isTaken_BP;

always_comb
  begin
    if (i_next_PC_logic_misprediction) 
      begin
        o_next_PC_logic_next_PC = i_next_PC_logic_recoveredAddr;
      end
    else if (BP_sel)
      begin
        o_next_PC_logic_next_PC = i_next_PC_logic_predictedAddr;
      end
    else
      begin
        o_next_PC_logic_next_PC = i_next_PC_logic_PC_plus_offset;
      end
  end

endmodule