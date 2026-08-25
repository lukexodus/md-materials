## Three-Address Code


Three-address code represents the most fundamental and widely-used intermediate representation form, where each instruction contains at most three operands: two sources and one destination. This constraint simplifies instruction selection and register allocation while maintaining sufficient expressiveness for complex computations.

The basic structure follows the pattern `result = operand1 operator operand2`, where each operand can be a variable, constant, or temporary. Complex expressions decompose into sequences of three-address instructions, making implicit evaluation order explicit and facilitating optimization analysis.

Instruction types encompass arithmetic operations (`t1 = a + b`), assignment statements (`x = y`), conditional and unconditional jumps (`if a < b goto L1`, `goto L2`), procedure calls (`call p, n` where n indicates parameter count), and array operations (`t1 = a[i]`, `a[i] = t2`).

Temporary variable generation handles intermediate computation results. The compiler introduces temporaries systematically, ensuring each subexpression evaluation has a designated storage location. Temporary naming schemes typically use prefixes (t1, t2, t3) to distinguish compiler-generated variables from user-defined identifiers.

Address calculation instructions support array indexing and pointer arithmetic. Multi-dimensional arrays require offset computation through linearization formulas, while pointer dereference operations translate into explicit load and store instructions with computed addresses.

Implementation considerations include temporary variable management, instruction sequence optimization, and memory layout decisions. Efficient temporary allocation minimizes register pressure, while instruction scheduling can improve pipeline utilization and cache performance.

**Key points:** Three-address code provides a uniform, analyzable representation that simplifies optimization algorithms while maintaining semantic fidelity to source language constructs through systematic decomposition of complex expressions.

