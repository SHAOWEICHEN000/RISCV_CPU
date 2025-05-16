module fetch(
input clk,
input rst,
input next_pc_select,
input [15:0] pc_target,
output reg [15:0] pc
);
always @(posedge clk) begin
if (rst)begin
pc <= 16'h0000;
end else if (next_pc_select) begin
pc <= pc_target;
end else begin
pc <= pc + 16'h4;
end
end
endmodule
