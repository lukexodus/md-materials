## Module 4: Neural Forecasting Methods


### 4.1 Neural Networks for Time Series

#### 4.1.1 Motivation & Advantages

- Nonlinear pattern learning
- Automatic feature extraction
- Handling multiple seasonalities
- Multivariate capabilities
- End-to-end learning

#### 4.1.2 Challenges Specific to Time Series

- Limited training data: sequences vs i.i.d. samples
- Temporal ordering preservation
- Non-stationarity and distribution shift
- Interpretability requirements
- Long-range dependencies

#### 4.1.3 Input Representation

- Sliding window approach: lookback period
- Autoregressive features: lagged values
- Time features: hour, day, month, etc.
- Categorical embeddings: day of week, store ID
- External regressors: weather, promotions

### 4.2 Multi-Layer Perceptrons (MLPs) for Forecasting

#### 4.2.1 Architecture Design

- Input: flattened window of lagged values
- Hidden layers: typically 1-3 layers
- Output: single or multiple horizons
- Activation functions: ReLU common
- [Limitation] No explicit temporal modeling

#### 4.2.2 Training Considerations

- Window size selection: lookback period
- Direct vs recursive multi-step forecasting
- Loss functions: MSE, MAE, quantile loss
- Regularization: dropout, weight decay
- Batch composition: temporal ordering

#### 4.2.3 Practical Performance

- [Empirical] Competitive on simple patterns
- Fast training and inference
- Baseline for comparison
- Limited for complex temporal dependencies
- Data efficiency concerns

### 4.3 Convolutional Neural Networks (CNNs)

#### 4.3.1 1D Convolutions for Sequences

- Temporal convolution: pattern detection
- Dilated convolutions: expanded receptive field
- WaveNet-style architecture
- Causal convolutions: no future leakage
- Residual connections for depth

#### 4.3.2 Advantages for Time Series

- Parameter sharing across time
- Local pattern detection
- Hierarchical feature learning
- Faster than RNNs: parallelizable
- Fixed-size receptive field per layer

#### 4.3.3 Architectures

- Temporal Convolutional Networks (TCN)
- Dilated causal convolutions
- Residual blocks
- [Research] N-BEATS: interpretable basis functions
- [Research] N-HiTS: hierarchical interpolation

### 4.4 Recurrent Neural Networks (RNNs)

#### 4.4.1 Standard RNN Limitations

- Vanishing gradients: long sequences
- Sequential computation: slow training
- [Practical] Rarely used directly for forecasting
- LSTM/GRU preferred

#### 4.4.2 LSTM for Forecasting

- Cell state: long-term memory
- Gate mechanisms: selective information flow
- Many-to-one: sequence to single output
- Many-to-many: sequence-to-sequence
- Encoder-decoder for multi-horizon

#### 4.4.3 GRU for Forecasting

- Simpler than LSTM: fewer parameters
- Update and reset gates
- [Empirical] Often comparable performance to LSTM
- Faster training
- Preferred when data is limited

#### 4.4.4 Practical Considerations

- Sequence length selection
- Stateful vs stateless RNNs
- Bidirectional RNNs: [Caution] future information leakage
- Teacher forcing during training
- Gradient clipping necessity

### 4.5 Sequence-to-Sequence Models

#### 4.5.1 Encoder-Decoder Architecture

- Encoder: compresses input sequence
- Context vector: fixed representation
- Decoder: generates output sequence
- Multi-step forecasting naturally
- [Application] Multi-horizon forecasting

#### 4.5.2 Attention Mechanisms

- Addressing fixed-context bottleneck
- Weighted sum over encoder states
- Alignment scores: query-key similarity
- [Improvement] Better long-sequence modeling
- Interpretability: attention weights

#### 4.5.3 Multi-Horizon Forecasting

- Direct strategy: separate model per horizon
- Recursive strategy: iterative one-step
- Direct-recursive hybrid (MIMO - Multiple Input Multiple Output)
- Sequence-to-sequence: natural multi-horizon
- [Trade-off] Accuracy vs error propagation

### 4.6 Transformer-Based Models

#### 4.6.1 Self-Attention for Time Series

- Positional encoding: time step information
- Multi-head attention: different temporal patterns
- Parallel computation advantage
- [Challenge] Quadratic complexity in sequence length

#### 4.6.2 Temporal Fusion Transformer (TFT)

- Multi-horizon forecasting framework
- Variable selection: feature importance
- Static covariate encoders
- Temporal self-attention
- Quantile forecasting for uncertainty
- [Application] Industry adoption

#### 4.6.3 Informer

- Efficient attention: ProbSparse mechanism
- Long sequence forecasting (LSTF)
- Distilling operation: reducing dimensions
- [Research] Addressing transformer limitations for long sequences

#### 4.6.4 Autoformer

- Auto-correlation mechanism: replacing self-attention
- Series decomposition: trend + seasonal
- [Research] Improved long-term forecasting

#### 4.6.5 Patch-based Transformers

- PatchTST: dividing series into patches
- Channel independence
- [Recent] State-of-the-art on benchmarks
- Reduced computational cost

### 4.7 Specialized Neural Architectures

