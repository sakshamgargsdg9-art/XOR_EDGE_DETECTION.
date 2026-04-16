`timescale 1ns/1ps

module testbench;

    reg clk;
    reg reset;

    // Instantiate DUT
    top_module DUT (
        .clk(clk),
        .reset(reset)
    );

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    initial begin
        reset = 1;
        #10 reset = 0;
        #5000 $finish;
    end

endmodule
