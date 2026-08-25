## Strings and strconv Packages


### strings Package

Provides utilities for manipulating UTF-8 encoded strings, treating them as slices of runes rather than bytes.

**String Manipulation Functions**

- `Contains`, `ContainsAny`, `ContainsRune` - substring searching
- `Count` - counts non-overlapping instances
- `Fields`, `FieldsFunc` - splits strings into fields
- `HasPrefix`, `HasSuffix` - prefix/suffix checking
- `Index`, `IndexAny`, `IndexByte`, `IndexRune` - position finding
- `Join` - concatenates slice elements with separator
- `Repeat` - repeats string n times
- `Replace`, `ReplaceAll` - string replacement
- `Split`, `SplitAfter`, `SplitN` - string splitting
- `ToLower`, `ToUpper`, `Title` - case conversion
- `Trim`, `TrimSpace`, `TrimPrefix`, `TrimSuffix` - whitespace/character removal

**strings.Builder** Efficient string concatenation for building strings incrementally:

- Minimizes memory copying
- Grows buffer as needed
- Provides `WriteString`, `WriteByte`, `WriteRune` methods
- `String()` method returns built string

**strings.Reader** Implements io.Reader, io.ReaderAt, io.Seeker for reading from strings.

### strconv Package

Handles conversions between strings and other basic data types.

**String to Numeric Conversions**

- `Atoi` - string to int (base 10)
- `ParseBool` - string to boolean
- `ParseFloat` - string to floating-point
- `ParseInt`, `ParseUint` - string to integer with specified base

**Numeric to String Conversions**

- `Itoa` - int to string (base 10)
- `FormatBool` - boolean to string
- `FormatFloat` - floating-point to string with precision control
- `FormatInt`, `FormatUint` - integer to string with specified base

**Quoting and Unquoting**

- `Quote`, `QuoteRune` - adds quotes and escapes
- `Unquote`, `UnquoteChar` - removes quotes and unescapes
- `QuoteToASCII` - quotes with ASCII-only output

