## Benchmarking in Rust


Benchmarking in Rust involves measuring and analyzing code performance to identify bottlenecks, compare implementations, and prevent performance regressions. Rust's ecosystem provides sophisticated tools for creating reliable, statistically sound benchmarks that help developers make informed optimization decisions.

### Criterion Crate

Criterion is the de facto standard benchmarking library for Rust, providing statistical rigor, detailed reporting, and comprehensive analysis tools for performance measurement.

#### Basic Criterion Setup

```rust
// Cargo.toml
[dev-dependencies]
criterion = { version = "0.5", features = ["html_reports"] }

[[bench]]
name = "my_benchmarks"
harness = false
```

```rust
// benches/my_benchmarks.rs
use criterion::{black_box, criterion_group, criterion_main, Criterion};

fn fibonacci_recursive(n: u64) -> u64 {
    match n {
        0 => 1,
        1 => 1,
        n => fibonacci_recursive(n - 1) + fibonacci_recursive(n - 2),
    }
}

fn fibonacci_iterative(n: u64) -> u64 {
    let mut a = 0;
    let mut b = 1;
    for _ in 0..n {
        let temp = a;
        a = b;
        b = temp + b;
    }
    b
}

fn benchmark_fibonacci(c: &mut Criterion) {
    c.bench_function("fib_recursive_20", |b| {
        b.iter(|| fibonacci_recursive(black_box(20)))
    });
    
    c.bench_function("fib_iterative_20", |b| {
        b.iter(|| fibonacci_iterative(black_box(20)))
    });
}

criterion_group!(benches, benchmark_fibonacci);
criterion_main!(benches);
```

#### Advanced Criterion Configuration

```rust
use criterion::{
    black_box, criterion_group, criterion_main, 
    Criterion, BenchmarkId, PlotConfiguration, AxisScale,
    Throughput, SamplingMode, MeasurementTime
};
use std::time::Duration;

fn comprehensive_benchmark(c: &mut Criterion) {
    // Configure measurement parameters
    let mut group = c.benchmark_group("sorting_algorithms");
    group.measurement_time(Duration::from_secs(10));
    group.sample_size(1000);
    group.sampling_mode(SamplingMode::Flat);
    
    // Configure plotting
    group.plot_config(PlotConfiguration::default().summary_scale(AxisScale::Logarithmic));
    
    // Benchmark across multiple input sizes
    for size in [100, 1000, 10000, 100000].iter() {
        let mut data: Vec<i32> = (0..*size).collect();
        data.reverse(); // Worst case for some algorithms
        
        group.throughput(Throughput::Elements(*size as u64));
        
        group.bench_with_input(
            BenchmarkId::new("quicksort", size),
            size,
            |b, &size| {
                b.iter_batched(
                    || data.clone(),
                    |mut data| {
                        quicksort(&mut data);
                        black_box(data)
                    },
                    criterion::BatchSize::SmallInput,
                )
            },
        );
        
        group.bench_with_input(
            BenchmarkId::new("mergesort", size),
            size,
            |b, &size| {
                b.iter_batched(
                    || data.clone(),
                    |mut data| {
                        mergesort(&mut data);
                        black_box(data)
                    },
                    criterion::BatchSize::SmallInput,
                )
            },
        );
    }
    
    group.finish();
}

fn quicksort(arr: &mut [i32]) {
    if arr.len() <= 1 {
        return;
    }
    let pivot = partition(arr);
    quicksort(&mut arr[0..pivot]);
    quicksort(&mut arr[pivot + 1..]);
}

fn partition(arr: &mut [i32]) -> usize {
    let pivot = arr.len() - 1;
    let mut i = 0;
    
    for j in 0..pivot {
        if arr[j] <= arr[pivot] {
            arr.swap(i, j);
            i += 1;
        }
    }
    arr.swap(i, pivot);
    i
}

fn mergesort(arr: &mut [i32]) {
    if arr.len() <= 1 {
        return;
    }
    
    let mid = arr.len() / 2;
    mergesort(&mut arr[0..mid]);
    mergesort(&mut arr[mid..]);
    
    let mut temp = arr.to_vec();
    merge(&arr[0..mid], &arr[mid..], &mut temp);
    arr.copy_from_slice(&temp);
}

fn merge(left: &[i32], right: &[i32], result: &mut [i32]) {
    let mut i = 0;
    let mut j = 0;
    let mut k = 0;
    
    while i < left.len() && j < right.len() {
        if left[i] <= right[j] {
            result[k] = left[i];
            i += 1;
        } else {
            result[k] = right[j];
            j += 1;
        }
        k += 1;
    }
    
    while i < left.len() {
        result[k] = left[i];
        i += 1;
        k += 1;
    }
    
    while j < right.len() {
        result[k] = right[j];
        j += 1;
        k += 1;
    }
}

criterion_group!(benches, comprehensive_benchmark);
criterion_main!(benches);
```

#### Criterion Features and Options

```rust
use criterion::{
    criterion_group, criterion_main, Criterion,
    BatchSize, Throughput, SamplingMode, WarmupTime,
    MeasurementTime, PlotConfiguration, AxisScale
};

fn advanced_criterion_features(c: &mut Criterion) {
    // Memory allocation benchmarks
    c.bench_function("vec_allocation", |b| {
        b.iter(|| {
            let mut vec = Vec::new();
            for i in 0..1000 {
                vec.push(black_box(i));
            }
            black_box(vec)
        })
    });
    
    // Throughput benchmarks
    c.bench_function("string_processing", |b| {
        let input = "a".repeat(10000);
        b.throughput(Throughput::Bytes(input.len() as u64));
        b.iter(|| {
            let result = input.chars().map(|c| c.to_uppercase().collect::<String>()).collect::<String>();
            black_box(result)
        })
    });
    
    // Parameterized benchmarks
    let mut group = c.benchmark_group("hash_functions");
    for input_size in [10, 100, 1000, 10000].iter() {
        let data = vec![0u8; *input_size];
        
        group.bench_with_input(
            BenchmarkId::new("sha256", input_size),
            &data,
            |b, data| {
                b.iter(|| {
                    use sha2::{Sha256, Digest};
                    let mut hasher = Sha256::new();
                    hasher.update(data);
                    black_box(hasher.finalize())
                })
            },
        );
        
        group.bench_with_input(
            BenchmarkId::new("blake3", input_size),
            &data,
            |b, data| {
                b.iter(|| {
                    black_box(blake3::hash(data))
                })
            },
        );
    }
    group.finish();
}

criterion_group!(benches, advanced_criterion_features);
criterion_main!(benches);
```

