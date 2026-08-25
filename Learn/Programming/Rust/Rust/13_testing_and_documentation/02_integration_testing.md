## Integration Testing


Integration testing in Rust verifies that different parts of your application work correctly together, testing the public interface of your crate as external users would interact with it. Unlike unit tests that focus on individual components in isolation, integration tests exercise complete workflows and validate that modules, functions, and external dependencies integrate properly.

### Tests Directory Structure

Rust follows a conventional directory structure for integration tests, placing them in a dedicated `tests` directory at the root of your project, alongside `src` and `Cargo.toml`. Each file in the `tests` directory is compiled as a separate crate, allowing for isolated test environments.

The standard structure looks like:

```
my_project/
├── Cargo.toml
├── src/
│   ├── lib.rs
│   └── main.rs
└── tests/
    ├── integration_test.rs
    ├── common/
    │   └── mod.rs
    └── another_test.rs
```

Each file directly under `tests/` becomes a separate integration test binary. Files in subdirectories like `tests/common/` are treated as modules that can be shared between integration tests, not as separate test binaries themselves.

**Example:**

```rust
// tests/integration_test.rs
use my_project::important_function;

#[test]
fn test_important_workflow() {
    let result = important_function("test input");
    assert_eq!(result, "expected output");
}

#[test]
fn test_error_handling() {
    let result = std::panic::catch_unwind(|| {
        important_function("invalid input")
    });
    assert!(result.is_err());
}
```

For shared functionality between integration tests, create a common module:

```rust
// tests/common/mod.rs
use std::fs;
use std::path::Path;

pub fn setup_test_environment() -> tempfile::TempDir {
    tempfile::tempdir().expect("Failed to create temp directory")
}

pub fn create_test_file(dir: &Path, name: &str, content: &str) {
    let file_path = dir.join(name);
    fs::write(file_path, content).expect("Failed to write test file");
}
```

```rust
// tests/file_operations.rs
mod common;

use my_project::file_processor;
use common::{setup_test_environment, create_test_file};

#[test]
fn test_file_processing_workflow() {
    let temp_dir = setup_test_environment();
    create_test_file(temp_dir.path(), "input.txt", "test content");
    
    let result = file_processor::process_file(temp_dir.path().join("input.txt"));
    assert!(result.is_ok());
}
```

Integration tests run with `cargo test`, and you can run specific integration test files using `cargo test --test integration_test`. The `--test` flag followed by the filename (without extension) targets a specific integration test binary.

### External Crate Testing

Integration tests treat your crate as an external dependency, importing it using standard `use` statements just as external users would. This approach ensures that your public API is accessible and functions correctly from an outside perspective.

When testing libraries that depend on external crates, integration tests verify that these dependencies work correctly in realistic scenarios. This includes testing with different versions of dependencies, mock implementations, and various configuration states.

**Example:**

```rust
// tests/database_integration.rs
use my_web_app::{Database, User, UserService};
use tokio_test;

#[tokio::test]
async fn test_user_crud_operations() {
    let db = Database::connect("sqlite::memory:").await.unwrap();
    let user_service = UserService::new(db);
    
    // Test user creation
    let user = User::new("alice", "alice@example.com");
    let created_user = user_service.create_user(user).await.unwrap();
    assert!(created_user.id > 0);
    
    // Test user retrieval
    let retrieved_user = user_service.get_user(created_user.id).await.unwrap();
    assert_eq!(retrieved_user.username, "alice");
    
    // Test user update
    let updated_user = user_service.update_email(created_user.id, "newalice@example.com").await.unwrap();
    assert_eq!(updated_user.email, "newalice@example.com");
    
    // Test user deletion
    let deleted = user_service.delete_user(created_user.id).await.unwrap();
    assert!(deleted);
}
```

For testing with external services or APIs, integration tests often use techniques like dependency injection, mock servers, or test containers:

```rust
// tests/api_integration.rs
use my_service::{ApiClient, Configuration};
use wiremock::{MockServer, Mock, ResponseTemplate};
use wiremock::matchers::{method, path};

#[tokio::test]
async fn test_api_client_with_mock_server() {
    let mock_server = MockServer::start().await;
    
    Mock::given(method("GET"))
        .and(path("/users/123"))
        .respond_with(ResponseTemplate::new(200)
            .set_body_json(serde_json::json!({
                "id": 123,
                "name": "Test User"
            })))
        .mount(&mock_server)
        .await;
    
    let config = Configuration::new(&mock_server.uri());
    let client = ApiClient::new(config);
    
    let user = client.get_user(123).await.unwrap();
    assert_eq!(user.name, "Test User");
}
```

