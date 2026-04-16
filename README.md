# Efficient-Implementation-of-Activation-Functions-on-an-FPGA

- Hardware-efficient activation function architectures (Tanh, Sigmoid, ReLU, Leaky ReLU, ELU) on the
Nexys4 DDR FPGA
- IEEE 754 floating-point arithmetic to implement addition, subtraction, multiplication, and division.
- UART module for real-time communication between the FPGA and a Python-based interface.

### Floating Point Arithmetic 

-- Sign bit (1 bit): Indicates whether the number is positive(bit=0) or negative(bit=1).
-- Exponent (8 bits): Stores the exponent of the number in ”biased” form. The bias for the exponent in single precision is 127. The actual exponent E=exponent   bits−127
-- Mantissa (23 bits): Stores the fractional part (the significand) of the number, where the first bit is assumed to be 1 (implicit leading 1 for normalized numbers)
