## Token Filters

Token filters are the final stage of the analyzer pipeline. They receive the token stream produced by the tokenizer and can add, remove, or modify tokens, but unlike character filters they operate on tokens rather than raw characters. An analyzer may chain zero or more token filters, applied in the order they are listed.

### Position in the Analysis Pipeline

Token filters run after the single mandatory tokenizer. Because tokenization has already happened, token filters cannot see across token boundaries except where a filter is explicitly designed to combine or split existing tokens (e.g. `shingle`, `word_delimiter_graph`).

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 800 200">
  <text x="400" y="20" font-size="14" font-weight="bold" text-anchor="middle" fill="#333">Token Filters' Position in the Pipeline (svg_diagram)</text>

  <rect x="20" y="60" width="170" height="60" rx="6" fill="#fef7e0" stroke="#f9ab00" stroke-width="1.5" />
  <text x="105" y="80" font-size="13" text-anchor="middle" fill="#1a1a1a">Character Filters</text>
  <text x="105" y="97" font-size="11" text-anchor="middle" fill="#555">0 or more</text>
  <text x="105" y="112" font-size="10" text-anchor="middle" fill="#777">string → string</text>

  <line x1="190" y1="90" x2="225" y2="90" stroke="#666" stroke-width="1.5" marker-end="url(#arrow3)" />

  <rect x="225" y="60" width="150" height="60" rx="6" fill="#e6f4ea" stroke="#34a853" stroke-width="1.5" />
  <text x="300" y="80" font-size="13" text-anchor="middle" fill="#1a1a1a">Tokenizer</text>
  <text x="300" y="97" font-size="11" text-anchor="middle" fill="#555">exactly 1</text>
  <text x="300" y="112" font-size="10" text-anchor="middle" fill="#777">string → tokens</text>

  <line x1="375" y1="90" x2="410" y2="90" stroke="#666" stroke-width="1.5" marker-end="url(#arrow3)" />

  <rect x="410" y="55" width="190" height="70" rx="6" fill="#fce8e6" stroke="#ea4335" stroke-width="2.5" />
  <text x="505" y="78" font-size="13" font-weight="bold" text-anchor="middle" fill="#1a1a1a">Token Filters</text>
  <text x="505" y="95" font-size="11" text-anchor="middle" fill="#555">0 or more, in order</text>
  <text x="505" y="110" font-size="10" text-anchor="middle" fill="#777">tokens → tokens</text>

  <line x1="600" y1="90" x2="635" y2="90" stroke="#666" stroke-width="1.5" marker-end="url(#arrow3)" />

  <rect x="635" y="60" width="145" height="60" rx="6" fill="#e8f0fe" stroke="#4285f4" stroke-width="1.5" />
  <text x="707" y="85" font-size="13" text-anchor="middle" fill="#1a1a1a">Inverted Index</text>

  <text x="505" y="150" font-size="11" text-anchor="middle" fill="#888">Can add tokens (synonyms), remove tokens (stopwords),</text>
  <text x="505" y="165" font-size="11" text-anchor="middle" fill="#888">or transform tokens (stemming, lowercasing) in place.</text>
</svg>

### Categories of Built-in Token Filters

Elasticsearch's built-in token filters can be grouped functionally: normalization, stemming, stopword removal, synonym expansion, n-gram generation, and language-specific transformations.

**Normalization Filters**

| Filter | Behavior |
|---|---|
| `lowercase` | Converts token text to lowercase |
| `uppercase` | Converts token text to uppercase |
| `trim` | Removes leading/trailing whitespace from tokens |
| `asciifolding` | Converts non-ASCII characters to their closest ASCII equivalent (e.g. `é` → `e`) |
| `decimal_digit` | Converts Unicode decimal digits from other scripts to `0`-`9` |

```json
POST _analyze
{
  "tokenizer": "standard",
  "filter": ["lowercase", "asciifolding"],
  "text": "Café MÜNCHEN"
}
```

This produces `cafe` and `munchen` — case is normalized and diacritics are stripped, widening recall for users who type without accents.

**Stemming Filters**

| Filter | Behavior |
|---|---|
| `stemmer` | Applies algorithmic stemming (e.g. Porter, Snowball) for a specified `language` |
| `kstem` | A lower-aggressiveness stemmer for English, largely dictionary-based |
| `porter_stem` | Applies the classic Porter stemming algorithm for English specifically |
| `snowball` | Applies Snowball-family stemmers across multiple languages |

```json
POST _analyze
{
  "tokenizer": "standard",
  "filter": [{"type": "stemmer", "language": "english"}],
  "text": "running runs jumped"
}
```

This produces `running` → `run`... wait — [Unverified] the exact stem forms depend on the specific stemming algorithm variant configured (e.g. `english`, `light_english`, `possessive_english` each behave slightly differently), so verifying output against the live `_analyze` API for the exact `language` value in use is advisable rather than assuming a single canonical stem per word.

**Stopword Filters**

| Filter | Behavior |
|---|---|
| `stop` | Removes stopwords from a configurable or predefined language list |

```json
PUT stop_example
{
  "settings": {
    "analysis": {
      "analyzer": {
        "my_stop_analyzer": {
          "tokenizer": "standard",
          "filter": ["lowercase", "my_stopwords"]
        }
      },
      "filter": {
        "my_stopwords": {
          "type": "stop",
          "stopwords": "_english_"
        }
      }
    }
  }
}

POST stop_example/_analyze
{
  "analyzer": "my_stop_analyzer",
  "text": "The quick fox is fast"
}
```

