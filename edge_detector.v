`timescale 1ns/1ps
//======================================================
// Module: edge_detector.v
// Description: Multi-directional Edge Detector with 
//              Variable Thresholding support.
//======================================================

module edge_detector #(
    parameter PIXEL_BITS = 8
)(
    input  wire [PIXEL_BITS-1:0] pixel_orig,
    input  wire [PIXEL_BITS-1:0] pixel_left,
    input  wire [PIXEL_BITS-1:0] pixel_right,
    input  wire [PIXEL_BITS-1:0] pixel_up,
    input  wire [PIXEL_BITS-1:0] pixel_down,
    input  wire [PIXEL_BITS-1:0] threshold,
    output wire [PIXEL_BITS-1:0] edge_pixel
);

    // Raw differences
    wire [PIXEL_BITS-1:0] raw_left  = (pixel_orig > pixel_left)  ? (pixel_orig - pixel_left)  : (pixel_left - pixel_orig);
    wire [PIXEL_BITS-1:0] raw_right = (pixel_orig > pixel_right) ? (pixel_orig - pixel_right) : (pixel_right - pixel_orig);
    wire [PIXEL_BITS-1:0] raw_up    = (pixel_orig > pixel_up)    ? (pixel_orig - pixel_up)    : (pixel_up - pixel_orig);
    wire [PIXEL_BITS-1:0] raw_down  = (pixel_orig > pixel_down)  ? (pixel_orig - pixel_down)  : (pixel_down - pixel_orig);

    // If input is binary 0 or 1, scale difference to 255
    wire [PIXEL_BITS-1:0] diff_left  = (raw_left  == 1) ? 8'd255 : raw_left;
    wire [PIXEL_BITS-1:0] diff_right = (raw_right == 1) ? 8'd255 : raw_right;
    wire [PIXEL_BITS-1:0] diff_up    = (raw_up    == 1) ? 8'd255 : raw_up;
    wire [PIXEL_BITS-1:0] diff_down  = (raw_down  == 1) ? 8'd255 : raw_down;

    // Gradient combination
    wire [PIXEL_BITS-1:0] max_horizontal = (diff_left > diff_right) ? diff_left : diff_right;
    wire [PIXEL_BITS-1:0] max_vertical   = (diff_up > diff_down)    ? diff_up   : diff_down;
    wire [PIXEL_BITS-1:0] max_grad       = (max_horizontal > max_vertical) ? max_horizontal : max_vertical;

    // Apply Threshold
    assign edge_pixel = (max_grad >= threshold) ? 8'd255 : 8'd0;

endmodule