## Boolean Algebra and Logic Gates

### Overview

Boolean algebra provides the mathematical foundation for digital logic design, describing how binary variables (which can take only the values 0 and 1, or equivalently false and true) combine through logical operations. Logic gates are the physical (or, in a simulation context, conceptual) hardware implementations of these Boolean operations, and every digital circuit inside a microcontroller — from a simple AND gate to a complete arithmetic logic unit (ALU) — is ultimately built from combinations of a small set of basic gates. Understanding Boolean algebra allows embedded engineers to reason about, simplify, and design the logic that governs both custom digital hardware and the bitwise operations used constantly in firmware.

### Boolean Values and Variables

A Boolean variable can hold exactly one of two values, most commonly denoted:
- **1 / True / High**
- **0 / False / Low**

In digital electronics, these values correspond to distinguishable voltage levels (e.g., near supply voltage for 1, near ground for 0), though the exact voltage thresholds depend on the specific logic family and are not part of Boolean algebra itself — Boolean algebra operates on the abstract 0/1 values, independent of the electrical implementation.

### Basic Boolean Operations

**AND**

The AND operation, written $A \cdot B$ or $A \land B$, produces 1 only when both inputs are 1. It models the idea of "both conditions must hold."

**OR**

The OR operation, written $A + B$ or $A \lor B$, produces 1 when at least one input is 1. It models "at least one condition holds."

**NOT**

The NOT operation, written $\overline{A}$ or $\lnot A$, inverts a single input: 1 becomes 0, and 0 becomes 1. It is the only standard unary (single-input) Boolean operation among the basic set.

**Truth Tables for Basic Operations**

| A | B | A AND B | A OR B |
|---|---|---|---|
| 0 | 0 | 0 | 0 |
| 0 | 1 | 0 | 1 |
| 1 | 0 | 0 | 1 |
| 1 | 1 | 1 | 1 |

| A | NOT A |
|---|---|
| 0 | 1 |
| 1 | 0 |

### Derived Operations

**NAND (NOT AND)**

Produces the inverse of AND: 0 only when both inputs are 1, otherwise 1. NAND is notable because any Boolean function can be built using NAND gates alone, making it a **functionally complete** operation — a property exploited heavily in chip manufacturing, since fabricating a single gate type repeatedly can simplify production.

**NOR (NOT OR)**

Produces the inverse of OR: 1 only when both inputs are 0, otherwise 0. Like NAND, NOR is also functionally complete on its own.

**XOR (Exclusive OR)**

Produces 1 when the inputs differ (one is 1 and the other is 0), and 0 when they match. XOR is central to arithmetic circuits (it produces the sum bit in binary addition without carry) and to simple parity/checksum calculations.

**XNOR (Exclusive NOR)**

The inverse of XOR: produces 1 when inputs match, 0 when they differ — useful for equality comparison circuits.

**Truth Tables for Derived Operations**

| A | B | NAND | NOR | XOR | XNOR |
|---|---|---|---|---|---|
| 0 | 0 | 1 | 1 | 0 | 1 |
| 0 | 1 | 1 | 0 | 1 | 0 |
| 1 | 0 | 1 | 0 | 1 | 0 |
| 1 | 1 | 0 | 0 | 0 | 1 |

