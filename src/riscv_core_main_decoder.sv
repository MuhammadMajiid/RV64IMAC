module riscv_core_main_decoder (
    input logic [6:0] i_main_decoder_opcode,
    input logic [2:0] i_main_decoder_funct3,
    output logic [2:0] o_main_decoder_imsrc,
    output logic       o_main_decoder_UCtrl,
    output logic [1:0] o_main_decoder_resultsrc,
    output logic       o_main_decoder_regwrite,
    output logic       o_main_decoder_alusrcB,
    output logic       o_main_decoder_memwrite,
    output logic       o_main_decoder_branch,
    output logic       o_main_decoder_jump,
    output logic [1:0] o_main_decoder_size,
    output logic       o_main_decoder_LdExt,
    output logic       o_main_decoder_isword,
    output logic       o_main_decoder_aluop
);

logic [15:0] control_signals;

assign {o_main_decoder_regwrite,o_main_decoder_imsrc,o_main_decoder_UCtrl,
o_main_decoder_alusrcB,o_main_decoder_memwrite,o_main_decoder_resultsrc,
o_main_decoder_branch,o_main_decoder_aluop,o_main_decoder_size,o_main_decoder_LdExt,o_main_decoder_isword,o_main_decoder_jump} = control_signals;

always_comb begin : control_signals_proc
control_signals = 14'b0;
case (i_main_decoder_opcode)
    // regwrite_imsrc_UCtrl_alusrcB_memwrite_resultsrc_branch_aluop_size_LdExt_isword_jump

    7'b0110011:  control_signals = 16'b1_xxx_x_0_0_00_0_1_xx_x_0_0; // R-Type except word instructions
    7'b0111011:  control_signals = 16'b1_xxx_x_0_0_00_0_1_xx_x_1_0; // R-Type for word instructions
    7'b0010011:  control_signals = 16'b1_000_x_1_0_00_0_1_xx_x_0_0; // I-Type except word instructions

    7'b0011011:  control_signals = 16'b1_000_x_1_0_00_0_1_xx_x_1_0; // I-Type for word instructions

    7'b0000011:  begin                                              // I-Type for loads
                       {control_signals[15:5],control_signals[1:0]} = 13'b1_000_x_1_0_01_0_0_x_0;
                       case (i_main_decoder_funct3)
                        3'h0: control_signals[4:2]= 3'b000;
                        3'h1: control_signals[4:2]= 3'b010;
                        3'h2: control_signals[4:2]= 3'b100;
                        3'h3: control_signals[4:2]= 3'b110;
                        3'h4: control_signals[4:2]= 3'b001;
                        3'h5: control_signals[4:2]= 3'b011;
                        3'h6: control_signals[4:2]= 3'b101;
                        default: control_signals[4:2]= 3'bxxx;
                       endcase
                 end
   7'b0100011:  begin                                              // S-Type 
                       {control_signals[15:5],control_signals[2:0]} = 14'b0_001_x_1_1_xx_0_0_x_x_0;
                       case (i_main_decoder_funct3)
                        3'h0: control_signals[4:3]= 2'b00;
                        3'h1: control_signals[4:3]= 2'b01;
                        3'h2: control_signals[4:3]= 2'b10;
                        3'h3: control_signals[4:3]= 2'b11;
                        
                        default: control_signals[4:2]= 2'bxx;
                       endcase
                 end
   7'b1100011:  control_signals= 16'b0_010_x_1_0_xx_1_0_xx_x_x_0;  // B-Type
   7'b1101111:  control_signals = 16'b1_011_x_1_0_10_0_0_xx_x_x_1; // jal
   7'b1100111:  control_signals = 16'b1_000_x_1_0_10_0_0_xx_x_x_1; // jalr
   7'b0110111:  control_signals = 16'b1_100_1_1_0_11_0_x_xx_x_x_0; // lui
   7'b0010111:  control_signals = 16'b1_100_1_1_0_11_0_x_xx_x_x_0; // auipc

    default   :  control_signals = 16'b0_xxx_x_x_0_xx_0_x_xx_x_x_0; // Default Case     
endcase



end
endmodule