## Ownership and Memory Safety in Constrained Environments

### Overview

This content examines the ownership/borrowing model — introduced at a high level in the prior Rust-for-embedded-systems overview — in more mechanical depth, specifically as it operates under the additional pressures of embedded/constrained environments: no heap or a severely limited one, no OS-backed virtual memory to fault on invalid access, hard real-time deadlines, and interrupt-driven concurrency. The central question this content addresses is *how* the ownership model delivers memory safety guarantees mechanically, and where those guarantees do and do not extend once genuine hardware interaction and constrained resources enter the picture.

### The Three Rules of Ownership

Rust's ownership system rests on three rules enforced entirely at compile time by the borrow checker, with no runtime representation or cost for the rules themselves:

1. Each value has exactly one owner (a variable binding).
2. When the owner goes out of scope, the value is dropped (its destructor, if any, runs) — deterministically, at a compile-time-known point, not at an unpredictable garbage-collection cycle.
3. Ownership can be *moved* (transferred to a new owner, invalidating the old binding) or *borrowed* (temporarily referenced, without transferring ownership), but not simultaneously mutably borrowed from more than one place, nor mutably and immutably borrowed at the same time.

```rust
fn configure_sensor(config: SensorConfig) {
    // `config` is owned here
} // `config` dropped here, deterministically, at scope exit

let cfg = SensorConfig::new();
configure_sensor(cfg);
// `cfg` has been *moved* into configure_sensor; using `cfg` here
// again is a compile error, not a runtime use-after-free
```

**[Inference]** Rule 2 — deterministic drop at scope exit — is mechanically the same principle as C++ RAII, already discussed in the C++-for-embedded content, and delivers the same benefit for embedded resource management (hardware peripheral release, critical-section exit, buffer lifetime). What differs from C++ is rule 3: Rust's compiler *enforces* the aliasing discipline (no simultaneous mutable+immutable or multiple-mutable access) as a hard compile error, whereas C++ relies on programmer discipline to avoid the equivalent aliasing bugs (e.g., a dangling reference, or two objects both believing they exclusively own a hardware resource).

### Stack Allocation as the Default, and Why That Matters for Constrained Memory

Rust values are stack-allocated by default; heap allocation is opt-in and explicit (`Box`, `Vec`, `String`, all requiring the `alloc` crate under `#![no_std]`, as noted in the prior overview). This default has direct relevance to constrained-memory embedded targets:

```rust
// Entirely stack-allocated; no heap, no allocator required
struct SensorReading {
    temperature: f32,
    pressure: f32,
    timestamp: u32,
}

fn process_reading() -> SensorReading {
    SensorReading { temperature: 21.5, pressure: 101.3, timestamp: 1000 }
    // returned by value; Rust's move semantics avoid a deep copy
    // in most cases via compiler optimization (return value
    // optimization / guaranteed copy elision-like behavior),
    // though Rust does not give the same formal elision guarantee
    // C++17 provides for copy elision
}
```

**[Unverified]** The precise conditions under which Rust's compiler elides a move/copy on return (versus performing an actual memory copy) are implementation-detail-dependent rather than a language guarantee in the way C++17's mandatory copy elision is standardized — for size-sensitive or performance-sensitive embedded code, this is worth verifying against generated assembly rather than assumed, consistent with the "verify, don't assume zero-cost" principle raised in the C++ zero-cost-abstraction content.

Fixed-size stack allocation for known-size data (arrays, small structs) avoids the fragmentation and non-deterministic-timing concerns associated with heap allocation, discussed in both the MISRA C and C++-for-embedded content as reasons embedded/safety-critical code commonly avoids or restricts dynamic allocation — Rust's default posture aligns with that existing embedded practice rather than fighting against it, in contrast to `std`-first languages where heap allocation is the unremarkable default.

### Borrowing Rules and Aliasing: The Mechanism Behind Data-Race Prevention

The borrow checker's aliasing rule — at most one mutable reference, or any number of immutable references, but never both simultaneously to the same data — is the specific mechanism that prevents data races at compile time, without needing a runtime lock, atomic operation, or critical section for the *safety* guarantee itself (though a runtime synchronization primitive is still needed when genuine concurrent *access* — e.g., interrupt and main-line code both needing to touch shared state — is actually required, as noted in the prior overview).

```rust
let mut sensor_data: [u16; 8] = [0; 8];

let reader = &sensor_data;        // immutable borrow
// let writer = &mut sensor_data; // COMPILE ERROR: cannot borrow
                                    // as mutable while borrowed
                                    // as immutable
println!("{}", reader[0]);
```

