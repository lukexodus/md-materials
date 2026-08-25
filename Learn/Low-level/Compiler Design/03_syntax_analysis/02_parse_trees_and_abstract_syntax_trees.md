## Parse Trees and Abstract Syntax Trees


Parse trees represent the complete derivation of input according to grammar rules, showing every step of the parsing process. Each internal node represents a grammar rule application, while leaves correspond to terminal symbols. Parse trees preserve all syntactic information but can be verbose for complex expressions.

Abstract syntax trees (ASTs) provide a condensed representation focusing on program structure rather than parsing details. ASTs eliminate unnecessary nodes like parentheses and operator precedence markers, retaining only semantically significant information. Each node typically represents an operation or construct, with children representing operands or sub-constructs.

**Key points** about tree structures:

- Parse trees maintain complete grammatical derivation information
- ASTs focus on semantic structure and facilitate later compilation phases
- Tree construction occurs during parsing through semantic actions
- Node attributes can store type information, symbol table references, and intermediate code

