## Experiment Tracking Systems


### Weights & Biases (wandb)

A comprehensive experiment tracking platform that integrates seamlessly with PyTorch through the `wandb` library. Researchers can log metrics, hyperparameters, model artifacts, and system information automatically during training.

**Key points:**

- Real-time metric visualization and comparison across experiments
- Automatic hyperparameter logging and sweep configuration
- Model artifact versioning and storage
- Integration with popular PyTorch frameworks like Lightning and Transformers
- Collaborative features for team research projects

### TensorBoard

PyTorch's native integration with TensorBoard through `torch.utils.tensorboard.SummaryWriter` provides visualization capabilities for training metrics, model graphs, and data distributions.

**Key points:**

- Scalar metric tracking (loss, accuracy, learning rates)
- Histogram visualization for weights and gradients
- Model architecture visualization through computational graphs
- Embedding projections for high-dimensional data
- Image and audio logging capabilities for computer vision and audio tasks

### MLflow

An open-source platform for managing the complete machine learning lifecycle, with strong PyTorch integration through automatic logging and model registry features.

**Key points:**

- Experiment organization with run comparison utilities
- Model packaging and deployment capabilities
- Parameter and metric tracking with UI dashboard
- Integration with various storage backends (local, S3, Azure, GCS)
- REST API for programmatic experiment management

### Neptune

A metadata store designed for ML experiment management with extensive PyTorch integration capabilities.

**Key points:**

- Automatic PyTorch model logging and visualization
- Code versioning and data lineage tracking
- Custom dashboard creation for experiment monitoring
- Integration with Jupyter notebooks for research workflows
- Team collaboration features with permission management