### Doc-tests

Doc-tests are executable code examples embedded within documentation comments that serve both as documentation and as tests. Rust automatically discovers and runs these examples when you execute `cargo test`, ensuring that your documentation remains accurate and up-to-date.

Doc-tests are written using triple backticks with the `rust` language specifier within documentation comments:

**Example:**

```rust
/// Calculates the factorial of a number.
/// 
/// # Examples
/// 
/// ```
/// use my_math::factorial;
/// 
/// assert_eq!(factorial(5), 120);
/// assert_eq!(factorial(0), 1);
/// ```
/// 
/// # Panics
/// 
/// This function panics if given a negative number:
/// 
/// ```should_panic
/// use my_math::factorial;
/// 
/// factorial(-1); // This will panic
/// ```
pub fn factorial(n: i32) -> i32 {
    if n < 0 {
        panic!("Factorial is not defined for negative numbers");
    }
    (1..=n).product()
}
```

Doc-tests support various attributes to control their behavior:

- `ignore` - Skip the test during normal test runs
- `should_panic` - Expect the code to panic
- `no_run` - Compile but don't execute the code
- `compile_fail` - Expect compilation to fail
- `edition2018` or `edition2021` - Specify Rust edition

**Example with advanced doc-test features:**

```rust
/// A configuration parser that handles various formats.
/// 
/// ```
/// use my_config::ConfigParser;
/// 
/// let parser = ConfigParser::new();
/// let config = parser.parse_from_str(r#"
///     name = "MyApp"
///     version = "1.0.0"
/// "#).unwrap();
/// 
/// assert_eq!(config.get("name"), Some("MyApp"));
/// ```
/// 
/// For complex setup that you don't want to show in docs:
/// 
/// ```
/// # use my_config::ConfigParser;
/// # use std::fs;
/// # let temp_dir = tempfile::tempdir().unwrap();
/// # let config_path = temp_dir.path().join("config.toml");
/// # fs::write(&config_path, "debug = true").unwrap();
/// 
/// let parser = ConfigParser::new();
/// let config = parser.parse_from_file(&config_path).unwrap();
/// assert_eq!(config.get("debug"), Some("true"));
/// ```
pub struct ConfigParser {
    // implementation
}
```

Doc-tests can also be used in integration test files and separate documentation files with the `.md` extension, providing flexibility in organizing comprehensive examples and tutorials.

### Testing Private Functions

While integration tests focus on public APIs, there are legitimate scenarios where testing private functions becomes necessary for thorough coverage. Rust provides several approaches to access private functionality for testing purposes.

The most common approach uses the `#[cfg(test)]` attribute to create test-only public interfaces:

**Example:**

```rust
// src/lib.rs
pub struct Calculator {
    memory: f64,
}

impl Calculator {
    pub fn new() -> Self {
        Calculator { memory: 0.0 }
    }
    
    pub fn add(&mut self, value: f64) -> f64 {
        self.memory = self.internal_add(self.memory, value);
        self.memory
    }
    
    fn internal_add(&self, a: f64, b: f64) -> f64 {
        a + b
    }
    
    // Test-only public access to private function
    #[cfg(test)]
    pub fn test_internal_add(&self, a: f64, b: f64) -> f64 {
        self.internal_add(a, b)
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    
    #[test]
    fn test_internal_add_directly() {
        let calc = Calculator::new();
        assert_eq!(calc.test_internal_add(2.0, 3.0), 5.0);
    }
}
```

Another approach involves creating a separate testing module that's conditionally compiled:

```rust
// src/lib.rs
mod calculator {
    pub struct Calculator {
        memory: f64,
    }
    
    impl Calculator {
        pub fn new() -> Self {
            Calculator { memory: 0.0 }
        }
        
        fn complex_calculation(&self, input: &[f64]) -> f64 {
            input.iter().fold(0.0, |acc, &x| acc + x * x)
        }
    }
}

#[cfg(test)]
pub mod test_helpers {
    use super::calculator::Calculator;
    
    impl Calculator {
        pub fn expose_complex_calculation(&self, input: &[f64]) -> f64 {
            self.complex_calculation(input)
        }
    }
}

pub use calculator::Calculator;
```