**Key points:**

- Criterion provides statistical analysis and HTML reports
- `black_box` prevents compiler optimizations that could skew results
- `iter_batched` allows setup/teardown for each iteration
- Throughput measurements help understand scaling characteristics
- Parameterized benchmarks enable comparison across different inputs

### Micro-benchmarks

Micro-benchmarks focus on measuring the performance of small, isolated pieces of code to understand low-level performance characteristics and optimization opportunities.

#### CPU-Intensive Micro-benchmarks

```rust
use criterion::{black_box, criterion_group, criterion_main, Criterion};

// Benchmark different approaches to the same problem
fn sum_for_loop(data: &[i32]) -> i64 {
    let mut sum = 0i64;
    for &item in data {
        sum += item as i64;
    }
    sum
}

fn sum_iterator(data: &[i32]) -> i64 {
    data.iter().map(|&x| x as i64).sum()
}

fn sum_fold(data: &[i32]) -> i64 {
    data.iter().fold(0i64, |acc, &x| acc + x as i64)
}

fn sum_simd(data: &[i32]) -> i64 {
    // Simulate SIMD operations
    let chunks = data.chunks_exact(4);
    let remainder = chunks.remainder();
    
    let mut sum = 0i64;
    for chunk in chunks {
        sum += chunk[0] as i64 + chunk[1] as i64 + chunk[2] as i64 + chunk[3] as i64;
    }
    
    for &item in remainder {
        sum += item as i64;
    }
    
    sum
}

fn micro_benchmark_summation(c: &mut Criterion) {
    let data: Vec<i32> = (0..10000).collect();
    
    let mut group = c.benchmark_group("summation_methods");
    
    group.bench_function("for_loop", |b| {
        b.iter(|| sum_for_loop(black_box(&data)))
    });
    
    group.bench_function("iterator", |b| {
        b.iter(|| sum_iterator(black_box(&data)))
    });
    
    group.bench_function("fold", |b| {
        b.iter(|| sum_fold(black_box(&data)))
    });
    
    group.bench_function("manual_simd", |b| {
        b.iter(|| sum_simd(black_box(&data)))
    });
    
    group.finish();
}
```

#### Memory Access Pattern Benchmarks

```rust
use criterion::{black_box, criterion_group, criterion_main, Criterion, BenchmarkId};

fn sequential_access(data: &mut [i32]) {
    for i in 0..data.len() {
        data[i] = data[i].wrapping_add(1);
    }
}

fn random_access(data: &mut [i32], indices: &[usize]) {
    for &idx in indices {
        data[idx] = data[idx].wrapping_add(1);
    }
}

fn strided_access(data: &mut [i32], stride: usize) {
    let mut i = 0;
    while i < data.len() {
        data[i] = data[i].wrapping_add(1);
        i += stride;
    }
}

fn cache_benchmark(c: &mut Criterion) {
    let mut group = c.benchmark_group("memory_access_patterns");
    
    for size in [1024, 8192, 65536, 524288].iter() {
        let mut data = vec![0i32; *size];
        let indices: Vec<usize> = (0..*size).rev().collect(); // Reverse order
        
        group.bench_with_input(
            BenchmarkId::new("sequential", size),
            size,
            |b, _| {
                b.iter(|| {
                    sequential_access(black_box(&mut data));
                })
            },
        );
        
        group.bench_with_input(
            BenchmarkId::new("random", size),
            size,
            |b, _| {
                b.iter(|| {
                    random_access(black_box(&mut data), black_box(&indices));
                })
            },
        );
        
        for stride in [2, 4, 8, 16].iter() {
            group.bench_with_input(
                BenchmarkId::new(format!("stride_{}", stride), size),
                size,
                |b, _| {
                    b.iter(|| {
                        strided_access(black_box(&mut data), *stride);
                    })
                },
            );
        }
    }
    
    group.finish();
}
```

#### Branch Prediction Benchmarks

```rust
use criterion::{black_box, criterion_group, criterion_main, Criterion};
use rand::Rng;

fn predictable_branches(data: &[i32]) -> i32 {
    let mut sum = 0;
    for &value in data {
        if value > 0 { // Predictable pattern
            sum += value;
        }
    }
    sum
}

fn unpredictable_branches(data: &[i32]) -> i32 {
    let mut sum = 0;
    for &value in data {
        if value % 2 == 0 { // Random pattern
            sum += value;
        }
    }
    sum
}

fn branchless_version(data: &[i32]) -> i32 {
    let mut sum = 0;
    for &value in data {
        // Branchless: use boolean as integer
        sum += value * (value > 0) as i32;
    }
    sum
}

fn branch_prediction_benchmark(c: &mut Criterion) {
    let mut rng = rand::thread_rng();
    
    // Predictable data (sorted)
    let mut predictable_data: Vec<i32> = (0..10000).map(|_| rng.gen_range(-100..100)).collect();
    predictable_data.sort();
    
    // Unpredictable data (random)
    let unpredictable_data: Vec<i32> = (0..10000).map(|_| rng.gen()).collect();
    
    let mut group = c.benchmark_group("branch_prediction");
    
    group.bench_function("predictable_branches", |b| {
        b.iter(|| predictable_branches(black_box(&predictable_data)))
    });
    
    group.bench_function("unpredictable_branches", |b| {
        b.iter(|| unpredictable_branches(black_box(&unpredictable_data)))
    });
    
    group.bench_function("branchless_predictable", |b| {
        b.iter(|| branchless_version(black_box(&predictable_data)))
    });
    
    group.bench_function("branchless_unpredictable", |b| {
        b.iter(|| branchless_version(black_box(&unpredictable_data)))
    });
    
    group.finish();
}
```

