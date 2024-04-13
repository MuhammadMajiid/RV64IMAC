module riscv_core_mux_2to1 #(
    parameter DATA_WIDTH = 64 
) (
    input logic [DATA_WIDTH-1 :0] i_input0 ,
    input logic [DATA_WIDTH-1 :0] i_input1 ,
    input logic                   i_sel ,
    output logic [DATA_WIDTH-1 :0] o_mux_out
);

always_comb begin : MUX_PROC
    o_mux_out = 0;
    case (i_sel)
      1'b0  : o_mux_out = i_input0;
      1'b1  : o_mux_out = i_input1;
     default: o_mux_out = 0;
    endcase    
end
    
endmodule