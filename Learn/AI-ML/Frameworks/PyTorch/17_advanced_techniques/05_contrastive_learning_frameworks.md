## Contrastive Learning Frameworks


Contrastive learning learns representations by maximizing agreement between positive pairs while minimizing agreement between negative pairs, enabling learning from unlabeled data through careful augmentation strategies.

**Key Points:**

- Contrastive learning requires careful construction of positive and negative pairs
- Data augmentation strategies significantly impact representation quality
- [Inference] Temperature scaling affects the concentration of learned representations
- Momentum encoders can stabilize training and improve performance

**SimCLR Implementation:**

```python
class SimCLR(nn.Module):
    def __init__(self, encoder, projection_dim=128, temperature=0.5):
        super().__init__()
        self.encoder = encoder
        self.temperature = temperature
        
        # Projection head
        encoder_dim = self._get_encoder_dim()
        self.projection_head = nn.Sequential(
            nn.Linear(encoder_dim, encoder_dim),
            nn.ReLU(),
            nn.Linear(encoder_dim, projection_dim)
        )
        
    def forward(self, x1, x2):
        # Encode both augmented views
        h1 = self.encoder(x1)
        h2 = self.encoder(x2)
        
        # Project to contrastive space
        z1 = self.projection_head(h1)
        z2 = self.projection_head(h2)
        
        # L2 normalize projections
        z1 = F.normalize(z1, dim=1)
        z2 = F.normalize(z2, dim=1)
        
        return z1, z2
        
    def _get_encoder_dim(self):
        dummy_input = torch.randn(1, 3, 224, 224)
        with torch.no_grad():
            output = self.encoder(dummy_input)
        return output.shape[-1]

class SimCLRLoss(nn.Module):
    def __init__(self, temperature=0.5):
        super().__init__()
        self.temperature = temperature
        
    def forward(self, z1, z2):
        batch_size = z1.shape[0]
        
        # Combine representations
        representations = torch.cat([z1, z2], dim=0)  # [2*batch_size, projection_dim]
        
        # Compute similarity matrix
        similarity_matrix = torch.mm(representations, representations.t()) / self.temperature
        
        # Create labels for positive pairs
        labels = torch.cat([torch.arange(batch_size) + batch_size,
                           torch.arange(batch_size)], dim=0)
        labels = labels.to(representations.device)
        
        # Mask out self-similarity
        mask = torch.eye(2 * batch_size, device=representations.device).bool()
        similarity_matrix.masked_fill_(mask, -float('inf'))
        
        # Compute contrastive loss
        loss = F.cross_entropy(similarity_matrix, labels)
        
        return loss
```

**MoCo (Momentum Contrast):**

```python
class MoCo(nn.Module):
    def __init__(self, encoder_q, encoder_k, dim=128, K=65536, m=0.999, T=0.07):
        super().__init__()
        self.K = K
        self.m = m
        self.T = T
        
        # Query encoder
        self.encoder_q = encoder_q
        self.encoder_k = encoder_k
        
        # Projection heads
        encoder_dim = self._get_encoder_dim()
        self.projection_q = nn.Sequential(
            nn.Linear(encoder_dim, encoder_dim),
            nn.ReLU(),
            nn.Linear(encoder_dim, dim)
        )
        self.projection_k = nn.Sequential(
            nn.Linear(encoder_dim, encoder_dim),
            nn.ReLU(),
            nn.Linear(encoder_dim, dim)
        )
        
        # Initialize key encoder with query encoder
        for param_q, param_k in zip(self.encoder_q.parameters(), self.encoder_k.parameters()):
            param_k.data.copy_(param_q.data)
            param_k.requires_grad = False
            
        for param_q, param_k in zip(self.projection_q.parameters(), self.projection_k.parameters()):
            param_k.data.copy_(param_q.data)
            param_k.requires_grad = False
            
        # Memory bank (queue)
        self.register_buffer("queue", torch.randn(dim, K))
        self.queue = F.normalize(self.queue, dim=0)
        self.register_buffer("queue_ptr", torch.zeros(1, dtype=torch.long))
        
    @torch.no_grad()
    def _momentum_update_key_encoder(self):
        """Momentum update of the key encoder"""
        for param_q, param_k in zip(self.encoder_q.parameters(), self.encoder_k.parameters()):
            param_k.data = param_k.data * self.m + param_q.data * (1. - self.m)
            
        for param_q, param_k in zip(self.projection_q.parameters(), self.projection_k.parameters()):
            param_k.data = param_k.data * self.m + param_q.data * (1. - self.m)
            
    @torch.no_grad()
    def _dequeue_and_enqueue(self, keys):
        batch_size = keys.shape[0]
        ptr = int(self.queue_ptr)
        
        # Replace the keys at ptr (dequeue and enqueue)
        self.queue[:, ptr:ptr + batch_size] = keys.T
        ptr = (ptr + batch_size) % self.K  # Move pointer
        self.queue_ptr[0] = ptr
        
    def forward(self, im_q, im_k):
        # Query features
        q = self.encoder_q(im_q)
        q = self.projection_q(q)
        q = F.normalize(q, dim=1)
        
        # Key features
        with torch.no_grad():
            self._momentum_update_key_encoder()
            
            k = self.encoder_k(im_k)
            k = self.projection_k(k)
            k = F.normalize(k, dim=1)
            
        # Compute logits
        l_pos = torch.einsum('nc,nc->n', [q, k]).unsqueeze(-1)  # Positive logits
        l_neg = torch.einsum('nc,ck->nk', [q, self.queue.clone().detach()])  # Negative logits
        
        logits = torch.cat([l_pos, l_neg], dim=1) / self.T
        labels = torch.zeros(logits.shape[0], dtype=torch.long, device=logits.device)
        
        # Update queue
        self._dequeue_and_enqueue(k)
        
        return logits, labels
```

