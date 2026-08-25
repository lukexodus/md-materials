## Real Number System and Intervals

### Overview

The real number system forms the foundation for all calculus operations used in machine learning, including gradients, optimization, and continuous probability distributions. Machine learning models operate primarily on real-valued parameters, and understanding the structure of $\mathbb{R}$ is prerequisite to understanding limits, derivatives, and integrals.

### The Real Number System

#### Hierarchy of Number Sets

The real numbers $\mathbb{R}$ are built from nested subsets:

- **Natural numbers** $\mathbb{N} = \{1, 2, 3, \dots\}$ (sometimes includes 0, depending on convention)
- **Integers** $\mathbb{Z} = \{\dots, -2, -1, 0, 1, 2, \dots\}$
- **Rational numbers** $\mathbb{Q}$: numbers expressible as $\frac{p}{q}$ where $p, q \in \mathbb{Z}$ and $q \neq 0$
- **Irrational numbers**: numbers that cannot be expressed as a ratio of integers (e.g., $\pi$, $\sqrt{2}$, $e$)
- **Real numbers** $\mathbb{R} = \mathbb{Q} \cup \text{(irrationals)}$

$$\mathbb{N} \subset \mathbb{Z} \subset \mathbb{Q} \subset \mathbb{R}$$

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 700 260">
  <text x="350" y="25" font-size="16" text-anchor="middle" font-family="sans-serif" font-weight="bold">Number Set Hierarchy (svg_diagram)</text>
  <circle cx="350" cy="150" r="95" fill="#dbeafe" stroke="#1e3a8a" stroke-width="1.5" />
  <text x="350" y="65" font-size="13" text-anchor="middle" font-family="sans-serif">Real Numbers ℝ</text>
  <circle cx="330" cy="160" r="70" fill="#bfdbfe" stroke="#1e3a8a" stroke-width="1.5" />
  <text x="330" y="100" font-size="12" text-anchor="middle" font-family="sans-serif">Rational ℚ</text>
  <circle cx="320" cy="170" r="45" fill="#93c5fd" stroke="#1e3a8a" stroke-width="1.5" />
  <text x="320" y="135" font-size="11" text-anchor="middle" font-family="sans-serif">Integers ℤ</text>
  <circle cx="315" cy="185" r="22" fill="#60a5fa" stroke="#1e3a8a" stroke-width="1.5" />
  <text x="315" y="188" font-size="10" text-anchor="middle" font-family="sans-serif" fill="#1e293b">ℕ</text>
  <circle cx="460" cy="130" r="35" fill="#fecaca" stroke="#7f1d1d" stroke-width="1.5" />
  <text x="460" y="133" font-size="10" text-anchor="middle" font-family="sans-serif">Irrationals</text>
</svg>

#### Key Properties of $\mathbb{R}$

- **Ordered field**: for any two real numbers $a, b$, exactly one of $a < b$, $a = b$, or $a > b$ holds
- **Completeness property**: every non-empty subset of $\mathbb{R}$ that is bounded above has a least upper bound (supremum) in $\mathbb{R}$. This property distinguishes $\mathbb{R}$ from $\mathbb{Q}$ and is what allows limits and continuity to behave consistently
- **Density**: between any two distinct real numbers, there exist infinitely many other real numbers (both rational and irrational)

**Relevance to Machine Learning**

- Model weights, biases, and activations are typically represented as real numbers (approximated by floating-point values in practice)
- The completeness property underlies convergence guarantees in optimization algorithms; without it, limit points of a sequence of loss values might not exist within the number system
- [Inference] Floating-point arithmetic in actual ML frameworks only approximates $\mathbb{R}$ due to finite precision, which can introduce numerical instability not present in the idealized real number system

### Intervals

An interval is a subset of $\mathbb{R}$ consisting of all real numbers between two endpoints.

#### Types of Intervals

| Notation | Set Definition | Type |
|---|---|---|
| $(a, b)$ | $\{x \in \mathbb{R} : a < x < b\}$ | Open |
| $[a, b]$ | $\{x \in \mathbb{R} : a \le x \le b\}$ | Closed |
| $[a, b)$ | $\{x \in \mathbb{R} : a \le x < b\}$ | Half-open |
| $(a, b]$ | $\{x \in \mathbb{R} : a < x \le b\}$ | Half-open |
| $(a, \infty)$ | $\{x \in \mathbb{R} : x > a\}$ | Open, unbounded |
| $[a, \infty)$ | $\{x \in \mathbb{R} : x \ge a\}$ | Closed, unbounded |
| $(-\infty, \infty)$ | $\mathbb{R}$ | Entire real line |

**Key Points**

- Open intervals do not include their endpoints; closed intervals do
- $\infty$ and $-\infty$ are not real numbers, so intervals involving them are always open at that end
- In optimization, the domain of a loss function or activation function is often restricted to an interval (e.g., probabilities lie in $[0, 1]$)

#### Bounded vs. Unbounded Intervals

