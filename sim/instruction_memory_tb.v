module instruction_memory_tb;
reg clk;
reg [15:0] i_address;
wire [31:0] i_read_data;
instruction_memory imem (
.clk(clk),
.i_address(i_address),
.i_read_data(i_read_data)
);
// Clock generator
initial begin
clk = 0;
forever #5 clk = ~clk;
end
initial begin
$display("========= Instruction Memory Test =========");
#1;
// Read memory[0] (i_address = 0)
i_address = 16'h0000;
@(posedge clk);
#1 $display("i_address=0x0000 → i_read_data = %h (expect 12345678)", i_read_data);
// Read memory[1] (i_address = 0x4)
i_address = 16'h0004;
@(posedge clk);
#1 $display("i_address=0x0004 → i_read_data = %h (expect deadbeef)", i_read_data);
// Read memory[2] (i_address = 0x8)
i_address = 16'h0008;
@(posedge clk);
#1 $display("i_address=0x0008 → i_read_data = %h (expect beefcafe)", i_read_data);
$finish;
end
endmodule
