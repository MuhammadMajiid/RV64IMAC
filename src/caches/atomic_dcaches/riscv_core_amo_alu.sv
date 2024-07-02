module riscv_core_amo_alu #(
    parameter DATA_WIDTH = 64
) (
    input logic [DATA_WIDTH-1 : 0]   i_data_from_mem ,
    input logic [DATA_WIDTH-1 : 0]   i_data_from_core ,
    input logic [  3          : 0]   i_amo_op,
    output logic [DATA_WIDTH-1 : 0]  o_amo_alu_result 
);


always_comb begin : amo_operations
    o_amo_alu_result = 'b0;
    case (i_amo_op)
    
        // AMOSWAP
      4'b0000  :  o_amo_alu_result = i_data_from_core;
      
        // AMOADD
      4'b0001  :  o_amo_alu_result = i_data_from_mem + i_data_from_core;
      
        // AMOAND
      4'b0010  :  o_amo_alu_result = i_data_from_mem & i_data_from_core;
      
        // AMOOR
      4'b0011  :  o_amo_alu_result = i_data_from_mem | i_data_from_core;
      
        // AMOXOR
      4'b0100  :  o_amo_alu_result = i_data_from_mem ^ i_data_from_core;
      
        // AMOMAX_SIGNED
      4'b0101  :  o_amo_alu_result = ( $signed(i_data_from_mem)  > $signed(i_data_from_core) ) ? i_data_from_mem : i_data_from_core ;
      
        // AMOMIN_SIGNED
      4'b0110  :  o_amo_alu_result = ( $signed(i_data_from_mem)  < $signed(i_data_from_core) ) ? i_data_from_mem : i_data_from_core ;
    
        // AMOMAX_UNSIGNED
      4'b0111  :  o_amo_alu_result = ( i_data_from_mem  > i_data_from_core  )  ? i_data_from_mem : i_data_from_core ;

        // AMOMIN_UNSIGNED
      4'b1000  :  o_amo_alu_result = ( i_data_from_mem  < i_data_from_core  ) ?  i_data_from_mem : i_data_from_core ;

      default  : o_amo_alu_result = 'b0;
    endcase

end
    
endmodule