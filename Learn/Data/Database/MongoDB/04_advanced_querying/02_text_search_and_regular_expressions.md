## Text Search and Regular Expressions


MongoDB provides comprehensive text search capabilities through text indexes and the `$text` operator, along with flexible pattern matching using regular expressions. These features enable applications to perform sophisticated text-based queries, from simple keyword searches to complex pattern matching with language-specific considerations.

### Text Indexes and Text Search

#### Creating Text Indexes

Text indexes enable efficient full-text search capabilities by analyzing text content and creating searchable tokens. MongoDB supports text indexes on string fields and arrays of strings.

**Basic text index creation:**

```javascript
// Single field text index
db.articles.createIndex({ title: "text" })

// Multiple field text index
db.articles.createIndex({ 
  title: "text", 
  content: "text", 
  tags: "text" 
})

// Compound index with text and regular fields
db.articles.createIndex({ 
  category: 1, 
  title: "text", 
  content: "text" 
})
```

**Weighted text indexes:**

```javascript
// Assign different weights to fields
db.articles.createIndex(
  { 
    title: "text", 
    content: "text", 
    tags: "text" 
  },
  { 
    weights: { 
      title: 10,    // Title matches are more important
      content: 5,   // Content matches are moderately important
      tags: 1       // Tag matches have default weight
    }
  }
)
```

#### Text Index Options

**Language specification:**

```javascript
db.articles.createIndex(
  { title: "text", content: "text" },
  { 
    default_language: "english",
    language_override: "lang"  // Field name that overrides language per document
  }
)
```

**Custom text index names:**

```javascript
db.articles.createIndex(
  { title: "text", content: "text" },
  { name: "article_text_search" }
)
```

#### Text Index Limitations

- Collections can have at most one text index
- Text indexes cannot be used as the shard key in sharded collections
- Text search queries cannot use hint() to specify which index to use
- [Unverified] Text indexes may have significant storage overhead for large text collections

### `$text` Operator and Scoring

#### Basic Text Search

The `$text` operator performs text search on collections with text indexes:

```javascript
// Simple text search
db.articles.find({ $text: { $search: "mongodb database" } })

// Search with phrase
db.articles.find({ $text: { $search: "\"NoSQL database\"" } })

// Exclude terms using minus sign
db.articles.find({ $text: { $search: "mongodb -mysql" } })
```

#### Text Search Options

**Case sensitivity:**

```javascript
// Case-sensitive search (default is case-insensitive)
db.articles.find({ 
  $text: { 
    $search: "MongoDB", 
    $caseSensitive: true 
  } 
})
```

**Diacritic sensitivity:**

```javascript
// Diacritic-sensitive search
db.articles.find({ 
  $text: { 
    $search: "café", 
    $diacriticSensitive: true 
  } 
})
```

**Language specification:**

```javascript
// Override default language for search
db.articles.find({ 
  $text: { 
    $search: "base de données", 
    $language: "french" 
  } 
})
```

#### Text Search Scoring

MongoDB assigns relevance scores to text search results based on term frequency and field weights:

```javascript
// Include text score in results
db.articles.find(
  { $text: { $search: "mongodb database" } },
  { score: { $meta: "textScore" } }
)

// Sort by text score (highest relevance first)
db.articles.find(
  { $text: { $search: "mongodb database" } },
  { score: { $meta: "textScore" } }
).sort({ score: { $meta: "textScore" } })

// Filter by minimum score
db.articles.find(
  { 
    $text: { $search: "mongodb database" },
    score: { $meta: "textScore" }
  },
  { score: { $meta: "textScore" } }
).find({ score: { $gte: 1.0 } })
```

#### Advanced Text Search Queries

**Combining with other query conditions:**

```javascript
// Text search with additional filters
db.articles.find({
  $text: { $search: "mongodb tutorial" },
  category: "programming",
  publishedDate: { $gte: ISODate("2024-01-01") }
})

// Using $and for multiple text searches (not typically needed)
db.articles.find({
  $and: [
    { $text: { $search: "mongodb" } },
    { category: "database" },
    { author: "John Doe" }
  ]
})
```

**Text search with projection:**

