// `timescale 1ns/1ps
// //======================================================
// // Module: output_memory.v (Verilog-2005 compatible)
// //======================================================

// module output_memory #(
//     parameter WIDTH = 8,
//     parameter HEIGHT = 8,
//     parameter FILE_NAME = "edge_output.mem"
// )(
//     input  wire clk,
//     input  wire reset,
//     input  wire write_enable,
//     input  wire [15:0] addr,
//     input  wire edge_pixel,
//     output reg  [0:0] mem_out
// );

//     reg [0:0] mem [0:(WIDTH*HEIGHT)-1];
//     integer i;

//     // ---------- Initialize ----------
//     initial begin
//         for (i = 0; i < WIDTH*HEIGHT; i = i + 1)
//             mem[i] = 1'b0;
//         mem_out = 1'b0;
//     end

//     // ---------- Write edges ----------
//     always @(posedge clk or posedge reset) begin
//         if (reset)
//             mem_out <= 1'b0;
//         else if (write_enable) begin
//             mem[addr] <= edge_pixel;
//             mem_out   <= edge_pixel;
//         end
//     end

//     // ---------- Save at simulation end ----------
//     initial begin
//         // Wait until simulation ends
//         #5000;   // enough time for full image
//         $writememb(FILE_NAME, mem);
//         $display("Edge map saved to: %s", FILE_NAME);
//     end

// endmodule
`timescale 1ns/1ps
//======================================================
// Module: output_memory.v (Verilog-2005 compatible)
// Description: Synchronous write memory for the 1-bit 
//              edge map. Uses delayed initial block for file output.
//======================================================

module output_memory #(
    parameter WIDTH      = 8,
    parameter HEIGHT     = 8,
    parameter PIXEL_BITS = 1,
    parameter FILE_NAME  = "edge_output.mem"
)(
    input  wire clk,
    input  wire reset,
    input  wire write_enable,
    input  wire [15:0] addr,
    // Input is a single bit edge pixel (0 or 1)
    input  wire [PIXEL_BITS-1:0] edge_pixel, 
    // Output for monitoring the currently written data
    output reg  [PIXEL_BITS-1:0] mem_out 
);

    reg [PIXEL_BITS-1:0] mem [0:(WIDTH*HEIGHT)-1];
    integer i;

    // ---------- Initialization (Runs once at t=0) ----------
    initial begin
        // Initialize memory and output to 0
        for (i = 0; i < WIDTH*HEIGHT; i = i + 1)
            mem[i] = {PIXEL_BITS{1'b0}};
        mem_out = {PIXEL_BITS{1'b0}};
    end

    // ---------- Synchronous Write Logic (Runs on clk/reset) ----------
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            // Reset output (and all memory for simulation)
            for (i = 0; i < WIDTH*HEIGHT; i = i + 1)
                mem[i] <= {PIXEL_BITS{1'b0}};
            mem_out <= {PIXEL_BITS{1'b0}};
        end else if (write_enable) begin
            // Synchronous write
            mem[addr] <= edge_pixel;
            mem_out   <= edge_pixel; 
        end
    end

    // ---------- Save at simulation end (Verilog-2005 Workaround) ----------
    initial begin
        // WARNING: The delay (#5000) MUST be long enough for the entire image 
        // processing cycle to complete in the testbench. Adjust as needed.
        #5000; 
        $writememb(FILE_NAME, mem);
        $display("Edge map saved to: %s", FILE_NAME);
        // Optional: Stop the simulation after writing the file
        //$finish;
    end

endmodule