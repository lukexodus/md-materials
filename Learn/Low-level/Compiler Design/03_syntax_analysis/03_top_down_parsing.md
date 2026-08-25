## Top-Down Parsing


Top-down parsing constructs parse trees from root to leaves, attempting to match input against grammar productions starting from the start symbol. The parser predicts which production to apply based on lookahead tokens.

### Recursive Descent Parsing

Recursive descent parsing implements a recursive procedure for each non-terminal in the grammar. Each procedure attempts to recognize its corresponding non-terminal by calling other procedures for sub-structures. This approach provides intuitive, readable parser implementations.

The method requires careful handling of left recursion and backtracking. Predictive recursive descent eliminates backtracking by using lookahead to determine which production to apply, but this requires LL(k) grammars.

### LL Parsing

LL(k) parsers read input Left-to-right and produce Leftmost derivations using k tokens of lookahead. LL(1) parsers are most common, using a single lookahead token to make parsing decisions.

LL parsing uses a parsing table constructed from FIRST and FOLLOW sets. FIRST(α) contains terminals that can begin strings derived from α, while FOLLOW(A) contains terminals that can immediately follow non-terminal A in valid derivations.

The LL(1) parsing algorithm uses a stack and parsing table to determine actions:

- If stack top matches input token, both are consumed
- If stack top is a non-terminal, the parsing table determines which production to apply
- Productions are expanded by pushing right-hand side symbols onto the stack in reverse order

**Key points** for LL parsing:

- Requires left-factoring to eliminate common prefixes
- Cannot handle left-recursive grammars
- Parsing table construction detects LL(1) conflicts
- Provides excellent error recovery capabilities through synchronization tokens

