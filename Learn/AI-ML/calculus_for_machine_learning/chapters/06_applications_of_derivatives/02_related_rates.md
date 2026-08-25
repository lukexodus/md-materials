## Related Rates

### Definition and Motivation

Related rates problems involve finding the rate of change of one quantity by relating it to the rate of change of another quantity, when both quantities are functions of a shared underlying variable — typically time, $t$. The technique relies on implicit differentiation applied to an equation connecting the two (or more) quantities.

### Key Points

- Related rates problems always begin with an equation relating two or more quantities, followed by differentiating that equation with respect to time using implicit differentiation.
- The core insight is that if quantities are related by an equation at every instant, their **rates of change** are also related by the differentiated form of that equation.
- While related rates are typically introduced using physical or geometric scenarios, the same underlying technique — differentiating a constraint equation with respect to a shared variable — appears in machine learning wherever interdependent quantities evolve jointly during training or inference.

### General Problem-Solving Framework

1. Identify all variables and write down an equation relating them.
2. Differentiate the equation with respect to time $t$, applying implicit differentiation and the chain rule to every term.
3. Substitute known values (rates and quantities) at the specific instant of interest.
4. Solve algebraically for the unknown rate.

### Worked Example 1: Expanding Circle

A circle's radius increases at a rate of $3\text{ cm/s}$. Find the rate at which the area is increasing when the radius is $10\text{ cm}$.

The relating equation is the area formula:

$$A = \pi r^2$$

Differentiating both sides with respect to $t$:

$$\frac{dA}{dt} = 2\pi r \cdot \frac{dr}{dt}$$

Substituting $r = 10$ and $\dfrac{dr}{dt} = 3$:

$$\frac{dA}{dt} = 2\pi(10)(3) = 60\pi \approx 188.5 \text{ cm}^2/\text{s}$$

### Worked Example 2: Ladder Sliding Down a Wall

A 13-foot ladder leans against a wall. The bottom slides away from the wall at $2\text{ ft/s}$. Find how fast the top of the ladder is sliding down when the bottom is $5$ feet from the wall.

The relating equation comes from the Pythagorean theorem, where $x$ is the distance from the wall to the ladder's base, and $y$ is the height of the ladder's top:

$$x^2 + y^2 = 13^2 = 169$$

Differentiating with respect to $t$:

$$2x\frac{dx}{dt} + 2y\frac{dy}{dt} = 0$$

At the instant in question, $x = 5$, so $y = \sqrt{169-25} = \sqrt{144} = 12$. Substituting $x=5$, $y=12$, $\dfrac{dx}{dt}=2$:

$$2(5)(2) + 2(12)\frac{dy}{dt} = 0$$

$$20 + 24\frac{dy}{dt} = 0 \implies \frac{dy}{dt} = -\frac{20}{24} = -\frac{5}{6} \text{ ft/s}$$

The negative sign indicates the top of the ladder is sliding **down** at $\frac{5}{6}\text{ ft/s}$.

### Visualizing the Ladder Problem

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 480 320">
  <text x="240" y="25" font-size="16" font-weight="bold" text-anchor="middle" fill="#1a1a1a">Related Rates: Sliding Ladder (svg_diagram)</text>

  
  <line x1="80" y1="60" x2="80" y2="270" stroke="#333" stroke-width="3" />
  <line x1="80" y1="270" x2="420" y2="270" stroke="#333" stroke-width="3" />

  
  <line x1="80" y1="90" x2="280" y2="270" stroke="#2563eb" stroke-width="4" />

  
  <text x="60" y="180" font-size="12" fill="#1e3a8a">y (height)</text>
  <text x="170" y="290" font-size="12" fill="#1e3a8a">x (distance)</text>

  
  <line x1="280" y1="270" x2="330" y2="270" stroke="#dc2626" stroke-width="2" marker-end="url(#arrowR)" />
  <text x="335" y="265" font-size="11" fill="#dc2626">dx/dt = 2 ft/s</text>

  <line x1="80" y1="90" x2="80" y2="130" stroke="#059669" stroke-width="2" marker-end="url(#arrowR2)" />
  <text x="90" y="120" font-size="11" fill="#065f46">dy/dt = -5/6 ft/s</text>

  <text x="240" y="305" font-size="12" text-anchor="middle" fill="#555">x² + y² = 13² relates the two rates via implicit differentiation</text>
