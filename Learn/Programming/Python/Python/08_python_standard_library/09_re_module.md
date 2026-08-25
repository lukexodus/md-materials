## `re` Module


The re module is Python's built-in regular expression library that provides powerful pattern matching and text manipulation capabilities. It implements Perl-style regular expressions with additional Python-specific features.

### Module Import and Basic Usage

```python
import re

# Basic pattern matching
pattern = r'\d+'
text = "I have 42 apples and 13 oranges"
match = re.search(pattern, text)
```

### Core Functions

### search()

Searches for the first occurrence of a pattern in a string.

```python
import re

text = "The quick brown fox jumps over the lazy dog"
result = re.search(r'brown', text)
if result:
    print(f"Found: {result.group()}")
    print(f"Position: {result.start()}-{result.end()}")
```

### match()

Matches a pattern only at the beginning of a string.

```python
text = "Hello World"
result = re.match(r'Hello', text)  # Matches
result = re.match(r'World', text)  # None - doesn't match at start
```

### findall()

Returns all non-overlapping matches as a list.

```python
text = "Contact: john@email.com or jane@company.org"
emails = re.findall(r'\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}\b', text)
# Returns: ['john@email.com', 'jane@company.org']
```

### finditer()

Returns an iterator of match objects for all matches.

```python
text = "The temperatures are 25°C, 30°C, and 18°C"
for match in re.finditer(r'(\d+)°C', text):
    print(f"Temperature: {match.group(1)}°C at position {match.start()}")
```

### sub()

Replaces occurrences of a pattern with a replacement string.

```python
text = "The year is 2023"
result = re.sub(r'\d{4}', '2024', text)
# Returns: "The year is 2024"

# With function replacement
def increment_year(match):
    return str(int(match.group()) + 1)

result = re.sub(r'\d{4}', increment_year, text)
```

### subn()

Like sub() but returns a tuple with the new string and the number of substitutions.

```python
text = "apple apple banana apple"
result, count = re.subn(r'apple', 'orange', text)
# Returns: ('orange orange banana orange', 3)
```

### split()

Splits a string by occurrences of a pattern.

```python
text = "apple,banana;orange:grape"
fruits = re.split(r'[,;:]', text)
# Returns: ['apple', 'banana', 'orange', 'grape']
```

### Pattern Compilation

### compile()

Compiles a regular expression pattern into a Pattern object for reuse.

```python
pattern = re.compile(r'\b\w+@\w+\.\w+\b')
text1 = "Contact john@email.com"
text2 = "Or reach jane@company.org"

match1 = pattern.search(text1)
match2 = pattern.search(text2)
```

**Key points**: Compilation improves performance when using the same pattern multiple times.

### Regular Expression Syntax

### Character Classes

- `.` - Any character except newline
- `\d` - Any digit (0-9)
- `\D` - Any non-digit
- `\w` - Any word character (letters, digits, underscore)
- `\W` - Any non-word character
- `\s` - Any whitespace character
- `\S` - Any non-whitespace character

### Quantifiers

- `*` - Zero or more occurrences
- `+` - One or more occurrences
- `?` - Zero or one occurrence
- `{n}` - Exactly n occurrences
- `{n,}` - n or more occurrences
- `{n,m}` - Between n and m occurrences

### Anchors

- `^` - Start of string
- `$` - End of string
- `\b` - Word boundary
- `\B` - Non-word boundary

### Groups and Capturing

### Basic Groups

```python
text = "John Doe, age 30"
match = re.search(r'(\w+) (\w+), age (\d+)', text)
if match:
    first_name = match.group(1)
    last_name = match.group(2)
    age = match.group(3)
    full_match = match.group(0)  # or match.group()
```

### Named Groups

```python
pattern = r'(?P<first>\w+) (?P<last>\w+), age (?P<age>\d+)'
match = re.search(pattern, text)
if match:
    print(match.group('first'))
    print(match.groupdict())  # Returns dict of all named groups
```

### Non-capturing Groups

```python
# (?:...) creates a non-capturing group
text = "http://example.com and https://test.org"
urls = re.findall(r'https?://(?:\w+\.)+\w+', text)
```

### Flags and Modifiers

### Common Flags

```python
# Case insensitive
re.search(r'hello', 'HELLO WORLD', re.IGNORECASE)

# Multiline mode
re.search(r'^World', 'Hello\nWorld', re.MULTILINE)

# Dot matches newline
re.search(r'Hello.World', 'Hello\nWorld', re.DOTALL)

# Verbose mode for readable patterns
pattern = re.compile(r'''
    \b                # Word boundary
    \w+               # One or more word characters
    @                 # Literal @ symbol
    \w+               # One or more word characters
    \.                # Literal dot
    \w+               # One or more word characters
    \b                # Word boundary
''', re.VERBOSE)
```

### Combining Flags

```python
flags = re.IGNORECASE | re.MULTILINE
result = re.search(r'^hello', text, flags)
```

### Advanced Features

### Lookahead and Lookbehind

