## Character Encoding


Character encoding defines the mapping between abstract characters — letters, digits, symbols, control codes — and their binary representations in memory. Without a defined encoding, a sequence of bytes has no deterministic interpretation as text.

---

### The Fundamental Problem

Hardware stores and transmits bits. Human communication requires characters. Encoding is the contract that resolves this:

```
Character  →  Code Point  →  Binary Representation
   'A'     →     65       →     0100 0001
```

A **character set** defines which characters exist and assigns each a **code point** (an integer ID). An **encoding** defines how that code point is stored as bytes.

---

### ASCII

**American Standard Code for Information Interchange**, standardized in 1963.

- 7-bit encoding → 128 code points (0–127)
- Covers: uppercase/lowercase Latin, digits 0–9, punctuation, 33 control characters
- Stored in 8-bit bytes; the 8th bit was historically unused (later abused for vendor extensions)

#### ASCII Layout

|Range (Dec)|Range (Hex)|Contents|
|---|---|---|
|0–31|0x00–0x1F|Control characters (NUL, LF, CR, TAB, ESC…)|
|32–47|0x20–0x2F|Space and punctuation|
|48–57|0x30–0x39|Digits 0–9|
|65–90|0x41–0x5A|Uppercase A–Z|
|97–122|0x61–0x7A|Lowercase a–z|
|127|0x7F|DEL|

**Key structural properties:**

- `'A'` = 65, `'a'` = 97 → difference of exactly 32 = `0x20`. Toggling bit 5 flips case.
- `'0'` = 48 = `0x30`. Digit `n` is at code point `0x30 + n`. Converting ASCII digit to integer: subtract 48.
- Control characters 0–31 map to Ctrl+key combinations (e.g., `0x0A` = LF = Ctrl+J).

#### Selected ASCII Control Characters

|Code|Hex|Name|Meaning|
|---|---|---|---|
|0|0x00|NUL|Null terminator (C strings)|
|7|0x07|BEL|Terminal bell|
|8|0x08|BS|Backspace|
|9|0x09|HT|Horizontal tab|
|10|0x0A|LF|Line feed (Unix newline)|
|13|0x0D|CR|Carriage return (Windows: CR+LF)|
|27|0x1B|ESC|Escape|
|32|0x20|SP|Space (first printable)|

---

### The Extended ASCII Problem

ASCII's 128 code points cannot represent accented characters (é, ñ, ü), Cyrillic, Greek, or any non-Latin script. Vendors filled the 8th bit (code points 128–255) with different characters, producing incompatible **code pages**:

|Code Page|Coverage|
|---|---|
|ISO 8859-1 (Latin-1)|Western European|
|ISO 8859-5|Cyrillic|
|ISO 8859-6|Arabic|
|Windows-1252|Western European (Windows superset of Latin-1)|
|IBM 437|Original IBM PC (box-drawing characters)|

A file encoded in one code page read under another produces **mojibake** — garbled text. This fragmentation was the direct motivation for Unicode.

---

### Unicode

Unicode is a universal character set maintained by the Unicode Consortium. Its goal: assign a unique code point to every character in every writing system, past and present.

- **Current scope (Unicode 15.1):** 149,813 assigned characters across 161 scripts
- **Maximum code space:** 1,114,112 code points (U+0000 to U+10FFFF)
- Code points are written as `U+` followed by 4–6 hex digits: `U+0041` = 'A', `U+4E2D` = '中', `U+1F600` = '😀'

#### Unicode Planes

The code space is divided into 17 planes of 65,536 code points each:

|Plane|Range|Name|Contents|
|---|---|---|---|
|0|U+0000–U+FFFF|Basic Multilingual Plane (BMP)|Most modern scripts, symbols|
|1|U+10000–U+1FFFF|Supplementary Multilingual Plane|Historic scripts, musical notation|
|2|U+20000–U+2FFFF|Supplementary Ideographic Plane|CJK extensions|
|14|U+E0000–U+EFFFF|Supplementary Special-purpose Plane|Tags|
|15–16|U+F0000–U+10FFFF|Private Use Area|Application-defined|

The BMP contains the overwhelming majority of characters used in modern text.

---

### Unicode Encodings (UTFs)

Unicode defines code points. It does not mandate byte representation — that is handled by **Unicode Transformation Formats (UTFs)**. Three encodings are in widespread use.

<svg viewBox="0 0 680 380" xmlns="http://www.w3.org/2000/svg" font-family="monospace" font-size="12"> <!-- Background --> <rect width="680" height="380" fill="#0d1117" rx="10"/> <!-- Title -->

