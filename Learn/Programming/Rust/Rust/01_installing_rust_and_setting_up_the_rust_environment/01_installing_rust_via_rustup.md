## Installing Rust via `rustup`


`rustup` is the **official tool** for managing Rust versions and associated tools. It installs the Rust compiler (`rustc`), the package manager (`cargo`), standard libraries, and documentation. It also allows easy updates and switching between Rust versions or channels.

### Requirements

- A Unix-like system (Linux, macOS) or Windows
- A terminal or shell
- On Windows: PowerShell or CMD with Administrator privileges (or Git Bash for Unix-like experience)
    

### Installation Steps

#### On Linux and macOS

Open a terminal and run:

```sh
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
```

- This script will prompt you to install Rust with default settings.
- To customize the installation (e.g., default toolchain, install directory), choose the **custom install** option.

After installation, configure your environment:

```sh
source $HOME/.cargo/env
```

#### On Windows

1. Go to: [https://rustup.rs](https://rustup.rs)
2. Download and run the **Windows installer**.
3. Follow the installer instructions. It installs:
    - `rustc` (Rust compiler)
    - `cargo` (Package manager)
    - `rustup` (Toolchain manager)
        
You may need to restart your terminal or add Rust to your system `PATH` manually if not done automatically.

### Verifying Installation

After installation, run the following commands:

```sh
rustc --version    # prints the compiler version
cargo --version    # prints the Cargo version
rustup --version   # prints the Rustup version
```

### Components Installed

- `rustc`: Rust compiler
- `cargo`: Builds and manages dependencies
- `rust-std`: Standard library
- `rust-docs`: Local documentation (`cargo doc`)
- `clippy`: Linter (can be installed separately)
- `rustfmt`: Formatter (can be installed separately)
    

### Managing Versions and Channels

**Rust Channels**
- **Stable**: Officially released, most reliable.
- **Beta**: Pre-release, one step ahead of stable.
- **Nightly**: Cutting-edge features, unstable APIs.
    

**Switching Channels**

```sh
rustup default stable      # use the stable release
rustup default nightly     # set nightly as default
rustup override set nightly # override only in current directory
```

**Installing Components**

```sh
rustup component add rustfmt    # formatter
rustup component add clippy     # linter
```

**Updating Rust**

```sh
rustup update                  # updates all installed toolchains
rustup update stable           # updates only the stable version
```

**Uninstalling Rust**

```sh
rustup self uninstall
```

### Directory Structure

Installed by default under:

- **Linux/macOS**: `$HOME/.cargo/` and `$HOME/.rustup/`
- **Windows**: `%USERPROFILE%\.cargo\` and `%USERPROFILE%\.rustup\`
    

**Conclusion**

`rustup` is the preferred and official way to install and manage Rust. It ensures that all necessary components are installed and kept up-to-date with minimal manual configuration.

---

