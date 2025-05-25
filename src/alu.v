`ifndef ALU_V
`define ALU_V
module alu(
    input clk, // Still needed if ALU_result was a reg, but we'll make it combinational
    input [6:0] opcode,
    input [4:0] rs1, // Not directly used in ALU, typically for debug or passed through
    input [4:0] rs2, // Not directly used in ALU, typically for debug or passed through
    input [4:0] rd,  // Not directly used in ALU, typically for debug or passed through
    input [2:0] funct3,
    input [6:0] funct7,
    input [31:0] read_data1, // Operand A
    input [31:0] read_data2, // Operand B (for R-type/branch/store)
    input [31:0] imm32,      // Sign-extended 32-bit immediate
    input [31:0] pc_in,      // 32-bit PC from top module (connect pc32)
    output wire [31:0] ALU_result, // Make this a wire for combinational output
    output wire branch          // Make this a wire for combinational ou000000000tput
);

    // Local Parameters for Opcodes
    localparam [6:0] R_TYPE  = 7'b0110011,
                     I_TYPE  = 7'b0010011,
                     STORE   = 7'b0100011,
                     LOAD    = 7'b0000011,
                     BRANCH  = 7'b1100011,
                     JALR    = 7'b1100111,
                     JAL     = 7'b1101111,
                     AUIPC   = 7'b0010111,
                     LUI     = 7'b0110111;

    // Internal wires for signed operations if needed
    wire signed [31:0] s_op_a = $signed(read_data1);
    wire signed [31:0] s_op_b = $signed(read_data2);

    // Combinational logic for ALU_result
    assign ALU_result =
        // R-Type Instructions
        (opcode == R_TYPE && funct3 == 3'b000 && funct7 == 7'b0000000) ? (s_op_a + s_op_b) : // ADD
        (opcode == R_TYPE && funct3 == 3'b000 && funct7 == 7'b0100000) ? (s_op_a - s_op_b) : // SUB
        (opcode == R_TYPE && funct3 == 3'b001 && funct7 == 7'b0000000) ? (read_data1 << read_data2[4:0]) : // SLL (shamt from rs2)
        (opcode == R_TYPE && funct3 == 3'b010)                         ? ((s_op_a < s_op_b) ? 32'd1 : 32'd0) : // SLT
        (opcode == R_TYPE && funct3 == 3'b011)                         ? ((read_data1 < read_data2) ? 32'd1 : 32'd0) : // SLTU
        (opcode == R_TYPE && funct3 == 3'b100)                         ? (read_data1 ^ read_data2) : // XOR
        (opcode == R_TYPE && funct3 == 3'b101 && funct7 == 7'b0000000) ? (read_data1 >> read_data2[4:0]) : // SRL (shamt from rs2)
        (opcode == R_TYPE && funct3 == 3'b101 && funct7 == 7'b0100000) ? (s_op_a >>> read_data2[4:0]) : // SRA (shamt from rs2)
        (opcode == R_TYPE && funct3 == 3'b110)                         ? (read_data1 | read_data2) : // OR
        (opcode == R_TYPE && funct3 == 3'b111)                         ? (read_data1 & read_data2) : // AND

        // I-Type (ALU operations with immediate)
        (opcode == I_TYPE && funct3 == 3'b000) ? (s_op_a + $signed(imm32)) : // ADDI
        (opcode == I_TYPE && funct3 == 3'b001) ? (read_data1 << imm32[4:0]) : // SLLI (shamt from imm32[4:0])
        (opcode == I_TYPE && funct3 == 3'b010) ? ((s_op_a < $signed(imm32)) ? 32'd1 : 32'd0) : // SLTI
        (opcode == I_TYPE && funct3 == 3'b011) ? ((read_data1 < imm32) ? 32'd1 : 32'd0) : // SLTIU
        (opcode == I_TYPE && funct3 == 3'b100) ? (read_data1 ^ imm32) : // XORI
        (opcode == I_TYPE && funct3 == 3'b101 && funct7 == 7'b0000000) ? (read_data1 >> imm32[4:0]) : // SRLI (shamt from imm32[4:0])
        (opcode == I_TYPE && funct3 == 3'b101 && funct7 == 7'b0100000) ? (s_op_a >>> imm32[4:0]) : // SRAI (shamt from imm32[4:0])
        (opcode == I_TYPE && funct3 == 3'b110) ? (read_data1 | imm32) : // ORI
        (opcode == I_TYPE && funct3 == 3'b111) ? (read_data1 & imm32) : // ANDI

        // Load/Store Address Calculation (always read_data1 + imm32 for effective address)
        (opcode == LOAD  && (funct3 == 3'b000 || funct3 == 3'b001 || funct3 == 3'b010 || funct3 == 3'b100 || funct3 == 3'b101)) ? (read_data1 + imm32) : // LB, LH, LW, LBU, LHU
        (opcode == STORE && (funct3 == 3'b000 || funct3 == 3'b001 || funct3 == 3'b010)) ? (read_data1 + imm32) : // SB, SH, SW

        // JALR Return Address Calculation (and target)
        (opcode == JALR) ? (pc_in + 32'd4) : // JALR's return address to rd (PC + 4 bytes) - *Correction from JALR target*

        // JAL Return Address Calculation
        (opcode == JAL) ? (pc_in + 32'd4) : // JAL's return address to rd (PC + 4 bytes)

        // AUIPC Calculation
        (opcode == AUIPC) ? (pc_in + imm32) : // AUIPC adds PC to U-type immediate

        // LUI Calculation
        (opcode == LUI) ? imm32 : // LUI simply loads U-type immediate

        32'b0; // Default case for ALU_result (important to always assign)

    // Combinational logic for branch condition
    assign branch =
        (opcode == BRANCH && funct3 == 3'b000) ? (read_data1 == read_data2) : // BEQ
        (opcode == BRANCH && funct3 == 3'b001) ? (read_data1 != read_data2) : // BNE
        (opcode == BRANCH && funct3 == 3'b100) ? (s_op_a < s_op_b) :          // BLT
        (opcode == BRANCH && funct3 == 3'b101) ? (s_op_a >= s_op_b) :         // BGE
        (opcode == BRANCH && funct3 == 3'b110) ? (read_data1 < read_data2) :  // BLTU
        (opcode == BRANCH && funct3 == 3'b111) ? (read_data1 >= read_data2) : // BGEU
        1'b0; // Default: No branch (important to always assign)

endmodule
`endif