<text x="340" y="30" text-anchor="middle" fill="#c9d1d9" font-size="14" font-weight="bold">UTF Encoding Comparison</text>

<!-- Column Headers -->

<text x="30" y="60" fill="#8b949e" font-size="11">Encoding</text> <text x="150" y="60" fill="#8b949e" font-size="11">Code Point Range</text> <text x="320" y="60" fill="#8b949e" font-size="11">Bytes Used</text> <text x="430" y="60" fill="#8b949e" font-size="11">Byte Pattern</text>

<line x1="20" y1="66" x2="660" y2="66" stroke="#30363d" stroke-width="1"/> <!-- UTF-8 rows --> <!-- Row 1 -->

<text x="30" y="90" fill="#58a6ff" font-size="12" font-weight="bold">UTF-8</text> <text x="150" y="90" fill="#c9d1d9" font-size="11">U+0000–U+007F</text> <text x="320" y="90" fill="#3fb950" font-size="11">1</text> <text x="430" y="90" fill="#e6c07b" font-size="11">0xxxxxxx</text>

<text x="150" y="112" fill="#c9d1d9" font-size="11">U+0080–U+07FF</text> <text x="320" y="112" fill="#3fb950" font-size="11">2</text> <text x="430" y="112" fill="#e6c07b" font-size="11">110xxxxx 10xxxxxx</text>

<text x="150" y="134" fill="#c9d1d9" font-size="11">U+0800–U+FFFF</text> <text x="320" y="134" fill="#3fb950" font-size="11">3</text> <text x="430" y="134" fill="#e6c07b" font-size="11">1110xxxx 10xxxxxx 10xxxxxx</text>

<text x="150" y="156" fill="#c9d1d9" font-size="11">U+10000–U+10FFFF</text> <text x="320" y="156" fill="#3fb950" font-size="11">4</text> <text x="430" y="156" fill="#e6c07b" font-size="11">11110xxx 10xxxxxx 10xxxxxx 10xxxxxx</text>

<line x1="20" y1="168" x2="660" y2="168" stroke="#30363d" stroke-width="1"/> <!-- UTF-16 rows -->

<text x="30" y="192" fill="#58a6ff" font-size="12" font-weight="bold">UTF-16</text> <text x="150" y="192" fill="#c9d1d9" font-size="11">U+0000–U+FFFF (BMP)</text> <text x="320" y="192" fill="#3fb950" font-size="11">2</text> <text x="430" y="192" fill="#e6c07b" font-size="11">direct 16-bit value</text>

<text x="150" y="214" fill="#c9d1d9" font-size="11">U+10000–U+10FFFF</text> <text x="320" y="214" fill="#3fb950" font-size="11">4</text> <text x="430" y="214" fill="#e6c07b" font-size="11">surrogate pair (2 × 16-bit)</text>

<line x1="20" y1="226" x2="660" y2="226" stroke="#30363d" stroke-width="1"/> <!-- UTF-32 row -->

<text x="30" y="250" fill="#58a6ff" font-size="12" font-weight="bold">UTF-32</text> <text x="150" y="250" fill="#c9d1d9" font-size="11">U+0000–U+10FFFF</text> <text x="320" y="250" fill="#3fb950" font-size="11">4 (fixed)</text> <text x="430" y="250" fill="#e6c07b" font-size="11">00 XX XX XX</text>

<line x1="20" y1="262" x2="660" y2="262" stroke="#30363d" stroke-width="1"/> <!-- Legend / notes -->

<text x="30" y="290" fill="#8b949e" font-size="11">UTF-8 bit capacity per sequence length:</text> <text x="30" y="308" fill="#c9d1d9" font-size="11">1-byte: 7 bits → 128 code points</text> <text x="30" y="324" fill="#c9d1d9" font-size="11">2-byte: 11 bits → 2,048 code points</text> <text x="30" y="340" fill="#c9d1d9" font-size="11">3-byte: 16 bits → 65,536 code points</text> <text x="30" y="356" fill="#c9d1d9" font-size="11">4-byte: 21 bits → 1,114,112 code points</text>

<text x="370" y="290" fill="#8b949e" font-size="11">x = payload bits (code point value)</text> <text x="370" y="308" fill="#8b949e" font-size="11">Leading byte prefix identifies length.</text> <text x="370" y="324" fill="#8b949e" font-size="11">Continuation bytes always: 10xxxxxx</text> <text x="370" y="342" fill="#8b949e" font-size="11">This allows self-synchronization —</text> <text x="370" y="358" fill="#8b949e" font-size="11">any byte position is unambiguous.</text> </svg>

