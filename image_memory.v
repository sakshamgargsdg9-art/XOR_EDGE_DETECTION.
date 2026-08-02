`timescale 1ns/1ps
//======================================================
// Module: image_memory.v 
//======================================================

module image_memory #(
    parameter MAX_SIZE    = 65536,
    parameter PIXEL_BITS  = 24,
    parameter FILE_NAME   = "binary_input.mem"   
)(
    input  wire clk,
    input  wire reset,
    input  wire [15:0] addr,
    output reg  [PIXEL_BITS-1:0] pixel_out
);

    reg [PIXEL_BITS-1:0] mem [0:MAX_SIZE-1];
    reg [8*256-1:0] runtime_file; 
    
    integer file_handle, c;
    integer file_rows;
    integer file_cols;
    integer in_word;
    integer elements_this_line;
    integer i;

    // ---------- Initialize ----------
    initial begin
        for (i = 0; i < MAX_SIZE; i = i + 1)
            mem[i] = {PIXEL_BITS{1'b0}};
        pixel_out = {PIXEL_BITS{1'b0}};

        if (!$value$plusargs("INPUT_FILE=%s", runtime_file))
            runtime_file = FILE_NAME;

        file_rows = 0;
        file_cols = 0;
        in_word   = 0;
        elements_this_line = 0;

        // PASS 1: Auto-detect rows and columns based on spaces and newlines
        file_handle = $fopen(runtime_file, "r");
        if (file_handle != 0) begin
            c = $fgetc(file_handle);
            while (c != -1 && c != 32'hFFFFFFFF) begin // Loop until EOF
                // Check for whitespace: Space(32), Tab(9), Newline(10), CR(13)
                if (c == 32 || c == 9 || c == 10 || c == 13) begin
                    in_word = 0;
                    if (c == 10) begin // When we hit a newline, log the row
                        if (elements_this_line > 0) begin
                            file_rows = file_rows + 1;
                            file_cols = elements_this_line; 
                            elements_this_line = 0;
                        end
                    end
                end else begin // It's a binary character
                    if (in_word == 0) begin
                        in_word = 1;
                        elements_this_line = elements_this_line + 1;
                    end
                end
                c = $fgetc(file_handle);
            end
            
            // Catch the final line if the file doesn't end with a blank newline
            if (elements_this_line > 0) begin
                file_rows = file_rows + 1;
                file_cols = elements_this_line;
            end
            
            $fclose(file_handle);
            $display("Auto-calculated Dimensions: %0d rows x %0d cols", file_rows, file_cols);

            // PASS 2: Read the actual binary pixel data
            // PASS 2: Read the actual hex pixel data
            $readmemh(runtime_file, mem);
            
        end else begin
            $display("FATAL ERROR: Could not open file %s", runtime_file);
        end
    end

    // ---------- Output pixel ----------
    always @(posedge clk or posedge reset) begin
        if (reset)
            pixel_out <= {PIXEL_BITS{1'b0}};
        else
            pixel_out <= mem[addr];
    end

endmodule
