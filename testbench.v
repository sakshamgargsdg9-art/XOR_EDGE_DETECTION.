`timescale 1ns/1ps

module testbench;

    reg clk;
    reg reset;
    reg [7:0] threshold;
    reg [15:0] img_width;
    reg [15:0] img_height;

    integer parsed_thresh, parsed_w, parsed_h;

    // Instantiate DUT
    top_module #(
        .PIXEL_BITS(8)
    ) DUT (
        .clk(clk),
        .reset(reset),
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
        
        // Defaults
        threshold  = 8'd30;
        img_width  = 16'd16;
        img_height = 16'd16;

        // Command line overrides
        if ($value$plusargs("THRESHOLD=%d", parsed_thresh)) threshold = parsed_thresh[7:0];
        if ($value$plusargs("WIDTH=%d",     parsed_w))      img_width = parsed_w[15:0];
        if ($value$plusargs("HEIGHT=%d",    parsed_h))      img_height = parsed_h[15:0];

        #20 reset = 0;

        // Dynamic completion check
        wait(DUT.addr == (img_width * img_height - 1));
        #20;

        DUT.out_mem.export_pgm_image(threshold, img_width, img_height);
        
        $finish;
    end

endmodule