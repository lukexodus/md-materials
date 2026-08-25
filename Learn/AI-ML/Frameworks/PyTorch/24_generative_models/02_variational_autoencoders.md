## Variational Autoencoders


Variational Autoencoders (VAEs) combine deep learning with variational Bayesian inference to learn probabilistic representations of data. VAEs encode input data into a latent distribution rather than fixed points, enabling controlled generation through sampling from the learned latent space.

The VAE architecture consists of an encoder network that maps inputs to latent distribution parameters (mean and variance) and a decoder network that reconstructs data from latent samples. The training objective combines reconstruction loss with a regularization term (KL divergence) that encourages the latent distribution to match a prior distribution.

### Mathematical Foundation

The VAE optimizes the Evidence Lower BOund (ELBO), which provides a tractable approximation to the intractable marginal likelihood. The ELBO decomposes into reconstruction accuracy and KL divergence between the approximate posterior and prior distributions.

```python
def vae_loss(x, x_recon, mu, log_var):
    ## Reconstruction loss (binary cross-entropy or MSE)
    recon_loss = F.binary_cross_entropy(x_recon, x, reduction='sum')
    
    ## KL divergence loss
    kl_loss = -0.5 * torch.sum(1 + log_var - mu.pow(2) - log_var.exp())
    
    return recon_loss + kl_loss
```

### Reparameterization Trick

The reparameterization trick enables backpropagation through stochastic sampling by expressing random samples as deterministic functions of parameters and auxiliary noise variables. This technique transforms the stochastic computation graph into a deterministic one while maintaining the distributional properties.

### Advanced VAE Variants

**β-VAEs** introduce a weighting parameter β for the KL divergence term, controlling the trade-off between reconstruction quality and latent space regularity. Higher β values encourage more disentangled representations but may reduce reconstruction quality.

**Conditional VAEs (CVAEs)** incorporate additional conditioning information to enable controlled generation based on class labels, attributes, or other structured information.

**Vector Quantized VAEs (VQ-VAEs)** replace continuous latent variables with discrete representations through vector quantization, enabling autoregressive modeling of latent codes and improved sample quality.

**Key Points:**

- VAEs provide interpretable latent representations suitable for data exploration and manipulation
- The probabilistic framework enables uncertainty quantification and controlled sampling
- Applications include dimensionality reduction, data generation, and representation learning