**[Inference]** This rule set is what makes a specific, common embedded C/C++ bug class a compile-time error rather than a runtime hazard: an ISR and main-line code both holding raw pointers/references to the same buffer, with the main-line code reading it while the ISR concurrently writes it, producing a data race whose symptoms (torn reads, inconsistent state) are frequently intermittent and hardware/timing-dependent, and correspondingly difficult to reproduce and debug — the class of bug that `volatile`, discussed in the compiler-optimization-flags content, only partially addresses (ordering/elision, not atomicity or true synchronization).

### Where the Guarantee Ends: `unsafe` and Its Scope

Memory safety in Rust is a guarantee about *safe* Rust code specifically — code inside an `unsafe` block opts out of certain compiler-checked guarantees (raw pointer dereference validity, for one) in exchange for allowing operations the borrow checker cannot verify, as introduced in the prior overview's discussion of register access. It is important to be precise about exactly what `unsafe` does and does not disable:

- `unsafe` does **not** disable the borrow checker's ownership/move rules, or type checking generally — those still apply inside `unsafe` blocks.
- `unsafe` specifically permits: dereferencing raw pointers, calling `unsafe` functions (including FFI calls into C), mutable access to `static mut` variables, implementing `unsafe` traits, and accessing union fields.
- The programmer, not the compiler, becomes responsible for upholding the invariants the operation requires (e.g., that a raw pointer used in `read_volatile` genuinely points to valid, correctly-typed memory) — an incorrect `unsafe` block can reintroduce the exact memory-safety bugs (invalid access, aliasing violations) the rest of the language prevents.

```rust
static mut SHARED_COUNTER: u32 = 0;

fn interrupt_handler() {
    unsafe {
        // Accessing a mutable static requires unsafe: the compiler
        // cannot verify no data race occurs against other access
        // points to SHARED_COUNTER
        SHARED_COUNTER += 1;
    }
}
```

**[Inference]** This specific pattern — a `static mut` accessed from both an interrupt handler and main-line code — is exactly the situation where `unsafe` alone does *not* provide safety; it merely permits code the compiler cannot verify, and it remains the programmer's responsibility to ensure the access is actually safe (e.g., via a critical section, an atomic type, or a proper synchronization primitive). Idiomatic embedded Rust generally avoids raw `static mut` shared state in favor of safer wrapper types (a `Mutex`-like critical-section-protected cell, or an atomic type where the target supports lock-free atomics) specifically so the `unsafe` surface area stays minimal and concentrated, consistent with the layering principle discussed in the prior overview's PAC/HAL/`unsafe`-boundary content.

### Interior Mutability: Safely Mutating Through a Shared Reference

Rust's default aliasing rules (one mutable *or* many immutable references) are sometimes too restrictive for legitimate patterns — a global peripheral handle that multiple parts of the program need read/write access to, for instance. The "interior mutability" pattern provides controlled, safety-preserving ways to mutate data through what is nominally a shared/immutable reference, by moving the aliasing check from compile time to a runtime mechanism:

- `Cell<T>` / `RefCell<T>`: single-threaded interior mutability, with `RefCell` performing a runtime borrow-check (panicking on violation) rather than a compile-time one — **[Inference]** generally unsuitable for interrupt-handler-to-main-line-code sharing specifically because it is not designed to be safe across genuinely concurrent (interrupt-preemption) access, only against Rust's ordinary single-threaded aliasing concerns.
- Critical-section-protected wrapper types (common in embedded crates, e.g., patterns built around the `critical-section` crate or `cortex-m::interrupt::Mutex`): provide interior mutability whose safety specifically accounts for interrupt-context concurrent access, by requiring the caller to be inside a critical section (interrupts masked) to obtain mutable access.
- Atomic types (`core::sync::atomic::AtomicU32`, etc.): where the target architecture provides genuine atomic instructions, these allow lock-free shared mutable access safely, with the safety guarantee coming from the hardware's atomicity rather than a software-enforced critical section.

```rust
use critical_section::Mutex;
use core::cell::RefCell;

static SHARED_STATE: Mutex<RefCell<u32>> = Mutex::new(RefCell::new(0));

fn interrupt_handler() {
    critical_section::with(|cs| {
        let mut state = SHARED_STATE.borrow_ref_mut(cs);
        *state += 1;
    }); // critical section (and thus safe mutable access) ends here
}
```

This pattern gives the same net effect as a C/C++ critical-section-protected shared variable, but the *requirement* to be inside a critical section to obtain mutable access is enforced by the type system (the API simply does not offer a way to get mutable access without proving, via the `cs` token, that a critical section is active) rather than relying purely on programmer discipline to remember to disable interrupts before touching shared state.