#### Function Call Overhead Benchmarks

```rust
use criterion::{black_box, criterion_group, criterion_main, Criterion};

#[inline(never)]
fn expensive_function_call(x: i32) -> i32 {
    x * x + x + 1
}

#[inline(always)]
fn inlined_function_call(x: i32) -> i32 {
    x * x + x + 1
}

fn direct_computation(x: i32) -> i32 {
    x * x + x + 1
}

fn function_call_benchmark(c: &mut Criterion) {
    let input = 42;
    
    let mut group = c.benchmark_group("function_call_overhead");
    
    group.bench_function("no_inline", |b| {
        b.iter(|| {
            let mut sum = 0;
            for i in 0..1000 {
                sum += expensive_function_call(black_box(input + i));
            }
            sum
        })
    });
    
    group.bench_function("inline_always", |b| {
        b.iter(|| {
            let mut sum = 0;
            for i in 0..1000 {
                sum += inlined_function_call(black_box(input + i));
            }
            sum
        })
    });
    
    group.bench_function("direct", |b| {
        b.iter(|| {
            let mut sum = 0;
            for i in 0..1000 {
                let x = black_box(input + i);
                sum += direct_computation(x);
            }
            sum
        })
    });
    
    group.finish();
}
```

**Key points:**

- Micro-benchmarks reveal low-level performance characteristics
- Memory access patterns significantly impact performance
- Branch prediction affects conditional code performance
- Function call overhead varies with inlining strategies
- Isolated measurements help identify optimization opportunities

### Statistical Analysis

Criterion provides comprehensive statistical analysis to ensure benchmark results are reliable and meaningful, accounting for measurement noise and system variability.

#### Understanding Criterion's Statistical Output

```rust
use criterion::{black_box, criterion_group, criterion_main, Criterion, SamplingMode};
use std::time::Duration;

fn statistical_analysis_demo(c: &mut Criterion) {
    // Configure for detailed statistical analysis
    let mut group = c.benchmark_group("statistical_analysis");
    group.sampling_mode(SamplingMode::Auto);
    group.measurement_time(Duration::from_secs(5));
    group.sample_size(1000);
    group.confidence_level(0.95);
    group.significance_level(0.05);
    group.noise_threshold(0.02); // 2% noise threshold
    
    // Benchmark with consistent performance
    group.bench_function("consistent_performance", |b| {
        b.iter(|| {
            let mut sum = 0;
            for i in 0..1000 {
                sum += i;
            }
            black_box(sum)
        })
    });
    
    // Benchmark with variable performance
    group.bench_function("variable_performance", |b| {
        b.iter(|| {
            let mut sum = 0;
            let iterations = if rand::random::<bool>() { 1000 } else { 2000 };
            for i in 0..iterations {
                sum += i;
            }
            black_box(sum)
        })
    });
    
    // Benchmark with allocation variance
    group.bench_function("allocation_variance", |b| {
        b.iter(|| {
            let size = rand::random::<usize>() % 1000 + 1000;
            let vec: Vec<i32> = (0..size).collect();
            black_box(vec)
        })
    });
    
    group.finish();
}

// Custom statistical analysis
fn custom_statistical_analysis(c: &mut Criterion) {
    use criterion::measurement::WallTime;
    use criterion::{BatchSize, BenchmarkGroup};
    
    let mut group: BenchmarkGroup<WallTime> = c.benchmark_group("custom_stats");
    
    // Collect raw measurements for custom analysis
    group.bench_function("raw_measurements", |b| {
        b.iter_custom(|iters| {
            let start = std::time::Instant::now();
            for _ in 0..iters {
                black_box(expensive_computation(100));
            }
            start.elapsed()
        })
    });
    
    group.finish();
}

fn expensive_computation(n: usize) -> usize {
    (0..n).map(|i| i * i).sum()
}
```

#### Interpreting Statistical Results

```rust
use criterion::{black_box, criterion_group, criterion_main, Criterion};
use std::collections::HashMap;

// Demonstrate how to interpret confidence intervals and significance
fn interpretation_benchmark(c: &mut Criterion) {
    let mut group = c.benchmark_group("interpretation_example");
    
    // Two very similar algorithms
    group.bench_function("algorithm_a", |b| {
        b.iter(|| {
            let mut map = HashMap::new();
            for i in 0..100 {
                map.insert(i, i * 2);
            }
            black_box(map)
        })
    });
    
    group.bench_function("algorithm_b", |b| {
        b.iter(|| {
            let mut map = HashMap::with_capacity(100);
            for i in 0..100 {
                map.insert(i, i * 2);
            }
            black_box(map)
        })
    });
    
    group.finish();
}

// Statistical significance testing
fn significance_testing(c: &mut Criterion) {
    let mut group = c.benchmark_group("significance_testing");
    
    // Baseline implementation
    group.bench_function("baseline", |b| {
        b.iter(|| {
            let mut vec = Vec::new();
            for i in 0..1000 {
                vec.push(i);
            }
            black_box(vec)
        })
    });
    
    // Optimized implementation
    group.bench_function("optimized", |b| {
        b.iter(|| {
            let mut vec = Vec::with_capacity(1000);
            for i in 0..1000 {
                vec.push(i);
            }
            black_box(vec)
        })
    });
    
    // Further optimized
    group.bench_function("further_optimized", |b| {
        b.iter(|| {
            let vec: Vec<i32> = (0..1000).collect();
            black_box(vec)
        })
    });
    
    group.finish();
}
```

#### Handling Measurement Noise

