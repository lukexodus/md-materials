## Language Interoperability with C

### Overview

Interoperability between Rust and C is a practical necessity for most embedded Rust adoption, since the overwhelming majority of existing vendor SDKs, RTOS kernels, and legacy embedded codebases are written in C, and few projects can or should attempt a full rewrite. Rust's Foreign Function Interface (FFI) is built around the `extern "C"` calling convention, allowing Rust to call C functions and, symmetrically, expose Rust functions callable from C — a bidirectional bridge that supports the incremental-adoption pattern flagged in the prior Rust overview, where a new Rust module is introduced into an existing C embedded codebase rather than replacing it wholesale.

### Why FFI Uses the C ABI Specifically

Rust does not define a stable Application Binary Interface (ABI) for its own native calling convention — the exact layout of structs, function-call register/stack conventions, and name mangling for ordinary Rust functions can change between compiler versions and even between compilations, since Rust reserves the right to optimize these details without an external compatibility promise. C's ABI, by contrast, has been stable for decades and is what essentially every embedded toolchain, linker, and existing library already targets. `extern "C"` tells the Rust compiler to generate code conforming to the platform's C calling convention specifically, making the resulting function callable from — or able to call into — genuine C code compiled by a separate C compiler.

**[Inference]** This is the same underlying reason C++ name mangling requires `extern "C"` blocks when interfacing with C libraries — Rust's situation is directly analogous, but the stakes are somewhat higher because Rust's *native* ABI is unstable by design (unlike C++, which does have a de facto stable-ish ABI per major compiler/platform, the Itanium C++ ABI being the common one on non-Windows targets), so `extern "C"` in Rust is not merely a mangling fix but the only genuinely portable way to define a cross-language-callable interface at all.

### Calling C Functions from Rust

```rust
// Declaring the signature of an existing C function
extern "C" {
    fn hal_gpio_write(pin: u8, value: u8) -> i32;
    fn hal_i2c_read(addr: u8, buf: *mut u8, len: usize) -> i32;
}

fn set_led(state: bool) {
    unsafe {
        // Calling any extern "C" function requires unsafe:
        // the compiler cannot verify the C implementation
        // upholds Rust's safety invariants
        hal_gpio_write(13, if state { 1 } else { 0 });
    }
}
```

Every call into an `extern "C"` function requires an `unsafe` block, consistent with the `unsafe`-boundary discipline discussed in the prior ownership/memory-safety content — the Rust compiler has no visibility into what the C implementation actually does, so it cannot verify the call upholds Rust's aliasing, lifetime, or validity invariants. This is a deliberate, structural reinforcement of the "concentrate `unsafe` at the FFI/HAL boundary" pattern: every point where Rust code crosses into C is explicitly marked, rather than being an invisible, unmarked risk.

### Exposing Rust Functions to C

The reverse direction — a C caller (existing RTOS code, a vendor bootloader, or a mixed-language build) invoking a Rust function — requires `#[no_mangle]` to suppress Rust's default name-mangling scheme, so the linker-visible symbol name matches what the C code's declaration expects.

```rust
#[no_mangle]
pub extern "C" fn rust_process_packet(data: *const u8, len: usize) -> i32 {
    if data.is_null() {
        return -1;
    }
    let slice = unsafe {
        // Reconstructing a safe Rust slice from a raw C pointer +
        // length pair requires unsafe: the compiler cannot verify
        // the pointer is valid or the length is accurate
        core::slice::from_raw_parts(data, len)
    };
    // process `slice` using ordinary safe Rust from this point on
    0
}
```

```c
/* Corresponding C-side declaration */
extern int32_t rust_process_packet(const uint8_t *data, size_t len);
```

**[Inference]** This pattern — a thin `unsafe` boundary function that immediately reconstructs a safe Rust type (a slice, in this case) from raw C-supplied pointer/length arguments, then delegates to ordinary safe Rust logic — is generally the preferred structure for Rust-from-C entry points specifically because it minimizes the amount of code operating outside the borrow checker's guarantees to the smallest possible surface (the pointer validity/length-correctness assumption at the single boundary call), consistent with the same unsafe-concentration principle raised for PAC/HAL crates in the prior overview.

### Struct Layout Compatibility: `#[repr(C)]`

