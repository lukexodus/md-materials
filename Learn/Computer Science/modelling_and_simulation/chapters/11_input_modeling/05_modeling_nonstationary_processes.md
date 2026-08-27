## Modeling Nonstationary Processes

### Overview

A nonstationary process is a stochastic input whose statistical properties — most commonly its rate, mean, or variance — change systematically over the simulated time horizon, rather than remaining constant. Modeling nonstationary processes correctly is critical in simulations where activity levels genuinely fluctuate over the period being studied, such as call center arrivals that peak at midday, retail traffic that surges seasonally, or hospital admissions that vary by hour and day of week. Treating a nonstationary process as if it were stationary (constant-rate) is one of the more consequential input-modeling errors, since it can systematically mis-estimate congestion during peak periods even if the time-averaged rate is correctly captured.

### Stationary vs. Nonstationary Processes

**Key Points**

- A **stationary process** has statistical properties (mean, variance, rate) that do not change over time; a homogeneous Poisson process with constant rate $\lambda$ is the canonical stationary arrival model.
- A **nonstationary process** has properties that vary with time; a nonhomogeneous Poisson process with time-varying rate $\lambda(t)$ is the canonical example for arrival streams.
- Using the overall average rate $\bar{\lambda}$ from a nonstationary process to drive a stationary model in simulation understates peak congestion and overstates off-peak congestion, distorting metrics like maximum queue length or worst-case waiting time.
- Nonstationarity can appear in interarrival rates, service rates, resource availability (e.g., staffing schedules), and demand levels simultaneously, and each may need separate treatment.

### Detecting Nonstationarity

Before modeling a process as nonstationary, its presence should be confirmed rather than assumed:

- **Time-series plot of counts per interval** — plotting arrival counts (or another rate-like quantity) in fixed time buckets (e.g., hourly) across the observation period; a clear repeating or trending pattern indicates nonstationarity.
- **Chi-square test of homogeneity** — formally tests whether counts across different time intervals are consistent with a single constant rate.
- **Autocorrelation and trend inspection** — checking whether rate estimates from adjacent time periods are systematically related (trend, cyclicality) rather than fluctuating randomly around a constant mean.
- **Domain knowledge** — many real-world arrival and demand processes are known a priori to vary by time of day, day of week, or season, and can be assumed nonstationary from process understanding alone even before formal testing.

### The Nonhomogeneous Poisson Process (NHPP)

#### Definition

The Nonhomogeneous Poisson Process generalizes the standard (homogeneous) Poisson process by allowing the arrival rate $\lambda(t)$ to vary as a function of time $t$, while retaining the Poisson process's independent-increments property.

The expected number of arrivals in $[0, t]$ is given by the integrated rate function:

$$\Lambda(t) = \int_0^t \lambda(u)\, du$$

The number of arrivals in an interval $[t_1, t_2]$ follows a Poisson distribution with mean $\Lambda(t_2) - \Lambda(t_1)$:

$$P\big(N(t_2) - N(t_1) = k\big) = \frac{\big[\Lambda(t_2)-\Lambda(t_1)\big]^k \, e^{-[\Lambda(t_2)-\Lambda(t_1)]}}{k!}$$

#### Estimating the Rate Function

**Piecewise-Constant Rate Estimation**

The most common practical approach divides the observation period into fixed subintervals (e.g., hourly buckets) and estimates a separate constant rate $\hat{\lambda}_i$ for each subinterval $i$ from historical counts:

$$\hat{\lambda}_i = \frac{\text{average count in interval } i}{\text{length of interval } i}$$

**Key Points**

- Simple to compute and widely supported in simulation software as a direct input specification (a rate table).
- Interval width involves a bias-variance trade-off: narrower intervals track real rate changes more precisely but produce noisier estimates from fewer observations per interval; wider intervals smooth noise but can mask genuine rate fluctuations within the interval.
- Discontinuities at interval boundaries are an artifact of the piecewise-constant approximation, not necessarily a feature of the true underlying process.

**Smooth Rate Function Estimation**

Alternative approaches fit a continuous, smooth function $\lambda(t)$ rather than a step function:

- **Polynomial or trigonometric (Fourier) regression** — fits a smooth curve capturing daily or seasonal cyclicality without artificial discontinuities.
- **Kernel smoothing** — estimates $\lambda(t)$ as a locally weighted average of nearby observed counts, avoiding a fixed parametric form.
- **Spline-based methods** — piecewise polynomial fits with continuity constraints at knot points, offering a compromise between full parametric smoothness and local flexibility.

[Inference] Smooth rate estimation methods are more commonly used in academic and specialized simulation research than in routine industrial practice, where piecewise-constant rate tables remain the dominant approach due to their simplicity and direct compatibility with common simulation software.

### Generating Variates from a Nonhomogeneous Poisson Process

#### Thinning (Acceptance-Rejection) Algorithm

The thinning method generates NHPP arrivals by first generating arrivals from a homogeneous Poisson process at a rate at least as high as the maximum of $\lambda(t)$, then probabilistically discarding ("thinning") candidate arrivals:

