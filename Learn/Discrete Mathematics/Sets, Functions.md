## Power Set

In **set theory**, a **power set** of a given set $S$ is the set of all possible subsets of $S$, including the empty set $\emptyset$ and $S$ itself. The power set is usually denoted as $P(S)$ or $2^S$ because it contains $2^n$ elements if the original set $S$ has $n$ elements.

### Example:
Let’s say $S = \{a, b\}$.

The power set $P(S)$ includes all subsets of $S$:
- The empty set: $\emptyset$
- The singleton sets: $\{a\}$, $\{b\}$
- The full set: $\{a, b\}$

So, the power set of $S$ is:
$$ P(S) = \{\emptyset, \{a\}, \{b\}, \{a, b\}\} $$

### Key Points:
1. **Number of subsets**: If a set $S$ has $n$ elements, its power set will have $2^n$ subsets.
   - For example, if $S$ has 3 elements, the power set will have $2^3 = 8$ subsets.

2. **Power set of an empty set**: If $S = \emptyset$, the power set of $S$ is:
   $$ P(\emptyset) = \{\emptyset\} $$
   Since the only subset of an empty set is itself.

### Example with 3 elements:
Let $S = \{x, y, z\}$.

The power set $P(S)$ will include:
$$ P(S) = \{\emptyset, \{x\}, \{y\}, \{z\}, \{x, y\}, \{x, z\}, \{y, z\}, \{x, y, z\}\} $$

So the power set contains $2^3 = 8$ subsets.

### Applications of Power Sets:
- **Combinatorics**: Power sets are used to understand all possible combinations of a set.
- **Boolean algebra**: Power sets play a key role in representing logical statements, where each subset represents a truth value combination.
- **Computer science**: Power sets are useful in generating combinations, searching problems, and dealing with state spaces.

## **Set Partitioning**

**Set partitioning** is the process of dividing a set into non-overlapping and non-empty subsets such that every element of the original set is included in exactly one subset. In other words, a partition of a set $S$ is a collection of subsets (called "blocks" or "parts") where:
1. Each element of $S$ is in exactly one subset.
2. No subset is empty.
3. The union of all subsets equals the original set $S$.

### Example of a Set Partition:
Let’s take the set $S = \{1, 2, 3\}$.

Some possible partitions of $S$ are:
- $\{\{1\}, \{2\}, \{3\}\}$ (each element is in its own subset).
- $\{\{1, 2\}, \{3\}\}$ (1 and 2 are grouped together, 3 is alone).
- $\{\{1, 3\}, \{2\}\}$ (1 and 3 are grouped together, 2 is alone).
- $\{\{1, 2, 3\}\}$ (all elements are in one subset).

The total number of ways to partition a set grows rapidly as the number of elements increases.

## **Bell Numbers**

The **Bell number**, denoted as $B_n$, counts the number of ways a set of $n$ elements can be partitioned into non-empty subsets. Bell numbers are named after the mathematician Eric Temple Bell.

- **Bell number for $n = 0$** (empty set): $B_0 = 1$. There's only one way to partition the empty set: with no subsets.
- **Bell number for $n = 1$**: $B_1 = 1$. There is only one way to partition a single-element set: $\{ \{1\} \}$.
- **Bell number for $n = 2$**: $B_2 = 2$. The set $\{1, 2\}$ can be partitioned as $\{\{1\}, \{2\}\}$ or $\{\{1, 2\}\}$.
- **Bell number for $n = 3$**: $B_3 = 5$. The set $\{1, 2, 3\}$ can be partitioned into five different ways.

The first few **Bell numbers** are:

$$
B_0 = 1, \quad B_1 = 1, \quad B_2 = 2, \quad B_3 = 5, \quad B_4 = 15, \quad B_5 = 52, \quad B_6 = 203, \ldots
$$

### Recursive Formula for Bell Numbers:
Bell numbers can be computed using the following recursive relationship:
$$
B_{n+1} = \sum_{k=0}^{n} \binom{n}{k} B_k
$$
Where $B_0 = 1$ and $\binom{n}{k}$ is a binomial coefficient.

### Example of Bell Number Calculation:

**Example 1: Calculating $B_3$:**
$$
B_3 = \binom{2}{0} B_0 + \binom{2}{1} B_1 + \binom{2}{2} B_2
$$
$$
B_3 = 1 \cdot 1 + 2 \cdot 1 + 1 \cdot 2 = 1 + 2 + 2 = 5
$$


**Example 2: Calculating $B_4$**
We already know the values for smaller Bell numbers:
- $B_0 = 1$
- $B_1 = 1$
- $B_2 = 2$
- $B_3 = 5$

Now, using the formula for $B_4$:
$$
B_4 = \binom{3}{0} B_0 + \binom{3}{1} B_1 + \binom{3}{2} B_2 + \binom{3}{3} B_3
$$

Calculating the binomial coefficients:
- $\binom{3}{0} = 1$
- $\binom{3}{1} = 3$
- $\binom{3}{2} = 3$
- $\binom{3}{3} = 1$

Substitute and compute:
$$
B_4 = 1 \cdot 1 + 3 \cdot 1 + 3 \cdot 2 + 1 \cdot 5
$$
$$
B_4 = 1 + 3 + 6 + 5 = 15
$$

So, $B_4 = 15$.

