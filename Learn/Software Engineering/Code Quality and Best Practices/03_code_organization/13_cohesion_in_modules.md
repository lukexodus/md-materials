## Cohesion in Modules


Cohesion refers to the degree to which the elements inside a module belong together. It is a measure of the strength of the relationship between the class's methods and data themselves. In software design, high cohesion is the goal, as it implies that a module focuses on a single task or concept, making it robust, reliable, and reusable. Cohesion is often inversely correlated with coupling; high cohesion usually leads to low coupling.

**Key Points**

- **Single Responsibility Principle (SRP):** Cohesion is closely related to SRP. A highly cohesive module should have only one reason to change.
    
- **Maintainability:** Changes in a highly cohesive module are less likely to impact unrelated parts of the system.
    
- **Reusability:** Modules that perform a single, well-defined task are easier to reuse in different contexts than modules that perform multiple unrelated operations.
    

**Levels of Cohesion (Ordered from Lowest/Worst to Highest/Best)**

1. **Coincidental Cohesion:** Parts of a module are grouped arbitrarily; the only relationship between them is that they are in the same file. (e.g., a `Utilities` class containing `calculate_tax` and `resize_image`).
    
2. **Logical Cohesion:** Parts are grouped because they categorize the same way logically, even if they are different by nature (e.g., a module grouping all input handling routines for mouse, keyboard, and network).
    
3. **Temporal Cohesion:** Parts are grouped by when they are processed (e.g., an initialization routine that opens a database connection, reads a config file, and initializes a variable, solely because these happen at startup).
    
4. **Procedural Cohesion:** Parts are grouped because they always follow a certain sequence of execution (e.g., a function that checks permissions and then opens a file).
    
5. **Communicational Cohesion:** Parts are grouped because they operate on the same data (e.g., a module that reads data from a sensor, logs it, and calculates an average).
    
6. **Sequential Cohesion:** The output of one part serves as the input for another part within the same module (e.g., a function that formats data and then validates the formatted string).
    
7. **Functional Cohesion:** All elements of a module contribute to the execution of a single, well-defined task. This is the ideal state.
    

**Example**

- Low Cohesion (Coincidental/Logical):
    
    A class that handles unrelated tasks creates a "God Object."
    
    Python
    
    ```
    class SystemManager:
        def send_email(self, msg): ...
        def query_database(self, query): ...
        def calculate_pi(self, digits): ...
        def render_gui(self): ...
    ```
    
- High Cohesion (Functional):
    
    Modules are broken down by specific domain or function.
    
    Python
    
    ```
    class EmailService:
        """Responsible solely for email operations."""
        def send_email(self, msg): ...
    
    class DatabaseConnector:
        """Responsible solely for database interactions."""
        def query(self, query): ...
    
    class MathUtils:
        """Responsible solely for mathematical calculations."""
        def calculate_pi(self, digits): ...
    ```


---

