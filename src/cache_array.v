module cache_array(
    input clk,
    input rst,
    input wE0,
    input wE1,
    input [1:0]index,
    input v_write_in,
    input [27:0]tag_write_in,
    input [31:0]data_write_in,
    input dirty_write_in,
    output reg v_way0,
    output reg v_way1,
    output reg dirty_way0,
    output reg dirty_way1,
    output reg[27:0]tag_way0,
    output reg[27:0]tag_way1,
    output reg[31:0]data_way0,
    output reg[31:0]data_way1
);
    reg valid_array[0:3][0:1];        
    reg [27:0] tag_array[0:3][0:1];
    reg [31:0] data_array[0:3][0:1];
    reg dirty_array[0:3][0:1];

    // write in memory
    always @(posedge clk) begin
        if (wE0) begin
            valid_array[index][0] <= v_write_in;
            tag_array[index][0]   <= tag_write_in;
            data_array[index][0]  <= data_write_in;
            dirty_array[index][0] <= dirty_write_in;
        end
        if (wE1) begin
            valid_array[index][1] <= v_write_in;
            tag_array[index][1]   <= tag_write_in;
            data_array[index][1]  <= data_write_in;
            dirty_array[index][1] <= dirty_write_in;
        end
    end

    // read memory
    always @(*) begin
        v_way0    = valid_array[index][0];
        v_way1    = valid_array[index][1];
        tag_way0  = tag_array[index][0];
        tag_way1  = tag_array[index][1];
        data_way0 = data_array[index][0];
        data_way1 = data_array[index][1];
        dirty_way0 = dirty_array[index][0];
        dirty_way1 = dirty_array[index][1];
    end

endmodule
