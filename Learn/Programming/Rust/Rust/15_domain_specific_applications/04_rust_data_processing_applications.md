## Rust Data Processing Applications


### Serialization Formats

Rust excels at handling various serialization formats with excellent performance and type safety. The ecosystem provides robust libraries for common formats with zero-copy deserialization capabilities.

**Key points:**

- `serde` provides a unified serialization framework across formats
- Zero-copy deserialization with `&str` and `&[u8]` for performance
- Custom serializers and deserializers for domain-specific needs
- Schema validation and evolution support
- Binary formats like MessagePack and CBOR for efficiency

**Example:**

```rust
use serde::{Deserialize, Serialize};
use serde_json;
use rmp_serde as rmps;

#[derive(Serialize, Deserialize, Debug)]
struct DataRecord {
    id: u64,
    timestamp: i64,
    values: Vec<f64>,
    metadata: HashMap<String, String>,
}

// JSON processing with streaming
fn process_json_stream(reader: impl Read) -> Result<Vec<DataRecord>, Box<dyn Error>> {
    let mut records = Vec::new();
    let deserializer = serde_json::Deserializer::from_reader(reader);
    
    for record in deserializer.into_iter::<DataRecord>() {
        records.push(record?);
    }
    Ok(records)
}

// Zero-copy JSON parsing
#[derive(Deserialize)]
struct BorrowedRecord<'a> {
    name: &'a str,
    data: &'a RawValue,
}

// Binary serialization with MessagePack
fn serialize_binary(records: &[DataRecord]) -> Result<Vec<u8>, rmps::encode::Error> {
    rmps::to_vec(records)
}

// Custom serializer for specific format
use serde::ser::{Serialize, Serializer, SerializeStruct};

impl Serialize for CustomFormat {
    fn serialize<S>(&self, serializer: S) -> Result<S::Ok, S::Error>
    where
        S: Serializer,
    {
        let mut state = serializer.serialize_struct("CustomFormat", 3)?;
        state.serialize_field("version", &self.version)?;
        state.serialize_field("data", &hex::encode(&self.data))?;
        state.serialize_field("checksum", &self.calculate_checksum())?;
        state.end()
    }
}
```

The `quick-xml` crate provides streaming XML parsing, while `csv` offers high-performance CSV processing with automatic type inference. Protocol Buffers support through `prost` enables efficient cross-language data exchange.

### Data Transformation Pipelines

Rust's iterator system and functional programming features make it ideal for building efficient data transformation pipelines with compile-time guarantees.

**Key points:**

- Iterator chains provide zero-cost abstractions for transformations
- `rayon` enables parallel processing across pipeline stages
- Error handling with `Result` types maintains pipeline integrity
- Streaming processing for large datasets that don't fit in memory
- Custom iterator adaptors for domain-specific operations

**Example:**

```rust
use rayon::prelude::*;
use std::collections::HashMap;

#[derive(Debug, Clone)]
struct RawData {
    sensor_id: String,
    timestamp: i64,
    value: f64,
    quality: u8,
}

#[derive(Debug)]
struct ProcessedData {
    sensor_id: String,
    hour: i64,
    avg_value: f64,
    sample_count: usize,
}

// Sequential transformation pipeline
fn transform_data(raw_data: Vec<RawData>) -> Result<Vec<ProcessedData>, ProcessingError> {
    raw_data
        .into_iter()
        .filter(|record| record.quality > 80) // Quality filter
        .map(|record| validate_record(record)) // Validation
        .collect::<Result<Vec<_>, _>>()? // Early error return
        .into_iter()
        .map(|record| normalize_timestamp(record)) // Transformation
        .group_by(|record| (record.sensor_id.clone(), record.hour))
        .map(|(key, group)| aggregate_group(key, group))
        .collect()
}

// Parallel pipeline processing
fn parallel_transform(raw_data: Vec<RawData>) -> Vec<ProcessedData> {
    raw_data
        .into_par_iter()
        .filter(|record| record.quality > 80)
        .map(|record| process_record(record))
        .filter_map(Result::ok)
        .collect::<Vec<_>>()
        .into_iter()
        .group_by(|record| record.sensor_id.clone())
        .map(|(sensor_id, records)| aggregate_sensor_data(sensor_id, records))
        .collect()
}

// Streaming pipeline for large datasets
struct DataPipeline<R: BufRead> {
    reader: R,
    buffer: String,
}

impl<R: BufRead> DataPipeline<R> {
    fn new(reader: R) -> Self {
        Self {
            reader,
            buffer: String::new(),
        }
    }
    
    fn process_stream(&mut self) -> impl Iterator<Item = Result<ProcessedData, ProcessingError>> + '_ {
        std::iter::from_fn(move || {
            self.buffer.clear();
            match self.reader.read_line(&mut self.buffer) {
                Ok(0) => None, // EOF
                Ok(_) => Some(self.parse_and_transform(&self.buffer)),
                Err(e) => Some(Err(ProcessingError::IoError(e))),
            }
        })
    }
}
```

