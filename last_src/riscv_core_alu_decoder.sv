module riscv_core_alu_decoder (
    input logic [2:0] i_alu_decoder_funct3,
    input logic       i_alu_decoder_aluop,
    input logic       i_alu_decoder_funct7_5,
    input logic       i_alu_decoder_funct7_0,
    input logic       i_alu_decoder_opcode_5,
    output logic [3:0] o_alu_decoder_alucontrol

);
    
logic [3:0] control_signals;
assign o_alu_decoder_alucontrol = control_signals;

always_comb begin : write_alucontrol_proc

control_signals=4'b0000;
case (i_alu_decoder_aluop)
    1'b0   : control_signals = 4'b0000; // lw,sw,jal,jalr,lui,auipc

    1'b1   : begin
            if (!i_alu_decoder_funct7_0 && i_alu_decoder_opcode_5) begin

                case (i_alu_decoder_funct3)
                        3'h0: control_signals = (i_alu_decoder_funct7_5) ? 4'b0001 : 4'b0000;
                        3'h1: control_signals = 4'b0100;
                        3'h2: control_signals = 4'b0101;
                        3'h3: control_signals = 4'b1000;
                        3'h4: control_signals = 4'b0110;
                        3'h5: control_signals = (i_alu_decoder_funct7_5) ? 4'b1111 : 4'b0111;
                        3'h6: control_signals = 4'b0011;
                        3'h7: control_signals = 4'b0010;
                        default: control_signals = 4'b0000;
                    endcase
                
            end

            else if (i_alu_decoder_funct7_0 && i_alu_decoder_opcode_5) begin

                case (i_alu_decoder_funct3)
                        3'h0: control_signals = 4'b0000;
                        3'h1: control_signals = 4'b0001;
                        3'h2: control_signals = 4'b0010;
                        3'h3: control_signals = 4'b0011;
                        3'h4: control_signals = 4'b0100;
                        3'h5: control_signals = 4'b0101;
                        3'h6: control_signals = 4'b0110;
                        3'h7: control_signals = 4'b0111;
                        default: control_signals = 4'b0000;
                    endcase
                
            end

            else if(!i_alu_decoder_opcode_5)
            begin

                case (i_alu_decoder_funct3)
                        3'h0: control_signals = 4'b0000;
                        3'h1: control_signals = 4'b0100;
                        3'h2: control_signals = 4'b0101;
                        3'h3: control_signals = 4'b1000;
                        3'h4: control_signals = 4'b0110;
                        3'h5: control_signals = (i_alu_decoder_funct7_5) ? 4'b1111 : 4'b0111;
                        3'h6: control_signals = 4'b0011;
                        3'h7: control_signals = 4'b0010;
                        default: control_signals = 4'b0000;
                    endcase

            end

             
    end


    default: control_signals=4'b0000;
endcase

end


endmodule








/*
                   if (i_alu_decoder_funct7_0) begin


                    if (!i_alu_decoder_funct7_5 && i_alu_decoder_opcode_5) // "M" extension
                    begin
                    case (i_alu_decoder_funct3)
                        3'h0: control_signals = 4'b0000;
                        3'h1: control_signals = 4'b0001;
                        3'h2: control_signals = 4'b0010;
                        3'h3: control_signals = 4'b0011;
                        3'h4: control_signals = 4'b0100;
                        3'h5: control_signals = 4'b0101;
                        3'h6: control_signals = 4'b0110;
                        3'h7: control_signals = 4'b0111;
                        default: control_signals = 4'b0000;
                    endcase
                   end



                   end
                   else
                   begin
                    case (i_alu_decoder_funct3)
                    3'h0: begin // and , sub , andi
                               if (i_alu_decoder_funct7_5 && i_alu_decoder_opcode_5) // sub
                               begin
                                   control_signals = 4'b0001;
                               end
                               else                                                  // and,andi
                                   control_signals = 4'b0000;
                          end 
                    3'h1: control_signals=4'b0100;  // sll , slli
                    3'h2: control_signals=4'b0101;  // slt , slti
                    3'h3: control_signals=4'b1000;  // sltu , sltui
                    3'h4: control_signals=4'b0110;  // xor , xori
                    3'h5: begin                     // srl ,sra , srli , srai 
                               if (i_alu_decoder_funct7_5) // sra ,srai
                                begin
                                    control_signals=4'b1111;
                                end
                                else                       // srl , srli
                                    control_signals=4'b0111;
                          end      
                    3'h6: control_signals=4'b0011; // or , ori
                    3'h7: control_signals=4'b0010; // and , andi     
                    default: control_signals = 4'b0000;
                   endcase
                   end
             end*/
