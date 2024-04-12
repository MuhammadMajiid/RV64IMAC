module riscv_core_main_decoder (
    input logic [6:0] i_main_decoder_opcode,
    input logic [2:0] i_main_decoder_funct3,
    input logic [6:0] i_main_decoder_funct7,
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
    output logic       o_main_decoder_aluop,
    output logic       o_main_decoder_imsel,
    output logic       o_main_decoder_new_mux_sel,
    output logic       o_main_decoder_amo,
    output logic [3:0] o_main_decoder_amo_op,
    output logic       o_main_decoder_lr,
    output logic       o_main_decoder_sc,
    output logic       o_main_decoder_src_sel,
    output logic [1:0] o_main_decoder_op,
    output logic       o_main_decoder_illegal,
    output logic       o_main_decoder_read

);

logic [17:0] control_signals;

logic [6:0] atomic_signals;

logic [4:0] funct5;

assign funct5 = i_main_decoder_funct7[6:2] ;

assign {o_main_decoder_amo,
o_main_decoder_amo_op,
o_main_decoder_lr,
o_main_decoder_sc} = atomic_signals;

assign {o_main_decoder_regwrite,
o_main_decoder_imsrc,
o_main_decoder_UCtrl,
o_main_decoder_alusrcB,
o_main_decoder_memwrite,
o_main_decoder_resultsrc,
o_main_decoder_branch,
o_main_decoder_aluop,
o_main_decoder_size,
o_main_decoder_LdExt,
o_main_decoder_isword,
o_main_decoder_jump,
o_main_decoder_bjreg,
o_main_decoder_imsel} = control_signals;

always_comb begin : control_signals_proc

