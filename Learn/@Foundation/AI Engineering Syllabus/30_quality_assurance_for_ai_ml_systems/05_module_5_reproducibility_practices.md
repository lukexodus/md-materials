## Module 5: Reproducibility Practices


### 5.1 Reproducibility Fundamentals

- Definition: Same code + data + environment → same results
- Importance in research and production
- Levels of reproducibility:
    - Computational reproducibility
    - Statistical reproducibility
    - Conceptual reproducibility
- Barriers to reproducibility in ML

### 5.2 Sources of Non-Reproducibility

**Randomness:**

- Random initialization
- Data shuffling
- Stochastic operations (dropout, augmentation)
- Hardware-dependent operations (GPU atomics)
- Non-deterministic algorithms (some cuDNN ops)

**Environment Differences:**

- Library version mismatches
- Operating system differences
- Hardware differences (CPU vs GPU, different GPUs)
- Compiler optimizations
- Floating point precision variations

**Data Issues:**

- Data access/availability
- Data preprocessing variations
- Temporal data changes
- Data shuffling order

**Configuration:**

- Undocumented hyperparameters
- Hardcoded values
- Environment variables
- Implicit dependencies

### 5.3 Controlling Randomness

**Random Seed Management:**

```python
# Example pattern
import random
import numpy as np
import torch

def set_seed(seed=42):
    random.seed(seed)
    np.random.seed(seed)
    torch.manual_seed(seed)
    torch.cuda.manual_seed_all(seed)
    # For full reproducibility (may impact performance)
    torch.backends.cudnn.deterministic = True
    torch.backends.cudnn.benchmark = False
```

**Best Practices:**

- Set seeds at the start of experiments
- Document seed values used
- Use different seeds for different runs
- Understand performance tradeoffs (determinism vs speed)
- Report results across multiple seeds

**Framework-Specific Settings:**

- PyTorch: CUBLAS_WORKSPACE_CONFIG
- TensorFlow: tf.random.set_seed(), TF_DETERMINISTIC_OPS
- Scikit-learn: random_state parameter

### 5.4 Environment Management

**Dependency Management:**

- requirements.txt (Python, pip)
- environment.yml (Conda)
- pyproject.toml (Poetry)
- Pipfile (Pipenv)
- Pin exact versions (numpy==1.24.3, not numpy>=1.20)
- Include transitive dependencies

**Virtual Environments:**

- venv, virtualenv (Python)
- Conda environments
- Environment per project
- Document creation steps

**Containerization:**

- Docker for complete environment capture
- Dockerfile with explicit base images
- Multi-stage builds for optimization
- Docker Compose for services
- Container registries (Docker Hub, ECR, GCR)

**Example Dockerfile:**

```dockerfile
FROM python:3.10-slim
WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY . .
CMD ["python", "train.py"]
```

### 5.5 Code Versioning

**Version Control Basics:**

- Git fundamentals
- Commit messages (conventional commits)
- Branching strategies (gitflow, trunk-based)
- Tagging releases
- .gitignore for artifacts

**Repository Structure:**

```
project/
├── data/                 # Data (or instructions to get it)
├── notebooks/            # Exploration notebooks
├── src/                  # Source code
│   ├── data/            # Data loading/processing
│   ├── features/        # Feature engineering
│   ├── models/          # Model definitions
│   └── utils/           # Utilities
├── tests/               # Unit and integration tests
├── configs/             # Configuration files
├── experiments/         # Experiment tracking
├── docs/                # Documentation
├── requirements.txt     # Dependencies
├── setup.py            # Package installation
└── README.md           # Project overview
```

**Code Review for Reproducibility:**

- Check for hardcoded paths
- Verify seed setting
- Confirm configuration management
- Validate logging

### 5.6 Data Versioning

**Importance:**

- Data changes over time
- Different dataset versions
- Preprocessing variations

**Data Versioning Tools:**

- DVC (Data Version Control)
- Git LFS (Large File Storage)
- Pachyderm
- Delta Lake
- LakeFS

**DVC Example Workflow:**

```bash
# Initialize DVC
dvc init

# Track data file
dvc add data/dataset.csv

# Commit .dvc file
git add data/dataset.csv.dvc .gitignore
git commit -m "Add dataset"

# Push data to remote
dvc push
```

