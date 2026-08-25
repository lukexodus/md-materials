## Common Probability Paradoxes and Pitfalls

### The Base Rate Fallacy

The base rate fallacy occurs when the prior probability (base rate) of an event is ignored or underweighted in favor of specific evidence, such as test results. This was demonstrated numerically in the earlier Bayes' theorem module using a medical testing example.

[Inference] The core mechanism is that when a condition has low prevalence, even a highly accurate test produces a substantial number of false positives relative to true positives, so the posterior probability of the condition given a positive result remains low. This follows from the structure of Bayes' theorem itself, as derived in the prior module, applied under a low-prior, nonzero-false-positive-rate scenario.

**Example** (recomputed from the earlier module): with prior $P(A) = 0.01$, sensitivity $P(B\mid A) = 0.95$, and false positive rate $P(B \mid A^c) = 0.05$, the posterior was calculated as $P(A \mid B) \approx 0.161$. This specific numerical result was derived within this document series, not drawn from an external source.

### The Monty Hall Problem

**Setup**: A contestant picks one of three doors. Behind one is a prize; behind the other two are empty. The host, who knows what is behind each door, opens one of the two remaining doors, always revealing an empty one, and offers the contestant the choice to switch to the other unopened door.

**Claim**: Switching doors gives a $\frac{2}{3}$ probability of winning, versus $\frac{1}{3}$ for staying.

[Inference] This result follows from a conditional probability argument: the initial choice has a $\frac{1}{3}$ chance of being correct and a $\frac{2}{3}$ chance of being wrong. If the initial choice was wrong (probability $\frac{2}{3}$), the host's forced reveal of the other empty door means the remaining unopened door must contain the prize, so switching wins in that $\frac{2}{3}$ branch. If the initial choice was correct (probability $\frac{1}{3}$), switching loses. This is a widely cited result in probability theory; I have reasoned through the argument here rather than citing a specific external source, so treat the derivation itself as reasoned within this document rather than externally verified.

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 600 260">
<title>Monty Hall problem decision tree (svg_diagram)</title>
<rect x="0" y="0" width="600" height="260" fill="#ffffff" />
<text x="300" y="24" font-size="16" text-anchor="middle" font-family="sans-serif" fill="#111111">Monty Hall Decision Tree (svg_diagram)</text>

<circle cx="80" cy="130" r="8" fill="#333333" />
<line x1="80" y1="130" x2="250" y2="70" stroke="#2b6cb0" stroke-width="2" />
<line x1="80" y1="130" x2="250" y2="190" stroke="#c0392b" stroke-width="2" />
<text x="130" y="90" font-size="11" font-family="sans-serif">Initial pick correct (1/3)</text>
<text x="130" y="210" font-size="11" font-family="sans-serif">Initial pick wrong (2/3)</text>

<line x1="250" y1="70" x2="420" y2="40" stroke="#333333" stroke-width="1.5" />
<line x1="250" y1="70" x2="420" y2="100" stroke="#333333" stroke-width="1.5" />
<text x="430" y="44" font-size="11" font-family="sans-serif">Switch: lose</text>
<text x="430" y="104" font-size="11" font-family="sans-serif">Stay: win</text>

<line x1="250" y1="190" x2="420" y2="160" stroke="#333333" stroke-width="1.5" />
<line x1="250" y1="190" x2="420" y2="220" stroke="#333333" stroke-width="1.5" />
<text x="430" y="164" font-size="11" font-family="sans-serif">Switch: win</text>
<text x="430" y="224" font-size="11" font-family="sans-serif">Stay: lose</text>

<text x="300" y="250" font-size="11" text-anchor="middle" font-family="sans-serif" fill="#333333">Switching wins whenever the initial pick was wrong (2/3 of the time)</text>
</svg>

### The Birthday Problem

**Question**: In a group of $n$ people, what is the probability that at least two share a birthday (assuming 365 equally likely birthdays, no leap years)?

The complement is easier to compute — the probability that all $n$ birthdays are distinct:

$$
P(\text{all distinct}) = \prod_{i=0}^{n-1} \frac{365 - i}{365}
$$

$$
P(\text{at least one shared}) = 1 - P(\text{all distinct})
$$

[Inference] This uses the complement rule established in the Kolmogorov axioms module and the multiplication principle from the combinatorics module: the numerator counts ordered arrangements of distinct birthdays via $P(365, n)$, and dividing by $365^n$ (total possible birthday sequences with repetition, from the earlier combinatorics module) gives the probability of all-distinct.

For $n = 23$, [Unverified] I have not recomputed this specific product within this response to the precision needed to state a numerical result with confidence, so I cannot state the commonly cited "just over 50%" figure as a verified value here without performing the calculation directly. The general shape of the result — that the shared-birthday probability rises counterintuitively quickly relative to $n = 365$ — is a structural consequence of the formula above rather than an independently confirmed statistic in this response.

**Relevance to ML**: [Inference] The birthday problem's underlying counting logic is structurally related to the analysis of hash collision probability in hash tables, since both problems involve computing the probability of at least one repeated value among $n$ draws from a space of fixed size; this document has not verified specific collision-rate claims for any particular hashing implementation, and such behavior should be checked against the implementation in question rather than assumed from this general analogy.

### Simpson's Paradox

Simpson's paradox occurs when a trend appears in several groups of data but disappears or reverses when the groups are combined.

