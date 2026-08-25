## Advanced Testing in Rust


Advanced testing in Rust encompasses sophisticated techniques and tools that go beyond basic unit testing to ensure software reliability, performance, and correctness. These approaches leverage Rust's ecosystem and tooling to provide comprehensive testing strategies that catch edge cases, measure performance, and maintain code quality across complex systems.

### Property-based Testing

Property-based testing shifts focus from testing specific examples to testing properties that should hold true across a wide range of inputs. Instead of manually crafting test cases, property-based testing generates random inputs and verifies that certain invariants remain true, often discovering edge cases that traditional testing might miss.

**Key points:**

- Tests properties rather than specific input-output pairs
- Automatically generates test cases and shrinks failing cases to minimal examples
- Particularly effective for testing mathematical properties, parsers, and data structures
- The `proptest` and `quickcheck` crates provide property-based testing frameworks

**Example:**

```rust
use proptest::prelude::*;

// Property: reversing a vector twice should yield the original vector
proptest! {
    #[test]
    fn test_reverse_twice(mut vec: Vec<i32>) {
        let original = vec.clone();
        vec.reverse();
        vec.reverse();
        prop_assert_eq!(vec, original);
    }
}

// Property: sorting should preserve all elements
proptest! {
    #[test]
    fn test_sort_preserves_elements(mut vec: Vec<i32>) {
        let mut sorted = vec.clone();
        sorted.sort();
        
        // Count occurrences in both vectors
        let mut original_counts = std::collections::HashMap::new();
        let mut sorted_counts = std::collections::HashMap::new();
        
        for item in &vec {
            *original_counts.entry(*item).or_insert(0) += 1;
        }
        
        for item in &sorted {
            *sorted_counts.entry(*item).or_insert(0) += 1;
        }
        
        prop_assert_eq!(original_counts, sorted_counts);
    }
}

// Custom strategy for testing a binary tree
#[derive(Debug, Clone)]
enum Tree {
    Leaf,
    Node(Box<Tree>, i32, Box<Tree>),
}

impl Tree {
    fn insert(&mut self, value: i32) {
        match self {
            Tree::Leaf => *self = Tree::Node(Box::new(Tree::Leaf), value, Box::new(Tree::Leaf)),
            Tree::Node(left, node_value, right) => {
                if value <= *node_value {
                    left.insert(value);
                } else {
                    right.insert(value);
                }
            }
        }
    }
    
    fn contains(&self, value: i32) -> bool {
        match self {
            Tree::Leaf => false,
            Tree::Node(left, node_value, right) => {
                if value == *node_value {
                    true
                } else if value < *node_value {
                    left.contains(value)
                } else {
                    right.contains(value)
                }
            }
        }
    }
}

// Strategy for generating arbitrary trees
fn arb_tree() -> impl Strategy<Value = Tree> {
    let leaf = Just(Tree::Leaf);
    leaf.prop_recursive(8, 256, 10, |inner| {
        (inner.clone(), any::<i32>(), inner)
            .prop_map(|(left, value, right)| {
                Tree::Node(Box::new(left), value, Box::new(right))
            })
    })
}

proptest! {
    #[test]
    fn test_tree_insert_contains(
        mut tree in arb_tree(),
        values in prop::collection::vec(any::<i32>(), 0..100)
    ) {
        for value in &values {
            tree.insert(*value);
        }
        
        for value in &values {
            prop_assert!(tree.contains(*value));
        }
    }
}

// Testing with constraints
proptest! {
    #[test]
    fn test_division(
        dividend in any::<i32>(),
        divisor in 1..i32::MAX // Exclude zero to avoid division by zero
    ) {
        let result = dividend / divisor;
        let remainder = dividend % divisor;
        
        // Property: dividend = divisor * quotient + remainder
        prop_assert_eq!(dividend, divisor * result + remainder);
        
        // Property: remainder should be less than divisor
        prop_assert!(remainder.abs() < divisor.abs());
    }
}
```

Property-based testing excels at finding boundary conditions, overflow scenarios, and logical inconsistencies that might not be apparent in manually written tests.

### Fuzzing

Fuzzing involves providing random, malformed, or unexpected inputs to programs to discover crashes, security vulnerabilities, and edge cases. Rust's memory safety features make it particularly well-suited for fuzzing, as memory corruption bugs are largely eliminated, allowing focus on logic errors and panics.

**Key points:**

- Generates random inputs to test program robustness
- Effective for finding security vulnerabilities and unexpected behavior
- `cargo-fuzz` integrates libFuzzer for structured fuzzing
- Coverage-guided fuzzing focuses on code paths that haven't been explored

**Example:**

