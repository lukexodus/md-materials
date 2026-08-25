## Model Pruning Techniques


**Structured vs Unstructured Pruning** Structured pruning removes entire neurons, channels, or layers, maintaining regular computation patterns that hardware can efficiently execute. Unstructured pruning removes individual weights regardless of their position, achieving higher compression rates but potentially creating sparse matrices that require specialized hardware support.

**Magnitude-Based Pruning** This fundamental approach removes weights with the smallest absolute values, operating under the assumption that small weights contribute minimally to model performance. PyTorch's `torch.nn.utils.prune` module implements magnitude pruning through `RandomUnstructured` and `L1Unstructured` classes. The process typically involves iterative pruning where a percentage of weights are removed, followed by fine-tuning to recover performance.

**Gradual Pruning Schedules** Rather than removing weights all at once, gradual pruning removes small percentages of weights over multiple training epochs. This allows the model to adapt to the reduced capacity progressively. Common schedules include polynomial decay, exponential decay, and linear scheduling of the pruning rate.

**Advanced Pruning Methods** SNIP (Single-shot Network Pruning) evaluates weight importance using gradient information before training begins. Lottery Ticket Hypothesis-based approaches identify sparse subnetworks that can achieve comparable performance to the original dense network when trained from specific initializations. Fisher information-based pruning uses second-order gradient information to identify less critical parameters.

**Key Points:**

- Structured pruning maintains computational efficiency but may reduce compression rates
- Unstructured pruning achieves higher compression but requires sparse computation support
- Gradual pruning typically outperforms one-shot approaches
- Modern pruning methods consider both weight magnitude and gradient information

