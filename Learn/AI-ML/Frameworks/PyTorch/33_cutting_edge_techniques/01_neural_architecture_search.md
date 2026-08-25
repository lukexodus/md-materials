## Neural Architecture Search


Neural Architecture Search automates the design of neural network architectures, moving beyond manual engineering to discover optimal topologies through systematic exploration of architecture spaces.

**Differentiable Architecture Search (DARTS)**

DARTS formulates architecture search as a continuous optimization problem by introducing architecture weights that make the search space differentiable:

```python
import torch
import torch.nn as nn
import torch.nn.functional as F
from torch.autograd import Variable

class MixedOp(nn.Module):
    def __init__(self, C, stride, PRIMITIVES):
        super().__init__()
        self._ops = nn.ModuleList()
        for primitive in PRIMITIVES:
            op = OPS[primitive](C, stride, False)
            self._ops.append(op)
    
    def forward(self, x, weights):
        return sum(w * op(x) for w, op in zip(weights, self._ops))

class Cell(nn.Module):
    def __init__(self, steps, multiplier, C_prev_prev, C_prev, C, reduction):
        super().__init__()
        self.reduction = reduction
        self.steps = steps
        
        if reduction_prev:
            self.preprocess0 = FactorizedReduce(C_prev_prev, C, affine=False)
        else:
            self.preprocess0 = ReLUConvBN(C_prev_prev, C, 1, 1, 0, affine=False)
        
        self.preprocess1 = ReLUConvBN(C_prev, C, 1, 1, 0, affine=False)
        
        self._ops = nn.ModuleList()
        self._bns = nn.ModuleList()
        
        for i in range(self.steps):
            for j in range(2 + i):
                stride = 2 if reduction and j < 2 else 1
                op = MixedOp(C, stride, PRIMITIVES)
                self._ops.append(op)
    
    def forward(self, s0, s1, weights):
        s0 = self.preprocess0(s0)
        s1 = self.preprocess1(s1)
        
        states = [s0, s1]
        offset = 0
        for i in range(self.steps):
            s = sum(self._ops[offset+j](h, weights[offset+j]) for j, h in enumerate(states))
            offset += len(states)
            states.append(s)
        
        return torch.cat(states[-self._multiplier:], dim=1)
```

**Progressive Search Strategies**

Progressive DARTS addresses training instability through curriculum learning approaches:

```python
class ProgressiveSearchSpace:
    def __init__(self, initial_ops=['skip_connect', 'sep_conv_3x3']):
        self.current_ops = initial_ops
        self.all_ops = ['skip_connect', 'sep_conv_3x3', 'sep_conv_5x5', 
                       'dil_conv_3x3', 'dil_conv_5x5', 'max_pool_3x3', 'avg_pool_3x3']
        self.expansion_schedule = [5, 10, 15]  # Epochs to expand search space
        
    def expand_search_space(self, epoch):
        if epoch in self.expansion_schedule:
            remaining_ops = [op for op in self.all_ops if op not in self.current_ops]
            if remaining_ops:
                self.current_ops.extend(remaining_ops[:2])  # Add 2 operations
                return True
        return False
    
    def get_current_primitives(self):
        return self.current_ops

class ProgressiveDARTSTrainer:
    def __init__(self, model, search_space):
        self.model = model
        self.search_space = search_space
        self.architect = Architect(model, args)
        
    def train_epoch(self, train_queue, valid_queue, epoch):
        # Check if search space should be expanded
        if self.search_space.expand_search_space(epoch):
            self._reinitialize_architecture_weights()
        
        for step, (input, target) in enumerate(train_queue):
            # Architecture weight update
            input_search, target_search = next(iter(valid_queue))
            self.architect.step(input, target, input_search, target_search, 
                              self.optimizer, unrolled=args.unrolled)
            
            # Model weight update
            self.optimizer.zero_grad()
            logits = self.model(input)
            loss = criterion(logits, target)
            loss.backward()
            self.optimizer.step()
```

**Evolutionary Architecture Search**

Evolutionary methods explore architecture spaces through mutation and selection:

```python
class EvolutionaryNAS:
    def __init__(self, population_size=50, mutation_rate=0.1):
        self.population_size = population_size
        self.mutation_rate = mutation_rate
        self.population = self._initialize_population()
        
    def _initialize_population(self):
        population = []
        for _ in range(self.population_size):
            genome = {
                'layers': random.randint(8, 20),
                'channels': [random.choice([32, 64, 128, 256]) for _ in range(6)],
                'operations': [random.choice(PRIMITIVES) for _ in range(14)],
                'skip_connections': [random.random() < 0.3 for _ in range(14)]
            }
            population.append(genome)
        return population
    
    def mutate(self, genome):
        mutated = genome.copy()
        if random.random() < self.mutation_rate:
            # Mutate number of layers
            mutated['layers'] += random.choice([-1, 1])
            mutated['layers'] = max(8, min(20, mutated['layers']))
        
        if random.random() < self.mutation_rate:
            # Mutate operations
            idx = random.randint(0, len(mutated['operations'])-1)
            mutated['operations'][idx] = random.choice(PRIMITIVES)
        
        return mutated
    
    def evolve_generation(self, fitness_scores):
        # Selection
        sorted_pop = [x for _, x in sorted(zip(fitness_scores, self.population), reverse=True)]
        elite = sorted_pop[:self.population_size//4]
        
        # Crossover and mutation
        new_population = elite.copy()
        while len(new_population) < self.population_size:
            parent1, parent2 = random.sample(elite, 2)
            child = self._crossover(parent1, parent2)
            child = self.mutate(child)
            new_population.append(child)
        
        self.population = new_population
```

