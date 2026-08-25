## Module 3: The Deep Learning Revolution - AlexNet


### 3.1 ImageNet Challenge and Context

- ImageNet Large Scale Visual Recognition Challenge (ILSVRC)
- 1000 classes, 1.2M training images
- Pre-AlexNet approaches (hand-crafted features, SIFT, HOG)
- 2012 breakthrough moment

### 3.2 AlexNet Architecture

- 8-layer deep network (5 conv + 3 FC)
- Detailed layer breakdown:
    - Conv1: 96 kernels, 11×11, stride 4
    - MaxPool1: 3×3, stride 2
    - Conv2: 256 kernels, 5×5
    - MaxPool2: 3×3, stride 2
    - Conv3: 384 kernels, 3×3
    - Conv4: 384 kernels, 3×3
    - Conv5: 256 kernels, 3×3
    - MaxPool3: 3×3, stride 2
    - FC6: 4096 units
    - FC7: 4096 units
    - FC8: 1000 units (softmax)
- Input size: 224×224×3 (227×227 in practice)
- Parameter count: ~60 million

### 3.3 Key Innovations

- ReLU activation function (faster training)
- Overlapping pooling
- Local Response Normalization (LRN)
- Dropout regularization (0.5 in FC layers)
- Data augmentation (random crops, horizontal flips, color jittering)
- Multi-GPU training architecture
- PCA color augmentation

### 3.4 Training Details

- Batch size and learning rate schedule
- Weight decay and momentum
- Training time and hardware used
- Top-5 error: 15.3% (vs 26.2% second place)

### 3.5 Impact and Legacy

- Sparked deep learning renaissance
- Demonstrated GPU effectiveness
- Established design patterns
- Limitations (large parameters in FC layers)

---

