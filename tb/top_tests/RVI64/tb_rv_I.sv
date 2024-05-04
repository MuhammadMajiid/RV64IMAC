/*
Date:20/12/2023
test bench for RVI64 core with basic instructions to test the functionality of each instruction
first we initialze the data memory with x means each location will have it's address as a data value
and each register with 2x means each reg will have it's address *2 as a data
this will make it more easy to excepect the changed value due to each instruction
*/
module tb();
parameter XLEN = 64 ;//data and address width
parameter REGS = 32 ;//No.of Registers
parameter MEMS = 50 ;//No.of initialized memory location (enough for us)
//Core inputs
logic rst_n, clk;
integer fd,rv;
integer myfile;           //file handler
integer out_file;         //file handler
bit [63:0] expc_val;      //expected value
bit [63:0] dummy;
//Core instance
riscv_core_top c1(clk,rst_n);


logic [63:0] ram [0:12];
always #50  clk = ~clk;


initial  begin
$readmemh("I_Type_check.txt",ram);
end


initial begin
    rst_n=0;
    clk=0;
    #1
    rst_n=1;
    #1;


    //myfile = $fopen("R_Type check.txt","r");            //R-type check holds the expected output    
    //out_file = $fopen("check_result.txt", "w");        //result of cheching is printed out in a text file
    fd=$fopen("I Type.txt","r");                        //// intialize instruction memory


    for(int i =0;i<13;i++)
        rv=$fscanf(fd,"%h",{c1.u_riscv_core_imem.mem[4*i+3],c1.u_riscv_core_imem.mem[4*i+2],c1.u_riscv_core_imem.mem[4*i+1],c1.u_riscv_core_imem.mem[4*i]});
    //for(int i=0 ;i<MEMS+10;i++)
      //  $display("Mem[%0d]=%0h",i,c1.mem[i]);
    for(int i=0 ; i<MEMS ; i++)                                              //initialize datamem
        c1.u_riscv_core_data_mem.mem[i]=i;
    for(int i =0 ; i<REGS ; i++)                                           //intialize regfile
        c1.u_riscv_core_rf.rf[i]=2*i;



    repeat(5)
        @(posedge clk);
      for(int i=0 ; i<13 ; i++)  begin
      //dummy = $fscanf(myfile,"%h",expc_val);

       @(negedge clk)


       //if(tb_rv.c1.u_riscv_core_data_mem.mem[] == expc_val) begin
       if(c1.u_riscv_core_rf.rf[17]== ram[i])  begin
        $display("pass");
        //$fwrite(out_file,"%s\n","passed");
       end
       
       else  begin
        $display("failed");
        //$fwrite(out_file,"%s\n","failed");
       end
      
     end

     
    //$fclose(myfile);


    
    
end

endmodule