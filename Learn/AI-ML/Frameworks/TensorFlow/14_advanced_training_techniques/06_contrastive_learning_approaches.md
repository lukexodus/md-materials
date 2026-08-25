## Contrastive Learning Approaches


### Theoretical Foundation

Contrastive learning learns representations by maximizing agreement between differently augmented views of the same data while minimizing agreement with other samples. This approach creates rich representations without requiring labeled data.

**InfoNCE Loss**: Maximizes mutual information between positive pairs while minimizing it for negative pairs, providing theoretical foundation for contrastive objectives.

**Temperature Scaling**: Controls the concentration of the distribution, affecting the difficulty of distinguishing between positive and negative pairs.

**Hard Negative Mining**: Focuses learning on difficult negative examples that are similar to positive pairs but belong to different classes.

### Popular Frameworks

**SimCLR**: Uses extensive data augmentation and large batch sizes to create positive and negative pairs, with a projection head for contrastive learning.

**MoCo (Momentum Contrast)**: Maintains a dynamic dictionary of negative samples using momentum updates, enabling larger effective batch sizes.

**SwAV**: Combines contrastive learning with clustering, using swapped prediction between different augmented views.

**BYOL (Bootstrap Your Own Latent)**: Eliminates the need for negative samples by using momentum updates and stop gradients.

### TensorFlow Implementation

```python
# SimCLR implementation
class SimCLR(tf.keras.Model):
    def __init__(self, encoder, projection_dim=128, temperature=0.1):
        super().__init__()
        self.encoder = encoder
        self.projection_head = tf.keras.Sequential([
            tf.keras.layers.Dense(512, activation='relu'),
            tf.keras.layers.Dense(projection_dim)
        ])
        self.temperature = temperature
        
    def call(self, x1, x2, training=True):
        # Get representations for both augmented views
        h1 = self.encoder(x1, training=training)
        h2 = self.encoder(x2, training=training)
        
        # Project to lower dimensional space
        z1 = self.projection_head(h1, training=training)
        z2 = self.projection_head(h2, training=training)
        
        # Normalize embeddings
        z1 = tf.nn.l2_normalize(z1, axis=1)
        z2 = tf.nn.l2_normalize(z2, axis=1)
        
        return z1, z2
    
    def contrastive_loss(self, z1, z2):
        batch_size = tf.shape(z1)[0]
        
        # Concatenate representations
        representations = tf.concat([z1, z2], axis=0)
        
        # Compute similarity matrix
        similarity_matrix = tf.matmul(representations, representations, transpose_b=True)
        similarity_matrix = similarity_matrix / self.temperature
        
        # Create labels (positive pairs)
        labels = tf.concat([
            tf.range(batch_size, 2 * batch_size),
            tf.range(0, batch_size)
        ], axis=0)
        
        # Create mask to exclude self-similarity
        mask = tf.cast(tf.eye(2 * batch_size), tf.bool)
        similarity_matrix = tf.where(mask, -np.inf, similarity_matrix)
        
        # Compute cross-entropy loss
        loss = tf.keras.losses.sparse_categorical_crossentropy(
            labels, similarity_matrix, from_logits=True
        )
        
        return tf.reduce_mean(loss)

# MoCo implementation
class MoCo(tf.keras.Model):
    def __init__(self, encoder_q, encoder_k, dim=128, K=65536, m=0.999, T=0.07):
        super().__init__()
        self.K = K
        self.m = m
        self.T = T
        
        # Query encoder
        self.encoder_q = encoder_q
        self.fc_q = tf.keras.layers.Dense(dim)
        
        # Key encoder (momentum updated)
        self.encoder_k = encoder_k
        self.fc_k = tf.keras.layers.Dense(dim)
        
        # Initialize key encoder with query encoder weights
        for param_q, param_k in zip(self.encoder_q.trainable_variables + self.fc_q.trainable_variables,
                                   self.encoder_k.trainable_variables + self.fc_k.trainable_variables):
            param_k.assign(param_q)
        
        # Queue for storing negative samples
        self.register_buffer("queue", tf.random.normal([dim, K]))
        self.register_buffer("queue_ptr", tf.Variable(0, dtype=tf.int64))
        
    @tf.function
    def momentum_update_key_encoder(self):
        """Momentum update of the key encoder"""
        for param_q, param_k in zip(self.encoder_q.trainable_variables + self.fc_q.trainable_variables,
                                   self.encoder_k.trainable_variables + self.fc_k.trainable_variables):
            param_k.assign(param_k * self.m + param_q * (1. - self.m))

# BYOL implementation  
class BYOL(tf.keras.Model):
    def __init__(self, encoder, hidden_dim=4096, proj_dim=256, pred_dim=4096, tau=0.996):
        super().__init__()
        self.tau = tau
        
        # Online network
        self.online_encoder = encoder
        self.online_projector = tf.keras.Sequential([
            tf.keras.layers.Dense(hidden_dim, activation='relu'),
            tf.keras.layers.BatchNormalization(),
            tf.keras.layers.Dense(proj_dim)
        ])
        self.predictor = tf.keras.Sequential([
            tf.keras.layers.Dense(pred_dim, activation='relu'),
            tf.keras.layers.BatchNormalization(),
            tf.keras.layers.Dense(proj_dim)
        ])
        
        # Target network (momentum updated)
        self.target_encoder = tf.keras.models.clone_model(encoder)
        self.target_projector = tf.keras.models.clone_model(self.online_projector)
        
    def call(self, x1, x2):
        # Online network forward pass
        online_repr1 = self.online_encoder(x1)
        online_proj1 = self.online_projector(online_repr1)
        online_pred1 = self.predictor(online_proj1)
        
        online_repr2 = self.online_encoder(x2)
        online_proj2 = self.online_projector(online_repr2)
        online_pred2 = self.predictor(online_proj2)
        
        # Target network forward pass (no gradients)
        with tf.stop_gradient():
            target_repr1 = self.target_encoder(x1)
            target_proj1 = self.target_projector(target_repr1)
            
            target_repr2 = self.target_encoder(x2)
            target_proj2 = self.target_projector(target_repr2)
        
        return online_pred1, online_pred2, target_proj1, target_proj2
```

**Key points:**

- Advanced training techniques address limitations of standard supervised learning approaches
- Transfer learning and fine-tuning enable efficient knowledge reuse across related tasks
- Self-supervised and contrastive learning methods reduce dependence on labeled data
- Curriculum learning and multi-task approaches can improve model generalization and training efficiency
- [Inference] Success of these techniques often depends on careful hyperparameter tuning and domain-specific adaptations

**Related topics:** Meta-learning and few-shot learning, neural architecture search, advanced optimization techniques, regularization methods, ensemble learning strategies, and domain adaptation approaches.

---

