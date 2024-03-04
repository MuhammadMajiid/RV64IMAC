//--------------------------module instantiation--------------------------
/*
riscv_core_data_mem
#(
  .XLEN (64)
  ,.MWID(8)
  ,.MLEN(256)
)
u_riscv_core_data_mem
(
  .i_data_mem_clk          ()
  ,.i_data_mem_rst_n       ()
  ,.i_data_mem_w_en        ()
  ,.i_data_mem_ld_extend   ()
  ,.i_data_mem_r_w_size    ()
  ,.i_data_mem_address     ()
  ,.i_data_mem_wdata       ()
  ,.o_data_mem_rdata       ()
);
*/
//////////////////////////////////////////////////////////////////////////
module riscv_core_data_mem
#(
  parameter XLEN = 64,
  parameter MWID = 8,           // memory width
  parameter MLEN = 256          // memory length
)
(
  input  logic            i_data_mem_clk,
  input  logic            i_data_mem_rst_n,
  input  logic            i_data_mem_w_en,
  input  logic            i_data_mem_ld_extend,
  input  logic [1:0]      i_data_mem_r_w_size,
  input  logic [XLEN-1:0] i_data_mem_address,
  input  logic [XLEN-1:0] i_data_mem_wdata,
  output logic [XLEN-1:0] o_data_mem_rdata
);

logic [MLEN-1:0][MWID-1:0] mem ;      // packed memory array byte x 256
logic [XLEN-1:0] rdata;               // read data without extention

integer i;
always_ff @(posedge i_data_mem_clk, negedge i_data_mem_rst_n)
  begin: store_proc
    if(~i_data_mem_rst_n)
      begin
        for (i=0; i<MLEN; i=i+1)
          begin
              mem[i] <= 'b0;
          end
      end
    else if(i_data_mem_w_en)
      begin
        case (i_data_mem_r_w_size)
          2'b00:   mem[i_data_mem_address]     <= i_data_mem_wdata;
          2'b01:   mem[i_data_mem_address +:2] <= i_data_mem_wdata;
          2'b10:   mem[i_data_mem_address +:4] <= i_data_mem_wdata;
          2'b11:   mem[i_data_mem_address +:8] <= i_data_mem_wdata;
          default: mem[i_data_mem_address +:8] <= i_data_mem_wdata;
        endcase
      end
  end

always_comb
  begin: load_proc
      begin
        case (i_data_mem_r_w_size)
          2'b00:   rdata = mem[i_data_mem_address];
          2'b01:   rdata = mem[i_data_mem_address +:2];
          2'b10:   rdata = mem[i_data_mem_address +:4];
          2'b11:   rdata = mem[i_data_mem_address +:8];
          default: rdata = mem[i_data_mem_address +:8];
        endcase
      end 
    
  end

always_comb
  begin: load_extend_proc
    if (i_data_mem_ld_extend) 
      begin
        case (i_data_mem_r_w_size)
          2'b00:  o_data_mem_rdata =  {{56{rdata[7]}},  rdata[7:0]};
          2'b01:  o_data_mem_rdata =  {{48{rdata[15]}}, rdata[15:0]};
          2'b10:  o_data_mem_rdata =  {{32{rdata[31]}}, rdata[31:0]};
          2'b11:  o_data_mem_rdata =  rdata;
          default:o_data_mem_rdata =  rdata;
        endcase
      end 
    else 
      begin
        case (i_data_mem_r_w_size)
          2'b00:  o_data_mem_rdata =  {{56{1'b0}},  rdata[7:0]};
          2'b01:  o_data_mem_rdata =  {{48{1'b0}}, rdata[15:0]};
          2'b10:  o_data_mem_rdata =  {{32{1'b0}}, rdata[31:0]};
          2'b11:  o_data_mem_rdata =  rdata;
          default:o_data_mem_rdata =  rdata;
        endcase
      end
  end
endmodule