### Logic Gate Symbols

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 800 420" font-family="sans-serif">
  <text x="400" y="28" text-anchor="middle" font-size="18" font-weight="bold" fill="#1a1a1a">Standard Logic Gate Symbols (svg_diagram)</text>

  <text x="90" y="70" font-size="13" font-weight="bold" fill="#2b6cb0">AND</text>
  <path d="M 60 90 L 60 140 L 90 140 A 25 25 0 0 0 90 90 Z" fill="#eef4fb" stroke="#2b6cb0" stroke-width="2" />
  <line x1="30" y1="100" x2="60" y2="100" stroke="#2b6cb0" stroke-width="2" />
  <line x1="30" y1="130" x2="60" y2="130" stroke="#2b6cb0" stroke-width="2" />
  <line x1="115" y1="115" x2="140" y2="115" stroke="#2b6cb0" stroke-width="2" />

  <text x="290" y="70" font-size="13" font-weight="bold" fill="#2b6cb0">OR</text>
  <path d="M 260 90 Q 285 115 260 140 Q 300 140 320 115 Q 300 90 260 90 Z" fill="#eef4fb" stroke="#2b6cb0" stroke-width="2" />
  <line x1="230" y1="100" x2="265" y2="100" stroke="#2b6cb0" stroke-width="2" />
  <line x1="230" y1="130" x2="265" y2="130" stroke="#2b6cb0" stroke-width="2" />
  <line x1="320" y1="115" x2="345" y2="115" stroke="#2b6cb0" stroke-width="2" />

  <text x="490" y="70" font-size="13" font-weight="bold" fill="#2b6cb0">NOT</text>
  <polygon points="460,90 460,140 505,115" fill="#eef4fb" stroke="#2b6cb0" stroke-width="2" />
  <circle cx="511" cy="115" r="6" fill="#eef4fb" stroke="#2b6cb0" stroke-width="2" />
  <line x1="430" y1="115" x2="460" y2="115" stroke="#2b6cb0" stroke-width="2" />
  <line x1="517" y1="115" x2="545" y2="115" stroke="#2b6cb0" stroke-width="2" />

  <text x="90" y="220" font-size="13" font-weight="bold" fill="#b7791f">NAND</text>
  <path d="M 60 240 L 60 290 L 90 290 A 25 25 0 0 0 90 240 Z" fill="#fff7e6" stroke="#b7791f" stroke-width="2" />
  <circle cx="121" cy="265" r="6" fill="#fff7e6" stroke="#b7791f" stroke-width="2" />
  <line x1="30" y1="250" x2="60" y2="250" stroke="#b7791f" stroke-width="2" />
  <line x1="30" y1="280" x2="60" y2="280" stroke="#b7791f" stroke-width="2" />
  <line x1="127" y1="265" x2="150" y2="265" stroke="#b7791f" stroke-width="2" />

  <text x="290" y="220" font-size="13" font-weight="bold" fill="#b7791f">NOR</text>
  <path d="M 260 240 Q 285 265 260 290 Q 300 290 320 265 Q 300 240 260 240 Z" fill="#fff7e6" stroke="#b7791f" stroke-width="2" />
  <circle cx="326" cy="265" r="6" fill="#fff7e6" stroke="#b7791f" stroke-width="2" />
  <line x1="230" y1="250" x2="265" y2="250" stroke="#b7791f" stroke-width="2" />
  <line x1="230" y1="280" x2="265" y2="280" stroke="#b7791f" stroke-width="2" />
  <line x1="332" y1="265" x2="355" y2="265" stroke="#b7791f" stroke-width="2" />

  <text x="490" y="220" font-size="13" font-weight="bold" fill="#b7791f">XOR</text>
  <path d="M 470 240 Q 495 265 470 290 Q 510 290 530 265 Q 510 240 470 240 Z" fill="#fff7e6" stroke="#b7791f" stroke-width="2" />
  <path d="M 460 240 Q 480 265 460 290" fill="none" stroke="#b7791f" stroke-width="2" />
  <line x1="435" y1="250" x2="465" y2="250" stroke="#b7791f" stroke-width="2" />
  <line x1="435" y1="280" x2="465" y2="280" stroke="#b7791f" stroke-width="2" />
  <line x1="530" y1="265" x2="555" y2="265" stroke="#b7791f" stroke-width="2" />
</svg>

### Boolean Algebra Laws and Identities

These laws allow logical expressions to be simplified or transformed, which matters for both digital circuit minimization and writing efficient conditional logic in firmware.

**Identity and Null Laws**

$$A \cdot 1 = A \qquad A + 0 = A$$
$$A \cdot 0 = 0 \qquad A + 1 = 1$$

**Idempotent Law**

$$A \cdot A = A \qquad A + A = A$$

**Complement Law**

$$A \cdot \overline{A} = 0 \qquad A + \overline{A} = 1$$

**Commutative Law**

$$A \cdot B = B \cdot A \qquad A + B = B + A$$

