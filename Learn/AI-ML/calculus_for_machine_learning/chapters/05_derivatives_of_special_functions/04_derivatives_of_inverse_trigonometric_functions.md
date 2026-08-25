## Derivatives of Inverse Trigonometric Functions

### Core Derivative Formulas

The derivatives of the six inverse trigonometric functions are as follows:

$$\frac{d}{dx}\left[\arcsin x\right] = \frac{1}{\sqrt{1-x^2}}, \qquad -1 < x < 1$$

$$\frac{d}{dx}\left[\arccos x\right] = \frac{-1}{\sqrt{1-x^2}}, \qquad -1 < x < 1$$

$$\frac{d}{dx}\left[\arctan x\right] = \frac{1}{1+x^2}$$

$$\frac{d}{dx}\left[\text{arccot } x\right] = \frac{-1}{1+x^2}$$

$$\frac{d}{dx}\left[\text{arcsec } x\right] = \frac{1}{|x|\sqrt{x^2-1}}, \qquad |x| > 1$$

$$\frac{d}{dx}\left[\text{arccsc } x\right] = \frac{-1}{|x|\sqrt{x^2-1}}, \qquad |x| > 1$$

### Key Points

- Unlike ordinary trigonometric derivatives, inverse trigonometric derivatives are **algebraic** (involving roots and rational expressions) rather than trigonometric themselves.
- $\arctan x$ has the most commonly encountered derivative in machine learning contexts, due to its bounded, smooth, monotonic shape and appearance in some bounded activation functions.
- All six formulas can be derived using **implicit differentiation** combined with the Pythagorean identity.

### Derivation of $\frac{d}{dx}[\arcsin x]$

Let $y = \arcsin x$, which means $\sin y = x$, with $y \in \left[-\frac{\pi}{2}, \frac{\pi}{2}\right]$.

Differentiating both sides implicitly with respect to $x$:

$$\cos y \cdot \frac{dy}{dx} = 1 \implies \frac{dy}{dx} = \frac{1}{\cos y}$$

Using the Pythagorean identity, $\cos y = \sqrt{1-\sin^2 y} = \sqrt{1-x^2}$ (positive root, since $\cos y \geq 0$ on this interval):

$$\frac{dy}{dx} = \frac{1}{\sqrt{1-x^2}}$$

### Derivation of $\frac{d}{dx}[\arctan x]$

Let $y = \arctan x$, which means $\tan y = x$, with $y \in \left(-\frac{\pi}{2}, \frac{\pi}{2}\right)$.

Differentiating both sides implicitly:

$$\sec^2 y \cdot \frac{dy}{dx} = 1 \implies \frac{dy}{dx} = \frac{1}{\sec^2 y}$$

Using the identity $\sec^2 y = 1 + \tan^2 y = 1 + x^2$:

$$\frac{dy}{dx} = \frac{1}{1+x^2}$$

This derivation pattern — implicit differentiation followed by substitution using a Pythagorean identity — generalizes to all six inverse trigonometric derivatives.

### Worked Examples

**Example 1:**

$$f(x) = \arctan(2x)$$

Using the chain rule:

$$f'(x) = \frac{1}{1+(2x)^2} \cdot 2 = \frac{2}{1+4x^2}$$

**Example 2:**

$$f(x) = \arcsin(x^2)$$

Using the chain rule:

$$f'(x) = \frac{1}{\sqrt{1-x^4}} \cdot 2x = \frac{2x}{\sqrt{1-x^4}}$$

**Example 3:**

$$f(x) = x \arctan x$$

Using the product rule:

$$f'(x) = \arctan x + x \cdot \frac{1}{1+x^2} = \arctan x + \frac{x}{1+x^2}$$

**Example 4:**

$$f(x) = \arccos(3x - 1)$$

Using the chain rule:

$$f'(x) = \frac{-1}{\sqrt{1-(3x-1)^2}} \cdot 3 = \frac{-3}{\sqrt{1-(3x-1)^2}}$$

