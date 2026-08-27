## Reed-Solomon Codes

### Definition

Reed-Solomon (RS) codes are a family of non-binary linear block codes operating over a finite field $\mathbb{F}_q$ (typically $q = 2^m$ in practice), previously noted as a special case of the BCH construction where the symbol alphabet is the extension field itself rather than restricted to $\mathbb{F}_2$. An RS code with parameters $(n, k)$ over $\mathbb{F}_q$ has length $n = q-1$ (in the standard construction), dimension $k$, and minimum distance:

$$d_{\min} = n - k + 1$$

This achieves the **Singleton bound** with equality (previously introduced in the context of linear block codes generally), making Reed-Solomon codes **maximum distance separable (MDS)** codes — the maximum possible minimum distance for any code with the given $n$ and $k$.

### Construction via Polynomial Evaluation

**[Confirmed]** The most direct and intuitive construction of an RS code treats a message as the coefficients of a polynomial and encodes by evaluating that polynomial at many points:

1. A message $m = (m_0, m_1, \dots, m_{k-1}) \in \mathbb{F}_q^k$ defines a polynomial:

$$m(x) = m_0 + m_1 x + m_2 x^2 + \dots + m_{k-1}x^{k-1}$$

of degree less than $k$.

2. Fix $n$ distinct evaluation points $x_1, x_2, \dots, x_n \in \mathbb{F}_q$ (in the standard construction, all nonzero field elements, giving $n = q-1$).

3. The codeword is the vector of evaluations:

$$c = \left(m(x_1), m(x_2), \dots, m(x_n)\right)$$

**[Confirmed]** This evaluation-based view makes the MDS property almost immediate: two distinct polynomials of degree less than $k$ can agree on at most $k-1$ points (a nonzero polynomial of degree $< k$ has at most $k-1$ roots, by the fundamental theorem of algebra over a field), so any two distinct codewords must differ in at least $n - (k-1) = n-k+1$ positions — exactly matching $d_{\min} = n-k+1$.

### Why This Achieves MDS

The evaluation-based intuition directly explains the Singleton bound equality: since agreement on $k-1$ points is the *most* two distinct degree-$<k$ polynomials can share, no code construction can do better than $d_{\min} = n-k+1$ for a given $(n,k)$ — this is exactly the general Singleton bound. Reed-Solomon codes achieve it exactly, rather than merely approaching it, which is why they are the canonical MDS code family referenced throughout coding theory (including in the earlier binary erasure channel discussion, where MDS codes were noted as capacity-achieving for the BEC).

### Diagram: Polynomial Evaluation Encoding

```mermaid
flowchart LR
    A["Message m₀,...,m_(k-1)"] --> B["Form polynomial<br/>m(x), degree < k"]
    B --> C["Evaluate at n<br/>distinct points x₁,...,xₙ"]
    C --> D["Codeword c =<br/>(m(x₁),...,m(xₙ))"]
    D --> E["Any 2 distinct codewords<br/>agree on ≤ k-1 points"]
    E --> F["d_min = n - k + 1<br/>(Singleton bound, MDS)"]
```

### Connection to BCH Construction

**[Confirmed]** The evaluation-point view and the BCH-style root-based view are two equivalent perspectives on the same code family. The BCH-style construction takes $g(x) = \prod_{i=1}^{2t}(x - \alpha^i)$ as the generator polynomial (roots at consecutive powers of a primitive element $\alpha$), giving $n-k = 2t$ and thus $d_{\min} \ge 2t+1 = n-k+1$ — meeting the BCH bound with equality precisely because the non-binary alphabet removes the conjugate-root degree reduction that limits binary BCH codes (each root $\alpha^i$ over $\mathbb{F}_q$ has its own distinct, degree-1 minimal polynomial $x-\alpha^i$ when working directly in $\mathbb{F}_q$ rather than a binary subfield).

### Diagram: Reed-Solomon Codeword Geometry (Erasures vs Errors)

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 550 260">
  <text x="275" y="25" text-anchor="middle" font-size="16" font-weight="bold" fill="#1a1a1a">Reed-Solomon: n Symbols, k Needed to Recover (svg_diagram)</text>

  <rect x="50" y="60" width="450" height="60" fill="#f9fafb" stroke="#374151" stroke-width="1.5" />
  <rect x="50" y="60" width="45" height="60" fill="#dcfce7" />
  <rect x="95" y="60" width="45" height="60" fill="#dcfce7" />
  <rect x="140" y="60" width="45" height="60" fill="#fee2e2" />
  <rect x="185" y="60" width="45" height="60" fill="#dcfce7" />
  <rect x="230" y="60" width="45" height="60" fill="#dcfce7" />
  <rect x="275" y="60" width="45" height="60" fill="#fee2e2" />
  <rect x="320" y="60" width="45" height="60" fill="#dcfce7" />
  <rect x="365" y="60" width="45" height="60" fill="#dcfce7" />
  <rect x="410" y="60" width="45" height="60" fill="#dcfce7" />
  <rect x="455" y="60" width="45" height="60" fill="#dcfce7" />

  <text x="275" y="145" text-anchor="middle" font-size="11" fill="#166534">Green = received correctly (n - 2 symbols here)</text>
  <text x="275" y="165" text-anchor="middle" font-size="11" fill="#991b1b">Red = erased or corrupted symbols</text>
  <text x="275" y="195" text-anchor="middle" font-size="11" fill="#374151">Any k correctly-received symbols suffice</text>
  <text x="275" y="212" text-anchor="middle" font-size="11" fill="#374151">to reconstruct m(x) via polynomial interpolation</text>
