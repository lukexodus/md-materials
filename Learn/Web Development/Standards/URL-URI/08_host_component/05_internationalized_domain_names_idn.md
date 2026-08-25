## Internationalized Domain Names (IDN)


Internationalized Domain Names allow domain names to contain characters from non-ASCII scripts, enabling users to register and access domains in their native languages and writing systems. IDN support extends the Domain Name System beyond the original ASCII character limitation.

**Character Set Expansion:**

Traditional DNS hostnames are restricted to ASCII letters (a-z, A-Z), digits (0-9), and hyphens, with additional constraints on placement. IDNs permit characters from Unicode, including Latin characters with diacriticals (é, ñ, ü), Cyrillic script (кириллица), Arabic script (العربية), Chinese characters (中文), Japanese scripts (日本語), and numerous other writing systems.

**Protocol Compatibility:**

The DNS infrastructure operates on ASCII-based protocols that cannot directly process non-ASCII characters. IDNs employ an encoding mechanism to represent Unicode characters as ASCII-compatible strings, allowing seamless integration with existing DNS infrastructure without protocol modifications.

**Label Processing:**

Domain names consist of labels separated by dots. Each label in an IDN is processed independently. A domain like `例え.jp` contains two labels: `例え` (Unicode) and `jp` (ASCII). The Unicode label requires encoding while the ASCII label remains unchanged.

**Unicode Normalization:**

[Inference] Before encoding, IDN labels undergo Unicode normalization to ensure consistent representation. Different Unicode sequences can represent visually identical characters, and normalization resolves these variations to canonical forms.

**IDNA Standard:**

The Internationalized Domain Names in Applications (IDNA) specification defines the conversion between Unicode domain names and ASCII-compatible representations. The current standard is IDNA2008, which supersedes the earlier IDNA2003 specification. These standards define character validation, normalization procedures, and encoding requirements.

**Display vs. Protocol Forms:**

IDNs exist in two forms: the Unicode form displayed to users and the ASCII-encoded form used in DNS protocols. Applications must convert between these forms appropriately. Browsers display `münchen.de` to users but query DNS for the encoded equivalent.

**Security Considerations:**

IDNs introduce homograph attack risks where visually similar characters from different scripts create deceptive domain names. The Cyrillic 'а' (U+0430) appears identical to the Latin 'a' (U+0061) in many fonts. An attacker could register `pаypal.com` (with Cyrillic 'а') to mimic `paypal.com`. Browsers and registrars implement policies to mitigate these risks, including script mixing restrictions and visual warnings.

**Registry Policies:**

Top-level domain registries establish rules governing which characters are permitted in registrations under their domains. Some TLDs restrict registrations to specific scripts or implement bundling policies where visually similar variants are assigned to the same registrant.

