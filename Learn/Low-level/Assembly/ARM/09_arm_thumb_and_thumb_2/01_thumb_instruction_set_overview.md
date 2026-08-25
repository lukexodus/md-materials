## Thumb Instruction Set Overview


Thumb is a compressed instruction set architecture designed by ARM to improve code density while maintaining reasonable performance. Introduced with the ARMv4T architecture, Thumb represents a subset of the full 32-bit ARM instruction set encoded into 16-bit instructions.

The primary motivation for Thumb was to address memory constraints and cost considerations in embedded systems. By reducing instruction size from 32 bits to 16 bits, Thumb achieves approximately 65-70% of the code size of equivalent ARM code while delivering roughly 85-90% of the performance. This trade-off made ARM processors more viable for applications with limited memory bandwidth or storage capacity.

Thumb instructions operate on a restricted register set, primarily using registers R0-R7 (low registers), though some instructions can access high registers R8-R15. The instruction set includes common operations such as data processing, load/store, branches, and basic arithmetic, but with reduced flexibility compared to full ARM instructions.

