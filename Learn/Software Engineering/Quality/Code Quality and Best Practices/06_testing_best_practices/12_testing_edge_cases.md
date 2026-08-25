## Testing edge cases


Definition and Scope

Edge cases refer to scenarios that occur at the extreme operating parameters of a software component. Unlike "happy path" testing, which validates standard user behaviors, edge case testing focuses on boundary conditions, unexpected inputs, and system limits. In high-quality codebases, handling these cases is critical for preventing crash loops, data corruption, and security vulnerabilities like buffer overflows or injection attacks. A robust system must behave deterministically even when inputs deviate from the norm.

**Categories of Edge Cases**

- **Boundary Values:** Inputs at the exact upper and lower limits of accepted ranges (e.g., intended index 0, index -1, index $n$, index $n+1$).
    
- **Data Type Mismatches:** Providing strings where integers are expected, or floating-point precision errors (e.g., $0.1 + 0.2 \neq 0.3$).
    
- **Empty and Null States:** Processing empty strings, null pointers, empty collections, or 0-byte files.
    
- **Resource Exhaustion:** Memory limits (StackOverflow), disk space saturation, or network timeout thresholds.
    
- **Concurrency Anomalies:** Race conditions occurring when two processes access a resource simultaneously at the exact moment of state change.
    
- **Formatting Extremes:** Extremely long strings, special characters, or non-ASCII (Unicode/Emoji) inputs in text fields.
    

**Identification Strategies**

- **Boundary Value Analysis (BVA):** Specifically targets input values at the edge of equivalence classes. If a valid range is 1 to 100, test cases should cover 0, 1, 100, and 101.
    
- **Equivalence Partitioning:** Divides input data into partitions of valid and invalid data. You assume behavior is consistent within a partition, so you focus testing efforts on the edges where partitions meet.
    
- **Error Guessing:** Relies on developer intuition to predict where specific implementations might fail (e.g., division by zero logic).
    

Example: Pagination Logic

Consider a function designed to paginate a list of items. Common errors occur when the requested page is negative, zero, or exceeds the total page count.

_Bad Implementation (Vulnerable to Edge Cases):_

Python

```
def get_page(items, page_number, page_size):
    # Fails if page_number is 0 or negative
    # Fails if page_number > total_pages (returns empty list but might confuse UI)
    start_index = (page_number - 1) * page_size
    end_index = start_index + page_size
    return items[start_index:end_index]
```

_Robust Implementation (Handling Edge Cases):_

Python

```
def get_page(items, page_number, page_size):
    if not items:
        return []
    
    if page_size <= 0:
        raise ValueError("Page size must be at least 1")
        
    # Edge Case: Negative or Zero page request
    if page_number < 1:
        page_number = 1
        
    total_items = len(items)
    start_index = (page_number - 1) * page_size
    
    # Edge Case: Requesting a page beyond available data
    if start_index >= total_items:
        return []
        
    # Edge Case: Last page is not full size
    end_index = min(start_index + page_size, total_items)
    
    return items[start_index:end_index]
```

**Testing Checklist**

1. **Zero/Null:** Input is 0, 0.0, or null/None.
    
2. **Max/Min:** Input is `MAX_INT`, `MIN_INT`, or exceeds buffer size.
    
3. **Collection Size:** List is empty, has exactly one item, or has `MAX_ITEMS`.
    
4. **Ordering:** Input is unsorted when sorted is expected, or reverse sorted.
    
5. **Temporal:** Dates affecting leap years, end of month, or Unix epoch rollover.
    

Impact on System Stability

Proper edge case handling transforms a fragile application into a resilient one. It ensures that the system fails gracefully—returning a meaningful error message or a default safe state—rather than terminating unexpectedly. This directly correlates to Code Quality metrics such as reliability, maintainability, and security compliance.

---

