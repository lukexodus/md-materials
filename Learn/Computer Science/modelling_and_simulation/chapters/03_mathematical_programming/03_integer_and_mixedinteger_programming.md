## Integer and Mixed-Integer Programming

### Overview

Integer Programming (IP) and Mixed-Integer Programming (MIP) extend linear programming by requiring some or all decision variables to take integer values. This restriction models real-world situations involving indivisible units, yes/no decisions, sequencing, and combinatorial choices that cannot be captured by continuous variables alone.

In an **Integer Program**, all decision variables must be integers. In a **Mixed-Integer Program**, only a subset of variables are restricted to integers while the rest remain continuous. A special and widely used case is **Binary Integer Programming (BIP)**, where variables are restricted to {0, 1}, typically representing yes/no or on/off decisions.

### Mathematical Formulation

A general Mixed-Integer Linear Program (MILP) is written as:

$$\text{minimize } c^T x + d^T y$$



$$\text{subject to: } Ax + By \leq b$$



$$x \in \mathbb{Z}^n, \quad y \in \mathbb{R}^m$$

Here $x$ represents the integer-constrained decision variables, $y$ represents continuous decision variables, and $c$, $d$, $A$, $B$, $b$ define the objective coefficients and constraint structure.

For a **pure Integer Program**, all variables belong to $\mathbb{Z}^n$. For a **Binary Integer Program**, variables are constrained as:

$$x_i \in \{0, 1\}, \quad \forall i$$

### Why Integer Constraints Matter

**Key Points**

- Continuous (LP) relaxations may produce fractional solutions that are meaningless in practice — for example, 3.7 machines to purchase or 0.5 of a worker assigned to a shift.
- Integer constraints are essential for modeling discrete, combinatorial, or logical decisions.
- Adding integrality constraints transforms the problem from convex and polynomial-time solvable (LP) to NP-hard in the general case, since the feasible region is no longer convex.

### Common Problem Types

#### Binary Decision Problems

Variables represent yes/no choices, such as whether to open a facility, select a project, or include an item in a set.

#### Knapsack Problem

Selecting a subset of items with given weights and values to maximize total value without exceeding a capacity constraint:

$$\text{maximize } \sum_i v_i x_i \quad \text{subject to } \sum_i w_i x_i \leq W, \quad x_i \in \{0,1\}$$

#### Assignment and Set Covering Problems

Assigning tasks to agents, or selecting a minimum-cost set of resources to cover all requirements — both rely on binary variables to encode discrete assignment logic.

#### Facility Location Problems

Mixed-integer formulation where binary variables decide whether a facility is opened, and continuous variables determine flow or allocation quantities once facilities are chosen.

#### Traveling Salesman Problem (TSP) and Routing

Sequencing and routing problems are classically formulated as integer programs using binary variables to indicate whether an edge or arc is used in a route.

### Solution Methods

#### Branch and Bound

The dominant exact method for solving MIPs. It works by:

