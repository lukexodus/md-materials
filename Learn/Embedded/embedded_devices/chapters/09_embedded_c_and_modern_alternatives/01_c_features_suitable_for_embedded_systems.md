## C++ Features Suitable for Embedded Systems


### Overview

Modern C++ (C++11 through C++23) offers substantial improvements over C for embedded development — stronger type safety, zero-cost abstractions, compile-time computation, and RAII-based resource management — but not every language feature is appropriate for resource-constrained, real-time, or safety-critical targets. The central discipline in embedded C++ is selecting a subset of the language that provides safety and expressiveness benefits without introducing hidden runtime costs, non-deterministic timing, or dynamic memory dependencies that bare-metal systems typically cannot afford. This subsetting discipline is formalized in guideline documents such as AUTOSAR C++14 (a safety-oriented restriction of C++14, analogous in spirit to MISRA C for C).

### Why "Embedded C++" Is a Curated Subset, Not the Full Language

**Key Points**

- Many C++ standard library facilities assume a hosted environment with dynamic memory, exceptions, and RTTI available and inexpensive — assumptions that frequently do not hold on bare-metal microcontrollers.
- Some features have cost that is hidden from the source code (implicit heap allocation, virtual dispatch overhead, exception unwinding tables occupying flash) — the "zero-cost abstraction" principle applies unevenly depending on which features are used and how.
- Real-time and safety-critical certification (DO-178C for avionics, ISO 26262 for automotive, IEC 62304 for medical) generally requires deterministic, analyzable timing and memory behavior, which rules out or heavily restricts several C++ features regardless of their general usefulness.
- **[Inference]** The practical embedded C++ subset therefore tends to favor compile-time mechanisms (templates, `constexpr`) over runtime polymorphism, and stack/static allocation over heap allocation, wherever both achieve the same design goal.

### Features Generally Well-Suited to Embedded Use

#### RAII (Resource Acquisition Is Initialization)

RAII ties resource lifetime to object scope via constructors/destructors, and is broadly considered one of C++'s strongest advantages for embedded reliability — it applies equally well to hardware resource management as to memory.

```cpp
class GpioPin {
public:
    explicit GpioPin(uint8_t pin) : pin_(pin) {
        enable_pin(pin_);
    }
    ~GpioPin() {
        disable_pin(pin_);
    }
private:
    uint8_t pin_;
};

void toggle_led() {
    GpioPin led(13);
    /* pin automatically disabled when led goes out of scope,
       even on early return */
}
```

This pattern extends naturally to peripheral clock enable/disable, mutex/critical-section guards, and DMA channel lifetime management, reducing a common class of embedded bugs (forgetting to release a resource on an error path).

#### constexpr and Compile-Time Computation

`constexpr` functions and variables are evaluated at compile time when their inputs are compile-time constants, moving computation out of the runtime path entirely — directly beneficial for both flash size (no runtime code generated for the computation) and execution speed.

```cpp
constexpr uint32_t compute_baud_divisor(uint32_t clock_hz, uint32_t baud) {
    return clock_hz / (16U * baud);
}

/* Evaluated entirely at compile time; no runtime division occurs */
constexpr uint32_t divisor = compute_baud_divisor(72000000U, 115200U);
```

`constexpr` is widely regarded as one of the highest-value modern C++ features for embedded work specifically because it eliminates runtime cost for genuinely compile-time-known values, replacing what would otherwise be preprocessor macros (with no type safety) or runtime computation.

#### Templates for Zero-Overhead Abstraction

Templates generate specialized code at compile time, avoiding the runtime dispatch cost of virtual functions when the exact type is known at compile time — commonly used in embedded contexts for peripheral drivers parameterized by register address or bit-width, where a single template definition generates efficient, type-specific code for each instantiation.

```cpp
template <uint32_t BaseAddr>
class GpioRegister {
public:
    static void set() {
        *reinterpret_cast<volatile uint32_t*>(BaseAddr) |= 1U;
    }
    static void clear() {
        *reinterpret_cast<volatile uint32_t*>(BaseAddr) &= ~1U;
    }
};

using LedGpio = GpioRegister<0x40020014>;
/* LedGpio::set() compiles to the same instructions as a hand-written
   direct register access — no runtime indirection */
```

