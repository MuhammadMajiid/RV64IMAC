// Parametrized module for pipe stages

module riscv_core_pipe 
#(
    parameter W_PIPE_BUS = 32
)
(

    // Global inputs
    input logic i_pipe_clk,
    input logic i_pipe_rst_n,

    // Control inputs
    input logic i_pipe_clr,
    input logic i_pipe_en_n,
    
    // Input
    input logic [W_PIPE_BUS-1:0] i_pipe_in,

    // Output
    output logic [W_PIPE_BUS-1:0] o_pipe_out
);

// Pipe behaviour
always_ff @(posedge i_pipe_clk, negedge i_pipe_rst_n) 
begin : pipe_proc
    if (!i_pipe_rst_n) 
    begin
        o_pipe_out <= 'b0;
    end
    else if (i_pipe_clr) begin
        o_pipe_out <= 'b0;
    end
    else if (!i_pipe_en_n) 
    begin
        o_pipe_out <= i_pipe_in;
    end
    else
    begin
        o_pipe_out <= o_pipe_out;
    end
end

endmodule