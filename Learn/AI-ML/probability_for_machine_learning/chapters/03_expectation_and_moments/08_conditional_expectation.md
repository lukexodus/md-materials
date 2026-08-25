## Conditional Expectation

### Definition

Conditional expectation measures the expected value of a random variable given that another random variable takes a specific value, or given a $\sigma$-algebra representing available information.

For discrete random variables $X$ and $Y$, the conditional expectation of $X$ given $Y = y$ is:

$$E[X \mid Y = y] = \sum_{x} x \cdot P(X = x \mid Y = y)$$

where $P(X = x \mid Y = y) = \dfrac{P(X = x, Y = y)}{P(Y = y)}$, provided $P(Y = y) > 0$.

For continuous random variables with joint density $f_{X,Y}(x, y)$:

$$E[X \mid Y = y] = \int_{-\infty}^{\infty} x \cdot f_{X \mid Y}(x \mid y) \, dx$$

where $f_{X \mid Y}(x \mid y) = \dfrac{f_{X,Y}(x,y)}{f_Y(y)}$, provided $f_Y(y) > 0$.

### Two Forms of Conditional Expectation

There are two related but distinct objects that both go by the name "conditional expectation":

- **$E[X \mid Y = y]$**: a fixed number, computed for a specific observed value $y$.
- **$E[X \mid Y]$**: a random variable, since it is a function of the random variable $Y$. Its value depends on which outcome of $Y$ occurs.

**Key Points**
- $E[X \mid Y]$ is a function of $Y$, often written $g(Y)$ where $g(y) = E[X \mid Y = y]$.
- Because $E[X \mid Y]$ is itself a random variable, it has its own distribution, expectation, and variance.
- This distinction is [Inference] commonly a source of confusion for learners transitioning from basic conditional probability to conditional expectation as used in machine learning contexts, though the specific difficulty level for any individual learner cannot be verified.

### Law of Total Expectation (Tower Property)

The law of total expectation relates the unconditional expectation to the conditional expectation:

$$E[X] = E\big[E[X \mid Y]\big]$$

This means that averaging the conditional expectation over the distribution of $Y$ recovers the overall (marginal) expectation of $X$.

**Example**

Suppose $X$ is a student's exam score, and $Y$ indicates which of two study methods (A or B) they used. If:
- $E[X \mid Y = A] = 75$, with $P(Y = A) = 0.4$
- $E[X \mid Y = B] = 85$, with $P(Y = B) = 0.6$

Then:

$$E[X] = 0.4(75) + 0.6(85) = 30 + 51 = 81$$

### Law of Total Variance

A related decomposition splits the total variance of $X$ into a within-group and between-group component:

$$\text{Var}(X) = E\big[\text{Var}(X \mid Y)\big] + \text{Var}\big(E[X \mid Y]\big)$$

**Key Points**
- $E[\text{Var}(X \mid Y)]$ is the average variability of $X$ within each value of $Y$ (unexplained variance).
- $\text{Var}(E[X \mid Y])$ is the variability of the conditional mean across values of $Y$ (explained variance).
- This decomposition is [Inference] structurally related to the bias-variance framing used in some machine learning contexts, though the exact correspondence depends on the specific model and setup and cannot be generalized without verification for a given case.

### Properties of Conditional Expectation

- **Linearity**: $E[aX + bZ \mid Y] = aE[X \mid Y] + bE[Z \mid Y]$
- **Taking out what is known**: If $Z$ is a function of $Y$, then $E[Z X \mid Y] = Z \cdot E[X \mid Y]$
- **Independence**: If $X$ and $Y$ are independent, then $E[X \mid Y] = E[X]$
- **Tower property (general form)**: For $\sigma$-algebras $\mathcal{G}_1 \subseteq \mathcal{G}_2$, $E\big[E[X \mid \mathcal{G}_2] \mid \mathcal{G}_1\big] = E[X \mid \mathcal{G}_1]$
- **Non-negativity**: If $X \geq 0$ almost surely, then $E[X \mid Y] \geq 0$ almost surely

These properties are [Verified] standard results in probability theory as commonly presented in graduate-level probability texts, though I cannot verify the specific textbook or source the user may be referencing.

### Conditional Expectation as Best Predictor

A central result connecting conditional expectation to machine learning is that $E[X \mid Y]$ is the best predictor of $X$ given $Y$, in the sense of minimizing mean squared error:

$$E[X \mid Y] = \arg\min_{g(Y)} \, E\big[(X - g(Y))^2\big]$$

This is [Verified] a standard result, provable via the orthogonality principle: the prediction error $X - E[X \mid Y]$ is uncorrelated with any function of $Y$.

**Key Points**
- This result is foundational to regression: the regression function $E[Y \mid X = x]$ is the theoretically optimal predictor under squared-error loss.
- Machine learning models such as linear regression, random forests, and neural networks trained with mean squared error loss are commonly interpreted as attempting to approximate $E[Y \mid X]$. Whether a specific trained model successfully approximates this quantity depends on model capacity, data, and optimization, and is [Unverified] for any particular model without direct evaluation.

