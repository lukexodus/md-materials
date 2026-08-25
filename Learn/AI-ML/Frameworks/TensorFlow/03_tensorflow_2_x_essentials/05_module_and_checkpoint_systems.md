## Module and Checkpoint Systems


**tf.Module Architecture** tf.Module provides the base class for building reusable components in TensorFlow 2.x. It automatically tracks variables and sub-modules, enabling proper serialization and checkpoint management.

**Variable Tracking** tf.Module automatically discovers and tracks:

- tf.Variable instances assigned to module attributes
- Variables created within tf.keras.layers
- Sub-modules that are themselves tf.Module instances
- Variables created within @tf.function methods

**Checkpoint System Evolution** TensorFlow 2.x checkpoints store variable values and their relationship structure rather than graph definitions. This provides several advantages:

- **Model Architecture Independence**: Checkpoints can be loaded into different but compatible model architectures
- **Partial Loading**: Specific layers or variable subsets can be restored selectively
- **Cross-Platform Compatibility**: Checkpoints work across different hardware and software configurations

**SavedModel Format** The SavedModel format in TensorFlow 2.x preserves:

- Complete computational graphs (via tf.function)
- Variable values and optimization states
- Asset files (vocabularies, lookup tables)
- Signature definitions for serving

**Checkpoint Management**

```python
# Creating checkpoints
model = tf.keras.Sequential([...])
checkpoint = tf.train.Checkpoint(model=model)
manager = tf.train.CheckpointManager(checkpoint, '/path/to/checkpoints', max_to_keep=3)

# Saving checkpoints
manager.save()

# Restoring checkpoints
latest = tf.train.latest_checkpoint('/path/to/checkpoints')
checkpoint.restore(latest)
```

