
`timescale 1ns / 1ps

module cache_array_tb;
    reg clk;
    reg rst;
    reg write_en;
    reg [1:0] index;
    reg v_write_in;
    reg [27:0] tag_write_in;
    reg [31:0] data_write_in;
    reg dirty_write_in;
    reg victim_way;

    wire v_way0;
    wire v_way1;
    wire dirty_way0;
    wire dirty_way1;
    wire [27:0] tag_way0;
    wire [27:0] tag_way1;
    wire [31:0] data_way0;
    wire [31:0] data_way1;

    cache_array cache_array(
        .clk(clk),
        .rst(rst),
        .write_en(write_en),
        .index(index),
        .victim_way(victim_way),
        .v_write_in(v_write_in),
        .tag_write_in(tag_write_in),
        .data_write_in(data_write_in),
        .dirty_write_in(dirty_write_in),
        .v_way0(v_way0),
        .v_way1(v_way1),
        .dirty_way0(dirty_way0),
        .dirty_way1(dirty_way1),
        .tag_way0(tag_way0),
        .tag_way1(tag_way1),
        .data_way0(data_way0),
        .data_way1(data_way1)
    );

    initial begin
        $dumpfile("cache_array_tb.vcd");
        $dumpvars(0, cache_array_tb);
    end

    // Clock generator
    initial begin
        clk = 0;
        forever #5 clk = ~clk; 
    end

    task display_status(input [1:0] i);
        $display("T=%0t | index=%0d | V0=%b V1=%b | Tag0=%h Tag1=%h | Data0=%h Data1=%h | D0=%b D1=%b",
            $time, i, v_way0, v_way1, tag_way0, tag_way1, data_way0, data_way1, dirty_way0, dirty_way1);
    endtask

    initial begin 
        // 初始化
        rst = 1; write_en = 0; v_write_in = 0;
        dirty_write_in = 0; tag_write_in = 0; data_write_in = 0;
        index = 0; victim_way = 0;
        #12; rst = 0;

        // === 寫入 set 0, way 0 ===
        index = 2'b00; victim_way = 0;
        tag_write_in = 28'hAAAAAAA; data_write_in = 32'h11111111;
        v_write_in = 1; dirty_write_in = 1; write_en = 1; #10; write_en = 0;
        display_status(index);

        // === 寫入 set 0, way 1 ===
        index = 2'b00; victim_way = 1;
        tag_write_in = 28'hBBBBBBB; data_write_in = 32'h22222222;
        v_write_in = 1; dirty_write_in = 0; write_en = 1; #10; write_en = 0;
        display_status(index);

        // === 寫入 set 1, way 1 ===
        index = 2'b01; victim_way = 1;
        tag_write_in = 28'hCCCCCCC; data_write_in = 32'h33333333;
        v_write_in = 1; dirty_write_in = 1; write_en = 1; #10; write_en = 0;
        display_status(index);

        // === 驗證 set 0 是否保留 ===
        index = 2'b00; #10;
        display_status(index);

        // === 驗證 set 1 ===
        index = 2'b01; #10;
        display_status(index);

        $finish;
    end
endmodule
