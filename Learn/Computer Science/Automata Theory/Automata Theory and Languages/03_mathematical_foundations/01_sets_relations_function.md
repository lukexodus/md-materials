## Sets, Relations, Function

### **1. Sets: Collections of Things**

**What is a set?**
A set is just a collection of objects. We write sets using curly braces:
- $\{1, 2, 3\}$ is a set containing three numbers
- $\{a, b, c\}$ is a set containing three letters
- $\{\text{apple}, \text{banana}\}$ is a set of fruits

**Key idea:** Either something is in the set (we write $x \in A$) or it's not (we write $x \notin A$).

**Examples:**
- Let $A = \{2, 4, 6, 8\}$. Then $4 \in A$ but $5 \notin A$.
- The *empty set* $\emptyset = \{\}$ contains nothing.

**Set operations:**
- **Union** $A \cup B$: everything in $A$ *or* $B$ (or both)
  - $\{1,2\} \cup \{2,3\} = \{1,2,3\}$
- **Intersection** $A \cap B$: everything in *both* $A$ and $B$
  - $\{1,2\} \cap \{2,3\} = \{2\}$
- **Complement** $\overline{A}$: everything *not* in $A$
  - If our universe is $\{1,2,3,4,5\}$ and $A = \{1,2\}$, then $\overline{A} = \{3,4,5\}$
- **Difference** $A \setminus B$: things in $A$ but not in $B$
  - $\{1,2,3\} \setminus \{2,4\} = \{1,3\}$

---

### **2. Relations: Connections Between Things**

**What is a relation?**
A relation describes how things are connected. The simplest is a *binary relation* connecting pairs.

**Examples:**
- "is less than" on numbers: $2 < 5$, $3 < 4$
- "is a parent of" on people
- "is connected to" on cities

**Formal definition:**
A binary relation $R$ on sets $A$ and $B$ is just a set of pairs:
$$R \subseteq A \times B$$

where $A \times B = \{(a,b) : a \in A, b \in B\}$ (the *Cartesian product*).

**Example:**
Let $A = \{1,2,3\}$ and $B = \{a,b\}$.
- $A \times B = \{(1,a), (1,b), (2,a), (2,b), (3,a), (3,b)\}$
- A relation might be $R = \{(1,a), (2,b)\}$

**Special types of relations:**

An **equivalence relation** satisfies three properties:
1. **Reflexive:** $x \sim x$ (everything relates to itself)
2. **Symmetric:** if $x \sim y$ then $y \sim x$
3. **Transitive:** if $x \sim y$ and $y \sim z$ then $x \sim z$

**Example:** "has the same birthday as" is an equivalence relation on people.

---

### **3. Functions: Special Relations**

**What is a function?**
A function $f: A \to B$ assigns to each element of $A$ exactly one element of $B$.

**Example:**
- $f(x) = 2x$ assigns to each number its double
- $f(1) = 2$, $f(2) = 4$, $f(3) = 6$

**Key difference from relations:**
- A relation can connect one input to many outputs: $\{(1,a), (1,b)\}$
- A function connects each input to *exactly one* output

**Partial vs. total functions:**
- **Total function:** defined for *every* input in $A$
  - $f(x) = x + 1$ is total on all numbers
- **Partial function:** defined for *some* inputs
  - $g(x) = \frac{1}{x}$ is undefined at $x = 0$

**Example of partial function:**
A program that tries to find a solution:
```
find_solution(problem):
    search for solution
    if found: return solution
    if not found: keep searching forever (never returns)
```
This is partial because it doesn't return an answer for every input.

---

### **4. Alphabets, Strings, and Languages**

**Alphabet:** A finite set of symbols.
- $\Sigma = \{0, 1\}$ (binary alphabet)
- $\Sigma = \{a, b, c, \ldots, z\}$ (English letters)

**String (word):** A sequence of symbols from the alphabet.
- Over $\{0,1\}$: "0", "101", "1111", ""
- The empty string is written $\varepsilon$ or $\lambda$

