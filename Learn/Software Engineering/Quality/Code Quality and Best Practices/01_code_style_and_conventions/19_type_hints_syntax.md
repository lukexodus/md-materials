## Type Hints Syntax


Type hinting explicitly declares the expected data types of variables, function arguments, and return values. While the runtime does not enforce them, they are critical for static analysis tools (mypy, pyright), IDE autocompletion, and code maintainability.

**Key Points**

- **Modern Syntax (Python 3.10+):** Prefer native types (`list`, `dict`) and the pipe operator (`|`) over imported types from the `typing` module where possible.
    
- **Variable Annotation:** define the type immediately after the variable name using a colon.
    
- **Function Signatures:** Annotate all parameters and the return type (`->`).
    
- **Special Forms:** Use `Optional`, `Any`, `NoReturn`, and `Final` to express semantic intent clearly.
    

Primitive and Collection Types

Standard primitive types (int, str, bool, float) are used directly. For collections in modern Python, use standard classes as generics.

Python

```
# Modern Syntax (Python 3.9+)
name: str = "Alice"
age: int = 30
scores: list[int] = [10, 20, 30]
user_map: dict[str, int] = {"Alice": 30}
coordinates: tuple[int, int] = (10, 20)

# Legacy Syntax (Pre-3.9, requires 'typing')
from typing import List, Dict, Tuple
scores: List[int] = [10, 20]
```

Unions and Optionals

Express that a value can be one of multiple types.

Python

```
# Modern Syntax (Python 3.10+)
identifier: int | str = 12345
optional_value: str | None = None

# Legacy Syntax
from typing import Union, Optional
identifier: Union[int, str] = 12345
optional_value: Optional[str] = None
```

Callables

Use Callable to annotate functions passed as arguments.

Python

```
from collections.abc import Callable

# Syntax: Callable[[ParamType1, ParamType2], ReturnType]
def execute_operation(op: Callable[[int, int], int], x: int, y: int) -> int:
    return op(x, y)
```

TypeVars and Generics

Use TypeVar for generic functions where the return type depends on the input type.

Python

```
from typing import TypeVar, Sequence

T = TypeVar("T")

def first_element(items: Sequence[T]) -> T:
    return items[0]
```

**Advanced Type Hints**

- **Final:** Indicates a variable should not be reassigned.
    
- **Literal:** Restricts a value to specific literals (useful for config modes).
    
- **TypedDict:** Defines dictionaries with specific keys and value types.
    
- **Protocol:** Defines structural subtyping (duck typing) requirements.
    

Python

```
from typing import Final, Literal, TypedDict, Protocol

MAX_RETRIES: Final[int] = 3

mode: Literal["read", "write"] = "read"

class UserConfig(TypedDict):
    host: str
    port: int

class renderable(Protocol):
    def render(self) -> str: ...
```