1. Let $\lambda^* = \max_t \lambda(t)$ over the simulation horizon.
2. Generate candidate arrival times from a homogeneous Poisson process with rate $\lambda^*$.
3. For each candidate arrival at time $t$, accept it with probability $\dfrac{\lambda(t)}{\lambda^*}$; otherwise discard it.

**Key Points**

- Conceptually simple and exact (produces statistically correct NHPP variates), given a correctly specified $\lambda(t)$.
- Computationally inefficient when $\lambda(t)$ varies substantially, since a large fraction of candidate arrivals may be discarded during low-rate periods, wasting generated random numbers.

#### Inverse Transform (via Integrated Rate Function)

An alternative method inverts the integrated rate function $\Lambda(t)$ directly:

1. Generate a homogeneous Poisson process of arrivals with rate 1 in "integrated time," i.e., generate $E_1, E_2, \dots$ as cumulative sums of Exponential(1) interarrival times.
2. Transform each cumulative value $E_i$ back to real time via $\Lambda^{-1}(E_i)$.

This method avoids the rejection inefficiency of thinning but requires that $\Lambda(t)$ be invertible, which is straightforward for piecewise-constant rate functions and some smooth parametric forms, but may require numerical inversion for arbitrary $\lambda(t)$.

### Rate Function Estimation and Generation Workflow

```mermaid
flowchart TD
    A[Collect time-stamped event data] --> B[Bucket into fixed intervals or fit smooth curve]
    B --> C{Piecewise-constant or smooth rate function?}
    C -- Piecewise-constant --> D[Estimate rate per interval: count / interval length]
    C -- Smooth --> E[Fit polynomial, Fourier, kernel, or spline model]
    D --> F[Assemble integrated rate function Lambda(t)]
    E --> F
    F --> G{Generation method}
    G -- Thinning --> H[Generate homogeneous candidates at max rate, accept/reject]
    G -- Inverse transform --> I[Generate Exponential(1) cumulative sums, invert Lambda(t)]
    H --> J[NHPP arrival stream for simulation]
    I --> J
```

### Beyond Arrival Processes: Other Nonstationary Inputs

**Key Points**

- **Time-varying service rates** — server efficiency may degrade over a shift (fatigue) or improve with experience (learning curve effects); these can be modeled with a time-indexed service rate similar to $\lambda(t)$ for arrivals.
- **Time-varying resource availability** — staffing levels, machine availability, or capacity may follow known schedules (e.g., more staff scheduled during forecasted peak hours), which interacts directly with nonstationary arrival modeling and must be represented explicitly in the simulation logic rather than folded into the arrival rate alone.
- **Seasonal and trend components in demand** — longer-horizon simulations (e.g., annual capacity planning) may need to model both within-day nonstationarity and across-day or across-season trends simultaneously, often requiring a multiplicative or additive decomposition of the rate function into daily, weekly, and seasonal components.

### Validating a Nonstationary Input Model

- Compare the fitted rate function $\hat{\lambda}(t)$ visually against the raw binned counts to confirm the model captures the observed pattern without excessive over- or under-smoothing.
- Generate synthetic arrival streams from the fitted NHPP and compare their binned counts per interval against the historical binned counts using a goodness-of-fit test per interval or overall.
- Check that simulation outputs sensitive to peak timing (e.g., maximum queue length, time of worst delay) occur at realistic times of day when compared against historical operational knowledge, not only that aggregate output statistics match.

### Common Pitfalls

- **Using a single time-averaged rate** — collapsing a nonstationary process into one overall constant rate is the most common and most consequential error, since it erases exactly the peak-load information that nonstationary modeling exists to capture.
- **Choosing interval width arbitrarily** — selecting piecewise-constant interval widths without checking the bias-variance trade-off can either mask real peaks (too wide) or introduce estimation noise mistaken for genuine rate variation (too narrow).
- **Ignoring the interaction between nonstationary arrivals and nonstationary resources** — modeling time-varying demand without also representing time-varying staffing or capacity (when both actually vary together, e.g., staff scheduled in anticipation of demand) can produce a misleading picture of congestion.
- **Assuming a parametric smooth form fits without checking** — imposing a Fourier or polynomial rate function without validating residual fit can obscure real irregularities, such as a one-time event or holiday effect, that a smooth curve is not designed to capture.
- **Treating the thinning algorithm's maximum rate incorrectly** — underestimating $\lambda^* = \max_t \lambda(t)$ (e.g., from a sample that did not include the true peak period) produces an invalid, biased NHPP generation process.

### Next Steps

**Related Topics**

- Nonhomogeneous Poisson Process Estimation with Sparse or Multi-Year Data
- Modeling Learning and Fatigue Effects in Service Processes
- Seasonal Decomposition Techniques for Long-Horizon Simulation Inputs
- Combining Nonstationary Arrivals with Time-Varying Staffing Models
- Goodness-of-Fit Testing for Time-Varying Rate Functions
- Rare Event and Holiday-Effect Modeling in Demand Forecasting for Simulation