**[Inference]** This pattern is frequently used to replace C-style register-access macros with type-safe equivalents that produce identical generated code, giving compile-time type checking without runtime cost — though it does increase compile time and can increase code size if many distinct template instantiations are generated for similar-but-not-identical types (template bloat), which is a real tradeoff to monitor via map-file inspection.

#### Strongly Typed Enums (enum class)

`enum class` prevents implicit conversion to integer and prevents unintended comparison between unrelated enum types, addressing a category of bugs that MISRA C's essential-type model also targets in C.

```cpp
enum class UartParity : uint8_t {
    None,
    Even,
    Odd
};
/* UartParity::Even cannot be implicitly compared to an unrelated
   enum or used as a bare integer without an explicit cast */
```

#### References for Parameter Passing

References provide non-null, non-reassignable aliasing with cleaner syntax than pointers for cases where a null value is never valid, communicating intent more precisely than a pointer parameter and eliminating a class of null-pointer-check omissions.

```cpp
void configure_uart(UartConfig &cfg) {
    cfg.baud_rate = 115200U;
    /* cfg is guaranteed non-null by the language, unlike a pointer */
}
```

#### `static_assert` for Compile-Time Verification

Performs compile-time checks with no runtime cost, commonly used in embedded contexts to verify struct sizes for register/protocol layout, alignment assumptions, or type-width assumptions at compile time rather than discovering a mismatch at runtime or during hardware bring-up.

```cpp
struct SensorPacket {
    uint8_t  header;
    uint16_t value;
    uint8_t  checksum;
};
static_assert(sizeof(SensorPacket) == 4, "Unexpected padding in SensorPacket");
```

#### Namespaces

Provide scoping with zero runtime cost, useful for organizing driver code and avoiding symbol collisions across a multi-vendor-library embedded project without any of the overhead concerns that apply to other features on this list.

#### `nullptr`

Type-safe null pointer constant, eliminating the ambiguity of `NULL`/`0` in overload resolution and template contexts — a straightforward safety improvement with no runtime cost.

### Features Requiring Caution or Restriction

#### Dynamic Memory Allocation (new/delete, containers that allocate)

**[Inference]** Heap allocation on embedded targets carries the same concerns as C's `malloc`/`free` (discussed in the MISRA C context: fragmentation over long uptime, non-deterministic allocation time, and difficult failure handling when memory is exhausted), and is commonly disallowed entirely in safety-critical embedded C++ projects, or restricted to a small number of allocations performed once at startup before real-time operation begins (avoiding allocation/deallocation churn during steady-state operation).

- Standard containers that allocate by default (`std::vector`, `std::string`, `std::map`) are frequently avoided or replaced with fixed-capacity equivalents (`std::array`, or a custom fixed-capacity vector-like container) for exactly this reason.
- Custom allocators or overloaded `operator new`/`operator delete` backed by a fixed memory pool are a common middle ground, allowing container-like APIs while keeping allocation bounded and deterministic — but this is a deliberate architectural choice, not a default-safe pattern.

#### Exceptions

Exception handling requires runtime support (typically unwind tables and a runtime library) that adds flash footprint even when exceptions are never thrown, and exception propagation timing is not generally bounded/deterministic in the way hard real-time systems require.

- Many embedded toolchains provide `-fno-exceptions` specifically to eliminate this overhead, and many embedded/safety-critical C++ style guides disallow exceptions outright, preferring error codes, `std::optional`/`std::expected` (where available), or explicit status-return patterns.
- **[Inference]** Where a codebase disables exceptions at the compiler level, any standard library facility that would throw on error (e.g., `std::vector::at()` on out-of-range access) instead typically calls `std::terminate` or an equivalent abort path — this needs to be an explicit, understood design decision rather than an incidental consequence of turning the flag on.

#### RTTI (Run-Time Type Information) — `dynamic_cast`, `typeid`

Adds flash footprint (type information tables) and runtime cost, frequently disabled via `-fno-rtti` on embedded toolchains alongside `-fno-exceptions`, for similar footprint and determinism reasons. `dynamic_cast`-based designs are generally replaceable with `static_cast` where the type is known by design, or with a variant/tagged-union pattern (`std::variant` with `std::visit`, where available and its overhead is acceptable) where genuine runtime type discrimination is needed.

