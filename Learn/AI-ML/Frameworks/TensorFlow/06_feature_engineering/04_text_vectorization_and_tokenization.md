## Text Vectorization and Tokenization


**Tokenization Strategies** Tokenization splits text into meaningful units (tokens) that can be processed by machine learning algorithms.

**Word-Level Tokenization**

- **Whitespace Splitting**: Simplest approach, splits on whitespace characters
- **Punctuation Handling**: Separates punctuation from words
- **Case Normalization**: Converts text to lowercase for consistency
- **Stop Word Removal**: Eliminates common words with little semantic meaning

**Subword Tokenization** Subword tokenization addresses out-of-vocabulary issues by breaking words into smaller units.

**Byte Pair Encoding (BPE)** BPE iteratively merges the most frequent character pairs, building a vocabulary of subword units.

**Advantages**:

- Handles rare and unknown words effectively
- Reduces vocabulary size while maintaining semantic information
- Works well across different languages

**WordPiece Tokenization** WordPiece, used in BERT and similar models, maximizes likelihood of training data given the subword vocabulary.

**SentencePiece** SentencePiece treats text as sequences of Unicode characters, enabling language-agnostic tokenization without requiring pre-tokenization.

**Vectorization Approaches**

**Bag of Words (BoW)** BoW represents text as vectors counting token occurrences, ignoring word order and context.

**Term Frequency-Inverse Document Frequency (TF-IDF)** TF-IDF weights token frequencies by their inverse document frequency, emphasizing distinctive terms.

**Formula**: TF-IDF(t,d) = TF(t,d) × log(N/DF(t))

Where:

- TF(t,d) = frequency of term t in document d
- N = total number of documents
- DF(t) = number of documents containing term t

**Dense Vector Representations** Modern approaches learn dense vector representations that capture semantic relationships.

**Word Embeddings**

- **Word2Vec**: Learns embeddings using skip-gram or continuous bag-of-words objectives
- **GloVe**: Global vectors trained on word co-occurrence statistics
- **FastText**: Extends Word2Vec with subword information

**Contextual Embeddings** Transformer-based models generate context-dependent embeddings:

- **BERT**: Bidirectional encoder representations
- **GPT**: Generative pre-trained transformer embeddings
- **RoBERTa**: Robustly optimized BERT approach

