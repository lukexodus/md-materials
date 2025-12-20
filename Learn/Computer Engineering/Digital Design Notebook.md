## IEEE 754

IEEE 754 is a widely used standard for representing floating-point numbers in computers. Let's go step-by-step through how to **convert a decimal number into IEEE 754 format** and then **convert it back from IEEE 754 format to decimal**.

### IEEE 754 Standard Format:
The standard 32-bit (single precision) floating-point representation has three main parts:
1. **Sign bit (S)**: 1 bit that determines if the number is positive (0) or negative (1).
2. **Exponent (E)**: 8 bits for the exponent, stored in a **biased** form (with a bias of 127 for single precision).
3. **Mantissa/Fraction (M)**: 23 bits representing the significant digits of the number.

The value of the number is calculated as:
$$ \text{Value} = (-1)^S \times (1 + M) \times 2^{E - 127} $$

### Step 1: Decimal to IEEE 754 Conversion
Let's convert the decimal number 12.75 into IEEE 754 format.

#### Step-by-Step Conversion:
1. **Sign Bit (S)**: Since 12.75 is positive, the sign bit is $S = 0$.

2. **Convert to Binary**:
   - Convert the integer part (12) and fractional part (0.75) separately.
   - Integer part 12: $12_{10} = 1100_2$.
   - Fractional part 0.75: $0.75_{10} = 0.11_2$ (multiply by 2 and take the integer part).

   So, $12.75_{10} = 1100.11_2$.

3. **Normalize the Binary Number**:
   - In normalized scientific notation, $1100.11_2 = 1.10011_2 \times 2^3$.
   - The exponent is 3, and the mantissa is the fractional part after the decimal point ($10011$).

4. **Exponent (E)**: 
   - Add the bias (127) to the exponent (3).
   - $E = 127 + 3 = 130$.
   - Convert 130 to an 8-bit binary: $130_{10} = 10000010_2$.

5. **Mantissa (M)**:
   - The fractional part of the normalized number is $10011$, which fills the first 5 bits.
   - Pad the remaining bits with zeros to make it 23 bits: $10011000000000000000000_2$.

6. **Final IEEE 754 Representation**:
   - Sign: $0$
   - Exponent: $10000010$
   - Mantissa: $10011000000000000000000$

   Putting it together:
   $$ 0 \ 10000010 \ 10011000000000000000000_2 $$

   In hexadecimal, the IEEE 754 representation is:
   $$ 41460000_{16} $$

### Step 2: IEEE 754 to Decimal Conversion
Now, let's reverse the process by converting the IEEE 754 number back to decimal. We'll use the same number: $0 \ 10000010 \ 10011000000000000000000_2$.

#### Step-by-Step Conversion:
1. **Extract the Sign (S)**: The first bit is 0, so the sign is positive.

2. **Extract the Exponent (E)**:
   - The next 8 bits are $10000010_2 = 130_{10}$.
   - To get the actual exponent, subtract the bias (127): $130 - 127 = 3$.

3. **Extract the Mantissa (M)**:
   - The remaining 23 bits are $10011000000000000000000_2$.
   - This represents $1.10011_2$ in normalized form (1 is implied).

4. **Calculate the Decimal Value**:
   - The number is represented as:
     $$ (1 + 0.10011_2) \times 2^3 $$
   - Convert the fractional part $0.10011_2$ to decimal:
     $$ 0.10011_2 = 1 \times 2^{-1} + 0 \times 2^{-2} + 0 \times 2^{-3} + 1 \times 2^{-4} + 1 \times 2^{-5} = 0.59375_{10} $$
   - So, the full number is:
     $$ (1 + 0.59375) \times 2^3 = 1.59375 \times 8 = 12.75 $$

Thus, the IEEE 754 number $0 \ 10000010 \ 10011000000000000000000_2$ converts back to $12.75_{10}$.

### Summary of Steps:
1. **Decimal to IEEE 754**:
   - Find the binary representation of the number.
   - Normalize the number.
   - Find the exponent and mantissa.
   - Write the IEEE 754 format.

2. **IEEE 754 to Decimal**:
   - Extract the sign, exponent, and mantissa.
   - Reconstruct the binary number and calculate its decimal equivalent.

### **Rationale of the IEEE 754 Floating-Point Structure**

IEEE 754 was designed to efficiently represent real numbers (both very large and very small) and handle calculations involving precision and range limitations in computers. Its structure is as follows:

