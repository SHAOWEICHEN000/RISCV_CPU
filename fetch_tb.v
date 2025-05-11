`include"fetch.v"
module fetch_tb;
reg  clk;
reg  rst;
reg  next_pc_select;     //select jump
wire [15:0]pc;
reg [15:0]pc_target;	  //jump address
fetch fetch(
	.clk(clk),
	.rst(rst),
	.next_pc_select(next_pc_select),
	.pc(pc),
	.pc_target(pc_target)
);
  initial begin
    clk = 0;
    forever #5 clk = ~clk;
  end
initial begin
 clk = 1'b1;
  rst = 1'b1;
  next_pc_select = 1'b0;
  pc_target = 16'h0000;

  #1
  #10
  rst = 1'b0;

  #10
  $display("PC: %h", pc);

  /***************************
  * Add more test cases here *
  ***************************/
  #10 
  pc_target= 16'h1010;
  next_pc_select = 1'b0;
  #10
  $display("PC: %h", pc);
  #10
  pc_target =16'h1011;
  next_pc_select = 1'b1;
  #10
  $display("PC: %h", pc);
  #10
  rst = 1'b1;
  pc_target = 16'h1111;
  next_pc_select = 1'b1;
  #10
  $display("PC: %h", pc);
  #10
  rst = 1'b0;
  pc_target = 16'b0001;
  next_pc_select = 1'b0;
  #10
  $display("PC: %h", pc);
  #100
  $finish;
end

  
  endmodule
