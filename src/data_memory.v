module data_memory(
input clk,
input mem_wEn,
input rst,
input [15:0] address,
input [31:0] write_data,
output reg[31:0] read_data
);
localparam RAM_DEPTH = 1 << 16;
reg [31:0] memory[0:RAM_DEPTH - 1];
always @(posedge clk) begin
if(rst) begin
if (mem_wEn) begin 
memory[address[15:2]] <= write_data; // word-aligned
@(posedge clk);
end
read_data <= memory[address[15:2]];
end
end
endmodule

