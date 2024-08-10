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
`define csr_medeleg       12'h302
`define csr_mideleg       12'h303
`define csr_mie           12'h304
`define csr_mtvec         12'h305

//machine trap handling registers addresses
`define csr_mscratch      12'h340
`define csr_mepc          12'h341
`define csr_mcause        12'h342
`define csr_mtval         12'h343
`define csr_mip           12'h344
`define csr_mtinst        12'h34a

//hardware performance monitor CSRs
`define csr_time          12'hc01
`define csr_cycle         12'hc00
`define csr_mtimecmp      12'hbbf

//supervisor trap setup registers addresses
`define csr_sstatus       12'h100
`define csr_sie           12'h104
`define csr_stvec         12'h105

//supervisor trap handling registers addresses
`define csr_sscratch      12'h140 
`define csr_sepc          12'h141
`define csr_scause        12'h142
`define csr_stval         12'h143
`define csr_sip           12'h144
`define csr_stimecmp      12'h14d      //need to be revised

//supervisor protection and translation register address
`define csr_satp          12'h180                                   


//exceptions and interrupts
`define instr_addr_misaligned  63'h0
`define illegal_instr          63'h2
`define ebreak                 63'h3
`define lw_access_fault        63'h5 
`define sw_access_fault        63'h7
`define ecall                  63'hb 
`define m_external_interrupt   63'hb 
`define m_timer_interrupt      63'h7
`define s_external_interrupt   63'h9
`define s_timer_interrupt      63'h5

//modes
`define m_mode                 2'b11
`define s_mode                 2'b01


//CSR operations
`define CSRRW                  2'h1
`define CSRRS                  2'h2
`define CSRRC                  2'h3

module riscv_core_csr_unit(

    input  logic                    i_csr_unit_clk,
    input  logic                    i_csr_unit_rst_n,
    input  logic  [`XLEN-1:0]       i_csr_unit_pc,                    //input PC
    input  logic                    i_csr_unit_mem_wen,               //memory write enable signal
    input  logic  [`XLEN-1:0]       i_csr_unit_fault_addr,            //fault address from load or store operation
    input  logic  [`instr_addr-1:0] i_csr_unit_instr,

    //external interrupts
    input  logic                   i_csr_unit_mexternal,             //machine external interrupt
    input  logic                   i_csr_unit_sexternal,
    output logic                   o_csr_unit_ack,                    //acknowlegment
    
    //CSR instructions signals      
    input  logic                    i_csr_unit_csr_wen,               //csr write enable signal
    input  logic  [1:0]             i_csr_unit_op,                    //CSR operation
    input  logic  [`XLEN-1:0]       i_csr_unit_src,
    input  logic  [`csr_addr-1:0]   i_csr_unit_csr_addr,              //csr address
    output logic  [`XLEN-1:0]       o_csr_unit_csr_rdata,             //data read from the csr

    //exception handling signals
    output logic [`XLEN-1:0]        o_csr_unit_irq_handler,           //trap handler address
    output logic [`XLEN-1:0]        o_csr_unit_rtrn_addr,                  //return address
    output logic                    o_csr_unit_addr_ctrl,             //select between mepc and irq_handler
    output logic                    o_csr_unit_mux1,

    //machine mode instructions
    input  logic                   i_csr_unit_mret_wb,
    input  logic                   i_csr_unit_ecall,
    input  logic                   i_csr_unit_ebreak,
    input  logic                   i_csr_unit_sret,     //not connected yet

    //exception signals
    input  logic                   i_csr_unit_illegal_instr_id,   
    input  logic                    i_csr_unit_illegal_instr_exe,       
    input  logic                   i_csr_unit_instr_addr_misaligned,
    input  logic                   i_csr_unit_lw_access_fault,
    input  logic                   i_csr_unit_sw_access_fault,

    //flush signals
    output logic                   o_csr_unit_if_flush,
    output logic                   o_csr_unit_id_flush,
    output logic                   o_csr_unit_exe_flush,
    output logic                   o_csr_unit_mem_flush

);


//machine mode CSR registers
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
logic [`XLEN-1:0] medeleg;
logic [`XLEN-1:0] mideleg;


