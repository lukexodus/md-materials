## Main rustup Commands


### Installation & Updates
- `rustup update` - Update Rust toolchains and rustup itself
- `rustup self update` - Update rustup itself only
- `rustup install <toolchain>` - Install a specific toolchain

### Toolchain Management
- `rustup toolchain list` - List installed toolchains
- `rustup toolchain install <toolchain>` - Install a toolchain
- `rustup toolchain uninstall <toolchain>` - Remove a toolchain
- `rustup toolchain link <name> <path>` - Create a custom toolchain
- `rustup default <toolchain>` - Set the default toolchain

### Target Management
- `rustup target list` - List available targets
- `rustup target add <target>` - Add a compilation target
- `rustup target remove <target>` - Remove a compilation target

### Component Management  
- `rustup component list` - List available components
- `rustup component add <component>` - Add a component
- `rustup component remove <component>` - Remove a component

### Override Management
- `rustup override list` - List directory overrides
- `rustup override set <toolchain>` - Set toolchain override for current directory
- `rustup override unset` - Remove override for current directory

### Information Commands
- `rustup show` - Show current toolchain information
- `rustup which <command>` - Show which binary will be run
- `rustup doc` - Open local Rust documentation

### Utility Commands
- `rustup run <toolchain> <command>` - Run command with specific toolchain
- `rustup help` - Show help information


---

