## Modules and Visibility


### Module Declaration and Organization

Rust uses the `mod` keyword to declare modules, which serve as namespaces for organizing code. Modules can be defined inline within a file or as separate files in the filesystem.

```rust
// Inline module declaration
mod network {
    fn connect() {
        println!("Connecting to network...");
    }
}

// File-based module (network.rs or network/mod.rs)
mod network;
```

### Module Hierarchy Structure

Modules form a tree structure starting from the crate root (`main.rs` for binaries, `lib.rs` for libraries). Child modules can contain their own submodules, creating nested namespaces.

```rust
// src/lib.rs
mod front_of_house {
    mod hosting {
        fn add_to_waitlist() {}
        fn seat_at_table() {}
    }
    
    mod serving {
        fn take_order() {}
        fn serve_order() {}
    }
}
```

### File System Module Organization

Rust provides two conventions for organizing modules in the filesystem:

```
src/
├── lib.rs
├── front_of_house.rs
└── front_of_house/
    ├── hosting.rs
    └── serving.rs
```

The module tree mirrors the filesystem structure, with `mod.rs` files serving as module roots for directories.

### Privacy and Visibility Rules

By default, all items in Rust are private to their parent module. This includes functions, structs, enums, constants, and nested modules. Privacy boundaries exist at module boundaries, not at file boundaries.

```rust
mod front_of_house {
    fn private_function() {} // Private by default
    
    mod hosting {
        fn add_to_waitlist() {} // Private to hosting module
    }
}

// This would cause a compilation error
// front_of_house::hosting::add_to_waitlist();
```

### Public Visibility with pub

The `pub` keyword makes items public, allowing them to be accessed from outside their defining module.

```rust
mod front_of_house {
    pub mod hosting {
        pub fn add_to_waitlist() {
            println!("Adding to waitlist");
        }
        
        fn private_helper() {} // Still private
    }
}

// Now this works
front_of_house::hosting::add_to_waitlist();
```

### Granular Visibility Modifiers

Rust provides several visibility modifiers for fine-grained access control:

#### pub(crate) - Crate Visibility

Makes items visible throughout the current crate but not to external crates.

```rust
mod utils {
    pub(crate) fn internal_helper() {
        // Visible anywhere in this crate
    }
}
```

#### pub(super) - Parent Module Visibility

Makes items visible to the parent module only.

```rust
mod parent {
    mod child {
        pub(super) fn call_from_parent() {
            // Only parent module can call this
        }
    }
    
    fn test() {
        child::call_from_parent(); // This works
    }
}
```

#### pub(in path) - Restricted Path Visibility

Makes items visible only within a specific module path.

```rust
mod a {
    mod b {
        mod c {
            pub(in crate::a) fn restricted_function() {
                // Only visible within module 'a'
            }
        }
    }
}
```

### Struct and Enum Visibility

Struct fields and enum variants have their own visibility rules:

```rust
mod back_of_house {
    pub struct Breakfast {
        pub toast: String,      // Public field
        seasonal_fruit: String, // Private field
    }
    
    impl Breakfast {
        pub fn summer(toast: &str) -> Breakfast {
            Breakfast {
                toast: String::from(toast),
                seasonal_fruit: String::from("peaches"),
            }
        }
    }
    
    pub enum Appetizer {
        Soup,  // Public by default when enum is pub
        Salad,
    }
}
```

### Re-exporting with pub use

The `pub use` statement allows re-exporting items from other modules, creating convenient public APIs.

```rust
mod front_of_house {
    pub mod hosting {
        pub fn add_to_waitlist() {}
    }
}

// Re-export for convenience
pub use crate::front_of_house::hosting;

// Now external users can call:
// my_crate::hosting::add_to_waitlist();
// Instead of:
// my_crate::front_of_house::hosting::add_to_waitlist();
```

### Creating Module Facades

`pub use` enables creating clean public APIs by selectively re-exporting items:

```rust
mod internal {
    pub mod complex_module {
        pub fn useful_function() {}
        pub fn another_function() {}
    }
    
    pub mod helpers {
        pub fn utility_function() {}
    }
}

// Create a clean public API
pub use internal::complex_module::useful_function;
pub use internal::helpers::utility_function;

// Hide the internal organization from users
```

### External Crate Dependencies

External crates are declared in `Cargo.toml` and brought into scope using `use` statements or the `extern crate` keyword (in older Rust editions).

```toml
# Cargo.toml
[dependencies]
serde = "1.0"
tokio = { version = "1.0", features = ["full"] }
```

```rust
// Modern approach (Rust 2018+)
use serde::{Serialize, Deserialize};
use tokio::net::TcpListener;

// Older approach (still valid)
extern crate serde;
use serde::{Serialize, Deserialize};
```

### Crate Root and Prelude

The crate root (`lib.rs` or `main.rs`) defines the public API of your crate. Items not marked as `pub` remain internal implementation details.

```rust
// lib.rs
mod internal_module;

pub mod public_api {
    pub use crate::internal_module::PublicStruct;
    pub use crate::internal_module::public_function;
}

// Users can only access items through public_api
```

### Workspace and Multi-Crate Projects

In workspace projects, each crate maintains its own module system. Crates can depend on each other through `Cargo.toml` dependencies.

```toml
# Workspace Cargo.toml
[workspace]
members = ["crate_a", "crate_b"]

# crate_a/Cargo.toml
[dependencies]
crate_b = { path = "../crate_b" }
```

### Use Statements and Imports

The `use` keyword brings items into scope, reducing the need for fully qualified paths:

```rust
use std::collections::HashMap;
use std::io::{self, Write}; // Importing multiple items
use std::fmt::Result as FmtResult; // Aliasing to avoid conflicts

// Glob imports (use sparingly)
use std::collections::*;
```

### Module Testing Organization

Test modules follow special visibility rules and are typically organized using the `#[cfg(test)]` attribute:

```rust
#[cfg(test)]
mod tests {
    use super::*; // Import items from parent module
    
    #[test]
    fn test_private_function() {
        // Can access private items in the same module
        private_function();
    }
}
```

**Key points**: Modules provide namespace organization and privacy boundaries in Rust. The `pub` keyword and its variants offer granular control over item visibility. Re-exporting with `pub use` creates clean public APIs. External dependencies are managed through Cargo.toml and brought into scope with `use` statements. Understanding module organization is crucial for building maintainable Rust applications and libraries.

**Example**: A typical library structure might re-export key functionality while hiding implementation details, use `pub(crate)` for internal utilities, and organize code into logical modules that mirror the problem domain rather than technical implementation.

**Related topics**: Understanding Rust's module system pairs well with learning about traits and generics for API design, error handling patterns across module boundaries, and cargo workspace management for larger projects.

---

