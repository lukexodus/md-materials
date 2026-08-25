## Real-World Application Examples


**Scientific Computing Workflows**

```python
# Signal processing example
def generate_signal(frequency, duration, sample_rate):
    t = np.linspace(0, duration, int(sample_rate * duration))
    signal = np.sin(2 * np.pi * frequency * t)
    noise = np.random.normal(0, 0.1, len(t))
    return t, signal + noise

# FFT analysis
t, noisy_signal = generate_signal(50, 1.0, 1000)
fft_result = np.fft.fft(noisy_signal)
frequencies = np.fft.fftfreq(len(noisy_signal), 1/1000)
```

**Data Analysis Pipelines**

```python
# Statistical analysis workflow
def analyze_dataset(data):
    # Descriptive statistics
    stats = {
        'mean': np.mean(data, axis=0),
        'std': np.std(data, axis=0),
        'median': np.median(data, axis=0),
        'percentiles': np.percentile(data, [25, 75], axis=0)
    }
    
    # Correlation analysis
    correlation_matrix = np.corrcoef(data.T)
    
    # Outlier detection using IQR method
    Q1 = np.percentile(data, 25, axis=0)
    Q3 = np.percentile(data, 75, axis=0)
    IQR = Q3 - Q1
    outliers = (data < Q1 - 1.5 * IQR) | (data > Q3 + 1.5 * IQR)
    
    return stats, correlation_matrix, outliers
```

**Image and Signal Processing**

```python
# Image processing operations
def process_image(image_array):
    # Assuming image_array is a 2D numpy array representing grayscale image
    
    # Gaussian blur using convolution
    kernel = np.array([[1, 2, 1], [2, 4, 2], [1, 2, 1]]) / 16
    blurred = scipy.ndimage.convolve(image_array, kernel)
    
    # Edge detection using Sobel operator
    sobel_x = np.array([[-1, 0, 1], [-2, 0, 2], [-1, 0, 1]])
    sobel_y = np.array([[-1, -2, -1], [0, 0, 0], [1, 2, 1]])
    
    grad_x = scipy.ndimage.convolve(image_array, sobel_x)
    grad_y = scipy.ndimage.convolve(image_array, sobel_y)
    
    gradient_magnitude = np.sqrt(grad_x**2 + grad_y**2)
    
    return blurred, gradient_magnitude
```

**Financial Modeling Applications**

```python
# Portfolio analysis and risk metrics
def portfolio_analysis(returns, weights):
    """
    Analyze portfolio performance and risk metrics
    returns: 2D array where each column represents asset returns
    weights: 1D array of portfolio weights
    """
    # Portfolio returns
    portfolio_returns = np.dot(returns, weights)
    
    # Risk metrics
    volatility = np.std(portfolio_returns) * np.sqrt(252)  # Annualized
    var_95 = np.percentile(portfolio_returns, 5)  # Value at Risk
    
    # Sharpe ratio calculation
    risk_free_rate = 0.02  # Assumed
    excess_returns = portfolio_returns - risk_free_rate/252
    sharpe_ratio = np.mean(excess_returns) / np.std(excess_returns) * np.sqrt(252)
    
    # Correlation matrix
    correlation_matrix = np.corrcoef(returns.T)
    
    return {
        'portfolio_returns': portfolio_returns,
        'volatility': volatility,
        'var_95': var_95,
        'sharpe_ratio': sharpe_ratio,
        'correlation_matrix': correlation_matrix
    }

# Monte Carlo simulation for option pricing
def monte_carlo_option_pricing(S0, K, T, r, sigma, n_simulations):
    """Black-Scholes Monte Carlo simulation"""
    dt = T / 365
    price_paths = np.zeros((n_simulations, 365))
    price_paths[:, 0] = S0
    
    for t in range(1, 365):
        Z = np.random.standard_normal(n_simulations)
        price_paths[:, t] = price_paths[:, t-1] * np.exp(
            (r - 0.5 * sigma**2) * dt + sigma * np.sqrt(dt) * Z
        )
    
    # Calculate option payoff
    payoffs = np.maximum(price_paths[:, -1] - K, 0)  # Call option
    option_price = np.exp(-r * T) * np.mean(payoffs)
    
    return option_price, price_paths
```

