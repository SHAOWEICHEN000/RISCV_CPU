`include "fetch.v"
`include "regfile.v"
`include "instruction_memory.v"
`include "decode.v"
`include "imm_gen.v"
`include "data_memory.v"
`include "alu.v"

module top(input clk, input rst); // Removed incorrect comment

    // IF stage signals
    wire [15:0] pc;        // Current Program Counter (byte address)
    wire [15:0] i_address; // Address for instruction memory (connected to pc)
    wire [31:0] instruction; // Fetched instruction
    // ID stage signals
    wire [6:0] opcode;
    wire [4:0] rs1, rs2, rd;
    wire [2:0] funct3;
    wire [6:0] funct7;
    wire [11:0] imm_i;
    wire [11:0] imm_s;
    wire [11:0] imm_b;
    wire [20:0] imm_j;
    wire [19:0] imm_u;
    wire [31:0] imm32; // Sign-extended immediate from imm_gen
    wire wEn, branch_op;
    wire [1:0] op_A_sel, op_B_sel;
    wire [5:0] ALU_Control;
    wire mem_wEn, wb_sel;
    wire next_pc_select; // Control signal from decode to fetch

    // Regfile signals
    wire [31:0] regfile_read_data1;
    wire [31:0] regfile_read_data2;
    reg [31:0] write_data; // Data to write back to regfile (MUST be reg)

    // ALU signals
    wire [31:0] ALU_result;
    wire branch; // ALU's branch condition output (combinational)

    // Data Memory signals
    wire [31:0] data_mem_read_data;
    wire [15:0] data_mem_address; // 16-bit byte address for data memory
    wire [31:0] data_mem_write_data;

    // 32-bit PC variants for ALU and JALR calculations
    wire [31:0] pc32   = {16'b0, pc};      // Zero-extend 16-bit PC to 32-bit for arithmetic
    wire [31:0] pc32p4 = pc32 + 32'd4;     // PC + 4 (for JAL return address)

    // ALU Operands
    wire [31:0] operand1;
    wire [31:0] operand2;

    // JALR target calculation
    wire [31:0] JALR_target; // 32-bit JALR target address

    // --- Module Instantiations ---
    wire [31:0] branch_sum = pc32 + imm32;   // 先算好 pc+imm
    wire [15:0]pc_target;
    // Fetch Stage
    fetch fetch1(
        .clk(clk),
        .rst(rst),
        .next_pc_select(next_pc_select), // Control from decode
        .pc_target(pc_target),           // Calculated next PC
        .pc(pc)                          // Current PC output
    );

    // Instruction Memory
    instruction_memory instruction_memory1(
        .clk(clk),
        .i_address(i_address), // PC (byte address) is the instruction address
        .i_read_data(instruction) // Fetched instruction
    );

    // Decode Stage
    decode decode1(
        .pc(pc), // Pass PC to decode for AUIPC/JAL return address calculations (if decode needs it)
        .instruction(instruction),
        .opcode(opcode),
        .imm_i(imm_i),
        .imm_s(imm_s),
        .imm_b(imm_b),
        .imm_j(imm_j),
        .imm_u(imm_u),
        .clk(clk),
        .branch(branch), // CONNECTED: ALU's branch output to decode's branch input
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
        .funct7(funct7),
        .next_PC_select(next_pc_select) // CONNECTED: Decode generates this signal
    );

    // Immediate Generator
    imm_gen imm_gen1(
        .clk(clk),
        .instruction(instruction),
        .imm32(imm32) // Outputs the sign-extended 32-bit immediate
    );

    // Register File
    regfile regfile1(
        .clk(clk),
        .rst(rst),
        .wEn(wEn),
        .rs1(rs1),
        .rs2(rs2),
        .rd(rd),
        .write_data(write_data), // Data to write to regfile
        .read_data1(regfile_read_data1), // Read data from rs1
        .read_data2(regfile_read_data2)  // Read data from rs2
    );

    // ALU
    alu alu1(
        .clk(clk), // Clock is only needed if ALU has internal registers, otherwise can remove
        .opcode(opcode),
        .rs1(rs1), // Pass for debug or specific ALU internal logic
        .rs2(rs2), // Pass for debug or specific ALU internal logic
        .rd(rd),   // Pass for debug or specific ALU internal logic
        .funct3(funct3),
        .funct7(funct7),
        .read_data1(operand1), // Connect ALU operand 1
        .read_data2(operand2), // Connect ALU operand 2
        .imm32(imm32),         // Connect sign-extended immediate
        .pc_in(pc32),          // CONNECTED: 32-bit PC to ALU for PC-relative ops
        .ALU_result(ALU_result),
        .branch(branch)        // ALU's combinational branch decision
    );

    // Data Memory
    data_memory data_memory1(
        .clk(clk),
        .rst(rst),
        .mem_wEn(mem_wEn),
        .address(data_mem_address),     // CORRECTED: Connect ALU result for address
        .write_data(data_mem_write_data), // Data to write to memory
        .read_data(data_mem_read_data)   // Data read from memory
    );

    // --- Control Logic and Data Path Assignments ---

    // Instruction Memory Address Assignment (PC is the byte address)
    assign i_address = pc;


    assign pc_target =
        (next_pc_select && opcode == 7'b1100011 && branch) ? branch_sum[15:0] :
        (next_pc_select && opcode == 7'b1101111)           ? branch_sum[15:0] :
        (next_pc_select && opcode == 7'b1100111)           ? JALR_target[15:0] : (pc);
                                                             
    // JALR Target Calculation (rs1 + sign-extended immediate, LSB cleared)
    assign JALR_target = (regfile_read_data1 + imm32) & ~32'h1;

    // ALU Operand 1 Selection (op_A_sel from decode)
    assign operand1 =
        (op_A_sel == 2'b00) ? regfile_read_data1 : // Read data from rs1
        (op_A_sel == 2'b01) ? pc32 :               // PC value (for AUIPC)
        (op_A_sel == 2'b10) ? pc32p4 :             // PC + 4 (for JAL/JALR return address)
        32'b0; // Default or error case

    // ALU Operand 2 Selection (op_B_sel from decode)
    assign operand2 =
        (op_B_sel == 2'b00) ? regfile_read_data2 : // Read data from rs2
        (op_B_sel == 2'b01) ? imm32 :              // Immediate value
        32'b0; // Default or error case

    // Data Memory Address Assignment (from ALU result)
    assign data_mem_address = ALU_result[15:0]; // Assuming data memory is 16-bit addressed

    // Data to write to Data Memory (for Store instructions)
    assign data_mem_write_data = regfile_read_data2; // Store instructions write rs2 to memory

    // Writeback Data Selection (wb_sel from decode)
    // write_data is a 'reg' and assigned in an always block
    always @(posedge clk) begin
        write_data <= (wb_sel == 1'b0) ? ALU_result : data_mem_read_data;
    end

    // Debug Display (Sequential, triggered on clock edge)
    always @(posedge clk) begin
        $display("--------------------------------------------------");
        $display("Cycle: %0d", $time / 10); // Assuming 10ns cycle time
        $display("=== FETCH ===");
        $display("PC = %h, Instruction = %h", pc, instruction);
        $display("=== DECODE ===");
        $display("opcode=%b, rs1=%d, rs2=%d, rd=%d", opcode, rs1, rs2, rd);
        $display("funct3=%b, funct7=%b", funct3, funct7);
        $display("imm32 = %h", imm32);
        $display("next_PC_select = %b, wEn = %b, branch_op = %b", next_pc_select, wEn, branch_op);
        $display("op_A_sel = %b, op_B_sel = %b, ALU_Control = %b", op_A_sel, op_B_sel, ALU_Control);
        $display("mem_wEn = %b, wb_sel = %b", mem_wEn, wb_sel);
        $display("=== ALU ===");
        $display("[ALU] Operand1=%h, Operand2=%h", operand1, operand2);
        $display("ALU_result = %h, branch = %b", ALU_result, branch);
        $display("PC_TARGET = %h, JALR_target = %h", pc_target, JALR_target);
        $display("=== WRITEBACK ===");
        $display("WriteData = %h, ToReg = %d, wb_sel = %b", write_data, rd, wb_sel);
        $display("=== DATA MEMORY ===");
        $display("Data Memory Address = %h, Data Memory Write Data = %h, Data Memory Read Data = %h, branch_sum=%h", data_mem_address, data_mem_write_data, data_mem_read_data, branch_sum);

        // Terminate simulation if PC exceeds program range
        // Program has 11 instructions (0 to 10), last instruction at byte address 10 * 4 = 40 (0x28)
        // So, if PC goes beyond 0x28 (e.g., 0x2c), it's likely finished.
        if (pc > 16'h0040) begin // Adjusted to allow last instruction at 0x28 to execute
            $display("⚠️ PC exceeded valid program range or reached end of program.");
            $display("Final WriteData = %h, ToReg = %d, wb_sel = %b", write_data, rd, wb_sel);
            $finish;
        end
    end

endmodule
