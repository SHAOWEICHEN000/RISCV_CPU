`timescale 1ns / 1ps
module address_splitter_tb;
reg clk;
reg  [31:0]address;
wire [27:0]tag_memory;
wire [1:0] set_memory;
wire [1:0]offset_memory;
address_splitter address_splitter(
    .clk(clk),
    .address(address),
    .tag_memory(tag_memory),
    .set_memory(set_memory),
    .offset_memory(offset_memory)
);
    // Clock generator
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    task display_status;
        $display("T=%0t | address = %b | tag_memory = %b | set_memory=%b | offset_memory =%b", $time, address, tag_memory,set_memory,offset_memory);
    endtask
    
    initial begin
        address=32'hfffffffa;
        #10 display_status();
        $finish;
    end
endmodule
