## Punycode Encoding


Punycode is the ASCII-compatible encoding algorithm used to represent IDN labels in DNS. It transforms Unicode strings into ASCII strings prefixed with a distinctive marker.

**Encoding Marker:**

Punycode-encoded labels begin with the ASCII prefix `xn--` followed by the encoded representation. This prefix signals that the label contains encoded Unicode content. The label `münchen` becomes `xn--mnchen-3ya` when encoded.

**Encoding Algorithm:**

The Punycode algorithm separates ASCII and non-ASCII characters within a label. ASCII characters (basic code points) are preserved in their original form. Non-ASCII characters (extended code points) are encoded using a variable-length integer encoding scheme with positional insertion markers.

**Encoding Process:**

For the label `münchen`: The basic ASCII characters `m`, `n`, `c`, `h`, `e`, `n` are extracted, forming the base string `mnchen`. The non-ASCII character `ü` (U+00FC) is encoded with positional information. The position indicator and character code are compressed using base-36 encoding. The result combines as `xn--mnchen-3ya`, where `3ya` encodes the insertion of `ü` after the second character.

**Base-36 Encoding:**

Punycode uses base-36 (digits 0-9 and letters a-z) to represent encoded values compactly. The algorithm employs variable-length encoding where certain positions trigger threshold adjustments, optimizing for common cases while supporting arbitrary Unicode code points.

**Delimiter Function:**

When basic ASCII characters exist in the original label, a hyphen separates them from the encoded portion. In `xn--mnchen-3ya`, the final hyphen delimits `mnchen` (basic characters) from `3ya` (encoded insertion data). Labels containing only non-ASCII characters lack this delimiter.

**Decoding Process:**

Punycode decoding reverses the transformation. The decoder recognizes the `xn--` prefix, extracts basic characters before the final hyphen, interprets the encoded portion to determine insertion positions and code points, and reconstructs the Unicode string by inserting characters at specified positions.

**Case Insensitivity:**

Punycode encoding is case-insensitive. The encoded form uses lowercase letters, and decoders treat uppercase and lowercase equivalently. Domain name case-insensitivity extends to Punycode labels.

**Length Constraints:**

DNS labels are limited to 63 octets. Punycode-encoded labels must respect this constraint. Long Unicode labels may exceed the limit after encoding, making them invalid for DNS registration. The `xn--` prefix and encoding overhead reduce the effective capacity for Unicode characters.

**All-ASCII Labels:**

Labels containing only ASCII characters are not Punycode-encoded and do not receive the `xn--` prefix. The domain `example.com` remains unchanged rather than becoming `xn--example-xxxx.com`.

**Application Responsibilities:**

Applications displaying URIs must decode Punycode to present Unicode forms to users. Applications constructing DNS queries must encode Unicode labels to Punycode. Web browsers typically display decoded IDNs in the address bar while sending encoded forms in HTTP Host headers.

**Example Transformations:**

- `日本.jp` → `xn--wgv71a.jp`
- `الإمارات.ae` → `xn--mgbaam7a8h.ae`
- `москва.рф` → `xn--80adxhks.xn--p1ai`
- `café.fr` → `xn--caf-dma.fr`

