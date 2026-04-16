// `timescale 1ns/1ps
// //======================================================
// // Module: edge_detector.v
// // Description: Simple XOR-based edge detector
// //======================================================

// module edge_detector #(
//     parameter PIXEL_BITS = 1
// )(
//     input  wire [PIXEL_BITS-1:0] pixel_orig,
//     input  wire [PIXEL_BITS-1:0] pixel_left,
//     input  wire [PIXEL_BITS-1:0] pixel_right,
//     input  wire [PIXEL_BITS-1:0] pixel_up,
//     input  wire [PIXEL_BITS-1:0] pixel_down,
//     output wire [PIXEL_BITS-1:0] edge_pixel
// );

//     // Compute difference between pixel and neighbors
//     wire [PIXEL_BITS-1:0] diff_left;
//     wire [PIXEL_BITS-1:0] diff_right;
//     wire [PIXEL_BITS-1:0] diff_up;
//     wire [PIXEL_BITS-1:0] diff_down;

//     assign diff_left  = pixel_orig ^ pixel_left;
//     assign diff_right = pixel_orig ^ pixel_right;
//     assign diff_up    = pixel_orig ^ pixel_up;
//     assign diff_down  = pixel_orig ^ pixel_down;

//     // Combine all differences into one edge output
//     assign edge_pixel = diff_left | diff_right | diff_up | diff_down;

// endmodule


`timescale 1ns/1ps
//======================================================
// Module: edge_detector.v
// Description: Multi-directional XOR-based edge detector
//              (Binary Mode)
//======================================================

module edge_detector #(
    parameter PIXEL_BITS = 1 // Set to 1 for Binary Mode
)(
    // Current pixel and its four immediate neighbors
    input  wire [PIXEL_BITS-1:0] pixel_orig,
    input  wire [PIXEL_BITS-1:0] pixel_left,
    input  wire [PIXEL_BITS-1:0] pixel_right,
    input  wire [PIXEL_BITS-1:0] pixel_up,
    input  wire [PIXEL_BITS-1:0] pixel_down,
    // Final combined edge result (1-bit)
    output wire [PIXEL_BITS-1:0] edge_pixel
);

    // Compute difference (edge detection) between pixel and each neighbor using XOR
    wire [PIXEL_BITS-1:0] diff_left;
    wire [PIXEL_BITS-1:0] diff_right;
    wire [PIXEL_BITS-1:0] diff_up;
    wire [PIXEL_BITS-1:0] diff_down;

    // Operation: edge = original XOR shifted
    assign diff_left  = pixel_orig ^ pixel_left;
    assign diff_right = pixel_orig ^ pixel_right;
    assign diff_up    = pixel_orig ^ pixel_up;
    assign diff_down  = pixel_orig ^ pixel_down;

    // Final Output: final_edge = edge_left OR edge_right OR edge_up OR edge_down
    // If an edge is detected in ANY direction, the output edge_pixel is HIGH (1).
    assign edge_pixel = diff_left | diff_right | diff_up | diff_down;

endmodule