//supervisor level CSR registers
logic [`XLEN-1:0] sstatus;
logic [`XLEN-1:0] sip;
logic [`XLEN-1:0] sie;
logic [`XLEN-1:0] stvec;
logic [`XLEN-1:0] sepc;
logic [`XLEN-1:0] scause;
logic [`XLEN-1:0] stval;
logic [`XLEN-1:0] satp;                       //to be done
logic [`XLEN-1:0] sscratch;
logic [`XLEN-1:0] stimecmp;


//64-bit counter
logic [`XLEN-1:0] counter;

//intermediate value
logic [`XLEN-1:0] op_result;    //result of CSR operation
logic [1:0] current_mode;     
logic [`XLEN-1:0] tvec;
logic [`XLEN-1:0] cause;



//FSM states
typedef enum logic {idle,setting_up} state;
state current_state;


//trap address modes
logic [`XLEN-1 :0] direct_addr, vector_addr;
logic [`XLEN-1 :0] intrr_addr, expn_addr;       //trap address in vector mode
logic pending_exception;

//flush signals
logic csr_flush_mem;
logic csr_flush_exe;
logic csr_flush_id;
logic csr_flush_if;

//bits in mstatus,sstatus,mie,sie
logic  mstatus_mie;
logic  mstatus_mpie;
logic  mstatus_sie;
logic  mstatus_spie;
logic [1:0] mstatus_mpp;
logic mstatus_spp;
logic sstatus_sie;
logic sstatus_spie;
logic sstatus_spp;
logic mip_meip;
logic mip_mtip;
logic ip_seip;
logic ip_stip;
logic mie_meie;
logic mie_seie;
logic mie_stie;
logic mie_mtie;
logic [47:0] mie_reserved, sie_reserved;
logic sie_seie;
logic sie_stie;



//misa register                          
assign misa = {
    2'b10,                           //MXL=2  XLEN = 64
    36'b0,                           //reserved
    26'b00000001000001000100000101   //RV-IMAC with machine and supervisor modes
};

assign mstatus = {
51'b0,
mstatus_mpp,
2'b0,
mstatus_spp,			
mstatus_mpie,        
1'b0,
mstatus_spie,        
1'b0,
mstatus_mie,            
1'b0,
mstatus_sie,            
1'b0
};

assign sstatus = {
55'b0,
sstatus_spp,
2'b0,
sstatus_spie,
3'b0,
sstatus_sie,
1'b0
};


assign mip = {
52'b0,
mip_meip,
1'b0,
ip_seip,
1'b0,
mip_mtip,
1'b0,
ip_stip,
5'b0
};

assign sip = {
54'b0,
ip_seip,
3'b0,
ip_stip,
5'b0
};

assign sie = {
sie_reserved,
6'b0,
sie_seie,
3'b0,
sie_stie,
5'b0
};

assign mie = {
mie_reserved,
4'b0,
mie_meie,
1'b0,
mie_seie,
1'b0,
mie_mtie,
1'b0,
mie_stie,
5'b0
};


assign satp = 64'b0;


