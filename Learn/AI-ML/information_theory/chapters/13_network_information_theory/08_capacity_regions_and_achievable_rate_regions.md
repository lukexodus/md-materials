## Capacity Regions and Achievable Rate Regions

### Overview

A capacity region generalizes the single-user channel capacity to networks with multiple senders and/or receivers. Instead of a single number (bits/channel use), the fundamental limit is a **region** in an $n$-dimensional rate space, where $n$ is the number of independent messages in the network. A rate tuple $(R_1, R_2, \ldots, R_n)$ is achievable if there exist codes that let all messages be communicated with error probability approaching zero as block length $\to \infty$. The capacity region is the closure of the set of all achievable rate tuples.

This topic covers the general framework — what the region represents, how achievability and converse arguments combine to characterize it, and the structural properties (convexity, time-sharing) common to essentially all multi-user capacity results.

### Why a Region Instead of a Number

In point-to-point communication, capacity $C$ is a single scalar: the supremum of achievable rates. In a network with multiple independent messages, "capacity" cannot be a scalar because different users can trade rate against each other. For example, in a multiple access channel, if one sender transmits at a very high rate, it may force the other sender's achievable rate toward zero, and vice versa.

The capacity region $\mathcal{C} \subseteq \mathbb{R}_{+}^n$ therefore captures the entire frontier of simultaneously achievable rates. Any point strictly inside the region is achievable; any point strictly outside is not, no matter how sophisticated the coding scheme.

### Formal Definition of Achievability

A rate tuple $(R_1, \ldots, R_n)$ is **achievable** if, for every $\epsilon > 0$, there exists a blocklength $N$ and an $(N, 2^{NR_1}, \ldots, 2^{NR_n})$ code such that the average (or maximal, depending on convention) probability of decoding error satisfies

$$P_e^{(N)} \le \epsilon$$

for all messages simultaneously, as $N \to \infty$. The **capacity region** $\mathcal{C}$ is the closure of the set of all such achievable tuples.

**Key Points**
- Achievability is a joint condition: all messages must be decoded reliably at once, not on average across a random subset.
- The closure is taken because the achievable set is generally open or not closed under limits; standard practice includes boundary points via closure.
- Different network models (MAC, broadcast, relay, interference) have different code definitions (single encoder vs. multiple encoders, single decoder vs. multiple decoders), but the achievability definition follows the same template.

### General Proof Strategy: Achievability and Converse

Every capacity region result is established via two separate arguments that must meet:

