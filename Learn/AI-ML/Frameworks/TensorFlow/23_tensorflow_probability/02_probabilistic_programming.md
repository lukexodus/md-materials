## Probabilistic Programming


Probabilistic programming in TensorFlow Probability allows you to define generative models using probability distributions as first-class objects. This paradigm enables the specification of complex probabilistic models where variables can be uncertain, and relationships between variables are expressed through conditional dependencies.

The programming model supports both forward sampling from generative models and inverse inference to estimate posterior distributions given observed data. TFP provides a rich ecosystem of probability distributions, from simple univariate distributions like Normal and Bernoulli to complex multivariate distributions like Multivariate Normal and Mixture distributions.

**Key points**: Generative model specification, conditional dependencies, forward and inverse inference, rich distribution ecosystem, integration with TensorFlow's automatic differentiation.

**Example**: Defining a simple Bayesian linear regression model where both weights and noise have prior distributions, and posterior inference is performed using observed data.

