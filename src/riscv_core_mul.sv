module riscv_core_mul
#(
  parameter XLEN = 64
)
( 
  input   logic [XLEN-1:0] i_mul_srcA,
  input   logic [XLEN-1:0] i_mul_srcB,
  input   logic [1:0]      i_mul_control,
  input   logic            i_mul_isword,
  input   logic            i_mul_en,
  output  logic [XLEN-1:0] o_mul_result
);


logic [XLEN-1:0]   multiplicand;
logic [XLEN-1:0]   multiplier;

riscv_core_mul_in
#(
  .XLEN(XLEN)
)
u_riscv_core_mul_in
(
  .i_mul_in_srcA(i_mul_srcA),
  .i_mul_in_srcB(i_mul_srcB),
  .i_mul_in_control(i_mul_control),
  .i_mul_in_isword(i_mul_isword),
  .o_mul_in_multiplicand(multiplicand),
  .o_mul_in_multiplier(multiplier)
);


// perform radix-16 modified booth encoding for unsigned multiplication
// number of partial products = ceil{(64+1)/log2{16}} = 17 each of length M+1=65
// multiplier is divided into overlapping groups each of 5-bits 
// possibilities +/- {0, Y, Y, 2Y, 2Y, 3Y, 3Y, 4Y, 4Y, 5Y, 5Y, 6Y, 6Y, 7Y, 7Y, 8Y}

logic [XLEN+3:0] pp [16:0];

