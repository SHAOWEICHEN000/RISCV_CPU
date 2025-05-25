`ifndef DATA_MEMORY_V
`define DATA_MEMORY_V
module data_memory (
    input  wire        clk,
    input  wire        rst,
    input  wire        mem_wEn,        // 1 = store, 0 = load
    input  wire [15:0]  address,        // 5-bit → 32 words
    input  wire [31:0] write_data,
    output reg  [31:0] read_data
);
    localparam RAM_DEPTH = 16;         // 32 × 4B = 128 B
    reg [31:0] memory [0:RAM_DEPTH-1];
    integer i;

    always @(posedge clk) begin
        // ---------- Reset：清空記憶體 ----------
        if (rst) begin
            for (i = 0; i < RAM_DEPTH; i = i + 1)
                memory[i] = 32'b0;
            read_data = 32'b0;
        end
        // ---------- 正常運作 ----------
        else begin
            if (mem_wEn)                      // Store
                memory[address] = write_data;
            read_data = memory[address];     // Load (下一拍取出)
        end
    end
endmodule
`endif