Rust's default struct layout (`repr(Rust)`) is, like its calling convention, unspecified and subject to compiler-chosen reordering/optimization — a Rust struct's field order in memory is not guaranteed to match its declaration order. For a struct to be passed across the FFI boundary (as a pointer, or by value) and have a C-compatible, predictable memory layout, it must be annotated `#[repr(C)]`.

```rust
#[repr(C)]
pub struct SensorPacket {
    pub header: u8,
    pub value: u16,
    pub checksum: u8,
}
```

```c
/* Must match field order, types, and (implicitly) padding exactly */
typedef struct {
    uint8_t  header;
    uint16_t value;
    uint8_t  checksum;
} SensorPacket;
```

`#[repr(C)]` guarantees the same field ordering and padding/alignment rules a C compiler would apply for an equivalent struct on the target platform — directly analogous to the struct-padding portability concern already raised in both the portable-C content (implementation-defined padding) and the C++ `static_assert` pattern for verifying layout assumptions. **[Inference]** Verifying that a `#[repr(C)]` Rust struct's `size_of::<T>()` matches the corresponding C `sizeof(...)` — via a build-time or test-time assertion, Rust's `const` context supporting a `static_assert`-equivalent check — is good practice for the same reason the earlier C++ `static_assert` example verified `SensorPacket` layout: a silent mismatch here produces a binary that compiles and links but misinterprets memory at the FFI boundary.

### Naming and Type Mapping Considerations

