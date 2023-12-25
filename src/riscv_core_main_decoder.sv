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
    output logic       o_main_decoder_bjreg,
    output logic [1:0] o_main_decoder_size,
    output logic       o_main_decoder_LdExt,
    output logic       o_main_decoder_isword,
    output logic       o_main_decoder_aluop
);

logic [16:0] control_signals;

assign {o_main_decoder_regwrite,o_main_decoder_imsrc,o_main_decoder_UCtrl,
o_main_decoder_alusrcB,o_main_decoder_memwrite,o_main_decoder_resultsrc,
o_main_decoder_branch,o_main_decoder_aluop,o_main_decoder_size,o_main_decoder_LdExt,o_main_decoder_isword,o_main_decoder_jump,o_main_decoder_bjreg} = control_signals;

always_comb begin : control_signals_proc

case (i_main_decoder_opcode)
    // regwrite_imsrc_UCtrl_alusrcB_memwrite_resultsrc_branch_aluop_size_LdExt_isword_jump_bjreg

    7'b0110011:  control_signals = 17'b1_000_0_0_0_00_0_1_00_0_0_0_0; // R-Type except word instructions
    7'b0111011:  control_signals = 17'b1_000_0_0_0_00_0_1_00_0_1_0_0; // R-Type for word instructions
    7'b0010011:  control_signals = 17'b1_000_0_1_0_00_0_1_00_0_0_0_0; // I-Type except word instructions

    7'b0011011:  control_signals = 17'b1_000_0_1_0_00_0_1_00_0_1_0_0; // I-Type for word instructions

    7'b0000011:  begin                                              // I-Type for loads
                       {control_signals[16:6],control_signals[2:0]} = 14'b1_000_0_1_0_01_0_0_0_0_0;
                       case (i_main_decoder_funct3)
                        3'h0: control_signals[5:3]= 3'b000;
                        3'h1: control_signals[5:3]= 3'b010;
                        3'h2: control_signals[5:3]= 3'b100;
                        3'h3: control_signals[5:3]= 3'b110;
                        3'h4: control_signals[5:3]= 3'b001;
                        3'h5: control_signals[5:3]= 3'b011;
                        3'h6: control_signals[5:3]= 3'b101;
                        default: control_signals[5:3]= 3'b000;
                       endcase
                 end
   7'b0100011:  begin                                              // S-Type 
                       {control_signals[16:6],control_signals[3:0]} = 15'b0_001_0_1_1_00_0_0_0_0_0_0;
                       case (i_main_decoder_funct3)
                        3'h0: control_signals[5:4]= 2'b00;
                        3'h1: control_signals[5:4]= 2'b01;
                        3'h2: control_signals[5:4]= 2'b10;
                        3'h3: control_signals[5:4]= 2'b11;
                        
                        default: control_signals[5:4]= 2'b00;
                       endcase
                 end
   7'b1100011:  control_signals = 17'b0_010_0_1_0_00_1_0_00_0_0_0_0;  // B-Type
   7'b1101111:  control_signals = 17'b1_011_0_1_0_10_0_0_00_0_0_1_0; // jal
   7'b1100111:  control_signals = 17'b1_000_0_1_0_10_0_0_00_0_0_1_1; // jalr
   7'b0110111:  control_signals = 17'b1_100_1_1_0_11_0_0_00_0_0_0_0; // lui
   7'b0010111:  control_signals = 17'b1_100_0_1_0_11_0_0_00_0_0_0_0; // auipc

    default   :  control_signals = 17'b0_000_0_0_0_00_0_0_00_0_0_0_0; // Default Case     
endcase



end
endmodule