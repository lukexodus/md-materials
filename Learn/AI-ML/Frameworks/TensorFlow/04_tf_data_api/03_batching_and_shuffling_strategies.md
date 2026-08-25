## Batching and Shuffling Strategies


Proper batching and shuffling are crucial for effective model training.

**Batching Operations** Various batching strategies accommodate different requirements:

```python
# Simple batching
dataset = dataset.batch(batch_size=32)

# Padded batching for variable-length sequences
dataset = dataset.padded_batch(
    batch_size=32,
    padded_shapes=([None], []),  # Variable length sequences
    padding_values=(0, -1)       # Padding values
)

# Bucket batching for similar-length sequences
def bucket_function(x, y):
    return tf.cast(tf.shape(x)[0] // 10, tf.int64)

dataset = dataset.group_by_window(
    key_func=bucket_function,
    reduce_func=lambda _, els: els.batch(32),
    window_size=32
)
```

**Shuffling Strategies** Shuffling prevents overfitting to data order:

```python
# Basic shuffling with buffer
dataset = dataset.shuffle(buffer_size=10000)

# Reshuffle each epoch
dataset = dataset.shuffle(buffer_size=10000, reshuffle_each_iteration=True)

# File-level shuffling for large datasets
filenames = tf.data.Dataset.list_files('data/*.tfrecord')
filenames = filenames.shuffle(buffer_size=100)
dataset = filenames.interleave(tf.data.TFRecordDataset)
```

**Optimal Order of Operations** The sequence of dataset operations affects performance and correctness:

```python
# Recommended order for training datasets
dataset = (dataset
    .shuffle(10000)           # Shuffle before repeat
    .repeat()                 # Repeat for multiple epochs
    .map(preprocess_fn)       # Apply preprocessing
    .batch(32)                # Batch after preprocessing
    .prefetch(tf.data.AUTOTUNE)  # Prefetch for performance
)
```

