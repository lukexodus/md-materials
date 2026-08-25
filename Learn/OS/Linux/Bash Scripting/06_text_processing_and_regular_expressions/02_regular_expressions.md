## Regular Expressions


Regular expressions (regex) are powerful pattern-matching tools that enable sophisticated text processing, searching, and manipulation in bash scripting. They provide a concise way to describe complex patterns within strings, making them essential for data validation, text parsing, and automated text processing tasks.

### Basic Regex Patterns

Basic regex patterns form the foundation of pattern matching. The simplest patterns match literal characters exactly as they appear. For example, the pattern `cat` matches the exact sequence of characters "cat" in a string.

The dot (.) metacharacter serves as a wildcard, matching any single character except newline. The pattern `c.t` would match "cat", "cut", "cot", or any three-character string starting with 'c' and ending with 't'.

Escape sequences allow you to match literal metacharacters. To match a literal dot, you use `\.`. Common escape sequences include `\n` for newline, `\t` for tab, and `\\` for a literal backslash.

Alternation using the pipe symbol (|) creates an OR condition. The pattern `cat|dog` matches either "cat" or "dog". Parentheses group alternatives: `(cat|dog)s` matches "cats" or "dogs".

### Character Classes and Quantifiers

Character classes define sets of characters to match at a single position. Square brackets create character classes: `[aeiou]` matches any vowel, while `[0-9]` matches any digit. The caret inside brackets negates the class: `[^0-9]` matches any non-digit character.

Predefined character classes provide shortcuts for common patterns:

- `\d` matches digits (equivalent to `[0-9]`)
- `\w` matches word characters (letters, digits, underscore)
- `\s` matches whitespace characters (space, tab, newline)
- `\D`, `\W`, `\S` are the negated versions

Ranges within character classes use hyphens: `[a-z]` matches lowercase letters, `[A-Z]` matches uppercase letters, and `[a-zA-Z0-9]` matches alphanumeric characters.

Quantifiers specify how many times a pattern should match:

- `*` matches zero or more occurrences
- `+` matches one or more occurrences
- `?` matches zero or one occurrence
- `{n}` matches exactly n occurrences
- `{n,}` matches n or more occurrences
- `{n,m}` matches between n and m occurrences

Quantifiers are greedy by default, matching as many characters as possible. Adding `?` after a quantifier makes it non-greedy: `.*?` matches the shortest possible string.

### Anchors and Boundaries

Anchors specify position requirements within strings rather than matching actual characters. The caret `^` anchors a pattern to the beginning of a line, while the dollar sign `$` anchors to the end of a line. The pattern `^hello$` matches only if "hello" comprises the entire line.

Word boundaries (`\b`) match positions between word and non-word characters. The pattern `\bcat\b` matches "cat" as a complete word but not within "category" or "caterpillar". The non-word boundary `\B` matches positions that are not word boundaries.

String anchors `\A` and `\Z` match the absolute beginning and end of the entire string, regardless of line breaks. These differ from line anchors when dealing with multiline strings.

Lookahead and lookbehind assertions check for patterns without consuming characters:

- `(?=pattern)` positive lookahead
- `(?!pattern)` negative lookahead
- `(?<=pattern)` positive lookbehind
- `(?<!pattern)` negative lookbehind

### Capturing Groups and Backreferences

Parentheses create capturing groups that store matched portions for later reference. The pattern `(cat|dog) and (bird|fish)` creates two groups that can be referenced individually. Groups are numbered starting from 1, corresponding to their opening parenthesis position.

Backreferences allow you to match previously captured groups using `\1`, `\2`, etc. The pattern `(\w+) \1` matches repeated words like "the the" or "and and". This enables complex pattern matching where parts of the match must be identical.

Non-capturing groups use `(?:pattern)` syntax when you need grouping for alternation or quantifiers but don't want to capture the content. This improves performance and keeps backreference numbering clean.

Named groups provide more readable references: `(?<name>pattern)` creates a named group accessible as `\k<name>` in some regex flavors.

Substitution operations use captured groups to build replacement strings. In commands like `sed`, `$1`, `$2`, etc., reference captured groups in the replacement text.

**Key points:**

- Regular expressions require different syntax depending on the tool (grep, sed, awk, bash built-ins)
- Basic Regular Expressions (BRE) and Extended Regular Expressions (ERE) have different metacharacter requirements
- Test regex patterns thoroughly with representative data before using in production scripts
- Consider performance implications with complex patterns and large datasets
- Use online regex testers for development and debugging

**Example:**

```bash
# Email validation pattern
email_pattern="^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$"

# Extract domain from email
if [[ $email =~ (.+)@(.+) ]]; then
    user="${BASH_REMATCH[1]}"
    domain="${BASH_REMATCH[2]}"
fi

# Find and replace with sed
sed 's/\([0-9]\{1,3\}\)\.\([0-9]\{1,3\}\)\.\([0-9]\{1,3\}\)\.\([0-9]\{1,3\}\)/IP:\1.\2.\3.\4/g' logfile.txt

# Phone number formatting
phone_pattern="^\([0-9]{3}\) [0-9]{3}-[0-9]{4}$"
```

For advanced bash scripting, consider exploring PCRE (Perl Compatible Regular Expressions) for more sophisticated pattern matching, regex optimization techniques for performance-critical applications, and integration with tools like grep, sed, and awk for comprehensive text processing workflows.

---