```python
# Positive lookahead (?=...)
text = "password123"
# Match word characters followed by digits
match = re.search(r'\w+(?=\d+)', text)  # Matches "password"

# Negative lookahead (?!...)
text = "test123 test456 testword"
# Match "test" not followed by "word"
matches = re.findall(r'test(?!word)', text)  # ['test', 'test']

# Positive lookbehind (?<=...)
text = "USD100 EUR200 GBP300"
# Match numbers preceded by "USD"
match = re.search(r'(?<=USD)\d+', text)  # Matches "100"

# Negative lookbehind (?<!...)
text = "pre-test post-test notest"
# Match "test" not preceded by "no"
matches = re.findall(r'(?<!no)test', text)  # ['test', 'test']
```

### Backreferences

```python
# Match repeated words
text = "This is is a test test"
duplicates = re.findall(r'\b(\w+)\s+\1\b', text)
# Returns: ['is', 'test']

# Replace repeated words
cleaned = re.sub(r'\b(\w+)\s+\1\b', r'\1', text)
# Returns: "This is a test"
```

### Conditional Patterns

```python
# Match different patterns based on a condition
text = "Mr. Smith or Ms. Johnson"
# Match title and name, handling different titles
pattern = r'(Mr\.|Ms\.)\s+(\w+)'
matches = re.findall(pattern, text)
```

### Match Objects

### Match Object Methods

```python
text = "The price is $25.99"
match = re.search(r'\$(\d+)\.(\d+)', text)

if match:
    print(match.group())      # Full match: "$25.99"
    print(match.group(1))     # First group: "25"
    print(match.group(2))     # Second group: "99"
    print(match.groups())     # All groups: ("25", "99")
    print(match.start())      # Start position
    print(match.end())        # End position
    print(match.span())       # (start, end) tuple
```

### Common Patterns

### Email Validation

```python
email_pattern = r'\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}\b'
text = "Contact us at support@company.com"
email = re.search(email_pattern, text)
```

### Phone Number Extraction

```python
phone_pattern = r'\b(?:\+?1[-.\s]?)?\(?([0-9]{3})\)?[-.\s]?([0-9]{3})[-.\s]?([0-9]{4})\b'
text = "Call me at (555) 123-4567 or +1-555-987-6543"
phones = re.findall(phone_pattern, text)
```

### URL Matching

```python
url_pattern = r'https?://(?:[-\w.])+(?:\:[0-9]+)?(?:/(?:[\w/_.])*(?:\?(?:[\w&=%.])*)?(?:\#(?:[\w.])*)?)?'
text = "Visit https://example.com/page?id=123#section"
urls = re.findall(url_pattern, text)
```

### Date Extraction

```python
date_pattern = r'\b(\d{1,2})/(\d{1,2})/(\d{4})\b'
text = "The event is on 12/25/2023"
dates = re.findall(date_pattern, text)
```

### Performance Considerations

### Compilation Benefits

```python
# Inefficient - compiles pattern each time
for text in large_text_list:
    re.search(r'pattern', text)

# Efficient - compile once, use many times
pattern = re.compile(r'pattern')
for text in large_text_list:
    pattern.search(text)
```

### Non-greedy Matching

```python
html = "<div>Content</div><div>More content</div>"
# Greedy (default)
greedy = re.findall(r'<div>.*</div>', html)  # Matches entire string
# Non-greedy
non_greedy = re.findall(r'<div>.*?</div>', html)  # Matches each div separately
```

### Error Handling

### Pattern Compilation Errors

```python
try:
    pattern = re.compile(r'[invalid pattern')
except re.error as e:
    print(f"Invalid regex pattern: {e}")
```

### Practical Examples

### Log File Processing

```python
log_pattern = re.compile(r'(\d{4}-\d{2}-\d{2})\s+(\d{2}:\d{2}:\d{2})\s+(\w+)\s+(.+)')
log_line = "2023-12-01 10:30:45 ERROR Database connection failed"
match = log_pattern.search(log_line)
if match:
    date, time, level, message = match.groups()
```

### Text Cleaning

```python
def clean_text(text):
    # Remove extra whitespace
    text = re.sub(r'\s+', ' ', text)
    # Remove special characters except basic punctuation
    text = re.sub(r'[^\w\s.,!?-]', '', text)
    # Remove multiple punctuation
    text = re.sub(r'[.,!?]{2,}', '.', text)
    return text.strip()
```

### Data Validation

```python
def validate_credit_card(card_number):
    # Remove spaces and dashes
    card_number = re.sub(r'[-\s]', '', card_number)
    # Check if it's 13-19 digits
    if re.match(r'^\d{13,19}$', card_number):
        return True
    return False
```

**Key points**: The re module provides comprehensive pattern matching capabilities with functions for searching, matching, replacing, and splitting text. Compilation improves performance for repeated use, and various flags modify pattern behavior. Advanced features include lookahead/lookbehind assertions, backreferences, and named groups.

**Conclusion**: The re module is essential for text processing tasks in Python, offering powerful pattern matching through regular expressions. Understanding its functions, syntax, and performance considerations enables efficient text manipulation and data extraction from complex strings.

---

