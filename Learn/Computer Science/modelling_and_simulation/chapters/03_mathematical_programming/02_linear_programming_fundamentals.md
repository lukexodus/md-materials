## Linear Programming Fundamentals

### Definition and Conceptual Basis

**Linear programming (LP)** is a mathematical optimization technique for finding the best outcome — maximum profit, minimum cost, or similar objective — in a model whose requirements are represented by linear relationships. It is one of the foundational tools of operations research and is frequently used within modelling and simulation contexts to determine optimal parameter settings, resource allocations, or control policies for a system once its structure has been mathematically represented.

Unlike the dynamic state-space models discussed in earlier topics, linear programming is fundamentally a static optimization technique: it seeks a single optimal solution to a snapshot problem rather than describing how a system evolves over time. It becomes relevant to simulation when a system's operating decisions must be optimized, either as an input to a simulation run or as a post-processing step applied to policies discovered through simulation.

### Standard Form of a Linear Program

A linear program consists of three essential components: a **linear objective function** to be maximized or minimized, a set of **linear constraints**, and **non-negativity restrictions** on the decision variables.

**General form:**

$$\text{Maximize (or Minimize)} \quad z = c_1 x_1 + c_2 x_2 + \dots + c_n x_n$$

subject to:

$$a_{11}x_1 + a_{12}x_2 + \dots + a_{1n}x_n \leq b_1$$



$$a_{21}x_1 + a_{22}x_2 + \dots + a_{2n}x_n \leq b_2$$



$$\vdots$$



$$a_{m1}x_1 + a_{m2}x_2 + \dots + a_{mn}x_n \leq b_m$$



$$x_1, x_2, \dots, x_n \geq 0$$

where $x_1, \dots, x_n$ are decision variables, $c_j$ are objective coefficients, $a_{ij}$ are constraint coefficients, and $b_i$ are constraint bounds (right-hand-side values).

**Key Points**

- All relationships — objective and constraints alike — must be linear; any product of two decision variables, ratio involving decision variables, or nonlinear function immediately places the problem outside standard linear programming.
- Constraints can be expressed as $\leq$, $\geq$, or $=$; conversion between these forms (e.g., introducing slack or surplus variables) is used to bring a problem into standard computational form.
- Non-negativity restrictions reflect that most real-world decision variables (quantities produced, resources allocated) cannot meaningfully take negative values, though this restriction can be relaxed or reformulated for variables that can be negative (using variable substitution techniques).

### Components in Detail

**Decision variables** represent the quantities the decision-maker controls and seeks to determine optimal values for (e.g., units of each product to manufacture).

**Objective function** is the single linear expression to be maximized or minimized, representing the overall goal of the optimization (e.g., total profit, total cost, total distance).

**Constraints** represent limitations or requirements the solution must satisfy (e.g., available labor hours, raw material limits, minimum demand requirements).

**Feasible region** is the set of all decision variable values satisfying every constraint simultaneously; the optimal solution, if one exists, lies within or on the boundary of this region.

### Example: A Production Planning Problem

A factory produces two products, A and B. Each unit of A yields a profit of 40 and requires 2 hours of labor and 3 units of raw material. Each unit of B yields a profit of 30 and requires 1 hour of labor and 4 units of raw material. Available labor is 40 hours and available raw material is 60 units.

**Decision variables:** $x_1$ = units of A produced, $x_2$ = units of B produced

**Objective function:**

$$\text{Maximize} \quad z = 40x_1 + 30x_2$$

**Constraints:**

$$2x_1 + x_2 \leq 40 \quad \text{(labor)}$$



$$3x_1 + 4x_2 \leq 60 \quad \text{(raw material)}$$



$$x_1, x_2 \geq 0$$

This system defines a feasible region in the $x_1$-$x_2$ plane, and the optimal production mix is found at one of the vertices (corner points) of this region.

### Diagrammatic Representation: Feasible Region

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 500 400">
<text x="250" y="20" text-anchor="middle" font-size="14" font-weight="bold">Feasible Region and Optimal Vertex (svg_diagram)</text>
<line x1="60" y1="350" x2="460" y2="350" stroke="black" stroke-width="1.5" />
<line x1="60" y1="350" x2="60" y2="40" stroke="black" stroke-width="1.5" />
<text x="465" y="355" font-size="12">x1</text>
<text x="45" y="35" font-size="12">x2</text>
<line x1="60" y1="230" x2="340" y2="350" stroke="#2563eb" stroke-width="2" />
<text x="345" y="345" font-size="11" fill="#2563eb">2x1+x2=40</text>
<line x1="60" y1="80" x2="380" y2="350" stroke="#dc2626" stroke-width="2" />
<text x="385" y="350" font-size="11" fill="#dc2626">3x1+4x2=60</text>
<polygon points="60,350 60,230 148,258 200,350" fill="#93c5fd" fill-opacity="0.4" stroke="none" />
<circle cx="148" cy="258" r="5" fill="#16a34a" />
<text x="155" y="255" font-size="11" fill="#16a34a">Optimal Vertex</text>
<circle cx="60" cy="230" r="4" fill="#374151" />
<circle cx="60" cy="350" r="4" fill="#374151" />
<circle cx="200" cy="350" r="4" fill="#374151" />
<text x="490" y="380" font-size="10" fill="#666">Shaded region = feasible; vertex = candidate optima</text>
</svg>

