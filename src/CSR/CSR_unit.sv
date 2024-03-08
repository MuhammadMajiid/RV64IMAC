`define XLEN              64
`define csr_addr          12
`define instr_addr        32

//machine information registers addresses
`define csr_mvendorid     12'hf11
`define csr_marchid       12'hf12
`define csr_mimpid        12'hf13
`define csr_mhartid       12'hf14

//machine trap setup registers addresses
`define csr_mstatus       12'h300
`define csr_misa          12'h301
`define csr_mie           12'h304
`define csr_mtvec         12'h305

//machine trap handling registers addresses
`define csr_mscratch      12'h340
`define csr_mepc          12'h341
`define csr_mcause        12'h342
`define csr_mip           12'h344
`define csr_mtval         12'h343
`define csr_mtinst        12'h34a

//hardware performance monitor CSRs
`define csr_time          12'hc01
`define csr_cycle         12'hc00
`define csr_mtimecmp      12'hbbf

//bits in mstatus,mie, and mip                         
`define mstatus_mie       mstatus[3]
`define mstatus_mpie      mstatus[7]
`define mie_meie          mie[11]
`define mip_meip          mip[11]
`define mie_mtie          mie[7]
`define mip_mtip          mip[7]

//exceptions and interrupts
`define instr_addr_misaligned  63'h0
`define illegal_instr          63'h2
`define ebreak                 63'h3
`define lw_access_fault        63'h5 
`define sw_access_fault        63'h7
`define ecall                  63'hb 
`define external_interrupt     63'hb 
`define timer_interrupt        63'h7


//CSR operations
`define CSRRW                  2'h1
`define CSRRS                  2'h2
`define CSRRC                  2'h3

module riscv_core_csr_unit(

    input  logic                    i_riscv_core_clk,
    input  logic                    i_riscv_core_rst_n,
    input  logic  [`instr_addr-1:0] i_riscv_core_pc,                    //input PC
    input  logic                    i_riscv_core_mem_wen,               //memory write enable signal
    input  logic  [`XLEN-1:0]       i_riscv_core_fault_addr,            //fault address from load or store operation
    input  logic  [`instr_addr-1:0] i_riscv_core_instr,

    //external interrupts
    input  logic                   i_riscv_core_mexternal,             //machine external interrupt
    output logic                   o_riscv_core_ack,                    //acknowlegment
    
    //CSR instructions signals      
    input  logic                    i_riscv_core_csr_wen,               //csr write enable signal
    input  logic  [2:0]             i_riscv_core_op,                    //CSR operation
    input  logic  [`XLEN-1:0]       i_riscv_core__csr_src,
    input  logic  [`csr_addr-1:0]   i_riscv_core_csr_addr,              //csr address
    output logic  [`XLEN-1:0]       o_riscv_core_csr_rdata,             //data read from the csr

    //exception handling signals
    output logic [`instr_addr-1:0]  o_riscv_core_irq_handler,           //trap handler address
    output logic [`instr_addr-1:0]  o_riscv_core_mepc,                  //return address
    output logic                    o_riscv_core_addr_ctrl,             //select between mepc and irq_handler
    output logic                    o_riscv_core_mux1,

    //machine mode instructions
    input  logic                   i_riscv_core_mret_id,
    input  logic                   i_riscv_core_mret_wb,
    input  logic                   i_riscv_core_ecall,
    input  logic                   i_riscv_core_ebreak,

    //exception signals
    input  logic                   i_riscv_core_illegal_instr_id,   
    input  logic                    i_riscv_core_illegal_instr_exe,       
    input  logic                   i_riscv_core_instr_addr_misaligned,
    input  logic                   i_riscv_core_lw_access_fault,
    input  logic                   i_riscv_core_sw_access_fault,

    //flush signals
    output logic                   o_riscv_core_if_flush,
    output logic                   o_riscv_core_id_flush,
    output logic                   o_riscv_core_exe_flush,
    output logic                   o_riscv_core_mem_flush

);


//CSR registers
logic [`XLEN-1:0] mstatus;
logic [`XLEN-1:0] misa;
logic [`XLEN-1:0] mie;
logic [`XLEN-1:0] mip;
logic [`XLEN-1:0] mcause;
logic [`XLEN-1:0] mepc;
logic [`XLEN-1:0] mtval;
logic [`XLEN-1:0] mtinst;
logic [`XLEN-1:0] mtvec;
logic [`XLEN-1:0] mscratch;
logic [`XLEN-1:0] mtimecmp;

//64-bit counter
logic [`XLEN-1:0] counter;

//intermediate value
logic [`XLEN-1:0] op_result;                         //result of CSR operation



//FSM states
typedef enum logic {idle,setting_up} state;
state current_state;


//trap address modes
logic [`instr_addr-1 :0] direct_addr, vector_addr;
logic [`instr_addr-1 :0] intrr_addr, expn_addr;       //trap address in vector mode
logic pending_exception;

//flush signals
logic csr_flush_mem;
logic csr_flush_exe;
logic csr_flush_id;
logic csr_flush_if;




