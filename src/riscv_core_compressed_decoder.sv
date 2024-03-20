module riscv_core_compressed_decoder (
    input logic  [31:0] i_compressed_decoder_instr,
    output logic [31:0] o_compressed_decoder_instr,
    output logic        o_compressed_decoder_is_compressed,
    output logic        o_compressed_decoder_illegal_instr
);

localparam Q0 = 2'b00; // Quadrant 0
localparam Q1 = 2'b01; // Quadrant 1
localparam Q2 = 2'b10; // Quadrant 2
// Q0 C.Instructions
localparam C_ADDI4SPN = 3'b000;
localparam C_LW       = 3'b010;
localparam C_LD       = 3'b011;
localparam C_SW       = 3'b110;
localparam C_SD       = 3'b111;
// Q1 C.Instructions
localparam C_ADDI_NOP = 3'b000;
localparam C_ADDIW = 3'b001;
localparam C_LI = 3'b010;
localparam C_ADDIL6SP_LUI = 3'b011;
localparam C_J = 3'b101;
localparam C_BEQZ = 3'b110;
localparam C_BNEZ = 3'b111;
localparam C_ARTH_LOGIC = 3'b100;
// Q2 C.Instructions
localparam C_SLLI = 3'b000;
localparam C_LWSP = 3'b010;
localparam C_LDSP = 3'b011;
localparam C_JR_MV_BR_JALR_ADD = 3'b100;
localparam C_SWSP = 3'b110;
localparam C_SDSP = 3'b111;

