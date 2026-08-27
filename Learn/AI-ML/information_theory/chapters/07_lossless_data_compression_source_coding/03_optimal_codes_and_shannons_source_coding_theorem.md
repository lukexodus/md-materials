## Optimal Codes and Shannon's Source Coding Theorem

### Setting Up the Problem

Given a discrete memoryless source $X$ emitting symbols from an alphabet $\{x_1, \ldots, x_n\}$ with probabilities $\{p_1, \ldots, p_n\}$, the goal of source coding is to assign binary codewords of lengths $\{l_1, \ldots, l_n\}$ that (a) form a valid prefix code, per the Kraft inequality $\sum_i 2^{-l_i} \leq 1$, and (b) minimize the expected codeword length:

$$L = \sum_{i=1}^{n} p_i l_i$$

An **optimal code** is a prefix code that achieves the minimum possible value of $L$ over all valid length assignments for the given probability distribution. Shannon's source coding theorem establishes the fundamental limit that this optimal length can approach, and why that limit is entropy.

### Lower Bound: Entropy as the Floor

**Claim**: For any uniquely decodable code (and hence any prefix code) over source $X$, the expected length satisfies:

$$L \geq H(X)$$

where $H(X) = -\sum_i p_i \log_2 p_i$ is the Shannon entropy of the source, measured in bits.