//misa register
assign misa = {
    2'b10,                           //MXL=2  XLEN = 64
    36'b0,                           //reserved
    26'b00000000000001000100000101   //RV-IMAC with machine is implemented till now
};




always_comb 
  begin
    case (i_riscv_core_op)

      `CSRRW:      op_result = i_riscv_core__csr_src;
      `CSRRS:      op_result = o_riscv_core_csr_rdata | i_riscv_core__csr_src;
      `CSRRC:      op_result = o_riscv_core_csr_rdata & (~i_riscv_core__csr_src);

      default:     op_result = 64'hx; 

    endcase

  end


/************************output assignment******************************/
always_ff @(posedge i_riscv_core_clk or negedge i_riscv_core_rst_n)
begin: output_assignment_proc

 if(!i_riscv_core_rst_n)
  o_riscv_core_csr_rdata <= 64'b0;
  
   else 
    begin

     case(i_riscv_core_csr_addr)
      

       `csr_mvendorid:    o_riscv_core_csr_rdata <= 32'b0;

       `csr_marchid:      o_riscv_core_csr_rdata <= 64'b0;

       `csr_mhartid:      o_riscv_core_csr_rdata <= 64'b0;

       `csr_mimpid:       o_riscv_core_csr_rdata <= 64'b0;

       `csr_misa:         o_riscv_core_csr_rdata <= misa;

       `csr_mstatus:      o_riscv_core_csr_rdata <= mstatus;

       `csr_mie:          o_riscv_core_csr_rdata <= mie;

       `csr_mip:          o_riscv_core_csr_rdata <= mip;

       `csr_mcause:       o_riscv_core_csr_rdata <= mcause;

       `csr_mtvec:        o_riscv_core_csr_rdata <= mtvec;

       `csr_mepc:         o_riscv_core_csr_rdata <= mepc;

       `csr_mtval:        o_riscv_core_csr_rdata <= mtval;

       `csr_mtinst:       o_riscv_core_csr_rdata <= mtinst;

       `csr_mscratch:     o_riscv_core_csr_rdata <= mscratch;

       `csr_time:         o_riscv_core_csr_rdata <= counter;

       `csr_cycle:        o_riscv_core_csr_rdata <= counter;

       `csr_mtimecmp:     o_riscv_core_csr_rdata <= mtimecmp;

       default:           o_riscv_core_csr_rdata <= 64'b0;
      

     endcase

      

    end

end
/***************************end of output assignment***************************/






