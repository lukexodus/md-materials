## Wireless Security Protocols (WEP, WPA, WPA2, WPA3)


Wired Equivalent Privacy (WEP) provided initial 802.11 security through RC4 stream cipher encryption with 40-bit or 104-bit keys. Static key sharing and weak initialization vector implementation created significant vulnerabilities. [Unverified] WEP can typically be compromised within minutes using readily available tools, though specific attack timeframes depend on traffic volume and implementation details.

Wi-Fi Protected Access (WPA) replaced WEP with Temporal Key Integrity Protocol (TKIP) addressing key management vulnerabilities. Pre-shared keys or 802.1X authentication provide access control. Message Integrity Check (MIC) prevents frame tampering through cryptographic authentication codes.

WPA2 implements Advanced Encryption Standard (AES) encryption through Counter Mode with Cipher Block Chaining Message Authentication Code Protocol (CCMP). 128-bit AES keys provide stronger encryption than WEP or WPA implementations. Enterprise mode uses 802.1X authentication with RADIUS servers for centralized credential management.

WPA3 enhances security through Simultaneous Authentication of Equals (SAE) replacing Pre-Shared Key (PSK) authentication vulnerabilities. Forward secrecy ensures past communications remain secure even if passwords are compromised. Enhanced Open provides encryption for open networks without authentication requirements.

**Key Points:**

- WEP vulnerabilities led to rapid replacement by stronger protocols
- WPA introduced dynamic key management addressing static key weaknesses
- WPA2 AES encryption provides current standard security implementation
- WPA3 addresses remaining authentication vulnerabilities with forward secrecy