always_comb begin
    // default
    o_compressed_decoder_is_compressed = 1'b1;
    o_compressed_decoder_illegal_instr = 1'b0;
    o_compressed_decoder_instr         = i_compressed_decoder_instr;

    unique case (i_compressed_decoder_instr[1:0])
       Q0 : begin
        unique case (i_compressed_decoder_instr[15:13])
           C_ADDI4SPN : begin
              o_compressed_decoder_instr = {
                2'b00,
                i_compressed_decoder_instr[10:7],
                i_compressed_decoder_instr[12:11],
                i_compressed_decoder_instr[5],
                i_compressed_decoder_instr[6],
                2'b00,
                5'h02,
                3'b000,
                2'b01,
                i_compressed_decoder_instr[4:2],
                7'b0010011
              };
              if (i_compressed_decoder_instr[12:5] == 8'b0) o_compressed_decoder_illegal_instr = 1'b1;
           end 
           C_LW : begin
            o_compressed_decoder_instr = {
                5'b0,
                i_compressed_decoder_instr[5],
                i_compressed_decoder_instr[12:10],
                i_compressed_decoder_instr[6],
                2'b00,
                2'b01,
                i_compressed_decoder_instr[9:7],
                3'b010,
                2'b01,
                i_compressed_decoder_instr[4:2],
                7'b0000011
              };
           end
           C_LD : begin
            o_compressed_decoder_instr = {
                4'b0,
                i_compressed_decoder_instr[6:5],
                i_compressed_decoder_instr[12:10],
                3'b000,
                2'b01,
                i_compressed_decoder_instr[9:7],
                3'b011,
                2'b01,
                i_compressed_decoder_instr[4:2],
                7'b0000011
              };
           end
           C_SW : begin
            o_compressed_decoder_instr = {
                5'b0,
                i_compressed_decoder_instr[5],
                i_compressed_decoder_instr[12],
                2'b01,
                i_compressed_decoder_instr[4:2],
                2'b01,
                i_compressed_decoder_instr[9:7],
                3'b010,
                i_compressed_decoder_instr[11:10],
                i_compressed_decoder_instr[6],
                2'b00,
                7'b0100011
              };
           end
           C_SD : begin
            o_compressed_decoder_instr = {
                4'b0,
                i_compressed_decoder_instr[6:5],
                i_compressed_decoder_instr[12],
                2'b01,
                i_compressed_decoder_instr[4:2],
                2'b01,
                i_compressed_decoder_instr[9:7],
                3'b011,
                i_compressed_decoder_instr[11:10],
                3'b000,
                7'b0100011
              };
           end
            default: o_compressed_decoder_illegal_instr = 1'b1;
        endcase
       end
       Q1 : begin
        unique case (i_compressed_decoder_instr[15:13])
           C_ADDI_NOP : begin
                o_compressed_decoder_instr = {
                    {6{i_compressed_decoder_instr[12]}},
                    i_compressed_decoder_instr[12],
                    i_compressed_decoder_instr[6:2],
                    i_compressed_decoder_instr[11:7],
                    3'b0,
                    i_compressed_decoder_instr[11:7],
                    7'b0010011
                };
           end
           C_ADDIW : begin
                o_compressed_decoder_instr = {
                    {6{i_compressed_decoder_instr[12]}},
                    i_compressed_decoder_instr[12],
                    i_compressed_decoder_instr[6:2],
                    i_compressed_decoder_instr[11:7],
                    3'b0,
                    i_compressed_decoder_instr[11:7],
                    7'b0011011
                };
           end
           C_LI : begin
                o_compressed_decoder_instr = {
                    {6{i_compressed_decoder_instr[12]}},
                    i_compressed_decoder_instr[12],
                    i_compressed_decoder_instr[6:2],
                    5'b0,
                    3'b0,
                    i_compressed_decoder_instr[11:7],
                    7'b0010011
                };
           end
           C_ADDIL6SP_LUI : begin
            if (i_compressed_decoder_instr[11:7] == 5'h02) begin
                o_compressed_decoder_instr = {
                    {3{i_compressed_decoder_instr[12]}},
                    i_compressed_decoder_instr[4:3],
                    i_compressed_decoder_instr[5],
                    i_compressed_decoder_instr[2],
                    i_compressed_decoder_instr[6],
                    4'b0,
                    5'h02,
                    3'b0,
                    5'h02,
                    7'b0010011
                };
            end
            else if (i_compressed_decoder_instr[11:7] != 5'h00) begin
                o_compressed_decoder_instr = {
                    {14{i_compressed_decoder_instr[12]}},
                    i_compressed_decoder_instr[12],
                    i_compressed_decoder_instr[6:2],
                    i_compressed_decoder_instr[11:7],
                    7'b0110111
                };
            end
           end
           C_ARTH_LOGIC : begin
               unique case (i_compressed_decoder_instr[11:10])
               2'b00 : begin // --SRLI
                    o_compressed_decoder_instr = {
                        7'b0000000,
                        i_compressed_decoder_instr[6:2],
                        2'b01,
                        i_compressed_decoder_instr[9:7],
                        3'b101,
                        2'b01,
                        i_compressed_decoder_instr[9:7],
                        7'b0010011
                   };
               end
               2'b01 : begin // --SRAI
                    o_compressed_decoder_instr = {
                        7'b0100000,
                        i_compressed_decoder_instr[6:2],
                        2'b01,
                        i_compressed_decoder_instr[9:7],
                        3'b101,
                        2'b01,
                        i_compressed_decoder_instr[9:7],
                        7'b0010011
                   };
               end
               2'b10 : begin // --ANDI
                    o_compressed_decoder_instr = {
                        {6{i_compressed_decoder_instr[12]}},
                        i_compressed_decoder_instr[12],
                        i_compressed_decoder_instr[6:2],
                        2'b01,
                        i_compressed_decoder_instr[9:7],
                        7'b0010011
                   };
               end
               2'b11 : begin // --ALU
                   if (i_compressed_decoder_instr[12] == 1'b0) begin
                        unique case (i_compressed_decoder_instr[6:5])
                           2'b00 : begin // --SUB
                                o_compressed_decoder_instr = {
                                    2'b01,
                                    5'b0,
                                    2'b01,
                                    i_compressed_decoder_instr[4:2],
                                    2'b01,
                                    i_compressed_decoder_instr[9:7],
                                    3'b0,
                                    2'b01,
                                    i_compressed_decoder_instr[9:7],
                                    7'b0110011
                                };
                           end
                           2'b01 : begin // --XOR
                                o_compressed_decoder_instr = {
                                    7'b0,
                                    2'b01,
                                    i_compressed_decoder_instr[4:2],
                                    2'b01,
                                    i_compressed_decoder_instr[9:7],
                                    3'b100,
                                    2'b01,
                                    i_compressed_decoder_instr[9:7],
                                    7'b0110011
                                };
                           end
                           2'b10 : begin // --OR
                                o_compressed_decoder_instr = {
                                    7'b0,
                                    2'b01,
                                    i_compressed_decoder_instr[4:2],
                                    2'b01,
                                    i_compressed_decoder_instr[9:7],
                                    3'b110,
                                    2'b01,
                                    i_compressed_decoder_instr[9:7],
                                    7'b0110011
                                };
                           end
                           2'b11 : begin // --AND
                                o_compressed_decoder_instr = {
                                    7'b0,
                                    2'b01,
                                    i_compressed_decoder_instr[4:2],
                                    2'b01,
                                    i_compressed_decoder_instr[9:7],
                                    3'b111,
                                    2'b01,
                                    i_compressed_decoder_instr[9:7],
                                    7'b0110011
                                };
                           end 
                        endcase
                   end
                   else begin
                        unique case (i_compressed_decoder_instr[6:5])
                           2'b00 : begin // --SUBW
                                o_compressed_decoder_instr = {
                                    2'b01,
                                    5'b0,
                                    2'b01,
                                    i_compressed_decoder_instr[4:2],
                                    2'b01,
                                    i_compressed_decoder_instr[9:7],
                                    3'b0,
                                    2'b01,
                                    i_compressed_decoder_instr[9:7],
                                    7'b0111011
                                };
                           end
                           2'b01 : begin // --ADDW
                                o_compressed_decoder_instr = {
                                    7'b0,
                                    2'b01,
                                    i_compressed_decoder_instr[4:2],
                                    2'b01,
                                    i_compressed_decoder_instr[9:7],
                                    3'b0,
                                    2'b01,
                                    i_compressed_decoder_instr[9:7],
                                    7'b0111011
                                };
                           end
                            default: o_compressed_decoder_illegal_instr = 1'b1;
                        endcase
                   end
               end 
               endcase
           end
           C_J : begin
                o_compressed_decoder_instr = {
                    i_compressed_decoder_instr[12],
                    i_compressed_decoder_instr[8],
                    i_compressed_decoder_instr[10:9],
                    i_compressed_decoder_instr[6],
                    i_compressed_decoder_instr[7],
                    i_compressed_decoder_instr[2],
                    i_compressed_decoder_instr[11],
                    i_compressed_decoder_instr[5:3],
                    {9{i_compressed_decoder_instr[12]}},
                    5'b0,
                    7'b1101111
                };
           end
           C_BEQZ : begin
                o_compressed_decoder_instr = {
                    {4{i_compressed_decoder_instr[12]}},
                    i_compressed_decoder_instr[6:5],
                    i_compressed_decoder_instr[2],
                    5'b0,
                    2'b01,
                    i_compressed_decoder_instr[9:7],
                    3'b0,
                    i_compressed_decoder_instr[11:10],
                    i_compressed_decoder_instr[4:3],
                    i_compressed_decoder_instr[12],
                    7'b1100011
                };
           end
           C_BNEZ : begin
                o_compressed_decoder_instr = {
                    {4{i_compressed_decoder_instr[12]}},
                    i_compressed_decoder_instr[6:5],
                    i_compressed_decoder_instr[2],
                    5'b0,
                    2'b01,
                    i_compressed_decoder_instr[9:7],
                    3'b001,
                    i_compressed_decoder_instr[11:10],
                    i_compressed_decoder_instr[4:3],
                    i_compressed_decoder_instr[12],
                    7'b1100011
                };
           end 
            default: o_compressed_decoder_illegal_instr = 1'b1;
        endcase
       end
       Q2 : begin
            unique case (i_compressed_decoder_instr[15:13])
               C_SLLI : begin
                    o_compressed_decoder_instr = {
                        7'b0,
                        i_compressed_decoder_instr[6:2],
                        i_compressed_decoder_instr[11:7],
                        3'b001,
                        i_compressed_decoder_instr[11:7],
                        7'b0010011
                    };
               end
               C_LWSP : begin
                    o_compressed_decoder_instr = {
                        4'b0,
                        i_compressed_decoder_instr[3:2],
                        i_compressed_decoder_instr[12],
                        i_compressed_decoder_instr[6:4],
                        2'b00,
                        5'b00010,
                        3'b010,
                        i_compressed_decoder_instr[11:7],
                        7'b0000011
                    };
               end
               C_LDSP : begin
                    o_compressed_decoder_instr = {
                        3'b0,
                        i_compressed_decoder_instr[4:2],
                        i_compressed_decoder_instr[12],
                        i_compressed_decoder_instr[6:5],
                        3'b0,
                        5'b00010,
                        3'b011,
                        i_compressed_decoder_instr[11:7],
                        7'b0000011
                    };
               end
               C_JR_MV_BR_JALR_ADD : begin
                    if (i_compressed_decoder_instr[12] == 1'b0) begin
                        if (i_compressed_decoder_instr[6:2] == 5'b0) begin // --JR
                            o_compressed_decoder_instr = {
                                12'b0,
                                i_compressed_decoder_instr[11:7],
                                3'b0,
                                5'b0,
                                7'b1100111
                            };
                        end
                        else begin // --MV
                            o_compressed_decoder_instr = {
                                7'b0,
                                i_compressed_decoder_instr[6:2],
                                5'b0,
                                3'b0,
                                i_compressed_decoder_instr[11:7],
                                7'b0110011
                            };
                        end
                        if (i_compressed_decoder_instr[11:7] == 5'b0) begin
                            o_compressed_decoder_illegal_instr = 1'b1;
                        end
                    end
                    else begin
                        if (i_compressed_decoder_instr[11:2] == 5'b0) begin // --EBREAK
                            o_compressed_decoder_instr = {
                                32'h00_10_00_73
                            };
                        end
                        else if (i_compressed_decoder_instr[11:7] != 5'b0 && i_compressed_decoder_instr[6:2] == 5'b0) begin // --JALR
                            o_compressed_decoder_instr = {
                                12'b0,
                                i_compressed_decoder_instr[11:7],
                                3'b0,
                                5'b00001,
                                7'b1100111
                            };
                        end
                        else if (i_compressed_decoder_instr[11:2] != 5'b0) begin // --ADD
                            o_compressed_decoder_instr = {
                                7'b0,
                                i_compressed_decoder_instr[6:2],
                                i_compressed_decoder_instr[11:7],
                                3'b0,
                                i_compressed_decoder_instr[11:7],
                                7'b0110011
                            };
                        end
                        else begin
                            o_compressed_decoder_illegal_instr = 1'b1;
                        end
                    end
               end
               C_SWSP : begin
                    o_compressed_decoder_instr = {
                        4'b0,
                        i_compressed_decoder_instr[8:7],
                        i_compressed_decoder_instr[12],
                        i_compressed_decoder_instr[6:2],
                        5'b00010,
                        3'b010,
                        i_compressed_decoder_instr[11:9],
                        2'b00,
                        7'b0100011
                    };
               end
               C_SDSP : begin
                    o_compressed_decoder_instr = {
                        3'b0,
                        i_compressed_decoder_instr[9:7],
                        i_compressed_decoder_instr[12],
                        i_compressed_decoder_instr[6:2],
                        5'b00010,
                        3'b011,
                        i_compressed_decoder_instr[11:10],
                        3'b000,
                        7'b0100011
                    };
               end
                default: o_compressed_decoder_illegal_instr = 1'b1;
            endcase
       end
        default: begin
            o_compressed_decoder_is_compressed = 1'b0;
        end
    endcase

    // Illegal instruction handling
    if (o_compressed_decoder_illegal_instr) begin
        o_compressed_decoder_instr = i_compressed_decoder_instr;
    end
end

endmodule