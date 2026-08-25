## Reserved vs Unreserved Characters


### Unreserved Characters

These characters never need to be percent-encoded and have no special meaning:

- Alphanumeric: `A-Z`, `a-z`, `0-9`
- Special characters: `-`, `.`, `_`, `~`

### Reserved Characters

These characters have special meaning in URIs and must be percent-encoded when used literally:

**General Delimiters:**

- `:` (colon)
- `/` (slash)
- `?` (question mark)
- `#` (hash/fragment identifier)
- `[` and `]` (brackets)
- `@` (at sign)

**Sub-Delimiters:**

- `!` (exclamation mark)
- `$` (dollar sign)
- `&` (ampersand)
- `'` (apostrophe)
- `(` and `)` (parentheses)
- `*` (asterisk)
- `+` (plus sign)
- `,` (comma)
- `;` (semicolon)
- `=` (equals sign)

**Example:** To include a literal `?` in a path segment:

```
https://example.com/what%3Fis%3Fthis  // Correct
https://example.com/what?is?this      // Incorrect - creates query string
```

