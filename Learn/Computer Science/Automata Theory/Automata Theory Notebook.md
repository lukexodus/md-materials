## Gödel Encodings in Automata Theory

Gödel encoding (also called Gödel numbering) is a technique that assigns unique natural numbers to symbolic expressions, allowing formal systems to be studied mathematically. In automata theory, this concept is used to encode machines, strings, and computations as numbers.

### Basic Concept

The fundamental idea is to map discrete objects (like symbols, strings, or machine descriptions) to natural numbers in a way that:
- Each object gets a unique number
- The encoding is effectively computable
- We can decode numbers back to their original objects

### Common Encodings in Automata Theory

**String Encoding**
For an alphabet Σ = {a₁, a₂, ..., aₖ}, we can encode strings as numbers. For example, if Σ = {0, 1}:
- We might encode string w = 101 as the binary number 101₂ = 5
- Or use a scheme where each symbol gets a prime: 0→2, 1→3, then 101 → 3·2·3 = 18

**Turing Machine Encoding**
A Turing machine M = (Q, Σ, Γ, δ, q₀, qaccept, qreject) can be encoded by:
1. Numbering states, symbols, and transitions
2. Representing the transition function δ as a sequence of tuples
3. Converting this representation to a single natural number

### Applications

**Diagonalization Arguments**
Gödel encodings enable proofs like showing the undecidability of the halting problem. We can enumerate all Turing machines as ⟨M₁⟩, ⟨M₂⟩, ... and construct a machine that differs from each Mᵢ on input i.

**Universal Turing Machines**
A universal Turing machine U takes as input ⟨M⟩ (the encoding of machine M) and w (an input string), then simulates M on w.

**Complexity Theory**
Encodings allow us to treat decision problems about machines (like "Does M halt on empty input?") as languages over {0,1}*.

The key insight is that Gödel encodings transform questions about computational objects into questions about numbers, enabling mathematical analysis of computation itself.

---

## Turing Machines

A Turing machine is a theoretical computational model that defines an abstract machine capable of performing any computation that can be algorithmically described. It was introduced by Alan Turing in 1936.

### Formal Definition

A Turing machine is a 7-tuple: **M = (Q, Σ, Γ, δ, q₀, qaccept, qreject)** where:

- **Q** = finite set of states
- **Σ** = input alphabet (not containing the blank symbol ␣)
- **Γ** = tape alphabet, where ␣ ∈ Γ and Σ ⊆ Γ
- **δ: Q × Γ → Q × Γ × {L, R}** = transition function
- **q₀ ∈ Q** = start state
- **qaccept ∈ Q** = accept state
- **qreject ∈ Q** = reject state (qreject ≠ qaccept)

### Components

**The Tape**
- An infinite one-dimensional tape divided into cells
- Each cell contains a symbol from Γ
- Initially contains the input string, with blank symbols (␣) filling the rest

**The Head**
- Reads and writes symbols on the tape
- Can move left (L) or right (R) one cell at a time

**The Control**
- In one state from Q at any time
- Uses δ to determine the next action based on current state and symbol under the head

### How It Works

In each step, based on the current state q and the symbol a being read:
1. Write a new symbol b to the current cell
2. Move the head left or right
3. Transition to a new state q'

Formally: δ(q, a) = (q', b, D) means "in state q reading a, write b, move in direction D, go to state q'"

### Computation

A Turing machine **accepts** an input string w if:
- Starting in q₀ with w on the tape
- It eventually enters qaccept

A Turing machine **rejects** w if it enters qreject, or if it runs forever without accepting (for some definitions).

### Example

Here's a simple Turing machine that accepts strings of the form 0ⁿ1ⁿ:

1. Scan right, marking each 0 with X
2. Find the corresponding 1 and mark it with Y
3. Return left to find the next unmarked 0
4. Accept if all 0s and 1s are matched

### Variants

**Multi-tape Turing Machines**
- Multiple tapes with independent heads
- More convenient for design, but equivalent in power to single-tape machines

**Nondeterministic Turing Machines**
- δ can specify multiple possible transitions
- Machine "branches" into multiple computation paths
- Accepts if any path reaches qaccept

**Enumerators**
- Output strings rather than accept/reject
- Useful for defining recognizable languages

### Church-Turing Thesis

The Church-Turing thesis states that any effectively computable function can be computed by a Turing machine. This makes Turing machines the standard model for what is computable.

### Language Classes

- **Recognizable (Recursively Enumerable)**: Languages for which a TM accepts all strings in the language (may loop on strings not in the language)
- **Decidable (Recursive)**: Languages for which a TM halts and accepts/rejects correctly on all inputs

### Significance

Turing machines are used to:
- Define what problems are computable
- Prove undecidability results (e.g., the halting problem)
- Establish computational complexity classes (P, NP, etc.)
- Serve as a theoretical foundation for modern computers

Despite their simplicity, Turing machines can simulate any real-world computer algorithm, making them a powerful theoretical tool for understanding the limits and capabilities of computation.