**BYOL (Bootstrap Your Own Latent):**

```python
class BYOL(nn.Module):
    def __init__(self, encoder, projection_dim=256, hidden_dim=4096, tau=0.996):
        super().__init__()
        self.tau = tau
        
        # Online network
        self.online_encoder = encoder
        encoder_dim = self._get_encoder_dim()
        
        self.online_projector = nn.Sequential(
            nn.Linear(encoder_dim, hidden_dim),
            nn.BatchNorm1d(hidden_dim),
            nn.ReLU(),
            nn.Linear(hidden_dim, projection_dim)
        )
        
        self.online_predictor = nn.Sequential(
            nn.Linear(projection_dim, hidden_dim),
            nn.BatchNorm1d(hidden_dim),
            nn.ReLU(),
            nn.Linear(hidden_dim, projection_dim)
        )
        
        # Target network (momentum encoder)
        self.target_encoder = copy.deepcopy(encoder)
        self.target_projector = copy.deepcopy(self.online_projector)
        
        # Stop gradient for target network
        for param in self.target_encoder.parameters():
            param.requires_grad = False
        for param in self.target_projector.parameters():
            param.requires_grad = False
            
    @torch.no_grad()
    def _update_target_network(self):
        """EMA update of target network"""
        for online_param, target_param in zip(
            self.online_encoder.parameters(), self.target_encoder.parameters()
        ):
            target_param.data = self.tau * target_param.data + (1 - self.tau) * online_param.data
            
        for online_param, target_param in zip(
            self.online_projector.parameters(), self.target_projector.parameters()
        ):
            target_param.data = self.tau * target_param.data + (1 - self.tau) * online_param.data
            
    def forward(self, x1, x2):
        # Online network forward pass
        online_repr_1 = self.online_encoder(x1)
        online_proj_1 = self.online_projector(online_repr_1)
        online_pred_1 = self.online_predictor(online_proj_1)
        
        online_repr_2 = self.online_encoder(x2)
        online_proj_2 = self.online_projector(online_repr_2)
        online_pred_2 = self.online_predictor(online_proj_2)
        
        # Target network forward pass
        with torch.no_grad():
            target_repr_1 = self.target_encoder(x1)
            target_proj_1 = self.target_projector(target_repr_1)
            
            target_repr_2 = self.target_encoder(x2)
            target_proj_2 = self.target_projector(target_repr_2)
            
        # Update target network
        self._update_target_network()
        
        return (online_pred_1, online_pred_2), (target_proj_1, target_proj_2)

class BYOLLoss(nn.Module):
    def __init__(self):
        super().__init__()
        
    def forward(self, online_preds, target_projs):
        online_pred_1, online_pred_2 = online_preds
        target_proj_1, target_proj_2 = target_projs
        
        # L2 normalize
        online_pred_1 = F.normalize(online_pred_1, dim=-1, p=2)
        online_pred_2 = F.normalize(online_pred_2, dim=-1, p=2)
        target_proj_1 = F.normalize(target_proj_1, dim=-1, p=2)
        target_proj_2 = F.normalize(target_proj_2, dim=-1, p=2)
        
        # Compute loss (negative cosine similarity)
        loss_1 = 2 - 2 * (online_pred_1 * target_proj_2.detach()).sum(dim=-1)
        loss_2 = 2 - 2 * (online_pred_2 * target_proj_1.detach()).sum(dim=-1)
        
        return (loss_1 + loss_2).mean()
```

