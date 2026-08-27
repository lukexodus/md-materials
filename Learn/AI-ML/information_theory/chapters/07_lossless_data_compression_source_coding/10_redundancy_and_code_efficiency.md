## Redundancy and Code Efficiency

### Formal Definitions

Given a source $X$ with entropy $H(X)$ and a code assigning it expected length $L = \sum_i p_i l_i$, two standard metrics quantify how well that code compresses relative to the theoretical limit.

**Redundancy** is the absolute excess of expected code length above entropy:

$$R = L - H(X)$$

Redundancy is measured in the same units as $L$ and $H(X)$ (bits per symbol, when using $\log_2$). By the source coding theorem, $R \geq 0$ always, with $R = 0$ achievable only for dyadic distributions under an optimal code.

**Coding efficiency** (sometimes called **relative efficiency**) is the ratio of the theoretical minimum to the actual achieved length:

$$\eta = \frac{H(X)}{L}$$

expressed either as a fraction in $[0, 1]$ or as a percentage. An efficiency of $\eta = 1$ (100%) indicates the code achieves the entropy bound exactly; lower values indicate proportionally more wasted bits per symbol.

**Relative redundancy** normalizes redundancy by entropy rather than by $L$:

$$\rho = \frac{R}{H(X)} = \frac{L - H(X)}{H(X)} = \frac{1}{\eta} - 1$$

**[Inference]** Different textbooks and papers use slightly different conventions for "redundancy" — some define it relative to $L$ instead of $H(X)$ (i.e., $R/L$ rather than $R/H(X)$), and some define efficiency as $1 - \rho$ rather than $H(X)/L$. The definitions given above ($R = L - H(X)$ and $\eta = H(X)/L$) are the most commonly encountered conventions, but readers should check the specific convention used in any given source when comparing numerical efficiency figures across references.

### Worked Example — Computing All Three Metrics

Using the 5-symbol Huffman example from earlier ($P(A)=0.35, P(B)=0.25, P(C)=0.20, P(D)=0.12, P(E)=0.08$), previously computed:

$$H(X) \approx 2.153 \text{ bits}, \qquad L_{\text{Huffman}} = 2.20 \text{ bits}$$

**Redundancy**:
$$R = 2.20 - 2.153 = 0.047 \text{ bits per symbol}$$

**Coding efficiency**:
$$\eta = \frac{2.153}{2.20} \approx 0.979 \;\; (97.9\%)$$

**Relative redundancy**:
$$\rho = \frac{0.047}{2.153} \approx 0.0218 \;\; (2.18\%)$$

This confirms the Huffman code for this distribution is highly efficient — within about 2% of the theoretical minimum — even though it does not achieve entropy exactly, since the distribution is not dyadic.

### Worked Example — A Poorly Matched Distribution

Recall the earlier binary source example with $P(x_1) = 0.9$, $P(x_2) = 0.1$, where $H(X) \approx 0.469$ bits but the only valid single-symbol prefix code gives $L^* = 1$ bit (since any two-symbol prefix code requires at least 1 bit per symbol).

**Redundancy**:
$$R = 1 - 0.469 = 0.531 \text{ bits per symbol}$$

**Coding efficiency**:
$$\eta = \frac{0.469}{1} \approx 0.469 \;\; (46.9\%)$$

**Relative redundancy**:
$$\rho = \frac{0.531}{0.469} \approx 1.132 \;\; (113.2\%)$$

This starkly illustrates that redundancy and efficiency are **distribution-dependent**, not properties of the coding algorithm alone: the same Huffman algorithm produces a near-optimal 97.9%-efficient code for one distribution and a poor 46.9%-efficient code for another, purely because of how well the distribution's probabilities align with achievable integer codeword lengths (i.e., how close the distribution is to dyadic).

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 640 260">
  <text x="320" y="22" text-anchor="middle" font-size="15" font-weight="bold" fill="#1a1a1a">Efficiency Depends on the Distribution, Not Just the Algorithm (svg_diagram)</text>

  <text x="160" y="55" text-anchor="middle" font-size="12" fill="#333">5-symbol distribution</text>
  <rect x="80" y="70" width="160" height="24" fill="#27ae60" opacity="0.6" />
  <text x="160" y="87" text-anchor="middle" font-size="11" fill="#1a1a1a">eta approx 97.9%</text>

  <text x="480" y="55" text-anchor="middle" font-size="12" fill="#333">skewed binary distribution</text>
  <rect x="400" y="70" width="76" height="24" fill="#c0392b" opacity="0.6" />
  <text x="438" y="87" text-anchor="middle" font-size="11" fill="#1a1a1a">eta approx 46.9%</text>

  <text x="320" y="140" text-anchor="middle" font-size="12" fill="#555">Same algorithm (Huffman), same optimality guarantee within its class —</text>
  <text x="320" y="160" text-anchor="middle" font-size="12" fill="#555">but efficiency varies dramatically based on how close probabilities are to powers of 1/2.</text>

  <text x="320" y="200" text-anchor="middle" font-size="12" fill="#333">Fix for skewed case: block coding or arithmetic coding recovers efficiency</text>
  <text x="320" y="220" text-anchor="middle" font-size="12" fill="#333">by removing the per-symbol integer-length constraint.</text>
