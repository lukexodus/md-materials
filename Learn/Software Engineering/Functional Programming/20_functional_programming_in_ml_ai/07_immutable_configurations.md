## Immutable Configurations


Immutable configurations represent hyperparameters, model settings, and training parameters as immutable data structures that cannot be modified after creation, ensuring reproducibility, enabling safe concurrent access, and facilitating configuration versioning.

**Configuration as Immutable Data:**

Configurations are represented as frozen dictionaries, named tuples, or dataclass instances with frozen attributes. Once created, configuration values cannot change. New configurations are derived by copying and modifying specific fields, preserving the original:

```python
from dataclasses import dataclass, replace

@dataclass(frozen=True)
class ModelConfig:
    num_layers: int
    hidden_dim: int
    dropout_rate: float
    activation: str

# Creating configuration
config = ModelConfig(num_layers=12, hidden_dim=768, dropout_rate=0.1, activation='gelu')

# Deriving new configuration
modified_config = replace(config, dropout_rate=0.2)
# Original config remains unchanged
```

**Reproducibility Guarantees:**

Immutability guarantees that configuration state cannot drift during execution. Training runs using the same configuration object will use identical hyperparameters throughout, eliminating bugs from accidental mutation. Configurations can be serialized at the start of training and deserialized later to exactly reproduce experimental conditions.

**Versioning and Lineage:**

Configuration history forms an immutable chain where each derived configuration references its parent. This lineage tracking enables understanding how configurations evolved across experiments:

```python
@dataclass(frozen=True)
class ConfigWithLineage:
    params: dict
    parent_hash: str | None
    timestamp: float
    
    def derive(self, **updates):
        new_params = {**self.params, **updates}
        parent_hash = hash(self)
        return ConfigWithLineage(new_params, parent_hash, time.time())
```

**Safe Concurrent Access:**

Immutable configurations can be safely shared across threads and processes without locks or synchronization. Distributed training workers can each hold a reference to the same configuration object without risk of race conditions. Configuration sharing becomes trivial since no worker can modify shared state.

**Configuration Composition:**

Immutable configurations compose through merging, where later configurations override earlier ones. Base configurations provide defaults, with experiment-specific configurations layering modifications:

```python
base_config = TrainingConfig(
    batch_size=32,
    learning_rate=1e-3,
    epochs=100
)

experiment_config = replace(
    base_config,
    learning_rate=5e-4,
    epochs=50
)
```

**Validation at Construction:**

Configuration validation occurs at instantiation time, ensuring all configurations are valid before any computation begins. Invalid configurations cannot exist:

```python
@dataclass(frozen=True)
class ValidatedConfig:
    learning_rate: float
    batch_size: int
    
    def __post_init__(self):
        if self.learning_rate <= 0:
            raise ValueError("Learning rate must be positive")
        if self.batch_size < 1:
            raise ValueError("Batch size must be at least 1")
```

**Configuration as Code:**

Configurations expressed as immutable data structures can be version-controlled directly in source code. Changes to configurations appear as code diffs, enabling review and tracking of experimental variations. Configuration files (JSON, YAML) deserialize into immutable objects, maintaining immutability guarantees.

**Hash-based Caching:**

Immutable configurations can be hashed deterministically for caching and deduplication. Training artifacts (checkpoints, metrics) can be indexed by configuration hash, enabling automatic retrieval of results for previously-seen configurations. Configuration hashes serve as unique identifiers for experimental runs.

**Functional Configuration Updates:**

Configuration updates are expressed as pure functions that take a configuration and return a new configuration:

```python
def increase_capacity(config: ModelConfig, factor: float) -> ModelConfig:
    return replace(
        config,
        num_layers=int(config.num_layers * factor),
        hidden_dim=int(config.hidden_dim * factor)
    )

def enable_augmentation(config: TrainingConfig) -> TrainingConfig:
    return replace(config, use_augmentation=True, augmentation_strength=0.5)
```

**Configuration Search Spaces:**

Hyperparameter search defines a space of immutable configurations to explore. Each configuration candidate is immutable, ensuring evaluation results correspond to specific, unchanging hyperparameter settings. Search algorithms generate new candidate configurations without mutating existing ones, maintaining a complete history of all evaluated configurations.

