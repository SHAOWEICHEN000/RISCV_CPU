module lru(
    input clk,
    input rst,
    input [1:0] index,
    input update_en,
    input hit0,
    input hit1,
    output victim_way
);
    reg [3:0] lru_bit;

    // reset and update
    always @(posedge clk) begin
        if (rst) begin
            lru_bit[0] <= 0;
            lru_bit[1] <= 0;
            lru_bit[2] <= 0;
            lru_bit[3] <= 0;
        end else if (update_en) begin	   //find way
            if (hit0)
                lru_bit[index] <= 0;  
            else if (hit1)
                lru_bit[index] <= 1; 
        end
    end

    assign victim_way = ~lru_bit[index];  // victim
endmodule
