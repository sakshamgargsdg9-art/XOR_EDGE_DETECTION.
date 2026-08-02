//======================================================
// Module: xor_edge_detector.v
// Description: Computes threshold-based edge detection
// Supports Binary, Grayscale (RGB→Gray), and Per-channel RGB
//======================================================
`timescale 1ns/1ps

module xor_edge_detector #(
    parameter PIXEL_BITS = 24
)(
    input wire [PIXEL_BITS-1:0] pixel_orig,   // Original pixel
    input wire [PIXEL_BITS-1:0] pixel_shift,  // Neighbor pixel
    input wire [1:0] mode_sel,                // 00=Binary, 01=Grayscale, 10=Per-channel
    input wire [7:0] threshold,               // Threshold input
    output reg edge_out
);

    // Split RGB channels if needed
    wire [7:0] R1 = pixel_orig[23:16];
    wire [7:0] G1 = pixel_orig[15:8];
    wire [7:0] B1 = pixel_orig[7:0];
    wire [7:0] R2 = pixel_shift[23:16];
    wire [7:0] G2 = pixel_shift[15:8];
    wire [7:0] B2 = pixel_shift[7:0];

    // Grayscale conversion (approximation)
    wire [7:0] gray1 = (R1*30 + G1*59 + B1*11) / 100;
    wire [7:0] gray2 = (R2*30 + G2*59 + B2*11) / 100;

    // Absolute differences for channels
    wire [7:0] diffR = (R1 > R2) ? (R1 - R2) : (R2 - R1);
    wire [7:0] diffG = (G1 > G2) ? (G1 - G2) : (G2 - G1);
    wire [7:0] diffB = (B1 > B2) ? (B1 - B2) : (B2 - B1);

    // Absolute difference for grayscale
    wire [7:0] diffGray = (gray1 > gray2) ? (gray1 - gray2) : (gray2 - gray1);

    // Binary difference (if using 1-bit pixels, scale to 255 if different)
    wire binary_diff = pixel_orig[0] ^ pixel_shift[0];
    wire [7:0] diffBinary = binary_diff ? 8'd255 : 8'd0;

    // Mode-based threshold evaluation
    always @(*) begin
        case (mode_sel)
            2'b00:   edge_out = (diffBinary >= threshold) ? 1'b1 : 1'b0; // Binary
            2'b01:   edge_out = (diffGray   >= threshold) ? 1'b1 : 1'b0; // Grayscale
            2'b10:   edge_out = ((diffR >= threshold) || (diffG >= threshold) || (diffB >= threshold)) ? 1'b1 : 1'b0; // Per-channel RGB
            default: edge_out = 1'b0;
        endcase
    end

endmodule