</svg>

### Worked Example 3: Conical Tank

Water drains from a conical tank at a rate of $2\text{ m}^3/\text{min}$. The tank has a height of $6\text{ m}$ and a top radius of $3\text{ m}$. Find the rate at which the water level is dropping when the water depth is $2\text{ m}$.

The volume of a cone is $V = \frac{1}{3}\pi r^2 h$. Since the tank's radius and height are proportional ($r/h = 3/6 = 1/2$, so $r = h/2$), substitute to express volume purely in terms of $h$:

$$V = \frac{1}{3}\pi\left(\frac{h}{2}\right)^2 h = \frac{\pi h^3}{12}$$

Differentiating with respect to $t$:

$$\frac{dV}{dt} = \frac{\pi}{12} \cdot 3h^2 \cdot \frac{dh}{dt} = \frac{\pi h^2}{4}\frac{dh}{dt}$$

Substituting $\dfrac{dV}{dt} = -2$ (negative, since volume is decreasing) and $h=2$:

$$-2 = \frac{\pi (4)}{4}\frac{dh}{dt} = \pi \frac{dh}{dt}$$

$$\frac{dh}{dt} = -\frac{2}{\pi} \approx -0.637 \text{ m/min}$$

### Relevance to Machine Learning

- **Coupled parameter updates in optimization:** [Inference] When multiple model parameters or intermediate quantities are constrained by a shared relationship (for example, a normalization constraint that ties several values together), understanding how a rate of change in one quantity propagates to related quantities follows the same differentiation logic as related rates problems, though this framing is more of a conceptual analogy than a standard named technique in ML literature.
- **Sensitivity analysis in dynamical systems models:** Models that describe quantities evolving over time (e.g., certain time-series or physics-informed models) may involve differentiated constraint equations analogous to related rates problems, where the rate of change of one state variable is expressed in terms of another via a governing equation.
- **Chain rule as the shared foundation:** [Fact] Related rates problems are fundamentally an application of the chain rule and implicit differentiation with respect to a shared variable (time); this is the same mathematical machinery that underlies backpropagation, where gradients of a loss with respect to early-layer parameters are computed by chaining derivatives through intermediate quantities — though in backpropagation the "shared variable" role is played by the network's parameters rather than time.
- **Conservation and constraint-based training:** [Speculation] Some physics-informed or constraint-based machine learning models may incorporate related-rate-style differentiated constraints directly into their loss functions to enforce physically consistent relationships between predicted quantities during training; the specific formulations vary considerably across research approaches and this connection should be treated as a conceptual parallel rather than an established standard technique.

### Common Pitfalls

- **Substituting known numerical values too early:** Values for specific quantities (like $x=5$ in the ladder example) should only be substituted **after** differentiating the full equation — substituting first turns the equation into a static numerical fact with no rate information, since differentiating a constant produces zero.
- **Forgetting that all variables are implicitly functions of time:** Every quantity that changes over time must receive a $\frac{d(\cdot)}{dt}$ factor when differentiated, even if $t$ does not appear explicitly in the original equation.
- **Mismatched or missing units:** Since related rates problems combine multiple physical or contextual quantities, forgetting to track units consistently is a common source of errors.
- **Sign confusion for decreasing quantities:** Rates that represent a decrease (e.g., water draining, distance shrinking) must be entered as negative values in the corresponding derivative terms, as shown in the conical tank example.

### Conclusion

Related rates problems apply implicit differentiation to equations connecting multiple time-dependent quantities, allowing one unknown rate of change to be solved for in terms of known rates. While most commonly taught through classic geometric scenarios, the underlying technique — differentiating a constraint equation with respect to a shared variable using the chain rule — is conceptually the same mathematical machinery that underlies gradient propagation and constraint handling in more advanced machine learning contexts.

**Related Topics**
- Implicit differentiation techniques
- Chain rule and its role in backpropagation
- Physics-informed neural networks and differential constraints
- Multivariable calculus and partial derivatives
- Optimization under equality constraints
- Sensitivity analysis in dynamical systems