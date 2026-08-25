## Markov Chain Monte Carlo


Markov Chain Monte Carlo (MCMC) methods in TensorFlow Probability provide exact sampling from posterior distributions, offering an alternative to variational approximations when computational resources permit more intensive sampling procedures.

TFP includes several MCMC algorithms: Hamiltonian Monte Carlo (HMC) for continuous variables, No-U-Turn Sampler (NUTS) as an adaptive version of HMC, Metropolis-Hastings for general proposals, and specialized samplers for specific distribution families. The library also supports advanced techniques like parallel tempering and replica exchange.

The MCMC framework is designed for automatic differentiation compatibility, enabling gradient-based samplers that can efficiently explore high-dimensional posterior distributions. TFP provides diagnostic tools for assessing chain convergence, effective sample size calculation, and potential scale reduction factors.

**Key points**: Exact posterior sampling, HMC and NUTS algorithms, gradient-based exploration, convergence diagnostics, parallel tempering, automatic differentiation integration.

**Example**: Using NUTS to sample from a hierarchical Bayesian model posterior, with automatic step size adaptation and convergence monitoring.

