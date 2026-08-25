## Probabilistic Layers


Probabilistic layers extend standard neural network layers to incorporate uncertainty directly into the network architecture. These layers maintain distributions over parameters and activations, enabling uncertainty propagation throughout the network.

TFP provides several types of probabilistic layers: `DenseVariational` for fully connected layers with weight distributions, `Convolution2DVariational` for convolutional layers, and `DistributionLambda` for custom probabilistic transformations. These layers can be seamlessly integrated with standard Keras layers to create hybrid deterministic-probabilistic architectures.

The layers support different variational approximation strategies, from simple mean-field Gaussian to more complex structured approximations. They also handle the necessary KL regularization terms automatically, simplifying the construction of variational Bayesian networks.

**Key points**: Parameter and activation distributions, hybrid architectures, variational approximation strategies, automatic KL regularization, seamless Keras integration.

