module alu_tb;
reg clk;
reg [6:0] opcode;
reg [4:0] rs1, rs2, rd;
reg [2:0] funct3;
reg [6:0] funct7;
reg [11:0] imm_i, imm_s, imm_b;
reg [20:0] imm_j;
reg [19:0] imm_u;
reg [31:0] read_data1, read_data2;
reg [31:0] imm32;
reg [15:0] pc;
wire [31:0] ALU_result;
wire branch;
alu uut (
.clk(clk),
.opcode(opcode),
.rs1(rs1),
.rs2(rs2),
.pc(pc),
.rd(rd),
.funct3(funct3),
.funct7(funct7),
.imm_i(imm_i),
.imm_s(imm_s),
.imm_b(imm_b),
.imm_j(imm_j),
.imm_u(imm_u),
.read_data1(read_data1),
.read_data2(read_data2),
.imm32(imm32),
.ALU_result(ALU_result),
.branch(branch)
);
initial begin
clk = 0;
forever #5 clk = ~clk;
end
initial begin
$display("=============R-TYPE ===================");
opcode = 7'b0110011; // R-type
funct3 = 3'b000; // ADD
funct7 = 7'b0000000;
read_data1 = 32'd10;
read_data2 = 32'd5;
#10;
$display("ADD: %d + %d = %d (expect 15)", read_data1, read_data2, ALU_result);
opcode = 7'b0110011; // R-type
funct3 = 3'b010; // SLT
read_data1 = 32'd10;
read_data2 = 32'd20;
#10;
$display("SLT: %d < %d = %d (expect 1)", read_data1, read_data2, ALU_result);
opcode = 7'b0110011; // R-type
funct3 = 3'b010; // SLT
read_data1 = 32'd30;
read_data2 = 32'd20;
#10;
$display("SLT: %d < %d = %d (expect 0)", read_data1, read_data2, ALU_result);
opcode = 7'b0110011; // R-type
funct3 = 3'b001; // Sll
funct7 =  7'b0000000; // Sll
read_data1 = 32'd10;
imm32= 32'd2;
#10;
$display("SLT: %d << %d = %d (expect 40)", read_data1, imm32, ALU_result);
$display("=============I-TYPE ===================");
opcode = 7'b0010011; // I-type
funct3 = 3'b000; // ADDI
imm_i = 12'd20;
read_data1 = 32'd10;
#10;
$display("ADDI: %d + %d = %d (expect 30)", read_data1, imm_i, ALU_result);
opcode = 7'b0010011; // I-type
funct3 = 3'b100; // XORI
imm_i = 12'd2;
read_data1 = 32'd10;
#10;
$display("XORI: %d ^ %d = %d (expect 8)", read_data1, imm_i, ALU_result);
opcode = 7'b0010011; // I-type
funct3 = 3'b101; // Srli
funct7 =  7'b0000000; // Srli
read_data1 = 32'd10;
imm32= 32'd2;
#10;
$display("SRLI: %d >> %d = %d (expect 2)", read_data1, imm32, ALU_result);
opcode = 7'b0010011; // I-type
funct3 = 3'b111; // ANDI
imm_i = 12'd20;
read_data1 = 32'd10;
#10;
$display("ANDI: %d & %d = %d (expect 0)", read_data1, imm_i, ALU_result);
$display("=============l-TYPE ===================");
opcode     = 7'b0000011;     // I-type: LOAD
funct3     = 3'b010;         // lw
read_data1 = 32'd100;        // base register (ex: x1 = 100)
imm32      = 32'd12;         // offset
#10;
$display("LW Address: %d + %d = %d (expect 112)", read_data1, imm32, ALU_result);
$display("=============s-TYPE ===================");
opcode     = 7'b0100011;     // s-type: LOAD
funct3     = 3'b010;         // sw
read_data1 = 32'd100;        // base register (ex: x1 = 100)
imm32      = 32'd12;         // offset
#10;
$display("SW Address: %d + %d = %d (expect 112)", read_data1, imm32, ALU_result);
$display("=============branch ===================");
opcode     =7'b1100011;    // B-type: 
funct3     = 3'b000;         // BEQ
read_data1 = 32'd100;        // base register (ex: x1 = 100)
read_data2 = 32'd100;         // offset
#10;
$display("BEQ	: %d + %d = %d (expect 1)", read_data1,read_data2, branch);
opcode     =7'b1100011;    // B-type: 
funct3     = 3'b000;         // BEQ
read_data1 = 32'd100;        // base register (ex: x1 = 100)
read_data2 = 32'd10;         // offset
#10;
$display("BEQ	: %d + %d = %d (expect 0)", read_data1,read_data2, branch);
$display("=============JAL ===================");
opcode     =7'b1101111;    // J-type: 
pc= 32'd100;        // base register (ex: x1 = 100)
#10;
$display("JAL	: PC= %d (expect 104)",  ALU_result); 
$finish;
end
endmodule
