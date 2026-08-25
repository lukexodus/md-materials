## Dataset Transformations and Preprocessing


Dataset transformations enable data preprocessing and augmentation within the input pipeline.

**Basic Transformations** Core transformation operations modify dataset elements:

```python
# Map transformation applies function to each element
dataset = dataset.map(lambda x: x * 2)

# Filter removes elements based on predicate
dataset = dataset.filter(lambda x: x > 0)

# Take and skip for dataset slicing
train_dataset = dataset.take(8000)
test_dataset = dataset.skip(8000)

# Repeat for multiple epochs
dataset = dataset.repeat(epochs)
```

**Advanced Preprocessing** Complex preprocessing operations for different data types:

```python
# Image preprocessing
def preprocess_image(image_path):
    image = tf.io.read_file(image_path)
    image = tf.io.decode_image(image, channels=3)
    image = tf.image.resize(image, [224, 224])
    image = tf.cast(image, tf.float32) / 255.0
    return image

image_dataset = image_paths.map(preprocess_image)

# Text preprocessing
def preprocess_text(text):
    text = tf.strings.lower(text)
    text = tf.strings.regex_replace(text, '[^a-zA-Z0-9 ]', '')
    return text

text_dataset = text_dataset.map(preprocess_text)
```

**Parallel Processing** Transformation operations support parallel execution:

```python
# Parallel map with multiple CPU cores
dataset = dataset.map(
    preprocess_function,
    num_parallel_calls=tf.data.AUTOTUNE
)

# Interleave for parallel file reading
dataset = tf.data.Dataset.list_files('data/*.tfrecord')
dataset = dataset.interleave(
    tf.data.TFRecordDataset,
    cycle_length=4,
    num_parallel_calls=tf.data.AUTOTUNE
)
```

**Data Augmentation** On-the-fly data augmentation within the pipeline:

```python
def augment_image(image, label):
    image = tf.image.random_flip_left_right(image)
    image = tf.image.random_brightness(image, 0.2)
    image = tf.image.random_contrast(image, 0.8, 1.2)
    return image, label

dataset = dataset.map(augment_image)
```

