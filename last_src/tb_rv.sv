/*
Authors: Aly_Ruby       Mohamed_Morsi
Date:20/12/2023
test bench for RVI64 core with basic instructions to test the functionality of each instruction
first we initialze the data memory with x means each location will have it's address as a data value
and each register with 2x means each reg will have it's address *2 as a data
this will make it more easy to excepect the changed value due to each instruction
*/
module tb();
parameter XLEN = 64 ;//data and address width
parameter REGS = 32 ;//No.of Registers
parameter MEMS = 5000 ;//No.of initialized memory location (enough for us)
//Core inputs
logic rst_n, clk;
integer fd,rv;
//Core instance
riscv_core_top c1(clk,rst_n);
always #50  clk = ~clk;
initial begin
    rst_n=0;
    clk=0;
    #1
    rst_n=1;
    #1;
        fd=$fopen("ls.hex","r");                        //// intialize instruction memory
        for(int i =0;i<35;i++)                      //////enter the number of lines
            rv=$fscanf(fd,"%h",{c1.u_main_mem_inst.u_main_mem.MEM[i]});

    for(int i =0 ; i<REGS ; i++) begin                                           //intialize regfile
        c1.u_riscv_core_top_2.u_riscv_core_rf.rf[i]=0;
    end
    c1.u_riscv_core_top_2.u_riscv_core_rf.rf[0]=64'h0;
    c1.u_riscv_core_top_2.u_riscv_core_rf.rf[2]=64'h000000007ffffff0;
    c1.u_riscv_core_top_2.u_riscv_core_rf.rf[3]=64'h0000000010000000;
    repeat(4000)
        @(posedge(clk));
    
    $stop;
end


endmodule