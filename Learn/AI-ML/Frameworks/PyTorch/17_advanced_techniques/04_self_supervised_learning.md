## Self-Supervised Learning


Self-supervised learning creates supervision signals from the data itself, enabling learning from unlabeled datasets through pretext tasks that capture meaningful representations.

**Key Points:**

- Self-supervised methods generate supervision signals without human annotation
- Pretext tasks should encourage learning of useful representations for downstream tasks
- [Inference] Effective pretext tasks capture semantic relationships and structural properties
- Self-supervised learning often requires careful augmentation strategies

**Masked Autoencoder Implementation:**

```python
class MaskedAutoencoder(nn.Module):
    def __init__(self, encoder, decoder, mask_ratio=0.75, patch_size=16):
        super().__init__()
        self.encoder = encoder
        self.decoder = decoder
        self.mask_ratio = mask_ratio
        self.patch_size = patch_size
        
    def forward(self, x):
        # Create patches
        patches = self._create_patches(x)
        batch_size, num_patches, patch_dim = patches.shape
        
        # Random masking
        mask = torch.rand(batch_size, num_patches) < self.mask_ratio
        visible_patches = patches[~mask].reshape(batch_size, -1, patch_dim)
        
        # Encode visible patches
        encoded_features = self.encoder(visible_patches)
        
        # Decode to reconstruct all patches
        reconstructed_patches = self.decoder(encoded_features, mask)
        
        return reconstructed_patches, patches, mask
        
    def _create_patches(self, x):
        batch_size, channels, height, width = x.shape
        patch_height = height // self.patch_size
        patch_width = width // self.patch_size
        
        patches = x.unfold(2, self.patch_size, self.patch_size).unfold(3, self.patch_size, self.patch_size)
        patches = patches.contiguous().view(
            batch_size, channels, patch_height * patch_width, self.patch_size * self.patch_size
        )
        patches = patches.permute(0, 2, 1, 3).reshape(
            batch_size, patch_height * patch_width, -1
        )
        
        return patches

class MAELoss(nn.Module):
    def __init__(self):
        super().__init__()
        self.mse_loss = nn.MSELoss()
        
    def forward(self, reconstructed, original, mask):
        # Only compute loss on masked patches
        masked_reconstructed = reconstructed[mask]
        masked_original = original[mask]
        
        return self.mse_loss(masked_reconstructed, masked_original)
```

**Contrastive Predictive Coding:**

```python
class ContrastivePredictiveCoding(nn.Module):
    def __init__(self, encoder, context_size=128, prediction_steps=12):
        super().__init__()
        self.encoder = encoder
        self.context_size = context_size
        self.prediction_steps = prediction_steps
        
        # Context network (GRU for sequence modeling)
        self.context_network = nn.GRU(
            input_size=encoder.output_dim,
            hidden_size=context_size,
            batch_first=True
        )
        
        # Prediction networks for each future step
        self.prediction_networks = nn.ModuleList([
            nn.Linear(context_size, encoder.output_dim)
            for _ in range(prediction_steps)
        ])
        
    def forward(self, x):
        batch_size, sequence_length, *input_dims = x.shape
        
        # Encode all time steps
        x_reshaped = x.view(batch_size * sequence_length, *input_dims)
        encoded_features = self.encoder(x_reshaped)
        encoded_features = encoded_features.view(batch_size, sequence_length, -1)
        
        # Extract context from past
        context_length = sequence_length - self.prediction_steps
        context_input = encoded_features[:, :context_length]
        future_targets = encoded_features[:, context_length:]
        
        # Generate context representation
        context_output, _ = self.context_network(context_input)
        final_context = context_output[:, -1]  # Use last context state
        
        # Predict future representations
        predictions = []
        for i, prediction_net in enumerate(self.prediction_networks):
            pred = prediction_net(final_context)
            predictions.append(pred)
            
        return torch.stack(predictions, dim=1), future_targets

class CPCLoss(nn.Module):
    def __init__(self, temperature=0.1):
        super().__init__()
        self.temperature = temperature
        
    def forward(self, predictions, targets):
        batch_size, num_predictions, feature_dim = predictions.shape
        loss = 0
        
        for i in range(num_predictions):
            pred = predictions[:, i]  # [batch_size, feature_dim]
            target = targets[:, i]    # [batch_size, feature_dim]
            
            # Compute similarity scores
            scores = torch.mm(pred, target.transpose(0, 1)) / self.temperature
            
            # Contrastive loss (InfoNCE)
            labels = torch.arange(batch_size, device=predictions.device)
            step_loss = F.cross_entropy(scores, labels)
            loss += step_loss
            
        return loss / num_predictions
```

