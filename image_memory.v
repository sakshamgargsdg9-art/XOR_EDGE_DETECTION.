`timescale 1ns/1ps
//======================================================
// Module: image_memory.v  (clean Verilog-2005 version)
// Description: Loads pixels from .mem file at runtime
//              Uses +INPUT_FILE=<filename>
//======================================================

module image_memory #(
    parameter WIDTH       = 8,
    parameter HEIGHT      = 8,
    parameter PIXEL_BITS  = 24,
    parameter FILE_NAME   = "image_input.mem"   // default
)(
    input  wire clk,
    input  wire reset,
    input  wire [15:0] addr,
    output reg  [PIXEL_BITS-1:0] pixel_out
);

    reg [PIXEL_BITS-1:0] mem [0:(WIDTH*HEIGHT)-1];
    reg [8*256-1:0] runtime_file;  // holds filename text
    integer i;

    // ---------- Initialize ----------
    initial begin
        // zero memory to avoid X
        for (i = 0; i < WIDTH*HEIGHT; i = i + 1)
            mem[i] = {PIXEL_BITS{1'b0}};
        pixel_out = {PIXEL_BITS{1'b0}};

        // read runtime filename
        if (!$value$plusargs("INPUT_FILE=%s", runtime_file))
            runtime_file = FILE_NAME;

        $display("Loading image from file: %s", runtime_file);
        $readmemh(runtime_file, mem);
    end

    // ---------- Output pixel ----------
    always @(posedge clk or posedge reset) begin
        if (reset)
            pixel_out <= {PIXEL_BITS{1'b0}};
        else
            pixel_out <= mem[addr];
    end

endmodule