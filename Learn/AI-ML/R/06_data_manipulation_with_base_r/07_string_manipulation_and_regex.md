## String Manipulation and Regex


### Basic String Functions

```r
text <- c("Hello World", "Data Science", "R Programming")

# String length
nchar(text)                 # Character count: 11, 12, 13

# Case conversion
toupper(text)               # Convert to uppercase
tolower(text)               # Convert to lowercase

# Substring extraction
substr(text, 1, 5)          # First 5 characters of each string
substring(text, 7)          # From 7th character to end
```

### String Searching and Matching

```r
# Pattern matching
grep("Data", text)          # Returns indices of matches: 2
grepl("Data", text)         # Returns logical vector: FALSE TRUE FALSE

# Case-insensitive matching
grep("data", text, ignore.case = TRUE)

# Fixed string matching (no regex)
grep(".", text, fixed = TRUE)   # Literal dot, not regex
```

### String Replacement

```r
# Basic replacement
gsub("World", "Universe", text)     # Replace all occurrences
sub("World", "Universe", text)      # Replace first occurrence only

# Pattern-based replacement
gsub("[0-9]", "X", c("abc123", "def456"))  # Replace digits with X
```

### Advanced Regex Patterns

```r
emails <- c("user@example.com", "invalid-email", "test@domain.org")

# Email validation pattern
email_pattern <- "^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$"
grepl(email_pattern, emails)       # TRUE FALSE TRUE

# Extract parts using regex groups
phone_numbers <- c("123-456-7890", "987-654-3210")
# Extract area code (first 3 digits)
gsub("([0-9]{3})-([0-9]{3})-([0-9]{4})", "\\1", phone_numbers)
```

### String Splitting and Combining

```r
# String splitting
sentences <- "The quick brown fox jumps"
strsplit(sentences, " ")[[1]]       # Split by space

# Multiple strings
multiple_text <- c("a,b,c", "x,y,z")
strsplit(multiple_text, ",")        # Returns list of character vectors

# String combining
paste("Hello", "World")             # "Hello World" (space separator)
paste("Hello", "World", sep = "")   # "HelloWorld" (no separator)
paste0("Hello", "World")            # Same as above

# Vectorized combining
words <- c("Data", "Science")
paste(words, "Rules", sep = " ")    # "Data Rules" "Science Rules"
```

### Pattern Extraction

```r
# Extract all matches
text_with_numbers <- "There are 25 cats and 30 dogs"
regmatches(text_with_numbers, gregexpr("[0-9]+", text_with_numbers))

# Extract first match only
regmatches(text_with_numbers, regexpr("[0-9]+", text_with_numbers))
```

**Key Points:**

- Base R provides comprehensive data manipulation capabilities without external dependencies
- Understanding the difference between `[`, `[[`, and `$` operators is crucial for effective data access
- The `merge()` function offers flexible joining options similar to SQL operations
- String manipulation in base R uses vectorized operations for efficiency
- Regular expressions provide powerful pattern matching capabilities
- Most functions are vectorized, operating on entire vectors or data frame columns simultaneously

**Related Topics:**

- Advanced statistical functions and modeling
- Data visualization with base R graphics
- Performance optimization techniques
- Integration with external data sources
- Custom function development for data manipulation tasks

---