### Integer Overflow Behavior: Debug vs. Release

A specific, easy-to-overlook detail relevant to the memory/behavioral-safety discussion: Rust's default integer overflow behavior differs between build profiles.

- **Debug builds**: integer overflow triggers a runtime panic (a controlled abort with an error message), by default.
- **Release builds** (the profile actually shipped to embedded targets): integer overflow **wraps** (two's-complement wraparound) silently by default, for performance reasons — the same behavior as unsigned integer overflow in C, and notably *not* a panic in the shipped build.

**[Inference]** This means the debug-build panic-on-overflow behavior — which could otherwise serve as a useful bug-catching mechanism during development — does *not* carry over to the release build actually deployed to hardware, unless explicitly configured via `overflow-checks = true` in the release profile (at a runtime cost for the added check, similar in spirit to the tradeoff of enabling any additional runtime check). This is a meaningful gap relative to the broader "compile-time safety" narrative around Rust: integer overflow is a runtime behavioral choice, not something the borrow checker or type system prevents at compile time in the way ownership violations are prevented, and the earlier MISRA C discussion of signed-overflow-as-undefined-behavior does not have a direct one-to-one Rust analogue — Rust defines wrapping behavior for release builds rather than leaving it undefined, which is a narrower but still real hazard class (a silently wrapped value can still be a logic bug, even though it is not undefined behavior in the C sense).

### No Stack Overflow Protection Without Hardware/OS Support

**[Inference]** The ownership model's guarantees are about *heap* and reference-aliasing safety; they do not, on their own, prevent stack overflow on a bare-metal target with no MMU-backed guard page — the same hazard already flagged in the linker-scripts content for C/C++ applies equally to Rust, since stack depth (particularly with recursive functions, or large stack-allocated arrays/structs, which Rust's stack-by-default posture can make easier to accidentally create) is not tracked or bounded by the borrow checker. Mitigations (explicit stack size reservation and, where the target/toolchain supports it, a stack-painting or watermarking technique to detect high-water-mark usage) remain necessary in Rust embedded projects for the same reasons they are necessary in C/C++ ones.

### Comparison: What Ownership Does and Does Not Guarantee in Constrained Environments

| Hazard class | Prevented by ownership/borrowing at compile time? |
| --- | --- |
| Use-after-free (heap or stack) | Yes, in safe code |
| Double-free | Yes, in safe code |
| Dangling references | Yes, in safe code (lifetime checking) |
| Data races (safe code, safe shared-state APIs) | Yes, via aliasing rules + required synchronization types |
| Buffer overrun (slice/array indexing) | Runtime-checked (panics), not compile-time eliminated in the general case |
| Integer overflow (release build, default) | No — wraps silently unless `overflow-checks` enabled |
| Stack overflow | No — requires separate stack-size reservation/monitoring |
| Logic errors / incorrect algorithm | No — outside the scope of any memory-safety mechanism |
| Invalid raw pointer access inside `unsafe` | No — `unsafe` code's correctness is the programmer's responsibility |

### Ownership Guarantee Boundary

===MERMAID_DIAGRAM===

flowchart TD

A[Rust code] --> B{Inside a\nsafe block?}

B -->|Yes| C[Borrow checker enforces:\nno UAF, no double-free,\nno aliasing violations,\nno data races]

B -->|No, unsafe block| D[Raw pointer deref,\nstatic mut access,\nFFI calls permitted]

D --> E{Programmer manually\nupholds invariants?}

E -->|Yes, correctly| F[Safety preserved,\nbut unverified by compiler]

E -->|No, or incorrectly| G[Memory safety violation\npossible: same bug classes\nas C/C++]

C --> H{Integer overflow\nin release build?}

H -->|overflow-checks off\ndefault| I[Silent wraparound,\nnot a compile-time-\nprevented hazard]

H -->|overflow-checks on| J[Runtime panic\nadded cost]

**Related Topics**

- Critical-section and atomic-type patterns for interrupt-safe shared state in Rust
- Stack usage analysis and overflow protection techniques for `#![no_std]` targets
- Lifetime annotations and borrow checker mechanics beyond the basic ownership rules
- Auditing `unsafe` blocks in PAC/HAL crates as a code-review discipline
- `overflow-checks` and other release-profile configuration tradeoffs
- Comparing Rust's compile-time guarantees against MISRA C/AUTOSAR C++14 static-analysis-based guarantees
- Formal verification and Rust (e.g., tools targeting a verified subset) for the highest safety-integrity contexts