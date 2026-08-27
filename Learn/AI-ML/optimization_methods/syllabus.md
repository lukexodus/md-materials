## Table of Contents: Optimization Methods

### Mathematical Foundations and Prerequisites

- Linear algebra review: vector spaces, norms, inner products
- Matrix decompositions: eigenvalue, singular value, Cholesky, QR
- Positive definite and positive semidefinite matrices
- Multivariable calculus: gradients, Jacobians, Hessians
- Taylor series expansions in multiple dimensions
- Topology basics: open, closed, compact, bounded sets
- Sequences, limits, and continuity in normed spaces
- Differentiability and directional derivatives
- Implicit function theorem
- Basic real analysis for optimization proofs
- Set notation and mathematical logic for optimization statements
- Introduction to functional analysis for infinite-dimensional problems

### Optimization Problem Formulation

- Decision variables, objective functions, and constraints
- Feasible region and feasible set characterization
- Local versus global optima definitions
- Equality and inequality constraint types
- Standard form and canonical form conversions
- Classification: linear, nonlinear, convex, nonconvex
- Classification: continuous versus discrete optimization
- Classification: single-objective versus multi-objective
- Classification: deterministic versus stochastic problems
- Well-posedness and existence of solutions
- Sensitivity and parametric formulations
- Modeling real-world problems as optimization programs

### Convexity and Convex Analysis

- Convex sets and their properties
- Convex hulls and extreme points
- Convex functions and epigraphs
- First-order and second-order convexity conditions
- Quasiconvexity and pseudoconvexity
- Operations preserving convexity
- Conjugate functions and Legendre transform
- Subgradients and subdifferentials
- Support functions and separating hyperplanes
- Convex optimization problem structure
- Strong convexity and its implications
- Convexity in composite and constrained problems

### Optimality Conditions

- Unconstrained first-order necessary conditions
- Unconstrained second-order sufficient conditions
- Constrained optimization and Lagrange multipliers
- Karush-Kuhn-Tucker conditions derivation
- Constraint qualifications: LICQ, MFCQ, Slater's condition
- Complementary slackness interpretation
- Second-order conditions for constrained problems
- Sensitivity analysis via multipliers
- Geometric interpretation of optimality conditions
- Necessary versus sufficient condition distinctions

### Duality Theory

- Lagrangian function construction
- Dual function and dual problem formulation
- Weak duality and duality gap
- Strong duality conditions
- Slater's condition and constraint qualifications for duality
- Complementary slackness and primal-dual relationships
- Saddle point theory
- Fenchel duality
- Lagrangian relaxation for hard problems
- Dual decomposition methods
- Economic interpretation of dual variables

### Line Search Methods

- Descent direction concepts
- Exact line search techniques
- Inexact line search and Armijo condition
- Wolfe conditions and curvature requirements
- Goldstein conditions
- Backtracking line search algorithms
- Step length selection strategies
- Convergence rate implications of line search choice

### Gradient-Based Unconstrained Optimization

- Steepest descent method
- Convergence analysis of gradient descent
- Condition number effects on convergence
- Conjugate gradient method for quadratics
- Nonlinear conjugate gradient variants
- Momentum and heavy-ball methods
- Nesterov accelerated gradient method
- Coordinate descent methods
- Block coordinate descent

### Newton and Quasi-Newton Methods

- Newton's method derivation and convergence
- Modified Newton methods for nonconvexity
- Quasi-Newton motivation and secant condition
- DFP update formula
- BFGS update formula
- Limited-memory BFGS for large-scale problems
- Symmetric rank-one updates
- Broyden family of updates
- Convergence properties of quasi-Newton methods

### Trust Region Methods

- Trust region subproblem formulation
- Cauchy point calculation
- Dogleg method
- Two-dimensional subspace minimization
- Exact trust region subproblem solution
- Trust region radius update rules
- Global convergence theory for trust region methods
- Trust region versus line search comparison

### Derivative-Free Optimization

- Motivation for derivative-free methods
- Nelder-Mead simplex method
- Pattern search and generalized pattern search
- Coordinate search methods
- Model-based trust region derivative-free methods
- Finite difference gradient approximations
- Simultaneous perturbation stochastic approximation
- Bayesian optimization fundamentals
- Gaussian process surrogate models
- Acquisition functions for Bayesian optimization

### Linear Programming Theory

- Standard form linear programs
- Polyhedra and basic feasible solutions
- Vertices, edges, and extreme points of polyhedra
- Fundamental theorem of linear programming
- LP duality theory
- Complementary slackness in linear programming
- Degeneracy and its implications

### Linear Programming Algorithms

- Simplex method mechanics
- Tableau representation and pivoting
- Bland's rule for avoiding cycling
- Two-phase simplex method
- Big-M method
- Revised simplex method
- Dual simplex method
- Interior point methods for linear programming
- Primal-dual interior point algorithms
- Path-following methods
- Computational complexity comparisons

### Sensitivity Analysis in Linear Programming

- Shadow prices and their interpretation
- Ranging analysis for objective coefficients
- Ranging analysis for right-hand side values
- Adding new variables or constraints post-optimality
- Parametric linear programming

### Quadratic Programming

- Quadratic program formulation and classification
- Convex versus nonconvex quadratic programs
- Active set methods for quadratic programming
- Interior point methods for quadratic programming
- Equality-constrained quadratic programming via KKT systems
- Range space and null space methods
- Sequential quadratic programming subproblems

