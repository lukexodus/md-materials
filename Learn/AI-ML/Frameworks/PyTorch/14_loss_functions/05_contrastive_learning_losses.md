## Contrastive Learning Losses


Contrastive learning losses enable representation learning through comparison between similar and dissimilar samples, forming the foundation for self-supervised learning approaches.

**Fundamental Contrastive Losses:**

_Contrastive Loss:_

- Pairwise loss that attracts similar samples and repels dissimilar ones
- Margin parameter controlling the separation between negative pairs
- Distance metric choice (Euclidean, cosine) affecting representation geometry
- Binary similarity labels determining attractive and repulsive forces

_Triplet Loss:_

- Anchor-positive-negative triplet relationships
- Margin-based separation between positive and negative samples
- Hard negative mining strategies for improved training efficiency
- Online triplet generation during training for diverse sample combinations

_InfoNCE Loss:_

- Information-theoretic foundation for contrastive learning
- Temperature parameter controlling concentration of representations
- Noise Contrastive Estimation for efficient computation
- Theoretical connections to mutual information maximization

**Modern Contrastive Formulations:**

_SimCLR Loss:_

- Self-supervised contrastive learning for visual representations
- Data augmentation creating positive pairs from single images
- Large batch sizes enabling diverse negative sampling
- Temperature-scaled cosine similarity for representation comparison

_SupCon Loss:_

- Supervised contrastive learning incorporating label information
- Multiple positives per anchor when labels are available
- Generalization of self-supervised approaches to supervised settings
- Improved representation quality through supervised signal integration

```python
class SupConLoss(nn.Module):
    def __init__(self, temperature=0.07):
        super().__init__()
        self.temperature = temperature
        
    def forward(self, features, labels):
        batch_size = features.shape[0]
        # Normalize features
        features = F.normalize(features, dim=1)
        
        # Compute similarity matrix
        similarity_matrix = torch.matmul(features, features.T) / self.temperature
        
        # Create mask for positive pairs
        labels = labels.view(-1, 1)
        mask = torch.eq(labels, labels.T).float()
        
        # Remove diagonal (self-similarity)
        mask = mask - torch.eye(batch_size, device=mask.device)
        
        # Compute loss
        exp_sim = torch.exp(similarity_matrix)
        sum_exp_sim = torch.sum(exp_sim * (1 - torch.eye(batch_size, device=mask.device)), dim=1, keepdim=True)
        log_prob = similarity_matrix - torch.log(sum_exp_sim)
        
        # Average over positive pairs
        pos_mask = mask
        if pos_mask.sum(1).min() > 0:  # Avoid division by zero
            loss = -((pos_mask * log_prob).sum(1) / pos_mask.sum(1)).mean()
        else:
            loss = torch.tensor(0.0, requires_grad=True, device=features.device)
            
        return loss
```