#### 4.7.1 DeepAR (Amazon)

- Autoregressive RNN
- Probabilistic forecasting: learned distribution
- Multi-step sampling
- Handles multiple related time series
- Cold-start problem mitigation

#### 4.7.2 N-BEATS

- Pure deep learning: no time series-specific components
- Doubly residual stacking
- Interpretable variant: trend + seasonality blocks
- Generic variant: fully learnable
- [Benchmark] Strong performance on M4 competition

#### 4.7.3 N-HiTS

- Hierarchical interpolation
- Multi-rate sampling
- Expressiveness with efficiency
- Improved on N-BEATS
- [Recent] Competitive benchmark results

#### 4.7.4 WaveNet

- Originally for audio generation
- Dilated causal convolutions
- Exponentially growing receptive field
- Probabilistic forecasting capability
- Computationally expensive

### 4.8 Probabilistic Forecasting with Neural Networks

#### 4.8.1 Point vs Probabilistic Forecasts

- Point forecasts: single value prediction
- Probabilistic: full predictive distribution
- Uncertainty quantification importance
- Decision-making under uncertainty
- Risk management applications

#### 4.8.2 Quantile Regression

- Predicting multiple quantiles (e.g., 0.1, 0.5, 0.9)
- Pinball loss: quantile-specific loss function
- Non-crossing constraint considerations
- Flexible distribution shape
- Computationally efficient

#### 4.8.3 Parametric Distributions

- Gaussian: mean and variance outputs
- Negative binomial: count data
- Student-t: heavier tails
- Mixture models: multi-modal distributions
- Maximum likelihood training

#### 4.8.4 Monte Carlo Dropout

- Dropout during inference
- Multiple stochastic forward passes
- Empirical predictive distribution
- Epistemic uncertainty estimation
- [Note] Calibration may be poor

#### 4.8.5 Normalizing Flows

- Invertible transformations
- Exact likelihood computation
- Flexible distribution learning
- [Advanced] Computational overhead
- [Application] Complex multivariate distributions

### 4.9 Training Neural Forecasting Models

#### 4.9.1 Loss Functions

- MSE/MAE: standard point forecasting
- MAPE: percentage error
- Quantile loss: probabilistic forecasting
- CRPS: continuous ranked probability score
- sMAPE: symmetric MAPE

#### 4.9.2 Data Preparation

- Train/validation/test temporal splits
- Normalization: per-series or global
- Missing value imputation
- Sequence padding for batching
- Augmentation: jittering, window slicing

#### 4.9.3 Optimization Strategies

- Adam optimizer: common default
- Learning rate scheduling: reduce on plateau
- Gradient clipping: RNN stability
- Early stopping on validation loss
- Batch size: larger often better for transformers

#### 4.9.4 Regularization

- Dropout: standard practice
- Weight decay: L2 regularization
- Layer normalization: training stability
- [Specific] Recurrent dropout for LSTMs
- Attention dropout for transformers

### 4.10 Multivariate Forecasting

#### 4.10.1 Problem Formulation

- Forecasting multiple related series
- Capturing cross-series dependencies
- Shared patterns exploitation
- Scalability to thousands of series

#### 4.10.2 Global vs Local Models

- Local: separate model per series
- Global: single model for all series
- [Trade-off] Generalization vs specialization
- Parameter sharing benefits
- Meta-learning perspective

#### 4.10.3 Architectural Approaches

- Vector autoregression: linear baseline
- RNN with series embeddings
- Graph neural networks: explicit dependencies
- Attention across series
- Hierarchical models: grouped series

#### 4.10.4 Cross-Learning

- Transfer learning across series
- Few-shot forecasting: meta-learning
- Domain adaptation
- Cold-start problem: new series
- [Practical] Data efficiency gains

### 4.11 Evaluation & Benchmarking

#### 4.11.1 Metrics

- MAE, RMSE, MAPE, sMAPE
- MASE: Mean Absolute Scaled Error
- Forecast skill: improvement over baseline
- Quantile loss for probabilistic
- Coverage: prediction interval evaluation

#### 4.11.2 Benchmark Datasets

- M-competitions: M3, M4, M5
- Electricity: UCI dataset
- Traffic: road occupancy
- Tourism: Australian tourism
- ETT: Electricity Transformer Temperature
- [Resource] GluonTS for standardized evaluation

#### 4.11.3 Comparison Considerations

- Computational cost: training and inference
- Data requirements: sample efficiency
- Interpretability needs
- Forecast horizon performance
- [Empirical] No universally best method

### 4.12 Implementation Frameworks

#### 4.12.1 Libraries & Tools

- GluonTS: probabilistic forecasting toolkit
- Darts: user-friendly forecasting library
- PyTorch Forecasting: deep learning focus
- NeuralProphet: neural extension of Prophet
- Sktime: unified interface for forecasting

#### 4.12.2 Pre-trained Models

- TimesFM (Google): foundation model for time series
- Lag-Llama: LLM-inspired architecture
- [Emerging] Foundation models for forecasting
- Transfer learning opportunities
- [Unverified] Zero-shot forecasting capabilities

---

