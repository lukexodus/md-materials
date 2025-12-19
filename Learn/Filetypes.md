# .ini

.ini files are configuration files that use a simple, human-readable format to store settings and parameters for applications, operating systems, and services. The name comes from "initialization" since these files often contain startup configuration data.

## Basic Syntax Rules

### Structure Overview
INI files are organized into sections with key-value pairs:

```ini
[Section]
key=value
```

### Case Sensitivity
**[Inference]** Case sensitivity varies by implementation:
- Section names: usually case-insensitive
- Key names: often case-insensitive
- Values: typically case-sensitive

**Note:** The actual behavior depends on the parser being used.

## Core Components

### Sections

Sections are defined by square brackets:

```ini
[Database]
host=localhost
port=5432

[Application]
name=MyApp
debug=false
```

**Rules:**
- Section names are enclosed in `[` and `]`
- Sections group related settings
- All keys must belong to a section (in most implementations)

### Key-Value Pairs

**Basic syntax:**
```ini
key=value
```

**Alternative delimiters:**
```ini
; Equals sign (most common)
name=John

; Colon (supported by some parsers)
name: John
```

### Comments

```ini
; This is a comment (most common)
# This is also a comment (supported by some parsers)

[Section]
key=value  ; Inline comments may work depending on parser
```

## Data Types

### Strings

```ini
[Settings]
; Unquoted strings
name=John Doe
path=C:\Users\Documents

; Quoted strings (when needed for spaces or special chars)
message="Hello, World!"
description='Single quotes may work'

; Empty values
empty=
blank=
```

### Numbers

```ini
[Configuration]
; Integers
port=8080
timeout=30

; Floats
version=1.5
ratio=0.75

; Note: Parser determines if these are numbers or strings
```

### Booleans

**[Unverified]** Different parsers accept different boolean representations:

```ini
[Flags]
; Common representations
enabled=true
disabled=false

; Alternative formats (parser-dependent)
active=yes
inactive=no

debug=on
production=off

feature=1
oldfeature=0
```

### No Native Lists or Objects

**Important limitation:** Standard INI format does not support arrays or nested structures.

**Common workarounds:**

```ini
; Comma-separated values
[Features]
modules=auth,logging,cache

; Numbered keys
[Users]
user1=Alice
user2=Bob
user3=Carol

; Repeated keys (parser-dependent)
[Servers]
host=server1.example.com
host=server2.example.com
host=server3.example.com
```

## Sections in Detail

### Global Section

Some parsers allow keys before any section:

```ini
; Global settings (not in all parsers)
version=1.0
author=John

[Application]
name=MyApp
```

### Section Hierarchy

**Standard INI:** No hierarchy support

**Extended formats (like TOML-style):**
```ini
[parent.child]
value=something

; Or dot notation in keys
[settings]
database.host=localhost
database.port=5432
```

**[Inference]** This is a parser-specific extension and not part of the original INI specification.

## Advanced Features

### Multiline Values

**[Unverified]** Support varies by parser:

```ini
[Text]
; Line continuation with backslash
description=This is a long \
description that spans \
multiple lines

; Indented continuation
message=Line one
    Line two (indented continuation)
```

### Variable Substitution

**[Unverified]** Some parsers support variable interpolation:

```ini
[Paths]
root=/var/www
html=${root}/html
logs=${root}/logs

; Or with different syntax
base=C:\Program Files
app=$(base)\MyApp
```

### Including Other Files

**[Unverified]** Parser-specific feature:

```ini
; Various syntaxes exist
include=/path/to/other.ini
#include "another.ini"
```

## Common Variations

### Windows INI
```ini
[Settings]
Name=Application
Version=1.0
Path=C:\Program Files\App
```

### PHP INI Style
```ini
[PHP]
engine = On
short_open_tag = Off
max_execution_time = 30
memory_limit = 128M
```

### Git Config Style
```ini
[core]
    repositoryformatversion = 0
    filemode = true
    bare = false
[remote "origin"]
    url = https://github.com/user/repo.git
    fetch = +refs/heads/*:refs/remotes/origin/*
```

## Best Practices

### Organization
```ini
; Group related settings in sections
[Database]
host=localhost
port=5432
name=mydb

[Cache]
enabled=true
ttl=3600

[Logging]
level=info
file=/var/log/app.log
```

### Naming Conventions

```ini
[Section Names]
; Use clear, descriptive names
; PascalCase or lowercase common

[application_settings]
; Underscores for multi-word names
max_connections=100

; Or camelCase
maxConnections=100
```

### Comments and Documentation

```ini
;==================================
; Application Configuration
;==================================

[Database]
; Primary database connection
host=localhost      ; Default to localhost
port=5432          ; PostgreSQL default port
```

### Value Formatting

```ini
[Formatting]
; Be consistent with spacing
option1=value
option2=value

; Or with spaces around equals
option3 = value
option4 = value

; Avoid mixing styles in same file
```

## Common Pitfalls

### Special Characters

```ini
[Problems]
; These may cause issues without quotes
semicolon=value;with;semicolons  ; May be truncated at first semicolon
hash=value#with#hashes           ; May be treated as comment
equals=key=value                 ; May confuse parser

; Better to quote
semicolon="value;with;semicolons"
```

### Whitespace

```ini
[Whitespace]
; Leading/trailing spaces handling varies
trimmed=value
spaced = value 
quoted="  value with spaces  "
```

### Duplicate Keys

```ini
[Duplicates]
; Behavior varies by parser
key=first
key=second  ; May overwrite, append, or cause error
```

### Reserved Characters

```ini
[Characters]
; Watch out for
brackets=[value]      ; May confuse section parsing
quotes=value"with"quotes
backslash=C:\path     ; Escape handling varies
```

## Complete Example

