## **Recursive Functions**


A **recursive function** is a function that **calls itself** to solve a problem. It **breaks down** a complex problem into smaller subproblems of the same type.

### **Structure of a Recursive Function**

1. **Base Case** – The condition that stops the recursion.
2. **Recursive Case** – The function calls itself with a smaller problem.

---

### **Example: Factorial of a Number**

Factorial (`n!`) is defined as:

$$
n! = n \times (n-1) \times (n-2) \times ... \times 1
$$

With the base case:

$$
0! = 1
$$

```cpp
#include <iostream>
using namespace std;

int factorial(int n) {
    if (n == 0) return 1;  // Base case
    return n * factorial(n - 1);  // Recursive case
}

int main() {
    cout << factorial(5);  // Output: 120
    return 0;
}
```

---

### **Example: Fibonacci Series**

The Fibonacci sequence is defined as:

$$
F(n) = F(n-1) + F(n-2)
$$

With base cases:

$$
F(0) = 0, \quad F(1) = 1
$$

```cpp
int fibonacci(int n) {
    if (n <= 1) return n;  // Base case
    return fibonacci(n - 1) + fibonacci(n - 2);  // Recursive case
}
```

---

### **Tail Recursion**

A recursive function is **tail-recursive** if the **last operation** is the recursive call.  
Example: Tail-recursive factorial (optimized):

```cpp
int factorialHelper(int n, int result) {
    if (n == 0) return result;  // Base case
    return factorialHelper(n - 1, n * result);  // Tail recursion
}

int factorial(int n) {
    return factorialHelper(n, 1);
}
```

**Benefits of Tail Recursion:**  
✅ Uses **less memory** (can be optimized into a loop).  
✅ **Avoids stack overflow** in deep recursion.

---

### **Recursion vs. Iteration**

|Feature|Recursion|Iteration|
|---|---|---|
|Function Calls|Yes|No|
|Space Complexity|High (stack usage)|Low|
|Performance|Slower (due to function calls)|Faster|
|Readability|More intuitive for divide-and-conquer problems|More efficient for simple loops|

---

### **When to Use Recursion?**

✅ Problems that can be broken into **smaller subproblems** (e.g., Trees, Graphs, Divide & Conquer).  
✅ **Mathematical computations** (Factorial, Fibonacci, Power, GCD).  
✅ **Backtracking problems** (Maze solving, N-Queens).

***

