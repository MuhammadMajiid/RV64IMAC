`define INDEX 14:3

module main_mem #(
    parameter MEM_DEPTH  =  12,
    parameter DATA_WIDTH =  64,
    parameter ADDR_WIDTH =  64,
    parameter CACHE_LINE_WIDTH =  256
) (
    input logic i_clk,
    input logic i_rst_n,

    
    // Interface with READ CHANNEL //

    input logic [ADDR_WIDTH-1     : 0] i_mem_read_address,
    input logic                        i_mem_read_req,
    output  logic                        o_mem_read_done,
    output  logic [CACHE_LINE_WIDTH-1 : 0] o_cache_line,
    
    // Interface with WRITE CHANNEL //

    output logic                         o_mem_write_done,
    input logic                          i_mem_write_valid,
    input logic [     DATA_WIDTH-1 : 0]  i_mem_write_data,
    input logic [     ADDR_WIDTH-1 : 0]  i_mem_write_address,
    input logic [                7 : 0]  i_write_strobe
);


localparam MEM_SIZE = (2**MEM_DEPTH);

(* ram_style = "block" *) bit [63:0] MEM [0: MEM_SIZE-1];

initial begin
    MEM[0]=64'h43ad006283134295;
    MEM[1]=64'h04639a6300638463;
    MEM[2]=64'h4295a0090014e493;
    MEM[3]=64'h8463439500028313;
    MEM[4]=64'ha00902639f630063;
    MEM[5]=64'h438d0062c3134295;
    MEM[6]=64'h0263966300638463;
    MEM[7]=64'h0062e3134295a009;
    MEM[8]=64'h9d6300638463439d;
    MEM[9]=64'ha3134295a0090063;
    MEM[10]=64'h0063846343810052;
    MEM[11]=64'ha021430100639463;
    MEM[12]=64'h4281a009430198f9;
    MEM[13]=64'h839b009893b70305;
    MEM[14]=64'h9263006385636803;
    MEM[15]=64'h4215a009b7f50063;
    MEM[16]=64'h43a9024283334289;
    MEM[17]=64'h0063966300638463;
    MEM[18]=64'ha02143010024e493;
    MEM[19]=64'h4281a009430198f5;
    MEM[20]=64'h839b009893b70305;
    MEM[21]=64'h9263006385636803;
    MEM[22]=64'h4215a009b7f50063;
    MEM[23]=64'h846343bd929242a9;
    MEM[24]=64'he493005396630053;
    MEM[25]=64'h98eda02143010044;
    MEM[26]=64'h03054281a0094301;
    MEM[27]=64'h6803839b009893b7;
    MEM[28]=64'h0063926300638563;
    MEM[29]=64'h00500213a009b7f5;
    MEM[30]=64'h0000031300700293;
    MEM[31]=64'h0100041300800393;
    MEM[32]=64'h0280059302000513;
    MEM[33]=64'h0380069303000613;
    MEM[34]=64'h0480079304000713;
    MEM[35]=64'h01f0089300f00813;
    MEM[36]=64'h0500099303200913;
    MEM[37]=64'h04000a9306300a13;
    MEM[38]=64'h0053b02300433023;
    MEM[39]=64'h0125302301043023;
    MEM[40]=64'h00033b8300532baf;
    MEM[41]=64'h95630173846343b1;
    MEM[42]=64'ha0190084e4930173;
    MEM[43]=64'h0000a001a00998dd;
    end


always @( posedge i_clk) begin : BLOCK_READ_and_DATA_WRITE
o_mem_read_done <=0;
o_mem_write_done <=0;

if(i_mem_read_req)
begin


o_cache_line <= { 
    MEM[i_mem_read_address[`INDEX] + 3],
    MEM[i_mem_read_address[`INDEX] + 2],
    MEM[i_mem_read_address[`INDEX] + 1],
    MEM[i_mem_read_address[`INDEX] + 0]};

    o_mem_read_done <= 1;
end

else if(i_mem_write_valid)
begin

if(i_write_strobe[0])
MEM[i_mem_write_address[`INDEX]][7:0] <= i_mem_write_data[7:0];

if(i_write_strobe[1])
MEM[i_mem_write_address[`INDEX]][15:8] <= i_mem_write_data[15:8];

if(i_write_strobe[2])
MEM[i_mem_write_address[`INDEX]][23:16] <= i_mem_write_data[23:16];

if(i_write_strobe[3])
MEM[i_mem_write_address[`INDEX]][31:24] <= i_mem_write_data[31:24];

if(i_write_strobe[4])
MEM[i_mem_write_address[`INDEX]][39:32] <= i_mem_write_data[39:32];

if(i_write_strobe[5])
MEM[i_mem_write_address[`INDEX]][47:40] <= i_mem_write_data[47:40];

if(i_write_strobe[6])
MEM[i_mem_write_address[`INDEX]][55:48] <= i_mem_write_data[55:48];

if(i_write_strobe[7])
MEM[i_mem_write_address[`INDEX]][63:56] <= i_mem_write_data[63:56];
    


    o_mem_write_done <=1;
end
/*
else if (!i_rst_n)
begin
    for (int i = 0 ; i < MEM_SIZE ;i=i+1 ) begin
        MEM[i] <= 'b0;
    end
end
*/
end
    
endmodule