```ini
;==================================
; Application Configuration File
; Version: 1.0
; Last Updated: 2024-12-13
;==================================

; Global settings
app_name=MyApplication
version=1.0.0

[Database]
; Primary database connection
type=postgresql
host=localhost
port=5432
database=myapp_db
username=dbuser
password=secret123
pool_size=10
timeout=30

[Server]
host=0.0.0.0
port=8080
debug=false
workers=4

[Logging]
enabled=true
level=info
file=/var/log/myapp.log
max_size=10485760  ; 10MB in bytes
rotation=daily

[Cache]
enabled=true
type=redis
host=localhost
port=6379
ttl=3600

[Features]
; Feature flags
authentication=true
api_v2=false
experimental=false

[Email]
smtp_host=smtp.example.com
smtp_port=587
from_address=noreply@example.com
use_tls=true

[Paths]
static=/var/www/static
uploads=/var/www/uploads
temp=/tmp/myapp
```

## Format Comparison Note

INI is simpler than YAML or JSON but has limitations:
- **No native arrays or nested objects**
- **No standardized data types** (everything is potentially a string)
- **Parser-dependent features** (comments, escaping, multiline)
- **Best for simple, flat configurations**

For more complex configurations, consider YAML, JSON, or TOML instead.

## Common Use Cases

INI files are widely used for:
- Application configuration (desktop software, games)
- System settings (Windows registry alternatives)
- Database connection strings
- Web server configuration
- Development environment settings

## Advantages

- Simple, readable format that non-technical users can edit
- Widely supported across programming languages
- Platform-independent
- Lightweight with minimal overhead
- Easy to parse and generate

## Limitations

- No standardized specification (implementations vary)
- Limited data types (mainly strings)
- No support for nested structures
- No built-in validation
- Encoding issues can occur with special characters

## Programming Language Support

Most programming languages have libraries for reading and writing INI files:
- **Python**: `configparser` module
- **C#**: `System.Configuration` namespace
- **Java**: Various third-party libraries
- **JavaScript/Node.js**: `ini` npm package
- **PHP**: `parse_ini_file()` function

INI files remain popular for configuration management due to their simplicity and broad compatibility, though more complex applications often use JSON, YAML, or XML formats instead.

---

# .yaml

