## **Dynamic Programming**


**Dynamic Programming (DP)** is an **optimization technique** used to solve problems by **breaking them down into smaller subproblems** and storing their results to avoid redundant computations. It is commonly used in **combinatorics, optimization, and graph problems**.

---

### **Types of Dynamic Programming**

1. **Top-Down (Memoization)** – Solving problems recursively while storing results.
2. **Bottom-Up (Tabulation)** – Iteratively solving subproblems and building up the final solution.

---

### **Top-Down Approach (Memoization)**

Uses **recursion + caching** to avoid recomputation.

✅ **Example: Fibonacci Sequence using Memoization**

```cpp
#include <iostream>
#include <vector>
using namespace std;

vector<int> memo(100, -1); // Initialize cache with -1

int fib(int n) {
    if (n <= 1) return n;
    if (memo[n] != -1) return memo[n]; // Return cached result
    return memo[n] = fib(n - 1) + fib(n - 2);
}

int main() {
    cout << "Fibonacci(10): " << fib(10) << endl;
    return 0;
}
```

**Output:**

```
Fibonacci(10): 55
```

🔹 Stores computed values to prevent redundant recursive calls.

---

### **Bottom-Up Approach (Tabulation)**

Uses **iteration** to build solutions from smaller subproblems.

✅ **Example: Fibonacci using Tabulation**

```cpp
#include <iostream>
using namespace std;

int fib(int n) {
    int dp[100] = {0, 1}; // Base cases
    for (int i = 2; i <= n; ++i)
        dp[i] = dp[i - 1] + dp[i - 2];
    return dp[n];
}

int main() {
    cout << "Fibonacci(10): " << fib(10) << endl;
    return 0;
}
```

**Output:**

```
Fibonacci(10): 55
```

🔹 Builds results iteratively, avoiding recursion overhead.

---

### **Optimized Space Complexity**

We only need the last two Fibonacci numbers instead of storing the entire array.

✅ **Example: Fibonacci with O(1) Space Complexity**

```cpp
#include <iostream>
using namespace std;

int fib(int n) {
    if (n <= 1) return n;
    int a = 0, b = 1, c;
    for (int i = 2; i <= n; ++i) {
        c = a + b;
        a = b;
        b = c;
    }
    return b;
}

int main() {
    cout << "Fibonacci(10): " << fib(10) << endl;
    return 0;
}
```

🔹 Uses **constant space (`O(1)`)** instead of storing all values.

---

### **Common Problems Solved Using DP**

✅ **Knapsack Problem**  
✅ **Longest Common Subsequence (LCS)**  
✅ **Longest Increasing Subsequence (LIS)**  
✅ **Coin Change Problem**  
✅ **Matrix Chain Multiplication**

---

