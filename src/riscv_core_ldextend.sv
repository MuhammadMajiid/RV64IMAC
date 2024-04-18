module riscv_core_ldextend
#(
  parameter XLEN = 64
)
(
  input  logic             i_ldextend_su_extend,
  input  logic  [1:0]      i_ldextend_r_w_size,
  input  logic  [XLEN-1:0] i_ldextend_rdata,
  output logic  [XLEN-1:0] o_ldextend_rdata
);

always_comb
  begin: ldextend_proc
    if (!i_ldextend_su_extend) 
      begin
        case (i_ldextend_r_w_size)
          2'b00:   o_ldextend_rdata = {{56{i_ldextend_rdata[7]}},  i_ldextend_rdata[7:0]};
          2'b01:   o_ldextend_rdata = {{48{i_ldextend_rdata[15]}}, i_ldextend_rdata[15:0]};
          2'b10:   o_ldextend_rdata = {{32{i_ldextend_rdata[31]}}, i_ldextend_rdata[31:0]};
          2'b11:   o_ldextend_rdata = i_ldextend_rdata;
          default: o_ldextend_rdata = i_ldextend_rdata;
        endcase
      end 
    else 
      begin
        case (i_ldextend_r_w_size)
          2'b00:   o_ldextend_rdata = {{56{1'b0}}, i_ldextend_rdata[7:0]};
          2'b01:   o_ldextend_rdata = {{48{1'b0}}, i_ldextend_rdata[15:0]};
          2'b10:   o_ldextend_rdata = {{32{1'b0}}, i_ldextend_rdata[31:0]};
          2'b11:   o_ldextend_rdata = i_ldextend_rdata;
          default: o_ldextend_rdata = i_ldextend_rdata;
        endcase
      end
  end

endmodule