```rust
// Cargo.toml for fuzz testing
// [dependencies]
// libfuzzer-sys = "0.4"
// 
// [[bin]]
// name = "fuzz_target_1"
// path = "fuzz/fuzz_targets/fuzz_target_1.rs"
// test = false
// doc = false

use libfuzzer_sys::fuzz_target;

// Example: fuzzing a JSON parser
fuzz_target!(|data: &[u8]| {
    if let Ok(s) = std::str::from_utf8(data) {
        let _ = serde_json::from_str::<serde_json::Value>(s);
    }
});

// Example: fuzzing a custom data structure
use std::collections::HashMap;

#[derive(Debug)]
struct LRUCache<K, V> {
    capacity: usize,
    map: HashMap<K, V>,
    order: Vec<K>,
}

impl<K: Clone + Eq + std::hash::Hash, V> LRUCache<K, V> {
    fn new(capacity: usize) -> Self {
        Self {
            capacity,
            map: HashMap::new(),
            order: Vec::new(),
        }
    }
    
    fn get(&mut self, key: &K) -> Option<&V> {
        if self.map.contains_key(key) {
            // Move to end (most recently used)
            self.order.retain(|k| k != key);
            self.order.push(key.clone());
            self.map.get(key)
        } else {
            None
        }
    }
    
    fn put(&mut self, key: K, value: V) {
        if self.map.contains_key(&key) {
            self.order.retain(|k| k != &key);
        } else if self.map.len() >= self.capacity {
            // Remove least recently used
            if let Some(lru_key) = self.order.first().cloned() {
                self.map.remove(&lru_key);
                self.order.remove(0);
            }
        }
        
        self.map.insert(key.clone(), value);
        self.order.push(key);
    }
}

// Fuzzing operations on LRU cache
fuzz_target!(|data: &[u8]| {
    let mut cache = LRUCache::new(10);
    let mut i = 0;
    
    while i < data.len() {
        match data[i] % 3 {
            0 => {
                // Insert operation
                if i + 2 < data.len() {
                    let key = data[i + 1];
                    let value = data[i + 2];
                    cache.put(key, value);
                    i += 3;
                } else {
                    break;
                }
            }
            1 => {
                // Get operation
                if i + 1 < data.len() {
                    let key = data[i + 1];
                    let _ = cache.get(&key);
                    i += 2;
                } else {
                    break;
                }
            }
            _ => {
                i += 1;
            }
        }
    }
});

// Structured fuzzing with arbitrary crate
use arbitrary::{Arbitrary, Unstructured};

#[derive(Arbitrary, Debug)]
enum CacheOperation {
    Put { key: u8, value: u32 },
    Get { key: u8 },
    Clear,
}

fuzz_target!(|data: &[u8]| {
    let mut cache = LRUCache::new(5);
    let mut unstructured = Unstructured::new(data);
    
    while let Ok(op) = CacheOperation::arbitrary(&mut unstructured) {
        match op {
            CacheOperation::Put { key, value } => {
                cache.put(key, value);
            }
            CacheOperation::Get { key } => {
                let _ = cache.get(&key);
            }
            CacheOperation::Clear => {
                cache = LRUCache::new(5);
            }
        }
    }
});

// Fuzzing with invariant checking
fuzz_target!(|data: &[u8]| {
    let mut cache = LRUCache::new(3);
    let mut unstructured = Unstructured::new(data);
    
    while let Ok(op) = CacheOperation::arbitrary(&mut unstructured) {
        match op {
            CacheOperation::Put { key, value } => {
                cache.put(key, value);
            }
            CacheOperation::Get { key } => {
                let _ = cache.get(&key);
            }
            CacheOperation::Clear => {
                cache = LRUCache::new(3);
            }
        }
        
        // Invariant: cache should never exceed capacity
        assert!(cache.map.len() <= cache.capacity);
        assert!(cache.order.len() <= cache.capacity);
        assert_eq!(cache.map.len(), cache.order.len());
    }
});
```

Fuzzing is particularly valuable for testing parsers, network protocols, file format handlers, and any code that processes external input.

### Mocking

Mocking in Rust involves creating fake implementations of dependencies to isolate units of code during testing. This technique enables testing of complex systems by controlling external dependencies and simulating various scenarios including error conditions.

**Key points:**

- Isolates code under test from external dependencies
- Enables testing of error conditions and edge cases
- Trait objects and dependency injection facilitate mocking
- The `mockall` crate provides powerful mocking capabilities

**Example:**

