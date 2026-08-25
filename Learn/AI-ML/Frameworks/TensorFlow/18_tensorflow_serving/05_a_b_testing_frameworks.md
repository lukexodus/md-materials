## A/B Testing Frameworks


A/B testing frameworks enable controlled experiments comparing different model versions or configurations in production environments. TensorFlow Serving supports sophisticated traffic routing and experimental design capabilities.

**Key Points:**

- Traffic splitting distributes requests between experimental variants
- Statistical significance testing ensures reliable experimental results
- Multi-armed bandit algorithms optimize traffic allocation dynamically
- Contextual routing enables targeted experiments based on user attributes

### Traffic Splitting Implementation

```python
# Traffic routing and experiment management
class ABTestingFramework:
    def __init__(self, serving_clients, metrics_collector):
        self.serving_clients = serving_clients  # Dict of model_version -> client
        self.metrics_collector = metrics_collector
        self.experiments = {}
        self.routing_rules = {}
    
    def create_experiment(self, experiment_id, variants, traffic_allocation, 
                         success_metric='accuracy', minimum_sample_size=1000):
        """Create new A/B testing experiment"""
        experiment = {
            'id': experiment_id,
            'variants': variants,  # {'control': version_1, 'treatment': version_2}
            'traffic_allocation': traffic_allocation,  # {'control': 0.5, 'treatment': 0.5}
            'success_metric': success_metric,
            'minimum_sample_size': minimum_sample_size,
            'start_time': time.time(),
            'status': 'running',
            'results': {variant: {'requests': 0, 'metrics': []} for variant in variants}
        }
        
        self.experiments[experiment_id] = experiment
        return experiment
    
    def route_request(self, request_data, experiment_id=None, user_context=None):
        """Route request to appropriate model variant"""
        if experiment_id not in self.experiments:
            # Default routing to latest stable version
            return self._route_to_default(request_data)
        
        experiment = self.experiments[experiment_id]
        
        # Determine variant assignment
        variant = self._assign_variant(experiment, user_context)
        model_version = experiment['variants'][variant]
        
        # Route to appropriate serving client
        client = self.serving_clients[model_version]
        
        try:
            # Make prediction
            start_time = time.time()
            result = client.predict(request_data)
            latency = time.time() - start_time
            
            # Record metrics
            self._record_experiment_result(experiment_id, variant, {
                'latency': latency,
                'success': True,
                'prediction': result,
                'timestamp': time.time()
            })
            
            return {
                'prediction': result,
                'variant': variant,
                'experiment_id': experiment_id
            }
        
        except Exception as e:
            # Record failure
            self._record_experiment_result(experiment_id, variant, {
                'latency': None,
                'success': False,
                'error': str(e),
                'timestamp': time.time()
            })
            raise
    
    def _assign_variant(self, experiment, user_context=None):
        """Assign user to experiment variant"""
        # Simple random assignment based on traffic allocation
        if user_context and 'user_id' in user_context:
            # Consistent assignment based on user ID hash
            import hashlib
            user_hash = int(hashlib.md5(user_context['user_id'].encode()).hexdigest(), 16)
            threshold = user_hash % 100 / 100.0
        else:
            # Random assignment
            threshold = np.random.random()
        
        cumulative_prob = 0
        for variant, probability in experiment['traffic_allocation'].items():
            cumulative_prob += probability
            if threshold <= cumulative_prob:
                return variant
        
        # Fallback to first variant
        return list(experiment['variants'].keys())[0]
    
    def _record_experiment_result(self, experiment_id, variant, result):
        """Record experiment result for analysis"""
        if experiment_id in self.experiments:
            experiment = self.experiments[experiment_id]
            experiment['results'][variant]['requests'] += 1
            experiment['results'][variant]['metrics'].append(result)
    
    def analyze_experiment(self, experiment_id, confidence_level=0.95):
        """Analyze experiment results with statistical significance"""
        if experiment_id not in self.experiments:
            return None
        
        experiment = self.experiments[experiment_id]
        results = experiment['results']
        
        # Check minimum sample size
        total_requests = sum(r['requests'] for r in results.values())
        if total_requests < experiment['minimum_sample_size']:
            return {
                'status': 'insufficient_data',
                'total_requests': total_requests,
                'minimum_required': experiment['minimum_sample_size']
            }
        
        # Calculate metrics for each variant
        variant_stats = {}
        for variant, data in results.items():
            metrics = data['metrics']
            successful_requests = [m for m in metrics if m['success']]
            
            if successful_requests:
                latencies = [m['latency'] for m in successful_requests if m['latency']]
                success_rate = len(successful_requests) / len(metrics)
                
                variant_stats[variant] = {
                    'requests': len(metrics),
                    'success_rate': success_rate,
                    'avg_latency': np.mean(latencies) if latencies else None,
                    'p95_latency': np.percentile(latencies, 95) if latencies else None,
                    'error_rate': 1 - success_rate
                }
        
        # Statistical significance test
        significance_test = self._calculate_significance(variant_stats, confidence_level)
        
        # Determine winner
        winner = self._determine_winner(variant_stats, experiment['success_metric'])
        
        return {
            'status': 'complete' if significance_test['significant'] else 'inconclusive',
            'variant_stats': variant_stats,
            'significance_test': significance_test,
            'winner': winner,
            'confidence_level': confidence_level
        }
    
    def _calculate_significance(self, variant_stats, confidence_level):
        """Calculate statistical significance between variants"""
        from scipy import stats
        
        if len(variant_stats) != 2:
            return {'significant': False, 'reason': 'Only supports two-variant tests'}
        
        variants = list(variant_stats.keys())
        control_data = variant_stats[variants[0]]
        treatment_data = variant_stats[variants[1]]
        
        # Z-test for success rate difference
        n1, n2 = control_data['requests'], treatment_data['requests']
        p1, p2 = control_data['success_rate'], treatment_data['success_rate']
        
        if n1 < 30 or n2 < 30:
            return {'significant': False, 'reason': 'Insufficient sample size for significance test'}
        
        # Pooled standard error
        p_pool = (p1 * n1 + p2 * n2) / (n1 + n2)
        se = np.sqrt(p_pool * (1 - p_pool) * (1/n1 + 1/n2))
        
        if se == 0:
            return {'significant': False, 'reason': 'No variance in success rates'}
        
        # Z-score and p-value
        z_score = (p2 - p1) / se
        p_value = 2 * (1 - stats.norm.cdf(abs(z_score)))
        
        alpha = 1 - confidence_level
        significant = p_value < alpha
        
        return {
            'significant': significant,
            'p_value': p_value,
            'z_score': z_score,
            'confidence_level': confidence_level,
            'effect_size': p2 - p1
        }
    
    def _determine_winner(self, variant_stats, success_metric):
        """Determine winning variant based on success metric"""
        if success_metric == 'success_rate':
            return max(variant_stats.keys(), 
                      key=lambda v: variant_stats[v]['success_rate'])
        elif success_metric == 'latency':
            return min(variant_stats.keys(), 
                      key=lambda v: variant_stats[v]['avg_latency'] or float('inf'))
        elif success_metric == 'error_rate':
            return min(variant_stats.keys(), 
                      key=lambda v: variant_stats[v]['error_rate'])
        else:
            return None

# Multi-armed bandit optimization
class MultiArmedBanditOptimizer:
    def __init__(self, variants, exploration_rate=0.1):
        self.variants = variants
        self.exploration_rate = exploration_rate
        self.variant_stats = {
            variant: {'pulls': 0, 'rewards': 0, 'avg_reward': 0}
            for variant in variants
        }
    
    def select_variant(self):
        """Select variant using epsilon-greedy strategy"""
        if np.random.random() < self.exploration_rate:
            # Exploration: random selection
            return np.random.choice(self.variants)
        else:
            # Exploitation: select best performing variant
            best_variant = max(self.variant_stats.keys(), 
                             key=lambda v: self.variant_stats[v]['avg_reward'])
            return best_variant
    
    def update_reward(self, variant, reward):
        """Update variant performance with new reward"""
        stats = self.variant_stats[variant]
        stats['pulls'] += 1
        stats['rewards'] += reward
        stats['avg_reward'] = stats['rewards'] / stats['pulls']
    
    def get_confidence_bounds(self, confidence=0.95):
        """Calculate confidence bounds for each variant"""
        bounds = {}
        for variant, stats in self.variant_stats.items():
            if stats['pulls'] > 0:
                # Wilson score interval for binomial proportion
                n = stats['pulls']
                p = stats['avg_reward']
                z = 1.96  # 95% confidence
                
                denominator = 1 + z**2/n
                center = (p + z**2/(2*n)) / denominator
                margin = z * np.sqrt((p*(1-p)/n + z**2/(4*n**2))) / denominator
                
                bounds[variant] = {
                    'lower': center - margin,
                    'upper': center + margin,
                    'center': center
                }
        
        return bounds

# Contextual experiment routing
class ContextualExperimentRouter:
    def __init__(self, ab_framework):
        self.ab_framework = ab_framework
        self.routing_rules = []
    
    def add_routing_rule(self, rule_id, condition_func, experiment_id, priority=0):
        """Add contextual routing rule"""
        rule = {
            'id': rule_id,
            'condition': condition_func,
            'experiment_id': experiment_id,
            'priority': priority
        }
        self.routing_rules.append(rule)
        # Sort by priority (higher priority first)
        self.routing_rules.sort(key=lambda r: r['priority'], reverse=True)
    
    def route_request(self, request_data, user_context):
        """Route request based on contextual rules"""
        # Find matching rule
        for rule in self.routing_rules:
            if rule['condition'](user_context):
                return self.ab_framework.route_request(
                    request_data, 
                    experiment_id=rule['experiment_id'],
                    user_context=user_context
                )
        
        # Default routing if no rules match
        return self.ab_framework.route_request(request_data, user_context=user_context)

# Usage example
# Initialize serving clients for different model versions
serving_clients = {
    'v1': TensorFlowServingRESTClient("http://localhost:8501", "model", "1"),
    'v2': TensorFlowServingRESTClient("http://localhost:8501", "model", "2"),
    'v3': TensorFlowServingRESTClient("http://localhost:8501", "model", "3")
}

# Create A/B testing framework
ab_framework = ABTestingFramework(serving_clients, metrics_collector=None)

# Set up experiment
experiment = ab_framework.create_experiment(
    experiment_id="model_v2_vs_v1",
    variants={'control': 'v1', 'treatment': 'v2'},
    traffic_allocation={'control': 0.7, 'treatment': 0.3},
    success_metric='success_rate',
    minimum_sample_size=10000
)

# Set up contextual routing
contextual_router = ContextualExperimentRouter(ab_framework)

# Add rules for different user segments
contextual_router.add_routing_rule(
    rule_id="premium_users",
    condition_func=lambda ctx: ctx.get('user_tier') == 'premium',
    experiment_id="model_v3_premium_test",
    priority=10
)

contextual_router.add_routing_rule(
    rule_id="mobile_users",
    condition_func=lambda ctx: ctx.get('device_type') == 'mobile',
    experiment_id="model_mobile_optimization",
    priority=5
)
```

