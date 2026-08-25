## Part-of-Speech Tagging


Part-of-speech tagging assigns grammatical categories to each word in a sequence, requiring understanding of syntactic context and word usage patterns.

**Neural POS Tagger Implementation**

```python
class POSTagger(nn.Module):
    def __init__(self, vocab_size, embedding_dim, hidden_dim, num_pos_tags, 
                 char_vocab_size=None, char_embedding_dim=50):
        super(POSTagger, self).__init__()
        
        # Word-level embeddings
        self.word_embedding = nn.Embedding(vocab_size, embedding_dim)
        
        # Character-level embeddings (optional)
        self.use_char_features = char_vocab_size is not None
        if self.use_char_features:
            self.char_embedding = nn.Embedding(char_vocab_size, char_embedding_dim)
            self.char_lstm = nn.LSTM(char_embedding_dim, char_embedding_dim, 
                                   batch_first=True, bidirectional=True)
            total_embedding_dim = embedding_dim + char_embedding_dim * 2
        else:
            total_embedding_dim = embedding_dim
        
        # Main sequence processing
        self.lstm = nn.LSTM(total_embedding_dim, hidden_dim, batch_first=True, 
                           bidirectional=True)
        self.dropout = nn.Dropout(0.5)
        self.pos_classifier = nn.Linear(hidden_dim * 2, num_pos_tags)
    
    def _get_char_features(self, char_sequences):
        # char_sequences: [batch_size, seq_len, max_word_len]
        batch_size, seq_len, max_word_len = char_sequences.size()
        
        # Reshape for character LSTM
        char_sequences = char_sequences.view(-1, max_word_len)
        char_embedded = self.char_embedding(char_sequences)
        
        # Process characters
        char_output, (char_hidden, _) = self.char_lstm(char_embedded)
        
        # Use final hidden states
        char_features = torch.cat([char_hidden[0], char_hidden[1]], dim=-1)
        char_features = char_features.view(batch_size, seq_len, -1)
        
        return char_features
    
    def forward(self, word_sequences, char_sequences=None):
        # Word embeddings
        word_embedded = self.word_embedding(word_sequences)
        
        # Combine with character features if available
        if self.use_char_features and char_sequences is not None:
            char_features = self._get_char_features(char_sequences)
            combined_features = torch.cat([word_embedded, char_features], dim=-1)
        else:
            combined_features = word_embedded
        
        # Main LSTM processing
        lstm_out, _ = self.lstm(combined_features)
        dropped = self.dropout(lstm_out)
        pos_scores = self.pos_classifier(dropped)
        
        return pos_scores
```

**Data Preparation for POS Tagging**

```python
class POSDataset(torch.utils.data.Dataset):
    def __init__(self, sentences, pos_tags, word_vocab, pos_vocab, char_vocab=None):
        self.sentences = sentences
        self.pos_tags = pos_tags
        self.word_vocab = word_vocab
        self.pos_vocab = pos_vocab
        self.char_vocab = char_vocab
        
    def __len__(self):
        return len(self.sentences)
    
    def __getitem__(self, idx):
        sentence = self.sentences[idx]
        tags = self.pos_tags[idx]
        
        # Convert words to indices
        word_indices = [self.word_vocab.get(word, self.word_vocab['<unk>']) 
                       for word in sentence]
        
        # Convert POS tags to indices
        tag_indices = [self.pos_vocab[tag] for tag in tags]
        
        # Character-level features (if using)
        char_sequences = None
        if self.char_vocab:
            char_sequences = []
            for word in sentence:
                char_indices = [self.char_vocab.get(char, self.char_vocab['<unk>']) 
                              for char in word]
                char_sequences.append(char_indices)
        
        return {
            'words': torch.tensor(word_indices),
            'tags': torch.tensor(tag_indices),
            'chars': char_sequences
        }

def collate_pos_batch(batch):
    # Handle variable length sequences
    words = [item['words'] for item in batch]
    tags = [item['tags'] for item in batch]
    
    # Pad sequences
    words_padded = nn.utils.rnn.pad_sequence(words, batch_first=True)
    tags_padded = nn.utils.rnn.pad_sequence(tags, batch_first=True)
    
    # Create attention masks
    masks = torch.zeros_like(words_padded)
    for i, seq in enumerate(words):
        masks[i, :len(seq)] = 1
    
    return words_padded, tags_padded, masks
```