---

### UTF-8 In Depth

UTF-8 is the dominant encoding on the web and in Unix-based systems. Its design properties make it exceptionally practical:

#### Encoding Algorithm

To encode code point `U`:

```
If U ≤ 0x7F:
    output: 0xxxxxxx                          (7 payload bits)

If 0x80 ≤ U ≤ 0x7FF:
    output: 110xxxxx 10xxxxxx                 (11 payload bits)

If 0x800 ≤ U ≤ 0xFFFF:
    output: 1110xxxx 10xxxxxx 10xxxxxx        (16 payload bits)

If 0x10000 ≤ U ≤ 0x10FFFF:
    output: 11110xxx 10xxxxxx 10xxxxxx 10xxxxxx  (21 payload bits)
```

Fill the `x` bits with the binary representation of `U`, most significant bits first.

#### Worked Example: Encoding U+00E9 ('é')

```
U+00E9 = 233 = 1110 1001 in binary (9 bits, fits 2-byte form)

2-byte template:  110xxxxx 10xxxxxx
                      ^^^      ^^^^^^
Payload bits of 0xE9 = 000 11101001  → split as 000 11  |  101001

Result:  110 00011  10 101001
       = 0xC3       0xA9

Bytes stored: C3 A9
```

#### Self-Synchronization Property

UTF-8 byte roles are unambiguous from any byte:

```
0xxxxxxx  → single-byte character (ASCII-compatible)
10xxxxxx  → continuation byte (never a sequence start)
110xxxxx  → start of 2-byte sequence
1110xxxx  → start of 3-byte sequence
11110xxx  → start of 4-byte sequence
```

A parser that loses position can re-synchronize by scanning forward to the next byte that is not `10xxxxxx`. No other encoding offers this property.

#### ASCII Backward Compatibility

Any valid ASCII file is valid UTF-8. Code points U+0000–U+007F encode identically in both. This was a deliberate design choice that enabled gradual adoption.

---

### UTF-16 In Depth

UTF-16 uses 16-bit code units. BMP characters (U+0000–U+FFFF) are stored directly. Characters outside the BMP require **surrogate pairs**.

#### Surrogate Pairs

The BMP range U+D800–U+DFFF is permanently reserved for surrogates and contains no assigned characters.

```
High surrogate:  U+D800–U+DBFF  (1024 values)
Low surrogate:   U+DC00–U+DFFF  (1024 values)
Pairs available: 1024 × 1024 = 1,048,576  (covers all non-BMP code points)
```

**Encoding a non-BMP code point `U`:**

```
U' = U - 0x10000              (range: 0x00000–0xFFFFF, 20 bits)
High surrogate = 0xD800 + (U' >> 10)        (upper 10 bits)
Low  surrogate = 0xDC00 + (U' & 0x3FF)      (lower 10 bits)
```

**Example: U+1F600 ('😀')**

```
U' = 0x1F600 - 0x10000 = 0xF600
   = 0000 1111 01  |  10 0000 0000  (split at bit 10)

High = 0xD800 + 0x003D = 0xD83D
Low  = 0xDC00 + 0x200  = 0xDE00

Stored as: D83D DE00
```

#### Byte Order and BOM

UTF-16 is sensitive to byte order. A **Byte Order Mark (BOM)** at the start of a stream resolves ambiguity:

|BOM Bytes|Byte Order|
|---|---|
|`FF FE`|Little-endian (UTF-16 LE)|
|`FE FF`|Big-endian (UTF-16 BE)|

UTF-16 LE is the native encoding of Windows internal APIs and the Java `char` type (internally).

---

### UTF-32

Each code point is stored as a fixed 32-bit integer. Simple to index (character `n` is always at byte offset `4n`) but space-inefficient — ASCII text in UTF-32 consumes 4× the bytes of UTF-8.

Used internally in some language runtimes (Python 3 uses a variable internal format; some systems use UCS-4, which is effectively UTF-32).

---

### Encoding Comparison

|Property|UTF-8|UTF-16|UTF-32|
|---|---|---|---|
|Unit size|8-bit|16-bit|32-bit|
|Variable width|Yes (1–4 bytes)|Yes (2 or 4 bytes)|No (fixed 4 bytes)|
|ASCII compatible|Yes|No|No|
|BOM required|No|Recommended|Yes|
|Random access by code point|O(n)|O(n)*|O(1)|
|Dominant use|Web, Unix, files|Windows APIs, Java internals|Some runtimes|

