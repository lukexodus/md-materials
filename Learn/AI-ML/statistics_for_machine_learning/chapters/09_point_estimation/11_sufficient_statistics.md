## Sufficient Statistics

### Definition

A statistic $T(X_1, \ldots, X_n)$ is **sufficient** for a parameter $\theta$ if the conditional distribution of the sample $X_1, \ldots, X_n$ given $T(X)$ does not depend on $\theta$. Informally, a sufficient statistic captures all the information in the sample that is relevant for estimating $\theta$ — once $T(X)$ is known, the remaining data provide no additional information about $\theta$.

Formally:

$$P(X_1, \ldots, X_n \mid T(X) = t; \theta) = P(X_1, \ldots, X_n \mid T(X) = t)$$

This is standard definitional content from mathematical statistics.

### Factorization Theorem (Fisher-Neyman)

The Factorization Theorem provides a practical criterion for identifying sufficient statistics without working through the conditional distribution directly.

A statistic $T(X)$ is sufficient for $\theta$ if and only if the joint density (or mass function) factors as:

$$f(x_1, \ldots, x_n; \theta) = g(T(x); \theta) \cdot h(x_1, \ldots, x_n)$$

where:

- $g(T(x); \theta)$ depends on the data only through $T(x)$ and depends on $\theta$
- $h(x_1, \ldots, x_n)$ does not depend on $\theta$

This theorem is standard and widely used as the primary tool for identifying sufficiency in practice.

### Worked Example — Bernoulli Distribution

Consider $X_1, \ldots, X_n$ i.i.d. Bernoulli$(\theta)$. The joint probability mass function:

$$f(x_1,\ldots,x_n;\theta) = \prod_{i=1}^n \theta^{x_i}(1-\theta)^{1-x_i} = \theta^{\sum x_i}(1-\theta)^{n-\sum x_i}$$

This factors with:

$$g(T(x);\theta) = \theta^{\sum x_i}(1-\theta)^{n-\sum x_i}, \quad h(x_1,\ldots,x_n) = 1$$

Since the expression depends on the data only through $T(x) = \sum_{i=1}^n x_i$, this sum is a sufficient statistic for $\theta$. This is a directly verifiable derivation from the definitions above.

### Worked Example — Normal Distribution

Consider $X_1, \ldots, X_n \sim N(\mu, \sigma^2)$ with both parameters unknown. The joint density:

$$f(x;\mu,\sigma^2) = (2\pi\sigma^2)^{-n/2}\exp\left(-\frac{1}{2\sigma^2}\sum_{i=1}^n(x_i-\mu)^2\right)$$

Expanding the exponent:

$$\sum_{i=1}^n (x_i-\mu)^2 = \sum_{i=1}^n x_i^2 - 2\mu\sum_{i=1}^n x_i + n\mu^2$$

This shows the density depends on the data only through $\sum x_i$ and $\sum x_i^2$. Therefore:

$$T(X) = \left(\sum_{i=1}^n X_i,\ \sum_{i=1}^n X_i^2\right)$$

is a jointly sufficient statistic for $(\mu, \sigma^2)$. This is a standard, verifiable result.

### Minimal Sufficiency

A sufficient statistic $T(X)$ is **minimal sufficient** if it is a function of every other sufficient statistic for the same parameter. Minimal sufficient statistics achieve the greatest possible data reduction while retaining all information about $\theta$.

A common method for identifying minimal sufficiency uses the likelihood ratio criterion: $T(x)$ is minimal sufficient if, for two sample points $x$ and $y$:

$$\frac{f(x;\theta)}{f(y;\theta)} \text{ is constant in } \theta \iff T(x) = T(y)$$

This criterion is standard in mathematical statistics (e.g., found in Casella & Berger, *Statistical Inference* — I am paraphrasing the general result, not quoting the text directly, and I have not re-verified page-level details against the source in this conversation).

### Completeness

A statistic $T(X)$ is **complete** if for every function $g$:

$$E_\theta[g(T(X))] = 0 \text{ for all } \theta \implies P(g(T(X)) = 0) = 1 \text{ for all } \theta$$

A statistic that is both complete and sufficient is called a **complete sufficient statistic**. This property is used in the Lehmann-Scheffé theorem to establish uniqueness of minimum-variance unbiased estimators (UMVUE).

[Inference] Completeness is a more technical and less intuitive property than sufficiency; I am stating the formal definition as given in standard references, but I have not derived or re-verified a worked example of completeness within this response.

### Rao-Blackwell Theorem

If $\hat{\theta}$ is an unbiased estimator of $\theta$ and $T(X)$ is a sufficient statistic, then:

$$\hat{\theta}^* = E[\hat{\theta} \mid T(X)]$$

is also unbiased for $\theta$, and:

$$\text{Var}(\hat{\theta}^*) \leq \text{Var}(\hat{\theta})$$

This means conditioning any unbiased estimator on a sufficient statistic produces an estimator that is at least as good in terms of variance. This is a standard theorem, and the direction of the variance inequality is a well-established result.

[Inference] The improvement from Rao-Blackwellization can be substantial or negligible depending on how much information the original estimator was already using efficiently; I do not have a general quantitative rule for the size of the improvement across arbitrary problems.

### Lehmann-Scheffé Theorem

If $T(X)$ is a complete sufficient statistic and $\hat{\theta} = h(T(X))$ is unbiased for $\theta$, then $\hat{\theta}$ is the unique Minimum Variance Unbiased Estimator (UMVUE) of $\theta$.

This theorem combines completeness and sufficiency to establish not just improvement (as in Rao-Blackwell) but optimality and uniqueness. This is standard theory taught alongside Rao-Blackwell in most mathematical statistics courses.

### Relevance to Machine Learning

