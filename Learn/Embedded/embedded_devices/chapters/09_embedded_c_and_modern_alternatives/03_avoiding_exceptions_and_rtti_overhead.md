## Avoiding Exceptions and RTTI Overhead

### Overview

Disabling C++ exception handling and Run-Time Type Information (RTTI) is one of the most common and highest-impact embedded C++ build decisions, typically implemented via `-fno-exceptions -fno-rtti` at the compiler level. Both features impose costs that are substantially less predictable and less bounded than the rest of the language, which conflicts directly with the flash-footprint constraints and deterministic-timing requirements common to bare-metal and real-time embedded work. This content builds on the general C++-for-embedded and zero-cost-abstraction material already covered, focusing specifically on the mechanics of why these two features cost what they cost, and the practical patterns used to do without them.

### Why Exceptions Are Expensive on Embedded Targets

#### Flash Footprint Cost

Exception handling in the common `zero-cost exceptions` implementation model (used by GCC and Clang on most targets, including ARM) does not add per-call runtime overhead for the non-throwing path — but it does add substantial static data: unwind tables (`.eh_frame`, `.gcc_except_table` or equivalent) describing, for every function that could be part of a throw's stack-unwinding path, how to unwind that stack frame and which destructors to run.

- **[Inference]** This static table data scales with the number of functions in the call graph that participate in exception-aware code, not with whether exceptions are actually thrown at runtime — meaning flash cost is paid even in builds where no exception is ever thrown in practice, which is the specific concern for flash-constrained microcontrollers.
- The runtime support library needed to walk these tables and perform unwinding (commonly `libgcc`'s unwinder, or an equivalent) itself occupies flash space once linked in, even if referenced by only a single `throw` statement anywhere in the program.

#### Non-Deterministic Timing on the Throwing Path

Even under the zero-cost model, the actual unwinding process when an exception *is* thrown involves walking the call stack frame-by-frame, consulting unwind tables, and running destructors along the way — the cost is proportional to call-stack depth and the number of objects requiring destruction, not a small fixed cost.

**[Inference]** For hard real-time systems where every code path must have an analyzable worst-case execution time (WCET), an exception-throwing path whose cost depends on dynamic call depth is generally difficult or impossible to bound tightly, which is a primary reason real-time and safety-critical guideline documents (in the spirit of AUTOSAR C++14, MISRA-adjacent guidance) commonly restrict or prohibit exception use rather than only being concerned with static flash cost.

#### Memory Allocation During Exception Handling

Some exception scenarios (notably, `std::bad_alloc` thrown by a failed allocation itself) can require the exception-handling runtime to perform its own dynamic allocation for exception object storage, depending on the implementation and the size/type of the exception object — introducing a dynamic-allocation dependency into what is nominally an error-handling path, which is exactly the kind of hidden-cost surprise flagged as a general C++ concern in the zero-cost-abstraction discussion.

### What `-fno-exceptions` Actually Does



```
arm-none-eabi-g++ -fno-exceptions -fno-unwind-tables -c file.cpp
```

- Removes generation of `.eh_frame`/unwind-table data, recovering the associated flash footprint.
- Causes any `try`/`catch`/`throw` construct encountered in source to be a **compile error**, not a silently ignored no-op — this is a build-time enforcement mechanism, not merely an optimization hint.
- Standard library facilities that would normally `throw` on error (e.g., `std::vector::at()`'s out-of-range access, `std::string` allocation failure) instead typically call `std::terminate()` (which itself typically calls `abort()`) rather than throwing, depending on the specific standard library implementation in use.
- `-fno-unwind-tables` is commonly paired alongside `-fno-exceptions` to ensure unwind-table generation is fully suppressed, since the two flags address closely related but not strictly identical code-generation behavior depending on toolchain version.

**[Inference]** Enabling `-fno-exceptions` on an existing codebase that assumes exceptions are available (including much of the standard library's error-reporting design) is a significant behavioral change, not a purely cosmetic build flag — every call site that previously relied on catching an exception for error handling needs an alternative error-propagation mechanism, which is why this is generally treated as an early, project-wide architectural decision rather than something toggled casually mid-project.

### Alternative Error-Handling Patterns Without Exceptions

#### Return Codes / Status Enums

The most direct replacement, analogous to conventional C error handling, with `enum class` (from the general embedded-C++ content) providing type safety over a plain `int` return code.

```cpp
enum class SensorError : uint8_t {
    Ok,
    NotResponding,
    ChecksumFailed,
    OutOfRange
};

SensorError read_temperature(float &out_value) {
    if (!sensor_present()) {
        return SensorError::NotResponding;
    }
    out_value = perform_reading();
    return SensorError::Ok;
}
```

#### std::optional (C++17)

Communicates "may not have a value" without an exception and without a separate out-parameter, for cases where the failure carries no additional error detail worth propagating.

```cpp
#include <optional>

std::optional<uint16_t> read_adc_safe(uint8_t channel) {
    if (channel >= NUM_ADC_CHANNELS) {
        return std::nullopt;
    }
    return read_adc_channel(channel);
}

if (auto val = read_adc_safe(3)) {
    process_reading(*val);
}
```

`std::optional` **[Inference]** is generally implementable without heap allocation (the value or its absence is typically stored inline within the `optional` object itself), making it compatible with the no-dynamic-allocation constraints common in embedded C++ — this should be confirmed against the specific standard library implementation in use rather than assumed universally, since the standard specifies behavior, not the exact storage strategy in every corner case.

#### std::expected (C++23) or Equivalent Result Types

Where the toolchain supports C++23, `std::expected<T, E>` carries either a success value or an error value in a single return type, giving richer error information than `std::optional` without exceptions. **[Unverified]** Embedded toolchain support for C++23 library features varies significantly by vendor and GCC/Clang version in use, so availability should be checked against the specific target toolchain rather than assumed; many embedded projects instead hand-roll a similar `Result<T, E>`-style template for portability across older toolchain versions.

#### Error Callback / Status Register Pattern

Common in interrupt-driven or hardware-abstraction-layer code: an operation sets a status flag or invokes a registered error callback rather than returning or throwing, particularly where the "failure" is detected asynchronously (e.g., a peripheral fault flag set by hardware, checked on a subsequent poll or via interrupt).

### Why RTTI Is Expensive on Embedded Targets

RTTI (`typeid`, `dynamic_cast`) requires the compiler to generate type-descriptor data for every polymorphic class (any class with at least one virtual function), and requires runtime support to walk class hierarchies and compare/match type descriptors during a `dynamic_cast`.

- Flash cost: type-descriptor tables for every polymorphic class, whether or not `dynamic_cast`/`typeid` is ever actually used on instances of that class elsewhere in the program.
- Runtime cost of `dynamic_cast`: potentially a hierarchy walk (not a fixed small cost) when casting across a non-trivial inheritance structure, particularly with multiple/virtual inheritance — timing that is again difficult to bound tightly for WCET analysis, the same concern raised for exceptions.
- `typeid` comparison cost is generally smaller and more bounded than `dynamic_cast`, but still requires the underlying type-descriptor data to exist in flash.

### What `-fno-rtti` Actually Does



```
arm-none-eabi-g++ -fno-rtti -c file.cpp
```

- Removes generation of type-descriptor data associated with polymorphic classes, recovering the associated flash footprint.
- Causes `dynamic_cast` (to anything other than `void*`, in some toolchain implementations) and `typeid` on polymorphic types to be a **compile error**.
- Does **not** disable virtual functions or virtual dispatch generally — a class can still have virtual functions and participate in ordinary (non-RTTI) polymorphic calls with `-fno-rtti` enabled; only the specific type-introspection facilities are removed.

### Alternatives to RTTI-Based Type Discrimination

#### static_cast When the Type Is Known by Design

If the calling code's design guarantees the concrete type (e.g., a factory function that only ever produces one specific derived type in a given context), `static_cast` performs the conversion with no runtime check and no type-descriptor dependency — at the cost of no safety net if the design assumption is ever violated, so this substitution is only appropriate when that guarantee genuinely holds.

```cpp
/* Only safe if the caller's design guarantees the actual
   object is a TemperatureSensor — no runtime verification occurs */
TemperatureSensor *sensor = static_cast<TemperatureSensor*>(base_ptr);
```

#### Manual Type Tagging

A simple, RTTI-free pattern: an explicit enum member identifying the concrete type, checked manually before a `static_cast`, giving back some of the safety `dynamic_cast` would have provided without requiring the RTTI runtime machinery.

```cpp
enum class SensorKind : uint8_t { Temperature, Pressure, Humidity };

class SensorBase {
public:
    explicit SensorBase(SensorKind kind) : kind_(kind) {}
    SensorKind kind() const { return kind_; }
private:
    SensorKind kind_;
};

class TemperatureSensor : public SensorBase {
public:
    TemperatureSensor() : SensorBase(SensorKind::Temperature) {}
};

/* Manual, RTTI-free type check before the cast */
if (base_ptr->kind() == SensorKind::Temperature) {
    auto *temp = static_cast<TemperatureSensor*>(base_ptr);
}
```

#### std::variant and std::visit (C++17)

Where the full set of possible concrete types is known and closed (not extensible at runtime via an open class hierarchy), `std::variant` provides type-safe discrimination without RTTI, using a tag stored inline rather than a polymorphic type-descriptor lookup.

```cpp
#include <variant>

struct TemperatureReading { float celsius; };
struct PressureReading { float kilopascals; };

using SensorReading = std::variant<TemperatureReading, PressureReading>;

void process(const SensorReading &reading) {
    std::visit([](auto &&r) {
        /* compile-time-resolved per alternative, no RTTI involved */
    }, reading);
}
```

**[Inference]** `std::variant` is generally preferable to a manually-tagged class hierarchy when the set of alternatives is genuinely fixed and small, since it avoids both RTTI and the per-object vtable-pointer overhead of a polymorphic base class — the tradeoff is that `std::variant`-based designs are less easily extended with a new alternative type without modifying the variant definition itself, unlike an open class hierarchy.

#### Templates / CRTP for Compile-Time-Known Types

As covered in the templates content, when the concrete type is genuinely known at compile time (the common embedded case for a fixed hardware target), templates or CRTP eliminate the need for any runtime type discrimination at all — this is generally the preferred first option before reaching for RTTI-free runtime-discrimination patterns, since it has no runtime cost whatsoever rather than a reduced-but-nonzero cost.

### Combined Flag Set Commonly Used Together



```
-fno-exceptions -fno-rtti -fno-unwind-tables -fno-threadsafe-statics
```

This combination (introduced individually in the general embedded-C++ content) is frequently applied as a single, coherent project-wide policy rather than flags chosen independently, since exceptions, RTTI, and unwind-table generation are closely related runtime-support facilities that are typically adopted or rejected together as part of one "freestanding-style" embedded C++ build configuration decision.

### Decision Summary Table

| Concern | Exceptions | RTTI |
| --- | --- | --- |
| Flash cost source | Unwind tables (`.eh_frame`) + runtime unwinder | Type-descriptor tables per polymorphic class |
| Cost paid even if unused at runtime | Yes (static table data) | Yes (static table data) |
| Timing predictability | Poor on throw path (stack-depth dependent) | Poor for `dynamic_cast` on deep/complex hierarchies |
| Disable flag | `-fno-exceptions` | `-fno-rtti` |
| Compile-time enforcement | `try`/`catch`/`throw` become errors | `dynamic_cast`/`typeid` become errors |
| Common replacement | Return codes, `enum class`, `std::optional`/`std::expected` | `static_cast` with design guarantee, manual tagging, `std::variant`, templates |

### Decision Flow for Exception/RTTI Policy

===MERMAID_DIAGRAM===

flowchart TD

A[New embedded C++ project] --> B{Hard real-time /\nWCET analysis required?}

B -->|Yes| C[-fno-exceptions -fno-rtti\nstrongly indicated]

B -->|No, but flash-constrained| D{Flash budget tight\nrelative to unwind/RTTI\ntable overhead?}

D -->|Yes| C

D -->|No, ample flash| E{Team/toolchain has\nestablished exception-based\nerror handling patterns?}

E -->|Yes, deliberate| F[Exceptions/RTTI enabled\nas explicit policy]

E -->|No strong reason either way| C

C --> G[Adopt return codes /\nstd::optional / std::variant\nas replacement patterns]

F --> H[Document policy;\nverify flash/timing budget\nregularly as codebase grows]

**Related Topics**

- WCET (Worst-Case Execution Time) analysis techniques for embedded real-time code
- `std::variant` and `std::visit` as an RTTI-free polymorphism alternative
- Standard library implementation differences (libstdc++ vs. libc++ vs. embedded-specific implementations) around exception-free error paths
- Building a custom `Result<T, E>` type for pre-C++23 toolchains
- AUTOSAR C++14 rules on exception and RTTI usage in automotive contexts
- Static analysis detection of accidental exception/RTTI reliance before enabling the disabling flags
- Interrupt service routine constraints on error-handling pattern choice