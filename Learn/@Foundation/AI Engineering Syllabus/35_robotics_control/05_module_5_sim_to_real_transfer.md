## Module 5: Sim-to-Real Transfer


### 5.1 Reality Gap Challenges

- Simulation limitations
    - Physics approximations
    - Sensor noise modeling
    - Actuator dynamics
    - Contact dynamics
- Appearance gap
- Dynamics mismatch
- Quantifying reality gap

### 5.2 Domain Randomization

- Parameter randomization
    - Physics parameters (friction, mass, damping)
    - Geometric parameters
    - Actuator parameters
- Visual randomization
    - Textures and materials
    - Lighting conditions
    - Camera parameters
- Automatic domain randomization (ADR)
    - Curriculum-based randomization
    - Performance-driven adaptation
- Structured domain randomization

### 5.3 System Identification

- Parameter estimation from real data
- Bayesian optimization for calibration
- Black-box identification
- Gray-box modeling
- Online adaptation techniques

### 5.4 Domain Adaptation Techniques

- Feature-level adaptation
- Policy distillation
- Adversarial domain adaptation
- Gradient reversal layers
- Domain confusion losses

### 5.5 Learning Robust Policies

- Adversarial training
- Worst-case optimization
- Ensemble policies
- Robust MDP formulations
- H-infinity control perspective

### 5.6 Simulation Fidelity

- High-fidelity physics engines
    - MuJoCo
    - PyBullet
    - Isaac Gym/Isaac Sim
    - Gazebo
- Contact modeling
- Deformable objects
- Fluid dynamics
- Computational trade-offs

### 5.7 Real-World Fine-Tuning

- Safety considerations
- Limited real-world data
- Online learning in real environments
- Meta-learning for fast adaptation
- Few-shot transfer
- Progressive deployment strategies

### 5.8 Residual Policies

- Learning residuals over base policies
- Sim-to-real residual learning
- Additive corrections
- Hybrid control strategies

### 5.9 Grounded Simulation

- Real2sim2real pipelines
- Trajectory-based calibration
- Inverse modeling
- Closing the loop with real data

### 5.10 Validation and Benchmarking

- Sim-to-real success metrics
- Transfer evaluation protocols
- Safety verification
- Ablation studies
- Reproducibility considerations

---

