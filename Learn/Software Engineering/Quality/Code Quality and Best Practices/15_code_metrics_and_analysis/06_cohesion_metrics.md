## Cohesion Metrics


Cohesion quantifies the functional relatedness of elements within a module (typically a class). In high-quality architecture, cohesion metrics serve as leading indicators for the Single Responsibility Principle (SRP). Low cohesion invariably predicts high maintenance costs, fragility, and difficult testability. While "High Cohesion" is a qualitative mantra, rigorous software engineering relies on quantitative measurements to drive refactoring decisions.

### The LCOM Family (Lack of Cohesion of Methods)

The Chidamber & Kemerer (C&K) metrics suite introduced LCOM, but its original definition has evolved into several variants (LCOM1 through LCOM5) to address mathematical anomalies and interpretability.

- LCOM4 (Connected Components approach):
    
    This is currently the most actionable variant for identifying "God Classes." LCOM4 treats methods as nodes in a graph. An edge exists between two methods if:
    
    1. They access the same instance field.
        
    2. One method calls the other.
        
    
    The metric counts the number of connected components in this graph.
    
    - **Value = 1:** The class is cohesive. All parts are related.
        
    - **Value > 1:** The class consists of disjoint sets of responsibilities. An LCOM4 of 2 implies the class can likely be split into two separate classes without breaking internal logic.
        
    - **Value = 0:** (Edge case) A class with no methods or only getters/setters.
        
- LCOM-HS (Henderson-Sellers):
    
    Unlike raw LCOM counts which are unbounded and difficult to compare across classes of different sizes, LCOM-HS is normalized between 0 and 1.
    
    $$LCOM_{HS} = \frac{M - \mu(A)}{1 - \mu(A)}$$
    
    Where $M$ is the number of methods and $\mu(A)$ is the average number of methods accessing each field.
    
    - **0.0:** Perfect cohesion (every method touches every field).
        
    - **1.0:** Total lack of cohesion (each method touches a unique subset of fields, or no fields).
        

### Connectivity Metrics: TCC and LCC

While LCOM measures the lack of cohesion, Bieman and Ott’s metrics measure the presence of connectivity via shared variable access. These are often more precise for determining _how_ coupled the internal methods are.

- TCC (Tight Class Cohesion):
    
    The relative number of directly connected method pairs. A pair of methods is "directly connected" if they access at least one common instance variable.
    
    $$TCC = \frac{NDC}{NP}$$
    
    Where $NDC$ is the Number of Direct Connections and $NP$ is the maximum possible number of pairs $[N \times (N-1) / 2]$.
    
    - _Threshold:_ TCC < 0.5 typically indicates a "Loose Class" that may be a collection of utility functions rather than an abstract data type.
        
- LCC (Loose Class Cohesion):
    
    Includes both direct and indirect connections (e.g., Method A calls Method B, which accesses Field X; Method C accesses Field X directly. A and C are indirectly connected).
    
    - _Interpretation:_ If TCC is low but LCC is high, the class uses call chains to maintain state consistency. If both are low, the class is likely an incoherent "blob."
        

### CAM (Cohesion Among Methods)

CAM is a metric derived from the "Bansiya and Davis" suite (QMOOD). It evaluates the "closeness" of methods based on parameter signatures, though modern adaptations focus on field usage intersection.

$$CAM = \frac{\sum_{i=1}^{M} |F_i|}{M \times |F_{total}|}$$

Where $|F_i|$ is the number of distinct parameter types (or fields) used by method $i$, and $|F_{total}|$ is the total distinct types/fields used by the class.

- **Application:** CAM is effective in detecting "Schizophrenic Classes" where distinct groups of methods operate on entirely different data types (e.g., a class mixing SQL formatting logic with UI rendering logic).
    

### Semantic Cohesion (Conceptual Cohesion)

Traditional metrics (LCOM, TCC) are structural—they rely on syntax (field access). They fail to detect poor cohesion in classes that share fields but perform semantically unrelated tasks (e.g., a "Manager" class uses a generic `ID` field for both User and Product lookups).

- C3 (Conceptual Cohesion of Classes):
    
    Utilizes Latent Semantic Indexing (LSI) or simple Vector Space Models on identifiers and comments.
    
    1. Extract terms from method names, arguments, and return types.
        
    2. Construct a term-document matrix.
        
    3. Calculate the cosine similarity between method vectors.
        
    
    - _Usage:_ High structural cohesion but low semantic cohesion suggests the class is a "Data Clump" or a "God Object" holding tightly coupled but logically distinct domains.
        

### Anti-Patterns and Refactoring Triggers

Metric values are signals, not verdicts. However, specific patterns in cohesion metrics warrant immediate architectural review:

- **The "Utility" False Positive:** Helper classes (e.g., `StringUtils`) often have LCOM4 equal to the number of methods (complete disconnectivity) because they are static and stateless. These should be excluded from cohesion analysis or refactored into domain objects if they begin managing state.
    
- **The "Lazy Class" Anomaly:** A class with high cohesion (LCOM=1) but very low complexity and few methods may be an unnecessary abstraction (Lazy Class). High cohesion does not justify existence if the responsibility is trivial.
    
- **Refactoring Strategy:**
    
    1. **Calculate LCOM4.**
        
    2. If LCOM4 > 1, visualize the dependency graph.
        
    3. **Identify Components:** Each connected component represents a distinct responsibility.
        
    4. **Extract Class:** Move the smaller component (methods + fields they touch) to a new class.
        
    5. **Re-evaluate:** Both new classes should now have LCOM4 = 1.
        

Related Topics: Coupling Metrics (CBO, RFC), Connascence, Abstract Data Type (ADT) Theory, Cyclomatic Complexity.

---

