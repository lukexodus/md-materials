## Text Preprocessing Pipelines


**Text Preprocessing Fundamentals**

Text preprocessing converts raw text into numerical representations suitable for neural network processing. This involves tokenization, vocabulary building, encoding, and various normalization steps.

```python
import torch
from collections import Counter
from torchtext.data.utils import get_tokenizer
import re

class TextPreprocessor:
    def __init__(self, vocab_size=10000, min_freq=2):
        self.vocab_size = vocab_size
        self.min_freq = min_freq
        self.tokenizer = get_tokenizer('basic_english')
        self.vocab = {}
        self.word_to_idx = {}
        self.idx_to_word = {}
    
    def build_vocabulary(self, texts):
        """Build vocabulary from text corpus"""
        word_counts = Counter()
        for text in texts:
            tokens = self.tokenizer(self.preprocess_text(text))
            word_counts.update(tokens)
        
        # Filter by frequency and limit vocabulary size
        vocab_items = word_counts.most_common(self.vocab_size - 4)  # Reserve special tokens
        vocab_items = [(word, count) for word, count in vocab_items if count >= self.min_freq]
        
        # Add special tokens
        self.word_to_idx = {
            '<PAD>': 0, '<UNK>': 1, '<SOS>': 2, '<EOS>': 3
        }
        
        for i, (word, _) in enumerate(vocab_items):
            self.word_to_idx[word] = i + 4
        
        self.idx_to_word = {idx: word for word, idx in self.word_to_idx.items()}
        self.vocab_size = len(self.word_to_idx)
    
    def preprocess_text(self, text):
        """Clean and normalize text"""
        text = text.lower()
        text = re.sub(r'[^a-zA-Z0-9\s]', '', text)  # Remove punctuation
        text = re.sub(r'\s+', ' ', text).strip()     # Normalize whitespace
        return text
    
    def encode_text(self, text, max_length=None):
        """Convert text to token indices"""
        tokens = self.tokenizer(self.preprocess_text(text))
        indices = [self.word_to_idx.get(token, self.word_to_idx['<UNK>']) for token in tokens]
        
        if max_length:
            if len(indices) > max_length:
                indices = indices[:max_length]
            else:
                indices.extend([self.word_to_idx['<PAD>']] * (max_length - len(indices)))
        
        return torch.tensor(indices, dtype=torch.long)
```

**Tokenization Strategies**

Different tokenization approaches serve various text processing needs:

```python
from transformers import AutoTokenizer  # [Unverified - external dependency]

# Word-level tokenization
word_tokenizer = get_tokenizer('basic_english')
word_tokens = word_tokenizer("Hello world, how are you?")

# Subword tokenization (BPE, WordPiece)
# bert_tokenizer = AutoTokenizer.from_pretrained('bert-base-uncased')
# subword_tokens = bert_tokenizer.tokenize("Hello world, how are you?")

# Character-level tokenization
def char_tokenize(text):
    return list(text)

char_tokens = char_tokenize("Hello world")
```

**Sequence Processing and Padding**

Handling variable-length sequences requires padding and masking strategies:

```python
def collate_text_batch(batch):
    """Custom collate function for variable-length text sequences"""
    texts, labels = zip(*batch)
    
    # Find maximum length in batch
    max_length = max(len(text) for text in texts)
    
    # Pad sequences
    padded_texts = []
    attention_masks = []
    
    for text in texts:
        padding_length = max_length - len(text)
        padded_text = text + [0] * padding_length  # 0 = PAD token
        attention_mask = [1] * len(text) + [0] * padding_length
        
        padded_texts.append(padded_text)
        attention_masks.append(attention_mask)
    
    return {
        'input_ids': torch.tensor(padded_texts),
        'attention_mask': torch.tensor(attention_masks),
        'labels': torch.tensor(labels)
    }
```

**Text Augmentation Techniques**

Text augmentation helps improve model robustness and generalization:

```python
import random

class TextAugmentation:
    def __init__(self):
        pass
    
    def random_word_deletion(self, text, p=0.1):
        """Randomly delete words from text"""
        words = text.split()
        if len(words) == 1:
            return text
        
        new_words = [word for word in words if random.random() > p]
        return ' '.join(new_words) if new_words else random.choice(words)
    
    def random_word_swap(self, text, n=1):
        """Randomly swap positions of words"""
        words = text.split()
        for _ in range(n):
            if len(words) < 2:
                break
            idx1, idx2 = random.sample(range(len(words)), 2)
            words[idx1], words[idx2] = words[idx2], words[idx1]
        return ' '.join(words)
    
    def synonym_replacement(self, text, n=1):
        """Replace words with synonyms [Inference - requires external resources]"""
        # Would typically use WordNet or similar resources
        # Implementation depends on available synonym databases
        return text  # Placeholder
```

**Language-Specific Preprocessing**

Different languages require specialized preprocessing approaches:

```python
class MultilingualPreprocessor:
    def __init__(self, language='en'):
        self.language = language
        self.setup_language_specific_tools()
    
    def setup_language_specific_tools(self):
        """Initialize language-specific processing tools"""
        if self.language == 'en':
            self.tokenizer = get_tokenizer('basic_english')
        elif self.language == 'zh':
            # Chinese text requires character-based or word segmentation
            self.tokenizer = self.chinese_tokenize
        # Add other languages as needed
    
    def chinese_tokenize(self, text):
        """Simple Chinese character tokenization [Inference - may need specialized tools]"""
        # In practice, would use jieba or similar segmentation tools
        return list(text)  # Character-level as fallback
    
    def preprocess_by_language(self, text):
        """Apply language-specific preprocessing"""
        if self.language == 'en':
            return text.lower()
        elif self.language == 'zh':
            # Chinese-specific preprocessing
            return text
        return text
```

**Key Points:**

- Text preprocessing involves tokenization, vocabulary building, and encoding steps
- Variable sequence lengths require padding strategies and attention masks
- Text augmentation techniques improve model robustness through data diversity
- Language-specific preprocessing may require specialized tools and approaches