*UTF-16 random access is O(1) only for BMP-only text; surrogate pairs break fixed-width assumption.

---

### Normalization

A single visible character can have multiple valid Unicode representations. This creates comparison and storage inconsistencies.

**Example: 'é' (e with acute)**

```
Composed form (NFC):   U+00E9  (single precomposed character)
Decomposed form (NFD): U+0065 U+0301  (e + combining acute accent)
```

Both render identically. String equality fails without normalization.

Unicode defines four normalization forms:

|Form|Description|
|---|---|
|NFC|Canonical decomposition, then canonical composition (most compact, web default)|
|NFD|Canonical decomposition only|
|NFKC|Compatibility decomposition, then canonical composition|
|NFKD|Compatibility decomposition only|

Compatibility decomposition also collapses visually similar but semantically distinct characters (e.g., `ﬁ` ligature → `fi`).

---

### Grapheme Clusters

A **code point** is not always what a user perceives as a single character. A **grapheme cluster** is the smallest user-perceived unit of text:

```
'ệ' = U+0065 (e) + U+0323 (combining dot below) + U+0302 (combining circumflex)
    = 3 code points, 1 grapheme cluster
```

String length in most programming languages counts code units or code points, not grapheme clusters. This has direct implications for text rendering, cursor movement, and string truncation.

---

### Encoding Detection and the BOM

|Encoding|BOM (hex)|
|---|---|
|UTF-8|`EF BB BF` (optional, discouraged)|
|UTF-16 LE|`FF FE`|
|UTF-16 BE|`FE FF`|
|UTF-32 LE|`FF FE 00 00`|
|UTF-32 BE|`00 00 FE FF`|

Without a BOM, encoding must be declared externally (HTTP `Content-Type` header, XML declaration, HTML `<meta charset>`) or heuristically detected. Heuristic detection is inherently unreliable and a source of security vulnerabilities.

---

### Hardware and Systems Perspective

At the systems level, character encoding intersects several architecture concerns:

```
Memory layout:    Endianness affects multi-byte encodings (UTF-16, UTF-32)
String operations: strlen() in C assumes null-terminated bytes; breaks on UTF-16
SIMD processing:  Fixed-width encodings (UTF-32) permit vectorized operations
                  Variable-width encodings require sequential parsing or
                  special SIMD algorithms (e.g., simdjson UTF-8 validation)
Kernel/OS layer:  Linux kernel internals use byte strings (mostly ASCII)
                  Windows NT kernel uses UTF-16 LE natively throughout
```

---

### Common Encoding Bugs

|Bug|Cause|
|---|---|
|Mojibake (garbled text)|File read under wrong encoding|
|Truncated multibyte character|Buffer split at byte boundary, not code point boundary|
|Incorrect string length|Counting bytes instead of code points or grapheme clusters|
|Failed equality comparison|Unnormalized Unicode (NFC vs NFD)|
|Security bypass|Overlong UTF-8 encodings (now illegal per RFC 3629) used to bypass path checks|

Overlong encodings were a real attack vector: the null character `U+0000` could be encoded as `C0 80` in early implementations, bypassing C string termination checks. RFC 3629 (2003) explicitly prohibits overlong encodings.

---

**Key Points**

- ASCII is 7-bit, 128 characters, backward-compatible with the low half of UTF-8.
- Unicode assigns code points; UTFs define byte storage. These are distinct concerns.
- UTF-8 is variable-width (1–4 bytes), ASCII-compatible, and self-synchronizing. It is the dominant encoding for interchange.
- UTF-16 uses surrogate pairs for non-BMP characters. It is not ASCII-compatible and requires BOM or external byte-order declaration.
- UTF-32 is fixed-width, enabling O(1) code point indexing, at significant space cost.
- A code point is not the same as a grapheme cluster; string length semantics depend on which unit is being counted.
- Normalization (NFC/NFD) is necessary for correct Unicode string comparison.

**Conclusion** Character encoding is a boundary layer between human-readable text and binary storage. Errors at this boundary — wrong encoding assumptions, missing normalization, byte-vs-character confusion — are among the most persistent sources of bugs in systems software. A complete understanding of ASCII, Unicode code points, and the UTF family of encodings is prerequisite to correct text handling at any level of the stack.

**Next Steps** Proceed to _Binary Arithmetic and Overflow_ to examine how bit patterns are operated on arithmetically, or to _IEEE 754 Floating-Point Representation_ to see how encoding principles extend to real numbers.

---

