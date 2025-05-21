module address_splitter(
    input [31:0]address,
    output reg [27:0]tag_memory,
    output reg [1:0] set_memory,
    output reg [1:0]offset_memory
);
    always @(*) begin
        tag_memory    = address[31:4];
        set_memory    = address[3:2];
        offset_memory = address[1:0];
    end
endmodule 11
