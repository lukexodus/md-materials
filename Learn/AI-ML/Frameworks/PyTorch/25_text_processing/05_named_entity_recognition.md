## Named Entity Recognition


Named Entity Recognition (NER) identifies and classifies named entities within text sequences using sequence labeling approaches.

**BIO Tagging Scheme**

```python
# BIO tagging: B-Beginning, I-Inside, O-Outside
# Example: "Apple Inc. was founded by Steve Jobs"
# Tags:    B-ORG I-ORG O    O       O  B-PER I-PER

class NERTagger(nn.Module):
    def __init__(self, vocab_size, embedding_dim, hidden_dim, num_tags):
        super(NERTagger, self).__init__()
        
        self.embedding = nn.Embedding(vocab_size, embedding_dim)
        self.lstm = nn.LSTM(embedding_dim, hidden_dim, batch_first=True, 
                           bidirectional=True)
        self.hidden2tag = nn.Linear(hidden_dim * 2, num_tags)
        self.dropout = nn.Dropout(0.5)
    
    def forward(self, sentence):
        embedded = self.embedding(sentence)
        lstm_out, _ = self.lstm(embedded)
        dropped = self.dropout(lstm_out)
        tag_scores = self.hidden2tag(dropped)
        return tag_scores
```

**Conditional Random Field (CRF) Integration**

```python
import torch
import torch.nn as nn

class BiLSTM_CRF(nn.Module):
    def __init__(self, vocab_size, embedding_dim, hidden_dim, num_tags):
        super(BiLSTM_CRF, self).__init__()
        
        self.embedding = nn.Embedding(vocab_size, embedding_dim)
        self.lstm = nn.LSTM(embedding_dim, hidden_dim // 2, batch_first=True, 
                           bidirectional=True)
        self.hidden2tag = nn.Linear(hidden_dim, num_tags)
        
        # CRF parameters
        self.num_tags = num_tags
        # Transition scores from tag i to tag j
        self.transitions = nn.Parameter(torch.randn(num_tags, num_tags))
        self.start_transitions = nn.Parameter(torch.randn(num_tags))
        self.end_transitions = nn.Parameter(torch.randn(num_tags))
    
    def _get_lstm_features(self, sentence):
        embedded = self.embedding(sentence)
        lstm_out, _ = self.lstm(embedded)
        lstm_features = self.hidden2tag(lstm_out)
        return lstm_features
    
    def _forward_alg(self, feats, mask):
        # Compute forward scores for CRF
        batch_size, seq_len, num_tags = feats.size()
        
        # Initialize forward scores
        alpha = feats.new_full((batch_size, num_tags), -10000)
        alpha[:, self.start_transitions.argmax()] = self.start_transitions.max()
        
        for t in range(seq_len):
            mask_t = mask[:, t].unsqueeze(1)
            emit_score = feats[:, t].unsqueeze(1)
            
            # Broadcast for transition scores
            alpha_t = alpha.unsqueeze(2) + self.transitions.unsqueeze(0) + emit_score
            alpha = torch.logsumexp(alpha_t, dim=1) * mask_t + alpha * (1 - mask_t)
        
        # Add end transition scores
        alpha = alpha + self.end_transitions.unsqueeze(0)
        return torch.logsumexp(alpha, dim=1)
    
    def _score_sentence(self, feats, tags, mask):
        # Compute score for given tag sequence
        batch_size, seq_len = tags.size()
        score = feats.new_zeros(batch_size)
        
        # Add start transition score
        score += self.start_transitions[tags[:, 0]]
        
        for t in range(seq_len - 1):
            mask_t = mask[:, t]
            score += self.transitions[tags[:, t], tags[:, t + 1]] * mask_t
            score += feats[:, t].gather(1, tags[:, t].unsqueeze(1)).squeeze(1) * mask_t
        
        # Add final emission and end transition scores
        last_tag_indices = mask.sum(1) - 1
        last_tags = tags.gather(1, last_tag_indices.unsqueeze(1)).squeeze(1)
        score += self.end_transitions[last_tags]
        
        return score
    
    def neg_log_likelihood(self, sentence, tags, mask):
        feats = self._get_lstm_features(sentence)
        forward_score = self._forward_alg(feats, mask)
        gold_score = self._score_sentence(feats, tags, mask)
        return (forward_score - gold_score).sum()
```

**Training and Evaluation**

```python
def train_ner_model(model, train_loader, val_loader, epochs, device):
    optimizer = torch.optim.Adam(model.parameters(), lr=1e-3)
    
    for epoch in range(epochs):
        model.train()
        total_loss = 0
        
        for sentences, tags, masks in train_loader:
            sentences = sentences.to(device)
            tags = tags.to(device)
            masks = masks.to(device)
            
            optimizer.zero_grad()
            loss = model.neg_log_likelihood(sentences, tags, masks)
            loss.backward()
            optimizer.step()
            
            total_loss += loss.item()
        
        # Validation
        model.eval()
        val_f1 = evaluate_ner(model, val_loader, device)
        print(f'Epoch {epoch+1}, Loss: {total_loss:.4f}, Val F1: {val_f1:.4f}')

def evaluate_ner(model, data_loader, device):
    model.eval()
    all_predictions = []
    all_labels = []
    
    with torch.no_grad():
        for sentences, tags, masks in data_loader:
            sentences = sentences.to(device)
            masks = masks.to(device)
            
            # Viterbi decoding for best path
            predictions = model.decode(sentences, masks)
            
            # Extract valid tokens (non-padded)
            for pred, label, mask in zip(predictions, tags, masks):
                valid_len = mask.sum().item()
                all_predictions.extend(pred[:valid_len])
                all_labels.extend(label[:valid_len].tolist())
    
    # Calculate F1 score
    from sklearn.metrics import f1_score
    return f1_score(all_labels, all_predictions, average='macro')
```

**Key Points**

- BIO tagging scheme enables consistent entity boundary identification
- CRF layers enforce valid tag sequence constraints
- Evaluation requires entity-level metrics rather than token-level accuracy
- [Inference] Optimal approaches balance model complexity with available training data

