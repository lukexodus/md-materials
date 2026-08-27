## Table of Contents: Information Theory

### Foundations and Historical Context

- Shannon's 1948 paper and the birth of the field
- The communication system model: source, channel, receiver
- Discrete vs continuous information sources
- Deterministic vs probabilistic views of information
- Relationship to thermodynamics and statistical mechanics
- Historical precursors: Nyquist, Hartley, Boltzmann

### Probability and Random Variables Prerequisites

- Sample spaces, events, and probability axioms
- Discrete and continuous random variables
- Joint, marginal, and conditional distributions
- Expectation, variance, and moments
- Stochastic processes and stationarity
- Markov chains and their properties
- The law of large numbers and central limit theorem

### Entropy: The Measure of Uncertainty

- Self-information and the surprisal function
- Definition of Shannon entropy
- Axiomatic derivation of entropy
- Properties of entropy: non-negativity, boundedness
- Entropy of a binary source
- Joint entropy of multiple random variables
- Conditional entropy and the chain rule
- Entropy as expected surprisal

### Mutual Information and Divergence

- Definition and derivation of mutual information
- Relationship between mutual information and entropy
- Properties: symmetry, non-negativity, chain rule
- Kullback-Leibler divergence
- Properties and asymmetry of KL divergence
- Cross-entropy and its relation to KL divergence
- Jensen-Shannon divergence
- f-divergences as a general framework
- Data processing inequality

### Information Inequalities and Bounds

- Jensen's inequality and convexity in information theory
- Gibbs' inequality
- Fano's inequality
- Log-sum inequality
- Han's inequality
- Maximum entropy principle
- Entropy maximization under constraints

### Asymptotic Equipartition Property

- Statement and intuition behind the AEP
- Typical sets and their properties
- Weak law of large numbers connection
- Joint AEP for pairs of sequences
- Implications for data compression

### Lossless Data Compression (Source Coding)

- Fixed-length vs variable-length codes
- Prefix codes and the Kraft inequality
- Optimal codes and Shannon's source coding theorem
- Huffman coding algorithm and optimality proof
- Shannon-Fano coding
- Arithmetic coding
- Elias coding and universal codes
- Lempel-Ziv algorithms (LZ77, LZ78, LZW)
- Adaptive and dynamic Huffman coding
- Redundancy and code efficiency

### Universal Source Coding

- Universal codes for unknown source distributions
- Minimum description length principle
- Context tree weighting
- Prediction by partial matching

### Channel Capacity and Coding

- Discrete memoryless channels
- Channel capacity definition
- Binary symmetric channel capacity
- Binary erasure channel capacity
- Symmetric and weakly symmetric channels
- Channel coding theorem (Shannon's second theorem)
- Converse to the channel coding theorem
- Joint source-channel coding theorem
- Feedback capacity

### Error-Correcting Codes

- Hamming distance and error detection/correction basics
- Linear block codes
- Hamming codes
- Cyclic codes and generator polynomials
- BCH codes
- Reed-Solomon codes
- Convolutional codes and trellis representation
- Viterbi decoding algorithm
- Turbo codes and iterative decoding
- Low-density parity-check codes
- Polar codes
- Belief propagation and message passing decoding

### Continuous Channels and Differential Entropy

- Differential entropy definition and properties
- Comparison between discrete and differential entropy
- Relative entropy for continuous distributions
- Maximum entropy distributions under moment constraints
- Gaussian channel model
- Shannon-Hartley theorem and channel capacity
- Power and bandwidth constraints
- Parallel Gaussian channels and water-filling

### Rate Distortion Theory

- Lossy compression motivation
- Distortion measures
- Rate distortion function definition
- Rate distortion theorem
- Rate distortion for Gaussian sources
- Blahut-Arimoto algorithm
- Vector quantization

### Network Information Theory

- Multiple access channels
- Broadcast channels
- Relay channels
- Interference channels
- Slepian-Wolf coding for distributed source compression
- Wyner-Ziv coding with side information
- Network coding fundamentals
- Capacity regions and achievable rate regions

### Information Theory and Statistics

- Hypothesis testing and Stein's lemma
- Chernoff-Stein lemma
- Large deviations theory
- Sanov's theorem
- Fisher information
- Cramer-Rao bound
- Relationship between Fisher information and KL divergence

### Kolmogorov Complexity and Algorithmic Information

- Definition of Kolmogorov complexity
- Relationship to Shannon entropy
- Incompressibility and randomness
- Universal probability
- Minimum description length connection
- Algorithmic information theory applications

### Information Theory in Cryptography

- Perfect secrecy and Shannon's theorem
- One-time pad and information-theoretic security
- Key equivocation
- Unicity distance
- Wiretap channel and secrecy capacity
- Authentication and information theory

### Quantum Information Theory

- Qubits and quantum states
- Von Neumann entropy
- Quantum mutual information
- Holevo bound
- Quantum channel capacity
- Quantum error correction basics
- Entanglement and information

### Information Theory in Machine Learning

- Cross-entropy loss and maximum likelihood
- KL divergence in variational inference
- Information bottleneck method
- Mutual information estimation techniques
- Entropy regularization
- Information-theoretic generalization bounds
- Rate distortion perspective on representation learning

### Portfolio Theory and Information

- Kelly criterion and gambling
- Growth rate optimal portfolios
- Relationship between entropy and investment growth
- Universal portfolios

### Advanced and Specialized Topics

- Multiterminal information theory
- Information geometry
- Renyi entropy and generalized entropies
- Tsallis entropy
- Common randomness and secret key generation
- Information-theoretic security in networks
- Zero-error information theory
- Index coding

### Practical Implementation and Tools

- Implementing entropy coders from scratch
- Benchmarking compression algorithms
- Simulating channel coding schemes
- Software libraries for information-theoretic computation
- Reading and analyzing Shannon's original papers
- Working through Cover and Thomas problem sets
