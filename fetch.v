	`ifndef FETCH_V
	`define FETCH_V
	module fetch(
	input clk,
	input rst,
	input next_pc_select,     //select jump
	output [31:0]pc,
	input [31:0]pc_target	  //jump address
	//in the future need to expand to stall,flush
	//stall:	pause pipeline forward		data hazard, wait memory
	//flush:	flush pipeline data		jump error prediction
	);
	reg [31:0]pc_fetch;
	assign pc=pc_fetch;
	always @(posedge clk)begin
		if(rst)
			pc_fetch<=0;
		else if(next_pc_select)
			pc_fetch<=pc_target;
		else if(pc_target)
			pc_fetch<=pc_fetch+4;
	end
	endmodule
	`endif
