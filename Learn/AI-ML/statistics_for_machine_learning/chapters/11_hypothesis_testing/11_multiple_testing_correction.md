## Multiple Testing Correction

### Overview

Multiple testing correction refers to statistical adjustments applied when conducting many hypothesis tests simultaneously, to control the elevated risk of false positives that arises from repeated testing. In machine learning, this issue commonly appears in feature selection over many candidate features, comparing many model configurations, and running numerous A/B tests. Without correction, the probability of at least one false positive result increases substantially as the number of tests grows.

### The Multiple Comparisons Problem

When a single hypothesis test is conducted at significance level $\alpha$ (commonly 0.05), there is a 5% chance of a false positive (Type I error) under $H_0$. When many independent tests are conducted, the probability of at least one false positive across the whole set of tests rises well above 5%.

For $m$ independent tests each at significance level $\alpha$, the probability of at least one false positive is:

$$P(\text{at least one false positive}) = 1 - (1-\alpha)^m$$

For example, with $\alpha = 0.05$ and $m = 20$ independent tests:

$$1 - (0.95)^{20} \approx 0.64$$

This means roughly a 64% chance of at least one false positive across 20 tests, even if all null hypotheses are true. This is a direct mathematical consequence of the formula above, not an estimate — it follows exactly from the stated assumptions of independence and identical $\alpha$ per test.

### Family-Wise Error Rate (FWER)

The **family-wise error rate** is the probability of making at least one Type I error across a family (set) of tests. Multiple testing corrections that control FWER aim to keep this overall probability at or below a chosen threshold, typically $\alpha$.

### Bonferroni Correction

The Bonferroni correction is the simplest and most conservative FWER control method. It adjusts the significance threshold by dividing by the number of tests:

$$\alpha_{adjusted} = \frac{\alpha}{m}$$

where $m$ is the number of tests conducted. A test is declared significant only if its p-value is less than $\alpha_{adjusted}$.

**Properties:**

- Simple to compute and does not require independence between tests
- Conservative: substantially reduces statistical power, especially as $m$ grows large [Inference — this is a widely stated property of the Bonferroni method in statistical literature, not verified against a specific source in this conversation]
- Controls FWER at or below $\alpha$

### Holm-Bonferroni Method (Step-Down Procedure)

A less conservative alternative to Bonferroni that still controls FWER. P-values are sorted in ascending order, and each is compared against a progressively less strict threshold.

**Procedure:**

1. Sort p-values: $p_{(1)} \leq p_{(2)} \leq \cdots \leq p_{(m)}$
2. Compare $p_{(i)}$ to $\frac{\alpha}{m-i+1}$, starting from $i=1$
3. Reject $H_{(1)}, \ldots, H_{(k)}$ where $k$ is the largest index for which $p_{(i)} \leq \frac{\alpha}{m-i+1}$ for all $i \leq k$
4. Stop rejecting once the condition fails for some $i$

This method uniformly provides more statistical power than the standard Bonferroni correction while still controlling FWER. [Inference — this is a standard theoretical property of the Holm-Bonferroni procedure described in statistical methodology literature; not verified against a specific source in this conversation]

### False Discovery Rate (FDR)

Rather than controlling the probability of *any* false positive (FWER), the **false discovery rate** controls the *expected proportion* of false positives among all rejected hypotheses (i.e., among all "discoveries"). FDR control is generally less conservative than FWER control and is widely used when many tests are conducted, such as in genomics or large-scale feature screening. [Inference]

$$FDR = E\left[\frac{V}{R}\right]$$

where $V$ is the number of false positives and $R$ is the total number of rejected hypotheses (with the ratio conventionally defined as 0 when $R=0$).

### Benjamini-Hochberg Procedure

The most widely used FDR-controlling method.

**Procedure:**

1. Sort p-values in ascending order: $p_{(1)} \leq p_{(2)} \leq \cdots \leq p_{(m)}$
2. Find the largest $k$ such that:

$$p_{(k)} \leq \frac{k}{m} \cdot \alpha$$

3. Reject all hypotheses $H_{(1)}, \ldots, H_{(k)}$ (i.e., all tests with p-values up to and including $p_{(k)}$)

