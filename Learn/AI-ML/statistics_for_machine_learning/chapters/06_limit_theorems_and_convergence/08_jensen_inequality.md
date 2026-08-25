## Jensen Inequality

### Definition

Jensen's inequality relates the value of a convex or concave function applied to an expectation to the expectation of the function applied to a random variable. For a convex function $\phi$ and a random variable $X$ with finite expectation:

$$\phi(E[X]) \leq E[\phi(X)]$$

For a concave function $\phi$, the inequality reverses:

$$\phi(E[X]) \geq E[\phi(X)]$$

Equality holds when $\phi$ is linear (affine), or, more generally, when $X$ is constant (degenerate distribution), or when $X$ is supported entirely on a region where $\phi$ is linear.

### Key Points

- A function $\phi$ is convex if, for all $x, y$ in its domain and $t \in [0,1]$: $\phi(tx + (1-t)y) \leq t\phi(x) + (1-t)\phi(y)$. Intuitively, the function curves upward (like a bowl).
- A function is concave if the inequality reverses; it curves downward (like a dome).
- The discrete two-point version of Jensen's inequality is the defining condition of convexity itself; the general form extends this to full probability distributions via expectation.
- The inequality direction depends entirely on the curvature of $\phi$ — this is the most common source of error when applying it, since reversing the assumed convexity/concavity flips the inequality.
- The "gap" $E[\phi(X)] - \phi(E[X])$ is non-negative for convex $\phi$ and relates to the variance of $X$ and the curvature of $\phi$, though the exact relationship depends on the specific function.

### Derivation (Sketch)

For a differentiable convex function $\phi$, the tangent line at any point $\mu = E[X]$ lies below the function everywhere:

$$\phi(x) \geq \phi(\mu) + \phi'(\mu)(x - \mu) \quad \text{for all } x$$

This follows from the definition of convexity for differentiable functions. Substituting $x = X$ (a random variable) and taking expectations on both sides:

