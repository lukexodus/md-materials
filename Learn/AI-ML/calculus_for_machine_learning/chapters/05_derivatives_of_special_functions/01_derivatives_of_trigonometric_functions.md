## Derivatives of Trigonometric Functions

### Core Derivative Formulas

The six basic trigonometric functions each have a standard derivative formula:

$$\frac{d}{dx}[\sin x] = \cos x$$

$$\frac{d}{dx}[\cos x] = -\sin x$$

$$\frac{d}{dx}[\tan x] = \sec^2 x$$

$$\frac{d}{dx}[\cot x] = -\csc^2 x$$

$$\frac{d}{dx}[\sec x] = \sec x \tan x$$

$$\frac{d}{dx}[\csc x] = -\csc x \cot x$$

### Key Points

- All six formulas can be derived from just the derivatives of $\sin x$ and $\cos x$, combined with the quotient rule.
- Trigonometric derivatives appear in machine learning primarily through **positional encodings** in transformer architectures, periodic feature engineering, and signal-processing-based models.
- The derivatives of sine and cosine form a repeating cycle of period four under repeated differentiation, which is relevant to Taylor series expansions.

### Derivation of $\frac{d}{dx}[\sin x] = \cos x$

Using the limit definition of the derivative:

$$\frac{d}{dx}[\sin x] = \lim_{h \to 0} \frac{\sin(x+h) - \sin(x)}{h}$$

Applying the angle addition formula, $\sin(x+h) = \sin x \cos h + \cos x \sin h$:

$$= \lim_{h \to 0} \frac{\sin x \cos h + \cos x \sin h - \sin x}{h}$$

$$= \lim_{h \to 0} \left[\sin x \cdot \frac{\cos h - 1}{h} + \cos x \cdot \frac{\sin h}{h}\right]$$

This derivation relies on two standard limits:

$$\lim_{h \to 0} \frac{\sin h}{h} = 1, \qquad \lim_{h \to 0} \frac{\cos h - 1}{h} = 0$$

[Fact] These two limits are typically established using the squeeze theorem in standard calculus treatments. Substituting them in:

$$\frac{d}{dx}[\sin x] = \sin x \cdot 0 + \cos x \cdot 1 = \cos x$$

### Derivation of $\frac{d}{dx}[\cos x] = -\sin x$

A similar approach using $\cos(x+h) = \cos x \cos h - \sin x \sin h$ yields:

$$\frac{d}{dx}[\cos x] = -\sin x$$

Alternatively, this result follows directly from the identity $\cos x = \sin\left(\frac{\pi}{2} - x\right)$ combined with the chain rule.

### Deriving $\tan x$, $\sec x$, $\csc x$, $\cot x$ via the Quotient Rule

Since $\tan x = \dfrac{\sin x}{\cos x}$, applying the quotient rule:

$$\frac{d}{dx}[\tan x] = \frac{\cos x \cdot \cos x - \sin x \cdot (-\sin x)}{\cos^2 x} = \frac{\cos^2 x + \sin^2 x}{\cos^2 x} = \frac{1}{\cos^2 x} = \sec^2 x$$

Since $\sec x = \dfrac{1}{\cos x}$, applying the quotient rule (or chain rule on $(\cos x)^{-1}$):

$$\frac{d}{dx}[\sec x] = \frac{0 \cdot \cos x - 1 \cdot (-\sin x)}{\cos^2 x} = \frac{\sin x}{\cos^2 x} = \frac{1}{\cos x} \cdot \frac{\sin x}{\cos x} = \sec x \tan x$$

The derivations for $\cot x$ and $\csc x$ follow analogously, using $\cot x = \dfrac{\cos x}{\sin x}$ and $\csc x = \dfrac{1}{\sin x}$.

### Worked Examples

**Example 1:**

$$f(x) = \sin(3x)$$

Using the chain rule:

$$f'(x) = 3\cos(3x)$$

**Example 2:**

$$f(x) = x^2 \cos(x)$$

Using the product rule:

$$f'(x) = 2x\cos(x) - x^2\sin(x)$$

**Example 3:**

$$f(x) = \tan(x^2 + 1)$$

Using the chain rule:

$$f'(x) = \sec^2(x^2+1) \cdot 2x = 2x\sec^2(x^2+1)$$

**Example 4:**

$$f(x) = \frac{\sin x}{1 + \cos x}$$

Using the quotient rule:

$$f'(x) = \frac{\cos x(1+\cos x) - \sin x(-\sin x)}{(1+\cos x)^2} = \frac{\cos x + \cos^2 x + \sin^2 x}{(1+\cos x)^2} = \frac{\cos x + 1}{(1+\cos x)^2} = \frac{1}{1+\cos x}$$

