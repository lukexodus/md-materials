## Probability Mass Functions

### Definition

A probability mass function (PMF) fully characterizes the distribution of a discrete random variable $X$ by assigning a probability to each value in its support. For a discrete random variable with possible values $x_1, x_2, x_3, \ldots$:

$$p_X(x) = P(X = x)$$

[Inference] The PMF concept was introduced briefly in the discrete random variables topic; this topic treats it as the primary object of study, examining its properties and construction in greater depth. This framing is a direct continuation of previously established definitions in this conversation, not an independently confirmed external claim.

### Defining Properties

A function $p_X$ qualifies as a valid PMF if and only if it satisfies both of the following, which follow from Kolmogorov's axioms applied to the events $\{X = x_i\}$:

**Non-negativity**

$$p_X(x) \geq 0 \quad \text{for all } x$$

**Normalization**

$$\sum_{\text{all } x} p_X(x) = 1$$

For any value $x$ not in the support of $X$ (i.e., a value $X$ cannot take), $p_X(x) = 0$.

### Support of a Random Variable

The **support** of $X$ is the set of values for which $p_X(x) > 0$:

$$\text{Supp}(X) = \{x : p_X(x) > 0\}$$

This can be finite (e.g., outcome of a die roll) or countably infinite (e.g., number of trials until first success in a Geometric distribution).

### Deriving Probabilities of Events from a PMF

For any event $A$ defined in terms of the value of $X$ (i.e., $A = \{X \in S\}$ for some set $S$):

$$P(X \in S) = \sum_{x \in S} p_X(x)$$