### The Fundamental Theorem of Linear Programming

**Key Points**

- If a linear program has an optimal solution, at least one optimal solution occurs at a vertex (extreme point) of the feasible region — an insight that underlies the simplex method's strategy of searching only among vertices rather than the entire feasible region.
- The feasible region of a linear program, when non-empty and bounded, forms a convex polytope; convexity ensures that any local optimum found at a vertex is also a global optimum. [Inference]
- A linear program may have: a single unique optimal solution, multiple optimal solutions (an entire edge or face of equally optimal points), no feasible solution (infeasibility), or an unbounded solution (objective can be improved indefinitely).

### Solution Methods

- **Graphical method:** Applicable only to problems with two (or occasionally three) decision variables; involves plotting constraints, identifying the feasible region, and evaluating the objective function at each vertex.
- **Simplex method:** An algebraic algorithm that systematically moves from one vertex of the feasible region to an adjacent vertex with an improved (or equal) objective value, terminating when no adjacent vertex offers improvement. Applicable to problems of arbitrary size.
- **Interior-point methods:** A class of algorithms that approach the optimal solution by traversing through the interior of the feasible region rather than along its boundary vertices, often more efficient for very large-scale problems.

**Key Points**

- The simplex method, despite having worst-case exponential time complexity in theory, performs efficiently on the vast majority of practical problems encountered. [Inference]
- Modern LP solvers typically implement both simplex and interior-point methods, selecting or allowing the user to select the more efficient approach for a given problem's structure and scale.

### Diagrammatic Representation: LP Solution Workflow

===MERMAID_DIAGRAM===

flowchart TD

A["Define Decision Variables (svg_diagram)"] --> B["Formulate Objective Function"]

B --> C["Formulate Constraints"]

C --> D["Identify Feasible Region"]

D --> E{"Feasible Region Empty?"}

E -->|Yes| F["Infeasible Problem"]

E -->|No| G{"Objective Unbounded on Region?"}

G -->|Yes| H["Unbounded Solution"]

G -->|No| I["Apply Simplex / Interior-Point Method"]

I --> J["Optimal Solution at Vertex"]

### Duality in Linear Programming

Every linear program (the **primal**) has an associated **dual** linear program, whose variables correspond to the primal's constraints and vice versa.

**Key Points**

- The dual of a maximization problem is a minimization problem (and vice versa), and the optimal objective values of the primal and dual coincide when both have feasible solutions (strong duality).
- Dual variables have an economic interpretation as **shadow prices** — the marginal change in the optimal objective value per unit relaxation of the corresponding primal constraint.
- Duality is used extensively in sensitivity analysis, revealing how the optimal solution and objective value respond to changes in constraint bounds or objective coefficients without re-solving the entire problem from scratch. [Inference]

### Sensitivity Analysis in Linear Programming

**Key Points**

- **Shadow prices** indicate the rate of change of the optimal objective value with respect to small changes in a constraint's right-hand-side value, valid only within a specific range (the "range of feasibility").
- **Reduced costs** indicate how much an objective coefficient for a currently non-basic (zero-valued) decision variable would need to improve before that variable would enter the optimal solution at a nonzero value.
- Sensitivity analysis allows decision-makers to assess which constraints are binding (limiting factors) and which resources would be most valuable to acquire additional units of, without re-solving the model. [Inference]

### Role of Linear Programming Within Modelling and Simulation

**Key Points**

- LP is frequently used to determine an optimal static policy (e.g., resource allocation, production levels) that is then embedded as a fixed input or parameter set within a larger dynamic simulation model.
- In simulation-optimization workflows, LP-based subroutines may be invoked repeatedly within a simulation loop to re-optimize decisions as simulated conditions change over time (e.g., periodic re-optimization in inventory or scheduling simulations). [Inference]
- LP assumes perfect linearity and certainty in coefficients; when a real system's decision problem involves nonlinear relationships or uncertainty, extensions such as nonlinear programming, integer programming, or stochastic programming are used instead.

### Common Pitfalls

- **Forcing nonlinear relationships into linear form:** Approximating genuinely nonlinear cost or production relationships as linear can produce misleadingly optimal-looking solutions that do not reflect true system behavior.
- **Ignoring integrality requirements:** Applying standard LP to problems where decision variables must take integer values (e.g., whole units of equipment) can yield fractional "optimal" solutions that are not implementable without further rounding or reformulation as an integer program.
- **Misinterpreting shadow prices outside their valid range:** Applying a shadow price to a constraint change that falls outside the range of feasibility can produce inaccurate sensitivity conclusions.
- **Overlooking infeasibility or unboundedness during formulation:** Failing to check whether a formulated model is even solvable before attempting interpretation of a solver's output.

**Related Topics**

- Mathematical Models and Their Components
- Integer and Mixed-Integer Programming
- Nonlinear Programming and Optimization
- Duality Theory and Shadow Price Interpretation
- Simulation-Optimization Techniques
- Stochastic Programming Under Uncertainty
- Network Flow Models and Transportation Problems