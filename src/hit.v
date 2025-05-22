module hit(
    input clk,
    input v_way0,
    input v_way1,
    input [27:0]tag_way0,
    input [27:0]tag_way1,
    input [27:0]tag_memory,
    output reg hit0,
    output reg hit1,
    output reg hit_all
);
    reg jg0;
    reg jg1;
    always @(posedge clk) begin
        jg0=0;
        jg1=0;
    	// equal block memory and cache way0
        if(tag_memory== tag_way0) begin
            jg0=1;
        end
        if(tag_memory== tag_way1) begin
            jg1=1;
        end
        #10 hit1=v_way1 & jg1;
        #10 hit0=v_way0 & jg0;
        #10 hit_all =hit0 | hit1;
        $display("[hit.v] tag_mem=%h, tag0=%h, tag1=%h, v0=%b, v1=%b, hit0=%b, hit1=%b, hit_all=%b",
        tag_memory, tag_way0, tag_way1, v_way0, v_way1, hit0, hit1, hit_all);

    end
endmodule