YAML (YAML Ain't Markup Language) is a human-readable data serialization standard commonly used for configuration files, data exchange, and structured data storage. It was originally called "Yet Another Markup Language" but was later redefined to emphasize its data-oriented nature.

## Key Features

YAML is designed to be:
- **Human-readable** and easy to edit
- **Language-independent** 
- **Expressive** enough to represent complex data structures
- **Minimal** in syntax overhead

## Basic Syntax Rules

### Indentation
- YAML uses spaces (not tabs) for indentation
- The number of spaces doesn't matter, but consistency within each level is required
- Typically 2 or 4 spaces per indentation level

```yaml
parent:
  child: value
  another_child: value
```

### Key-Value Pairs
Basic structure uses a colon followed by a space:

```yaml
key: value
name: John
age: 30
```

### Comments
Comments start with `#` and continue to the end of the line:

```yaml
# This is a comment
name: John  # This is also a comment
```

## Data Types

### Scalars (Simple Values)

**Strings:**
```yaml
# Unquoted (most common)
name: John Doe

# Single quotes (literal)
message: 'Hello, World!'

# Double quotes (allows escape sequences)
path: "C:\\Users\\file.txt"

# Multi-line (preserves newlines)
description: |
  This is line one
  This is line two

# Multi-line (folds into single line)
description: >
  This text will be
  folded into a
  single line
```

**Numbers:**
```yaml
integer: 42
float: 3.14
scientific: 1.5e+3
```

**Booleans:**
```yaml
enabled: true
disabled: false
# Also accepted: yes/no, on/off
```

**Null:**
```yaml
value: null
# Also: ~
empty: ~
```

### Lists (Arrays)

**Block style:**
```yaml
fruits:
  - apple
  - banana
  - orange
```

**Flow style (inline):**
```yaml
fruits: [apple, banana, orange]
```

**Nested lists:**
```yaml
matrix:
  - [1, 2, 3]
  - [4, 5, 6]
  - [7, 8, 9]
```

### Maps (Dictionaries/Objects)

**Block style:**
```yaml
person:
  name: John
  age: 30
  city: New York
```

**Flow style (inline):**
```yaml
person: {name: John, age: 30, city: New York}
```

**Nested maps:**
```yaml
company:
  name: TechCorp
  location:
    city: San Francisco
    country: USA
```

## Complex Structures

### List of Maps
```yaml
employees:
  - name: John
    role: Developer
    age: 30
  - name: Jane
    role: Designer
    age: 28
```

### Map of Lists
```yaml
departments:
  engineering:
    - Alice
    - Bob
  sales:
    - Carol
    - Dave
```

### Mixed Nesting
```yaml
project:
  name: MyApp
  team:
    - name: Alice
      skills:
        - Python
        - JavaScript
    - name: Bob
      skills:
        - Java
        - Go
```

## Special Features

### Anchors and Aliases
Reuse content with `&` (anchor) and `*` (alias):

```yaml
defaults: &defaults
  timeout: 30
  retries: 3

production:
  <<: *defaults
  server: prod.example.com

development:
  <<: *defaults
  server: dev.example.com
```

### Document Separators
Multiple documents in one file:

```yaml
---
document: 1
name: First
---
document: 2
name: Second
```

### Explicit Data Types
```yaml
string: !!str 123
integer: !!int "123"
float: !!float "3.14"
```

## Common Pitfalls

### Indentation Errors
```yaml
# Wrong - inconsistent indentation
parent:
  child: value
   wrong: value  # Extra space

# Correct
parent:
  child: value
  correct: value
```

### Quoted vs Unquoted Strings
```yaml
# These characters require quotes
special: "value: with colon"
hash: "value # with hash"

# Numbers as strings
version: "1.20"  # String
port: 8080       # Number
```

### Boolean Confusion
```yaml
# These are booleans
enabled: yes
active: true

# These are strings
response: "yes"
answer: 'true'
```

## Best Practices

1. **Use consistent indentation** (2 or 4 spaces)
2. **Use quotes for strings with special characters**
3. **Keep it readable** - YAML prioritizes human readability
4. **Use comments** to explain complex structures
5. **Validate your YAML** before deploying (many online validators available)
6. **Avoid tabs** - always use spaces
7. **Use explicit types** when ambiguity might occur

## Example: Complete Configuration File

```yaml
# Application Configuration
version: "1.0"

app:
  name: MyApplication
  port: 8080
  debug: false
  
database:
  host: localhost
  port: 5432
  credentials:
    username: admin
    password: secret123
  
features:
  - authentication
  - logging
  - caching
  
logging:
  level: info
  output: |
    /var/log/app.log
    
environments:
  development:
    api_url: http://localhost:3000
    timeout: 60
  production:
    api_url: https://api.example.com
    timeout: 30
```

This covers the fundamental syntax and structure of YAML. The format emphasizes readability and simplicity while supporting complex nested data structures.

## Common Use Cases

- **Configuration files** (Docker Compose, Kubernetes, CI/CD pipelines)
- **API documentation** (OpenAPI/Swagger specifications)
- **Data exchange** between applications
- **Infrastructure as Code** (Ansible playbooks, CloudFormation)
- **Static site generators** (Jekyll, Hugo front matter)

## Advantages

- Extremely readable and writable by humans
- Supports complex data structures
- No need for closing tags or brackets
- Widely supported across programming languages
- Great for version control (clear diffs)

## Disadvantages

- **Indentation sensitivity** can cause errors
- **Performance** is slower than JSON for parsing
- **Complexity** in advanced features can be confusing
- **Security risks** if parsing untrusted YAML (code execution)
- **Ambiguity** in some edge cases

## Best Practices

- Use consistent indentation (2 or 4 spaces, never tabs)
- Quote strings when ambiguity might occur
- Validate YAML files before deployment
- Be cautious with user-supplied YAML content
- Use comments to explain complex configurations

YAML has become the de facto standard for many DevOps tools and cloud-native applications, largely replacing XML and complementing JSON in the configuration space.

---

# .json

JSON (JavaScript Object Notation) is a lightweight, text-based data interchange format that's easy for humans to read and write, and easy for machines to parse and generate. Despite its name suggesting a connection to JavaScript, JSON is language-independent and widely used across all programming languages.

## Structure and Syntax

JSON is built on two main structures:
- **Objects**: collections of key-value pairs enclosed in curly braces `{}`
- **Arrays**: ordered lists of values enclosed in square brackets `[]`

```json
{
  "name": "John Doe",
  "age": 30,
  "isActive": true,
  "address": {
    "street": "123 Main St",
    "city": "New York",
    "zipCode": "10001"
  },
  "hobbies": ["reading", "swimming", "coding"],
  "spouse": null
}
```

## Data Types

JSON supports six data types:
- **String**: text enclosed in double quotes
- **Number**: integer or floating-point
- **Boolean**: true or false
- **null**: represents empty value
- **Object**: collection of key-value pairs
- **Array**: ordered list of values

## Syntax Rules

- Data is in name/value pairs
- Data is separated by commas
- Objects are enclosed in curly braces `{}`
- Arrays are enclosed in square brackets `[]`
- Strings must use double quotes (not single quotes)
- No trailing commas allowed
- No comments supported

## Common Use Cases

- **Web APIs** and REST services
- **Configuration files** for applications
- **Data storage** in NoSQL databases
- **AJAX** requests in web applications
- **Package managers** (package.json in Node.js)
- **Data exchange** between systems

## Advantages

- **Simple and lightweight** syntax
- **Fast parsing** and generation
- **Widely supported** across all programming languages
- **Human-readable** format
- **Strict specification** reduces ambiguity
- **Compact** size for data transmission

## Disadvantages

- **No comments** support
- **Limited data types** (no dates, functions, etc.)
- **No schema validation** built-in
- **Verbose** for simple configurations
- **No multi-line strings** without escaping
- **Security risks** if parsing untrusted JSON

## JSON vs Other Formats

| Feature | JSON | XML | YAML |
|---------|------|-----|------|
| Readability | Good | Fair | Excellent |
| Parsing Speed | Fast | Slow | Moderate |
| Size | Compact | Verbose | Compact |
| Comments | No | Yes | Yes |
| Schema Support | External | Built-in | External |

## Best Practices

- Validate JSON structure before processing
- Use consistent naming conventions (camelCase or snake_case)
- Keep nesting levels reasonable
- Use proper data types (don't store numbers as strings)
- Consider using JSON Schema for validation
- Be cautious with user-supplied JSON content

JSON remains the most popular data interchange format for web applications and APIs due to its simplicity, broad support, and excellent performance characteristics.

---

# Web Font Format Comparison

## WOFF (Web Open Font Format)
- **Release**: 2009
- **Compression**: Zlib compression applied to font data
- **Size**: Typically 40% smaller than uncompressed TTF/OTF
- **Browser support**: All modern browsers (IE9+, released 2011)
- **Structure**: Container format that wraps TTF or OTF with metadata

## WOFF2
- **Release**: 2014
- **Compression**: Brotli compression algorithm
- **Size**: Typically 30% smaller than WOFF (about 50% smaller than TTF/OTF overall)
- **Browser support**: All modern browsers since ~2016 (Chrome 36+, Firefox 39+, Safari 10+, Edge 14+)
- **Performance**: Better compression means faster loading
- **Current recommendation**: Preferred format for web use

## OTF (OpenType Font)
- **Release**: 1996 (jointly by Adobe and Microsoft)
- **Structure**: PostScript-based outlines (CFF data)
- **Features**: Supports advanced typographic features (ligatures, alternates, etc.)
- **Size**: Uncompressed
- **Use case**: Desktop publishing, design software, legacy web support

## TTF (TrueType Font)
- **Release**: 1980s (Apple and Microsoft)
- **Structure**: TrueType outlines (glyf data)
- **Features**: Simpler than OTF but widely compatible
- **Size**: Uncompressed
- **Use case**: Desktop systems, legacy web support

## Key Differences Summary

**Compression**: WOFF2 > WOFF > TTF/OTF (uncompressed)

**Web optimization**: WOFF2 and WOFF are specifically designed for web delivery with compression and metadata support. TTF/OTF are desktop formats.

**File size ranking** (smallest to largest): WOFF2 < WOFF < TTF ≈ OTF

**Modern web practice**: Serve WOFF2 with WOFF fallback. TTF/OTF are typically used as source formats or for older browser support.

---

# Video Codecs for Web Development

## H.264 (AVC - Advanced Video Coding)
- **Release**: 2003
- **Patent status**: Patent-encumbered, licensing fees apply for some uses
- **Browser support**: Universal (all major browsers)
- **Quality**: Good quality at moderate bitrates
- **Use case**: Most widely compatible codec, default choice for broad compatibility
- **Typical container**: MP4
- **Hardware support**: Excellent hardware acceleration on nearly all devices

## H.265 (HEVC - High Efficiency Video Coding)
- **Release**: 2013
- **Patent status**: Patent-encumbered with complex licensing
- **Browser support**: Limited (Safari on Apple devices, Edge on Windows with hardware support)
- **Quality**: ~50% better compression than H.264 at same quality
- **Use case**: Apple ecosystem, high-quality video with smaller file sizes
- **Typical container**: MP4
- **Hardware support**: Modern Apple devices, newer Windows PCs

## VP8
- **Release**: 2008 (Google)
- **Patent status**: Royalty-free, open source
- **Browser support**: All modern browsers
- **Quality**: Comparable to H.264
- **Use case**: Open-source alternative, WebRTC
- **Typical container**: WebM
- **Hardware support**: Limited compared to H.264

## VP9
- **Release**: 2013 (Google)
- **Patent status**: Royalty-free, open source
- **Browser support**: Chrome, Firefox, Edge, Opera (not Safari)
- **Quality**: Comparable to H.265, better than H.264
- **Use case**: YouTube, open-source projects, when Safari support isn't critical
- **Typical container**: WebM
- **Hardware support**: Growing support on Android, Chrome devices

## AV1
- **Release**: 2018 (Alliance for Open Media - Google, Mozilla, Cisco, etc.)
- **Patent status**: Royalty-free, open source
- **Browser support**: Chrome 70+, Firefox 67+, Edge 79+, Safari 17+ (limited)
- **Quality**: ~30% better compression than VP9/H.265
- **Use case**: Future-focused projects, streaming services (Netflix, YouTube)
- **Typical container**: MP4, WebM
- **Hardware support**: Limited but growing (newer GPUs, mobile chips)
- **Encoding speed**: Slower than alternatives

## Theora
- **Release**: 2004
- **Patent status**: Royalty-free, open source
- **Browser support**: Most browsers (legacy)
- **Quality**: Inferior to modern codecs
- **Use case**: Largely obsolete, replaced by VP8/VP9
- **Typical container**: Ogg

## Comparison Table

| Codec | Quality/Compression | Browser Support | License | Hardware Decode | Best For |
|-------|-------------------|-----------------|---------|-----------------|----------|
| **H.264** | Good | Universal | Patented | Excellent | Maximum compatibility |
| **H.265** | Excellent | Limited (Apple/Windows) | Patented | Good (modern) | Apple ecosystem |
| **VP8** | Good | Universal | Free | Limited | WebRTC, open source |
| **VP9** | Excellent | Good (no Safari) | Free | Growing | YouTube, Android |
| **AV1** | Best | Growing | Free | Limited | Future-proofing, streaming |
| **Theora** | Poor | Legacy | Free | Minimal | Obsolete |

## Current Best Practices

**For maximum compatibility** (2025):
```html
<video controls>
  <source src="video.mp4" type="video/mp4; codecs=avc1.4d002a">
  <source src="video.webm" type="video/webm; codecs=vp9">
</video>
```

**For modern browsers with fallback**:
```html
<video controls>
  <source src="video.mp4" type="video/mp4; codecs=av01.0.05M.08">
  <source src="video.webm" type="video/webm; codecs=vp9">
  <source src="video.mp4" type="video/mp4; codecs=avc1.4d002a">
</video>
```

**Recommended approach**:
- Primary: H.264 (MP4) for universal support
- Progressive enhancement: Add VP9 or AV1 for better compression where supported
- Consider H.265 only if targeting Apple ecosystem specifically

---

# Audio Codecs for Web Development

## MP3 (MPEG-1/2 Audio Layer III)
- **Release**: 1993
- **Patent status**: Patents expired (2017 in US, earlier elsewhere)
- **Browser support**: Universal (all major browsers)
- **Quality**: Lossy, good quality at 128-320 kbps
- **Bitrate**: Typically 128-320 kbps
- **Use case**: Default choice for maximum compatibility
- **Typical container**: MP3 file, MP4
- **File size**: Moderate

## AAC (Advanced Audio Coding)
- **Release**: 1997
- **Patent status**: Patent-encumbered
- **Browser support**: Universal (all major browsers)
- **Quality**: Better than MP3 at same bitrate (~30% more efficient)
- **Bitrate**: Typically 96-256 kbps
- **Use case**: Modern default, iOS/Apple ecosystem, video soundtracks
- **Typical container**: MP4, M4A
- **File size**: Smaller than MP3 for same quality

## Opus
- **Release**: 2012
- **Patent status**: Royalty-free, open source
- **Browser support**: All modern browsers (Chrome 33+, Firefox 15+, Edge 14+, Safari 11+)
- **Quality**: Best-in-class across all bitrates (6-510 kbps)
- **Bitrate**: Variable, 6-510 kbps (excels at low bitrates)
- **Use case**: WebRTC, voice chat, music streaming, modern web apps
- **Typical container**: WebM, Ogg
- **File size**: Best compression efficiency
- **Latency**: Very low, ideal for real-time

## Vorbis (Ogg Vorbis)
- **Release**: 2000
- **Patent status**: Royalty-free, open source
- **Browser support**: All modern browsers
- **Quality**: Comparable to MP3, slightly better at lower bitrates
- **Bitrate**: Typically 64-320 kbps
- **Use case**: Open-source projects, gaming (historically)
- **Typical container**: Ogg, WebM
- **File size**: Similar to MP3
- **Status**: Largely superseded by Opus

## FLAC (Free Lossless Audio Codec)
- **Release**: 2001
- **Patent status**: Royalty-free, open source
- **Browser support**: Chrome 56+, Firefox 51+, Edge 16+, Safari 11+
- **Quality**: Lossless (bit-perfect reproduction)
- **Compression**: ~50-70% of original WAV size
- **Use case**: High-fidelity audio, archival, audiophile applications
- **Typical container**: FLAC file, Ogg
- **File size**: Large (but smaller than WAV)

## WAV (Waveform Audio File Format)
- **Release**: 1991
- **Patent status**: None (uncompressed)
- **Browser support**: Universal
- **Quality**: Lossless, uncompressed
- **Bitrate**: ~1411 kbps for CD quality (44.1kHz, 16-bit stereo)
- **Use case**: Raw audio, editing, when file size doesn't matter
- **Typical container**: WAV file
- **File size**: Very large

## WebM Audio (Vorbis/Opus in WebM)
- **Release**: 2010 (container)
- **Patent status**: Royalty-free, open source
- **Browser support**: All modern browsers (except Safari was late)
- **Quality**: Depends on codec (Vorbis or Opus)
- **Use case**: Open web standards, HTML5 audio
- **Typical container**: WebM
- **Codecs used**: Vorbis or Opus

## AC-3 (Dolby Digital)
- **Release**: 1992
- **Patent status**: Patent-encumbered, Dolby licensing
- **Browser support**: Limited (Safari, some others with hardware support)
- **Quality**: Good for surround sound
- **Use case**: Surround sound, video soundtracks, streaming services
- **Typical container**: MP4, various video formats
- **Channels**: Up to 5.1 surround

## E-AC-3 (Dolby Digital Plus)
- **Release**: 2005
- **Patent status**: Patent-encumbered, Dolby licensing
- **Browser support**: Limited (Safari, Edge on Windows)
- **Quality**: Better than AC-3, up to 7.1 channels
- **Use case**: High-quality video soundtracks, streaming platforms
- **Typical container**: MP4
- **Channels**: Up to 7.1 surround

## Comparison Table

| Codec | Type | Quality/Efficiency | Browser Support | License | File Size | Best For |
|-------|------|-------------------|-----------------|---------|-----------|----------|
| **MP3** | Lossy | Good | Universal | Free (expired) | Moderate | Maximum compatibility |
| **AAC** | Lossy | Better | Universal | Patented | Small-Moderate | Modern default, video |
| **Opus** | Lossy | Best | Universal (modern) | Free | Smallest | Real-time, streaming, future |
| **Vorbis** | Lossy | Good | Universal | Free | Moderate | Legacy open source |
| **FLAC** | Lossless | Perfect | Good (modern) | Free | Large | High-fidelity, archival |
| **WAV** | Uncompressed | Perfect | Universal | Free | Very Large | Raw audio, editing |
| **AC-3** | Lossy | Good (surround) | Limited | Patented | Moderate | Surround sound |
| **E-AC-3** | Lossy | Better (surround) | Limited | Patented | Moderate | HD surround sound |

## Current Best Practices

**For maximum compatibility** (2025):
```html
<audio controls>
  <source src="audio.mp3" type="audio/mpeg">
  <source src="audio.ogg" type="audio/ogg; codecs=opus">
</audio>
```

**For modern browsers with optimal quality**:
```html
<audio controls>
  <source src="audio.opus" type="audio/opus">
  <source src="audio.m4a" type="audio/mp4; codecs=mp4a.40.2">
  <source src="audio.mp3" type="audio/mpeg">
</audio>
```

**For high-fidelity applications**:
```html
<audio controls>
  <source src="audio.flac" type="audio/flac">
  <source src="audio.m4a" type="audio/mp4">
</audio>
```

## Recommended Approach

**General web use**:
- Primary: **AAC** (M4A/MP4) for good quality and compatibility
- Fallback: **MP3** for older devices
- Progressive: **Opus** for best efficiency in modern browsers

**Voice/Real-time** (WebRTC, conferencing):
- Primary: **Opus** (specifically designed for this)

**Music streaming**:
- Modern: **Opus** (better quality at lower bitrates)
- Compatible: **AAC** or **MP3**

**Archival/High-fidelity**:
- **FLAC** for lossless compression
- **WAV** for uncompressed

**File size priority**:
1. Opus (smallest for given quality)
2. AAC
3. MP3
4. Vorbis

---

# Media Container Formats for Web Development

## MP4 (.mp4, .m4a, .m4v)
- **Full name**: MPEG-4 Part 14
- **Release**: 2001
- **Patent status**: Some patents, widely licensed
- **Browser support**: Universal (all major browsers)
- **Video codecs**: H.264, H.265/HEVC, AV1 (newer)
- **Audio codecs**: AAC, MP3, AC-3, E-AC-3
- **Features**: Streaming support, chapters, subtitles, metadata
- **Use case**: Default choice for web video, most compatible
- **Streaming**: HTTP progressive download, HLS, DASH
- **File extensions**: .mp4 (video), .m4a (audio only), .m4v (Apple variant)

## WebM (.webm)
- **Release**: 2010 (Google)
- **Patent status**: Royalty-free, open source
- **Browser support**: Chrome, Firefox, Edge, Opera (Safari 14.1+ with limitations)
- **Video codecs**: VP8, VP9, AV1
- **Audio codecs**: Vorbis, Opus
- **Features**: Streaming, chapters, subtitles, designed for HTML5
- **Use case**: Open-source projects, YouTube, when Safari isn't critical
- **Streaming**: DASH, WebRTC
- **Benefits**: No licensing fees, modern codec support

## Ogg (.ogg, .ogv, .oga, .ogx)
- **Release**: 1993 (container), 2003 (video)
- **Patent status**: Royalty-free, open source
- **Browser support**: Firefox, Chrome, Opera (not Safari, not IE/old Edge)
- **Video codecs**: Theora (obsolete), VP8, VP9
- **Audio codecs**: Vorbis, Opus, FLAC, Speex
- **Features**: Unlimited codec support, metadata, streaming
- **Use case**: Legacy open-source projects, audio (Opus/Vorbis)
- **Status**: Largely replaced by WebM for video
- **File extensions**: .ogg (audio), .ogv (video), .oga (audio), .ogx (multiplexed)

## MOV (.mov, .qt)
- **Full name**: QuickTime File Format
- **Release**: 1991 (Apple)
- **Patent status**: Apple proprietary (but widely supported)
- **Browser support**: Safari (native), limited in others
- **Video codecs**: H.264, H.265/HEVC, ProRes, many others
- **Audio codecs**: AAC, PCM, many others
- **Features**: Professional features, multiple tracks, extensive metadata
- **Use case**: Apple ecosystem, video editing, Safari-specific content
- **Relationship**: MP4 is based on MOV format
- **Note**: Often requires conversion for web use

## AVI (.avi)
- **Full name**: Audio Video Interleave
- **Release**: 1992 (Microsoft)
- **Patent status**: Microsoft, widely supported
- **Browser support**: Poor (not recommended for web)
- **Video codecs**: Various (DivX, Xvid, H.264, many legacy codecs)
- **Audio codecs**: MP3, PCM, AC-3, various
- **Features**: Simple container, legacy support
- **Use case**: Legacy systems, desktop playback only
- **Issues**: No native browser support, inconsistent codec support
- **Recommendation**: Convert to MP4 for web

## MKV/Matroska (.mkv, .mka, .mks)
- **Full name**: Matroska Multimedia Container
- **Release**: 2002
- **Patent status**: Royalty-free, open source
- **Browser support**: None (no native browser support)
- **Video codecs**: Nearly all (H.264, H.265, VP9, AV1, etc.)
- **Audio codecs**: Nearly all (AAC, Opus, FLAC, DTS, etc.)
- **Features**: Extensive features, multiple audio/subtitle tracks, chapters, menus
- **Use case**: Archival, high-quality media, desktop playback
- **Benefits**: Most flexible container, no codec limitations
- **Web use**: Requires conversion to MP4/WebM

## FLV (.flv)
- **Full name**: Flash Video
- **Release**: 2002 (Macromedia/Adobe)
- **Patent status**: Adobe proprietary
- **Browser support**: None (Flash deprecated 2020)
- **Video codecs**: Sorenson Spark, VP6, H.264
- **Audio codecs**: MP3, AAC, Nellymoser
- **Use case**: Obsolete, legacy Flash content only
- **Status**: Dead format, convert to MP4
- **Historical note**: Was dominant for web video pre-HTML5

## 3GP/3G2 (.3gp, .3g2)
- **Full name**: 3rd Generation Partnership Project
- **Release**: 1998
- **Patent status**: Various mobile standards
- **Browser support**: Limited/inconsistent
- **Video codecs**: H.263, H.264, MPEG-4
- **Audio codecs**: AMR, AAC
- **Features**: Optimized for mobile networks (3G)
- **Use case**: Legacy mobile video, obsolete for modern web
- **Recommendation**: Convert to MP4

## MPEG (.mpg, .mpeg, .m2v)
- **Full name**: Moving Picture Experts Group
- **Release**: 1993 (MPEG-1), 1995 (MPEG-2)
- **Patent status**: Patent-encumbered
- **Browser support**: Limited/inconsistent
- **Video codecs**: MPEG-1, MPEG-2
- **Audio codecs**: MP2, MP3
- **Features**: Basic streaming, DVD/broadcast standard (MPEG-2)
- **Use case**: Legacy video, DVD sources
- **Recommendation**: Convert to MP4 for web

## TS (.ts, .m2ts)
- **Full name**: MPEG Transport Stream
- **Release**: 1995
- **Patent status**: Patent-encumbered (MPEG-2)
- **Browser support**: Indirect (used in HLS streaming)
- **Video codecs**: H.264, H.265, MPEG-2
- **Audio codecs**: AAC, MP3, AC-3
- **Features**: Designed for broadcast, error resilience
- **Use case**: HLS streaming (Apple), broadcast, Blu-ray
- **Streaming**: Primary format for HLS (.m3u8 playlists)
- **Direct playback**: Not for direct `<video>` tag use

## WMV/ASF (.wmv, .asf)
- **Full name**: Windows Media Video / Advanced Systems Format
- **Release**: 1999 (Microsoft)
- **Patent status**: Microsoft proprietary
- **Browser support**: None (legacy IE only with plugins)
- **Video codecs**: WMV (VC-1)
- **Audio codecs**: WMA
- **Use case**: Obsolete, legacy Windows content
- **Recommendation**: Convert to MP4

## Comparison Table

| Container | Browser Support | Video Codecs | Audio Codecs | License | Web Ready | Best For |
|-----------|----------------|--------------|--------------|---------|-----------|----------|
| **MP4** | Universal | H.264, H.265, AV1 | AAC, MP3, AC-3 | Patented | ✅ Yes | Maximum compatibility |
| **WebM** | Modern (no Safari*) | VP8, VP9, AV1 | Vorbis, Opus | Free | ✅ Yes | Open source, modern |
| **Ogg** | Limited | Theora, VP8 | Vorbis, Opus | Free | ⚠️ Audio only | Audio (Opus) |
| **MOV** | Safari only | H.264, H.265 | AAC | Apple | ⚠️ Limited | Apple ecosystem |
| **MKV** | None | Any | Any | Free | ❌ No | Archival, convert first |
| **AVI** | None | Various | Various | Microsoft | ❌ No | Legacy, convert first |
| **FLV** | None (Flash dead) | VP6, H.264 | MP3, AAC | Adobe | ❌ No | Obsolete |
| **TS** | Indirect (HLS) | H.264, H.265 | AAC, AC-3 | Patented | ⚠️ Streaming | HLS streaming |

*Safari 14.1+ has limited VP9 support

## Feature Comparison

| Container | Streaming | Multiple Audio | Subtitles | Chapters | Metadata | Complexity |
|-----------|-----------|----------------|-----------|----------|----------|------------|
| **MP4** | ✅ Yes | ✅ Yes | ✅ Yes | ✅ Yes | ✅ Rich | Medium |
| **WebM** | ✅ Yes | ✅ Yes | ✅ Yes | ✅ Yes | ✅ Good | Medium |
| **Ogg** | ✅ Yes | ✅ Yes | Limited | Limited | ✅ Basic | Low |
| **MOV** | ✅ Yes | ✅ Yes | ✅ Yes | ✅ Yes | ✅ Extensive | High |
| **MKV** | ✅ Yes | ✅ Unlimited | ✅ Unlimited | ✅ Yes | ✅ Extensive | High |
| **AVI** | ❌ No | Limited | ❌ No | ❌ No | Limited | Low |

## Current Best Practices (2025)

**Standard web video**:
```html
<video controls>
  <source src="video.mp4" type="video/mp4">
  <source src="video.webm" type="video/webm">
</video>
```

**With modern codecs**:
```html
<video controls>
  <!-- AV1 in MP4 for newest browsers -->
  <source src="video-av1.mp4" type='video/mp4; codecs="av01.0.05M.08"'>
  
  <!-- VP9 in WebM for modern browsers -->
  <source src="video-vp9.webm" type='video/webm; codecs="vp9"'>
  
  <!-- H.264 in MP4 for compatibility -->
  <source src="video-h264.mp4" type='video/mp4; codecs="avc1.42E01E"'>
</video>
```

**Audio only**:
```html
<audio controls>
  <source src="audio.m4a" type="audio/mp4">
  <source src="audio.webm" type="audio/webm; codecs=opus">
  <source src="audio.mp3" type="audio/mpeg">
</audio>
```

## Streaming Protocols & Containers

**HLS (HTTP Live Streaming)** - Apple standard:
- Container: **TS** (.ts segments)
- Playlist: .m3u8
- Support: Universal (all browsers via native or hls.js)

**DASH (Dynamic Adaptive Streaming)** - MPEG standard:
- Container: **MP4** or **WebM** (fragmented)
- Manifest: .mpd (XML)
- Support: Chrome, Firefox, Edge (via dash.js)

**WebRTC**:
- Container: **WebM** (VP8/VP9/Opus or H.264/Opus)
- Real-time peer-to-peer

## Recommended Approach

**For maximum compatibility**:
- Primary: **MP4** with H.264 + AAC
- Progressive: **WebM** with VP9 + Opus for modern browsers
- Future: Add **AV1** in MP4 for efficiency

**For streaming**:
- **HLS** with TS segments (universal compatibility)
- **DASH** with MP4 segments (efficient, modern)

**For open-source projects**:
- Primary: **WebM** (VP9 + Opus)
- Fallback: **MP4** (H.264 + AAC)

**For archival/offline**:
- **MKV** (most flexible, lossless options)
- Convert to **MP4** for distribution

**Avoid for web**:
- FLV (Flash is dead)
- AVI (no browser support)
- WMV/ASF (proprietary, no support)
- MKV for direct playback (convert first)

---

# Compression & Archival Formats for Web Development

## Gzip (.gz)
- **Release**: 1992
- **Algorithm**: DEFLATE (LZ77 + Huffman coding)
- **Compression ratio**: Good (typically 60-70% reduction for text)
- **Speed**: Fast compression and decompression
- **Browser support**: Universal (HTTP Content-Encoding: gzip)
- **Use case**: Default HTTP compression, single file compression
- **Command line**: `gzip file.txt` (creates file.txt.gz)
- **Web server**: Automatic compression of text resources (HTML, CSS, JS, JSON)
- **Limitations**: Single file only, no directory/archive support

## Brotli (.br)
- **Release**: 2015 (Google)
- **Algorithm**: LZ77 + Huffman + context modeling
- **Compression ratio**: Excellent (10-25% better than gzip for text)
- **Speed**: Slower compression, fast decompression
- **Browser support**: All modern browsers (Chrome 50+, Firefox 44+, Safari 11+, Edge 15+)
- **Use case**: HTTP compression for static assets, WOFF2 fonts
- **Command line**: `brotli file.txt` (creates file.txt.br)
- **Web server**: Modern HTTP compression (Content-Encoding: br)
- **Compression levels**: 0-11 (11 = maximum compression, very slow)
- **Best for**: Pre-compressed static assets (CSS, JS, fonts)

## Zip (.zip)
- **Release**: 1989
- **Algorithm**: DEFLATE (same as gzip)
- **Compression ratio**: Good (similar to gzip)
- **Speed**: Fast
- **Browser support**: JavaScript libraries (JSZip, etc.), native File System Access API
- **Use case**: Multi-file archives, client-side file bundling, downloads
- **Structure**: Archive format with directory support
- **Features**: Individual file compression, metadata, no solid compression
- **Platform**: Universal compatibility across all OS

## Tar + Gzip (.tar.gz, .tgz)
- **Components**: Tar (archive) + Gzip (compression)
- **Compression ratio**: Good (same as gzip)
- **Speed**: Fast
- **Browser support**: JavaScript libraries required
- **Use case**: Unix/Linux distributions, source code archives, server-side bundling
- **Structure**: Tar creates archive, then gzip compresses entire archive
- **Benefits**: Preserves Unix permissions, symbolic links
- **Common in**: Node.js ecosystem, npm packages (tarballs)

## Tar + Brotli (.tar.br)
- **Components**: Tar (archive) + Brotli (compression)
- **Compression ratio**: Excellent (better than tar.gz)
- **Speed**: Slower compression, fast decompression
- **Browser support**: Limited, JavaScript libraries required
- **Use case**: Modern alternative to tar.gz for distributions
- **Status**: Less common, but growing

## 7zip (.7z)
- **Release**: 1999
- **Algorithm**: LZMA/LZMA2 (Lempel-Ziv-Markov chain)
- **Compression ratio**: Excellent (often best for general data)
- **Speed**: Slow compression, moderate decompression
- **Browser support**: JavaScript libraries (7z-wasm, etc.)
- **Use case**: Maximum compression for downloads, archives
- **Features**: Solid compression, AES-256 encryption, very high compression
- **Platform**: Requires 7-Zip software or libraries

## Zstandard/Zstd (.zst)
- **Release**: 2016 (Facebook/Meta)
- **Algorithm**: LZ77 + entropy coding (FSE, Huffman)
- **Compression ratio**: Excellent (comparable to Brotli)
- **Speed**: Very fast compression and decompression
- **Browser support**: Limited (no native browser support yet)
- **Use case**: Real-time compression, large-scale data transfer, emerging HTTP compression
- **Compression levels**: 1-22 (negative levels for ultra-fast)
- **Benefits**: Best balance of speed and compression ratio
- **Status**: Growing adoption, used by Facebook, Linux kernel, npm

## LZ4 (.lz4)
- **Release**: 2011
- **Algorithm**: LZ77 variant
- **Compression ratio**: Moderate (lower than gzip)
- **Speed**: Extremely fast (emphasis on speed over ratio)
- **Browser support**: JavaScript libraries available
- **Use case**: Real-time compression where speed is critical
- **Benefits**: Decompression speed ~10x faster than gzip
- **Trade-off**: Larger files than gzip/brotli

## Comparison Table

| Format | Compression Ratio | Compression Speed | Decompression Speed | Browser Support | Best For |
|--------|------------------|-------------------|---------------------|-----------------|----------|
| **Gzip** | Good (baseline) | Fast | Fast | Universal (HTTP) | Default HTTP compression |
| **Brotli** | Excellent (+15-25%) | Slow | Fast | Modern browsers | Static assets, fonts |
| **Zip** | Good (= gzip) | Fast | Fast | JS libraries | Multi-file archives |
| **7z** | Excellent | Very Slow | Moderate | JS libraries | Maximum compression |
| **Zstd** | Excellent | Very Fast | Very Fast | Limited | Real-time, future HTTP |
| **LZ4** | Moderate (-40%) | Extremely Fast | Extremely Fast | JS libraries | Speed-critical |
| **Tar.gz** | Good | Fast | Fast | JS libraries | Unix/Linux archives |

## Web Server Configuration

**HTTP Compression Priority** (Content-Encoding):
1. **Brotli** (if supported by client and pre-compressed available)
2. **Gzip** (universal fallback)
3. **Uncompressed** (if neither supported)

**Typical nginx configuration**:
```nginx
# Gzip
gzip on;
gzip_types text/plain text/css application/json application/javascript text/xml application/xml;
gzip_min_length 1000;

# Brotli (with ngx_brotli module)
brotli on;
brotli_types text/plain text/css application/json application/javascript text/xml application/xml;
```

## File Size Comparison (Example)

For a typical 100KB JavaScript file:
- **Uncompressed**: 100 KB
- **Gzip**: ~30 KB (70% reduction)
- **Brotli (level 11)**: ~25 KB (75% reduction)
- **Zstd (level 19)**: ~26 KB (74% reduction)
- **7z (ultra)**: ~24 KB (76% reduction)

For a 1MB text/JSON file:
- **Uncompressed**: 1000 KB
- **Gzip**: ~150-200 KB
- **Brotli**: ~120-170 KB
- **Zstd**: ~130-180 KB
- **7z**: ~110-160 KB

## Best Practices for Web Development

**Static Assets** (CSS, JS, fonts):
```
Pre-compress with both:
- file.js.gz (gzip)
- file.js.br (brotli level 11)
Configure server to serve pre-compressed files
```

**Dynamic Content** (HTML, API responses):
```
Use on-the-fly compression:
- Brotli (levels 4-6 for dynamic content)
- Gzip (fallback)
```

**Client-Side Downloads** (user-generated archives):
```
Use Zip format with JSZip:
- Universal compatibility
- JavaScript-accessible
- No server processing needed
```

**Large File Transfers**:
```
Consider:
- Zstd for best speed/ratio balance
- 7z for maximum compression
- Split into chunks for resumable downloads
```

**Real-Time Data**:
```
- LZ4 for maximum speed
- Zstd (low levels 1-3) for balanced approach
- Gzip as universal fallback
```

## Recommended Approach

**For most web projects**:
- Static assets: Pre-compress with **Brotli** + **Gzip** fallback
- Dynamic content: On-the-fly **Brotli** (level 4-6) or **Gzip**
- User downloads: **Zip** for compatibility

**For modern/performance-focused projects**:
- Explore **Zstd** for future-proofing
- Use **Brotli level 11** for all static assets
- Consider **7z** for large downloadable archives

**For maximum compatibility**:
- Primary: **Gzip** (universal)
- Archives: **Zip** (universal)
- Avoid formats requiring special software