## Turing-computable functions


### Formal model and function semantics

A deterministic single-tape Turing machine is a tuple  
$M = \langle Q , \Sigma , \Gamma , \delta , q_0 , q_{acc} , q_{rej} \rangle$  
with $Q$ finite, $\Sigma \subseteq \Gamma \setminus { \sqcup }$, and partial transition function  
$\delta : Q \times \Gamma \to Q \times \Gamma \times { L , R }$.

A **partial function** $f : \Sigma^* \rightharpoonup \Sigma^*$ is **Turing-computable** if there exists a Turing machine $M$ such that for every $w \in \Sigma^*$:
- if $f w$ is defined, then $M$ halts in $q_{acc}$ with $f w$ written on the tape
- if $f w$ is undefined, then $M$ does not halt
    

A **total function** is Turing-computable if the corresponding machine halts on all inputs. The distinction between partial and total computability is essential and mirrors the distinction between recursively enumerable and recursive sets.

Analogy: the machine is a mechanical clerk following an instruction book. A partial function corresponds to a clerk who may work forever on some requests, while a total function corresponds to one who always eventually finishes.

### Encodings and invariance

Computability is invariant under choice of encoding. For any reasonable Gödel numbering  
$\langle \cdot \rangle : \Sigma^* \to \mathbb{N}$, a function $f : \mathbb{N} \rightharpoonup \mathbb{N}$ is computable iff the induced string function $\hat f$ is computable.

This invariance under effective encodings yields the **Church–Turing thesis**, asserting that all effectively calculable functions are Turing-computable. This is a thesis rather than a theorem.

### Relationship to language recognition

For a set $A \subseteq \Sigma^*$, define the characteristic function  
$\chi_A : \Sigma^* \to { 0 , 1 }$.

Then:
- $A$ is recursive iff $\chi_A$ is total Turing-computable
- $A$ is recursively enumerable iff $\chi_A$ is partial Turing-computable
    

Thus function computation strictly refines language acceptance by separating halting behavior from output production.

### Normal forms for computable functions

Every Turing-computable function admits the following normal representations.

**Kleene normal form**

There exists a primitive recursive predicate $T$ and primitive recursive function $U$ such that

$$  
f x = U \mu y . T x y  
$$

Here $\mu$ denotes unbounded minimization. This characterizes partial recursive functions.

**Register machine normal form**

Every computable function is computable by a register machine using only increment, decrement with zero test, and conditional jumps.

**Single-tape normal form**

Every multi-tape or nondeterministic machine computing $f$ can be transformed into a deterministic single-tape machine computing the same function, with at most quadratic time overhead.

Analogy: different normal forms are like different assembly languages for the same processor class, varying in convenience but not power.

### Algebraic structure and closure properties

The class of partial computable functions is the smallest class containing the initial functions and closed under:
- composition
- primitive recursion
- unbounded minimization
    

Total computable functions are closed under:
- composition
- primitive recursion
- bounded minimization
    

They are not closed under unbounded minimization.

### Universal computation

There exists a universal partial computable function  
$U : \Sigma^* \times \Sigma^* \rightharpoonup \Sigma^*$  
such that for every computable function $f$ there exists $e$ with

$$  
f x = U e x  
$$

This implies the existence of a **universal Turing machine** and underlies self-reference and diagonalization arguments.

### Undecidability phenomena

Let $\varphi_e$ denote the partial computable function computed by machine index $e$.

**Halting problem**

The set

$$  
H = { \langle e , x \rangle \mid \varphi_e x \text{ halts} }  
$$

is not recursive. Consequently, there is no total computable function deciding whether a given partial computable function is defined on a given input.

**Rice theorem**

For any nontrivial property $P$ of partial computable functions, the set

$$  
{ e \mid \varphi_e \text{ has property } P }  
$$

is undecidable.

Analogy: asking semantic questions about arbitrary programs is like trying to predict the long-term behavior of any mechanical process from its blueprint alone.

### Reductions and completeness

Many undecidable problems are shown undecidable via many-one reductions from the halting problem. A function $f$ is computable iff there exists a computable reduction from its graph to $H$.

The halting problem is complete for recursively enumerable sets under computable reductions.

### Time and space complexity of function computation

A function $f$ is computable in time $t n$ if there exists a Turing machine computing $f$ whose running time on input $x$ is bounded by $t |x|$.

Function computation induces complexity classes such as:
- $\mathrm{FP}$ total functions computable in polynomial time
- $\mathrm{FEXP}$ total functions computable in exponential time
    

These are function analogues of decision classes and are central in complexity-theoretic reductions.

### Expressive power comparisons

Turing-computable functions coincide with:
- partial recursive functions
- $\lambda$-definable functions
- functions computable by register machines
- functions definable in first-order arithmetic with $\mu$-operator
    

Each equivalence is provable via explicit simulations.

### Fixed points and self-reference

For every total computable function $f : \Sigma^* \to \Sigma^*$ there exists $e$ such that

$$  
\varphi_e = \varphi_{f e}  
$$

This is the **Kleene recursion theorem** and enables self-reproducing and self-modifying computations.

Analogy: a program that can obtain and manipulate its own blueprint, much like a biological organism copying its DNA.

### Connections to logic and verification

Turing-computable functions correspond to $\Sigma_1$-definable functions in first-order arithmetic.

Undecidability of semantic properties of computable functions forms the theoretical basis for impossibility results in program verification, including full functional correctness and termination analysis.

### Related topics

Partial recursive functions  
$\lambda$-calculus  
Register machines  
Recursion theorem  
Halting problem  
Rice theorem  
Computable reductions  
Function complexity classes

---