**Training with Accuracy Metrics**

```python
def train_pos_tagger(model, train_loader, val_loader, epochs, device):
    criterion = nn.CrossEntropyLoss(ignore_index=0)  # Ignore padding
    optimizer = torch.optim.Adam(model.parameters(), lr=1e-3)
    
    best_val_acc = 0
    
    for epoch in range(epochs):
        # Training phase
        model.train()
        train_loss = 0
        train_correct = 0
        train_total = 0
        
        for words, tags, masks in train_loader:
            words, tags, masks = words.to(device), tags.to(device), masks.to(device)
            
            optimizer.zero_grad()
            outputs = model(words)
            
            # Reshape for loss calculation
            outputs = outputs.view(-1, outputs.size(-1))
            tags = tags.view(-1)
            
            loss = criterion(outputs, tags)
            loss.backward()
            optimizer.step()
            
            train_loss += loss.item()
            
            # Calculate accuracy (excluding padding tokens)
            _, predicted = outputs.max(1)
            mask_flat = masks.view(-1).bool()
            train_total += mask_flat.sum().item()
            train_correct += ((predicted == tags) & mask_flat).sum().item()
        
        # Validation phase
        val_acc = evaluate_pos_tagger(model, val_loader, device)
        train_acc = 100 * train_correct / train_total
        
        print(f'Epoch {epoch+1}: Train Acc: {train_acc:.2f}%, Val Acc: {val_acc:.2f}%')
        
        if val_acc > best_val_acc:
            best_val_acc = val_acc
            torch.save(model.state_dict(), 'best_pos_model.pth')

def evaluate_pos_tagger(model, data_loader, device):
    model.eval()
    correct = 0
    total = 0
    
    with torch.no_grad():
        for words, tags, masks in data_loader:
            words, tags, masks = words.to(device), tags.to(device), masks.to(device)
            
            outputs = model(words)
            _, predicted = outputs.max(-1)
            
            # Only count non-padded tokens
            mask_bool = masks.bool()
            total += mask_bool.sum().item()
            correct += ((predicted == tags) & mask_bool).sum().item()
    
    return 100 * correct / total
```

**Advanced Features**

```python
class AdvancedPOSTagger(nn.Module):
    def __init__(self, vocab_size, embedding_dim, hidden_dim, num_pos_tags,
                 num_layers=2, use_crf=True, dropout=0.5):
        super(AdvancedPOSTagger, self).__init__()
        
        self.embedding = nn.Embedding(vocab_size, embedding_dim)
        self.lstm = nn.LSTM(embedding_dim, hidden_dim, num_layers=num_layers,
                           batch_first=True, bidirectional=True, dropout=dropout)
        
        # Multi-layer perceptron for tag scoring
        self.mlp = nn.Sequential(
            nn.Linear(hidden_dim * 2, hidden_dim),
            nn.ReLU(),
            nn.Dropout(dropout),
            nn.Linear(hidden_dim, num_pos_tags)
        )
        
        # Optional CRF layer
        self.use_crf = use_crf
        if use_crf:
            self.crf = CRF(num_pos_tags)
    
    def forward(self, sentences, tags=None, mask=None):
        embedded = self.embedding(sentences)
        lstm_out, _ = self.lstm(embedded)
        emissions = self.mlp(lstm_out)
        
        if self.use_crf:
            if tags is not None:  # Training mode
                loss = -self.crf(emissions, tags, mask=mask, reduction='mean')
                return loss
            else:  # Inference mode
                return self.crf.decode(emissions, mask=mask)
        else:
            return emissions
```

**Morphological Feature Integration**

