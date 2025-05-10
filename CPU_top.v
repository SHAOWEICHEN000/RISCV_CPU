//If wire
wire [31:0]pc;
wire [31:0]i_read_data;
wire next_pc_select;
wire [31:0] pc_target;
//ID wire
//R-type
wire [6:0]opcode;
wire [4:0]rs1;
wire [4:0]rs2;
wire [4:0]rd;
wire [2:0]funct3;
wire [6:0]funct7;
//L type
wire [11:0]imm_i;
//s type
wire [11:0]imm_s;
//B type
wire [11:0]imm_b;
//J-type
wire [20:0] imm_j;
//U type
wire [19:0]imm_u;
wire [31:0] imm32;
wire next_PC_select;
wire wEn;
wire branch_op;
wire [1:0] op_A_sel;
wire [1:0]op_B_sel;
wire [5:0] ALU_Control;
wire mem_wEn;
wire wb_sel;
//regfile wire
wire [31:0] write_data;
assign write_data = (wb_sel == 0) ? ALU_result : read_data;
wire [31:0] read_data1;
wire [31:0] read_data2;
//ALU wire
wire [31:0] ALU_result;
wire branch;
wire [31:0]JALR_target;
//JALR passthrough
assign JALR_target = imm32 + read_data1;

//Data Memory
wire [31:0] read_data;
//IF Module
fetch fetch1(
.clk(clk),
.rst(rst),
.pc(pc),
.next_pc_select(next_pc_select),
.pc_target(pc_target)
);
instruction_memory instruction_memory1(
.clk(clk),
.i_address(pc),
.i_read_data(i_read_data)
);

//ID modulee
decode decode1(
.pc(pc),
.instruction(i_read_data),
.opcode(opcode),
.rd(rd),
.rs1(rs1),
.rs2(rs2),
.funct3(funct3),
.funct7(funct7),
.imm_i(imm_i),
.imm_s(imm_s),
.imm_b(imm_b),
.imm_j(imm_j),
.imm_u(imm_u),
.next_PC_select(next_PC_select),
.wEn(wEn),
.branch_op(branch_op),
.op_A_sel(op_A_sel),
.op_B_sel(op_B_sel),
.ALU_Control( ALU_Control),
.mem_wEn(mem_wEn),
.wb_sel(wb_sel)
);

imm_gen imm_gen1 (
  .instruction(i_read_data),  // 或 decode 給出的 instruction
  .imm32(imm32)
);
// target PC calculation
assign pc_target = 
    (opcode == 7'b1100011) ? (pc + imm32) :       // BEQ/BNE/...
    (opcode == 7'b1101111) ? (pc + imm32) :       // JAL
    (opcode == 7'b1100111) ? JALR_target :        // JALR
    32'b0;
//regfile
regfile regfile(
.clk(clk),
.rst(rst),
.wEn(wEn),
.rs1(rs1),
.rs2(rs2),
.rd(rd),
.write_data(write_data),
.read_data1(read_data1),
.read_data2(read_data2)
);
//ALU
alu alu1(
.opcode(opcode),
.pc(pc),
.clk(clk), 
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
.read_data1(read_data1),
.read_data2(read_data2),
.imm32(imm32),
.ALU_result(ALU_result),
.branch(branch)
);
//Data memory
data_memory data_memory(
.clk(clk),
.mem_wEn(mem_wEn),
.address(ALU_result),
.write_data(write_data),
.read_data(read_data)
);
//show
always @(posedge clk) begin
     $display("=== FETCH ===");
     $display("PC = %h, Instruction = %h", pc, i_read_data);
     $display("=== DECODE ===");
     $display("opcode=%b, rs1=%d, rs2=%d, rd=%d", opcode, rs1, rs2, rd);
     $display("funct3=%b, funct7=%b", funct3, funct7);
     $display("imm_i=%h, imm_s=%h, imm_b=%h, imm_j=%h, imm_u=%h", imm_i, imm_s, imm_b, imm_j, imm_u);
     $display("imm32 = %h", imm32);
     $display("=== WRITEBACK ===");
     $display("WriteData = %h, ToReg = %d, wb_sel = %b", write_data, rd, wb_sel);

end
