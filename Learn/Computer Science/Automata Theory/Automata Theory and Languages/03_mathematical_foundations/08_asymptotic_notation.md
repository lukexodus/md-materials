## Asymptotic Notation


### Mathematical Formulation

For functions $f,g:\mathbb{N}\to\mathbb{R}_{\ge 0}$, asymptotic notation characterizes growth rates as $n\to\infty$.

**Big-O**
Asymptotic upper bound, defining a preorder.
$$
f(n)=O(g(n)) \iff \exists c>0,\exists n_0,\forall n\ge n_0,; f(n)\le c\cdot g(n)
$$

**Big-Ω**
Asymptotic lower bound.
$$
f(n)=\Omega(g(n)) \iff \exists c>0,\exists n_0,\forall n\ge n_0,; f(n)\ge c\cdot g(n)
$$

**Big-Θ**
Asymptotic tight bound, inducing an equivalence relation.
$$
f(n)=\Theta(g(n)) \iff f(n)=O(g(n))\land f(n)=\Omega(g(n))
$$

**little-o**
Strictly smaller growth rate.
$$
f(n)=o(g(n)) \iff \forall c>0,\exists n_0,\forall n\ge n_0,; f(n)<c\cdot g(n)
$$

**little-ω**
Strictly larger growth rate.
$$
f(n)=\omega(g(n)) \iff g(n)=o(f(n))
$$

Intuitively, $O$ and $\Omega$ describe bounding envelopes, $\Theta$ captures scale equivalence, and $o$ and $\omega$ formalize strict separation of growth rates.

### Role in Computation

* Complexity classes classify languages $L\subseteq\Sigma^*$ via time or space bounds expressed using $O$ and $\Theta$.
* State complexity of automaton transformations is characterized by bounds such as $2^{\Theta(n)}$ or $\Theta(n^k)$.
* Hierarchy theorems and separation results rely on $o$ and $\omega$ to formalize asymptotic resource gaps.

### Fundamental Growth Chain

$$
\log n = o(n^\epsilon)\quad \forall \epsilon>0
$$
$$
n^k = o(c^n)\quad \forall k\in\mathbb{N},\forall c>1
$$

These relations underlie resource hierarchies spanning regular languages, context-free languages, and general computable languages.

### Related Topics

* Time complexity classes
* Space complexity classes
* Hierarchy theorems
* State complexity
* Descriptive complexity


---