Custom iterator adaptors can encapsulate complex transformation logic while maintaining the zero-cost abstraction benefits. The `itertools` crate provides additional iterator methods for grouping, windowing, and batching operations.

### ETL Processes

Rust's performance and reliability make it excellent for Extract, Transform, Load operations, especially for high-throughput data processing systems.

**Key points:**

- Async I/O with `tokio` for concurrent data extraction
- Memory-efficient processing of large datasets
- Robust error handling and recovery mechanisms
- Integration with databases, message queues, and file systems
- Monitoring and observability through metrics and logging

**Example:**

```rust
use tokio::fs::File;
use tokio::io::{AsyncBufReadExt, BufReader};
use sqlx::{PgPool, Row};
use tracing::{info, error, instrument};

struct ETLPipeline {
    source_config: SourceConfig,
    transform_rules: Vec<TransformRule>,
    destination: PgPool,
    batch_size: usize,
}

impl ETLPipeline {
    #[instrument(skip(self))]
    async fn run(&self) -> Result<ETLStats, ETLError> {
        let mut stats = ETLStats::default();
        
        // Extract phase
        let extracted_data = self.extract_data().await?;
        stats.extracted_count = extracted_data.len();
        
        // Transform phase
        let transformed_data = self.transform_data(extracted_data).await?;
        stats.transformed_count = transformed_data.len();
        
        // Load phase
        let loaded_count = self.load_data(transformed_data).await?;
        stats.loaded_count = loaded_count;
        
        info!("ETL pipeline completed: {:?}", stats);
        Ok(stats)
    }
    
    async fn extract_data(&self) -> Result<Vec<RawRecord>, ETLError> {
        match &self.source_config {
            SourceConfig::File(path) => self.extract_from_file(path).await,
            SourceConfig::Database(conn) => self.extract_from_database(conn).await,
            SourceConfig::Api(endpoint) => self.extract_from_api(endpoint).await,
        }
    }
    
    async fn extract_from_file(&self, path: &Path) -> Result<Vec<RawRecord>, ETLError> {
        let file = File::open(path).await?;
        let reader = BufReader::new(file);
        let mut lines = reader.lines();
        let mut records = Vec::new();
        
        while let Some(line) = lines.next_line().await? {
            match serde_json::from_str::<RawRecord>(&line) {
                Ok(record) => records.push(record),
                Err(e) => {
                    error!("Failed to parse line: {}, error: {}", line, e);
                    continue;
                }
            }
        }
        
        Ok(records)
    }
    
    async fn transform_data(&self, data: Vec<RawRecord>) -> Result<Vec<TransformedRecord>, ETLError> {
        // Parallel transformation with error collection
        let results: Vec<Result<TransformedRecord, TransformError>> = data
            .into_par_iter()
            .map(|record| self.apply_transforms(record))
            .collect();
            
        let mut transformed = Vec::new();
        let mut errors = Vec::new();
        
        for result in results {
            match result {
                Ok(record) => transformed.push(record),
                Err(e) => errors.push(e),
            }
        }
        
        if !errors.is_empty() {
            error!("Transform errors: {:?}", errors);
        }
        
        Ok(transformed)
    }
    
    async fn load_data(&self, data: Vec<TransformedRecord>) -> Result<usize, ETLError> {
        let mut loaded_count = 0;
        
        for batch in data.chunks(self.batch_size) {
            let mut tx = self.destination.begin().await?;
            
            for record in batch {
                sqlx::query("INSERT INTO processed_data (id, value, timestamp) VALUES ($1, $2, $3)")
                    .bind(&record.id)
                    .bind(record.value)
                    .bind(record.timestamp)
                    .execute(&mut *tx)
                    .await?;
            }
            
            tx.commit().await?;
            loaded_count += batch.len();
        }
        
        Ok(loaded_count)
    }
}
```

