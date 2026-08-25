## Avoid Deep Nesting


Deeply nested code, often referred to as "Arrow Code" or the "Pyramid of Doom," significantly increases cyclomatic complexity and cognitive load. It forces the reader to maintain multiple mental contexts simultaneously, increasing the likelihood of bugs and making maintenance difficult.

**Key Points**

- **Guard Clauses:** Invert `if` statements to handle negative cases or edge cases immediately and return early. This flattens the main logic path.
    
- **Extraction:** Identify nested blocks that represent a distinct task and extract them into private helper methods. This provides semantic naming to the logic and reduces the indentation level of the parent method.
    
- **Polymorphism:** Replace complex `switch` statements or nested `if-else` chains based on type checking with polymorphic method dispatch.
    
- **Functional Constructs:** Utilize higher-order functions like `map`, `filter`, and `reduce` (or LINQ/Stream APIs) to process collections without explicit nested loops and conditionals.
    

**Example**

_Bad Practice (Deep Nesting):_

Java

```
public void processOrder(Order order) {
    if (order != null) {
        if (order.getItems() != null) {
            if (order.getItems().size() > 0) {
                for (Item item : order.getItems()) {
                    if (item.isInStock()) {
                        if (item.getPrice() > 0) {
                            shipItem(item);
                        }
                    }
                }
            }
        }
    }
}
```

_Refactored (Guard Clauses and Streams):_

Java

```
public void processOrder(Order order) {
    if (order == null || order.getItems() == null || order.getItems().isEmpty()) {
        return;
    }

    order.getItems().stream()
        .filter(Item::isInStock)
        .filter(item -> item.getPrice() > 0)
        .forEach(this::shipItem);
}
```