case (i_main_decoder_opcode)
    // regwrite_imsrc_UCtrl_alusrcB_memwrite_resultsrc_branch_aluop_size_LdExt_isword_jump_bjreg

    7'b0110011:  begin
                    if (!i_main_decoder_funct7[0]) begin
                        control_signals = 18'b1_000_0_0_0_00_0_1_00_0_0_0_0_0; // R-Type except word instructions
                    end
                    else begin
                       control_signals =18'b1_000_0_0_0_00_0_1_00_0_0_0_0_1; // R-Type for part of M extension
                    end

                 end 
    7'b0111011:  begin
                        control_signals = 18'b1_000_0_0_0_00_0_1_00_0_1_0_0_0; // R-Type for word instructions and part of M extension
                        if (i_main_decoder_funct7[0]) begin
                            control_signals [0] = 1;
                        end
                 end
    7'b0010011:  control_signals = 18'b1_000_0_1_0_00_0_1_00_0_0_0_0_0; // I-Type except word instructions

    7'b0011011:  control_signals = 18'b1_000_0_1_0_00_0_1_00_0_1_0_0_0; // I-Type for word instructions

    7'b0000011:  begin                                              // I-Type for loads
                       {control_signals[17:7],control_signals[3:0]} = 15'b1_000_0_1_0_01_0_0_0_0_0_0;
                       case (i_main_decoder_funct3)
                        3'h0: control_signals[6:4]= 3'b000;
                        3'h1: control_signals[6:4]= 3'b010;
                        3'h2: control_signals[6:4]= 3'b100;
                        3'h3: control_signals[6:4]= 3'b110;
                        3'h4: control_signals[6:4]= 3'b001;
                        3'h5: control_signals[6:4]= 3'b011;
                        3'h6: control_signals[6:4]= 3'b101;
                        default: control_signals[6:4]= 3'b000;
                       endcase
                 end
   7'b0100011:  begin                                              // S-Type 
                       {control_signals[17:7],control_signals[4:0]} = 16'b0_001_0_1_1_00_0_0_0_0_0_0_0;
                       case (i_main_decoder_funct3)
                        3'h0: control_signals[6:5]= 2'b00;
                        3'h1: control_signals[6:5]= 2'b01;
                        3'h2: control_signals[6:5]= 2'b10;
                        3'h3: control_signals[6:5]= 2'b11;
                        
                        default: control_signals[6:5]= 2'b00;
                       endcase
                 end
   7'b1100011:  control_signals = 18'b0_010_0_1_0_00_1_0_00_0_0_0_0_0;  // B-Type
   7'b1101111:  control_signals = 18'b1_011_0_1_0_10_0_0_00_0_0_1_0_0; // jal
   7'b1100111:  control_signals = 18'b1_000_0_1_0_10_0_0_00_0_0_1_1_0; // jalr
   7'b0110111:  control_signals = 18'b1_100_1_1_0_00_0_0_00_0_0_0_0_0; // lui
   7'b0010111:  control_signals = 18'b1_100_0_1_0_00_0_0_00_0_0_0_0_0; // auipc
   7'b1110011:  control_signals = 18'b1_110_0_0_0_11_0_0_00_0_0_0_0_0; // CSR_instruction


   7'b0101111:  begin // A extension 
                     control_signals = 18'b1_101_0_1_0_01_0_0_10_0_0_0_0_0;

                     if (funct5[4:3] == 2'b11)
                     begin
                        control_signals [4] = 1;
                     end

                     if (i_main_decoder_funct3[0])
                     begin
                        control_signals [6:5] = 2'b11;
                     end
                end 


    default   :  control_signals = 18'b0_000_0_0_0_00_0_0_00_0_0_0_0_0; // Default Case     
endcase



end



//////////////////////////
/// NEW MUX SEL LOGIC ////
//////////////////////////

always_comb begin : NEW_MUX_SEL_signal_proc

o_main_decoder_new_mux_sel = 0;

case (i_main_decoder_opcode)


   7'b0110011:   o_main_decoder_new_mux_sel = 0;
   7'b0111011:   o_main_decoder_new_mux_sel = 0;
   7'b0010011:   o_main_decoder_new_mux_sel = 0; // I-Type except word instructions

   7'b0011011:   o_main_decoder_new_mux_sel = 0; // I-Type for word instructions
 
   7'b0000011:   o_main_decoder_new_mux_sel = 0;
   7'b0100011:   o_main_decoder_new_mux_sel = 0;
   7'b1100011:   o_main_decoder_new_mux_sel = 1; // B-Type
   7'b1101111:   o_main_decoder_new_mux_sel = 1; // jal
   7'b1100111:   o_main_decoder_new_mux_sel = 1; // jalr
   7'b0110111:   o_main_decoder_new_mux_sel = 1; // lui
   7'b0010111:   o_main_decoder_new_mux_sel = 1; // auipc
   7'b0101111:   o_main_decoder_new_mux_sel = 0; // A extension
   7'b1110011:   o_main_decoder_new_mux_sel = 0; // CSR_instruction

    default   :  o_main_decoder_new_mux_sel = 0; // Default Case     
endcase



end



/////////////////////////////
/// Atomic Signals Logic ////
/////////////////////////////

always_comb begin : Atomic_Signals_Logic

atomic_signals = 7'b0;

case (i_main_decoder_opcode)
   7'b0101111 : begin 
                    
                    case (funct5)
                     5'b00010  : atomic_signals =7'b0_0000_1_0;
                     5'b00011  : atomic_signals =7'b0_0000_0_1;
                     5'b00001  : atomic_signals =7'b1_0000_0_0;
                     5'b00000  : atomic_signals =7'b1_0001_0_0;
                     5'b01100  : atomic_signals =7'b1_0010_0_0;
                     5'b01000  : atomic_signals =7'b1_0011_0_0;
                     5'b00100  : atomic_signals =7'b1_0100_0_0;
                     5'b10100  : atomic_signals =7'b1_0101_0_0;

                     5'b10000  : atomic_signals =7'b1_0110_0_0;
                     5'b11100  : atomic_signals =7'b1_0111_0_0;
                     5'b11000  : atomic_signals =7'b1_1000_0_0;
                     default   : atomic_signals =7'b0_0000_0_0;
                    endcase
                end

    default: atomic_signals = 7'b0;
endcase

end



//////////////////////
/// SRC_SEL LOGIC ////
//////////////////////

always_comb begin : SRC_SEL_LOGIC

o_main_decoder_src_sel = 0;

case (i_main_decoder_opcode)

    7'b1110011: begin
                o_main_decoder_src_sel = 0;
                if(i_main_decoder_funct3[2])
                o_main_decoder_src_sel = 1;
                end

    default: o_main_decoder_src_sel = 0 ;
endcase

end


/////////////////
/// OP LOGIC ////
/////////////////

always_comb begin : OP_LOGIC

o_main_decoder_op = 2'b00;

case (i_main_decoder_opcode)

    7'b1110011: begin
               case (i_main_decoder_funct3[1:0])
                2'b01  : o_main_decoder_op = 2'b01; 
                2'b10  : o_main_decoder_op = 2'b10; 
                2'b11  : o_main_decoder_op = 2'b11; 
                default: o_main_decoder_op = 2'b00; 
               endcase
                end

    default: o_main_decoder_op = 2'b00; 
endcase

end





///////////////////
/// READ LOGIC ////
///////////////////

always_comb begin : READ_LOGIC

o_main_decoder_read = 0;

case (i_main_decoder_opcode)

    7'b0000011: o_main_decoder_read = 1;
    7'b0110111: o_main_decoder_read = 0;
    7'b0101111: o_main_decoder_read = 0;

    default: o_main_decoder_read = 0;
endcase

end




//////////////////////////////////
/// ILLEGAL INSTRUCTION LOGIC ////
//////////////////////////////////

always_comb begin : ILLEGAL_INSTRUCTION_LOGIC

o_main_decoder_illegal = 1;

case (i_main_decoder_opcode)


   7'b0000000:   o_main_decoder_illegal = 0;
   7'b0010011:   o_main_decoder_illegal = 0; // I-Type except word instructions

   7'b0011011:   o_main_decoder_illegal = 0; // I-Type for word instructions
 
   7'b0000011:   o_main_decoder_illegal = 0;
   7'b0100011:   o_main_decoder_illegal = 0;
   7'b1100011:   o_main_decoder_illegal = 0; // B-Type
   7'b1101111:   o_main_decoder_illegal = 0; // jal
   7'b1100111:   o_main_decoder_illegal = 0;// jalr
   7'b0110111:   o_main_decoder_illegal = 0; // lui
   7'b0010111:   o_main_decoder_illegal = 0; // auipc
   7'b0110011:   o_main_decoder_illegal = 0; // M extension_1
   7'b0111011:   o_main_decoder_illegal = 0; // M extension_2
   7'b0101111:   o_main_decoder_illegal = 0; // A extension
   7'b1110011:   o_main_decoder_illegal = 0; // CSR_instruction

    default   :  o_main_decoder_illegal = 1; // Default Case     
endcase



end


endmodule