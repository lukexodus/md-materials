## R Markdown Fundamentals


R Markdown combines narrative text with executable R code, creating dynamic documents that automatically update when underlying data or analysis changes. The format uses Markdown syntax for text formatting and code chunks for R execution.

**Key points:**

- Code chunks are enclosed in triple backticks with `{r}` headers
- Chunk options control execution behavior (eval, echo, include, cache)
- YAML headers define document metadata and output formats
- Inline code uses single backticks with `r` prefix for embedding results in text

The knitting process converts R Markdown to various output formats through the knitr package, which executes code chunks and weaves results into the final document. Output formats include HTML, PDF, Word documents, presentations, and dashboards.

**Example:** A basic R Markdown document structure includes YAML front matter specifying output format, followed by alternating text and code sections. Code chunks can generate plots, tables, and statistical summaries that automatically appear in the rendered document.