$$E[\phi(X)] \geq E[\phi(\mu) + \phi'(\mu)(X - \mu)]$$



$$E[\phi(X)] \geq \phi(\mu) + \phi'(\mu)(E[X] - \mu)$$

Since $\mu = E[X]$, the term $E[X] - \mu = 0$, leaving:

$$E[\phi(X)] \geq \phi(\mu) = \phi(E[X])$$

This establishes the convex case. The concave case follows by applying the same argument to $-\phi$, which is convex when $\phi$ is concave.

### Worked Example

Let $\phi(x) = x^2$, which is convex, and let $X$ be a random variable with $E[X] = 3$ and $\text{Var}(X) = 4$.

**Question:** Compare $\phi(E[X])$ and $E[\phi(X)]$.

$$\phi(E[X]) = (E[X])^2 = 3^2 = 9$$

Using the identity $\text{Var}(X) = E[X^2] - (E[X])^2$:

$$E[X^2] = \text{Var}(X) + (E[X])^2 = 4 + 9 = 13$$

So $E[\phi(X)] = E[X^2] = 13$.

**Result:** $\phi(E[X]) = 9 \leq 13 = E[\phi(X)]$, confirming Jensen's inequality for this convex case. This particular example is in fact an exact restatement of the variance identity — the "gap" $E[X^2] - (E[X])^2$ is precisely $\text{Var}(X)$, which is always non-negative.

### Use in Machine Learning

- **Evidence Lower Bound (ELBO) in variational inference**: Jensen's inequality (applied to the concave logarithm function) is used to derive the ELBO, a tractable lower bound on the log-likelihood that underlies variational autoencoders (VAEs) and other latent-variable models.
- **Expectation-Maximization (EM) algorithm**: The E-step derivation relies on Jensen's inequality to construct a lower bound on the log-likelihood that is then maximized.
- **Loss function convexity arguments**: When analyzing whether a loss function is convex, Jensen's inequality provides the formal justification for statements like "the expected loss over a mixture is bounded by the mixture of expected losses."
- **Bounding log-likelihoods and probabilistic bounds**: Because $\log$ is concave, $E[\log X] \leq \log E[X]$, a relationship used frequently in information-theoretic derivations, including in deriving the Kullback-Leibler divergence's non-negativity.

[Inference] The prevalence of Jensen's inequality in specific ML subfields (variational inference, EM, information theory) reflects the mathematical structure of log-likelihood objectives rather than a documented usage statistic I can cite; I do not have access to a source quantifying "how often" it appears across ML literature.

### Special Case: KL Divergence Non-Negativity

Jensen's inequality can be used to demonstrate that Kullback-Leibler divergence is always non-negative. For distributions $P$ and $Q$:

$$D_{KL}(P \| Q) = E_P\left[\log \frac{P(X)}{Q(X)}\right] = -E_P\left[\log \frac{Q(X)}{P(X)}\right]$$

Since $\log$ is concave, Jensen's inequality gives:

$$-E_P\left[\log \frac{Q(X)}{P(X)}\right] \geq -\log E_P\left[\frac{Q(X)}{P(X)}\right] = -\log(1) = 0$$

This shows $D_{KL}(P \| Q) \geq 0$, with equality [Inference] generally understood to hold when $P = Q$ almost everywhere — I have not independently re-derived the full equality-condition proof here, so this specific claim should be treated as a standard textbook result rather than something verified step-by-step in this response.

### Comparison Table

| Property | Convex Case | Concave Case |
| --- | --- | --- |
| Inequality direction | $\phi(E[X]) \leq E[\phi(X)]$ | $\phi(E[X]) \geq E[\phi(X)]$ |
| Example function | $x^2$, $e^x$ | $\log(x)$, $\sqrt{x}$ |
| Common ML use | Variance/moment bounds | ELBO, log-likelihood bounds |
| Equality condition | $X$ constant, or $\phi$ linear on support | $X$ constant, or $\phi$ linear on support |

### Visualization

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 700 400" font-family="Arial, sans-serif">
<text x="350" y="26" text-anchor="middle" font-size="16" font-weight="bold" fill="#1a1a1a">Jensen's Inequality for Convex φ(x) = x² (svg_diagram)</text>

<line x1="70" y1="340" x2="640" y2="340" stroke="#333" stroke-width="2" />
<line x1="70" y1="340" x2="70" y2="50" stroke="#333" stroke-width="2" />
<text x="640" y="360" text-anchor="middle" font-size="12" fill="#333">x</text>
<text x="45" y="55" text-anchor="middle" font-size="12" fill="#333">φ(x)</text>


<path d="M 90 100 C 200 260, 260 320, 320 336 C 380 320, 440 260, 500 160 C 540 100, 570 60, 610 55" fill="none" stroke="`#2980b9`" stroke-width="3" />


<line x1="150" y1="290" x2="480" y2="110" stroke="#c0392b" stroke-width="2" stroke-dasharray="5,4" />

<line x1="315" y1="340" x2="315" y2="200" stroke="#27ae60" stroke-width="2" stroke-dasharray="3,3" />
<circle cx="315" cy="336" r="5" fill="#27ae60" />
<text x="315" y="358" text-anchor="middle" font-size="12" fill="#27ae60">E[X] = μ</text>

<circle cx="315" cy="336" r="4" fill="#2980b9" />
<text x="380" y="336" font-size="12" fill="#2980b9">φ(E[X])</text>

<circle cx="315" cy="200" r="5" fill="#c0392b" />
<text x="380" y="200" font-size="12" fill="#c0392b">E[φ(X)]</text>

<line x1="330" y1="336" x2="330" y2="200" stroke="#7f8c8d" stroke-width="1" />
<text x="340" y="270" font-size="11" fill="#7f8c8d">Jensen gap</text>

<text x="150" y="70" font-size="12" fill="#333">Secant line lies above curve</text>

<text x="150" y="88" font-size="12" fill="#333">for convex φ (chord ≥ function)</text>

</svg>

### Limitations

- **Requires convexity/concavity of $\phi$**: The inequality does not apply, or applies with unknown direction, to functions that are neither globally convex nor globally concave over the relevant domain.
- **Direction sensitivity**: [Inference] Misidentifying whether a function is convex or concave over the actual range of $X$ is a common source of error when applying this result, though I do not have a documented source quantifying how frequently this specific error occurs in practice.
- **Bound tightness varies**: The gap between $\phi(E[X])$ and $E[\phi(X)]$ can be small or large depending on the variance of $X$ and the curvature of $\phi$; the inequality itself gives no indication of how large the gap is without further analysis.
- **Strict vs. non-strict convexity**: For strictly convex functions, the inequality is strict unless $X$ is almost surely constant; for non-strictly convex (but still convex) functions, equality can hold under broader conditions.

> Correction applies preemptively to flagged items above: Several statements regarding "how often" or "how commonly" certain errors or usage patterns occur in applied ML practice are labeled [Inference] because I do not have access to confirmed statistical sources on these specific claims. The mathematical definitions, derivation, and worked numerical example are standard, verifiable results and are not subject to this caveat.

### Next Steps

- Convex functions and convex sets — formal properties
- Evidence Lower Bound (ELBO) — full derivation using Jensen's inequality
- Expectation-Maximization algorithm — E-step and M-step derivation
- Kullback-Leibler divergence — properties and use in ML loss functions
- Convex optimization fundamentals for ML
- Chernoff bound — related use of convexity via exponential moments