### Nonlinear Programming Algorithms

- Penalty function methods
- Exact penalty functions
- Augmented Lagrangian methods
- Sequential quadratic programming algorithm
- SQP merit functions and globalization
- Interior point methods for nonlinear programming
- Barrier function methods
- Primal-dual interior point for nonconvex problems
- Filter methods for nonlinear programming
- Generalized reduced gradient method

### Constrained Optimization Software Practice

- Feasibility restoration techniques
- Warm-starting strategies
- Scaling and preconditioning constrained problems
- Handling infeasible and unbounded problems numerically
- Termination criteria for constrained solvers

### Nonconvex and Global Optimization

- Local versus global search strategies
- Multi-start methods
- Branch and bound for global optimization
- Convex relaxation techniques
- Cutting plane methods for nonconvex problems
- Underestimation and overestimation bounds
- Difference of convex functions programming
- Semidefinite programming relaxations
- Concave minimization approaches

### Semidefinite and Conic Programming

- Semidefinite programming formulation
- Cone programming generalizations
- Second-order cone programming
- Duality in conic programming
- Interior point methods for semidefinite programs
- Applications of SDP relaxations

### Integer and Combinatorial Optimization

- Integer programming formulation types
- Linear relaxation of integer programs
- Branch and bound algorithm mechanics
- Branching strategies and variable selection
- Cutting plane methods for integer programming
- Gomory cuts
- Branch and cut algorithms
- Branch and price for large-scale integer programs
- Column generation techniques
- Dynamic programming for combinatorial problems
- Network flow optimization formulations
- Shortest path, max flow, and min cost flow algorithms
- Matching and assignment problems
- Traveling salesman problem formulations and bounds
- Knapsack problem variants and algorithms
- Facility location and set covering problems

### Mixed-Integer Nonlinear Programming

- MINLP problem structure
- Outer approximation methods
- Generalized Benders decomposition
- Branch and bound for nonconvex MINLP
- Convex MINLP solution approaches

### Stochastic and Metaheuristic Optimization

- Simulated annealing algorithm and cooling schedules
- Genetic algorithms and evolutionary strategies
- Crossover, mutation, and selection operators
- Particle swarm optimization
- Ant colony optimization
- Tabu search
- Differential evolution
- Harmony search and other nature-inspired methods
- No free lunch theorem implications
- Hybridizing metaheuristics with local search

### Stochastic Approximation and Optimization Under Uncertainty

- Stochastic gradient descent fundamentals
- Convergence analysis of stochastic gradient methods
- Minibatch stochastic gradient methods
- Variance reduction techniques
- Adaptive learning rate methods
- Adam, RMSProp, and Adagrad algorithms
- Second-order stochastic methods
- Robbins-Monro stochastic approximation theory

### Large-Scale and Distributed Optimization

- Proximal gradient methods
- Proximal operator computation and properties
- Accelerated proximal gradient methods
- Alternating direction method of multipliers
- ADMM convergence theory
- Distributed optimization architectures
- Consensus optimization
- Federated optimization considerations
- Parallel and asynchronous optimization algorithms
- Sketching and randomized linear algebra for optimization

### Nonsmooth Optimization

- Subgradient methods
- Subgradient method convergence and step size rules
- Bundle methods
- Proximal point algorithms
- Moreau envelope and smoothing techniques
- Composite optimization formulations
- Regularized optimization with L1 and nuclear norm penalties

### Multi-Objective Optimization

- Pareto optimality and dominance concepts
- Pareto frontier characterization
- Weighted sum scalarization method
- Epsilon-constraint method
- Goal programming
- Multi-objective evolutionary algorithms
- NSGA-II algorithm mechanics
- Decision-making under multiple criteria

### Robust and Stochastic Programming

- Robust optimization problem formulation
- Uncertainty sets and robust counterparts
- Chance-constrained programming
- Two-stage stochastic programming
- Multi-stage stochastic programming
- Sample average approximation methods
- Distributionally robust optimization
- Scenario generation and reduction techniques

### Dynamic Programming and Optimal Control

- Bellman equation and principle of optimality
- Discrete-time dynamic programming
- Continuous-time optimal control formulation
- Pontryagin's maximum principle
- Hamilton-Jacobi-Bellman equation
- Linear quadratic regulator problems
- Model predictive control optimization
- Reinforcement learning connections to dynamic programming

### Optimization in Machine Learning Contexts

- Empirical risk minimization framework
- Regularization and generalization tradeoffs in optimization
- Convex surrogate loss functions
- Optimization landscape of neural networks
- Saddle points and local minima in deep learning
- Batch normalization effects on optimization
- Second-order and natural gradient methods in deep learning
- Hyperparameter optimization techniques

### Numerical Considerations and Software

- Floating point arithmetic and numerical stability
- Conditioning and preconditioning techniques
- Automatic differentiation principles
- Forward mode versus reverse mode differentiation
- Solver selection criteria for different problem classes
- Modeling languages for optimization
- Benchmarking and performance profiling of algorithms
- Reproducibility and numerical experiment design

### Applications and Case Studies

- Portfolio optimization formulations
- Engineering design optimization
- Supply chain and logistics optimization
- Optimal experiment design
- Signal processing and compressed sensing applications
- Optimal transport theory and applications
- Game-theoretic optimization and equilibrium computation
