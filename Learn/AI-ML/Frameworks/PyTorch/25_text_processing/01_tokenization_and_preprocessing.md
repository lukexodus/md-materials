## Tokenization and Preprocessing


Tokenization converts raw text into discrete units (tokens) that neural networks can process, serving as the foundational step in all NLP pipelines.

**Key Points**

- Tokenization strategies significantly impact model performance and vocabulary size
- Preprocessing decisions affect model generalization and robustness
- Modern approaches balance vocabulary efficiency with semantic preservation
- Subword tokenization methods address out-of-vocabulary issues

**Tokenization Approaches**

**Word-Level Tokenization**

```python
import torch
from collections import Counter

def word_tokenizer(text):
    # Basic word splitting with punctuation handling
    tokens = text.lower().split()
    tokens = [token.strip('.,!?;:"()[]') for token in tokens]
    return [token for token in tokens if token]

# Vocabulary building
def build_vocab(texts, min_freq=2):
    counter = Counter()
    for text in texts:
        counter.update(word_tokenizer(text))
    
    vocab = {'<pad>': 0, '<unk>': 1}
    for word, freq in counter.items():
        if freq >= min_freq:
            vocab[word] = len(vocab)
    return vocab
```

**Subword Tokenization**

- **Byte Pair Encoding (BPE)**: Iteratively merges frequent character pairs
- **WordPiece**: Google's approach used in BERT, optimizes likelihood
- **SentencePiece**: Language-agnostic unigram model approach
- **Character-Level**: Processes individual characters as tokens

**Preprocessing Pipeline**

```python
import re
from torch.utils.data import Dataset

class TextPreprocessor:
    def __init__(self, lowercase=True, remove_punctuation=False):
        self.lowercase = lowercase
        self.remove_punctuation = remove_punctuation
    
    def clean_text(self, text):
        # HTML/XML tag removal
        text = re.sub(r'<[^>]+>', '', text)
        
        # URL removal
        text = re.sub(r'http\S+', '', text)
        
        # Normalize whitespace
        text = re.sub(r'\s+', ' ', text).strip()
        
        if self.lowercase:
            text = text.lower()
            
        if self.remove_punctuation:
            text = re.sub(r'[^\w\s]', '', text)
            
        return text
```

**Challenges and Considerations**

- Language-specific tokenization requirements vary significantly
- Handling of special characters, emojis, and multilingual text
- Memory efficiency versus vocabulary coverage tradeoffs
- [Inference] Optimal tokenization strategies depend on specific downstream tasks and available computational resources

