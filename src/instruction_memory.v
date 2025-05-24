`ifndef INSTRUCTION_MEMORY_V
`define INSTRUCTION_MEMORY_V
module instruction_memory(
input clk,
input [15:0] i_address,
output reg [31:0] i_read_data

);
localparam RAM_DEPTH = 1 << 16;
reg [31:0]memory[0:RAM_DEPTH];
always @(posedge clk)begin
i_read_data <= memory[i_address[15:2]]; // rm low bits（ 4 bytes in each instruction）
end

initial begin
    $readmemh("program.hex", memory);  // c code compile hex file
end

endmodule
`endif
