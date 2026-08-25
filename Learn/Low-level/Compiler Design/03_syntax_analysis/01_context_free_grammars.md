## Context-Free Grammars


Context-free grammars (CFGs) provide the mathematical foundation for describing programming language syntax. A CFG consists of four components: a set of terminal symbols (tokens), non-terminal symbols (syntactic categories), production rules, and a start symbol.

Production rules define how non-terminals can be expanded into sequences of terminals and non-terminals. For example, a simple expression grammar might include:

- E → E + T | T
- T → T * F | F
- F → (E) | id | num

The grammar defines the syntactic structure while remaining independent of semantic meaning. Ambiguous grammars can generate multiple parse trees for the same input, requiring disambiguation through precedence and associativity rules or grammar restructuring.

Left-recursive productions (where a non-terminal appears as the leftmost symbol in its own production) must be eliminated for top-down parsing. This involves transforming rules like A → Aα | β into A → βA' and A' → αA' | ε.

