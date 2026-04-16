# Efficient-Implementation-of-Activation-Functions-on-an-FPGA

- Hardware-efficient activation function architectures (Tanh, Sigmoid, ReLU, Leaky ReLU, ELU) on the
Nexys4 DDR FPGA.
- IEEE 754 floating-point arithmetic to implement addition, subtraction, multiplication, and division.
- UART module for real-time communication between the FPGA and a Python-based interface.

### Floating Point Arithmetic 

- Sign bit (1 bit): Indicates whether the number is positive(bit=0) or negative(bit=1).
- Exponent (8 bits): Stores the exponent of the number in ”biased” form. The bias for the exponent in single precision is 127. The actual exponent E=exponent   bits−127
- Mantissa (23 bits): Stores the fractional part (the significand) of the number, where the first bit is assumed to be 1 (implicit leading 1 for normalized numbers)

- A detailed analysis of the precision of floating-point numbers and hardware requirements was performed for corresponding precision bits. Finally, 8 bits of mantissa were chosen, which is a balance of hardware requirements and precision.

### Implementation Algorithm

- Tanh(x) :
  - The input x (ranging from 0 to 3, as beyond this range the values become nearly constant) was quantized to the required number of levels, in this case, 7 bits (128 levels)
  -  The quantized input is rounded off to the nearest quantization level and encoded into 7 bits.
  -  The tanh value of the quantized value is computed and is represented as a 32-bit floating-point number with 8 precision bits for mantissa.
  -  The minimal logic expression is derived using the Quine-McKluskey algorithm using Python.
  -  The other activation functions are implemented using the same algorithm with changes in input range and offset.
 
- The division is performed using the Newton-Raphson Algorithm,  where the reciprocal of the divisor is computed and then multiplied by the
dividend to get the division result.

### Neural Network model

- A fully connected neural network architecture was trained on the BON EEG Dataset for
binary classification of epileptic and non-epileptic EEG signals.
- The BONEEG dataset consists of 5 sets of 100 signals each. Each EEG signal is a 23.6-second segment that was recorded with a sampling rate of 173.61 Hz. Each subset has 4097 data points per EEG signal.

### Final conclusions

- The output values were accurate to the third decimal place and were a good approximation to the original value. The results were
verified for all the 5 activation functions along with the reception and transmission of input and output data.
- Power consumption was optimized for a total of 0.122 W on-chip power utilisation with 21% Dynamic Power.
- By utilizing the FPGA, these non-linear functions are optimized for efficient computation using combinational digital design. A modularized black-box interface for these activation functions ensures seamless integration with more complex designs, such as deep neural networks and CNN architectures
on an FPGA.
- This approach strikes a balance between accuracy and hardware resource utilization, enabling the deployment of advanced machine learning models in resource-constrained environments.

### Future Scope (to be implemented)

- Extend support to newer activation functions like Swish, GELU, or Softplus, which are used in state-of-the-art models.
- Implement full neural network layers (e.g., convolution, normalization, pooling) alongside activation functions to create fully accelerated hardware
models.
- Adapt FPGAs-based implementations to support attention mechanisms used in transformers, as these dominate modern AI architectures.
- Pipelining techniques to improve latency and achieve high clock rates for faster inference.
- Optimize activation function implementations for specific domains such as Image processing, NLP etc.

