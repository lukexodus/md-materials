## Partial Fractions

### Definition and Purpose

Partial fraction decomposition is an algebraic technique that rewrites a rational function $\frac{P(x)}{Q(x)}$ as a sum of simpler fractions whose denominators are lower-degree polynomials. This decomposition is performed so that each resulting term can be integrated using elementary antiderivative rules (log, arctangent, power rule).

This technique applies when $P(x)$ and $Q(x)$ are polynomials and the degree of $P(x)$ is less than the degree of $Q(x)$ (a **proper rational function**). If the degree of $P(x)$ is greater than or equal to the degree of $Q(x)$, polynomial long division must be performed first.

### Why This Matters for Machine Learning

Partial fractions appear in ML-adjacent contexts primarily through:
- Deriving closed-form solutions to certain differential equations used in continuous-time models (e.g., some ODE-based dynamics in control-adjacent ML, continuous normalizing flows) [Inference — based on the general role of rational-function integration in solving linear ODEs; specific ML paper usage is not confirmed here]
- Computing integrals of rational functions that arise in probability (e.g., some density normalization constants) [Inference]
- Underlying symbolic integration in computer algebra systems that some ML pipelines call for exact preprocessing [Unverified — no specific system confirmed]

This technique is more foundational algebra-support than a direct ML algorithm component, so its ML relevance is largely indirect scaffolding for calculus fluency.

### General Setup

Given $\frac{P(x)}{Q(x)}$ in lowest terms with $\deg(P) < \deg(Q)$, factor $Q(x)$ completely into linear and irreducible quadratic factors:

$$Q(x) = (x - a_1)^{m_1}(x - a_2)^{m_2} \cdots (x^2 + bx + c)^{n_1} \cdots$$

Each factor type contributes a specific decomposition pattern.

### Case 1 — Distinct Linear Factors

If $Q(x) = (x - a_1)(x - a_2) \cdots (x - a_k)$ with all roots distinct:

$$\frac{P(x)}{Q(x)} = \frac{A_1}{x - a_1} + \frac{A_2}{x - a_2} + \cdots + \frac{A_k}{x - a_k}$$

**Example**

Decompose $\frac{3x + 5}{(x - 1)(x + 2)}$.

Set up:
$$\frac{3x+5}{(x-1)(x+2)} = \frac{A}{x-1} + \frac{B}{x+2}$$

Multiply both sides by $(x-1)(x+2)$:
$$3x + 5 = A(x+2) + B(x-1)$$

Substitute $x = 1$: $8 = 3A \Rightarrow A = \frac{8}{3}$

Substitute $x = -2$: $-1 = -3B \Rightarrow B = \frac{1}{3}$

Result:
$$\frac{3x+5}{(x-1)(x+2)} = \frac{8/3}{x-1} + \frac{1/3}{x+2}$$

Integrating:
$$\int \frac{3x+5}{(x-1)(x+2)}\,dx = \frac{8}{3}\ln|x-1| + \frac{1}{3}\ln|x+2| + C$$

### Case 2 — Repeated Linear Factors

If a factor $(x - a)$ appears with multiplicity $m$, it contributes:

$$\frac{A_1}{x-a} + \frac{A_2}{(x-a)^2} + \cdots + \frac{A_m}{(x-a)^m}$$

**Example**

Decompose $\frac{x + 1}{(x-2)^2}$.

$$\frac{x+1}{(x-2)^2} = \frac{A}{x-2} + \frac{B}{(x-2)^2}$$

Multiply through:
$$x + 1 = A(x-2) + B$$

Substitute $x = 2$: $3 = B$

Match coefficients of $x$: $1 = A \Rightarrow A = 1$

Result:
$$\frac{x+1}{(x-2)^2} = \frac{1}{x-2} + \frac{3}{(x-2)^2}$$

Integrating:
$$\int \frac{x+1}{(x-2)^2}\,dx = \ln|x-2| - \frac{3}{x-2} + C$$

### Case 3 — Irreducible Quadratic Factors

If $Q(x)$ contains an irreducible quadratic factor $(x^2 + bx + c)$ (discriminant $< 0$, so it cannot be factored into real linear terms), it contributes a term of the form:

$$\frac{Ax + B}{x^2 + bx + c}$$

**Example**

Decompose $\frac{2x^2 - x + 4}{(x-1)(x^2+4)}$.

