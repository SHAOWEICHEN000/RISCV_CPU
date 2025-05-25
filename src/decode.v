`ifndef DECODE_V
`define DECODE_V
module decode(
    input [15:0] pc, // PC is passed for debug or specific instruction calculations (e.g., AUIPC)
    input [31:0] instruction,
    // Control input from ALU for branch condition
    input branch, // <--- 恢復 branch 輸入

    // R-type instruction fields
    output reg [6:0] opcode,
    output reg [4:0] rs1,
    output reg [4:0] rs2,
    output reg [4:0] rd,
    output reg [2:0] funct3,
    output reg [6:0] funct7,

    // Immediate fields (raw bits, imm_gen will handle sign extension)
    output reg [11:0] imm_i,
    output reg [11:0] imm_s,
    output reg [11:0] imm_b,
    output reg [20:0] imm_j,
    output reg [19:0] imm_u,

    // Control signals for pipeline stages
    output reg next_PC_select, // <--- 恢復 next_PC_select 輸出
    output reg wEn,            // Write Enable for Register File
    output reg branch_op,      // Tells ALU if this is a branch instruction
    output reg [1:0] op_A_sel, // ALU Operand A selection
    output reg [1:0] op_B_sel, // ALU Operand B selection
    output reg [5:0] ALU_Control, // ALU operation type
    input clk,                 // Clock for sequential logic
    output reg mem_wEn,        // Write Enable for Data Memory
    output reg wb_sel         // Writeback data selection (ALU result or Mem read data)
);

    // Local parameters for RISC-V opcodes
    localparam [6:0] R_TYPE  = 7'b0110011,
                     I_TYPE  = 7'b0010011,
                     STORE   = 7'b0100011,
                     LOAD    = 7'b0000011,
                     BRANCH  = 7'b1100011, // <--- 恢復為 BRANCH
                     JALR    = 7'b1100111,
                     JAL     = 7'b1101111,
                     AUIPC   = 7'b0010111,
                     LUI     = 7'b0110111;

    always @(posedge clk) begin
        // --- 1. 初始化所有輸出為安全預設值 (非阻塞賦值) ---
        opcode         <= 7'b0;
        rs1            <= 5'b0;
        rs2            <= 5'b0;
        rd             <= 5'b0;
        funct3         <= 3'b0;
        funct7         <= 7'b0;
        imm_i          <= 12'b0;
        imm_s          <= 12'b0;
        imm_b          <= 12'b0;
        imm_j          <= 21'b0;
        imm_u          <= 20'b0;

        // 控制訊號預設值
        next_PC_select <= 1'b0; // 預設為順序執行
        wEn            <= 1'b0; // 預設不寫入暫存器
        branch_op      <= 1'b0; // 預設不是分支指令
        op_A_sel       <= 2'b00; // 預設 ALU 操作數來自 rs1
        op_B_sel       <= 2'b00; // 預設 ALU 操作數來自 rs2
        ALU_Control    <= 6'b000000; // 預設 ALU 控制為 NOP 或 ADD
        mem_wEn        <= 1'b0; // 預設不寫入記憶體
        wb_sel         <= 1'b0; // 預設回寫 ALU 結果

        // --- 2. 根據指令 opcode 進行解碼和控制訊號生成 (使用 case 語句更清晰) ---
        case (instruction[6:0]) // <--- 這裡使用 instruction[6:0] 來判斷當前指令
            R_TYPE: begin // R-type instructions (ADD, SUB, SLL, SLT, XOR, SRL, OR, AND)
                opcode   <= instruction[6:0];
                rd       <= instruction[11:7];
                funct3   <= instruction[14:12];
                rs1      <= instruction[19:15];
                rs2      <= instruction[24:20];
                funct7   <= instruction[31:25];

                // Control signals for R-type
                wEn      <= 1'b1;  // Write to register file
                op_A_sel <= 2'b00; // Operand A from rs1
                op_B_sel <= 2'b00; // Operand B from rs2
                wb_sel   <= 1'b0;  // Write ALU result back
               
            end

            I_TYPE: begin // I-type ALU operations (ADDI, SLTI, XORI, ORI, ANDI, SLLI, SRLI, SRAI)
                opcode   <= instruction[6:0];
                rd       <= instruction[11:7];
                funct3   <= instruction[14:12];
                rs1      <= instruction[19:15];
                imm_i    <= instruction[31:20]; // Raw immediate bits

                // Control signals for I-type ALU ops
                wEn      <= 1'b1;  // Write to register file
                op_A_sel <= 2'b00; // Operand A from rs1
                op_B_sel <= 2'b01; // Operand B from immediate (imm32)
                wb_sel   <= 1'b0;  // Write ALU result back
                // ALU_Control based on funct3/funct7, similar to R-type
            end

            LOAD: begin // Load instructions (LB, LH, LW, LBU, LHU)
                opcode   <= instruction[6:0];
                rd       <= instruction[11:7];
                funct3   <= instruction[14:12];
                rs1      <= instruction[19:15];
                imm_i    <= instruction[31:20]; // Raw immediate bits

                // Control signals for Load
                wEn      <= 1'b1;  // Write to register file
                mem_wEn  <= 1'b0;  // Do not write to data memory (it's a load)
                op_A_sel <= 2'b00; // Operand A from rs1 (for address calculation)
                op_B_sel <= 2'b01; // Operand B from immediate (imm32 for address calculation)
                wb_sel   <= 1'b1;  // Write data from memory back to regfile
                ALU_Control <= 6'b000000; // ALU performs ADD for address calculation
            end

            STORE: begin // Store instructions (SB, SH, SW)
                opcode   <= instruction[6:0];
                funct3   <= instruction[14:12];
                rs1      <= instruction[19:15];
                rs2      <= instruction[24:20];
                imm_s    <= {instruction[31:25], instruction[11:7]}; // Raw immediate bits

                // Control signals for Store
                wEn      <= 1'b0;  // Do not write to register file
                mem_wEn  <= 1'b1;  // Write to data memory
                op_A_sel <= 2'b00; // Operand A from rs1 (for address calculation)
                op_B_sel <= 2'b01; // Operand B from immediate (imm32 for address calculation)
                wb_sel   <= 1'b0;  // No writeback to regfile
                ALU_Control <= 6'b000000; // ALU performs ADD for address calculation
            end

            BRANCH: begin // Branch instructions (BEQ, BNE, BLT, BGE, BLTU, BGEU)
                opcode   <= instruction[6:0];
                rs1      <= instruction[19:15];
                rs2      <= instruction[24:20];
                funct3   <= instruction[14:12];
                imm_b    <= {instruction[31], instruction[7], instruction[30:25], instruction[11:8]}; // Raw immediate bits

                // Control signals for Branch
                wEn      <= 1'b0;  // Do not write to register file
                branch_op <= 1'b1; // This is a branch instruction
                mem_wEn  <= 1'b0;
                op_A_sel <= 2'b00; // Operands from rs1/rs2 for ALU comparison
                op_B_sel <= 2'b00;
                wb_sel   <= 1'b0;
                // next_PC_select depends on 'branch' input from ALU
                if (branch) begin // If ALU's branch output is true
                    next_PC_select <= 1'b1; // Take the branch
                end else begin
                    next_PC_select <= 1'b0; // Don't take the branch (fall through)
                end
                // ALU_Control for branch comparison is set in ALU based on funct3
            end

            JALR: begin // Jump and Link Register
                opcode   <= instruction[6:0];
                rd       <= instruction[11:7];
                funct3   <= instruction[14:12]; // Should be 000 for JALR
                rs1      <= instruction[19:15];
                imm_i    <= instruction[31:20]; // Raw immediate bits

                // Control signals for JALR
                next_PC_select <= 1'b1;  // Always jump
                wEn            <= 1'b1;  // Write return address to rd
                branch_op      <= 1'b0;
                mem_wEn        <= 1'b0;
                op_A_sel       <= 2'b10; // Operand A for ALU is PC + 4 (return address)
                op_B_sel       <= 2'b00; // Not used for ALU result calculation, but for PC target
                wb_sel         <= 1'b0;  // Write ALU result (PC+4) back
                ALU_Control    <= 6'b000000; // ALU performs ADD for target (rs1 + imm)
            end

            JAL: begin // Jump and Link
                opcode   <= instruction[6:0];
                rd       <= instruction[11:7];
                imm_j    <= {instruction[31], instruction[19:12], instruction[20], instruction[30:21], 1'b0}; // Raw immediate bits

                // Control signals for JAL
                next_PC_select <= 1'b1;  // Always jump
                wEn            <= 1'b1;  // Write return address to rd
                branch_op      <= 1'b0;
                mem_wEn        <= 1'b0;
                op_A_sel       <= 2'b10; // Operand A for ALU is PC + 4 (return address)
                op_B_sel       <= 2'b00; // Not used for ALU result calculation, but for PC target
                wb_sel         <= 1'b0;  // Write ALU result (PC+4) back
                ALU_Control    <= 6'b000000; // ALU performs ADD for target (PC + imm)
            end

            AUIPC: begin // Add Upper Immediate to PC
                opcode   <= instruction[6:0];
                rd       <= instruction[11:7];
                imm_u    <= instruction[31:12]; // Raw immediate bits

                // Control signals for AUIPC
                wEn      <= 1'b1;  // Write to register file
                op_A_sel <= 2'b01; // Operand A is PC
                op_B_sel <= 2'b01; // Operand B is immediate (imm32)
                wb_sel   <= 1'b0;  // Write ALU result back
                ALU_Control <= 6'b000000; // ALU performs ADD
            end

            LUI: begin // Load Upper Immediate
                opcode   <= instruction[6:0];
                rd       <= instruction[11:7];
                imm_u    <= instruction[31:12]; // Raw immediate bits

                // Control signals for LUI
                wEn      <= 1'b1;  // Write to register file
                op_A_sel <= 2'b11; // Operand A is hardcoded zero (or don't care if ALU handles LUI directly)
                op_B_sel <= 2'b01; // Operand B is immediate (imm32)
                wb_sel   <= 1'b0;  // Write ALU result back
                ALU_Control <= 6'b000000; // ALU performs ADD (0 + imm_u)
            end

            default: begin // Default case for unsupported or invalid opcodes
                // All outputs remain at their initialized safe default values (0 or 1'b0)
                // No specific action needed here, as they are already set at the top of the block.
                // This ensures all outputs are well-defined even for unknown instructions.
            end
        endcase
    end
endmodule
`endif
