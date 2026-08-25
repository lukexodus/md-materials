## Character Filters

Character filters are the first stage of an Elasticsearch analyzer pipeline. They operate on the raw text of a field before tokenization occurs, transforming the character stream by adding, removing, or changing characters. Because they run before the tokenizer, character filters can influence how text is subsequently split into tokens.

### Position in the Analysis Pipeline

An analyzer applies its components in a fixed order: character filters run first, then a single tokenizer, then token filters. Character filters receive the original string and return a modified string, which is then handed to the tokenizer.

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 800 200">
  <text x="400" y="20" font-size="14" font-weight="bold" text-anchor="middle" fill="#333">Analyzer Pipeline (svg_diagram)</text>

  <rect x="20" y="60" width="180" height="60" rx="6" fill="#e8f0fe" stroke="#4285f4" stroke-width="1.5" />
  <text x="110" y="85" font-size="13" text-anchor="middle" fill="#1a1a1a">Raw Text</text>
  <text x="110" y="102" font-size="11" text-anchor="middle" fill="#555">Original field value</text>

  <line x1="200" y1="90" x2="240" y2="90" stroke="#666" stroke-width="1.5" marker-end="url(#arrow)" />

  <rect x="240" y="60" width="180" height="60" rx="6" fill="#fef7e0" stroke="#f9ab00" stroke-width="1.5" />
  <text x="330" y="80" font-size="13" text-anchor="middle" fill="#1a1a1a">Character Filters</text>
  <text x="330" y="97" font-size="11" text-anchor="middle" fill="#555">0 or more, in order</text>
  <text x="330" y="112" font-size="10" text-anchor="middle" fill="#777">string in → string out</text>

  <line x1="420" y1="90" x2="460" y2="90" stroke="#666" stroke-width="1.5" marker-end="url(#arrow)" />

  <rect x="460" y="60" width="150" height="60" rx="6" fill="#e6f4ea" stroke="#34a853" stroke-width="1.5" />
  <text x="535" y="80" font-size="13" text-anchor="middle" fill="#1a1a1a">Tokenizer</text>
  <text x="535" y="97" font-size="11" text-anchor="middle" fill="#555">exactly 1</text>
  <text x="535" y="112" font-size="10" text-anchor="middle" fill="#777">string in → tokens out</text>

  <line x1="610" y1="90" x2="650" y2="90" stroke="#666" stroke-width="1.5" marker-end="url(#arrow)" />

  <rect x="650" y="60" width="130" height="60" rx="6" fill="#fce8e6" stroke="#ea4335" stroke-width="1.5" />
  <text x="715" y="80" font-size="13" text-anchor="middle" fill="#1a1a1a">Token Filters</text>
  <text x="715" y="97" font-size="11" text-anchor="middle" fill="#555">0 or more, in order</text>
  <text x="715" y="112" font-size="10" text-anchor="middle" fill="#777">tokens in → tokens out</text>

  <text x="330" y="150" font-size="11" text-anchor="middle" fill="#888">Character filters can shift character offsets,</text>
  <text x="330" y="165" font-size="11" text-anchor="middle" fill="#888">affecting highlighting unless offsets are corrected.</text>
</svg>

A single analyzer can chain zero or more character filters. When multiple are configured, they execute in the order listed in the `char_filter` array, with each filter's output feeding into the next filter's input.

### Built-in Character Filters

Elasticsearch ships three built-in character filters.

**HTML Strip Character Filter**

The `html_strip` filter strips HTML elements (e.g. `<b>`, `\<div\>`) from the text and decodes HTML entities (e.g. `&amp;` becomes `&`).

```json
PUT html_strip_example
{
  "settings": {
    "analysis": {
      "analyzer": {
        "my_html_analyzer": {
          "tokenizer": "keyword",
          "char_filter": ["html_strip"]
        }
      }
    }
  }
}

POST html_strip_example/_analyze
{
  "analyzer": "my_html_analyzer",
  "text": "<p>I&apos;m so <b>happy</b>!</p>"
}
```

This produces the token `I'm so happy!` with tags removed and the entity decoded. An optional `escaped_tags` parameter can be set to prevent specific tags from being stripped.

**Mapping Character Filter**

The `mapping` filter performs a configurable set of key-to-value string replacements, similar to a find-and-replace operation. It is defined using an array of `key => value` pairs or an external file referenced via `mappings_path`.

```json
PUT mapping_example
{
  "settings": {
    "analysis": {
      "analyzer": {
        "my_mapping_analyzer": {
          "tokenizer": "keyword",
          "char_filter": ["my_char_filter"]
        }
      },
      "char_filter": {
        "my_char_filter": {
          "type": "mapping",
          "mappings": [
            ":) => _happy_",
            ":( => _sad_"
          ]
        }
      }
    }
  }
}

POST mapping_example/_analyze
{
  "analyzer": "my_mapping_analyzer",
  "text": "I'm feeling :) today"
}
```

