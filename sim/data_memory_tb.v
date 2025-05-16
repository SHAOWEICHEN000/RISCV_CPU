`include"data_memory.v"
module  data_memory_tb;
reg clk,mem_wEn,rst;
reg [15:0]address;
reg [31:0]write_data;
wire [31:0] read_data;
data_memory data_memory(
.clk(clk),
.rst(rst),
.mem_wEn(mem_wEn),
.address(address),
.write_data(write_data),
.read_data(read_data)
); 

initial begin
clk=0;
forever #5 clk=~clk;
end
initial begin
rst=0;
mem_wEn=0;
write_data = 32'h00000000;
address=16'h0000;
#10
// 寫入
  @(posedge clk);
  rst=1;
mem_wEn = 1;
address = 16'h006f;
write_data = 32'h11100011;


@(posedge clk);

// 關閉寫入
mem_wEn = 0;
@(posedge clk);
rst=0;
// 讀出
#1 $display("Read Data = %h should be 11100011", read_data);
#1 $display("address in test_bench= %b (should be 0000000001101111 )", address);
$finish;
end
endmodule
