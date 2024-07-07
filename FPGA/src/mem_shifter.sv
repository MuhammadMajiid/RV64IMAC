module mem_shifter #(
    parameter DATA_WIDTH =  64
) (
    
    input logic [7:0] i_write_strobe,
    input logic       i_mem_write_req,

    input logic [DATA_WIDTH-1 : 0] i_data,

    output logic [DATA_WIDTH-1 : 0] o_data,
    output logic                    o_mem_write_req
);

always_comb begin : SHIFTER

if(i_write_strobe[0])
o_data = i_data;

else if(i_write_strobe[1])
o_data = i_data << 8;

else if(i_write_strobe[2])
o_data = i_data << 16;

else if(i_write_strobe[3])
o_data = i_data << 24;

else if(i_write_strobe[4])
o_data = i_data << 32;

else if(i_write_strobe[5])
o_data = i_data << 40;

else if(i_write_strobe[6])
o_data = i_data << 48;

else if(i_write_strobe[7])
o_data = i_data << 56;

else
o_data = i_data;

o_mem_write_req = i_mem_write_req;

end

endmodule