```rust
use mockall::*;
use async_trait::async_trait;

// Define traits for dependencies
#[async_trait]
trait HttpClient {
    async fn get(&self, url: &str) -> Result<String, String>;
    async fn post(&self, url: &str, body: &str) -> Result<String, String>;
}

trait Database {
    fn save_user(&self, user: &User) -> Result<u64, String>;
    fn get_user(&self, id: u64) -> Result<Option<User>, String>;
}

#[derive(Debug, Clone, PartialEq)]
struct User {
    id: u64,
    name: String,
    email: String,
}

// Service that depends on external services
struct UserService<H: HttpClient, D: Database> {
    http_client: H,
    database: D,
}

impl<H: HttpClient, D: Database> UserService<H, D> {
    fn new(http_client: H, database: D) -> Self {
        Self { http_client, database }
    }
    
    async fn create_user_from_api(&self, user_id: u64) -> Result<User, String> {
        // Fetch user data from external API
        let url = format!("https://api.example.com/users/{}", user_id);
        let response = self.http_client.get(&url).await?;
        
        // Parse response (simplified)
        let user_data: serde_json::Value = serde_json::from_str(&response)
            .map_err(|e| format!("Failed to parse JSON: {}", e))?;
        
        let user = User {
            id: user_id,
            name: user_data["name"].as_str().unwrap_or("Unknown").to_string(),
            email: user_data["email"].as_str().unwrap_or("").to_string(),
        };
        
        // Save to database
        let saved_id = self.database.save_user(&user)?;
        
        Ok(User { id: saved_id, ..user })
    }
    
    async fn notify_user(&self, user_id: u64, message: &str) -> Result<(), String> {
        let user = self.database.get_user(user_id)?
            .ok_or_else(|| "User not found".to_string())?;
        
        let notification_payload = serde_json::json!({
            "to": user.email,
            "message": message
        });
        
        self.http_client.post(
            "https://api.notifications.com/send",
            &notification_payload.to_string()
        ).await?;
        
        Ok(())
    }
}

// Create mocks
#[automock]
#[async_trait]
trait HttpClient {
    async fn get(&self, url: &str) -> Result<String, String>;
    async fn post(&self, url: &str, body: &str) -> Result<String, String>;
}

#[automock]
trait Database {
    fn save_user(&self, user: &User) -> Result<u64, String>;
    fn get_user(&self, id: u64) -> Result<Option<User>, String>;
}

#[cfg(test)]
mod tests {
    use super::*;
    
    #[tokio::test]
    async fn test_create_user_success() {
        let mut mock_http = MockHttpClient::new();
        let mut mock_db = MockDatabase::new();
        
        // Set up expectations
        mock_http
            .expect_get()
            .with(eq("https://api.example.com/users/123"))
            .times(1)
            .returning(|_| Ok(r#"{"name": "John Doe", "email": "john@example.com"}"#.to_string()));
        
        mock_db
            .expect_save_user()
            .times(1)
            .returning(|_| Ok(456));
        
        let service = UserService::new(mock_http, mock_db);
        let result = service.create_user_from_api(123).await;
        
        assert!(result.is_ok());
        let user = result.unwrap();
        assert_eq!(user.id, 456);
        assert_eq!(user.name, "John Doe");
        assert_eq!(user.email, "john@example.com");
    }
    
    #[tokio::test]
    async fn test_create_user_http_error() {
        let mut mock_http = MockHttpClient::new();
        let mock_db = MockDatabase::new();
        
        mock_http
            .expect_get()
            .times(1)
            .returning(|_| Err("Network error".to_string()));
        
        let service = UserService::new(mock_http, mock_db);
        let result = service.create_user_from_api(123).await;
        
        assert!(result.is_err());
        assert_eq!(result.unwrap_err(), "Network error");
    }
    
    #[tokio::test]
    async fn test_create_user_database_error() {
        let mut mock_http = MockHttpClient::new();
        let mut mock_db = MockDatabase::new();
        
        mock_http
            .expect_get()
            .times(1)
            .returning(|_| Ok(r#"{"name": "John Doe", "email": "john@example.com"}"#.to_string()));
        
        mock_db
            .expect_save_user()
            .times(1)
            .returning(|_| Err("Database connection failed".to_string()));
        
        let service = UserService::new(mock_http, mock_db);
        let result = service.create_user_from_api(123).await;
        
        assert!(result.is_err());
        assert_eq!(result.unwrap_err(), "Database connection failed");
    }
    
    #[tokio::test]
    async fn test_notify_user_success() {
        let mut mock_http = MockHttpClient::new();
        let mut mock_db = MockDatabase::new();
        
        let test_user = User {
            id: 123,
            name: "John Doe".to_string(),
            email: "john@example.com".to_string(),
        };
        
        mock_db
            .expect_get_user()
            .with(eq(123))
            .times(1)
            .returning(move |_| Ok(Some(test_user.clone())));
        
        mock_http
            .expect_post()
            .with(
                eq("https://api.notifications.com/send"),
                predicate::str::contains("john@example.com")
            )
            .times(1)
            .returning(|_, _| Ok("Notification sent".to_string()));
        
        let service = UserService::new(mock_http, mock_db);
        let result = service.notify_user(123, "Welcome!").await;
        
        assert!(result.is_ok());
    }
    
    #[tokio::test]
    async fn test_notify_user_not_found() {
        let mock_http = MockHttpClient::new();
        let mut mock_db = MockDatabase::new();
        
        mock_db
            .expect_get_user()
            .with(eq(123))
            .times(1)
            .returning(|_| Ok(None));
        
        let service = UserService::new(mock_http, mock_db);
        let result = service.notify_user(123, "Welcome!").await;
        
        assert!(result.is_err());
        assert_eq!(result.unwrap_err(), "User not found");
    }
}

// Manual mock implementation for more control
struct ManualMockDatabase {
    users: std::collections::HashMap<u64, User>,
    save_calls: std::cell::RefCell<Vec<User>>,
    should_fail: bool,
}

impl ManualMockDatabase {
    fn new() -> Self {
        Self {
            users: std::collections::HashMap::new(),
            save_calls: std::cell::RefCell::new(Vec::new()),
            should_fail: false,
        }
    }
    
    fn with_user(mut self, user: User) -> Self {
        self.users.insert(user.id, user);
        self
    }
    
    fn with_failure(mut self) -> Self {
        self.should_fail = true;
        self
    }
    
    fn get_save_calls(&self) -> Vec<User> {
        self.save_calls.borrow().clone()
    }
}

impl Database for ManualMockDatabase {
    fn save_user(&self, user: &User) -> Result<u64, String> {
        if self.should_fail {
            return Err("Mock database error".to_string());
        }
        
        self.save_calls.borrow_mut().push(user.clone());
        Ok(user.id)
    }
    
    fn get_user(&self, id: u64) -> Result<Option<User>, String> {
        if self.should_fail {
            return Err("Mock database error".to_string());
        }
        
        Ok(self.users.get(&id).cloned())
    }
}
```

Mocking enables comprehensive testing of business logic while isolating external dependencies, making tests faster, more reliable, and capable of testing error scenarios.

### Benchmarking

Benchmarking in Rust measures performance characteristics of code, enabling optimization decisions based on empirical data. Rust provides built-in benchmarking capabilities along with sophisticated third-party tools for detailed performance analysis.

**Key points:**

- Measures execution time, memory usage, and other performance metrics
- Helps identify performance bottlenecks and validate optimizations
- Built-in `#[bench]` attribute and `criterion` crate for advanced benchmarking
- Statistical analysis helps account for measurement variance

**Example:**

