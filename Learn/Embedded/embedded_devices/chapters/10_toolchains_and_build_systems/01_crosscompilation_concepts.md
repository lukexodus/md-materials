## Cross-Compilation Concepts

### Overview

Cross-compilation is the process of building an executable on one machine (the **host**) intended to run on a different machine (the **target**) — nearly universal in embedded development, since microcontrollers and small embedded processors typically lack the resources, OS, or tooling to run a compiler themselves. This content covers the general mechanics applicable across C, C++, and Rust embedded toolchains, tying together concepts already touched on individually in prior content (linker scripts, `#![no_std]`, the `thumbv7em-none-eabihf` target string seen in the Rust FFI content) into a coherent picture of what actually happens when a build is "cross-compiled."

### Host, Target, and (Sometimes) Build Machine

The GNU toolchain convention distinguishes three roles, though only two are typically distinct in ordinary embedded work:

- **Build machine**: the machine the compiler is actually built/compiled on.
- **Host machine**: the machine the compiler *runs* on (i.e., where you invoke `gcc` or `cargo build`).
- **Target machine**: the machine the *output binary* is intended to run on.

For the overwhelming majority of embedded workflows, build and host are the same machine (a developer's x86_64 Linux/macOS/Windows workstation), and only the target differs — this is the ordinary "cross-compilation" case. A distinct build machine matters primarily when *building the cross-compiler itself* (e.g., a Canadian Cross build, producing a cross-compiler on one machine that will itself run on a second machine to target a third) — **[Inference]** a scenario embedded application developers rarely need to construct themselves, since toolchain vendors and projects like `arm-none-eabi-gcc` or Rust's target support already distribute pre-built cross-compilers for common host/target combinations.

### The Target Triple (or Quadruple)

Cross-compilation toolchains identify a target using a structured string, conventionally `<arch>-<vendor>-<os>-<abi>` (the "target triple," though it often has four components in practice).

Examples relevant to embedded work:

- `arm-none-eabi` — ARM architecture, no vendor specified, no OS (`none`, i.e., bare-metal), embedded ABI (EABI). This is the standard bare-metal ARM Cortex-M/Cortex-R cross-compiler target string, used by the `arm-none-eabi-gcc` toolchain referenced throughout the linker-script and compiler-flags content.
- `thumbv7em-none-eabihf` — the Rust target string seen in the prior FFI content: `thumbv7em` (Thumb-2 instruction set for ARMv7E-M cores, e.g., Cortex-M4), `none` (no OS), `eabihf` (embedded ABI, hardware floating point — meaning FPU instructions are used directly rather than software-emulated, connecting back to the `-mfloat-abi=hard` flag discussed in the compiler-optimization-flags content).
- `riscv32imac-unknown-none-elf` — a RISC-V bare-metal target, illustrating that the same triple structure generalizes across instruction set architectures, not just ARM.
- `x86_64-unknown-linux-gnu` — a *non*-embedded example included for contrast: the ordinary "native compile for a Linux desktop/server" target, useful as a reference point for how much the triple's components change once an OS and a full ABI are present versus the bare-metal `none` targets above.

**[Inference]** The `none` OS component specifically signals "no operating system assumptions" to the toolchain and standard library — this is the deeper reason `#![no_std]` (from the Rust content) is required for bare-metal targets: the `std` library's implementation is written assuming OS services (heap allocator, threads, file I/O) that a `*-none-*` target triple explicitly does not provide, so `std` simply cannot be built for such a target at all, making `#![no_std]` not a stylistic choice but a hard requirement matching the target triple's `none` designation.

### What Changes When Cross-Compiling: Beyond Just the Instruction Set

Cross-compilation is not only about generating a different CPU instruction encoding — several other dimensions change simultaneously, each a potential source of subtle bugs if not handled correctly:

- **Instruction set and ABI**: the obvious dimension — generating ARM Thumb-2 instructions instead of x86_64 instructions, following the target's calling convention (register usage for arguments/return values, stack alignment requirements) rather than the host's.
- **Data type sizes and alignment**: as discussed extensively in the portable-C content, `int`, pointer width, and struct padding/alignment rules are target-dependent — code that behaves one way when compiled *natively* for testing on an x86_64 host (where `int` is 32-bit, pointers are 64-bit) can behave differently once cross-compiled for a target where these differ (many embedded targets have 32-bit pointers; some 8-bit legacy targets have 16-bit `int`).
- **Endianness**: as discussed in the portable-C content, byte order is architecture-defined; a host and target with differing endianness (uncommon between a typical x86_64 host and ARM target, since both are commonly little-endian, but a real concern for some embedded architectures) requires explicit handling of any data serialized on one and interpreted on the other.
- **Standard library availability and behavior**: a bare-metal `none` target, as noted above, generally has no full standard library at all (`#![no_std]` in Rust; a minimal or absent C standard library implementation, discussed further below) — code that compiles and runs correctly natively on a hosted development machine may simply fail to link, or link against a drastically reduced-functionality library, once cross-compiled.
- **Floating-point support**: whether the target has a hardware FPU (and which floating-point ABI it uses, `eabihf` vs. `eabi` in the ARM examples above) changes both code generation and calling-convention details for any function taking or returning floating-point values — a mismatch here (linking `eabihf`-compiled and `eabi`-compiled object files together) is a known source of the "compiles and links but hard-faults on the target" class of bug already flagged in the compiler-optimization-flags content.

### C Standard Library Implementations for Bare-Metal Targets

Unlike Rust's explicit `#![no_std]`/`std` split, C's situation is less formally delineated but functionally similar: a bare-metal C project generally cannot use a full "hosted" C standard library implementation (glibc, a desktop-oriented libc) because it assumes OS support (system calls for file I/O, memory-mapped heap growth via `brk`/`mmap`) that doesn't exist on the target.

- **Newlib** (and its embedded-oriented variant, **newlib-nano**): the most common C standard library implementation bundled with `arm-none-eabi-gcc` and similar embedded toolchains, designed to have its OS-dependent portions (`_sbrk`, `_write`, `_read`, and similar low-level "syscall stub" functions) implemented or stubbed by the application/board-support code rather than assuming a real OS underneath.
- **Newlib-nano**: a size-optimized variant of Newlib, commonly used specifically for its substantially smaller flash footprint (particularly in `printf`/`scanf`-family functions, whose full-featured implementations are large) at the cost of some functionality (e.g., reduced floating-point format support in `printf` by default, configurable).
- Application code must supply the "syscall stubs" Newlib expects — `_sbrk` (heap growth, typically implemented to hand out memory from a fixed linker-script-defined heap region, connecting directly to the heap placement discussed in the linker-scripts content), `_write` (commonly redirected to a UART or semihosting channel so `printf` produces visible output during development).
- **[Inference]** This stub-implementation requirement is a direct, practical consequence of cross-compiling for a `none`-OS target: the standard library's *interface* (the function signatures application code calls, like `malloc` or `printf`) remains available, but its *implementation* of the OS-dependent portions must be supplied by the embedded project itself, since no real OS exists underneath to service those calls — closely paralleling why Rust's bare-metal targets need an explicit panic handler and, if heap use is wanted, an explicit global allocator, as discussed in the prior Rust content.

### Sysroot and Cross-Compiled Header/Library Isolation

A **sysroot** is a directory tree mimicking a target system's root filesystem layout (`/usr/include`, `/usr/lib`, etc.) but containing headers and pre-built libraries for the *target*, not the host — the mechanism that prevents a cross-compiler from accidentally picking up the host machine's headers or libraries (which are for the wrong architecture entirely and would produce a broken or non-functional binary if linked in).

**[Inference]** This isolation is a persistent source of confusing build errors when cross-compilation toolchains and build systems are misconfigured — a build that seems to compile successfully but produces a binary that faults immediately on the target hardware is frequently traceable to accidental host-header or host-library contamination (e.g., a `#include` resolving to a host system header rather than the intended target/vendor SDK header) rather than a logic error in the application code itself, making sysroot/include-path configuration one of the first things worth auditing when a cross-compiled binary's behavior doesn't match expectations despite a clean build.

### Emulation and Testing Without Physical Hardware

Since a cross-compiled binary cannot run natively on the host, verifying its behavior before (or without) real hardware requires either an emulator or a full instruction-set simulator:

- **QEMU**: widely used for emulating various embedded ARM (and other architecture) targets, allowing a cross-compiled binary to actually execute on the host machine under emulation — useful for early bring-up testing, CI pipelines without physical hardware access, and debugging logic that doesn't depend on exact peripheral timing/behavior the emulator may not model precisely.
- **Vendor-specific simulators**: some microcontroller vendors provide instruction-accurate or peripheral-accurate simulators for their specific parts, generally offering closer fidelity to real hardware behavior for that specific chip than a general-purpose emulator, at the cost of being vendor/part-specific rather than broadly applicable.
- **[Inference]** Neither emulation nor simulation is a full substitute for testing on actual physical hardware for embedded work specifically because timing-sensitive behavior (interrupt latency, exact peripheral register timing, power-related edge cases) is frequently not modeled with full fidelity by either — emulation/simulation is best understood as a complement that catches logic errors earlier and more cheaply, not a replacement for hardware-in-the-loop validation before release, particularly for real-time or safety-critical code paths.

### Semihosting: A Debug-Time Bridge to the Host

Semihosting is a mechanism (commonly ARM-defined, implemented via a debug probe connection) allowing embedded code running on real target hardware to make what look like system calls (`printf`-style output, file I/O) that are actually intercepted by the debugger/probe and serviced by the *host* machine — a practical bridge for development-time diagnostics on hardware with no other easy output mechanism (no UART wired up yet, for instance).

**[Inference]** Semihosting is generally unsuitable for production/release firmware specifically because each semihosting call halts the target CPU and hands control to the debug probe, introducing timing behavior entirely dependent on the debug connection being present and responsive — a semihosting call executed with no debugger attached typically hangs the target waiting for a response that will never come, making it a debug-build-only mechanism analogous in spirit to why `-O0` debug builds (from the compiler-optimization-flags content) are unrepresentative of shipped release-build timing.

### Native Unit Testing vs. Target/Emulated Testing: A Layered Strategy

**[Inference]** A common and practical embedded testing strategy layers three tiers, each catching different bug classes at different cost:

1. **Native (host-compiled) unit tests**: business logic, algorithms, and data structures with no direct hardware dependency are compiled *natively* for the host (not cross-compiled) and tested with ordinary host-based unit testing tools — fast to run, easy to debug with full host tooling, but cannot catch cross-compilation-specific issues (type-size differences, endianness, ABI mismatches) since the code never actually runs as the target architecture during this tier.
2. **Emulated/simulated testing**: the actual cross-compiled target binary, run under QEMU or a vendor simulator — catches cross-compilation-specific logic issues (the type-size/endianness/ABI class of bug from the "what changes" section above) without requiring physical hardware access, at the fidelity limitations already noted.
3. **Hardware-in-the-loop testing**: the actual cross-compiled binary running on real target silicon — the only tier that validates true peripheral timing, interrupt latency, and hardware-specific edge cases, and therefore generally required before release regardless of how much confidence the first two tiers provide.

This layered structure exists specifically because relying solely on tier 1 (natively-compiled tests) systematically misses the entire class of cross-compilation-introduced bugs discussed throughout this content, while relying solely on tier 3 (hardware-only testing) is typically far slower and less convenient for iterative development — the layering is a pragmatic tradeoff between test speed/convenience and fidelity to actual shipped behavior.

### Cross-Compilation Build Flow

===MERMAID_DIAGRAM===

flowchart TD

A["Source code\n(C / C++ / Rust)"] --> B["Cross-compiler\ninvoked on host\n(e.g. arm-none-eabi-gcc,\nrustc --target ...)"]

B --> C["Target-specific headers/\nlibraries from sysroot\n(NOT host headers)"]

C --> D["Object files:\ntarget instruction set,\ntarget ABI, target type sizes"]

D --> E["Linker + linker script\n(memory map, section placement)"]

E --> F["Target binary\n(.elf / .bin / .hex)"]

F --> G{"Verification tier"}

G -->|"Tier 1"| H["Native unit tests\n(host-compiled, no cross-compile)"]

G -->|"Tier 2"| I["QEMU / vendor simulator\n(runs actual cross-compiled binary)"]

G -->|"Tier 3"| J["Physical hardware\n(hardware-in-the-loop)"]

**Related Topics**

- Newlib/newlib-nano syscall stub implementation (`_sbrk`, `_write`) for a specific board
- QEMU embedded target emulation setup and its fidelity limitations per peripheral
- Sysroot and include-path configuration troubleshooting in cross-compilation build systems
- Target triple selection and Rust's `rustup target add` workflow for embedded targets
- Semihosting configuration via debug probes (OpenOCD, J-Link) for development-time diagnostics
- Hardware-in-the-loop (HIL) test automation frameworks for embedded CI pipelines
- Floating-point ABI (`eabi` vs `eabihf`) mismatches and their link-time/runtime symptoms