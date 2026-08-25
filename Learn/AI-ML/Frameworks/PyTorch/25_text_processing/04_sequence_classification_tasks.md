## Sequence Classification Tasks


Sequence classification involves assigning labels to entire text sequences, requiring models to aggregate information across variable-length inputs.

**Binary Classification Implementation**

```python
class TextClassifier(nn.Module):
    def __init__(self, vocab_size, embedding_dim, hidden_dim, num_classes, 
                 pretrained_embeddings=None):
        super(TextClassifier, self).__init__()
        
        self.embedding = nn.Embedding(vocab_size, embedding_dim)
        if pretrained_embeddings is not None:
            self.embedding.weight.data.copy_(pretrained_embeddings)
        
        self.lstm = nn.LSTM(embedding_dim, hidden_dim, batch_first=True, 
                           bidirectional=True)
        self.dropout = nn.Dropout(0.5)
        self.classifier = nn.Linear(hidden_dim * 2, num_classes)
    
    def forward(self, x, lengths=None):
        embedded = self.embedding(x)
        
        if lengths is not None:
            # Pack sequences for variable lengths
            packed = nn.utils.rnn.pack_padded_sequence(
                embedded, lengths, batch_first=True, enforce_sorted=False)
            lstm_out, (hidden, _) = self.lstm(packed)
            lstm_out, _ = nn.utils.rnn.pad_packed_sequence(lstm_out, batch_first=True)
        else:
            lstm_out, (hidden, _) = self.lstm(embedded)
        
        # Use final hidden states from both directions
        final_hidden = torch.cat([hidden[-2], hidden[-1]], dim=1)
        dropped = self.dropout(final_hidden)
        logits = self.classifier(dropped)
        
        return logits
```

**Multi-Class Classification with Attention**

```python
class AttentionClassifier(nn.Module):
    def __init__(self, vocab_size, embedding_dim, hidden_dim, num_classes):
        super(AttentionClassifier, self).__init__()
        
        self.embedding = nn.Embedding(vocab_size, embedding_dim)
        self.lstm = nn.LSTM(embedding_dim, hidden_dim, batch_first=True, 
                           bidirectional=True)
        
        # Attention mechanism
        self.attention = nn.Linear(hidden_dim * 2, 1)
        self.classifier = nn.Linear(hidden_dim * 2, num_classes)
        self.dropout = nn.Dropout(0.5)
    
    def forward(self, x, mask=None):
        embedded = self.embedding(x)
        lstm_out, _ = self.lstm(embedded)
        
        # Compute attention weights
        attention_weights = torch.tanh(self.attention(lstm_out))
        attention_weights = F.softmax(attention_weights, dim=1)
        
        if mask is not None:
            attention_weights = attention_weights * mask.unsqueeze(-1)
            attention_weights = attention_weights / attention_weights.sum(dim=1, keepdim=True)
        
        # Weighted sum of hidden states
        context = torch.sum(attention_weights * lstm_out, dim=1)
        dropped = self.dropout(context)
        logits = self.classifier(dropped)
        
        return logits
```

**Training Pipeline**

```python
def train_classifier(model, train_loader, val_loader, epochs, device):
    criterion = nn.CrossEntropyLoss()
    optimizer = torch.optim.Adam(model.parameters(), lr=1e-3)
    scheduler = torch.optim.lr_scheduler.ReduceLROnPlateau(optimizer, patience=3)
    
    best_val_acc = 0
    
    for epoch in range(epochs):
        # Training phase
        model.train()
        train_loss = 0
        train_correct = 0
        train_total = 0
        
        for batch_idx, (data, targets, lengths) in enumerate(train_loader):
            data, targets = data.to(device), targets.to(device)
            
            optimizer.zero_grad()
            outputs = model(data, lengths)
            loss = criterion(outputs, targets)
            loss.backward()
            optimizer.step()
            
            train_loss += loss.item()
            _, predicted = outputs.max(1)
            train_total += targets.size(0)
            train_correct += predicted.eq(targets).sum().item()
        
        # Validation phase
        model.eval()
        val_loss = 0
        val_correct = 0
        val_total = 0
        
        with torch.no_grad():
            for data, targets, lengths in val_loader:
                data, targets = data.to(device), targets.to(device)
                outputs = model(data, lengths)
                loss = criterion(outputs, targets)
                
                val_loss += loss.item()
                _, predicted = outputs.max(1)
                val_total += targets.size(0)
                val_correct += predicted.eq(targets).sum().item()
        
        train_acc = 100 * train_correct / train_total
        val_acc = 100 * val_correct / val_total
        
        scheduler.step(val_loss)
        
        if val_acc > best_val_acc:
            best_val_acc = val_acc
            torch.save(model.state_dict(), 'best_model.pth')
        
        print(f'Epoch {epoch+1}: Train Acc: {train_acc:.2f}%, Val Acc: {val_acc:.2f}%')
```

**Key Points**

- Sequence aggregation strategies significantly impact classification performance
- Attention mechanisms help identify important sequence positions
- Variable-length sequence handling requires careful batch processing
- Class imbalance considerations affect model training and evaluation

