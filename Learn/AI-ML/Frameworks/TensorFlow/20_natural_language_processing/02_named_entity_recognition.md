## Named Entity Recognition


Named Entity Recognition (NER) identifies and classifies named entities within text into predefined categories such as persons, organizations, locations, dates, and monetary values. TensorFlow supports both token-level and span-level NER approaches using sequence labeling architectures.

**Key Points:**

- Token-level classification using BIO (Begin-Inside-Outside) or BILOU tagging schemes
- Sequence-to-sequence models for handling variable-length entity spans
- Conditional Random Fields (CRF) layers for enforcing label consistency
- Multi-task learning combining NER with part-of-speech tagging or dependency parsing

TensorFlow's implementation typically employs bidirectional LSTM or GRU networks with CRF output layers. The CRF layer ensures that label sequences follow valid patterns (e.g., I-PER cannot follow B-LOC). Attention mechanisms can improve performance by allowing the model to focus on relevant context when making entity predictions.

**Examples:**

- Biomedical NER for extracting drug names, diseases, and proteins from research papers
- Financial NER for identifying companies, currencies, and monetary amounts in news articles
- Legal document processing for extracting case names, statutes, and legal entities
- Social media NER handling informal text with hashtags, mentions, and abbreviations

Character-level features often complement word-level representations, particularly for handling out-of-vocabulary words and morphologically rich languages. TensorFlow's flexibility allows combining multiple feature types within a single model architecture.

