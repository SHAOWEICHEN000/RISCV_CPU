`timescale 1ns / 1ps

module Data_multiplexer_tb;
    reg clk;
    reg [31:0] data_way0;
    reg [31:0] data_way1;
    reg hit1;
    wire [31:0] data;

    Data_multiplexer uut (
        .clk(clk),
        .data_way0(data_way0),
        .data_way1(data_way1),
        .hit1(hit1),
        .data(data)
    );

    // Clock generator
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    task display_status;
        $display("T=%0t | hit1 = %b | data = %h", $time, hit1, data);
    endtask

    initial begin
        // test hit1 = 0 → output  data_way0
        hit1 = 0;
        data_way1 = 32'h12345678;
        data_way0 = 32'h22222222;
        #10; display_status();

        // test hit1 = 1 → output data_way1
        hit1 = 1;
        #10; display_status();

        $finish;
    end
endmodule
