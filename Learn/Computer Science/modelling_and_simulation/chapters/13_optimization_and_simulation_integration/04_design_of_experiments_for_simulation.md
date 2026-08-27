## Design of Experiments for Simulation

### Definition and Purpose

Design of Experiments (DOE) for simulation refers to the systematic planning of which combinations of input factor values ("design points") to run through a simulation model, in order to extract maximum information about the system's behavior while minimizing the number of expensive simulation runs required. Unlike physical experiments, simulation experiments have no measurement error from instrumentation, but they typically retain **stochastic noise** from the simulation's own random number generation — unless that randomness is deliberately controlled. DOE provides the structure needed to separate the effects of individual input factors, detect interactions between factors, and build predictive metamodels of simulation output, rather than relying on ad hoc or one-factor-at-a-time experimentation.

### Why DOE Matters in Simulation Contexts

Simulation models often have many input factors (arrival rates, service rates, routing probabilities, resource capacities, control parameters), and each simulation run can be computationally expensive. Running every combination of every factor at every level (a full factorial design) becomes infeasible as the number of factors grows, since the number of required runs grows exponentially:

$$N = L^k$$

where $L$ is the number of levels per factor and $k$ is the number of factors. DOE techniques exist specifically to reduce this run count while preserving the ability to estimate the effects that matter most — main effects and, where relevant, interaction effects — and to do so in the presence of simulation output noise.

### Key Terminology

- **Factor** — an input variable to the simulation model that the experimenter controls (e.g., number of servers, arrival rate, buffer size).
- **Level** — a specific value or setting assigned to a factor within the experiment (e.g., "low" and "high" arrival rates).
- **Response** — the simulation output being measured (e.g., average waiting time, throughput, utilization).
- **Design Point** — a specific combination of factor levels at which the simulation is run.
- **Replication** — repeated runs of the simulation at the same design point using independent random number streams, used to estimate the variability of the response.
- **Main Effect** — the average change in response caused by changing a single factor's level, averaged across all levels of other factors.
- **Interaction Effect** — the degree to which the effect of one factor depends on the level of another factor.

### Full Factorial Designs

A full factorial design evaluates every possible combination of factor levels. For $k$ factors each at 2 levels, this is denoted a $2^k$ factorial design, requiring $2^k$ design points (before replication). Full factorial designs allow estimation of all main effects and all interaction effects (two-way, three-way, and higher-order), making them the most informationally complete design type. Their major drawback is scalability: a modest 7-factor, 2-level design already requires $2^7 = 128$ design points, and simulation replication multiplies that further.

### Fractional Factorial Designs

Fractional factorial designs deliberately run only a carefully chosen subset (a "fraction," such as $\frac{1}{2}$ or $\frac{1}{4}$) of the full factorial combinations, selected so that lower-order effects (main effects and, often, two-way interactions) remain estimable, at the cost of confounding certain higher-order interaction effects with each other or with lower-order effects. This confounding structure is described by the design's **resolution**:

- **Resolution III** — main effects are not confounded with each other, but may be confounded with two-way interactions.
- **Resolution IV** — main effects are not confounded with two-way interactions, but two-way interactions may be confounded with each other.
- **Resolution V** — main effects and two-way interactions are all estimable without mutual confounding.

Fractional factorial designs are widely used in simulation studies as a **screening** step: identifying which factors (out of a potentially large candidate set) have practically significant effects on the response, before committing further simulation budget to a detailed study of those factors alone.

### Screening Designs

When the number of candidate factors is large (often dozens), even fractional factorial designs may be too costly. **Plackett-Burman designs** are a class of highly efficient screening designs that estimate main effects using a number of runs close to a multiple of 4, substantially fewer than a full or fractional factorial would require, at the cost of heavily confounding interaction effects with main effects. Their purpose is purely to identify the small subset of factors that matter most (following the empirical heuristic that a small fraction of factors typically account for most of the variation in response — an instance of the sparsity-of-effects principle), not to characterize those factors' effects precisely.

```mermaid
flowchart LR
    A[Large candidate factor set] --> B[Screening Design<br/>e.g. Plackett-Burman, Fractional Factorial]
    B --> C[Identify significant factors]
    C --> D[Response Surface Design<br/>e.g. Central Composite, Box-Behnken]
    D --> E[Fitted metamodel of response]
    E --> F[Optimization / further analysis]
```

### Response Surface Designs

Once significant factors have been identified through screening, response surface designs are used to characterize the shape of the response function in more detail — particularly curvature — over a localized region of interest.

- **Central Composite Design (CCD)** — augments a factorial (or fractional factorial) design with axial ("star") points and center points, allowing estimation of a full second-order (quadratic) polynomial model, including curvature terms. Widely used in Response Surface Methodology.
- **Box-Behnken Design** — an alternative second-order design that avoids extreme corner combinations of factor levels (useful when such combinations are physically implausible or represent unrealistic operating conditions in the simulated system), using fewer design points than a comparable CCD in some configurations.

The fitted second-order model typically takes the form:

$$\hat{y}(x) = \beta_0 + \sum_{i=1}^k \beta_i x_i + \sum_{i=1}^k \beta_{ii} x_i^2 + \sum_{i<j} \beta_{ij} x_i x_j$$

### Space-Filling Designs

Factorial and response-surface designs are built around the assumption of a relatively simple (often polynomial) underlying response function. When the simulation's response surface is expected to be highly nonlinear, non-monotonic, or entirely unknown in shape — common in complex simulation metamodeling contexts — **space-filling designs** are preferred instead. These designs distribute design points as evenly as possible across the entire input space, without assuming any particular functional form.

