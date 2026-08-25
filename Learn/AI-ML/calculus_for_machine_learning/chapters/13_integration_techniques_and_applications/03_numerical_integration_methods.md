## Numerical Integration Methods

### Definition and Purpose

Numerical integration (also called quadrature) refers to algorithms that compute approximate values of definite integrals $\int_a^b f(x)\,dx$ when an exact closed-form antiderivative does not exist, is impractical to derive, or when $f(x)$ is only known at discrete sample points rather than as a formula. This is a standard, confirmed area of numerical analysis.

### Why This Matters for Machine Learning

Numerical integration connects to ML in several confirmed and inferential ways:
- Many probability computations (e.g., marginal likelihoods, Bayesian posterior normalization) involve integrals with no closed form and require numerical approximation. [Inference — this follows from the general mathematical structure of Bayesian inference; specific library implementations are not verified here]
- Expected value computations over continuous distributions in reinforcement learning and probabilistic modeling may require numerical quadrature or Monte Carlo estimation. [Inference]
- I cannot verify specific claims about which ML frameworks internally call which quadrature routines, so any such detail beyond general mathematical structure should be treated as [Unverified].

### The Riemann Sum Foundation

All numerical integration methods build on the Riemann sum definition of the definite integral:

$$\int_a^b f(x)\,dx \approx \sum_{i=1}^{n} f(x_i^*)\,\Delta x$$

where $\Delta x = \frac{b-a}{n}$ and $x_i^*$ is a sample point in the $i$-th subinterval. This is the standard definition from which the definite integral itself is formally derived as $n \to \infty$.

### Method 1 — Left and Right Riemann Sums

**Left Riemann Sum:**
$$L_n = \Delta x \sum_{i=0}^{n-1} f(x_i)$$

**Right Riemann Sum:**
$$R_n = \Delta x \sum_{i=1}^{n} f(x_i)$$

where $x_i = a + i\Delta x$.

These are the simplest approximations and generally have the largest error for a given $n$ compared to the methods below, particularly for monotonic functions. This is a standard, confirmed property of these methods.

**Example**

Approximate $\int_0^2 x^2\,dx$ using $n = 4$ (Left Riemann Sum).

$\Delta x = \frac{2-0}{4} = 0.5$

Sample points: $x_0=0, x_1=0.5, x_2=1, x_3=1.5$

$$L_4 = 0.5\left[f(0) + f(0.5) + f(1) + f(1.5)\right] = 0.5[0 + 0.25 + 1 + 2.25] = 0.5(3.5) = 1.75$$

The exact value is $\int_0^2 x^2\,dx = \frac{8}{3} \approx 2.667$, so this approximation underestimates because $f(x)=x^2$ is increasing and the left sum uses the smaller left-endpoint values on each subinterval. This underestimation behavior is a confirmed, general property for increasing functions with left sums.

### Method 2 — Midpoint Rule

$$M_n = \Delta x \sum_{i=1}^{n} f(\bar{x}_i)$$

where $\bar{x}_i$ is the midpoint of the $i$-th subinterval. The midpoint rule is generally more accurate than left/right Riemann sums for the same $n$, and its error term is $O(\Delta x^2)$ for functions with bounded second derivative. This is a confirmed result from numerical analysis error theory.

**Example**

Approximate $\int_0^2 x^2\,dx$ using $n=4$ (Midpoint Rule).

Midpoints: $0.25, 0.75, 1.25, 1.75$

$$M_4 = 0.5[f(0.25)+f(0.75)+f(1.25)+f(1.75)] = 0.5[0.0625+0.5625+1.5625+3.0625]$$
$$= 0.5(5.25) = 2.625$$

This is closer to the exact value $2.667$ than the left Riemann sum result.

### Method 3 — Trapezoidal Rule

$$T_n = \frac{\Delta x}{2}\left[f(x_0) + 2f(x_1) + 2f(x_2) + \cdots + 2f(x_{n-1}) + f(x_n)\right]$$

This approximates the area under the curve using trapezoids instead of rectangles. Its error term is also $O(\Delta x^2)$, and it is a confirmed standard method covered in essentially all introductory numerical analysis references.

**Example**

Approximate $\int_0^2 x^2\,dx$ using $n=4$ (Trapezoidal Rule).

