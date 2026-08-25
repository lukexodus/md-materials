## Module 11: Advanced Training Techniques


### 11.1 Data Augmentation

- Random crops and resizing
- Horizontal/vertical flips
- Color jittering (brightness, contrast, saturation)
- Cutout and random erasing
- MixUp and CutMix
- AutoAugment and RandAugment
- Mosaic augmentation (YOLO)
- Test-time augmentation (TTA)

### 11.2 Regularization Methods

- Dropout and spatial dropout
- DropConnect
- DropBlock (structured dropout)
- Stochastic Depth (layer dropout)
- Shake-Shake and Shake-Drop
- Label smoothing
- Weight decay (L2 regularization)
- Early stopping

### 11.3 Normalization Techniques

- Batch Normalization (BN)
    - Internal covariate shift mitigation
    - Training/inference mode differences
    - Batch size dependency
- Layer Normalization
- Instance Normalization
- Group Normalization
- Switchable Normalization
- Weight Normalization
- When to use which normalization

### 11.4 Optimization Strategies

- SGD with momentum
- Nesterov momentum
- AdaGrad and RMSprop
- Adam and AdamW
- LAMB and LARS (large batch training)
- Lookahead optimizer
- Learning rate schedules:
    - Step decay
    - Exponential decay
    - Cosine annealing
    - Warm restarts
    - Warm-up strategies
- Gradient clipping

### 11.5 Advanced Loss Functions

- Focal Loss (address class imbalance)
- Label smoothing cross-entropy
- IoU-based losses (GIoU, DIoU, CIoU)
- Lovász-Softmax (segmentation)
- Contrastive losses
- Triplet loss
- Center loss

### 11.6 Transfer Learning and Fine-Tuning

- Pretrained model selection
- Feature extraction vs fine-tuning
- Layer freezing strategies
- Learning rate differential
- Domain adaptation techniques
- Few-shot learning approaches

### 11.7 Mixed Precision Training

- FP16 computation benefits
- Loss scaling
- Dynamic loss scaling
- Automatic Mixed Precision (AMP)
- Memory savings
- Speed improvements

### 11.8 Distributed Training

- Data parallelism
- Model parallelism
- Synchronous vs asynchronous SGD
- Gradient accumulation
- Large batch training challenges
- Communication efficiency

---