#### Virtual Functions and Polymorphism

Not prohibited, but carry real costs worth weighing deliberately:

- Each polymorphic object carries a vtable pointer, increasing per-object size.
- Virtual dispatch is an indirect call, with a small but non-zero and less predictable timing cost compared to a direct or template-resolved call — relevant on cycle-budget-tight interrupt handlers, less relevant in non-time-critical application logic.
- Virtual functions can still be entirely appropriate for embedded designs that genuinely need runtime polymorphism (e.g., a hardware abstraction layer supporting multiple sensor variants selected at runtime rather than compile time) — the tradeoff is deliberate design choice vs. templates, not a blanket avoidance rule.
- **[Inference]** A common pattern is using templates/static polymorphism when the concrete type is known at compile time (the common embedded case — the target hardware doesn't change at runtime), reserving virtual dispatch for the genuinely runtime-variable cases.

#### Standard Library I/O Streams (`<iostream>`, `std::cout`)

`<iostream>`-based I/O pulls in substantial runtime library code and static initialization overhead, and is rarely appropriate for bare-metal firmware; most embedded C++ projects either avoid the iostream library entirely (using direct UART/peripheral output functions) or, if console-style output is wanted, provide a minimal custom formatted-output implementation rather than linking the full standard iostream library.

#### `std::function` and Type-Erased Callables

`std::function` commonly performs a heap allocation internally for captures beyond a small inline buffer (implementation-defined threshold), making it a hidden dynamic-allocation risk that isn't obvious from the call site — a callback mechanism that looks like a simple function pointer replacement can silently introduce heap use. **[Inference]** Function-pointer-based callbacks, or templated callable parameters resolved at compile time, are generally preferred in allocation-sensitive embedded code for this reason.

### Feature Suitability Summary

| Feature | Runtime Cost | Embedded Suitability | Notes |
| --- | --- | --- | --- |
| RAII | None (compile-time binding) | Well-suited | Extends naturally to hardware resource management |
| `constexpr` | None (if truly compile-time) | Well-suited | Reduces both flash size and runtime cost |
| Templates | None (generates specialized code) | Well-suited, monitor code size | Risk of instantiation bloat |
| `enum class` | None | Well-suited | Direct safety improvement over C enums |
| References | None | Well-suited | Non-null guarantee vs. pointers |
| `static_assert` | None (compile-time only) | Well-suited | Catches layout/size assumptions early |
| Dynamic allocation | High, non-deterministic | Restrict or avoid | Fragmentation, unbounded timing |
| Exceptions | Flash footprint + non-deterministic unwind | Usually disabled | `-fno-exceptions` common |
| RTTI | Flash footprint + runtime cost | Usually disabled | `-fno-rtti` common |
| Virtual functions | Small, bounded, per-call indirect cost | Deliberate choice | Fine when genuinely needed; templates preferred when type is static |
| `<iostream>` | High (library size + static init) | Avoid on bare-metal | Use direct peripheral I/O |
| `std::function` | Possible hidden heap allocation | Caution | Prefer function pointers/templates |

### Standard Library Containers: What Typically Works Well

Several standard library facilities are commonly used in embedded C++ specifically because they involve no dynamic allocation and no exceptions in their core usage:

```cpp
#include <array>
#include <cstdint>

/* std::array: fixed-size, stack/static allocated, no heap involvement */
std::array<uint16_t, 32> adc_samples{};

/* Provides bounds-checked .at() (throws — avoid if exceptions disabled)
   and unchecked operator[] (use this in exception-free builds) */
adc_samples[0] = read_adc_channel(0);
```

`std::array` is widely used as a direct, safer replacement for C-style fixed arrays (it carries its size, preventing a class of pointer-decay bugs), with effectively zero overhead versus a raw array. `std::optional` (C++17) and `std::span` (C++20) are similarly commonly adopted where the toolchain's C++ standard version supports them, since both are typically implementable without heap allocation and improve API expressiveness (optional return values, non-owning array views) over C-style sentinel values and separate pointer/length parameter pairs.

### Compiler Flags Commonly Paired with Embedded C++

Building on the optimization-flag discussion from compiler flags generally, embedded C++ builds typically add:

- `-fno-exceptions` — disables exception handling support, reducing flash footprint.
- `-fno-rtti` — disables RTTI, reducing flash footprint.
- `-fno-threadsafe-statics` — removes the (mutex-based) thread-safety guard around function-local `static` initialization, which is unnecessary overhead on typical single-core bare-metal targets without an RTOS providing real threading, though **[Inference]** this should be re-evaluated if the target does run an RTOS with genuine concurrent access to such statics.
- `-fno-unwind-tables` — further reduces flash footprint associated with stack unwinding metadata, generally paired with `-fno-exceptions`.

### AUTOSAR C++14 as a Safety-Oriented Subset

AUTOSAR C++14 (Automotive Open System Architecture) provides a MISRA-analogous rule set specifically for C++14 usage in automotive embedded systems, addressing many of the concerns above with formal, checkable rules — restricting or banning dynamic memory in certain contexts, restricting multiple inheritance, requiring explicit rules around implicit conversions, and similar. **[Unverified]** As with MISRA C, the specific rule numbering and text is part of a licensed standards document and is not reproduced here; projects adopting it should consult the current official publication and a compliant static analysis tool rather than a secondary summary.

### Practical Guidance for Adopting C++ in an Existing C Embedded Project

- Adopt `constexpr`, `enum class`, `static_assert`, references, and namespaces early — these have essentially no downside for embedded use and directly replace common C anti-patterns (macros for constants, weak enums, missing null checks).
- Introduce templates for register/peripheral abstraction incrementally, verifying via the `.map` file that generated code size and content match hand-written equivalents.
- Decide the exceptions/RTTI policy (`-fno-exceptions -fno-rtti` or not) as an explicit, project-wide, early architectural decision — retrofitting this decision onto a codebase that has grown to assume exceptions are available is significantly more disruptive than establishing it from the start.
- Treat dynamic allocation as opt-in per subsystem rather than a language default: prefer `std::array`/fixed-capacity containers, and if heap use is unavoidable for a subsystem, isolate it and consider a bounded custom allocator rather than the general-purpose heap.
- Where certification (DO-178C, ISO 26262, IEC 62304) is in scope, select the language subset per the relevant guideline document (e.g., AUTOSAR C++14) from the start of the project, since retrofitting compliance is considerably more expensive than designing for it from the outset.

### Embedded C++ Feature Decision Flow

===MERMAID_DIAGRAM===

flowchart TD

A[Candidate C++ feature] --> B{Cost known and\nbounded at compile time?}

B -->|Yes: constexpr, templates,\nenum class, RAII, references| C[Generally safe to adopt]

B -->|No, runtime-dependent| D{Does it require heap,\nexceptions, or RTTI?}

D -->|Heap allocation| E{Bounded/pool-based\nallocator used?}

E -->|Yes, deliberate design| F[Acceptable with isolation]

E -->|No, general heap| G[Avoid in real-time/\nsafety-critical paths]

D -->|Exceptions or RTTI| H{Project has explicitly\nenabled exceptions/RTTI?}

H -->|No -fno-exceptions/-fno-rtti| I[Do not use]

H -->|Yes, deliberate policy| J[Acceptable per policy]

D -->|Neither| K{Genuine runtime\npolymorphism needed?}

K -->|Yes| L[Virtual functions:\nacceptable, deliberate]

K -->|No, type known\nat compile time| M[Prefer templates\nover virtual dispatch]

**Related Topics**

- AUTOSAR C++14 rule categories and static analysis tooling
- Template metaprogramming for compile-time peripheral register abstraction
- Custom fixed-capacity containers and pool allocators for embedded C++
- RTOS integration considerations for C++ (task objects, thread-safe statics, ISR-context restrictions)
- `std::variant`/`std::visit` as a heap-free alternative to runtime polymorphism
- C++20/C++23 features (`std::span`, concepts, modules) and embedded toolchain support maturity
- Interoperability patterns between C++ application code and vendor C-based HAL/SDK code