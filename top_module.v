`timescale 1ns/1ps
//======================================================
// Module: top_module.v (Verilog-2005 compatible)
//======================================================

module top_module #(
    parameter WIDTH       = 16,
    parameter HEIGHT      = 16,
    parameter PIXEL_BITS  = 1,
    parameter INPUT_FILE  = "checkerboard_16.mem",
    parameter OUTPUT_FILE = "edge_output.mem"
)(
    input  wire clk,
    input  wire reset
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
        .WIDTH(WIDTH),
        .HEIGHT(HEIGHT),
        .PIXEL_BITS(PIXEL_BITS),
        .FILE_NAME(INPUT_FILE)
    ) img_mem (
        .clk(clk),
        .reset(reset),
        .addr(addr),
        .pixel_out(pixel_orig)
    );

    // ---------------- Shift Units ----------------
    shift_unit #(.WIDTH(WIDTH), .HEIGHT(HEIGHT)) sL (.addr(addr), .direction(2'b00), .shifted_addr(addr_left));
    shift_unit #(.WIDTH(WIDTH), .HEIGHT(HEIGHT)) sR (.addr(addr), .direction(2'b01), .shifted_addr(addr_right));
    shift_unit #(.WIDTH(WIDTH), .HEIGHT(HEIGHT)) sU (.addr(addr), .direction(2'b10), .shifted_addr(addr_up));
    shift_unit #(.WIDTH(WIDTH), .HEIGHT(HEIGHT)) sD (.addr(addr), .direction(2'b11), .shifted_addr(addr_down));

    // ---------------- Neighbor Pixel Reads ----------------
    assign pix_left  = img_mem.mem[addr_left];
    assign pix_right = img_mem.mem[addr_right];
    assign pix_up    = img_mem.mem[addr_up];
    assign pix_down  = img_mem.mem[addr_down];

    // ---------------- Edge Detector ----------------
    edge_detector #(.PIXEL_BITS(PIXEL_BITS)) e1 (
        .pixel_orig(pixel_orig),
        .pixel_left(pix_left),
        .pixel_right(pix_right),
        .pixel_up(pix_up),
        .pixel_down(pix_down),
        .edge_pixel(edge_pixel)
    );

    // ---------------- Output Memory ----------------
    output_memory #(
    .WIDTH(WIDTH),
    .HEIGHT(HEIGHT),
    .FILE_NAME(OUTPUT_FILE)
) out_mem (
    .clk(clk),
    .reset(reset),
    .write_enable(write_enable),
    .addr(addr),
    .edge_pixel(edge_pixel[0]), // FIXED: 1-bit value
    .mem_out()
);

    // ---------------- Address Counter ----------------
    initial addr = 0;
    always @(posedge clk or posedge reset) begin
        if (reset)
            addr <= 0;
        else if (addr < (WIDTH*HEIGHT - 1))
            addr <= addr + 1;
    end

    assign write_enable = 1'b1; // always write each clock

endmodule
