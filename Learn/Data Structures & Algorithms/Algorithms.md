### Big-Theta (Θ) and Bounds

When analyzing algorithms, we use asymptotic notation to describe their growth rates. One of the most precise notations is **Big-Theta (Θ)**, which gives both an **upper bound** and a **lower bound** on a function.

---

### Big-Theta (Θ) Definition
Big-Theta (Θ) defines a **tight bound** on the growth of a function. It states that a function $f(n)$ grows at the same rate as another function $g(n)$ up to constant factors.

**Mathematical Definition:**  
A function $f(n)$ is in $\Theta(g(n))$ if there exist positive constants $c_1, c_2, n_0$ such that:

$$
c_1 g(n) \leq f(n) \leq c_2 g(n) \quad \text{for all } n \geq n_0
$$

This means that $f(n)$ is sandwiched between two multiples of $g(n)$, meaning $g(n)$ provides both an upper and lower bound.

---

### Big-O (O), Big-Omega (Ω), and Big-Theta (Θ)
Big-Theta relates closely to **Big-O** and **Big-Omega**:

- **Big-O (O)**: Upper bound (worst-case)  
  - $f(n) = O(g(n))$ means $f(n)$ does not grow faster than $g(n)$.
- **Big-Omega (Ω)**: Lower bound (best-case)  
  - $f(n) = \Omega(g(n))$ means $f(n)$ grows at least as fast as $g(n)$.
- **Big-Theta (Θ)**: Tight bound (average-case or general growth)  
  - $f(n) = \Theta(g(n))$ means $g(n)$ gives both a lower and an upper bound for $f(n)$.

If a function is in **Big-Theta**, it is also in both **Big-O** and **Big-Omega**.

---

### Examples of Big-Theta Bounds
1. **Linear function:**
   - $f(n) = 5n + 10$
   - $g(n) = n$
   - We can find constants $c_1 = 4$, $c_2 = 6$, and $n_0 = 10$ such that:

     $$
     4n \leq 5n + 10 \leq 6n
     $$

   - So, $f(n) = \Theta(n)$.

2. **Quadratic function:**
   - $f(n) = 2n^2 + 3n + 5$
   - $g(n) = n^2$
   - By choosing appropriate constants, we get:

     $$
     c_1 n^2 \leq 2n^2 + 3n + 5 \leq c_2 n^2
     $$

   - So, $f(n) = \Theta(n^2)$.

3. **Logarithmic function:**
   - $f(n) = 7\log n + 20$
   - $g(n) = \log n$
   - Since $f(n)$ is bounded above and below by multiples of $\log n$, we conclude:

     $$
     f(n) = \Theta(\log n)
     $$

---

### Graphical Interpretation
Big-Theta notation means that $f(n)$ and $g(n)$ grow at the same rate. Visually, the function $f(n)$ stays between two constant multiples of $g(n)$ as $n \to \infty$.

If plotted on a graph:
- $O(g(n))$ would be an upper bound curve.
- $\Omega(g(n))$ would be a lower bound curve.
- $\Theta(g(n))$ would mean that $f(n)$ is squeezed between them.

---

### Why is Big-Theta Important?
- It provides the **most precise** growth rate analysis.
- It helps in understanding **average-case complexity**.
- It is useful for determining **algorithm efficiency** in practice.

---

### Recursion and Methods for Solving Recurrences  

Recursion is a technique where a function calls itself to solve a problem. In algorithm analysis, many recursive algorithms lead to recurrence relations, which describe their time complexity. Several methods exist to solve these recurrences:  

- **Substitution Method**  
- **Iteration (Recursion Tree) Method**  
- **Master Method**  

---

### Substitution Method  

The **substitution method** involves **guessing** a solution and using **mathematical induction** to prove that it satisfies the recurrence.

#### Steps:  
1. **Guess the form** of the solution.  
2. **Prove by induction** that the guess holds.  
3. **Find the constants** (if needed).  

#### Example:  
Solve the recurrence:

$$
T(n) = 2T(n/2) + n
$$

**Step 1: Guess the solution**  
We assume $T(n) = O(n \log n)$.  

**Step 2: Expand the recurrence**  
Expanding a few levels:

$$
T(n) = 2T(n/2) + n
$$
$$
= 2(2T(n/4) + n/2) + n
$$
$$
= 4T(n/4) + 2n
$$
$$
= 8T(n/8) + 3n
$$

Generalizing, at level $i$:  

$$
T(n) = 2^i T(n/2^i) + i n
$$

When $n/2^i = 1 \Rightarrow i = \log n$, we get:  

$$
T(n) = 2^{\log n} T(1) + n \log n
$$

Since $T(1) = O(1)$, this simplifies to:  

$$
T(n) = O(n \log n)
$$

Thus, the recurrence is **$O(n \log n)$**.

---

### Iteration (Recursion Tree) Method  

The **iteration method** expands the recurrence into a **recursion tree** to find the total work done.

#### Example:  
Solve:

$$
T(n) = 3T(n/3) + n
$$

**Step 1: Expand the recurrence**  

Expanding a few levels:  

$$
T(n) = 3T(n/3) + n
$$
$$
= 3(3T(n/9) + n/3) + n
$$
$$
= 9T(n/9) + 4n/3
$$
$$
= 27T(n/27) + 7n/3
$$

Generalizing at level $i$:  

$$
T(n) = 3^i T(n/3^i) + i n
$$

When $n/3^i = 1 \Rightarrow i = \log_3 n$, we get:

$$
T(n) = 3^{\log_3 n} T(1) + n \log_3 n
$$

Since $T(1) = O(1)$, we simplify:

$$
T(n) = O(n \log n)
$$

Thus, the recurrence is **$O(n \log n)$**.

---

### Master Method  

The **Master Theorem** provides a direct way to solve recurrences of the form:

$$
T(n) = aT(n/b) + f(n)
$$

where:  
- $a$ = number of recursive calls  
- $b$ = factor by which $n$ is reduced  
- $f(n)$ = extra work outside recursion  

**Case 1: Polynomial dominates ($f(n) = O(n^c)$, where $c < \log_b a$)**  
$$
T(n) = \Theta(n^{\log_b a})
$$

**Case 2: $f(n) = \Theta(n^{\log_b a})$**  
$$
T(n) = \Theta(n^{\log_b a} \log n)
$$

**Case 3: Work outside recursion dominates ($f(n) = \Omega(n^c)$, where $c > \log_b a$ and regularity holds)**  
$$
T(n) = \Theta(f(n))
$$

#### Example:  
Solve:

$$
T(n) = 2T(n/2) + n
$$

Here,  
- $a = 2$,  
- $b = 2$,  
- $f(n) = O(n)$.  

Since $\log_2 2 = 1$ and $f(n) = O(n^1)$, Case 2 applies:

$$
T(n) = \Theta(n \log n)
$$

Thus, the recurrence is **$O(n \log n)$**.

---

### Summary  

| Method | Approach | Example Use |
|--------|---------|-------------|
| **Substitution Method** | Guess and prove | $T(n) = 2T(n/2) + n$ |
| **Iteration Method** | Expand into a tree | $T(n) = 3T(n/3) + n$ |
| **Master Method** | Direct formula | $T(n) = 4T(n/2) + n^2$ |
