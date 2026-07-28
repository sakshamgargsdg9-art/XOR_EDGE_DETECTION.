`timescale 1ns/1ps
//======================================================
// Module: top_module.v
//======================================================

module top_module #(
    parameter MAX_SIZE    = 65536,
    parameter PIXEL_BITS  = 8,
    parameter INPUT_FILE  = "grayscale_16.mem",
    parameter OUTPUT_FILE = "edge_output.pgm"
)(
    input  wire clk,
    input  wire reset,
    input  wire [PIXEL_BITS-1:0] threshold,
    input  wire [15:0] img_width,   // Dynamic input width
    input  wire [15:0] img_height   // Dynamic input height
);

    // ---------------- Signals ----------------
    reg  [15:0] addr;
    wire [PIXEL_BITS-1:0] pixel_orig;
    wire [PIXEL_BITS-1:0] pix_left, pix_right, pix_up, pix_down;
    wire [PIXEL_BITS-1:0] edge_pixel;
    wire [15:0] addr_left, addr_right, addr_up, addr_down;
    wire write_enable;

    // ---------------- Image Memory ----------------
    image_memory #(
        .WIDTH(16),
        .HEIGHT(16),
        .PIXEL_BITS(PIXEL_BITS),
        .FILE_NAME(INPUT_FILE)
    ) img_mem (
        .clk(clk),
        .reset(reset),
        .addr(addr),
        .pixel_out(pixel_orig)
    );

    // ---------------- Dynamic Shift Units ----------------
    shift_unit sL (.addr(addr), .img_width(img_width), .img_height(img_height), .direction(2'b00), .shifted_addr(addr_left));
    shift_unit sR (.addr(addr), .img_width(img_width), .img_height(img_height), .direction(2'b01), .shifted_addr(addr_right));
    shift_unit sU (.addr(addr), .img_width(img_width), .img_height(img_height), .direction(2'b10), .shifted_addr(addr_up));
    shift_unit sD (.addr(addr), .img_width(img_width), .img_height(img_height), .direction(2'b11), .shifted_addr(addr_down));

    // Boundary Safe Neighbor Memory Lookup
    assign pix_left  = (addr_left  == 16'hFFFF) ? pixel_orig : img_mem.mem[addr_left];
    assign pix_right = (addr_right == 16'hFFFF) ? pixel_orig : img_mem.mem[addr_right];
    assign pix_up    = (addr_up    == 16'hFFFF) ? pixel_orig : img_mem.mem[addr_up];
    assign pix_down  = (addr_down  == 16'hFFFF) ? pixel_orig : img_mem.mem[addr_down];

    // ---------------- Edge Detector ----------------
    edge_detector #(.PIXEL_BITS(PIXEL_BITS)) e1 (
        .pixel_orig(pixel_orig),
        .pixel_left(pix_left),
        .pixel_right(pix_right),
        .pixel_up(pix_up),
        .pixel_down(pix_down),
        .threshold(threshold),
        .edge_pixel(edge_pixel)
    );

    // ---------------- Output Memory ----------------
    output_memory #(
        .MAX_SIZE(MAX_SIZE),
        .PIXEL_BITS(PIXEL_BITS),
        .FILE_NAME(OUTPUT_FILE)
    ) out_mem (
        .clk(clk),
        .reset(reset),
        .write_enable(write_enable),
        .addr(addr),
        .edge_pixel(edge_pixel),
        .mem_out()
    );

    // Dynamic Address Counter Bound
    always @(posedge clk or posedge reset) begin
        if (reset)
            addr <= 0;
        else if (addr < (img_width * img_height - 1))
            addr <= addr + 1;
    end

    assign write_enable = 1'b1;

endmodule