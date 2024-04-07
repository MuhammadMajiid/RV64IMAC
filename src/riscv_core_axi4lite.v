module riscv_core_axi4lite 
#
(
    parameter ADDR_WIDTH     = 64,
    parameter AXI_DATA_WIDTH = 64,
    parameter STRB_WIDTH     = $clog2(AXI_DATA_WIDTH)
)
(
    /*
        Global Signals
    */
    input  wire                      axi_clk,
    input  wire                      axi_arstn,
    /*
        Slave Interface
    */
    /*Read Address Channel*/
    input  wire [ADDR_WIDTH-1:0]     saxi_araddr,
    input  wire [2:0]                saxi_arprot,
    input  wire                      saxi_arvalid,
    output reg                       saxi_arready,
    /*Read Data Channel*/
    output reg [AXI_DATA_WIDTH-1:0]  saxi_rdata,
    output reg [1:0]                 saxi_rresp,
    output reg                       saxi_rvalid,
    input  wire                      saxi_rready,
    /*Write Address Channel*/
    input  wire [ADDR_WIDTH-1:0]     saxi_awaddr,
    input  wire [2:0]                saxi_awprot,
    input  wire                      saxi_awvalid,
    output reg                       saxi_awready,
    /*Write Data Channel*/
    input  wire [AXI_DATA_WIDTH-1:0] saxi_wdata,
    input  wire [STRB_WIDTH-1:0]     saxi_wstrb,
    input  wire                      saxi_wvalid,
    output reg                       saxi_wready,
    /*Write Response Channel*/
    input  wire                      saxi_bready,
    output reg                       saxi_bvalid,
    output reg [1:0]                 saxi_bresp,
    /*
        Master Interface
    */
    /*Read Address Channel*/
    output reg [ADDR_WIDTH-1:0]     maxi_araddr,
    output wire [2:0]                maxi_arprot,
    output reg                      maxi_arvalid,
    input  wire                      maxi_arready,
    /*Read Data Channel*/
    input  wire [AXI_DATA_WIDTH-1:0] maxi_rdata,
    input  wire [1:0]                maxi_rresp,
    input  wire                      maxi_rvalid,
    output reg                      maxi_rready,
    /*Write Address Channel*/
    output reg [ADDR_WIDTH-1:0]     maxi_awaddr,
    output wire [2:0]                maxi_awprot,
    output reg                      maxi_awvalid,
    input  wire                      maxi_awready,
    /*Write Data Channel*/
    output reg [AXI_DATA_WIDTH-1:0] maxi_wdata,
    output wire [STRB_WIDTH-1:0]     maxi_wstrb,
    output reg                      maxi_wvalid,
    input  wire                      maxi_wready,
    /*Write Response Channel*/
    output reg                      maxi_bready,
    input  wire                      maxi_bvalid,
    input  wire [1:0]                maxi_bresp
);

/*Protection = 3'b000*/
assign maxi_awprot = saxi_awprot;
assign maxi_arprot = saxi_arprot;
/*Stobe = ONES 'KEEP ALL'*/
assign maxi_wstrb  = saxi_wstrb;
/*Response = 2'b00 'OKAY'*/

/*Read Address Channel Transaction Control*/
always @(posedge axi_clk, negedge axi_arstn) begin : read_address_channel
    if (~axi_arstn) begin
        saxi_arready <= 1'b0;
        maxi_arvalid <= 1'b0;
        maxi_araddr  <= 'b0;
    end
    else if (maxi_arready && saxi_arvalid) begin
        saxi_arready <= 1'b1;
        maxi_arvalid <= saxi_arvalid;
        maxi_araddr  <= saxi_araddr;
    end
    else begin
        saxi_arready <= 1'b0;
        maxi_arvalid <= 1'b0;
    end
end

/*Read Data Channel Transaction Control*/
always @(posedge axi_clk, negedge axi_arstn) begin : read_data_channel
    if (~axi_arstn) begin
        maxi_rready <= 1'b0;
        saxi_rvalid <= 1'b0;
        saxi_rdata  <= 'b0;
    end
    else if (maxi_rvalid && saxi_rready) begin
        maxi_rready <= 1'b1;
        saxi_rvalid <= maxi_rvalid;
        saxi_rdata  <= maxi_rdata;
    end
    else begin
        maxi_rready <= 1'b1;
        saxi_rvalid <= maxi_rvalid;
    end
end

/*Write Address Transaction Control*/
always @(posedge axi_clk, negedge axi_arstn) begin : write_address_channel
    if (~axi_arstn) begin
        saxi_awready <= 1'b0;
        maxi_awvalid <= 1'b0;
        maxi_awaddr  <= 'b0;
    end
    else if (maxi_awready && saxi_awvalid) begin
        saxi_awready <= 1'b1;
        maxi_awvalid <= saxi_awvalid;
        maxi_awaddr  <= saxi_awaddr;
    end
    else begin
        saxi_awready <= 1'b0;
        maxi_awvalid <= 1'b0;
    end
end

/*Write Data Transaction Control*/
always @(posedge axi_clk, negedge axi_arstn) begin : write_data_channel
    if (~axi_arstn) begin
        saxi_wready <= 1'b0;
        maxi_wvalid <= 1'b0;
        maxi_wdata  <= 'b0;
    end
    else if (maxi_wready && saxi_wvalid) begin
        saxi_wready <= 1'b1;
        maxi_wvalid <= saxi_wvalid;
        maxi_wdata  <= saxi_wdata;
    end
    else begin
        saxi_wready <= 1'b0;
        maxi_wvalid <= 1'b0;
    end
end

/*Write Response Transaction Control*/
always @(posedge axi_clk, negedge axi_arstn) begin : write_response_channel
    if (~axi_arstn) begin
        maxi_bready <= 1'b0;
        saxi_bresp  <= 2'b00;
    end
    else if (maxi_bvalid && saxi_bready) begin
        maxi_bready <= saxi_bready;
        saxi_bresp  <= maxi_bresp;
    end
    else begin
        maxi_bready <= 1'b0;
        saxi_bresp  <= 2'b00;
    end
end
endmodule