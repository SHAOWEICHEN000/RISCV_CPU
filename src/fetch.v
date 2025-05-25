`ifndef FETCH_V
`define FETCH_V
module fetch(
    input clk,
    input rst,
    input next_pc_select,
    input [15:0]pc_target,
    output reg [15:0] pc
);

always @(posedge clk or posedge rst) begin
    if (rst) begin
        pc <= 16'h0000;

    end else if (next_pc_select) begin
        pc <= pc_target;  // ✅ 不要 +4！
    end else begin
        pc <= pc + 16'h4;
        @(posedge clk);
    end
end

endmodule

`endif
