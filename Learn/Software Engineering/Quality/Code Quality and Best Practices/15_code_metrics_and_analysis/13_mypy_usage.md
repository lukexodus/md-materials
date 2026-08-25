## MyPy Usage


### Strict Configuration and Enforcing Standards

Adopting MyPy in an enterprise environment requires moving beyond default settings to enforce rigorous type safety. The baseline for high-quality codebases should be the `--strict` mode, which aggregates several restrictive flags. However, granular control is often necessary for legacy migration.

**Critical Configuration Flags (pyproject.toml):**

Ini, TOML

```
[tool.mypy]
python_version = "3.12"
strict = true
warn_return_any = true
warn_unused_configs = true
disallow_untyped_defs = true
disallow_incomplete_defs = true
check_untyped_defs = true
disallow_untyped_decorators = true
no_implicit_optional = true
warn_redundant_casts = true
warn_unused_ignores = true
show_error_codes = true

# Module-specific overrides for legacy code
[[tool.mypy.overrides]]
module = "legacy_module.*"
ignore_missing_imports = true
disallow_untyped_defs = false
```

**Architectural Enforcement:**

- **Explicit `Any` Prohibition:** The usage of `Any` defeats the purpose of static analysis. If dynamic typing is unavoidable, prefer `object` (if operations are restricted) or rigorous runtime validation narrowing. Configure `disallow_any_generics` and `disallow_any_unimported` to prevent silent propagation of `Any` from untyped libraries.
    
- **Error Codes:** Never use a blanket `# type: ignore`. Always append the specific error code (e.g., `# type: ignore[attr-defined]`) to ensure that legitimate, unrelated errors are not suppressed during refactoring or library updates.
    

### Advanced Type System Features

Structural Subtyping with Protocols:

Standard inheritance (nominal subtyping) couples code tightly. Use typing.Protocol to define interfaces based on behavior rather than lineage, enabling dependency inversion and easier mocking in tests.

Python

```
from typing import Protocol, runtime_checkable

@runtime_checkable
class DataPersister(Protocol):
    def save(self, data: dict[str, str]) -> int: ...

class PostgresClient:
    def save(self, data: dict[str, str]) -> int:
        # Implementation details
        return 1

def process_transaction(db: DataPersister, payload: dict[str, str]) -> None:
    db.save(payload)
```

Generics and Variance:

Correctly handling covariance and contravariance is essential for library design.

- **Covariant (`TypeVar('T', covariant=True)`):** Useful for read-only containers. If `Dog` is a subclass of `Animal`, `List[Dog]` is a subtype of `List[Animal]`.
    
- **Contravariant (`TypeVar('T', contravariant=True)`):** Critical for callables. A function expecting an `Animal` can accept a `Dog` input (depending on the context of execution and argument consumption).
    

TypedDict for Structured Dictionaries:

When interacting with JSON APIs where class serialization overhead is undesirable, use TypedDict to enforce schema on dictionary literals.

Python

```
from typing import TypedDict, NotRequired

class APIResponse(TypedDict):
    status: int
    payload: dict[str, str]
    error_message: NotRequired[str]  # Python 3.11+
```

### Performance and CI Integration

Daemon Mode (dmypy):

For large codebases, the startup time of MyPy is prohibitive. Utilizing dmypy maintains a persistent daemon that caches the program state, significantly reducing latency for iterative checks during development.

Incremental Checking and Caching:

Ensure the .mypy_cache directory is preserved between CI runs (e.g., via GitHub Actions cache or GitLab CI artifacts). Cold starts on large repositories can throttle CI throughput.

Pre-commit Hooks:

Shift validation left by enforcing type checks at the commit stage. However, restrict pre-commit hooks to changed files only (files: \.py$) to avoid blocking workflow on full-repository scans, which should be reserved for the CI pipeline.

### Handling Third-Party Libraries and Stubs

Missing Imports Strategy:

The flag --ignore-missing-imports is a dangerous global default. It silences errors for all untyped libraries. Instead:

1. **Install Stubs:** Check `types-requests`, `types-pyyaml`, etc.
    
2. **Generate Stubs:** Use `stubgen` to create initial stub files for untyped dependencies.
    
3. **Module-Level Ignore:** Apply ignores strictly in the configuration file for specific libraries that lack type support, never globally.
    

Runtime vs. Type Checking Guards:

To prevent circular imports caused strictly by type annotations, use typing.TYPE_CHECKING. This block is executed only by static analyzers, not at runtime.

Python

```
from typing import TYPE_CHECKING

if TYPE_CHECKING:
    from .complex_service import Service  # Avoids runtime circular import

def handler(service: "Service") -> None: # String forward reference required
    ...
```

### Anti-Patterns in Static Typing

1. **The `Optional` Trap:** Relying on implicit optional (assigning `None` to a non-Optional type) is deprecated. Always use `X | None` (Python 3.10+) or `Optional[X]`.
    
2. **Overusing `cast`:** `typing.cast` forces the type checker to accept a value, essentially disabling verification. It should be a measure of last resort. Prefer type guards (`TypeGuard`) or `isinstance` checks which narrow types safely at runtime and analysis time.
    
3. **Mutable Default Arguments:** While Python allows this, MyPy often flags it depending on configuration. Even if permitted, the type signature `def foo(x: list = [])` is fundamentally flawed. Use `def foo(x: list | None = None)` and initialize inside the function.
    

Related Topics: Advanced Python Type Hinting, CI/CD Pipeline Optimization, Refactoring Legacy Codebases, Python Design Patterns.

---

