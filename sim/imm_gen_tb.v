`include "imm_gen.v"

module imm_gen_tb;
  reg clk;
  reg [31:0] instruction;
  wire [31:0] imm32;

  // 單元模組
  imm_gen imm_gen(
    .clk(clk),
    .instruction(instruction),
    .imm32(imm32)
  );

  // 時脈產生器
  initial begin
    clk = 0;
    forever #5 clk = ~clk;
  end

  // 測試流程
  initial begin
    $display("=============JALR Test===================");
    instruction = 32'b111111111111_00010_000_00001_1100111;

    #1 $display("Instruction = %b", instruction);
    #1 $display("JALR: imm32 = %h (expect FFFFFFFF or signed -1)", imm32);
    $display("=============S Test===================");
    instruction = 32'b010001111111_00010_000_00001_1100111;

    #1 $display("Instruction = %b", instruction);
    #1 $display("S: imm32 = %h (expect 0000047f or signed -1)", imm32);
    $display("=============B Test===================");
    instruction = 32'b110001111111_00010_000_00001_1100111;

    #1 $display("Instruction = %b", instruction);
    #1 $display("B: imm32 = %h (expect fffffc7f or signed -1)", imm32);
    $display("=============U Test===================");
    instruction = 32'b011011111111_00010_000_00001_1100111;

    #1 $display("Instruction = %b", instruction);
    #1 $display("LUI: imm32 = %h (expect 000006ff or signed -1)", imm32);
     instruction = 32'b001011111111_00010_000_00001_1100111;

    #1 $display("Instruction = %b", instruction);
    #1 $display("AUIPC: imm32 = %h (expect 000002ff or signed -1)", imm32);
        $display("=============J Test===================");
    instruction = 32'b110111111111_00010_000_00001_1100111;

    #1 $display("Instruction = %b", instruction);
    #1 $display("JAL: imm32 = %h (expect FFFFFDFF or signed -1)", imm32);
    $finish;
  end
endmodule
