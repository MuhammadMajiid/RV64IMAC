module uartTrans(
    input  logic i_wen,
    input  logic ready,
    input  logic [63:0] i_data,
    input  logic [63:0] address,
    output logic [7:0] uart_out_data,
    output logic valid,
    output logic o_wen,
    output logic stall
);
    always_comb begin : behavior
        //default values
        stall         = 1'b0;
        o_wen         = 1'b0;
        valid         = 1'b0;
        uart_out_data = i_data[7:0];
        if(address == 64'h10000000 && i_wen)begin
            if(!ready)begin
                stall = 1'b1;
                valid = 1'b0;
                o_wen = 1'b0;
            end
            else begin
                stall = 1'b0;
                valid = 1'b1;
                o_wen = 1'b0;
            end
        end
        else begin
            stall = 1'b0;
            valid = 1'b0;
            o_wen = i_wen;
        end
    end
endmodule