```rust
use criterion::{black_box, criterion_group, criterion_main, Criterion, BatchSize};
use std::time::Duration;

fn noise_handling_benchmark(c: &mut Criterion) {
    let mut group = c.benchmark_group("noise_handling");
    
    // High-noise benchmark (system calls)
    group.bench_function("high_noise_syscall", |b| {
        b.iter_batched(
            || std::fs::File::create("/tmp/benchmark_temp_file"),
            |file_result| {
                if let Ok(file) = file_result {
                    std::fs::remove_file("/tmp/benchmark_temp_file").ok();
                }
                black_box(file_result)
            },
            BatchSize::SmallInput,
        )
    });
    
    // Low-noise benchmark (pure computation)
    group.bench_function("low_noise_computation", |b| {
        b.iter(|| {
            let mut sum = 0u64;
            for i in 0..1000 {
                sum = sum.wrapping_add(i);
            }
            black_box(sum)
        })
    });
    
    // Medium-noise benchmark (memory allocation)
    group.bench_function("medium_noise_allocation", |b| {
        b.iter(|| {
            let vec: Vec<u8> = vec![0; 1024];
            black_box(vec)
        })
    });
    
    group.finish();
}

// Controlling for external factors
fn controlled_environment_benchmark(c: &mut Criterion) {
    let mut group = c.benchmark_group("controlled_environment");
    group.measurement_time(Duration::from_secs(10));
    group.warm_up_time(Duration::from_secs(3));
    
    // Warm up system caches
    let warmup_data: Vec<i32> = (0..10000).collect();
    for _ in 0..100 {
        let _: i32 = warmup_data.iter().sum();
    }
    
    group.bench_function("cache_warmed", |b| {
        let data: Vec<i32> = (0..10000).collect();
        b.iter(|| {
            let sum: i32 = data.iter().sum();
            black_box(sum)
        })
    });
    
    group.finish();
}

criterion_group!(
    benches,
    statistical_analysis_demo,
    custom_statistical_analysis,
    interpretation_benchmark,
    significance_testing,
    noise_handling_benchmark,
    controlled_environment_benchmark
);
criterion_main!(benches);
```

**Key points:**

- Criterion calculates confidence intervals and significance tests
- Sample size and measurement time affect statistical reliability
- Noise threshold helps identify meaningful performance differences
- Warm-up periods reduce measurement artifacts
- Batch size affects overhead from setup/teardown operations

### Benchmark Harnesses

Benchmark harnesses provide the infrastructure for running, organizing, and managing benchmark suites, enabling systematic performance testing across different scenarios and configurations.

#### Custom Benchmark Harness

```rust
use criterion::{criterion_group, criterion_main, Criterion};
use std::time::{Duration, Instant};
use std::collections::HashMap;

// Custom harness for specialized benchmarking needs
struct CustomBenchmarkHarness {
    name: String,
    warmup_iterations: usize,
    measurement_iterations: usize,
    results: HashMap<String, Vec<Duration>>,
}

impl CustomBenchmarkHarness {
    fn new(name: String) -> Self {
        Self {
            name,
            warmup_iterations: 100,
            measurement_iterations: 1000,
            results: HashMap::new(),
        }
    }
    
    fn bench<F>(&mut self, test_name: &str, mut test_fn: F)
    where
        F: FnMut(),
    {
        // Warmup phase
        for _ in 0..self.warmup_iterations {
            test_fn();
        }
        
        // Measurement phase
        let mut measurements = Vec::with_capacity(self.measurement_iterations);
        for _ in 0..self.measurement_iterations {
            let start = Instant::now();
            test_fn();
            measurements.push(start.elapsed());
        }
        
        self.results.insert(test_name.to_string(), measurements);
    }
    
    fn report(&self) {
        println!("Benchmark Results for: {}", self.name);
        println!("{:-<60}", "");
        
        for (test_name, measurements) in &self.results {
            let total_time: Duration = measurements.iter().sum();
            let avg_time = total_time / measurements.len() as u32;
            let min_time = *measurements.iter().min().unwrap();
            let max_time = *measurements.iter().max().unwrap();
            
            println!("Test: {}", test_name);
            println!("  Average: {:?}", avg_time);
            println!("  Min:     {:?}", min_time);
            println!("  Max:     {:?}", max_time);
            println!("  Samples: {}", measurements.len());
            println!();
        }
    }
}

// Example usage of custom harness
fn custom_harness_example() {
    let mut harness = CustomBenchmarkHarness::new("Custom Benchmark Suite".to_string());
    
    harness.bench("vector_creation", || {
        let _vec: Vec<i32> = (0..1000).collect();
    });
    
    harness.bench("hashmap_creation", || {
        let mut map = HashMap::new();
        for i in 0..1000 {
            map.insert(i, i * 2);
        }
    });
    
    harness.report();
}
```

#### Multi-threaded Benchmark Harness

```rust
use criterion::{black_box, criterion_group, criterion_main, Criterion, BenchmarkId};
use std::sync::{Arc, Mutex};
use std::thread;
use std::time::Duration;
use rayon::prelude::*;

fn parallel_benchmark_harness(c: &mut Criterion) {
    let mut group = c.benchmark_group("parallel_processing");
    
    // Data processing workload
    let data: Vec<i32> = (0..100000).collect();
    
    // Sequential processing
    group.bench_function("sequential", |b| {
        b.iter(|| {
            let result: Vec<i32> = data
                .iter()
                .map(|&x| expensive_operation(x))
                .collect();
            black_box(result)
        })
    });
    
    // Parallel processing with different thread counts
    for thread_count in [1, 2, 4, 8, 16].iter() {
        group.bench_with_input(
            BenchmarkId::new("parallel_rayon", thread_count),
            thread_count,
            |b, &thread_count| {
                let pool = rayon::ThreadPoolBuilder::new()
                    .num_threads(thread_count)
                    .build()
                    .unwrap();
                
                b.iter(|| {
                    let result: Vec<i32> = pool.install(|| {
                        data.par_iter()
                            .map(|&x| expensive_operation(x))
                            .collect()
                    });
                    black_box(result)
                })
            },
        );
    }
    
    // Manual thread management
    for thread_count in [1, 2, 4, 8].iter() {
        group.bench_with_input(
            BenchmarkId::new("manual_threads", thread_count),
            thread_count,
            |b, &thread_count| {
                b.iter(|| {
                    let chunk_size = data.len() / thread_count;
                    let results = Arc::new(Mutex::new(Vec::new()));
                    let mut handles = vec![];
                    
                    for i in 0..*thread_count {
                        let start = i * chunk_size;
                        let end = if i == thread_count - 1 {
                            data.len()
                        } else {
                            (i + 1) * chunk_size
                        };
                        
                        let chunk = &data[start..end];
                        let results_clone = Arc::clone(&results);
                        
                        let handle = thread::spawn(move || {
                            let chunk_results: Vec<i32> = chunk
                                .iter()
                                .map(|&x| expensive_operation(x))
                                .collect();
                            results_clone.lock().unwrap().extend(chunk_results);
                        });
                        
                        handles.push(handle);
                    }
                    
                    for handle in handles {
                        handle.join().unwrap();
                    }
                    
                    let final_results = results.lock().unwrap().clone();
                    black_box(final_results)
                })
            },
        );
    }
    
    group.finish();
}

fn expensive_operation(x: i32) -> i32 {
    // Simulate expensive computation
    let mut result = x;
    for _ in 0..1000 {
        result = result.wrapping_mul(17).wrapping_add(1);
    }
    result
}
```

