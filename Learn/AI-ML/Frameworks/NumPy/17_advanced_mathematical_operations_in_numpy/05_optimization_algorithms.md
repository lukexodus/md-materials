## Optimization Algorithms


Optimization algorithms in SciPy provide comprehensive tools for finding function extrema, solving constrained optimization problems, and identifying optimal parameter values across diverse mathematical and engineering applications.

Unconstrained optimization algorithms include gradient-based methods like BFGS and L-BFGS-B that utilize derivative information for efficient convergence, and derivative-free methods like Nelder-Mead simplex that work with noisy or discontinuous objective functions.

Constrained optimization extends optimization to problems with equality and inequality constraints, utilizing methods like Sequential Least Squares Programming (SLSQP) and trust region algorithms that balance objective function optimization with constraint satisfaction.

Global optimization addresses problems with multiple local minima by implementing algorithms like differential evolution, simulated annealing, and basin-hopping that explore the entire solution space to identify global optima rather than local solutions.

Multi-objective optimization handles problems with competing objectives, providing Pareto-optimal solutions that represent optimal trade-offs between conflicting goals. These methods prove essential for engineering design and decision-making applications.

Least squares optimization specializes in parameter estimation problems where objective functions represent sum-of-squares residuals, utilizing specialized algorithms that exploit mathematical structure for enhanced convergence properties.

**Example:**

```python
from scipy import optimize

# Define objective function with multiple minima
def objective_function(x):
    return (x[0] - 1)**2 + (x[1] - 2)**2 + 0.1 * np.sin(10 * x[0]) * np.sin(10 * x[1])

# Unconstrained optimization
initial_guess = [0, 0]
result_bfgs = optimize.minimize(objective_function, initial_guess, method='BFGS')
result_nelder = optimize.minimize(objective_function, initial_guess, method='Nelder-Mead')

print(f"BFGS result: {result_bfgs.x}, function value: {result_bfgs.fun}")
print(f"Nelder-Mead result: {result_nelder.x}, function value: {result_nelder.fun}")

# Constrained optimization
def constraint1(x):
    return x[0] + x[1] - 1  # x[0] + x[1] >= 1

def constraint2(x):
    return x[0]**2 + x[1]**2 - 4  # x[0]^2 + x[1]^2 <= 4

constraints = [
    {'type': 'ineq', 'fun': constraint1},
    {'type': 'ineq', 'fun': lambda x: 4 - x[0]**2 - x[1]**2}
]

bounds = [(-2, 2), (-2, 2)]
constrained_result = optimize.minimize(objective_function, initial_guess, 
                                     method='SLSQP', bounds=bounds, constraints=constraints)

# Global optimization
global_result = optimize.differential_evolution(objective_function, bounds)
basinhopping_result = optimize.basinhopping(objective_function, initial_guess)

# Least squares fitting
def model_function(x, a, b, c):
    return a * np.exp(-b * x) + c

# Generate noisy data
x_data = np.linspace(0, 5, 50)
true_params = [2.5, 1.3, 0.5]
y_true = model_function(x_data, *true_params)
y_data = y_true + 0.1 * np.random.randn(len(x_data))

# Fit parameters
popt, pcov = optimize.curve_fit(model_function, x_data, y_data)
print(f"Fitted parameters: {popt}")
print(f"Parameter uncertainties: {np.sqrt(np.diag(pcov))}")

# Root finding
def equation(x):
    return x**3 - 2*x**2 + x - 1

root_scalar = optimize.root_scalar(equation, bracket=[0, 2], method='brentq')
root_vector = optimize.root(lambda x: [x[0]**2 + x[1]**2 - 1, x[0] - x[1]], [0.5, 0.5])
```

