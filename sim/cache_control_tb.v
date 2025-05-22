
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
    $display("=== Cache Control Test Start ===");
    clk = 0;
    rst = 1;
    wEn = 0; rEn = 0;
    address = 32'h00000000;
    refill = 32'hDEADBEEF;
    #10 rst = 0;

    // ---- Write Miss + Refill ----
    #10 address = 32'h55555555;
    wEn = 1; rEn = 0;
    #10 wEn = 0;

    // Wait for refill
    #50 mem_ready = 1;
    #10 mem_ready = 0;

    // ---- Write Hit (same address) ----
    #20 address = 32'h00000000;
    wEn = 1;


    // ---- Conflict Miss: cause eviction ----
    #20 address = 32'h00000040; // 同樣 index 的不同 tag，造成 conflict miss
    wEn = 1;
    #10 wEn = 0;

    // Wait for write-back of dirty block
    #50 mem_ready = 1;
    #10 mem_ready = 0;

    // ---- Read back to verify refill ----
    #20 address = 32'h55555555; 
    rEn = 1;
    #10 rEn = 0;
    
    
    $display("=== Cache Control Test End ===");
    $finish;
end
always @(posedge clk) begin
    $display("Time=%0t, State=%0d, Addr=%h, hit_all=%b, victim=%b, dirty=%b, Read=%h", 
    $time, uut.next_state, address, uut.hit_all, uut.victim_way, uut.victim_dirty, uut.read_memry);
    
end
endmodule
