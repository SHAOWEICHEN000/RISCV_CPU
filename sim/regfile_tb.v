module regfile_tb;
reg clk, rst, wEn;
reg [4:0] rs1, rs2, rd;
reg [31:0] write_data;
wire [31:0] read_data1, read_data2;
integer i;
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
initial begin
clk=0;
forever #5 clk=~clk;
end
initial begin//put in another block
rst = 1; wEn = 0;
rs1 = 0; rs2 = 0; rd = 0;
write_data = 32'h00000000;
#10 rst = 0;
// write x1 ~ x31
for (i = 1; i < 32; i = i + 1) begin
@(posedge clk);
wEn = 1;	
rd = i;
write_data = i * 32'h11111111;
@(posedge clk); // 資料與目標暫存器已設定，現在寫入
end
@(posedge clk); // 等一拍確保寫入完成
wEn = 0;
// 讀出 x1 ~ x31
for (i = 1; i < 32; i = i + 1) begin
@(posedge clk);
rs1 = i;
#1 $display("x%0d = %h (expect %h)", i, read_data1, i * 32'h11111111);
end
$finish;
end
endmodule

