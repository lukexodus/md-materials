## Mathematical Models and Their Components

### Definition and Conceptual Basis

A **mathematical model** is a formal representation of a system's structure and behavior using mathematical constructs — variables, equations, functions, and constraints — that permits analysis, prediction, and simulation without directly manipulating the real system. Mathematical models form the bridge between the conceptual system-theoretic framework (system, environment, interface, state) and the executable simulation code that produces numerical results.

Every mathematical model, regardless of its specific formalism, is built from a common set of components: variables, parameters, and the functional or equational relationships connecting them.

### Core Components of a Mathematical Model

**Variables** are quantities whose values change during the operation of the model and are classified according to their role:

- **State variables:** The minimal set of variables whose values at a given time, together with future inputs, fully determine the system's future behavior.
- **Input variables (exogenous variables):** Quantities imposed on the model from outside, not determined by the model's own internal relationships.
- **Output variables:** Quantities the model produces that are of interest for observation or that affect the environment.

**Parameters** are quantities that remain constant during a single simulation run (or over the period of interest) but that characterize the specific instance of the system being modelled — for example, a resistance value in a circuit model or a growth rate in a population model.

**Key Points**

- The same physical quantity can be classified as a parameter in one modelling context and a state variable in another, depending on whether its variation over the timescale of interest is considered relevant to the study.
- Choosing an appropriate, minimal set of state variables is central to good model design; an insufficient set fails to capture necessary dynamics, while an excessive set adds unnecessary complexity. [Inference]

### Functional Relationships

The core of a mathematical model is the set of functional relationships connecting variables and parameters. These generally take one of several forms:

- **Algebraic equations:** Direct functional relationships without derivatives or time-shifts, expressing instantaneous dependencies (e.g., $y = kx$).
- **Differential equations:** Relationships involving derivatives with respect to a continuous variable (typically time), used for continuous-time dynamic systems.
- **Difference equations:** Relationships involving variables at discrete time steps, used for discrete-time dynamic systems.
- **Logical/rule-based relationships:** Conditional or rule-based expressions determining state transitions, common in discrete-event and agent-based models.

**Key Points**

- The choice of relationship type follows directly from the system's classification along the time-representation axis (continuous, discrete-time, or discrete-event).
- A single model can combine multiple relationship types — for instance, a hybrid model combining differential equations for continuous dynamics with logical rules for discrete mode-switching.

### General Structure: State-Space Formulation

A widely used organizing structure for dynamic mathematical models is the **state-space formulation**, which explicitly separates state evolution from output generation:

$$\dot{x}(t) = f(x(t), u(t), \theta, t)$$



$$y(t) = g(x(t), u(t), \theta, t)$$

where $x(t)$ is the state vector, $u(t)$ is the input vector, $y(t)$ is the output vector, $\theta$ represents the parameter set, and $t$ is time. The first equation is the **state equation** (or transition function), and the second is the **output equation** (or observation function).

**Key Points**

- This structure directly parallels the formal system-theoretic definition $S = (T, X, \Omega, Y, Q, \delta, \lambda)$ introduced earlier, with $f$ corresponding to $\delta$ and $g$ corresponding to $\lambda$.
- Explicit dependence on $t$ in $f$ or $g$ indicates a time-varying system; its absence indicates time-invariance.
- Explicit dependence on $\theta$ highlights that model behavior is conditional on parameter values, motivating sensitivity analysis and calibration as essential modelling activities.

### Diagrammatic Representation: Model Component Relationships

===MERMAID_DIAGRAM===

flowchart LR

P["Parameters θ (svg_diagram)"] --> F["State Equation f"]

U["Input u(t)"] --> F

X["State x(t)"] --> F

F --> XD["State Derivative / Next State"]

P --> G["Output Equation g"]

U --> G

X --> G

G --> Y["Output y(t)"]

### Types of Mathematical Models by Formalism

