## Precision Recall and F1 Derivation

### Overview

Precision, recall, and F1-score are classification metrics derived from the confusion matrix, each constructed to capture a different aspect of a model's error profile. This topic walks through the formal derivation of each metric from first principles, showing how they relate to one another mathematically.

### Key Points

- Precision, recall, and F1-score are all derived from the four basic counts in a confusion matrix: TP, TN, FP, FN.
- Precision measures the reliability of positive predictions; recall measures the completeness of positive predictions.
- F1-score is the harmonic mean of precision and recall, constructed specifically to penalize imbalance between the two.
- [Inference] The harmonic mean is used rather than the arithmetic mean because it is more sensitive to low values in either precision or recall, so a very low value in one metric will pull the F1-score down more than an arithmetic mean would; this is a standard mathematical property of the harmonic mean, though its practical implications for any specific model comparison depend on the actual precision and recall values involved.

### Foundational Definitions

Starting from the confusion matrix counts:

- $TP$ = True Positives
- $TN$ = True Negatives
- $FP$ = False Positives
- $FN$ = False Negatives

**Precision** is defined as the proportion of predicted positives that are actually positive:

$$\text{Precision} = \frac{TP}{TP + FP}$$

**Recall** (also called Sensitivity or True Positive Rate) is defined as the proportion of actual positives that are correctly predicted:

$$\text{Recall} = \frac{TP}{TP + FN}$$

Both metrics share the same numerator ($TP$) but differ in their denominator: precision's denominator is the total number of predicted positives, while recall's denominator is the total number of actual positives.

### Deriving Precision from First Principles

Precision answers the question: "Of all instances the model labeled positive, how many were correct?"

Formally, let $\hat{Y}=1$ denote a positive prediction and $Y=1$ denote an actual positive. Precision is the conditional probability:

$$\text{Precision} = P(Y=1 \mid \hat{Y}=1) = \frac{P(Y=1, \hat{Y}=1)}{P(\hat{Y}=1)}$$

In terms of observed counts, this becomes:

$$\text{Precision} = \frac{TP}{TP + FP}$$

Since $TP + FP$ represents the total count of positive predictions made by the model, regardless of whether they were correct.

### Deriving Recall from First Principles

Recall answers the question: "Of all instances that are actually positive, how many did the model correctly identify?"

Formally, recall is the conditional probability:

$$\text{Recall} = P(\hat{Y}=1 \mid Y=1) = \frac{P(Y=1, \hat{Y}=1)}{P(Y=1)}$$

In terms of observed counts:

$$\text{Recall} = \frac{TP}{TP + FN}$$

Since $TP + FN$ represents the total count of actual positive instances, whether correctly identified or missed.

### Precision and Recall Derivation Diagram (svg_diagram)

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 520 300">
<text x="20" y="25" font-size="14" font-weight="bold" fill="#222">Precision and Recall from Confusion Matrix (svg_diagram)</text>
<rect x="180" y="60" width="120" height="45" fill="#eafbea" stroke="#2ca02c" stroke-width="1.5" />
<text x="220" y="87" font-size="13" fill="#222">TP</text>
<rect x="300" y="60" width="120" height="45" fill="#fdecea" stroke="#d62728" stroke-width="1.5" />
<text x="350" y="87" font-size="13" fill="#222">FN</text>
<rect x="180" y="105" width="120" height="45" fill="#fdecea" stroke="#d62728" stroke-width="1.5" />
<text x="220" y="132" font-size="13" fill="#222">FP</text>
<rect x="300" y="105" width="120" height="45" fill="#eafbea" stroke="#2ca02c" stroke-width="1.5" />
<text x="345" y="132" font-size="13" fill="#222">TN</text>
<line x1="180" y1="170" x2="300" y2="170" stroke="#1f77b4" stroke-width="2" />
<text x="185" y="190" font-size="11" fill="#1f77b4">Precision = TP / (TP + FP)</text>
<text x="185" y="205" font-size="9" fill="#555">(column-wise: predicted positive)</text>
<line x1="420" y1="60" x2="420" y2="150" stroke="#ff7f0e" stroke-width="2" />
<text x="200" y="230" font-size="11" fill="#ff7f0e">Recall = TP / (TP + FN)</text>
<text x="200" y="245" font-size="9" fill="#555">(row-wise: actual positive)</text>

