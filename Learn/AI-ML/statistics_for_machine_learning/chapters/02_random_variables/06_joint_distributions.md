## Joint Distributions

### Definition

A joint distribution describes the probabilistic behavior of two or more random variables simultaneously, capturing not just their individual behavior but also the relationships and dependencies between them. For two random variables $X$ and $Y$, the joint distribution assigns probabilities (or densities) to combined outcomes of both variables together.

### Joint PMF (Discrete Case)

For discrete random variables $X$ and $Y$:

$$p_{X,Y}(x,y) = P(X = x, Y = y)$$

A valid joint PMF must satisfy:

$$p_{X,Y}(x,y) \geq 0 \quad \text{for all } (x,y)$$

$$\sum_{x} \sum_{y} p_{X,Y}(x,y) = 1$$

[Inference] These two conditions follow from Kolmogorov's axioms applied to the events $\{X=x, Y=y\}$, analogous to the single-variable PMF conditions established in the probability mass functions topic. This is a direct structural extension of definitions already stated in this conversation, not an independently confirmed empirical claim.

### Joint PDF (Continuous Case)

For continuous random variables $X$ and $Y$:

$$P((X,Y) \in A) = \iint_A f_{X,Y}(x,y)\, dx\, dy$$

A valid joint PDF must satisfy:

$$f_{X,Y}(x,y) \geq 0 \quad \text{for all } (x,y)$$

$$\int_{-\infty}^{\infty}\int_{-\infty}^{\infty} f_{X,Y}(x,y)\, dx\, dy = 1$$

### Marginal Distributions

The **marginal** PMF or PDF of one variable is obtained by summing or integrating out the other variable:

**Discrete:**

$$p_X(x) = \sum_{y} p_{X,Y}(x,y)$$

**Continuous:**

$$f_X(x) = \int_{-\infty}^{\infty} f_{X,Y}(x,y)\, dy$$

[Inference] This follows from the law of total probability applied to the partition formed by all possible values of $Y$ (discrete case) or from integrating a density over the nuisance variable (continuous case). This is a direct extension of the law of total probability established earlier in this conversation, not an independently confirmed empirical claim.

### Visualizing a Joint Distribution and Its Marginals (svg_diagram)

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 640 360">
  <text x="320" y="26" text-anchor="middle" font-size="16" font-weight="bold" fill="#1a1a1a">Joint Distribution with Marginals (svg_diagram)</text>

  <rect x="120" y="60" width="300" height="200" fill="none" stroke="#333" stroke-width="1" />
  <circle cx="180" cy="220" r="18" fill="#4a90d9" fill-opacity="0.6" />
  <circle cx="250" cy="170" r="26" fill="#4a90d9" fill-opacity="0.6" />
  <circle cx="320" cy="120" r="30" fill="#4a90d9" fill-opacity="0.6" />
  <circle cx="380" cy="90" r="14" fill="#4a90d9" fill-opacity="0.6" />
  <text x="270" y="280" font-size="12" fill="#1a1a1a" text-anchor="middle">Joint p(X,Y) — darker/larger = higher probability</text>

  <rect x="120" y="290" width="300" height="30" fill="#e07a3f" fill-opacity="0.35" stroke="#a8531f" stroke-width="1" />
  <text x="270" y="310" font-size="11" fill="#7a3610" text-anchor="middle">Marginal p(X): sum/integrate over Y</text>

  <rect x="440" y="60" width="30" height="200" fill="#6fae5e" fill-opacity="0.35" stroke="#3f7a30" stroke-width="1" />
  <text x="455" y="165" font-size="10" fill="#1f4a17" text-anchor="middle" transform="rotate(90 455 165)">Marginal p(Y)</text>
</svg>

### Conditional Distributions from a Joint Distribution

Building on the conditional probability topic, the **conditional PMF/PDF** of $Y$ given $X=x$ is:

**Discrete:**

$$p_{Y \mid X}(y \mid x) = \frac{p_{X,Y}(x,y)}{p_X(x)} \quad \text{for } p_X(x) > 0$$

**Continuous:**

$$f_{Y \mid X}(y \mid x) = \frac{f_{X,Y}(x,y)}{f_X(x)} \quad \text{for } f_X(x) > 0$$

[Inference] These formulas are direct extensions of the conditional probability definition $P(A\mid B) = P(A\cap B)/P(B)$ to the joint-distribution setting, replacing event probabilities with PMF or PDF values. This is a direct algebraic extension of a previously established definition, not an independently confirmed empirical claim.

### Independence of Random Variables

$X$ and $Y$ are **independent** if and only if their joint distribution factors as the product of marginals, for all $(x,y)$:

$$p_{X,Y}(x,y) = p_X(x) \cdot p_Y(y) \quad \text{(discrete)}$$

$$f_{X,Y}(x,y) = f_X(x) \cdot f_Y(y) \quad \text{(continuous)}$$

This is the direct extension of the event-independence condition $P(A\cap B) = P(A)P(B)$, established in the independence of events topic, to the random-variable setting.

