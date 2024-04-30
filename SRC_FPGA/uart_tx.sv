/*
    Author : Mohamed Maged
*/
module uart_tx #
(
    parameter DWIDTH = 4'd8
)
(
    // Global
    input logic               uart_clk,
    input logic               uart_rst_n,

    // Core-to-Tx
    input  logic [DWIDTH-1:0] core_data,
    input  logic              core_valid,
    output logic              ready_to_core,

    // UART Interface Tx
    output logic              uart_txd,
    output logic              uart_busy
);

// Internal declaration
logic uart_tx_comb;
logic uart_busy_comb;
logic ready_comb;
logic [DWIDTH-1:0] data_reg, data_comb;
logic [$clog2(DWIDTH):0] frame_count_reg, frame_count_comb;

// state encoding "Gray"
typedef enum logic [1:0] {IDLE, START, TX, STOP} fsm_t;
(*fsm_encoding = "gray"*) fsm_t state_crnt, state_nxt;

// Transmission
always_ff @(posedge uart_clk, negedge uart_rst_n) begin
    if (!uart_rst_n) begin
        data_reg          <= 'b0;
        frame_count_reg   <= 'b0;
        state_crnt        <= IDLE;
    end
    else begin
        data_reg          <= data_comb;
        frame_count_reg   <= frame_count_comb;
        state_crnt        <= state_nxt;
    end
end

always_comb begin
    // --Default Values
    uart_tx_comb       = 1'b1;
    uart_busy_comb     = 1'b1;
    data_comb          = data_reg;
    frame_count_comb   = frame_count_reg;
    state_nxt          = state_crnt;
    ready_comb         = 1'b0;

    unique case (state_crnt)
            IDLE  : begin
                uart_busy_comb     = 1'b0;
                frame_count_comb   = DWIDTH-1;
                ready_comb         = 1'b1;
                if (core_valid) begin
                    data_comb          = core_data;
                    state_nxt          = START;
                    ready_comb         = 1'b0;
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
                    frame_count_comb  = DWIDTH-1;
                    state_nxt         = STOP;
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
assign ready_to_core = ready_comb;

endmodule