**Machine Learning Preprocessing**

```python
# Feature engineering and preprocessing
class DataPreprocessor:
    def __init__(self):
        self.scalers = {}
        self.encoders = {}
    
    def standardize_features(self, X, feature_names=None):
        """Z-score standardization"""
        mean = np.mean(X, axis=0)
        std = np.std(X, axis=0)
        standardized = (X - mean) / std
        
        self.scalers['standard'] = {'mean': mean, 'std': std}
        return standardized
    
    def normalize_features(self, X, method='min-max'):
        """Feature normalization"""
        if method == 'min-max':
            min_vals = np.min(X, axis=0)
            max_vals = np.max(X, axis=0)
            normalized = (X - min_vals) / (max_vals - min_vals)
            self.scalers['minmax'] = {'min': min_vals, 'max': max_vals}
        elif method == 'robust':
            median = np.median(X, axis=0)
            mad = np.median(np.abs(X - median), axis=0)
            normalized = (X - median) / mad
            self.scalers['robust'] = {'median': median, 'mad': mad}
        
        return normalized
    
    def create_polynomial_features(self, X, degree=2):
        """Generate polynomial features"""
        n_samples, n_features = X.shape
        n_output_features = 1
        
        # Calculate number of polynomial features
        for d in range(1, degree + 1):
            n_output_features += np.math.comb(n_features + d - 1, d)
        
        poly_features = np.ones((n_samples, n_output_features))
        feature_idx = 1
        
        # Generate polynomial combinations
        for d in range(1, degree + 1):
            for combo in itertools.combinations_with_replacement(range(n_features), d):
                poly_features[:, feature_idx] = np.prod(X[:, combo], axis=1)
                feature_idx += 1
        
        return poly_features
```

**Simulation and Modeling Projects**

```python
# Physical simulation example: Particle dynamics
def simulate_particle_system(n_particles, n_steps, dt=0.01):
    """Simulate N-body particle system with gravity"""
    # Initialize positions and velocities
    positions = np.random.random((n_particles, 2)) * 10
    velocities = np.random.random((n_particles, 2)) * 2 - 1
    masses = np.random.random(n_particles) * 5 + 1
    
    # Store trajectory
    trajectory = np.zeros((n_steps, n_particles, 2))
    
    G = 1.0  # Gravitational constant
    
    for step in range(n_steps):
        # Calculate forces between all particle pairs
        forces = np.zeros((n_particles, 2))
        
        for i in range(n_particles):
            for j in range(i + 1, n_particles):
                # Vector from i to j
                r_vec = positions[j] - positions[i]
                r_mag = np.linalg.norm(r_vec)
                
                if r_mag > 0.1:  # Avoid singularity
                    # Gravitational force magnitude
                    F_mag = G * masses[i] * masses[j] / r_mag**2
                    F_vec = F_mag * r_vec / r_mag
                    
                    forces[i] += F_vec
                    forces[j] -= F_vec
        
        # Update velocities and positions (Euler integration)
        accelerations = forces / masses.reshape(-1, 1)
        velocities += accelerations * dt
        positions += velocities * dt
        
        # Store current positions
        trajectory[step] = positions.copy()
    
    return trajectory

# Epidemiological modeling (SIR model)
def sir_model(S0, I0, R0, beta, gamma, t_max, dt=0.1):
    """Simulate SIR epidemic model"""
    t = np.arange(0, t_max, dt)
    n_steps = len(t)
    
    S = np.zeros(n_steps)
    I = np.zeros(n_steps)
    R = np.zeros(n_steps)
    
    S[0], I[0], R[0] = S0, I0, R0
    N = S0 + I0 + R0
    
    for i in range(1, n_steps):
        dS = -beta * S[i-1] * I[i-1] / N
        dI = beta * S[i-1] * I[i-1] / N - gamma * I[i-1]
        dR = gamma * I[i-1]
        
        S[i] = S[i-1] + dS * dt
        I[i] = I[i-1] + dI * dt
        R[i] = R[i-1] + dR * dt
    
    return t, S, I, R
```

