`ifndef DECODE_V
`define DECODE_V
module decode(
input [31:0]pc,
input [31:0] instruction,
//R-type
output reg[6:0]opcode,
output reg[4:0]rs1,
output reg[4:0]rs2,
output reg[4:0]rd,
output reg[2:0]funct3,
output reg[6:0]funct7,
//L type
output reg[11:0]imm_i,
//s type
output reg[11:0]imm_s,
//B type
output reg[11:0]imm_b,
//J-type
output reg [20:0] imm_j,
//U type
output reg[19:0]imm_u,
output reg next_PC_select,
 output reg wEn,
input branch,
  // Outputs to Execute/ALU
  output reg branch_op, // Tells ALU if this is a branch instruction
  output reg [1:0] op_A_sel,
  output reg [1:0]op_B_sel,
  output reg [5:0] ALU_Control,

  // Outputs to Memory
  output reg mem_wEn,

  // Outputs to Writeback
  output reg wb_sel
);

   localparam [6:0]R_TYPE  = 7'b0110011,
                   I_TYPE  = 7'b0010011,
                   STORE   = 7'b0100011,
                   LOAD    = 7'b0000011,
                   BRANCH  = 7'b1100011,
                   JALR    = 7'b1100111,
                   JAL     = 7'b1101111,
                   AUIPC   = 7'b0010111,
                   LUI     = 7'b0110111;
    always @(*) begin
    //  DEFAULT（PREVENT latch）
        opcode  <= 7'b0;
        rd      <= 5'b0;
        funct3  <= 3'b0;
        rs1     <= 5'b0;
        rs2     <= 5'b0;
        funct7  <= 7'b0;
        imm_i   <= 12'b0;
        imm_s   <= 12'b0;
        imm_b	<= 12'b0;
        imm_j   <= 21'b0;
        imm_u   <= 20'b0;
    if(instruction[6:0]==R_TYPE) begin
    //R-type
     	opcode  <= instruction[6:0];
    	rd      <= instruction[11:7];
    	funct3  <= instruction[14:12];
    	rs1     <= instruction[19:15];
    	rs2     <= instruction[24:20];
    	funct7  <= instruction[31:25];
    end
    
    // I-type 
    if(instruction[6:0]==I_TYPE || instruction[6:0]==LOAD ||instruction[6:0]==JALR  ) begin
    	opcode  <= instruction[6:0];
        rd      <= instruction[11:7];
        funct3  <= instruction[14:12];
        rs1     <= instruction[19:15];
        imm_i   <= instruction[31:20];
    end
    //S-type
    if(instruction[6:0]==STORE)begin
   	opcode  <= instruction[6:0];
        funct3  <= instruction[14:12];
        rs1     <= instruction[19:15];
        rs2     <= instruction[24:20];
        imm_s   <= {instruction[31:25], instruction[11:7]};
    end

     //BRANCH TYPE
    if(instruction[6:0]==BRANCH)begin
   	opcode  <= instruction[6:0];
    	rs1     <= instruction[19:15];
    	rs2     <= instruction[24:20];
    	funct3  <= instruction[14:12];
    	imm_b   <= {instruction[31], instruction[7], instruction[30:25], instruction[11:8]}; 
    end

     //JAL TYPE
    if(instruction[6:0]==JAL)begin
   	opcode  <= instruction[6:0];
    	rd      <= instruction[11:7];
    	imm_j   <= {instruction[31], instruction[19:12], instruction[20], instruction[30:21],1'b0}; 
    end
     //U TYPE
    if(instruction[6:0]==AUIPC||instruction[6:0]==LUI )begin
   	opcode  <= instruction[6:0];
    	rd      <= instruction[11:7];
    	imm_u   <= instruction[31:12];  
    end
    case (opcode) 
	   7'b0110011: begin // R-type
		  next_PC_select = 0;
		  branch_op = 0;
		  mem_wEn = 0;
		  op_A_sel = 2'b00;
		  op_B_sel = 0;
		  wb_sel = 0;
		  wEn = 1;
		  if (funct3 == 3'b000) begin 
		    if (funct7 == 7'b0000000) begin 
			   ALU_Control = 6'b000000; //add
			 end else begin 
			   ALU_Control = 6'b001000; //sub
			 end 
		  end else if (funct3 == 3'b010) begin 
		    ALU_Control = 6'b000010; //slt
		  end else if (funct3 == 3'b100) begin 
		    ALU_Control = 6'b000100; //xor
		  end else if (funct3 == 3'b111) begin 
		    ALU_Control = 6'b000111; //and
		  end else if (funct3 == 3'b001) begin
		    ALU_Control = 6'b000001; //sll
		  end else if (funct3 == 3'b011) begin
		    ALU_Control = 6'b000010; //sltu
		  end else if (funct3 == 3'b110) begin
		    ALU_Control = 6'b000110; //or
		  end else if (funct3 == 3'b101) begin
		    if (funct7 == 7'b0000000) begin
			   ALU_Control = 6'b000101; //srl
			 end else begin 
			   ALU_Control = 6'b001101; //sra
			 end 
		  end 
      end 		  
		7'b0010011: begin //I-type
		  next_PC_select = 0;
		  branch_op = 0;
		  mem_wEn = 0;
		  op_A_sel = 2'b00;
		  op_B_sel = 1;
		  wb_sel = 0;
		  wEn = 1;
		  if (funct3 == 3'b000) begin
		    ALU_Control = 6'b000000; //addi 
		  end else if (funct3 == 3'b001) begin
			 ALU_Control = 6'b000001; //slli
		  end else if (funct3 == 3'b010) begin
			 ALU_Control = 6'b000011; //slti
		  end else if (funct3 == 3'b011) begin
			 ALU_Control = 6'b000011; //sltiu
		  end else if (funct3 == 3'b100) begin 
			 ALU_Control = 6'b000100; //xori
		  end else if (funct3 == 3'b101) begin 
		    if (funct7 == 7'b0000000) begin 
			   ALU_Control = 6'b000101; //srli
			 end else begin 
			   ALU_Control = 6'b001101; //srai
			 end
		  end else if (funct3 == 3'b110) begin
		    ALU_Control = 6'b000110; //ori
		  end else if (funct3 == 3'b111) begin 
		    ALU_Control = 6'b000111; //andi
		  end
		end
      7'b0000011: begin //Load
		  next_PC_select = 0;
		  branch_op = 0;
		  mem_wEn = 0;
		  op_A_sel = 2'b00;
		  op_B_sel = 1;
		  wb_sel = 1;
		  wEn = 1;
		  ALU_Control = 6'b000000;
		end 
      7'b0100011: begin //Store
		  next_PC_select = 0;
		  branch_op = 0;
		  mem_wEn = 1;
		  op_A_sel = 2'b00;
		  op_B_sel = 1;
		  wb_sel = 0;
		  wEn = 0;
		  ALU_Control = 6'b000000;
		end
		7'b1100011: begin //Branch 
		  branch_op = 1;
		  mem_wEn = 0;
		  op_A_sel = 2'b00;
		  op_B_sel = 0;
		  wb_sel = 0;
		  wEn = 0;
		  if (branch) begin 
		    next_PC_select = 1;
		  end else begin 
		    next_PC_select = 0;
		  end
		  if (funct3 == 3'b000) begin 
		    ALU_Control = 6'b010000; //beq
		  end else if (funct3 == 3'b001) begin 
		    ALU_Control = 6'b010001; //bne
        end else if (funct3 == 3'b100) begin 
		    ALU_Control = 6'b000010; //blt
        end else if (funct3 == 3'b101) begin 
		    ALU_Control = 6'b010101; //bge
        end else if (funct3 == 3'b110) begin 
		    ALU_Control = 6'b010110; //bltu
        end else if (funct3 == 3'b111) begin 
		    ALU_Control = 6'b010111; //bgeu
        end 
		end
		7'b1100111: begin //Jalr
		  next_PC_select = 1;
		  branch_op = 0;
		  mem_wEn = 0;
		  op_A_sel = 2'b10; // PC + 4
		  op_B_sel = 0;
		  wb_sel = 0;
		  wEn = 1;
		  ALU_Control = 6'b111111;
		end
		7'b1101111: begin //Jal
		  next_PC_select = 1;
		  branch_op = 0;
		  mem_wEn = 0;
		  op_A_sel = 2'b10;  // PC + 4 
		  op_B_sel = 0;
		  wb_sel = 0;
		  wEn = 1;
		  ALU_Control = 6'b011111;
		end
		7'b0010111: begin //Auipc//
		  branch_op = 0;
		  mem_wEn = 0;
		  op_A_sel = 2'b01; // PC
		  op_B_sel = 1;
		  wb_sel = 0;
		  wEn = 1;
		  ALU_Control = 6'b000000;
		end
		7'b0110111: begin //Lui
		  branch_op = 0;
		  mem_wEn = 0;
		  op_A_sel = 2'b11; // hard code zero  
		  op_B_sel = 1;
		  wb_sel = 0;
		  wEn = 1;
		  ALU_Control = 6'b000000;
		end
    endcase 
    end
endmodule
`endif
