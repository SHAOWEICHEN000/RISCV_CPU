`ifndef DATA_MEMORY_V
`define DATA_MEMORY_V

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
      #1 $display("address[15:2]  = %h ",address[15:2] );
        @(posedge clk);
      #1 $display("memory[address[15:2]]  = %h (expect 11111111)",memory[address[15:2]] );
    end
    read_data <= memory[address[15:2]];

    end
  end

endmodule

`endif
