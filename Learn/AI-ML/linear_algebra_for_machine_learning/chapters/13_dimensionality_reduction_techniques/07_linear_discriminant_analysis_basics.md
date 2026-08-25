## Linear Discriminant Analysis Basics

### Overview

Linear Discriminant Analysis (LDA) is a supervised dimensionality reduction and classification technique that finds linear combinations of features maximizing separation between known classes. Unlike PCA, which finds directions of maximum variance without regard to class labels, LDA explicitly uses label information to find directions that best discriminate between groups.

### Prerequisite Concepts

- $Eigendecomposition$ and generalized eigenvalue problems
- $Covariance matrix$ (within-class and between-class variants)
- $Matrix inversion$
- Basic supervised learning terminology (classes, labels)
- PCA (useful for contrast, though not strictly required)

### PCA vs. LDA: Core Distinction

| Aspect | PCA | LDA |
|---|---|---|
| Supervision | Unsupervised (no labels used) | Supervised (requires class labels) |
| Objective | Maximize total variance | Maximize class separability |
| Output dimensionality limit | Up to $d$ (original feature count) | Up to $C - 1$ (number of classes minus one) |
| Typical use case | Compression, visualization, noise reduction | Classification, class-aware dimensionality reduction |

**Key Points**
- PCA directions may or may not align with directions useful for distinguishing classes
- [Inference] LDA is generally more effective than PCA as a preprocessing step specifically when the goal is classification and class-discriminative directions differ from directions of maximum overall variance; when they coincide, the two methods may yield similar results

### The Objective of LDA

LDA seeks a projection that maximizes the ratio of between-class variance to within-class variance. Intuitively, this means finding directions along which classes are far apart (high between-class spread) while each individual class remains tightly clustered (low within-class spread).

### Diagram: LDA Objective — Class Separation

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 700 350">
  <text x="350" y="25" font-size="16" font-weight="bold" text-anchor="middle" fill="#1a1a1a">LDA: Maximizing Class Separation (svg_diagram)</text>

  <text x="180" y="55" font-size="13" text-anchor="middle" fill="#1a1a1a" font-weight="bold">Poor projection axis</text>
  <line x1="60" y1="150" x2="300" y2="150" stroke="#5f6368" stroke-width="1.5" />
  <ellipse cx="140" cy="120" rx="55" ry="25" fill="#e8f0fe" stroke="#4285f4" stroke-width="2" transform="rotate(20, 140, 120)" />
  <ellipse cx="200" cy="170" rx="55" ry="25" fill="#fce8e6" stroke="#ea4335" stroke-width="2" transform="rotate(20, 200, 170)" />
  <text x="180" y="220" font-size="11" text-anchor="middle" fill="#5f6368">Classes overlap when projected</text>
  <text x="180" y="235" font-size="11" text-anchor="middle" fill="#5f6368">onto this axis</text>

  <text x="530" y="55" font-size="13" text-anchor="middle" fill="#1a1a1a" font-weight="bold">Good LDA projection axis</text>
  <line x1="400" y1="230" x2="660" y2="90" stroke="#34a853" stroke-width="2.5" />
  <ellipse cx="460" cy="120" rx="55" ry="25" fill="#e8f0fe" stroke="#4285f4" stroke-width="2" transform="rotate(20, 460, 120)" />
  <ellipse cx="560" cy="190" rx="55" ry="25" fill="#fce8e6" stroke="#ea4335" stroke-width="2" transform="rotate(20, 560, 190)" />
  <text x="530" y="270" font-size="11" text-anchor="middle" fill="#5f6368">Classes well-separated when</text>
  <text x="530" y="285" font-size="11" text-anchor="middle" fill="#5f6368">projected onto this axis</text>

  <circle cx="130" cy="115" r="3" fill="#4285f4" />
  <circle cx="150" cy="125" r="3" fill="#4285f4" />
  <circle cx="460" cy="115" r="3" fill="#4285f4" />
  <circle cx="470" cy="130" r="3" fill="#4285f4" />
</svg>

### Mathematical Formulation

**Within-class scatter matrix:**

$$S_W = \sum_{c=1}^{C} \sum_{i \in c} (x_i - \mu_c)(x_i - \mu_c)^T$$

where $\mu_c$ is the mean vector of class $c$, and the inner sum runs over all samples belonging to class $c$. $S_W$ measures the total spread of points around their respective class means.

**Between-class scatter matrix:**

$$S_B = \sum_{c=1}^{C} n_c (\mu_c - \mu)(\mu_c - \mu)^T$$

where $n_c$ is the number of samples in class $c$, and $\mu$ is the overall mean across all classes. $S_B$ measures how far each class mean is from the global mean, weighted by class size.

**Key Points**
- $S_W$ is analogous to an average "spread within groups" measure
- $S_B$ is analogous to a "spread between group centers" measure
- Both matrices are $d \times d$, matching the dimensionality of the feature space

### The LDA Optimization Problem

LDA seeks a projection vector (or matrix) $W$ that maximizes:

$$J(W) = \frac{W^T S_B W}{W^T S_W W}$$

This is known as the **generalized Rayleigh quotient**. Maximizing this ratio is equivalent to solving the generalized eigenvalue problem:

