## Operators


### **Arithmetic Operators**

Perform mathematical operations on numbers.

- `+` (Addition) → `5 + 3 = 8`
- `-` (Subtraction) → `5 - 3 = 2`
- `*` (Multiplication) → `5 * 3 = 15`
- `/` (Division) → `5 / 2 = 2.5`
- `//` (Floor Division) → `5 // 2 = 2`
- `%` (Modulus) → `5 % 2 = 1`
- `**` (Exponentiation) → `2 ** 3 = 8`
    

**Example:**

```python
a, b = 5, 2
print(a + b, a - b, a * b, a / b, a // b, a % b, a ** b)
```

### **Comparison Operators**

Compare two values and return `True` or `False`.

- `==` (Equal) → `5 == 5 → True`
- `!=` (Not Equal) → `5 != 3 → True`
- `>` (Greater Than) → `5 > 3 → True`
- `<` (Less Than) → `5 < 3 → False`
- `>=` (Greater Than or Equal) → `5 >= 5 → True`
- `<=` (Less Than or Equal) → `5 <= 3 → False`
    

**Example:**

```python
x, y = 10, 20
print(x == y, x != y, x > y, x < y, x >= y, x <= y)
```

### **Logical Operators**

Perform logical operations on boolean values.

- `and` (Logical AND) → `True and False → False`
- `or` (Logical OR) → `True or False → True`
- `not` (Logical NOT) → `not True → False`
    

**Example:**

```python
a, b = True, False
print(a and b, a or b, not a)
```

### **Bitwise Operators**

Operate on binary representations of numbers.

- `&` (AND) → `5 & 3 = 1` (0101 & 0011 = 0001)
- `|` (OR) → `5 | 3 = 7` (0101 | 0011 = 0111)
- `^` (XOR) → `5 ^ 3 = 6` (0101 ^ 0011 = 0110)
- `~` (NOT) → `~5 = -6` (inverts bits)
- `<<` (Left Shift) → `5 << 1 = 10` (0101 → 1010)
- `>>` (Right Shift) → `5 >> 1 = 2` (0101 → 0010)
    

**Example:**

```python
a, b = 5, 3
print(a & b, a | b, a ^ b, ~a, a << 1, a >> 1)
```

### **Assignment Operators**

Assign values and modify variables.

- `=` (Assign) → `x = 5`
- `+=` (Add and Assign) → `x += 3` (Same as `x = x + 3`)
- `-=` (Subtract and Assign) → `x -= 3`
- `*=` (Multiply and Assign) → `x *= 3`
- `/=` (Divide and Assign) → `x /= 3`
- `//=` (Floor Divide and Assign) → `x //= 3`
- `%=` (Modulus and Assign) → `x %= 3`
- `**=` (Exponentiate and Assign) → `x **= 3`
- `&=`, `|=`, `^=`, `<<=`, `>>=` (Bitwise Assignments)
    

**Example:**

```python
x = 5
x += 3
print(x)  # Output: 8
```

### **Identity Operators**

Check if two objects share the same memory location.

- `is` → `a is b` (True if they reference the same object)
- `is not` → `a is not b`
    

**Example:**

```python
a = [1, 2, 3]
b = a
c = [1, 2, 3]
print(a is b, a is not c)
```

### **Membership Operators**

Check if a value exists in a sequence.

- `in` → `3 in [1, 2, 3]` (True)
- `not in` → `4 not in [1, 2, 3]` (True)
    

**Example:**

```python
nums = [1, 2, 3, 4]
print(3 in nums, 5 not in nums)
```

### **Operator Precedence**

Defines the order in which operations are executed.  
**Precedence (Highest to Lowest):**

1. `()` (Parentheses)
2. `**` (Exponentiation)
3. `+x, -x, ~x` (Unary Operators)
4. `*, /, //, %` (Multiplication and Division)
5. `+, -` (Addition and Subtraction)
6. `<<, >>` (Bitwise Shift)
7. `&` (Bitwise AND)
8. `^` (Bitwise XOR)
9. `|` (Bitwise OR)
10. `==, !=, >, <, >=, <=` (Comparisons)
11. `is, is not, in, not in` (Identity and Membership)
12. `not` (Logical NOT)
13. `and` (Logical AND)
14. `or` (Logical OR)
15. `=, +=, -=, *=, /=, //=, %=, **=, &=, |=, ^=, <<=, >>=` (Assignments)
    

**Example:**

```python
result = 5 + 2 * 3  # Multiplication happens first: 5 + (2 * 3) = 11
```

**Key Points**
- Operators perform arithmetic, comparison, logical, bitwise, assignment, identity, and membership operations.
- Arithmetic operators include `+`, `-`, `*`, `/`, `//`, `%`, `**`.
- Comparison operators return boolean values based on conditions.
- Logical operators (`and`, `or`, `not`) operate on boolean values.
- Bitwise operators manipulate binary representations.
- Assignment operators modify variables in-place.
- Identity operators (`is`, `is not`) compare memory locations.
- Membership operators (`in`, `not in`) check sequence membership.
- Operator precedence determines execution order.

---

