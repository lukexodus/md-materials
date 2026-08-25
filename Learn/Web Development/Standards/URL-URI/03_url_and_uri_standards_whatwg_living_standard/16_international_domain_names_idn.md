## International Domain Names (IDN)


Internationalized Domain Names allow domain names to contain non-ASCII characters. IDN is handled through ASCII-compatible encoding (ACE) using the Punycode algorithm.

### Punycode Encoding

Punycode converts Unicode strings into ASCII strings that can be used in DNS. Encoded labels begin with "xn--" followed by the encoded representation.

**Example:**

```
Original: münchen.de
Punycode: xn--mnchen-3ya.de

Original: 中国.cn
Punycode: xn--fiqs8s.cn
```

### IDNA Standards

IDNA (Internationalized Domain Names in Applications) defines how applications should process international domain names. IDNA2008 is the current standard, though IDNA2003 is still widely used in practice.

The standards define which Unicode characters are valid in domain names, how to normalize domain names before encoding, and validation rules for preventing security issues.

### Security Considerations

IDN homograph attacks exploit visual similarity between characters from different scripts. Characters from different alphabets may look identical (e.g., Latin 'a' vs. Cyrillic 'а').

Browsers implement protections such as displaying Punycode for mixed-script domains, limiting certain character combinations, and maintaining lists of confusable characters.