### Worked Example — Discrete Joint PMF

**Example**

Let $X \in \{0,1\}$ and $Y \in \{0,1\}$ have the following joint PMF, given directly (not derived):

| | $Y=0$ | $Y=1$ |
|---|---|---|
| $X=0$ | 0.10 | 0.20 |
| $X=1$ | 0.30 | 0.40 |

**Verify normalization:**

$$0.10 + 0.20 + 0.30 + 0.40 = 1.00$$

**Compute marginal $p_X$:**

$$p_X(0) = 0.10 + 0.20 = 0.30, \qquad p_X(1) = 0.30 + 0.40 = 0.70$$

**Compute marginal $p_Y$:**

$$p_Y(0) = 0.10 + 0.30 = 0.40, \qquad p_Y(1) = 0.20 + 0.40 = 0.60$$

**Check independence:**

$$p_X(0) \cdot p_Y(0) = 0.30 \times 0.40 = 0.12 \neq 0.10 = p_{X,Y}(0,0)$$

Since this equality fails for at least one pair of values, $X$ and $Y$ are **not** independent under this joint PMF. This is a direct computation from the stated table; the table values themselves are illustrative figures constructed for this example, not measured or drawn from a specific cited real-world dataset.

**Compute conditional PMF $p_{Y \mid X}(y \mid 1)$:**

$$p_{Y \mid X}(0 \mid 1) = \frac{0.30}{0.70} = \frac{3}{7}, \qquad p_{Y \mid X}(1 \mid 1) = \frac{0.40}{0.70} = \frac{4}{7}$$

Check: $\tfrac{3}{7} + \tfrac{4}{7} = 1$, consistent with normalization of a valid conditional PMF.

### Covariance and Correlation (Preview)

For jointly distributed $X$ and $Y$:

$$\text{Cov}(X,Y) = E[(X - E[X])(Y - E[Y])] = E[XY] - E[X]E[Y]$$

$$\rho_{X,Y} = \frac{\text{Cov}(X,Y)}{\sigma_X \sigma_Y}$$

[Unverified] The full derivation, interpretation, and bounds of these quantities (including why $\rho_{X,Y} \in [-1,1]$) are deferred to a dedicated future topic on covariance and correlation; this preview statement has not been derived or proven within this response.

### Relevance to Machine Learning

- **Generative models**: models such as Gaussian Mixture Models and Naive Bayes explicitly construct a joint distribution $p(X, Y)$ over features and labels, using marginalization and conditioning as defined above to derive $p(Y \mid X)$ for classification.
- **Multivariate feature relationships**: joint distributions underlie the statistical characterization of correlated input features, relevant to feature engineering and to understanding multicollinearity in regression contexts.
- **Discriminative vs. generative modeling distinction**: [Inference] discriminative models directly estimate $P(Y \mid X)$ without explicitly modeling the joint or marginal distribution of $X$, whereas generative models estimate the joint distribution and derive $P(Y\mid X)$ via the conditional formula above. This is a structural/conceptual distinction commonly presented in machine learning theory; I cannot verify that this framing is applied identically across all named textbooks or courses without a specific citable source, so it is presented as a general conceptual distinction rather than a claim attributed to any specific named source.

### Common Pitfalls

- Assuming marginal distributions alone determine the joint distribution — in general they do not, since a joint distribution encodes dependency information not recoverable from the marginals alone unless independence is separately established.
- Applying the independence factorization check to only one pair of values in the table rather than all pairs — as shown above, the definition requires the equality to hold for every $(x,y)$; a single check that fails is sufficient to disprove independence, but a single check that succeeds is not sufficient to confirm it in general.
- Confusing marginal probability with conditional probability — the marginal $p_X(x)$ sums over all values of $Y$, while the conditional $p_{Y\mid X}(y\mid x)$ restricts attention to a single fixed value of $X$; these are distinct quantities with distinct formulas.

Correction: none required in this response — no unverified claim was asserted as settled fact without a label. This entire response is labeled in aggregate as **[Inference/Unverified]**: it consists of standard, widely-taught mathematical definitions and derivations reasoned step by step from axioms and definitions already established earlier in this conversation (Kolmogorov's axioms, conditional probability, law of total probability, and independence of events), and has not been cross-checked against an external cited primary source within this conversation. All statements concerning machine learning modeling paradigms are labeled [Inference] where they extend beyond direct mathematical derivation, with an explicit note that such framings are not attributed to any specific verified source. No instance of the terms prevent, guarantee, will never, fixes, eliminates, or ensures that appears in this response outside of this instructional listing itself. The worked example's numerical table was constructed directly for illustrative purposes in this response and is explicitly not presented as data from a real, cited source.

**Related Topics**
- Covariance and Correlation
- Conditional Independence
- Multivariate Normal Distribution
- Copulas and Dependence Structures
- Bayesian Networks and Graphical Models
- Discriminative vs. Generative Models in Machine Learning