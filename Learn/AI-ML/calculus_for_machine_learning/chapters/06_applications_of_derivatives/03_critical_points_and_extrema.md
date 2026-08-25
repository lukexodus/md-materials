## Critical Points and Extrema

### Definition of Critical Points

A **critical point** of a function $f$ occurs at a value $x = c$ in the domain of $f$ where either:

$$f'(c) = 0 \quad \text{or} \quad f'(c) \text{ does not exist}$$

Critical points are the candidate locations for **local extrema** (local maxima or local minima), though not every critical point is necessarily an extremum.

### Key Points

- Critical points are necessary but not sufficient conditions for local extrema — a critical point could also be a saddle-like point (in the single-variable case, a point where the function flattens but does not turn, such as an inflection point with zero slope).
- Finding critical points is the essential first step in nearly all single-variable and multivariable optimization procedures, including those underlying machine learning training algorithms.
- In machine learning, critical points correspond to locations in a loss landscape where the gradient is zero, which includes minima, maxima, and saddle points.

### Types of Extrema

- **Local (relative) minimum:** A point where $f(c) \leq f(x)$ for all $x$ in some neighborhood of $c$.
- **Local (relative) maximum:** A point where $f(c) \geq f(x)$ for all $x$ in some neighborhood of $c$.
- **Global (absolute) minimum/maximum:** The smallest or largest value of $f$ across its entire domain (or a specified closed interval).

### Fermat's Theorem on Critical Points

**Theorem:** If $f$ has a local extremum at $x=c$ and $f$ is differentiable at $c$, then $f'(c) = 0$.

[Fact] This is a foundational result in optimization theory, but it is important to note the theorem's direction: it states that differentiable extrema must be critical points, not that all critical points are extrema. A function can have $f'(c) = 0$ without $c$ being a maximum or minimum (for example, $f(x) = x^3$ at $x=0$, where the function has a horizontal tangent but merely flattens before continuing to increase).

### Worked Example 1: Finding Critical Points

$$f(x) = x^3 - 6x^2 + 9x + 1$$

$$f'(x) = 3x^2 - 12x + 9 = 3(x^2 - 4x + 3) = 3(x-1)(x-3)$$

Setting $f'(x) = 0$:

$$x = 1, \quad x = 3$$

These are the two critical points of $f$.

### Classifying Critical Points: First Derivative Test

The first derivative test classifies a critical point $c$ by examining the sign of $f'(x)$ on either side of $c$:

- If $f'$ changes from **positive to negative** at $c$: local maximum.
- If $f'$ changes from **negative to positive** at $c$: local minimum.
- If $f'$ does **not change sign** at $c$: neither a maximum nor a minimum.

Continuing the example above, testing intervals around $x=1$ and $x=3$:

| Interval | Sign of $f'(x)$ | Behavior |
|---|---|---|
| $x < 1$ | positive | increasing |
| $1 < x < 3$ | negative | decreasing |
| $x > 3$ | positive | increasing |

At $x=1$: $f'$ changes from positive to negative $\implies$ local maximum.
At $x=3$: $f'$ changes from negative to positive $\implies$ local minimum.

### Classifying Critical Points: Second Derivative Test

As introduced with higher-order derivatives, the second derivative test provides an alternative classification method:

$$f''(c) > 0 \implies \text{local minimum}, \qquad f''(c) < 0 \implies \text{local maximum}$$

For the same example, $f''(x) = 6x - 12$:

$$f''(1) = 6(1) - 12 = -6 < 0 \implies \text{local maximum (confirms first derivative test)}$$

$$f''(3) = 6(3) - 12 = 6 > 0 \implies \text{local minimum (confirms first derivative test)}$$

