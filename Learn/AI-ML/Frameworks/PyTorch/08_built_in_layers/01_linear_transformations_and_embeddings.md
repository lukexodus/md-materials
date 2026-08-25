## Linear Transformations and Embeddings


**Linear Layer (torch.nn.Linear)** The fundamental fully connected layer performs linear transformation: y = xW^T + b. Parameters include input features, output features, and optional bias. Commonly used in feedforward networks, classification heads, and attention mechanisms.

**Embedding Layer (torch.nn.Embedding)** Maps discrete tokens to dense vector representations. Essential for natural language processing and recommendation systems. Parameters include vocabulary size, embedding dimension, padding index, and maximum norm constraints. Supports sparse gradients for memory efficiency with large vocabularies.

**EmbeddingBag Layer** Computes sums, means, or max of embeddings without instantiating intermediate embeddings. Memory-efficient for bag-of-words models and variable-length sequences.