#### Benchmark Configuration Management

```rust
use criterion::{criterion_group, criterion_main, Criterion, BenchmarkId};
use serde::{Deserialize, Serialize};
use std::collections::HashMap;

#[derive(Debug, Serialize, Deserialize)]
struct BenchmarkConfig {
    name: String,
    iterations: usize,
    warmup_time: u64,
    measurement_time: u64,
    input_sizes: Vec<usize>,
    algorithms: Vec<String>,
}

impl Default for BenchmarkConfig {
    fn default() -> Self {
        Self {
            name: "Default Benchmark".to_string(),
            iterations: 1000,
            warmup_time: 3,
            measurement_time: 5,
            input_sizes: vec![100, 1000, 10000],
            algorithms: vec!["algorithm_a".to_string(), "algorithm_b".to_string()],
        }
	}

fn configurable_benchmark_harness(c: &mut Criterion) {
    // Load configuration (in practice, this might come from a file)
    let config = BenchmarkConfig {
        name: "Sorting Algorithm Comparison".to_string(),
        iterations: 500,
        warmup_time: 2,
        measurement_time: 10,
        input_sizes: vec![1000, 5000, 10000, 50000],
        algorithms: vec!["quicksort".to_string(), "mergesort".to_string(), "heapsort".to_string()],
    };
    
    let mut group = c.benchmark_group(&config.name);
    group.sample_size(config.iterations);
    group.warm_up_time(Duration::from_secs(config.warmup_time));
    group.measurement_time(Duration::from_secs(config.measurement_time));
    
    // Algorithm implementations
    let algorithms: HashMap<String, fn(&mut [i32])> = [
        ("quicksort".to_string(), quicksort as fn(&mut [i32])),
        ("mergesort".to_string(), mergesort_wrapper as fn(&mut [i32])),
        ("heapsort".to_string(), heapsort as fn(&mut [i32])),
    ].iter().cloned().collect();
    
    for size in &config.input_sizes {
        let mut test_data: Vec<i32> = (0..*size as i32).rev().collect(); // Worst case
        
        for algo_name in &config.algorithms {
            if let Some(algorithm) = algorithms.get(algo_name) {
                group.bench_with_input(
                    BenchmarkId::new(algo_name, size),
                    size,
                    |b, _| {
                        b.iter_batched(
                            || test_data.clone(),
                            |mut data| {
                                algorithm(&mut data);
                                black_box(data)
                            },
                            criterion::BatchSize::SmallInput,
                        )
                    },
                );
            }
        }
    }
    
    group.finish();
}

fn quicksort(arr: &mut [i32]) {
    if arr.len() <= 1 { return; }
    let pivot = partition(arr);
    quicksort(&mut arr[0..pivot]);
    quicksort(&mut arr[pivot + 1..]);
}

fn mergesort_wrapper(arr: &mut [i32]) {
    let mut temp = arr.to_vec();
    mergesort_recursive(arr, &mut temp, 0, arr.len());
}

fn mergesort_recursive(arr: &mut [i32], temp: &mut [i32], start: usize, end: usize) {
    if end - start <= 1 { return; }
    let mid = start + (end - start) / 2;
    mergesort_recursive(arr, temp, start, mid);
    mergesort_recursive(arr, temp, mid, end);
    merge_arrays(&arr[start..end], &mut temp[start..end], mid - start);
    arr[start..end].copy_from_slice(&temp[start..end]);
}

fn merge_arrays(arr: &[i32], temp: &mut [i32], mid: usize) {
    let (left, right) = arr.split_at(mid);
    let mut i = 0; let mut j = 0; let mut k = 0;
    
    while i < left.len() && j < right.len() {
        if left[i] <= right[j] {
            temp[k] = left[i]; i += 1;
        } else {
            temp[k] = right[j]; j += 1;
        }
        k += 1;
    }
    
    while i < left.len() { temp[k] = left[i]; i += 1; k += 1; }
    while j < right.len() { temp[k] = right[j]; j += 1; k += 1; }
}

fn heapsort(arr: &mut [i32]) {
    let len = arr.len();
    for i in (0..len / 2).rev() {
        heapify(arr, len, i);
    }
    for i in (1..len).rev() {
        arr.swap(0, i);
        heapify(arr, i, 0);
    }
}

fn heapify(arr: &mut [i32], heap_size: usize, root: usize) {
    let mut largest = root;
    let left = 2 * root + 1;
    let right = 2 * root + 2;
    
    if left < heap_size && arr[left] > arr[largest] {
        largest = left;
    }
    if right < heap_size && arr[right] > arr[largest] {
        largest = right;
    }
    if largest != root {
        arr.swap(root, largest);
        heapify(arr, heap_size, largest);
    }
}
```

#### Comprehensive Benchmark Suite Management

