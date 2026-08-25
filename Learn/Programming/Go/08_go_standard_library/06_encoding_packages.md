## encoding Packages


Go's encoding packages provide standardized ways to convert data between different formats.

### json Package

Handles JavaScript Object Notation encoding and decoding.

**Core Functions**

- `Marshal` - encodes Go values to JSON
- `Unmarshal` - decodes JSON to Go values
- `MarshalIndent` - formatted JSON output
- Encoder/Decoder types for streaming

**Struct Tags** Control JSON field behavior:

```go
type Person struct {
    Name  string `json:"name"`
    Age   int    `json:"age,omitempty"`
    Email string `json:"-"`
}
```

**Tag Options**

- Field renaming: `json:"custom_name"`
- Omit empty: `json:",omitempty"`
- Skip field: `json:"-"`
- String conversion: `json:",string"`

**Custom Marshaling** Types can implement:

- `json.Marshaler` interface
- `json.Unmarshaler` interface

### xml Package

Handles Extensible Markup Language encoding and decoding.

**Core Functions**

- `Marshal`, `MarshalIndent` - Go values to XML
- `Unmarshal` - XML to Go values
- Encoder/Decoder for streaming

**Struct Tags**

```go
type Book struct {
    Title  string `xml:"title,attr"`
    Author string `xml:"author"`
    Pages  int    `xml:",chardata"`
}
```

**Tag Options**

- Attribute: `xml:",attr"`
- Character data: `xml:",chardata"`
- CDATA: `xml:",cdata"`
- Element naming: `xml:"custom-name"`

### csv Package

Handles Comma-Separated Values reading and writing.

**Reader** `csv.Reader` provides:

- `Read()` - reads single record
- `ReadAll()` - reads all records
- Configurable delimiter, comment character
- Field count validation
- Quote handling

**Writer** `csv.Writer` provides:

- `Write()` - writes single record
- `WriteAll()` - writes multiple records
- `Flush()` - ensures data written
- Configurable delimiter and quote character

**Configuration Options**

- `Comma` - field delimiter (default comma)
- `Comment` - comment character
- `FieldsPerRecord` - field count validation
- `LazyQuotes` - allows lazy quote parsing
- `TrimLeadingSpace` - trims leading whitespace

**Output** The Go standard library represents one of the most well-designed and comprehensive standard libraries in modern programming languages. Its consistent interfaces, comprehensive documentation, and battle-tested reliability make it an excellent foundation for building robust applications. The packages work together cohesively, sharing common patterns and interfaces that make the entire ecosystem feel unified and predictable.

**Related Topics**: Go interfaces and embedding, concurrency patterns with goroutines and channels, Go modules and dependency management, testing with the testing package, HTTP programming with net/http, database programming with database/sql

---

