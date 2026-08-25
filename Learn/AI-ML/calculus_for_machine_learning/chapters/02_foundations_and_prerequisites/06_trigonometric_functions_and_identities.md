## Trigonometric Functions and Identities

### Core Trigonometric Functions

The six trigonometric functions are defined from a right triangle or, more generally, from the unit circle:

$$\sin(\theta), \quad \cos(\theta), \quad \tan(\theta) = \frac{\sin(\theta)}{\cos(\theta)}$$

$$\csc(\theta) = \frac{1}{\sin(\theta)}, \quad \sec(\theta) = \frac{1}{\cos(\theta)}, \quad \cot(\theta) = \frac{1}{\tan(\theta)}$$

**Key Points**

- $\sin(\theta)$ and $\cos(\theta)$ have domain $\mathbb{R}$ and range $[-1, 1]$
- $\tan(\theta)$ is undefined where $\cos(\theta) = 0$, i.e., at $\theta = \frac{\pi}{2} + k\pi$ for integer $k$
- All trigonometric functions are periodic

#### Periodicity Table

| Function | Period |
|---|---|
| $\sin(\theta)$, $\cos(\theta)$ | $2\pi$ |
| $\tan(\theta)$, $\cot(\theta)$ | $\pi$ |
| $\sec(\theta)$, $\csc(\theta)$ | $2\pi$ |

These period values are standard mathematical definitions, verifiable directly from the unit circle.

### Unit Circle Definition

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 400 400">
  <text x="200" y="25" font-size="16" text-anchor="middle" font-family="sans-serif" font-weight="bold">Unit Circle Definition (svg_diagram)</text>

  <line x1="30" y1="220" x2="370" y2="220" stroke="#334155" stroke-width="1.5" />
  <line x1="200" y1="50" x2="200" y2="390" stroke="#334155" stroke-width="1.5" />

  <circle cx="200" cy="220" r="120" fill="none" stroke="#1e3a8a" stroke-width="1.5" />

  <line x1="200" y1="220" x2="285" y2="135" stroke="#b91c1c" stroke-width="2" />
  <circle cx="285" cy="135" r="4" fill="#b91c1c" />
  <text x="295" y="130" font-size="11" font-family="sans-serif">(cos θ, sin θ)</text>

  <path d="M 230 220 A 30 30 0 0 0 221 195" fill="none" stroke="#15803d" stroke-width="1.5" />
  <text x="235" y="205" font-size="11" font-family="sans-serif" fill="#15803d">θ</text>

  <line x1="285" y1="135" x2="285" y2="220" stroke="#9ca3af" stroke-width="1" stroke-dasharray="3,3" />
  <text x="290" y="180" font-size="10" font-family="sans-serif" fill="#6b7280">sin θ</text>
  <line x1="200" y1="220" x2="285" y2="220" stroke="#9ca3af" stroke-width="1" stroke-dasharray="3,3" />
  <text x="230" y="235" font-size="10" font-family="sans-serif" fill="#6b7280">cos θ</text>
</svg>

This is a standard geometric definition, verifiable from any trigonometry reference.

### Fundamental Identities

#### Pythagorean Identity

$$\sin^2(\theta) + \cos^2(\theta) = 1$$

This follows directly from the unit circle (radius = 1) via the Pythagorean theorem. This is a verifiable mathematical identity, not [Inference].

Derived forms:

$$1 + \tan^2(\theta) = \sec^2(\theta)$$
$$1 + \cot^2(\theta) = \csc^2(\theta)$$

#### Angle Sum and Difference Identities

$$\sin(a \pm b) = \sin(a)\cos(b) \pm \cos(a)\sin(b)$$
$$\cos(a \pm b) = \cos(a)\cos(b) \mp \sin(a)\sin(b)$$

#### Double Angle Identities

$$\sin(2\theta) = 2\sin(\theta)\cos(\theta)$$
$$\cos(2\theta) = \cos^2(\theta) - \sin^2(\theta) = 1 - 2\sin^2(\theta) = 2\cos^2(\theta) - 1$$

These are standard, verifiable trigonometric identities derivable from the angle sum formulas.

### Derivatives of Trigonometric Functions

$$\frac{d}{dx}\sin(x) = \cos(x)$$
$$\frac{d}{dx}\cos(x) = -\sin(x)$$
$$\frac{d}{dx}\tan(x) = \sec^2(x)$$

These are standard calculus results, verifiable through the limit definition of the derivative.

**Example**

Differentiate $f(x) = \sin(2x)$ using the chain rule:

$$f'(x) = \cos(2x) \cdot 2 = 2\cos(2x)$$