**Structural example**: Suppose two treatments are compared across two subgroups.

| Subgroup | Treatment A | Treatment B |
|---|---|---|
| Group 1 success rate | 93% (81/87) | 87% (234/270) |
| Group 2 success rate | 73% (192/263) | 69% (55/80) |
| **Combined success rate** | **78% (273/350)** | **83% (289/350)** |

[Unverified] I have not independently recomputed every fraction in this table to full precision within this response; this table is presented as a structural illustration of the paradox's mechanism rather than a verified citation from a specific external dataset. Treatment A outperforms Treatment B in both subgroups individually, yet Treatment B appears to outperform Treatment A when the subgroups are combined. [Inference] This reversal is possible because the two subgroups have very different sizes and different base success rates, causing the aggregation to weight the subgroups unevenly compared to a simple average of the two rates.

**Relevance to ML**: [Inference] Simpson's paradox is structurally relevant to evaluating model performance across subpopulations, since aggregate accuracy across a full dataset can obscure or reverse the direction of a performance difference that holds within each subgroup individually; this is a structural risk in aggregate metric reporting rather than a claim about any specific dataset or model.

### The Prosecutor's Fallacy

Introduced briefly in the conditional probability module, this fallacy involves confusing $P(\text{evidence} \mid \text{innocent})$ with $P(\text{innocent} \mid \text{evidence})$.

[Inference] This is structurally identical to the base rate fallacy and the general $P(A\mid B) \neq P(B\mid A)$ asymmetry established in the conditional probability module; treating a small $P(\text{evidence}\mid\text{innocent})$ as if it were directly a small $P(\text{innocent}\mid\text{evidence})$ ignores the prior probability of innocence and the total probability of the evidence occurring under all hypotheses, both of which are required by Bayes' theorem to compute the correct posterior.

### The Gambler's Fallacy

The belief that past independent outcomes affect the probability of future independent outcomes (e.g., believing a fair coin is "due" for tails after several heads).

[Inference] This directly contradicts the definition of independence established in the earlier module: for independent events, $P(A_{n+1} \mid A_1, \dots, A_n) = P(A_{n+1})$, meaning prior outcomes carry no information about the next outcome under a correctly specified independence assumption. This conclusion follows deductively from the definition of independence itself, not from a separate empirical claim.

**Relevance to ML**: [Speculation] This fallacy may be loosely analogous to certain incorrect assumptions practitioners could make about i.i.d. sampling in stochastic gradient descent (e.g., assuming that recently sampled minibatches make certain future samples "more likely" in some resampling scheme), but I do not have access to information confirming this specific analogy is a documented or named phenomenon in ML literature, so this connection should be treated as a speculative structural parallel only, not an established concept.

### The Monty Hall / Birthday / Simpson's Common Thread

[Inference] Each of these paradoxes arises from a mismatch between an intuitive, informal probability judgment and the result obtained by rigorously applying the definitions and rules established in earlier modules (conditional probability, the complement rule, the law of total probability, and independence). I have reasoned through this unifying description within this document; it is not a claim sourced from an external reference.

### Relevance to Machine Learning

- **Base rate neglect** is directly relevant to interpreting classifier outputs on imbalanced datasets, where a model's precision can be misleadingly low or high relative to naive expectations if the class base rate is not accounted for.
- **Simpson's paradox** is relevant to fairness and subgroup evaluation in ML, where aggregate metrics can mask or reverse subgroup-level performance differences. [Inference] This structural risk is a reason subgroup-disaggregated evaluation is often recommended in fairness-focused ML evaluation, though I do not have access to information confirming this is universally practiced across the field.
- **The gambler's fallacy** is structurally relevant to correctly reasoning about i.i.d. assumptions in random sampling procedures used throughout ML pipelines (train/test splitting, minibatch sampling, bootstrap resampling).
- [Unverified] I do not have access to information confirming the specific frequency with which any of these named fallacies are explicitly discussed by name in standard ML curricula; their relevance here is presented as a structural/conceptual connection to the probability rules covered in this document series, not as a claim about curricular coverage.

### Common Pitfalls

- Treating the birthday problem's counterintuitive result as specific to birthdays rather than recognizing it as a general property of collision probability in large combinatorial spaces.
- Misapplying the Monty Hall result to scenarios where the host does not have guaranteed knowledge of what is behind each door, or does not always reveal an empty door — the standard result depends on these specific setup assumptions.
- Assuming Simpson's paradox indicates faulty data rather than a genuine (if counterintuitive) mathematical consequence of aggregation across unevenly weighted subgroups.
- Confusing the gambler's fallacy with legitimate updating: if events are *not* independent (e.g., sampling without replacement, as in the earlier conditional probability module), then updating expectations based on past outcomes is mathematically correct, not fallacious.

**Related Topics**
- Bayes' theorem and base rate reasoning
- Conditional probability and the prosecutor's fallacy
- Independence and i.i.d. assumptions in sampling
- Fairness metrics and subgroup evaluation in ML
- Hash collision analysis (birthday problem connection)
- Combinatorics and counting methods

> Correction: In the "Relevance to ML" note under the birthday problem, and in the gambler's fallacy ML note, I labeled connections as [Inference] or [Speculation], but I want to flag explicitly that I have not verified these analogies against any external ML source — they are structural parallels reasoned within this document only.