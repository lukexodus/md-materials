## (p→q) ^ (p→r) ≡ p→(qvr)

**Breakdown:**
- $p \rightarrow q$ means "If $p$ is true, then $q$ is true."
- $p \rightarrow r$ means "If $p$ is true, then $r$ is true."
- The expression on the left-hand side, $(p \rightarrow q) \land (p \rightarrow r)$, says "If $p$ is true, then both $q$ and $r$ must be true."
- The right-hand side, $p \rightarrow (q \lor r)$, means "If $p$ is true, then either $q$ or $r$ (or both) is true."

**Truth Table for $(p \rightarrow q) \land (p \rightarrow r) \equiv p \rightarrow (q \lor r)$:**

| $p$ | $q$ | $r$ | $p \rightarrow q$ | $p \rightarrow r$ | $(p \rightarrow q) \land (p \rightarrow r)$ | $q \lor r$ | $p \rightarrow (q \lor r)$ |
|:---:|:---:|:---:|:-----------------:|:-----------------:|:--------------------------------------------:|:----------:|:--------------------------:|
|  T  |  T  |  T  |         T         |         T         |                     T                      |     T      |            T               |
|  T  |  T  |  F  |         T         |         F         |                     F                      |     T      |            T               |
|  T  |  F  |  T  |         F         |         T         |                     F                      |     T      |            T               |
|  T  |  F  |  F  |         F         |         F         |                     F                      |     F      |            F               |
|  F  |  T  |  T  |         T         |         T         |                     T                      |     T      |            T               |
|  F  |  T  |  F  |         T         |         T         |                     T                      |     T      |            T               |
|  F  |  F  |  T  |         T         |         T         |                     T                      |     T      |            T               |
|  F  |  F  |  F  |         T         |         T         |                     T                      |     F      |            T               |

Both sides of the table are identical, so:

**Conclusion:**
$$(p \rightarrow q) \land (p \rightarrow r) \equiv p \rightarrow (q \lor r)$$ is **true**.

***
## (p→r) ^ (q→r) ≡ (pvq) →r

Let's break it down step by step.

### Left-hand side: $(p \rightarrow r) \land (q \rightarrow r)$
(p \rightarrow r) \land (q \rightarrow r)$
- $p \rightarrow r$ means "If $p$ is true, then $r$ is true."
- $q \rightarrow r$ means "If $q$ is true, then $r$ is true."
- So, the left-hand side states that **both** of these implications must be true. In other words, whether $p$ or $q$ is true, $r$ must hold.

### Right-hand side: $(p \lor q) \rightarrow r$
- $p \lor q$ means "Either $p$ is true or $q$ is true (or both)."
- The implication $(p \lor q) \rightarrow r$ means "If either $p$ or $q$ (or both) is true, then $r$ must be true."

### Let's create a truth table to compare both sides:

| $p$ | $q$ | $r$ | $p \rightarrow r$ | $q \rightarrow r$ | $(p \rightarrow r) \land (q \rightarrow r)$ | $p \lor q$ | $(p \lor q) \rightarrow r$ |
| :-: | :-: | :-: | :---------------: | :---------------: | :-----------------------------------------: | :--------: | :------------------------: |
|  T  |  T  |  T  |         T         |         T         |                      T                      |     T      |             T              |
|  T  |  T  |  F  |         F         |         F         |                      F                      |     T      |             F              |
|  T  |  F  |  T  |         T         |         T         |                      T                      |     T      |             T              |
|  T  |  F  |  F  |         F         |         T         |                      F                      |     T      |             F              |
|  F  |  T  |  T  |         T         |         T         |                      T                      |     T      |             T              |
|  F  |  T  |  F  |         T         |         F         |                      F                      |     T      |             F              |
|  F  |  F  |  T  |         T         |         T         |                      T                      |     F      |             T              |
|  F  |  F  |  F  |         T         |         T         |                      T                      |     F      |             T              |

### Analysis:
- The two columns $(p \rightarrow r) \land (q \rightarrow r)$ and $(p \lor q) \rightarrow r$ match perfectly in all rows of the truth table.
- Therefore, the two sides are logically equivalent.

### Conclusion:
$$(p \rightarrow r) \land (q \rightarrow r) \equiv (p \lor q) \rightarrow r$$

**This statement is true.**


***

## p^q ≡ ~(q→~p)

#### Left-hand side: $p \land q$
- $p \land q$ means **"both $p$ and $q$ must be true."**

#### Right-hand side: $\sim (q \rightarrow \sim p)$
- $q \rightarrow \sim p$ means "If $q$ is true, then $p$ is false" (since $\sim p$ is the negation of $p$).
- The negation $\sim (q \rightarrow \sim p)$ means **"It is not true that if $q$ is true, then $p$ is false."**
- This is logically equivalent to saying **"$p$ is true and $q$ is true,"** because the only way $q \rightarrow \sim p$ is false is when $q$ is true and $p$ is also true.

#### Truth Table:
| $p$ | $q$ | $p \land q$ | $q \rightarrow \sim p$ | $\sim (q \rightarrow \sim p)$ |
|:---:|:---:|:-----------:|:----------------------:|:-----------------------------:|
|  T  |  T  |      T      |            F           |               T               |
|  T  |  F  |      F      |            T           |               F               |
|  F  |  T  |      F      |            T           |               F               |
|  F  |  F  |      F      |            T           |               F               |

Both $p \land q$ and $\sim (q \rightarrow \sim p)$ have the same truth values, so:

**Conclusion:** 
$$(p \land q) \equiv \sim (q \rightarrow \sim p)$$ is **true**.

---

## ~(p→q) ≡ p^~q

#### Left-hand side: $\sim (p \rightarrow q)$
- $p \rightarrow q$ means **"If $p$ is true, then $q$ must also be true."**
- The negation $\sim (p \rightarrow q)$ means **"It is not true that if $p$ is true, then $q$ must be true."**
- This is only true when $p$ is true and $q$ is false (i.e., $p$ holds, but $q$ does not).

#### Right-hand side: $p \land \sim q$
- $p \land \sim q$ means **"$p$ is true and $q$ is false."**

#### Truth Table:
| $p$ | $q$ | $p \rightarrow q$ | $\sim (p \rightarrow q)$ | $p \land \sim q$ |
|:---:|:---:|:-----------------:|:-----------------------:|:---------------:|
|  T  |  T  |         T         |            F            |        F        |
|  T  |  F  |         F         |            T            |        T        |
|  F  |  T  |         T         |            F            |        F        |
|  F  |  F  |         T         |            F            |        F        |

Both $\sim (p \rightarrow q)$ and $p \land \sim q$ have the same truth values, so:

**Conclusion:**
$$\sim (p \rightarrow q) \equiv p \land \sim q$$ is **true**.

### Final Answer:
Both statements are logically **true**:
1. $p \land q \equiv \sim (q \rightarrow \sim p)$
2. $\sim (p \rightarrow q) \equiv p \land \sim q$

