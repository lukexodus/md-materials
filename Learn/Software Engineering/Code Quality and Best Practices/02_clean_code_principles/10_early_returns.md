## Early returns


Early returns, also known as "returning early," involve exiting a function as soon as the result is known or a condition is met, rather than waiting until the end of the function. This practice linearizes the control flow and prevents deeply nested conditional structures, often referred to as "Arrow Code."

**Key Points**

- **Reduced Indentation:** Deep nesting forces the reader to track the stack of conditions mentally. Early returns keep the code aligned to the left, making it easier to scan vertically.
    
- **Happy Path Prominence:** By handling edge cases and exiting early, the primary logic (the "happy path") remains at the main indentation level, emphasizing the function's core purpose.
    
- **Simplification of Logic:** It removes the need for complex `else` blocks. Once a return statement is executed, the subsequent code is implicitly the `else` case, but without the syntactic overhead.
    
- **State Management:** Returning early often avoids the need for temporary variables (like `isValid` flags) that persist throughout the function scope.
    

**Example**

_Bad Practice (Arrow Code)_

Python

```
def process_payment(order):
    if order is not None:
        if order.is_active:
            if order.has_items:
                if order.payment_method == 'credit_card':
                    # Core Logic here
                    return "Processed"
                else:
                    return "Invalid Payment Method"
            else:
                return "No items"
        else:
            return "Inactive order"
    else:
        return "No order"
```

_Good Practice_

Python

```
def process_payment(order):
    if order is None:
        return "No order"
    
    if not order.is_active:
        return "Inactive order"
        
    if not order.has_items:
        return "No items"
        
    if order.payment_method != 'credit_card':
        return "Invalid Payment Method"

    # Core Logic is now flat and obvious
    return "Processed"
```