**Proof sketch (via Gibbs' inequality)**: Define $q_i = 2^{-l_i}$. By the Kraft inequality, $\sum_i q_i \leq 1$, so $\{q_i\}$ can be treated as a sub-probability distribution. The difference $L - H(X)$ can be written as:

$$L - H(X) = \sum_i p_i l_i + \sum_i p_i \log_2 p_i = -\sum_i p_i \log_2 q_i + \sum_i p_i \log_2 p_i = \sum_i p_i \log_2 \frac{p_i}{q_i}$$

This is precisely the **Kullback–Leibler divergence** $D_{KL}(p \| q) = \sum_i p_i \log_2 (p_i/q_i)$, extended to account for $\sum_i q_i \leq 1$. KL divergence is always non-negative (Gibbs' inequality), with equality if and only if $p_i = q_i$ for all $i$. Therefore:

$$L - H(X) \geq 0 \quad \Longrightarrow \quad L \geq H(X)$$

Equality holds exactly when $q_i = 2^{-l_i} = p_i$ for every symbol — that is, when each codeword length is precisely $l_i = -\log_2 p_i$. This only happens when every probability is a negative power of two (a **dyadic distribution**).

### Upper Bound: Achievability Within One Bit

**Claim**: A prefix code exists whose expected length satisfies:

$$L < H(X) + 1$$

**Construction (Shannon–Fano style)**: Choose integer lengths:

$$l_i = \lceil -\log_2 p_i \rceil$$

This is well-defined because $-\log_2 p_i \geq 0$ for any valid probability. These lengths satisfy the Kraft inequality:

$$\sum_i 2^{-l_i} \leq \sum_i 2^{-(-\log_2 p_i)} = \sum_i p_i = 1$$

so a valid prefix code with these lengths is guaranteed to exist (by Kraft's sufficiency direction). Since $l_i < -\log_2 p_i + 1$ by the definition of the ceiling function, the expected length satisfies:

$$L = \sum_i p_i l_i < \sum_i p_i (-\log_2 p_i + 1) = H(X) + 1$$

### The Source Coding Theorem, Combined

Putting the lower and upper bounds together gives the classical statement of Shannon's (noiseless) source coding theorem for a single use of the source:

$$H(X) \leq L^* < H(X) + 1$$

where $L^*$ denotes the expected length of an **optimal** prefix code (necessarily at least as good as the Shannon–Fano construction above, so the upper bound still applies).

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 640 260">
  <text x="320" y="24" text-anchor="middle" font-size="15" font-weight="bold" fill="#1a1a1a">Source Coding Theorem: The One-Bit Gap (svg_diagram)</text>

  <line x1="80" y1="140" x2="580" y2="140" stroke="#333" stroke-width="2" />
  <line x1="80" y1="130" x2="80" y2="150" stroke="#333" stroke-width="2" />
  <text x="80" y="170" text-anchor="middle" font-size="12" fill="#333">H(X)</text>

  <line x1="330" y1="130" x2="330" y2="150" stroke="#c0392b" stroke-width="2" />
  <text x="330" y="170" text-anchor="middle" font-size="12" fill="#c0392b">H(X) + 1</text>

  <rect x="80" y="100" width="250" height="20" fill="#27ae60" opacity="0.35" />
  <text x="205" y="95" text-anchor="middle" font-size="12" fill="#27ae60">Achievable region for L*</text>

  <circle cx="150" cy="110" r="6" fill="#2980b9" />
  <text x="150" y="215" text-anchor="middle" font-size="11" fill="#2980b9">L* here (near-dyadic probs)</text>

  <circle cx="300" cy="110" r="6" fill="#8e44ad" />
  <text x="300" y="235" text-anchor="middle" font-size="11" fill="#8e44ad">L* here (skewed, hard-to-match probs)</text>

  <text x="330" y="200" text-anchor="middle" font-size="12" fill="#333">L* is always in [H(X), H(X)+1)</text>
</svg>

### Why the Gap Exists — The Integer-Length Constraint

The one-bit slack arises purely because codeword lengths must be positive integers, while the information-theoretically ideal length $-\log_2 p_i$ is generally not an integer. Symbols with probability not equal to a power of $\tfrac{1}{2}$ cannot be assigned their exact ideal length, forcing rounding up (to preserve the prefix property) and incurring redundancy.

**[Inference]** The worst-case gap approaching a full bit tends to occur in highly skewed two-symbol distributions (e.g., $p_1 \to 1$, $p_2 \to 0$), where $H(X) \to 0$ but at least 1 bit per symbol is still structurally required to distinguish two possible outcomes at all, since a single symbol source cannot be encoded in zero bits.

### Extension by Blocking: Closing the Gap

The one-bit-per-symbol penalty can be made arbitrarily small (as a fraction of length per symbol) by encoding **blocks of $N$ symbols jointly** rather than symbol by symbol. Let $X^N$ denote a block of $N$ i.i.d. draws from the source. Applying the same theorem to the block source:

$$H(X^N) \leq L_N^* < H(X^N) + 1$$

For a memoryless (i.i.d.) source, entropy is additive: $H(X^N) = N \cdot H(X)$. Dividing through by $N$ to get the expected length **per original symbol**:

$$H(X) \leq \frac{L_N^*}{N} < H(X) + \frac{1}{N}$$

As $N \to \infty$, the per-symbol redundancy $\tfrac{1}{N}$ vanishes, and the achievable rate converges exactly to entropy:

$$\lim_{N \to \infty} \frac{L_N^*}{N} = H(X)$$

This is the deeper and more powerful form of the source coding theorem: **entropy is the asymptotically achievable compression limit**, not merely a bound with a fixed gap.

```mermaid
flowchart LR
    A["Single-symbol coding"] --> B["H(X) <= L < H(X) + 1"]
    B --> C["Block N symbols jointly"]
    C --> D["H(X^N) <= L_N < H(X^N) + 1"]
    D --> E["Divide by N (i.i.d. source: H(X^N) = N*H(X))"]
    E --> F["H(X) <= L_N/N < H(X) + 1/N"]
    F --> G["As N -> infinity, redundancy 1/N -> 0"]
    G --> H["Per-symbol rate converges to H(X)"]
```

### Worked Example — Computing the Gap for a Simple Source

Consider a binary source with $P(x_1) = 0.9$, $P(x_2) = 0.1$.

**Entropy**:
$$H(X) = -0.9 \log_2(0.9) - 0.1 \log_2(0.1) \approx -0.9(-0.152) - 0.1(-3.322) \approx 0.137 + 0.332 = 0.469 \text{ bits}$$

**Single-symbol optimal prefix code**: With only two symbols, the only valid prefix code assigns length 1 to each (e.g., $x_1 = 0$, $x_2 = 1$), since any prefix code over 2 symbols must use at least one bit per symbol (assigning length 0 to one symbol would leave no valid non-prefix codeword for the other). So:

$$L^* = 0.9(1) + 0.1(1) = 1 \text{ bit}$$

This confirms $H(X) = 0.469 \leq L^* = 1 < H(X) + 1 = 1.469$, but the **efficiency** $H(X)/L^* \approx 46.9\%$ is poor — over half the transmitted bits are structurally wasted redundancy at the single-symbol level.

**Blocking with $N = 2$**: Treat pairs of symbols as a 4-outcome alphabet: $\{x_1x_1, x_1x_2, x_2x_1, x_2x_2\}$ with probabilities $\{0.81, 0.09, 0.09, 0.01\}$. A Huffman code on this block distribution would assign shorter codewords to $x_1x_1$ and can be shown to achieve $L_2^*/2$ closer to $H(X)$ than the single-symbol case — illustrating the convergence predicted by the blocking argument. **[Inference]** The exact optimal $L_2^*$ depends on the specific Huffman tree constructed for these four probabilities and is not derived symbolically here, but the qualitative improvement in per-symbol efficiency with blocking is a direct, well-established consequence of the theorem.

### Redundancy and Coding Efficiency

Two standard metrics quantify how close a code comes to the entropy limit:

- **Redundancy**: $R = L - H(X)$, the excess bits per symbol above the theoretical minimum.
- **Coding efficiency**: $\eta = \dfrac{H(X)}{L}$, expressed as a ratio (or percentage), where $\eta = 1$ (100%) indicates an optimal, entropy-achieving code.

Huffman coding is guaranteed to produce the prefix code minimizing $L$ for a given symbol-level distribution — that is, it achieves $L^*$ exactly among all prefix codes over that alphabet — but $L^*$ itself is still bounded below by $H(X)$ and above by $H(X)+1$ unless blocking is used, or unless the source happens to have a dyadic distribution.

### Relationship to Huffman Coding and Arithmetic Coding

- **Huffman coding** operates on a fixed symbol (or block) alphabet, always achieves the true optimal $L^*$ for that alphabet, but still incurs up to 1 bit of redundancy per symbol unless combined with blocking, and requires each symbol to receive an integer number of bits.
- **Arithmetic coding** sidesteps the integer-length constraint entirely by encoding an entire sequence as a single fractional interval, effectively allowing fractional bits per symbol. This lets arithmetic coding approach $H(X)$ per symbol directly without the explicit blocking construction Huffman coding requires, and is why arithmetic coding (and modern range coding variants) typically outperforms symbol-wise Huffman coding on skewed distributions. **[Unverified]** The precise practical efficiency gap between arithmetic coding and blocked Huffman coding depends on implementation details, block size chosen, and source statistics, and is not a fixed universal number.

### Key Points

- Shannon's source coding theorem bounds the optimal expected prefix-code length as $H(X) \leq L^* < H(X) + 1$ for single-symbol coding.
- The lower bound follows from the non-negativity of KL divergence (Gibbs' inequality) applied to the implied distribution $2^{-l_i}$.
- The upper bound is achieved constructively via lengths $l_i = \lceil -\log_2 p_i \rceil$, which always satisfy the Kraft inequality.
- Equality with entropy is achieved only for **dyadic distributions**, where every $p_i$ is an exact power of $\tfrac{1}{2}$.
- Encoding symbols in **blocks of $N$** drives the per-symbol redundancy down to $\tfrac{1}{N}$, so entropy is the true asymptotic compression limit, not just a loose one-bit bound.
- **Coding efficiency** $\eta = H(X)/L$ quantifies how close any real code comes to this limit.

### Next Steps

- Huffman coding algorithm: construction procedure and optimality proof
- Arithmetic coding and range coding as fractional-bit alternatives to Huffman
- Extension to sources with memory: entropy rate and context-based coding (e.g., PPM, LZ-family compressors)
- Dyadic distributions and when Huffman coding achieves entropy exactly
- Universal source coding: Lempel-Ziv algorithms and adaptive coding without known probabilities
- Redundancy-efficiency tradeoffs in practical compression standards