- **Sign (1 bit)**: Determines whether the number is positive or negative.
- **Exponent (8 bits in single precision)**: Controls the scaling (powers of 2), allowing numbers to represent very large or very small values.
- **Mantissa (23 bits in single precision)**: Holds the significant digits of the number, providing precision.

This structure enables floating-point numbers to handle a wide range of values, including very small fractions and large numbers, by adjusting the exponent (scaling) while maintaining a reasonable amount of precision via the mantissa.

### **Rationale for the Ratio of Exponent to Mantissa**

The balance between the **exponent** and **mantissa** is a trade-off between **range** and **precision**:

- **Exponent (8 bits)**: These bits determine the **range** of numbers that can be represented. With 8 bits, the exponent can range from $2^{-126}$ to $2^{127}$ (in single precision). This allows the representation of both very large and very small numbers.
  
- **Mantissa (23 bits)**: These bits determine the **precision** of the number. The more bits in the mantissa, the more digits you can represent accurately. With 23 bits, the mantissa provides about 7 decimal digits of precision.

The ratio (8 bits for exponent, 23 bits for mantissa) balances between having a wide **range** of numbers (so you can represent large/small values) and good **precision** (so calculations are accurate enough). If the exponent were smaller, you'd lose range but gain precision, and vice versa.

### **What Does Bias Mean?**

In IEEE 754, the **exponent** is stored in a "biased" format. This means that a fixed number (called the **bias**) is added to the actual exponent value to allow both positive and negative exponents to be stored using unsigned binary values.

For **single precision** (32-bit):
- The bias is **127**.
- If the stored exponent is $E$, then the actual exponent is calculated as:
  $$ \text{Actual exponent} = E - 127 $$

**Why use bias?**
The biased exponent allows the use of unsigned integers to represent both positive and negative exponents, which simplifies the hardware design for storing and manipulating exponents.

Example:
- If the stored exponent is 130, the actual exponent is:
  $$ 130 - 127 = 3 $$
- If the stored exponent is 100, the actual exponent is:
  $$ 100 - 127 = -27 $$

This makes it easier to handle a wide range of exponents, both large and small.

### **What Does Normalization Mean?**

**Normalization** ensures that the floating-point representation is unique and maximizes the precision of the mantissa. A normalized floating-point number has the form:

$$ 1.m \times 2^E $$

Where:
- The **1** before the decimal point is **implied** (not stored in the mantissa).
- The **m** part is the mantissa.
- **E** is the exponent, which determines the power of 2.

In normalized form:
- The first bit of the mantissa is always **1** (except for special cases like 0). This is why it's not stored explicitly, effectively giving 1 extra bit of precision.

**Why normalize?**
- It avoids multiple representations of the same value. For example, without normalization, $12.75$ could be represented as $1.10011 \times 2^3$ or $11.0011 \times 2^2$.
- It maximizes the precision of the mantissa by utilizing the most significant bit, ensuring the mantissa always starts with a 1 (except for special cases).

### Example of Normalization:
For the number $12.75$ (binary $1100.11_2$):
- In normalized form, it becomes $1.10011_2 \times 2^3$.
- The exponent is 3, and the mantissa is $10011$ (with the leading 1 implied).

In summary:
- The **structure** of IEEE 754 ensures a balance between range and precision.
- The **bias** allows exponents to be represented as unsigned values, simplifying their storage.
- **Normalization** ensures that numbers are represented consistently and with maximum precision.


## Two's Complement

**Two's complement** is a method for representing signed integers in binary. It's widely used in computer systems because it simplifies arithmetic operations, especially subtraction. Let's break down how to convert between **two's complement** and **decimal** in both directions.

---

### **1. Two's Complement to Decimal Conversion**

To convert a binary number in two's complement form to decimal, follow these steps:

#### Step-by-Step Process:

1. **Check the leftmost (most significant) bit** (the sign bit):
   - If the leftmost bit is **0**, the number is positive. Simply convert it to decimal as usual.
   - If the leftmost bit is **1**, the number is negative. You need to find its two's complement (invert the bits and add 1) to get its magnitude, then add a negative sign.

#### Example 1: Convert 8-bit two's complement binary `01101001` to decimal:
1. The leftmost bit is **0**, so the number is positive.
2. Convert the binary `01101001` to decimal:
   $$ 0 \times 2^7 + 1 \times 2^6 + 1 \times 2^5 + 0 \times 2^4 + 1 \times 2^3 + 0 \times 2^2 + 0 \times 2^1 + 1 \times 2^0 = 64 + 32 + 8 + 1 = 105_{10} $$
