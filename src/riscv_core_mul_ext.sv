module riscv_core_mul_ext
#(
  parameter XLEN = 64
)
(
  input  logic  [XLEN+3:0]    mul_ext_pp  [16:0],
  output logic  [2*XLEN-1:0]  mul_ext_extended_pp [16:0]
);

genvar j;
generate
  for (j = 0; j < 16 ; j = j + 1) 
    begin
      assign mul_ext_extended_pp[j] = {{(XLEN-(4*j+1)-3){mul_ext_pp[j][XLEN+3]}}, {mul_ext_pp[j]}, {(4*j){1'b0}}};
    end
endgenerate
assign mul_ext_extended_pp[16] = {{mul_ext_pp[16][XLEN-1:0]}, {(64){1'b0}}};

endmodule