`include "fetch.v"
`include "regfile.v"
`include "instruction_memory.v"
`include "decode.v"
`include "imm_gen.v"
`include "data_memory.v"
`include "alu.v"

module top(input clk, input rst // ✅ 改成 reg
); // Add clk and rst as inputs

    // IF stagez
    wire  [31:0] i_read_data;
    wire [15:0] i_address;
    wire[15:0]pc;
    // ID stage
    wire [6:0] opcode;
    wire [4:0] rs1, rs2, rd;
    wire [2:0] funct3;
    wire [6:0] funct7;
    wire [31:0] imm_i, imm_s, imm_b, imm_j, imm_u, imm32;
    wire wEn, branch_op;
    wire [1:0] op_A_sel, op_B_sel;
    wire [5:0] ALU_Control;
    wire mem_wEn, wb_sel;
    wire [31:0] instruction;    

    // Regfile
    wire [31:0] read_data1;
    wire [31:0] read_data2;

    // ALU
    wire [31:0] ALU_result;
    wire branch;
    // Data Memory
    wire [31:0] data_mem_read_data; // Changed name to avoid conflict
    wire [15:0] data_mem_address;
wire [31:0] data_mem_write_data;
wire [31:0] write_data;
wire [31:0] operand1, operand2;
wire [31:0] regfile_read_data1, regfile_read_data2;

    wire [31:0] read_data;
    //JALR
    wire [31:0] JALR_target;

    // Fetch
    fetch fetch1(
        .clk(clk),
        .rst(rst),
        .next_pc_select(next_pc_select),
        .pc_target(pc_target),
        .pc(pc)     
    );

    // Instruction Memory
    instruction_memory instruction_memory1(
        .clk(clk),
        .i_address(i_address),
        .i_read_data(instruction) // Connect to instruction
    );

    // Decode
    decode decode1(
        .pc(pc),
        .instruction(instruction),
        .opcode(opcode),
        .imm_i(imm_i),
        .imm_s(imm_s),
        .imm_b(imm_b),
        .imm_j(imm_j),
        .imm_u(imm_u),
        .clk(clk),        
        .branch(branch), // Corrected connection
        .next_PC_select(next_pc_select),
        .branch_op(branch_op),
        .op_A_sel(op_A_sel),
        .op_B_sel(op_B_sel),
        .ALU_Control(ALU_Control),
        .mem_wEn(mem_wEn),
        .wb_sel(wb_sel),
        .wEn(wEn),
        .rs1(rs1),
        .rs2(rs2),
        .rd(rd),
        .funct3(funct3),
        .funct7(funct7)
    );

    // Immediate Generator
    imm_gen imm_gen1(
        .clk(clk),
        .instruction(instruction),
        .imm32(imm32)
    );

    // Register File
    regfile regfile1(
        .clk(clk),
        .rst(rst),
        .wEn(wEn),
        .rs1(rs1),
        .rs2(rs2),
        .rd(rd),
        .write_data(write_data),
        .read_data1(regfile_read_data1),
        .read_data2(regfile_read_data2)
    );

    // ALU
    alu alu1(
        .clk(clk),
        .opcode(opcode),
        .rs1(rs1),
        .rs2(rs2),
        .rd(rd),
        .funct3(funct3),
        .funct7(funct7),
        .imm_i(imm_i),  // Connect immediates
        .imm_s(imm_s),
        .imm_b(imm_b),
        .imm_j(imm_j),
        .imm_u(imm_u),
        .read_data1(operand1),
        .read_data2(operand2),
        .imm32(imm32),
        .ALU_result(ALU_result),
        .branch(branch)
    );

    // Data Memory
    data_memory data_memory1(
        .clk(clk),
        .rst(rst),
        .mem_wEn(mem_wEn),
        .address(data_mem_address), // Connect address
        .write_data(data_mem_write_data), // Connect write data
        .read_data(data_mem_read_data)
    );

    // PC Target Calculation
    assign pc_target =
        (opcode == 7'b1100011) ? (pc + imm32) :         // BEQ/BNE/...
        (opcode == 7'b1101111) ? (pc + imm32) :         // JAL
        (opcode == 7'b1100111) ? JALR_target :         // JALR
        pc + 4; // Default: PC + 4

    assign JALR_target = read_data1 + imm32;

    // Writeback MUX
    assign write_data = (wb_sel == 0) ? ALU_result : data_mem_read_data; // Corrected

    // Operand Select MUXes
     assign operand1 = (op_A_sel == 2'b00) ? regfile_read_data1 :
                  (op_A_sel == 2'b01) ? pc :
                  (op_A_sel == 2'b10) ? (pc + 4) :
                  32'b0;

    assign operand2 = (op_B_sel == 2'b00) ? regfile_read_data2 : imm32;
    
    // Data memory address assignment
    assign data_mem_address = ALU_result[15:0];  // Connect ALU result to data memory address for store/load
    assign data_mem_write_data =operand2; //connect read_data2 to data_memory write_data


    // Debug Display
    always @(posedge clk) begin
        $display("=== FETCH ===");
        $display("PC = %h, Instruction = %h", pc, instruction); // Use instruction
        $display("=== DECODE ===");
        $display("opcode=%b, rs1=%d, rs2=%d, rd=%d", opcode, rs1, rs2, rd);
        $display("funct3=%b, funct7=%b", funct3, funct7);
        $display("imm32 = %h", imm32);
        $display("=== ALU ===");
        $display("ALU_result = %h, branch = %b", ALU_result, branch);
        $display("=== WRITEBACK ===");
        $display("WriteData = %h, ToReg = %d, wb_sel = %b", write_data, rd, wb_sel);
         $display("=== DATA MEMORY ===");
        $display("Data Memory Address = %h, Data Memory Write Data = %h, Data Memory Read Data = %h", data_mem_address, data_mem_write_data, data_mem_read_data);
    end



    assign i_address = pc; // Connect i_address

endmodule
