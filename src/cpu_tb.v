`timescale 1ns/1ps

module top_tb;
    reg clk;
    reg rst;

    // 實例化 DUT (Design Under Test)
    top uut (
        .clk(clk),
        .rst(rst)
    );

    // Clock generation (週期 10ns = 100MHz)
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // 每 5ns 反轉一次，週期 10ns
    end

    // Reset + 控制模擬流程
    initial begin
        $dumpfile("top_tb.vcd");    // 建立 VCD 檔案供 GTKWave 用
        $dumpvars(0, top_tb);       // Dump 所有變數 (0 表示所有層次)

        rst = 1;
        #20 rst = 0; // 重置拉高 10ns，確保初始化完成

        // 觀察足夠長的時間，例如 3000ns
        #300 $finish; // 模擬在 3000ns 後結束
    end
endmodule
