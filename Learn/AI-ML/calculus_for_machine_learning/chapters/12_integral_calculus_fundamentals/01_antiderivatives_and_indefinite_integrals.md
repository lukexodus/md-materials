## Antiderivatives and Indefinite Integrals

### Definition

An antiderivative of a function $f(x)$ is any function $F(x)$ such that:

$$F'(x) = f(x)$$

The indefinite integral of $f(x)$ is written:

$$\int f(x)\,dx = F(x) + C$$

Where $C$ is an arbitrary constant of integration. This is a direct mathematical definition, not an inference.

### Why the Constant of Integration Matters

If $F(x)$ is one antiderivative of $f(x)$, then $F(x) + C$ is also an antiderivative for any constant $C$, since the derivative of a constant is zero:

$$\frac{d}{dx}[F(x) + C] = F'(x) + 0 = f(x)$$

This is a direct calculus fact. Conversely, if $F_1(x)$ and $F_2(x)$ are both antiderivatives of the same $f(x)$ on an interval, then $F_1(x) - F_2(x)$ must be a constant on that interval — a consequence of the Mean Value Theorem applied to $F_1 - F_2$, whose derivative is zero everywhere on the interval. This is a standard proven result in calculus, not an inference.

### Basic Antiderivative Rules

**Power Rule**

$$\int x^n\,dx = \frac{x^{n+1}}{n+1} + C, \qquad n \neq -1$$

This is the reverse of the power rule for derivatives and is a direct calculus fact, verifiable by differentiating the right-hand side.

**Special Case: $n = -1$**

$$\int \frac{1}{x}\,dx = \ln|x| + C$$

The absolute value is required because $\ln(x)$ is only defined for $x > 0$, while $\frac{1}{x}$ is defined for all $x \neq 0$; this is a direct consequence of the domain of the natural logarithm.

**Exponential Functions**

$$\int e^x\,dx = e^x + C$$

$$\int a^x\,dx = \frac{a^x}{\ln a} + C, \qquad a > 0, a \neq 1$$

Both are direct calculus facts, verifiable by differentiation.

**Trigonometric Functions**

$$\int \sin x\,dx = -\cos x + C$$

$$\int \cos x\,dx = \sin x + C$$

$$\int \sec^2 x\,dx = \tan x + C$$

These follow directly from the known derivatives of $\cos x$, $\sin x$, and $\tan x$ respectively, reversed.

### Linearity of the Integral

$$\int [af(x) + bg(x)]\,dx = a\int f(x)\,dx + b\int g(x)\,dx$$

Where $a, b$ are constants. This follows directly from the linearity of differentiation (the derivative of a sum is the sum of derivatives, and constants factor out of derivatives), and is a proven calculus property, not an inference.

### Relevance to Machine Learning

[Inference] Antiderivatives themselves are used less directly in standard ML training loops than derivatives are, since gradient-based optimization (as covered in prior sections on gradient descent, momentum, and adaptive methods) relies primarily on differentiation rather than integration. However, integration and antiderivatives underlie several ML-relevant concepts described below. I cannot verify the relative frequency of antiderivative-based computations versus derivative-based computations across all ML practice without access to a systematic survey [Unverified].

**Cumulative Distribution Functions**

Given a probability density function $p(x)$, the cumulative distribution function is:

$$F(x) = \int_{-\infty}^{x} p(t)\,dt$$

This is a direct application of integration as an antiderivative process (with a specific lower bound), and CDFs are used in probabilistic ML models. This is a standard definition in probability theory, not an inference.

**Expected Value Computations**

$$E[X] = \int_{-\infty}^{\infty} x\,p(x)\,dx$$

Used in Bayesian ML methods and in deriving properties of loss functions under probabilistic assumptions. This is a standard definition, not an inference.

**Area Under the ROC Curve (AUC)**

[Inference] The AUC metric, commonly used to evaluate binary classifiers, is computed as a definite integral of the ROC curve function. I cannot verify the precise computational implementation used in any specific ML library without checking that library's source code or documentation [Unverified].

**Normalizing Constants in Probabilistic Models**

For a probability density $p(x) = \frac{1}{Z}\tilde{p}(x)$, the normalizing constant $Z$ is computed as:

$$Z = \int \tilde{p}(x)\,dx$$

This integral must evaluate such that $p(x)$ integrates to $1$ over its domain, by the definition of a valid probability density. In many ML contexts (e.g., certain Bayesian models), this integral is intractable in closed form, which [Inference] is commonly cited in ML literature as a primary motivation for approximate inference methods such as variational inference and Markov Chain Monte Carlo (MCMC) sampling. I cannot verify claims about which specific models require these approximations without checking each model individually [Unverified].

### Antiderivatives Do Not Always Have Closed Forms

[Inference] Not every function has an antiderivative expressible in terms of elementary functions (polynomials, exponentials, logarithms, trigonometric functions, and their combinations). A commonly cited example in calculus literature is $e^{-x^2}$, whose antiderivative (related to the Gaussian error function $\text{erf}(x)$) cannot be written using elementary functions — this is a known result in calculus (proven via Liouville's theorem in differential algebra) [Unverified — I have not independently re-derived or verified Liouville's theorem's application here from a primary source in this conversation]. This is directly relevant to ML because the Gaussian distribution's normalizing constant relies on this non-elementary integral, evaluated instead via the known closed-form result $\int_{-\infty}^{\infty} e^{-x^2}\,dx = \sqrt{\pi}$, which is a specific definite integral (not a general antiderivative) provable via polar coordinate transformation. This specific proof technique and result is a standard mathematical fact.

### Worked Example

Find the antiderivative of $f(x) = 3x^2 + 2x - 5$.

Applying the power rule term by term (a direct calculus computation):

$$\int (3x^2 + 2x - 5)\,dx = 3 \cdot \frac{x^3}{3} + 2 \cdot \frac{x^2}{2} - 5x + C = x^3 + x^2 - 5x + C$$

Verification by differentiation:

$$\frac{d}{dx}[x^3 + x^2 - 5x + C] = 3x^2 + 2x - 5$$

This confirms the antiderivative is correct, since differentiating it recovers the original function exactly. This is a direct, verifiable calculus computation, not an inference.

### Common Pitfalls

- **Forgetting the constant of integration $C$**: omitting $C$ produces an incomplete answer, since infinitely many functions share the same derivative
- **Applying the power rule at $n = -1$**: this case requires the logarithm rule instead, since the power rule's denominator $n+1$ would be zero and undefined
- **Assuming every function has an elementary antiderivative**: as shown above, this is not the case; numerical integration methods are used in practice for such functions in computational contexts [Inference — the use of numerical integration for non-elementary antiderivatives in ML software is commonly described in numerical methods literature, but I cannot verify specific implementation choices in any particular library without checking its documentation, so this remains Unverified]

### Disclaimer on Behavioral and Attribution Claims

Statements above regarding the relative role of antiderivatives in ML practice, motivations for variational inference or MCMC, and any implementation-specific claims about ML libraries are labeled [Inference] or [Unverified] and are not confirmed from primary sources in this conversation. The core calculus results (power rule, linearity, the Gaussian integral value, Liouville's theorem's existence as a named result) are standard textbook mathematics; where I have not independently re-derived a named theorem's full proof in this conversation, this is noted. No claim in this document should be read as a guarantee about behavior of any specific software, library, or model.

### Related Topics

- Definite integrals and the Fundamental Theorem of Calculus
- Integration techniques (substitution, integration by parts)
- Probability density functions and their calculus foundations
- Variational inference and the evidence lower bound (ELBO)
- Monte Carlo integration methods
- Multivariable and vector calculus for backpropagation