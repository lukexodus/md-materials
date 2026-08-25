## **Bitwise Operators and Operations**


Bitwise operators work at the **bit level** and are used to manipulate individual bits of a number. These operators are **faster** and commonly used in **low-level programming, cryptography, and optimization techniques**.

---

### **Bitwise Operators in C++**

| Operator | Name        | Description                                                        |
| -------- | ----------- | ------------------------------------------------------------------ |
| `&`      | AND         | Sets a bit to `1` if both corresponding bits are `1`               |
| `        | `           | OR                                                                 |
| `^`      | XOR         | Sets a bit to `1` if bits are different (`1 ^ 0 = 1`, `0 ^ 1 = 1`) |
| `~`      | NOT         | Flips all bits (1s become 0s, 0s become 1s)                        |
| `<<`     | Left Shift  | Shifts bits left by `n` places, filling with 0s                    |
| `>>`     | Right Shift | Shifts bits right by `n` places, discarding bits                   |

---

### **Bitwise AND (`&`)**

**Formula:** `a & b`

```cpp
#include <iostream>
using namespace std;

int main() {
    int a = 5;  // 0101 in binary
    int b = 3;  // 0011 in binary
    cout << (a & b) << endl; // Output: 1 (0001)
    return 0;
}
```

✅ **Use Case:** Checking if a number is even (`num & 1 == 0` means even).

---

### **Bitwise OR (`|`)**

**Formula:** `a | b`

```cpp
int a = 5;  // 0101
int b = 3;  // 0011
cout << (a | b) << endl; // Output: 7 (0111)
```

✅ **Use Case:** Setting specific bits in a flag register.

---

### **Bitwise XOR (`^`)**

**Formula:** `a ^ b`

```cpp
int a = 5;  // 0101
int b = 3;  // 0011
cout << (a ^ b) << endl; // Output: 6 (0110)
```

✅ **Use Case:** Swapping numbers without a temporary variable.

```cpp
a = a ^ b;
b = a ^ b;
a = a ^ b;
```

---

### **Bitwise NOT (`~`)**

**Formula:** `~a`

```cpp
int a = 5;  // 0000 0101
cout << (~a) << endl; // Output: -6 (in 2’s complement form)
```

✅ **Use Case:** Negating bits or flipping bit values.

---

### **Left Shift (`<<`)**

**Formula:** `a << n` (Shifts bits `n` places to the left)

```cpp
int a = 5;  // 0000 0101
cout << (a << 1) << endl; // Output: 10 (0000 1010)
cout << (a << 2) << endl; // Output: 20 (0001 0100)
```

✅ **Use Case:** Fast multiplication by powers of `2`.  
Example: `x << 3` is the same as `x * 8`.

---

### **Right Shift (`>>`)**

**Formula:** `a >> n` (Shifts bits `n` places to the right)

```cpp
int a = 20;  // 0001 0100
cout << (a >> 1) << endl; // Output: 10 (0000 1010)
cout << (a >> 2) << endl; // Output: 5  (0000 0101)
```

✅ **Use Case:** Fast division by powers of `2`.  
Example: `x >> 3` is the same as `x / 8`.

---

### **Bitwise Tricks and Applications**

#### **1. Check if a Number is Even or Odd**

```cpp
if (num & 1) 
    cout << "Odd";
else 
    cout << "Even";
```

#### **2. Swap Two Numbers Without Using a Temporary Variable**

```cpp
a = a ^ b;
b = a ^ b;
a = a ^ b;
```

1. **First Operation**:

```cpp
a = a ^ b;
```
    
- This operation stores the result of `a XOR b` in `a`. At this point, `a` contains a value that represents both `a` and `b` without revealing either of them.
2. **Second Operation**:

```cpp
b = a ^ b;
```
    
- Here, we take the new value of `a` (which is `a XOR b`) and XOR it with `b`. The result of this operation is the original value of `a`. This is because:
	- `a XOR b XOR b` simplifies to `a` (since `b XOR b` equals `0` and `x XOR 0` equals `x`).
3. **Third Operation:**
```cpp
a = a ^ b;
```

- Finally, we take the new value of `b` (which is now the original value of `a`) and XOR it with the current value of `a` (which is `a XOR b`). The result of this operation is the original value of `b`. This works because:
    - `a XOR b XOR a` simplifies to `b` (for the same reason as above).

#### **3. Count the Number of 1s in a Binary Representation (Brian Kernighan's Algorithm)**

```cpp
int countOnes(int n) {
    int count = 0;
    while (n) {
        n = n & (n - 1);
        count++;
    }
    return count;
}
```

1. **Initialize `count` to 0** – This variable keeps track of the number of `1` bits in `n`.
2. **Loop while `n` is nonzero**:
    - `n & (n - 1)` removes the **rightmost set bit (1)** in `n`.
    - Each iteration decreases the number of `1`s in `n` until `n` becomes `0`.
    - Increment `count` after each operation.
3. **Return `count`**, which is the total number of `1`s in the binary representation of `n`.

**How `n = n & (n - 1)` Works**

- The expression `n & (n - 1)` clears the **rightmost set bit** (the lowest `1` bit) in `n`.

**Example Walkthrough**