</svg>

### Sources of Redundancy

Redundancy in a code arises from two conceptually distinct causes, both discussed in earlier topics:

1. **Integer-length rounding redundancy**: even an optimal prefix code must assign integer-length codewords, while the ideal length $-\log_2 p_i$ is generally fractional. This is the redundancy source that arithmetic coding specifically eliminates, and that block coding reduces asymptotically (per the $H(X) \leq L_N^*/N < H(X) + 1/N$ result).
2. **Model mismatch redundancy**: if the code is built using estimated or assumed probabilities $q_i$ that differ from the source's true probabilities $p_i$, an additional redundancy term appears. Using the KL-divergence relationship derived earlier in the context of the source coding theorem's lower bound:

$$L(q) - H(X) = D_{KL}(p \| q) + \left[\text{integer-length rounding term}\right]$$

**[Inference]** This decomposition is most cleanly exact in the idealized case where non-integer lengths $l_i = -\log_2 q_i$ are permitted (as in the arithmetic-coding-style analysis); with a real integer-length code built from a mismatched model $q$, the two redundancy sources (model mismatch and integer rounding) combine, and separating their individual numerical contributions requires the specific code construction being analyzed. The qualitative point — that using the *wrong* probability model costs additional bits beyond what integer-length rounding alone would cost — holds generally and is a standard result in information theory.

### Redundancy in Practice: Why It Matters

- **Compression ratio benchmarking**: efficiency and redundancy metrics let engineers compare a real compressor's output size against the theoretical best possible for a given (measured or assumed) source model, separating "how good is this specific algorithm" from "how compressible is this data fundamentally."
- **Algorithm selection**: distributions with efficiency far below 100% under Huffman coding (like the skewed binary example) signal that switching to arithmetic coding, block coding, or better context modeling could yield meaningful compression gains; distributions already near 97-99% efficiency under Huffman offer little room for improvement from switching entropy coders alone.
- **Diagnosing model mismatch**: if a real-world compressor performs worse than expected, decomposing the redundancy into rounding versus mismatch components (even qualitatively) helps identify whether the fix is a better entropy coder (addresses rounding) or a better probability/context model (addresses mismatch) — this is precisely why modern high-performance compressors invest heavily in **context modeling** (e.g., PPM, CABAC, context-mixing) rather than only in entropy-coder refinement.

### Efficiency Across the Techniques Covered So Far

| Technique | Typical redundancy source | Efficiency ceiling |
|---|---|---|
| Static Huffman (single symbol) | Integer-length rounding | Up to $H(X)+1$; can be far below 100% for skewed distributions |
| Blocked Huffman ($N$ symbols) | Integer-length rounding, reduced by factor $N$ | Approaches 100% as $N \to \infty$ |
| Shannon-Fano | Integer-length rounding (looser than Huffman) | Slightly below Huffman's efficiency for the same distribution |
| Arithmetic coding | Negligible (fractional bits per symbol) | Very close to 100%, limited mainly by finite-precision overhead |
| Elias / universal integer codes | Bounded redundancy across a distribution class, not distribution-specific optimality | Not optimal for any single known distribution by design |
| Adaptive Huffman / arithmetic | Model mismatch during the early "learning" phase of the stream | Approaches static-code efficiency as more symbols are observed |

### Key Points

- **Redundancy** $R = L - H(X)$ and **coding efficiency** $\eta = H(X)/L$ are the two standard metrics for how close a real code comes to the entropy limit.
- Efficiency depends heavily on the **specific probability distribution**, not just the coding algorithm — the same Huffman algorithm can be near-optimal for one distribution and quite inefficient for another.
- Redundancy arises from two sources: the unavoidable **integer-length rounding** inherent to symbol-by-symbol prefix codes, and **model mismatch** when the code is built from probabilities that differ from the true source distribution.
- Blocking and arithmetic coding both target the integer-length rounding source of redundancy; better context modeling targets the model-mismatch source.
- Efficiency metrics guide practical decisions about which compression technique to apply to a given data source.

### Related Topics

- Kullback-Leibler divergence and its role in quantifying model-mismatch redundancy
- Redundancy in sources with memory: entropy rate versus per-symbol entropy
- Rate-distortion theory (redundancy concepts extended to lossy compression)
- Practical benchmarking methodology: empirical entropy estimation from real data
- Context modeling techniques (PPM, CABAC) for reducing model-mismatch redundancy
- Universal source coding and the redundancy-optimality tradeoff for unknown distributions