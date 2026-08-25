## Module 7: Generative Adversarial Networks (GANs)


### 7.1 Foundations

- Two-player game framework
- Generator network: noise to data
- Discriminator network: real vs fake classification
- Adversarial training dynamics
- Nash equilibrium concept

### 7.2 Mathematical Formulation

- Minimax objective function
- Value function: theoretical analysis
- Optimal discriminator derivation
- Generator objective equivalence to JSD minimization
- Training algorithm: alternating optimization

### 7.3 Training Challenges

- Mode collapse: causes and symptoms
- Vanishing gradients for generator
- Training instability
- Convergence difficulties
- Evaluation metrics: IS, FID, precision/recall

### 7.4 GAN Variants & Improvements

- DCGAN: convolutional architecture, architectural guidelines
- Wasserstein GAN (WGAN): Wasserstein distance, weight clipping
- WGAN-GP: gradient penalty for Lipschitz constraint
- Progressive GAN: growing strategy for high resolution
- StyleGAN: style-based generator, adaptive instance normalization
- Conditional GAN (cGAN): class-conditional generation
- CycleGAN: unpaired image-to-image translation
- Pix2Pix: paired image-to-image translation

### 7.5 Advanced Topics

- Spectral normalization
- Self-attention in GANs (SAGAN)
- BigGAN: large-scale training
- Truncation trick
- Latent space manipulation
- GAN inversion

---

