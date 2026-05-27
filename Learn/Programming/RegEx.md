## Syllabus

### **Module 1: Introduction to Regular Expressions**

- What is Regex?
- History and Uses of Regular Expressions
- Basic Syntax and Structure
- Common Applications (Text Search, Validation, Data Processing)

**Exercises:**

- Simple pattern matching in text
- Using regex in text editors like VS Code, Notepad++, or Sublime Text

---

### **Module 2: Basic Regex Syntax**

- **Literals and Metacharacters**
    - Matching simple characters and words
    - Escape sequences (`\`, `.`)
- **Anchors**
    - `^` (Start of a string)
    - `$` (End of a string)
- **Character Classes**
    - `[abc]` (Matches any character in the set)
    - `[^abc]` (Negated character set)
    - `[a-z]`, `[0-9]` (Ranges)
    - `\d`, `\w`, `\s` (Predefined character classes)
    - `\D`, `\W`, `\S` (Negated character classes)

**Exercises:**

- Match specific words and numbers in a sentence
- Extract uppercase letters from a text

---

### **Module 3: Quantifiers and Grouping**

- **Quantifiers**
    - `*` (0 or more)
    - `+` (1 or more)
    - `?` (0 or 1)
    - `{n}`, `{n,}`, `{n,m}` (Exact and range-based repetition)
- **Grouping and Capturing**
    - `()` (Capturing groups)
    - `(?: )` (Non-capturing groups)
- **Alternation (OR Operator)**
    - `|` (Matches one pattern or another)

**Exercises:**

- Extract words of specific lengths from a paragraph
- Match multiple date formats (DD-MM-YYYY, MM/DD/YYYY)

---

### **Module 4: Lookaheads, Lookbehinds, and Flags**

- **Lookaheads**
    - Positive Lookahead `(?=...)`
    - Negative Lookahead `(?!...)`
- **Lookbehinds**
    - Positive Lookbehind `(?<=...)`
    - Negative Lookbehind `(?<!...)`
- **Regex Flags (Modifiers)**
    - `g` (Global)
    - `i` (Case-insensitive)
    - `m` (Multiline mode)
    - `s` (Dotall mode)

**Exercises:**

- Extract phone numbers only if preceded by a country code
- Match email addresses ignoring case

---

### **Module 5: Practical Applications in Programming**

- Using regex in:
    - Python (`re` module)
    - JavaScript (`RegExp` object)
    - Java (`Pattern` and `Matcher` classes)
    - Shell scripting (`grep`, `sed`, `awk`)
- Regex for:
    - Form validation (emails, phone numbers, URLs)
    - Data extraction (log files, CSV, JSON)
    - Web scraping

**Exercises:**

- Write a Python script to extract valid emails from a text file
- Use JavaScript regex to validate a password strength

---

### **Module 6: Performance Optimization and Best Practices**

- Understanding Regex Engine (Backtracking and Execution)
- Avoiding Catastrophic Backtracking
- Optimizing Complex Patterns
- When to Use and When to Avoid Regex

**Exercises:**

- Optimize a regex pattern to improve performance
- Convert inefficient regex patterns into better alternatives

---

### **Final Project: Real-World Application**

- Choose one of the following projects:
    - Build a Regex-based Text Sanitizer
    - Implement a Web Scraper that Uses Regex
    - Develop a Data Cleaning Tool for Log Files

---

# Basic Regex Syntax

## **Literals and Metacharacters**

#### **Literals**

Literals in regex are characters that match exactly as they appear. If you write `hello` in a regex pattern, it will only match the exact string "hello" in a given text.

✅ **Examples**:

- `/cat/` → Matches "cat" in "The cat is sleeping."
- `/apple/` → Matches "apple" in "I like apple pie."

---

#### **Metacharacters**

Metacharacters are special symbols in regex that have a unique meaning instead of matching their literal value.

| **Metacharacter** | **Meaning**                                                     | **Example**                                           |
| ----------------- | --------------------------------------------------------------- | ----------------------------------------------------- |
| `.`               | Matches any character except newline                            | `/c.t/` matches "cat", "cot", "cut"                   |
| `\`               | Escape character (used to match metacharacters as literals)     | `/\./` matches a period `.`                           |
| `^`               | Start of a string                                               | `/^Hello/` matches "Hello world", but not "Say Hello" |
| `$`               | End of a string                                                 | `/world$/` matches "Hello world" but not "worldwide"  |
| `*`               | 0 or more repetitions of the preceding character                | `/a*/` matches "aaa", "a", and "" (empty)             |
| `+`               | 1 or more repetitions of the preceding character                | `/a+/` matches "aaa" and "a", but not ""              |
| `?`               | 0 or 1 occurrence of the preceding character                    | `/colou?r/` matches both "color" and "colour"         |
| `{n}`             | Exact `n` repetitions of the preceding character                | `/a{3}/` matches "aaa" but not "aa"                   |
| `{n,}`            | At least `n` repetitions                                        | `/a{2,}/` matches "aa", "aaa", "aaaa"                 |
| `{n,m}`           | Between `n` and `m` repetitions                                 | `/a{2,4}/` matches "aa", "aaa", "aaaa" but not "a"    |
| `[]`              | Character class (matches any character inside brackets)         | `/[aeiou]/` matches "a", "e", "i", "o", or "u"        |
| `[^ ]`            | Negated character class (matches anything except what's inside) | `/[^aeiou]/` matches any non-vowel letter             |
| `                 | `                                                               | Alternation (OR operator)                             |
| `()`              | Grouping                                                        | `/(ab)+/` matches "abab" but not "a"                  |
| `\d`              | Matches any digit (0-9)                                         | `/\d+/` matches "123" in "A123B"                      |
| `\w`              | Matches any word character (letters, digits, _)                 | `/\w+/` matches "Hello_123"                           |
| `\s`              | Matches whitespace (space, tab, newline)                        | `/\s+/` matches spaces in "Hello World"               |
| `\D`              | Matches any non-digit                                           | `/\D+/` matches "abc" in "123abc456"                  |
| `\W`              | Matches any non-word character                                  | `/\W+/` matches punctuation marks                     |
| `\S`              | Matches any non-whitespace character                            | `/\S+/` matches "Hello" in " Hello "                  |

---

### **Escaping Metacharacters**

Since metacharacters have special meanings, you need to **escape** them using `\` (backslash) if you want to match them as normal characters.

✅ **Examples**:

- `/\./` → Matches a literal period `.`
- `/\*/` → Matches a literal asterisk `*`
- `/\?/` → Matches a literal question mark `?`

💡 **Example Use Case:** Extracting file extensions

```regex
/\.[a-z]+$/
```

This pattern will match `.txt`, `.jpg`, `.pdf`, etc., at the end of a filename.

---

## **Anchors**

Anchors are special regex symbols that match positions in a string rather than actual characters. They are useful for ensuring patterns appear at the beginning, end, or specific boundaries of a string.

---

#### **Start and End Anchors**

|**Anchor**|**Meaning**|**Example**|
|---|---|---|
|`^`|Matches the **start** of a string|`/^Hello/` matches "Hello world" but not "Say Hello"|
|`$`|Matches the **end** of a string|`/world$/` matches "Hello world" but not "worldwide"|

✅ **Examples**:

- `/^abc/` → Matches "abc" in "abc123" but not in "123abc"
- `/xyz$/` → Matches "xyz" in "hello xyz" but not in "xyz hello"

💡 **Use Case**:  
Validating full string matches (e.g., ensuring a username is only lowercase letters)

```regex
/^[a-z]+$/
```

This pattern ensures the entire string consists of only lowercase letters.

---

#### **Word Boundaries**

|**Anchor**|**Meaning**|**Example**|
|---|---|---|
|`\b`|Matches a **word boundary** (between a word and a non-word character)|`/\bcar\b/` matches "car" in "a car" but not in "cartoon"|
|`\B`|Matches **not** a word boundary|`/\Bing/` matches "ing" in "singing" but not in "ingrained"|

✅ **Examples**:

- `/\bcat\b/` → Matches "cat" in "black cat" but not in "caterpillar"
- `/\Bing/` → Matches "ing" in "singing" but not in "ingrained"

💡 **Use Case**:  
Finding standalone words instead of partial matches.

```regex
/\bword\b/
```

This ensures "word" is matched only when it's a full word, not part of "password" or "wording."

---

## **Character Classes**

Character classes define sets of characters that can match a single character in a string. They allow flexibility in pattern matching by specifying ranges or groups of characters.

---

#### **Basic Character Classes**

|**Pattern**|**Meaning**|**Example**|
|---|---|---|
|`[abc]`|Matches **any** of the characters inside|`/[aeiou]/` matches vowels in "hello" → "e", "o"|
|`[^abc]`|Matches **any character except** those inside|`/[^aeiou]/` matches consonants in "hello" → "h", "l", "l"|
|`[a-z]`|Matches **any lowercase letter**|`/[a-z]/` matches "h" in "Hello"|
|`[A-Z]`|Matches **any uppercase letter**|`/[A-Z]/` matches "H" in "Hello"|
|`[0-9]`|Matches **any digit**|`/[0-9]/` matches "4" in "A4B"|
|`[a-zA-Z]`|Matches **any letter (uppercase or lowercase)**|`/[a-zA-Z]/` matches "H" and "e" in "Hello123"|
|`[a-z0-9]`|Matches **any lowercase letter or digit**|`/[a-z0-9]/` matches "h" and "3" in "h3llo"|

✅ **Examples**:

- `/[aeiou]/` → Matches vowels in "hello" ("e", "o")
- `/[0-9]/` → Matches digits in "Year 2025" ("2", "0", "2", "5")

---

#### **Predefined Character Classes**

| **Pattern** | **Equivalent to** | **Meaning**                          | **Example**                                 |
| ----------- | ----------------- | ------------------------------------ | ------------------------------------------- |
| `\d`        | `[0-9]`           | Matches any digit                    | `/\d+/` matches "123" in "Room 123"         |
| `\D`        | `[^0-9]`          | Matches any non-digit                | `/\D+/` matches "Room " in "Room 123"       |
| `\w`        | `[a-zA-Z0-9_]`    | Matches any word character           | `/\w+/` matches "Hello_123" in "Hello_123!" |
| `\W`        | `[^a-zA-Z0-9_]`   | Matches any non-word character       | `/\W+/` matches "!" in "Hello!"             |
| `\s`        | `[ \t\r\n\f]`     | Matches any whitespace               | `/\s+/` matches spaces in "Hello World"     |
| `\S`        | `[^\t\r\n\f]`     | Matches any non-whitespace character | `/\S+/` matches "Hello" in " Hello "        |

✅ **Examples**:

- `/\d+/` → Matches "123" in "ID: 1234"
- `/\s+/` → Matches spaces in "Hello World"
- `/\w+/` → Matches "UserName" in "UserName_42"

---

#### **Character Class Ranges and Combinations**

Character classes can be combined to create more flexible patterns.

✅ **Examples**:

- `/[a-zA-Z0-9]/` → Matches any alphanumeric character
- `/[^0-9a-fA-F]/` → Matches any character except hexadecimal digits
- `/[A-Za-z\s]/` → Matches any letter or space

💡 **Use Case**: Matching hexadecimal color codes

```regex
/^#[0-9A-Fa-f]{6}$/
```

This ensures a valid 6-character hex color code like `#FF5733` or `#abcdef`.

## Control Characters

Control characters are special characters that do not represent visible symbols but instead control the flow of text, such as newlines, tabs, and page breaks. These characters can be matched using escape sequences in regular expressions.

---

#### **Common Control Characters**

|**Escape Sequence**|**Meaning**|**Example Match**|
|---|---|---|
|`\t`|Tab (ASCII 9)|`"Hello\tWorld"` → Matches `\t`|
|`\n`|Newline (ASCII 10)|`"Hello\nWorld"` → Matches `\n`|
|`\r`|Carriage Return (ASCII 13)|`"Hello\rWorld"` → Matches `\r`|
|`\f`|Form Feed (ASCII 12)|`"Page\fBreak"` → Matches `\f`|
|`\v`|Vertical Tab (ASCII 11)|`"Hello\vWorld"` → Matches `\v`|

✅ **Examples**:

- `/\t+/` → Matches one or more tab characters
- `/Hello\nWorld/` → Matches `"Hello"` followed by a newline, then `"World"`

---

💡 **Use Case**:  
Cleaning or formatting text files by removing unnecessary control characters.

```regex
/[\t\n\r\f\v]+/
```

This pattern matches any combination of whitespace control characters.

# Quantifiers and Grouping

## Quantifiers

Quantifiers define how many times a character, group, or character class should appear in a match. They allow patterns to be more flexible by specifying minimum and maximum occurrences.

---

#### **Basic Quantifiers**

|**Quantifier**|**Meaning**|**Example**|
|---|---|---|
|`*`|Matches **0 or more** times|`/a*/` matches "", "a", "aaa" in "aaa"|
|`+`|Matches **1 or more** times|`/a+/` matches "a", "aaa" in "aaa" but not ""|
|`?`|Matches **0 or 1** time (optional)|`/colou?r/` matches "color" and "colour"|
|`{n}`|Matches **exactly `n` times**|`/\d{3}/` matches "123" in "1234"|
|`{n,}`|Matches **at least `n` times**|`/\d{2,}/` matches "12345" in "12345"|
|`{n,m}`|Matches **between `n` and `m` times**|`/\d{2,4}/` matches "12", "123", or "1234" in "12345"|

✅ **Examples**:

- `/a*/` → Matches "", "a", "aa", "aaa"
- `/b+/` → Matches "b", "bb", "bbb" but not ""
- `/\d{4}/` → Matches "2025" in "Year 2025"

---

#### **Greedy vs. Lazy Quantifiers**

Quantifiers in regex can be **greedy** or **lazy**, depending on how much text they try to match.

- **Greedy Quantifiers**: Match **as much as possible** while still allowing the rest of the pattern to match.
- **Lazy Quantifiers**: Match **as little as possible** while still allowing the rest of the pattern to match.

---

#### **Comparison of Greedy and Lazy Quantifiers**

| **Quantifier** | **Type** | **Meaning**                            |
| -------------- | -------- | -------------------------------------- |
| `.*`           | Greedy   | Matches **0 or more** of any character |
| `.*?`          | Lazy     | Matches **as little as possible**      |
| `.+`           | Greedy   | Matches **1 or more** of any character |
| `.+?`          | Lazy     | Matches **as little as possible**      |

✅ **Example 1**: Matching HTML Tags

Input:

```text
<a>First</a><a>Second</a>
```

1. **Greedy (`<.*>`):**
    
    ```regex
    /<.*>/
    ```
    
    **Matches:** `<a>First</a><a>Second</a>` (captures everything between the first `<` and the last `>`)
    
2. **Lazy (`<.*?>`):**
    
    ```regex
    /<.*?>/
    ```
    
    **Matches:** `<a>` (stops at the first `>` instead of continuing)

✅ **Example 2**: Extracting Numbers From Text

**Pattern:**

- **Greedy:** `\d+`
- **Lazy:** `\d+?`

**Input:**

```text
Order: 1000, 2000, 3000
```

|**Type**|**Match Result**|
|---|---|
|Greedy (`\d+`)|`1000`, `2000`, `3000` (matches full numbers)|
|Lazy (`\d+?`)|`1`, `0`, `0`, `0`, `2`, `0`, `0`, `0`, ... (matches one digit at a time)|

---

💡 **Key Takeaways:**

- **Greedy** quantifiers match **as much as possible**.
- **Lazy** quantifiers match **as little as possible** while still allowing the rest of the pattern to match.
- Use **lazy quantifiers (`*?`, `+?`, `{n,m}?`)** when you need to extract smaller, more precise matches.
    
---

💡 **Use Case**: Validating a phone number format

```regex
/^\d{3}-\d{3}-\d{4}$/
```

This ensures a format like `123-456-7890`.

## **Grouping and Capturing**

Grouping and capturing allow you to organize parts of a regex pattern and extract specific matched portions of text.

---

### **1. Grouping with `()`**

Parentheses `()` create groups in regex, which allow you to apply quantifiers to multiple characters and structure complex patterns.

✅ **Example:** Matching repeated words

```regex
/(abc)+/
```

- Matches `"abc"`, `"abcabc"`, `"abcabcabc"`, etc.

✅ **Example:** Matching a date format

```regex
/\d{2}-(Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec)-\d{4}/
```

- Matches `"12-Jan-2025"`, `"01-Feb-1999"`, etc.

---

### **2. Capturing Groups (`()`)**

Capturing groups **store matched text**, which can be retrieved using match groups in programming languages.

✅ **Example:** Extracting a year

```regex
/(\d{4})/
```

- Input: `"Year: 2025"`
- Captures: `"2025"`

✅ **Example:** Extracting first and last names

```regex
/(\w+)\s+(\w+)/
```

- Input: `"John Doe"`
- Group 1: `"John"`, Group 2: `"Doe"`

---

### **3. Non-Capturing Groups `(?:...)`**

Sometimes, grouping is needed without capturing the match. This is useful for structuring patterns without affecting captured groups.

✅ **Example:** Matching "Mr." or "Ms." without capturing the title

```regex
/(?:Mr|Ms)\. (\w+)/
```

- Input: `"Mr. Smith"`
- Captures only `"Smith"`, ignoring `"Mr."`

---

### **4. Backreferences (`\1`, `\2`, etc.)**

Backreferences allow you to refer to previously matched groups **within the same regex pattern**.

✅ **Example:** Detecting duplicate words

```regex
/\b(\w+)\s+\1\b/
```

- Input: `"hello hello world"`
- Matches `"hello hello"`

✅ **Example:** Matching opening and closing HTML tags

```regex
/<(\w+)>.*<\/\1>/
```

- Matches `"<div>Content</div>"`, ensuring both tags are the same

---

💡 **Key Takeaways:**

- Use `()` for **grouping and capturing**.
- Use `(?:...)` for **non-capturing groups**.
- Use `\1`, `\2`, etc., for **backreferences** to enforce repetition of previous matches.

## **Alternation (OR Operator)**

The **alternation operator** (`|`) allows you to match **one pattern or another**, functioning like a logical OR in regular expressions.

---

### **1. Basic Usage**

The `|` symbol separates multiple options, and the regex engine matches **the first possible option**.

✅ **Example:** Matching different fruit names

```regex
/apple|banana|cherry/
```

- Matches `"apple"`, `"banana"`, or `"cherry"` in a string.

✅ **Example:** Matching different spellings

```regex
/color|colour/
```

- Matches both American (`color`) and British (`colour`) spelling.

---

### **2. Grouping with `()` for Alternation**

Using parentheses `()` ensures alternation applies to a specific part of the pattern.

✅ **Example:** Matching file extensions

```regex
/\w+\.(jpg|png|gif)/
```

- Matches `"image.jpg"`, `"photo.png"`, `"icon.gif"`, etc.

✅ **Example:** Matching different date formats

```regex
/\d{2}-(Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec)-\d{4}/
```

- Matches `"12-Jan-2025"`, `"01-Feb-1999"`, etc.

---

### **3. Avoiding Pitfalls: Order Matters**

The regex engine processes alternation **from left to right**, so **more specific patterns should come first** to avoid partial matches.

❌ **Incorrect:**

```regex
/hello|hell/
```

- Input: `"hello"` → Only `"hell"` matches because it appears first.

✅ **Correct:**

```regex
/hell|hello/
```

- Input: `"hello"` → `"hello"` matches correctly.

---

### **4. Using Alternation Inside Character Classes `[]`**

Alternation does **not** work inside character classes `[]`. Use individual characters instead.

❌ **Incorrect:**

```regex
/[a|b|c]/
```

- Matches **literal** characters `"a"`, `"|"`, `"b"`, `"|"`, and `"c"` instead of `"a"`, `"b"`, or `"c"`.

✅ **Correct:**

```regex
/[abc]/
```

- Matches `"a"`, `"b"`, or `"c"` as intended.

---

💡 **Key Takeaways:**

- `|` allows multiple **alternative** matches.
- Use `()` for **scoped** alternation.
- Order matters—**place longer patterns first**.
- **Do not use alternation inside character classes `[]`**—use direct characters instead.

# Lookaheads, Lookbehinds, and Flags

## **Lookaheads**

A **lookahead** is a type of **zero-width assertion** in regex that checks if a pattern exists **ahead** without including it in the match.

---

### **1. Positive Lookahead `(?=...)`**

A **positive lookahead** ensures that a pattern exists **after** the current position, but it is **not part of the match**.

✅ **Example:** Matching "foo" only if followed by "bar"

```regex
/foo(?=bar)/
```

- Input: `"foobar"`, `"foobaz"`
- Matches `"foo"` **only in** `"foobar"` (not `"foobaz"`).

✅ **Example:** Finding words followed by a number

```regex
/\w+(?=\d)/
```

- Input: `"test123 example456"`
- Matches `"test"`, `"example"` (before the digits).

---

### **2. Negative Lookahead `(?!...)`**

A **negative lookahead** ensures that a pattern **does not exist** after the current position.

✅ **Example:** Matching "foo" only if **not** followed by "bar"

```regex
/foo(?!bar)/
```

- Input: `"foobar"`, `"foobaz"`
- Matches `"foo"` **only in** `"foobaz"` (not `"foobar"`).

✅ **Example:** Finding words **not** followed by a number

```regex
/\w+(?!\d)/
```

- Input: `"test123 example"`
- Matches `"example"` (not `"test"`, since `"test"` is followed by `123`).

---

### **3. Combining Lookaheads**

Lookaheads can be combined to enforce multiple conditions **ahead** of the match. Since lookaheads are **zero-width assertions**, they do not consume characters, allowing multiple conditions to be checked simultaneously.

---

#### **1. Combining Positive Lookaheads (`(?=...)`)**

A **match occurs only if all the conditions are met**.

✅ **Example: Match a word followed by both a digit and a punctuation mark**

```regex
/\w+(?=\d)(?=\.)/
```

- Input: `"word123."`, `"word456!"`
- Matches: `"word123"` (since it is followed by **both** a number and a period).

✅ **Example: Match "foo" only if followed by both "bar" and "baz"**

```regex
/foo(?=bar)(?=baz)/
```

- Input: `"foobarbaz"`, `"foobar"`, `"foobaz"`
- Matches `"foo"` **only in** `"foobarbaz"` (since both "bar" and "baz" follow).

---

#### **2. Combining Negative Lookaheads (`(?!...)`)**

A **match occurs only if none of the conditions are met**.

✅ **Example: Match "foo" only if NOT followed by "bar" and "baz"**

```regex
/foo(?!bar)(?!baz)/
```

- Input: `"foobar"`, `"foobaz"`, `"foobat"`
- Matches `"foo"` **only in** `"foobat"`.

✅ **Example: Match words that are NOT followed by a digit or a punctuation mark**

```regex
/\w+(?!\d)(?!\.)/
```

- Input: `"test123"`, `"example."`, `"hello"`
- Matches `"hello"` (since it is **not** followed by a digit or period).

---

#### **3. Combining Positive and Negative Lookaheads**

A match occurs **if certain conditions are met, while others are avoided**.

✅ **Example: Match "foo" if followed by "bar" but NOT "baz"**

```regex
/foo(?=bar)(?!baz)/
```

- Input: `"foobar"`, `"foobaz"`, `"foobarbaz"`
- Matches `"foo"` **only in** `"foobar"`.

✅ **Example: Match words followed by a number but NOT a period**

```regex
/\w+(?=\d)(?!\.)/
```

- Input: `"word123."`, `"word456"`, `"word789!"`
- Matches `"word456"` and `"word789"` (not `"word123"` because it is followed by a period).

---

💡 **Key Takeaways:**

- **Multiple positive lookaheads** ensure **all conditions exist**.
- **Multiple negative lookaheads** ensure **none of the conditions exist**.
- **Mixing positive and negative lookaheads** allows fine control over what follows a match.
- Lookaheads do **not consume characters**, so they can be stacked for complex conditions.

## **Lookbehinds**

A **lookbehind** is a type of **zero-width assertion** in regex that checks if a pattern exists **before** the current position without including it in the match.

---

### **1. Positive Lookbehind `(?<=...)`**

A **positive lookbehind** ensures that a pattern **appears before** the match but **is not part of the match itself**.

✅ **Example:** Matching "bar" only if preceded by "foo"

```regex
/(?<=foo)bar/
```

- Input: `"foobar"`, `"bazbar"`
- Matches `"bar"` **only in** `"foobar"` (not `"bazbar"`).

✅ **Example:** Finding numbers **after** a dollar sign

```regex
/(?<=\$)\d+/
```

- Input: `"$100 and €200"`
- Matches `"100"` (not `"200"` since it lacks `$`).

---

### **2. Negative Lookbehind `(?<!...)`**

A **negative lookbehind** ensures that a pattern **does not appear** before the match.

✅ **Example:** Matching "bar" only if **not** preceded by "foo"

```regex
/(?<!foo)bar/
```

- Input: `"foobar"`, `"bazbar"`
- Matches `"bar"` **only in** `"bazbar"` (not `"foobar"`).

✅ **Example:** Finding numbers **not** preceded by a dollar sign

```regex
/(?<!\$)\d+/
```

- Input: `"$100 and 200"`
- Matches `"200"` (not `"100"` since it's preceded by `$`).

---

### **3. Combining Lookbehinds**

Lookbehinds can be combined to check multiple conditions.

✅ **Example:** Matching "bar" only if preceded by "foo" **but not** "bazfoo"

```regex
/(?<=foo)(?<!bazfoo)bar/
```

- Matches `"bar"` in `"foobar"`, but **not** in `"bazfoobar"`.

✅ **Example:** Finding a number preceded by **either** `$` or `€`

```regex
/(?<=\$|€)\d+/
```

- Input: `"$100 and €200"`
- Matches `"100"` and `"200"`.

---

💡 **Key Takeaways:**

- **Lookbehinds assert conditions before** but **do not consume** characters in the match.
- **Positive Lookbehind `(?<=...)`** → Ensures a pattern **precedes** the match.
- **Negative Lookbehind `(?<!...)`** → Ensures a pattern **does not precede** the match.
- **Lookbehinds can be combined** for advanced pattern matching.
- Some regex engines (like JavaScript) **do not support variable-length lookbehinds** (e.g., `(?<=foo|bar)`).

## **Regex Flags (Modifiers)**

Regex **flags** (also called **modifiers**) alter the behavior of a regex pattern, such as making it case-insensitive, enabling multiline mode, or allowing global searches.

---

### **1. Common Flags**

| **Flag** | **Description**                                           | **Example Regex** | **Effect**                                       |
| -------- | --------------------------------------------------------- | ----------------- | ------------------------------------------------ |
| `i`      | Case-insensitive matching                                 | `/hello/i`        | Matches `"hello"`, `"Hello"`, `"HELLO"`          |
| `g`      | Global search (matches **all** occurrences)               | `/apple/g`        | Finds **all** `"apple"` in `"apple apple"`       |
| `m`      | Multiline mode (anchors `^` and `$` work per line)        | `/^foo/m`         | Matches `"foo"` at the **start of each line**    |
| `s`      | Dotall mode (`.` matches newlines `\n`)                   | `/hello.world/s`  | `"hello\nworld"` matches                         |
| `u`      | Unicode support (enables Unicode properties like `\p{L}`) | `/\p{L}+/u`       | Matches **any** Unicode letter                   |
| `y`      | Sticky mode (matches only at the last match position)     | `/hello/y`        | Matches `"hello"` **only at the exact position** |

---

### **2. Flag Usage in Different Environments**

#### **In JavaScript (Regex literals)**

```javascript
const regex = /hello/i;
console.log(regex.test("HELLO")); // true
```

#### **In Python (`re` module)**

```python
import re
pattern = re.compile(r"hello", re.IGNORECASE)
print(pattern.search("HELLO"))  # Matches
```

#### **In Command Line (`grep`)**

```sh
grep -i "hello" file.txt  # Case-insensitive search for "hello"
```

---

### **3. Combining Multiple Flags**

Flags can be combined to achieve multiple behaviors at once.

✅ **Example: Case-insensitive + Global (`i`, `g`)**

```regex
/word/gi
```

- Finds **all** occurrences of `"word"`, ignoring case.

✅ **Example: Multiline + Dotall (`m`, `s`)**

```regex
/^hello.world/ms
```

- Matches `"hello"` at **start of each line**, even if `"world"` is on another line.

✅ **Example: Unicode property support (`u`)**

```regex
/\p{L}+/u
```

- Matches **any** word in **any** language (`L` = Unicode letter).

---

💡 **Key Takeaways:**

- Flags modify regex behavior (case-insensitivity, multiline, global search, etc.).
- **`i`** → Case-insensitive, **`g`** → Global match, **`m`** → Multiline, **`s`** → Dotall.
- Flags can be **combined** for advanced matching.
- **Some engines** (JavaScript, Python, etc.) use **different syntax** for flags.

### **`y` Flag (Sticky Mode)**

The **`y` flag**, also known as **"sticky mode"**, forces the regex to match **only from the current position in the string**. Unlike the **global `g` flag**, which allows the regex to continue searching from the last match, the `y` flag requires the next match to start **exactly** where the last match ended.

---

#### **1. Key Differences Between `y` and `g` Flags**

|**Flag**|**Behavior**|
|---|---|
|`g` (global)|Continues searching from the **last match position**, skipping characters if necessary.|
|`y` (sticky)|Matches **only** at the exact position where the last match ended. If it fails there, the whole match attempt fails.|

---

#### **2. Example: `y` vs. `g` in JavaScript**

```javascript
const str = "abc abc";
const regexG = /abc/g;
const regexY = /abc/y;

console.log(regexG.exec(str)); // Matches "abc" at index 0
console.log(regexG.exec(str)); // Matches "abc" at index 4 (it skips the space)

console.log(regexY.exec(str)); // Matches "abc" at index 0
console.log(regexY.exec(str)); // null (fails because there's a space at index 3)
```

🔹 **Key Observations:**

- With `g`, the second match happens at index **4** (it skips the space).
- With `y`, the second match **fails** because the next character is a space (it doesn't move past it).

---

#### **3. Practical Use Cases of `y`**

✅ **Parsing structured text**

- Ensures matches occur in sequence without skipping characters.

✅ **Tokenizing strings**

- Used in lexical analysis (e.g., JavaScript's `matchAll`).

✅ **Performance optimization**

- Helps avoid unnecessary backtracking in long strings.

---

#### **4. `y` with `lastIndex` Property**

Since `y` only works from the **exact position** of `lastIndex`, you can manually update `lastIndex` to control where matching starts.

```javascript
const str = "123 456";
const regex = /\d+/y;
regex.lastIndex = 4; // Force search to start at index 4

console.log(regex.exec(str)); // Matches "456"
```

---

💡 **Key Takeaways:**

- The **`y` flag** makes matches **sticky**, meaning they must start exactly at `lastIndex`.
- Unlike **`g`**, it **does not skip characters** to find a match.
- It is mainly used in **parsers, tokenizers, and performance optimizations**.
- Available in **JavaScript**, but not all regex engines support it.


# Advanced Aspects

## **Unicode `\p{}` in Regex**

The `\p{}` syntax is used in **Unicode-aware** regular expressions to match **specific character properties**. It allows matching characters based on their **script, category, or block**, making it useful for multilingual text processing.

---

### **1. Basic Syntax**

```regex
\p{PROPERTY}
```

- Matches any character that belongs to the given **Unicode property**.

To negate a property, use **`\P{}`** (uppercase `P`).

```regex
\P{PROPERTY}
```

- Matches any character **not** belonging to the specified property.

⚠️ **Requires Unicode mode (`u` flag) in some regex engines** (e.g., JavaScript).

---

### **2. Common Unicode Properties**

|**Property**|**Description**|**Example Regex**|**Matches**|
|---|---|---|---|
|`\p{L}`|Any **letter** (includes all alphabets)|`\p{L}+`|`"Hello"`, `"你好"`|
|`\p{Lu}`|**Uppercase** letters|`\p{Lu}+`|`"HELLO"`, `"АБВ"`|
|`\p{Ll}`|**Lowercase** letters|`\p{Ll}+`|`"hello"`, `"абв"`|
|`\p{N}`|Any **number** (digits, Roman numerals, etc.)|`\p{N}+`|`"123"`, `"Ⅶ"`|
|`\p{P}`|Any **punctuation** character|`\p{P}+`|`".,!?-"`|
|`\p{S}`|Any **symbol** (math, currency, etc.)|`\p{S}+`|`"€$+"`|
|`\p{Z}`|**Whitespace** characters|`\p{Z}+`|`" "` (space, non-breaking space, etc.)|
|`\p{C}`|**Control** and invisible characters|`\p{C}+`|`"\n", "\t"`|

🔹 **Example:** Match any letter from any language

```regex
/\p{L}+/
```

- Matches `"Hello"`, `"你好"`, `"Γειά"`, `"Привет"`

🔹 **Example:** Match any number (including non-Arabic numerals)

```regex
/\p{N}+/
```

- Matches `"123"`, `"Ⅶ"`, `"٢"` (Arabic 2)

🔹 **Example:** Match any punctuation

```regex
/\p{P}/
```

- Matches `","`, `"!"`, `"."`, `"?"`

---

### **3. Unicode Script Matching**

You can also match characters by **script** (e.g., Latin, Cyrillic, Arabic).

|**Property**|**Description**|**Example Match**|
|---|---|---|
|`\p{Script=Latin}`|Latin script|`"Hello"`|
|`\p{Script=Cyrillic}`|Cyrillic script|`"Привет"`|
|`\p{Script=Greek}`|Greek script|`"Γειά"`|
|`\p{Script=Arabic}`|Arabic script|`"مرحبا"`|

🔹 **Example:** Match only **Cyrillic** characters

```regex
/\p{Script=Cyrillic}+/
```

- Matches `"Привет"` but not `"Hello"`.

---

### **4. Negating Unicode Properties (`\P{}`)**

To **exclude** a Unicode property, use `\P{}` (uppercase `P`).

🔹 **Example:** Match any character **except** letters

```regex
/\P{L}+/
```

- Matches `"123!@# "` (but not `"Hello"`).

🔹 **Example:** Match text that is **not** Greek

```regex
/\P{Script=Greek}+/
```

- Matches `"Hello"` but **not** `"Γειά"`.

---

💡 **Key Takeaways:**

- `\p{}` matches Unicode **categories, scripts, or blocks**.
- `\P{}` negates the property.
- Works in **Unicode-supported regex engines** (e.g., JavaScript `u` flag, Python, PCRE).
- Helps with **multilingual text processing**.