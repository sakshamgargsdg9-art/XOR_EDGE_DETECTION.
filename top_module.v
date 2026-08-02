`timescale 1ns/1ps
//======================================================
// Module: top_module.v
//======================================================

module top_module #(
    parameter MAX_SIZE    = 65536,
    parameter PIXEL_BITS  = 24,
    parameter INPUT_FILE  = "grayscale_16.mem",
    parameter OUTPUT_FILE = "edge_output.pgm"
)(
    input  wire clk,
    input  wire reset,
    input  wire [1:0]  mode_sel,
    input  wire [7:0]  threshold,
    input  wire [15:0] img_width,
    input  wire [15:0] img_height
);

    // ---------------- Signals ----------------
    reg  [15:0] addr;

    wire [PIXEL_BITS-1:0] pixel_orig;
    wire [PIXEL_BITS-1:0] pix_left, pix_right, pix_up, pix_down;

    // Output image is always an 8-bit grayscale edge map
    wire [7:0] edge_pixel;

    wire [15:0] addr_left, addr_right, addr_up, addr_down;
    wire write_enable;

    wire edge_left, edge_right, edge_up, edge_down, final_edge;

    // ---------------- Image Memory ----------------
    image_memory #(
        .MAX_SIZE(MAX_SIZE),
        .PIXEL_BITS(PIXEL_BITS),
        .FILE_NAME(INPUT_FILE)
    ) img_mem (
        .clk(clk),
        .reset(reset),
        .addr(addr),
        .pixel_out(pixel_orig)
    );

    // ---------------- Dynamic Shift Units ----------------
    shift_unit sL (
        .addr(addr),
        .img_width(img_width),
        .img_height(img_height),
        .direction(2'b00),
        .shifted_addr(addr_left)
    );

    shift_unit sR (
        .addr(addr),
        .img_width(img_width),
        .img_height(img_height),
        .direction(2'b01),
        .shifted_addr(addr_right)
    );

    shift_unit sU (
        .addr(addr),
        .img_width(img_width),
        .img_height(img_height),
        .direction(2'b10),
        .shifted_addr(addr_up)
    );

    shift_unit sD (
        .addr(addr),
        .img_width(img_width),
        .img_height(img_height),
        .direction(2'b11),
        .shifted_addr(addr_down)
    );

    // ---------------- Neighbor Pixel Lookup ----------------
    assign pix_left  = (addr_left  == 16'hFFFF) ? pixel_orig : img_mem.mem[addr_left];
    assign pix_right = (addr_right == 16'hFFFF) ? pixel_orig : img_mem.mem[addr_right];
    assign pix_up    = (addr_up    == 16'hFFFF) ? pixel_orig : img_mem.mem[addr_up];
    assign pix_down  = (addr_down  == 16'hFFFF) ? pixel_orig : img_mem.mem[addr_down];

    // ---------------- Edge Detectors ----------------
    xor_edge_detector #(.PIXEL_BITS(PIXEL_BITS)) xL (
        .pixel_orig(pixel_orig),
        .pixel_shift(pix_left),
        .mode_sel(mode_sel),
        .threshold(threshold),  // <-- FIXED: Added threshold connection
        .edge_out(edge_left)
    );

    xor_edge_detector #(.PIXEL_BITS(PIXEL_BITS)) xR (
        .pixel_orig(pixel_orig),
        .pixel_shift(pix_right),
        .mode_sel(mode_sel),
        .threshold(threshold),  // <-- FIXED: Added threshold connection
        .edge_out(edge_right)
    );

    xor_edge_detector #(.PIXEL_BITS(PIXEL_BITS)) xU (
        .pixel_orig(pixel_orig),
        .pixel_shift(pix_up),
        .mode_sel(mode_sel),
        .threshold(threshold),  // <-- FIXED: Added threshold connection
        .edge_out(edge_up)
    );

    xor_edge_detector #(.PIXEL_BITS(PIXEL_BITS)) xD (
        .pixel_orig(pixel_orig),
        .pixel_shift(pix_down),
        .mode_sel(mode_sel),
        .threshold(threshold),  // <-- FIXED: Added threshold connection
        .edge_out(edge_down)
    );

    // ---------------- Edge Combiner ----------------
    edge_combiner ec (
        .edge_left(edge_left),
        .edge_right(edge_right),
        .edge_up(edge_up),
        .edge_down(edge_down),
        .final_edge(final_edge)
    );

    // Convert to an 8-bit grayscale edge map
    assign edge_pixel = final_edge ? 8'd255 : 8'd0;

    // ---------------- Output Memory ----------------
    output_memory #(
        .MAX_SIZE(MAX_SIZE),
        .PIXEL_BITS(8),
        .FILE_NAME(OUTPUT_FILE)
    ) out_mem (
        .clk(clk),
        .reset(reset),
        .write_enable(write_enable),
        .addr(addr),
        .edge_pixel(edge_pixel),
        .mem_out()
    );

    // ---------------- Address Counter ----------------
    always @(posedge clk or posedge reset) begin
        if (reset)
            addr <= 0;
        else if (addr < (img_width * img_height - 1))
            addr <= addr + 1;
    end

    assign write_enable = 1'b1;

endmodule