```rust
// Cargo.toml
// [dev-dependencies]
// criterion = { version = "0.5", features = ["html_reports"] }
// 
// [[bench]]
// name = "sorting_benchmark"
// harness = false

use criterion::{black_box, criterion_group, criterion_main, Criterion, BenchmarkId, Throughput};
use std::collections::HashMap;

// Different sorting algorithms to benchmark
fn bubble_sort<T: Ord + Clone>(arr: &mut [T]) {
    let len = arr.len();
    for i in 0..len {
        for j in 0..len - 1 - i {
            if arr[j] > arr[j + 1] {
                arr.swap(j, j + 1);
            }
        }
    }
}

fn quick_sort<T: Ord + Clone>(arr: &mut [T]) {
    if arr.len() <= 1 {
        return;
    }
    
    let pivot_index = partition(arr);
    let (left, right) = arr.split_at_mut(pivot_index);
    quick_sort(left);
    quick_sort(&mut right[1..]);
}

fn partition<T: Ord + Clone>(arr: &mut [T]) -> usize {
    let len = arr.len();
    let pivot_index = len / 2;
    arr.swap(pivot_index, len - 1);
    
    let mut store_index = 0;
    for i in 0..len - 1 {
        if arr[i] <= arr[len - 1] {
            arr.swap(i, store_index);
            store_index += 1;
        }
    }
    arr.swap(store_index, len - 1);
    store_index
}

// Benchmark different sorting algorithms
fn sort_benchmark(c: &mut Criterion) {
    let mut group = c.benchmark_group("sorting");
    
    for size in [10, 100, 1000, 10000].iter() {
        let data: Vec<i32> = (0..*size).rev().collect(); // Worst case: reverse sorted
        
        group.throughput(Throughput::Elements(*size as u64));
        
        group.bench_with_input(
            BenchmarkId::new("bubble_sort", size),
            size,
            |b, &size| {
                b.iter(|| {
                    let mut data = data.clone();
                    bubble_sort(black_box(&mut data));
                });
            },
        );
        
        group.bench_with_input(
            BenchmarkId::new("quick_sort", size),
            size,
            |b, &size| {
                b.iter(|| {
                    let mut data = data.clone();
                    quick_sort(black_box(&mut data));
                });
            },
        );
        
        group.bench_with_input(
            BenchmarkId::new("std_sort", size),
            size,
            |b, &size| {
                b.iter(|| {
                    let mut data = data.clone();
                    data.sort();
                    black_box(data);
                });
            },
        );
    }
    
    group.finish();
}

// Benchmark data structure operations
fn data_structure_benchmark(c: &mut Criterion) {
    let mut group = c.benchmark_group("data_structures");
    
    // Benchmark HashMap vs BTreeMap
    let keys: Vec<i32> = (0..1000).collect();
    let values: Vec<String> = (0..1000).map(|i| format!("value_{}", i)).collect();
    
    group.bench_function("hashmap_insert", |b| {
        b.iter(|| {
            let mut map = HashMap::new();
            for (k, v) in keys.iter().zip(values.iter()) {
                map.insert(black_box(*k), black_box(v.clone()));
            }
            black_box(map);
        });
    });
    
    group.bench_function("btreemap_insert", |b| {
        b.iter(|| {
            let mut map = std::collections::BTreeMap::new();
            for (k, v) in keys.iter().zip(values.iter()) {
                map.insert(black_box(*k), black_box(v.clone()));
            }
            black_box(map);
        });
    });
    
    // Benchmark lookup performance
    let hashmap: HashMap<i32, String> = keys.iter().zip(values.iter())
        .map(|(k, v)| (*k, v.clone()))
        .collect();
    
    let btreemap: std::collections::BTreeMap<i32, String> = keys.iter().zip(values.iter())
        .map(|(k, v)| (*k, v.clone()))
        .collect();
    
    group.bench_function("hashmap_lookup", |b| {
        b.iter(|| {
            for key in &keys {
                let _ = hashmap.get(black_box(key));
            }
        });
    });
    
    group.bench_function("btreemap_lookup", |b| {
        b.iter(|| {
            for key in &keys {
                let _ = btreemap.get(black_box(key));
            }
        });
    });
    
    group.finish();
}

// Benchmark memory allocation patterns
fn allocation_benchmark(c: &mut Criterion) {
    let mut group = c.benchmark_group("allocation");
    
    group.bench_function("vec_push", |b| {
        b.iter(|| {
            let mut vec = Vec::new();
            for i in 0..1000 {
                vec.push(black_box(i));
            }
            black_box(vec);
        });
    });
    
    group.bench_function("vec_with_capacity", |b| {
        b.iter(|| {
            let mut vec = Vec::with_capacity(1000);
            for i in 0..1000 {
                vec.push(black_box(i));
            }
            black_box(vec);
        });
    });
    
    group.bench_function("vec_from_iter", |b| {
        b.iter(|| {
            let vec: Vec<i32> = (0..1000).collect();
            black_box(vec);
        });
    });
    
    group.finish();
}

// Custom benchmark for async operations
fn async_benchmark(c: &mut Criterion) {
    let rt = tokio::runtime::Runtime::new().unwrap();
    
    c.bench_function("async_task", |b| {
        b.to_async(&rt).iter(|| async {
            // Simulate async work
            let future1 = async { tokio::time::sleep(tokio::time::Duration::from_nanos(1)).await };
            let future2 = async { tokio::time::sleep(tokio::time::Duration::from_nanos(1)).await };
            
            tokio::join!(future1, future2);
        });
    });
}

// Parametric benchmarks
fn parametric_benchmark(c: &mut Criterion) {
    let mut group = c.benchmark_group("fibonacci");
    
    for i in [10, 20, 30].iter() {
        group.bench_with_input(BenchmarkId::new("recursive", i), i, |b, i| {
            b.iter(|| fibonacci_recursive(black_box(*i)));
        });
        
        group.bench_with_input(BenchmarkId::new("iterative", i), i, |b, i| {
            b.iter(|| fibonacci_iterative(black_box(*i)));
        });
    }
    
    group.finish();
}

fn fibonacci_recursive(n: u64) -> u64 {
    match n {
        0 => 0,
        1 => 1,
        _ => fibonacci_recursive(n - 1) + fibonacci_recursive(n - 2),
    }
}

fn fibonacci_iterative(n: u64) -> u64 {
    if n <= 1 {
        return n;
    }
    
    let mut a = 0;
    let mut b = 1;
    
    for _ in 2..=n {
        let temp = a + b;
        a = b;
        b = temp;
    }
    
    b
}

criterion_group!(
    benches,
    sort_benchmark,
    data_structure_benchmark,
    allocation_benchmark,
    async_benchmark,
    parametric_benchmark
);
criterion_main!(benches);

// Built-in benchmark (requires nightly)
#![feature(test)]
extern crate test;

#[cfg(test)]
mod bench_tests {
    use super::*;
    use test::Bencher;
    
    #[bench]
    fn bench_bubble_sort(b: &mut Bencher) {
        let mut data: Vec<i32> = (0..100).rev().collect();
        b.iter(|| {
            let mut data_copy = data.clone();
            bubble_sort(&mut data_copy);
            test::black_box(data_copy);
        });
    }
    
    #[bench]
    fn bench_std_sort(b: &mut Bencher) {
        let mut data: Vec<i32> = (0..100).rev().collect();
        b.iter(|| {
            let mut data_copy = data.clone();
            data_copy.sort();
            test::black_box(data_copy);
        });
    }
}
```

