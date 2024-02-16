module riscv_core_4_2_compressor1bit
#(
)
(
  input   logic i_4_2_compressor1bit_in1,
  input   logic i_4_2_compressor1bit_in2,
  input   logic i_4_2_compressor1bit_in3,
  input   logic i_4_2_compressor1bit_in4,
  input   logic i_4_2_compressor1bit_cin,
  output  logic o_4_2_compressor1bit_cout,
  output  logic o_4_2_compressor1bit_out1,
  output  logic o_4_2_compressor1bit_out2
);

logic o_full_adder_sum1;

riscv_core_full_adder
#(
)
u_riscv_core_full_adder1
(
  .i_full_adder_in1(i_4_2_compressor1bit_in1),
  .i_full_adder_in2(i_4_2_compressor1bit_in2),
  .i_full_adder_cin(i_4_2_compressor1bit_in3),
  .o_full_adder_cout(o_4_2_compressor1bit_cout),
  .o_full_adder_sum(o_full_adder_sum1)
);

riscv_core_full_adder
#(
)
u_riscv_core_full_adder2
(
  .i_full_adder_in1(i_4_2_compressor1bit_in4),
  .i_full_adder_in2(o_full_adder_sum1),
  .i_full_adder_cin(i_4_2_compressor1bit_cin),
  .o_full_adder_cout(o_4_2_compressor1bit_out2),
  .o_full_adder_sum(o_4_2_compressor1bit_out1)
);
endmodule