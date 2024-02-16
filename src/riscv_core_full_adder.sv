module riscv_core_full_adder
#(
)
(
  input  logic i_full_adder_in1,
  input  logic i_full_adder_in2,
  input  logic i_full_adder_cin,
  output logic o_full_adder_cout,
  output logic o_full_adder_sum
);

assign {o_full_adder_cout, o_full_adder_sum} = i_full_adder_in1 + i_full_adder_in2 + i_full_adder_cin;

endmodule