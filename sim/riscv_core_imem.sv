//--------------------------module instantiation--------------------------
/*
riscv_core_imem
#(
  .ALEN (64)
  ,.ILEN(32)
  ,.MWID(8)
  ,.MLEN(256)
)
u_riscv_core_imem
(
  .i_imem_rst_n            ()
  ,.i_imem_address         ()
  ,.o_imem_rdata           ()
);
*/

module riscv_core_imem
#(
  parameter ALEN = 64,          //Adress width
  parameter ILEN = 32,          // instruction width
  parameter MWID = 8,           // memory width
  parameter MLEN = 256          // memory length
)(
input  logic            i_imem_rst_n,
input  logic [ALEN-1:0] i_imem_address,
output logic [ILEN-1:0] o_imem_rdata
);

logic [MLEN-1:0][MWID-1:0] mem ;      // packed memory array byte x 256

integer i;
always_ff @(negedge i_imem_rst_n)
  begin: reset_proc
    if(~i_imem_rst_n)
      begin
        for (i=0; i<MLEN; i=i+1)
          begin
              mem[i] <= 1'b0;
          end
      end
  end

always_comb begin : read_proc
  o_imem_rdata=mem[i_imem_address +:4];
end

endmodule 

