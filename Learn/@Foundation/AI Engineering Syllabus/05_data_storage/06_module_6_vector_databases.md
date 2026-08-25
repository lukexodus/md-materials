## Module 6: Vector Databases


### 6.1 Vector Embeddings Fundamentals

- What are embeddings
- Semantic similarity concepts
- Embedding models and dimensions
- Dense vs sparse vectors
- Use cases: semantic search, RAG, recommendation

### 6.2 Similarity Search Algorithms

- Brute force (exact) search
- Approximate Nearest Neighbor (ANN)
- Locality-Sensitive Hashing (LSH)
- HNSW (Hierarchical Navigable Small World)
- IVF (Inverted File Index)
- Product Quantization
- FAISS algorithms

### 6.3 Distance Metrics

- Euclidean distance (L2)
- Cosine similarity
- Dot product
- Hamming distance
- Manhattan distance (L1)
- Metric selection considerations

### 6.4 Vector Database Systems

#### 6.4.1 Purpose-Built Vector DBs

- Pinecone: Managed service, namespaces, metadata filtering
- Weaviate: GraphQL, modules, hybrid search
- Milvus: Open source, multiple indexes, GPU support
- Qdrant: Rust-based, payload filtering, clustering
- Chroma: Embedded/client-server, simplicity

#### 6.4.2 Extensions to Existing DBs

- pgvector: PostgreSQL extension, indexing options
- Redis Vector Search: Integration with Redis data structures
- Elasticsearch Vector Search: Dense/sparse vectors, hybrid scoring
- MongoDB Atlas Vector Search: Integration with documents

### 6.5 Indexing and Optimization

- Index types and trade-offs
- Build-time vs query-time parameters
- Memory vs disk trade-offs
- Quantization techniques
- Sharding vector data
- Index maintenance and updates

### 6.6 Hybrid Search Patterns

- Keyword + vector combination
- Metadata filtering with vector search
- Reranking strategies
- Multi-vector search
- Cross-encoder scoring

### 6.7 Vector Database Applications

- Retrieval-Augmented Generation (RAG)
- Semantic search engines
- Recommendation systems
- Anomaly detection
- Image/audio similarity search
- Duplicate detection

---

