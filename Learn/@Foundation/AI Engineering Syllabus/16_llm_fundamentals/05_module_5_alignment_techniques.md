## Module 5: Alignment Techniques


### 5.1 AI Alignment Problem

- What is alignment?
- Intent alignment vs impact alignment
- Outer vs inner alignment
- Specification gaming
- Value learning challenges

### 5.2 Reinforcement Learning from Human Feedback (RLHF)

- RLHF pipeline overview
- Three-stage process: SFT → Reward Model → RL
- Historical development (InstructGPT paper)
- Computational requirements

### 5.3 Reward Modeling

- Preference data collection
- Pairwise comparison annotations
- Bradley-Terry model
- Reward model training objective
- Reward model architecture (typically reusing base model)
- Reward hacking concerns

### 5.4 Preference Data Collection

- Human labeler instructions
- Comparison criteria (helpfulness, harmlessness, honesty)
- Inter-annotator agreement
- Quality control mechanisms
- Scale and cost considerations
- Adversarial prompting for robustness

### 5.5 Proximal Policy Optimization (PPO)

- Policy gradient methods
- KL divergence constraint
- Clipped surrogate objective
- Value function estimation
- Actor-critic architecture
- PPO hyperparameters and tuning

### 5.6 RLHF Implementation Details

- Reference model for KL penalty
- Sampling and rollout generation
- Batch processing strategies
- Training stability challenges
- Reward scaling and normalization
- Multiple reward models [Inference: some systems use]

### 5.7 Direct Preference Optimization (DPO)

- Eliminating explicit reward model
- Direct policy optimization from preferences
- Simplified training pipeline
- Computational efficiency gains
- Mathematical formulation
- Comparison with RLHF

### 5.8 Variants and Extensions

- Identity Preference Optimization (IPO)
- Kahneman-Tversky Optimization (KTO)
- Rejection sampling optimization
- Reward-ranked fine-tuning (RAFT)
- Constitutional AI-integrated methods

### 5.9 Red Teaming

- Adversarial testing methodology
- Automated red teaming
- Human red team protocols
- Discovering failure modes
- Iterative safety improvements

### 5.10 Helpfulness vs Harmlessness Trade-offs

- Multi-objective optimization
- Refusal tuning
- Over-refusal problems
- Calibrating safety boundaries

### 5.11 Debate and Recursive Reward Modeling

- AI safety through debate
- Scalable oversight techniques
- Iterated amplification
- Recursive decomposition

### 5.12 Evaluation of Aligned Models

- Safety benchmarks
- Truthfulness evaluation
- Bias measurement
- Capabilities assessment post-alignment
- Human preference evaluation

### 5.13 Open Problems in Alignment

- Scalable oversight challenges
- Deceptive alignment risks [Speculation]
- Value pluralism and aggregation
- Long-term robustness
- Alignment tax on capabilities

---