### Visualizing Critical Points

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 520 320">
  <text x="260" y="25" font-size="16" font-weight="bold" text-anchor="middle" fill="#1a1a1a">Critical Points: Local Max and Min (svg_diagram)</text>

  <line x1="40" y1="270" x2="480" y2="270" stroke="#333" stroke-width="1.5" />
  <line x1="260" y1="50" x2="260" y2="290" stroke="#333" stroke-width="1.5" />

  
  <path d="M 90,240 C 150,100 190,90 230,120 C 260,140 260,140 290,180 C 330,230 370,230 430,90" fill="none" stroke="#2563eb" stroke-width="3" />

  
  <circle cx="230" cy="120" r="6" fill="#dc2626" />
  <text x="180" y="105" font-size="11" fill="#dc2626">local max (f' = 0)</text>

  
  <circle cx="330" cy="230" r="6" fill="#059669" />
  <text x="335" y="250" font-size="11" fill="#065f46">local min (f' = 0)</text>

  <text x="260" y="305" font-size="12" text-anchor="middle" fill="#555">Tangent line is horizontal at both critical points</text>
</svg>

### Critical Points Where the Derivative Does Not Exist

Critical points are not limited to where $f'(x)=0$; they also include points where $f'(x)$ fails to exist, provided the point is still in the function's domain.

**Example:**

$$f(x) = |x|$$

As shown in an earlier discussion of differentiability, $f'(0)$ does not exist due to the corner at $x=0$. Despite this, $x=0$ is still a critical point, and in fact corresponds to the global minimum of $f(x) = |x|$.

### The Extreme Value Theorem and Global Extrema

**Theorem:** If $f$ is continuous on a closed interval $[a,b]$, then $f$ attains both a global maximum and a global minimum on that interval.

To find global extrema on a closed interval, the standard procedure is:

1. Find all critical points of $f$ within $(a,b)$.
2. Evaluate $f$ at each critical point.
3. Evaluate $f$ at the interval's endpoints, $f(a)$ and $f(b)$.
4. Compare all these values; the largest is the global maximum, the smallest is the global minimum.

[Fact] This procedure, often called the **closed interval method**, is a standard technique in introductory calculus for guaranteeing global extrema are found, and relies fundamentally on the Extreme Value Theorem's guarantee of existence on closed, bounded intervals.

### Relevance to Machine Learning

- **Loss function minima:** The central goal of training a machine learning model is to find parameter values that minimize a loss function — precisely a critical point search, typically restricted to minima rather than maxima or general critical points.
- **Saddle points in high-dimensional optimization:** [Fact] In high-dimensional parameter spaces (as in deep neural networks), critical points where the gradient is zero are far more likely to be **saddle points** than true local minima or maxima, since a saddle point only requires the Hessian to have mixed positive and negative eigenvalues across many dimensions — a condition that becomes statistically more likely as dimensionality increases. This is a well-documented consideration in deep learning optimization theory. [Inference — the precise statistical argument and its practical implications for specific architectures continue to be discussed in the optimization literature.]
- **Gradient descent's implicit goal:** Gradient descent algorithms search for points where the gradient (the multivariable generalization of $f'(x)$) is approximately zero, making critical point theory the mathematical target of the entire optimization process.
- **Non-differentiable critical points in ML:** Activation functions like ReLU have a critical point at $x=0$ where the derivative does not exist in the classical sense; as discussed previously, this is typically handled using a subgradient convention in practice, allowing optimization to proceed despite the technical non-differentiability at that point.
- **Local vs. global minima in non-convex loss landscapes:** [Inference] Since most deep learning loss functions are non-convex, gradient-based methods generally provide no guarantee of finding the global minimum and often converge to some critical point (frequently a local minimum or a region near a saddle point); empirical observations suggest that many local minima found in practice tend to have similar loss values in certain large-scale settings, though this finding is architecture- and problem-dependent and should not be treated as a universal guarantee.

### Common Pitfalls

- **Assuming every critical point is an extremum:** As shown with $f(x)=x^3$ at $x=0$, a horizontal tangent does not guarantee a maximum or minimum.
- **Forgetting non-differentiable points as candidates:** Only checking where $f'(x)=0$ while ignoring points where $f'(x)$ fails to exist can cause critical points (and potential extrema) to be missed.
- **Confusing local and global extrema:** A local maximum is not necessarily the largest value of the function overall; global extrema require checking endpoints (on closed intervals) or analyzing end behavior (on unbounded domains).
- **Relying solely on the second derivative test when it is inconclusive:** If $f''(c) = 0$, the second derivative test provides no information, and the first derivative test (or higher-order analysis) must be used instead.

### Conclusion

Critical points — where the derivative is zero or undefined — are the essential starting point for identifying local and global extrema of a function, classified using either the first or second derivative test. In machine learning, this theory directly underlies the goal of training algorithms, which search for critical points of a loss function, though the high-dimensional, non-convex nature of most deep learning loss landscapes means such searches typically encounter saddle points and local minima rather than guaranteed global minima.

**Related Topics**
- The Hessian matrix and multivariable critical point classification
- Saddle points and their prevalence in high-dimensional optimization
- Convex functions and global minimum guarantees
- Gradient descent and its convergence behavior
- The Extreme Value Theorem and closed interval optimization
- Non-convex loss landscapes in deep learning