always_comb 
  begin
    case (i_csr_unit_op)

      `CSRRW:      op_result = i_csr_unit_src;
      `CSRRS:      op_result = o_csr_unit_csr_rdata | i_csr_unit_src;
      `CSRRC:      op_result = o_csr_unit_csr_rdata & (~i_csr_unit_src);

      default:     op_result = 64'h0; 

    endcase

  end


/************************output assignment******************************/
always_comb
begin: output_assignment_proc

 if(!i_csr_unit_rst_n)
  o_csr_unit_csr_rdata = 64'b0;
  
   else 
    begin

     case(i_csr_unit_csr_addr)
      

       `csr_mvendorid:    o_csr_unit_csr_rdata = 32'b0;

       `csr_marchid:      o_csr_unit_csr_rdata = 64'b0;

       `csr_mhartid:      o_csr_unit_csr_rdata = 64'b0;

       `csr_mimpid:       o_csr_unit_csr_rdata = 64'b0;

       `csr_misa:         o_csr_unit_csr_rdata = misa;

       `csr_medeleg:      o_csr_unit_csr_rdata = medeleg;

       `csr_mideleg:      o_csr_unit_csr_rdata = mideleg;

       `csr_mstatus:      o_csr_unit_csr_rdata = mstatus;

       `csr_mie:          o_csr_unit_csr_rdata = mie;

       `csr_mip:          o_csr_unit_csr_rdata = mip;

       `csr_mcause:       o_csr_unit_csr_rdata = mcause;

       `csr_mtvec:        o_csr_unit_csr_rdata = mtvec;

       `csr_mepc:         o_csr_unit_csr_rdata = mepc;

       `csr_mtval:        o_csr_unit_csr_rdata = mtval;

       `csr_mtinst:       o_csr_unit_csr_rdata = mtinst;

       `csr_mscratch:     o_csr_unit_csr_rdata = mscratch;

       `csr_time:         o_csr_unit_csr_rdata = counter;

       `csr_cycle:        o_csr_unit_csr_rdata = counter;

       `csr_mtimecmp:     o_csr_unit_csr_rdata = mtimecmp;

       `csr_sstatus:      o_csr_unit_csr_rdata = sstatus;

       `csr_sie:          o_csr_unit_csr_rdata = sie;

       `csr_sip:          o_csr_unit_csr_rdata = sip;

       `csr_scause:       o_csr_unit_csr_rdata = scause;

       `csr_stvec:        o_csr_unit_csr_rdata = stvec;

       `csr_sepc:         o_csr_unit_csr_rdata = sepc;

       `csr_stval:        o_csr_unit_csr_rdata = stval;

       `csr_sscratch:     o_csr_unit_csr_rdata = sscratch;

       `csr_satp:         o_csr_unit_csr_rdata = satp;

       `csr_stimecmp:     o_csr_unit_csr_rdata = stimecmp;

       default:           o_csr_unit_csr_rdata = 64'b0;
      

     endcase

      

    end

end
/***************************end of output assignment***************************/