This yields the token `I'm feeling _happy_ today`. This is commonly used to normalize domain-specific symbols, emoticons, or shorthand into consistent, searchable terms.

**Pattern Replace Character Filter**

The `pattern_replace` filter uses a Java regular expression to match character sequences and replace them, with support for capture group references in the replacement string.

```json
PUT pattern_replace_example
{
  "settings": {
    "analysis": {
      "analyzer": {
        "my_pattern_analyzer": {
          "tokenizer": "keyword",
          "char_filter": ["my_pattern_filter"]
        }
      },
      "char_filter": {
        "my_pattern_filter": {
          "type": "pattern_replace",
          "pattern": "(\\d+)-(\\d+)",
          "replacement": "$1_$2"
        }
      }
    }
  }
}

POST pattern_replace_example/_analyze
{
  "analyzer": "my_pattern_filter",
  "text": "Reference 123-456 applies"
}
```

The digit-hyphen-digit pattern `123-456` becomes `123_456`. [Unverified] Poorly constructed regular expressions in this filter can be computationally expensive against large inputs, so patterns intended for production use benefit from being tested against representative data volumes beforehand.

### Configuring Custom Analyzers with Character Filters

Character filters are rarely used standalone in a mapping; they are components assembled into a `custom` analyzer alongside a tokenizer and optional token filters.

```json
PUT custom_analyzer_example
{
  "settings": {
    "analysis": {
      "char_filter": {
        "quote_mapper": {
          "type": "mapping",
          "mappings": ["‘ => '", "’ => '", "“ => \"", "” => \""]
        }
      },
      "analyzer": {
        "normalized_text": {
          "type": "custom",
          "char_filter": ["html_strip", "quote_mapper"],
          "tokenizer": "standard",
          "filter": ["lowercase"]
        }
      }
    }
  },
  "mappings": {
    "properties": {
      "content": {
        "type": "text",
        "analyzer": "normalized_text"
      }
    }
  }
}
```

Here, `html_strip` runs first to remove markup, then `quote_mapper` normalizes curly quotes to straight quotes, and finally the `standard` tokenizer splits the cleaned text before lowercasing.

### Offset Correction and Highlighting

Character filters can change the length of the text (e.g. stripping HTML tags shortens it, or `mapping` replacements may lengthen or shorten it). Elasticsearch's built-in character filters record the offset changes they introduce so that the original character positions in the source field can still be mapped correctly for features like highlighting. Custom character filters implemented via plugins that do not correctly track offsets can cause highlighting to point to incorrect positions in the original text.

### Character Filters and the `_analyze` API

The `_analyze` API is the primary tool for inspecting how character filters transform text, independent of a full index. It can be tested against an ad hoc combination of filters without creating an index.

```json
POST _analyze
{
  "tokenizer": "keyword",
  "char_filter": [
    {
      "type": "mapping",
      "mappings": ["- => _"]
    }
  ],
  "text": "elastic-search-guide"
}
```

Using the `keyword` tokenizer here keeps the entire string as a single token so the effect of the character filter alone is visible: `elastic_search_guide`.

### Performance Considerations

**Key Points**
- Character filters run at analysis time, both during indexing and during query parsing for analyzed queries (e.g. `match`), so their cost is paid on both paths.
- `pattern_replace` with complex regular expressions is typically the most expensive of the three built-in filters. [Inference] Because it must evaluate a regex engine against the full character stream, it likely carries more overhead than the simpler direct-mapping lookup performed by `mapping`, though the actual cost difference depends on pattern complexity and input size.
- `html_strip` is generally used only on fields known to contain markup, since running it on already-clean text adds unnecessary processing.
- Character filters that significantly alter text length are worth validating against highlighting behavior before relying on them in production, since offset tracking correctness affects highlight accuracy.

### Common Use Cases

- Stripping HTML/XML markup from web-scraped or CMS-sourced content before indexing.
- Normalizing typographic variants (curly quotes, em-dashes, non-breaking spaces) to their standard ASCII equivalents.
- Converting domain-specific notation (e.g. part numbers, emoticons, currency symbols) into a normalized searchable form.
- Removing or masking sensitive patterns (e.g. redacting sequences resembling identifiers) prior to indexing, as a lightweight text-transform step. [Unverified] This approach does not guarantee removal of sensitive data with the same reliability as dedicated ingest-time processors, since regex-based masking is only as complete as the pattern coverage.

### Related Topics

- Tokenizers (standard, keyword, ngram, pattern)
- Token Filters (lowercase, stop, synonym, stemmer)
- Custom Analyzers — full pipeline composition
- The `_analyze` API — testing and debugging analyzers
- Search-time vs. index-time analysis
- Ingest Pipelines vs. character filters for text preprocessing
- Highlighting and offset strategies (`unified`, `fvh`, `plain`)