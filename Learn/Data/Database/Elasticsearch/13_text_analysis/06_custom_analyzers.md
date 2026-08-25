## Custom Analyzers

A custom analyzer is one assembled explicitly from individual components — zero or more character filters, exactly one tokenizer, and zero or more token filters — rather than relying on a pre-packaged built-in analyzer. Custom analyzers are defined in the `analysis` section of index settings and are the mechanism for tailoring text analysis to a specific field's requirements.

### Anatomy of a Custom Analyzer

A custom analyzer is declared with `"type": "custom"` (or `type` omitted, since `custom` is implied when `tokenizer` is specified directly) and references named components, each of which can either be a built-in name or a separately defined custom component.

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 800 220">
  <text x="400" y="20" font-size="14" font-weight="bold" text-anchor="middle" fill="#333">Custom Analyzer Composition (svg_diagram)</text>

  <rect x="60" y="45" width="680" height="150" rx="8" fill="#f8f9fa" stroke="#999" stroke-width="1.5" stroke-dasharray="4,3" />
  <text x="400" y="65" font-size="12" text-anchor="middle" fill="#555" font-style="italic">"my_custom_analyzer"</text>

  <rect x="90" y="80" width="180" height="80" rx="6" fill="#fef7e0" stroke="#f9ab00" stroke-width="1.5" />
  <text x="180" y="102" font-size="12" font-weight="bold" text-anchor="middle" fill="#1a1a1a">char_filter</text>
  <text x="180" y="120" font-size="10" text-anchor="middle" fill="#555">array, ordered</text>
  <text x="180" y="135" font-size="10" text-anchor="middle" fill="#555">0 or more entries</text>
  <text x="180" y="150" font-size="10" text-anchor="middle" fill="#777">e.g. html_strip</text>

  <rect x="310" y="80" width="180" height="80" rx="6" fill="#e6f4ea" stroke="#34a853" stroke-width="2" />
  <text x="400" y="102" font-size="12" font-weight="bold" text-anchor="middle" fill="#1a1a1a">tokenizer</text>
  <text x="400" y="120" font-size="10" text-anchor="middle" fill="#555">single value</text>
  <text x="400" y="135" font-size="10" text-anchor="middle" fill="#555">exactly 1 required</text>
  <text x="400" y="150" font-size="10" text-anchor="middle" fill="#777">e.g. standard</text>

  <rect x="530" y="80" width="180" height="80" rx="6" fill="#fce8e6" stroke="#ea4335" stroke-width="1.5" />
  <text x="620" y="102" font-size="12" font-weight="bold" text-anchor="middle" fill="#1a1a1a">filter</text>
  <text x="620" y="120" font-size="10" text-anchor="middle" fill="#555">array, ordered</text>
  <text x="620" y="135" font-size="10" text-anchor="middle" fill="#555">0 or more entries</text>
  <text x="620" y="150" font-size="10" text-anchor="middle" fill="#777">e.g. lowercase, stop</text>

  <text x="400" y="182" font-size="10" text-anchor="middle" fill="#888">Named components (e.g. "my_stopwords") are defined separately under analysis.filter, analysis.char_filter, analysis.tokenizer</text>
</svg>

### Basic Structure

```json
PUT custom_analyzer_basic
{
  "settings": {
    "analysis": {
      "analyzer": {
        "my_custom_analyzer": {
          "type": "custom",
          "char_filter": ["html_strip"],
          "tokenizer": "standard",
          "filter": ["lowercase", "asciifolding"]
        }
      }
    }
  },
  "mappings": {
    "properties": {
      "description": {
        "type": "text",
        "analyzer": "my_custom_analyzer"
      }
    }
  }
}

POST custom_analyzer_basic/_analyze
{
  "analyzer": "my_custom_analyzer",
  "text": "<p>Café MÜNCHEN</p>"
}
```

This strips the HTML tags, tokenizes on Unicode word boundaries, lowercases, and folds diacritics, producing `cafe` and `munchen`.

### Defining Named Custom Components

When a built-in component needs non-default parameters, it must be defined as a named custom component under `analysis.char_filter`, `analysis.tokenizer`, or `analysis.filter`, then referenced by name from the analyzer definition.

```json
PUT custom_analyzer_named_components
{
  "settings": {
    "analysis": {
      "char_filter": {
        "quote_normalizer": {
          "type": "mapping",
          "mappings": ["‘ => '", "’ => '", "“ => \"", "” => \""]
        }
      },
      "tokenizer": {
        "comma_tokenizer": {
          "type": "pattern",
          "pattern": ","
        }
      },
      "filter": {
        "english_stop": {
          "type": "stop",
          "stopwords": "_english_"
        },
        "english_stemmer": {
          "type": "stemmer",
          "language": "light_english"
        }
      },
      "analyzer": {
        "product_description_analyzer": {
          "type": "custom",
          "char_filter": ["html_strip", "quote_normalizer"],
          "tokenizer": "standard",
          "filter": ["lowercase", "english_stop", "english_stemmer"]
        }
      }
    }
  }
}
```

