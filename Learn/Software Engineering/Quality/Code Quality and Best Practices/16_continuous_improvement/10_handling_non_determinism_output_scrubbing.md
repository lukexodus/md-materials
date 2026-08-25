## Handling Non-Determinism & Output Scrubbing


The primary engineering challenge in characterization testing is non-deterministic output. Trivial changes in timestamps, memory addresses (pointers), or GUIDs will cause false positives in the diff comparison.

Scrubbing Strategies:

"Scrubbers" are regex-based processors that sanitize output before comparison.

- **Pattern:** `Scrubbers.scrub_guid(output)`
    
- **Implementation:** Replace dynamic values with static placeholders (e.g., replace `d34b-2321-...` with `<GUID>`).
    

**Code Example (Python-esque):**

Python

```
import re

def scrub_timestamp(text):
    # Regex to find ISO8601 timestamps and replace with fixed literal
    return re.sub(
        r'\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}', 
        '<TIMESTAMP>', 
        text
    )

def test_legacy_report_generation():
    result = legacy_system.generate_report()
    
    # Sanitize before comparison
    clean_result = scrub_timestamp(result)
    
    # Compare against saved master file
    verify(clean_result)
```

Architectural Constraint:

The scrubber logic must be deterministic itself. Avoid scrubbing mechanisms that introduce variable length replacements or rely on external state.