### Data Validation

Rust's type system provides compile-time validation, while runtime validation ensures data integrity throughout processing pipelines.

**Key points:**

- Custom `Deserialize` implementations for validation during parsing
- `validator` crate for declarative validation rules
- Schema validation for structured data formats
- Custom error types with detailed validation failure information
- Integration with parsing for early error detection

**Example:**

```rust
use validator::{Validate, ValidationError};
use serde::{Deserialize, Deserializer};
use std::collections::HashMap;

#[derive(Debug, Deserialize, Validate)]
struct UserRecord {
    #[validate(length(min = 1, max = 50))]
    name: String,
    
    #[validate(email)]
    email: String,
    
    #[validate(range(min = 0, max = 150))]
    age: u8,
    
    #[validate(custom = "validate_phone")]
    phone: String,
    
    #[validate(nested)]
    address: Address,
    
    #[serde(deserialize_with = "deserialize_tags")]
    tags: Vec<String>,
}

#[derive(Debug, Deserialize, Validate)]
struct Address {
    #[validate(length(min = 1, max = 100))]
    street: String,
    
    #[validate(length(min = 1, max = 50))]
    city: String,
    
    #[validate(regex = "ZIP_REGEX")]
    postal_code: String,
}

fn validate_phone(phone: &str) -> Result<(), ValidationError> {
    if phone.len() >= 10 && phone.chars().all(|c| c.is_numeric() || c == '-') {
        Ok(())
    } else {
        Err(ValidationError::new("invalid_phone_format"))
    }
}

fn deserialize_tags<'de, D>(deserializer: D) -> Result<Vec<String>, D::Error>
where
    D: Deserializer<'de>,
{
    let tags: Vec<String> = Vec::deserialize(deserializer)?;
    
    if tags.len() > 10 {
        return Err(serde::de::Error::custom("too many tags"));
    }
    
    for tag in &tags {
        if tag.len() > 20 {
            return Err(serde::de::Error::custom("tag too long"));
        }
    }
    
    Ok(tags)
}

// Schema validation for JSON data
struct SchemaValidator {
    schema: serde_json::Value,
    compiled_schema: jsonschema::JSONSchema,
}

impl SchemaValidator {
    fn new(schema_json: &str) -> Result<Self, ValidationError> {
        let schema: serde_json::Value = serde_json::from_str(schema_json)?;
        let compiled_schema = jsonschema::JSONSchema::compile(&schema)
            .map_err(|e| ValidationError::new("schema_compilation_failed"))?;
            
        Ok(Self { schema, compiled_schema })
    }
    
    fn validate_data(&self, data: &serde_json::Value) -> Result<(), Vec<String>> {
        let validation_result = self.compiled_schema.validate(data);
        
        match validation_result {
            Ok(_) => Ok(()),
            Err(errors) => {
                let error_messages: Vec<String> = errors
                    .map(|error| format!("{}: {}", error.instance_path, error))
                    .collect();
                Err(error_messages)
            }
        }
    }
}

// Data quality assessment
#[derive(Debug)]
struct DataQualityReport {
    total_records: usize,
    valid_records: usize,
    validation_errors: HashMap<String, usize>,
    completeness_score: f64,
    accuracy_score: f64,
}

fn assess_data_quality(records: &[UserRecord]) -> DataQualityReport {
    let mut error_counts = HashMap::new();
    let mut valid_count = 0;
    
    for record in records {
        match record.validate() {
            Ok(_) => valid_count += 1,
            Err(errors) => {
                for (field, field_errors) in errors.field_errors() {
                    let count = error_counts.entry(field.to_string()).or_insert(0);
                    *count += field_errors.len();
                }
            }
        }
    }
    
    let completeness_score = valid_count as f64 / records.len() as f64;
    let accuracy_score = calculate_accuracy_score(records);
    
    DataQualityReport {
        total_records: records.len(),
        valid_records: valid_count,
        validation_errors: error_counts,
        completeness_score,
        accuracy_score,
    }
}
```

