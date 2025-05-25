`ifndef REGFILE_V
`define REGFILE_V
module regfile(
input clk,
input rst,
input wEn, // Write Enable
input [31:0] write_data,
input [4:0] rs1,
input [4:0] rs2,
input [4:0] rd,
output [31:0] read_data1,
output [31:0] read_data2

);
 reg [31:0]x[0:31];
 assign read_data1 = x[rs1];
assign read_data2 = x[rs2];
integer i;
 always @(posedge clk) begin
 	
 if (rst) begin
    x[0] = 32'b0; // x0 永遠為 0（RISC-V 規範）
    for(i=0;i<32;i++)begin
    x[i]=32'b0;
    end
  end else if (wEn && rd != 5'd0) begin
   x[rd] = write_data;
    
  end


 end
endmodule
`endif