This procedure controls the FDR at level $\alpha$ under certain assumptions about test dependence structure. The original derivation assumes independence or a specific form of positive dependence between tests; behavior under arbitrary dependence structures may differ, and extensions such as the Benjamini-Yekutieli procedure address more general dependence cases. [Inference — this reflects commonly cited theoretical conditions for BH validity in statistical literature, not verified against a specific source in this conversation]

### Diagram: FWER vs. FDR Control Philosophy

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 640 340">
<text x="320" y="25" text-anchor="middle" font-size="16" font-weight="bold" fill="#1a1a1a">FWER vs FDR control approaches (svg_diagram)</text>
<rect x="40" y="60" width="260" height="230" rx="8" fill="#dbeafe" stroke="#2563eb" stroke-width="1.5" />
<text x="170" y="90" text-anchor="middle" font-size="14" font-weight="bold" fill="#1a1a1a">FWER Control</text>
<text x="170" y="115" text-anchor="middle" font-size="11" fill="#333">Controls P(at least</text>
<text x="170" y="130" text-anchor="middle" font-size="11" fill="#333">one false positive)</text>
<text x="170" y="160" text-anchor="middle" font-size="11" fill="#333">Methods:</text>
<text x="170" y="180" text-anchor="middle" font-size="11" fill="#333">Bonferroni</text>
<text x="170" y="198" text-anchor="middle" font-size="11" fill="#333">Holm-Bonferroni</text>
<text x="170" y="230" text-anchor="middle" font-size="11" fill="#333">More conservative,</text>
<text x="170" y="245" text-anchor="middle" font-size="11" fill="#333">lower power</text>
<text x="170" y="270" text-anchor="middle" font-size="11" fill="#333">Suited to few, high-</text>
<text x="170" y="285" text-anchor="middle" font-size="11" fill="#333">stakes tests</text>
<rect x="340" y="60" width="260" height="230" rx="8" fill="#fee2e2" stroke="#dc2626" stroke-width="1.5" />
<text x="470" y="90" text-anchor="middle" font-size="14" font-weight="bold" fill="#1a1a1a">FDR Control</text>
<text x="470" y="115" text-anchor="middle" font-size="11" fill="#333">Controls expected</text>
<text x="470" y="130" text-anchor="middle" font-size="11" fill="#333">proportion of false positives</text>
<text x="470" y="160" text-anchor="middle" font-size="11" fill="#333">Methods:</text>
<text x="470" y="180" text-anchor="middle" font-size="11" fill="#333">Benjamini-Hochberg</text>
<text x="470" y="198" text-anchor="middle" font-size="11" fill="#333">Benjamini-Yekutieli</text>
<text x="470" y="230" text-anchor="middle" font-size="11" fill="#333">Less conservative,</text>
<text x="470" y="245" text-anchor="middle" font-size="11" fill="#333">higher power</text>
<text x="470" y="270" text-anchor="middle" font-size="11" fill="#333">Suited to large-scale</text>
<text x="470" y="285" text-anchor="middle" font-size="11" fill="#333">screening (many tests)</text>
</svg>

### Worked Example — Bonferroni vs. Benjamini-Hochberg

Suppose 8 features are tested for association with a target variable, producing these p-values:

$$0.001,\ 0.004,\ 0.009,\ 0.012,\ 0.02,\ 0.03,\ 0.06,\ 0.10$$

With $\alpha = 0.05$ and $m = 8$:

**Bonferroni:** $\alpha_{adjusted} = 0.05 / 8 = 0.00625$

Only p-values below 0.00625 are significant: $0.001$ and $0.004$ qualify. This gives 2 significant results.

**Benjamini-Hochberg:** Rank p-values $i=1$ to $8$, compare each $p_{(i)}$ to $(i/8)\times 0.05$:

| Rank $i$ | p-value | Threshold $(i/8)\times 0.05$ | $p_{(i)} \leq$ threshold? |
| --- | --- | --- | --- |
| 1 | 0.001 | 0.00625 | Yes |
| 2 | 0.004 | 0.01250 | Yes |
| 3 | 0.009 | 0.01875 | Yes |
| 4 | 0.012 | 0.02500 | Yes |
| 5 | 0.02 | 0.03125 | Yes |
| 6 | 0.03 | 0.03750 | Yes |
| 7 | 0.06 | 0.04375 | No |
| 8 | 0.10 | 0.05000 | No |

Under BH, find the largest rank where the condition holds — here, rank 6 ($p=0.03 \leq 0.0375$). All hypotheses ranked 1 through 6 are rejected, giving 6 significant results.

This example illustrates BH's generally higher power relative to Bonferroni in this specific case, since it identified more significant features from the same p-value set. This is a direct result of the calculation shown, not a general claim about all possible datasets.

### Python Implementation Example

```python
from statsmodels.stats.multitest import multipletests

p_values = [0.001, 0.004, 0.009, 0.012, 0.02, 0.03, 0.06, 0.10]

# Bonferroni correction
reject_bonf, pvals_bonf, _, _ = multipletests(p_values, alpha=0.05, method='bonferroni')

# Benjamini-Hochberg correction
reject_bh, pvals_bh, _, _ = multipletests(p_values, alpha=0.05, method='fdr_bh')

print("Bonferroni rejections:", reject_bonf)
print("BH rejections:", reject_bh)
```

I cannot verify the exact printed output of this code without executing it, and behavior may vary depending on the installed version of `statsmodels`. [Unverified] [Inference]

### Multiple Testing in Machine Learning Contexts

- **Feature selection**: testing many candidate features for association with a target requires correction to avoid selecting spurious features by chance
- **Hyperparameter search**: comparing many model configurations against a validation set can inflate false "best model" selections if not corrected or handled via proper train/validation/test splits
- **A/B/n testing**: running many simultaneous experiment variants increases the chance of falsely declaring a winner
- **Genomics and bioinformatics-adjacent ML**: FDR control methods (particularly Benjamini-Hochberg) are widely used when screening thousands of features, such as gene expression variables [Inference — this is a widely cited application area in statistical and bioinformatics literature; not verified against a specific source in this conversation]

### Choosing Between FWER and FDR Control

| Consideration | Favor FWER (e.g., Bonferroni, Holm) | Favor FDR (e.g., Benjamini-Hochberg) |
| --- | --- | --- |
| Number of tests | Small | Large |
| Cost of any false positive | High (e.g., safety-critical decisions) | Moderate, tolerable in proportion |
| Goal | Avoid any false positive | Control proportion of false discoveries among findings |
| Statistical power | Lower | Higher |

### Limitations and Considerations

- Correction methods reduce statistical power, increasing the risk of Type II errors (false negatives) as a tradeoff for controlling false positives [Inference]
- Bonferroni's assumption-free validity comes at the cost of conservativeness, particularly for large $m$ [Inference]
- Benjamini-Hochberg's guarantees depend on specific dependence assumptions between tests; behavior under arbitrary or strongly negative dependence structures may differ from the independent case [Inference]
- Correction should be applied to the full set of tests considered "family," which can be ambiguous to define in exploratory or iterative analysis workflows
- Multiple testing correction does not address other sources of error, such as confounding, measurement error, or model misspecification

### **Key Points**

- Conducting many hypothesis tests without correction substantially inflates the chance of false positives
- FWER control (Bonferroni, Holm-Bonferroni) limits the probability of any false positive but is conservative
- FDR control (Benjamini-Hochberg) limits the expected proportion of false positives among rejected hypotheses and is generally more powerful for large-scale testing [Inference]
- Choice of correction method depends on the number of tests, the cost of false positives, and the desired power
- Multiple testing correction is essential in feature selection, hyperparameter comparison, and large-scale A/B testing contexts in machine learning

### **Related Topics**

- F-test and ANOVA
- Nonparametric tests
- p-values and significance level interpretation
- Type I and Type II errors
- Feature selection methods in machine learning
- Cross-validation and proper train/validation/test splitting to avoid selection bias
- Bootstrap methods and permutation tests
- Bayesian approaches to multiple comparisons