### Database Engines

Rust's performance characteristics and memory safety make it excellent for building database engines and storage systems.

**Key points:**

- Custom storage engines with precise memory management
- Lock-free data structures for concurrent access
- ACID transaction support through careful state management
- Query optimization and execution planning
- Integration with existing database protocols

**Example:**

```rust
use std::collections::BTreeMap;
use std::sync::{Arc, RwLock};
use tokio::sync::RwLock as AsyncRwLock;

// Simple in-memory key-value store with ACID properties
pub struct SimpleDB {
    data: Arc<AsyncRwLock<BTreeMap<String, Vec<u8>>>>,
    transaction_log: Arc<AsyncRwLock<Vec<LogEntry>>>,
    checkpoint_interval: usize,
}

#[derive(Debug, Clone)]
pub enum LogEntry {
    Insert { key: String, value: Vec<u8> },
    Update { key: String, old_value: Vec<u8>, new_value: Vec<u8> },
    Delete { key: String, value: Vec<u8> },
    Commit { transaction_id: u64 },
    Rollback { transaction_id: u64 },
}

impl SimpleDB {
    pub fn new() -> Self {
        Self {
            data: Arc::new(AsyncRwLock::new(BTreeMap::new())),
            transaction_log: Arc::new(AsyncRwLock::new(Vec::new())),
            checkpoint_interval: 1000,
        }
    }
    
    pub async fn get(&self, key: &str) -> Option<Vec<u8>> {
        let data = self.data.read().await;
        data.get(key).cloned()
    }
    
    pub async fn put(&self, key: String, value: Vec<u8>) -> Result<(), DbError> {
        let mut data = self.data.write().await;
        let mut log = self.transaction_log.write().await;
        
        let old_value = data.get(&key).cloned();
        
        // Write to log first (WAL)
        let log_entry = match old_value {
            Some(old) => LogEntry::Update {
                key: key.clone(),
                old_value: old,
                new_value: value.clone(),
            },
            None => LogEntry::Insert {
                key: key.clone(),
                value: value.clone(),
            },
        };
        
        log.push(log_entry);
        
        // Then update in-memory data
        data.insert(key, value);
        
        // Checkpoint if needed
        if log.len() >= self.checkpoint_interval {
            self.checkpoint().await?;
        }
        
        Ok(())
    }
    
    async fn checkpoint(&self) -> Result<(), DbError> {
        let data = self.data.read().await;
        let mut log = self.transaction_log.write().await;
        
        // Serialize data to disk
        let serialized = bincode::serialize(&*data)?;
        tokio::fs::write("checkpoint.db", serialized).await?;
        
        // Clear log after successful checkpoint
        log.clear();
        
        Ok(())
    }
}

// Query engine for simple SQL-like operations
pub struct QueryEngine {
    db: Arc<SimpleDB>,
}

#[derive(Debug)]
pub enum Query {
    Select { table: String, conditions: Vec<Condition> },
    Insert { table: String, values: HashMap<String, Value> },
    Update { table: String, values: HashMap<String, Value>, conditions: Vec<Condition> },
    Delete { table: String, conditions: Vec<Condition> },
}

impl QueryEngine {
    pub fn new(db: Arc<SimpleDB>) -> Self {
        Self { db }
    }
    
    pub async fn execute(&self, query: Query) -> Result<QueryResult, QueryError> {
        match query {
            Query::Select { table, conditions } => {
                self.execute_select(&table, &conditions).await
            },
            Query::Insert { table, values } => {
                self.execute_insert(&table, values).await
            },
            Query::Update { table, values, conditions } => {
                self.execute_update(&table, values, &conditions).await
            },
            Query::Delete { table, conditions } => {
                self.execute_delete(&table, &conditions).await
            },
        }
    }
    
    async fn execute_select(&self, table: &str, conditions: &[Condition]) -> Result<QueryResult, QueryError> {
        // Simplified table scan with condition evaluation
        let mut results = Vec::new();
        
        // In a real implementation, this would use indexes and query optimization
        let data = self.db.data.read().await;
        
        for (key, value) in data.iter() {
            if key.starts_with(&format!("{}:", table)) {
                let record: HashMap<String, Value> = bincode::deserialize(value)?;
                
                if self.evaluate_conditions(&record, conditions) {
                    results.push(record);
                }
            }
        }
        
        Ok(QueryResult::Select(results))
    }
    
    fn evaluate_conditions(&self, record: &HashMap<String, Value>, conditions: &[Condition]) -> bool {
        conditions.iter().all(|condition| {
            match record.get(&condition.field) {
                Some(value) => condition.evaluate(value),
                None => false,
            }
        })
    }
}
```

