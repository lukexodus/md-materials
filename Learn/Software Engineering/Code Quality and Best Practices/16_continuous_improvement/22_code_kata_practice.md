## Code Kata Practice


### Deliberate Practice and Cognitive Load

Code Katas are not merely algorithmic drills; they are a mechanism for **deliberate practice** aimed at internalizing syntax, IDE shortcuts, and refactoring patterns. The architectural objective is to move low-level coding mechanics from System 2 (slow, conscious effort) to System 1 (fast, intuitive muscle memory). This reduction in cognitive load allows developers to reserve mental bandwidth for higher-order architectural reasoning and domain modeling during production work.

### Categories of Architectural Katas

1. The Refactoring Kata (Legacy Remediation)

Focuses on safety mechanisms when modifying existing, untestable code.

- **Example:** The Gilded Rose Kata, Trivia Kata.
    
- **Technique:**
    
    - **Golden Master / Approval Testing:** Establish a baseline of behavior by capturing text-based output before modifying code.
        
    - **Characterization Tests:** Write tests not to verify correctness, but to codify current behavior (including bugs).
        
    - **Micro-commits:** Practice extremely small, atomic commits (e.g., rename variable, extract method) to enable granular reverts.
        

2. The Greenfield TDD Kata

Focuses on the strict application of the Red-Green-Refactor loop.

- **Example:** String Calculator, Bowling Game.
    
- **Technique:**
    
    - **ZOMBIES Heuristic:** Zero, One, Many, Boundary, Interface, Exceptions, Scenarios.
        
    - **Baby Steps:** Enforce a constraint where a test must be written and passed every 2 minutes.
        
    - **Transformation Priority Premise:** Practice prioritizing simpler code transformations (e.g., constant to scalar) over complex ones (e.g., scalar to array) to drive generalization.
        

3. The Object Calisthenics Kata

Focuses on code maintainability and OO design principles by applying artificial, extreme constraints.

- **Constraints:**
    
    - One level of indentation per method.
        
    - Don't use the `else` keyword (forces polymorphism or guard clauses).
        
    - Wrap all primitives and strings (forces Value Objects).
        
    - First-class collections (wrap all lists/arrays).
        
    - One dot per line (Law of Demeter enforcement).
        
    - No getters/setters/properties (forces Tell-Don't-Ask).
        

### Execution Models for Team Standardization

Randori (Dojo Style)

A collaborative format involving a driver, a navigator, and the audience.

- **Setup:** One computer projected on a screen.
    
- **Rotation:** Time-boxed pairs (e.g., 5-7 minutes). The driver moves to the audience, the navigator becomes the driver, and a new navigator joins from the audience.
    
- **Objective:** Aligns the team on IDE usage, shortcuts, and naming conventions. It exposes knowledge gaps in tooling efficiency.
    

Ping Pong Pairing

A high-velocity TDD cycle between two developers.

- **Cycle:**
    
    1. **Dev A:** Writes a failing test.
        
    2. **Dev B:** Writes the minimal code to pass the test.
        
    3. **Dev B:** Writes the next failing test.
        
    4. **Dev A:** Writes the minimal code to pass the test.
        
- **Refactoring:** Both developers refactor together after the pass state.
    

### Anti-Patterns in Practice

- **The "Solution" Fallacy:** Focusing on solving the algorithmic problem rather than the process. If the solution is known, the kata should focus on a different constraint (e.g., "solve it without using a loop").
    
- **Skipping Refactor:** In the Red-Green-Refactor cycle, developers often rush from Green to Red. The Refactor step is the primary venue for design pattern application and must be the longest phase.
    
- **Silent Coding:** Katas are a communication exercise. The driver must vocalize intent before typing. Silent typing decouples the navigator and observers from the thought process.
    

Related Topics: Test-Driven Development (TDD), Behavior-Driven Development (BDD), Pair Programming Dynamics, Legacy Code Characterization.

---

