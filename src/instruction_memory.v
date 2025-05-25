`ifndef INSTRUCTION_MEMORY_V
`define INSTRUCTION_MEMORY_V
module instruction_memory(
    input clk,
    input [15:0] i_address, // Assuming this is a byte address from the PC
    output reg [31:0] i_read_data
);

    // RAM_DEPTH = 1 << (Address_Width - 2) for word-aligned memory
    // (16-bit byte address means 14 bits for word address)
    localparam RAM_DEPTH = 1 << 14; // 16384 words * 4 bytes/word = 65536 bytes (64KB)
    reg [31:0] memory[0:RAM_DEPTH-1]; // Declares a memory of 16384 32-bit words

    always @(posedge clk) begin
        // For byte-addressed PC, divide by 4 (right shift by 2) to get the word index
        // This effectively ignores the lowest 2 bits (byte offset) of the address.
        i_read_data <= memory[i_address[15:2]];
    end

    initial begin
        // Loads program.hex into the 'memory' array
        // Make sure program.hex contains 32-bit hexadecimal values for instructions
        $readmemh("program.hex", memory);
    end

endmodule
`endif