This produces `quick`, `fox`, `fast` — `the` and `is` are removed as English stopwords. A custom stopword list can be supplied via `stopwords` (inline array) or `stopwords_path` (file reference) instead of `_english_`.

**Synonym Filters**

| Filter | Behavior |
|---|---|
| `synonym` | Expands or replaces tokens using a configured synonym list, applied at analysis time |
| `synonym_graph` | Like `synonym`, but preserves correct token graph structure for multi-word synonyms, important for phrase queries |

```json
PUT synonym_example
{
  "settings": {
    "analysis": {
      "analyzer": {
        "my_synonym_analyzer": {
          "tokenizer": "standard",
          "filter": ["lowercase", "my_synonyms"]
        }
      },
      "filter": {
        "my_synonyms": {
          "type": "synonym",
          "synonyms": ["fast, quick, speedy"]
        }
      }
    }
  }
}

POST synonym_example/_analyze
{
  "analyzer": "my_synonym_analyzer",
  "text": "quick fox"
}
```

This produces `quick` and `fast` as co-located tokens at the same position (`speedy` too), meaning a search for any of the three terms matches. `synonym_graph` is generally preferred over `synonym` when multi-word synonyms are involved and the field is also used with phrase or span queries, since it maintains an accurate positional token graph.

**N-gram Filters**

| Filter | Behavior |
|---|---|
| `ngram` | Generates n-gram substrings from existing tokens (post-tokenization, unlike the `ngram` tokenizer) |
| `edge_ngram` | Generates prefix-anchored substrings from existing tokens |

```json
POST _analyze
{
  "tokenizer": "standard",
  "filter": [{"type": "edge_ngram", "min_gram": 1, "max_gram": 3}],
  "text": "fox"
}
```

This produces `f`, `fo`, `fox`. The filter form operates after word tokenization, whereas the tokenizer form of `edge_ngram` operates on the raw string directly — the choice affects whether n-grams can cross whitespace boundaries.

**Word Delimiter Filters**

| Filter | Behavior |
|---|---|
| `word_delimiter` | Splits tokens on delimiters (e.g. hyphens, underscores, case changes) and can also generate combined forms |
| `word_delimiter_graph` | Like `word_delimiter`, but preserves correct token graph structure |

```json
POST _analyze
{
  "tokenizer": "keyword",
  "filter": ["word_delimiter_graph"],
  "text": "Wi-Fi-2024"
}
```

This produces `Wi`, `Fi`, `2024` as separate tokens (with additional configuration options controlling whether concatenated forms like `WiFi` are also generated). `word_delimiter_graph` is the version generally recommended over `word_delimiter` for the same token-graph-correctness reasons as `synonym_graph`.

**Other Common Filters**

| Filter | Behavior |
|---|---|
| `unique` | Removes duplicate tokens at the same position |
| `reverse` | Reverses the characters of each token (used for suffix matching with wildcard-style queries) |
| `truncate` | Truncates tokens to a configurable maximum length |
| `length` | Removes tokens that fall outside a configured min/max character length |
| `shingle` | Generates word n-grams (multi-word combinations) from the token stream, useful for phrase-like matching |

### Filter Ordering Matters

Because token filters apply sequentially, their order changes the outcome. Placing `lowercase` before a `stop` filter configured with lowercase stopwords is necessary for the stopword list to match correctly, since `stop` performs exact string matching against its configured list.

```json
POST _analyze
{
  "tokenizer": "standard",
  "filter": ["stop", "lowercase"],
  "text": "The Fox"
}
```

With this ordering, `The` is compared against the stopword list before being lowercased — if the stopword list contains only lowercase `the`, the uppercase `The` token is not removed, and both `The` and `Fox` (lowercased) survive. Reversing the order to `["lowercase", "stop"]` correctly removes `the`.

### Custom Token Filter Configuration in an Analyzer

```json
PUT custom_filter_example
{
  "settings": {
    "analysis": {
      "analyzer": {
        "full_pipeline": {
          "type": "custom",
          "tokenizer": "standard",
          "filter": [
            "lowercase",
            "my_stopwords",
            {"type": "stemmer", "language": "light_english"}
          ]
        }
      },
      "filter": {
        "my_stopwords": {
          "type": "stop",
          "stopwords": "_english_"
        }
      }
    }
  }
}
```

This assembles a pipeline that lowercases, removes English stopwords, and applies light English stemming, in that order.

### Performance Considerations

**Key Points**
- Filter order affects both correctness (as shown above) and performance; placing a `stop` filter before expensive filters like `stemmer` or `synonym` reduces the number of tokens those later filters must process.
- `synonym` and `synonym_graph` filters are typically loaded once at analyzer initialization; [Inference] very large synonym files can increase node startup or index-open time and memory footprint, though the magnitude depends on synonym list size and update frequency.
- `shingle` and `ngram`-family filters multiply the number of tokens produced, which increases index size and can increase query-time analysis cost. [Unverified] The degree of increase is workload- and configuration-dependent (particularly `min_shingle_size`/`max_shingle_size` or `min_gram`/`max_gram`), so testing against representative data before production rollout is advisable.

### Related Topics

- Tokenizers (standard, keyword, ngram, path_hierarchy)
- Character Filters (html_strip, mapping, pattern_replace)
- Custom Analyzers — full pipeline assembly and ordering
- Synonym management — inline vs. file-based, `synonym` vs. `synonym_graph`
- The `_analyze` API for filter chain debugging
- Search-as-you-type strategies using `edge_ngram` and `shingle`
- Stemming vs. lemmatization trade-offs