```rust
use criterion::{criterion_group, criterion_main, Criterion};
use std::collections::BTreeMap;
use std::time::Instant;

struct BenchmarkSuite {
    name: String,
    benchmarks: BTreeMap<String, Box<dyn Fn(&mut Criterion)>>,
    metadata: BTreeMap<String, String>,
}

impl BenchmarkSuite {
    fn new(name: String) -> Self {
        Self {
            name,
            benchmarks: BTreeMap::new(),
            metadata: BTreeMap::new(),
        }
    }
    
    fn add_benchmark<F>(&mut self, name: String, benchmark: F) 
    where 
        F: Fn(&mut Criterion) + 'static 
    {
        self.benchmarks.insert(name, Box::new(benchmark));
    }
    
    fn add_metadata(&mut self, key: String, value: String) {
        self.metadata.insert(key, value);
    }
    
    fn run_all(&self, c: &mut Criterion) {
        println!("Running benchmark suite: {}", self.name);
        for (key, value) in &self.metadata {
            println!("  {}: {}", key, value);
        }
        println!();
        
        for (name, benchmark) in &self.benchmarks {
            println!("Running benchmark: {}", name);
            let start = Instant::now();
            benchmark(c);
            println!("Completed in: {:?}\n", start.elapsed());
        }
    }
}

fn comprehensive_benchmark_suite(c: &mut Criterion) {
    let mut suite = BenchmarkSuite::new("Performance Test Suite".to_string());
    
    suite.add_metadata("version".to_string(), "1.0.0".to_string());
    suite.add_metadata("target".to_string(), std::env::consts::ARCH.to_string());
    suite.add_metadata("os".to_string(), std::env::consts::OS.to_string());
    
    // Add CPU-intensive benchmarks
    suite.add_benchmark("cpu_intensive".to_string(), |c| {
        c.bench_function("matrix_multiply", |b| {
            let matrix_a = vec![vec![1.0f32; 100]; 100];
            let matrix_b = vec![vec![2.0f32; 100]; 100];
            
            b.iter(|| {
                let result = matrix_multiply(&matrix_a, &matrix_b);
                black_box(result)
            })
        });
    });
    
    // Add memory-intensive benchmarks
    suite.add_benchmark("memory_intensive".to_string(), |c| {
        c.bench_function("large_vector_operations", |b| {
            b.iter(|| {
                let mut vec: Vec<u64> = (0..1_000_000).collect();
                vec.sort();
                vec.reverse();
                black_box(vec)
            })
        });
    });
    
    // Add I/O benchmarks (simulated)
    suite.add_benchmark("io_operations".to_string(), |c| {
        c.bench_function("string_processing", |b| {
            let text = "Hello, World! ".repeat(10000);
            b.iter(|| {
                let result: String = text
                    .chars()
                    .map(|c| c.to_uppercase().to_string())
                    .collect();
                black_box(result)
            })
        });
    });
    
    suite.run_all(c);
}

fn matrix_multiply(a: &[Vec<f32>], b: &[Vec<f32>]) -> Vec<Vec<f32>> {
    let rows_a = a.len();
    let cols_a = a[0].len();
    let cols_b = b[0].len();
    
    let mut result = vec![vec![0.0; cols_b]; rows_a];
    
    for i in 0..rows_a {
        for j in 0..cols_b {
            for k in 0..cols_a {
                result[i][j] += a[i][k] * b[k][j];
            }
        }
    }
    
    result
}
```

**Key points:**

- Custom harnesses provide specialized benchmarking capabilities
- Configuration management enables systematic testing across scenarios
- Multi-threaded harnesses reveal scalability characteristics
- Comprehensive suites organize related benchmarks logically
- Metadata tracking helps correlate results with system conditions

### Performance Regression Testing

Performance regression testing ensures that code changes don't introduce unexpected performance degradations by comparing current performance against established baselines.

#### Baseline Management System

```rust
use criterion::{black_box, criterion_group, criterion_main, Criterion, BenchmarkId};
use serde::{Deserialize, Serialize};
use std::collections::HashMap;
use std::fs;
use std::path::Path;
use std::time::Duration;

#[derive(Debug, Serialize, Deserialize, Clone)]
struct PerformanceBaseline {
    benchmark_name: String,
    mean_time_ns: u64,
    std_dev_ns: u64,
    timestamp: String,
    git_commit: Option<String>,
    system_info: SystemInfo,
}

#[derive(Debug, Serialize, Deserialize, Clone)]
struct SystemInfo {
    os: String,
    arch: String,
    cpu_count: usize,
    total_memory: u64,
}

impl SystemInfo {
    fn current() -> Self {
        Self {
            os: std::env::consts::OS.to_string(),
            arch: std::env::consts::ARCH.to_string(),
            cpu_count: num_cpus::get(),
            total_memory: 0, // Would need sys-info crate for actual memory
        }
    }
}

struct RegressionTester {
    baselines: HashMap<String, PerformanceBaseline>,
    threshold_percent: f64,
    baseline_file: String,
}

impl RegressionTester {
    fn new(baseline_file: String, threshold_percent: f64) -> Self {
        let baselines = if Path::new(&baseline_file).exists() {
            let content = fs::read_to_string(&baseline_file).unwrap_or_default();
            serde_json::from_str(&content).unwrap_or_default()
        } else {
            HashMap::new()
        };
        
        Self {
            baselines,
            threshold_percent,
            baseline_file,
        }
    }
    
    fn check_regression(&self, benchmark_name: &str, current_time_ns: u64) -> RegressionResult {
        if let Some(baseline) = self.baselines.get(benchmark_name) {
            let baseline_time = baseline.mean_time_ns as f64;
            let current_time = current_time_ns as f64;
            let change_percent = ((current_time - baseline_time) / baseline_time) * 100.0;
            
            if change_percent > self.threshold_percent {
                RegressionResult::Regression {
                    baseline_ns: baseline.mean_time_ns,
                    current_ns: current_time_ns,
                    change_percent,
                }
            } else if change_percent < -self.threshold_percent {
                RegressionResult::Improvement {
                    baseline_ns: baseline.mean_time_ns,
                    current_ns: current_time_ns,
                    change_percent: change_percent.abs(),
                }
            } else {
                RegressionResult::NoChange {
                    baseline_ns: baseline.mean_time_ns,
                    current_ns: current_time_ns,
                    change_percent,
                }
            }
        } else {
            RegressionResult::NewBenchmark { current_ns: current_time_ns }
        }
    }
    
    fn update_baseline(&mut self, benchmark_name: String, time_ns: u64, std_dev_ns: u64) {
        let baseline = PerformanceBaseline {
            benchmark_name: benchmark_name.clone(),
            mean_time_ns: time_ns,
            std_dev_ns,
            timestamp: chrono::Utc::now().to_rfc3339(),
            git_commit: get_git_commit(),
            system_info: SystemInfo::current(),
        };
        
        self.baselines.insert(benchmark_name, baseline);
    }
    
    fn save_baselines(&self) -> Result<(), Box<dyn std::error::Error>> {
        let content = serde_json::to_string_pretty(&self.baselines)?;
        fs::write(&self.baseline_file, content)?;
        Ok(())
    }
}

#[derive(Debug)]
enum RegressionResult {
    Regression { baseline_ns: u64, current_ns: u64, change_percent: f64 },
    Improvement { baseline_ns: u64, current_ns: u64, change_percent: f64 },
    NoChange { baseline_ns: u64, current_ns: u64, change_percent: f64 },
    NewBenchmark { current_ns: u64 },
}

fn get_git_commit() -> Option<String> {
    // In practice, you'd use git2 crate or shell out to git
    std::process::Command::new("git")
        .args(&["rev-parse", "HEAD"])
        .output()
        .ok()
        .and_then(|output| {
            if output.status.success() {
                Some(String::from_utf8_lossy(&output.stdout).trim().to_string())
            } else {
                None
            }
        })
}
```