/***********************************state transition****************************/
always_ff @(posedge i_csr_unit_clk or negedge i_csr_unit_rst_n)
begin:trap_setup_proc


    if (!i_csr_unit_rst_n)
    begin
        current_state <= idle;
        mstatus_mpp <= `m_mode; 
        mstatus_spp <= 1'b0; 
        sstatus_spp <= 1'b0;        
        mcause <= 64'b0;
        mtval  <= 64'b0;
        mtinst <= 64'b0;
        scause <= 64'b0;
        mepc   = 64'b0;
        sepc   = 64'b0;
        stval  <= 64'b0;
    end

    else
    begin
        case (current_state)
           idle:
             begin


                if (i_csr_unit_csr_wen)
                  begin
                    if (i_csr_unit_mret_wb)
                     mstatus_mpp <= 2'b00;

                    else if (i_csr_unit_sret)
                     sstatus_spp <= 1'b0;

                    else if (i_csr_unit_csr_addr == `csr_mstatus)
                     begin
                      mstatus_mpp  <= op_result[12:11];
                      mstatus_spp  <= op_result[8];
                     end

                    else if (i_csr_unit_csr_addr == `csr_sstatus)
                     sstatus_spp  <= op_result[8];


                    else if (i_csr_unit_csr_addr == `csr_mcause)
                      mcause <= op_result;


                    else if (i_csr_unit_csr_addr == `csr_mtval)
                      mtval <= op_result;

                    else if (i_csr_unit_csr_addr == `csr_mtinst)
                      mtinst <= op_result;

                    else if (i_csr_unit_csr_addr == `csr_scause)
                      scause <= op_result;

                    else if (i_csr_unit_csr_addr == `csr_stval)
                      stval <= op_result;
                  end

                
                //external interrupts
                if (mstatus_mie & mie_meie & mip_meip)
                  begin
                    mepc = i_csr_unit_pc;
                    current_state <= setting_up;
                    mtval  <= 64'b0;
                    mtinst <= 64'b0;
                    mcause[63] <= 1'b1;
                    mcause[62:0] <= `m_external_interrupt;
                    o_csr_unit_ack <= 1'b1;
                    mstatus_mpp <= current_mode;
                  end

                
                //timer interrupts
                else if (mstatus_mie & mie_mtie & mip_mtip)
                  begin
                    mepc = i_csr_unit_pc;
                    current_state <= setting_up;
                    mtval  <= 64'b0;
                    mtinst <= 64'b0;
                    mcause[63] <= 1'b1;
                    mcause[62:0] <= `m_timer_interrupt;
                    mstatus_mpp <= current_mode;
                  end


                else if (mstatus_sie & mie_seie & ip_seip)
                  begin
                    current_state <= setting_up;
                      case (current_mode)
                        `m_mode:
                          begin
                              mepc = i_csr_unit_pc;
                              mtval  <= 64'b0;
                              mtinst <= 64'b0;
                              mcause[63] <= 1'b1;
                              mcause[62:0] <= `s_external_interrupt;
                              o_csr_unit_ack <= 1'b1;
                              mstatus_mpp <= `m_mode;
                          end

                        `s_mode:
                          begin
                            if (mideleg[9])
                             begin
                              sepc   = i_csr_unit_pc;
                              stval  <= 64'b0;
                              scause[63] <= 1'b1;
                              scause[62:0] <= `s_external_interrupt;
                              o_csr_unit_ack <= 1'b1;
                              mstatus_spp <= 1'b1;
                              sstatus_spp <= 1'b1;
                             end

                            else
                             begin
                              mepc = i_csr_unit_pc;
                              mtval  <= 64'b0;
                              mtinst <= 64'b0;
                              mcause[63] <= 1'b1;
                              mcause[62:0] <= `s_external_interrupt;
                              o_csr_unit_ack <= 1'b1;
                              mstatus_mpp <= `s_mode;
                             end
                          end
                      endcase
                    
                  end


                else if (mstatus_sie & mie_stie & ip_stip)
                  begin
                    current_state <= setting_up;
                      case (current_mode)
                        `m_mode:
                          begin
                              mepc = i_csr_unit_pc;
                              mtval  <= 64'b0;
                              mtinst <= 64'b0;
                              mcause[63] <= 1'b1;
                              mcause[62:0] <= `s_timer_interrupt;
                              mstatus_mpp <= `m_mode;
                          end

                        `s_mode:
                          begin
                            if (mideleg[5])
                             begin
                              sepc   = i_csr_unit_pc;
                              stval  <= 64'b0;
                              scause[63] <= 1'b1;
                              scause[62:0] <= `s_timer_interrupt;
                              mstatus_spp <= 1'b1;
                              sstatus_spp <= 1'b1;
                             end

                            else
                             begin
                              mepc = i_csr_unit_pc;
                              mtval  <= 64'b0;
                              mtinst <= 64'b0;
                              mcause[63] <= 1'b1;
                              mcause[62:0] <= `s_timer_interrupt;
                              mstatus_mpp <= `s_mode;
                             end
                          end
                      endcase
                    
                  end

               
                //illegal instruction exception
                else if (i_csr_unit_illegal_instr_id || i_csr_unit_illegal_instr_exe)
                  begin
                    current_state <= setting_up;
                      case (current_mode)
                        `m_mode:
                          begin
                              mepc = i_csr_unit_pc;
                              mtval  <= 64'b0;
                              mtinst <= i_csr_unit_instr;
                              mcause[63] <= 1'b0;
                              mcause[62:0] <= `illegal_instr;
                              mstatus_mpp <= `m_mode;
                          end

                        `s_mode:
                          begin
                            if (medeleg[2])
                             begin
                              sepc   = i_csr_unit_pc;
                              stval  <= 64'b0;
                              scause[63] <= 1'b0;
                              scause[62:0] <= `illegal_instr;
                              mstatus_spp <= 1'b1;
                              sstatus_spp <= 1'b1;
                             end

                            else
                             begin
                              mepc = i_csr_unit_pc;
                              mtval  <= 64'b0;
                              mtinst <= i_csr_unit_instr;
                              mcause[63] <= 1'b0;
                              mcause[62:0] <= `illegal_instr;
                              mstatus_mpp <= `s_mode;
                             end
                          end
                      endcase
                    
                  end


                //instruction address misaligned exception
                else if (i_csr_unit_instr_addr_misaligned)
                  begin
                    current_state <= setting_up;
                      case (current_mode)
                        `m_mode:
                          begin
                              mepc = i_csr_unit_pc;
                              mtval  <= 64'b0;
                              mtinst <= i_csr_unit_instr;
                              mcause[63] <= 1'b0;
                              mcause[62:0] <= `instr_addr_misaligned;
                              mstatus_mpp <= `m_mode;
                          end

                        `s_mode:
                          begin
                            if (medeleg[0])
                             begin
                              sepc   = i_csr_unit_pc;
                              stval  <= 64'b0;
                              scause[63] <= 1'b0;
                              scause[62:0] <= `instr_addr_misaligned;
                              mstatus_spp <= 1'b1;
                              sstatus_spp <= 1'b1;
                             end

                            else
                             begin
                              mepc = i_csr_unit_pc;
                              mtval  <= 64'b0;
                              mtinst <= i_csr_unit_instr;
                              mcause[63] <= 1'b0;
                              mcause[62:0] <= `instr_addr_misaligned;
                              mstatus_mpp <= `s_mode;
                             end
                          end
                      endcase
                    
                  end
                  
                

                //ecall instruction generates ecall exception
                else if (i_csr_unit_ecall)
                  begin
                    current_state <= setting_up;
                    mepc = i_csr_unit_pc;
                    mtval  <= 64'b0;
                    mtinst <= i_csr_unit_instr;
                    mcause[63] <= 1'b0;
                    mcause[62:0] <= `ecall;
                    mstatus_mpp <= `m_mode;
                  end
                      
                

                //ebreak instruction generates ebreak exception
                else if (i_csr_unit_ebreak)
                  begin
                    current_state <= setting_up;
                      case (current_mode)
                        `m_mode:
                          begin
                              mepc = i_csr_unit_pc;
                              mtval  <= 64'b0;
                              mtinst <= i_csr_unit_instr;
                              mcause[63] <= 1'b0;
                              mcause[62:0] <= `ebreak;
                              mstatus_mpp <= `m_mode;
                          end

                        `s_mode:
                          begin
                            if (medeleg[3])
                             begin
                              sepc   = i_csr_unit_pc;
                              stval  <= 64'b0;
                              scause[63] <= 1'b0;
                              scause[62:0] <= `ebreak;
                              mstatus_spp <= 1'b1;
                              sstatus_spp <= 1'b1;
                             end

                            else
                             begin
                              mepc = i_csr_unit_pc;
                              mtval  <= 64'b0;
                              mtinst <= i_csr_unit_instr;
                              mcause[63] <= 1'b0;
                              mcause[62:0] <= `ebreak;
                              mstatus_mpp <= `s_mode;
                             end
                          end
                      endcase
                    
                  end


                else if (i_csr_unit_sw_access_fault)
                  begin
                    current_state <= setting_up;
                      case (current_mode)
                        `m_mode:
                          begin
                              mepc = i_csr_unit_pc;
                              mtval  <= i_csr_unit_fault_addr;
                              mtinst <= i_csr_unit_instr;
                              mcause[63] <= 1'b0;
                              mcause[62:0] <= `sw_access_fault;
                              mstatus_mpp <= `m_mode;
                          end

                        `s_mode:
                          begin
                            if (medeleg[7])
                             begin
                              sepc   = i_csr_unit_pc;
                              stval  <= i_csr_unit_fault_addr;
                              scause[63] <= 1'b0;
                              scause[62:0] <= `sw_access_fault;
                              mstatus_spp <= 1'b1;
                              sstatus_spp <= 1'b1;
                             end

                            else
                             begin
                              mepc = i_csr_unit_pc;
                              mtval  <= i_csr_unit_fault_addr;
                              mtinst <= i_csr_unit_instr;
                              mcause[63] <= 1'b0;
                              mcause[62:0] <= `sw_access_fault;
                              mstatus_mpp <= `s_mode;
                             end
                          end
                      endcase
                    
                  end


                else if (i_csr_unit_lw_access_fault)
                  begin
                    current_state <= setting_up;
                      case (current_mode)
                        `m_mode:
                          begin
                              mepc = i_csr_unit_pc;
                              mtval  <= i_csr_unit_fault_addr;
                              mtinst <= i_csr_unit_instr;
                              mcause[63] <= 1'b0;
                              mcause[62:0] <= `lw_access_fault;
                              mstatus_mpp <= `m_mode;
                          end

                        `s_mode:
                          begin
                            if (medeleg[5])
                             begin
                              sepc   = i_csr_unit_pc;
                              stval  <= i_csr_unit_fault_addr;
                              scause[63] <= 1'b0;
                              scause[62:0] <= `lw_access_fault;
                              mstatus_spp <= 1'b1;
                              sstatus_spp <= 1'b1;
                             end

                            else
                             begin
                              mepc = i_csr_unit_pc;
                              mtval  <= i_csr_unit_fault_addr;
                              mtinst <= i_csr_unit_instr;
                              mcause[63] <= 1'b0;
                              mcause[62:0] <= `lw_access_fault;
                              mstatus_mpp <= `s_mode;
                             end
                          end
                      endcase
                    
                  end




             end


           setting_up:
              begin
                current_state <= idle;
                o_csr_unit_ack <= 1'b0;
              end
        endcase
    end

end
/****************************end of state transition*********************/





/****************************CSR assignment**********************************/
always_ff @(posedge i_csr_unit_clk or negedge i_csr_unit_rst_n)
begin: csr_assignment_proc

if (!i_csr_unit_rst_n)
 begin    
    mstatus_sie    <= 1'b0;
    mstatus_mie    <= 1'b0;
    mstatus_spie   <= 1'b0;
    mstatus_mpie   <= 1'b0;
    sstatus_sie    <= 1'b0;
    sstatus_spie   <= 1'b0;
    mie_reserved   <= 48'b0;
    mie_meie       <= 1'b0;
    mie_seie       <= 1'b0;
    mie_stie       <= 1'b0;
    mie_mtie       <= 1'b0;
    medeleg        <= 64'b0;
    mideleg        <= 64'b0;
    sie_reserved   <= 48'b0;
    sie_seie       <= 1'b0;
    sie_stie       <= 1'b0;
    mtvec          <= 64'b0;
    stvec          <= 64'b0;
    mscratch       <= 64'b0;
    mtimecmp       <= 64'b0;
    stimecmp       <= 64'b0;
    sscratch       <= 64'b0;
 end



 else
 begin
    if (i_csr_unit_csr_wen)
    begin 
        if (i_csr_unit_mret_wb)
        begin
            mstatus_mie  <= mstatus_mpie;
            mstatus_mpie <= 1'b1;
        end

        else if (i_csr_unit_sret)
        begin
            sstatus_sie  <= sstatus_spie;
            sstatus_spie <= 1'b1;
        end

        else
        begin
            case (i_csr_unit_csr_addr)
              
              `csr_mstatus:
                 begin
                    mstatus_mie  <= op_result[3];
                    mstatus_mpie <= op_result[7];
                    mstatus_sie  <= op_result[1];
                    mstatus_spie <= op_result[5];
                 end

              `csr_sstatus:
                 begin
                    sstatus_sie  <= op_result[1];
                    sstatus_spie <= op_result[5];
                 end

              `csr_mie:
                 begin
                    mie_meie <= op_result[11];
                    mie_mtie <= op_result[7];
                    mie_seie <= op_result[9];
                    mie_stie <= op_result[5];
                    mie_reserved <= op_result[63:16];
                 end

              `csr_mtvec:
                 begin
                    mtvec <= op_result;
                 end

              `csr_mscratch:
                 begin
                    mscratch <= op_result;
                 end

              `csr_medeleg:
                begin
                  medeleg <= op_result;
                end

              `csr_mideleg:
                begin
                  mideleg <= op_result;
                end

              `csr_mtimecmp:
                 begin
                    mtimecmp <= op_result;
                 end

              `csr_sie:
                 begin
                  sie_seie <= op_result[9];
                  sie_stie <= op_result[5];
                  sie_reserved <= op_result[63:16];
                 end

              `csr_stvec:
                 begin
                    stvec <= op_result;
                 end

              `csr_sscratch:
                 begin
                  sscratch <= op_result;
                 end

              `csr_stimecmp:
                 begin
                  stimecmp <= op_result;
                 end

            endcase
        end
    end



    else
    begin
        case (current_state)
          setting_up:
            begin
                mstatus_mpie <= mstatus_mie;
                mstatus_spie <= mstatus_sie;
                mstatus_mie  <= 1'b0;
                mstatus_sie  <= 1'b0;
                sstatus_spie <= sstatus_sie;
                sstatus_sie  <= 1'b0;
            end
        endcase
    end
 end

end



 always_ff @(posedge i_csr_unit_clk or negedge i_csr_unit_rst_n)
 begin
    if (! i_csr_unit_rst_n)
      begin
        mip_meip <= 1'b0;
        mip_mtip <= 1'b0;
        ip_stip <= 1'b0;
        ip_seip <= 1'b0;
      end

    else

    begin 
      mip_meip <= i_csr_unit_mexternal;
      ip_seip <= i_csr_unit_sexternal;
      mip_mtip <= (counter >= mtimecmp);
      ip_stip <= (counter >= stimecmp);
    end

 end

 /*********************************end of csr assignment*********************************/


 

 /*********************************switching between modes********************************/
 always_comb  
   begin
    current_mode = mstatus_mpp;
    
    if (i_csr_unit_mret_wb)
      current_mode = mstatus_mpp;

    else if (i_csr_unit_sret)
      current_mode = `s_mode;

   end



 /*********************************machine timer******************************************/

 always_ff @(posedge i_csr_unit_clk or negedge i_csr_unit_rst_n)
   begin: timer_proc
     if (! i_csr_unit_rst_n)
   
       counter <= 64'b0;

     else
   
       counter <= counter +1;
   end

