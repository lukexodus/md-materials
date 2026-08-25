## Punycode Encoding Algorithm


**Punycode** is the encoding algorithm that converts Unicode domain labels to ASCII-compatible format for use in DNS infrastructure. Defined in **RFC 3492**, Punycode enables Unicode domain names to function within ASCII-only DNS protocols without requiring changes to core DNS software.

The algorithm is specifically designed for encoding Internationalized Domain Names in Applications (IDNA), though it can theoretically encode any Unicode string. Punycode is deterministic, bijective (one-to-one mapping), and produces compact ASCII representations.

**Algorithm Overview:**

Punycode separates the encoding process into two phases:

1. **Basic code points** (ASCII characters already in the string) are copied directly
2. **Non-basic code points** (non-ASCII Unicode characters) are encoded using a compressed representation

The encoded string consists of:

- All ASCII characters from the original string (if any)
- A delimiter (hyphen) separating basic from encoded sections
- Encoded representation of non-ASCII characters and their positions

**Encoding Structure:**

```
Basic-ASCII-Characters-EncodedNonASCII

Example:
münchen → mnchen-3ya
(ASCII: mnchen, Delimiter: -, Encoded: 3ya)
```

**Detailed Encoding Process:**

**Step 1: Extract Basic Code Points**

Copy all ASCII characters (code points < 128) directly to the output in their original positions:

```
Input: münchen
ASCII extracted: mnchen
Remaining to encode: ü (U+00FC)
```

**Step 2: Add Delimiter**

If there are both ASCII and non-ASCII characters, insert a hyphen (-) to separate them:

```
Output so far: mnchen-
```

**Step 3: Encode Non-Basic Code Points**

Punycode uses a variable-length encoding scheme with bias adaptation to efficiently encode the positions and values of non-ASCII characters.

The algorithm iteratively processes non-ASCII characters in order of their Unicode code points, encoding both:

- The character's code point value
- Its position in the original string

**Key Algorithm Parameters:**

```
base = 36 (uses digits 0-9 and letters a-z)
tmin = 1
tmax = 26
skew = 38
damp = 700
initial_bias = 72
initial_n = 128 (first non-ASCII code point)
delimiter = '-' (hyphen)
```

**Bias Adaptation:**

Punycode uses adaptive bias to optimize encoding efficiency. The bias adjusts based on the number of code points processed, making frequent patterns more compact.

**Variable-Length Integer Encoding:**

Non-ASCII characters are encoded as variable-length base-36 integers. Each digit represents a value from 0-35:

```
0-9 → values 0-9
a-z → values 10-35
```

**Complete Example Walkthrough:**

Encoding **"münchen"**:

```
Step 1: Extract ASCII
ASCII: m, n, c, h, e, n
Non-ASCII: ü (U+00FC, decimal 252)

Step 2: Initial output
mnchen-

Step 3: Encode ü position and value
Position: 1 (after 'm')
Code point: 252
Bias: 72 (initial)

Calculation: [specific encoding arithmetic]
Encoded: 3ya

Final result: mnchen-3ya
```

Encoding **"日本"** (Japan):

```
Step 1: No ASCII characters
Output: (empty)

Step 2: No delimiter needed
Output: (empty)

Step 3: Encode both characters
日 = U+65E5 (decimal 26085)
本 = U+672C (decimal 26412)

Encoded: wgv71a
Final result: wgv71a
```

**Decoding Process:**

Punycode decoding reverses the encoding:

1. Split string at the last hyphen
2. Characters before hyphen are literal ASCII
3. Characters after hyphen are decoded to extract Unicode code points and positions
4. Insert decoded characters at specified positions

```
Input: mnchen-3ya
Split: "mnchen" | "3ya"
Decode "3ya" → ü at position 1
Result: münchen
```

**Properties of Punycode:**

**Bijective**: Every Unicode string has exactly one Punycode encoding, and every valid Punycode string decodes to exactly one Unicode string.

**Compact**: ASCII characters require no encoding overhead. Non-ASCII characters are encoded efficiently, especially when similar code points appear.

**Case-preserving**: Although domain names are case-insensitive, Punycode preserves case information for applications that need it.

**ASCII-safe**: Encoded output contains only ASCII letters, digits, and hyphens, compatible with all DNS implementations.

**Key Points:**

- Punycode enables Unicode in ASCII-only DNS
- Defined in RFC 3492
- Uses base-36 encoding for efficiency
- Adaptive bias optimizes compression
- Bijective mapping ensures unique encoding/decoding
- ASCII characters pass through unchanged
- Encoding is deterministic and reversible

**Algorithm Complexity:**

[Inference] Punycode encoding time complexity is approximately O(n × m) where n is the number of non-ASCII characters and m is the total string length. Decoding is approximately O(m) where m is the encoded string length.

**Limitations:**

**Maximum length**: Encoded labels are limited to 63 octets (DNS label length limit), which constrains how many Unicode characters can be encoded, particularly for high code point values.

**No compression**: Each Unicode character requires encoding space. Strings with many unique non-ASCII characters produce longer encoded outputs.

**Not human-readable**: Encoded strings (after the "xn--" prefix) are not meaningful to humans, though this is by design for DNS compatibility.

**Example Encodings:**

```
Original → Punycode

münchen → mnchen-3ya
zürich → zrich-kva
москва → 80ake
中国 → fiqs8s
مصر → wgbl6i
παράδειγμα → hxajbheg2az4pqz2a
日本語 → wgv71a119e
example → example (no encoding needed)
```

The Punycode algorithm successfully bridges Unicode's rich character set with DNS's ASCII limitations, enabling internationalized domain names while maintaining full backward compatibility with existing internet infrastructure.

