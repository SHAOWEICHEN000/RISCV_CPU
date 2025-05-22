`timescale 1ns / 1ps
module hit_tb;
    reg clk;
    reg v_way0;
    reg v_way1;
    reg [27:0] tag_way0;
    reg [27:0] tag_way1;
    reg [27:0] tag_memory;
    wire hit0;
    wire hit1;
    wire hit_all;

    hit hit(
        .clk(clk),
        .v_way0(v_way0),
        .v_way1(v_way1),
        .tag_way0(tag_way0),
        .tag_way1(tag_way1),
        .tag_memory(tag_memory),
        .hit0(hit0),
        .hit1(hit1),
        .hit_all(hit_all)
    );

    // Clock generator
    initial begin
        clk = 0;
        forever #5 clk = ~clk; 
    end

    task display_status();
        $display("T=%0t | hit0= %b | hit1= %b | hit_all = %b",
                $time, hit0, hit1, hit_all);
    endtask

    initial begin
        $display("\n--- [Test 1] tag_way0 = tag_memory, way0 valid ---");
        v_way0 = 1;
        v_way1 = 0;
        tag_way0 = 28'h9abcdef;
        tag_way1 = 28'h97abcde;
        tag_memory = 28'h9abcdef;
        #10; display_status();

        $display("\n--- [Test 2] tag_way1 = tag_memory, both valid ---");
        v_way0 = 1;
        v_way1 = 1;
        tag_way1 = 28'h9abcdef;
        #10; display_status();

        $display("\n--- [Test 3] both tag mismatch ---");
        v_way0 = 1;
        v_way1 = 1;
        tag_way0 = 28'hAAAAAAA;
        tag_way1 = 28'hBBBBBBB;
        tag_memory = 28'hCCCCCCC;
        #10; display_status();

        $display("\n--- [Test 4] way0 invalid but tag match ---");
        v_way0 = 0;
        tag_way0 = tag_memory;
        #10; display_status();

        $finish;
    end
endmodule
