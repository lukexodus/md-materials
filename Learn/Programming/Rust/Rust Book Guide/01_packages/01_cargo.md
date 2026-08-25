## `cargo`


### 1. Creating a New Project

To create a new Rust project with Cargo, you can run the following command:

```bash
cargo new my_project
```

This creates a new directory called `my_project` with the following structure:

```
my_project/
├── Cargo.toml
└── src/
    └── main.rs
```

- `Cargo.toml`: The manifest file where you define metadata, dependencies, and other configuration.
- `src/main.rs`: The main entry point of your Rust program.

For a **library** instead of a binary, use:

```bash
cargo new my_library --lib
```

This creates a library package with a similar structure, but the main file will be `lib.rs` instead of `main.rs`.

---

### 2. Basic Commands

Here are some of the most commonly used Cargo commands:

- **`cargo build`**: Compiles the project. It creates a `target/` directory with the compiled binaries.
- **`cargo run`**: Builds and then runs the project.
- **`cargo test`**: Runs the tests in the project.
- **`cargo clean`**: Removes the `target/` directory and any build artifacts.
- **`cargo doc`**: Generates documentation for the project and its dependencies.
- **`cargo check`**: Quickly checks your code for errors without producing a binary.

Example:

```bash
cargo run
```

---

### 3. Managing Dependencies

Cargo uses the `Cargo.toml` file to manage dependencies. To add a dependency, you simply add it under the `[dependencies]` section in your `Cargo.toml` file.

Example `Cargo.toml`:

```toml
[dependencies]
rand = "0.8.3"
serde = { version = "1.0", features = ["derive"] }
```

To install a dependency directly from the command line, you can use:

```bash
cargo add rand
```

You can also specify dependencies from other sources like Git repositories or local paths:

```toml
[dependencies]
some_crate = { git = "https://github.com/user/some_crate.git" }
local_crate = { path = "../local_crate" }
```

---

### 4. Building and Running a Project

To **build** the project:

```bash
cargo build
```

The compiled binary will be in the `target/debug/` directory by default. If you want to build in release mode (optimized for performance):

```bash
cargo build --release
```

This will place the binary in the `target/release/` directory.

To **run** the project:

```bash
cargo run
```

You can pass command-line arguments to your binary:

```bash
cargo run -- arg1 arg2
```

---

### 5. Testing

Cargo makes it easy to test your Rust code. By convention, you can write unit tests directly in the `src/` files, or create integration tests in the `tests/` directory.

To run all tests in your project, use:

```bash
cargo test
```

You can filter tests by name:

```bash
cargo test test_name
```

For documentation tests (which test code snippets in your comments), run:

```bash
cargo test --doc
```

In Rust, when you run tests using `cargo test`, you can specify additional arguments to control how tests are executed. The `--` separator is used to distinguish between arguments intended for Cargo and arguments meant for the test binary itself. 

Here’s how it works:

- **Before `--`**: Any arguments before the `--` are passed to Cargo. These arguments control how Cargo runs, such as building the project or running tests in parallel.
  
- **After `--`**: Any arguments after the `--` are passed to the test binary (the executable produced by Cargo that runs the tests). These are used to control specific behaviors of the test execution, such as filtering test names or setting output formats.

**Example**:
```bash
cargo test -- --nocapture
```

- `cargo test`: Runs the test suite using Cargo.
- `--`: The separator indicating that subsequent arguments are for the test binary.
- `--nocapture`: Passed to the test binary, telling it not to capture (i.e., hide) the output of tests (useful for printing debug messages).

**When to Use It**:
1. **Without the `--` separator**, any arguments you pass are treated as instructions for Cargo itself.
   - Example: `cargo test --release` tells Cargo to build and run the tests in release mode.

2. **With the `--` separator**, arguments after the `--` are passed to the test binary.
   - Example: `cargo test -- --test-threads=1` runs the tests in a single thread (which can be useful for debugging).

**Some Common Test Binary Options After `--**`:
- `--nocapture`: Shows test output, such as `println!` statements, during the test execution.
- `--test-threads=N`: Runs tests in `N` threads.
- `--exact`: Ensures that only a test with the exact name is run.
- `--ignored`: Runs tests marked as `#[ignore]`.

---

### 6. Building Documentation

Cargo can generate documentation for your code and its dependencies using the following command:

```bash
cargo doc
```

This generates documentation in the `target/doc/` directory. To open the documentation in a web browser:

```bash
cargo doc --open
```

---

### 7. Workspaces

Workspaces allow you to manage multiple packages (crates) in a single Cargo project. This is useful for larger projects that consist of several related crates.

To create a workspace, you need a `Cargo.toml` file in the root of the workspace with the following structure:

```toml
[workspace]
members = [
    "crate1",
    "crate2"
]
```

The workspace structure looks like this:

```
workspace/
├── Cargo.toml
├── crate1/
│   └── Cargo.toml
└── crate2/
    └── Cargo.toml
```

With a workspace, you can build all packages at once using:

```bash
cargo build
```

---

### 8. Publishing Crates

To publish your crate to [crates.io](https://crates.io), the Rust package registry:

1. Create an account on [crates.io](https://crates.io).
2. Login to crates.io via Cargo:

   ```bash
   cargo login
   ```

3. Ensure your crate is ready for publishing by running:

   ```bash
   cargo publish --dry-run
   ```

4. Finally, publish your crate:

   ```bash
   cargo publish
   ```

---

### 9. Profiles

Cargo has two default profiles: `dev` and `release`. You can customize these profiles in the `Cargo.toml` file under the `[profile]` section.

Example of customizing the release profile:

```toml
[profile.release]
opt-level = 3
debug = false
lto = true
```

You can configure different optimization levels, debug info, and more depending on your use case.

---

### 10. Cargo.toml Deep Dive

The `Cargo.toml` file is the manifest for your project. Here's a typical `Cargo.toml` structure:

```toml
[package]
name = "my_project"
version = "0.1.0"
authors = ["Your Name <your_email@example.com>"]
edition = "2021"

[dependencies]
serde = "1.0"
```

Key sections:
- `[package]`: Information about your package, including its name, version, and authors.
- `[dependencies]`: Lists external crates your project depends on.
- `[dev-dependencies]`: Dependencies only needed for tests.
- `[build-dependencies]`: Dependencies needed for build scripts.

---

### 11. Advanced Features

Cargo also supports advanced features, such as:

- **Features**: Allows you to conditionally compile parts of your crate based on flags in your `Cargo.toml`.

   ```toml
   [features]
   default = ["serde"]
   serde = ["serde"]
   ```

- **Build Scripts**: Custom scripts that are executed during the build process. These are useful for tasks like generating code or compiling native dependencies.

   Create a `build.rs` file in your project, and Cargo will run it automatically.

- **Custom Commands**: You can define custom subcommands that are specific to your project. These can be written as separate binaries in your project and invoked via `cargo my_command`.