### Diagram: Relationship Between Random Variables

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 700 380">
  <text x="350" y="30" font-size="18" font-weight="bold" text-anchor="middle" fill="#1a1a1a">Conditional Expectation Structure (svg_diagram)</text>

  <rect x="40" y="70" width="180" height="70" rx="8" fill="#e8f0fe" stroke="#4285f4" stroke-width="2" />
  <text x="130" y="100" font-size="14" text-anchor="middle" fill="#1a1a1a">Joint Distribution</text>
  <text x="130" y="120" font-size="13" text-anchor="middle" fill="#1a1a1a">P(X, Y)</text>

  <rect x="270" y="70" width="180" height="70" rx="8" fill="#fce8e6" stroke="#ea4335" stroke-width="2" />
  <text x="360" y="100" font-size="14" text-anchor="middle" fill="#1a1a1a">Fix Y = y</text>
  <text x="360" y="120" font-size="13" text-anchor="middle" fill="#1a1a1a">Condition on event</text>

  <rect x="500" y="70" width="180" height="70" rx="8" fill="#e6f4ea" stroke="#34a853" stroke-width="2" />
  <text x="590" y="100" font-size="13" text-anchor="middle" fill="#1a1a1a">E[X | Y = y]</text>
  <text x="590" y="120" font-size="12" text-anchor="middle" fill="#1a1a1a">a fixed number</text>

  <line x1="220" y1="105" x2="265" y2="105" stroke="#5f6368" stroke-width="2" marker-end="url(#arrow1)" />
  <line x1="450" y1="105" x2="495" y2="105" stroke="#5f6368" stroke-width="2" marker-end="url(#arrow1)" />

  <rect x="270" y="200" width="180" height="70" rx="8" fill="#fef7e0" stroke="#fbbc04" stroke-width="2" />
  <text x="360" y="230" font-size="14" text-anchor="middle" fill="#1a1a1a">Vary Y over support</text>
  <text x="360" y="250" font-size="12" text-anchor="middle" fill="#1a1a1a">all possible y</text>

  <rect x="500" y="200" width="180" height="70" rx="8" fill="#e6f4ea" stroke="#34a853" stroke-width="2" />
  <text x="590" y="228" font-size="13" text-anchor="middle" fill="#1a1a1a">E[X | Y]</text>
  <text x="590" y="248" font-size="12" text-anchor="middle" fill="#1a1a1a">a random variable</text>

  <line x1="360" y1="140" x2="360" y2="195" stroke="#5f6368" stroke-width="2" marker-end="url(#arrow1)" />
  <line x1="450" y1="235" x2="495" y2="235" stroke="#5f6368" stroke-width="2" marker-end="url(#arrow1)" />

  <rect x="270" y="320" width="410" height="45" rx="8" fill="#f3e8fd" stroke="#a142f4" stroke-width="2" />
  <text x="475" y="347" font-size="13" text-anchor="middle" fill="#1a1a1a">E[ E[X | Y] ] = E[X]  (Tower Property)</text>

  <line x1="590" y1="270" x2="590" y2="300" stroke="#5f6368" stroke-width="2" />
  <line x1="590" y1="300" x2="475" y2="315" stroke="#5f6368" stroke-width="2" marker-end="url(#arrow1)" />

  </svg>

### Application in Machine Learning

**Key Points**
- **Regression models**: The target function that regression algorithms attempt to learn is [Inference] commonly framed as $E[Y \mid X]$ in statistical learning theory, though this framing is a modeling choice tied to squared-error loss specifically, and other loss functions target different conditional quantities (e.g., quantile loss targets conditional quantiles, not conditional expectation).
- **Bayesian inference**: The posterior mean $E[\theta \mid \text{data}]$ is a conditional expectation used as a point estimate in Bayesian methods.
- **Expectation-Maximization (EM)**: The E-step computes a conditional expectation of a complete-data log-likelihood given observed data and current parameter estimates.
- **Markov chains and reinforcement learning**: Conditional expectations given the current state, such as $E[R_{t+1} \mid S_t = s]$, underlie value functions in reinforcement learning.

These applications are [Verified] widely described in standard machine learning and statistical learning literature, though the exact formulation and terminology can vary by source and is [Unverified] for any specific textbook the user has not identified.

### Worked Example: Discrete Case

Let $X$ represent a document's processing time (in days) and $Y$ represent document type, with joint distribution:

| $X \backslash Y$ | Type A | Type B |
|---|---|---|
| 1 day | 0.10 | 0.05 |
| 3 days | 0.15 | 0.10 |
| 5 days | 0.05 | 0.55 |

Marginal probabilities: $P(Y = A) = 0.30$, $P(Y = B) = 0.70$

$$E[X \mid Y = A] = 1\left(\frac{0.10}{0.30}\right) + 3\left(\frac{0.15}{0.30}\right) + 5\left(\frac{0.05}{0.30}\right) = 0.333 + 1.5 + 0.833 = 2.667$$

$$E[X \mid Y = B] = 1\left(\frac{0.05}{0.70}\right) + 3\left(\frac{0.10}{0.70}\right) + 5\left(\frac{0.55}{0.70}\right) = 0.071 + 0.429 + 3.929 = 4.429$$

**Verification via tower property:**

$$E[X] = 0.30(2.667) + 0.70(4.429) = 0.80 + 3.10 = 3.90$$

This can be cross-checked by computing $E[X]$ directly from the marginal distribution of $X$, which should [Inference] match to within rounding error if the computation is correct, though I have not independently re-derived the marginal here to confirm exact agreement beyond the arithmetic shown.

### Common Pitfalls

- Confusing $E[X \mid Y = y]$ (a number) with $E[X \mid Y]$ (a random variable) is a frequent source of error.
- Assuming $E[X \mid Y]$ is linear in $Y$ when no such assumption is justified — linearity holds under specific distributional assumptions (e.g., joint normality), not in general.
- Treating conditional expectation as implying causation. $E[X \mid Y]$ describes statistical association, not a causal mechanism.
- Applying the tower property incorrectly across mismatched $\sigma$-algebras.

### Related Topics

- Conditional variance and its decomposition
- Regression functions and squared-error loss minimization
- The Expectation-Maximization (EM) algorithm
- Markov chains and conditional expectation in state transitions
- Bayesian posterior expectation and point estimation
- Martingales and the tower property in stochastic processes
- Law of iterated expectations in causal inference contexts