**Associative Law**

$$(A \cdot B) \cdot C = A \cdot (B \cdot C) \qquad (A + B) + C = A + (B + C)$$

**Distributive Law**

$$A \cdot (B + C) = (A \cdot B) + (A \cdot C)$$
$$A + (B \cdot C) = (A + B) \cdot (A + C)$$

**De Morgan's Theorems**

Among the most practically important identities, allowing conversion between AND/OR forms and their negations:

$$\overline{A \cdot B} = \overline{A} + \overline{B}$$
$$\overline{A + B} = \overline{A} \cdot \overline{B}$$

De Morgan's theorems are frequently applied when simplifying conditional logic in firmware — for example, rewriting a negated compound condition into an equivalent, sometimes clearer or more efficient form.

### Functional Completeness

A set of Boolean operations is **functionally complete** if any possible Boolean function can be constructed using only operations from that set. The set {AND, OR, NOT} is functionally complete, and remarkably, NAND alone is also functionally complete, as is NOR alone. This property is why digital chip manufacturing historically favored building entire circuits from a single repeated gate type (commonly NAND), simplifying fabrication while still achieving arbitrary logic.

### Combinational vs. Sequential Logic

**Combinational Logic**

Circuits whose output depends only on the current combination of inputs, with no memory of past inputs. Built directly from logic gates as described above (e.g., an adder circuit that computes a sum based purely on its current input bits).

**Sequential Logic**

Circuits whose output depends on both current inputs and past state, requiring memory elements (flip-flops or latches) built from combinations of basic gates. Sequential logic underlies registers, counters, and state machines — including the processor's own program counter and internal registers. [Inference] The detailed construction of flip-flops from gates and their timing behavior (setup/hold times, clock edges) is a substantial topic in its own right and is only referenced here as the boundary where Boolean algebra extends into sequential digital design.

### Relationship to Bitwise Operations in Firmware

The AND, OR, NOT, and XOR operations described here correspond directly to the bitwise operators (`&`, `|`, `~`, `^`) used in embedded C and similar languages, though applied at a different level of abstraction: Boolean algebra reasons about single-bit logical values, while bitwise operators in firmware apply the same logic independently across every bit position of a multi-bit variable (such as an 8-bit or 32-bit register value) in a single operation.

### Comparative Summary

| Operation | Symbol | Output is 1 when... | Functionally Complete Alone? |
|---|---|---|---|
| AND | $A \cdot B$ | Both inputs are 1 | No |
| OR | $A + B$ | At least one input is 1 | No |
| NOT | $\overline{A}$ | Input is 0 | No (unary) |
| NAND | $\overline{A \cdot B}$ | Not both inputs are 1 | Yes |
| NOR | $\overline{A + B}$ | Neither input is 1 | Yes |
| XOR | $A \oplus B$ | Inputs differ | No |
| XNOR | $\overline{A \oplus B}$ | Inputs match | No |

### Practical Example: Simplifying a Firmware Condition

Boolean algebra can simplify real conditional logic. Suppose firmware needs to trigger an alarm when it is *not* the case that both a door sensor and a motion sensor are simultaneously inactive:

**Original condition (as first written):**
```c
if (!(door_inactive && motion_inactive)) {
    trigger_alarm();
}
```

Applying De Morgan's theorem, $\overline{A \cdot B} = \overline{A} + \overline{B}$, this is logically equivalent to:

```c
if (!door_inactive || !motion_inactive) {
    trigger_alarm();
}
```

Or, rewritten in terms of the sensors being *active* rather than *inactive*:

```c
if (door_active || motion_active) {
    trigger_alarm();
}
```

This final form is often clearer to read and reason about than the original negated compound expression, illustrating a direct, practical payoff from applying Boolean algebra identities to firmware logic.

### Related Topics

- Number systems and binary arithmetic
- Digital logic design and combinational circuits
- Sequential logic: flip-flops, latches, and state machines
- Bit manipulation techniques for register configuration
- Microcontroller architecture and the arithmetic logic unit (ALU)
- Karnaugh maps and logic minimization techniques