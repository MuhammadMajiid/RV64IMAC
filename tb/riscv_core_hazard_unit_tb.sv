`timescale 1ns/1ps
`include "C:\\Users\\majii\\Documents\\MyGit\\Verilog\\RISC-V\\class\\riscv_core_hazard_unit_class.sv"


module riscv_core_hazard_unit_tb;

//-------------Global Parameters-------------//
parameter CLKPER      = 20;
parameter LOOPS       = 150;
parameter STOP_TIME   = LOOPS*CLKPER;
parameter WRITE_FILE  = "HU_OUT.txt";

//-------------Global Signals-------------//
logic clk, rst_n;
integer fh;

//-------------Drive Signals----------------//
// RV64I Detection
logic [4:0] i_hazard_unit_rs1_id;
logic [4:0] i_hazard_unit_rs2_id;
logic [4:0] i_hazard_unit_rs1_ex;
logic [4:0] i_hazard_unit_rs2_ex;
logic [4:0] i_hazard_unit_rd_ex;
logic [4:0] i_hazard_unit_rd_mem;
logic [4:0] i_hazard_unit_rd_wb;
// Control signals
logic i_hazard_unit_regwrite_mem;
logic i_hazard_unit_regwrite_wb;
logic i_hazard_unit_resultsrc0_ex;
logic i_hazard_unit_pcsrc_ex;
//-------------Monitor Signals-------------//
// Forwarding
logic [1:0] o_hazard_unit_forwarda_ex;
logic [1:0] o_hazard_unit_forwardb_ex;
// Stall
logic o_hazard_unit_stall_if;
logic o_hazard_unit_stall_id;
// Flush
logic o_hazard_unit_flush_id;
logic o_hazard_unit_flush_ex;

//-------------DUT-------------//
riscv_core_hazard_unit dut (.*);

//-------------Init-------------//
initial begin
    rst_n = 1'b0;
    clk   = 1'b0;
    @(negedge clk);
    rst_n = 1'b1;
end

//-------------Clocking-------------//
initial begin
    forever begin
        #(CLKPER/2) clk = ~clk;
    end
end

//-------------Pipeline Behaviour-------------//
always @(posedge clk, negedge rst_n) begin
    if(!rst_n) begin
        i_hazard_unit_rs1_ex <= 5'b0;
        i_hazard_unit_rs2_ex <= 5'b0;
        i_hazard_unit_rd_mem <= 5'b0;
        i_hazard_unit_rd_wb  <= 5'b0;
    end
    else begin
        i_hazard_unit_rs1_ex <= i_hazard_unit_rs1_id;
        i_hazard_unit_rs2_ex <= i_hazard_unit_rs2_id;
        i_hazard_unit_rd_mem <= i_hazard_unit_rd_ex;
        i_hazard_unit_rd_wb  <= i_hazard_unit_rd_mem;
    end
end