This defines each non-default component (`quote_normalizer`, `english_stop`, `english_stemmer`) separately, then composes them into `product_description_analyzer` alongside built-in defaults (`html_strip`, `standard`, `lowercase`) referenced directly by name.

### Order of Execution

Within a custom analyzer, `char_filter` entries run in array order against the raw string, then the single `tokenizer` runs once, then `filter` entries run in array order against the resulting tokens. This order is fixed by pipeline stage, but within each stage the array order is significant and determines the outcome, as covered previously for filter ordering (e.g. `lowercase` before `stop`).

```json
POST custom_analyzer_named_components/_analyze
{
  "analyzer": "product_description_analyzer",
  "text": "<p>The Running Shoes are ‘on sale’</p>"
}
```

Processing order: `html_strip` removes `<p>` tags → `quote_normalizer` converts curly quotes to straight quotes → `standard` tokenizer splits into words → `lowercase` normalizes case → `english_stop` removes `the`, `are` → `english_stemmer` reduces `running` toward its stem form.

### Testing a Custom Analyzer Inline (Without Creating an Index)

The `_analyze` API supports defining an entire custom analyzer inline, which is useful for iterating on a configuration before committing it to index settings.

```json
POST _analyze
{
  "char_filter": ["html_strip"],
  "tokenizer": "standard",
  "filter": ["lowercase", "asciifolding"],
  "text": "<b>Ünïcödé</b> test"
}
```

This behaves identically to a named custom analyzer with the same components, without requiring an index to be created first.

### Updating Custom Analyzers on Existing Indices

Analyzer settings are part of `static` index settings for already-indexed fields, meaning a new analyzer definition cannot simply be added to an open index if it changes how existing data would be interpreted. Adding a new analyzer (not modifying an existing one) to an index's settings is possible, but only while the index is closed.

```json
POST custom_analyzer_named_components/_close

PUT custom_analyzer_named_components/_settings
{
  "analysis": {
    "analyzer": {
      "new_analyzer": {
        "type": "custom",
        "tokenizer": "whitespace",
        "filter": ["lowercase"]
      }
    }
  }
}

POST custom_analyzer_named_components/_open
```

[Unverified] Because closing an index makes it unavailable for reads and writes during the operation, this is generally scheduled during a maintenance window for production indices, and applying it to an index alias pattern spanning multiple indices requires iterating per-index. Changing how an *existing* field's already-indexed data is analyzed additionally requires reindexing, since analysis happens at index time and altering the analyzer does not retroactively change previously stored terms.

### Custom Analyzers and Multi-fields

A common pattern pairs a custom analyzer on the main `text` field with a `keyword` sub-field (or a differently-analyzed sub-field) via the `fields` mapping parameter, allowing the same source value to be queried both as full text and as an exact or alternately-tokenized value.

```json
PUT multi_field_custom_analyzer
{
  "settings": {
    "analysis": {
      "analyzer": {
        "product_analyzer": {
          "type": "custom",
          "tokenizer": "standard",
          "filter": ["lowercase", "asciifolding"]
        }
      }
    }
  },
  "mappings": {
    "properties": {
      "product_name": {
        "type": "text",
        "analyzer": "product_analyzer",
        "fields": {
          "raw": {
            "type": "keyword"
          },
          "autocomplete": {
            "type": "search_as_you_type"
          }
        }
      }
    }
  }
}
```

Here `product_name` is analyzed for full-text search, `product_name.raw` supports exact-value matching and aggregations, and `product_name.autocomplete` supports search-as-you-type queries — each driven by the same source value but a different analysis strategy.

### Common Custom Analyzer Patterns

**Key Points**
- HTML content fields typically pair `html_strip` with `standard` tokenization and `lowercase`, optionally adding `stop` for a target language.
- E-commerce SKU or code fields typically use `keyword` or `pattern` tokenization combined with `uppercase`/`lowercase` normalization, avoiding stemming and stopword removal entirely since exact matching matters more than recall.
- Multi-language content spanning a single field (rather than one field per language) generally uses `standard` with broad-strokes normalization (`lowercase`, `asciifolding`) rather than a single language analyzer, since language-specific stemming assumes a known target language.
- Search-as-you-type fields typically pair a `standard` (or similar) index-time analyzer with `edge_ngram` filters, while using a plain `standard` analyzer at search time to avoid generating unnecessary n-grams from the user's query — this asymmetric analyzer setup is configured via `search_analyzer` on the field mapping, separate from the indexing analyzer.

### Related Topics

- Tokenizers, Character Filters, and Token Filters — individual component reference
- Built-in Analyzers — pre-packaged alternatives to full customization
- Multi-fields (`fields`) — applying multiple analyzers to one source value
- `search_analyzer` vs. index-time `analyzer` — asymmetric analysis
- Normalizers — analyzer-equivalent processing for `keyword` fields
- Reindexing — required when changing analysis of already-indexed data
- The `_analyze` API — inline testing of custom pipelines