**Example 3: Calculating $B_5$**
Now, we need to calculate $B_5$. Using the known values:
- $B_0 = 1$
- $B_1 = 1$
- $B_2 = 2$
- $B_3 = 5$
- $B_4 = 15$

Now apply the recursive formula for $B_5$:
$$
B_5 = \binom{4}{0} B_0 + \binom{4}{1} B_1 + \binom{4}{2} B_2 + \binom{4}{3} B_3 + \binom{4}{4} B_4
$$

Calculating the binomial coefficients:
- $\binom{4}{0} = 1$
- $\binom{4}{1} = 4$
- $\binom{4}{2} = 6$
- $\binom{4}{3} = 4$
- $\binom{4}{4} = 1$

Substitute and compute:
$$
B_5 = 1 \cdot 1 + 4 \cdot 1 + 6 \cdot 2 + 4 \cdot 5 + 1 \cdot 15
$$
$$
B_5 = 1 + 4 + 12 + 20 + 15 = 52
$$

So, $B_5 = 52$.

**Example 4: Calculating $B_6$**
Now we calculate $B_6$. Using the known values:
- $B_0 = 1$
- $B_1 = 1$
- $B_2 = 2$
- $B_3 = 5$
- $B_4 = 15$
- $B_5 = 52$

Using the recursive formula for $B_6$:
$$
B_6 = \binom{5}{0} B_0 + \binom{5}{1} B_1 + \binom{5}{2} B_2 + \binom{5}{3} B_3 + \binom{5}{4} B_4 + \binom{5}{5} B_5
$$

Calculating the binomial coefficients:
- $\binom{5}{0} = 1$
- $\binom{5}{1} = 5$
- $\binom{5}{2} = 10$
- $\binom{5}{3} = 10$
- $\binom{5}{4} = 5$
- $\binom{5}{5} = 1$

Substitute and compute:
$$
B_6 = 1 \cdot 1 + 5 \cdot 1 + 10 \cdot 2 + 10 \cdot 5 + 5 \cdot 15 + 1 \cdot 52
$$
$$
B_6 = 1 + 5 + 20 + 50 + 75 + 52 = 203
$$

So, $B_6 = 203$.

#### Summary of Bell Numbers:
- $B_0 = 1$
- $B_1 = 1$
- $B_2 = 2$
- $B_3 = 5$
- $B_4 = 15$
- $B_5 = 52$
- $B_6 = 203$

### Applications of Bell Numbers:
- **Combinatorics**: Bell numbers are essential in counting partitions, grouping problems, and configurations.
- **Data Science**: Partitioning data into clusters.
- **Programming**: When dealing with set partitions, Bell numbers help understand the number of ways to divide sets in algorithms.

## Composition of Functions

Let $f: A \to B$ and $g: B \to C$ be two functions. The **composition of $f$ and $g$**, denoted as $g \circ f$, is a function that maps $A \to C$ and is defined by:
$$
(g \circ f)(x) = g(f(x)), \quad \text{for all } x \in A.
$$

In this composition:
- You apply the function $f$ first to $x$ (i.e., $f(x)$).
- Then, you apply $g$ to the result $f(x)$ to get $g(f(x))$.

Thus, the domain of $g \circ f$ is $A$ and the codomain is $C$.

### Example:
Let’s say we have two functions:
- $f: A \to B$ with $f(x) = x + 1$.
- $g: B \to C$ with $g(y) = y^2$.

Then the composition $g \circ f$ is:
$$
(g \circ f)(x) = g(f(x)) = (x+1)^2.
$$

---

## Counting Functions Between Sets

Let’s say we have two sets $X$ and $Y$, with:
- $|X| = m$ (i.e., set $X$ has $m$ elements),
- $|Y| = n$ (i.e., set $Y$ has $n$ elements).

#### Total Number of Functions from $X$ to $Y$:
If a function $f: X \to Y$ maps every element of $X$ to some element in $Y$, the total number of possible functions is:
$$
n^m.
$$
This is because for each of the $m$ elements of $X$, there are $n$ possible choices in $Y$.

#### Total Number of **One-One** (Injective) Functions:
A function is **one-one** (or injective) if no two elements of $X$ map to the same element in $Y$. For this to happen, the number of elements in $Y$ must be at least as large as the number of elements in $X$ (i.e., $n \geq m$). The total number of one-one functions from $X$ to $Y$ is given by:
$$
nP_m = \frac{n!}{(n - m)!},
$$
which is the **number of permutations** of $m$ elements chosen from $n$.

#### Total Number of **Onto** (Surjective) Functions:
A function is **onto** (or surjective) if every element of $Y$ has at least one element from $X$ mapping to it. The total number of onto functions from $X$ to $Y$ (if $m \geq n$) is given by:
$$
n^m - \binom{n}{1}(n-1)^m + \binom{n}{2}(n-2)^m - \dots + (-1)^{n-1} \binom{n}{n-1}(1)^m.
$$

This formula uses the principle of **inclusion-exclusion** to count how many ways you can map $X$ onto $Y$ by subtracting cases where some elements of $Y$ are left out.

### Example for Total Number of Functions:
If $|X| = 3$ and $|Y| = 2$, then:
- **Total functions** from $X \to Y$: $2^3 = 8$.
- **Total one-one functions** from $X \to Y$: No injective function exists because $|X| > |Y|$.
- **Total onto functions**: Use the formula above to calculate for $m = 3$ and $n = 2$.