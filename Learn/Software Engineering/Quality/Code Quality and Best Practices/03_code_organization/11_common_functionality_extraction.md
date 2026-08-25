## Common functionality extraction


Common functionality extraction is the refactoring process of identifying repeated logic across the codebase and moving it into reusable units (functions, classes, modules, or services). This is the practical application of the DRY (Don't Repeat Yourself) principle.

**Key Points**

- **DRY (Don't Repeat Yourself):** Every piece of knowledge or logic must have a single, unambiguous representation within the system. Duplication leads to maintenance nightmares where a bug fix in one instance is missed in the copy.
    
- **The Rule of Three:** A heuristic for avoiding premature abstraction.
    
    - 1st time: Write the code.
        
    - 2nd time: Copy the code (allowable WET - Write Everything Twice).
        
    - 3rd time: Refactor and extract into a common function.
        
        Premature extraction can lead to "abstraction indirection," where generic functions become overly complex with conditionals to handle slightly different use cases.
        
- **Pure Functions vs. Contextual Logic:**
    
    - **Utils/Helpers:** Extract pure functions (stateless, deterministic) into utility modules. These handle generic tasks like string formatting, date manipulation, or math calculations.
        
    - **Shared Services:** Extract stateful or business-heavy logic into services or base classes.
        
- **De-coupling:** Extracted code should be loosely coupled. A utility function should not depend on the global state of the application or specific UI frameworks unless explicitly designed for that layer.
    

**Risks of Poor Extraction**

- **The "Utils" Drawer:** Creating a massive `Utils.java` or `helpers.js` file that becomes a dumping ground for unrelated logic. This creates low cohesion. Instead, categorize extractions: `DateUtils`, `ValidationHelpers`, `MathLibrary`.
    
- **God Objects:** Extracting too much shared state into a Base Controller or Base Class, creating a monolithic dependency that is hard to test and modify.
    

**Example**

_Redundant Logic (WET):_

Python

```
# In UserProfile.py
def format_user_date(user):
    return user.created_at.strftime('%Y-%m-%d')

# In OrderHistory.py
def format_order_date(order):
    return order.purchase_date.strftime('%Y-%m-%d')

# If the business requirement changes to DD/MM/YYYY, we must edit two files.
```

_Extracted Logic (DRY):_

Python

```
# utils/date_formatter.py
DEFAULT_DATE_FORMAT = '%Y-%m-%d'

def format_standard_date(date_obj):
    if not date_obj:
        return ''
    return date_obj.strftime(DEFAULT_DATE_FORMAT)

# In UserProfile.py
from utils.date_formatter import format_standard_date
print(format_standard_date(user.created_at))

# In OrderHistory.py
print(format_standard_date(order.purchase_date))
```

---