$$T_4 = \frac{0.5}{2}[f(0) + 2f(0.5) + 2f(1) + 2f(1.5) + f(2)]$$
$$= 0.25[0 + 0.5 + 2 + 4.5 + 4] = 0.25(11) = 2.75$$

**Error Bound (Trapezoidal Rule):**

$$|E_T| \leq \frac{(b-a)^3}{12n^2}\max|f''(x)|$$

This is a confirmed, standard error bound formula from numerical analysis textbooks.

### Method 4 — Simpson's Rule

Simpson's Rule uses parabolic arcs instead of straight lines or rectangles, requiring an even number of subintervals $n$:

$$S_n = \frac{\Delta x}{3}\left[f(x_0) + 4f(x_1) + 2f(x_2) + 4f(x_3) + \cdots + 4f(x_{n-1}) + f(x_n)\right]$$

The coefficient pattern alternates $4, 2, 4, 2, \ldots, 4$ between the endpoints. Simpson's Rule has error term $O(\Delta x^4)$, making it substantially more accurate than the trapezoidal or midpoint rules for smooth functions at the same $n$. This is a confirmed result.

**Example**

Approximate $\int_0^2 x^2\,dx$ using $n=4$ (Simpson's Rule).

$$S_4 = \frac{0.5}{3}[f(0) + 4f(0.5) + 2f(1) + 4f(1.5) + f(2)]$$
$$= \frac{0.5}{3}[0 + 1 + 2 + 9 + 4] = \frac{0.5}{3}(16) = 2.6\overline{6}$$

This matches the exact value $\frac{8}{3} = 2.6\overline{6}$ exactly. This exact match is expected and confirmed by theory: Simpson's Rule integrates cubic polynomials (and therefore quadratics) exactly, because its derivation is based on fitting quadratic interpolants.

**Error Bound (Simpson's Rule):**

$$|E_S| \leq \frac{(b-a)^5}{180n^4}\max|f^{(4)}(x)|$$

This is a confirmed, standard error bound formula.

### Comparison of Convergence Rates

| Method | Error Order | Exact for polynomials up to degree |
|---|---|---|
| Left/Right Riemann | $O(\Delta x)$ | 0 |
| Midpoint | $O(\Delta x^2)$ | 1 |
| Trapezoidal | $O(\Delta x^2)$ | 1 |
| Simpson's | $O(\Delta x^4)$ | 3 |

This table reflects standard, confirmed results from numerical analysis theory.

### Visual Comparison of Approximation Shapes

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 800 500">
\<style\>
  .axis { stroke: var(--border, #888); stroke-width: 1.5; }
  .curve { stroke: var(--text, #333); stroke-width: 2; fill: none; }
  .rect { fill: var(--accent, #3b82f6); opacity: 0.3; stroke: var(--accent, #3b82f6); stroke-width: 1; }
  .trap { fill: var(--accent2, #ef4444); opacity: 0.25; stroke: var(--accent2, #ef4444); stroke-width: 1; }
  .txt { font-family: sans-serif; font-size: 13px; fill: var(--text, #222); }
  .title { font-family: sans-serif; font-size: 16px; font-weight: bold; fill: var(--text, #222); }
\</style\>
<text x="400" y="26" text-anchor="middle" class="title">Riemann vs Trapezoidal Approximation (svg_diagram)</text>

<text x="200" y="55" text-anchor="middle" class="txt">Left Riemann Sum (rectangles)</text>
<line x1="60" y1="220" x2="360" y2="220" class="axis" />
<line x1="60" y1="220" x2="60" y2="80" class="axis" />
<path d="M 60 210 Q 150 180 210 140 Q 280 100 360 90" class="curve" />
<rect x="60" y="210" width="60" height="10" class="rect" />
<rect x="120" y="185" width="60" height="35" class="rect" />
<rect x="180" y="150" width="60" height="70" class="rect" />
<rect x="240" y="105" width="60" height="115" class="rect" />
<rect x="300" y="95" width="60" height="125" class="rect" />
<text x="200" y="240" text-anchor="middle" class="txt">Rectangles under/over curve create gaps</text>

<text x="600" y="55" text-anchor="middle" class="txt">Trapezoidal Rule</text>
<line x1="460" y1="220" x2="760" y2="220" class="axis" />
<line x1="460" y1="220" x2="460" y2="80" class="axis" />
<path d="M 460 210 Q 550 180 610 140 Q 680 100 760 90" class="curve" />
<polygon points="460,210 520,185 520,220 460,220" class="trap" />
<polygon points="520,185 580,150 580,220 520,220" class="trap" />
<polygon points="580,150 640,105 640,220 580,220" class="trap" />
<polygon points="640,105 700,95 700,220 640,220" class="trap" />
<text x="600" y="240" text-anchor="middle" class="txt">Slanted tops follow curve more closely</text>

<text x="400" y="290" text-anchor="middle" class="txt">Simpson's Rule fits a parabola through each pair of subintervals,</text>
<text x="400" y="310" text-anchor="middle" class="txt">following curvature even more closely than the trapezoidal rule</text>

<rect x="150" y="350" width="500" height="90" rx="6" fill="var(--bg2,#f0f0f0)" stroke="var(--border,#888)" stroke-width="1.5" />
<text x="400" y="375" text-anchor="middle" class="txt">General accuracy ordering (same n, smooth f):</text>
<text x="400" y="400" text-anchor="middle" class="txt" font-weight="bold">Riemann &lt; Trapezoidal ≈ Midpoint &lt; Simpson's</text>
<text x="400" y="420" text-anchor="middle" class="txt">This ordering is a confirmed general result, though exact error</text>
</svg>

### Composite vs. Adaptive Methods

**Composite methods** apply a fixed rule (trapezoidal, Simpson's) uniformly across a fixed number of equal-width subintervals, as shown above. This is the standard usage covered in the examples.

**Adaptive quadrature** methods adjust subinterval width dynamically, using smaller subintervals where the function changes rapidly and larger subintervals where it is smoother. This is a confirmed, standard numerical analysis technique (e.g., adaptive Simpson's rule), though I cannot verify specific implementation details of any particular software library without checking its documentation directly.

### Monte Carlo Integration (Higher-Dimensional Context)

For high-dimensional integrals (common in ML settings involving many input variables), classical quadrature methods (trapezoidal, Simpson's) suffer from the "curse of dimensionality" — the number of required evaluation points grows exponentially with dimension. This is a confirmed, well-documented limitation in numerical analysis.

Monte Carlo integration instead estimates the integral using random sampling:

$$\int_a^b f(x)\,dx \approx (b-a) \cdot \frac{1}{N}\sum_{i=1}^{N} f(x_i), \quad x_i \sim \text{Uniform}(a,b)$$

The error of Monte Carlo integration decreases at a rate of $O(1/\sqrt{N})$ regardless of dimension, which is why it becomes preferable to classical quadrature in high dimensions despite its slower convergence rate in low dimensions. This convergence rate is a confirmed, standard result from probability theory (via the Central Limit Theorem).

Monte Carlo integration has documented relevance to ML techniques such as Markov Chain Monte Carlo (MCMC) sampling in Bayesian inference and some stochastic estimation procedures. [Inference — this is a general, widely-taught mathematical connection; I do not have access to information confirming specific implementation details of any named ML library's internal use of these methods]

### Common Errors

- Using an odd number of subintervals with Simpson's Rule — this method's formula requires $n$ to be even, and applying it with odd $n$ produces an invalid or incorrectly indexed computation
- Confusing the midpoint rule's coefficient pattern with the trapezoidal rule's coefficient pattern
- Assuming numerical integration error decreases linearly with more subintervals for all methods — the actual rate depends on the specific method's error order as shown in the comparison table
- Applying classical quadrature methods to very high-dimensional integrals without considering Monte Carlo alternatives, given the curse of dimensionality noted above

### Disclaimer on Behavioral/Applied Claims

Statements above about how numerical integration methods are used inside specific machine learning software, libraries, or published research are labeled [Inference] or [Unverified] as appropriate. I cannot verify internal implementation details of any named or unnamed ML system, and behavior of any such system is not guaranteed and may vary by implementation, version, or configuration.

**Related Topics**
- Monte Carlo methods and variance reduction techniques
- Gaussian quadrature (higher-order polynomial-exact methods)
- Error analysis and convergence rate theory
- Multivariable/multiple integrals
- Applications to Bayesian inference and marginal likelihood estimation