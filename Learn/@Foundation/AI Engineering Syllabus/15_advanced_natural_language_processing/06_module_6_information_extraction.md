## Module 6: Information Extraction


### 6.1 Information Extraction Fundamentals

- IE task definition and scope
- IE pipeline architecture
- Structured vs unstructured data
- Knowledge base population
- Applications of IE
- Semi-structured IE (HTML, XML)
- Evaluation frameworks

### 6.2 Named Entity Recognition (NER)

- Entity types and taxonomies
- Sequence labeling formulation
- IOB/BIO tagging scheme
- IOBES tagging
- Traditional NER approaches
    - Rule-based systems
    - Gazetteer-based methods
    - CRF (Conditional Random Fields)
- Feature engineering for NER
- Context window optimization

### 6.3 Neural NER Models

- BiLSTM-CRF architecture
- Character-level representations
- CNN for character embeddings
- Multi-task learning for NER
- Transfer learning approaches
- Domain adaptation for NER

### 6.4 Transformer-Based NER

- BERT for NER
- Token classification approach
- Whole word masking considerations
- Fine-tuning strategies
- Subword tokenization challenges
- Nested NER
- Discontinuous entity recognition
- Few-shot NER
- Zero-shot NER with prompting

### 6.5 Relation Extraction

- Relation types and schemas
- Binary relation extraction
- Supervised relation extraction
- Distant supervision
- Bootstrapping methods
- Pattern-based extraction
- Kernel methods for RE
- Feature-based models

### 6.6 Neural Relation Extraction

- CNN for relation extraction
- LSTM for relation extraction
- Attention mechanisms for RE
- Entity position embeddings
- Graph convolutional networks for RE
- Transformer-based RE
- Joint entity and relation extraction
- End-to-end IE models

### 6.7 Event Extraction

- Event definition and representation
- Event triggers and arguments
- Event detection
- Argument role labeling
- Event coreference
- Temporal event extraction
- Document-level event extraction
- Cross-sentence event extraction
- ACE event extraction standard

### 6.8 Coreference Resolution

- Mention detection
- Mention clustering
- Anaphor resolution
- Cataphora handling
- Pronoun resolution
- Neural coreference models
- End-to-end coreference systems
- Entity linking vs coreference
- Evaluation metrics (MUC, B³, CEAF, CoNLL)

### 6.9 Knowledge Graph Construction

- Knowledge graph fundamentals
- Triple extraction (subject, predicate, object)
- Open IE systems
- Entity disambiguation
- Relation canonicalization
- Knowledge graph completion
- Link prediction
- Entity alignment
- Ontology matching

### 6.10 Template Filling and Slot Filling

- Template-based IE
- Slot identification
- Value normalization
- Multi-slot systems
- TAC-KBP evaluations
- Neural template filling
- Generative slot filling

### 6.11 Temporal Information Extraction

- Temporal expression recognition (TIMEX)
- Event ordering
- Temporal relation extraction
- TimeBank and temporal annotation
- Temporal reasoning
- Duration extraction
- Frequency extraction

### 6.12 Entity Linking and Disambiguation

- Entity mention detection
- Candidate generation
- Entity ranking
- Context-based disambiguation
- Coherence models
- Neural entity linking
- Zero-shot entity linking
- Cross-lingual entity linking
- Linking to knowledge bases (Wikipedia, Wikidata)

### 6.13 Open Information Extraction

- Domain-independent extraction
- Verb-based extraction
- Clause-based extraction
- OpenIE systems (ReVerb, OLLIE, ClausIE)
- Confidence scoring
- Extraction canonicalization
- Handling n-ary relations

### 6.14 Domain-Specific IE

- Biomedical IE
    - Gene and protein extraction
    - Drug-disease relations
    - Clinical IE
- Financial IE
    - Company-relation extraction
    - Event extraction from financial news
- Legal IE
    - Contract information extraction
    - Case law extraction
- Scientific IE
    - Citation extraction
    - Method and dataset extraction

### 6.15 Multilingual and Cross-Lingual IE

- Language-agnostic models
- Cross-lingual transfer
- Multilingual BERT for IE
- Code-switching IE
- Low-resource language IE
- Annotation projection
- Parallel corpus exploitation

### 6.16 Weak Supervision and Distant Supervision

- Heuristic-based labeling
- Knowledge base distant supervision
- Noise handling in distant supervision
- Multi-instance learning
- Snorkel framework
- Label aggregation
- Programmatic weak supervision

### 6.17 Few-Shot and Zero-Shot IE

- Meta-learning for IE
- Prompt-based IE
- In-context learning for IE
- Prototypical networks
- Matching networks
- Data augmentation for few-shot IE

### 6.18 IE Evaluation

- Precision, recall, F1 for IE tasks
- Exact vs partial matching
- Relaxed evaluation metrics
- Error analysis for IE
- Annotation quality
- Inter-annotator agreement
- Standard evaluation frameworks (CoNLL, ACE, TAC-KBP)

---

