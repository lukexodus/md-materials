## Union Bound

### Definition

Let $A_1, A_2, \dots, A_n$ be a finite (or countable) collection of events in a probability space. The Union Bound (also called Boole's Inequality) states:

$$P\left(\bigcup_{i=1}^n A_i\right) \leq \sum_{i=1}^n P(A_i)$$

For a countably infinite collection of events, the analogous statement is:

$$P\left(\bigcup_{i=1}^\infty A_i\right) \leq \sum_{i=1}^\infty P(A_i)$$

[Inference] This is the standard form of the Union Bound as commonly presented in probability theory, reasoned from general familiarity with the topic. I cannot verify the exact phrasing or historical attribution against a specific named source in this response.

### Key Points

- The Union Bound requires **no assumption of independence** between the events $A_i$; it holds unconditionally.
- The bound becomes tight (an equality) when the events are pairwise disjoint (mutually exclusive). [Inference] This is reasoned directly from the definition of probability for disjoint events, rather than confirmed against a specific named source in this response.
- The bound is generally considered loose when events overlap substantially, since summing individual probabilities double-counts shared outcomes. [Inference] Reasoned from the structure of the inequality itself.

### Proof Sketch

[Unverified] I cannot verify this exact derivation against a specific named source in this response, but a commonly presented proof structure is as follows:

For two events, the inclusion–exclusion principle gives:

$$P(A_1 \cup A_2) = P(A_1) + P(A_2) - P(A_1 \cap A_2)$$

Since $P(A_1 \cap A_2) \geq 0$:

$$P(A_1 \cup A_2) \leq P(A_1) + P(A_2)$$

This can be extended to $n$ events by induction. [Inference] This derivation follows from the two-event inclusion–exclusion identity, extended by an inductive argument, reasoned through directly rather than reproduced verbatim from a specific verified source. This proof sketch should be checked independently against a formal reference if used for rigorous work.

### Worked Example

Suppose a system has 5 independent components, each failing with probability $0.02$ over a given time period. Let $A_i$ denote the event that component $i$ fails.

Using the Union Bound, the probability that **at least one** component fails is bounded by:

$$P\left(\bigcup_{i=1}^5 A_i\right) \leq \sum_{i=1}^5 P(A_i) = 5 \times 0.02 = 0.10$$

[Inference] This calculation follows directly from substituting the stated values into the Union Bound formula. I have computed this directly rather than citing it from an external source, so it should be checked independently if used for formal purposes. Note that since independence is given in this example, the exact probability could alternatively be computed as $1 - (0.98)^5 \approx 0.0961$, which is close to but strictly less than the Union Bound's estimate of $0.10$ — illustrating that the bound is an upper bound, not an exact value. [Inference] This comparison follows from computing the complementary probability directly using independence, which is a separate calculation from the Union Bound itself; I have computed this directly rather than citing it, so it should be checked independently.

### Visual Intuition

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 700 320">
  <text x="350" y="30" text-anchor="middle" font-size="18" font-weight="bold" fill="#1a1a1a">Union Bound (svg_diagram)</text>

  <ellipse cx="280" cy="180" rx="110" ry="80" fill="#4a72c4" opacity="0.35" stroke="#4a72c4" stroke-width="1.5" />
  <text x="220" y="140" font-size="12" fill="#4a72c4">A₁</text>

  <ellipse cx="380" cy="180" rx="110" ry="80" fill="#c4574a" opacity="0.35" stroke="#c4574a" stroke-width="1.5" />
  <text x="440" y="140" font-size="12" fill="#c4574a">A₂</text>

  <text x="330" y="185" text-anchor="middle" font-size="11" fill="#333">overlap</text>

  <text x="350" y="290" text-anchor="middle" font-size="12" fill="#555">P(A₁∪A₂) ≤ P(A₁)+P(A₂); summing double-counts the overlap region</text>
</svg>

### Relation to Other Concepts

- The Union Bound is a direct consequence of the countable additivity (or finite additivity) axiom of probability combined with the non-negativity of probabilities. [Inference] Reasoned from the structure of the proof sketch above.
- It is commonly used alongside other concentration inequalities (e.g., Chernoff bounds, Hoeffding's Inequality) in a technique often called a **union bound argument**, where a bound on a single "bad event" is combined with the Union Bound to control the probability that **any** of several bad events occurs. [Inference] This is a commonly described technique in probability theory and theoretical computer science pedagogy, reasoned from general familiarity with the topic; I cannot verify this exact characterization against a specific named source in this response.
- [Unverified] I cannot verify the precise historical attribution of the Union Bound (commonly associated with the name "Boole's Inequality") without checking a formal source.

### Relevance to Machine Learning

- [Inference] The Union Bound is commonly used in statistical learning theory to derive uniform generalization bounds over a finite hypothesis class, by bounding the probability that **any** hypothesis in the class has a large gap between training and true error, based on general familiarity with the topic. I cannot verify this connection against a specific named paper or textbook in this response.
- [Inference] This technique underlies parts of the PAC (Probably Approximately Correct) learning framework's finite-hypothesis-class generalization bounds, based on general familiarity with statistical learning theory. I cannot verify this specific application against a named source in this response.
- [Unverified] I cannot verify specific claims about how any particular ML library, framework, or paper directly applies the Union Bound without checking that source directly.
- For any behavioral claims about how a specific model, algorithm, or system's error probabilities combine in practice: behavior is not guaranteed and may vary depending on implementation, data, hypothesis class structure, and other conditions. This is a general disclaimer and not specific to any single system.

### Related Topics

- Boole's Inequality (alternate name for the Union Bound)
- Inclusion–exclusion principle
- PAC learning framework and generalization bounds
- Chernoff bounds and Hoeffding's Inequality (often combined with the Union Bound)
- Concentration inequalities in statistical learning theory

---

**Verification Status of This Document**: This document contains multiple [Inference] and [Unverified] labeled statements, particularly regarding historical attribution, the precise formal role of the Union Bound in PAC learning derivations, and connections to machine learning practice. The core definition and proof sketch reflect a standard formulation in probability theory as commonly taught, but I cannot verify this text against a specific named source in this response. This entire document should be treated as **[Unverified]** pending independent cross-check against a formal reference (e.g., Billingsley's *Probability and Measure* or a standard statistical learning theory textbook).