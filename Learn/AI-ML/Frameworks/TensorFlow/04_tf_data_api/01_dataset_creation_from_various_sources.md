## Dataset Creation from Various Sources


The tf.data API supports multiple data sources and formats, enabling flexible data ingestion for machine learning workflows.

**From Tensors and Arrays** The most basic dataset creation involves in-memory data structures:

```python
# From lists or arrays
dataset = tf.data.Dataset.from_tensor_slices([1, 2, 3, 4, 5])
dataset = tf.data.Dataset.from_tensor_slices({'features': features_array, 'labels': labels_array})

# From tensors
tensor_dataset = tf.data.Dataset.from_tensors(tf.constant([[1, 2], [3, 4]]))
```

**From Files** File-based dataset creation supports various formats:

```python
# Text files
text_dataset = tf.data.TextLineDataset(['file1.txt', 'file2.txt'])

# CSV files
csv_dataset = tf.data.experimental.CsvDataset(
    filenames=['data.csv'],
    record_defaults=[tf.float32, tf.int32, tf.string]
)

# TFRecord files (TensorFlow's binary format)
tfrecord_dataset = tf.data.TFRecordDataset(['data.tfrecord'])

# Image files
image_paths = tf.data.Dataset.list_files('images/*.jpg')
image_dataset = image_paths.map(lambda x: tf.io.read_file(x))
```

**From Generators** Python generators enable custom data creation logic:

```python
def data_generator():
    for i in range(1000):
        yield (i, i**2)

dataset = tf.data.Dataset.from_generator(
    data_generator,
    output_signature=(
        tf.TensorSpec(shape=(), dtype=tf.int32),
        tf.TensorSpec(shape=(), dtype=tf.int32)
    )
)
```

**From External Sources** Integration with external data systems:

```python
# From SQL databases (requires additional setup)
# [Unverified] - specific implementation varies by database type
sql_dataset = tf.data.experimental.SqlDataset(
    driver_name="sqlite",
    data_source_name="database.db",
    query="SELECT * FROM table_name"
)
```

**Directory Structure Datasets** For image classification tasks with directory-based organization:

```python
dataset = tf.keras.utils.image_dataset_from_directory(
    'data_dir',
    labels='inferred',
    label_mode='categorical',
    batch_size=32,
    image_size=(224, 224)
)
```