| Model Type | Governing Structure | Typical Application |
| --- | --- | --- |
| Ordinary differential equation (ODE) models | $\dot{x} = f(x, u)$ | Population dynamics, circuits, mechanical systems |
| Partial differential equation (PDE) models | $\partial u/\partial t = f(u, \partial u/\partial \mathbf{x}, ...)$ | Heat diffusion, fluid flow, wave propagation |
| Difference equation models | $x_{k+1} = f(x_k, u_k)$ | Digital control systems, discrete population models |
| Algebraic/static models | $y = f(x)$, no time dependence | Steady-state analysis, input-output economic models |
| Discrete-event models | Event-driven state transition functions | Queueing systems, manufacturing lines, logistics |
| Agent-based / rule-based models | Local interaction rules per agent | Social dynamics, epidemiology, market simulation |
| Stochastic process models | Probability distributions governing transitions | Markov chains, random walks, Monte Carlo models |

### Example: Constructing a Simple Mathematical Model

Consider modelling the population of a single species with limited resources (logistic growth):

- **State variable:** Population size $N(t)$
- **Parameters:** Intrinsic growth rate $r$, carrying capacity $K$
- **Governing differential equation (state equation):**

$$\frac{dN}{dt} = rN\left(1 - \frac{N}{K}\right)$$

- **Output equation:** If the observed quantity is simply the population itself, $y(t) = N(t)$, making the output equation trivial (identity mapping).

This single equation encapsulates the full mathematical model: it specifies how the state variable evolves as a function of its own current value and two parameters, with no external input variable in this simplified case (a closed-system approximation, per the open/closed classification).

### Model Calibration and Parameter Estimation

Constructing a mathematical model's structure is distinct from determining the specific numerical values of its parameters, a process known as **calibration** or **parameter estimation**.

**Key Points**

- Calibration typically involves fitting model output to observed real-world data by adjusting parameter values to minimize a discrepancy measure (e.g., sum of squared errors).
- A model with correct structure but poorly calibrated parameters can still produce inaccurate predictions, underscoring that structural validity and parameter accuracy are separate concerns. [Inference]
- Over-parameterized models (too many free parameters relative to available data) risk overfitting, where the model fits historical data well but generalizes poorly to new conditions.

### Levels of Model Abstraction

Mathematical models exist along a spectrum of abstraction, trading fidelity against tractability:

- **Mechanistic (first-principles) models:** Derived from known physical, chemical, or biological laws (e.g., conservation of mass/energy, Newton's laws).
- **Empirical (data-driven) models:** Derived by fitting mathematical forms directly to observed data, without necessarily reflecting underlying causal mechanisms (e.g., regression models, curve fits).
- **Hybrid (grey-box) models:** Combine mechanistic structure for known relationships with empirical/data-driven components for poorly understood aspects.

**Key Points**

- Mechanistic models generally extrapolate more reliably beyond the range of observed data, since they are grounded in underlying causal laws rather than curve-fitting alone. [Inference]
- Empirical models can achieve high accuracy within the range of data used for fitting but carry greater risk when extrapolated outside that range.

### Model Complexity and Parsimony

**Key Points**

- The principle of parsimony favors the simplest mathematical model that adequately captures the phenomena of interest for the study's purpose, avoiding unnecessary complexity.
- Increasing model complexity (more state variables, more parameters, higher-order terms) generally improves fit to observed data but increases the risk of overfitting and reduces interpretability. [Inference]
- Model selection criteria (e.g., Akaike Information Criterion, Bayesian Information Criterion) formalize the trade-off between goodness of fit and model complexity in the context of statistical/empirical models.

### Common Pitfalls

- **Confusing correlation-based fits with mechanistic validity:** An empirical model that fits historical data well is not necessarily capturing the true causal structure of the system, and may fail under conditions outside the fitted data range.
- **Insufficient state variables:** Omitting a state variable that carries essential memory of past behavior, forcing the model to rely improperly on input history alone.
- **Parameter identifiability issues:** Attempting to estimate more independent parameters than the available data can support, leading to non-unique or unstable parameter estimates. [Inference]
- **Ignoring units and dimensional consistency:** Combining terms with mismatched units within a single equation, producing results that are numerically computable but physically meaningless.

**Related Topics**

- System Classification Schemes
- State-Space Representation and Transfer Functions
- Model Calibration and Parameter Estimation Techniques
- Numerical Integration Methods for Differential Equations
- Model Validation and Verification
- Sensitivity Analysis in Simulation Models
- Overfitting and Model Selection Criteria