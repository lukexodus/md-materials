## Architecture Overview


MMX introduced eight 64-bit registers (MM0-MM7) that alias the mantissa portion of the x87 floating-point registers (ST0-ST7). This design decision meant MMX and x87 FPU operations cannot execute simultaneously without performance penalties due to shared register space.

The 64-bit MMX registers support packed data types that allow multiple smaller integer values to be processed in parallel:

- Packed byte: 8 elements of 8 bits each
- Packed word: 4 elements of 16 bits each
- Packed doubleword: 2 elements of 32 bits each
- Quadword: 1 element of 64 bits

