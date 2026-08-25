## Non-context-free Languages


### Definition via Separation

A language $L \subseteq \Sigma^*$ is **non-context-free** if there exists no context-free grammar $G$ such that
$$
L = L(G)
$$
Equivalently,
$$
L \notin \mathsf{CFL}
$$
where $\mathsf{CFL}$ denotes the class of languages recognized by nondeterministic pushdown automata.

Non-context-freeness is established exclusively via impossibility arguments, typically by contradiction using closure properties, pumping-style lemmas, or reductions from known non-CFLs.

---

### Canonical Non-CFL Examples

#### Multiple Equality Constraints

$$
L_1 = { a^n b^n c^n \mid n \ge 0 }
$$
Requires simultaneous equality of three counters, exceeding single-stack power.

#### Copy Languages

$$
L_2 = { ww \mid w \in {0,1}^* }
$$

#### Cross-serial Dependencies

$$
L_3 = { a^i b^j c^i d^j \mid i,j \ge 0 }
$$

#### Prime-Length Languages

$$
L_4 = { a^p \mid p \text{ prime} }
$$

---

### Pumping Lemma for CFLs

For every $L \in \mathsf{CFL}$, there exists $p \in \mathbb{N}$ such that any $w \in L$ with $|w| \ge p$ admits a decomposition
$$
w = uvxyz
$$
satisfying:
$$
|vxy| \le p \quad \land \quad |vy| \ge 1 \quad \land \quad \forall k \ge 0 : uv^k x y^k z \in L
$$

#### Non-CFL Proof Pattern

Assume $L \in \mathsf{CFL}$, choose a structured $w$, and show that all valid decompositions violate language constraints under pumping.

For $L_1 = { a^n b^n c^n }$, any pumping disrupts at least one equality invariant.

---

### Ogden’s Lemma

A strengthening of the pumping lemma: mark positions in $w$ to force pumping regions to intersect them.

For every CFL $L$, there exists $p$ such that for any $w \in L$ with at least $p$ marked positions,
$$
w = uvxyz
$$
where $v,y$ contain marked positions and pumping preserves membership.

Ogden’s lemma proves non-context-freeness of languages where the standard pumping lemma is insufficient.

---

### Closure Property Separations

CFLs are **not** closed under:

* Intersection
* Complement
* Set difference

#### Intersection Argument

Let
$$
L_a = { a^i b^i c^j \mid i,j \ge 0 }, \quad
L_b = { a^j b^i c^i \mid i,j \ge 0 }
$$
Both are context-free, but
$$
L_a \cap L_b = { a^n b^n c^n \mid n \ge 0 }
$$
is not.

---

### Homomorphic Images and Inverse Homomorphisms

CFLs are closed under homomorphism and inverse homomorphism.

To prove $L$ non-CFL, it suffices to show that there exists a homomorphism $h$ such that
$$
h^{-1}(L)
$$
or
$$
h(L)
$$
equals a known non-CFL.

---

### Reduction-Based Proofs

If $L_0$ is non-CFL and
$$
L_0 \le_m L
$$
via a homomorphism or rational transduction preserving context-freeness, then $L$ is non-CFL.

Rational transductions preserve CFLs; hence inverse images of non-CFLs remain non-CFL.

---

### PDA-Based Limitations

NPDAs possess a single unbounded stack. Any language requiring:

* Two independent unbounded counters
* Equality across three or more segments
* Unbounded copying

is not recognizable by an NPDA.

Formal invariant: stack height at position $i$ determines all future matching capability. Multiple independent dependencies cannot be encoded.

---

### Parikh Image and Semilinearity

Parikh’s theorem: for any CFL $L \subseteq \Sigma^*$, the Parikh image
$$
\Psi(L) \subseteq \mathbb{N}^{|\Sigma|}
$$
is semilinear.

If $\Psi(L)$ is not semilinear, then $L \notin \mathsf{CFL}$.

Example:
$$
\Psi({ a^n b^n c^n }) = { (n,n,n) \mid n \ge 0 }
$$
is not semilinear.

---

### Ambiguity vs Non-CFL

Ambiguity is orthogonal to non-context-freeness.

There exist:

* Unambiguous CFLs
* Ambiguous CFLs
* Inherently ambiguous CFLs

Non-CFLs admit no CFG at all.

---

### Complexity-Theoretic View

Membership:
$$
L \in \mathsf{CFL} \Rightarrow \mathsf{MEMB}(L) \in \mathsf{P}
$$

Many non-CFLs have membership problems in $\mathsf{P}$, $\mathsf{NP}$, or undecidable, independent of generability.

Example:
$$
\mathsf{MEMB}({ ww }) \in \mathsf{P}
$$
yet ${ ww } \notin \mathsf{CFL}$.

---

### Logical Characterization

CFLs correspond to existential second-order logic with a single binary relation encoding a tree:
$$
\mathsf{CFL} = \mathsf{ESO}[<]
$$

Languages requiring simultaneous second-order dependencies across multiple spans exceed this fragment.

---

### Hierarchy Separations

$$
\mathsf{REG} \subsetneq \mathsf{DCFL} \subsetneq \mathsf{CFL} \subsetneq \mathsf{CSL}
$$

Non-CFLs may still be context-sensitive or recursively enumerable.

---

### Related Topics

* Pumping lemma for CFLs
* Ogden’s lemma
* Parikh images
* Context-sensitive languages
* Multiple-stack automata
* Linear bounded automata
* Tree-adjoining grammars
* Mildly context-sensitive languages

---

