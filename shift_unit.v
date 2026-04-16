// `timescale 1ns/1ps
// //======================================================
// // Module: shift_unit.v (Verilog-2005 compatible)
// //======================================================

// module shift_unit #(
//     parameter WIDTH = 16,
//     parameter HEIGHT = 16
// )(
//     input  wire [15:0] addr,
//     input  wire [1:0] direction,     // 00=Left, 01=Right, 10=Up, 11=Down
//     output reg  [15:0] shifted_addr
// );

//     reg [15:0] row;
//     reg [15:0] col;

//     always @(*) begin
//         row = addr / WIDTH;
//         col = addr % WIDTH;

//         case (direction)
//             2'b00: shifted_addr = (col == 0)        ? addr : addr - 1;      // Left
//             2'b01: shifted_addr = (col == WIDTH-1)  ? addr : addr + 1;      // Right
//             2'b10: shifted_addr = (row == 0)        ? addr : addr - WIDTH;  // Up
//             2'b11: shifted_addr = (row == HEIGHT-1) ? addr : addr + WIDTH;  // Down
//             default: shifted_addr = addr;
//         endcase
//     end

// endmodule

`timescale 1ns/1ps
//======================================================
// Module: shift_unit.v (Verilog-2005 compatible, Boundary Fixed)
// Description: Generates neighbor address or Invalid Marker.
//======================================================

module shift_unit #(
    parameter WIDTH = 16,
    parameter HEIGHT = 16
)(
    input  wire [15:0] addr,
    input  wire [1:0] direction,     // 00=Left, 01=Right, 10=Up, 11=Down
    output reg  [15:0] shifted_addr // Variable name retained
);

    reg [15:0] row;
    reg [15:0] col;
    localparam [15:0] INVALID_ADDR_MARKER = 16'hFFFF;

    always @(*) begin
        row = addr / WIDTH;
        col = addr % WIDTH;

        case (direction)
            // Left: Invalid if col == 0. Else, addr - 1.
            2'b00: shifted_addr = (col == 0)          ? INVALID_ADDR_MARKER : addr - 1; 

            // Right: Invalid if col == WIDTH-1. Else, addr + 1.
            2'b01: shifted_addr = (col == WIDTH - 1)  ? INVALID_ADDR_MARKER : addr + 1;

            // Up: Invalid if row == 0. Else, addr - WIDTH.
            2'b10: shifted_addr = (row == 0)          ? INVALID_ADDR_MARKER : addr - WIDTH;

            // Down: Invalid if row == HEIGHT-1. Else, addr + WIDTH.
            2'b11: shifted_addr = (row == HEIGHT - 1) ? INVALID_ADDR_MARKER : addr + WIDTH;

            default: shifted_addr = INVALID_ADDR_MARKER;
        endcase
    end

endmodule