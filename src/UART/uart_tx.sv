/*
    S_AXI4-Stream UART-Tx Interface
    ______________
    |PARTYP| Type |
    |-------------|
    |2'b00 | NONE |
    |-------------|
    |2'b01 | ODD  |            
    |-------------|
    |2'b00 | EVEN |
    |-------------|
    |2'b01 | NONE |
    |-------------|
*/

`timescale 1ns/1ps
module uart_tx #
(
    parameter DWIDTH = 4'd8,
    parameter PARTYP = 2'b01 
)
(
    // Global
    input logic               uart_clk,
    input logic               uart_rst_n,

    // AXI-stream Intrface Rx
    input  logic [DWIDTH-1:0] s_axis_tdata,
    input  logic              s_axis_tvalid,
    input  logic              s_axis_tlast,
    output logic              s_axis_tready,

    // UART Interface Tx
    output logic              uart_txd,
    output logic              uart_busy
);

// Internal declaration
logic s_axis_tready_comb;
logic s_axis_tlast_reg;
logic uart_tx_comb;
logic uart_busy_comb;
logic parity_bit;
logic [DWIDTH-1:0] data_reg, data_comb;
logic [DWIDTH-1:0] parity_check_reg;
logic [$clog2(DWIDTH):0] frame_count_reg, frame_count_comb;

// state encoding "Gray"
typedef enum logic [1:0] {IDLE, START, TX, STOP} fsm_t;
(*fsm_encoding = "gray"*) fsm_t state_crnt, state_nxt;

// parity generation block
uart_parity #
(
    .DWIDTH(DWIDTH)
    ,.PARTYP(PARTYP)
) check 
(
    .data_in(parity_check_reg)
    ,.parity_out(parity_bit)
);

// Transmission
always_ff @(posedge uart_clk, negedge uart_rst_n) begin
    if (!uart_rst_n) begin
        data_reg          <= 'b0;
        parity_check_reg  <= 'b0;
        frame_count_reg   <= 'b0;
        s_axis_tlast_reg  <= 1'b0;
        state_crnt        <= IDLE;
    end
    else begin
        if (s_axis_tvalid && s_axis_tready_comb) begin
            parity_check_reg  <= s_axis_tdata;
            s_axis_tlast_reg  <= s_axis_tlast;
        end
        data_reg          <= data_comb;
        frame_count_reg   <= frame_count_comb;
        state_crnt        <= state_nxt;
    end
end

always_comb begin
    // --Default Values
    uart_tx_comb       = 1'b1;
    uart_busy_comb     = 1'b1;
    s_axis_tready_comb = 1'b0;
    data_comb          = data_reg;
    frame_count_comb   = frame_count_reg;
    state_nxt          = state_crnt;

    unique case (state_crnt)
            IDLE  : begin
                uart_busy_comb     = 1'b0;
                frame_count_comb   = DWIDTH + 4'd1;
                if (s_axis_tvalid) begin
                    s_axis_tready_comb = 1'b1;
                    data_comb          = s_axis_tdata;
                    state_nxt          = START;
                end
            end 
            START : begin
                uart_tx_comb       = 1'b0;
                state_nxt          = TX;
            end
            TX    : begin
                state_nxt          = TX;
                frame_count_comb   = frame_count_reg - 'b1;
                {data_comb, uart_tx_comb} = {1'b1, data_reg};
                if (frame_count_reg == 'b0) begin
                    uart_tx_comb     = parity_bit;
                    state_nxt        = STOP;
                end
                else if (frame_count_reg == 'd1) begin
                    uart_tx_comb     = s_axis_tlast_reg;
                end
            end
            STOP  : begin
                state_nxt          = IDLE;
            end
        endcase
end

// Output Assignment
assign uart_txd      = uart_tx_comb;
assign uart_busy     = uart_busy_comb;
assign s_axis_tready = s_axis_tready_comb;

endmodule