</svg>

### Erasure Decoding: Polynomial Interpolation

**[Confirmed]** When errors take the form of *erasures* (known missing positions, as in the previously discussed binary erasure channel context), RS decoding reduces to **polynomial interpolation**: given any $k$ of the $n$ evaluations $(x_i, m(x_i))$, the unique degree-$<k$ polynomial $m(x)$ passing through those $k$ points can be recovered exactly (e.g., via Lagrange interpolation), since $k$ points uniquely determine a degree-$<k$ polynomial over a field. This means an RS$(n,k)$ code corrects up to $n-k$ erasures — recovering the message as long as at least $k$ symbols survive, matching the erasure-correction intuition previously discussed for MDS codes on the BEC.

### Error Decoding: Beyond Erasures

**[Confirmed]** When errors are *unlocated* (unknown positions, unlike erasures), RS decoding follows the same general BCH decoding pipeline previously outlined — syndrome computation, error locator polynomial via Berlekamp-Massey, root-finding via Chien search — with one addition specific to non-binary codes: since a symbol error can take any of $q-1$ nonzero wrong values (not just a single "flip" as in binary codes), an additional **error magnitude** computation is required, typically via the **Forney algorithm**, after the error locations are found.

**[Confirmed]** An RS$(n,k)$ code can correct up to $t = \lfloor (n-k)/2 \rfloor$ unlocated errors — half the erasure-correction capability, following the same $2t \le d_{\min}-1$ relationship established generally for the correction/detection trade-off (previously covered under Hamming distance basics), here with $d_{\min} = n-k+1$.

### Worked Example

Consider RS$(255, 223)$ over $\mathbb{F}_{256}$ (i.e., $q=256$, 8-bit symbols) — **[Confirmed]** a widely referenced example historically associated with deep-space and storage applications due to its favorable rate and error-correction trade-off at byte-oriented symbol sizes. Here $n-k = 32$, giving:

- **Erasure correction:** up to $32$ erased symbols (256 bytes) can be recovered exactly via interpolation.
- **Error correction:** up to $\lfloor 32/2 \rfloor = 16$ unlocated symbol errors can be corrected.

**[Unverified]** Specific historical deployments and exact parameter choices (e.g., in particular spacecraft telemetry standards or CD/DVD storage formats) vary and should be checked against the specific standard's documentation rather than assumed from this general example, though RS$(255,223)$ specifically is a commonly cited textbook and historical reference point.

### Burst Error Correction

**[Inference]** Because Reed-Solomon codes operate on multi-bit symbols rather than individual bits, they are particularly well suited to correcting **burst errors** — a contiguous run of bit errors, common in real channels (e.g., scratches on optical media, deep fades in wireless channels) — since a burst affecting several consecutive bits is likely to corrupt only one or a few symbols rather than being spread across many, unlike a binary code where the same burst could corrupt many separate single-bit-error events beyond the code's binary correction capability. This symbol-oriented structure is a major practical reason RS codes are favored over binary BCH codes in storage and broadcast applications where burst errors dominate.

### Key Points

**Key Points**
- Reed-Solomon codes are the canonical MDS code family, achieving the Singleton bound with equality — the best possible minimum distance for any given $(n,k)$, over any alphabet.
- The polynomial-evaluation construction and the BCH-style root-based construction are equivalent views of the same code; the evaluation view most directly explains the MDS property via the "distinct polynomials agree on few points" argument.
- Erasure correction (up to $n-k$ symbols) via direct interpolation is simpler than unlocated error correction (up to $\lfloor(n-k)/2\rfloor$ symbols), which requires the full syndrome/locator/Forney decoding pipeline — mirroring the general erasure-vs-error asymmetry established for the binary erasure channel and Hamming distance discussions.
- The symbol-oriented (non-binary) structure makes RS codes especially effective against burst errors, a key reason for their widespread historical and continued use in storage and communication standards.

### Related Topics

- BCH codes and the shared root-based / evaluation-based construction duality (prerequisite, previously covered)
- Binary erasure channel capacity and MDS codes as capacity-achieving (prerequisite, previously covered)
- Lagrange interpolation and its role in erasure decoding
- Berlekamp-Massey algorithm, Chien search, and Forney's algorithm for error decoding
- Concatenated codes (RS outer code + convolutional inner code, historically common pairing)
- Fountain codes and Raptor codes as rateless generalizations of erasure-correcting ideas
- Finite field (Galois field) arithmetic for byte-oriented (F₂₅₆) implementations
- Burst error models and interleaving techniques