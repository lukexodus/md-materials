# Summations

## Background

Summations are a fundamental concept in mathematics used to add up sequences of numbers. Here’s an overview of everything you need to get started:

### Basic Notation

The summation notation uses the Greek letter sigma (∑) to represent the sum of a sequence of terms. Here’s the general form:

$$
\sum_{i=a}^{b} f(i)
$$

This notation tells you to sum the function \( f(i) \) as \( i \) goes from \( a \) to \( b \).

- \( \sum \) is the summation symbol.
- \( i \) is the index of summation.
- \( a \) is the lower limit of summation (starting value of \( i \)).
- \( b \) is the upper limit of summation (ending value of \( i \)).
- \( f(i) \) is the function or sequence to be summed.

**Example**

To sum the first 5 natural numbers, you write:

$$
\sum_{i=1}^{5} i = 1 + 2 + 3 + 4 + 5 = 15
$$

### Properties of Summation

1. **Linearity**:
   $$ \sum_{i=a}^{b} (c \cdot f(i) + d \cdot g(i)) = c \sum_{i=a}^{b} f(i) + d \sum_{i=a}^{b} g(i) $$
   This means you can distribute summation over addition and factor out constants.

2. **Index Shift**:
   You can shift the index of summation without changing the sum, as long as you adjust the limits appropriately.
   $$ \sum_{i=a}^{b} f(i) = \sum_{j=a+k}^{b+k} f(j-k) $$

3. **Splitting Summation**:
   You can split the summation into parts.
   $$ \sum_{i=a}^{c} f(i) + \sum_{i=c+1}^{b} f(i) = \sum_{i=a}^{b} f(i) $$

### Necessary Math Background

1. **Arithmetic Sequences**: Understand the formula for the sum of an arithmetic series.
   $$ \sum_{i=1}^{n} i = \frac{n(n+1)}{2} $$

2. **Geometric Sequences**: Understand the formula for the sum of a geometric series.
   $$ \sum_{i=0}^{n} ar^i = a \frac{1-r^{n+1}}{1-r} \quad \text{(for } r \ne 1\text{)} $$

3. **Basic Algebra**: Comfort with manipulating algebraic expressions, factoring, and distributing.

4. **Functions and Sequences**: Understanding how functions and sequences work, including basic notation like \( f(i) \) for a function and \( a_i \) for a sequence.

### Advanced Topics (if needed)

1. **Double Summation**: Summing over two indices.
   $$ \sum_{i=a}^{b} \sum_{j=c}^{d} f(i, j) $$

2. **Changing Order of Summation**: Techniques for reordering double summations.

### Practice Problems

1. Calculate \( \sum_{i=1}^{10} 2i \).
2. Find the sum of the first 50 odd numbers.
3. Evaluate \( \sum_{i=0}^{4} 3^i \).

### Practice Solutions

1. 
$$ \sum_{i=1}^{10} 2i = 2 \sum_{i=1}^{10} i = 2 \cdot \frac{10 \cdot 11}{2} = 110 $$

2. 
Sum of the first \( n \) odd numbers is \( n^2 \).
For \( n = 50 \), \( 50^2 = 2500 \).

3.
$$ \sum_{i=0}^{4} 3^i = 3^0 + 3^1 + 3^2 + 3^3 + 3^4 = 1 + 3 + 9 + 27 + 81 = 121 $$

Understanding these fundamentals will give you a solid foundation in working with summations in various mathematical contexts.

## Divergent Series vs Convergent Series