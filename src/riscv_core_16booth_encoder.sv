module riscv_core_16booth_encoder 
#(
  parameter XLEN = 64     //data length
)
(
  input  logic  [XLEN-1:0]  i_16booth_encoder_muld,  //input multiplicand
  input  logic  [4:0]       i_16booth_encoder_sel,   //multiplier grouped bits
  output logic  [XLEN+3:0]  o_16booth_encoder_pp     //partial product
);

logic [XLEN+2:0]  pos_muld, pos2_muld, pos3_muld, pos4_muld, pos5_muld, pos6_muld, pos7_muld, pos8_muld;
logic [XLEN+2:0]  neg_muld, neg2_muld, neg3_muld, neg4_muld, neg5_muld, neg6_muld, neg7_muld, neg8_muld;

always_comb
  begin: pp_proc
    pos_muld  = {3'b000, i_16booth_encoder_muld};
    pos2_muld = {pos_muld , 1'b0};
    pos4_muld = {pos2_muld, 1'b0};
    pos8_muld = {pos4_muld, 1'b0};

    neg_muld  = ~{3'b000, i_16booth_encoder_muld} + 1;
    neg2_muld = {neg_muld , 1'b0};
    neg4_muld = {neg2_muld, 1'b0};
    neg8_muld = {neg4_muld, 1'b0};

    pos3_muld = pos4_muld + neg_muld;
    pos6_muld = {pos3_muld, 1'b0};

    neg3_muld = neg2_muld + neg_muld;
    neg6_muld = {neg3_muld, 1'b0};

    pos5_muld = pos4_muld + pos_muld;
    pos7_muld = pos8_muld + neg_muld;

    neg5_muld = neg4_muld + neg_muld;
    neg7_muld = neg8_muld + pos_muld;

    case (i_16booth_encoder_sel)
        5'b00000: o_16booth_encoder_pp = 0;
        5'b00001: o_16booth_encoder_pp = {1'b0, pos_muld};
        5'b00010: o_16booth_encoder_pp = {1'b0, pos_muld};
        5'b00011: o_16booth_encoder_pp = {1'b0, pos2_muld};
        5'b00100: o_16booth_encoder_pp = {1'b0, pos2_muld};
        5'b00101: o_16booth_encoder_pp = {1'b0, pos3_muld};
        5'b00110: o_16booth_encoder_pp = {1'b0, pos3_muld};
        5'b00111: o_16booth_encoder_pp = {1'b0, pos4_muld};
        5'b01000: o_16booth_encoder_pp = {1'b0, pos4_muld};
        5'b01001: o_16booth_encoder_pp = {1'b0, pos5_muld};
        5'b01010: o_16booth_encoder_pp = {1'b0, pos5_muld};
        5'b01011: o_16booth_encoder_pp = {1'b0, pos6_muld};
        5'b01100: o_16booth_encoder_pp = {1'b0, pos6_muld};
        5'b01101: o_16booth_encoder_pp = {1'b0, pos7_muld};
        5'b01110: o_16booth_encoder_pp = {1'b0, pos7_muld};
        5'b01111: o_16booth_encoder_pp = {1'b0, pos8_muld};
        5'b10000: o_16booth_encoder_pp = {1'b1, neg8_muld};
        5'b10001: o_16booth_encoder_pp = {1'b1, neg7_muld};
        5'b10010: o_16booth_encoder_pp = {1'b1, neg7_muld};
        5'b10011: o_16booth_encoder_pp = {1'b1, neg6_muld};
        5'b10100: o_16booth_encoder_pp = {1'b1, neg6_muld};
        5'b10101: o_16booth_encoder_pp = {1'b1, neg5_muld};
        5'b10110: o_16booth_encoder_pp = {1'b1, neg5_muld};
        5'b10111: o_16booth_encoder_pp = {1'b1, neg4_muld};
        5'b11000: o_16booth_encoder_pp = {1'b1, neg4_muld};
        5'b11001: o_16booth_encoder_pp = {1'b1, neg3_muld};
        5'b11010: o_16booth_encoder_pp = {1'b1, neg3_muld};
        5'b11011: o_16booth_encoder_pp = {1'b1, neg2_muld};
        5'b11100: o_16booth_encoder_pp = {1'b1, neg2_muld};
        5'b11101: o_16booth_encoder_pp = {1'b1, neg_muld};
        5'b11110: o_16booth_encoder_pp = {1'b1, neg_muld};
        5'b11111: o_16booth_encoder_pp = 0;
        default:  o_16booth_encoder_pp = 0;
    endcase  
  end
    
endmodule