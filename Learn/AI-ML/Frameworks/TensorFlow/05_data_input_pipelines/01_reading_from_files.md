## Reading from Files


### CSV File Processing

TensorFlow provides specialized functions for reading structured data from CSV files through `tf.data.experimental.make_csv_dataset()` and `tf.io.decode_csv()`. These functions handle header parsing, data type inference, and missing value management automatically while supporting streaming processing for large datasets.

**Key Points:**

- `tf.data.experimental.make_csv_dataset()` automatically infers column types and handles headers
- `tf.io.decode_csv()` provides lower-level control over parsing with explicit column specifications
- Batch processing capabilities enable efficient memory utilization for large CSV files
- Missing value handling through default value specifications and validation rules
- Column selection and filtering reduce memory overhead by excluding unnecessary features

### JSON Data Ingestion

JSON data processing requires parsing structured text into tensor representations. TensorFlow handles JSON through `tf.io.decode_json_example()` for structured records and custom parsing functions for complex nested structures. The pipeline approach enables streaming processing of large JSON datasets without memory limitations.

**Key Points:**

- Structured JSON records map directly to feature dictionaries through parsing specifications
- Nested JSON structures require custom parsing functions or flattening operations
- Schema validation ensures consistent data types across JSON records
- Error handling mechanisms manage malformed JSON entries without pipeline failure
- [Inference] Memory efficiency depends on JSON structure complexity and nesting depth

### TFRecord Format Processing

TFRecord represents TensorFlow's optimized binary format for storing serialized data examples. This format provides superior performance for training pipelines through efficient serialization, compression support, and optimized I/O operations. Protocol Buffer serialization enables cross-platform compatibility and version control.

**Key Points:**

- `tf.data.TFRecordDataset()` creates datasets directly from TFRecord files
- `tf.train.Example` protocol buffers structure data with feature specifications
- Built-in compression support (GZIP, ZLIB) reduces storage requirements
- Sharding capabilities distribute large datasets across multiple files
- Schema evolution support maintains compatibility across data versions

**Examples:**

```python
# CSV dataset creation
csv_dataset = tf.data.experimental.make_csv_dataset(
    "data.csv",
    batch_size=32,
    column_names=['feature1', 'feature2', 'label'],
    column_defaults=[tf.float32, tf.float32, tf.int32]
)

# TFRecord dataset processing
def parse_example(example_proto):
    feature_description = {
        'image': tf.io.FixedLenFeature([], tf.string),
        'label': tf.io.FixedLenFeature([], tf.int64),
    }
    return tf.io.parse_single_example(example_proto, feature_description)

tfrecord_dataset = tf.data.TFRecordDataset("data.tfrecord")
parsed_dataset = tfrecord_dataset.map(parse_example)
```