**Best Practices:**

- Version raw data separately
- Track preprocessing scripts with data
- Document data lineage
- Use content-addressable storage
- Include data validation checks

### 5.7 Experiment Tracking

**What to Track:**

- Hyperparameters (all of them)
- Metrics (train, val, test)
- Artifacts (models, plots, predictions)
- System information (hardware, software)
- Training time
- Random seeds
- Git commit hash
- Configuration files

**Experiment Tracking Tools:**

- MLflow
- Weights & Biases (wandb)
- TensorBoard
- Neptune.ai
- Comet.ml
- Sacred

**MLflow Example:**

```python
import mlflow

with mlflow.start_run():
    mlflow.log_param("learning_rate", 0.001)
    mlflow.log_param("batch_size", 32)
    
    # Training loop
    for epoch in range(epochs):
        train_loss = train()
        val_loss = validate()
        mlflow.log_metric("train_loss", train_loss, step=epoch)
        mlflow.log_metric("val_loss", val_loss, step=epoch)
    
    mlflow.log_artifact("model.pth")
```

### 5.8 Configuration Management

**Configuration Files:**

- YAML, JSON, TOML formats
- Hierarchical configurations
- Environment-specific configs (dev, prod)
- Separate secrets from config

**Configuration Tools:**

- Hydra (Facebook)
- OmegaConf
- Python-dotenv (environment variables)
- ConfigParser (Python built-in)

**Example Hydra Config:**

```yaml
# config.yaml
model:
  name: resnet50
  num_classes: 10

training:
  batch_size: 32
  learning_rate: 0.001
  epochs: 100

data:
  path: /data/dataset
  augmentation: true
```

**Best Practices:**

- Never hardcode values
- Use configuration files
- Version control configurations
- Validate configurations
- Document all parameters

### 5.9 Model Checkpointing and Serialization

**Checkpointing Strategy:**

- Save best model based on validation metric
- Periodic checkpoints (every N epochs)
- Save last checkpoint (for resuming)
- Save optimizer state for exact resumption
- Include metadata (epoch, metrics, config)

**Serialization Formats:**

- PyTorch: .pt, .pth files (torch.save/load)
- TensorFlow: SavedModel, HDF5
- ONNX (cross-framework)
- Pickle (avoid for production)

**What to Save:**

- Model weights (state_dict)
- Model architecture (config or code)
- Optimizer state
- Training epoch/step
- Random number generator states
- Hyperparameters
- Performance metrics

### 5.10 Reproducibility Checklist

**Code:**

- [ ] All dependencies with exact versions listed
- [ ] Random seeds set and documented
- [ ] No hardcoded paths or values
- [ ] Code is version controlled
- [ ] Git commit hash recorded

**Data:**

- [ ] Dataset version documented
- [ ] Data source accessible
- [ ] Preprocessing steps documented and reproducible
- [ ] Data splits (train/val/test) saved or seed-based

**Environment:**

- [ ] Python version specified
- [ ] CUDA/GPU versions documented
- [ ] Docker image or Conda environment provided
- [ ] Operating system specified

**Experiments:**

- [ ] All hyperparameters logged
- [ ] Training procedure documented
- [ ] Evaluation protocol specified
- [ ] Results logged with experiment tracker

**Models:**

- [ ] Model architecture defined in code
- [ ] Pretrained weights accessible
- [ ] Checkpoint saving implemented
- [ ] Model card created

### 5.11 Reproducibility Validation

- Reproduce results on same machine
- Reproduce on different machine (same OS)
- Reproduce on different OS
- Have colleague reproduce independently
- Document any deviations
- Report mean and std across multiple runs

### 5.12 Continuous Integration for Reproducibility

- Automated tests for determinism
- Environment validation in CI
- Model training in CI (small subset)
- Dependency vulnerability scanning
- Documentation generation

### 5.13 Publishing Reproducible Research

- Share code on GitHub/GitLab
- Provide requirements and Docker images
- Include detailed README with setup steps
- Share preprocessed data or scripts
- Create Colab/Jupyter notebooks
- Use platforms like Papers with Code
- Archive on Zenodo for DOI

---

