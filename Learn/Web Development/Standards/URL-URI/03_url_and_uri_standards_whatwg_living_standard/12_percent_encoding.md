## Percent-Encoding


Percent-encoding (URL encoding) represents characters that have special meaning or are not allowed in URIs. It uses the percent sign (%) followed by two hexadecimal digits representing the character's byte value in UTF-8.

Reserved characters that have special meaning in URI syntax include: `:/?#[]@!$&'()*+,;=`

These characters must be percent-encoded when used literally in URI components. Unreserved characters (A-Z, a-z, 0-9, hyphen, period, underscore, tilde) should never be encoded.

**Example:**

```
Original: Hello World! How are you?
Encoded: Hello%20World%21%20How%20are%20you%3F
```

Modern standards prefer percent-encoding based on UTF-8 byte sequences rather than other character encodings.

