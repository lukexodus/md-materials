## Class Size and Complexity Metrics


### Weighted Methods per Class (WMC)

Raw line counts (LOC) are a poor proxy for complexity. WMC provides a superior measure by summing the Cyclomatic Complexity (CC) of all methods within a class.

- **Calculation:** $WMC = \sum_{i=1}^{n} CC_i$ where $n$ is the number of methods.
    
- **Thresholds:**
    
    - **WMC < 50:** Manageable and testable.
        
    - **WMC > 100:** Strong indicator of a "God Class" or "Blob" anti-pattern. The class likely violates the Single Responsibility Principle (SRP).
        
- **Implication:** A class with few high-complexity methods is as dangerous as a class with many low-complexity methods. High WMC directly correlates with defect density and maintenance effort.
    

### Lack of Cohesion in Methods (LCOM4)

LCOM4 measures the disparateness of methods within a class, identifying groups of methods that operate on disjoint sets of fields. It is the primary metric for identifying candidates for class splitting (Extract Class refactoring).

- **Logic:** Methods are nodes in a graph. An edge exists between methods if they access the same field or call each other. LCOM4 is the number of connected components in this graph.
    
- **Interpretation:**
    
    - **LCOM4 = 1:** The class is cohesive. All methods are related via state or behavior.
        
    - **LCOM4 > 1:** The class consists of two or more unrelated responsibilities. It should be split into $n$ separate classes, where $n$ is the LCOM4 score.
        
    - **LCOM4 = 0:** (Special case) Often indicates a class with no methods or a pure Data Transfer Object (DTO) with only getters/setters, which requires different architectural scrutiny.
        

### Response for a Class (RFC)

RFC measures the magnitude of the immediate testing surface. It is calculated as the number of methods in the class plus the number of distinct methods invoked by those methods (depth of 1).

- **Formula:** $RFC = |M \cup R|$ where $M$ is the set of methods in the class and $R$ is the set of remote methods called by $M$.
    
- **Testability Impact:** RFC is the strongest predictor of unit testing effort. An exponentially increasing RFC implies that mocking dependencies will become non-trivial, often leading to fragile, interaction-based tests rather than state-based tests.
    
- **Mitigation:** High RFC usually indicates tight coupling. It should be mitigated by introducing Facades or Mediators to reduce the number of direct dependencies.
    

### Coupling Between Object Classes (CBO)

CBO counts the number of other classes a specific class is coupled to (uses or is used by). Inheritance, interface implementation, method parameters, return types, and exceptions all contribute to coupling.

- **Stability Principle:** High CBO makes a class sensitive to changes in other parts of the system.
    
- **Efferent vs. Afferent:**
    
    - **Ce (Efferent Coupling):** Outgoing dependencies. High Ce indicates instability; the class breaks easily when dependencies change.
        
    - **Ca (Afferent Coupling):** Incoming dependencies. High Ca indicates responsibility; many other classes depend on this one.
        
- **Instability Metric ($I$):** $I = \frac{Ce}{Ce + Ca}$.
    
    - $I$ should approach 0 (maximally stable) for core domain entities.
        
    - $I$ should approach 1 (maximally instable) for leaf nodes like UI controllers or specific adapters.
        

### Cognitive Complexity

While not a strict "size" metric, Cognitive Complexity (developed by SonarSource) corrects the flaws of Cyclomatic Complexity by ignoring shorthand structures (like switch statements or multiple booleans in a single condition) that do not actually increase reading difficulty.

- **Usage:** It serves as a tie-breaker. If two classes have equal LOC and WMC, the one with higher Cognitive Complexity is the refactoring priority.
    
- **Nesting Penalty:** Heavily penalizes nesting (loops inside ifs inside loops), which disproportionately destroys readability compared to linear length.
    

### Refactoring Triggers

Metrics must trigger specific architectural interventions rather than vague warnings.

- **High WMC + High LCOM:** The class is complex and unfocused. **Action:** Break the class apart along the lines of the LCOM connected components.
    
- **High WMC + Low LCOM:** The class is complex but cohesive. **Action:** The class likely manages a complex state machine. Use the State Pattern or Strategy Pattern to delegate behavior while maintaining the cohesive data structure.
    
- **High CBO:** **Action:** Apply Dependency Inversion. Introduce interfaces to decouple implementation details.

---

