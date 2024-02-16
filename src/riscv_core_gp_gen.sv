module riscv_core_gp_gen(
  input  logic  i_gp_gen_in1,
  input  logic  i_gp_gen_in2,
  output logic  o_gp_gen_g,     // carry generated
  output logic  o_gp_gen_p     // carry propagated
);

assign o_gp_gen_g = i_gp_gen_in1 & i_gp_gen_in2;   
assign o_gp_gen_p = i_gp_gen_in1 ^ i_gp_gen_in2;   

endmodule