**$\Sigma^*$:** The set of *all possible strings* over alphabet $\Sigma$.
- $\{0,1\}^* = \{\varepsilon, 0, 1, 00, 01, 10, 11, 000, \ldots\}$

**Language:** A set of strings. Just a subset $L \subseteq \Sigma^*$.

**Examples:**
- $L_1 = \{\text{all strings with even length}\}$
- $L_2 = \{\text{all strings starting with } 0\}$
- $L_3 = \{0^n 1^n : n \geq 0\} = \{\varepsilon, 01, 0011, 000111, \ldots\}$

---

### **5. Decision Problems**

**What is a decision problem?**
A yes/no question about strings.

**Examples:**
- "Does this string have even length?" 
- "Does this string contain the substring '101'?"
- "Is this string a palindrome?"

**Characteristic function:**
For a language $L$, the characteristic function is:
$$\chi_L(x) = \begin{cases} 1 & \text{if } x \in L \\ 0 & \text{if } x \notin L \end{cases}$$

This turns set membership into a function that outputs 0 or 1.

---

### **6. Computability: What Can Algorithms Solve?**

**Computable/decidable:**
A problem is *decidable* if there exists an algorithm that always halts and correctly answers yes/no.

**Example (decidable):**
"Is this number even?"
```
is_even(n):
    if n % 2 == 0:
        return YES
    else:
        return NO
```
This always terminates with the right answer.

**Example (undecidable):**
The *halting problem*: "Does this program halt on this input?"

[Unverified claim about fundamental result]:
There is no algorithm that can solve the halting problem for all programs. This was proven by Alan Turing in 1936.

**Why it matters:** Some problems have no algorithmic solution, no matter how clever we are.

---

### **7. Recursively Enumerable Sets**

**Semi-decidable (r.e. = recursively enumerable):**
A set $A$ is r.e. if there's an algorithm that:
- Says YES if $x \in A$ (eventually)
- Might run forever if $x \notin A$ (never answers NO)

**Example:**
The halting problem is r.e.:
```
halts(program, input):
    run program on input
    if it halts:
        return YES
    else:
        keep running forever (never return NO)
```

**Why "enumerable"?**
[Inference]: R.e. sets can be listed by a program: it can print all members one by one, though it might take forever to print them all.

**Relationship:**
- Decidable = r.e. AND co-r.e. (both the set and its complement are r.e.)
- Many sets are r.e. but not decidable

---

### **8. What You Need to Understand the Next Section**

Now you have the building blocks:

1. **Sets, operations, universes** → What we're studying
2. **Relations and equivalences** → How things connect
3. **Functions (total/partial)** → Computations and algorithms
4. **Strings and languages** → Problems encoded as sets of strings
5. **Decision problems** → Yes/no questions
6. **Computability** → What algorithms can/cannot solve
7. **R.e. vs decidable** → Degrees of solvability

### Sets

**Set-theoretic universe and encoding.**
Assume a fixed universe $U$, typically $\Sigma^*$ for a finite alphabet $\Sigma$, or $\mathbb{N}$ under Gödel encodings. Languages are identified with subsets of $\Sigma^*$. Decision problems correspond to characteristic functions $\chi_L : \Sigma^* \to {0,1}$.

**Effective sets.**
A set $A \subseteq \mathbb{N}$ is:

* *Decidable (recursive)* iff $\chi_A$ is total computable.
* *Recursively enumerable (r.e.)* iff $A = \mathrm{dom}(f)$ for some partial computable function $f$, equivalently iff $A$ is accepted by a Turing machine.
* *Co-r.e.* iff $\overline{A}$ is r.e.

These induce strict inclusions:

$$
\mathrm{REC} \subsetneq \mathrm{RE} \cap \mathrm{coRE} = \mathrm{REC},
\qquad
\mathrm{RE} \subsetneq \mathcal{P}(\mathbb{N})
$$

**Set operations and computability.**
For r.e. sets $A,B$:

* $A \cup B$ and $A \cap B$ are r.e.
* $\overline{A}$ need not be r.e.
* $A \setminus B$ is r.e. iff $B$ is decidable.

