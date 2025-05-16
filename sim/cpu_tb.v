`timescale 1ns/1ps

module top_tb;
    reg clk;
    reg rst;

    // Instantiate your top module
    top uut (
        .clk(clk),
        .rst(rst)
         // 若有接 pc 輸出可觀察
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // 100MHz clock
    end

    // Reset and simulation control
    initial begin
        rst = 1;
        #10 rst = 0;
        #1000 $finish;  // 模擬執行一段時間後停止
    end
endmodule
