`timescale 1ns/1ps
//======================================================
// Module: shift_unit.v (Dynamic Row/Col Calculation)
//======================================================

module shift_unit (
    input  wire [15:0] addr,
    input  wire [15:0] img_width,   // Dynamic width input
    input  wire [15:0] img_height,  // Dynamic height input
    input  wire [1:0]  direction,   // 00=Left, 01=Right, 10=Up, 11=Down
    output reg  [15:0] shifted_addr
);

    reg [15:0] row;
    reg [15:0] col;
    localparam [15:0] INVALID_ADDR_MARKER = 16'hFFFF;

    always @(*) begin
        // Compute row and col dynamically based on active image width
        row = addr / img_width;
        col = addr % img_width;

        case (direction)
            // Left: Invalid if col == 0
            2'b00: shifted_addr = (col == 0)              ? INVALID_ADDR_MARKER : addr - 1; 

            // Right: Invalid if col == img_width - 1
            2'b01: shifted_addr = (col == img_width - 1)  ? INVALID_ADDR_MARKER : addr + 1;

            // Up: Invalid if row == 0
            2'b10: shifted_addr = (row == 0)              ? INVALID_ADDR_MARKER : addr - img_width;

            // Down: Invalid if row == img_height - 1
            2'b11: shifted_addr = (row == img_height - 1) ? INVALID_ADDR_MARKER : addr + img_width;

            default: shifted_addr = INVALID_ADDR_MARKER;
        endcase
    end

endmodule