### Compression Algorithms

Rust's zero-cost abstractions and performance characteristics make it ideal for implementing and using compression algorithms in data processing pipelines.

**Key points:**

- Built-in support for common formats through `flate2`, `bzip2`, and `lz4` crates
- Custom compression algorithms with precise memory control
- Streaming compression for large datasets
- Adaptive compression based on data characteristics
- Integration with serialization for automatic compression

**Example:**

```rust
use flate2::{Compression, read::GzDecoder, write::GzEncoder};
use lz4::{Decoder, EncoderBuilder};
use std::io::{Read, Write, BufReader, BufWriter};

pub struct CompressionPipeline {
    algorithm: CompressionAlgorithm,
    level: u32,
    buffer_size: usize,
}

#[derive(Debug, Clone)]
pub enum CompressionAlgorithm {
    Gzip,
    Lz4,
    Zstd,
    Brotli,
    Custom(Box<dyn CustomCompressor>),
}

impl CompressionPipeline {
    pub fn new(algorithm: CompressionAlgorithm, level: u32) -> Self {
        Self {
            algorithm,
            level,
            buffer_size: 64 * 1024, // 64KB buffer
        }
    }
    
    pub fn compress_data(&self, input: &[u8]) -> Result<Vec<u8>, CompressionError> {
        match &self.algorithm {
            CompressionAlgorithm::Gzip => self.compress_gzip(input),
            CompressionAlgorithm::Lz4 => self.compress_lz4(input),
            CompressionAlgorithm::Zstd => self.compress_zstd(input),
            CompressionAlgorithm::Custom(compressor) => compressor.compress(input),
        }
    }
    
    fn compress_gzip(&self, input: &[u8]) -> Result<Vec<u8>, CompressionError> {
        let mut encoder = GzEncoder::new(Vec::new(), Compression::new(self.level));
        encoder.write_all(input)?;
        Ok(encoder.finish()?)
    }
    
    fn compress_lz4(&self, input: &[u8]) -> Result<Vec<u8>, CompressionError> {
        let mut encoder = EncoderBuilder::new()
            .level(self.level)
            .build(Vec::new())?;
        encoder.write_all(input)?;
        let (compressed, _) = encoder.finish();
        Ok(compressed?)
    }
    
    // Streaming compression for large files
    pub async fn compress_stream<R, W>(&self, mut reader: R, mut writer: W) -> Result<u64, CompressionError>
    where
        R: AsyncRead + Unpin,
        W: AsyncWrite + Unpin,
    {
        let mut total_bytes = 0u64;
        let mut buffer = vec![0u8; self.buffer_size];
        
        match &self.algorithm {
            CompressionAlgorithm::Gzip => {
                let mut encoder = GzEncoder::new(writer, Compression::new(self.level));
                
                loop {
                    let bytes_read = reader.read(&mut buffer).await?;
                    if bytes_read == 0 {
                        break;
                    }
                    
                    encoder.write_all(&buffer[..bytes_read]).await?;
                    total_bytes += bytes_read as u64;
                }
                
                encoder.shutdown().await?;
            },
            _ => {
                // Implement other streaming algorithms
                todo!("Implement streaming for other algorithms");
            }
        }
        
        Ok(total_bytes)
    }
    
    // Adaptive compression based on data analysis
    pub fn analyze_and_compress(&self, data: &[u8]) -> Result<(Vec<u8>, CompressionStats), CompressionError> {
        let stats = self.analyze_data(data);
        let algorithm = self.select_optimal_algorithm(&stats);
        
        let compressed = self.compress_with_algorithm(data, &algorithm)?;
        
        let compression_stats = CompressionStats {
            original_size: data.len(),
            compressed_size: compressed.len(),
            algorithm_used: algorithm,
            compression_ratio: data.len() as f64 / compressed.len() as f64,
            entropy: stats.entropy,
        };
        
        Ok((compressed, compression_stats))
    }
    
    fn analyze_data(&self, data: &[u8]) -> DataStats {
        let mut byte_counts = [0u32; 256];
        
        for &byte in data {
            byte_counts[byte as usize] += 1;
        }
        
        let entropy = self.calculate_entropy(&byte_counts, data.len());
        let repetition_ratio = self.calculate_repetition_ratio(data);
        
        DataStats {
            entropy,
            repetition_ratio,
            size: data.len(),
            byte_distribution: byte_counts,
        }
    }
    
    fn calculate_entropy(&self, counts: &[u32; 256], total: usize) -> f64 {
        let mut entropy = 0.0;
        
        for &count in counts {
            if count > 0 {
                let probability = count as f64 / total as f64;
                entropy -= probability * probability.log2();
            }
        }
        
        entropy
    }
    
    fn select_optimal_algorithm(&self, stats: &DataStats) -> CompressionAlgorithm {
        // Simple heuristic-based algorithm selection
        if stats.entropy < 3.0 {
            CompressionAlgorithm::Lz4 // Fast compression for low entropy
        } else if stats.repetition_ratio > 0.7 {
            CompressionAlgorithm::Gzip // Good for repetitive data
        } else {
            CompressionAlgorithm::Zstd // Balanced for mixed data
        }
    }
}

// Dictionary-based compression for structured data
pub struct DictionaryCompressor {
    dictionary: HashMap<Vec<u8>, u16>,
    reverse_dictionary: HashMap<u16, Vec<u8>>,
    next_id: u16,
}

impl DictionaryCompressor {
    pub fn new() -> Self {
        Self {
            dictionary: HashMap::new(),
            reverse_dictionary: HashMap::new(),
            next_id: 0,
        }
    }
    
    pub fn compress_with_dictionary(&mut self, data: &[u8], window_size: usize) -> Vec<u8> {
        let mut compressed = Vec::new();
        let mut i = 0;
        
        while i < data.len() {
            let mut best_match = (0, 1); // (dictionary_id, length)
            
            // Find longest match in dictionary
            for len in (1..=window_size.min(data.len() - i)).rev() {
                let slice = &data[i..i + len];
                
                if let Some(&dict_id) = self.dictionary.get(slice) {
                    best_match = (dict_id, len);
                    break;
                }
            }
            
            if best_match.1 > 1 || (best_match.1 == 1 && best_match.0 != 0) {
                // Use dictionary reference
                compressed.extend_from_slice(&best_match.0.to_le_bytes());
                compressed.push(best_match.1 as u8);
                i += best_match.1;
            } else {
                // Add new entry to dictionary and output literal
                let slice = &data[i..i + 1];
                if !self.dictionary.contains_key(slice) && self.next_id < u16::MAX {
                    self.dictionary.insert(slice.to_vec(), self.next_id);
                    self.reverse_dictionary.insert(self.next_id, slice.to_vec());
                    self.next_id += 1;
                }
                
                compressed.push(0); // Literal marker
                compressed.push(data[i]);
                i += 1;
            }
        }
        
        compressed
    }
}
```

**Conclusion:** Rust's ecosystem provides comprehensive tools for data processing applications, from high-level abstractions like `serde` for serialization to low-level control for custom database engines. The language's performance characteristics, memory safety, and rich type system make it particularly well-suited for building reliable, efficient data processing systems.

**Next steps:** Consider exploring specialized crates like `polars` for DataFrame operations, `arrow` for columnar data processing, and `datafusion` for SQL query engines. The async ecosystem with `tokio` enables building scalable concurrent data processing systems.

---

