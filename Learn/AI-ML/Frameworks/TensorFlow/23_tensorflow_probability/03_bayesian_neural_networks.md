## Bayesian Neural Networks


Bayesian neural networks extend traditional neural networks by treating weights as probability distributions rather than point estimates. This approach naturally quantifies model uncertainty and provides more robust predictions, especially in scenarios with limited data or out-of-distribution inputs.

TFP enables the construction of Bayesian neural networks through probabilistic layers that maintain distributions over parameters. These networks can express both aleatoric uncertainty (inherent noise in data) and epistemic uncertainty (uncertainty due to limited knowledge or data).

The implementation involves replacing deterministic layers with probabilistic counterparts, defining prior distributions over weights, and using variational inference or sampling methods to approximate posterior distributions. TFP provides built-in probabilistic layers and utilities for converting standard Keras layers into their Bayesian equivalents.

**Key points**: Weight distributions instead of point estimates, uncertainty quantification, aleatoric vs epistemic uncertainty, probabilistic layer replacements, variational approximations.

**Example**: Converting a standard dense neural network into a Bayesian version using `tfp.layers.DenseVariational`, with prior and posterior distributions over weights.