An interval is **bounded** if both endpoints are finite real numbers. It is **unbounded** if it extends to $+\infty$ or $-\infty$.

- Bounded example: $[0, 1]$ — used for representing probabilities or normalized pixel values
- Unbounded example: $[0, \infty)$ — used for domains of functions like ReLU output or variance, which cannot be negative

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 700 200">
  <text x="350" y="25" font-size="16" text-anchor="middle" font-family="sans-serif" font-weight="bold">Interval Types on the Number Line (svg_diagram)</text>

  <line x1="50" y1="70" x2="650" y2="70" stroke="#334155" stroke-width="2" />
  <text x="50" y="90" font-size="11" text-anchor="middle" font-family="sans-serif">-3</text>
  <text x="150" y="90" font-size="11" text-anchor="middle" font-family="sans-serif">-2</text>
  <text x="250" y="90" font-size="11" text-anchor="middle" font-family="sans-serif">-1</text>
  <text x="350" y="90" font-size="11" text-anchor="middle" font-family="sans-serif">0</text>
  <text x="450" y="90" font-size="11" text-anchor="middle" font-family="sans-serif">1</text>
  <text x="550" y="90" font-size="11" text-anchor="middle" font-family="sans-serif">2</text>
  <text x="650" y="90" font-size="11" text-anchor="middle" font-family="sans-serif">3</text>

  <line x1="250" y1="120" x2="450" y2="120" stroke="#1d4ed8" stroke-width="4" />
  <circle cx="250" cy="120" r="6" fill="white" stroke="#1d4ed8" stroke-width="2" />
  <circle cx="450" cy="120" r="6" fill="white" stroke="#1d4ed8" stroke-width="2" />
  <text x="350" y="115" font-size="11" text-anchor="middle" font-family="sans-serif" fill="#1d4ed8">(-1, 1) open</text>

  <line x1="350" y1="150" x2="550" y2="150" stroke="#15803d" stroke-width="4" />
  <circle cx="350" cy="150" r="6" fill="#15803d" stroke="#15803d" stroke-width="2" />
  <circle cx="550" cy="150" r="6" fill="#15803d" stroke="#15803d" stroke-width="2" />
  <text x="450" y="145" font-size="11" text-anchor="middle" font-family="sans-serif" fill="#15803d">[0, 2] closed</text>

  <line x1="450" y1="180" x2="650" y2="180" stroke="#b91c1c" stroke-width="4" />
  <circle cx="450" cy="180" r="6" fill="#b91c1c" stroke="#b91c1c" stroke-width="2" />
  <text x="620" y="175" font-size="11" text-anchor="middle" font-family="sans-serif" fill="#b91c1c">[1, ∞)</text>
</svg>

### Absolute Value and Distance

The absolute value function defines distance on the real line:

$$|x| = \begin{cases} x & \text{if } x \ge 0 \\ -x & \text{if } x < 0 \end{cases}$$

Distance between two points $a$ and $b$ on $\mathbb{R}$ is given by $|a - b|$.

This is central to defining limits formally: the statement "$x$ is close to $a$" is expressed as $|x - a| < \delta$ for some small $\delta > 0$.

**Example**

To express that a model parameter $\theta$ lies within $0.01$ of a target value $\theta^*$:

$$|\theta - \theta^*| < 0.01$$

This is equivalent to the interval notation:

$$\theta \in (\theta^* - 0.01,\ \theta^* - 0.01 + 0.02) = (\theta^* - 0.01,\ \theta^* + 0.01)$$

### Interval Arithmetic in ML Contexts

- **Sigmoid function** output range: $(0, 1)$ — open interval, since the sigmoid never exactly reaches 0 or 1 for finite input
- **Tanh function** output range: $(-1, 1)$ — open interval
- **Softmax** outputs lie in $(0, 1)$ per component and sum to 1
- **ReLU** output range: $[0, \infty)$ — closed at 0, since ReLU can output exactly 0
- [Unverified] Specific numerical libraries may implement clipping or epsilon-bounding near these theoretical limits to avoid floating-point issues (e.g., clipping sigmoid output to $[\epsilon, 1-\epsilon]$); this varies by implementation and is not a property of the mathematical function itself

### Why This Matters for Calculus

- Limits are defined using intervals around a point (e.g., $(a - \delta, a + \delta)$)
- Continuity and differentiability are typically discussed over open intervals or closed intervals depending on whether endpoint behavior matters
- Domains of loss functions, activation functions, and probability density functions are defined as intervals or unions of intervals
- The completeness property of $\mathbb{R}$ guarantees that supremum/infimum-based arguments (used in proving convergence of gradient descent under certain conditions) are well-defined

**Related Topics**

- Functions, domain, and range
- Limits and the formal $\epsilon$-$\delta$ definition
- Continuity over intervals
- Supremum, infimum, and boundedness of sets
- Sequences and convergence
- Neighborhoods and open/closed sets in $\mathbb{R}^n$