Benchmarking provides quantitative data for optimization decisions and helps maintain performance standards across code changes.

### Code Coverage

Code coverage measures which parts of code are executed during testing, helping identify untested code paths and assess test suite completeness. Rust's ecosystem provides several tools for measuring and reporting code coverage.

**Key points:**

- Identifies untested code paths and potential gaps in test coverage
- Helps maintain code quality and reduce bugs
- `tarpaulin` and `grcov` provide coverage analysis for Rust projects
- Integration with CI/CD pipelines enables continuous coverage monitoring

**Example:**

```rust
// Cargo.toml configuration for coverage
// [dev-dependencies]
// tarpaulin = "0.22"

// Example module to test coverage
pub struct Calculator {
    history: Vec<(f64, f64, char, f64)>,
}

impl Calculator {
    pub fn new() -> Self {
        Self {
            history: Vec::new(),
        }
    }
    
    pub fn add(&mut self, a: f64, b: f64) -> f64 {
        let result = a + b;
        self.history.push((a, b, '+', result));
        result
    }
    
    pub fn subtract(&mut self, a: f64, b: f64) -> f64 {
        let result = a - b;
        self.history.push((a, b, '-', result));
        result
    }
    
    pub fn multiply(&mut self, a: f64, b: f64) -> f64 {
        let result = a * b;
        self.history.push((a, b, '*', result));
        result
    }
    
    pub fn divide(&mut self, a: f64, b: f64) -> Result<f64, String> {
        if b == 0.0 {
            Err("Division by zero".to_string())
        } else {
            let result = a / b;
            self.history.push((a, b, '/', result));
            Ok(result)
        }
    }
    
    pub fn power(&mut self, base: f64, exponent: f64) -> f64 {
        let result = base.powf(exponent);
        self.history.push((base, exponent, '^', result));
        result
    }

    pub fn sqrt(&mut self, value: f64) -> Result<f64, String> {
        if value < 0.0 {
            Err("Cannot calculate square root of negative number".to_string())
        } else {
            let result = value.sqrt();
            self.history.push((value, 0.0, '√', result));
            Ok(result)
        }
    }
    
    pub fn get_history(&self) -> &[(f64, f64, char, f64)] {
        &self.history
    }
    
    pub fn clear_history(&mut self) {
        self.history.clear();
    }
    
    pub fn get_last_result(&self) -> Option<f64> {
        self.history.last().map(|(_, _, _, result)| *result)
    }
    
    // This method has complex branching for coverage testing
    pub fn calculate_grade(&self, score: f64) -> String {
        if score < 0.0 || score > 100.0 {
            "Invalid score".to_string()
        } else if score >= 90.0 {
            "A".to_string()
        } else if score >= 80.0 {
            "B".to_string()
        } else if score >= 70.0 {
            "C".to_string()
        } else if score >= 60.0 {
            "D".to_string()
        } else {
            "F".to_string()
        }
    }
    
    // Method with error handling paths
    pub fn factorial(&self, n: u64) -> Result<u64, String> {
        if n > 20 {
            return Err("Factorial too large".to_string());
        }
        
        let mut result = 1;
        for i in 1..=n {
            result *= i;
        }
        Ok(result)
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    
    #[test]
    fn test_basic_operations() {
        let mut calc = Calculator::new();
        
        // Test addition
        assert_eq!(calc.add(2.0, 3.0), 5.0);
        
        // Test subtraction
        assert_eq!(calc.subtract(5.0, 3.0), 2.0);
        
        // Test multiplication
        assert_eq!(calc.multiply(4.0, 3.0), 12.0);
        
        // Test successful division
        assert_eq!(calc.divide(10.0, 2.0), Ok(5.0));
        
        // Test division by zero
        assert!(calc.divide(10.0, 0.0).is_err());
    }
    
    #[test]
    fn test_advanced_operations() {
        let mut calc = Calculator::new();
        
        // Test power function
        assert_eq!(calc.power(2.0, 3.0), 8.0);
        
        // Test square root - positive number
        assert_eq!(calc.sqrt(9.0), Ok(3.0));
        
        // Test square root - negative number (should be covered)
        assert!(calc.sqrt(-1.0).is_err());
    }
    
    #[test]
    fn test_history_functionality() {
        let mut calc = Calculator::new();
        
        calc.add(1.0, 2.0);
        calc.multiply(3.0, 4.0);
        
        let history = calc.get_history();
        assert_eq!(history.len(), 2);
        assert_eq!(history[0], (1.0, 2.0, '+', 3.0));
        assert_eq!(history[1], (3.0, 4.0, '*', 12.0));
        
        // Test last result
        assert_eq!(calc.get_last_result(), Some(12.0));
        
        // Test clear history
        calc.clear_history();
        assert_eq!(calc.get_history().len(), 0);
        assert_eq!(calc.get_last_result(), None);
    }
    
    #[test]
    fn test_grade_calculation() {
        let calc = Calculator::new();
        
        // Test all grade boundaries
        assert_eq!(calc.calculate_grade(95.0), "A");
        assert_eq!(calc.calculate_grade(85.0), "B");
        assert_eq!(calc.calculate_grade(75.0), "C");
        assert_eq!(calc.calculate_grade(65.0), "D");
        assert_eq!(calc.calculate_grade(55.0), "F");
        
        // Test boundary conditions
        assert_eq!(calc.calculate_grade(90.0), "A");
        assert_eq!(calc.calculate_grade(89.9), "B");
        
        // Test invalid scores
        assert_eq!(calc.calculate_grade(-1.0), "Invalid score");
        assert_eq!(calc.calculate_grade(101.0), "Invalid score");
    }
    
    #[test]
    fn test_factorial() {
        let calc = Calculator::new();
        
        // Test normal cases
        assert_eq!(calc.factorial(0), Ok(1));
        assert_eq!(calc.factorial(1), Ok(1));
        assert_eq!(calc.factorial(5), Ok(120));
        
        // Test error case
        assert!(calc.factorial(21).is_err());
    }
    
    // This test doesn't cover the sqrt error path - demonstrating partial coverage
    #[test]
    fn test_partial_coverage_example() {
        let mut calc = Calculator::new();
        
        // Only testing successful sqrt, not the error case
        assert_eq!(calc.sqrt(16.0), Ok(4.0));
        
        // Missing: calc.sqrt(-1.0) error case
    }
}

// Integration tests for coverage analysis
#[cfg(test)]
mod integration_tests {
    use super::*;
    
    #[test]
    fn test_calculator_workflow() {
        let mut calc = Calculator::new();
        
        // Simulate a complete calculator session
        let sum = calc.add(10.0, 5.0);
        let difference = calc.subtract(sum, 3.0);
        let product = calc.multiply(difference, 2.0);
        let quotient = calc.divide(product, 4.0).unwrap();
        let power_result = calc.power(quotient, 2.0);
        let sqrt_result = calc.sqrt(power_result).unwrap();
        
        assert_eq!(sqrt_result, 6.0);
        assert_eq!(calc.get_history().len(), 6);
    }
}

// Coverage configuration in Cargo.toml:
// [package.metadata.tarpaulin]
// exclude = ["tests/*", "benches/*"]
// timeout = 120
// count = true
// args = ["--exclude-files", "src/generated/*"]
// out = ["Html", "Lcov"]
// output-dir = "coverage/"

// Example coverage script (coverage.sh):
// #!/bin/bash
// 
// # Install tarpaulin if not already installed
// cargo install cargo-tarpaulin
// 
// # Run coverage analysis
// cargo tarpaulin --verbose --all-features --workspace --timeout 120 --out Html --output-dir coverage/
// 
// # Generate detailed coverage report
// cargo tarpaulin --verbose --all-features --workspace --timeout 120 --out Lcov --output-dir coverage/
// 
// # Open HTML report
// if [ -f "coverage/tarpaulin-report.html" ]; then
//     echo "Coverage report generated: coverage/tarpaulin-report.html"
//     # Uncomment to automatically open report
//     # open coverage/tarpaulin-report.html  # macOS
//     # xdg-open coverage/tarpaulin-report.html  # Linux
// fi

// Advanced coverage analysis with line-by-line tracking
pub struct AdvancedCalculator {
    value: f64,
    operations_count: u32,
}

impl AdvancedCalculator {
    pub fn new(initial_value: f64) -> Self {
        Self {
            value: initial_value,
            operations_count: 0,
        }
    }
    
    pub fn chain_add(mut self, value: f64) -> Self {
        self.value += value;
        self.operations_count += 1;
        self
    }
    
    pub fn chain_multiply(mut self, value: f64) -> Self {
        self.value *= value;
        self.operations_count += 1;
        self
    }
    
    pub fn conditional_operation(mut self, condition: bool, value: f64) -> Self {
        if condition {
            self.value *= value;  // This branch needs coverage
        } else {
            self.value += value;  // This branch also needs coverage
        }
        self.operations_count += 1;
        self
    }
    
    pub fn complex_calculation(mut self, a: f64, b: f64, c: f64) -> Result<Self, String> {
        // Multiple paths to test coverage
        if a == 0.0 {
            return Err("Parameter 'a' cannot be zero".to_string());
        }
        
        let discriminant = b * b - 4.0 * a * c;
        
        if discriminant < 0.0 {
            // Complex roots case - might be hard to reach
            self.value = f64::NAN;
        } else if discriminant == 0.0 {
            // Single root case
            self.value = -b / (2.0 * a);
        } else {
            // Two real roots case
            let sqrt_discriminant = discriminant.sqrt();
            let root1 = (-b + sqrt_discriminant) / (2.0 * a);
            let root2 = (-b - sqrt_discriminant) / (2.0 * a);
            self.value = root1.max(root2); // Take the larger root
        }
        
        self.operations_count += 1;
        Ok(self)
    }
    
    pub fn get_value(&self) -> f64 {
        self.value
    }
    
    pub fn get_operations_count(&self) -> u32 {
        self.operations_count
    }
}

#[cfg(test)]
mod advanced_tests {
    use super::*;
    
    #[test]
    fn test_chaining_operations() {
        let result = AdvancedCalculator::new(5.0)
            .chain_add(3.0)
            .chain_multiply(2.0)
            .get_value();
        
        assert_eq!(result, 16.0);
    }
    
    #[test]
    fn test_conditional_operation_both_branches() {
        // Test true branch
        let result1 = AdvancedCalculator::new(5.0)
            .conditional_operation(true, 3.0)
            .get_value();
        assert_eq!(result1, 15.0);
        
        // Test false branch
        let result2 = AdvancedCalculator::new(5.0)
            .conditional_operation(false, 3.0)
            .get_value();
        assert_eq!(result2, 8.0);
    }
    
    #[test]
    fn test_complex_calculation_all_paths() {
        // Test error case (a = 0)
        let calc = AdvancedCalculator::new(0.0);
        assert!(calc.complex_calculation(0.0, 1.0, 1.0).is_err());
        
        // Test negative discriminant (complex roots)
        let calc = AdvancedCalculator::new(0.0);
        let result = calc.complex_calculation(1.0, 0.0, 1.0).unwrap();
        assert!(result.get_value().is_nan());
        
        // Test zero discriminant (single root)
        let calc = AdvancedCalculator::new(0.0);
        let result = calc.complex_calculation(1.0, 2.0, 1.0).unwrap();
        assert_eq!(result.get_value(), -1.0);
        
        // Test positive discriminant (two real roots)
        let calc = AdvancedCalculator::new(0.0);
        let result = calc.complex_calculation(1.0, -3.0, 2.0).unwrap();
        assert_eq!(result.get_value(), 2.0); // max of roots 2 and 1
    }
}
```