3. Result: $105_{10}$.

#### Example 2: Convert 8-bit two's complement binary `10010110` to decimal:
1. The leftmost bit is **1**, so the number is negative.
2. Find the two's complement (invert all bits and add 1):
   - Invert `10010110`: `01101001`.
   - Add 1: `01101001 + 1 = 01101010`.
   - Convert `01101010` to decimal:
     $$ 64 + 32 + 8 + 2 = 106_{10} $$
3. The original number was negative, so the result is $-106_{10}$.

---

### **2. Decimal to Two's Complement Conversion**

To convert a decimal number to two's complement form, follow these steps:

#### Step-by-Step Process:

1. **If the number is positive**:
   - Convert the number to binary as usual.
   - Ensure the binary number fits the desired bit-length (pad with leading zeros if needed).

2. **If the number is negative**:
   - Convert the magnitude of the number to binary.
   - Invert the bits (take the complement of the bits).
   - Add 1 to the inverted bits.
   - Ensure the result fits the desired bit-length.

#### Example 1: Convert $35_{10}$ to 8-bit two's complement:
1. $35_{10}$ is positive, so convert to binary:
   $$ 35_{10} = 00100011_2 $$
2. Result: `00100011` (8 bits).

#### Example 2: Convert $-35_{10}$ to 8-bit two's complement:
1. Convert $35_{10}$ to binary:
   $$ 35_{10} = 00100011_2 $$
2. Invert the bits:
   $$ 00100011 \rightarrow 11011100 $$
3. Add 1:
   $$ 11011100 + 1 = 11011101_2 $$
4. Result: `11011101` (8 bits).

---

### **Why Use Two's Complement?**
- Two's complement simplifies arithmetic operations in hardware, particularly for addition and subtraction, because it avoids the need to handle both positive and negative numbers differently.
- The two's complement representation allows a single method for binary addition to handle both positive and negative values, including overflow detection.

### **Quick Summary**:
- **Two's complement to decimal**:
   - If the leftmost bit is 0, the number is positive.
   - If the leftmost bit is 1, the number is negative, and you find its magnitude using two's complement.
   
- **Decimal to two's complement**:
   - If positive, convert to binary and pad.
   - If negative, convert to binary, invert, and add 1.


## Binary Multiplication & Division

### **1. Binary Multiplication**

Binary multiplication is similar to decimal multiplication, but instead of multiplying by 10 (as in decimal), you're multiplying by 2. The steps are straightforward, involving **bitwise operations** and **shifting**.

#### **Steps for Binary Multiplication**:

1. **Multiply each bit of the second number** by the entire first number.
   - If the bit is **1**, copy the first number.
   - If the bit is **0**, the result is **0** for that row.
2. **Shift the result** of each multiplication left, according to its place value (like how you shift in decimal multiplication when you move to the next digit).
3. **Add all the shifted results** together.

#### **Example**: Multiply $13_{10}$ by $11_{10}$ in binary.

1. Convert to binary:
   - $13_{10} = 1101_2$
   - $11_{10} = 1011_2$

2. Multiply each bit of $1011_2$ by $1101_2$:

```
        1101    (13)
      × 1011    (11)
      ---------
        1101  (1101 × 1)
+      0000   (1101 × 0, shifted left by 1)
+     1101    (1101 × 1, shifted left by 2)
+    1101     (1101 × 1, shifted left by 3)
-----------------------
    10001111    (result = 143)
```

The result is $10001111_2$, which equals $143_{10}$.

---

### **2. Binary Division**

Binary division works similarly to long division in decimal. You repeatedly subtract the divisor from the current portion of the dividend, shifting bits as needed.

#### **Steps for Binary Division**:

1. Align the divisor with the leftmost bits of the dividend.
2. Subtract (bitwise) if the current portion of the dividend is greater than or equal to the divisor.
   - Write **1** in the quotient if subtraction occurs, otherwise **0**.
3. Shift the divisor to the right and repeat until you've covered all bits of the dividend.

#### **Example**: Divide $14_{10}$ by $3_{10}$ in binary.

1. Convert to binary:
   - $14_{10} = 1110_2$
   - $3_{10} = 0011_2$

2. Perform binary division:

```
     010  (quotient)
    -------
0011 | 1110  (dividend = 14)
      - 0011 (subtract 3)
      -------
        1011
      - 0011 (subtract 3)
      -------
        1001
      - 0011 (subtract 3)
      -------
         110  (remainder)
```

The quotient is $010_2$ (or $2_{10}$), and the remainder is $110_2$ (or $6_{10}$).

---

### **Key Points**:

1. **Binary multiplication**: Simple bitwise multiplication followed by left shifts and addition of partial products.
2. **Binary division**: Similar to long division; repeatedly subtract the divisor, write down a 1 or 0 for the quotient, and shift until the division is complete.

Binary operations like multiplication and division become easier once you grasp shifting and basic bitwise arithmetic!

## Two's Complement Binary Operations

In **two's complement**, operations like addition, subtraction, multiplication, and division follow rules similar to binary arithmetic but handle negative numbers inherently due to the representation. Here's how the basic operations work:

---

### 1. **Addition in Two's Complement**
Addition is straightforward in two's complement, just like binary addition. You add the binary numbers together, and the two's complement handles whether they are positive or negative automatically.

#### Steps:
- Add the two binary numbers bit by bit.
- If there's a carry out of the most significant bit (sign bit), discard it (in a fixed-width system like 8 bits or 16 bits).

#### Example:
Let's add $5_{10}$ and $-3_{10}$ in 4-bit two's complement.

1. $5_{10}$ is `0101_2`.
2. $-3_{10}$ is the two's complement of 3: `0011_2$ (invert and add 1) → `1101_2`.

Now, add the two:
```
  0101  (5)
+ 1101  (-3)
-------
  0010  (2)
```
Result: $2_{10}$, which is correct.

#### Overflow in Two's Complement Addition:
- If both numbers are positive and the result is negative, overflow has occurred.
- If both numbers are negative and the result is positive, overflow has occurred.

---

### 2. **Subtraction in Two's Complement**
Subtraction is handled by **adding the two's complement** of the number to be subtracted. This turns subtraction into addition, simplifying the operation.

#### Steps:
1. Convert the number to be subtracted into its two's complement form.
2. Add it to the first number.

#### Example:
Subtract $7_{10}$ from $5_{10}$ in 4-bit two's complement.

1. $5_{10}$ is `0101_2`.
2. $7_{10}$ is `0111_2`.
3. Find the two's complement of $7_{10}$:
   - Invert `0111_2 → 1000_2`.
   - Add 1: `1000 + 1 = 1001_2`.

Now, add:
```
  0101  (5)
+ 1001  (-7)
-------
  1110  (-2)
```
Result: $-2_{10}$, which is correct.

---

### 3. **Multiplication in Two's Complement**
Multiplication in two's complement is similar to binary multiplication, but you have to pay attention to the sign of the result based on the inputs. The most common approach is **booth's algorithm** or just multiplying normally and adjusting for signs.

#### Example:
Multiply $3_{10}$ by $-2_{10}$ in 4-bit two's complement.

1. $3_{10}$ is `0011_2$.
2. $-2_{10}$ is `1110_2` (two's complement of 2).

```
  0011  (3)
× 1110  (-2)
-------
  0011  (3 × 0)
  0000  (shift)
  0011  (3 × 1)
-------
 Result: 11010 (truncated to 4 bits → 1010)
```
This equals $-6_{10}$, which is correct.

---

### 4. **Division in Two's Complement**
Division follows similar rules as binary division, but the handling of signs is automatic due to two's complement. You'll divide the absolute values and apply the sign rules (positive/negative) based on the two operands.

#### Steps:
1. Perform division on the absolute values.
2. Apply the sign of the result based on the sign of the operands.

#### Example:
Divide $-10_{10}$ by $2_{10}$.

1. $-10_{10}$ in 8-bit two's complement is `11110110_2$.
2. $2_{10}$ in binary is `00000010_2`.

Divide the absolute values:
```
  1010 ÷ 0010 = 0101 (5)
```
The sign of the result is negative, so the result is $-5$.

---

### Summary of Operations in Two's Complement:
1. **Addition**: Add directly, and discard carry-out if it occurs. Check for overflow.
2. **Subtraction**: Add the two's complement of the number to be subtracted.
3. **Multiplication**: Multiply directly, paying attention to the sign.
4. **Division**: Divide absolute values and apply the correct sign.

Two's complement simplifies handling of negative numbers because you only need one addition/subtraction method for both positive and negative numbers.