#### Automated Regression Detection

```rust
use criterion::{black_box, criterion_group, criterion_main, Criterion};
use std::sync::Mutex;
use std::time::Instant;

lazy_static::lazy_static! {
    static ref REGRESSION_TESTER: Mutex<RegressionTester> = 
        Mutex::new(RegressionTester::new("benchmarks_baseline.json".to_string(), 5.0));
}

fn regression_detection_benchmark(c: &mut Criterion) {
    let mut group = c.benchmark_group("regression_detection");
    
    // Algorithm that might have regressions
    group.bench_function("sorting_algorithm", |b| {
        let mut data: Vec<i32> = (0..10000).rev().collect();
        
        let start = Instant::now();
        b.iter(|| {
            let mut test_data = data.clone();
            improved_quicksort(&mut test_data);
            black_box(test_data)
        });
        let elapsed = start.elapsed();
        
        // Check for regression
        let mut tester = REGRESSION_TESTER.lock().unwrap();
        let result = tester.check_regression("sorting_algorithm", elapsed.as_nanos() as u64);
        
        match result {
            RegressionResult::Regression { change_percent, .. } => {
                eprintln!("⚠️  PERFORMANCE REGRESSION DETECTED: {:.2}% slower", change_percent);
            }
            RegressionResult::Improvement { change_percent, .. } => {
                println!("✅ Performance improvement: {:.2}% faster", change_percent);
            }
            RegressionResult::NoChange { change_percent, .. } => {
                println!("➡️  No significant change: {:.2}%", change_percent);
            }
            RegressionResult::NewBenchmark { .. } => {
                println!("🆕 New benchmark, establishing baseline");
            }
        }
    });
    
    // Memory allocation benchmark
    group.bench_function("memory_allocation", |b| {
        let start = Instant::now();
        b.iter(|| {
            let vec: Vec<u8> = vec![0; 1024 * 1024]; // 1MB allocation
            black_box(vec)
        });
        let elapsed = start.elapsed();
        
        let mut tester = REGRESSION_TESTER.lock().unwrap();
        let result = tester.check_regression("memory_allocation", elapsed.as_nanos() as u64);
        
        match result {
            RegressionResult::Regression { change_percent, .. } => {
                eprintln!("⚠️  MEMORY ALLOCATION REGRESSION: {:.2}% slower", change_percent);
            }
            _ => {} // Handle other cases as needed
        }
    });
    
    group.finish();
}

fn improved_quicksort(arr: &mut [i32]) {
    // Potentially optimized version that might introduce regressions
    if arr.len() <= 10 {
        // Use insertion sort for small arrays
        insertion_sort(arr);
        return;
    }
    
    let pivot = partition_three_way(arr);
    improved_quicksort(&mut arr[0..pivot.0]);
    improved_quicksort(&mut arr[pivot.1..]);
}

fn insertion_sort(arr: &mut [i32]) {
    for i in 1..arr.len() {
        let key = arr[i];
        let mut j = i;
        while j > 0 && arr[j - 1] > key {
            arr[j] = arr[j - 1];
            j -= 1;
        }
        arr[j] = key;
    }
}

fn partition_three_way(arr: &mut [i32]) -> (usize, usize) {
    let pivot = arr[arr.len() / 2];
    let mut lt = 0;
    let mut gt = arr.len() - 1;
    let mut i = 0;
    
    while i <= gt {
        if arr[i] < pivot {
            arr.swap(lt, i);
            lt += 1;
            i += 1;
        } else if arr[i] > pivot {
            arr.swap(i, gt);
            if gt == 0 { break; }
            gt -= 1;
        } else {
            i += 1;
        }
    }
    
    (lt, gt + 1)
}
```

#### Continuous Integration Integration

```rust
use criterion::{black_box, criterion_group, criterion_main, Criterion};
use std::env;
use std::process;

fn ci_integration_benchmark(c: &mut Criterion) {
    let is_ci = env::var("CI").is_ok() || env::var("GITHUB_ACTIONS").is_ok();
    let pr_number = env::var("GITHUB_PR_NUMBER").ok();
    
    if is_ci {
        println!("Running in CI environment");
        if let Some(pr_num) = pr_number {
            println!("Pull Request: #{}", pr_num);
        }
    }
    
    let mut group = c.benchmark_group("ci_benchmarks");
    
    // Shorter running benchmarks for CI
    if is_ci {
        group.sample_size(100);
        group.measurement_time(std::time::Duration::from_secs(5));
    }
    
    group.bench_function("critical_path_performance", |b| {
        b.iter(|| {
            // Critical algorithm that must not regress
            let result = critical_algorithm(black_box(1000));
            black_box(result)
        })
    });
    
    group.bench_function("api_response_time", |b| {
        b.iter(|| {
            // Simulate API processing time
            let result = process_api_request(black_box("test_data"));
            black_box(result)
        })
    });
    
    group.finish();
    
    // Check for regressions and fail CI if found
    if is_ci {
        let mut tester = REGRESSION_TESTER.lock().unwrap();
        let mut has_regression = false;
        
        // In practice, you'd store benchmark results and check them here
        // This is a simplified example
        
        if has_regression {
            eprintln!("❌ Performance regressions detected! Failing CI build.");
            process::exit(1);
        } else {
            println!("✅ All performance benchmarks passed.");
        }
    }
}

fn critical_algorithm(input: usize) -> usize {
    // Simulate critical algorithm
    (0..input).map(|i| i * i).sum()
}

fn process_api_request(data: &str) -> String {
    // Simulate API request processing
    format!("Processed: {}", data.to_uppercase())
}
```