### Visualizing $\arctan(x)$ and Its Derivative

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 520 300">
  <text x="260" y="25" font-size="16" font-weight="bold" text-anchor="middle" fill="#1a1a1a">f(x) = arctan(x) and f'(x) = 1/(1+x²) (svg_diagram)</text>

  <line x1="40" y1="160" x2="480" y2="160" stroke="#333" stroke-width="1.5" />
  <line x1="260" y1="50" x2="260" y2="270" stroke="#333" stroke-width="1.5" />

  
  <path d="M 60,220 C 140,215 200,190 260,160 C 320,130 380,105 460,100" fill="none" stroke="#2563eb" stroke-width="3" />
  <text x="360" y="90" font-size="12" fill="#2563eb">f(x) = arctan(x)</text>

  
  <path d="M 60,250 C 150,248 200,220 260,190 C 320,220 370,248 460,250" fill="none" stroke="#dc2626" stroke-width="2" stroke-dasharray="6,3" />
  <text x="300" y="205" font-size="12" fill="#dc2626">f'(x) = 1/(1+x²)</text>

  <text x="260" y="290" font-size="12" text-anchor="middle" fill="#555">Derivative peaks at x = 0, decays toward 0 as |x| grows — both functions are bounded</text>
</svg>

### Relevance to Machine Learning

- **Bounded activation functions:** [Inference] While $\tanh$ and sigmoid are far more common as bounded, smooth activation functions in practice, $\arctan$ shares similar qualitative properties (bounded output, smooth, monotonic) and has occasionally been explored as an alternative activation function in some architectures; its derivative $\frac{1}{1+x^2}$ would be used analogously to the sigmoid derivative during backpropagation in such cases.
- **Angle and rotation-based models:** Inverse trigonometric functions arise in models involving geometric transformations, pose estimation, robotics kinematics, or angular regression tasks, where predicting an angle from other differentiable outputs may require differentiating an inverse trigonometric function during training.
- **Normalizing flows and specialized transformations:** [Unverified] Some specialized normalizing flow architectures or coordinate transformations may incorporate inverse trigonometric functions as part of their invertible mapping; when used, computing the Jacobian determinant for the change-of-variables formula would require these derivative formulas, though this is a comparatively niche application relative to more common flow architectures.
- **Gradient boundedness:** Since $\frac{1}{1+x^2}$ is bounded between 0 and 1 and decays smoothly, functions built on $\arctan$ avoid extreme gradient magnitudes, a property sometimes relevant when designing custom activation or regularization functions with controlled gradient behavior.

### Common Pitfalls

- **Sign errors between $\arcsin$ and $\arccos$ derivatives:** Since these two formulas differ only by a sign, mixing them up is a frequent mistake.
- **Forgetting domain restrictions:** The derivatives of $\arcsin x$ and $\arccos x$ are undefined at $x = \pm 1$ (where the denominator becomes zero) and outside $[-1, 1]$ (where the functions themselves are undefined).
- **Omitting the chain rule for composite arguments:** As shown in the worked examples, differentiating $\arctan(g(x))$ requires multiplying by $g'(x)$, not just substituting $g(x)$ into the base formula.
- **Absolute value handling in $\text{arcsec}$ and $\text{arccsc}$:** The $|x|$ term in these derivatives is often dropped incorrectly, which can produce sign errors for negative $x$.

### Conclusion

The derivatives of inverse trigonometric functions, derived through implicit differentiation and Pythagorean identities, produce purely algebraic expressions despite originating from trigonometric functions. While less central to mainstream machine learning than exponential or logarithmic derivatives, they remain relevant in angle-prediction tasks, geometric and robotics-related models, and certain specialized bounded-output formulations.

**Related Topics**
- Implicit differentiation techniques
- Chain rule applications with composite inverse functions
- Tanh and sigmoid as dominant bounded activation functions
- Angular regression and pose estimation in machine learning
- Normalizing flows and Jacobian determinants
- Pythagorean identities and their role in trigonometric calculus