/************************************end of timer process**********************************/
   
    


//return address
 always_comb 
   begin
    if (i_csr_unit_mret_wb)
     o_csr_unit_rtrn_addr = mepc;

    else if (i_csr_unit_sret)
     o_csr_unit_rtrn_addr = sepc;
     
    else
     o_csr_unit_rtrn_addr = stvec;
   end


//trap address
always_comb
  begin
    if (mstatus_spp)
     begin
      tvec = stvec;
      cause = scause;
     end

     else
      begin
       tvec = mtvec;
       cause = mcause;
      end
     
  end


 //pending exception
 assign pending_exception = (i_csr_unit_illegal_instr_id | i_csr_unit_illegal_instr_exe | i_csr_unit_instr_addr_misaligned | i_csr_unit_ecall | i_csr_unit_ebreak);


//interrupt handler address
assign o_csr_unit_irq_handler = tvec[0]? vector_addr : direct_addr;
assign direct_addr = tvec;
assign vector_addr = cause[63]? intrr_addr : expn_addr;
assign expn_addr = {tvec[63:1],1'b0};
assign intrr_addr = {tvec[63:1],1'b0} + (cause << 2);

//selector signals
assign o_csr_unit_addr_ctrl = i_csr_unit_mret_wb | i_csr_unit_sret;
assign o_csr_unit_mux1 = ((current_state == setting_up) | i_csr_unit_mret_wb | i_csr_unit_sret);


//flush signals
assign csr_flush_mem = i_csr_unit_lw_access_fault | i_csr_unit_sw_access_fault | ((mstatus_mie | mstatus_sie) & i_csr_unit_mem_wen) | (i_csr_unit_mret_wb | i_csr_unit_sret);
assign csr_flush_exe = csr_flush_mem | i_csr_unit_illegal_instr_exe | i_csr_unit_instr_addr_misaligned | (mstatus_mie | mstatus_sie);
assign csr_flush_id  = csr_flush_exe | pending_exception | (mstatus_mie | mstatus_sie);
assign csr_flush_if  = pending_exception |(current_state == setting_up) | (mstatus_mie) | (mstatus_sie) | (i_csr_unit_mret_wb | i_csr_unit_sret);


assign o_csr_unit_mem_flush = csr_flush_mem;
assign o_csr_unit_exe_flush = csr_flush_exe;
assign o_csr_unit_id_flush  = csr_flush_id;
assign o_csr_unit_if_flush  = csr_flush_if;





endmodule