### Continuous Integration

Continuous Integration (CI) in Rust automates testing, building, and deployment processes to ensure code quality and catch issues early. Modern CI systems integrate seamlessly with Rust's toolchain and provide comprehensive testing pipelines.

**Key points:**

- Automates testing across multiple platforms and Rust versions
- Integrates with code coverage, security scanning, and performance monitoring
- GitHub Actions, GitLab CI, and Jenkins provide robust Rust support
- Enables automated dependency updates and security vulnerability detection

**Example:**

```yaml
# .github/workflows/ci.yml - Comprehensive CI pipeline
name: Continuous Integration

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]

env:
  CARGO_TERM_COLOR: always
  RUST_BACKTRACE: 1

jobs:
  test:
    name: Test Suite
    runs-on: ${{ matrix.os }}
    strategy:
      matrix:
        os: [ubuntu-latest, windows-latest, macos-latest]
        rust: [stable, beta, nightly]
        exclude:
          # Reduce matrix size for faster CI
          - os: windows-latest
            rust: beta
          - os: macos-latest
            rust: beta

    steps:
    - name: Checkout code
      uses: actions/checkout@v4

    - name: Install Rust toolchain
      uses: dtolnay/rust-toolchain@master
      with:
        toolchain: ${{ matrix.rust }}
        components: rustfmt, clippy

    - name: Cache cargo registry
      uses: actions/cache@v3
      with:
        path: |
          ~/.cargo/registry/index/
          ~/.cargo/registry/cache/
          ~/.cargo/git/db/
          target/
        key: ${{ runner.os }}-cargo-${{ matrix.rust }}-${{ hashFiles('**/Cargo.lock') }}
        restore-keys: |
          ${{ runner.os }}-cargo-${{ matrix.rust }}-
          ${{ runner.os }}-cargo-

    - name: Check formatting
      run: cargo fmt --all -- --check

    - name: Run Clippy
      run: cargo clippy --all-targets --all-features -- -D warnings

    - name: Build project
      run: cargo build --verbose --all-features

    - name: Run tests
      run: cargo test --verbose --all-features

    - name: Run doctests
      run: cargo test --doc

  coverage:
    name: Code Coverage
    runs-on: ubuntu-latest
    needs: test

    steps:
    - name: Checkout code
      uses: actions/checkout@v4

    - name: Install Rust toolchain
      uses: dtolnay/rust-toolchain@stable

    - name: Install tarpaulin
      run: cargo install cargo-tarpaulin

    - name: Generate coverage report
      run: |
        cargo tarpaulin --verbose --all-features --workspace --timeout 120 \
          --exclude-files "tests/*" --exclude-files "benches/*" \
          --out Xml --output-dir coverage/

    - name: Upload coverage to Codecov
      uses: codecov/codecov-action@v3
      with:
        file: coverage/cobertura.xml
        flags: unittests
        name: codecov-umbrella
        fail_ci_if_error: true

  security:
    name: Security Audit
    runs-on: ubuntu-latest

    steps:
    - name: Checkout code
      uses: actions/checkout@v4

    - name: Install Rust toolchain
      uses: dtolnay/rust-toolchain@stable

    - name: Install cargo-audit
      run: cargo install cargo-audit

    - name: Run security audit
      run: cargo audit

    - name: Install cargo-deny
      run: cargo install cargo-deny

    - name: Check licenses and dependencies
      run: cargo deny check

  benchmark:
    name: Performance Benchmarks
    runs-on: ubuntu-latest
    if: github.event_name == 'push' && github.ref == 'refs/heads/main'

    steps:
    - name: Checkout code
      uses: actions/checkout@v4

    - name: Install Rust toolchain
      uses: dtolnay/rust-toolchain@stable

    - name: Run benchmarks
      run: cargo bench --bench sorting_benchmark

    - name: Store benchmark results
      uses: benchmark-action/github-action-benchmark@v1
      with:
        tool: 'cargo'
        output-file-path: target/criterion/reports/index.html
        github-token: ${{ secrets.GITHUB_TOKEN }}
        auto-push: true

  fuzzing:
    name: Fuzz Testing
    runs-on: ubuntu-latest
    if: github.event_name == 'push'

    steps:
    - name: Checkout code
      uses: actions/checkout@v4

    - name: Install Rust toolchain
      uses: dtolnay/rust-toolchain@nightly

    - name: Install cargo-fuzz
      run: cargo install cargo-fuzz

    - name: Run fuzz tests
      run: |
        # Run each fuzz target for a short duration in CI
        timeout 300 cargo fuzz run fuzz_target_1 || true
        timeout 300 cargo fuzz run fuzz_target_2 || true

  property-testing:
    name: Property-based Testing
    runs-on: ubuntu-latest

    steps:
    - name: Checkout code
      uses: actions/checkout@v4

    - name: Install Rust toolchain
      uses: dtolnay/rust-toolchain@stable

    - name: Run property tests
      run: cargo test --test proptest_integration

  cross-compile:
    name: Cross Compilation
    runs-on: ubuntu-latest
    strategy:
      matrix:
        target:
          - x86_64-unknown-linux-musl
          - aarch64-unknown-linux-gnu
          - x86_64-pc-windows-gnu

    steps:
    - name: Checkout code
      uses: actions/checkout@v4

    - name: Install Rust toolchain
      uses: dtolnay/rust-toolchain@stable
      with:
        targets: ${{ matrix.target }}

    - name: Install cross
      run: cargo install cross

    - name: Cross compile
      run: cross build --target ${{ matrix.target }} --release

  dependency-update:
    name: Dependency Updates
    runs-on: ubuntu-latest
    if: github.event_name == 'schedule'

    steps:
    - name: Checkout code
      uses: actions/checkout@v4

    - name: Install Rust toolchain
      uses: dtolnay/rust-toolchain@stable

    - name: Install cargo-update
      run: cargo install cargo-update

    - name: Update dependencies
      run: cargo update

    - name: Test with updated dependencies
      run: cargo test --all-features

    - name: Create Pull Request
      uses: peter-evans/create-pull-request@v5
      with:
        token: ${{ secrets.GITHUB_TOKEN }}
        commit-message: 'chore: update dependencies'
        title: 'Automated dependency updates'
        body: 'This PR updates project dependencies to their latest versions.'
        branch: dependency-updates

# .github/workflows/release.yml - Release pipeline
name: Release

on:
  push:
    tags:
      - 'v*.*.*'

jobs:
  create-release:
    name: Create Release
    runs-on: ubuntu-latest
    outputs:
      upload_url: ${{ steps.create_release.outputs.upload_url }}

    steps:
    - name: Create Release
      id: create_release
      uses: actions/create-release@v1
      env:
        GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
      with:
        tag_name: ${{ github.ref }}
        release_name: Release ${{ github.ref }}
        draft: false
        prerelease: false

  build-and-upload:
    name: Build and Upload Assets
    needs: create-release
    runs-on: ${{ matrix.os }}
    strategy:
      matrix:
        os: [ubuntu-latest, windows-latest, macos-latest]
        include:
          - os: ubuntu-latest
            asset_name: myapp-linux-amd64
            asset_path: target/release/myapp
          - os: windows-latest
            asset_name: myapp-windows-amd64.exe
            asset_path: target/release/myapp.exe
          - os: macos-latest
            asset_name: myapp-macos-amd64
            asset_path: target/release/myapp

    steps:
    - name: Checkout code
      uses: actions/checkout@v4

    - name: Install Rust toolchain
      uses: dtolnay/rust-toolchain@stable

    - name: Build release binary
      run: cargo build --release

    - name: Upload Release Asset
      uses: actions/upload-release-asset@v1
      env:
        GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
      with:
        upload_url: ${{ needs.create-release.outputs.upload_url }}
        asset_path: ${{ matrix.asset_path }}
        asset_name: ${{ matrix.asset_name }}
        asset_content_type: application/octet-stream

# cargo-deny.toml - Dependency and license checking
[graph]
targets = [
    { triple = "x86_64-unknown-linux-gnu" },
    { triple = "x86_64-pc-windows-msvc" },
    { triple = "x86_64-apple-darwin" },
]

[advisories]
db-path = "~/.cargo/advisory-db"
db-urls = ["https://github.com/rustsec/advisory-db"]
vulnerability = "deny"
unmaintained = "warn"
yanked = "warn"
notice = "warn"
ignore = []

[licenses]
unlicensed = "deny"
allow = [
    "MIT",
    "Apache-2.0",
    "Apache-2.0 WITH LLVM-exception",
    "BSD-2-Clause",
    "BSD-3-Clause",
    "ISC",
    "Unicode-DFS-2016",
]
deny = [
    "GPL-2.0",
    "GPL-3.0",
    "AGPL-1.0",
    "AGPL-3.0",
]
copyleft = "warn"
allow-osi-fsf-free = "neither"
default = "deny"
confidence-threshold = 0.8

[bans]
multiple-versions = "warn"
wildcards = "allow"
highlight = "all"
workspace-default-features = "allow"
external-default-features = "allow"
```

**Conclusion:** Advanced testing in Rust provides a comprehensive toolkit for ensuring software quality, performance, and reliability. The combination of property-based testing, fuzzing, mocking, benchmarking, code coverage analysis, and continuous integration creates a robust testing ecosystem that catches bugs early, prevents regressions, and maintains high code quality standards. These techniques work synergistically to provide confidence in code correctness while enabling rapid development and deployment cycles.

**Next steps:** Consider exploring mutation testing for test quality assessment, contract testing for API reliability, and chaos engineering for distributed system resilience.

---

