## Guard Clauses


Guard clauses add conditional logic to patterns, allowing patterns to match only when both the structural pattern and the boolean condition are satisfied. They provide fine-grained control over when a pattern should match without requiring nested conditional statements.

**Key Points:**

- Combines pattern matching with boolean predicates
- Evaluates after the pattern structure matches successfully
- Enables multiple patterns for the same type with different conditions
- Maintains pattern matching exhaustiveness checking
- Short-circuits evaluation when guards fail, moving to the next pattern
- Can reference variables bound by the pattern

Guards are evaluated in order, and the first matching pattern with a true guard is selected. This allows ordering patterns from most specific to most general, with guards handling the specific conditions.

**Example:**

```haskell
-- Haskell-style guards
factorial :: Int -> Int
factorial n
  | n < 0     = error "Negative input"
  | n == 0    = 1
  | n == 1    = 1
  | otherwise = n * factorial (n - 1)

classify :: Int -> String
classify x
  | x < 0            = "negative"
  | x == 0           = "zero"
  | x > 0 && x < 10  = "small positive"
  | x >= 10 && x < 100 = "medium positive"
  | otherwise        = "large positive"
```

**Example:**

```scala
// Scala-style guards in pattern matching
def processTransaction(amount: Double, accountBalance: Double): String = 
  (amount, accountBalance) match {
    case (a, _) if a <= 0 => 
      "Invalid transaction amount"
    case (a, b) if a > b => 
      "Insufficient funds"
    case (a, b) if a > b * 0.5 => 
      s"Large transaction: withdrawing $$${a} from $$${b}"
    case (a, b) => 
      s"Processing withdrawal of $$${a} from $$${b}"
  }

def categorizeTemperature(temp: Double, unit: String): String = 
  (temp, unit) match {
    case (t, "C") if t < 0 => "Freezing"
    case (t, "C") if t < 15 => "Cold"
    case (t, "C") if t < 25 => "Moderate"
    case (t, "C") if t >= 25 => "Hot"
    case (t, "F") if t < 32 => "Freezing"
    case (t, "F") if t < 59 => "Cold"
    case (t, "F") if t < 77 => "Moderate"
    case (t, "F") if t >= 77 => "Hot"
    case _ => "Unknown unit"
  }
```

**Output:**

```
processTransaction(100.0, 150.0)    // "Large transaction: withdrawing $100.0 from $150.0"
processTransaction(100.0, 50.0)     // "Insufficient funds"
categorizeTemperature(30.0, "C")    // "Hot"
categorizeTemperature(45.0, "F")    // "Cold"
```

Guards can access all variables bound in the pattern, allowing complex conditions that depend on the destructured values. This eliminates the need to extract values, then check conditions in separate if statements.

**Example:**

```scala
case class Order(items: List[String], total: Double, isPriority: Boolean)

def processOrder(order: Order): String = order match {
  case Order(items, total, true) if total > 1000 && items.length > 5 =>
    "Priority bulk order - expedite shipping"
  
  case Order(items, total, true) if total > 1000 =>
    "Priority high-value order"
  
  case Order(items, _, true) if items.length > 10 =>
    "Priority order with many items"
  
  case Order(_, total, _) if total > 5000 =>
    "High-value order - requires approval"
  
  case Order(items, _, _) if items.length > 20 =>
    "Bulk order - check inventory"
  
  case Order(_, total, _) if total < 10 =>
    "Small order - combine with others if possible"
  
  case _ =>
    "Standard order processing"
}
```

The combination of pattern matching and guards creates a declarative style where complex business logic is expressed as a series of conditions rather than nested control structures. Each case represents a complete decision rule, making the logic easier to understand and modify.

