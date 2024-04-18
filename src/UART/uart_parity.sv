module uart_parity #
(
    parameter DWIDTH = 4'd8,
    parameter PARTYP = 2'b00
)
(
    input  logic [DWIDTH-1:0] data_in,
    output logic parity_out
);

always_comb begin
    case (PARTYP)
       2'b00, 2'b11 : parity_out = 1; // --behaves as second stop bit
       2'b01 :        parity_out = (^data_in)? 1'b0 : 1'b1;
       2'b10 :        parity_out = (^data_in)? 1'b1 : 1'b0;
    endcase
end

endmodule