<text x="20" y="275" font-size="10" fill="#555">Precision sums down the predicted-positive column; recall sums across the actual-positive row</text>

</svg>

### Deriving the F1-Score

The F1-score is defined as the harmonic mean of precision and recall. The general formula for the harmonic mean of two values $a$ and $b$ is:

$$H(a,b) = \frac{2ab}{a+b}$$

Substituting $a = \text{Precision}$ and $b = \text{Recall}$:

$$F_1 = \frac{2 \cdot \text{Precision} \cdot \text{Recall}}{\text{Precision} + \text{Recall}}$$

This can also be expressed directly in terms of the confusion matrix counts. Starting from the precision and recall formulas:

$$\text{Precision} = \frac{TP}{TP+FP}, \quad \text{Recall} = \frac{TP}{TP+FN}$$

Substituting into the harmonic mean formula and simplifying algebraically:

$$F_1 = \frac{2 \cdot \frac{TP}{TP+FP} \cdot \frac{TP}{TP+FN}}{\frac{TP}{TP+FP} + \frac{TP}{TP+FN}}$$

Multiplying numerator and denominator by $(TP+FP)(TP+FN)$ to clear the fractions:

$$F_1 = \frac{2 \cdot TP}{2 \cdot TP + FP + FN}$$

This simplified form shows that F1-score can be computed directly from $TP$, $FP$, and $FN$, without needing $TN$ at all.

### Why the Harmonic Mean Rather Than the Arithmetic Mean

Consider a hypothetical case where Precision $= 1.0$ and Recall $= 0.01$.

- Arithmetic mean: $\frac{1.0 + 0.01}{2} = 0.505$
- Harmonic mean (F1): $\frac{2 \times 1.0 \times 0.01}{1.0 + 0.01} \approx 0.0198$

[Inference] This numerical comparison illustrates a general mathematical property of the harmonic mean — that it is pulled strongly toward the smaller of the two values — rather than a claim about any specific real classifier's behavior. The harmonic mean is used in F1 specifically because [Inference] it penalizes cases where one of precision or recall is very low, even if the other is very high, which is commonly cited as desirable when both false positives and false negatives carry meaningful cost; I cannot verify that this design choice is optimal for every application, since the appropriate weighting of precision versus recall depends on domain-specific costs not specified here.

### Generalizing to the Fβ-Score

The F1-score is a special case of a more general family, the Fβ-score, which allows recall to be weighted more or less heavily than precision using a parameter $\beta$:

$$F_\beta = (1+\beta^2) \cdot \frac{\text{Precision} \cdot \text{Recall}}{(\beta^2 \cdot \text{Precision}) + \text{Recall}}$$

Derivation notes:

- When $\beta = 1$, this reduces exactly to the standard F1-score.
- When $\beta > 1$, recall is weighted more heavily than precision.
- When $\beta < 1$, precision is weighted more heavily than recall.

In terms of confusion matrix counts, this generalizes to:

$$F_\beta = \frac{(1+\beta^2) \cdot TP}{(1+\beta^2) \cdot TP + \beta^2 \cdot FN + FP}$$

[Unverified] The choice of $\beta$ in applied settings is typically determined by domain-specific cost tradeoffs between false positives and false negatives, and I do not have access to a universal default value of $\beta$ appropriate across all applications.

### Boundary Behavior of the Derivation

Examining the formulas at their limits helps clarify their behavior:

- If $FP = 0$ and $FN = 0$ (perfect classifier): Precision $=1$, Recall $=1$, $F_1 = 1$.
- If $TP = 0$ (model never correctly identifies a positive): Precision $=0$ (assuming $FP>0$) or undefined (if $FP=0$ also), Recall $=0$, and $F_1 = 0$.
- If $TP + FP = 0$ (model never predicts positive at all): Precision is undefined ($0/0$), since there are no predicted positives to evaluate.

