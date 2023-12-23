module integeration_decoder_tb;
logic [6:0] opcode;
logic [2:0] funct3;
logic [6:0] funct7;
logic [2:0] imsrc;
logic       UCtrl;
logic [1:0] resultsrc;
logic       regwrite;
logic       alusrcB;
logic       memwrite;
logic       branch;
logic       jump;
logic [1:0] size;
logic       LdExt;
logic       isword;
logic       aluop;
logic       bjreg;
logic [3:0] alucontrol;

riscv_core_main_decoder u_main_decoder (opcode,funct3,imsrc,UCtrl,resultsrc,regwrite,alusrcB,memwrite, branch, jump, bjreg, size, LdExt, isword, aluop);
riscv_core_alu_decoder  u_alu_decoder  (funct3,aluop,funct7[5],opcode[5],alucontrol);

int input_opcodes , excepted_outputs , input_funct3 , input_funct7;
int results,scoreboard;
int err_count;

logic [20:0] current_ex_out , actual_out;

assign actual_out = {regwrite,imsrc,UCtrl,
alusrcB,memwrite,resultsrc,
branch,aluop,size,LdExt,isword,jump,bjreg,alucontrol};

logic [16:0] input_stimulus;

//assign input_stimulus ={opcode,funct3,funct7};

initial
 begin
 input_opcodes=$fopen("input_opcodes.txt","r");
 excepted_outputs=$fopen("expected_outputs.txt","r");
 results=$fopen("results.txt","a");
 input_funct3=$fopen("input_funt3.txt","r");
 input_funct7=$fopen("input_funct7.txt","r");
 scoreboard=$fopen("scoreboard.txt","a");
 err_count=0;
 $fdisplay(results,"============================================================");
 $fdisplay(scoreboard,"============================================================");



 while (! $feof(input_opcodes)) 
 begin
    $fscanf(input_opcodes,"%b",opcode);
    $fscanf(excepted_outputs , "%b" , current_ex_out);
    $fscanf(input_funct3 , "%h" , funct3);
    $fscanf(input_funct7 , "%h" , funct7);
    #1;
    if (current_ex_out === actual_out) 
begin
        $fdisplay(results , "PASS  : Expected is %b , Output is %b " , current_ex_out , actual_out);
end 
else
begin
        err_count=err_count+1;
        $fdisplay(results,"///////////////////////////////////////////////");
        $fdisplay(results , "ERROR : Expected is %b , Output is %b " , current_ex_out , actual_out);
        $fdisplay(results , "[%t] with opcode %b has the error ",$time,opcode);
        $fdisplay(results,"///////////////////////////////////////////////");
end
 end
$fdisplay(scoreboard,"Failed Cases count is : %d" , err_count);
$fclose(input_opcodes);
$fclose(excepted_outputs);
$fclose(input_funct3);
$fclose(input_funct7);
$fclose(results);
$fclose(scoreboard);
 end



endmodule