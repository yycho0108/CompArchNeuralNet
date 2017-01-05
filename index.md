---
title: Verilog Neural Network
description: Generic Deep Neural Network with Synthesizable Verilog
layout: default
---

![Net](images/net.jpg)

## Links

[Proposal](https://docs.google.com/document/d/1ULqsxGpxzVEamMZO5F3Pto4A9VCm7r37K5DoMaEWpnU/edit?usp=sharing)

[Demo Video](http://www.youtube.com)

### What did I do?

I implemented a generic feedforward [Artificial Neural Network](https://en.wikipedia.org/wiki/Artificial_neural_network) in verilog, with approximated sigmoid activation function.

A neural network is a recent advance in computer science, inspired by biological interaction of neurons in humans, that simulate the procedure of thought and training via enhancing the activation of a neuron *responsible* for a certain output. These neurons act in parallel to form a layer which, when stacked together, ultimately construct a *Deep Neural Network* that can act as highly intelligent function approximators, even for non-linear functions.

Due to time constraints, I couldn't get to implement a full [Convolutional Neural Network](https://en.wikipedia.org/wiki/Convolutional_neural_network), which would be an ideal application for this kind of project given its highly parallel nature; while the initial intent was to demonstrate a digit classifier, the empirically determined compilation time was 
Based on precomputed weights from a backpropagation network in Armadillo, I was able to load the parameters onto the network and verify the results for an XOR trained for XOR classification, the most basic application of the neural network demonstrating its functions.

### Why did I do it?

The operations that govern a neural network are, by nature, heavily parallel, whereas a CPU is mostly sequential. Modern machine-learning architectures take advantage of the massively parallel processing power of the GPU to accelerate the training and computing process, but [recent benchmarks](https://liu.diva-portal.org/smash/get/diva2:930724/FULLTEXT01.pdf) show that as more parallelism is required, FPGAs can outperform GPUs; indeed, unlike GPUs that require external computing interfaces, FPGAs can be a efficient and independent alternative to the task of training the neural network and computing predictions.

### How did I do this?

Implementing an FPU library *and* building a neural network would have been beyond the scope of this project, so I used the FPU library from [here](https://github.com/arktur04/FPU). In retrospect, this particular choice of the FPU library was unfortunate since it wasn't very synthesis-friendly and caused conflicts when implementing on the FPGA.

### Challenges

Floating Point Library
Stage-Based Computation
Matrix Multiplication and Indexing
Compiling Time
Implementing on the FPGA - ambiguous clocks, non-synthesizable FPU

### Building Upon