```javascript
// Return only specific fields with text score
db.articles.find(
  { $text: { $search: "mongodb atlas" } },
  { 
    title: 1, 
    author: 1, 
    publishedDate: 1,
    score: { $meta: "textScore" } 
  }
).sort({ score: { $meta: "textScore" } })
```

### Language-Specific Text Search

#### Supported Languages

MongoDB supports text search in multiple languages with language-specific stemming and stop word filtering:

**Commonly supported languages:**

- English (default)
- Spanish (spanish)
- French (french)
- German (german)
- Portuguese (portuguese)
- Italian (italian)
- Russian (russian)
- Turkish (turkish)
- Arabic (arabic)
- Chinese (chinese)
- Japanese (japanese)

#### Document-Level Language Override

```javascript
// Documents with language-specific content
db.articles.insertMany([
  {
    title: "Introduction to MongoDB",
    content: "MongoDB is a document database...",
    lang: "english"
  },
  {
    title: "Introducción a MongoDB",
    content: "MongoDB es una base de datos de documentos...",
    lang: "spanish"
  },
  {
    title: "Introduction à MongoDB",
    content: "MongoDB est une base de données de documents...",
    lang: "french"
  }
])

// Create text index with language override
db.articles.createIndex(
  { title: "text", content: "text" },
  { 
    default_language: "english",
    language_override: "lang"
  }
)
```

#### Language-Specific Search Features

**Stemming:** Words are reduced to their root forms

```javascript
// English stemming example
// Searching for "running" will also match "run", "runs", "ran"
db.articles.find({ $text: { $search: "running" } })
```

**Stop word filtering:** Common words are ignored in search

```javascript
// Stop words like "the", "a", "an" are automatically filtered
db.articles.find({ $text: { $search: "the mongodb database" } })
// Effectively searches for "mongodb database"
```

**Language-specific search:**

```javascript
// Search Spanish content
db.articles.find({ 
  $text: { 
    $search: "base datos", 
    $language: "spanish" 
  } 
})

// Search with automatic language detection per document
db.articles.find({ $text: { $search: "database" } })
// Uses each document's "lang" field for language-specific processing
```

### Regular Expression Queries

#### Basic Regular Expression Syntax

MongoDB supports regular expressions using the `$regex` operator or JavaScript regular expression literals:

```javascript
// Using $regex operator
db.users.find({ email: { $regex: "gmail\\.com$" } })

// Using JavaScript regex literal
db.users.find({ email: /gmail\.com$/ })

// With options
db.users.find({ 
  email: { 
    $regex: "gmail\\.com$", 
    $options: "i"  // Case-insensitive
  } 
})
```

#### Regular Expression Options

**Case-insensitive matching:**

```javascript
// Case-insensitive search
db.products.find({ 
  name: { 
    $regex: "smartphone", 
    $options: "i" 
  } 
})

// Using inline modifier
db.products.find({ name: /smartphone/i })
```

**Multiline matching:**

```javascript
// Multiline mode - ^ and $ match line boundaries
db.articles.find({ 
  content: { 
    $regex: "^Introduction", 
    $options: "m" 
  } 
})
```

**Dot-all mode:**

```javascript
// Dot matches newline characters
db.articles.find({ 
  content: { 
    $regex: "start.*end", 
    $options: "s" 
  } 
})
```

**Extended syntax:**

```javascript
// Allow comments and whitespace in regex
db.collection.find({ 
  field: { 
    $regex: "pattern # comment", 
    $options: "x" 
  } 
})
```

#### Common Regular Expression Patterns

**Email validation:**

```javascript
db.users.find({ 
  email: { 
    $regex: "^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$" 
  } 
})
```

**Phone number patterns:**

```javascript
// US phone number format
db.contacts.find({ 
  phone: { 
    $regex: "^\\+?1?[-.\\s]?\\(?[0-9]{3}\\)?[-.\\s]?[0-9]{3}[-.\\s]?[0-9]{4}$" 
  } 
})
```

**URL matching:**

```javascript
db.bookmarks.find({ 
  url: { 
    $regex: "^https?://[\\w\\.-]+\\.[a-zA-Z]{2,}" 
  } 
})
```

