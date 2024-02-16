module riscv_core_cla_128bit
#(
  parameter  WIDTH = 128
)
(
  input   logic  [WIDTH-1:0] i_core_cla_128bit_op1,
  input   logic  [WIDTH-1:0] i_core_cla_128bit_op2,
  output  logic  [WIDTH-1:0] o_core_cla_128bit_sum,
  output  logic              o_core_cla_128bit_cout
);

logic  [WIDTH/4:0]  c; // carry

assign c[0] = 1'b0;  // intial carry with zero

genvar i;
generate;
    for (i = 0; i < 32; i = i + 1)
      begin
        riscv_core_cla_4bit
        #(
        )
        u_riscv_core_cla_4bit 
        (
        .i_cla_4bit_op1  (i_core_cla_128bit_op1[i*4+3:i*4]),
        .i_cla_4bit_op2  (i_core_cla_128bit_op2[i*4+3:i*4]),
        .i_cla_4bit_cin  (c[i])           ,
        .o_cla_4bit_sum  (o_core_cla_128bit_sum[i*4+3:i*4]),
        .o_cla_4bit_cout (c[i+1])
        );  
      end
endgenerate

assign o_core_cla_128bit_cout = c[WIDTH/4];

endmodule