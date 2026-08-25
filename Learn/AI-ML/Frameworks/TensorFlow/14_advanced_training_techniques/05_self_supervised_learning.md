## Self-supervised Learning


### Pretext Task Design

Self-supervised learning creates supervisory signals from data itself without human annotations, enabling learning from large unlabeled datasets.

**Predictive Tasks**: Models predict missing or future parts of input data, such as next frame prediction in videos or masked token prediction in sequences.

**Contrastive Tasks**: Learn representations by contrasting positive and negative example pairs, encouraging similar representations for related samples.

**Generative Tasks**: Reconstruct input data from corrupted or partial versions, forcing models to learn meaningful internal representations.

### Common Pretext Tasks

**Image Rotation Prediction**: Trains models to predict rotation angles applied to images, encouraging learning of spatial features.

**Jigsaw Puzzle Solving**: Reconstructs shuffled image patches, promoting understanding of spatial relationships and object structure.

**Inpainting**: Fills missing regions in images, requiring semantic understanding of context and object properties.

**Temporal Order Verification**: Determines correct temporal order of video frames or sequence elements.

### TensorFlow Implementation

```python
# Rotation prediction pretext task
def create_rotation_dataset(images):
    rotated_images = []
    rotation_labels = []
    
    for image in images:
        for angle_idx, angle in enumerate([0, 90, 180, 270]):
            rotated = tf.image.rot90(image, k=angle_idx)
            rotated_images.append(rotated)
            rotation_labels.append(angle_idx)
            
    return tf.stack(rotated_images), tf.keras.utils.to_categorical(rotation_labels, 4)

# Masked image modeling (similar to BERT for images)
class MaskedImageModel(tf.keras.Model):
    def __init__(self, encoder, decoder, mask_ratio=0.15):
        super().__init__()
        self.encoder = encoder
        self.decoder = decoder
        self.mask_ratio = mask_ratio
        
    def call(self, images, training=True):
        if training:
            # Create random masks
            batch_size = tf.shape(images)[0]
            height, width = images.shape[1:3]
            
            mask = tf.random.uniform((batch_size, height, width, 1)) > self.mask_ratio
            masked_images = images * tf.cast(mask, images.dtype)
            
            # Encode masked images
            encoded = self.encoder(masked_images)
            
            # Decode to reconstruct original
            reconstructed = self.decoder(encoded)
            
            return reconstructed, mask
        else:
            return self.encoder(images)

# Contrastive learning data augmentation
def contrastive_augmentation(image):
    # Apply random augmentations to create positive pairs
    augmented1 = tf.image.random_flip_left_right(image)
    augmented1 = tf.image.random_brightness(augmented1, 0.2)
    augmented1 = tf.image.random_contrast(augmented1, 0.8, 1.2)
    
    augmented2 = tf.image.random_flip_left_right(image)
    augmented2 = tf.image.random_hue(augmented2, 0.1)
    augmented2 = tf.image.random_saturation(augmented2, 0.8, 1.2)
    
    return augmented1, augmented2
```

