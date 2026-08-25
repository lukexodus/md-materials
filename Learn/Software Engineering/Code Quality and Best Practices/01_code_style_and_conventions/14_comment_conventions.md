## Comment conventions


Comments are non-executable text annotations used to explain the code. High-quality comments explain the _why_ and the _context_, assuming the code itself explains the _how_.

**Key Points**

- **Self-Documenting Code:** The priority is to write code so clear (via naming and structure) that comments are unnecessary. Comments should not compensate for bad code.
    
- **The "Why" Rule:** Comments should explain business logic, complex algorithms, workarounds for bugs, or decisions that are not immediately obvious from reading the syntax.
    
- **Maintenance Burden:** Comments are artifacts that must be maintained. Outdated comments are worse than no comments as they actively mislead the developer.
    
- **Commented-Out Code:** Do not leave commented-out code in the codebase. Source control (Git) exists to track history; the main branch should contain only active code.
    

**Types of Comments**

1. **Documentation Comments (Docstrings/Javadoc):** Structured comments placed above functions/classes to describe their purpose, parameters, return values, and thrown exceptions. These are often parsed to generate external documentation.
    
2. **Inline Comments:** Brief notes on the same line as code, usually for variable definitions (use sparingly).
    
3. **Block Comments:** Multi-line descriptions for complex logic blocks.
    
4. **Annotation Tags:**
    
    - `TODO`: Pending tasks or features.
        
    - `FIXME`: Known bugs or broken code needing immediate attention.
        
    - `HACK`: Non-standard solution required for a specific constraint.
        

**Example**

_Bad Comment (Redundant):_

Python

```
i = i + 1  # Increment i
```

_Good Comment (Contextual):_

Python

```
# We add a random jitter here to prevent the thundering herd problem
# when all clients retry the connection simultaneously.
time.sleep(base_delay + random.uniform(0, 1))
```

_Docstring Example:_

Python

```
def calculate_velocity(distance, time):
    """
    Calculates velocity based on distance and time.

    Args:
        distance (float): The distance traveled in meters.
        time (float): The time taken in seconds.

    Returns:
        float: Velocity in meters/second.
    """
    return distance / time
```

---