$$\frac{2x^2 - x + 4}{(x-1)(x^2+4)} = \frac{A}{x-1} + \frac{Bx + C}{x^2+4}$$

Multiply through:
$$2x^2 - x + 4 = A(x^2+4) + (Bx+C)(x-1)$$

Substitute $x = 1$: $5 = 5A \Rightarrow A = 1$

Expand and match coefficients:
$$2x^2 - x + 4 = A x^2 + 4A + Bx^2 - Bx + Cx - C$$

Coefficient of $x^2$: $2 = A + B \Rightarrow B = 1$

Coefficient of $x^0$: $4 = 4A - C \Rightarrow C = 0$

Result:
$$\frac{2x^2-x+4}{(x-1)(x^2+4)} = \frac{1}{x-1} + \frac{x}{x^2+4}$$

Integrating (second term uses substitution $u = x^2+4$):
$$\int \frac{2x^2-x+4}{(x-1)(x^2+4)}\,dx = \ln|x-1| + \frac{1}{2}\ln(x^2+4) + C$$

### Case 4 — Repeated Irreducible Quadratic Factors

If $(x^2+bx+c)^n$ appears, it contributes:

$$\frac{A_1x+B_1}{x^2+bx+c} + \frac{A_2x+B_2}{(x^2+bx+c)^2} + \cdots + \frac{A_nx+B_n}{(x^2+bx+c)^n}$$

Terms with power $\geq 2$ in the denominator often require a reduction formula or trigonometric substitution ($x = \sqrt{c}\tan\theta$-type) to fully integrate.

### Improper Rational Functions

When $\deg(P) \geq \deg(Q)$, perform polynomial long division first:

$$\frac{P(x)}{Q(x)} = S(x) + \frac{R(x)}{Q(x)}$$

where $S(x)$ is the quotient polynomial and $R(x)$ is the remainder, with $\deg(R) < \deg(Q)$. Only $\frac{R(x)}{Q(x)}$ is then decomposed into partial fractions.

**Example**

$$\frac{x^3}{x^2 - 1} = x + \frac{x}{x^2-1}$$

The remainder term $\frac{x}{x^2-1}$ can then be decomposed using Case 1 since $x^2 - 1 = (x-1)(x+1)$.

