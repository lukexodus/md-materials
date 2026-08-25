## Single Level of Abstraction (SLA)


The Single Level of Abstraction (SLA) principle, often popularized by Robert C. Martin (Uncle Bob) in _Clean Code_, dictates that all statements within a function should exist at the same level of conceptual granularity. A function should either manage high-level business logic or perform low-level implementation details, but never both simultaneously. Mixing levels of abstraction creates cognitive dissonance for the reader, forcing them to constantly switch contexts between "what the system does" and "how the system does it."

**Core Concepts**

- **The Step-Down Rule:** Code should read like a top-down narrative. High-level functions should call functions at the next immediate level of abstraction, descending step-by-step into implementation details.
    
- **Separation of Concerns:** High-level policy (orchestration) must be separated from low-level mechanism (I/O, parsing, bitwise operations).
    
- **Function Size:** Adhering to SLA naturally results in smaller, more focused functions that do one thing well.
    

**Violation Indicators**

- **Mixed Vocabularies:** A function contains both business domain terms (e.g., `calculateTax`, `approveOrder`) and technical terms (e.g., `json.parse`, `string.split`, `http.get`).
    
- **Deep Indentation:** Mixing abstractions often leads to nested control structures as the code attempts to handle detail-heavy logic inline.
    
- **Lengthy Functions:** Functions exceeding 20-30 lines often indicate that multiple levels of abstraction are being collapsed into one.
    

**Example**

Violating SLA:

This function mixes high-level workflow (validating and saving) with low-level details (parsing HTML, formatting strings).

Python

```
def process_user_input(input_str):
    # Low level parsing
    if "<" in input_str and ">" in input_str:
        clean_str = input_str.replace("<", "").replace(">", "")
    else:
        clean_str = input_str
    
    # High level logic
    if len(clean_str) > 5:
        # Low level database simulation
        print(f"Saving to DB: {clean_str.upper()}")
        return True
    return False
```

Adhering to SLA:

The process_user_input function now only handles the workflow (orchestration), delegating details to helper functions.

Python

```
def process_user_input(input_str):
    cleaned_input = sanitize_html(input_str)
    if is_valid_length(cleaned_input):
        save_to_database(cleaned_input)
        return True
    return False

def sanitize_html(raw_str):
    return raw_str.replace("<", "").replace(">", "")

def is_valid_length(s):
    return len(s) > 5

def save_to_database(s):
    print(f"Saving to DB: {s.upper()}")
```

**Benefits**

- **Readability:** Developers can scan high-level functions to understand the flow without getting bogged down in implementation syntax.
    
- **Refactorability:** Low-level functions can be changed or optimized without risking the integrity of the high-level logic.
    

