module riscv_core_4_2_compressor
#(
  parameter XLEN = 64
)
(
  input   logic [2*XLEN-1:0] i_4_2_compressor_in1,
  input   logic [2*XLEN-1:0] i_4_2_compressor_in2,
  input   logic [2*XLEN-1:0] i_4_2_compressor_in3,
  input   logic [2*XLEN-1:0] i_4_2_compressor_in4,
  input   logic              i_4_2_compressor_cin,
  output  logic              o_4_2_compressor_cout,
  output  logic [2*XLEN-1:0] o_4_2_compressor_out1,
  output  logic [2*XLEN-1:0] o_4_2_compressor_out2
);

logic [2*XLEN:0] csa1_cin;

assign csa1_cin[0] = i_4_2_compressor_cin;

generate
  genvar i;
  for (i = 0; i < 2*XLEN; i = i + 1)
    begin
      riscv_core_4_2_compressor1bit
      #(
      )
      u_riscv_core_4_2_compressor1bit
      (
        .i_4_2_compressor1bit_in1(i_4_2_compressor_in1[i]),
        .i_4_2_compressor1bit_in2(i_4_2_compressor_in2[i]),
        .i_4_2_compressor1bit_in3(i_4_2_compressor_in3[i]),
        .i_4_2_compressor1bit_in4(i_4_2_compressor_in4[i]),
        .i_4_2_compressor1bit_cin(csa1_cin[i]),
        .o_4_2_compressor1bit_cout(csa1_cin[i+1]),
        .o_4_2_compressor1bit_out1(o_4_2_compressor_out1[i]),
        .o_4_2_compressor1bit_out2(o_4_2_compressor_out2[i])
      );
    end
endgenerate

endmodule