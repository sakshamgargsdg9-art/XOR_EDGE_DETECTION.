//======================================================
// Module: xor_edge_detector.v
// Description: Computes XOR-based edge detection
// Supports Binary, Grayscale (RGB→Gray), and Per-channel RGB
//======================================================
`timescale 1ns/1ps

module xor_edge_detector #(
    parameter PIXEL_BITS = 24
)(
    input wire [PIXEL_BITS-1:0] pixel_orig,   // Original pixel
    input wire [PIXEL_BITS-1:0] pixel_shift,  // Neighbor pixel
    input wire [1:0] mode_sel,                // 00=Binary, 01=Grayscale, 10=Per-channel
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

    // Channel-wise XOR
    wire [7:0] xorR = R1 ^ R2;
    wire [7:0] xorG = G1 ^ G2;
    wire [7:0] xorB = B1 ^ B2;

    // Grayscale XOR
    wire [7:0] xorGray = gray1 ^ gray2;

    // Binary XOR (if using 1-bit pixels)
    wire binary_xor = pixel_orig[0] ^ pixel_shift[0];

    // Mode-based output
    always @(*) begin
        case (mode_sel)
            2'b00: edge_out = binary_xor;                      // Binary
            2'b01: edge_out = |xorGray;                        // Grayscale
            2'b10: edge_out = |(xorR | xorG | xorB);           // Per-channel
            default: edge_out = 0;
        endcase
    end

endmodule