### Decomposition Method Selection

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 800 480">
\<style\>
  .box { fill: var(--bg2, #f0f0f0); stroke: var(--border, #888); stroke-width: 1.5; }
  .txt { font-family: sans-serif; font-size: 14px; fill: var(--text, #222); }
  .lbl { font-family: sans-serif; font-size: 12px; fill: var(--text-muted, #555); }
  .title { font-family: sans-serif; font-size: 16px; font-weight: bold; fill: var(--text, #222); }
\</style\>
<text x="400" y="28" text-anchor="middle" class="title">Partial Fraction Decomposition Method Selector (svg_diagram)</text>

<rect x="320" y="45" width="160" height="45" rx="6" class="box" />
<text x="400" y="72" text-anchor="middle" class="txt">deg(P) ≥ deg(Q)?</text>

<rect x="120" y="130" width="180" height="45" rx="6" class="box" />
<text x="210" y="157" text-anchor="middle" class="txt">Long divide first</text>

<rect x="500" y="130" width="180" height="45" rx="6" class="box" />
<text x="590" y="157" text-anchor="middle" class="txt">Factor Q(x) fully</text>

<line x1="400" y1="90" x2="210" y2="130" stroke="var(--border,#888)" stroke-width="1.5" />
<text x="280" y="105" class="lbl">Yes</text>

<line x1="400" y1="90" x2="590" y2="130" stroke="var(--border,#888)" stroke-width="1.5" />
<text x="470" y="105" class="lbl">No</text>

<line x1="210" y1="175" x2="590" y2="175" stroke="var(--border,#888)" stroke-width="1.5" stroke-dasharray="4,3" />
<text x="400" y="192" text-anchor="middle" class="lbl">remainder term rejoins here</text>

<rect x="60" y="230" width="170" height="50" rx="6" class="box" />
<text x="145" y="252" text-anchor="middle" class="txt">Distinct linear</text>
<text x="145" y="268" text-anchor="middle" class="lbl">A/(x-a)</text>

<rect x="260" y="230" width="170" height="50" rx="6" class="box" />
<text x="345" y="252" text-anchor="middle" class="txt">Repeated linear</text>
<text x="345" y="268" text-anchor="middle" class="lbl">A₁/(x-a)+A₂/(x-a)²</text>

<rect x="460" y="230" width="170" height="50" rx="6" class="box" />
<text x="545" y="252" text-anchor="middle" class="txt">Irreducible quadratic</text>
<text x="545" y="268" text-anchor="middle" class="lbl">(Ax+B)/(x²+bx+c)</text>

<rect x="660" y="230" width="120" height="50" rx="6" class="box" />
<text x="720" y="252" text-anchor="middle" class="txt">Repeated quad</text>
<text x="720" y="268" text-anchor="middle" class="lbl">sum of powers</text>

<line x1="400" y1="175" x2="145" y2="230" stroke="var(--border,#888)" stroke-width="1.2" />
<line x1="400" y1="175" x2="345" y2="230" stroke="var(--border,#888)" stroke-width="1.2" />
<line x1="400" y1="175" x2="545" y2="230" stroke="var(--border,#888)" stroke-width="1.2" />
<line x1="400" y1="175" x2="720" y2="230" stroke="var(--border,#888)" stroke-width="1.2" />

<rect x="150" y="330" width="500" height="90" rx="6" class="box" />
<text x="400" y="355" text-anchor="middle" class="txt">Solve for unknown constants via:</text>
<text x="400" y="375" text-anchor="middle" class="lbl">Substitution of convenient x-values (roots)</text>
<text x="400" y="393" text-anchor="middle" class="lbl">and/or matching polynomial coefficients</text>

<line x1="145" y1="280" x2="300" y2="330" stroke="var(--border,#888)" stroke-width="1" />
<line x1="345" y1="280" x2="350" y2="330" stroke="var(--border,#888)" stroke-width="1" />
<line x1="545" y1="280" x2="480" y2="330" stroke="var(--border,#888)" stroke-width="1" />
<line x1="720" y1="280" x2="550" y2="330" stroke="var(--border,#888)" stroke-width="1" />

<rect x="270" y="440" width="260" height="35" rx="6" class="box" />
<text x="400" y="463" text-anchor="middle" class="txt">Integrate each simple term</text>
<line x1="400" y1="420" x2="400" y2="440" stroke="var(--border,#888)" stroke-width="1.5" />
</svg>

### Standard Integral Forms Resulting from Decomposition

After decomposition, the resulting terms integrate to one of these forms:

$$\int \frac{A}{x-a}\,dx = A\ln|x-a| + C$$

$$\int \frac{A}{(x-a)^n}\,dx = \frac{-A}{(n-1)(x-a)^{n-1}} + C \quad (n \geq 2)$$

$$\int \frac{Ax+B}{x^2+bx+c}\,dx = \frac{A}{2}\ln(x^2+bx+c) + \left(B - \frac{Ab}{2}\right)\int \frac{dx}{x^2+bx+c} + C$$

The remaining integral $\int \frac{dx}{x^2+bx+c}$ is resolved by completing the square and using the arctangent formula:

$$\int \frac{dx}{x^2+k^2} = \frac{1}{k}\arctan\left(\frac{x}{k}\right) + C$$

### Common Errors

- Forgetting to perform long division first when the rational function is improper — this leads to an incorrect decomposition setup
- Misclassifying a quadratic as irreducible when it actually factors into real linear terms (always check the discriminant $b^2 - 4ac$)
- Sign errors when substituting root values to solve for constants
- Omitting the full set of terms for repeated factors (e.g., only including $\frac{A}{(x-a)^2}$ and skipping $\frac{B}{x-a}$)

### Verification Method

After decomposing, it is standard practice to recombine the partial fractions over a common denominator and confirm the result matches the original numerator $P(x)$. This step catches most algebraic errors before integration is attempted.

### Connection to Linear Algebra

The system of equations produced when matching coefficients (Case 2–4 setups) is a linear system in the unknown constants $A, B, C, \ldots$. This can be solved via substitution, elimination, or matrix methods (Gaussian elimination), linking this technique conceptually to the linear algebra foundations used elsewhere in ML mathematics. [Inference — this is a structural observation about the algebra involved, not a claim about how partial fractions are used inside any specific ML system]

**Related Topics**
- Integration by parts
- Trigonometric substitution
- Improper integrals
- Polynomial long division review
- Solving linear systems (Gaussian elimination) as applied to coefficient matching
- Applications of rational function integrals in solving first-order linear ODEs