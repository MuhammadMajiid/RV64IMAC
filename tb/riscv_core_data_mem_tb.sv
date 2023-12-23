`timescale 1ns / 1ps
module u_riscv_core_data_mem_tb();
parameter XLEN = 64;
parameter MWID = 8;
parameter MLEN = 256;
parameter CLK_PERIOD = 10;

logic            i_data_mem_clk;
logic            i_data_mem_rst_n;
logic            i_data_mem_w_en;
logic            i_data_mem_ld_extend;
logic [1:0]      i_data_mem_r_w_size;
logic [XLEN-1:0] i_data_mem_address;
logic [XLEN-1:0] i_data_mem_wdata;
logic [XLEN-1:0] o_data_mem_rdata;

initial 
  begin
    $dumpfile("riscv_core_data_mem_tb_DUMP.vcd");       
    $dumpvars;
    //reset
    i_data_mem_rst_n = 1'b0;
    //initialization
    i_data_mem_clk = 1'b0;
    i_data_mem_w_en = 1'b0;
    i_data_mem_ld_extend = 1'b0;
    #10;
    i_data_mem_rst_n = 1'b1;
    #10;
    i_data_mem_w_en = 1'b1;
    i_data_mem_r_w_size = 2'b00;
    i_data_mem_address = 64'h0;
    i_data_mem_wdata = 64'h00000000_00000001;
    #10;
    i_data_mem_w_en = 1'b0;
    i_data_mem_r_w_size = 2'b00;
    i_data_mem_address = 64'h0;
    i_data_mem_ld_extend = 1'b1;
    $display("TEST CASE 1 LB: %b",o_data_mem_rdata);
    #10;
    i_data_mem_w_en = 1'b1;
    i_data_mem_r_w_size = 2'b01;
    i_data_mem_address = 64'h1;
    i_data_mem_wdata = 64'h00000000_00007278;
    #10;
    i_data_mem_w_en = 1'b0;
    i_data_mem_r_w_size = 2'b01;
    i_data_mem_address = 64'h1;
    i_data_mem_ld_extend = 1'b1;
    $display("TEST CASE 2 LH: %b",o_data_mem_rdata);
    #10;
    i_data_mem_w_en = 1'b1;
    i_data_mem_r_w_size = 2'b10;
    i_data_mem_address = 64'h3;
    i_data_mem_wdata = 64'h00000000_70000001;
    #10;
    i_data_mem_w_en = 1'b0;
    i_data_mem_r_w_size = 2'b01;
    i_data_mem_address = 64'h3;
    i_data_mem_ld_extend = 1'b1;
    $display("TEST CASE 3 LW: %b",o_data_mem_rdata);
    #10;
    i_data_mem_w_en = 1'b1;
    i_data_mem_r_w_size = 2'b11;
    i_data_mem_address = 64'h7;
    i_data_mem_wdata = 64'h70000001_70000001;
    #10;
    i_data_mem_w_en = 1'b0;
    i_data_mem_r_w_size = 2'b11;
    i_data_mem_address = 64'h7;
    i_data_mem_ld_extend = 1'b1;
    $display("TEST CASE 4 LD: %b",o_data_mem_rdata);
    $stop;
  end

always #(CLK_PERIOD/2.0) i_data_mem_clk = ~i_data_mem_clk; 

riscv_core_data_mem
#(
  .XLEN (XLEN)
  ,.MWID(MWID)
  ,.MLEN(MLEN)
)
u_riscv_core_data_mem
(
  .i_data_mem_clk          (i_data_mem_clk)
  ,.i_data_mem_rst_n       (i_data_mem_rst_n)
  ,.i_data_mem_w_en        (i_data_mem_w_en)
  ,.i_data_mem_ld_extend   (i_data_mem_ld_extend)
  ,.i_data_mem_r_w_size    (i_data_mem_r_w_size)
  ,.i_data_mem_address     (i_data_mem_address)
  ,.i_data_mem_wdata       (i_data_mem_wdata)
  ,.o_data_mem_rdata       (o_data_mem_rdata)
);
endmodule