### Graphs of Sine and Cosine

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 700 260">
  <text x="350" y="25" font-size="16" text-anchor="middle" font-family="sans-serif" font-weight="bold">Sine and Cosine Waves (svg_diagram)</text>

  <line x1="40" y1="140" x2="660" y2="140" stroke="#334155" stroke-width="1.5" />
  <line x1="60" y1="40" x2="60" y2="230" stroke="#334155" stroke-width="1.5" />

  <path d="M 60 140 Q 110 60 160 140 T 260 140 T 360 140 T 460 140 T 560 140 T 660 140" fill="none" stroke="#1d4ed8" stroke-width="2.5" />
  <text x="600" y="90" font-size="11" font-family="sans-serif" fill="#1d4ed8">sin(x)</text>

  <path d="M 60 60 Q 110 140 160 60 T 260 60 T 360 60 T 460 60 T 560 60 T 660 60" fill="none" stroke="#15803d" stroke-width="2.5" />
  <text x="600" y="45" font-size="11" font-family="sans-serif" fill="#15803d">cos(x)</text>

  <text x="60" y="230" font-size="10" font-family="sans-serif">0</text>
  <text x="260" y="230" font-size="10" font-family="sans-serif">π</text>
  <text x="460" y="230" font-size="10" font-family="sans-serif">2π</text>
</svg>

### Relevance to Machine Learning

#### Positional Encoding in Transformers

Sinusoidal positional encodings use sine and cosine functions to inject sequence-order information into embeddings, as originally described in "Attention Is All You Need" (Vaswani et al., 2017):

$$PE_{(pos, 2i)} = \sin\left(\frac{pos}{10000^{2i/d}}\right)$$
$$PE_{(pos, 2i+1)} = \cos\left(\frac{pos}{10000^{2i/d}}\right)$$

I cannot verify the exact formula reproduction against the original paper text without directly fetching and confirming the source; the general structure described here reflects commonly cited descriptions of this method, but exact subscript/notation details should be checked against the original publication before being treated as authoritative.

**Key Points**

- [Inference] Using sine and cosine at varying frequencies allows the model to represent relative positions through linear combinations, since trigonometric identities relate $PE$ at position $pos+k$ to $PE$ at position $pos$. This is a commonly cited rationale in literature discussing this technique, but I cannot verify without a direct citation that this is the exact justification given in every source describing it.
- [Unverified] Whether specific current transformer implementations still use this exact sinusoidal scheme versus learned positional embeddings varies by architecture and model, and I do not have access to information confirming this for any particular current model without checking documentation directly.

#### Periodic Feature Engineering

Trigonometric functions are sometimes used to encode cyclical features (e.g., time of day, day of week) so that models can capture periodicity:

$$x_{\sin} = \sin\left(\frac{2\pi \cdot t}{T}\right), \quad x_{\cos} = \cos\left(\frac{2\pi \cdot t}{T}\right)$$

where $T$ is the period (e.g., 24 for hours in a day).

**Key Points**

- [Inference] This encoding is commonly used because it avoids the discontinuity that would occur if cyclical values were encoded as raw integers (e.g., hour 23 and hour 0 being far apart numerically despite being adjacent in time). This is a reasoning pattern found in general feature engineering discussions, but I cannot verify this is stated as the rationale in any specific single source without a citation.

#### Fourier-Based Methods

Trigonometric functions form the basis of Fourier series and Fourier transforms, which decompose signals into sums of sinusoids. [Unverified] The specific extent to which Fourier-based techniques are used in any particular current machine learning architecture is not something I can confirm without checking current, specific documentation or papers.

### Inverse Trigonometric Functions

| Function | Domain | Range |
|---|---|---|
| $\arcsin(x)$ | $[-1, 1]$ | $[-\pi/2, \pi/2]$ |
| $\arccos(x)$ | $[-1, 1]$ | $[0, \pi]$ |
| $\arctan(x)$ | $\mathbb{R}$ | $(-\pi/2, \pi/2)$ |

**Derivatives:**

$$\frac{d}{dx}\arcsin(x) = \frac{1}{\sqrt{1-x^2}}, \quad \frac{d}{dx}\arctan(x) = \frac{1}{1+x^2}$$

These are standard, verifiable calculus results.

### Summary Table

| Property | $\sin(\theta)$ | $\cos(\theta)$ | $\tan(\theta)$ |
|---|---|---|---|
| Domain | $\mathbb{R}$ | $\mathbb{R}$ | $\theta \neq \pi/2 + k\pi$ |
| Range | $[-1,1]$ | $[-1,1]$ | $\mathbb{R}$ |
| Period | $2\pi$ | $2\pi$ | $\pi$ |
| Derivative | $\cos(\theta)$ | $-\sin(\theta)$ | $\sec^2(\theta)$ |

**Related Topics**

- Chain rule applications with trigonometric compositions
- Fourier series and signal decomposition
- Positional encoding schemes in sequence models
- L'Hôpital's rule involving trigonometric limits
- Radians vs. degrees and angular measure conventions

---

**Note on this response:** Per your stated preferences, uncertain claims above are labeled [Inference] or [Unverified] where applicable. Standard, verifiable mathematical identities (Pythagorean identity, derivative formulas, periodicity) are not labeled, as they are confirmable directly from mathematical definitions rather than being unconfirmed claims. If any portion above is later found to misstate a verifiable mathematical fact, the correction convention from your preferences applies:

> Correction: I made an unverified claim. That was incorrect.