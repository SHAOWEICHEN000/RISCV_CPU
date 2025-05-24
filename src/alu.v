`ifndef ALU_V
`define ALU_V
module alu(
  input clk,
  input [6:0]opcode,
  input [4:0]rs1,
  input [4:0]rs2,
  input [4:0]rd,
  input [2:0]funct3,
  input [6:0]funct7,
  input [11:0]imm_i,
  input [11:0]imm_s,
  input [11:0]imm_b,
  input [20:0]imm_j,
  input [19:0]imm_u, 
  input [31:0]read_data1,
  input [31:0]read_data2,
  input [31:0]imm32,
  input [15:0]pc,
  output reg[31:0] ALU_result,
  output branch
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
                  wire signed [31:0] s_op_a;
		  wire signed [31:0] s_op_b;
		  reg branch_flag;
		  assign s_op_a = read_data1;
		  assign s_op_b = read_data2;

  		  assign branch = branch_flag;
always @(*)begin
	//-------------------------------R_TYPE-------------------------------
	if(opcode==R_TYPE)begin
		if(funct3==3'b000) begin//add
			 ALU_result = read_data1 + read_data2;
		end
		if(funct3==3'b001 &&funct7 == 7'b0000000) begin//SLL
			 ALU_result= read_data1<<  imm32[4:0];
		end
		if(funct3==3'b010) begin//SLT
			 ALU_result = (s_op_a < s_op_b) ? 32'd1 : 32'd0;
		end
		if(funct3==3'b011) begin//SLTU
			 ALU_result = (read_data1 < read_data2) ? 32'd1 : 32'd0;
		end
		if(funct3==3'b100) begin//XOR
			 ALU_result = read_data1 ^ read_data2;
		end
		if(funct3==3'b101 && funct7 == 7'b0000000) begin//SrL
			 ALU_result = read_data1 >> imm32[4:0]; 
		end
		if(funct3==3'b101 && funct7 == 7'b0100000) begin//Sra
			 ALU_result = $signed(read_data1) >>> imm32[4:0]; 
		end
		if(funct3==3'b110) begin//OR
			 ALU_result =read_data1|read_data2;
		end
		
		if(funct3==3'b111) begin//AND
			 ALU_result = read_data1 & read_data2;
		end	
	end	
	//--------------------------------L_TYPE-------------------------------
	if(opcode==LOAD)begin
		if(funct3==3'b000) begin//lb
			 ALU_result = read_data1 + imm32[7:0];
		end
		if(funct3==3'b001) begin//lh
			 ALU_result = read_data1 + imm32[15:0];
		end
		if(funct3==3'b010) begin//lw
			 ALU_result = read_data1 + imm32;
		end
		if(funct3==3'b100) begin//lbu
			 ALU_result = read_data1 + imm32;
		end
		if(funct3==3'b101) begin//lhu
			 ALU_result = read_data1 + imm32;
		end
	end
	//--------------------------------I_TYPE--------------------------------
	if(opcode==I_TYPE)begin
		if(funct3==3'b000) begin//addi
			 ALU_result = read_data1 + imm_i;
		end
		if(funct3==3'b001 &&funct7 == 7'b0000000) begin//SLLI
			 ALU_result =  read_data1 <<  imm32[4:0];
		end
		if(funct3==3'b010) begin//SLTI
			 ALU_result = (s_op_a < imm_i) ? 32'd1 : 32'd0;
		end
		if(funct3==3'b011) begin//SLTIU
			ALU_result = (read_data1 < imm32) ? 32'd1 : 32'd0;
		end
		if(funct3==3'b100) begin//XORI
			 ALU_result = read_data1 ^ imm_i;
		end
		if(funct3==3'b101 && funct7 == 7'b0000000) begin//SrLI
			 ALU_result = read_data1 >> imm32[4:0]; 
		end
		if(funct3==3'b101 && funct7 == 7'b0100000) begin//SraI
			 ALU_result = $signed(read_data1) >>> imm32[4:0]; 
		end
		if(funct3==3'b110) begin//ORI
			 ALU_result =read_data1|imm_i;
		end
		
		if(funct3==3'b111) begin//ANDI
			 ALU_result = read_data1 & imm_i;
		end
	end
	//---------------------------------s_type----------------------------------
	if(opcode==STORE)begin
		if(funct3==3'b000) begin//sb
			  ALU_result = read_data1 + imm32[7:0]; 
		end
		if(funct3==3'b001) begin//Sh
			ALU_result = read_data1 + imm32[15:0]; 
		end
		if(funct3==3'b010) begin//sw
			ALU_result = read_data1 + imm32; 
		end
	end	
	//---------------------------------branch-----------------------------------
	if (opcode == BRANCH) begin
        case (funct3)
            3'b000: branch_flag = (read_data1 == read_data2);  // beq
            3'b001: branch_flag = (read_data1 != read_data2);  // bne
            3'b100: branch_flag = ($signed(read_data1) < $signed(read_data2)); // blt
            3'b101: branch_flag = ($signed(read_data1) >= $signed(read_data2)); // bge
            3'b110: branch_flag = (read_data1 < read_data2);   // bltu
            3'b111: branch_flag = (read_data1 >= read_data2);  // bgeu
            default: branch_flag = 0;
        endcase
	    end else begin
	        branch_flag = 0;
	end
		
	//---------------------------------JALR--------------------------------------
	if (opcode == JALR) begin
       		 ALU_result = (read_data1 + imm32) & ~32'h1;
       	end
       	//---------------------------------JAL---------------------------------------
       	if (opcode == JAL) begin
       		 ALU_result =pc+4 ;
       	end
       	//---------------------------------AUIPC-------------------------------------
       	if (opcode == AUIPC) begin
       		ALU_result = pc + (imm_u << 12);
       	end
       	//----------------------------------LUI-------------------------------------
       	if (opcode == LUI) begin
       		 ALU_result = imm_u << 12;
       	end
       	//--------------------------------------------------------------------------
end
endmodule

`endif
