/*
    M_AXI4-Stream UART-Rx Interface
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

module uart_rx #
(
    parameter DWIDTH = 8,
    parameter PARTYP = 2'b00
)
(
    // Global
    input logic uart_clk,
    input logic uart_rst_n,

    // AXI-stream Intrface Tx
    output logic [DWIDTH-1:0] m_axis_tdata,
    output logic              m_axis_tvalid,
    output logic              m_axis_tlast,
    input  logic              m_axis_tready,

    // UART Interface
    input  logic              uart_rxd,
    output logic              uart_busy,
    output logic              uart_parity_err,
    output logic              uart_frame_err
);

// Internal declarations
logic [DWIDTH-1:0] m_axis_tdata_reg, m_axis_tdata_comb;
logic              m_axis_tvalid_reg, m_axis_tvalid_comb;
logic              m_axis_tlast_reg, m_axis_tlast_comb;
logic              uart_busy_reg, uart_busy_comb;
logic              start_bit_reg, start_bit_comb;
logic              stop_bit_reg, stop_bit_comb;
logic              parity_bit_reg, parity_bit_comb;
logic              parity_check;
logic              uart_parity_err_reg, uart_parity_err_comb;
logic [$clog2(DWIDTH)+1:0] frame_count_reg, frame_count_comb;

// state encoding "Gray"
typedef enum logic {IDLE, RX} fsm_t;
(*fsm_encoding = "none"*) fsm_t state_crnt, state_nxt;

// parity check block
uart_parity #
(
    .DWIDTH(DWIDTH)
    ,.PARTYP(PARTYP)
) check 
(
    .data_in(m_axis_tdata)
    ,.parity_out(parity_check)
);

always_ff @(posedge uart_clk, negedge uart_rst_n) begin : rx_block
    if (!uart_rst_n) begin
        m_axis_tdata_reg    <= 'b0;
        m_axis_tvalid_reg   <= 1'b0;
        m_axis_tlast_reg    <= 1'b0;
        uart_busy_reg       <= 1'b0;
        frame_count_reg     <= 'h0;
        start_bit_reg       <= 1'b0;
        stop_bit_reg        <= 1'b1;
        parity_bit_reg      <= 1'b1;
        uart_parity_err_reg <= 1'b0;
        state_crnt          <= IDLE;
    end
    else begin
        m_axis_tdata_reg    <= m_axis_tdata_comb;
        m_axis_tvalid_reg   <= m_axis_tvalid_comb;
        m_axis_tlast_reg    <= m_axis_tlast_comb;
        uart_busy_reg       <= uart_busy_comb;
        frame_count_reg     <= frame_count_comb;
        start_bit_reg       <= start_bit_comb;
        stop_bit_reg        <= start_bit_comb;
        parity_bit_reg      <= parity_bit_comb;
        uart_parity_err_reg <= uart_parity_err_comb;
        state_crnt          <= state_nxt;
    end
end

always_comb begin
    // Default values
    state_nxt            = state_crnt;
    m_axis_tvalid_comb   = m_axis_tvalid_reg;
    m_axis_tdata_comb    = m_axis_tdata_reg;
    m_axis_tlast_comb    = 1'b0;
    uart_busy_comb       = uart_busy_reg;
    frame_count_comb     = frame_count_reg;
    start_bit_comb       = start_bit_reg;
    stop_bit_comb        = stop_bit_reg;
    parity_bit_comb      = parity_bit_reg;
    uart_parity_err_comb = uart_parity_err_reg;    
    unique case (state_crnt)
        IDLE : begin
            m_axis_tdata_comb  = m_axis_tdata_reg;
            m_axis_tvalid_comb = 1'b0;
            uart_busy_comb     = 1'b0;
            frame_count_comb   = DWIDTH + 'd3;
            if (m_axis_tready) begin
                state_nxt      = RX;
                uart_busy_comb = 1'b1;
            end
        end
        RX : begin
            state_nxt         = RX;
            m_axis_tdata_comb = m_axis_tdata_reg;
            parity_bit_comb   = parity_bit_reg;
            m_axis_tlast_comb = m_axis_tlast_reg;
            uart_busy_comb    = 1'b1;
            frame_count_comb  = frame_count_reg - 'b1;
            if (frame_count_reg == 'b0) begin // --Stop Bit
                stop_bit_comb     = uart_rxd;
                uart_busy_comb    = 1'b0;
                state_nxt         = IDLE;
                frame_count_comb  = frame_count_reg;
                m_axis_tvalid_comb   = 1'b1;
                if (parity_bit_reg == parity_check) begin
                    uart_parity_err_comb = 1'b0;
                end
                else begin
                    uart_parity_err_comb = 1'b1;
                end
            end
            else begin // --Data Frame
                {parity_bit_comb,m_axis_tlast_comb,m_axis_tdata_comb,start_bit_comb} = {uart_rxd,parity_bit_reg,m_axis_tlast_reg,m_axis_tdata_reg[DWIDTH-1:1],start_bit_reg};
            end
        end
        endcase
end

// Output assignment
assign m_axis_tvalid   = m_axis_tvalid_reg;
assign m_axis_tdata    = (m_axis_tvalid_reg && m_axis_tready)? m_axis_tdata_reg : 'h0;
assign m_axis_tlast    = (m_axis_tvalid_reg)? m_axis_tlast_reg : 1'b0;
assign uart_busy       = uart_busy_reg;
assign uart_parity_err = uart_parity_err_reg;
assign uart_frame_err  = (!start_bit_reg && start_bit_reg);

endmodule