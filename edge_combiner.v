//======================================================
// Module: edge_combiner.v
// Description: Combines multi-directional XOR edge outputs
//======================================================

`timescale 1ns/1ps

module edge_combiner(
    input wire edge_left,
    input wire edge_right,
    input wire edge_up,
    input wire edge_down,
    output wire final_edge
);

    // Combine all directional edges using OR
    assign final_edge = edge_left | edge_right | edge_up | edge_down;

endmodule
