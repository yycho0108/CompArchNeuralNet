## Documentation

### What did I do?

I implemented a generic feedforward nerual network in verilog, with approximated sigmoid activation function. Based on precomputed weights from a backpropagation network in Armadillo, I was able to load the parameters onto the network and verify the results for an XOR trained for XOR classification, the most basic application of the neural network demonstrating its functions.

### Why did I do it?

The operations that govern a neural network are, by nature, heavily parallel, whereas a CPU is mostly sequential. Modern machine-learning architectures take advantage of the massively parallel processing power of the GPU to accelerate the training and computing process, but [recent benchmarks](https://liu.diva-portal.org/smash/get/diva2:930724/FULLTEXT01.pdf) show that as more parallelism is required, FPGAs can outperform GPUs; indeed, unlike GPUs that require external computing interfaces, FPGAs can be a efficient and independent alternative to the task of training the neural network and computing predictions.

### How did I do this?


### Challenges

Floating Point Library
Stage-Based Computation
Matrix Multiplication and Indexing
Compiling Time
Implementing on the FPGA - ambiguous clocks, non-synthesizable FPU

### Building Upon