Let's take `n = 13` (`1101` in binary).

1. **Initial:** `n = 1101`
    
    - `n - 1 = 1100`
    - `n & (n - 1) = 1101 & 1100 = 1100`
    - `count = 1`
2. **Next Iteration:** `n = 1100`
    
    - `n - 1 = 1011`
    - `n & (n - 1) = 1100 & 1011 = 1000`
    - `count = 2`
3. **Next Iteration:** `n = 1000`
    
    - `n - 1 = 0111`
    - `n & (n - 1) = 1000 & 0111 = 0000`
    - `count = 3`
4. **Exit Loop** (`n` becomes `0`), return `count = 3`.


#### **4. Check if a Number is a Power of Two**

```cpp
bool isPowerOfTwo(int n) {
    return (n > 0) && ((n & (n - 1)) == 0);
}
```


A number is a power of two if it has exactly **one** bit set in its binary representation. For example:

- $2^0 = 1$ → `0001`
- $2^1 = 2$ → `0010`
- $2^2 = 4$ → `0100`
- $2^3 = 8$ → `1000`

Each power of two has exactly **one** `1` in its binary form.

**How It Works**

```cpp
return (n > 0) && ((n & (n - 1)) == 0);
```

1. **`n > 0`**: Ensures that `n` is positive (powers of two are always positive).
2. **`(n & (n - 1)) == 0`**:
    - This expression clears the rightmost set bit.
    - If `n` is a power of two, it has exactly **one** set bit, so `n & (n - 1)` results in `0`.
    - If `n` is **not** a power of two, it has more than one `1` bit, and `n & (n - 1)` is **not** `0`.

**Example Walkthrough**

**Example 1: `n = 8` (Power of 2)**

- Binary: `1000`
- `n - 1 = 7` (`0111`)
- `n & (n - 1) = 1000 & 0111 = 0000`
- Returns **true**.

**Example 2: `n = 10` (Not a power of 2)**

- Binary: `1010`
- `n - 1 = 9` (`1001`)
- `n & (n - 1) = 1010 & 1001 = 1000`
- Returns **false**.

**Example 3: `n = 0`**

- `0 & (-1) = 0`, but `n > 0` is false.
- Returns **false**.

**Example 4: `n = -16`**

- Negative numbers are not powers of two.
- `n > 0` is false.
- Returns **false**.

#### **5. Set a Specific Bit**

```cpp
num |= (1 << pos);  // Set bit at 'pos' to 1
```

#### **6. Clear a Specific Bit**

```cpp
num &= ~(1 << pos);  // Clear bit at 'pos' (set to 0)
```

#### **7. Toggle a Bit**

```cpp
num ^= (1 << pos);  // Flip bit at 'pos'
```


#### **8. Counting Set Bits (Hamming Weight)**

✅ **Using Kernighan’s Algorithm**

```cpp
int countSetBits(int n) {
    int count = 0;
    while (n) {
        n &= (n - 1);  // Removes the rightmost set bit
        count++;
    }
    return count;
}
```

✅ **Example**:

```cpp
cout << countSetBits(7);  // Output: 3 (111 has 3 ones)
```

---

#### **9. Finding the Only Non-Repeating Element (XOR Trick)**

Given an array where every number appears twice except for one, find the unique number.  
✅ **Bitwise XOR Solution**

```cpp
int findUnique(vector<int>& nums) {
    int result = 0;
    for (int num : nums) {
        result ^= num;
    }
    return result;
}
```

✅ **Example**:

```cpp
vector<int> arr = {2, 3, 5, 3, 2};
cout << findUnique(arr);  // Output: 5
```

---

#### **10. Computing `x^y` (Exponentiation by Squaring)**

✅ **Efficient Power Calculation (O(log y))**

```cpp
long long power(long long x, long long y, long long mod) {
    long long result = 1;
    while (y > 0) {
        if (y & 1)  // If y is odd, multiply x
            result = (result * x) % mod;
        x = (x * x) % mod;  // Square x
        y >>= 1;  // Divide y by 2
    }
    return result;
}
```

✅ **Example**:

```cpp
cout << power(2, 10, 1000000007);  // Output: 1024
```

---

#### **11. Finding the Most Significant Set Bit**

✅ **Using `log2(n)`**

```cpp
int mostSignificantBit(int n) {
    return 1 << (31 - __builtin_clz(n));
}
```

✅ **Example**:

```cpp
cout << mostSignificantBit(18);  // Output: 16
```

---

#### **12. Greatest Common Divisor (GCD) Using Bitwise Operations**

✅ **Stein’s Algorithm (Binary GCD)**

```cpp
int gcd(int a, int b) {
    if (b == 0) return a;
    return gcd(b, a % b);
}
```

✅ **Example**:

```cpp
cout << gcd(48, 18);  // Output: 6
```

---

**Summary**

- **AND (`&`)** → Extract specific bits.
- **OR (`|`)** → Set specific bits.
- **XOR (`^`)** → Toggle bits, swap numbers.
- **NOT (`~`)** → Flip all bits.
- **Left Shift (`<<`)** → Multiply by `2^n`.
- **Right Shift (`>>`)** → Divide by `2^n`.

---

