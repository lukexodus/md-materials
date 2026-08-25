## Dictionary Learning Methods


Dictionary learning discovers a sparse representation of data by learning an overcomplete dictionary where each sample can be represented as a sparse linear combination of dictionary atoms.

**Key points:**

- Learns adaptive dictionaries tailored to specific data
- Promotes sparse representations for interpretability
- Handles noise and missing data well
- Computationally intensive but highly flexible
- Excellent for feature learning and denoising

```python
from sklearn.decomposition import DictionaryLearning, MiniBatchDictionaryLearning
from sklearn.feature_extraction.image import extract_patches_2d, reconstruct_from_patches_2d

# Image patch dictionary learning
def learn_image_dictionary(image, patch_size=(8, 8), n_components=100):
    """Learn dictionary from image patches"""
    # Extract patches
    patches = extract_patches_2d(image, patch_size, max_patches=2000, random_state=42)
    patches = patches.reshape(patches.shape[0], -1)
    
    # Normalize patches
    patches = patches - np.mean(patches, axis=1, keepdims=True)
    patches = patches / (np.std(patches, axis=1, keepdims=True) + 1e-8)
    
    # Learn dictionary
    dict_learner = DictionaryLearning(n_components=n_components, alpha=1, 
                                    max_iter=100, random_state=42)
    dictionary = dict_learner.fit(patches)
    
    return dictionary, patches

# Load sample image (use a face from the dataset)
sample_image = faces.data[0].reshape(64, 64)

# Learn dictionary from image patches
dict_model, patches = learn_image_dictionary(sample_image, patch_size=(8, 8), n_components=64)

# Visualize learned dictionary atoms
fig, axes = plt.subplots(8, 8, figsize=(12, 12))
for i, ax in enumerate(axes.flat):
    if i < dict_model.components_.shape[0]:
        atom = dict_model.components_[i].reshape(8, 8)
        ax.imshow(atom, cmap='gray')
        ax.set_title(f'Atom {i+1}')
    ax.axis('off')
plt.suptitle('Learned Dictionary Atoms')
plt.tight_layout()
plt.show()

# Sparse coding: represent new data using learned dictionary
def sparse_encode_image(image, dict_model, patch_size=(8, 8)):
    """Encode image using learned dictionary"""
    patches = extract_patches_2d(image, patch_size, max_patches=1000, random_state=42)
    patches = patches.reshape(patches.shape[0], -1)
    
    # Normalize patches
    patches = patches - np.mean(patches, axis=1, keepdims=True)
    patches = patches / (np.std(patches, axis=1, keepdims=True) + 1e-8)
    
    # Transform using dictionary
    sparse_codes = dict_model.transform(patches)
    
    return sparse_codes, patches

# Test on another image
test_image = faces.data[10].reshape(64, 64)
sparse_codes, test_patches = sparse_encode_image(test_image, dict_model)

print(f"Dictionary shape: {dict_model.components_.shape}")
print(f"Sparse codes shape: {sparse_codes.shape}")
print(f"Average sparsity: {np.mean(sparse_codes == 0):.4f}")
print(f"Average non-zero elements per patch: {np.mean(np.count_nonzero(sparse_codes, axis=1)):.2f}")
```

**Online dictionary learning for large datasets:**

```python
# Mini-batch dictionary learning for large datasets
def online_dictionary_learning_demo():
    """Demonstrate online dictionary learning with streaming data"""
    
    # Simulate streaming patches from multiple images
    all_patches = []
    for i in range(20):  # Use 20 face images
        image = faces.data[i].reshape(64, 64)
        patches = extract_patches_2d(image, (6, 6), max_patches=100, random_state=i)
        patches = patches.reshape(patches.shape[0], -1)
        all_patches.extend(patches)
    
    all_patches = np.array(all_patches)
    
    # Normalize all patches
    all_patches = all_patches - np.mean(all_patches, axis=1, keepdims=True)
    all_patches = all_patches / (np.std(all_patches, axis=1, keepdims=True) + 1e-8)
    
    # Online learning with mini-batches
    online_dict = MiniBatchDictionaryLearning(
        n_components=49,  # 7x7 grid of atoms
        alpha=1,
        batch_size=100,
        n_iter=50,
        random_state=42
    )
    
    # Fit in batches to simulate online learning
    batch_size = 200
    for i in range(0, len(all_patches), batch_size):
        batch = all_patches[i:i+batch_size]
        if len(batch) > 0:
            online_dict.partial_fit(batch)
    
    return online_dict, all_patches

online_dict, all_patches = online_dictionary_learning_demo()

# Visualize online learned dictionary
fig, axes = plt.subplots(7, 7, figsize=(12, 12))
for i, ax in enumerate(axes.flat):
    atom = online_dict.components_[i].reshape(6, 6)
    ax.imshow(atom, cmap='gray')
    ax.axis('off')
plt.suptitle('Online Dictionary Learning Results')
plt.tight_layout()
plt.show()

# Compare reconstruction quality
test_patches_sample = all_patches[:100]
sparse_codes_online = online_dict.transform(test_patches_sample)
reconstructed_patches = np.dot(sparse_codes_online, online_dict.components_)

reconstruction_error = np.mean((test_patches_sample - reconstructed_patches) ** 2)
print(f"Online dictionary reconstruction error: {reconstruction_error:.6f}")
print(f"Sparsity level: {np.mean(sparse_codes_online == 0):.4f}")
```

