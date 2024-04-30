//--------------------------module instantiation--------------------------
/*
riscv_core_rf
u_riscv_core_rf
(
	.i_rf_clk	()
	,.i_rf_we3  ()
	,.i_rf_a1   ()
	,.i_rf_a2   ()
	,.i_rf_a3   ()
	,.i_rf_wd3  ()
	,.o_rf_rd1  ()
	,.o_rf_rd2  ()
);
*/
module riscv_core_rf (         
	input logic i_rf_clk,
	input logic i_rf_we3,
	input logic [4:0] i_rf_a1,i_rf_a2,i_rf_a3,
	input logic [63:0] i_rf_wd3,
	output logic [63:0] o_rf_rd1, o_rf_rd2
	);
	logic [63:0] rf[31:0]; 	
	always_ff @(negedge i_rf_clk) begin  //write
		if ((i_rf_we3)&&(!(i_rf_a3==0))) rf[i_rf_a3] <= i_rf_wd3; 
	end
	//read
	assign o_rf_rd1 = (i_rf_a1 != 0 ) ? rf[i_rf_a1] : 0;
	assign o_rf_rd2 = (i_rf_a2 != 0 ) ? rf[i_rf_a2] : 0;
endmodule