//-------------Test Vectors-------------//
hazard_unit_hazard_unit_class test = new();
initial begin
    //---------Directed Tests---------//
        // Test 1 for Line 57 : hazard_unit_hazard_unit
    i_hazard_unit_regwrite_mem = 1'b1;
    i_hazard_unit_rs2_id = 5'b11011;
    i_hazard_unit_rd_ex = 5'b11011;
    fh = $fopen(WRITE_FILE, "a");
    $fdisplay(fh, "%t: INPUTS :  Rs1ID = %h - Rs1EX = %h - Rs2ID = %h - Rs2EX = %h - RdEX = %h - RdMem = %h - RdWb = %h    >> Loop Directed NO. 1", $time, i_hazard_unit_rs1_id, i_hazard_unit_rs1_ex, i_hazard_unit_rs2_id, i_hazard_unit_rs2_ex, i_hazard_unit_rd_ex, i_hazard_unit_rd_mem, i_hazard_unit_rd_wb);
    $fdisplay(fh, "%t: OUTPUTS:  ForwardA = %b - ForwardB = %b - StallIF = %b - StallID = %b - FlushID = %b - FlushEX = %b >> Loop Directed NO. 1", $time, o_hazard_unit_forwarda_ex, o_hazard_unit_forwardb_ex, o_hazard_unit_stall_if, o_hazard_unit_stall_id, o_hazard_unit_flush_id, o_hazard_unit_flush_ex);
    $fclose(fh);
        // Test 2 for line 76 : hazard_unit_hazard_unit
    i_hazard_unit_resultsrc0_ex = 1'b1;
    i_hazard_unit_rd_ex  = 5'b10011;
    i_hazard_unit_rs1_id = 5'b10011;
    fh = $fopen(WRITE_FILE, "a");
    $fdisplay(fh, "%t: INPUTS :  Rs1ID = %h - Rs1EX = %h - Rs2ID = %h - Rs2EX = %h - RdEX = %h - RdMem = %h - RdWb = %h    >> Loop Directed NO. 2", $time, i_hazard_unit_rs1_id, i_hazard_unit_rs1_ex, i_hazard_unit_rs2_id, i_hazard_unit_rs2_ex, i_hazard_unit_rd_ex, i_hazard_unit_rd_mem, i_hazard_unit_rd_wb);
    $fdisplay(fh, "%t: OUTPUTS:  ForwardA = %b - ForwardB = %b - StallIF = %b - StallID = %b - FlushID = %b - FlushEX = %b >> Loop Directed NO. 2", $time, o_hazard_unit_forwarda_ex, o_hazard_unit_forwardb_ex, o_hazard_unit_stall_if, o_hazard_unit_stall_id, o_hazard_unit_flush_id, o_hazard_unit_flush_ex);
    $fclose(fh);
        // Test 3 for line 76 : hazard_unit_hazard_unit
    i_hazard_unit_resultsrc0_ex = 1'b1;
    i_hazard_unit_rd_ex  = 5'b10011;
    i_hazard_unit_rs2_id = 5'b10011;
    fh = $fopen(WRITE_FILE, "a");
    $fdisplay(fh, "%t: INPUTS :  Rs1ID = %h - Rs1EX = %h - Rs2ID = %h - Rs2EX = %h - RdEX = %h - RdMem = %h - RdWb = %h    >> Loop Directed NO. 3", $time, i_hazard_unit_rs1_id, i_hazard_unit_rs1_ex, i_hazard_unit_rs2_id, i_hazard_unit_rs2_ex, i_hazard_unit_rd_ex, i_hazard_unit_rd_mem, i_hazard_unit_rd_wb);
    $fdisplay(fh, "%t: OUTPUTS:  ForwardA = %b - ForwardB = %b - StallIF = %b - StallID = %b - FlushID = %b - FlushEX = %b >> Loop Directed NO. 3", $time, o_hazard_unit_forwarda_ex, o_hazard_unit_forwardb_ex, o_hazard_unit_stall_if, o_hazard_unit_stall_id, o_hazard_unit_flush_id, o_hazard_unit_flush_ex);
    $fclose(fh);



    //---------Random Tests---------//
    for (int i=0 ; i<LOOPS ; i++ ) begin
        @(negedge clk);
        {i_hazard_unit_regwrite_mem, i_hazard_unit_regwrite_wb, i_hazard_unit_resultsrc0_ex, i_hazard_unit_pcsrc_ex} = $random;
        test.randomize();
        i_hazard_unit_rs1_id = test.i_hazard_unit_rs1_id;
        i_hazard_unit_rs2_id = test.i_hazard_unit_rs2_id;
        i_hazard_unit_rd_ex  = test.i_hazard_unit_rd_ex;
        
        // write output in a file
        fh = $fopen(WRITE_FILE, "a");
        $fdisplay(fh, "%t: INPUTS :  Rs1ID = %h - Rs1EX = %h - Rs2ID = %h - Rs2EX = %h - RdEX = %h - RdMem = %h - RdWb = %h    >> Loop %0d", $time, i_hazard_unit_rs1_id, i_hazard_unit_rs1_ex, i_hazard_unit_rs2_id, i_hazard_unit_rs2_ex, i_hazard_unit_rd_ex, i_hazard_unit_rd_mem, i_hazard_unit_rd_wb, i);
        $fdisplay(fh, "%t: OUTPUTS:  ForwardA = %b - ForwardB = %b - StallIF = %b - StallID = %b - FlushID = %b - FlushEX = %b >> Loop %0d", $time, o_hazard_unit_forwarda_ex, o_hazard_unit_forwardb_ex, o_hazard_unit_stall_if, o_hazard_unit_stall_id, o_hazard_unit_flush_id, o_hazard_unit_flush_ex, i);
        $fclose(fh);
    end
end

//-------------Stop Simulation-------------//
initial begin
    #(STOP_TIME) $stop;
end

endmodule