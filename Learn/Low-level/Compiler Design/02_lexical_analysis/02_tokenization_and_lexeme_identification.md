## Tokenization and Lexeme Identification


Tokenization breaks the continuous stream of input characters into discrete lexical units called tokens. Each token consists of a token type (category) and an associated lexeme (the actual character sequence from the source).

The tokenization process employs the principle of maximal munch, selecting the longest possible lexeme that matches a valid token pattern. This disambiguation strategy handles cases where multiple patterns could match the same character sequence, ensuring consistent and predictable lexer behavior.

Token categories encompass various language constructs: keywords (reserved words with special meaning), identifiers (user-defined names), literals (constant values), operators (symbols representing operations), and delimiters (punctuation marks that separate language elements).

Lexeme identification requires careful handling of overlapping patterns. Keywords often share prefixes with identifier patterns, necessitating precedence rules or lookahead mechanisms. The lexer must distinguish between contextually sensitive constructs while maintaining efficient processing.

Priority resolution mechanisms determine token selection when multiple patterns match. Typically, keywords receive higher priority than identifiers, and longer matches take precedence over shorter ones. Some lexers employ backtracking to explore alternative tokenizations when initial choices lead to invalid parse states.

**Example:** Processing the input "int x = 42;" produces tokens: [KEYWORD, "int"], [IDENTIFIER, "x"], [ASSIGN, "="], [INTEGER, "42"], [SEMICOLON, ";"]

