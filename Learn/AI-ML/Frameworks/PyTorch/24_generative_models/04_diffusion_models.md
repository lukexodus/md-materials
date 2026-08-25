## Diffusion Models


Diffusion models generate samples through a learned reverse denoising process, starting from pure noise and iteratively removing noise to produce high-quality samples. These models have achieved state-of-the-art results in image generation, surpassing GANs in sample quality and diversity metrics.

The forward diffusion process gradually adds Gaussian noise to data over multiple timesteps, eventually transforming the data distribution into pure noise. The reverse process learns to denoise samples, effectively reversing the forward corruption process.

### Denoising Diffusion Probabilistic Models (DDPMs)

DDPMs model the reverse process as a Markov chain with learned Gaussian transitions. The training objective involves predicting the noise added at each timestep, enabling the model to learn the score function (gradient of log probability) at different noise levels.

```python
def ddpm_loss(model, x_0, t, noise=None):
    if noise is None:
        noise = torch.randn_like(x_0)
    
    ## Forward process: add noise
    x_t = sqrt_alpha_cumprod[t] * x_0 + sqrt_one_minus_alpha_cumprod[t] * noise
    
    ## Predict noise
    predicted_noise = model(x_t, t)
    
    ## MSE loss between predicted and actual noise
    return F.mse_loss(predicted_noise, noise)
```

### Score-Based Generative Models

Score-based models learn the score function directly through denoising score matching, avoiding the need for explicit likelihood computation. These models use Langevin dynamics for sampling, iteratively following the gradient of the data distribution.

**Noise Conditional Score Networks (NCSNs)** train score networks at multiple noise levels, enabling effective sampling through annealed Langevin dynamics. The multi-scale approach addresses the challenge of score estimation in low-density regions.

### Sampling Algorithms

**DDPM Sampling** follows the learned reverse process, requiring hundreds or thousands of denoising steps for high-quality generation. Each step involves a neural network forward pass and Gaussian sampling.

**DDIM Sampling** (Denoising Diffusion Implicit Models) enables faster sampling by using deterministic reverse steps, reducing the required number of function evaluations while maintaining generation quality.

**Classifier-Free Guidance** enables conditional generation by training models that can operate both conditionally and unconditionally, using guidance scales to control the trade-off between sample quality and diversity.

**Key Points:**

- Diffusion models achieve superior sample quality compared to GANs on many benchmarks
- Training is more stable than adversarial approaches but requires significant computational resources
- Recent advances include faster sampling algorithms and improved conditioning mechanisms

