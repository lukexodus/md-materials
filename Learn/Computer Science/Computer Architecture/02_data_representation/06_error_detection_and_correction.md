## Error Detection and Correction


Reliable digital systems operate over physical media that introduce bit errors. Error detection identifies that an error occurred; error correction additionally identifies which bit(s) flipped and restores the original data. Both rely on introducing structured **redundancy** — extra bits whose values are constrained by the data bits, such that violations of those constraints signal corruption.

---

### Error Model

The standard model is the **binary symmetric channel (BSC)**: each bit flips independently with probability _p_, and flips are equally likely in both directions. More complex models (burst errors, erasures) exist but parity and Hamming codes address the single-bit and small-error regime.

**Hamming distance** d(x, y): the number of bit positions in which codewords x and y differ. For a code with minimum Hamming distance d_min:

- Detection capability: up to **d_min − 1** errors detected
- Correction capability: up to **⌊(d_min − 1)/2⌋** errors corrected

These bounds are simultaneous only when not mixed — a code used to correct t errors can detect t errors but loses some detection range.

---

### Parity

#### Single-Bit Even Parity

A single parity bit is appended so the total number of 1s in the codeword is even. For data word d₁d₂…dₙ:

$$P = d_1 \oplus d_2 \oplus \cdots \oplus d_n$$

The transmitted word is d₁d₂…dₙP. On receipt, the receiver recomputes the XOR of all bits including P. A nonzero result (the **syndrome**) indicates an odd number of errors.

- d_min = 2
- Detects all **odd-weight** error patterns
- Detects **no even-weight** error patterns — two simultaneous bit flips are invisible
- Cannot correct any error (only signals presence)

**Odd parity**: parity bit set so the total count of 1s is odd. Identical detection properties; used when an all-zeros codeword must be distinguishable from no transmission.

#### Two-Dimensional Parity (Longitudinal Redundancy Check)

Data arranged in an r×c matrix with one parity bit per row and one per column. Column parities can catch many 2-bit errors that single-bit parity misses, and can correct isolated single-bit errors by identifying the intersecting row and column. Burst errors up to c bits wide can be detected. Still fails against certain 4-bit rectangular error patterns.

---

### Hamming Codes

#### Construction Principle

Hamming codes achieve d_min = 3, enabling **single-error correction / double-error detection (SECDED)** when augmented with an overall parity bit.

For a code with r redundancy (check) bits, the number of data bits supportable is:

$$n = 2^r - 1, \quad k = 2^r - 1 - r$$

Standard Hamming codes: (n, k) = (3,1), (7,4), (15,11), (31,26), (63,57), …

Each check bit is placed at a power-of-2 position (1, 2, 4, 8, …). Each check bit covers all positions whose binary representation has that power-of-2 bit set. The check bit is chosen so the XOR of all covered positions is zero (even parity variant).

**Position assignment for (7,4):**

|Position|1|2|3|4|5|6|7|
|---|---|---|---|---|---|---|---|
|Type|P₁|P₂|d₁|P₃|d₂|d₃|d₄|
|Binary|001|010|011|100|101|110|111|

P₁ covers positions 1, 3, 5, 7 (bit 0 of position index = 1) P₂ covers positions 2, 3, 6, 7 (bit 1 = 1) P₃ covers positions 4, 5, 6, 7 (bit 2 = 1)

Check bit values:

- P₁ = d₁ ⊕ d₂ ⊕ d₄
- P₂ = d₁ ⊕ d₃ ⊕ d₄
- P₃ = d₂ ⊕ d₃ ⊕ d₄

#### Syndrome Decoding

On receipt, the receiver recomputes each check bit and XORs against the received value. The resulting syndrome bits S₃S₂S₁ form a binary number:

- Syndrome = 0: no error detected
- Syndrome = k (nonzero): bit at position k is in error → flip it

This works because each error position produces a unique nonzero syndrome equal to its binary index. This is the key structural property: the columns of the parity-check matrix H are the binary representations of 1 through n, all distinct and nonzero.

---

### Visualization — (7,4) Hamming Code Structure---

### Worked Example — (7,4) Encoding and Error Correction

