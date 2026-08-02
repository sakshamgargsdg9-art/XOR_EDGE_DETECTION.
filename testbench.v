`timescale 1ns/1ps

module testbench;

    reg clk;
    reg reset;
    reg [1:0] mode_sel;
    reg [7:0] threshold;
    reg [15:0] img_width;
    reg [15:0] img_height;

    integer parsed_mode, parsed_thresh;

    // Instantiate DUT
    top_module #(
        .PIXEL_BITS(24) 
    ) DUT (
        .clk(clk),
        .reset(reset),
        .mode_sel(mode_sel),
        .threshold(threshold),
        .img_width(img_width),
        .img_height(img_height)
    );

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    initial begin
        reset = 1;
        
        mode_sel  = 2'b00; // Defaulting to Binary mode (00)
        threshold = 8'd30;
        
        // Let image_memory's initial block auto-calculate the file shape
        #1; 
        
        // Pull the dimensions automatically found by the character scanner
        img_height = DUT.img_mem.file_rows;
        img_width  = DUT.img_mem.file_cols;

        // Fail-safe
        if (img_width === 16'bx || img_height === 16'bx || img_width == 0 || img_height == 0) begin
            $display("FATAL ERROR: Invalid Dimensions. Check your input file.");
            $finish;
        end

        if ($value$plusargs("MODE=%d",      parsed_mode))   mode_sel = parsed_mode[1:0];
        if ($value$plusargs("THRESHOLD=%d", parsed_thresh)) threshold = parsed_thresh[7:0];

        #20 reset = 0;

        // Will dynamically halt based on auto-calculated grid
        wait(DUT.addr == (img_width * img_height - 1));
        #20;

        // Pass mode_sel along with threshold, width, and height to match the new task signature
        DUT.out_mem.export_pgm_image(mode_sel, threshold, img_width, img_height);
        
        $finish;
    end

endmodule