- **Latin Hypercube Sampling (LHS)** — divides each factor's range into $N$ equally probable intervals and samples exactly one value from each interval per factor, then randomly pairs these values across factors, ensuring good coverage of each factor's marginal range with relatively few design points. LHS is widely used as the input design for building Kriging and other nonparametric metamodels.
- **Orthogonal Arrays** — structured designs ensuring that, for any pair of factors, all combinations of their levels appear an equal number of times, providing balanced coverage useful for both screening and metamodeling purposes.

### Handling Stochastic Noise in Simulation DOE

Because most simulations are stochastic, the response observed at a given design point is a random variable, not a fixed value. DOE for simulation must therefore explicitly account for this in ways that physical DOE (often assuming fixed, small measurement error) does not always emphasize as heavily:

- **Replication** — running multiple independent replications at each design point (using different random number seeds) to estimate both the mean response and its variance, enabling statistically valid effect estimates and confidence intervals.
- **Common Random Numbers (CRN)** — using the same random number streams across different design points to reduce the variance of *differences* between design points, improving the precision of estimated effects for a fixed number of replications. This is particularly valuable in factorial designs where the primary quantities of interest are effect estimates (differences between levels).
- **Variance Reduction Techniques** — antithetic variates and control variates can be layered onto a DOE structure to further reduce the number of replications needed to achieve a target precision on effect estimates.

### Metamodeling as a DOE Outcome

A common downstream goal of simulation DOE is to fit a **metamodel** (also called a surrogate model) — an approximate, computationally cheap mathematical representation of the simulation's input-output relationship, built from the data collected at the design points. Common metamodel forms include:

- **Linear and polynomial regression models** — fitted directly from factorial or response-surface design data.
- **Kriging (Gaussian process) models** — fitted from space-filling design data, providing both predictions and uncertainty quantification at untested points.
- **Neural network metamodels** — used when very large or highly nonlinear input-output relationships are being approximated, typically requiring larger space-filling designs to train adequately. [Inference — the design size needed for adequate neural network metamodel training is problem- and architecture-dependent, without a universal minimum sample size rule.]

Once fitted, the metamodel can be used in place of the original (expensive) simulation for tasks such as sensitivity analysis, optimization, or what-if exploration, subject to validation against held-out simulation runs to confirm the metamodel's predictive accuracy.

### Sequential and Adaptive Experimental Designs

Rather than fixing the entire experimental design in advance, sequential designs allocate simulation runs adaptively, using information from earlier runs to decide where to sample next. This is especially valuable in simulation-optimization and Bayesian optimization contexts, where the region of interest (e.g., near a suspected optimum) is not known before any data is collected. **Expected Improvement**-based sequential sampling, used within Bayesian optimization, is one such adaptive design strategy, selecting the next design point to maximize the expected improvement over the current best-known response.

### Design Selection Considerations

| Design Type | Best Suited For | Number of Runs | Assumes Response Shape |
| --- | --- | --- | --- |
| Full Factorial | Small number of factors, all interactions needed | Exponential in $k$ | None (fully general within levels tested) |
| Fractional Factorial | Moderate factor count, screening with some interaction resolution | Fraction of full factorial | Higher-order interactions negligible |
| Plackett-Burman | Large factor count, pure screening | ~multiple of 4 | Main effects dominate (sparsity of effects) |
| Central Composite / Box-Behnken | Few significant factors, need curvature | Moderate | Quadratic (second-order) |
| Latin Hypercube / Space-Filling | Complex, unknown response shape, metamodeling | Flexible, scalable | None assumed |

### Applications in Simulation Studies

- **Screening large-scale simulation models** — identifying which of dozens of input parameters materially affect system performance before detailed analysis.
- **Building metamodels for real-time decision support** — replacing slow simulations with fast Kriging or regression surrogates for interactive what-if tools.
- **Supporting simulation-optimization** — generating the design points used in Response Surface Methodology or as initial training data for Bayesian optimization.
- **Sensitivity analysis** — quantifying how much each input factor and factor interaction contributes to output variability.
- **Robustness and risk analysis** — exploring simulation response across a wide range of operating conditions to identify vulnerable regions of the input space.

### Key Points

- DOE for simulation exists to extract maximum information about factor effects while minimizing the number of computationally expensive simulation runs.
- Screening designs (fractional factorial, Plackett-Burman) are used first when many candidate factors exist, exploiting the sparsity-of-effects principle to narrow down significant factors cheaply.
- Response surface designs (CCD, Box-Behnken) characterize curvature in a localized region once significant factors are known.
- Space-filling designs (Latin Hypercube Sampling) are preferred when the response shape is unknown or highly nonlinear, and are the standard input design for Kriging and other nonparametric metamodels.
- Because simulation output is typically stochastic, replication and common random numbers are essential complements to any DOE structure, distinguishing simulation DOE from purely deterministic experimental design.
- The end product of simulation DOE is frequently a metamodel, which substitutes for the original simulation in downstream optimization, sensitivity analysis, or interactive exploration tasks.

### Related Topics

- Response Surface Methodology
- Kriging and Gaussian Process metamodeling
- Sensitivity analysis techniques (variance-based, screening-based)
- Common Random Numbers and variance reduction
- Bayesian optimization and sequential design
- Metamodel validation techniques