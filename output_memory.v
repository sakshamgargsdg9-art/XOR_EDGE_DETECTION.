`timescale 1ns/1ps
//======================================================
// Module: output_memory.v
//======================================================

module output_memory #(
    parameter MAX_SIZE   = 65536,
    parameter PIXEL_BITS = 8,
    parameter FILE_NAME  = "edge_output.pgm"
)(
    input  wire clk,
    input  wire reset,
    input  wire write_enable,
    input  wire [15:0] addr,
    input  wire [PIXEL_BITS-1:0] edge_pixel, 
    output reg  [PIXEL_BITS-1:0] mem_out 
);

    reg [PIXEL_BITS-1:0] mem [0:MAX_SIZE-1];
    reg [31:0] edge_count;
    integer i, file_handle;

    initial begin
        for (i = 0; i < MAX_SIZE; i = i + 1)
            mem[i] = {PIXEL_BITS{1'b0}};
        mem_out = {PIXEL_BITS{1'b0}};
        edge_count = 0;
    end

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            mem_out    <= {PIXEL_BITS{1'b0}};
            edge_count <= 0;
        end else if (write_enable) begin
            mem[addr] <= edge_pixel;
            mem_out   <= edge_pixel;
            
            if (edge_pixel > 0)
                edge_count <= edge_count + 1;
        end
    end

    // Task accepts dynamic width and height
    task export_pgm_image(
        input [PIXEL_BITS-1:0] threshold_val,
        input [15:0] img_w,
        input [15:0] img_h
    );
        integer total_pixels;
        begin
            total_pixels = img_w * img_h;
            file_handle = $fopen(FILE_NAME, "w");
            if (file_handle) begin
                $fwrite(file_handle, "P2\n");
                $fwrite(file_handle, "%0d %0d\n", img_w, img_h);
                $fwrite(file_handle, "%0d\n", (1 << PIXEL_BITS) - 1);

                for (i = 0; i < total_pixels; i = i + 1) begin
                    $fwrite(file_handle, "%0d ", mem[i]);
                    if ((i + 1) % img_w == 0)
                        $fwrite(file_handle, "\n");
                end
                $fclose(file_handle);
            end

            $display("========================================");
            $display("         EDGE DETECTION REPORT          ");
            $display("========================================");
            $display(" Image Grid Size   : %0d x %0d", img_w, img_h);
            $display(" Selected Threshold : %0d", threshold_val);
            $display(" Total Edge Pixels  : %0d / %0d", edge_count, total_pixels);
            $display(" Edge Ratio         : %0f %%", (edge_count * 100.0) / total_pixels);
            $display(" Saved Output Image : %s", FILE_NAME);
            $display("========================================");
        end
    endtask

endmodule