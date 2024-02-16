module riscv_core_cla_4bit
#(
  parameter WIDTH = 4  // operand width
)
(
  input  logic  [WIDTH-1:0]  i_cla_4bit_op1,
  input  logic  [WIDTH-1:0]  i_cla_4bit_op2,
  input  logic               i_cla_4bit_cin,
  output logic  [WIDTH-1:0]  o_cla_4bit_sum,
  output logic               o_cla_4bit_cout
);

logic [WIDTH-1:0] g;    // carry generated
logic [WIDTH-1:0] p;    // carry propagated
logic [WIDTH:0]   c;    // carry
integer j;

//gp generator

genvar i;
generate;
  for ( i=0 ; i<WIDTH ; i=i+1 )
    begin
      riscv_core_gp_gen u_riscv_core_gp_gen (.i_gp_gen_in1(i_cla_4bit_op1[i]),.i_gp_gen_in2(i_cla_4bit_op2[i]),.o_gp_gen_g(g[i]),.o_gp_gen_p(p[i]));    
    end
endgenerate

//carry generator

assign c[0] = i_cla_4bit_cin;
assign c[1] = g[0] + ( c[0] & p[0] );
assign c[2] = g[1] + ( (g[0] + ( c[0] & p[0]) ) & p[1] );
assign c[3] = g[2] + ( (g[1] + ( (g[0] + (c[0] & p[0]) ) & p[1])) & p[2] );
assign c[4] = g[3] + ( (g[2] + ( (g[1] + ( (g[0] + (c[0] & p[0]) ) & p[1])) & p[2] )) & p[3]);
assign o_cla_4bit_cout = c[WIDTH];

//sum generator

always_comb
  begin: sum_proc
    for ( j=0 ; j<WIDTH ; j=j+1 )
      begin
        o_cla_4bit_sum[j] = p[j] ^ c[j];
      end
  end

endmodule