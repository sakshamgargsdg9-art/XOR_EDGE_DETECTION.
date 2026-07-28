import numpy as np
from PIL import Image, ImageEnhance
import os

# --- Configuration ---
# This must match the OUTPUT_FILE parameter in your top_module.v
input_file = "edge_output.mem"
output_png = "edge_result.png"

# --- Main Processing ---
if not os.path.exists(input_file):
    print(f"❌ ERROR: Could not find '{input_file}'")
    print("   Make sure you ran the Verilog simulation first!")
    exit()

print(f"📂 Reading {input_file}...")

# Read the .mem file
try:
    with open(input_file, "r") as f:
        lines = [line.strip() for line in f if line.strip()]

    # Parse space-separated values into an integer matrix
    data = [list(map(int, line.split())) for line in lines]
    pixels = np.array(data, dtype=np.uint8)

    # Auto-detect dimensions
    HEIGHT, WIDTH = pixels.shape
    print(f"📏 Detected image size: {WIDTH}x{HEIGHT}")

    # Convert 0/1 to 0/255 (Black/White)
    # 0 becomes 0 (Black), 1 becomes 255 (White)
    pixels = pixels * 255

    # --- Save Image ---
    img = Image.fromarray(pixels, mode="L")
    img.save(output_png)
    print(f"✅ SUCCESS: Image saved as '{output_png}'")

except Exception as e:
    print(f"❌ ERROR processing file: {e}")
    print("   Ensure the .mem file contains only space-separated 0s and 1s.")