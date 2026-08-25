## Comprehensive Cargo.toml Guide


### Overview

`Cargo.toml` is the manifest file for Rust packages (crates). It contains metadata about your project and its dependencies. This file uses the TOML (Tom's Obvious, Minimal Language) format and is placed at the root of your Rust project.

### Basic Structure

```toml
[package]
name = "my_project"
version = "0.1.0"
edition = "2021"

[dependencies]
```

### Package Section

The `[package]` section defines metadata about your crate:

#### Required Fields

```toml
[package]
name = "my_awesome_crate"        # Crate name (must be unique on crates.io)
version = "1.2.3"               # Semantic version
edition = "2021"                # Rust edition (2015, 2018, 2021)
```

#### Optional Fields

```toml
[package]
name = "my_awesome_crate"
version = "1.2.3"
edition = "2021"
authors = ["Your Name <you@example.com>"]
license = "MIT OR Apache-2.0"
description = "A short description of the crate"
documentation = "https://docs.rs/my_awesome_crate"
homepage = "https://github.com/user/my_awesome_crate"
repository = "https://github.com/user/my_awesome_crate"
readme = "README.md"
keywords = ["cli", "tool", "utility"]  # Max 5 keywords
categories = ["command-line-utilities"] # See crates.io categories
rust-version = "1.56"           # Minimum supported Rust version (MSRV)
include = [                     # Files to include in published crate
    "src/**/*",
    "Cargo.toml",
    "README.md",
    "LICENSE*"
]
exclude = [                     # Files to exclude from published crate
    "tests/fixtures/*",
    "benches/large-input.txt"
]
publish = true                  # Set to false to prevent publishing
```

### Dependencies

#### Basic Dependencies

```toml
[dependencies]
serde = "1.0"                   # Latest compatible version
regex = "1.5.4"                 # Specific version
log = "0.4"                     # Compatible versions
rand = { version = "0.8", features = ["small_rng"] }
```

#### Version Requirements

```toml
[dependencies]
# Caret requirements (default)
serde = "^1.2.3"    # >=1.2.3, <2.0.0
serde = "1.2.3"     # Same as above

# Tilde requirements
serde = "~1.2.3"    # >=1.2.3, <1.3.0
serde = "~1.2"      # >=1.2.0, <1.3.0

# Wildcard requirements
serde = "1.*"       # >=1.0.0, <2.0.0
serde = "*"         # >=0.0.0

# Comparison requirements
serde = ">= 1.2.0"
serde = "> 1.2"
serde = "< 2.0"
serde = "= 1.2.3"

# Multiple requirements
serde = ">= 1.2, < 1.5"
```

#### Git Dependencies

```toml
[dependencies]
my_crate = { git = "https://github.com/user/my_crate" }
my_crate = { git = "https://github.com/user/my_crate", branch = "main" }
my_crate = { git = "https://github.com/user/my_crate", tag = "v1.0.0" }
my_crate = { git = "https://github.com/user/my_crate", rev = "abc123" }
```

#### Path Dependencies

```toml
[dependencies]
my_local_crate = { path = "../my_local_crate" }
utils = { path = "src/utils" }
```

#### Optional Dependencies and Features

```toml
[dependencies]
serde = { version = "1.0", optional = true }
tokio = { version = "1.0", features = ["full"] }

[features]
default = ["json"]              # Default features
json = ["serde", "serde_json"]  # Feature that enables other features
full = ["json", "xml"]          # Feature that enables multiple features
```

### Development Dependencies

Dependencies only used during development and testing:

```toml
[dev-dependencies]
criterion = "0.4"       # For benchmarking
proptest = "1.0"        # Property-based testing
tempfile = "3.0"        # Temporary file utilities
```

### Build Dependencies

Dependencies used by build scripts:

```toml
[build-dependencies]
cc = "1.0"              # For compiling C code
bindgen = "0.60"        # For generating FFI bindings
```

### Target-Specific Dependencies

Dependencies for specific platforms:

```toml
[target.'cfg(windows)'.dependencies]
winapi = "0.3"

[target.'cfg(unix)'.dependencies]
libc = "0.2"

[target.'cfg(target_arch = "wasm32")'.dependencies]
wasm-bindgen = "0.2"

# Alternative syntax
[target.x86_64-pc-windows-gnu.dependencies]
winapi = "0.3"
```

### Workspace Configuration

#### Root Cargo.toml for Workspace

```toml
[workspace]
members = [
    "crate1",
    "crate2",
    "tools/*",              # Glob patterns supported
]
exclude = ["old_crate"]     # Exclude specific directories
resolver = "2"              # Dependency resolver version

[workspace.dependencies]    # Shared dependencies
serde = "1.0"
tokio = "1.0"

[workspace.package]         # Shared package fields
authors = ["Your Name <you@example.com>"]
license = "MIT OR Apache-2.0"
edition = "2021"
```

#### Member Crate Using Workspace Dependencies

```toml
[package]
name = "member_crate"
version = "0.1.0"
edition.workspace = true    # Inherit from workspace
authors.workspace = true
license.workspace = true

[dependencies]
serde.workspace = true      # Use workspace version
```

### Binary and Library Configuration

#### Multiple Binaries

```toml
[[bin]]
name = "main_binary"
path = "src/main.rs"

[[bin]]
name = "helper_tool"
path = "src/bin/helper.rs"
```

#### Library Configuration

```toml
[lib]
name = "my_lib"             # Library name (defaults to package name)
path = "src/lib.rs"         # Path to library root
crate-type = ["lib"]        # Crate types: lib, rlib, dylib, cdylib, staticlib
```

#### Examples

```toml
[[example]]
name = "basic_usage"
path = "examples/basic.rs"

[[example]]
name = "advanced"
required-features = ["json"] # Only build with these features
```

#### Tests

```toml
[[test]]
name = "integration"
path = "tests/integration_test.rs"

[[test]]
name = "performance"
harness = false             # Don't use built-in test harness
```

#### Benchmarks

```toml
[[bench]]
name = "my_benchmark"
path = "benches/bench.rs"
harness = false
required-features = ["unstable"]
```

### Build Configuration

#### Build Script

```toml
[package]
build = "build.rs"          # Path to build script
```

#### Profile Settings

```toml
[profile.dev]
opt-level = 0               # Optimization level (0-3, "s", "z")
debug = true                # Include debug info
debug-assertions = true     # Enable debug assertions
overflow-checks = true      # Enable integer overflow checks
lto = false                 # Link-time optimization
panic = "unwind"           # Panic strategy: "unwind" or "abort"
incremental = true         # Incremental compilation
codegen-units = 256        # Number of codegen units

[profile.release]
opt-level = 3
debug = false
debug-assertions = false
overflow-checks = false
lto = true
panic = "abort"
incremental = false
codegen-units = 1

# Custom profiles
[profile.bench]
inherits = "release"
debug = true

[profile.my-profile]
inherits = "dev"
opt-level = 1
```

### Advanced Features

#### Patch Section

Override dependencies:

```toml
[patch.crates-io]
serde = { path = "../my-serde" }

[patch.'https://github.com/user/repo']
my_crate = { path = "../local-version" }
```

#### Replace Section (Deprecated)

```toml
[replace]
"serde:1.0.0" = { path = "../my-serde" }
```

#### Metadata

Custom metadata for tools:

```toml
[package.metadata.my_tool]
some_option = "value"
```

### Common Patterns

#### CLI Application

```toml
[package]
name = "my_cli_tool"
version = "0.1.0"
edition = "2021"
description = "A useful command-line tool"
license = "MIT OR Apache-2.0"
keywords = ["cli", "tool"]
categories = ["command-line-utilities"]

[dependencies]
clap = { version = "4.0", features = ["derive"] }
serde = { version = "1.0", features = ["derive"] }
serde_json = "1.0"
anyhow = "1.0"

[dev-dependencies]
assert_cmd = "2.0"
predicates = "2.1"
tempfile = "3.0"
```

#### Web Service

```toml
[package]
name = "my_web_service"
version = "0.1.0"
edition = "2021"

[dependencies]
tokio = { version = "1.0", features = ["full"] }
axum = "0.6"
serde = { version = "1.0", features = ["derive"] }
serde_json = "1.0"
tracing = "0.1"
tracing-subscriber = "0.3"

[dev-dependencies]
tower = { version = "0.4", features = ["util"] }
hyper = { version = "0.14", features = ["full"] }
```

#### Library with Optional Features

```toml
[package]
name = "my_library"
version = "1.0.0"
edition = "2021"

[dependencies]
serde = { version = "1.0", optional = true }
tokio = { version = "1.0", optional = true }
reqwest = { version = "0.11", optional = true }

[features]
default = []
async = ["tokio"]
http = ["reqwest", "async"]
serialization = ["serde"]
full = ["async", "http", "serialization"]
```

### Best Practices

1. **Version Management**: Use semantic versioning and be conservative with breaking changes
2. **Features**: Keep features optional and composable
3. **Dependencies**: Minimize dependencies and prefer well-maintained crates
4. **Documentation**: Include comprehensive package metadata
5. **MSRV**: Specify minimum supported Rust version when targeting older compilers
6. **License**: Always specify a license for public crates
7. **Keywords and Categories**: Use relevant keywords and categories for discoverability

### Common Commands

```bash
# Create new project
cargo new my_project
cargo init

# Build and run
cargo build
cargo run
cargo build --release

# Testing
cargo test
cargo bench

# Documentation
cargo doc --open

# Publishing
cargo publish --dry-run
cargo publish

# Dependency management
cargo update
cargo tree
cargo audit
```