#### Historical Performance Tracking

```rust
use criterion::{black_box, criterion_group, criterion_main, Criterion};
use serde::{Deserialize, Serialize};
use std::collections::BTreeMap;
use std::fs;

#[derive(Debug, Serialize, Deserialize)]
struct PerformanceHistory {
    benchmark_name: String,
    measurements: BTreeMap<String, PerformanceMeasurement>, // timestamp -> measurement
}

#[derive(Debug, Serialize, Deserialize)]
struct PerformanceMeasurement {
    mean_time_ns: u64,
    std_dev_ns: u64,
    git_commit: Option<String>,
    build_number: Option<u64>,
    metadata: BTreeMap<String, String>,
}

impl PerformanceHistory {
    fn new(benchmark_name: String) -> Self {
        Self {
            benchmark_name,
            measurements: BTreeMap::new(),
        }
    }
    
    fn add_measurement(&mut self, timestamp: String, measurement: PerformanceMeasurement) {
        self.measurements.insert(timestamp, measurement);
        
        // Keep only last 100 measurements to prevent unbounded growth
        if self.measurements.len() > 100 {
            let oldest_key = self.measurements.keys().next().unwrap().clone();
            self.measurements.remove(&oldest_key);
        }
    }
    
    fn detect_trend(&self, window_size: usize) -> Option<PerformanceTrend> {
        if self.measurements.len() < window_size * 2 {
            return None;
        }
        
        let recent_measurements: Vec<u64> = self.measurements
            .values()
            .rev()
            .take(window_size)
            .map(|m| m.mean_time_ns)
            .collect();
        
        let older_measurements: Vec<u64> = self.measurements
            .values()
            .rev()
            .skip(window_size)
            .take(window_size)
            .map(|m| m.mean_time_ns)
            .collect();
        
        let recent_avg = recent_measurements.iter().sum::<u64>() as f64 / recent_measurements.len() as f64;
        let older_avg = older_measurements.iter().sum::<u64>() as f64 / older_measurements.len() as f64;
        
        let change_percent = ((recent_avg - older_avg) / older_avg) * 100.0;
        
        if change_percent > 10.0 {
            Some(PerformanceTrend::Degrading { change_percent })
        } else if change_percent < -10.0 {
            Some(PerformanceTrend::Improving { change_percent: change_percent.abs() })
        } else {
            Some(PerformanceTrend::Stable { change_percent })
        }
    }
}

#[derive(Debug)]
enum PerformanceTrend {
    Improving { change_percent: f64 },
    Degrading { change_percent: f64 },
    Stable { change_percent: f64 },
}

fn historical_tracking_benchmark(c: &mut Criterion) {
    let mut group = c.benchmark_group("historical_tracking");
    
    group.bench_function("tracked_algorithm", |b| {
        b.iter(|| {
            let result = expensive_tracked_algorithm(black_box(5000));
            black_box(result)
        })
    });
    
    // Save measurement to history
    let timestamp = chrono::Utc::now().to_rfc3339();
    let measurement = PerformanceMeasurement {
        mean_time_ns: 1000000, // This would come from actual benchmark results
        std_dev_ns: 50000,
        git_commit: get_git_commit(),
        build_number: env::var("BUILD_NUMBER").ok().and_then(|s| s.parse().ok()),
        metadata: [
            ("compiler_version".to_string(), rustc_version_runtime::version().to_string()),
            ("optimization_level".to_string(), "release".to_string()),
        ].iter().cloned().collect(),
    };
    
    // Load existing history or create new
    let history_file = "performance_history.json";
    let mut history = if std::path::Path::new(history_file).exists() {
        let content = fs::read_to_string(history_file).unwrap();
        serde_json::from_str(&content).unwrap_or_else(|_| {
            PerformanceHistory::new("tracked_algorithm".to_string())
        })
    } else {
        PerformanceHistory::new("tracked_algorithm".to_string())
    };
    
    history.add_measurement(timestamp, measurement);
    
    // Analyze trends
    if let Some(trend) = history.detect_trend(10) {
        match trend {
            PerformanceTrend::Degrading { change_percent } => {
                println!("📉 Performance trend: Degrading by {:.2}%", change_percent);
            }
            PerformanceTrend::Improving { change_percent } => {
                println!("📈 Performance trend: Improving by {:.2}%", change_percent);
            }
            PerformanceTrend::Stable { change_percent } => {
                println!("➡️  Performance trend: Stable ({:.2}%)", change_percent);
            }
        }
    }
    
    // Save updated history
    let content = serde_json::to_string_pretty(&history).unwrap();
    fs::write(history_file, content).unwrap();
    
    group.finish();
}

fn expensive_tracked_algorithm(n: usize) -> u64 {
    (0..n).map(|i| (i as u64).pow(2)).sum()
}

criterion_group!(
    benches,
    configurable_benchmark_harness,
    parallel_benchmark_harness,
    comprehensive_benchmark_suite,
    regression_detection_benchmark,
    ci_integration_benchmark,
    historical_tracking_benchmark
);
criterion_main!(benches);
```

**Key points:**

- Baseline management enables systematic regression detection
- Automated detection integrates with CI/CD pipelines
- Historical tracking reveals long-term performance trends
- Statistical thresholds prevent false positive alerts
- Version control integration correlates changes with performance impact

**Important related topics to explore:** Memory profiling with tools like Valgrind and heaptrack, CPU profiling with perf and flamegraphs, async benchmarking strategies, cross-platform performance analysis, and integration with monitoring systems for production performance tracking.

---

