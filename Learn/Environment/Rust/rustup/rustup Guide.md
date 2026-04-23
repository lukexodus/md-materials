## 1. What is `rustup`?

`rustup` is the official Rust toolchain installer and version manager. It manages Rust compiler versions (`rustc`), the package manager (`cargo`), standard library components, and cross-compilation targets.

Source: [rustup.rs](https://rustup.rs/) and the [rustup book](https://rust-lang.github.io/rustup/).

---

## 2. Installation

### Linux / macOS

```bash
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
```

### Windows

Download and run `rustup-init.exe` from https://rustup.rs

### Non-interactive / CI installs

```bash
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
# -y = accept all defaults
```

### Post-install: source the env

```bash
source "$HOME/.cargo/env"
# or add to your .bashrc / .zshrc:
export PATH="$HOME/.cargo/bin:$PATH"
```

---

## 3. Core Concepts

|Concept|Description|
|---|---|
|**Toolchain**|A specific version of Rust + associated tools (rustc, cargo, etc.)|
|**Channel**|`stable`, `beta`, or `nightly`|
|**Component**|Optional additions to a toolchain (e.g., `clippy`, `rust-src`)|
|**Target**|A compilation target triple (e.g., `x86_64-unknown-linux-gnu`)|
|**Profile**|A preset group of components (`minimal`, `default`, `complete`)|

---

## 4. Managing Toolchains

### Show active toolchain

```bash
rustup show
rustup show active-toolchain
```

### List installed toolchains

```bash
rustup toolchain list
```

### Install a toolchain

```bash
rustup toolchain install stable
rustup toolchain install nightly
rustup toolchain install 1.75.0          # specific version
rustup toolchain install nightly-2024-01-01  # dated nightly
```

### Uninstall a toolchain

```bash
rustup toolchain uninstall nightly
```

### Set default toolchain

```bash
rustup default stable
rustup default nightly
rustup default 1.75.0
```

### Use a toolchain for a single command

```bash
rustup run nightly cargo build
# or shorthand:
cargo +nightly build
rustc +stable --version
```

### Directory-level override (`rust-toolchain.toml`)

Create a `rust-toolchain.toml` file in your project root:

```toml
[toolchain]
channel = "stable"          # or "nightly", "1.75.0"
components = ["rustfmt", "clippy"]
targets = ["wasm32-unknown-unknown"]
profile = "default"
```

`rustup` reads this automatically when you're in that directory.

### Directory override via CLI

```bash
rustup override set nightly          # set for current dir
rustup override set 1.75.0 --path /my/project
rustup override unset
rustup override list
```

---

## 5. Updating

```bash
rustup update              # update all installed toolchains
rustup update stable
rustup update nightly
rustup self update         # update rustup itself
```

---

## 6. Components

Components extend a toolchain. They are toolchain-specific.

### List available and installed components

```bash
rustup component list
rustup component list --installed
rustup component list --toolchain nightly
```

### Add a component

```bash
rustup component add clippy
rustup component add rustfmt
rustup component add rust-src
rustup component add rust-analyzer
rustup component add llvm-tools-preview
rustup component add miri              # nightly only
```

### Remove a component

```bash
rustup component remove clippy
```

### Common components reference

|Component|Use|
|---|---|
|`rustfmt`|Code formatter (`cargo fmt`)|
|`clippy`|Linter (`cargo clippy`)|
|`rust-src`|Standard library source (needed by rust-analyzer, some tools)|
|`rust-analyzer`|LSP server for IDEs|
|`llvm-tools-preview`|LLVM tools for coverage, profiling|
|`miri`|Interpreter for detecting UB (nightly only)|
|`rust-docs`|Offline Rust documentation|

---

## 7. Targets (Cross-Compilation)

A **target** is a platform you want to compile _for_ (not necessarily the machine you compile _on_).

### List installed and available targets

```bash
rustup target list
rustup target list --installed
rustup target list --toolchain stable
```

### Add a target

```bash
rustup target add wasm32-unknown-unknown
rustup target add aarch64-unknown-linux-gnu
rustup target add x86_64-pc-windows-gnu
rustup target add thumbv7em-none-eabihf    # embedded ARM
```

### Remove a target

```bash
rustup target remove wasm32-unknown-unknown
```

### Compile for a target

```bash
cargo build --target wasm32-unknown-unknown
```

> **Note:** Adding a target only installs the Rust standard library for that target. Cross-compilation often also requires a C linker/toolchain for the target platform. That is a separate system-level requirement.

---

## 8. Profiles

Profiles control which components are installed by default.

|Profile|Components|
|---|---|
|`minimal`|`rustc`, `cargo`, `rust-std`|
|`default`|`minimal` + `rustfmt`, `clippy`, `rust-docs`|
|`complete`|Everything available|

```bash
rustup set profile minimal
rustup set profile default
rustup toolchain install stable --profile minimal
```

---

## 9. Proxies

`rustup` installs proxy binaries (e.g., `rustc`, `cargo`) in `~/.cargo/bin`. When you invoke them, `rustup` routes the call to the correct toolchain based on:

1. Directory override (`rust-toolchain.toml` or `rustup override`)
2. Default toolchain

You can verify which binary is active:

```bash
rustc --version
cargo --version
rustup which rustc
rustup which cargo
```

---

## 10. `rustup doc` — Offline Documentation

```bash
rustup doc               # open the Rust book
rustup doc --std         # standard library docs
rustup doc --book        # The Rust Programming Language book
rustup doc --reference   # Rust Reference
rustup doc --nomicon     # The Rustonomicon
rustup doc --cargo       # Cargo book
```

Requires the `rust-docs` component to be installed.

---

## 11. Self-Management

```bash
rustup self update       # update rustup binary
rustup self uninstall    # remove rustup and all toolchains
```

---

## 12. Environment Variables

|Variable|Effect|
|---|---|
|`RUSTUP_HOME`|Override rustup metadata/toolchain dir (default `~/.rustup`)|
|`CARGO_HOME`|Override cargo home dir (default `~/.cargo`)|
|`RUSTUP_TOOLCHAIN`|Force a specific toolchain (overrides directory overrides)|
|`RUSTUP_DIST_SERVER`|Alternate distribution server (e.g., for mirrors)|
|`RUSTUP_UPDATE_ROOT`|Alternate source for rustup binary updates|
|`RUSTUP_IO_THREADS`|Number of threads for parallel downloads|

Example mirror configuration:

```bash
export RUSTUP_DIST_SERVER=https://mirrors.tuna.tsinghua.edu.cn/rustup
export RUSTUP_UPDATE_ROOT=https://mirrors.tuna.tsinghua.edu.cn/rustup/rustup
```

---

## 13. CI / Docker Patterns

### Minimal CI install

```bash
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- \
  -y \
  --profile minimal \
  --default-toolchain stable
source "$HOME/.cargo/env"
```

### Dockerfile pattern

```dockerfile
FROM debian:bookworm-slim
RUN apt-get update && apt-get install -y curl build-essential
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --profile minimal
ENV PATH="/root/.cargo/bin:${PATH}"
```

### `rust-toolchain.toml` in CI

Committing a `rust-toolchain.toml` to your repo means `rustup` automatically installs the right toolchain on any machine that has `rustup` installed — no extra CI config needed.

---

## 14. Nightly-specific Workflow

```bash
rustup toolchain install nightly --allow-downgrade \
  --component miri rust-src

# Use miri to check for undefined behavior
cargo +nightly miri run
cargo +nightly miri test

# Use unstable cargo features
cargo +nightly -Z build-std build --target x86_64-unknown-linux-gnu
```

---

## 15. Troubleshooting

|Problem|Command|
|---|---|
|Toolchain not found|`rustup toolchain install <channel>`|
|Component unavailable on nightly|Try a recent dated nightly: `nightly-YYYY-MM-DD`|
|`rustup` itself outdated|`rustup self update`|
|Check what's active|`rustup show`|
|Verify binary routing|`rustup which rustc`|
|Corrupt toolchain|`rustup toolchain uninstall <name>` then reinstall|

### Nightly component availability

Not all components are available on every nightly build. If a component is missing:

```bash
# Find latest nightly with a specific component
rustup toolchain install nightly --component miri --allow-downgrade
# --allow-downgrade lets rustup pick an older nightly that has the component
```

---

## 16. Quick Reference Cheatsheet

```bash
# Install & update
rustup update
rustup self update

# Toolchains
rustup toolchain list
rustup toolchain install nightly
rustup default stable
cargo +nightly build

# Overrides
rustup override set nightly
rustup override unset

# Components
rustup component add clippy rustfmt rust-src
rustup component list --installed

# Targets
rustup target add wasm32-unknown-unknown
cargo build --target wasm32-unknown-unknown

# Info
rustup show
rustup which rustc
rustup doc --book
```

---

All commands above are based on the official [rustup documentation](https://rust-lang.github.io/rustup/). Behavior of specific toolchain versions or nightly builds is subject to change; always verify against current docs for version-sensitive workflows. [Inference] — details like exact component availability on a given date are not confirmed here without checking live rustup metadata.