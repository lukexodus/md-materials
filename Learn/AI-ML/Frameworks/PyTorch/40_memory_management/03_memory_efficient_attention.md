## Memory-Efficient Attention


Attention mechanisms in transformers have quadratic memory complexity O(sequence_length²) due to the attention matrix. Memory-efficient attention implementations reduce this complexity through various algorithmic optimizations.

Flash Attention represents the state-of-the-art approach, using block-sparse computation and online softmax to reduce memory usage from O(N²) to O(N) while maintaining mathematical equivalence to standard attention. It achieves this by tiling the computation and using fast SRAM memory more efficiently.

**Key Points:**

- Flash Attention reduces memory usage by 2-4x for long sequences
- Maintains exact numerical results unlike approximation methods
- Integrated into PyTorch 2.0+ as `torch.nn.functional.scaled_dot_product_attention`
- Performance gains increase with longer sequence lengths

Memory-efficient implementations also include gradient checkpointing within attention computation, sparse attention patterns that reduce complexity through structured sparsity, and mixed precision techniques that use FP16 for activations while maintaining FP32 for critical computations.

**Example:**

```python
import torch
import torch.nn.functional as F

# Using PyTorch's memory-efficient attention
def efficient_attention(query, key, value, mask=None):
    return F.scaled_dot_product_attention(
        query, key, value, 
        attn_mask=mask,
        enable_gqa=True,  # Enable grouped query attention
        scale=None
    )

# Custom implementation with checkpointing
class MemoryEfficientAttention(torch.nn.Module):
    def forward(self, q, k, v):
        def attention_forward(q, k, v):
            scores = torch.matmul(q, k.transpose(-2, -1)) / math.sqrt(q.size(-1))
            attn_weights = F.softmax(scores, dim=-1)
            return torch.matmul(attn_weights, v)
        
        return checkpoint.checkpoint(attention_forward, q, k, v, use_reentrant=False)
```

