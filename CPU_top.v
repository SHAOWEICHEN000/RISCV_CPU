`include"fetch.v"
`include"regfile.v"
`include"instruction_memory.v"
`include"decode.v"
`include"imm_gen.v"
`include"data_memory"
`include"alu.v"

//If wire
reg  clk;
reg  rst;
reg  next_pc_select;     //select jump
wire [15:0]pc;
reg [15:0]pc_target;	  //jump address
reg [15:0] i_address;
wire [31:0] i_read_data;
//ID wire

  wire wEn, branch_op;
  wire [1:0] op_A_sel, op_B_sel;
  wire [5:0] ALU_Control;
  wire mem_wEn, wb_sel;
//regfile wire

reg [4:0] rs1, rs2, rd;
reg [31:0] write_data;
wire [31:0] read_data1, read_data2;

//ALU wire
  reg [6:0] opcode;
  reg [2:0] funct3;
  reg [6:0] funct7;
  reg [11:0] imm_i, imm_s, imm_b;
  reg [20:0] imm_j;
  reg [19:0] imm_u;
  reg [31:0] imm32;
  wire [31:0] ALU_result;
  wire branch;
  reg [31:0] instruction;


//Data Memory
reg [15:0]address;
reg [31:0]write_data;
wire [31:0] read_data;
//IF Module
fetch fetch1(
	.clk(clk),
	.rst(rst),
	.next_pc_select(next_pc_select),
	.pc(pc),
	.pc_target(pc_target)
);
instruction_memory instruction_memory1(
 	.clk(clk),
    	.i_address(i_address),
    	.i_read_data(i_read_data)
);

//ID modulee
decode decode1(

);

imm_gen imm_gen1 (
    .clk(clk),
    .instruction(instruction),
    .imm32(imm32)
);
// target PC calculation
assign pc_target = 
    (opcode == 7'b1100011) ? (pc + imm32) :       // BEQ/BNE/...
    (opcode == 7'b1101111) ? (pc + imm32) :       // JAL
    (opcode == 7'b1100111) ? JALR_target :        // JALR
    32'b0;
 //Muxes
assign write_data = (wb_sel == 0) ? ALU_result : read_data;
	
	assign read_data1= (op_A_sel == 2'b00) ? read_data1:
							 (op_A_sel == 2'b01) ? PC:
							 (op_A_sel == 2'b10) ? (PC + 16'd4):
							 (0);
							 
	assign read_data2= (op_B_sel) ? imm32:read_data2;
							 

	assign wb_data = write_data;
	
	//Read_select2 mux 
	assign read_sel2_mux = (instruction[6:0] == 7'b1100111 && instruction[14:12] == 3'b000) ? 0 : read_sel2;   
	//JALR passthrough
assign JALR_target = imm32 + read_data1;
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
//Data memory
data_memory data_memory(
.clk(clk),
.rst(rst),
.mem_wEn(mem_wEn),
.address(address),
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
