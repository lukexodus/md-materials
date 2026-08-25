## Azure Blob Storage


Azure Blob Storage is Microsoft's object storage solution optimized for storing massive amounts of unstructured data including text, binary data, documents, media files, and application data.

**Key points:**

- Three blob types: Block blobs (optimized for streaming and storing cloud objects), Page blobs (optimized for random read/write operations), and Append blobs (optimized for append operations)
- Hot, Cool, Cold, and Archive access tiers for cost optimization based on data access frequency
- Supports both REST APIs and client libraries for multiple programming languages
- Built-in security features including encryption at rest and in transit
- Hierarchical namespace capability when used with Data Lake Storage Gen2
- Lifecycle management policies for automatic tier transitions and deletion
- Immutable storage policies for compliance and legal hold requirements

**Example:** A media company stores video files in Block blobs using Hot tier for recently uploaded content, automatically transitioning older content to Cool tier after 30 days, and archiving content older than a year.