Data: d₁d₂d₃d₄ = **1011**

Compute check bits:

- P₁ = d₁ ⊕ d₂ ⊕ d₄ = 1 ⊕ 0 ⊕ 1 = **0**
- P₂ = d₁ ⊕ d₃ ⊕ d₄ = 1 ⊕ 1 ⊕ 1 = **1**
- P₃ = d₂ ⊕ d₃ ⊕ d₄ = 0 ⊕ 1 ⊕ 1 = **0**

Transmitted codeword (positions 1–7): **0 1 1 0 0 1 1**

Introduce error at position 5 → received: 0 1 1 0 **1** 1 1

Syndrome computation:

- S₁ = P₁ ⊕ r₁ ⊕ r₃ ⊕ r₅ ⊕ r₇ = 0⊕0⊕1⊕1⊕1 = **1**
- S₂ = P₂ ⊕ r₂ ⊕ r₃ ⊕ r₆ ⊕ r₇ = 1⊕1⊕1⊕1⊕1 = **1**
- S₃ = P₃ ⊕ r₄ ⊕ r₅ ⊕ r₆ ⊕ r₇ = 0⊕0⊕1⊕1⊕1 = **1**

S₃S₂S₁ = 101₂ = **5** → flip bit at position 5 → corrected.

---

### SECDED Extension

Appending an overall parity bit (position 0, covering all bits) extends (7,4) to (8,4) with d_min = 4:

- Syndrome nonzero + overall parity error → **single-bit error**, correct it
- Syndrome nonzero + overall parity correct → **double-bit error**, flag uncorrectable
- Syndrome zero + overall parity error → error in the parity bit itself, data intact

This is the standard used in ECC RAM.

---

### Parity-Check Matrix Formulation

A linear block code is fully described by its **parity-check matrix H** (r×n). A received word r is valid iff Hr^T = 0. The syndrome is s = Hr^T. For Hamming (7,4):

```
     pos: 1  2  3  4  5  6  7
H =  P₁ [1  0  1  0  1  0  1]
     P₂ [0  1  1  0  0  1  1]
     P₃ [0  0  0  1  1  1  1]
```

Column j of H is the binary representation of j. An error in position j produces syndrome equal to column j — directly identifying the error position. This is the algebraic reason the decoding procedure works.

The **generator matrix G** (k×n) produces codewords from data words: c = dG. G and H satisfy GH^T = 0.

---

### Code Efficiency and Bounds

**Code rate** R = k/n = (n−r)/n. For Hamming codes: R = (2^r − 1 − r)/(2^r − 1), approaching 1 as r grows.

**Hamming bound** (sphere-packing bound): for a binary (n, k) code correcting t errors, the number of codewords times the volume of a Hamming ball of radius t cannot exceed 2^n:

$$2^k \sum_{i=0}^{t} \binom{n}{i} \leq 2^n$$

Hamming codes achieve this bound with equality for t = 1 — they are **perfect codes**. Every binary n-tuple is within Hamming distance 1 of exactly one codeword. No wasted space in the code.

---

### Beyond Hamming — Burst Error Codes

Single-bit Hamming codes are optimal for independent errors but perform poorly against burst errors (consecutive flips from media defects, interference). Alternatives:

**Cyclic codes / CRC**: Based on polynomial arithmetic over GF(2). A codeword is a polynomial divisible by a generator polynomial g(x). CRCs detect all burst errors of length ≤ degree of g(x), and many longer bursts. Used in Ethernet, USB, storage.

**Reed-Solomon codes**: Operate over GF(2^m) symbols rather than bits. Can correct up to t symbol errors with 2t redundant symbols. Widely used in storage (CDs, SSDs), deep-space communication, QR codes.

**LDPC codes**: Low-density parity-check codes with sparse H matrices, approaching the Shannon channel capacity limit. Used in modern wireless and storage standards (5G, Wi-Fi 6, NVMe).

---

**Next Steps:** Cyclic codes and CRC derivation · Reed-Solomon construction over finite fields · LDPC tanner graphs · Interleaving for burst-error resilience · Application to ECC DRAM and NAND flash.

---