1. Solving the LP relaxation (ignoring integrality constraints).
2. If the solution is already integer-feasible, it is optimal for the IP/MIP.
3. If not, selecting a fractional variable and "branching" into two subproblems — one with $x_i \leq \lfloor x_i \rfloor$ and one with $x_i \geq \lceil x_i \rceil$.
4. Recursively solving each subproblem (the "bound" step uses the LP relaxation's objective value to prune branches that cannot improve on the best known integer solution).

This creates a search tree that is pruned wherever a branch's relaxed bound is worse than the current best feasible integer solution (the incumbent).

#### Branch and Cut

Combines branch and bound with **cutting planes** — additional valid inequalities added to tighten the LP relaxation and eliminate fractional solutions without cutting off any integer-feasible points. This is the standard approach used in most modern commercial solvers.

#### Cutting Plane Methods

Techniques such as Gomory cuts iteratively add linear inequalities that are satisfied by all integer feasible points but violated by the current fractional LP solution, progressively tightening the relaxation toward the integer hull.

#### Branch and Price

Used for large-scale problems with an enormous number of variables (common in routing and scheduling), combining branch and bound with column generation to avoid enumerating all variables explicitly.

#### Heuristic and Metaheuristic Approaches

For large or complex MIPs where exact methods are computationally prohibitive, heuristic methods such as **relaxation-based rounding**, **local search**, **genetic algorithms**, and **simulated annealing** are used to find good, though not necessarily optimal, solutions within reasonable time.

### The Branch and Bound Process (Illustration)

===MERMAID_DIAGRAM===

flowchart TD

A["Solve LP Relaxation"] --> B{"Integer Feasible?"}

B -->|Yes| C["Candidate Solution Found"]

B -->|No| D["Select Fractional Variable x_i"]

D --> E["Branch: x_i <= floor(x_i)"]

D --> F["Branch: x_i >= ceil(x_i)"]

E --> G{"Bound Worse Than Incumbent?"}

F --> H{"Bound Worse Than Incumbent?"}

G -->|Yes| I["Prune Branch"]

G -->|No| A

H -->|Yes| J["Prune Branch"]

H -->|No| A

C --> K{"Better Than Incumbent?"}

K -->|Yes| L["Update Incumbent"]

K -->|No| I

### LP Relaxation Gap

The **integrality gap** (or optimality gap) is the difference between the LP relaxation's objective value and the true integer-optimal objective value. A small gap indicates the LP relaxation is a tight approximation, making branch and bound converge quickly. A large gap signals a computationally harder instance, often requiring extensive branching or strong cutting planes.

$$\text{Gap} = \frac{Z_{LP} - Z_{IP}}{Z_{IP}} \times 100\%$$

[Unverified] The magnitude of this gap in practice depends heavily on problem structure and formulation tightness, and cannot be generalized across problem classes without instance-specific analysis.

### Formulation Techniques

#### Big-M Method

Used to model conditional or disjunctive constraints (e.g., "if binary variable $y = 1$, then constraint $A$ applies; otherwise constraint $B$ applies") by introducing a sufficiently large constant $M$:

$$g(x) \leq M(1 - y)$$

**Key Points**

- Choosing $M$ too small can incorrectly exclude feasible solutions.
- Choosing $M$ too large can weaken the LP relaxation, slowing solver convergence.
- Tight, problem-specific bounds on $M$ generally improve solver performance.

#### Indicator Constraints

Many modern solvers support indicator constraints natively, avoiding the numerical instability associated with poorly scaled Big-M formulations.

#### Special Ordered Sets (SOS)

Constraints used to model piecewise-linear functions or restrict which combinations of variables may be simultaneously nonzero, useful in production planning and blending problems.

### Worked Example

**Example**

A company must decide which of four projects to fund, given a budget of $100,000. Each project has a cost and expected profit:

| Project | Cost ($) | Profit ($) |
| --- | --- | --- |
| A | 40,000 | 70,000 |
| B | 50,000 | 60,000 |
| C | 30,000 | 45,000 |
| D | 20,000 | 35,000 |

Formulation:

$$\text{maximize } 70000x_A + 60000x_B + 45000x_C + 35000x_D$$



$$\text{subject to: } 40000x_A + 50000x_B + 30000x_C + 20000x_D \leq 100000$$



$$x_A, x_B, x_C, x_D \in \{0,1\}$$

**Output**

Solving this 0-1 knapsack-style problem yields the optimal selection of projects A, C, and D (total cost $90,000, total profit $150,000), which outperforms the alternative combination of A and B (total cost $90,000, total profit $130,000) despite using the same budget.

### Applications in Modelling and Simulation

- **Production planning:** determining discrete batch sizes, machine setups, and shift scheduling.
- **Supply chain design:** facility location, warehouse selection, and network design under fixed-charge cost structures.
- **Telecommunications:** network design and frequency assignment with discrete channel allocation.
- **Healthcare operations:** nurse scheduling, operating room allocation, and patient-to-resource assignment.
- **Simulation-optimization workflows:** MIP models are frequently embedded within simulation loops to optimize discrete design parameters (e.g., number of servers, buffer sizes) based on outputs from stochastic simulations.

### Computational Complexity Considerations

**Key Points**

- General Integer Programming is NP-hard; no known polynomial-time algorithm solves all instances efficiently.
- Problem size alone does not determine solvability — formulation strength, symmetry, and constraint structure significantly affect solver performance.
- [Inference] Well-formulated MIPs with tight LP relaxations and few symmetric solutions tend to solve substantially faster in practice than loosely formulated equivalents, though exact runtime behavior is instance-dependent and cannot be guaranteed a priori.

### Software and Solvers

Common tools used to solve IP/MIP models include CPLEX, Gurobi, and open-source solvers such as CBC and SCIP, typically accessed through modeling languages like AMPL, GAMS, or Python libraries such as PuLP and Pyomo. [Unverified] Specific performance comparisons between these solvers vary by problem instance, hardware, and solver version, and should be benchmarked directly for any given application rather than assumed from general reputation.

### Conclusion

Integer and Mixed-Integer Programming provide the mathematical framework for modeling discrete decision-making within optimization problems, extending linear programming to handle indivisibility, logical conditions, and combinatorial structure. While computationally harder than LP due to NP-hardness, methods such as branch and bound, cutting planes, and modern branch-and-cut solvers make large and complex MIPs tractable in practice, making IP/MIP foundational tools across production, logistics, scheduling, and simulation-based optimization.

### Related Topics

- Linear Programming Duality and Sensitivity Analysis
- Dynamic Programming for Sequential Decision Models
- Network Flow Optimization (Max-Flow, Min-Cost Flow)
- Metaheuristics: Genetic Algorithms, Simulated Annealing, Tabu Search
- Stochastic Programming and Optimization Under Uncertainty
- Simulation-Optimization Techniques
- Constraint Programming
- Multi-Objective Optimization