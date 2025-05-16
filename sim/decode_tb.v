module decode_tb;
reg clk;
reg [15:0] pc;
reg [31:0] instruction;
reg branch;
wire [6:0] opcode;
wire [4:0] rs1, rs2, rd;
wire [2:0] funct3;
wire [6:0] funct7;
wire [11:0] imm_i, imm_s, imm_b;
wire [20:0] imm_j;
wire [19:0] imm_u;
wire next_PC_select, wEn, branch_op;
wire [1:0] op_A_sel, op_B_sel;
wire [5:0] ALU_Control;
wire mem_wEn, wb_sel;
decode dut(
.clk(clk),
.pc(pc),
.instruction(instruction),
.opcode(opcode),
.rs1(rs1),
.rs2(rs2),
.rd(rd),
.funct3(funct3),
.funct7(funct7),
.imm_i(imm_i),
.imm_s(imm_s),
.imm_b(imm_b),
.imm_j(imm_j),
.imm_u(imm_u),
.next_PC_select(next_PC_select),
.wEn(wEn),
.branch(branch),
.branch_op(branch_op),
.op_A_sel(op_A_sel),
.op_B_sel(op_B_sel),
.ALU_Control(ALU_Control),
.mem_wEn(mem_wEn),
.wb_sel(wb_sel)
);
initial begin
clk = 0;
forever #5 clk = ~clk;
end
initial begin
$display("==== DECODE TEST ====");
pc = 0;
branch = 0;
// R-type: ADD x1, x2, x3
instruction = 32'b0000000_00011_00010_000_00001_0110011;
@(posedge clk); #1;
$display("R-type ADD: rd=%d rs1=%d rs2=%d ALU_Control=%b", rd, rs1, rs2, ALU_Control);
// I-type: ADDI x1, x2, 5
instruction = 32'b000000000101_00010_000_00001_0010011;
@(posedge clk); #1;
$display("I-type ADDI: rd=%d rs1=%d imm_i=%d ALU_Control=%b", rd, rs1, imm_i, ALU_Control);
// S-type: SW x3, 8(x2)
instruction = 32'b0000000_00011_00010_010_01000_0100011;
@(posedge clk); #1;
$display("S-type SW: rs1=%d rs2=%d imm_s=%d mem_wEn=%b", rs1, rs2, imm_s, mem_wEn);
// B-type: BEQ x2, x3, offset
instruction = 32'b0000000_00011_00010_000_00010_1100011;
branch = 1;
@(posedge clk); #1;
$display("B-type BEQ: rs1=%d rs2=%d imm_b=%d next_PC_select=%b", rs1, rs2, imm_b, next_PC_select);
// U-type: LUI x1, 0x12345
instruction = 32'b00010010001101000101_00001_0110111;
@(posedge clk); #1;
$display("U-type LUI: rd=%d imm_u=%h", rd, imm_u);
// J-type: JAL x1, offset
instruction = 32'b00000000000100000000_00001_1101111;
@(posedge clk); #1;
$display("J-type JAL: rd=%d imm_j=%h", rd, imm_j);
$finish;
end
endmodule
