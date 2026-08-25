## Word Embeddings and Representations


Word embeddings map discrete tokens to continuous vector representations, capturing semantic relationships and enabling neural network processing.

**Static Embeddings**

**Word2Vec Implementation**

```python
import torch
import torch.nn as nn
import torch.nn.functional as F

class Word2Vec(nn.Module):
    def __init__(self, vocab_size, embedding_dim):
        super(Word2Vec, self).__init__()
        self.embeddings = nn.Embedding(vocab_size, embedding_dim)
        self.linear = nn.Linear(embedding_dim, vocab_size)
        
    def forward(self, inputs):
        embeds = self.embeddings(inputs)
        out = self.linear(embeds)
        return out

# Skip-gram training
def train_skipgram(model, data_loader, optimizer, device):
    model.train()
    total_loss = 0
    
    for center_words, context_words in data_loader:
        center_words = center_words.to(device)
        context_words = context_words.to(device)
        
        optimizer.zero_grad()
        
        # Forward pass
        scores = model(center_words)
        loss = F.cross_entropy(scores, context_words)
        
        # Backward pass
        loss.backward()
        optimizer.step()
        
        total_loss += loss.item()
    
    return total_loss / len(data_loader)
```

**GloVe Integration**

```python
def load_glove_embeddings(glove_path, vocab, embedding_dim):
    embeddings = torch.randn(len(vocab), embedding_dim)
    found = 0
    
    with open(glove_path, 'r', encoding='utf-8') as f:
        for line in f:
            values = line.split()
            word = values[0]
            
            if word in vocab:
                vector = torch.tensor([float(x) for x in values[1:]])
                embeddings[vocab[word]] = vector
                found += 1
    
    print(f"Found embeddings for {found}/{len(vocab)} words")
    return embeddings
```

**Contextual Embeddings**

**Transformer-Based Representations**

```python
from transformers import AutoTokenizer, AutoModel
import torch

class ContextualEmbedder:
    def __init__(self, model_name='bert-base-uncased'):
        self.tokenizer = AutoTokenizer.from_pretrained(model_name)
        self.model = AutoModel.from_pretrained(model_name)
        self.model.eval()
    
    def get_embeddings(self, texts, layer_idx=-1):
        encoded = self.tokenizer(texts, padding=True, 
                                truncation=True, return_tensors='pt')
        
        with torch.no_grad():
            outputs = self.model(**encoded, output_hidden_states=True)
            embeddings = outputs.hidden_states[layer_idx]
        
        return embeddings
```

**Key Points**

- Static embeddings provide consistent representations but lack context sensitivity
- Contextual embeddings capture word meaning variations across different contexts
- Embedding dimensionality affects model capacity and computational requirements
- Pre-trained embeddings often outperform task-specific training on limited data

**Advanced Techniques**

- **Subword Embeddings**: FastText approach captures morphological information
- **Character-Level Embeddings**: Handle out-of-vocabulary words effectively
- **Positional Encodings**: Add sequence order information to embeddings
- [Inference] Optimal embedding strategies depend on task requirements, data availability, and computational constraints

