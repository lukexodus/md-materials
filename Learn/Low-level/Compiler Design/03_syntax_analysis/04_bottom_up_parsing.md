## Bottom-Up Parsing


Bottom-up parsing constructs parse trees from leaves to root, building larger structures from smaller components. The parser maintains a stack of parsed items and uses shift and reduce operations to process input.

The fundamental operation involves recognizing when stack contents match a production's right-hand side (handle), then reducing by replacing the handle with the production's left-hand side non-terminal.

### LR Parsing

LR parsers read input Left-to-right and produce Rightmost derivations in reverse. LR parsing is more powerful than LL parsing, handling a broader class of grammars including those with left recursion.

LR parsers use a deterministic finite automaton (DFA) to track parsing state. Each state represents a set of items (productions with position markers showing parsing progress). The parsing table contains shift, reduce, accept, and error actions.

**Key points** for LR parsing:

- Handles left-recursive grammars naturally
- Detects syntax errors as soon as possible
- Provides systematic construction of parsing tables
- More complex implementation than LL parsers

### SLR Parsing

Simple LR (SLR) parsing extends LR(0) by using FOLLOW sets to resolve reduce/reduce conflicts. An SLR parser reduces using production A → α only when the lookahead token is in FOLLOW(A).

SLR construction involves:

1. Building the LR(0) collection of item sets
2. Constructing the parsing table using FOLLOW sets for reduce actions
3. Detecting conflicts that cannot be resolved through FOLLOW information

SLR parsers handle a significant subset of programming language constructs but cannot resolve all conflicts in more complex grammars.

### LALR Parsing

Lookahead LR (LALR) parsing merges LR(1) states with identical item cores, reducing parsing table size while maintaining much of LR(1)'s power. LALR parsers provide a practical compromise between SLR simplicity and LR(1) capability.

LALR construction can be performed by:

1. Building the full LR(1) collection and merging compatible states
2. Building LR(0) collection and computing lookaheads separately
3. Using efficient algorithms that avoid constructing the full LR(1) collection

Most practical parser generators use LALR parsing due to its favorable size-to-power ratio.

### LR(1) Parsing

LR(1) parsers use one token of lookahead to make reduce decisions, providing the most powerful bottom-up parsing capability for deterministic context-free languages. Each item includes both a production and lookahead set, enabling more precise conflict resolution.

LR(1) parsing tables can be substantially larger than LALR tables, but they handle grammars that cause LALR conflicts. Modern parsing techniques and increased memory capacity make LR(1) parsers more practical than previously.

