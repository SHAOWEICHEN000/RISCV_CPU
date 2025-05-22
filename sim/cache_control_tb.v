
`timescale 1ns / 1ps

module cache_control_tb;
    reg clk, rst;
    reg mem_ready;
    reg [31:0] address;
    reg wEn, rEn;
    reg [31:0] refill;
    wire [31:0] write_memory;
    wire [31:0] read_memry;
    wire [31:0] update;

    cache_control uut (
        .clk(clk),
        .rst(rst),
        .mem_ready(mem_ready),
        .address(address),
        .wEn(wEn),
        .rEn(rEn),
        .refill(refill),
        .write_memory(write_memory),
        .read_memry(read_memry),
        .update(update)
    );

    // Clock generator
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    initial begin
        $dumpfile("cache_control_tb.vcd");
        $dumpvars(0, cache_control_tb);
    end

    initial begin
        rst = 1; mem_ready = 0; wEn = 0; rEn = 0;
        address = 32'h12345678;
        refill = 32'h89abcdef;
        #20 rst = 0;

        // 1. 模擬 read miss + refill
        $display("T=%0t | 模擬 read miss + refill", $time);
        rEn = 1;
        #10;
        rEn = 0; mem_ready = 1; #20; mem_ready = 0;

        // 2. 模擬 read hit
        #20 rEn = 1; #20 rEn = 0;

        // 3. 模擬 write hit
        #20 wEn = 1; #20 wEn = 0;

        // 4. 模擬 write miss + write back
        address = 32'h9ABCDEF0;
        refill = 32'hdeadbeef;
        write_memory=32'h11111111;
        #20 wEn = 1; #10 wEn = 0; mem_ready = 1; #20 mem_ready = 0;
        
        $display("T=%0t | 測試完成", $time);
        #20 $finish;
    end
endmodule
