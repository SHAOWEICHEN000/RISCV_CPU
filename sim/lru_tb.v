module lru_tb;
    reg clk;
    reg rst;
    reg [1:0] index;
    reg update_en;
    reg hit0;
    reg hit1;
    wire victim_way;

    lru lru(
        .clk(clk),
        .rst(rst),
        .index(index),
        .update_en(update_en),
        .hit0(hit0),
        .hit1(hit1),
        .victim_way(victim_way)
    );

    // Clock generator
    initial begin
        clk = 0;
        forever #5 clk = ~clk; 
    end

    initial begin 
        // 初始化
        index = 0;
        update_en = 0;
        hit0 = 0;
        hit1 = 0;

        // Reset
        rst = 1;
        #12;
        rst = 0;

        // 初始 victim_way
        $display("T=%0t | After reset           | victim_way = %b", $time, victim_way);

        // === 模擬 set 1：hit0 ===
        index = 2'b00;
        hit0 = 1;
        update_en = 1;
        #10;
        $display("T=%0t | hit0 @set 0           | victim_way = %b", $time, victim_way);

        // 清除
        update_en = 0;
        hit0 = 0;
        #10;

        // === 模擬 set 1：hit1 ===
        index = 2'b01;
        hit1 = 1;
        update_en = 1;
        #10;
        $display("T=%0t | hit1 @set 1           | victim_way = %b", $time, victim_way);

        // 清除
        update_en = 0;
        hit1 = 0;
        #10;

        // === 觀察 set 2 初始狀態 ===
        index = 2'b10;
        #10;
        $display("T=%0t | check @set 2 default  | victim_way = %b", $time, victim_way);

        $finish;
    end
endmodule
