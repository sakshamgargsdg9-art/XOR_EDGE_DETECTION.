SmartEdge XOR is an efficient edge detection project that explores how bitwise operations can be used to identify boundaries in 2D data. Instead of relying on traditional convolution-based filters, this approach uses the XOR operation to directly capture differences between neighboring pixels.

At its core, the idea is simple: edges occur where there is a change. By comparing adjacent values using XOR, the algorithm highlights these transitions with minimal computation. This makes the method both fast and lightweight, with a linear time complexity of O(n × m) for an n × m grid.

The project focuses on demonstrating how low-level logical operations can be leveraged to build efficient solutions for problems typically solved using heavier techniques. It is especially useful in scenarios involving binary images, grid-based systems, or resource-constrained environments.

Overall, this implementation serves as a practical example of combining algorithmic thinking with smart computation to achieve performance-efficient edge detection.


## How to Run & Test

### 1. Prerequisites & Setup
Install Icarus Verilog for simulation and Python's Image library for viewing output files:

```bash
sudo apt update
sudo apt install iverilog python3-pil -y
iverilog -o sim.out testbench.v top_module.v edge_detector.v xor_edge_detector.v edge_combiner.v shift_unit.v image_memory.v output_memory.v
vvp sim.out
# High sensitivity (detects weaker edges)
vvp sim.out +WIDTH=16 +HEIGHT=16 +THRESHOLD=30

# Moderate sensitivity
vvp sim.out +WIDTH=16 +HEIGHT=16 +THRESHOLD=70

# Testing a small 4x4 image
vvp sim.out +WIDTH=4 +HEIGHT=4 +THRESHOLD=50

python3 -c "from PIL import Image; Image.open('edge_output.pgm').save('edge_output.png')"

explorer.exe .