$$S_B v = \lambda S_W v$$

or, when $S_W$ is invertible:

$$S_W^{-1} S_B v = \lambda v$$

**Key Points**
- The eigenvectors $v$ corresponding to the largest eigenvalues $\lambda$ define the optimal discriminant directions
- Because $S_B$ is formed as a sum of $C$ rank-one-like terms constrained by the overall mean, its rank is at most $C - 1$, which limits the number of useful (non-zero eigenvalue) discriminant directions to $C - 1$
- This is why LDA can produce at most $C - 1$ meaningful projection dimensions, regardless of the original feature dimensionality $d$

### Step-by-Step Procedure

1. Compute the overall mean $\mu$ and per-class means $\mu_c$
2. Compute the within-class scatter matrix $S_W$
3. Compute the between-class scatter matrix $S_B$
4. Solve the generalized eigenvalue problem $S_W^{-1} S_B v = \lambda v$
5. Rank eigenvectors by descending eigenvalue
6. Select the top $k \leq C-1$ eigenvectors to form the projection matrix $V_k$
7. Project data: $Z = X V_k$

### Worked Example

Consider a two-class problem ($C = 2$) with 1D projection for illustration.

**Class A** samples: $\{1, 2, 3\}$, mean $\mu_A = 2$
**Class B** samples: $\{6, 7, 8\}$, mean $\mu_B = 7$
**Overall mean:** $\mu = 4.5$

**Within-class scatter** (treating as scalar variance sum for simplicity):

$$S_W = \sum_{x \in A}(x - \mu_A)^2 + \sum_{x \in B}(x - \mu_B)^2 = [(1-2)^2+(2-2)^2+(3-2)^2] + [(6-7)^2+(7-7)^2+(8-7)^2] = 2 + 2 = 4$$

**Between-class scatter:**

$$S_B = n_A(\mu_A - \mu)^2 + n_B(\mu_B - \mu)^2 = 3(2-4.5)^2 + 3(7-4.5)^2 = 3(6.25) + 3(6.25) = 37.5$$

**Discriminant ratio:**

$$J = \frac{S_B}{S_W} = \frac{37.5}{4} = 9.375$$

**Interpretation:** A high ratio indicates strong separation between classes relative to their internal spread — in this simplified 1D case, the classes are already well-separated along the single available axis, so LDA confirms this axis is a good (in fact, the only available) discriminant direction.

### Assumptions Underlying Classical LDA

- **Gaussian class-conditional distributions**: each class is assumed to be approximately normally distributed [Unverified — LDA can still perform reasonably in practice under moderate violations of this assumption, though theoretical guarantees weaken]
- **Equal covariance across classes**: classical LDA assumes all classes share the same covariance structure ($S_W$ is computed as a pooled estimate); when this assumption is violated, Quadratic Discriminant Analysis (QDA) may be more appropriate
- **Linear separability of class means**: LDA finds linear projections, so it is inherently limited in cases where class boundaries are strongly nonlinear

### LDA as a Classifier vs. LDA as Dimensionality Reduction

**Key Points**
- LDA is often introduced as a classifier: after projecting onto discriminant axes, new points are classified based on distance to projected class means (or via a Bayes-optimal decision rule under Gaussian assumptions)
- LDA is equally usable purely as a dimensionality reduction preprocessing step, feeding the reduced representation into a separate downstream classifier (e.g., logistic regression, SVM)
- [Inference] When used purely for dimensionality reduction, the class-separation objective can make LDA-reduced features particularly effective inputs for simple downstream classifiers, since much of the discriminative work has already been done during projection

### Common Pitfalls

- Applying LDA when $S_W$ is singular or near-singular (common when the number of features exceeds the number of samples), which makes $S_W^{-1}$ unstable or undefined — regularized variants (e.g., shrinkage LDA) address this
- Expecting more than $C-1$ useful discriminant dimensions, which is not possible under the classical formulation regardless of original feature dimensionality
- Applying LDA to strongly non-Gaussian or highly nonlinear class distributions and expecting performance comparable to nonlinear methods
- Confusing LDA's between/within scatter matrices with PCA's covariance matrix — they encode fundamentally different information (class structure vs. overall variance)
- Failing to standardize or preprocess features when scales differ dramatically, which can distort scatter matrix computations similarly to PCA

### Conclusion

LDA provides a supervised alternative to PCA for dimensionality reduction, explicitly leveraging class labels to find directions that maximize between-class separation relative to within-class spread. Its dimensionality is fundamentally capped at $C-1$, and its classical formulation relies on Gaussian, equal-covariance assumptions that should be considered when selecting it over alternatives like PCA, QDA, or nonlinear discriminant methods.

**Related Topics**
- Quadratic Discriminant Analysis (QDA) and relaxing the equal-covariance assumption
- Regularized and shrinkage LDA for high-dimensional, small-sample settings
- Fisher's Linear Discriminant as the two-class special case of LDA
- Combining PCA and LDA in sequential pipelines (PCA for noise reduction, then LDA for discrimination)
- Kernel Discriminant Analysis for nonlinear class boundaries
- Relationship between LDA and Bayes-optimal classification under Gaussian assumptions