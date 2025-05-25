`ifndef IMM_GEN_V
`define IMM_GEN_V

module imm_gen(
  input clk,
  input  [31:0] instruction,
  output reg [31:0] imm32
);

  wire [6:0] opcode = instruction[6:0];

  always @(posedge clk) begin
    case (opcode)
      // I-type (e.g. addi, lw, jalr)
      7'b0010011:imm32 = {{20{instruction[31]}}, instruction[31:20]};// addi
      
      7'b0000011:imm32 = {{20{instruction[31]}}, instruction[31:20]};// lw
      7'b1100111: // jalr
        imm32 = {{20{instruction[31]}}, instruction[31:20]};

      // S-type (e.g. sw)
      7'b0100011: 
        imm32 = {{20{instruction[31]}}, instruction[31:25], instruction[11:7]};

      // B-type (e.g. beq, bne, blt, bge)
      7'b1100011: begin // B-type
           imm32 = {{20{instruction[31]}},         // sign extend from imm[12]
           instruction[7],                // imm[11]
           instruction[30:25],            // imm[10:5]
           instruction[11:8],             // imm[4:1]
           1'b0};                         // LSB is always 0 (word-aligned)
      end



      // U-type (e.g. lui, auipc)
      7'b0110111, // lui
      7'b0010111: // auipc
        imm32 = {instruction[31:12], 12'b0};

      // J-type (e.g. jal)
      7'b1101111: 
        imm32 = {{11{instruction[31]}}, instruction[31], instruction[19:12], instruction[20], instruction[30:21], 1'b0};

      // Default case
      default:
        imm32 = 32'b0;
    endcase
  end

endmodule

`endif