```python
class MorphologyAwarePOSTagger(nn.Module):
    def __init__(self, vocab_size, embedding_dim, hidden_dim, num_pos_tags,
                 morphological_features_dim=50):
        super(MorphologyAwarePOSTagger, self).__init__()
        
        self.word_embedding = nn.Embedding(vocab_size, embedding_dim)
        
        # Morphological feature embeddings
        self.prefix_embedding = nn.Embedding(100, morphological_features_dim)  # Common prefixes
        self.suffix_embedding = nn.Embedding(100, morphological_features_dim)  # Common suffixes
        self.capitalization_embedding = nn.Embedding(4, 10)  # Cap patterns
        
        total_dim = embedding_dim + morphological_features_dim * 2 + 10
        
        self.lstm = nn.LSTM(total_dim, hidden_dim, batch_first=True, 
                           bidirectional=True)
        self.classifier = nn.Linear(hidden_dim * 2, num_pos_tags)
        self.dropout = nn.Dropout(0.5)
    
    def extract_morphological_features(self, words, word_strings):
        batch_size, seq_len = words.size()
        
        # Extract prefixes, suffixes, capitalization patterns
        prefix_indices = torch.zeros_like(words)
        suffix_indices = torch.zeros_like(words)
        cap_indices = torch.zeros_like(words)
        
        for i, sentence in enumerate(word_strings):
            for j, word in enumerate(sentence):
                # Prefix features (first 3 characters)
                prefix = word[:3].lower()
                prefix_indices[i, j] = self.get_feature_index(prefix, 'prefix')
                
                # Suffix features (last 3 characters)
                suffix = word[-3:].lower()
                suffix_indices[i, j] = self.get_feature_index(suffix, 'suffix')
                
                # Capitalization patterns
                if word.isupper():
                    cap_indices[i, j] = 0  # All caps
                elif word.istitle():
                    cap_indices[i, j] = 1  # Title case
                elif word.islower():
                    cap_indices[i, j] = 2  # All lower
                else:
                    cap_indices[i, j] = 3  # Mixed case
        
        return prefix_indices, suffix_indices, cap_indices
    
    def get_feature_index(self, feature, feature_type):
        # [Inference] This would typically use pre-built vocabularies
        # Simplified hash-based mapping for demonstration
        return hash(feature + feature_type) % 100
    
    def forward(self, words, word_strings):
        word_embedded = self.word_embedding(words)
        
        # Extract morphological features
        prefix_idx, suffix_idx, cap_idx = self.extract_morphological_features(words, word_strings)
        
        prefix_embedded = self.prefix_embedding(prefix_idx)
        suffix_embedded = self.suffix_embedding(suffix_idx)
        cap_embedded = self.capitalization_embedding(cap_idx)
        
        # Concatenate all features
        combined_features = torch.cat([
            word_embedded, prefix_embedded, suffix_embedded, cap_embedded
        ], dim=-1)
        
        lstm_out, _ = self.lstm(combined_features)
        dropped = self.dropout(lstm_out)
        pos_scores = self.classifier(dropped)
        
        return pos_scores
```

**Cross-Lingual POS Tagging**

```python
class CrossLingualPOSTagger(nn.Module):
    def __init__(self, source_vocab_size, target_vocab_size, embedding_dim, 
                 hidden_dim, num_pos_tags, shared_embedding_dim=300):
        super(CrossLingualPOSTagger, self).__init__()
        
        # Language-specific embeddings
        self.source_embedding = nn.Embedding(source_vocab_size, embedding_dim)
        self.target_embedding = nn.Embedding(target_vocab_size, embedding_dim)
        
        # Shared cross-lingual representation layer
        self.projection = nn.Linear(embedding_dim, shared_embedding_dim)
        
        # Shared LSTM and classifier
        self.lstm = nn.LSTM(shared_embedding_dim, hidden_dim, batch_first=True,
                           bidirectional=True)
        self.classifier = nn.Linear(hidden_dim * 2, num_pos_tags)
        self.dropout = nn.Dropout(0.5)
    
    def forward(self, words, language='source'):
        if language == 'source':
            embedded = self.source_embedding(words)
        else:
            embedded = self.target_embedding(words)
        
        # Project to shared space
        projected = torch.tanh(self.projection(embedded))
        
        # Shared processing
        lstm_out, _ = self.lstm(projected)
        dropped = self.dropout(lstm_out)
        pos_scores = self.classifier(dropped)
        
        return pos_scores
    
    def domain_adversarial_loss(self, source_features, target_features):
        # Gradient reversal layer would be implemented here
        # [Inference] This requires custom autograd functions for gradient reversal
        domain_classifier = nn.Linear(source_features.size(-1), 2)
        
        source_domain_scores = domain_classifier(source_features)
        target_domain_scores = domain_classifier(target_features)
        
        source_labels = torch.zeros(source_features.size(0), dtype=torch.long)
        target_labels = torch.ones(target_features.size(0), dtype=torch.long)
        
        domain_loss = F.cross_entropy(source_domain_scores, source_labels) + \
                     F.cross_entropy(target_domain_scores, target_labels)
        
        return domain_loss
```

