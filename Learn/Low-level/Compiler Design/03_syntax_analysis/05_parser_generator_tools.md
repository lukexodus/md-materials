## Parser Generator Tools


Parser generators automate parser construction from grammar specifications, significantly reducing development time and improving reliability compared to hand-written parsers.

### Yacc (Yet Another Compiler Compiler)

Yacc generates LALR parsers from grammar specifications written in a specialized notation. The tool processes grammar rules with embedded semantic actions, producing C code for the complete parser.

Yacc specifications consist of three sections:

- Declarations section defining tokens, precedence, and associativity
- Rules section containing grammar productions with semantic actions
- Programs section with additional C code

**Example** Yacc grammar fragment:

```
%token NUMBER ID
%left '+' '-'
%left '*' '/'

%%
expr: expr '+' expr { $$ = $1 + $3; }
    | expr '*' expr { $$ = $1 * $3; }
    | NUMBER        { $$ = $1; }
    | ID            { $$ = lookup($1); }
    ;
```

### Bison (GNU Yacc)

Bison extends Yacc functionality while maintaining compatibility. It provides enhanced error reporting, GLR parsing for ambiguous grammars, and improved location tracking for better error messages.

Bison supports multiple parsing algorithms:

- LALR(1) for standard deterministic parsing
- GLR for handling ambiguous grammars
- LR(1) when LALR conflicts cannot be resolved

Additional Bison features include pure parsers (reentrant), C++ parser generation, and advanced error recovery mechanisms.

**Key points** for parser generators:

- Automate parsing table construction and conflict detection
- Provide systematic approaches to grammar debugging
- Generate efficient, maintainable parser code
- Support semantic actions for AST construction and attribute evaluation

