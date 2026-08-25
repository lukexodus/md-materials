## Unicode Domain Names


**Unicode domain names** are domain names composed of characters from the Unicode Standard, which encompasses virtually all writing systems used in the world. Unicode provides a universal character encoding system that assigns a unique code point to each character across all languages.

The Unicode Standard (maintained by the Unicode Consortium) includes over 149,000 characters covering 159 modern and historic scripts. This comprehensive character set enables domain names to represent virtually any human language.

**Unicode Code Points:**

Each Unicode character is identified by a code point, typically written in hexadecimal notation with a "U+" prefix:

```
U+0041 = A (Latin capital letter A)
U+00E9 = é (Latin small letter e with acute)
U+4E2D = 中 (Chinese character for "middle")
U+0627 = ا (Arabic letter alef)
U+0410 = А (Cyrillic capital letter A)
U+0915 = क (Devanagari letter ka)
```

**Normalization:**

Unicode characters can sometimes be represented in multiple ways. For example, "é" can be encoded as:

- Single character: U+00E9 (precomposed form)
- Two characters: U+0065 + U+0301 (base letter + combining accent)

IDNA requires **Unicode Normalization Form C (NFC)**, which converts characters to their precomposed forms where possible. This ensures consistent representation and comparison of domain names.

**Character Categories:**

The Unicode Standard organizes characters into categories:

**Letters (L)**: Alphabetic characters from all scripts **Marks (M)**: Combining characters and diacritics **Numbers (N)**: Numeric digits from various scripts **Punctuation (P)**: Punctuation marks **Symbols (S)**: Various symbols **Separators (Z)**: Space and invisible separators

IDN specifications define which categories and specific characters are valid in domain names.

**IDNA Character Classes:**

IDNA2008 categorizes Unicode characters into classes that determine their validity in domain names:

**PVALID**: Characters always permitted in domain names

```
Examples:
- Latin letters: a-z, A-Z
- Arabic letters: ا ب ت
- Chinese characters: 中 文
- Cyrillic letters: а б в
```

**CONTEXTJ**: Characters permitted only in specific contexts (primarily zero-width joiner and non-joiner used in scripts like Arabic and Devanagari)

**CONTEXTO**: Characters permitted in specific contexts (middle dot, Greek lower numeral sign, Hebrew punctuation)

**DISALLOWED**: Characters never permitted in domain names

```
Examples:
- Control characters
- Whitespace (except specific exceptions)
- Certain punctuation
- Emoji (under IDNA2008)
- Symbols that could cause confusion
```

**UNASSIGNED**: Code points not yet assigned in Unicode (treated conservatively)

**Script Mixing Rules:**

[Inference] To prevent confusion and potential security issues, many registries implement policies restricting script mixing within a single domain label. Common approaches include:

**Single Script Policy**: Entire domain must use characters from one script **Limited Script Mixing**: Specific script combinations permitted (e.g., Latin + Han for Japanese) **Registry-Specific Rules**: Each TLD defines its own mixing policies

**Example:**

```
Permitted (single script):
münchen.de (all Latin with diacritics)
日本.jp (all Japanese)
москва.рф (all Cyrillic)

Potentially prohibited (mixed scripts):
exаmple.com (mixing Latin 'e' and Cyrillic 'а')
中国example.com (mixing Chinese and Latin)
```

**Right-to-Left Scripts:**

Scripts like Arabic and Hebrew write from right to left (RTL). When used in domain names, special handling ensures proper display:

```
Arabic domain: موقع.مصر
Displayed RTL: رصم.عقوم
(The domain visually appears right-to-left in RTL contexts)
```

Browsers and applications must implement bidirectional text algorithms (Unicode Bidirectional Algorithm) to correctly display mixed LTR and RTL content.

**Case Folding:**

Domain names are case-insensitive in ASCII, but Unicode introduces complexity. IDNA defines **case folding** rules that map uppercase characters to lowercase equivalents:

```
EXAMPLE.COM → example.com
MÜNCHEN.DE → münchen.de
МОСКВА.РФ → москва.рф
```

[Inference] Some scripts lack uppercase/lowercase distinctions (Chinese, Japanese, Arabic, Hebrew). For these scripts, case folding has no effect.

**Zero-Width Characters:**

Certain Unicode characters are invisible:

- Zero Width Joiner (U+200D)
- Zero Width Non-Joiner (U+200C)

These characters are contextually permitted in scripts where they affect character shaping (Arabic, Devanagari, Persian) but prohibited elsewhere to prevent abuse.

**Compatibility Characters:**

Unicode includes compatibility characters for backward compatibility with legacy encodings. IDNA2008 generally prohibits these to prevent confusion:

```
Regular A: U+0041
Full-width A: U+FF21 (DISALLOWED in IDNA2008)
```

**Key Points:**

- Unicode enables domain names in any script
- NFC normalization ensures consistent representation
- Character validity determined by IDNA tables
- Script mixing often restricted for security
- Case folding applies to all scripts
- Right-to-left scripts require bidirectional display algorithms
- Zero-width characters permitted only in specific contexts

**Validation Process:**

Converting a Unicode domain name for DNS use involves:

1. Normalize to Unicode NFC form
2. Apply case folding
3. Validate characters against IDNA tables
4. Check contextual rules for special characters
5. Verify script mixing policies
6. Encode to Punycode for DNS queries

This validation ensures domain names are technically valid, unambiguous, and secure against visual confusion attacks.

Unicode domain names represent the human-readable, culturally appropriate form that users interact with, while the underlying DNS infrastructure continues to use ASCII-compatible encoding for technical compatibility.