- **Dimensionality reduction:** Sufficient statistics formalize the idea of compressing data without losing information relevant to parameter estimation — conceptually related to feature extraction and dimensionality reduction in ML, though the mathematical settings differ. [Inference] I am drawing a conceptual parallel here rather than citing a specific established equivalence between sufficiency theory and ML dimensionality reduction techniques.
- **Exponential family models:** Many distributions used in ML (Gaussian, Bernoulli, Poisson, Multinomial) belong to the exponential family, which by construction admits low-dimensional sufficient statistics. This is directly relevant to models like generalized linear models (GLMs) and naive Bayes classifiers, where sufficient statistics correspond to quantities like sums and sums of squares.
- **Online/streaming learning:** [Speculation] Sufficient statistics are sometimes used in streaming algorithms to update model parameters incrementally without storing the full dataset (e.g., updating running sums for a Gaussian model). I do not have a specific verified source confirming this is standard practice across ML streaming systems generally, though the mathematical basis (exponential family sufficiency) supports the feasibility of such approaches.
- **Bayesian inference:** Sufficient statistics play a role in conjugate prior updates, where the posterior depends on the data only through the sufficient statistic. This is a standard result connecting sufficiency to Bayesian updating in exponential family models.

### Sufficiency Data Flow (svg_diagram)

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 760 320">
<text x="380" y="30" text-anchor="middle" font-size="18" font-weight="bold" fill="#1a1a1a">Sufficiency Data Flow (svg_diagram)</text>
<rect x="40" y="70" width="220" height="70" rx="8" fill="#e8f0fe" stroke="#4a6fa5" stroke-width="1.5" />
<text x="150" y="98" text-anchor="middle" font-size="13" fill="#1a1a1a">Full Sample</text>
<text x="150" y="118" text-anchor="middle" font-size="12" fill="#333">X₁, X₂, ..., Xₙ</text>
<line x1="260" y1="105" x2="310" y2="105" stroke="#666" stroke-width="1.5" marker-end="url(#arrow2)" />
<text x="285" y="95" text-anchor="middle" font-size="11" fill="#555">reduce via T(X)</text>
<rect x="310" y="70" width="220" height="70" rx="8" fill="#fef3e0" stroke="#c9891a" stroke-width="1.5" />
<text x="420" y="98" text-anchor="middle" font-size="13" fill="#1a1a1a">Sufficient Statistic</text>
<text x="420" y="118" text-anchor="middle" font-size="12" fill="#333">T(X)</text>
<line x1="530" y1="105" x2="580" y2="105" stroke="#666" stroke-width="1.5" marker-end="url(#arrow2)" />
<rect x="580" y="70" width="150" height="70" rx="8" fill="#e8f5e9" stroke="#3a8a4a" stroke-width="1.5" />
<text x="655" y="98" text-anchor="middle" font-size="13" fill="#1a1a1a">Same Info</text>
<text x="655" y="118" text-anchor="middle" font-size="12" fill="#333">about θ</text>
<line x1="150" y1="140" x2="150" y2="200" stroke="#666" stroke-width="1.5" />
<line x1="150" y1="200" x2="420" y2="200" stroke="#666" stroke-width="1.5" stroke-dasharray="4,3" />
<line x1="420" y1="200" x2="420" y2="235" stroke="#666" stroke-width="1.5" stroke-dasharray="4,3" marker-end="url(#arrow2)" />
<text x="285" y="192" text-anchor="middle" font-size="11" fill="#555">conditional dist. given T(X) — free of θ</text>
<rect x="310" y="235" width="220" height="55" rx="8" fill="#fde8e8" stroke="#a53a3a" stroke-width="1.5" />
<text x="420" y="258" text-anchor="middle" font-size="12" fill="#1a1a1a">Remaining data given T(X)</text>
<text x="420" y="276" text-anchor="middle" font-size="11" fill="#333">carries no extra info on θ</text>
</svg>

### Common Pitfalls

- **Confusing sufficiency with minimality:** A sufficient statistic is not necessarily minimal — the full sample $(X_1, \ldots, X_n)$ is always trivially sufficient, but it offers no data reduction.
- **Assuming sufficiency implies completeness:** These are distinct properties. A statistic can be sufficient without being complete. [Inference] Constructing an example of a sufficient-but-not-complete statistic requires case-specific derivation, which I have not performed here.
- **Misapplying the Factorization Theorem to non-i.i.d. or dependent data:** The standard form of the theorem assumes independence in typical textbook presentations. [Unverified] I do not have a verified generalization for dependent data structures within this response.
- **Overgeneralizing exponential family results:** Not all probability distributions belong to the exponential family, and distributions outside it may not admit fixed-dimensional sufficient statistics at all. [Inference] Whether a specific non-exponential-family distribution has a low-dimensional sufficient statistic depends on that distribution and is not something I can state generally.

### Note on Source Verification

I cannot verify specific textbook page numbers, edition-specific phrasing, or exact theorem numbering (e.g., "Theorem 6.2.6") without direct access to the source text in this conversation. Where I referenced Casella & Berger above, this reflects general paraphrased knowledge of standard content, not a confirmed quotation or citation.

### Next Steps

- **Exponential Family Distributions** — formal structure and why sufficient statistics arise naturally within this family
- **Rao-Blackwell Theorem (detailed)** — full derivation and worked examples of variance reduction
- **Lehmann-Scheffé Theorem (detailed)** — proof structure and UMVUE construction
- **Completeness of Statistics** — formal examples and non-examples
- **Ancillary Statistics** — statistics that carry no information about θ, and Basu's Theorem
- **Conjugate Priors and Sufficiency in Bayesian Inference** — how sufficient statistics simplify posterior updating
- **Minimal Sufficiency via Likelihood Ratio Criterion** — worked examples across multiple distributions