For integration tests that need access to private functions, you can create a test-only feature flag:

**Example:**

```rust
// Cargo.toml
[features]
testing = []

// src/lib.rs
impl Calculator {
    #[cfg(feature = "testing")]
    pub fn internal_state(&self) -> f64 {
        self.memory
    }
}

// tests/integration_test.rs
#[cfg(feature = "testing")]
use my_crate::Calculator;

#[test]
#[cfg(feature = "testing")]
fn test_internal_state_access() {
    let mut calc = Calculator::new();
    calc.add(5.0);
    assert_eq!(calc.internal_state(), 5.0);
}
```

### Test Harnesses

Test harnesses in Rust provide the infrastructure for running and managing tests, including custom test frameworks, benchmarks, and specialized testing scenarios. The default test harness handles most common testing needs, but custom harnesses become valuable for specific requirements.

Rust allows disabling the default test harness and implementing custom test execution logic:

**Example:**

```rust
// Cargo.toml
[[test]]
name = "custom_harness_test"
harness = false

// tests/custom_harness_test.rs
fn main() {
    println!("Running custom test harness");
    
    let tests = vec![
        ("test_addition", test_addition),
        ("test_subtraction", test_subtraction),
    ];
    
    let mut passed = 0;
    let mut failed = 0;
    
    for (name, test_fn) in tests {
        print!("Running {} ... ", name);
        match std::panic::catch_unwind(test_fn) {
            Ok(_) => {
                println!("ok");
                passed += 1;
            },
            Err(_) => {
                println!("FAILED");
                failed += 1;
            }
        }
    }
    
    println!("\nTest result: {} passed; {} failed", passed, failed);
    
    if failed > 0 {
        std::process::exit(1);
    }
}

fn test_addition() {
    assert_eq!(2 + 2, 4);
}

fn test_subtraction() {
    assert_eq!(5 - 3, 2);
}
```

Custom test harnesses are particularly useful for:

- Performance testing with custom timing and reporting
- Property-based testing frameworks
- Integration with external test runners
- Specialized testing protocols for embedded systems
- Custom assertion and reporting mechanisms

**Example of a performance-focused test harness:**

```rust
// tests/performance_harness.rs
use std::time::{Duration, Instant};

fn main() {
    let benchmarks = vec![
        ("fibonacci_recursive", benchmark_fibonacci_recursive),
        ("fibonacci_iterative", benchmark_fibonacci_iterative),
    ];
    
    for (name, bench_fn) in benchmarks {
        let duration = time_function(bench_fn);
        println!("{}: {:?}", name, duration);
    }
}

fn time_function<F>(f: F) -> Duration 
where 
    F: FnOnce()
{
    let start = Instant::now();
    f();
    start.elapsed()
}

fn benchmark_fibonacci_recursive() {
    for _ in 0..1000 {
        fibonacci_recursive(20);
    }
}

fn benchmark_fibonacci_iterative() {
    for _ in 0..1000 {
        fibonacci_iterative(20);
    }
}

fn fibonacci_recursive(n: u32) -> u32 {
    match n {
        0 => 0,
        1 => 1,
        _ => fibonacci_recursive(n - 1) + fibonacci_recursive(n - 2),
    }
}

fn fibonacci_iterative(n: u32) -> u32 {
    if n <= 1 {
        return n;
    }
    
    let mut prev = 0;
    let mut curr = 1;
    
    for _ in 2..=n {
        let next = prev + curr;
        prev = curr;
        curr = next;
    }
    
    curr
}
```

**Key points** for effective integration testing include organizing tests logically in the `tests/` directory, using shared modules for common functionality, leveraging doc-tests for documentation verification, strategically accessing private functions when necessary, and implementing custom test harnesses for specialized requirements.

**Conclusion:** Integration testing in Rust provides comprehensive verification of your crate's public interface and interactions with external dependencies. The structured approach to test organization, combined with powerful features like doc-tests and custom harnesses, enables thorough validation of complex systems while maintaining clean separation between different types of tests.

---

