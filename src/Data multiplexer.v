module Data_multiplexer(
    input [31:0]data_way0,
    input [31:0]data_way1,
    input hit1,
    output reg[31:0]data
);
    always @(*) begin
        if(hit1==0) begin
            data=data_way0;
        end else begin
            data=data_way1;
        end
    end
endmodule
