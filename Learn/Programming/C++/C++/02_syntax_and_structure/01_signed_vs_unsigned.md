## Signed vs Unsigned


In C++, integers can be either **signed** or **unsigned**, and this distinction affects their range and how they are represented in binary.

### 1. **Signed Integers**
   - **Signed integers** can represent both positive and negative numbers.
   - The most significant bit (MSB) in a signed integer is used to represent the sign of the number:
     - **0** for positive numbers.
     - **1** for negative numbers.
   - The binary representation of a signed integer typically uses **two's complement** format:
     - In two's complement, to represent a negative number, you invert all the bits of its positive counterpart and add 1.
     - For example, in an 8-bit system:
       - $+5$ is represented as `0000 0101`.
       - $-5$ is represented as `1111 1011` (invert `0000 0101` to `1111 1010` and add 1 to get `1111 1011`).
   - **Range**: For an $n$-bit signed integer:
     - Minimum value: $-2^{n-1}$
     - Maximum value: $2^{n-1} - 1$
   - Example: An 8-bit signed integer can range from $-128$ (`1000 0000`) to $127$ (`0111 1111`).

### 2. **Unsigned Integers**
   - **Unsigned integers** can only represent non-negative numbers.
   - All bits are used to represent the magnitude of the number, with no bit reserved for the sign.
   - **Range**: For an $n$-bit unsigned integer:
     - Minimum value: $0$
     - Maximum value: $2^n - 1$
   - Example: An 8-bit unsigned integer can range from $0$ (`0000 0000`) to $255$ (`1111 1111`).

### 3. **Binary Representation Examples**

#### **8-bit Signed Integer**
- **+5**: `0000 0101`
- **-5**: `1111 1011` (Two's complement of `0000 0101`)

#### **8-bit Unsigned Integer**
- **5**: `0000 0101`
- **255**: `1111 1111` (Highest possible value for 8-bit unsigned)

**Summary of Key Differences**:
- **Signed** integers use the MSB for the sign and can represent both positive and negative values.
- **Unsigned** integers use all bits for magnitude, allowing them to represent larger positive numbers but no negative numbers.

***
