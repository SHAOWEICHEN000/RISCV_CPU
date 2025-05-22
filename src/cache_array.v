module cache_array(
    input clk,
    input rst,
    input write_en,
    input [1:0] index,               // 4 sets
    input v_write_in,
    input [27:0] tag_write_in,
    input [31:0] data_write_in,
    input dirty_write_in,
    input victim_way,               // 0 = way0, 1 = way1
    output reg v_way0,
    output reg v_way1,
    output reg dirty_way0,
    output reg dirty_way1,
    output reg [27:0] tag_way0,
    output reg [27:0] tag_way1,
    output reg [31:0] data_way0,
    output reg [31:0] data_way1
);
    reg valid_array[0:3][0:1];        
    reg [27:0] tag_array[0:3][0:1];
    reg [31:0] data_array[0:3][0:1];
    reg dirty_array[0:3][0:1];

    // write memory using victim_way
    always @(posedge clk or posedge rst) begin
    if (rst) begin
        
        valid_array[0][0] <= 0; valid_array[0][1] <= 0;
        valid_array[1][0] <= 0; valid_array[1][1] <= 0;
        valid_array[2][0] <= 0; valid_array[2][1] <= 0;
        valid_array[3][0] <= 0; valid_array[3][1] <= 0;

        dirty_array[0][0] <= 0; dirty_array[0][1] <= 0;
        dirty_array[1][0] <= 0; dirty_array[1][1] <= 0;
        dirty_array[2][0] <= 0; dirty_array[2][1] <= 0;
        dirty_array[3][0] <= 0; dirty_array[3][1] <= 0;
        
        data_array[0][0] <= 0; data_array[0][1] <= 0;
        data_array[1][0] <= 0; data_array[1][1] <= 0;
        data_array[2][0] <= 0; data_array[2][1] <= 0;
        data_array[3][0] <= 0; data_array[3][1] <= 0;
        
        tag_array[0][0] <= 0; tag_array[0][1] <= 0;
        tag_array[1][0] <= 0; tag_array[1][1] <= 0;
        tag_array[2][0] <= 0; tag_array[2][1] <= 0;
        tag_array[3][0] <= 0; tag_array[3][1] <= 0;
        
    end else if (write_en) begin
        if (victim_way == 0) begin
            valid_array[index][0] <= v_write_in;
            dirty_array[index][0] <= dirty_write_in;
            tag_array[index][0] <= tag_write_in;
            data_array[index][0] <= data_write_in;
            $display("[WRITE CACHE] Set dirty0 = %b", dirty_write_in);
        end else begin
            valid_array[index][1] <= v_write_in;
            dirty_array[index][1] <= dirty_write_in;
            tag_array[index][1] <= tag_write_in;
            data_array[index][1] <= data_write_in;
            $display("[WRITE CACHE] Set dirty1 = %b", dirty_write_in);
        end
    end
        v_way0     = valid_array[index][0];
        v_way1     = valid_array[index][1];
        tag_way0   = tag_array[index][0];
        tag_way1   = tag_array[index][1];
        data_way0  = data_array[index][0];
        data_way1  = data_array[index][1];
        dirty_way0 = dirty_array[index][0];
        dirty_way1 = dirty_array[index][1];
        $display("[WRITE CACHE] read dirty_way0 = %b", dirty_way0);
end
endmodule