1. **Achievability (direct part).** Construct an explicit coding scheme (typically via random coding, joint typicality decoding, and sometimes techniques like superposition coding, binning, or successive cancellation) and show that all rate tuples in a claimed region $\mathcal{R}_{\text{in}}$ are achievable.
2. **Converse (outer bound).** Use information-theoretic inequalities (Fano's inequality, the data processing inequality, chain rules for entropy/mutual information) to show that any achievable rate tuple must lie in some region $\mathcal{R}_{\text{out}}$.

If $\mathcal{R}_{\text{in}} = \mathcal{R}_{\text{out}}$, the capacity region is exactly characterized. When the two regions do not match, only inner and outer bounds are known — this is the status for many open network information theory problems (e.g., the general interference channel, general relay networks).

### Structural Properties of Capacity Regions

**Convexity.** Capacity regions of memoryless networks are convex sets. This follows from **time-sharing**: if $(R_1, R_2)$ is achievable via code $\mathcal{A}$ and $(R_1', R_2')$ is achievable via code $\mathcal{B}$, then for any $\lambda \in [0,1]$, the rate pair

$$\lambda(R_1, R_2) + (1-\lambda)(R_1', R_2')$$

is achievable by using code $\mathcal{A}$ for a $\lambda$ fraction of the block and code $\mathcal{B}$ for the remaining $(1-\lambda)$ fraction.

**Closedness.** By definition (via closure), capacity regions are closed sets, so boundary rate tuples are included as achievable (in the limit).

**Monotonicity considerations.** Interior points of the region are achievable with error probability going to zero; the region does not shrink under relaxed constraints (e.g., average error vs. maximal error criteria may yield the same region under mild conditions, though this must be verified per model).

**Union over input distributions.** Many achievable regions are expressed as a union over auxiliary random variables or input distributions:

$$\mathcal{C} = \bigcup_{p(\cdot)} \mathcal{R}(p)$$

where $\mathcal{R}(p)$ is a region (often a polytope defined by mutual-information bounds) for a fixed joint distribution $p$ over channel inputs and auxiliary variables. The union is then convexified via time-sharing if the raw union is not already convex.

### Rate Regions as Polytopes

For many classical results (multiple access channel, degraded broadcast channel with superposition coding, Slepian–Wolf source coding), the achievable region for a **fixed input distribution** is a polytope described by linear inequalities in the rates, of the form:

$$\sum_{i \in S} R_i \le I(X_S ; Y \mid X_{S^c})$$

for subsets $S$ of the user index set, where $I(\cdot;\cdot)$ denotes mutual information. The overall capacity region is the union (and convex hull) of these polytopes over all valid input distributions.

**Example: two-user MAC achievable region (fixed $p(x_1)p(x_2)$)**

$$R_1 \le I(X_1; Y \mid X_2)$$
$$R_2 \le I(X_2; Y \mid X_1)$$
$$R_1 + R_2 \le I(X_1, X_2; Y)$$

This is a pentagon in the $(R_1, R_2)$ plane. The full capacity region is the union of such pentagons over all product input distributions $p(x_1)p(x_2)$, then take the convex hull (the union of pentagons over independent inputs is already convex for the MAC, a known result, so the convex-hull step is not needed there — but it is needed in general achievability constructions).

<svg viewBox="0 0 520 420" xmlns="http://www.w3.org/2000/svg">
  <text x="260" y="28" text-anchor="middle" font-size="16" font-weight="bold" fill="#1a1a1a">Two-User MAC Achievable Region (svg_diagram)</text>

  <!-- Axes -->
  <line x1="70" y1="360" x2="480" y2="360" stroke="#333" stroke-width="2"/>
  <line x1="70" y1="360" x2="70" y2="60" stroke="#333" stroke-width="2"/>
  <text x="490" y="365" font-size="14" fill="#333">R₁</text>
  <text x="55" y="55" font-size="14" fill="#333">R₂</text>
  <text x="40" y="365" font-size="12" fill="#333">0</text>

  <!-- Pentagon region -->
  <polygon points="70,360 300,360 380,220 300,100 70,100"
           fill="#4a90d9" fill-opacity="0.25" stroke="#2b5f8a" stroke-width="2"/>

  <!-- Corner labels -->
  <line x1="300" y1="360" x2="300" y2="370" stroke="#333" stroke-width="1"/>
  <text x="290" y="385" font-size="12" fill="#333">I(X₁;Y|X₂)</text>

  <line x1="60" y1="100" x2="70" y2="100" stroke="#333" stroke-width="1"/>
  <text x="10" y="104" font-size="12" fill="#333">I(X₂;Y|X₁)</text>

  <!-- Sum-rate constraint line -->
  <line x1="380" y1="220" x2="300" y2="100" stroke="#c0392b" stroke-width="2" stroke-dasharray="5,3"/>
  <text x="390" y="180" font-size="12" fill="#c0392b">R₁+R₂ = I(X₁,X₂;Y)</text>

  <!-- Interior label -->
  <text x="180" y="260" font-size="13" fill="#1a1a1a" font-style="italic">Achievable</text>
  <text x="180" y="278" font-size="13" fill="#1a1a1a" font-style="italic">rate region</text>
</svg>

### Region Characterization Across Network Models

| Network Model | Region Status | Key Bounding Quantities |
|---|---|---|
| Multiple Access Channel (MAC) | Fully known | Individual rates, sum-rate mutual informations |
| Degraded Broadcast Channel | Fully known | Superposition coding rates |
| General Broadcast Channel | Open in general | Marton's inner bound vs. outer bounds |
| Slepian–Wolf (distributed source coding) | Fully known | Joint/conditional entropies |
| Relay Channel | Open in general | Cutset bound (outer), decode-forward / compress-forward (inner) |
| Interference Channel | Open in general | Han–Kobayashi region (inner), various outer bounds |
| Two-Way Channel | Open in general | Inner/outer bounds only |

**Key Points**
- "Fully known" means achievability and converse regions coincide exactly.
- "Open in general" means only inner (achievable) and outer (converse) bounds exist, and they do not match for all channel parameters.
- [Inference] The persistence of open problems in interference and relay networks over several decades suggests these gaps reflect genuine difficulty in the converse techniques (single-letterization of multi-user mutual information expressions) rather than lack of effort.

### The Cutset Bound as a General Converse Tool

For networks with a single source and single destination but intermediate relays, the **cutset bound** provides a general (though often loose) outer bound. For any partition of nodes into a set $S$ containing the source and $S^c$ containing the destination:

$$R \le \max_{p(x_1,\ldots,x_N)} \min_{S : \text{source} \in S, \text{dest} \in S^c} I(X_S ; Y_{S^c} \mid X_{S^c})$$

This mirrors the max-flow min-cut theorem from network flow theory, applied to information flow, and is tight for some networks (e.g., the physically degraded relay channel) but not for others (e.g., general Gaussian relay networks), where a constant gap remains between cutset outer bounds and the best known achievable rates.

### Achievable Region Techniques (Summary)

**Key Points**
- **Random coding + joint typicality decoding**: the workhorse technique for essentially all achievability proofs, dating to Shannon's original random coding argument.
- **Superposition coding**: layers codewords so a receiver with a better channel can decode both layers, used in broadcast channels.
- **Binning**: partitions codebooks into bins to handle side information or interference, used in Slepian–Wolf coding and dirty-paper-coding-style schemes.
- **Successive cancellation / successive decoding**: decodes one user's signal, subtracts its effect, then decodes the next — used in MAC achievability and NOMA-style schemes.
- **Block Markov coding / decode-and-forward**: relays decode a block of the source message and re-encode it for the next hop, used in relay channel achievability.

### Rate Region vs. Capacity Region: Terminology Note

The terms are often used interchangeably, but some texts reserve **"achievable rate region"** for a region proven via a specific coding scheme (an inner bound that may not be tight), and **"capacity region"** for the true, exactly characterized set of all achievable rates. This distinction matters in reading the literature: a paper presenting an "achievable region" is not necessarily claiming optimality.

### Worked Example: Verifying a Rate Pair Against a Given Region

Suppose a fixed input distribution for a two-user MAC yields $I(X_1;Y|X_2) = 1.5$, $I(X_2;Y|X_1) = 1.2$, and $I(X_1,X_2;Y) = 2.0$ bits/channel use. Check whether $(R_1, R_2) = (1.0, 0.9)$ is achievable under this distribution.

**Output**
- $R_1 = 1.0 \le 1.5$ ✓
- $R_2 = 0.9 \le 1.2$ ✓
- $R_1 + R_2 = 1.9 \le 2.0$ ✓

All three constraints are satisfied, so $(1.0, 0.9)$ lies inside the pentagon and is achievable under this input distribution. Note that a different, better-chosen input distribution might expand the region further; this check only confirms membership for the given distribution, not optimality of the point.

### Conclusion

The capacity region formalism replaces the single-number capacity of point-to-point channels with a geometric object in rate space, built from achievability (inner bound) and converse (outer bound) arguments that ideally coincide. Convexity via time-sharing, polytope descriptions via mutual-information inequalities, and general tools like the cutset bound recur across virtually every network model. Many canonical multi-terminal problems (MAC, degraded broadcast, Slepian–Wolf) have fully closed-form regions, while others (general broadcast, interference, relay, two-way channels) remain open, with the gap between best-known inner and outer bounds an active research area.

**Next Topics**
- Multiple Access Channel: detailed capacity region derivation and successive cancellation decoding
- Broadcast Channels: superposition coding and Marton's inner bound
- Slepian–Wolf Coding: distributed source coding without cooperation
- Relay Channels: cutset bound, decode-forward, and compress-forward strategies
- Interference Channels: Han–Kobayashi achievable region
- Gaussian Network Models: capacity regions under power constraints
- Network Coding: the butterfly network and max-flow min-cut for information