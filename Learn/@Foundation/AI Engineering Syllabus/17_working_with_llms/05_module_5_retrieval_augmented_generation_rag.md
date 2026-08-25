## Module 5: Retrieval Augmented Generation (RAG)


### 5.1 RAG Fundamentals

- What is RAG
- Why RAG is needed
- Knowledge cutoff mitigation
- Hallucination reduction approaches
- Grounding in external data
- RAG vs fine-tuning

### 5.2 RAG Architecture Components

#### 5.2.1 Document Processing

- Text extraction
- Chunking strategies
- Chunk size considerations
- Chunk overlap
- Metadata preservation
- Document structure handling

#### 5.2.2 Embedding Generation

- Embedding models selection
- Text-to-vector conversion
- Embedding dimensions
- Model fine-tuning
- Batch processing
- Update strategies

#### 5.2.3 Vector Storage

- Vector database selection (see Module 6 from previous syllabus)
- Indexing strategies
- Similarity search algorithms
- Metadata filtering
- Hybrid search capabilities

#### 5.2.4 Retrieval Layer

- Query processing
- Semantic search
- Keyword search
- Hybrid retrieval
- Re-ranking mechanisms
- Result filtering

#### 5.2.5 Generation Layer

- Context assembly
- Prompt construction
- LLM invocation
- Response generation
- Citation handling
- Source attribution

### 5.3 Chunking Strategies

#### 5.3.1 Fixed-Size Chunking

- Character-based splitting
- Token-based splitting
- Chunk size selection
- Overlap configuration
- Boundary handling

#### 5.3.2 Semantic Chunking

- Sentence-level splitting
- Paragraph-level splitting
- Topic-based segmentation
- Hierarchical chunking
- Context preservation

#### 5.3.3 Document-Structure-Aware Chunking

- Markdown section splitting
- HTML element extraction
- PDF structure parsing
- Table handling
- Code block preservation

### 5.4 Retrieval Techniques

#### 5.4.1 Dense Retrieval

- Semantic similarity search
- Vector distance metrics
- Top-k selection
- Threshold-based filtering
- Embedding quality impact

#### 5.4.2 Sparse Retrieval

- BM25 algorithm
- TF-IDF scoring
- Keyword matching
- Boolean operators
- Query expansion

#### 5.4.3 Hybrid Retrieval

- Dense + sparse combination
- Score fusion methods
- Reciprocal rank fusion
- Weighted scoring
- Multi-stage retrieval

#### 5.4.4 Re-ranking

- Cross-encoder models
- Relevance scoring
- LLM-based re-ranking
- Feature-based ranking
- Diversity promotion

### 5.5 Advanced RAG Patterns

#### 5.5.1 Multi-Query RAG

- Query reformulation
- Multiple perspective queries
- Query decomposition
- Sub-query generation
- Result aggregation

#### 5.5.2 Hierarchical RAG

- Two-stage retrieval
- Summary-first approach
- Document-then-chunk retrieval
- Metadata filtering stages
- Progressive refinement

#### 5.5.3 Iterative RAG

- Retrieval-generation loops
- Follow-up queries
- Progressive context building
- Answer refinement
- Stopping criteria

#### 5.5.4 Agentic RAG

- Dynamic retrieval decisions
- Tool selection
- Query planning
- Result evaluation
- Adaptive strategies

### 5.6 Context Assembly

- Retrieved chunk ordering
- Relevance-based prioritization
- Chronological ordering
- Source diversity
- Context length management
- Token budget allocation

### 5.7 Prompt Engineering for RAG

- Context placement (beginning vs end)
- Instruction formulation
- Citation requirements
- Source attribution prompts
- Grounding instructions
- Hallucination prevention

### 5.8 RAG Evaluation

#### 5.8.1 Retrieval Metrics

- Precision@k
- Recall@k
- Mean Reciprocal Rank (MRR)
- Normalized Discounted Cumulative Gain (NDCG)
- Context relevance scoring

#### 5.8.2 Generation Metrics

- Faithfulness to sources
- Answer relevance
- Completeness
- Citation accuracy
- Coherence
- Fluency

#### 5.8.3 End-to-End Metrics

- User satisfaction
- Task completion rate
- Response time
- Cost per query
- Error rate

### 5.9 RAG Optimization

#### 5.9.1 Retrieval Optimization

- Index tuning
- Query optimization
- Embedding model selection
- Caching strategies
- Pre-filtering techniques

#### 5.9.2 Generation Optimization

- Prompt optimization
- Context compression
- Selective retrieval
- Result caching
- Batch processing

### 5.10 RAG Challenges and Solutions

#### 5.10.1 Common Issues

- Irrelevant retrieval
- [Inference] Context misuse in generation
- Missing information
- Outdated content
- Conflicting sources
- Long-tail queries

#### 5.10.2 Mitigation Strategies

- Retrieval quality improvement
- Query understanding enhancement
- Source validation
- Update mechanisms
- Conflict resolution
- Fallback handling

### 5.11 Production RAG Systems

- Scalability considerations
- Monitoring and logging
- Error handling
- Cost management
- Security and privacy
- Compliance requirements

---