**Word boundary matching:**

```javascript
// Find documents containing "mongo" as a complete word
db.articles.find({ 
  content: { 
    $regex: "\\bmongo\\b", 
    $options: "i" 
  } 
})
```

#### Performance Considerations for Regular Expressions

**Index usage with regular expressions:**

```javascript
// Regex queries starting with ^ can use indexes
db.users.find({ username: /^john/ })  // Can use index

// Regex queries not starting with ^ cannot use indexes efficiently
db.users.find({ username: /john/ })   // Cannot use index effectively
```

**Optimized patterns:**

```javascript
// Efficient - anchored at beginning
db.products.find({ sku: /^ABC/ })

// Less efficient - not anchored
db.products.find({ sku: /ABC/ })

// Very inefficient - starts with wildcard
db.products.find({ sku: /.*ABC/ })
```

### Case-Insensitive Searches

#### Using Regular Expressions for Case-Insensitivity

```javascript
// Case-insensitive exact match
db.users.find({ username: /^johndoe$/i })

// Case-insensitive partial match
db.products.find({ name: /smartphone/i })

// Case-insensitive starts with
db.cities.find({ name: /^new/i })
```

#### Collation for Case-Insensitive Operations

MongoDB provides collation for locale-aware string comparisons:

```javascript
// Create collection with default collation
db.createCollection("users", {
  collation: {
    locale: "en",
    strength: 2  // Case-insensitive and accent-insensitive
  }
})

// Query with case-insensitive collation
db.users.find({ username: "JohnDoe" }).collation({
  locale: "en",
  strength: 2
})

// Create case-insensitive index
db.users.createIndex(
  { username: 1 },
  { 
    collation: { 
      locale: "en", 
      strength: 2 
    } 
  }
)
```

#### Collation Strength Levels

**Strength level options:**

- `1`: Primary (base characters only)
- `2`: Secondary (case-insensitive, accent-sensitive)
- `3`: Tertiary (case-sensitive, accent-sensitive) - default
- `4`: Quaternary (consider punctuation)
- `5`: Identical (binary comparison)

```javascript
// Different collation examples
// Case-insensitive only
db.collection.find({ name: "John" }).collation({
  locale: "en",
  strength: 2
})

// Case and accent insensitive
db.collection.find({ name: "José" }).collation({
  locale: "en", 
  strength: 1
})
```

#### Combining Text Search with Case Sensitivity

```javascript
// Text search is case-insensitive by default
db.articles.find({ $text: { $search: "MongoDB" } })

// Override for case-sensitive text search
db.articles.find({ 
  $text: { 
    $search: "MongoDB", 
    $caseSensitive: true 
  } 
})

// Combine text search with case-insensitive regex
db.articles.find({
  $and: [
    { $text: { $search: "database" } },
    { author: /john/i }
  ]
})
```

#### Performance Optimization Strategies

**Index optimization for text search:**

```javascript
// Compound index for filtered text search
db.articles.createIndex({ 
  category: 1, 
  title: "text", 
  content: "text" 
})

// Query using compound index
db.articles.find({
  category: "programming",
  $text: { $search: "mongodb tutorial" }
})
```

**Regular expression optimization:**

```javascript
// Use indexes with anchored regex patterns
db.users.createIndex({ email: 1 })
db.users.find({ email: /^user.*@example\.com$/i })

// Consider using text indexes for complex pattern matching
db.products.createIndex({ name: "text", description: "text" })
db.products.find({ $text: { $search: "wireless bluetooth" } })
```

**Key points:**

- Text indexes provide more efficient full-text search than regular expressions for word-based queries
- Regular expressions are powerful for pattern matching but should be anchored when possible for better performance
- Collation provides standardized case-insensitive comparisons across different locales
- [Inference] Text search scoring algorithms likely consider term frequency, field weights, and document length, though exact implementation details may vary
- Combining multiple search techniques can provide flexible query capabilities while maintaining reasonable performance

**Related topics:** MongoDB aggregation text search stages, search result highlighting techniques, full-text search performance tuning, and integration with external search engines like Elasticsearch.

---

