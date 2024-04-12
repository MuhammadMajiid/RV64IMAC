module riscv_core_hazard_unit
(

    // RV64I Detection inputs
    input logic [4:0] i_hazard_unit_rs1_id,
    input logic [4:0] i_hazard_unit_rs2_id,
    input logic [4:0] i_hazard_unit_rs1_ex,
    input logic [4:0] i_hazard_unit_rs2_ex,
    input logic [4:0] i_hazard_unit_rd_ex,
    input logic [4:0] i_hazard_unit_rd_mem,
    input logic [4:0] i_hazard_unit_rd_wb,

    // Control signals inputs
    input logic i_hazard_unit_regwrite_mem,
    input logic i_hazard_unit_regwrite_wb,
    input logic [1:0] i_hazard_unit_resultsrc_ex,
    input logic i_hazard_unit_pcsrc_ex,

    // C Extension requests
    input logic i_hazard_unit_illegal_instr,

    // M Extension requests
    input logic i_hazard_unit_mdone,
    input logic i_hazard_unit_mbusy,

    // Caches requests
    input logic i_hazard_unit_dcache_stall,
    input logic i_hazard_unit_icache_stall,

    // Forwarding outputs
    output logic [1:0] o_hazard_unit_forwarda_ex,
    output logic [1:0] o_hazard_unit_forwardb_ex,

    // Stall outputs
    output logic o_hazard_unit_stall_if,
    output logic o_hazard_unit_stall_id,
    output logic o_hazard_unit_stall_ex,
    output logic o_hazard_unit_stall_mem,
    output logic o_hazard_unit_stall_wb,

    // Flush outputs
    output logic o_hazard_unit_flush_id,
    output logic o_hazard_unit_flush_ex,
    output logic o_hazard_unit_flush_mem,
    output logic o_hazard_unit_flush_wb,

    //CSR inputs
    input  logic i_hazard_unit_csr_flush_id,
    input  logic i_hazard_unit_csr_flush_ex,
    input  logic i_hazard_unit_csr_flush_mem,
    input  logic i_hazard_unit_csr_flush_wb
);

// Internals
logic lwstall_detection;
logic mstall_detection;
logic icache_stall_detection;
logic dcache_stall_detection;

//------------------------------Forwarding------------------------------\\

always_comb 
begin : forwarding_proc

    // Forwarding SrcA
    if ((i_hazard_unit_rs1_ex == i_hazard_unit_rd_mem) && i_hazard_unit_regwrite_mem && (i_hazard_unit_rs1_ex != 5'b0)) 
    begin
        o_hazard_unit_forwarda_ex = 2'b10;
    end
    else if ((i_hazard_unit_rs1_ex == i_hazard_unit_rd_wb) && i_hazard_unit_regwrite_wb && (i_hazard_unit_rs1_ex != 5'b0)) 
    begin
        o_hazard_unit_forwarda_ex = 2'b01;
    end
    else 
    begin
        o_hazard_unit_forwarda_ex = 2'b00;
    end
    
    // Forwarding SrcB
    if ((i_hazard_unit_rs2_ex == i_hazard_unit_rd_mem) && i_hazard_unit_regwrite_mem && (i_hazard_unit_rs2_ex != 5'b0)) 
    begin
        o_hazard_unit_forwardb_ex = 2'b10;
    end
    else if ((i_hazard_unit_rs2_ex == i_hazard_unit_rd_wb) && i_hazard_unit_regwrite_wb && (i_hazard_unit_rs2_ex != 5'b0)) 
    begin
        o_hazard_unit_forwardb_ex = 2'b01;
    end
    else 
    begin
        o_hazard_unit_forwardb_ex = 2'b00;
    end

end

//---------------------------------Stall---------------------------------\\

always_comb 
begin : stall_proc
    lwstall_detection       = ((i_hazard_unit_resultsrc_ex == 2'b01) && ((i_hazard_unit_rs1_id == i_hazard_unit_rd_ex) || (i_hazard_unit_rs2_id == i_hazard_unit_rd_ex)));
    mstall_detection        = (i_hazard_unit_mbusy && !i_hazard_unit_mdone);
    icache_stall_detection  = i_hazard_unit_icache_stall;
    dcache_stall_detection  = i_hazard_unit_dcache_stall;
    o_hazard_unit_stall_if  = lwstall_detection || mstall_detection || icache_stall_detection || dcache_stall_detection;
    o_hazard_unit_stall_id  = lwstall_detection || mstall_detection || dcache_stall_detection;
    o_hazard_unit_stall_ex  = mstall_detection  || dcache_stall_detection;
    o_hazard_unit_stall_mem = mstall_detection  || dcache_stall_detection;
    o_hazard_unit_stall_wb  = mstall_detection;
end

//---------------------------------Flush---------------------------------\\

always_comb 
begin : flush_proc
    o_hazard_unit_flush_ex  = (lwstall_detection || i_hazard_unit_pcsrc_ex || i_hazard_unit_csr_flush_ex );
    o_hazard_unit_flush_id  = i_hazard_unit_pcsrc_ex || i_hazard_unit_csr_flush_id;
    o_hazard_unit_flush_mem = i_hazard_unit_csr_flush_mem;
    o_hazard_unit_flush_wb  = i_hazard_unit_csr_flush_wb;
end

endmodule