These properties lift directly to language classes via automata-theoretic closure results.

---

### Relations

**$k$-ary relations.**
A relation $R \subseteq U^k$ is represented via effective tuple encodings $\langle x_1,\dots,x_k\rangle \in \Sigma^*$ or as a language over a product alphabet $\Sigma^k$.

**Decidable and enumerable relations.**

* $R$ is *decidable* iff its characteristic predicate is computable.
* $R$ is *recursively enumerable* iff membership is semi-decidable.

Canonical example:

$$
\mathrm{HALT} = { \langle M,w\rangle \mid M \text{ halts on } w }
$$

$\mathrm{HALT}$ is $\mathrm{r.e.}$-complete under many-one reductions.

**Equivalence relations and congruences.**

An equivalence relation $\equiv ;\subseteq \Sigma^* \times \Sigma^*$ is *right-invariant* iff

$$
x \equiv y ;\Rightarrow; xz \equiv yz \quad \forall z \in \Sigma^*
$$

The Myhill–Nerode relation associated with a language $L$ is defined by

$$
x \equiv_L y ;\iff; \forall z \in \Sigma^* ; (xz \in L \leftrightarrow yz \in L)
$$

$L$ is regular iff $\equiv_L$ has finite index.

**Relations recognized by automata.**

* Binary relations recognized by finite automata correspond to *rational relations*.
* Rational relations are closed under union, composition, and Kleene star, but not under complement.
* Synchronous rational relations correspond exactly to regular languages over paired alphabets.

**Logical characterizations.**

* First-order definable relations over words correspond to star-free languages.
* MSO-definable relations coincide with regular relations.

---

### Functions

**Total and partial functions.**
A function $f : U \to V$ may be partial. In computability theory:

* *Computable functions* are partial recursive functions.
* *Total computable functions* correspond to algorithms halting on all inputs.

**Characteristic and enumeration functions.**

* A set $A$ is r.e. iff there exists a total computable function $f$ enumerating $A$.
* $A$ is decidable iff both $A$ and $\overline{A}$ are enumerable.

**Reductions.**

* *Many-one reduction:*
  $A \leq_m B$ iff there exists a total computable function $f$ such that
  $$
  x \in A \iff f(x) \in B
  $$
* *Turing reduction:*
  $A \leq_T B$ iff $A$ is decidable by an oracle Turing machine with oracle $B$.

Completeness and hardness results for decision problems are defined relative to these reducibilities.

**Automaton-computable functions.**

* Deterministic finite-state transducers compute exactly the class of *regular functions*.
* Regular functions are closed under composition but not under inverse.
* MSO-definable string-to-string functions coincide with streaming transducer realizability.

**Functional relations.**
A relation $R \subseteq U \times V$ is functional iff

$$
\forall x \in U ; \exists \leq 1 y \in V ; (x,y) \in R
$$

Deciding functionality is undecidable for general r.e. relations and undecidable for Turing-recognizable relations under standard encodings.

---

### Algebraic and Structural Properties

**Lattices and Boolean structure.**

* Regular languages form a Boolean algebra under union, intersection, and complement.
* r.e. sets form a join-semilattice under union, lacking complements and finite meets.

**Fixed-point constructions.**

* Inductively defined relations arise as least fixed points of monotone operators on $\mathcal{P}(U^k)$.
* Central to semantics of recursive grammars, operational semantics, and verification logics.

**Categorical perspective.**

* Sets and total functions form the category $\mathbf{Set}$.
* Partial computable functions induce categories of partial maps.
* Automata induce morphisms in Kleisli categories of suitable monads.

---

### Undecidability and Limits

* Equality of r.e. sets is undecidable.
* Equivalence of partial computable functions is undecidable.
* Deciding whether an r.e. relation is decidable is undecidable.
* Rice’s theorem: every nontrivial semantic property of computable functions is undecidable.

---

### Related Topics

* Gödel numbering
* Myhill–Nerode relations
* Rational relations
* MSO logic on words
* Partial recursive functions
* Enumeration operators
* Fixed-point logics
* Type-theoretic semantics

---