- Rust's `bool` is guaranteed to be a single byte with only the bit patterns `0` and `1` valid — passing an arbitrary C `int`-as-boolean value directly into a Rust `bool` parameter without validation is undefined behavior if the value isn't exactly 0 or 1; using a C-compatible integer type (`u8`/`i32` matching the C side) and converting explicitly on the Rust side is the safer FFI pattern for boolean-like values.
- Rust has no direct native equivalent to C's `void*` for fully type-erased pointers in safe code, but `*mut c_void`/`*const c_void` (from `core::ffi`) map directly to it for FFI declaration purposes.
- Fixed-width integer types (`u8`, `u16`, `i32`, etc.) map directly and unambiguously to `<stdint.h>` equivalents (`uint8_t`, `uint16_t`, `int32_t`), which is one reason fixed-width types are effectively mandatory on both sides of an embedded FFI boundary — the same principle already emphasized for portable C in the MISRA C content applies with equal or greater force here, since an `int`-width mismatch across the FFI boundary is a direct ABI mismatch, not merely a portability concern.
- C `enum` and Rust `enum` are **not** layout-compatible by default — a C-compatible Rust enum intended to cross the FFI boundary generally needs `#[repr(C)]` or, for simple C-style enums, `#[repr(u8)]`/`#[repr(i32)]` (matching the C compiler's actual enum underlying-type choice, which is itself implementation-defined in C, echoing the general C portability concerns already discussed) to guarantee a compatible representation.

### Linking a Rust Static Library into a C/C++ Build

A common integration pattern for incremental adoption: build a Rust crate as a static library (`staticlib` crate type) and link it into an existing C/C++ embedded build system (Makefile, CMake, vendor IDE project) as an additional object/archive input, rather than restructuring the entire build around Cargo.

```toml
# Cargo.toml
[lib]
crate-type = ["staticlib"]
```



```
# Conceptual Makefile integration
rust_lib.a: src/lib.rs
	cargo build --release --target thumbv7em-none-eabihf
	cp target/thumbv7em-none-eabihf/release/librust_module.a rust_lib.a

firmware.elf: main.o rust_lib.a
	arm-none-eabi-gcc main.o -L. -lrust_module -T linker_script.ld -o firmware.elf
```

**[Inference]** This pattern keeps the existing C build system as the top-level orchestrator, treating the Rust crate as "just another library" from the linker's perspective — generally the lowest-friction adoption path for teams with substantial existing C build tooling and process investment, versus the alternative of migrating the entire project to a Cargo-centric build, which is a considerably larger undertaking and disruption to existing tooling, CI, and team familiarity.

### Panic Handling Across the FFI Boundary

A Rust panic unwinding (or aborting, depending on panic strategy) across an `extern "C"` boundary into C code is undefined behavior — C has no concept of Rust's panic/unwind mechanism, and the two are not designed to interoperate. This is a specific, easy-to-overlook FFI hazard distinct from the general panic-handler discussion in the prior overview.

- Embedded Rust projects (per the prior overview) commonly configure `panic = "abort"` in the build profile rather than the unwinding default, converting a panic into an immediate abort rather than an unwind attempt — **[Inference]** this sidesteps the undefined-behavior-across-FFI concern specifically because an abort terminates execution immediately rather than attempting to unwind through C stack frames that have no unwind-table information for the panic mechanism to consult.
- Where a panic must not propagate across an FFI boundary under any circumstance (e.g., a Rust module embedded in a C RTOS task that must not simply halt the entire system), `std::panic::catch_unwind` (or its `core`-compatible near-equivalent in `no_std` contexts, ecosystem-dependent) can contain a panic within the Rust side and convert it to an explicit error-code return before it reaches the FFI boundary — **[Unverified]** exact `no_std` support and behavior for panic-catching varies by target and Rust version, and should be verified against the current toolchain rather than assumed uniformly available.

### Header Generation: cbindgen

Manually keeping a C header declaration synchronized with the actual Rust function signatures and `#[repr(C)]` struct definitions is error-prone (a mismatch is a silent ABI hazard, not necessarily a build error, per the earlier discussion). The `cbindgen` tool automates this by parsing Rust source and generating a matching C/C++ header, keeping the two sides mechanically synchronized as the Rust side evolves rather than relying on manual header maintenance.

**[Inference]** Adopting `cbindgen` (or an equivalent generation step integrated into the build) is generally preferable to hand-maintained FFI headers for any FFI surface expected to change over the life of the project, since a hand-maintained header can silently drift out of sync with the actual Rust signatures with no compile-time or link-time error to catch the mismatch until a runtime symptom appears.

### Common FFI Pitfalls in Embedded Contexts

| Pitfall | Consequence | Mitigation |
| --- | --- | --- |
| Missing `#[repr(C)]` on a struct crossing the boundary | Undefined layout; silent memory misinterpretation | Always `#[repr(C)]` (or `#[repr(transparent)]` for single-field wrappers) on FFI-crossing types |
| Rust `enum` without explicit `repr` used as a C-compatible enum | Layout mismatch with C's enum representation | `#[repr(u8)]`/`#[repr(i32)]` matching the C side's actual underlying type |
| Panic unwinding across `extern "C"` | Undefined behavior | `panic = "abort"` in profile, and/or `catch_unwind` containment |
| Raw pointer/length pair passed without validation | Out-of-bounds access if C side supplies incorrect length | Validate at the boundary before `slice::from_raw_parts` |
| Assuming Rust's native calling convention is stable across compiler versions | Broken FFI after a toolchain upgrade | Always use `extern "C"`, never rely on `repr(Rust)` across a compiled-separately boundary |
| Header/signature drift between hand-maintained C header and actual Rust function | Silent ABI mismatch, hard-to-diagnose corruption | Generate the header via `cbindgen` rather than hand-maintaining it |

### Rust-C FFI Boundary Flow

===MERMAID_DIAGRAM===

flowchart TD

A["C code / existing SDK"] -->|"extern "C" call"| B["unsafe boundary\n(Rust side)"]

B --> C{"Validate pointer/\nlength arguments?"}

C -->|Yes| D["Reconstruct safe Rust\ntypes: slice::from_raw_parts,\nrepr(C) struct access"]

C -->|No, skipped| E["Undefined behavior risk\nif C side supplies\ninvalid data"]

D --> F["Ordinary safe Rust logic\n(borrow checker applies)"]

F --> G["Return via extern "C"\nsignature, repr(C) types"]

G --> A

H["Rust panic inside F"] -.->|"panic = 'abort'\nor catch_unwind"| I["Contained: does not\nunwind into C"]

**Related Topics**

- `cbindgen` configuration for automated C header generation from Rust
- `#[repr(C)]`, `#[repr(transparent)]`, and enum representation control in detail
- Build system integration patterns: Cargo-as-static-library within Makefile/CMake projects
- Panic strategy configuration (`abort` vs `unwind`) for embedded release profiles
- Bindgen (the reverse tool: generating Rust FFI declarations from existing C headers)
- Safety documentation conventions for `unsafe fn` boundaries in mixed-language codebases
- Cross-language debugging workflows for mixed Rust/C embedded binaries