/***********************************state transition****************************/
always_ff @(posedge i_riscv_core_clk or negedge i_riscv_core_rst_n)
begin:trap_setup_proc


    if (!i_riscv_core_rst_n)
    begin
        current_state <= idle;
        mcause <= 64'b0;
        mtval  <= 64'b0;
        mtinst <= 64'b0;
    end

    else
    begin
        case (current_state)
           idle:
             begin


                if (i_riscv_core_csr_wen)
                  begin
                    if (i_riscv_core_csr_addr == `csr_mcause)
                      mcause <= op_result;

                    else if (i_riscv_core_csr_addr == `csr_mtval)
                      mtval <= op_result;

                    else if (i_riscv_core_csr_addr == `csr_mtinst)
                      mtinst <= op_result;
                  end

                
                //external interrupts
                if (`mstatus_mie & `mie_meie & `mip_meip)
                  begin
                    current_state <= setting_up;
                    mtval  <= 64'b0;
                    mtinst <= 64'b0;
                    mcause[63] <= 1'b1;
                    mcause[62:0] <= `external_interrupt;
                    o_riscv_core_ack <= 1'b1;
                  end

                
                //timer interrupts
                else if (`mstatus_mie & `mie_mtie & `mip_mtip)
                  begin
                    current_state <= setting_up;
                    mtval  <= 64'b0;
                    mtinst <= 64'b0;
                    mcause[63] <= 1'b1;
                    mcause[62:0] <= `timer_interrupt;
                  end

               
                //illegal instruction exception
                else if (i_riscv_core_illegal_instr_id || i_riscv_core_illegal_instr_exe)
                  begin
                    current_state <= setting_up;
                    mtval  <= 64'b0;
                    mtinst <= i_riscv_core_instr;
                    mcause[63] <= 1'b0;
                    mcause[62:0] <= `illegal_instr;
                  end


                //instruction address misaligned exception
                else if (i_riscv_core_instr_addr_misaligned)
                  begin
                    current_state <= setting_up;
                    mtval  <= 64'b0;
                    mtinst <= i_riscv_core_instr;
                    mcause[63] <= 1'b0;
                    mcause[62:0] <= `instr_addr_misaligned;
                  end
                

                //ecall instruction generates ecall exception
                else if (i_riscv_core_ecall)
                  begin
                    current_state <= setting_up;
                    mtval  <= 64'b0;
                    mtinst <= i_riscv_core_instr;
                    mcause[63] <= 1'b0;
                    mcause[62:0] <= `ecall;
                  end
                

                //ebreak instruction generates ebreak exception
                else if (i_riscv_core_ebreak)
                  begin
                    current_state <= setting_up;
                    mtval  <= 64'b0;
                    mtinst <= i_riscv_core_instr;
                    mcause[63] <= 1'b0;
                    mcause[62:0] <= `ebreak;
                  end


                else if (i_riscv_core_sw_access_fault)
                  begin
                    current_state <= setting_up;
                    mtval  <= i_riscv_core_fault_addr;
                    mtinst <= i_riscv_core_instr;
                    mcause[63] <= 1'b0;
                    mcause[62:0] <= `sw_access_fault;
                  end


                else if (i_riscv_core_lw_access_fault)
                  begin
                    current_state <= setting_up;
                    mtval  <= i_riscv_core_fault_addr;
                    mtinst <= i_riscv_core_instr;
                    mcause[63] <= 1'b0;
                    mcause[62:0] <= `lw_access_fault;
                  end




             end


           setting_up:
              begin
                current_state <= idle;
                o_riscv_core_ack <= 1'b0;
              end
        endcase
    end

end
/****************************end of state transition*********************/





/****************************CSR assignment**********************************/
always_ff @(posedge i_riscv_core_clk or negedge i_riscv_core_rst_n)
begin: csr_assignment_proc

if (!i_riscv_core_rst_n)
 begin
    mstatus[10:0] <= 11'b0;
    mstatus[63:13] <= 49'b0;
    mstatus[12:11] <= 2'b11;              //machine mode
    mie <= 64'b0;
    mtvec <= 64'b0;
    mepc <= 64'b0;
    mscratch <= 64'b0;
    mtimecmp <= 64'b0;
 end



 else
 begin
    if (i_riscv_core_csr_wen)
    begin 
        if (i_riscv_core_mret_wb)
        begin
            `mstatus_mie <= `mstatus_mpie;
            `mstatus_mpie <= 1'b1;
        end

        else
        begin
            case (i_riscv_core_csr_addr)
              
              `csr_mstatus:
                 begin
                    `mstatus_mie <= op_result[3];
                    `mstatus_mpie <= op_result[7];
                 end

              `csr_mie:
                 begin
                    `mie_meie <= op_result[11];
                    `mie_mtie <= op_result[7];
                     mie[63:16] <= op_result[63:16];
                 end

              `csr_mtvec:
                 begin
                    mtvec <= op_result;
                 end

              `csr_mepc:
                 begin
                    mepc <= op_result;
                 end

              `csr_mscratch:
                 begin
                    mscratch <= op_result;
                 end

              `csr_mtimecmp:
                 begin
                    mtimecmp <= op_result;
                 end

            endcase
        end
    end



    else
    begin
        case (current_state)
          setting_up:
            begin
                 mepc <= i_riscv_core_pc;
                `mstatus_mpie <= `mstatus_mie;
                `mstatus_mie <= 1'b0;
            end
        endcase
    end
 end

end



 always_ff @(posedge i_riscv_core_clk or negedge i_riscv_core_rst_n)
 begin
    if (! i_riscv_core_rst_n)
      mip <= 64'b0;

    else

    begin 
      `mip_meip <= i_riscv_core_mexternal;
      `mip_mtip <= (counter >= mtimecmp);
    end

 end

 /*********************************end of csr assignment*********************************/




 /*********************************machine timer******************************************/

 always_ff @(posedge i_riscv_core_clk or negedge i_riscv_core_rst_n)
   begin: timer_proc
     if (! i_riscv_core_rst_n)
   
       counter <= 64'b0;

     else
   
       counter <= counter +1;
   end

/************************************end of timer process**********************************/
   
    


//return address
 assign o_riscv_core_mepc = mepc;

 //pending exception
 assign pending_exception = (i_riscv_core_illegal_instr_id | i_riscv_core_illegal_instr_exe | i_riscv_core_instr_addr_misaligned | i_riscv_core_ecall | i_riscv_core_ebreak);


//interrupt handler address
assign o_riscv_core_irq_handler = mtvec[0]? vector_addr : direct_addr;
assign direct_addr = mtvec[31:0];
assign vector_addr = mcause[63]? vector_addr : expn_addr;
assign expn_addr = {mtvec[31:1],1'b0};
assign intrr_addr = {mtvec[31:1],1'b0} + (mcause << 2);

//selector signals
assign o_riscv_core_addr_ctrl = i_riscv_core_mret_id;
assign o_riscv_core_mux1 = ((current_state == setting_up) | i_riscv_core_mret_id);


//flush signals
assign csr_flush_mem = i_riscv_core_lw_access_fault | i_riscv_core_sw_access_fault | (`mstatus_mie & i_riscv_core_mem_wen);
assign csr_flush_exe = csr_flush_mem | i_riscv_core_illegal_instr_exe | i_riscv_core_instr_addr_misaligned | (`mstatus_mie);
assign csr_flush_id = csr_flush_exe | pending_exception | (`mstatus_mie);
assign csr_flush_if =  (current_state == setting_up) | (i_riscv_core_mret_id) | pending_exception | (`mstatus_mie);


assign o_riscv_core_mem_flush = csr_flush_mem;
assign o_riscv_core_exe_flush = csr_flush_exe;
assign o_riscv_core_id_flush  = csr_flush_id;
assign o_riscv_core_if_flush  = csr_flush_if;





endmodule