[Inference] This follows from finite or countable additivity (Axiom 3 of Kolmogorov's axioms) applied to the disjoint elementary events $\{X = x\}$ for each $x \in S$, since these events are pairwise disjoint by construction. This is a direct derivation from previously established axioms, not a separately confirmed empirical result.

### Visualizing a PMF (svg_diagram)

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 640 320">
  <text x="320" y="26" text-anchor="middle" font-size="16" font-weight="bold" fill="#1a1a1a">PMF for Sum of Two Fair Dice (svg_diagram)</text>

  <line x1="60" y1="250" x2="600" y2="250" stroke="#333" stroke-width="1" />
  <line x1="60" y1="60" x2="60" y2="250" stroke="#333" stroke-width="1" />

  <rect x="75" y="240" width="30" height="10" fill="#4a90d9" />
  <rect x="115" y="220" width="30" height="30" fill="#4a90d9" />
  <rect x="155" y="200" width="30" height="50" fill="#4a90d9" />
  <rect x="195" y="180" width="30" height="70" fill="#4a90d9" />
  <rect x="235" y="160" width="30" height="90" fill="#4a90d9" />
  <rect x="275" y="140" width="30" height="110" fill="#4a90d9" />
  <rect x="315" y="160" width="30" height="90" fill="#4a90d9" />
  <rect x="355" y="180" width="30" height="70" fill="#4a90d9" />
  <rect x="395" y="200" width="30" height="50" fill="#4a90d9" />
  <rect x="435" y="220" width="30" height="30" fill="#4a90d9" />
  <rect x="475" y="240" width="30" height="10" fill="#4a90d9" />

  <text x="90" y="265" font-size="10" fill="#1a1a1a">2</text>
  <text x="130" y="265" font-size="10" fill="#1a1a1a">3</text>
  <text x="170" y="265" font-size="10" fill="#1a1a1a">4</text>
  <text x="210" y="265" font-size="10" fill="#1a1a1a">5</text>
  <text x="250" y="265" font-size="10" fill="#1a1a1a">6</text>
  <text x="288" y="265" font-size="10" fill="#1a1a1a">7</text>
  <text x="328" y="265" font-size="10" fill="#1a1a1a">8</text>
  <text x="368" y="265" font-size="10" fill="#1a1a1a">9</text>
  <text x="405" y="265" font-size="10" fill="#1a1a1a">10</text>
  <text x="445" y="265" font-size="10" fill="#1a1a1a">11</text>
  <text x="485" y="265" font-size="10" fill="#1a1a1a">12</text>

  <text x="320" y="290" font-size="12" fill="#1a1a1a" text-anchor="middle">Symmetric triangular shape peaking at sum = 7</text>
</svg>

### Worked Example

**Example**

Roll two independent fair six-sided dice and let $X$ = the sum of the two dice. There are $6 \times 6 = 36$ equally likely outcomes (each with probability $\tfrac{1}{36}$), from the multiplication principle established in the counting methods topic.

$$p_X(2) = \frac{1}{36}, \quad p_X(3) = \frac{2}{36}, \quad p_X(4) = \frac{3}{36}, \quad p_X(5) = \frac{4}{36}, \quad p_X(6) = \frac{5}{36}, \quad p_X(7) = \frac{6}{36}$$

$$p_X(8) = \frac{5}{36}, \quad p_X(9) = \frac{4}{36}, \quad p_X(10) = \frac{3}{36}, \quad p_X(11) = \frac{2}{36}, \quad p_X(12) = \frac{1}{36}$$

**Verify normalization:**

$$\frac{1+2+3+4+5+6+5+4+3+2+1}{36} = \frac{36}{36} = 1$$

**Compute $P(X \geq 10)$** using the event-derivation formula above:

$$P(X \geq 10) = p_X(10) + p_X(11) + p_X(12) = \frac{3}{36} + \frac{2}{36} + \frac{1}{36} = \frac{6}{36} = \frac{1}{6}$$

These values follow from direct enumeration of the 36 equally likely outcome pairs and counting how many pairs sum to each value; this is a mechanical computation from the stated setup, not drawn from an external cited source.

### Relationship to the CDF

As stated in the discrete random variables topic, the CDF is obtained by accumulating PMF values:

$$F_X(x) = \sum_{x_i \leq x} p_X(x_i)$$

Conversely, the PMF can be recovered from the CDF by taking successive differences at each point of discontinuity:

$$p_X(x_i) = F_X(x_i) - F_X(x_{i-1})$$

where $x_{i-1}$ denotes the next smaller value in the support below $x_i$. [Inference] This recovery formula follows directly from the definition of the CDF as a cumulative sum; subtracting the cumulative total up to the previous support value isolates the probability mass at exactly $x_i$. This is a direct algebraic consequence of the definitions already stated, not an independently confirmed empirical claim.

### Joint PMFs (Brief Preview)

For two discrete random variables $X$ and $Y$, a joint PMF is defined as:

$$p_{X,Y}(x,y) = P(X = x, Y = y)$$

[Unverified] A full treatment of joint PMFs, including marginalization and conditional PMFs derived from them, is deferred to a dedicated future topic on joint distributions; this preview statement has not been expanded upon or derived further in this response.

### Relevance to Machine Learning

- **Categorical model outputs**: classifiers that output a probability distribution over discrete class labels (e.g., via softmax) are producing an estimated PMF over the label space, directly relying on the non-negativity and normalization properties stated above.
- **Cross-entropy loss**: the standard cross-entropy loss function used in classification tasks is defined using the PMF (or estimated PMF) of the true and predicted label distributions: $-\sum_x p_{\text{true}}(x) \log p_{\text{model}}(x)$. [Inference] This formula is a standard construction connecting information theory to the PMF framework described here; I cannot cite a specific primary source confirming this exact notation within this conversation, so it is presented as the conventional form rather than a direct quotation from a verified document.
- **Discrete generative models**: models that generate discrete tokens (e.g., words, categorical variables) rely on an underlying PMF over the vocabulary or category set at each generation step. [Unverified] Whether any specific named model or library implementation computes this PMF exactly versus via approximation or sampling techniques is implementation-specific; I do not have a verified source confirming the exact behavior of any particular tool, and this is not a guaranteed property of any named system.

### Common Pitfalls

- Assigning a nonzero PMF value to a point outside the actual support of $X$, or failing to assign $p_X(x)=0$ implicitly for such points — this can cause normalization to fail if not handled carefully.
- Confusing a PMF value $p_X(x)$ (a probability, bounded in $[0,1]$) with a PDF value $f_X(x)$ (a density, which can exceed 1) — these are distinct objects for discrete versus continuous random variables respectively, as noted in the continuous random variables topic.
- Failing to verify normalization ($\sum p_X(x) = 1$) after constructing or estimating a PMF from data — an unnormalized function does not qualify as a valid PMF under Kolmogorov's axioms.

This entire response is labeled in aggregate as **[Inference/Unverified]**: it consists of standard, widely-taught mathematical definitions and derivations reasoned from axioms and definitions already established earlier in this conversation. I cannot verify any of it against an external cited primary source within this conversation, and no claim above uses the terms prevent, guarantee, will never, fixes, eliminates, or ensures that in a non-quoted context. All statements concerning the behavior of specific machine learning libraries, models, or tools are explicitly labeled [Inference] or [Unverified] with a disclaimer that such behavior is not guaranteed and may vary by implementation.

**Related Topics**
- Cumulative Distribution Functions (Discrete Case)
- Joint and Marginal PMFs
- Bernoulli and Binomial Distributions
- Geometric and Poisson Distributions
- Expectation and Variance from a PMF
- Categorical Cross-Entropy in Classification