### Visualizing Sine and Its Derivative

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 520 300">
  <text x="260" y="25" font-size="16" font-weight="bold" text-anchor="middle" fill="#1a1a1a">sin(x) and Its Derivative cos(x) (svg_diagram)</text>

  <line x1="40" y1="160" x2="480" y2="160" stroke="#333" stroke-width="1.5" />
  <text x="470" y="180" font-size="12" fill="#333">x</text>

  
  <path d="M 60,160 Q 110,80 160,160 T 260,160 T 360,160 T 460,160" fill="none" stroke="#2563eb" stroke-width="3" />
  <text x="380" y="100" font-size="12" fill="#2563eb">f(x) = sin(x)</text>

  
  <path d="M 60,100 Q 85,50 110,100 T 160,100 Q 185,150 210,100 T 260,100 Q 285,50 310,100 T 360,100 Q 385,150 410,100 T 460,100" fill="none" stroke="#dc2626" stroke-width="2" stroke-dasharray="6,3" />
  <text x="380" y="60" font-size="12" fill="#dc2626">f'(x) = cos(x)</text>

  <text x="260" y="270" font-size="12" text-anchor="middle" fill="#555">Notice: f' peaks where f has its steepest slope (zero crossings)</text>
</svg>

### Cyclical Pattern Under Repeated Differentiation

$$\sin x \xrightarrow{d/dx} \cos x \xrightarrow{d/dx} -\sin x \xrightarrow{d/dx} -\cos x \xrightarrow{d/dx} \sin x$$

This four-cycle pattern is the basis for the trigonometric terms in the **Taylor series** expansions of $\sin x$ and $\cos x$:

$$\sin x = x - \frac{x^3}{3!} + \frac{x^5}{5!} - \frac{x^7}{7!} + \dots$$

$$\cos x = 1 - \frac{x^2}{2!} + \frac{x^4}{4!} - \frac{x^6}{6!} + \dots$$

### Relevance to Machine Learning

- **Positional encodings in transformers:** [Fact] The original Transformer architecture uses sine and cosine functions of varying frequencies to encode token position information, since these functions provide a smooth, bounded, and periodic representation of position. Gradients with respect to these encodings during training rely on the trigonometric derivative formulas above. [Unverified — while the general mechanism is well documented, specific claims about how gradients flow through fixed (non-learned) positional encodings in a given implementation should be checked against the specific architecture, since fixed encodings are sometimes non-trainable and therefore do not require gradient computation with respect to the encoding itself.]
- **Signal processing and time-series models:** Periodic feature engineering (e.g., encoding time-of-day or day-of-week as sine/cosine pairs) relies on these derivatives when such features feed into differentiable models.
- **Fourier-based methods:** Some machine learning approaches incorporate Fourier features or Fourier transforms, where trigonometric derivatives are foundational to the underlying mathematics.
- **Physics-informed neural networks:** [Inference] Models that incorporate differential equations involving oscillatory or wave-like phenomena often require trigonometric derivatives as part of the loss function's physics-based constraints, though the exact formulation depends on the specific physical system being modeled.

### Common Pitfalls

- **Sign errors with cosine's derivative:** Forgetting the negative sign, i.e., writing $\frac{d}{dx}[\cos x] = \sin x$ instead of $-\sin x$, is one of the most frequent mistakes.
- **Forgetting the chain rule with composite trigonometric arguments:** Differentiating $\sin(kx)$ without multiplying by $k$ is a common oversight.
- **Confusing $\sec^2 x$ with $(\sec x)^2$ notation ambiguity:** These are actually equivalent, but learners sometimes mistakenly compute $\sec(x^2)$ instead.
- **Degrees vs. radians:** These derivative formulas assume $x$ is measured in radians; using degrees introduces an additional conversion factor.

### Conclusion

The derivatives of trigonometric functions follow directly from the limit definition combined with angle-addition identities and the quotient rule, producing a compact and interrelated set of six formulas. In machine learning, these derivatives are most directly relevant to periodic feature engineering and positional encoding schemes, where smooth, bounded, and periodic functions are differentiated as part of gradient-based training.

**Related Topics**
- Taylor and Maclaurin series expansions
- Positional encoding in transformer architectures
- Fourier features and Fourier transforms in machine learning
- Chain rule and quotient rule (prerequisite tools)
- Derivatives of inverse trigonometric functions
- Physics-informed neural networks and differential equation constraints