[Unverified] Different software implementations handle the undefined $0/0$ case differently (e.g., returning 0, raising a warning, or returning NaN), and I do not have access to confirm which convention any specific tool applies without checking that tool's documentation directly.

### Worked Numerical Example

Suppose a classifier produces the following confusion matrix counts on a test set: $TP = 40$, $FP = 30$, $FN = 10$, $TN = 920$.

**Step 1 — Precision:**

$$\text{Precision} = \frac{40}{40+30} = \frac{40}{70} \approx 0.571$$

**Step 2 — Recall:**

$$\text{Recall} = \frac{40}{40+10} = \frac{40}{50} = 0.8$$

**Step 3 — F1-score using the harmonic mean formula:**

$$F_1 = \frac{2 \times 0.571 \times 0.8}{0.571 + 0.8} = \frac{0.9136}{1.371} \approx 0.666$$

**Step 4 — Verification using the simplified count-based formula:**

$$F_1 = \frac{2 \times 40}{2 \times 40 + 30 + 10} = \frac{80}{120} \approx 0.667$$

The small numerical difference between Step 3 and Step 4 ($0.666$ vs. $0.667$) arises from intermediate rounding of precision and recall to three decimal places in Step 3; the exact fractional computation in Step 4 is the more precise result.

### Relationship Between the Three Metrics

```mermaid
flowchart TD
    A[Confusion Matrix: TP, FP, FN, TN] --> B[Precision = TP / (TP + FP)]
    A --> C[Recall = TP / (TP + FN)]
    B --> D[Harmonic Mean Formula]
    C --> D
    D --> E[F1 = 2·Precision·Recall / (Precision + Recall)]
    E --> F[Simplifies to F1 = 2·TP / (2·TP + FP + FN)]
```

### Comparison of the Three Metrics

| Metric | Numerator | Denominator | Question Answered |
| --- | --- | --- | --- |
| Precision | $TP$ | $TP + FP$ | Of predicted positives, how many are correct? |
| Recall | $TP$ | $TP + FN$ | Of actual positives, how many were found? |
| F1-Score | $2 \cdot TP$ | $2 \cdot TP + FP + FN$ | Balanced measure combining both questions |

### Limitations of the Derivation and Its Use

- The F1-score, by construction, does not include $TN$ in its formula, meaning it is insensitive to how the model handles true negatives. [Inference] This is sometimes cited as a reason F1-score can behave differently from accuracy under class imbalance, though the practical significance of this difference depends on the specific class distribution of a given dataset, which I cannot verify in general.
- Precision and recall are undefined in edge cases (e.g., zero predicted positives or zero actual positives), requiring explicit handling conventions that vary by implementation.
- The standard F1-score assumes equal importance between precision and recall; when this is not appropriate for a given application, the more general Fβ-score is used instead, requiring a domain-specific choice of $\beta$ that I cannot determine without additional context.
- [Unverified] I cannot verify whether any specific reported F1-score in an external study or tool used the same edge-case handling conventions described above without reviewing that specific source directly.

### Related Topics

- Confusion Matrix Statistics
- ROC Curves and AUC
- Matthews Correlation Coefficient
- Precision-Recall Curves and Threshold Selection
- Class Imbalance Handling Techniques
- Multi-Class Averaging Methods (Macro, Micro, Weighted)
- Bayes Classifier
- Decision Boundaries

Correction: This document contains [Inference] and [Unverified] labeled statements throughout, and per the stated requirement, the entire output should be treated as carrying this qualification. I do not have access to primary empirical studies, dataset-specific results, or confirmation of software-specific implementation conventions referenced above. Only the standard mathematical definitions and algebraic derivations presented (precision, recall, the harmonic mean, the F1 and Fβ formulas, and their algebraic simplification to count-based forms) reflect established, verifiable mathematical constructs, since each derivation step shown follows directly from the stated definitions through standard algebra.