**Evaluation Metrics and Analysis**

```python
def detailed_pos_evaluation(model, test_loader, pos_vocab, device):
    model.eval()
    predictions = []
    true_labels = []
    
    idx_to_pos = {idx: pos for pos, idx in pos_vocab.items()}
    
    with torch.no_grad():
        for words, tags, masks in test_loader:
            words, tags, masks = words.to(device), tags.to(device), masks.to(device)
            
            if hasattr(model, 'use_crf') and model.use_crf:
                batch_predictions = model(words, mask=masks)
                for pred, tag, mask in zip(batch_predictions, tags, masks):
                    valid_len = mask.sum().item()
                    predictions.extend(pred[:valid_len])
                    true_labels.extend(tag[:valid_len].cpu().numpy())
            else:
                outputs = model(words)
                _, predicted = outputs.max(-1)
                
                for pred, tag, mask in zip(predicted, tags, masks):
                    valid_len = mask.sum().item()
                    predictions.extend(pred[:valid_len].cpu().numpy())
                    true_labels.extend(tag[:valid_len].cpu().numpy())
    
    # Convert indices back to POS tags
    pred_tags = [idx_to_pos[idx] for idx in predictions]
    true_tags = [idx_to_pos[idx] for idx in true_labels]
    
    # Calculate metrics
    from sklearn.metrics import classification_report, confusion_matrix
    
    print("Classification Report:")
    print(classification_report(true_tags, pred_tags))
    
    print("\nConfusion Matrix (top 10 most frequent tags):")
    from collections import Counter
    most_common_tags = [tag for tag, _ in Counter(true_tags).most_common(10)]
    
    # Filter for most common tags
    filtered_true = [tag if tag in most_common_tags else 'OTHER' for tag in true_tags]
    filtered_pred = [tag if tag in most_common_tags else 'OTHER' for tag in pred_tags]
    
    cm = confusion_matrix(filtered_true, filtered_pred, labels=most_common_tags + ['OTHER'])
    
    import numpy as np
    print(np.array2string(cm, separator='\t'))
    
    return pred_tags, true_tags
```

**Key Points**

- Character-level features help handle out-of-vocabulary words and morphological variations
- CRF layers enforce grammatical constraints and improve sequence consistency
- Morphological features capture linguistic patterns beyond word-level information
- Cross-lingual approaches enable knowledge transfer between languages

**Performance Considerations**

- Model complexity affects both accuracy and inference speed
- Feature engineering choices significantly impact performance on specific languages
- [Inference] Optimal architectures vary based on target language morphological complexity
- Memory usage scales with vocabulary size and feature dimensionality

**Error Analysis Techniques**

```python
def analyze_pos_errors(predictions, true_labels, sentences, error_threshold=0.1):
    """Analyze common POS tagging errors for model improvement"""
    
    error_patterns = {}
    total_errors = 0
    
    for pred_seq, true_seq, sent in zip(predictions, true_labels, sentences):
        for i, (pred, true, word) in enumerate(zip(pred_seq, true_seq, sent)):
            if pred != true:
                total_errors += 1
                
                # Context analysis
                left_context = sent[max(0, i-2):i]
                right_context = sent[i+1:min(len(sent), i+3)]
                
                error_key = f"{true}->{pred}"
                if error_key not in error_patterns:
                    error_patterns[error_key] = {
                        'count': 0, 
                        'words': [], 
                        'contexts': []
                    }
                
                error_patterns[error_key]['count'] += 1
                error_patterns[error_key]['words'].append(word)
                error_patterns[error_key]['contexts'].append((left_context, right_context))
    
    # Report frequent error patterns
    sorted_errors = sorted(error_patterns.items(), key=lambda x: x[1]['count'], reverse=True)
    
    print(f"Total errors: {total_errors}")
    print("\nMost frequent error patterns:")
    
    for error_type, info in sorted_errors[:10]:
        if info['count'] / total_errors > error_threshold:
            print(f"{error_type}: {info['count']} occurrences")
            print(f"  Common words: {list(set(info['words'][:10]))}")
            print(f"  Example context: {info['contexts'][0]}")
            print()
    
    return error_patterns
```

**Related Topics**: Dependency parsing, syntactic analysis, multilingual NLP, transformer-based sequence labeling, and neural machine translation provide complementary approaches to understanding and processing textual linguistic structures beyond these fundamental text processing techniques.

---

