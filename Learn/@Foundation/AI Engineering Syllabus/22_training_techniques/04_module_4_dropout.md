## Module 4: Dropout


### 4.1 Foundations & Motivation

- Co-adaptation problem
- Ensemble interpretation
- Stochastic regularization
- Model averaging perspective

### 4.2 Standard Dropout

#### 4.2.1 Mechanism

- Bernoulli mask sampling: probability p
- Forward pass: neuron dropping
- Backward pass: gradient masking
- Inverted dropout: scaling during training
- Standard dropout: scaling during inference

#### 4.2.2 Mathematical Formulation

- Dropout as stochastic variable multiplication
- Expectation during inference
- Variance introduced by dropout
- Scaling factor: 1/(1-p) derivation

#### 4.2.3 Training vs Inference

- Stochastic forward passes during training
- Deterministic inference: all units active
- Monte Carlo dropout: multiple inference passes
- Uncertainty estimation through dropout

### 4.3 Dropout Rate Selection

#### 4.3.1 Layer-Specific Rates

- Common values: 0.2-0.5
- Input layer dropout: lower rates (0.1-0.2)
- Hidden layer dropout: moderate rates (0.5)
- Output layer considerations
- [Inference] Network depth effects

#### 4.3.2 Hyperparameter Tuning

- Validation-based selection
- Relationship to network capacity
- Task-dependent recommendations
- Over-regularization symptoms

### 4.4 Dropout Variants

#### 4.4.1 DropConnect

- Weight dropping vs neuron dropping
- Mask applied to connections
- Increased stochasticity
- Implementation complexity

#### 4.4.2 Spatial Dropout

- Dropping entire feature maps (CNNs)
- 2D/3D dropout for spatial data
- Motivation: correlated activations
- Implementation: dropout2d/dropout3d

#### 4.4.3 Variational Dropout

- Same mask across time steps (RNNs)
- Preserving temporal consistency
- Recurrent dropout patterns
- Theoretical foundation: variational inference

#### 4.4.4 Concrete/Gumbel Dropout

- Continuous relaxation of discrete dropout
- Learned dropout rates
- Differentiable with respect to dropout probability
- Structured pruning connection

#### 4.4.5 Targeted Dropout

- Adaptive dropout rates per unit
- Curriculum-based dropout scheduling
- Attention-guided dropout
- [Inference] Unit importance-based dropping

#### 4.4.6 Other Variants

- DropBlock: structured dropping in CNNs
- StochasticDepth: layer-level dropout
- DropPath: path dropout in residual networks
- Cutout: input-level structured dropout
- Zoneout (RNNs): stochastic identity preservation

### 4.5 Theoretical Understanding

#### 4.5.1 Ensemble Perspective

- Exponential number of thinned networks
- Weight sharing across sub-networks
- Geometric mean of predictions
- [Inference] Relationship to model averaging

#### 4.5.2 Bayesian Interpretation

- Approximate Bayesian inference
- Posterior distribution over weights
- Uncertainty quantification
- Monte Carlo dropout for uncertainty

#### 4.5.3 Information Theory Perspective

- Information bottleneck connection
- Adaptive noise injection
- [Research perspective] Mutual information constraints

### 4.6 Architecture-Specific Considerations

#### 4.6.1 Dropout in CNNs

- Standard dropout limitations
- Spatial dropout preference
- Placement: after pooling vs after convolution
- Interaction with batch normalization

#### 4.6.2 Dropout in RNNs

- Naive dropout problems: temporal inconsistency
- Variational dropout solution
- Recurrent dropout: hidden state vs input
- LSTM-specific dropout patterns

#### 4.6.3 Dropout in Transformers

- Attention dropout: attention weights
- Residual dropout: after sublayers
- Embedding dropout
- Layer dropout (StochasticDepth)

#### 4.6.4 Dropout in ResNets

- DropPath/StochasticDepth
- Skip connection considerations
- Survival probability scheduling
- Deep network training stability

### 4.7 Practical Implementation

#### 4.7.1 Framework APIs

- PyTorch: nn.Dropout, F.dropout
- TensorFlow: tf.keras.layers.Dropout
- Training mode requirement
- Functional vs module-based

#### 4.7.2 Common Pitfalls

- Forgetting train/eval mode switching
- Incorrect scaling approach
- Over-regularization
- Placement after batch normalization [debate]

#### 4.7.3 Debugging

- Monitoring active units
- Gradient flow verification
- Performance without dropout baseline
- Dropout rate ablation studies

### 4.8 Interactions with Other Techniques

#### 4.8.1 Dropout + Batch Normalization

- Redundancy debate
- Combined effectiveness [mixed evidence]
- Ordering considerations
- When to use both vs either

#### 4.8.2 Dropout + Data Augmentation

- Complementary regularization
- Combined strength adjustment
- Computational considerations

#### 4.8.3 Dropout + Weight Decay

- Different regularization mechanisms
- Hyperparameter interaction
- Combined tuning strategies

### 4.9 Advanced Topics

#### 4.9.1 Uncertainty Quantification

- MC Dropout for predictive uncertainty
- Epistemic vs aleatoric uncertainty
- Calibration with dropout
- Applications in safety-critical systems

#### 4.9.2 Adaptive Dropout

- Learning dropout rates
- Network pruning connection
- Structured sparsity induction
- AutoML for dropout configuration

---