riscv_core_16booth_encoder
#(
  .XLEN(XLEN)
)
u_riscv_core_16booth_encoder_pp0
(
  .i_16booth_encoder_muld(multiplicand),
  .i_16booth_encoder_sel({multiplier[3:0], 1'b0}),
  .o_16booth_encoder_pp(pp[0])
);

riscv_core_16booth_encoder
#(
  .XLEN(XLEN)
)
u_riscv_core_16booth_encoder_pp16
(
  .i_16booth_encoder_muld(multiplicand),
  .i_16booth_encoder_sel({4'b0000, multiplier[XLEN-1]}),
  .o_16booth_encoder_pp(pp[16])
);

genvar i;
generate
  for (i = 1; i < 16 ; i = i + 1) 
    begin
      riscv_core_16booth_encoder
      #(
        .XLEN(XLEN)
      )
      u_riscv_core_16booth_encoder
      (
        .i_16booth_encoder_muld(multiplicand),
        .i_16booth_encoder_sel(multiplier[4*i+3:4*i-1]),
        .o_16booth_encoder_pp(pp[i])
      );
    end
endgenerate

// extinding partial products to 128-bit

logic [2*XLEN-1:0] extended_pp [16:0];

riscv_core_mul_ext
#(
  .XLEN(XLEN)
)
u_riscv_core_mul_ext
(
  .mul_ext_pp(pp),
  .mul_ext_extended_pp(extended_pp)
);


// tree of 4-2 compressor

// Level1
logic [2*XLEN-1:0] compressed_result_lvl1 [7:0];
logic [3:0]        cout_lvl1;
genvar c;
generate
  for (c = 0; c < 4 ; c = c + 1) 
    begin
      riscv_core_4_2_compressor
      #(
        .XLEN(XLEN)
      )
      u_riscv_core_4_2_compressor_lvl1
      (
        .i_4_2_compressor_in1(extended_pp[4*c]),
        .i_4_2_compressor_in2(extended_pp[4*c+1]),
        .i_4_2_compressor_in3(extended_pp[4*c+2]),
        .i_4_2_compressor_in4(extended_pp[4*c+3]),
        .i_4_2_compressor_cin(1'b0),
        .o_4_2_compressor_cout(cout_lvl1[c]),
        .o_4_2_compressor_out1(compressed_result_lvl1[2*c]),
        .o_4_2_compressor_out2(compressed_result_lvl1[2*c+1])
      );
    end
endgenerate


// Level2
logic [2*XLEN-1:0] compressed_result_lvl2 [3:0];
logic [1:0]        cout_lvl2;
genvar k;
generate
  for (k = 0; k < 2 ; k = k + 1) 
    begin
      riscv_core_4_2_compressor
      #(
        .XLEN(XLEN)
      )
      u_riscv_core_4_2_compressor_lvl2
      (
        .i_4_2_compressor_in1(compressed_result_lvl1[4*k][2*XLEN-1:0]),
        .i_4_2_compressor_in2({compressed_result_lvl1[4*k+1][2*XLEN-2:0], 1'b0}),
        .i_4_2_compressor_in3(compressed_result_lvl1[4*k+2][2*XLEN-1:0]),
        .i_4_2_compressor_in4({compressed_result_lvl1[4*k+3][2*XLEN-2:0], 1'b0}),
        .i_4_2_compressor_cin(1'b0),
        .o_4_2_compressor_cout(cout_lvl2[k]),
        .o_4_2_compressor_out1(compressed_result_lvl2[2*k]),
        .o_4_2_compressor_out2(compressed_result_lvl2[2*k+1])
      );
    end
endgenerate

// Level3
logic [2*XLEN-1:0] compressed_result_lvl3 [1:0];
logic              cout_lvl3;
riscv_core_4_2_compressor
#(
  .XLEN(XLEN)
)
u_riscv_core_4_2_compressor_lvl3
(
  .i_4_2_compressor_in1(compressed_result_lvl2[0][2*XLEN-1:0]),
  .i_4_2_compressor_in2({compressed_result_lvl2[1][2*XLEN-2:0], 1'b0}),
  .i_4_2_compressor_in3(compressed_result_lvl2[2][2*XLEN-1:0]),
  .i_4_2_compressor_in4({compressed_result_lvl2[3][2*XLEN-2:0], 1'b0}),
  .i_4_2_compressor_cin(1'b0),
  .o_4_2_compressor_cout(cout_lvl3),
  .o_4_2_compressor_out1(compressed_result_lvl3[0]),
  .o_4_2_compressor_out2(compressed_result_lvl3[1])
);

// Level4
logic [2*XLEN-1:0] compressed_result_lvl4 [1:0];
logic              cout_lvl4;
riscv_core_4_2_compressor
#(
  .XLEN(XLEN)
)
u_riscv_core_4_2_compressor_lvl4
(
  .i_4_2_compressor_in1(compressed_result_lvl3[0][2*XLEN-1:0]),
  .i_4_2_compressor_in2({compressed_result_lvl3[1][2*XLEN-2:0], 1'b0}),
  .i_4_2_compressor_in3(extended_pp[16]),
  .i_4_2_compressor_in4(128'b0),
  .i_4_2_compressor_cin(1'b0),
  .o_4_2_compressor_cout(cout_lvl4),
  .o_4_2_compressor_out1(compressed_result_lvl4[0]),
  .o_4_2_compressor_out2(compressed_result_lvl4[1])
);


// perform addition using Carry Look Ahead Adder

logic [2*XLEN-1:0] product;
logic              cla_cout;

riscv_core_cla_128bit
#(
  .WIDTH(2*XLEN)
)
u_riscv_core_cla_128bit
(
  .i_core_cla_128bit_op1(compressed_result_lvl4[0][2*XLEN-1:0]),
  .i_core_cla_128bit_op2({compressed_result_lvl4[1][2*XLEN-2:0], 1'b0}),
  .o_core_cla_128bit_sum(product),
  .o_core_cla_128bit_cout(cla_cout)
);

riscv_core_mul_out
#(
  .XLEN(XLEN)
)
u_riscv_core_mul_out
(
  .i_mul_out_srcA(i_mul_srcA),
  .i_mul_out_srcB(i_mul_srcB),
  .i_mul_out_control(i_mul_control),
  .i_mul_out_isword(i_mul_isword),
  .i_mul_out_en(i_mul_en),
  .i_mul_out_product(product),
  .o_mul_out_result(o_mul_result)
);
endmodule