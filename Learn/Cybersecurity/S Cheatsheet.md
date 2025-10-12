# Syllabus

## 1. Fundamentals & Concepts

- Steganography vs Cryptography
- Data Hiding Principles
- Carrier Types (Images, Audio, Video, Text, Network, Files)
- LSB (Least Significant Bit) Theory
- Embedding vs Extraction
- Steganalysis Basics

## 2. Image Steganography

### 2.1 File Format Analysis

- PNG Structure & Metadata
- JPEG/JPG Structure & Metadata
- GIF Structure & Animation Frames
- BMP Format Analysis
- TIFF Format Analysis
- WebP & Modern Formats

### 2.2 Image Metadata Extraction

- EXIF Data Analysis
- IPTC Metadata
- XMP Data
- ICC Color Profiles
- Thumbnail Extraction
- GPS Coordinates

### 2.3 Visual Analysis Techniques

- Color Plane Separation (RGB, CMYK)
- Alpha Channel Analysis
- Histogram Analysis
- Contrast/Brightness Manipulation
- Color Inversion & Filters
- Image Layer Extraction

### 2.4 LSB Techniques

- LSB Extraction (Per Channel)
- MSB Analysis
- Bit Plane Slicing
- Bit Order Manipulation
- Multi-bit LSB Schemes

### 2.5 Advanced Image Analysis

- Stereogram Decoding
- QR Code Detection
- Barcode Reading
- Augmented Reality Markers
- Steganographic Algorithms Detection
- Image Diffing

## 3. Audio Steganography

### 3.1 Audio File Formats

- WAV Analysis
- MP3 Structure
- FLAC Format
- OGG Vorbis
- M4A/AAC Analysis

### 3.2 Audio Analysis Techniques

- Spectral Analysis
- Spectrogram Visualization
- Waveform Analysis
- Frequency Domain Analysis
- DTMF Tone Decoding
- Morse Code Detection

### 3.3 Audio Metadata

- ID3 Tags (v1, v2)
- Vorbis Comments
- APE Tags
- Embedded Cover Art

## 4. File & Archive Steganography

### 4.1 Archive Manipulation

- ZIP Structure & Hidden Files
- RAR Analysis
- TAR/GZ Extraction
- 7Z Format Analysis
- Nested Archives
- Password-Protected Archives

### 4.2 Filesystem Techniques

- Slack Space Analysis
- EOF (End of File) Data
- File Carving
- Magic Number Analysis
- Alternate Data Streams (ADS)
- Polyglot Files

### 4.3 Document Steganography

- PDF Hidden Layers
- Microsoft Office XML Analysis
- OpenDocument Format
- Embedded Objects
- Font-Based Hiding
- Whitespace Steganography

## 5. Network & Protocol Steganography

- PCAP File Analysis
- TCP/IP Header Analysis
- DNS Tunneling Detection
- HTTP Header Analysis
- ICMP Covert Channels
- Protocol Timing Analysis

## 6. Text-Based Steganography

- Unicode Steganography
- Zero-Width Characters
- Whitespace Encoding
- Case-Based Encoding
- Homoglyph Detection
- Markdown/HTML Hidden Content

## 7. Video Steganography

- Video Frame Extraction
- Container Format Analysis (MP4, AVI, MKV)
- Frame-by-Frame Analysis
- Subtitle Track Extraction
- Video Metadata Analysis

## 8. Cryptographic Integration

- Password-Protected Steganography
- Encrypted Payloads
- Key Derivation in Stego
- Cipher Detection
- Hash Verification

## 9. Steganalysis Tools (Kali Linux)

### 9.1 General Purpose Tools

- binwalk
- foremost
- steghide
- stegseek
- outguess
- stegsnow
- exiftool
- strings
- xxd/hexdump
- file

### 9.2 Image-Specific Tools

- zsteg
- stegsolve
- pngcheck
- jsteg
- stegdetect
- stegoVeritas
- ImageMagick
- GIMP

### 9.3 Audio Tools

- audacity
- sonic-visualiser
- sox
- ffmpeg
- mediainfo
- wavsteg

### 9.4 Analysis & Forensics

- volatility (memory)
- autopsy
- sleuthkit
- scalpel
- photorec
- testdisk

### 9.5 Scripting & Custom Tools

- Python PIL/Pillow
- Python wave/scipy
- Python struct
- Python binascii
- Bash scripting
- CyberChef

## 10. CTF-Specific Techniques

### 10.1 Common CTF Patterns

- Base64 in Images
- ROT Ciphers
- XOR Operations
- Reversed/Flipped Content
- Concatenated Flags
- Multi-Stage Challenges

### 10.2 Reconnaissance

- File Signature Verification
- String Pattern Matching
- Entropy Analysis
- Size Anomaly Detection
- Timestamp Analysis

### 10.3 Automated Workflows

- Tool Chaining
- Script Automation
- Flag Format Recognition
- Batch Processing
- Result Validation

## 11. Advanced Topics

- Machine Learning for Steganalysis
- Blockchain Steganography
- Biological Sequence Steganography
- 3D Model Steganography
- Executable File Steganography
- Cloud Storage Metadata

## 12. Practical Methodology

- Initial File Assessment
- Tool Selection Strategy
- Systematic Enumeration
- Documentation & Note-Taking
- Time Management
- Team Collaboration

---

# Fundamentals & Concepts

### Steganography vs Cryptography

Steganography and cryptography serve different security objectives and are often confused in CTF contexts.

**Cryptography** transforms data into an unreadable format through mathematical algorithms. The existence of the secret message is visible—ciphertext is obviously encrypted—but the content is protected. Anyone can see encrypted data exists; decryption requires the correct key.

**Steganography** hides the existence of the message itself within a carrier medium. The goal is covert communication where observers don't suspect hidden data exists. If executed properly, the carrier appears completely normal.

**Key Differences:**

- **Visibility**: Cryptography makes data unreadable but visible; steganography makes data invisible
- **Detection**: Encrypted data is obvious; steganographic data should be undetectable without specific analysis
- **Failure Mode**: Breaking crypto exposes plaintext; detecting stego exposes the communication channel
- **CTF Context**: Crypto challenges announce "this is encrypted"; stego challenges often provide seemingly normal files

**Combined Usage**: Modern steganography frequently combines both—encrypted data is embedded in carriers, providing secrecy (encryption) and obscurity (hiding). CTF challenges commonly layer these techniques.

### Data Hiding Principles

Data hiding in steganography relies on exploiting redundancy, noise tolerance, and format complexity in digital media.

**Redundancy Exploitation**: Digital files contain more data than humans perceive. Images have color depth beyond human vision; audio has frequencies we don't hear. Hidden data occupies these imperceptible spaces.

**Perceptual Transparency**: Modifications must not alert human senses. Changes to least significant bits in images or high-frequency audio components remain undetectable to casual observation.

**Statistical Transparency**: [Inference] Advanced steganalysis uses statistical analysis to detect anomalies. Effective steganography maintains statistical properties of the original carrier—histogram distributions, bit plane patterns, and frequency characteristics should appear natural.

**Capacity vs Detectability Trade-off**: More embedded data increases detection risk. CTF challenges balance meaningful payload size against maintaining carrier authenticity.

**Format Compliance**: Hidden data must not corrupt the carrier file format. Headers, checksums, and structural elements must remain valid for the file to open normally.

### Carrier Types

Different media types offer distinct hiding capacities, detection resistances, and extraction techniques.

#### Images

**Characteristics:**

- Most common CTF carrier type
- High capacity due to pixel redundancy
- Multiple color channels (RGB, RGBA) provide hiding spaces
- Various formats (PNG, JPEG, BMP, GIF) with different properties

**Hiding Locations:**

- Pixel values (LSB of color channels)
- Metadata (EXIF, IPTC, XMP)
- Color palette entries
- Alpha channel transparency values
- Image headers and unused chunks (PNG ancillary chunks)

**Format-Specific Notes:**

- **PNG**: Lossless, supports ancillary chunks for metadata, best for LSB
- **JPEG**: Lossy compression complicates LSB; DCT coefficients used instead
- **BMP**: No compression, straightforward LSB, large file sizes
- **GIF**: Limited palette, good for palette-based hiding

#### Audio

**Characteristics:**

- Less commonly used in beginner CTFs
- Human hearing limitations provide hiding opportunities
- Time-domain and frequency-domain techniques

**Hiding Locations:**

- LSB of audio samples
- Echo hiding in time delays
- Phase encoding in frequency components
- Spread spectrum techniques
- Metadata tags (ID3, FLAC headers)

**Common Formats:**

- **WAV**: Uncompressed, excellent for LSB
- **MP3**: Lossy, uses specific encoding artifacts
- **FLAC**: Lossless compressed, preserves LSB

#### Video

**Characteristics:**

- High capacity due to frame sequences
- Combines image and audio techniques
- Complex format structures offer multiple hiding vectors

**Hiding Locations:**

- Frame pixel data (per-frame LSB)
- Motion vectors in compressed video
- Metadata containers
- Audio track embedded data
- Subtitle/caption tracks

#### Text

**Characteristics:**

- Low capacity but easily distributable
- Format-based and linguistic techniques

**Hiding Locations:**

- Whitespace patterns (spaces, tabs, line breaks)
- Zero-width Unicode characters (U+200B, U+200C, U+200D, U+FEFF)
- Letter case variations
- Homoglyphs (visually similar characters)
- Markup language comments

#### Network

**Characteristics:**

- Covert channels in network protocols
- Less common in file-based CTFs, more in network forensics

**Hiding Locations:**

- TCP/IP header fields (IP ID, TTL, reserved bits)
- Protocol timing variations
- Packet ordering sequences
- DNS query patterns
- ICMP echo payload

#### Files

**Characteristics:**

- Container-based hiding in file structures
- Format polyglots and file concatenation

**Hiding Locations:**

- Appended data after file end markers
- Archive comment fields (ZIP, RAR)
- Filesystem slack space
- File format-specific reserved areas
- Polyglot files (valid as multiple formats)

### LSB (Least Significant Bit) Theory

LSB steganography is the most fundamental and frequently encountered technique in CTF challenges.

**Bit Significance Hierarchy**: In an 8-bit byte (value 0-255), each bit position contributes differently to the total value:

- Bit 7 (MSB): contributes 128
- Bit 6: contributes 64
- Bit 5: contributes 32
- Bit 4: contributes 16
- Bit 3: contributes 8
- Bit 2: contributes 4
- Bit 1: contributes 2
- Bit 0 (LSB): contributes 1

**Perceptual Impact**: Changing the LSB alters the value by only ±1. In a 24-bit RGB image:

- Red=200 becomes 201 (0xC8 to 0xC9)—visually imperceptible
- Changing MSB: Red=200 becomes 72 (0xC8 to 0x48)—dramatically visible

**Example Encoding**:

```
Original pixel: R=11010110 (214), G=10101010 (170), B=11110000 (240)
Hidden bits: 101 (to embed across RGB)

Modified pixel: R=11010111 (215), G=10101010 (170), B=11110001 (241)
                      ↑ LSB changed    ↑ unchanged      ↑ LSB changed
```

**Capacity Calculation**: For a 1920×1080 RGB image:

- Total pixels: 2,073,600
- Total bits (RGB channels): 6,220,800 bits
- LSB capacity (1 bit per channel): 6,220,800 bits = 777,600 bytes = ~759 KB

**Multi-bit LSB**: Some implementations use 2-4 least significant bits per byte, increasing capacity but also detection risk. Each additional bit doubles capacity but makes changes more perceptible.

**Bit Plane Analysis**: In CTF forensics, examining individual bit planes reveals LSB patterns. The LSB plane of an image with hidden data often shows distinct patterns or readable text.

### Embedding vs Extraction

Understanding the bidirectional process is critical for both creating and solving stego challenges.

#### Embedding Process

**Sequential Steps:**

1. **Carrier Selection**: Choose appropriate media type and size for payload capacity
2. **Payload Preparation**: Convert secret message to binary; optionally compress/encrypt
3. **Location Mapping**: Determine specific carrier positions for data placement (sequential, random seed-based, or pattern-based)
4. **Bit Insertion**: Replace carrier bits with payload bits according to chosen algorithm
5. **Format Preservation**: Ensure carrier remains valid and visually/audibly unchanged
6. **Optional Obfuscation**: Add decoy data or maintain statistical properties

**CTF Embedding Examples:**

```bash
# Simple LSB embedding with steghide (password-protected)
steghide embed -cf cover.jpg -ef secret.txt -p password123

# LSB embedding with stegano (Python)
stegano-lsb hide -i cover.png -m "flag{hidden_message}" -o stego.png

# Manual LSB with Python
# (Conceptual - replaces LSB of red channel with message bits)
```

#### Extraction Process

**Sequential Steps:**

1. **Carrier Analysis**: Identify file type, dimensions, and potential hiding capacity
2. **Detection Attempt**: Run steganalysis to confirm hidden data presence
3. **Tool Selection**: Choose extraction tool matching suspected embedding method
4. **Parameter Variation**: Try different bit positions, channels, orderings
5. **Data Reconstruction**: Reassemble extracted bits into original format
6. **Verification**: Check for file signatures, readable text, or known flag formats

**CTF Extraction Strategy:**

1. Run automated tools first (`steghide extract`, `stegsolve`, `zsteg`)
2. Check metadata and file structure anomalies
3. Manually inspect LSB planes
4. Try known CTF tool defaults
5. Analyze for patterns (headers, repeated sequences)

**Common Pitfall**: Extraction requires knowing the exact embedding parameters—bit position, channel order, random seed, and encoding scheme. CTF challenges often provide subtle hints in challenge descriptions or filenames.

### Steganalysis Basics

Steganalysis is the science of detecting hidden data—the adversarial counterpart to steganography.

**Detection Approaches:**

#### Visual Analysis

Human inspection for anomalies:

- Unusual file sizes relative to content
- Unexpected color patterns or noise
- Metadata inconsistencies
- Image quality degradation

#### Statistical Analysis

[Inference] Mathematical techniques detect embedding artifacts:

- **Chi-square Attack**: Detects LSB embedding by analyzing bit pair frequencies
- **Histogram Analysis**: Embedding changes color distribution patterns
- **Sample Pair Analysis**: Examines relationships between adjacent pixel values
- **DCT Coefficient Analysis**: For JPEG-specific detection

#### Structural Analysis

Format-level examination:

- Appended data beyond EOF markers
- Chunk analysis in PNG (ancillary chunks)
- Comment field inspection in archives
- Header field anomalies

**CTF Steganalysis Workflow:**

1. **File Identification**:

```bash
file suspicious_image.png
exiftool suspicious_image.png
```

2. **Automated Detection**:

```bash
# Check for known stego signatures
stegdetect suspicious_image.jpg

# Comprehensive automated analysis
zsteg -a suspicious_image.png  # For PNG/BMP
```

3. **Visual Inspection Tools**:

- **Stegsolve**: Examine bit planes, color channels, XOR operations
- **GIMP/Photoshop**: Layer manipulation, histogram viewing
- **HxD/hexedit**: Raw byte inspection for appended data

4. **Statistical Testing**: [Unverified] Some advanced tools provide statistical confidence scores, but these may produce false positives on noisy or heavily compressed images.

**Limitations**: Perfect steganography is theoretically undetectable. CTF challenges typically use imperfect implementations with detectable artifacts or provide subtle hints that steganography is present.

---

**Important Related Topics for CTF Preparation:**

- **Image Format Specifications**: Understanding PNG chunks, JPEG structure, BMP headers
- **Binary Data Manipulation**: Hexadecimal editing, bit operations, endianness
- **Python Scripting for Stego**: PIL/Pillow library, struct module, bitwise operations
- **Common CTF Stego Tools**: Detailed exploration of steghide, zsteg, stegsolve, stegseek

---

# Image Steganography

## File Format Analysis

### PNG Structure & Metadata

#### Understanding PNG Architecture

PNG (Portable Network Graphics) files follow a strict binary structure consisting of an 8-byte signature followed by a series of chunks. The signature is always `89 50 4E 47 0D 0A 1A 0A` in hexadecimal (in ASCII: `‰PNG\r\n\x1a\n`). Every chunk begins with a 4-byte length field (big-endian), followed by a 4-byte chunk type identifier, then the chunk data, and finally a 4-byte CRC-32 checksum.

Critical chunk types include IHDR (image header, must be first), PLTE (palette), IDAT (image data, can be multiple), and IEND (image trailer, must be last). Ancillary chunks like tEXt, zTXt, and iTXt store metadata without affecting image rendering. The chunk type identifier uses case sensitivity to determine criticality: uppercase first letter indicates critical chunks that must be understood by all decoders, while lowercase indicates ancillary chunks that can be safely ignored.

#### Extracting and Analyzing Metadata

Use `exiftool` to quickly identify all metadata present in a PNG file:

```bash
exiftool filename.png
```

For a more detailed hexdump analysis revealing chunk structure:

```bash
xxd filename.png | head -20
```

To extract the raw binary structure and parse chunks manually:

```bash
hexdump -C filename.png | head -50
```

The PNG specification defines specific ancillary chunks commonly used in CTF challenges. The tEXt chunk stores uncompressed text key-value pairs, while zTXt stores compressed text. The iTXt chunk supports international text with UTF-8 encoding. Extract these specifically:

```bash
strings filename.png | grep -E "^[A-Za-z0-9]+"
```

More surgical extraction using `pngcheck`:

```bash
pngcheck -v filename.png
```

This tool identifies chunk structure, validates CRC checksums, and reveals any anomalies. [Unverified] Some CTF challenges embed hidden data in malformed CRC values or unused chunk fields.

#### Advanced PNG Analysis Techniques

Examine the IHDR chunk explicitly (first 13 bytes after the PNG signature):

```bash
xxd -l 33 filename.png
```

The IHDR contains width (4 bytes), height (4 bytes), bit depth (1 byte), color type (1 byte), compression method (1 byte), filter method (1 byte), and interlace method (1 byte). Mismatches between declared dimensions and actual data can hide embedded content.

For automated metadata stripping and analysis:

```bash
convert filename.png -strip output.png
```

To examine individual IDAT chunks and their compression:

```bash
xxd filename.png | grep "IDAT" -A 5
```

Decompress PNG image data using `libpng` tools or Python:

```python
import zlib
with open('filename.png', 'rb') as f:
    f.read(8)  ## Skip signature
    ## Parse IHDR
    length = int.from_bytes(f.read(4), 'big')
    chunk_type = f.read(4)
    if chunk_type == b'IHDR':
        ihdr_data = f.read(length)
    ## Continue parsing IDAT chunks
```

#### CTF-Specific PNG Exploitation

PNG files can hide data through LSB (Least Significant Bit) steganography in pixel values. Use `stegsolve.jar` for visual analysis:

```bash
java -jar stegsolve.jar
```

Navigate through different color planes and bit planes to identify visual anomalies or hidden patterns.

For programmatic LSB extraction:

```python
from PIL import Image
import numpy as np

img = Image.open('filename.png')
pixels = np.array(img)
lsb = pixels & 1
lsb_image = Image.fromarray((lsb * 255).astype(np.uint8))
lsb_image.save('lsb_output.png')
```

Check for steganography tools signatures:

```bash
strings filename.png | grep -i "steghide\|openstego\|steg"
```

Analyze file size inconsistencies:

```bash
ls -lh filename.png
identify -verbose filename.png
```

If the file size is larger than expected for the image dimensions, investigate IDAT chunk padding and ancillary chunks.

### JPEG/JPG Structure & Metadata

#### JPEG File Format Fundamentals

JPEG files use a segment-based structure beginning with the Start Of Image (SOI) marker `FF D8`. Each segment starts with a marker (2 bytes: `FF` followed by a segment identifier), followed by a length field (2 bytes, big-endian) and segment data. The file concludes with the End Of Image (EOI) marker `FF D9`.

Key segments include APP0-APP15 (application-specific data), SOF (Start Of Frame, defines image parameters), DHT (Define Huffman Table), DQT (Define Quantization Table), SOS (Start Of Scan, begins compressed image data), and COM (comment). Critical markers for steganography include the APP1 segment, which typically contains EXIF data in a TIFF-compatible format.

The compressed image data between SOS and EOI is entropy-encoded and cannot be easily parsed without JPEG decoding. However, data can be hidden in the EXIF segments, quantization tables, Huffman tables, or exploited through metadata manipulation.

#### Extracting and Parsing JPEG Metadata

Use `exiftool` for comprehensive metadata extraction:

```bash
exiftool filename.jpg
exiftool -a filename.jpg  ## Show all metadata including duplicates
exiftool -G filename.jpg  ## Group metadata by category
```

To view raw JPEG structure:

```bash
xxd filename.jpg | head -30
```

Identify all segments present:

```bash
hexdump -C filename.jpg | grep "ff d"
```

Extract EXIF data as raw binary:

```bash
exiftool -b -Exif filename.jpg > exif.bin
```

Use `jpeginfo` for detailed segment analysis:

```bash
jpeginfo -c filename.jpg
```

This tool reports segment markers, sizes, and validates JPEG structure. For more granular analysis:

```bash
strings filename.jpg
```

#### Advanced JPEG Segment Manipulation

Extract and analyze JPEG APP segments specifically:

```bash
xxd filename.jpg | grep -i "ffe"
```

Each APP segment has a unique identifier (0-15). APP1 is standard for EXIF. Extract EXIF thumbnail data:

```bash
exiftool -b -ThumbnailImage filename.jpg > thumbnail.jpg
```

Analyze quantization tables and Huffman tables, which can be modified to embed data:

```bash
python3 << 'EOF'
import struct
with open('filename.jpg', 'rb') as f:
    data = f.read()
    ## Find DQT markers (FFD9)
    pos = 0
    while pos < len(data):
        if data[pos:pos+2] == b'\xff\xdb':
            print(f"DQT at offset {hex(pos)}")
            length = struct.unpack('>H', data[pos+2:pos+4])[0]
            print(f"Length: {length}")
        pos += 1
EOF
```

#### JPEG Steganography Detection and Exploitation

Identify jpeg comment sections:

```bash
exiftool -Comment filename.jpg
exiftool -b -Exif filename.jpg | strings
```

Check for hidden data in EXIF makernotes (often camera-manufacturer specific):

```bash
exiftool -MakerNotes filename.jpg
```

Use `steghide` to detect and extract data hidden in JPEG files:

```bash
steghide info filename.jpg
steghide extract -sf filename.jpg -xf output.txt  ## Will prompt for passphrase if encrypted
steghide extract -sf filename.jpg -xf output.txt -p ""  ## Try empty passphrase
```

[Inference] Steghide can embed files in JPEG using LSB manipulation in DCT coefficients, though this is difficult to verify without source analysis.

Analyze JPEG using `jsteg`:

```bash
jsteg reveal filename.jpg
```

Extract data from specific JPEG segments for analysis:

```bash
python3 << 'EOF'
import struct
def extract_app_segment(filename, segment_id):
    with open(filename, 'rb') as f:
        data = f.read()
    marker = bytes([0xff, 0xe0 + segment_id])
    pos = 0
    segments = []
    while pos < len(data):
        if data[pos:pos+2] == marker:
            length = struct.unpack('>H', data[pos+2:pos+4])[0]
            segment_data = data[pos+4:pos+4+length-2]
            segments.append(segment_data)
            pos += length + 2
        else:
            pos += 1
    return segments
app1_data = extract_app_segment('filename.jpg', 1)
for segment in app1_data:
    print(segment[:32])
EOF
```

Detect anomalies in JPEG entropy-coded data:

```bash
jpegoptim --strip-all -v filename.jpg
identify -verbose filename.jpg | grep -i "entropy\|huffman"
```

### GIF Structure & Animation Frames

#### GIF File Format Architecture

GIF (Graphics Interchange Format) files begin with the signature `47 49 46` (ASCII "GIF") followed by a version identifier (either "87a" or "89a"). This 6-byte header is followed by the Logical Screen Descriptor (7 bytes defining canvas dimensions and color information), optional Global Color Table, and then a sequence of blocks and extensions.

The file structure includes the Image Separator (`21` in GIF 89a, `2C` or `3B` or `F9` in context-dependent parsing), Extension Introducers (for animations, comments, and text), and Trailer (`3B`). Multiple Image blocks create animation frames. Text extensions (block type `01`) and Plain Text extensions (block type `01`) can embed hidden data directly in the file structure.

#### Extracting and Analyzing GIF Structure

Examine raw GIF structure:

```bash
xxd filename.gif | head -30
hexdump -C filename.gif
```

Identify GIF version and dimensions:

```bash
python3 << 'EOF'
with open('filename.gif', 'rb') as f:
    header = f.read(6)
    print(f"Header: {header}")
    lsd = f.read(7)
    width = int.from_bytes(lsd[0:2], 'little')
    height = int.from_bytes(lsd[2:4], 'little')
    print(f"Dimensions: {width}x{height}")
EOF
```

Extract all frames from an animated GIF:

```bash
convert filename.gif frame_%03d.png
ffmpeg -i filename.gif frame_%03d.png
```

Use `gifsicle` to analyze GIF structure in detail:

```bash
gifsicle --info filename.gif
gifsicle -e filename.gif  ## Extract all frames
```

#### Frame Analysis and Data Extraction

Extract specific frames:

```bash
gifsicle filename.gif '#0' > frame0.gif
gifsicle filename.gif '#0' '#1' > frames01.gif
```

Examine frame timing and disposal methods:

```bash
gifsicle --info --verbose filename.gif
```

Analyze frame metadata and extension blocks:

```bash
python3 << 'EOF'
with open('filename.gif', 'rb') as f:
    data = f.read()
    ## Skip header and LSD
    pos = 13
    frame_count = 0
    while pos < len(data):
        if data[pos] == 0x21:  ## Extension
            label = data[pos+1]
            if label == 0xF9:  ## Graphics Control Extension
                print(f"Graphics Control Extension at {hex(pos)}")
                block_size = data[pos+2]
                disposal = (data[pos+3] >> 2) & 0x07
                print(f"Disposal method: {disposal}")
            elif label == 0xFE:  ## Comment
                print(f"Comment at {hex(pos)}")
                block_size = data[pos+2]
                comment = data[pos+3:pos+3+block_size]
                print(f"Comment: {comment}")
        elif data[pos] == 0x2C:  ## Image
            frame_count += 1
            print(f"Image block at {hex(pos)} (Frame {frame_count})")
        elif data[pos] == 0x3B:  ## Trailer
            print(f"Trailer at {hex(pos)}")
            break
        pos += 1
EOF
```

#### GIF Steganography Techniques

Extract comments and text extensions from GIF:

```bash
strings filename.gif
```

[Inference] GIF comments and text extension blocks can store arbitrary binary data without affecting image rendering.

Extract GIF comment sections specifically:

```bash
python3 << 'EOF'
with open('filename.gif', 'rb') as f:
    data = f.read()
    pos = 0
    while pos < len(data):
        if data[pos:pos+2] == b'\x21\xfe':  ## Comment block
            block_size = data[pos+2]
            comment_data = data[pos+3:pos+3+block_size]
            print(f"Found comment: {comment_data}")
            pos += 3 + block_size
            ## Skip sub-blocks
            while data[pos] != 0x00:
                block_size = data[pos]
                pos += 1 + block_size
            pos += 1
        else:
            pos += 1
EOF
```

Analyze GIF palette for LSB steganography:

```bash
convert filename.gif -identify -verbose | grep "Colormap"
python3 << 'EOF'
from PIL import Image
img = Image.open('filename.gif')
palette = img.palette.getdata()[1]
## Extract LSBs from palette values
lsbs = [byte & 1 for byte in palette]
print(''.join(str(bit) for bit in lsbs))
EOF
```

Detect and analyze frame differences for hidden data:

```bash
python3 << 'EOF'
from PIL import Image
import numpy as np

gif = Image.open('filename.gif')
frames = []
try:
    while True:
        frames.append(np.array(gif.convert('RGB')))
        gif.seek(gif.tell() + 1)
except EOFError:
    pass

## Compare frames for differences
if len(frames) > 1:
    diff = np.abs(frames[0].astype(int) - frames[1].astype(int))
    print(f"Pixel differences: {np.sum(diff)}")
    changed_pixels = np.sum(diff, axis=2) > 0
    print(f"Changed pixels: {np.sum(changed_pixels)}")
EOF
```

### BMP Format Analysis

#### BMP File Structure Fundamentals

BMP (Bitmap) files are uncompressed or lightly compressed raster image formats with a straightforward structure. The file begins with a 14-byte File Header containing the signature `42 4D` (ASCII "BM"), file size (4 bytes, little-endian), reserved bytes (4 bytes, unused), and offset to pixel data (4 bytes). The Information Header follows (at least 40 bytes in BITMAPINFOHEADER format), specifying image width, height, bit depth, compression type, and color space information.

BMPs can use various bit depths (1, 4, 8, 16, 24, 32-bit), with 8-bit and lower requiring a color palette. The palette section follows the Information Header and contains RGB entries. Pixel data begins at the offset specified in the File Header and is stored bottom-to-top (inverted from typical image formats) unless specified otherwise.

#### Parsing and Analyzing BMP Headers

Extract BMP header information:

```bash
xxd -l 54 filename.bmp
```

Parse BMP structure programmatically:

```python
import struct

with open('filename.bmp', 'rb') as f:
    ## File Header (14 bytes)
    signature = f.read(2)
    file_size = struct.unpack('<I', f.read(4))[0]
    reserved = struct.unpack('<I', f.read(4))[0]
    pixel_offset = struct.unpack('<I', f.read(4))[0]
    
    print(f"Signature: {signature}")
    print(f"File size: {file_size}")
    print(f"Pixel data offset: {pixel_offset}")
    
    ## Information Header (at least 40 bytes)
    info_header_size = struct.unpack('<I', f.read(4))[0]
    width = struct.unpack('<i', f.read(4))[0]
    height = struct.unpack('<i', f.read(4))[0]
    planes = struct.unpack('<H', f.read(2))[0]
    bit_depth = struct.unpack('<H', f.read(2))[0]
    compression = struct.unpack('<I', f.read(4))[0]
    
    print(f"Dimensions: {width}x{height}")
    print(f"Bit depth: {bit_depth}")
    print(f"Compression: {compression} (0=none, 1=RLE8, 2=RLE4)")
```

Identify BMP anomalies:

```bash
identify -verbose filename.bmp
file filename.bmp
```

#### BMP Steganography and Data Hiding

BMPs are ideal for LSB steganography due to their uncompressed nature. Extract LSB planes:

```python
from PIL import Image
import numpy as np

img = Image.open('filename.bmp')
pixels = np.array(img)

if len(pixels.shape) == 3:  ## Color image
    lsb_image = Image.new('RGB', (pixels.shape[1], pixels.shape[0]))
    for bit in range(8):
        bit_plane = (pixels >> bit) & 1
        output = np.zeros_like(pixels)
        output[bit_plane == 1] = 255
        Image.fromarray(output).save(f'lsb_plane_{bit}.bmp')
else:  ## Grayscale
    for bit in range(8):
        bit_plane = (pixels >> bit) & 1
        Image.fromarray((bit_plane * 255).astype(np.uint8)).save(f'lsb_plane_{bit}.bmp')
```

Analyze BMP padding (BMPs pad each scanline to 4-byte boundaries):

```python
with open('filename.bmp', 'rb') as f:
    ## Parse header to get dimensions and bit depth
    f.seek(18)
    width = struct.unpack('<I', f.read(4))[0]
    height = struct.unpack('<I', f.read(4))[0]
    bit_depth = struct.unpack('<H', f.read(4))[0]
    
    bytes_per_pixel = bit_depth // 8
    bytes_per_scanline = (width * bit_depth + 31) // 32 * 4
    padding_bytes = bytes_per_scanline - (width * bytes_per_pixel)
    
    print(f"Padding per scanline: {padding_bytes} bytes")
```

Extract hidden data from BMP padding:

```python
with open('filename.bmp', 'rb') as f:
    ## Skip to pixel data
    f.seek(pixel_offset)
    
    hidden_data = []
    for _ in range(height):
        f.read(width * bytes_per_pixel)  ## Read actual pixel data
        padding = f.read(padding_bytes)  ## Read padding
        hidden_data.extend(padding)
    
    print(f"Hidden data: {bytes(hidden_data).hex()}")
    print(f"Hidden data (ASCII): {bytes(hidden_data)}")
```

Detect steghide usage in BMPs:

```bash
steghide info filename.bmp
steghide extract -sf filename.bmp -xf output.txt
```

Check for size inconsistencies between declared and actual file size:

```bash
python3 << 'EOF'
import struct
with open('filename.bmp', 'rb') as f:
    declared_size = struct.unpack('<I', f.read(4)[2:])[0]
    f.seek(0, 2)
    actual_size = f.tell()
    
    if declared_size != actual_size:
        print(f"Size mismatch: declared={declared_size}, actual={actual_size}")
        print(f"Extra data: {actual_size - declared_size} bytes")
EOF
```

### TIFF Format Analysis

#### TIFF File Structure and Header Parsing

TIFF (Tagged Image File Format) is a highly flexible format using a tag-based structure. TIFF files begin with an 8-byte header: 4 bytes for byte order indication (little-endian `49 49` or big-endian `4D 4D`), 2 bytes with value `42` (magic number), and 4 bytes specifying the offset to the first Image File Directory (IFD).

IFDs contain tags that describe image properties. Each IFD begins with a 2-byte count of directory entries, followed by 12-byte tag entries (each specifying tag number, type, count, and value/offset), and concluding with a 4-byte offset to the next IFD (0 if no additional IFD). TIFF supports multiple images and layers within a single file, making it complex to analyze completely.

#### Parsing TIFF Headers and IFDs

Extract TIFF header information:

```bash
xxd -l 8 filename.tiff
```

Parse TIFF structure programmatically:

```python
import struct

def parse_tiff(filename):
    with open(filename, 'rb') as f:
        ## Parse header
        byte_order = f.read(2)
        if byte_order == b'II':
            endian = '<'
            print("Little-endian TIFF")
        elif byte_order == b'MM':
            endian = '>'
            print("Big-endian TIFF")
        else:
            print("Invalid TIFF file")
            return
        
        magic = struct.unpack(endian + 'H', f.read(2))[0]
        if magic != 42:
            print(f"Invalid magic number: {magic}")
            return
        
        first_ifd_offset = struct.unpack(endian + 'I', f.read(4))[0]
        print(f"First IFD at offset: {hex(first_ifd_offset)}")
        
        ## Parse IFDs
        ifd_offset = first_ifd_offset
        ifd_count = 0
        while ifd_offset != 0:
            ifd_count += 1
            f.seek(ifd_offset)
            tag_count = struct.unpack(endian + 'H', f.read(2))[0]
            print(f"\nIFD {ifd_count}: {tag_count} tags")
            
            for _ in range(tag_count):
                tag_num, tag_type, tag_count, tag_val = struct.unpack(
                    endian + 'HHII', f.read(12)
                )
                print(f"  Tag {tag_num}: Type={tag_type}, Count={tag_count}, Value={hex(tag_val)}")
            
            ifd_offset = struct.unpack(endian + 'I', f.read(4))[0]

parse_tiff('filename.tiff')
```

Use `libtiff` tools for comprehensive TIFF analysis:

```bash
tiffinfo filename.tiff
tiffinfo -v filename.tiff  ## Verbose output
```

#### TIFF Metadata Extraction

Extract EXIF data from TIFF (EXIF is stored in IFD tag 34665):

```bash
exiftool filename.tiff
exiftool -a filename.tiff  ## All metadata
```

Extract ICC color profile:

```bash
exiftool -b -icc_profile filename.tiff > profile.icc
```

Analyze TIFF tags for anomalies:

```python
def analyze_tiff_tags(filename):
    import struct
    with open(filename, 'rb') as f:
        byte_order = f.read(2)
        endian = '<' if byte_order == b'II' else '>'
        f.seek(4)
        first_ifd = struct.unpack(endian + 'I', f.read(4))[0]
        
        f.seek(first_ifd)
        tag_count = struct.unpack(endian + 'H', f.read(2))[0]
        
        ## Known TIFF tags
        tags = {
            256: "ImageWidth", 257: "ImageLength", 258: "BitsPerSample",
            259: "Compression", 262: "PhotometricInterpretation",
            273: "StripOffsets", 277: "SamplesPerPixel", 278: "RowsPerStrip",
            279: "StripByteCounts", 282: "XResolution", 283: "YResolution",
            305: "Software", 306: "DateTime", 315: "Artist", 316: "HostComputer",
            34665: "ExifIFD", 34867: "InteroperabilityIFD"
        }
        
        for _ in range(tag_count):
            tag_num, tag_type, tag_count, tag_val = struct.unpack(
                endian + 'HHII', f.read(12)
            )
            tag_name = tags.get(tag_num, f"Unknown({tag_num})")
            print(f"{tag_name}: Type={tag_type}, Count={tag_count}, Value={tag_val}")

analyze_tiff_tags('filename.tiff')
```

#### TIFF Steganography and Hidden Data Detection

Extract TIFF image data and analyze LSBs:

```python
from PIL import Image
import numpy as np

img = Image.open('filename.tiff')
pixels = np.array(img)

## Extract each bit plane
for bit in range(min(8, pixels.dtype.itemsize * 8)):
    bit_plane = (pixels >> bit) & 1
    if len(pixels.shape) == 3:
        bit_image = Image.fromarray((bit_plane[:,:,0] * 255).astype(np.uint8))
    else:
        bit_image = Image.fromarray((bit_plane * 255).astype(np.uint8))
    bit_image.save(f'tiff_bitplane_{bit}.png')
```

Detect multiple images or strips in TIFF:

```python
img = Image.open('filename.tiff')
print(f"Number of frames: {img.n_frames if hasattr(img, 'n_frames') else 1}")

for i in range(getattr(img, 'n_frames', 1)):
    img.seek(i)
    print(f"Frame {i}: {img.size}, {img.mode}")
```

Check for hidden TIFF IFDs (multiple images):

```bash
strings filename.tiff | head -20
tiffcp -c none filename.tiff output.tiff  ## Re-encode without compression
```

Analyze TIFF compression methods:

```bash
tiffinfo filename.tiff | grep -i compression
identify -verbose filename.tiff | grep -i compression
```

[Inference] Compressed TIFF data may hide information in compression artifacts or in uncompressed metadata tags.

### WebP & Modern Formats

#### WebP Structure and Anatomy

WebP is a modern image format developed by Google, using a container-based structure similar to AVI and MOV files. The file begins with the "RIFF" signature (4 bytes `52 49 46 46`), followed by a 4-byte file size field (little-endian), and the format identifier "WEBP" (4 bytes). The RIFF structure is divided into chunks, each with a 4-byte FourCC identifier, 4-byte size, and chunk data (padded to even byte boundaries).

Key chunks include VP8 (lossy image data), VP8L (lossless image data), VP8X (extended features and metadata), ANIM (animation control), ANMF (animation frame), EXIF (EXIF metadata), and ICCP (ICC color profile). The VP8X chunk is mandatory for animated or extended WebP files and indicates which optional features are present.

#### Parsing WebP Structure

Extract WebP header and chunk information:

```bash
xxd -l 32 filename.webp
```

Parse WebP chunks programmatically:

```python
import struct

def parse_webp(filename):
    with open(filename, 'rb') as f:
        ## Parse RIFF header
        riff = f.read(4)
        if riff != b'RIFF':
            print("Not a RIFF file")
            return
        
        file_size = struct.unpack('<I', f.read(4))[0]
        webp = f.read(4)
        if webp != b'WEBP':
            print("Not a WebP file")
            return
        
        print(f"WebP file size: {file_size + 8} bytes")
        
        ## Parse chunks
        while True:
            chunk_header = f.read(8)
            if len(chunk_header) < 8:
                break
            
            fourcc = chunk_header[:4].decode('ascii', errors='replace')
            chunk_size = struct.unpack('<I', chunk_header[4:8])[0]
            chunk_data = f.read(chunk_size)
            
            print(f"Chunk: {fourcc}, Size: {chunk_size}")
            
            if fourcc == 'VP8X':
                flags = chunk_data[0]
                print(f"  Flags: {bin(flags)}")
                print(f"  Animation: {bool(flags & 0x02)}")
                print(f"  EXIF: {bool(flags & 0x08)}")
            
            ## Chunks are padded to even boundaries
            if chunk_size % 2 == 1:
                f.read(1)

parse_webp('filename.webp')
```

Use `webpmux` for detailed WebP analysis:

```bash
webpmux -info filename.webp
webpmux -get frame 1 filename.webp frame_output.webp  ## Extract frame
```

#### Extracting and Analyzing WebP Metadata

Extract EXIF data from WebP:

```bash
webpmux -get exif filename.webp exif.bin
exiftool filename.webp
```

Extract ICC color profile:

```bash
webpmux -get iccp filename.webp profile.icc
```

Decode WebP to raw format for analysis:

```bash
dwebp filename.webp -o output.ppm
```

Parse ANIM and ANMF chunks for animated WebP:

```python
import struct

def parse_animated_webp(filename):
    with open(filename, 'rb') as f:
        f.seek(12)  # Skip RIFF header (RIFF + size + WEBP)

        frame_index = 0

        while True:
            chunk_header = f.read(8)
            if len(chunk_header) < 8:
                break  # End of file

            fourcc = chunk_header[:4]
            chunk_size = struct.unpack('<I', chunk_header[4:8])[0]
            chunk_data = f.read(chunk_size)

            # Each chunk is padded to even size
            if chunk_size % 2 == 1:
                f.seek(1, 1)

            if fourcc == b'ANIM':
                # ANIM chunk: background color and loop count
                bgcolor = struct.unpack('<I', chunk_data[0:4])[0]
                loop_count = struct.unpack('<H', chunk_data[4:6])[0]
                print("=== ANIM Chunk ===")
                print(f"Background color: {hex(bgcolor)}")
                print(f"Loop count: {loop_count}\n")

            elif fourcc == b'ANMF':
                # ANMF chunk: frame info (position, size, duration, flags)
                frame_x = struct.unpack('<I', chunk_data[0:4])[0] & 0xFFFFFF
                frame_y = struct.unpack('<I', chunk_data[3:7])[0] >> 8 & 0xFFFFFF
                frame_width = struct.unpack('<H', chunk_data[6:8])[0] + 1
                frame_height = struct.unpack('<H', chunk_data[8:10])[0] + 1
                duration = struct.unpack('<I', chunk_data[10:14])[0] & 0xFFFFFF
                flags = chunk_data[13]

                # Interpret flags (bit 0 = dispose, bit 1 = blend)
                dispose_to_bg = bool(flags & 1)
                blend_with_prev = bool(flags & 2)

                frame_index += 1
                print(f"=== Frame {frame_index} (ANMF) ===")
                print(f"Frame position: ({frame_x}, {frame_y})")
                print(f"Frame size: {frame_width}x{frame_height}")
                print(f"Duration: {duration} ms")
                print(f"Dispose to background: {dispose_to_bg}")
                print(f"Blend with previous: {blend_with_prev}\n")

            else:
                # Skip non-animated chunks (VP8, VP8L, VP8X, etc.)
                f.seek(chunk_size, 1)

if __name__ == "__main__":
    parse_animated_webp("example.webp")
```

#### WebP Steganography and Hidden Data Detection

Extract and analyze VP8L (lossless) bitstream for anomalies:

```python
import struct

def analyze_vp8l_chunk(filename):
    with open(filename, 'rb') as f:
        f.seek(12)  ## Skip RIFF header
        
        while True:
            chunk_header = f.read(8)
            if len(chunk_header) < 8:
                break
            
            fourcc = chunk_header[:4]
            chunk_size = struct.unpack('<I', chunk_header[4:8])[0]
            chunk_data = f.read(chunk_size)
            
            if fourcc == b'VP8L':
                ## VP8L begins with 5-byte signature
                sig = chunk_data[0]
                width = struct.unpack('<H', chunk_data[1:3])[0] + 1
                height = (struct.unpack('<H', chunk_data[3:5])[0] >> 8) + 1
                has_alpha = (chunk_data[4] >> 4) & 1
                version = (chunk_data[4] >> 1) & 0x07
                
                print(f"VP8L dimensions: {width}x{height}")
                print(f"Has alpha: {has_alpha}")
                print(f"Version: {version}")
                print(f"Bitstream data size: {len(chunk_data) - 5} bytes")
            
            if chunk_size % 2 == 1:
                f.read(1)

analyze_vp8l_chunk('filename.webp')
```

Detect LSB steganography in WebP:

```python
from PIL import Image
import numpy as np

img = Image.open('filename.webp')
pixels = np.array(img)

## Extract LSB planes for each channel
if len(pixels.shape) == 3:
    for channel in range(pixels.shape[2]):
        lsb = pixels[:,:,channel] & 1
        lsb_image = Image.fromarray((lsb * 255).astype(np.uint8))
        lsb_image.save(f'webp_lsb_channel_{channel}.png')
else:
    lsb = pixels & 1
    Image.fromarray((lsb * 255).astype(np.uint8)).save('webp_lsb.png')
```

Check for steghide usage with WebP:

```bash
steghide info filename.webp
steghide extract -sf filename.webp -xf output.txt -p ""
```

Examine EXIF metadata for hidden data:

```bash
exiftool filename.webp
exiftool -b -Exif filename.webp | xxd
```

#### AVIF Format Analysis

AVIF (AV1 Image Format) is based on the ISO Base Media File Format (similar to MP4). It begins with the "ftyp" box signature followed by a 4-byte size field. Parse AVIF structure:

```python
import struct

def parse_avif(filename):
    with open(filename, 'rb') as f:
        while True:
            size_bytes = f.read(4)
            if len(size_bytes) < 4:
                break
            
            size = struct.unpack('>I', size_bytes)[0]
            box_type = f.read(4).decode('ascii', errors='replace')
            
            print(f"Box: {box_type}, Size: {size}")
            
            if box_type == 'ftyp':
                major_brand = f.read(4)
                minor_version = struct.unpack('>I', f.read(4))[0]
                print(f"  Major brand: {major_brand}")
                print(f"  Minor version: {minor_version}")
            elif box_type == 'meta':
                f.seek(f.tell() + 4)  ## Skip version and flags
            else:
                f.seek(f.tell() + size - 8)

parse_avif('filename.avif')
```

Extract AVIF using `libavif` tools:

```bash
avifdec filename.avif output.png
```

Analyze AVIF metadata:

```bash
exiftool filename.avif
ffprobe filename.avif
```

#### Modern Format Steganography Comparison

[Inference] Modern lossy formats (WebP VP8, AVIF AV1) present challenges for steganography compared to lossless formats due to compression artifacts and coefficient quantization. LSB-based steganography is theoretically possible but susceptible to re-compression.

Perform comparative analysis across formats:

```python
import os
from PIL import Image

formats = ['filename.jpg', 'filename.png', 'filename.webp', 'filename.avif']
for fmt in formats:
    if os.path.exists(fmt):
        img = Image.open(fmt)
        size = os.path.getsize(fmt)
        print(f"{fmt}: {img.size}, Mode: {img.mode}, File size: {size}")
```

Create test images to compare compression and steganography resilience:

```bash
## Create identical test image in multiple formats
convert original.png -depth 8 test.jpg
convert original.png test.png
cwebp original.png -o test.webp
```

#### Automated Format Detection and Analysis Workflow

Create a comprehensive file format analysis script:

```python
#!/usr/bin/env python3
import os
import struct
import subprocess
from PIL import Image

def analyze_file(filepath):
    if not os.path.exists(filepath):
        print(f"File not found: {filepath}")
        return
    
    with open(filepath, 'rb') as f:
        signature = f.read(8)
    
    ## Detect format
    if signature[:2] == b'\x89P':  ## PNG
        print(f"Format: PNG")
        analyze_png(filepath)
    elif signature[:2] == b'\xff\xd8':  ## JPEG
        print(f"Format: JPEG")
        analyze_jpeg(filepath)
    elif signature[:3] == b'GIF':  ## GIF
        print(f"Format: GIF")
        analyze_gif(filepath)
    elif signature[:2] == b'BM':  ## BMP
        print(f"Format: BMP")
        analyze_bmp(filepath)
    elif signature[:2] in [b'II', b'MM']:  ## TIFF
        print(f"Format: TIFF")
        analyze_tiff(filepath)
    elif signature[:4] == b'RIFF' and signature[8:12] == b'WEBP':  ## WebP
        print(f"Format: WebP")
        analyze_webp(filepath)
    else:
        print(f"Unknown format: {signature[:8].hex()}")
    
    ## General analysis
    print(f"\nFile size: {os.path.getsize(filepath)} bytes")
    
    try:
        ## Try PIL analysis
        img = Image.open(filepath)
        print(f"Dimensions: {img.size}")
        print(f"Mode: {img.mode}")
        print(f"Format: {img.format}")
    except:
        pass
    
    ## Extract metadata
    try:
        result = subprocess.run(['exiftool', filepath], 
                              capture_output=True, text=True, timeout=5)
        if result.stdout:
            print("\nMetadata:")
            for line in result.stdout.split('\n')[:10]:
                if line.strip():
                    print(f"  {line}")
    except:
        pass

def analyze_png(filepath):
    subprocess.run(['pngcheck', '-v', filepath], timeout=5)

def analyze_jpeg(filepath):
    subprocess.run(['jpeginfo', '-c', filepath], timeout=5)

def analyze_gif(filepath):
    subprocess.run(['gifsicle', '--info', filepath], timeout=5)

def analyze_bmp(filepath):
    print("BMP format detected - use PIL for detailed analysis")

def analyze_tiff(filepath):
    subprocess.run(['tiffinfo', filepath], timeout=5)

def analyze_webp(filepath):
    subprocess.run(['webpmux', '-info', filepath], timeout=5)

if __name__ == '__main__':
    import sys
    if len(sys.argv) > 1:
        analyze_file(sys.argv[1])
    else:
        print("Usage: analyze_file.py <filepath>")
```

#### Cross-Format Steganography Detection Strategy

Develop a systematic approach for CTF scenarios:

1. **Initial File Identification**: Use `file` command and magic byte analysis to confirm format
2. **Metadata Extraction**: Run `exiftool` on all formats to capture embedded metadata
3. **Format-Specific Analysis**: Apply format-appropriate tools (pngcheck, jpeginfo, etc.)
4. **LSB Analysis**: Extract bit planes to visualize hidden patterns using `stegsolve.jar` or custom Python
5. **Compression Artifacts**: Compare original and re-compressed versions to identify manipulation
6. **Steganography Tool Detection**: Attempt `steghide`, `stegsolve`, and other known tools with common passphrases

Create a master analysis script:

```bash
#!/bin/bash
TARGET_FILE="$1"

echo "=== Basic Information ==="
file "$TARGET_FILE"
ls -lh "$TARGET_FILE"

echo -e "\n=== Metadata Analysis ==="
exiftool "$TARGET_FILE" 2>/dev/null || echo "exiftool not available"

echo -e "\n=== Strings ==="
strings "$TARGET_FILE" | head -20

echo -e "\n=== Hex Dump (first 512 bytes) ==="
xxd "$TARGET_FILE" | head -32

echo -e "\n=== Format-Specific Analysis ==="
case "$(file -b "$TARGET_FILE")" in
    *PNG*)
        echo "PNG format detected"
        pngcheck -v "$TARGET_FILE" 2>/dev/null
        ;;
    *JPEG*)
        echo "JPEG format detected"
        jpeginfo -c "$TARGET_FILE" 2>/dev/null
        ;;
    *GIF*)
        echo "GIF format detected"
        gifsicle --info "$TARGET_FILE" 2>/dev/null
        ;;
    *WebP*)
        echo "WebP format detected"
        webpmux -info "$TARGET_FILE" 2>/dev/null
        ;;
    *)
        echo "Format not specifically handled"
        ;;
esac

echo -e "\n=== Steganography Detection ==="
steghide info "$TARGET_FILE" 2>/dev/null || echo "steghide info unavailable"
```

Related topics for comprehensive steganography coverage: **Audio Format Analysis**, **Archive and Container Format Exploitation**, **Metadata Manipulation Techniques**, **Polyglot File Construction**.

---

## Image Metadata Extraction

### EXIF Data Analysis

EXIF (Exchangeable Image File Format) metadata contains extensive technical information embedded by cameras, smartphones, and image editing software. This data frequently contains hidden flags, timestamps, or encoded information in CTF challenges.

#### Primary Tools and Commands

**ExifTool**
```bash
# Basic EXIF extraction
exiftool image.jpg

# Extract all metadata including maker notes
exiftool -a -u -g1 image.jpg

# Output to text file for analysis
exiftool -a -u image.jpg > metadata.txt

# Extract specific tag
exiftool -Model -Make -DateTimeOriginal image.jpg

# Recursive directory scan
exiftool -r /path/to/images/

# Extract binary data from specific tags
exiftool -b -ThumbnailImage image.jpg > thumb.jpg

# Show tag names (useful for finding hidden custom tags)
exiftool -s image.jpg

# Hex dump of specific tag
exiftool -htmlDump image.jpg > dump.html
```

**Exiv2**
```bash
# Extract all metadata
exiv2 -pa image.jpg

# Extract only EXIF data
exiv2 -pe image.jpg

# Print metadata in machine-readable format
exiv2 -Pkyct image.jpg

# Extract thumbnail
exiv2 -et image.jpg

# Show image comment
exiv2 -Pc image.jpg
```

**ImageMagick's identify**
```bash
# Basic metadata
identify -verbose image.jpg

# Extract specific properties
identify -format "%[EXIF:*]" image.jpg

# Show all profiles
identify -format "%[profiles]" image.jpg
```

#### CTF-Specific EXIF Analysis Techniques

**Hidden Data in Comment Fields**
```bash
# Extract comment fields (common hiding spot)
exiftool -Comment -UserComment -ImageDescription image.jpg

# Check for non-printable characters
exiftool -b -Comment image.jpg | xxd
```

**Timestamp Analysis**
```bash
# Extract all timestamp fields
exiftool -time:all -a -G0:1 -s image.jpg

# Compare creation vs modification times (may indicate manipulation)
exiftool -CreateDate -ModifyDate -FileModifyDate image.jpg
```

**Maker Notes Investigation**
Maker notes contain proprietary camera manufacturer data and are frequently exploited in CTFs:
```bash
# Extract maker notes
exiftool -makernotes:all image.jpg

# Binary dump of maker notes
exiftool -b -MakerNotes image.jpg | xxd

# For specific manufacturers
exiftool -canon:all image.jpg
exiftool -nikon:all image.jpg
```

**Custom Tag Discovery**
```bash
# List all tags including unknown ones
exiftool -u -G1 image.jpg

# Search for specific hex patterns in metadata
exiftool -b -unknown image.jpg | strings

# Extract APP segments from JPEG
exiftool -fast2 -ee -U image.jpg
```

#### Advanced EXIF Manipulation Detection

**Check for inconsistencies:**
```bash
# Compare embedded thumbnail with actual image
exiftool -b -ThumbnailImage image.jpg > thumb.jpg
compare image.jpg thumb.jpg diff.png  # ImageMagick

# Verify EXIF integrity
exiflibrary --check image.jpg  # [Inference] - may require specific library
```

### IPTC Metadata

IPTC (International Press Telecommunications Council) metadata is primarily used in journalism and publishing. In CTFs, IPTC fields often contain encoded flags or hints.

#### IPTC Extraction Commands

```bash
# Extract all IPTC data
exiftool -IPTC:all image.jpg

# Extract specific IPTC fields
exiftool -Keywords -Caption-Abstract -By-line image.jpg

# Check for multiple IPTC records
exiftool -a -IPTC:all image.jpg

# Binary extraction of IPTC data
exiftool -b -IPTC image.jpg > iptc.bin
```

**iptc-utils (Debian/Ubuntu package: `libimage-iptc-perl`)**
```bash
# [Unverified - tool availability may vary]
iptc-dump image.jpg

# Extract to XML
iptc-xml image.jpg > iptc.xml
```

#### Common IPTC Fields Used in CTFs

- **Keywords**: Often contains comma-separated encoded data
- **Caption/Abstract**: May contain base64 or other encoded strings
- **By-line (Author)**: Sometimes contains hidden usernames/passwords
- **Special Instructions**: Frequently overlooked field for hiding data

```bash
# Focus on common hiding spots
exiftool -Keywords -SpecialInstructions -Caption-Abstract image.jpg

# Check for trailing data
exiftool -b -Keywords image.jpg | xxd | tail -20
```

### XMP Data

XMP (Extensible Metadata Platform) is XML-based metadata that can contain extensive structured information. CTF challenges exploit XMP's flexibility to hide data within custom namespaces or embedded resources.

#### XMP Extraction and Analysis

```bash
# Extract all XMP data
exiftool -XMP:all image.jpg

# Extract raw XMP packet
exiftool -b -XMP image.jpg > xmp.xml

# Pretty-print XMP structure
exiftool -X image.jpg | xmllint --format - > formatted_xmp.xml

# Search for custom namespaces
exiftool -XMP:all -G1 image.jpg | grep -v "XMP-"
```

**Analyzing XMP XML Directly**
```bash
# Extract XMP packet manually from JPEG
strings image.jpg | sed -n '/<x:xmpmeta/,/<\/x:xmpmeta>/p' > xmp.xml

# Parse XMP with xmllint
xmllint --xpath '//*[local-name()="Description"]/@*' xmp.xml

# Search for base64 in XMP
grep -a "base64" xmp.xml
```

#### XMP Steganography Techniques

**Embedded Resources in XMP:**
```bash
# Check for embedded files in XMP
exiftool -XMP-xmpGImg:image image.jpg

# Extract embedded thumbnails from XMP
exiftool -b -XMP-xmpGImg:image image.jpg | base64 -d > embedded.jpg
```

**Custom Namespace Investigation:**
```bash
# List all XMP namespaces
exiftool -X image.jpg | grep xmlns

# Extract specific custom namespace
exiftool -XMP-custom:all image.jpg
```

**PDF XMP (when dealing with PDFs in image challenges):**
```bash
exiftool -XMP:all document.pdf
pdfinfo -meta document.pdf
```

### ICC Color Profiles

ICC (International Color Consortium) profiles can be surprisingly large and are excellent containers for steganographic data. They're binary structures often overlooked during initial analysis.

#### ICC Profile Extraction

```bash
# Extract ICC profile to separate file
exiftool -icc_profile -b image.jpg > profile.icc

# Using ImageMagick
convert image.jpg icc.icc

# View ICC profile information
exiftool profile.icc

# Detailed ICC analysis
iccdump profile.icc  # Part of lcms2-utils package
```

#### ICC Profile Analysis Techniques

**Check Profile Size:**
```bash
# Legitimate profiles typically 300KB-5MB
# Unusually large profiles may contain hidden data
ls -lh profile.icc

# Compare against standard profiles
diff profile.icc /usr/share/color/icc/sRGB.icc
```

**Binary Analysis of ICC Profiles:**
```bash
# Extract strings
strings profile.icc

# Hex dump analysis
xxd profile.icc | less

# Check for embedded files
binwalk profile.icc

# Look for entropy anomalies
ent profile.icc
```

**ICC Profile Structure:**
ICC profiles have a specific binary structure. Appended data after the profile definition is a common hiding technique:

```bash
# Read ICC profile header (first 128 bytes)
xxd -l 128 profile.icc

# Extract profile size from header (bytes 0-3)
xxd -s 0 -l 4 profile.icc

# Compare declared size vs actual file size
declared_size=$(xxd -s 0 -l 4 -p profile.icc)
actual_size=$(stat -f%z profile.icc)  # macOS
actual_size=$(stat -c%s profile.icc)  # Linux
```

**Removing ICC Profiles for Comparison:**
```bash
# Strip ICC profile from image
convert image.jpg -strip no_icc.jpg

# Or with exiftool
exiftool -icc_profile= image.jpg -o no_icc.jpg

# Compare file sizes
ls -lh image.jpg no_icc.jpg
```

### Thumbnail Extraction

Embedded thumbnails can differ from the main image, potentially containing hidden information, different content, or serving as decoy images.

#### Thumbnail Extraction Methods

```bash
# Extract with exiftool
exiftool -b -ThumbnailImage image.jpg > thumb.jpg
exiftool -b -PreviewImage image.jpg > preview.jpg

# Extract all preview/thumbnail variants
exiftool -b -ThumbnailImage -PreviewImage -JpgFromRaw image.jpg

# For RAW formats (CR2, NEF, etc.)
exiftool -b -JpgFromRaw image.cr2 > thumb.jpg
```

**Extract Thumbnails from EXIF Data:**
```bash
# EXIF thumbnails specifically
exiv2 -et image.jpg  # Outputs image-thumb.jpg

# Using ImageMagick for multi-page documents
convert 'image.jpg[0]' thumbnail.jpg  # First embedded image
```

#### Thumbnail Analysis Workflow

**Compare Thumbnail vs Main Image:**
```bash
# Visual comparison
compare thumb.jpg image.jpg diff.png

# Hash comparison
md5sum thumb.jpg image.jpg
sha256sum thumb.jpg image.jpg

# Pixel-level difference
compare -metric AE thumb.jpg image.jpg diff.png
```

**Check Thumbnail Timestamps:**
```bash
# Thumbnails may have different timestamps
exiftool -time:all thumb.jpg
exiftool -time:all image.jpg
```

**Multiple Thumbnail Investigation:**
```bash
# Some formats store multiple thumbnails
exiftool -ee -a -G1 image.jpg | grep -i thumb

# Extract all individually
exiftool -b -ThumbnailImage image.jpg > thumb1.jpg
exiftool -b -PreviewImage image.jpg > thumb2.jpg
exiftool -b -OtherImage image.jpg > thumb3.jpg
```

### GPS Coordinates

GPS metadata contains geolocation data that in CTFs may encode coordinates pointing to locations, map services, or represent encoded numeric data.

#### GPS Data Extraction

```bash
# Extract all GPS data
exiftool -gps:all image.jpg

# Extract specific coordinates
exiftool -GPSLatitude -GPSLongitude -GPSAltitude image.jpg

# Extract in decimal degrees format
exiftool -c "%.6f" -GPSPosition image.jpg

# Extract GPS with reference directions
exiftool -GPSLatitude -GPSLatitudeRef -GPSLongitude -GPSLongitudeRef image.jpg
```

#### GPS Coordinate Formats and Conversion

**Converting GPS Formats:**
```bash
# DMS (Degrees, Minutes, Seconds) to Decimal
# Example: 37 deg 47' 13.02" N = 37.786950

# Extract and convert with exiftool
exiftool -n -gps:all image.jpg  # -n outputs numeric values

# Using coordinate format string
exiftool -c "%+.6f" -GPSPosition image.jpg
```

**Generating Map Links from GPS Data:**
```bash
# Extract coordinates and create Google Maps URL
lat=$(exiftool -n -s3 -GPSLatitude image.jpg)
lon=$(exiftool -n -s3 -GPSLongitude image.jpg)
echo "https://www.google.com/maps?q=${lat},${lon}"

# OpenStreetMap URL
echo "https://www.openstreetmap.org/?mlat=${lat}&mlon=${lon}"
```

#### GPS Steganography Techniques

**Precision Analysis:**
GPS coordinates with unusual precision (e.g., 10+ decimal places) may encode additional information:
```bash
# Check coordinate precision
exiftool -a -G1 -s -gps:all image.jpg

# Extract raw GPS data
exiftool -b -GPSLatitude image.jpg | xxd
```

**GPS Timestamp Analysis:**
```bash
# Extract GPS time
exiftool -GPSDateStamp -GPSTimeStamp image.jpg

# Compare GPS time vs EXIF time (discrepancies may be significant)
exiftool -DateTimeOriginal -GPSDateStamp -GPSTimeStamp image.jpg
```

**Altitude and Additional GPS Fields:**
```bash
# These fields are less commonly checked
exiftool -GPSAltitude -GPSSpeed -GPSImgDirection -GPSDestBearing image.jpg

# GPS processing method and area information
exiftool -GPSProcessingMethod -GPSAreaInformation image.jpg

# Check for binary data in GPS fields
exiftool -b -GPSProcessingMethod image.jpg | xxd
```

#### Comprehensive Metadata Extraction Workflow

**Complete Extraction Script:**
```bash
#!/bin/bash
IMAGE="$1"
OUTPUT_DIR="metadata_analysis"

mkdir -p "$OUTPUT_DIR"

# Extract all metadata
exiftool -a -u -g1 "$IMAGE" > "$OUTPUT_DIR/full_metadata.txt"

# Extract EXIF, IPTC, XMP separately
exiftool -EXIF:all "$IMAGE" > "$OUTPUT_DIR/exif.txt"
exiftool -IPTC:all "$IMAGE" > "$OUTPUT_DIR/iptc.txt"
exiftool -XMP:all "$IMAGE" > "$OUTPUT_DIR/xmp.txt"
exiftool -b -XMP "$IMAGE" > "$OUTPUT_DIR/xmp.xml"

# Extract ICC profile
exiftool -icc_profile -b "$IMAGE" > "$OUTPUT_DIR/icc_profile.icc"

# Extract thumbnails
exiftool -b -ThumbnailImage "$IMAGE" > "$OUTPUT_DIR/thumbnail.jpg" 2>/dev/null
exiftool -b -PreviewImage "$IMAGE" > "$OUTPUT_DIR/preview.jpg" 2>/dev/null

# Extract GPS data
exiftool -gps:all "$IMAGE" > "$OUTPUT_DIR/gps.txt"

# Binary dumps for analysis
exiftool -b -Comment "$IMAGE" | xxd > "$OUTPUT_DIR/comment_hex.txt" 2>/dev/null
exiftool -b -UserComment "$IMAGE" | xxd > "$OUTPUT_DIR/usercomment_hex.txt" 2>/dev/null

# Generate HTML dump for detailed analysis
exiftool -htmlDump "$IMAGE" > "$OUTPUT_DIR/hex_dump.html"

echo "Metadata extraction complete. Results in $OUTPUT_DIR/"
```

### Cross-Platform Considerations

**Linux (Kali):**
- All tools mentioned are available via apt: `apt install exiftool exiv2 imagemagick libimage-exiftool-perl`
- Native support for all metadata formats
- lcms2-utils provides `iccdump` for ICC analysis

**Windows:**
- ExifTool available as standalone .exe from official website
- ImageMagick Windows binaries available
- [Inference] Some command syntax differs (e.g., line continuation, path separators)

**macOS:**
- Tools available via Homebrew: `brew install exiftool exiv2 imagemagick`
- `stat` command syntax differs from Linux (use `-f%z` instead of `-c%s`)

### Important Subtopics for Further Study

- **Metadata Manipulation and Anti-Forensics**: Understanding how attackers remove or falsify metadata
- **Format-Specific Metadata**: PNG (tEXt, zTXt chunks), GIF (comment extensions), TIFF tags, RAW formats
- **Automated Metadata Analysis Pipelines**: Scripting comprehensive extraction for multiple files
- **Metadata-Based OSINT**: Correlation of metadata across multiple images for intelligence gathering

---

## Visual Analysis Techniques

### Color Plane Separation (RGB, CMYK)

Color plane separation involves isolating individual color channels to reveal hidden data that may be embedded in specific color components. Different color models store information differently, making channel separation a fundamental steganography detection technique.

**RGB Channel Separation**

RGB images store data in three separate channels: Red, Green, and Blue. Data can be hidden in one or more channels while maintaining visual appearance.

Using **StegSolve** (primary tool):

```bash
# Launch StegSolve
java -jar stegsolve.jar image.png

# Manual navigation through planes:
# Use arrow keys or buttons to cycle through:
# - Red plane 0-7
# - Green plane 0-7  
# - Blue plane 0-7
```

Using **Python with PIL/Pillow**:

```python
from PIL import Image
import numpy as np

img = Image.open('image.png')
r, g, b = img.split()

# Save individual channels
r.save('red_channel.png')
g.save('green_channel.png')
b.save('blue_channel.png')

# Extract specific bit planes
img_array = np.array(img)
for channel in range(3):
    for bit in range(8):
        bit_plane = (img_array[:,:,channel] >> bit) & 1
        bit_plane = (bit_plane * 255).astype(np.uint8)
        Image.fromarray(bit_plane).save(f'channel_{channel}_bit_{bit}.png')
```

Using **ImageMagick**:

```bash
# Separate RGB channels
convert image.png -channel R -separate red.png
convert image.png -channel G -separate green.png
convert image.png -channel B -separate blue.png

# Extract specific bit planes
convert image.png -depth 8 -channel R -evaluate And 1 red_lsb.png
convert image.png -depth 8 -channel G -evaluate And 1 green_lsb.png
convert image.png -depth 8 -channel B -evaluate And 1 blue_lsb.png
```

Using **GIMP** (GUI approach):

```
1. Colors → Components → Decompose
2. Select "RGB" as color model
3. Check "Decompose to layers"
4. Examine each layer separately
5. Adjust levels/curves per layer
```

**CMYK Channel Separation**

CMYK (Cyan, Magenta, Yellow, Key/Black) is used in print media and some image formats. Less common in CTFs but occasionally encountered.

```bash
# Convert RGB to CMYK and separate
convert image.jpg -colorspace CMYK -separate cmyk_%d.png

# Extract specific CMYK channels
convert image.jpg -colorspace CMYK -channel C -separate cyan.png
convert image.jpg -colorspace CMYK -channel M -separate magenta.png
convert image.jpg -colorspace CMYK -channel Y -separate yellow.png
convert image.jpg -colorspace CMYK -channel K -separate black.png
```

**YCbCr/YUV Channel Separation**

Used in JPEG compression and video encoding. The Y channel stores luminance, Cb and Cr store chrominance.

```python
from PIL import Image

img = Image.open('image.jpg')
ycbcr = img.convert('YCbCr')
y, cb, cr = ycbcr.split()

y.save('y_luminance.png')
cb.save('cb_chroma_blue.png')
cr.save('cr_chroma_red.png')
```

### Alpha Channel Analysis

The alpha channel controls pixel transparency and is frequently exploited for steganography because visual changes may not be obvious to human observers.

**Extracting Alpha Channel**

Using **StegSolve**:

```bash
java -jar stegsolve.jar image.png
# Navigate to "Alpha plane 0-7" views
```

Using **ImageMagick**:

```bash
# Extract alpha channel
convert image.png -alpha extract alpha.png

# View alpha channel as grayscale
convert image.png -channel A -separate alpha_visible.png

# Combine RGB with inverted alpha to visualize
convert image.png \( +clone -alpha extract -negate \) -compose multiply -composite output.png

# Check if alpha channel exists
identify -verbose image.png | grep -i alpha
```

Using **Python**:

```python
from PIL import Image
import numpy as np

img = Image.open('image.png')

# Check if alpha exists
if img.mode in ('RGBA', 'LA', 'PA'):
    alpha = img.split()[-1]
    alpha.save('alpha_channel.png')
    
    # Extract alpha bit planes
    alpha_array = np.array(alpha)
    for bit in range(8):
        bit_plane = (alpha_array >> bit) & 1
        bit_plane = (bit_plane * 255).astype(np.uint8)
        Image.fromarray(bit_plane).save(f'alpha_bit_{bit}.png')
else:
    print("No alpha channel present")
```

Using **zsteg** (for PNG files):

```bash
# Analyze alpha channel LSB
zsteg -a image.png

# Specifically extract from alpha channel
zsteg -E 'a,lsb,xy' image.png > alpha_data.bin
```

**Alpha Channel Manipulation**

```bash
# Make fully opaque image to see hidden content
convert image.png -alpha off visible.png

# Invert alpha channel
convert image.png -channel A -negate alpha_inverted.png

# Apply alpha channel from one image to another
convert base.png mask.png -compose CopyOpacity -composite output.png
```

### Histogram Analysis

Histogram analysis reveals the distribution of pixel values across color channels. Anomalies in histograms can indicate hidden data.

**Generating Histograms**

Using **ImageMagick**:

```bash
# Generate histogram image
convert image.png histogram:histogram.png

# Generate detailed histogram data
convert image.png -define histogram:unique-colors=false histogram:info:- > histogram.txt

# Per-channel histograms
convert image.png -separate -define histogram:unique-colors=false histogram:channel_%d.png
```

Using **Python with Matplotlib**:

```python
from PIL import Image
import matplotlib.pyplot as plt
import numpy as np

img = Image.open('image.png')
img_array = np.array(img)

# RGB histogram
fig, axes = plt.subplots(1, 3, figsize=(15, 5))
colors = ['red', 'green', 'blue']

for i, color in enumerate(colors):
    axes[i].hist(img_array[:,:,i].ravel(), bins=256, color=color, alpha=0.7)
    axes[i].set_title(f'{color.capitalize()} Channel')
    axes[i].set_xlim([0, 256])

plt.savefig('histogram_rgb.png')

# Combined histogram
plt.figure(figsize=(10, 6))
for i, color in enumerate(colors):
    plt.hist(img_array[:,:,i].ravel(), bins=256, color=color, alpha=0.5, label=color)
plt.legend()
plt.savefig('histogram_combined.png')
```

Using **StegSolve**:

```
File → Analyse → Data Extract
View histogram in the interface
```

**Histogram Anomaly Detection**

[Inference] Steganography can create visible spikes or patterns in histograms, particularly in LSB steganography.

Key indicators to examine:

- **Spike doubling**: LSB embedding can create pairs of adjacent values
- **Even/odd imbalance**: LSB manipulation affects even/odd value distribution
- **Unnatural smoothness**: Hidden data may create artificial patterns
- **Channel-specific anomalies**: Data hidden in one channel only

```python
import numpy as np
from PIL import Image

def detect_histogram_anomalies(image_path):
    img = np.array(Image.open(image_path))
    
    for channel in range(3):
        hist, bins = np.histogram(img[:,:,channel].ravel(), bins=256)
        
        # Check for spike doubling
        pairs = hist[::2] - hist[1::2]
        if np.std(pairs) < np.std(hist) * 0.5:
            print(f"Channel {channel}: Possible LSB embedding detected")
        
        # Check even/odd distribution
        even_sum = np.sum(hist[::2])
        odd_sum = np.sum(hist[1::2])
        ratio = even_sum / odd_sum if odd_sum > 0 else 0
        if abs(ratio - 1.0) > 0.1:
            print(f"Channel {channel}: Even/odd imbalance: {ratio:.3f}")
```

### Contrast/Brightness Manipulation

Adjusting contrast and brightness can reveal data hidden in slight variations not visible to the human eye.

**Using ImageMagick**:

```bash
# Increase contrast dramatically
convert image.png -contrast -contrast -contrast high_contrast.png

# Auto-level (normalize histogram)
convert image.png -auto-level auto_leveled.png

# Normalize (stretch contrast to full range)
convert image.png -normalize normalized.png

# Adjust brightness/contrast with specific values
convert image.png -brightness-contrast 50x50 adjusted.png

# Apply sigmoid contrast (non-linear)
convert image.png -sigmoidal-contrast 10x50% sigmoid.png

# Equalize histogram
convert image.png -equalize equalized.png
```

**Using Python**:

```python
from PIL import Image, ImageEnhance
import numpy as np

img = Image.open('image.png')

# Adjust brightness
enhancer = ImageEnhance.Brightness(img)
for factor in [0.5, 1.5, 2.0, 3.0]:
    enhancer.enhance(factor).save(f'brightness_{factor}.png')

# Adjust contrast
enhancer = ImageEnhance.Contrast(img)
for factor in [2.0, 5.0, 10.0, 20.0]:
    enhancer.enhance(factor).save(f'contrast_{factor}.png')

# Histogram equalization
img_array = np.array(img)
for channel in range(3):
    hist, bins = np.histogram(img_array[:,:,channel].flatten(), 256, [0,256])
    cdf = hist.cumsum()
    cdf_normalized = cdf * 255 / cdf[-1]
    img_array[:,:,channel] = np.interp(img_array[:,:,channel].flatten(), 
                                        bins[:-1], cdf_normalized).reshape(img_array[:,:,channel].shape)
Image.fromarray(img_array.astype(np.uint8)).save('equalized.png')
```

**Using GIMP**:

```
Colors → Curves (adjust curve dramatically)
Colors → Levels (slide input/output levels)
Colors → Auto → Normalize
Colors → Auto → Equalize
Filters → Enhance → Sharpen (Unsharp Mask)
```

**Extreme Manipulation Techniques**:

```bash
# Apply multiple contrast operations
convert image.png -level 0%,100%,0.5 -contrast -contrast level_contrast.png

# Gamma correction
convert image.png -gamma 0.5 gamma_low.png
convert image.png -gamma 2.0 gamma_high.png

# Posterize (reduce colors to see patterns)
convert image.png -posterize 4 posterized.png
```

### Color Inversion & Filters

Color inversion and filter application can reveal negative images or data encoded with specific color transformations.

**Basic Inversion**

```bash
# Full color inversion
convert image.png -negate inverted.png

# Per-channel inversion
convert image.png -channel R -negate red_inverted.png
convert image.png -channel G -negate green_inverted.png
convert image.png -channel B -negate blue_inverted.png

# Invert specific bit planes (using Python)
```

```python
from PIL import Image
import numpy as np

img = np.array(Image.open('image.png'))

# XOR inversion (equivalent to bitwise NOT)
inverted = 255 - img
Image.fromarray(inverted.astype(np.uint8)).save('inverted.png')

# Per-channel XOR with custom values
for val in [127, 255, 85, 170]:
    xor_result = img ^ val
    Image.fromarray(xor_result.astype(np.uint8)).save(f'xor_{val}.png')
```

**Color Space Conversions**

```bash
# Convert to grayscale
convert image.png -colorspace Gray grayscale.png

# Convert to different color spaces
convert image.png -colorspace HSL hsl.png
convert image.png -colorspace HSB hsb.png
convert image.png -colorspace Lab lab.png

# Extract individual components from HSL
convert image.png -colorspace HSL -channel R -separate hue.png
convert image.png -colorspace HSL -channel G -separate saturation.png
convert image.png -colorspace HSL -channel B -separate lightness.png
```

**Filter Applications**

```bash
# Edge detection
convert image.png -edge 1 edges.png
convert image.png -canny 0x1+10%+30% canny_edges.png

# Emboss
convert image.png -emboss 2 embossed.png

# Sharpen
convert image.png -sharpen 0x3 sharpened.png

# Blur (sometimes reveals hidden structure)
convert image.png -blur 0x2 blurred.png

# Median filter (noise reduction)
convert image.png -median 3 median.png
```

**StegSolve Filters**:

```
StegSolve provides quick filter navigation:
- XOR with constant values (0-255)
- ADD/SUB operations
- Random color maps
- Stereogram view
```

**Advanced Color Manipulation**:

```python
from PIL import Image
import numpy as np

img = np.array(Image.open('image.png'))

# Apply bit-level operations
operations = {
    'xor_170': img ^ 170,
    'xor_85': img ^ 85,
    'and_170': img & 170,
    'or_85': img | 85,
    'shift_left': (img << 1) & 255,
    'shift_right': img >> 1,
    'swap_rg': img[:,:,[1,0,2]],
    'swap_rb': img[:,:,[2,1,0]]
}

for name, result in operations.items():
    Image.fromarray(result.astype(np.uint8)).save(f'{name}.png')
```

### Image Layer Extraction

Images may contain multiple layers, metadata, or embedded objects that require extraction.

**EXIF and Metadata Extraction**

```bash
# Extract all EXIF data
exiftool image.jpg
exiftool -a -G1 -s image.jpg  # Detailed format

# Extract to text file
exiftool image.jpg > metadata.txt

# Extract specific fields
exiftool -Comment -Description -ImageDescription image.jpg

# Extract thumbnail (if present)
exiftool -b -ThumbnailImage image.jpg > thumbnail.jpg

# Check for ICC profiles
exiftool -ICC_Profile image.jpg
```

**Embedded Object Extraction**

Using **binwalk**:

```bash
# Scan for embedded files
binwalk image.png

# Extract all found files
binwalk -e image.png

# Extract specific file types
binwalk --dd='.*' image.png

# Scan with entropy analysis
binwalk -E image.png
```

Using **foremost**:

```bash
# Carve files from image
foremost -i image.png -o output_dir

# Specify file types
foremost -t jpg,png,zip,pdf -i image.png -o output_dir
```

Using **steghide** (JPEG/BMP/WAV/AU):

```bash
# Extract hidden data (requires passphrase)
steghide extract -sf image.jpg

# Try without passphrase
steghide extract -sf image.jpg -p ""

# Get information about embedded data
steghide info image.jpg
```

**PNG-Specific Layer Extraction**

```bash
# Extract PNG chunks
pngcheck -v image.png

# Use tweakpng or pngtools
pngchunks image.png

# Extract specific chunks
python3 << EOF
import struct

with open('image.png', 'rb') as f:
    f.read(8)  # Skip PNG signature
    while True:
        length_data = f.read(4)
        if len(length_data) < 4:
            break
        length = struct.unpack('>I', length_data)[0]
        chunk_type = f.read(4).decode('ascii')
        chunk_data = f.read(length)
        crc = f.read(4)
        
        if chunk_type not in ['IHDR', 'IDAT', 'IEND']:
            print(f"Found {chunk_type} chunk ({length} bytes)")
            with open(f'chunk_{chunk_type}.bin', 'wb') as out:
                out.write(chunk_data)
EOF
```

**GIMP Layer Analysis**:

```
For XCF, PSD, or multi-layer formats:
1. Open in GIMP
2. Windows → Dockable Dialogs → Layers
3. Examine each layer individually
4. Export layers: Filters → Python-Fu → Export Layers
5. Check layer blend modes and opacity
```

**Animated Format Frame Extraction**

```bash
# Extract GIF frames
convert animation.gif frame_%d.png

# Extract APNG frames
apngdis animation.png

# Extract WebP frames (if animated)
webpmux -get frame 1 animation.webp -o frame1.webp
```

**PDF-Embedded Images**:

```bash
# Extract images from PDF
pdfimages document.pdf output_prefix

# With format preservation
pdfimages -all document.pdf output_prefix
```

### Important Related Topics

After mastering these visual analysis techniques, you should explore:

- **LSB Steganography Detection** - Applies histogram and bit plane analysis findings
- **File Format Analysis** - Understanding headers/structures enables deeper layer extraction
- **Audio Spectrogram Analysis** - Similar visual analysis principles applied to audio
- **Forensic File Recovery** - Extends embedded object extraction techniques

---

## LSB Techniques

### LSB Extraction (Per Channel)

LSB extraction involves isolating and reading the least significant bits from specific color channels in image files. This is the most common steganography technique in CTF challenges.

**Channel Structure in RGB Images:** Each pixel contains three color values (Red, Green, Blue), each typically 8 bits (0-255). Some formats include an Alpha channel (RGBA) for transparency.

```
Pixel structure:
RRRRRRRR GGGGGGGG BBBBBBBB (AAAAAAAA)
       ↑        ↑        ↑         ↑
      LSB      LSB      LSB       LSB
```

**Per-Channel Extraction Methods:**

#### Red Channel Only

```bash
# Using zsteg (automated)
zsteg -E b1,r,lsb,xy image.png

# Manual extraction with Python
from PIL import Image

img = Image.open('image.png')
pixels = img.load()
width, height = img.size

bits = []
for y in range(height):
    for x in range(width):
        r, g, b = pixels[x, y][:3]
        bits.append(str(r & 1))  # Extract LSB from red channel
        
# Convert bits to bytes
bytes_data = bytearray()
for i in range(0, len(bits), 8):
    byte = bits[i:i+8]
    bytes_data.append(int(''.join(byte), 2))
    
with open('extracted.bin', 'wb') as f:
    f.write(bytes_data)
```

#### Green Channel Only

```bash
zsteg -E b1,g,lsb,xy image.png
```

#### Blue Channel Only

```bash
zsteg -E b1,b,lsb,xy image.png
```

#### Alpha Channel (RGBA/PNG)

```bash
zsteg -E b1,a,lsb,xy image.png

# Manual Python extraction
r, g, b, a = pixels[x, y]
bits.append(str(a & 1))  # Extract LSB from alpha channel
```

#### All Channels Sequential (RGB order)

```bash
# Extract LSB from R, then G, then B in sequence
zsteg -E b1,rgb,lsb,xy image.png

# Manual approach
for y in range(height):
    for x in range(width):
        r, g, b = pixels[x, y][:3]
        bits.append(str(r & 1))
        bits.append(str(g & 1))
        bits.append(str(b & 1))
```

#### All Channels Sequential (BGR order)

Some tools and challenges use BGR ordering:

```bash
zsteg -E b1,bgr,lsb,xy image.png
```

**Reading Direction Variations:**

Extraction order significantly impacts decoded data:

```bash
# Row-wise left-to-right, top-to-bottom (most common)
zsteg -E b1,rgb,lsb,xy image.png

# Column-wise top-to-bottom, left-to-right
zsteg -E b1,rgb,lsb,yx image.png

# XOR with coordinates (advanced)
zsteg -E b1,rgb,lsb,XY image.png
```

**CTF Strategy for Per-Channel Extraction:**

1. **Try all single channels first:**

```bash
zsteg -a image.png | grep -E "b1,(r|g|b|a),lsb"
```

2. **Check RGB vs BGR ordering:**

```bash
zsteg -E b1,rgb,lsb,xy image.png > rgb.bin
zsteg -E b1,bgr,lsb,xy image.png > bgr.bin
strings rgb.bin | grep -i flag
strings bgr.bin | grep -i flag
```

3. **Examine extracted binary for file signatures:**

```bash
file extracted.bin
hexdump -C extracted.bin | head
```

**Common Patterns:**

- Text flags often in red or blue channels alone
- Binary files (ZIP, PNG) typically use all RGB channels for capacity
- Alpha channel rarely used but high-value when it is

### MSB Analysis

MSB (Most Significant Bit) analysis examines the most significant bits instead of least significant bits. While less common for data hiding due to high visibility, MSB analysis is valuable for forensics and understanding data structure.

**Bit Significance Review:**

```
Byte: 11010110
      ↑      ↑
     MSB    LSB
```

Changing MSB from 1→0 changes 11010110 (214) to 01010110 (86)—dramatically visible in images.

**Why MSB in CTF Challenges:**

[Inference] CTF creators occasionally use MSB techniques to:

- Test comprehensive bit analysis knowledge
- Hide data in intentionally corrupted/glitchy images
- Create red herrings where LSB contains decoy data
- Exploit specific tool limitations that only check LSB

**MSB Extraction with zsteg:**

```bash
# Extract MSB from red channel
zsteg -E b8,r,msb,xy image.png

# Extract MSB from all RGB channels
zsteg -E b8,rgb,msb,xy image.png

# Check all MSB variations automatically
zsteg -a image.png | grep msb
```

**Manual MSB Extraction (Python):**

```python
from PIL import Image

img = Image.open('image.png')
pixels = img.load()
width, height = img.size

bits = []
for y in range(height):
    for x in range(width):
        r, g, b = pixels[x, y][:3]
        # Extract MSB (bit 7) by right-shifting 7 positions
        bits.append(str((r >> 7) & 1))
        bits.append(str((g >> 7) & 1))
        bits.append(str((b >> 7) & 1))

# Convert to bytes
bytes_data = bytearray()
for i in range(0, len(bits), 8):
    byte = bits[i:i+8]
    bytes_data.append(int(''.join(byte), 2))

with open('msb_extracted.bin', 'wb') as f:
    f.write(bytes_data)
```

**MSB Visualization:**

Visual inspection of MSB patterns can reveal structure:

```python
# Create image from MSB plane
msb_img = Image.new('L', (width, height))
msb_pixels = msb_img.load()

for y in range(height):
    for x in range(width):
        r, g, b = pixels[x, y][:3]
        # Visualize red channel MSB
        msb_pixels[x, y] = ((r >> 7) & 1) * 255

msb_img.save('msb_visual.png')
```

**Combined MSB+LSB Analysis:**

```bash
# Check both simultaneously with zsteg
zsteg -E b1,rgb,lsb,xy image.png > lsb.bin
zsteg -E b8,rgb,msb,xy image.png > msb.bin
diff lsb.bin msb.bin
```

**Stegsolve MSB Analysis:**

Using Stegsolve (GUI tool):

1. Load image
2. Navigate through bit planes using arrow keys
3. Plane 7 (Red 7, Green 7, Blue 7) shows MSB
4. Look for patterns, text, or QR codes

### Bit Plane Slicing

Bit plane slicing separates an image into constituent bit layers, revealing hidden patterns imperceptible in the composite image.

**Concept:**

Each color channel (8-bit) can be decomposed into 8 binary images (bit planes):

```
Pixel value 214: 11010110
                 ││││││││
Bit Plane 7 (MSB): 1.......  (most significant)
Bit Plane 6:       .1......
Bit Plane 5:       ..0.....
Bit Plane 4:       ...1....
Bit Plane 3:       ....0...
Bit Plane 2:       .....1..
Bit Plane 1:       ......1.
Bit Plane 0 (LSB): .......0  (least significant)
```

**Visual Characteristics:**

- **Planes 7-6**: Contain most image structure and detail
- **Planes 5-3**: Medium-frequency details
- **Planes 2-0**: Noise, subtle variations—ideal for hidden data

**Stegsolve Method (Recommended for CTF):**

Stegsolve provides interactive bit plane viewing:

```bash
# Launch Stegsolve
java -jar stegsolve.jar

# Then in GUI:
# File → Open → Select image
# Use arrow keys (← →) to cycle through planes:
# - Red 0 through Red 7
# - Green 0 through Green 7
# - Blue 0 through Blue 7
# - Alpha 0 through Alpha 7 (if present)
```

**What to Look For:**

- Readable text in lower bit planes (0-2)
- QR codes appearing in specific planes
- Images hidden in single planes
- Geometric patterns indicating structured data
- Differences between planes (XOR operations)

**Python-Based Bit Plane Extraction:**

```python
from PIL import Image
import numpy as np

img = Image.open('image.png')
img_array = np.array(img)

# Extract specific bit plane from red channel
def extract_bit_plane(img_array, channel, bit_position):
    """
    channel: 0=Red, 1=Green, 2=Blue
    bit_position: 0 (LSB) to 7 (MSB)
    """
    channel_data = img_array[:, :, channel]
    bit_plane = (channel_data >> bit_position) & 1
    # Scale to visible range (0 or 255)
    bit_plane = bit_plane * 255
    return Image.fromarray(bit_plane.astype('uint8'), mode='L')

# Extract all planes from red channel
for bit in range(8):
    plane = extract_bit_plane(img_array, 0, bit)
    plane.save(f'red_plane_{bit}.png')
    print(f"Saved red plane {bit}")
```

**Automated Analysis with zsteg:**

```bash
# Check all bit plane combinations
zsteg -a image.png

# Specific plane extraction (bit 0 = LSB)
zsteg -E b1,rgb,lsb,xy image.png  # Plane 0
zsteg -E b2,rgb,lsb,xy image.png  # Plane 1
# ... up to b8 for MSB
```

**XOR Bit Plane Analysis:**

Some challenges hide data in XOR combinations of planes:

```python
# XOR planes (example: Red LSB XOR Green LSB)
red_lsb = (img_array[:, :, 0] & 1) * 255
green_lsb = (img_array[:, :, 1] & 1) * 255
xor_result = red_lsb ^ green_lsb
xor_img = Image.fromarray(xor_result.astype('uint8'), mode='L')
xor_img.save('xor_red_green.png')
```

**CTF Workflow:**

1. **Quick visual scan with Stegsolve** (all planes in 30 seconds)
2. **Identify suspicious planes** (unusual patterns, text fragments)
3. **Extract binary data** from identified planes
4. **Check for file signatures** in extracted data
5. **Try XOR combinations** if single planes unsuccessful

### Bit Order Manipulation

Bit order manipulation involves extracting or reading bits in non-standard sequences, including reversed bit order, interleaved patterns, or custom arrangements.

**Standard vs Reversed Bit Order:**

```
Standard (big-endian bit order):
Byte: 11010110 → bit 7 first, bit 0 last

Reversed (little-endian bit order):
Byte: 01101011 → bit 0 first, bit 7 last
```

**Common Bit Order Variations:**

#### 1. Reversed Bit Order Within Bytes

```python
def reverse_bits(byte):
    """Reverse bit order in a single byte"""
    result = 0
    for i in range(8):
        result = (result << 1) | (byte & 1)
        byte >>= 1
    return result

# Process extracted data
with open('extracted.bin', 'rb') as f:
    data = f.read()

reversed_data = bytearray([reverse_bits(b) for b in data])

with open('reversed.bin', 'wb') as f:
    f.write(reversed_data)
```

#### 2. Reversed Byte Order (Endianness)

```python
# Reverse byte order in extracted data
with open('extracted.bin', 'rb') as f:
    data = f.read()

reversed_bytes = data[::-1]  # Reverse entire byte sequence

with open('reversed_bytes.bin', 'wb') as f:
    f.write(reversed_bytes)
```

#### 3. Interleaved Bit Patterns

Data bits interleaved with carrier bits in specific patterns:

```python
# Extract every nth bit
def extract_interleaved(data, offset, step):
    """
    offset: starting bit position
    step: extract every 'step' bits
    """
    bits = []
    bit_count = len(data) * 8
    
    for i in range(offset, bit_count, step):
        byte_idx = i // 8
        bit_idx = i % 8
        if byte_idx < len(data):
            bit = (data[byte_idx] >> bit_idx) & 1
            bits.append(str(bit))
    
    # Convert to bytes
    bytes_data = bytearray()
    for i in range(0, len(bits), 8):
        if i + 8 <= len(bits):
            byte = int(''.join(bits[i:i+8]), 2)
            bytes_data.append(byte)
    
    return bytes_data

# Try different interleaving patterns
with open('image_data.bin', 'rb') as f:
    data = f.read()

for offset in range(8):
    for step in [2, 3, 4]:
        result = extract_interleaved(data, offset, step)
        with open(f'interleaved_o{offset}_s{step}.bin', 'wb') as f:
            f.write(result)
```

#### 4. Custom Bit Reading Sequences

Some challenges use algorithmic bit extraction:

```python
# Example: Extract bits based on coordinate-dependent pattern
from PIL import Image

img = Image.open('image.png')
pixels = img.load()
width, height = img.size

bits = []
for y in range(height):
    for x in range(width):
        r, g, b = pixels[x, y][:3]
        
        # Custom pattern: alternating bit positions
        bit_pos = (x + y) % 8
        
        # Extract specific bit from red channel
        bit = (r >> bit_pos) & 1
        bits.append(str(bit))
```

**zsteg Bit Order Options:**

```bash
# Standard LSB order
zsteg -E b1,rgb,lsb,xy image.png

# MSB order (reversed significance)
zsteg -E b1,rgb,msb,xy image.png

# Different byte orders (zsteg handles internally)
zsteg -a image.png | grep -v "^$"
```

**Detecting Non-Standard Bit Order:**

1. **Entropy analysis**: [Inference] Random-looking data might be correctly ordered; structured data with wrong bit order appears random
2. **File signature checking**: Try reversed orders and check for magic bytes
3. **Statistical patterns**: Correct order often shows ASCII-range bytes for text

```bash
# Check multiple extraction orders
for order in lsb msb; do
    zsteg -E b1,rgb,$order,xy image.png > ${order}.bin
    echo "=== ${order} ==="
    file ${order}.bin
    strings ${order}.bin | head -5
done
```

**CTF Strategy:**

1. **Extract with standard LSB order first**
2. **If garbled, reverse bit order within bytes**
3. **If still garbled, reverse byte order**
4. **Try interleaved patterns** with common steps (2, 3, 4)
5. **Check for coordinate-based or algorithmic patterns** (hints in challenge description)

### Multi-bit LSB Schemes

Multi-bit LSB schemes embed data using multiple least significant bits per byte, trading detectability for increased capacity.

**Bit Depth Variations:**

```
1-bit LSB: 11010110 → 1101011X (modify 1 bit)
2-bit LSB: 11010110 → 110101XX (modify 2 bits)
3-bit LSB: 11010110 → 11010XXX (modify 3 bits)
4-bit LSB: 11010110 → 1101XXXX (modify 4 bits)
```

**Perceptual Impact:**

|Bits Modified|Value Change Range|Visual Impact|CTF Usage|
|---|---|---|---|
|1-bit|±1|Imperceptible|Very common|
|2-bit|±3|Barely noticeable|Common|
|3-bit|±7|Slightly visible|Occasional|
|4-bit|±15|Clearly visible|Rare|

**Capacity Calculation for 1920×1080 RGB Image:**

```
1-bit LSB: 1 bit/channel × 3 channels × 2,073,600 pixels = 777,600 bytes (~759 KB)
2-bit LSB: 2 bits/channel × 3 channels × 2,073,600 pixels = 1,555,200 bytes (~1.5 MB)
3-bit LSB: 3 bits/channel × 3 channels × 2,073,600 pixels = 2,332,800 bytes (~2.2 MB)
4-bit LSB: 4 bits/channel × 3 channels × 2,073,600 pixels = 3,110,400 bytes (~3.0 MB)
```

**Extraction with zsteg:**

```bash
# 1-bit LSB (standard)
zsteg -E b1,rgb,lsb,xy image.png

# 2-bit LSB
zsteg -E b2,rgb,lsb,xy image.png

# 3-bit LSB
zsteg -E b3,rgb,lsb,xy image.png

# 4-bit LSB
zsteg -E b4,rgb,lsb,xy image.png

# Automated check of all bit depths
zsteg -a image.png | grep -E "b[1-8],rgb"
```

**Manual Multi-bit Extraction (Python):**

```python
from PIL import Image

def extract_n_bit_lsb(image_path, n_bits, channels='rgb'):
    """
    Extract n least significant bits from specified channels
    n_bits: 1-8 (number of LSBs to extract)
    channels: 'r', 'g', 'b', 'rgb', 'bgr', etc.
    """
    img = Image.open(image_path)
    pixels = img.load()
    width, height = img.size
    
    # Create bitmask for n bits
    mask = (1 << n_bits) - 1  # e.g., n_bits=3 → mask=0b111
    
    bits = []
    for y in range(height):
        for x in range(width):
            pixel = pixels[x, y][:3]
            
            for ch in channels:
                if ch == 'r':
                    value = pixel[0]
                elif ch == 'g':
                    value = pixel[1]
                elif ch == 'b':
                    value = pixel[2]
                
                # Extract n LSBs
                extracted = value & mask
                
                # Convert to binary string (padded to n_bits length)
                bits.append(format(extracted, f'0{n_bits}b'))
    
    # Join all bits
    bit_string = ''.join(bits)
    
    # Convert to bytes
    bytes_data = bytearray()
    for i in range(0, len(bit_string), 8):
        if i + 8 <= len(bit_string):
            byte = int(bit_string[i:i+8], 2)
            bytes_data.append(byte)
    
    return bytes_data

# Extract 2-bit LSB from RGB channels
data = extract_n_bit_lsb('image.png', n_bits=2, channels='rgb')
with open('2bit_extracted.bin', 'wb') as f:
    f.write(data)
```

**Bit Plane Combination Extraction:**

Some challenges use non-contiguous bit planes:

```python
def extract_specific_bits(image_path, bit_positions, channels='rgb'):
    """
    Extract specific bit positions (not necessarily contiguous)
    bit_positions: list of bit positions to extract [0-7]
    Example: [0, 1] for 2 LSBs, [0, 2, 4] for alternating bits
    """
    img = Image.open(image_path)
    pixels = img.load()
    width, height = img.size
    
    bits = []
    for y in range(height):
        for x in range(width):
            pixel = pixels[x, y][:3]
            
            for ch in channels:
                if ch == 'r':
                    value = pixel[0]
                elif ch == 'g':
                    value = pixel[1]
                elif ch == 'b':
                    value = pixel[2]
                
                # Extract specified bit positions
                for bit_pos in bit_positions:
                    bit = (value >> bit_pos) & 1
                    bits.append(str(bit))
    
    # Convert to bytes
    bytes_data = bytearray()
    for i in range(0, len(bits), 8):
        if i + 8 <= len(bits):
            byte = int(''.join(bits[i:i+8]), 2)
            bytes_data.append(byte)
    
    return bytes_data

# Example: Extract bits 0, 1, and 3 from each channel
data = extract_specific_bits('image.png', [0, 1, 3], 'rgb')
```

**Detection and Analysis:**

Visual detection of multi-bit LSB embedding:

```python
# Create visual difference map
from PIL import Image
import numpy as np

original = np.array(Image.open('original.png'))
stego = np.array(Image.open('stego.png'))

# Amplify differences
diff = np.abs(original.astype(int) - stego.astype(int)) * 50
diff = np.clip(diff, 0, 255).astype('uint8')

diff_img = Image.fromarray(diff)
diff_img.save('difference.png')
```

**CTF Strategy for Multi-bit LSB:**

1. **Start with 1-bit LSB** (most common)
2. **If capacity seems insufficient for expected payload, try 2-bit**
3. **Check file size**: If stego image is large, higher bit depths possible
4. **Visual inspection**: Noticeable artifacts suggest 3+ bit LSB
5. **Automated sweep**:

```bash
# Check all bit depths automatically
for bits in {1..4}; do
    echo "=== Testing ${bits}-bit LSB ==="
    zsteg -E b${bits},rgb,lsb,xy image.png > ${bits}bit.bin
    file ${bits}bit.bin
    strings ${bits}bit.bin | grep -i "flag\|ctf\|{" | head -3
done
```

**Hybrid Schemes:**

[Inference] Some advanced challenges use different bit depths per channel:

```python
# Example: 2 bits from R, 1 bit from G, 2 bits from B
def extract_hybrid(image_path):
    img = Image.open(image_path)
    pixels = img.load()
    width, height = img.size
    
    bits = []
    for y in range(height):
        for x in range(width):
            r, g, b = pixels[x, y][:3]
            
            # 2 LSBs from red
            bits.append(str(r & 1))
            bits.append(str((r >> 1) & 1))
            
            # 1 LSB from green
            bits.append(str(g & 1))
            
            # 2 LSBs from blue
            bits.append(str(b & 1))
            bits.append(str((b >> 1) & 1))
    
    # Convert to bytes
    bit_string = ''.join(bits)
    bytes_data = bytearray()
    for i in range(0, len(bit_string), 8):
        if i + 8 <= len(bit_string):
            bytes_data.append(int(bit_string[i:i+8], 2))
    
    return bytes_data
```

**Important Considerations:**

- **Compression artifacts**: JPEG's lossy compression destroys LSB data; multi-bit LSB only works with lossless formats (PNG, BMP, TIFF)
- **Statistical detection**: [Unverified] Higher bit depths create stronger statistical anomalies detectable by chi-square tests, though this is less relevant in CTF contexts
- **Tool limitations**: Not all tools support arbitrary bit depths; manual scripting may be necessary

---

# Advanced Image Analysis

## Stereogram Decoding

### Understanding Stereogram Types

Stereograms are images designed to create 3D depth perception through parallax viewing. The primary types encountered in CTF challenges are Random Dot Stereograms (RDS), Single Image Stereograms (SIS), and Autostereograms. RDS consists of two slightly offset versions of the same pattern viewed simultaneously, creating depth illusion. SIS/Autostereograms contain a single image where repeating patterns at varying horizontal offsets encode depth information.

Autostereograms function by repeating a base pattern across the image width with controlled shifts based on depth data. The shift distance is inversely related to perceived depth—smaller shifts create objects appearing further away, larger shifts bring objects closer. The eye-crossing distance and viewing method (crossed-eye vs. wall-eyed) affect the decoded result.

In CTF scenarios, hidden data is embedded in depth maps or the repeating pattern itself, requiring precise stereogram analysis to reveal.

### Identifying Autostereograms

Detect autostereograms through pattern analysis:

```python
import numpy as np
from PIL import Image
from scipy import signal

def detect_autostereogram(image_path):
    """
    Analyze image for autostereogram characteristics
    """
    img = Image.open(image_path)
    img_array = np.array(img.convert('L'))  # Convert to grayscale
    
    height, width = img_array.shape
    print(f"Image dimensions: {width}x{height}")
    
    # Analyze horizontal line patterns
    # Autostereograms have repeating patterns horizontally
    middle_row = img_array[height // 2, :]
    
    # Compute autocorrelation to find repeating pattern period
    autocorr = signal.correlate(middle_row, middle_row, mode='full')
    autocorr = autocorr[len(autocorr)//2:]
    
    # Find peaks in autocorrelation (indicate pattern repetition)
    peaks, properties = signal.find_peaks(autocorr[1:], height=np.max(autocorr)*0.5)
    
    if len(peaks) > 0:
        first_peak = peaks[0] + 1
        print(f"Potential pattern period: {first_peak} pixels")
        print(f"Autocorrelation peaks: {peaks[:5]}")
        return True, first_peak
    else:
        print("No repeating pattern detected")
        return False, None

def analyze_stereogram_depth(image_path):
    """
    Extract depth information from autostereogram
    """
    img = Image.open(image_path)
    img_array = np.array(img.convert('L'))
    
    height, width = img_array.shape
    
    # Analyze each row for pattern shifts
    is_stereogram, period = detect_autostereogram(image_path)
    
    if not is_stereogram or period is None:
        print("Not a stereogram")
        return None
    
    depth_map = np.zeros((height, width))
    
    # For each row, calculate pattern shift at each column
    for row in range(height):
        row_data = img_array[row, :]
        
        # Compare pattern shifts at different positions
        for col in range(width - period):
            # Extract two windows
            window1 = row_data[col:col+period]
            window2 = row_data[col+period:col+2*period]
            
            # Calculate correlation
            correlation = np.correlate(window1, window2, mode='valid')
            if len(correlation) > 0:
                depth_map[row, col] = correlation[0]
    
    # Normalize depth map
    depth_map = ((depth_map - depth_map.min()) / 
                 (depth_map.max() - depth_map.min()) * 255).astype(np.uint8)
    
    # Save depth map visualization
    depth_img = Image.fromarray(depth_map)
    depth_img.save('depth_map.png')
    print("Depth map saved to depth_map.png")
    
    return depth_map

# Usage
is_stereo, period = detect_autostereogram('image.png')
if is_stereo:
    depth_map = analyze_stereogram_depth('image.png')
```

### Stereogram Pattern Extraction

Extract the repeating pattern from autostereograms:

```python
def extract_stereogram_pattern(image_path):
    """
    Extract the base repeating pattern from autostereogram
    """
    img = Image.open(image_path)
    img_array = np.array(img.convert('L'))
    
    height, width = img_array.shape
    
    # Detect pattern period
    middle_row = img_array[height // 2, :]
    autocorr = signal.correlate(middle_row, middle_row, mode='full')
    autocorr = autocorr[len(autocorr)//2:]
    peaks, _ = signal.find_peaks(autocorr[1:], height=np.max(autocorr)*0.5)
    
    if len(peaks) == 0:
        print("No pattern detected")
        return None
    
    period = peaks[0] + 1
    print(f"Pattern period: {period}")
    
    # Extract pattern from top-left corner
    pattern = img_array[:period, :period]
    
    # Visualize pattern
    pattern_img = Image.fromarray(pattern)
    pattern_img.save('extracted_pattern.png')
    print(f"Pattern size: {pattern.shape}")
    print("Pattern saved to extracted_pattern.png")
    
    return pattern

def analyze_pattern_variations(image_path, period):
    """
    Analyze how pattern changes across the image (encodes depth)
    """
    img = Image.open(image_path)
    img_array = np.array(img.convert('L'))
    height, width = img_array.shape
    
    variations = []
    
    for col in range(0, width - period, period // 2):
        column_data = img_array[:, col:col+period]
        mean_val = np.mean(column_data)
        std_val = np.std(column_data)
        variations.append((col, mean_val, std_val))
    
    print("\nPattern variations across image:")
    for col, mean, std in variations[:10]:
        print(f"  Column {col}: Mean={mean:.1f}, StdDev={std:.1f}")
    
    return variations

# Usage
pattern = extract_stereogram_pattern('image.png')
if pattern is not None:
    period = pattern.shape[0]
    variations = analyze_pattern_variations('image.png', period)
```

### Stereogram Decoding to 2D Image

Decode autostereograms by extracting the hidden 2D image:

```python
def decode_autostereogram(image_path, viewing_distance=65):
    """
    Decode autostereogram to extract hidden 2D image.
    viewing_distance: approximate shift per depth unit
    """
    img = Image.open(image_path)
    img_array = np.array(img.convert('L'))
    
    height, width = img_array.shape
    
    # Detect base pattern period
    middle_row = img_array[height // 2, :]
    autocorr = signal.correlate(middle_row, middle_row, mode='full')
    autocorr = autocorr[len(autocorr)//2:]
    peaks, _ = signal.find_peaks(autocorr[1:], height=np.max(autocorr)*0.5)
    
    if len(peaks) == 0:
        print("No stereogram detected")
        return None
    
    period = peaks[0] + 1
    print(f"Base period: {period}")
    
    # Create output image
    decoded = np.zeros((height, width), dtype=np.uint8)
    
    # For each row
    for row in range(height):
        row_data = img_array[row, :]
        
        # Extract pattern at this row
        pattern = row_data[:period]
        
        # Replicate pattern across width
        for col in range(width):
            # Calculate expected position with depth variation
            pattern_idx = col % period
            decoded[row, col] = pattern[pattern_idx]
    
    # This creates the baseline; now detect shifts for depth
    decoded_img = Image.fromarray(decoded)
    decoded_img.save('decoded_stereogram.png')
    print("Decoded image saved to decoded_stereogram.png")
    
    return decoded

def cross_eye_view_decode(image_path):
    """
    Create a split image for cross-eye viewing
    """
    img = Image.open(image_path)
    width, height = img.size
    
    # Split into left and right halves
    left_half = img.crop((0, 0, width // 2, height))
    right_half = img.crop((width // 2, 0, width, height))
    
    # Create cross-eye version (swap left and right)
    cross_eye = Image.new('RGB', (width, height))
    cross_eye.paste(right_half, (0, 0))
    cross_eye.paste(left_half, (width // 2, 0))
    
    cross_eye.save('cross_eye_version.png')
    print("Cross-eye version saved")
    
    return cross_eye

# Usage
decoded = decode_autostereogram('stereogram.png')
cross_eye = cross_eye_view_decode('stereogram.png')
```

### Hidden Data Extraction from Stereograms

Extract hidden data embedded in depth information:

```python
def extract_depth_data(image_path):
    """
    Extract depth map as data for analysis
    """
    img = Image.open(image_path)
    img_array = np.array(img.convert('L'))
    
    height, width = img_array.shape
    
    # Detect pattern
    middle_row = img_array[height // 2, :]
    autocorr = signal.correlate(middle_row, middle_row, mode='full')
    autocorr = autocorr[len(autocorr)//2:]
    peaks, _ = signal.find_peaks(autocorr[1:], height=np.max(autocorr)*0.5)
    
    if len(peaks) == 0:
        return None
    
    period = peaks[0] + 1
    
    # Extract shift information
    depth_data = []
    
    for row in range(height):
        row_data = img_array[row, :]
        
        # For each position, measure pattern shift
        for col in range(0, width - period * 2, period):
            window1 = row_data[col:col+period]
            window2 = row_data[col+period:col+2*period]
            
            # Find best offset (represents depth)
            max_corr = -np.inf
            best_offset = 0
            
            for offset in range(-period//4, period//4):
                if 0 <= col + offset < width - period:
                    shifted = row_data[col+offset:col+offset+period]
                    corr = np.sum(window1 * shifted)
                    if corr > max_corr:
                        max_corr = corr
                        best_offset = offset
            
            depth_data.append(best_offset)
    
    # Convert depth data to binary
    depth_array = np.array(depth_data)
    binary_data = np.where(depth_array > 0, 1, 0)
    
    print(f"Extracted {len(binary_data)} depth values")
    print(f"Binary sequence (first 100): {''.join(str(b) for b in binary_data[:100])}")
    
    # Try to decode as ASCII
    for i in range(0, len(binary_data) - 7, 8):
        byte_val = 0
        for j in range(8):
            byte_val = (byte_val << 1) | binary_data[i+j]
        
        if 32 <= byte_val < 127:
            print(f"ASCII: {chr(byte_val)}", end='')
    print()
    
    return depth_data

# Usage
depth_data = extract_depth_data('stereogram.png')
```

### Stereogram Analysis with Machine Learning

[Inference] Use machine learning to detect and classify stereograms, though reliability without training data is not guaranteed.

```python
def analyze_stereogram_entropy(image_path):
    """
    Analyze entropy patterns to characterize stereogram type
    """
    from scipy.stats import entropy as scipy_entropy
    
    img = Image.open(image_path)
    img_array = np.array(img.convert('L'))
    
    height, width = img_array.shape
    
    # Calculate entropy in horizontal strips
    strip_height = height // 10
    entropies = []
    
    for i in range(10):
        strip = img_array[i*strip_height:(i+1)*strip_height, :]
        flat = strip.flatten()
        hist, _ = np.histogram(flat, bins=256, range=(0, 256))
        hist = hist / np.sum(hist)  # Normalize
        ent = scipy_entropy(hist)
        entropies.append(ent)
    
    print("Entropy by strip:")
    for i, ent in enumerate(entropies):
        print(f"  Strip {i}: {ent:.3f}")
    
    # Stereograms typically have lower entropy than random images
    avg_entropy = np.mean(entropies)
    print(f"Average entropy: {avg_entropy:.3f}")
    
    if avg_entropy < 5.0:
        print("Likely a structured/stereogram image")
    else:
        print("Likely a random/natural image")
    
    return entropies

def detect_repeating_patterns(image_path):
    """
    Detect repeating patterns using FFT
    """
    img = Image.open(image_path)
    img_array = np.array(img.convert('L'), dtype=np.float32)
    
    # Compute FFT
    fft_result = np.fft.fft2(img_array)
    fft_shifted = np.fft.fftshift(fft_result)
    magnitude = np.abs(fft_shifted)
    
    # Log scale for visualization
    log_magnitude = np.log1p(magnitude)
    
    # Normalize
    normalized = (log_magnitude / log_magnitude.max() * 255).astype(np.uint8)
    
    # Save FFT visualization
    fft_img = Image.fromarray(normalized)
    fft_img.save('fft_analysis.png')
    print("FFT analysis saved to fft_analysis.png")
    
    # Check for strong periodic components
    threshold = np.mean(magnitude) + 2 * np.std(magnitude)
    strong_components = np.sum(magnitude > threshold)
    
    print(f"Strong frequency components: {strong_components}")
    
    return fft_result

# Usage
analyze_stereogram_entropy('stereogram.png')
detect_repeating_patterns('stereogram.png')
```

## QR Code Detection

### QR Code Structure Recognition

QR (Quick Response) codes encode data using a square matrix of black and white modules. The structure includes three position detection patterns (corner squares), timing patterns (alternating lines), and data modules. Version 1 (smallest) is 21x21 modules; larger versions scale up to 177x177 modules.

The format information area contains error correction level and mask pattern. Data is encoded using various schemes (numeric, alphanumeric, byte, kanji) and protected by Reed-Solomon error correction, allowing recovery if up to 30% of the code is damaged.

### Detecting QR Codes in Images

Use OpenCV and `pyzbar` for QR code detection:

```python
import cv2
from pyzbar import pyzbar
import numpy as np
from PIL import Image

def detect_qr_codes(image_path):
    """
    Detect all QR codes in an image
    """
    img = cv2.imread(image_path)
    if img is None:
        print("Cannot read image")
        return []
    
    # Detect QR codes
    qr_codes = pyzbar.decode(img)
    
    print(f"Found {len(qr_codes)} QR code(s)")
    
    results = []
    for i, qr in enumerate(qr_codes):
        # Extract bounding box
        (x, y, w, h) = qr.rect
        print(f"\nQR Code {i+1}:")
        print(f"  Position: ({x}, {y})")
        print(f"  Size: {w}x{h}")
        print(f"  Type: {qr.type}")
        print(f"  Data: {qr.data.decode('utf-8', errors='replace')}")
        
        # Draw bounding box
        cv2.rectangle(img, (x, y), (x+w, y+h), (0, 255, 0), 2)
        
        results.append({
            'data': qr.data.decode('utf-8', errors='replace'),
            'rect': qr.rect,
            'type': qr.type
        })
    
    # Save marked image
    cv2.imwrite('qr_detected.png', img)
    print("\nMarked image saved to qr_detected.png")
    
    return results

def detect_qr_patterns_opencv(image_path):
    """
    Detect QR code position patterns using OpenCV
    """
    img = cv2.imread(image_path, cv2.IMREAD_GRAYSCALE)
    if img is None:
        return
    
    # Threshold image
    _, binary = cv2.threshold(img, 127, 255, cv2.THRESH_BINARY)
    
    # Find contours
    contours, _ = cv2.findContours(binary, cv2.RETR_TREE, cv2.CHAIN_APPROX_SIMPLE)
    
    # Look for square patterns (position detection patterns are square)
    square_candidates = []
    for contour in contours:
        x, y, w, h = cv2.boundingRect(contour)
        
        # Position patterns are roughly square
        if 0.8 < w / h < 1.2 and w > 20:
            square_candidates.append((x, y, w, h))
    
    print(f"Found {len(square_candidates)} square candidates")
    for i, (x, y, w, h) in enumerate(square_candidates[:5]):
        print(f"  Square {i+1}: ({x}, {y}), {w}x{h}")
    
    return square_candidates

# Usage
qr_results = detect_qr_codes('image.png')
squares = detect_qr_patterns_opencv('image.png')
```

### QR Code Data Extraction

Extract and decode QR code data:

```python
def extract_qr_data(image_path):
    """
    Extract all QR code data from image
    """
    img = cv2.imread(image_path)
    qr_codes = pyzbar.decode(img)
    
    extracted_data = []
    
    for qr in qr_codes:
        raw_data = qr.data
        
        # Try different decodings
        for encoding in ['utf-8', 'latin-1', 'cp1252', 'ascii']:
            try:
                decoded = raw_data.decode(encoding)
                extracted_data.append({
                    'raw': raw_data,
                    'decoded': decoded,
                    'encoding': encoding,
                    'type': qr.type
                })
                print(f"Decoded ({encoding}): {decoded[:100]}")
                break
            except:
                pass
    
    return extracted_data

def analyze_qr_data(qr_data):
    """
    Analyze extracted QR code data for hidden information
    """
    if isinstance(qr_data, str):
        decoded = qr_data
    else:
        try:
            decoded = qr_data.decode('utf-8')
        except:
            decoded = qr_data.hex()
    
    print(f"Raw length: {len(qr_data)} bytes")
    print(f"Decoded: {decoded[:200]}")
    
    # Check for URLs
    if 'http://' in decoded or 'https://' in decoded:
        print("URL detected:")
        for part in decoded.split():
            if part.startswith('http'):
                print(f"  {part}")
    
    # Check for base64 encoding
    try:
        import base64
        decoded_b64 = base64.b64decode(decoded)
        print(f"Base64 decoded ({len(decoded_b64)} bytes): {decoded_b64[:100]}")
    except:
        pass
    
    # Check for hex encoding
    if all(c in '0123456789ABCDEFabcdef' for c in decoded):
        hex_decoded = bytes.fromhex(decoded)
        print(f"Hex decoded ({len(hex_decoded)} bytes): {hex_decoded[:100]}")

# Usage
qr_data = extract_qr_data('image.png')
for data in qr_data:
    analyze_qr_data(data['raw'])
```

### Damaged QR Code Recovery

Recover data from partially damaged QR codes using error correction:

```python
def analyze_qr_damage(image_path):
    """
    Analyze QR code damage and error correction capability
    """
    img = cv2.imread(image_path, cv2.IMREAD_GRAYSCALE)
    if img is None:
        return
    
    # Threshold
    _, binary = cv2.threshold(img, 127, 255, cv2.THRESH_BINARY)
    
    # Detect QR boundary
    contours, _ = cv2.findContours(binary, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)
    
    if len(contours) == 0:
        print("No QR code detected")
        return
    
    # Get largest contour (likely the QR code)
    largest = max(contours, key=cv2.contourArea)
    x, y, w, h = cv2.boundingRect(largest)
    
    qr_region = binary[y:y+h, x:x+w]
    
    # Calculate damage ratio
    total_pixels = qr_region.size
    white_pixels = np.count_nonzero(qr_region)
    black_pixels = total_pixels - white_pixels
    
    print(f"QR Code region: {w}x{h}")
    print(f"Black pixels: {black_pixels} ({100*black_pixels/total_pixels:.1f}%)")
    print(f"White pixels: {white_pixels} ({100*white_pixels/total_pixels:.1f}%)")
    
    # For QR codes, approximately 50% should be black
    damage_indicator = abs(0.5 - (black_pixels / total_pixels))
    print(f"Damage indicator: {damage_indicator:.3f}")
    
    if damage_indicator > 0.2:
        print("Significant damage detected - error correction may be needed")

def enhance_damaged_qr(image_path):
    """
    Apply enhancement to make damaged QR codes more readable
    """
    img = cv2.imread(image_path, cv2.IMREAD_GRAYSCALE)
    if img is None:
        return
    
    # Apply CLAHE (Contrast Limited Adaptive Histogram Equalization)
    clahe = cv2.createCLAHE(clipLimit=2.0, tileGridSize=(8,8))
    enhanced = clahe.apply(img)
    
    # Apply morphological operations
    kernel = cv2.getStructuringElement(cv2.MORPH_RECT, (3,3))
    cleaned = cv2.morphologyEx(enhanced, cv2.MORPH_CLOSE, kernel)
    cleaned = cv2.morphologyEx(cleaned, cv2.MORPH_OPEN, kernel)
    
    # Sharpen
    kernel_sharpen = np.array([[-1,-1,-1],
                              [-1, 9,-1],
                              [-1,-1,-1]])
    sharpened = cv2.filter2D(cleaned, -1, kernel_sharpen)
    
    cv2.imwrite('qr_enhanced.png', sharpened)
    print("Enhanced QR code saved to qr_enhanced.png")
    
    # Try to decode enhanced version
    img_pil = Image.open('qr_enhanced.png')
    qr_codes = pyzbar.decode(img_pil)
    
    if qr_codes:
        print(f"Successfully decoded enhanced QR: {qr_codes[0].data.decode('utf-8', errors='replace')}")
    else:
        print("Still unable to decode enhanced QR")
    
    return sharpened

# Usage
analyze_qr_damage('damaged_qr.png')
enhance_damaged_qr('damaged_qr.png')
```

## Barcode Reading

### Barcode Format Detection

Barcodes encode data in patterns of vertical bars with varying widths. Common types include Code128 (alphanumeric), Code39 (alphanumeric with special chars), EAN (numeric only), and UPC (numeric only). Each format has specific encoding rules and check digit calculations.

```python
def detect_barcodes(image_path):
    """
    Detect all barcodes in an image
    """
    from pyzbar import pyzbar
    
    img = cv2.imread(image_path)
    if img is None:
        return []
    
    barcodes = pyzbar.decode(img)
    
    print(f"Found {len(barcodes)} barcode(s)")
    
    results = []
    for i, barcode in enumerate(barcodes):
        (x, y, w, h) = barcode.rect
        
        print(f"\nBarcode {i+1}:")
        print(f"  Type: {barcode.type}")
        print(f"  Data: {barcode.data.decode('utf-8', errors='replace')}")
        print(f"  Position: ({x}, {y}), Size: {w}x{h}")
        
        # Draw bounding box
        cv2.rectangle(img, (x, y), (x+w, y+h), (0, 255, 0), 2)
        cv2.putText(img, barcode.type, (x, y-10), cv2.FONT_HERSHEY_SIMPLEX, 0.5, (0, 255, 0), 2)
        
        results.append({
            'type': barcode.type,
            'data': barcode.data.decode('utf-8', errors='replace'),
            'rect': barcode.rect
        })
    
    cv2.imwrite('barcodes_detected.png', img)
    print("\nMarked image saved to barcodes_detected.png")
    
    return results

def analyze_barcode_patterns(image_path):
    """
    Detect barcode position and analyze bar patterns
    """
    img = cv2.imread(image_path, cv2.IMREAD_GRAYSCALE)
    if img is None:
        return
    
    # Detect vertical edges (bars run vertically)
    sobelx = cv2.Sobel(img, cv2.CV_64F, 1, 0, ksize=3)
    abs_sobelx = np.absolute(sobelx)
    scaled_sx = np.uint8(255 * abs_sobelx / np.max(abs_sobelx))
    
    # Threshold to find strong vertical edges
    _, barcode_candidates = cv2.threshold(scaled_sx, 127, 255, cv2.THRESH_BINARY)
    
    # Find contours of bar regions
    contours, _ = cv2.findContours(barcode_candidates, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)
    
    # Look for elongated rectangles (typical barcode shape)
    barcode_regions = []
    for contour in contours:
        x, y, w, h = cv2.boundingRect(contour)
        
        # Barcodes are elongated vertically
        if h > 2 * w and h > 50:
            barcode_regions.append((x, y, w, h))
    
    print(f"Found {len(barcode_regions)} potential barcode region(s)")
    for i, (x, y, w, h) in enumerate(barcode_regions):
        print(f"  Barcode {i+1}: ({x}, {y}), {w}x{h}")
    
    return barcode_regions

# Usage
barcodes = detect_barcodes('barcode_image.png')
regions = analyze_barcode_patterns('barcode_image.png')
```

### Barcode Data Extraction

Extract and decode barcode data:

```python
def extract_barcode_data(image_path):
    """
    Extract all barcode data from image
    """
    from pyzbar import pyzbar
    
    img = cv2.imread(image_path)
    barcodes = pyzbar.decode(img)
    
    extracted = []
    for barcode in barcodes:
        data = barcode.data.decode('utf-8', errors='replace')
        
        print(f"Type: {barcode.type}")
        print(f"Data: {data}")
        print(f"Raw (hex): {barcode.data.hex()}")
        
        # Analyze data
        if barcode.type.startswith('EAN') or barcode.type.startswith('UPC'):
            validate_ean_upc(data)
        elif barcode.type == 'CODE128':
            analyze_code128(data)
        
        extracted.append({
            'type': barcode.type,
            'data': data,
            'raw': barcode.data
        })
    
    return extracted

def validate_ean_upc(code):
    """
    Validate EAN/UPC barcode with check digit
    """
    # Remove check digit for validation
    if len(code) in [12, 13, 14]:
        digits = code[:-1]
        check_digit = int(code[-1])
        
        # Calculate check digit
        total = 0
        for i, digit in enumerate(reversed(digits)):
            weight = 3 if i % 2 == 0 else 1
            total += int(digit) * weight
        
        calculated = (10 - (total % 10)) % 10
        
        if calculated == check_digit:
            print(f"✓ Valid EAN/UPC")
        else:
            print(f"✗ Invalid EAN/UPC (calculated check digit: {calculated})")

def analyze_code128(code):
    """
    Analyze Code128 barcode encoding
    """
    # Code128 can encode various character sets
    has_uppercase = any(c.isupper() for c in code)
    has_lowercase = any(c.islower() for c in code)
    has_special = any(not c.isalnum() for c in code)
    
    print(f"Encoding: ", end="")
    if has_special:
        print("Code128C (special chars), ", end="")
    if has_lowercase:
        print("Code128B (lowercase), ", end="")
    if has_uppercase:
        print("Code128A (uppercase), ", end="")
    print()

# Usage
extracted = extract_barcode_data('barcode_image.png')
```

### Damaged Barcode Recovery

Recover data from partially damaged or rotated barcodes:

```python
def enhance_barcode_for_reading(image_path):
    """
    Apply enhancement techniques to improve barcode readability
    """
    img = cv2.imread(image_path, cv2.IMREAD_GRAYSCALE)
    if img is None:
        return
    
    # Try multiple enhancement techniques
    enhancements = {}
    
    # 1. Contrast stretching
    enhanced1 = cv2.equalizeHist(img)
    
    # 2
```



---

# Audio Steganography

## Audio File Formats

### WAV Analysis

#### WAV File Structure Fundamentals

WAV (Waveform Audio File Format) files use the RIFF (Resource Interchange File Format) container structure, identical to AVI and WebP at the container level. The file begins with the "RIFF" signature (4 bytes `52 49 46 46`), followed by a 4-byte file size field (little-endian, excluding the first 8 bytes), and the format identifier "WAVE" (4 bytes). The structure is divided into chunks, each with a 4-byte FourCC identifier, 4-byte size (little-endian), and chunk data padded to even byte boundaries.

Essential chunks include fmt (format description, mandatory), data (audio samples, mandatory), and fact (sample count, optional). Additional chunks like LIST, INFO, and custom application-specific chunks can embed metadata and hidden data. WAV files are uncompressed by default, making them ideal for LSB steganography. The fmt chunk specifies audio format (PCM, IEEE float, etc.), sample rate, bit depth, and channel count.

#### Parsing WAV Header and Structure

Extract WAV header information:

```bash
xxd -l 44 filename.wav
```

Parse WAV structure programmatically:

```python
import struct

def parse_wav(filename):
    with open(filename, 'rb') as f:
        ## Parse RIFF header
        riff = f.read(4)
        if riff != b'RIFF':
            print("Not a RIFF file")
            return
        
        file_size = struct.unpack('<I', f.read(4))[0]
        wave = f.read(4)
        if wave != b'WAVE':
            print("Not a WAV file")
            return
        
        print(f"WAV file size: {file_size + 8} bytes")
        
        ## Parse chunks
        chunks = {}
        while f.tell() < file_size + 8:
            chunk_header = f.read(8)
            if len(chunk_header) < 8:
                break
            
            fourcc = chunk_header[:4].decode('ascii', errors='replace')
            chunk_size = struct.unpack('<I', chunk_header[4:8])[0]
            chunk_data = f.read(chunk_size)
            chunks[fourcc] = chunk_data
            
            print(f"Chunk: {fourcc}, Size: {chunk_size}")
            
            if fourcc == 'fmt ':
                audio_format = struct.unpack('<H', chunk_data[0:2])[0]
                channels = struct.unpack('<H', chunk_data[2:4])[0]
                sample_rate = struct.unpack('<I', chunk_data[4:8])[0]
                byte_rate = struct.unpack('<I', chunk_data[8:12])[0]
                block_align = struct.unpack('<H', chunk_data[12:14])[0]
                bits_per_sample = struct.unpack('<H', chunk_data[14:16])[0]
                
                print(f"  Format: {audio_format} (1=PCM, 3=IEEE float)")
                print(f"  Channels: {channels}")
                print(f"  Sample rate: {sample_rate} Hz")
                print(f"  Bits per sample: {bits_per_sample}")
            
            elif fourcc == 'data':
                print(f"  Audio data size: {chunk_size} bytes")
            
            ## Chunks are padded to even boundaries
            if chunk_size % 2 == 1:
                f.read(1)
        
        return chunks

parse_wav('filename.wav')
```

Use `ffprobe` for comprehensive WAV analysis:

```bash
ffprobe -show_format -show_streams filename.wav
ffprobe -v error -select_streams a:0 -show_entries stream=codec_type,codec_name,sample_rate,channels,duration -of default=noprint_wrappers=1:nokey=1:noprint_wrappers=1 filename.wav
```

Analyze WAV file properties with `sox`:

```bash
sox filename.wav -n stat
sox filename.wav -n spectrogram -o spectrogram.png
```

#### WAV Metadata Extraction

Extract and analyze LIST chunks (contain metadata):

```python
def extract_wav_metadata(filename):
    with open(filename, 'rb') as f:
        f.seek(12)  ## Skip RIFF header
        
        while True:
            chunk_header = f.read(8)
            if len(chunk_header) < 8:
                break
            
            fourcc = chunk_header[:4]
            chunk_size = struct.unpack('<I', chunk_header[4:8])[0]
            chunk_data = f.read(chunk_size)
            
            if fourcc == b'LIST':
                list_type = chunk_data[:4]
                print(f"LIST type: {list_type}")
                
                ## Parse INFO subchunks
                if list_type == b'INFO':
                    pos = 4
                    while pos < len(chunk_data):
                        if pos + 8 > len(chunk_data):
                            break
                        
                        info_tag = chunk_data[pos:pos+4]
                        info_size = struct.unpack('<I', chunk_data[pos+4:pos+8])[0]
                        info_data = chunk_data[pos+8:pos+8+info_size]
                        
                        tag_name = {
                            b'IART': 'Artist',
                            b'INAM': 'Title',
                            b'ICOM': 'Comment',
                            b'ICRD': 'Creation Date',
                            b'ISFT': 'Software'
                        }.get(info_tag, info_tag.decode('ascii', errors='replace'))
                        
                        print(f"  {tag_name}: {info_data.decode('utf-8', errors='replace').rstrip(chr(0))}")
                        
                        pos += 8 + info_size
                        if info_size % 2 == 1:
                            pos += 1
            
            elif fourcc == b'ID3 ':
                print(f"ID3 chunk found: {chunk_data[:4]}")
            
            if chunk_size % 2 == 1:
                f.read(1)

extract_wav_metadata('filename.wav')
```

Extract metadata using `exiftool`:

```bash
exiftool filename.wav
exiftool -a filename.wav
```

#### WAV Steganography and Hidden Data Detection

Extract audio samples and perform LSB analysis:

```python
import numpy as np
import struct

def extract_wav_samples(filename):
    with open(filename, 'rb') as f:
        ## Skip RIFF header
        f.seek(12)
        
        fmt_data = None
        data_offset = None
        data_size = None
        
        ## Find fmt and data chunks
        while True:
            chunk_header = f.read(8)
            if len(chunk_header) < 8:
                break
            
            fourcc = chunk_header[:4]
            chunk_size = struct.unpack('<I', chunk_header[4:8])[0]
            
            if fourcc == b'fmt ':
                fmt_data = f.read(chunk_size)
            elif fourcc == b'data':
                data_offset = f.tell()
                data_size = chunk_size
                break
            else:
                f.seek(f.tell() + chunk_size)
            
            if chunk_size % 2 == 1:
                f.seek(f.tell() + 1)
        
        if fmt_data and data_offset:
            ## Parse format
            channels = struct.unpack('<H', fmt_data[2:4])[0]
            sample_rate = struct.unpack('<I', fmt_data[4:8])[0]
            bits_per_sample = struct.unpack('<H', fmt_data[14:16])[0]
            
            print(f"Channels: {channels}")
            print(f"Sample rate: {sample_rate}")
            print(f"Bits per sample: {bits_per_sample}")
            
            ## Extract audio data
            f.seek(data_offset)
            audio_data = f.read(data_size)
            
            ## Parse samples based on bit depth
            if bits_per_sample == 16:
                samples = np.frombuffer(audio_data, dtype=np.int16)
            elif bits_per_sample == 24:
                samples = np.zeros(len(audio_data) // 3, dtype=np.int32)
                for i in range(len(samples)):
                    byte1 = audio_data[i*3]
                    byte2 = audio_data[i*3+1]
                    byte3 = audio_data[i*3+2]
                    samples[i] = (byte3 << 16) | (byte2 << 8) | byte1
            elif bits_per_sample == 32:
                samples = np.frombuffer(audio_data, dtype=np.int32)
            elif bits_per_sample == 8:
                samples = np.frombuffer(audio_data, dtype=np.uint8)
            
            return samples, sample_rate, channels
    
    return None, None, None

## Extract LSBs from audio samples
samples, sample_rate, channels = extract_wav_samples('filename.wav')
if samples is not None:
    lsb_data = samples & 1
    print(f"Total samples: {len(samples)}")
    print(f"LSB sequence (first 100): {''.join(str(bit) for bit in lsb_data[:100])}")
    
    ## Extract LSB as bytes
    lsb_bytes = bytearray()
    for i in range(0, len(lsb_data) - 7, 8):
        byte_val = 0
        for j in range(8):
            byte_val = (byte_val << 1) | lsb_data[i+j]
        lsb_bytes.append(byte_val)
    
    print(f"LSB data: {lsb_bytes[:50]}")
    print(f"LSB data (ASCII): {bytes(lsb_bytes).decode('utf-8', errors='replace')}")
```

Analyze specific bit planes for hidden patterns:

```python
def analyze_wav_bitplanes(filename):
    samples, sample_rate, channels = extract_wav_samples(filename)
    
    if samples is None:
        return
    
    ## Analyze each bit plane
    for bit in range(min(16, samples.dtype.itemsize * 8)):
        bit_plane = (samples >> bit) & 1
        ones = np.sum(bit_plane)
        zeros = len(bit_plane) - ones
        
        ## Chi-squared test for randomness
        expected = len(bit_plane) / 2
        chi_sq = ((ones - expected) ** 2 + (zeros - expected) ** 2) / expected
        
        print(f"Bit {bit}: 1s={ones}, 0s={zeros}, χ²={chi_sq:.2f}")
        
        ## If distribution is suspicious, extract the bit plane
        if chi_sq > 100:
            print(f"  Anomaly detected at bit {bit}")

analyze_wav_bitplanes('filename.wav')
```

Detect steganography tools:

```bash
steghide info filename.wav
steghide extract -sf filename.wav -xf output.txt -p ""
```

Check for hidden data in WAV padding and metadata:

```python
def find_hidden_data_in_wav(filename):
    with open(filename, 'rb') as f:
        data = f.read()
    
    ## Find all chunks
    pos = 12
    hidden_chunks = []
    while pos < len(data):
        if pos + 8 > len(data):
            break
        
        fourcc = data[pos:pos+4]
        try:
            chunk_size = struct.unpack('<I', data[pos+4:pos+8])[0]
        except:
            break
        
        ## Check for unknown/suspicious chunks
        if fourcc[0] < 0x20 or fourcc[0] > 0x7E:
            print(f"Binary chunk at {hex(pos)}: {fourcc.hex()}, size: {chunk_size}")
            hidden_chunks.append((pos, chunk_size, data[pos+8:pos+8+chunk_size]))
        elif fourcc not in [b'fmt ', b'data', b'LIST', b'JUNK', b'PAD ', b'FACT']:
            print(f"Unusual chunk at {hex(pos)}: {fourcc}, size: {chunk_size}")
            hidden_chunks.append((pos, chunk_size, data[pos+8:pos+8+chunk_size]))
        
        pos += 8 + chunk_size
        if chunk_size % 2 == 1:
            pos += 1
    
    return hidden_chunks

hidden = find_hidden_data_in_wav('filename.wav')
for offset, size, content in hidden:
    print(f"Offset {hex(offset)}: {content[:50]}")
```

### MP3 Structure

#### MP3 Frame Format and ID3 Tags

MP3 (MPEG-1 Audio Layer III) files consist of frames preceded by optional ID3 tags. The ID3v2 tag (if present) appears at the file's beginning with the signature `49 44 33` (ASCII "ID3"), version information (2 bytes), flags (1 byte), and a 4-byte size field using synchsafe integers (7 bits per byte to avoid false sync markers). Each frame begins with a sync word (11 bits of 1s, `FF FB` or `FF FA` in hex, where the last bits indicate MPEG version and layer).

MP3 frames contain a 4-byte header (or variable-length header in some cases) followed by optional CRC (2 bytes), side information, and encoded audio data. Between frames, optional ancillary data, padding, or custom data can exist. ID3v1 tags (128 bytes) appear at the file's end with the signature `54 41 47` (ASCII "TAG").

#### Parsing MP3 ID3 Tags

Extract ID3v2 tags:

```python
import struct

def parse_id3v2(filename):
    with open(filename, 'rb') as f:
        header = f.read(10)
        
        if header[:3] != b'ID3':
            print("No ID3v2 tag found")
            return
        
        version_major = header[3]
        version_minor = header[4]
        flags = header[5]
        
        ## Synchsafe size (7 bits per byte)
        size_bytes = header[6:10]
        tag_size = (
            (size_bytes[0] << 21) | (size_bytes[1] << 14) |
            (size_bytes[2] << 7) | size_bytes[3]
        )
        
        print(f"ID3 version: {version_major}.{version_minor}")
        print(f"Tag size: {tag_size} bytes")
        print(f"Flags: {bin(flags)}")
        
        tag_data = f.read(tag_size)
        
        ## Parse frames within tag
        pos = 0
        while pos < len(tag_data) - 10:
            frame_id = tag_data[pos:pos+4].decode('ascii', errors='replace')
            if frame_id[0] == '\x00':  ## Padding
                break
            
            frame_size = struct.unpack('>I', tag_data[pos+4:pos+8])[0]
            frame_flags = struct.unpack('>H', tag_data[pos+8:pos+10])[0]
            frame_data = tag_data[pos+10:pos+10+frame_size]
            
            print(f"\nFrame: {frame_id}, Size: {frame_size}")
            print(f"  Data: {frame_data[:100]}")
            
            pos += 10 + frame_size

parse_id3v2('filename.mp3')
```

Extract ID3v1 tags (fixed 128-byte structure at end):

```python
def parse_id3v1(filename):
    with open(filename, 'rb') as f:
        f.seek(-128, 2)  ## Seek to 128 bytes before end
        tag = f.read(128)
        
        if tag[:3] != b'TAG':
            print("No ID3v1 tag found")
            return
        
        title = tag[3:33].decode('utf-8', errors='replace').rstrip('\x00')
        artist = tag[33:63].decode('utf-8', errors='replace').rstrip('\x00')
        album = tag[63:93].decode('utf-8', errors='replace').rstrip('\x00')
        year = tag[93:97].decode('utf-8', errors='replace').rstrip('\x00')
        comment = tag[97:127].decode('utf-8', errors='replace').rstrip('\x00')
        genre = tag[127]
        
        print(f"Title: {title}")
        print(f"Artist: {artist}")
        print(f"Album: {album}")
        print(f"Year: {year}")
        print(f"Comment: {comment}")
        print(f"Genre: {genre}")

parse_id3v1('filename.mp3')
```

Use `exiftool` for comprehensive ID3 extraction:

```bash
exiftool filename.mp3
exiftool -a filename.mp3
```

Extract raw ID3 tag data:

```bash
xxd -s 0 -l 256 filename.mp3
```

#### MP3 Frame Analysis

Parse MP3 frame headers:

```python
def parse_mp3_frames(filename, max_frames=10):
    with open(filename, 'rb') as f:
        ## Skip ID3 tag if present
        header = f.read(10)
        if header[:3] == b'ID3':
            version_major = header[3]
            size_bytes = header[6:10]
            tag_size = (
                (size_bytes[0] << 21) | (size_bytes[1] << 14) |
                (size_bytes[2] << 7) | size_bytes[3]
            )
            f.seek(tag_size + 10)
        else:
            f.seek(0)
        
        frame_count = 0
        while frame_count < max_frames:
            frame_header = f.read(4)
            if len(frame_header) < 4:
                break
            
            ## Check for sync marker (11 bits of 1s)
            if (frame_header[0] == 0xFF and (frame_header[1] & 0xE0) == 0xE0):
                ## Parse frame header
                mpeg_version = (frame_header[1] >> 3) & 0x03
                layer = (frame_header[1] >> 1) & 0x03
                protection_bit = frame_header[1] & 0x01
                bitrate_index = (frame_header[2] >> 4) & 0x0F
                sample_rate_index = (frame_header[2] >> 2) & 0x03
                padding = (frame_header[2] >> 1) & 0x01
                private_bit = frame_header[2] & 0x01
                
                channel_mode = (frame_header[3] >> 6) & 0x03
                mode_extension = (frame_header[3] >> 4) & 0x03
                copyright = (frame_header[3] >> 3) & 0x01
                original = (frame_header[3] >> 2) & 0x01
                emphasis = frame_header[3] & 0x03
                
                mpeg_names = ['MPEG 2.5', 'Reserved', 'MPEG 2', 'MPEG 1']
                layer_names = ['Reserved', 'Layer III', 'Layer II', 'Layer I']
                
                print(f"\nFrame {frame_count}: MPEG={mpeg_names[mpeg_version]}, Layer={layer_names[layer]}")
                print(f"  Bitrate index: {bitrate_index}, Sample rate index: {sample_rate_index}")
                print(f"  Padding: {padding}, Private: {private_bit}")
                print(f"  Channels: {channel_mode}, Copyright: {copyright}")
                
                frame_count += 1
                
                ## Estimate frame size and skip to next frame
                ## (requires bitrate and sample rate lookup tables)
                f.seek(f.tell() + 100)  ## Simplified skip
            else:
                f.seek(f.tell() + 1)

parse_mp3_frames('filename.mp3')
```

#### MP3 Steganography Detection

Extract ID3 frame content for hidden data:

```python
def extract_id3_frame_content(filename, frame_id):
    with open(filename, 'rb') as f:
        header = f.read(10)
        
        if header[:3] != b'ID3':
            return None
        
        version_major = header[3]
        size_bytes = header[6:10]
        tag_size = (
            (size_bytes[0] << 21) | (size_bytes[1] << 14) |
            (size_bytes[2] << 7) | size_bytes[3]
        )
        
        tag_data = f.read(tag_size)
        
        pos = 0
        while pos < len(tag_data) - 10:
            current_frame_id = tag_data[pos:pos+4].decode('ascii', errors='replace')
            frame_size = struct.unpack('>I', tag_data[pos+4:pos+8])[0]
            frame_data = tag_data[pos+10:pos+10+frame_size]
            
            if current_frame_id == frame_id:
                return frame_data
            
            pos += 10 + frame_size
    
    return None

## Extract common frames
txxx_data = extract_id3_frame_content('filename.mp3', 'TXXX')
if txxx_data:
    print(f"TXXX frame: {txxx_data}")

comm_data = extract_id3_frame_content('filename.mp3', 'COMM')
if comm_data:
    print(f"COMM frame: {comm_data}")
```

Detect steganography tools:

```bash
steghide info filename.mp3
steghide extract -sf filename.mp3 -xf output.txt -p ""
```

Analyze MP3 for LSB steganography in audio frames:

```python
import wave
import numpy as np

def extract_mp3_to_wav_then_analyze(mp3_file):
    ## First convert MP3 to WAV (requires ffmpeg)
    import subprocess
    wav_file = mp3_file.replace('.mp3', '.wav')
    subprocess.run(['ffmpeg', '-i', mp3_file, wav_file, '-y'], 
                   capture_output=True)
    
    ## Then analyze WAV for LSB
    with wave.open(wav_file, 'rb') as wav:
        frames = wav.readframes(wav.getnframes())
        samples = np.frombuffer(frames, dtype=np.int16)
        
        lsb_data = samples & 1
        lsb_bytes = bytearray()
        for i in range(0, len(lsb_data) - 7, 8):
            byte_val = 0
            for j in range(8):
                byte_val = (byte_val << 1) | lsb_data[i+j]
            lsb_bytes.append(byte_val)
        
        print(f"LSB data: {bytes(lsb_bytes[:100])}")

extract_mp3_to_wav_then_analyze('filename.mp3')
```

### FLAC Format

#### FLAC File Structure

FLAC (Free Lossless Audio Codec) begins with the 4-byte signature `66 4C 61 43` (ASCII "fLaC"), followed by metadata blocks and audio frames. Metadata blocks have a 1-byte header (last bit indicates if more metadata blocks follow, upper 7 bits specify block type), a 3-byte length field, and block data. Block type 0 is STREAMINFO (mandatory, always first), followed by optional types: PADDING (1), APPLICATION (2), SEEKTABLE (3), VORBIS_COMMENT (4), CUESHEET (5), PICTURE (6).

Audio frames begin with the sync code `FF FC` or `FF FD`, followed by frame header information and FLAC-specific encoded audio data. VORBIS_COMMENT blocks (type 4) store metadata in key-value pairs similar to Vorbis comments and are commonly exploited for steganography.

#### Parsing FLAC Metadata

Extract and parse FLAC metadata blocks:

```python
def parse_flac(filename):
    with open(filename, 'rb') as f:
        ## Check signature
        signature = f.read(4)
        if signature != b'fLaC':
            print("Not a FLAC file")
            return
        
        print("FLAC file detected")
        
        ## Parse metadata blocks
        last_block = False
        block_count = 0
        while not last_block:
            block_header = f.read(1)
            if len(block_header) < 1:
                break
            
            last_block = bool(block_header[0] & 0x80)
            block_type = block_header[0] & 0x7F
            
            ## Read block length (24-bit big-endian)
            length_bytes = f.read(3)
            block_length = (length_bytes[0] << 16) | (length_bytes[1] << 8) | length_bytes[2]
            
            block_data = f.read(block_length)
            
            block_type_names = {
                0: 'STREAMINFO',
                1: 'PADDING',
                2: 'APPLICATION',
                3: 'SEEKTABLE',
                4: 'VORBIS_COMMENT',
                5: 'CUESHEET',
                6: 'PICTURE'
            }
            
            block_name = block_type_names.get(block_type, f'Unknown({block_type})')
            print(f"\nBlock {block_count}: {block_name}, Length: {block_length}")
            
            if block_type == 0:  ## STREAMINFO
                min_blocksize = struct.unpack('>H', block_data[0:2])[0]
                max_blocksize = struct.unpack('>H', block_data[2:4])[0]
                min_framesize = (block_data[4] << 16) | (block_data[5] << 8) | block_data[6]
                max_framesize = (block_data[7] << 16) | (block_data[8] << 8) | block_data[9]
                sample_rate = ((block_data[10] << 12) | (block_data[11] << 4) | 
                              ((block_data[12] >> 4) & 0x0F))
                channels = ((block_data[12] & 0x0F) >> 1) + 1
                bits_per_sample = ((block_data[12] & 0x01) << 4) | (block_data[13] >> 4)
                bits_per_sample += 1
                
                print(f"  Sample rate: {sample_rate} Hz")
                print(f"  Channels: {channels}")
                print(f"  Bits per sample: {bits_per_sample}")
            
            elif block_type == 4:  ## VORBIS_COMMENT
                parse_vorbis_comment(block_data)
            
            elif block_type == 6:  ## PICTURE
                print(f"  Picture block: {len(block_data)} bytes")
            
            block_count += 1

def parse_vorbis_comment(data):
    pos = 0
    vendor_len = struct.unpack('<I', data[pos:pos+4])[0]
    pos += 4
    vendor = data[pos:pos+vendor_len].decode('utf-8', errors='replace')
    print(f"  Vendor: {vendor}")
    pos += vendor_len
    
    comment_count = struct.unpack('<I', data[pos:pos+4])[0]
    pos += 4
    print(f"  Comments: {comment_count}")
    
    for i in range(comment_count):
        if pos + 4 > len(data):
            break
        
        comment_len = struct.unpack('<I', data[pos:pos+4])[0]
        pos += 4
        comment = data[pos:pos+comment_len].decode('utf-8', errors='replace')
        print(f"    {i+1}. {comment[:100]}")
        pos += comment_len

parse_flac('filename.flac')
```

Use `metaflac` for FLAC analysis:

```bash
metaflac --list filename.flac
metaflac --show-md5sum filename.flac
```

Extract specific metadata:

```bash
metaflac --export-tags filename.flac
metaflac --export-picture-to=picture.png filename.flac
```

#### FLAC Steganography Analysis

Extract and analyze Vorbis comments for hidden data:

```python
def extract_flac_vorbis_comments(filename):
    with open(filename, 'rb') as f:
        f.seek(4)  ## Skip fLaC signature
        
        last_block = False
        while not last_block:
            block_header = f.read(1)
            last_block = bool(block_header[0] & 0x80)
            block_type = block_header[0] & 0x7F
            
            length_bytes = f.read(3)
            block_length = (length_bytes[0] << 16) | (length_bytes[1] << 8) | length_bytes[2]
            
            if block_type == 4:  ## VORBIS_COMMENT
                block_data = f.read(block_length)
                pos = 0
                vendor_len = struct.unpack('<I', block_data[pos:pos+4])[0]
                pos += 4 + vendor_len
                
                comment_count = struct.unpack('<I', block_data[pos:pos+4])[0]
                pos += 4
                
                comments = {}
                for _ in range(comment_count):
                    comment_len = struct.unpack('<I', block_data[pos:pos+4])[0]
                    pos += 4
                    comment = block_data[pos:pos+comment_len].decode('utf-8', errors='replace')
                    pos += comment_len
                    
                    if '=' in comment:
                        key, value = comment.split('=', 1)
                        comments[key] = value
                
                return comments
            else:
                f.seek(f.tell() + block_length)
    
    return None

comments = extract_flac_vorbis_comments('filename.flac')
if comments:
    for key, value in comments.items():
        print(f"{key}: {value[:100]}")
```

Extract embedded pictures from FLAC:

```python
def extract_flac_pictures(filename):
    with open(filename, 'rb') as f:
        f.seek(4)
        
        last_block = False
        picture_count = 0
        while not last_block:
            block_header = f.read(1)
            last_block = bool(block_header[0] & 0x80)
            block_type = block_header[0] & 0x7F
            
            length_bytes = f.read(3)
            block_length = (length_bytes[0] << 16) | (length_bytes[1] << 8) | length_bytes[2]
            block_data = f.read(block_length)
            
            if block_type == 6:  ## PICTURE
                picture_type = struct.unpack('>I', block_data[0:4])[0] mime_len = struct.unpack('>I', block_data[4:8])[0] mime_type = block_data[8:8+mime_len].decode('utf-8', errors='replace') desc_len = struct.unpack('>I', block_data[8+mime_len:12+mime_len])[0] description = block_data[12+mime_len:12+mime_len+desc_len].decode('utf-8', errors='replace')

            width = struct.unpack('>I', block_data[12+mime_len+desc_len:16+mime_len+desc_len])[0]
            height = struct.unpack('>I', block_data[16+mime_len+desc_len:20+mime_len+desc_len])[0]
            
            pic_len = struct.unpack('>I', block_data[32+mime_len+desc_len:36+mime_len+desc_len])[0]
            picture_data = block_data[36+mime_len+desc_len:36+mime_len+desc_len+pic_len]
            
            print(f"Picture {picture_count}: {mime_type}, {width}x{height}, {pic_len} bytes")
            print(f"  Description: {description}")
            
            # Save picture
            output_file = f'picture_{picture_count}_{mime_type.split("/")[1]}'
            with open(output_file, 'wb') as out:
                out.write(picture_data)
            print(f"  Saved to: {output_file}")
            
            picture_count += 1

extract_flac_pictures('filename.flac')
````

Analyze FLAC padding blocks for hidden data:

```python
def extract_flac_padding(filename):
    with open(filename, 'rb') as f:
        f.seek(4)
        
        last_block = False
        while not last_block:
            block_header = f.read(1)
            last_block = bool(block_header[0] & 0x80)
            block_type = block_header[0] & 0x7F
            
            length_bytes = f.read(3)
            block_length = (length_bytes[0] << 16) | (length_bytes[1] << 8) | length_bytes[2]
            
            if block_type == 1:  # PADDING
                padding_data = f.read(block_length)
                print(f"PADDING block: {block_length} bytes")
                
                # Check for patterns in padding
                if padding_data != b'\x00' * block_length:
                    print(f"  Non-zero padding detected!")
                    print(f"  Data: {padding_data[:100].hex()}")
                    
                    # Try to decode as text
                    try:
                        text = padding_data.decode('utf-8', errors='replace')
                        print(f"  As text: {text[:100]}")
                    except:
                        pass
            else:
                f.seek(f.tell() + block_length)

extract_flac_padding('filename.flac')
````

Extract FLAC audio and analyze for LSB steganography:

```bash
ffmpeg -i filename.flac -f wav - | xxd | head -20
```

Then analyze the converted WAV using LSB extraction techniques from the WAV section.

Detect steganography tools in FLAC:

```bash
steghide info filename.flac
steghide extract -sf filename.flac -xf output.txt -p ""
```

### OGG Vorbis

#### OGG Container Structure

OGG is a framing format for various codecs (Vorbis, Theora, Flac, Opus). OGG Vorbis files consist of pages, each beginning with the 4-byte signature `4F 67 67 53` (ASCII "OggS"), followed by version (1 byte), page type flags (1 byte), absolute granule position (8 bytes), serial number (4 bytes), page sequence number (4 bytes), checksum (4 bytes), and page segment table. Each page contains segments (data units) that can be partial frames.

The first page contains identification and comment headers. Vorbis comments (similar to Flac's Vorbis comments) store metadata in key-value pairs. These can be extensively exploited for data hiding due to their variable length nature.

#### Parsing OGG Vorbis Structure

Extract and parse OGG pages:

```python
def parse_ogg_vorbis(filename):
    with open(filename, 'rb') as f:
        page_count = 0
        while True:
            ## Read OGG page header
            oggs = f.read(4)
            if oggs != b'OggS':
                break
            
            version = f.read(1)[0]
            page_type = f.read(1)[0]
            granule_pos = struct.unpack('<Q', f.read(8))[0]
            serial_num = struct.unpack('<I', f.read(4))[0]
            seq_num = struct.unpack('<I', f.read(4))[0]
            checksum = struct.unpack('<I', f.read(4))[0]
            page_segments = f.read(1)[0]
            
            segment_table = f.read(page_segments)
            total_segment_size = sum(segment_table)
            
            page_data = f.read(total_segment_size)
            
            print(f"\nPage {page_count}")
            print(f"  Type: {page_type}, Serial: {serial_num}, Seq: {seq_num}")
            print(f"  Granule pos: {granule_pos}")
            print(f"  Segments: {page_segments}, Total size: {total_segment_size}")
            
            ## First page contains identification header
            if page_count == 0 or (page_type & 0x02):
                print(f"  Header page detected")
                if page_data[:7] == b'\x01vorbis':
                    print(f"  Vorbis identification header")
                    channels = page_data[11]
                    sample_rate = struct.unpack('<I', page_data[12:16])[0]
                    print(f"    Channels: {channels}, Sample rate: {sample_rate}")
                
                elif page_data[:7] == b'\x03vorbis':
                    print(f"  Vorbis comment header")
                    parse_vorbis_comments_ogg(page_data[7:])
            
            page_count += 1

def parse_vorbis_comments_ogg(data):
    pos = 0
    vendor_len = struct.unpack('<I', data[pos:pos+4])[0]
    pos += 4
    vendor = data[pos:pos+vendor_len].decode('utf-8', errors='replace')
    print(f"    Vendor: {vendor}")
    pos += vendor_len
    
    comment_count = struct.unpack('<I', data[pos:pos+4])[0]
    pos += 4
    print(f"    Comments: {comment_count}")
    
    for i in range(comment_count):
        if pos + 4 > len(data):
            break
        
        comment_len = struct.unpack('<I', data[pos:pos+4])[0]
        pos += 4
        if pos + comment_len > len(data):
            break
        
        comment = data[pos:pos+comment_len].decode('utf-8', errors='replace')
        print(f"      {i+1}. {comment[:100]}")
        pos += comment_len

parse_ogg_vorbis('filename.ogg')
```

Use `ogginfo` for comprehensive OGG analysis:

```bash
ogginfo filename.ogg
ogginfo -v filename.ogg  ## Verbose
```

Use `vorbiscomment` to extract and manipulate comments:

```bash
vorbiscomment -l filename.ogg
vorbiscomment -l filename.ogg > comments.txt
```

#### OGG Metadata and Steganography

Extract Vorbis comments programmatically:

```python
def extract_ogg_vorbis_comments(filename):
    with open(filename, 'rb') as f:
        page_count = 0
        while True:
            oggs = f.read(4)
            if oggs != b'OggS':
                break
            
            f.seek(f.tell() + 22)  ## Skip header to segment count
            page_segments = f.read(1)[0]
            segment_table = f.read(page_segments)
            total_segment_size = sum(segment_table)
            page_data = f.read(total_segment_size)
            
            ## Look for comment header
            if page_data[:7] == b'\x03vorbis':
                pos = 7
                vendor_len = struct.unpack('<I', page_data[pos:pos+4])[0]
                pos += 4 + vendor_len
                
                comment_count = struct.unpack('<I', page_data[pos:pos+4])[0]
                pos += 4
                
                comments = {}
                for _ in range(comment_count):
                    comment_len = struct.unpack('<I', page_data[pos:pos+4])[0]
                    pos += 4
                    comment = page_data[pos:pos+comment_len].decode('utf-8', errors='replace')
                    pos += comment_len
                    
                    if '=' in comment:
                        key, value = comment.split('=', 1)
                        comments[key.upper()] = value
                
                return comments
            
            page_count += 1
    
    return None

comments = extract_ogg_vorbis_comments('filename.ogg')
if comments:
    for key, value in comments.items():
        print(f"{key}: {value[:100]}")
```

Detect and extract suspicious Vorbis comments:

```python
def find_suspicious_ogg_comments(filename):
    comments = extract_ogg_vorbis_comments(filename)
    if not comments:
        return
    
    suspicious = []
    for key, value in comments.items():
        ## Look for binary data in comments
        try:
            value.encode('ascii')
        except UnicodeDecodeError:
            suspicious.append((key, value))
        
        ## Look for unusually long values
        if len(value) > 1000:
            suspicious.append((key, value[:100] + '...'))
        
        ## Look for base64 or hex patterns
        if all(c in '0123456789ABCDEFabcdef' for c in value[:20]):
            suspicious.append((key, f"Hex data: {value[:50]}"))
    
    if suspicious:
        print("Suspicious comments found:")
        for key, value in suspicious:
            print(f"  {key}: {value}")
    
    return suspicious

find_suspicious_ogg_comments('filename.ogg')
```

Analyze OGG page padding:

```python
def analyze_ogg_padding(filename):
    with open(filename, 'rb') as f:
        page_count = 0
        while True:
            pos = f.tell()
            oggs = f.read(4)
            if oggs != b'OggS':
                break
            
            f.seek(pos + 26)  ## Skip to segment count
            page_segments = f.read(1)[0]
            segment_table = f.read(page_segments)
            total_segment_size = sum(segment_table)
            page_data = f.read(total_segment_size)
            
            ## Check for unusual segment sizes
            if len(set(segment_table)) > 1:  ## Variable segment sizes
                print(f"Page {page_count}: Variable segments {list(segment_table[:10])}")
            
            page_count += 1

analyze_ogg_padding('filename.ogg')
```

Detect steganography in OGG:

```bash
steghide info filename.ogg
steghide extract -sf filename.ogg -xf output.txt -p ""
```

Extract raw OGG page data for analysis:

```bash
oggSplit filename.ogg  ## If available via oggsplit tool
```

Convert OGG to WAV and analyze audio:

```bash
ffmpeg -i filename.ogg output.wav
```

### M4A/AAC Analysis

#### M4A/AAC File Structure

M4A (MPEG-4 Audio) files use the ISO Base Media File Format (MP4 container), sharing structure with MP4 video files. Files begin with a file type box ("ftyp") containing brand identifier and compatibility flags. Audio data is stored in media data boxes ("mdat"), with metadata in movie boxes ("moov"). These boxes contain nested atoms describing codec parameters, track information, and metadata.

AAC (Advanced Audio Coding) is the audio codec typically used within M4A containers. Metadata is stored in ilst (item list) boxes within the moov atom, using iTunes-style tagging with mean and name atoms. This flexible metadata structure is exploitable for steganography.

#### Parsing M4A/MP4 Structure

Extract and parse M4A boxes:

```python
def parse_m4a(filename):
    with open(filename, 'rb') as f:
        while True:
            box_header = f.read(8)
            if len(box_header) < 8:
                break
            
            box_size = struct.unpack('>I', box_header[0:4])[0]
            box_type = box_header[4:8].decode('ascii', errors='replace')
            
            if box_size == 1:
                ## Extended size
                box_size = struct.unpack('>Q', f.read(8))[0]
            elif box_size == 0:
                ## Box extends to end of file
                f.seek(0, 2)
                box_size = f.tell() - f.tell() + 8
            
            print(f"Box: {box_type}, Size: {box_size}")
            
            if box_type in ['ftyp', 'mdat', 'moov']:
                box_data = f.read(box_size - 8)
                
                if box_type == 'ftyp':
                    major_brand = box_data[0:4]
                    minor_version = struct.unpack('>I', box_data[4:8])[0]
                    print(f"  Major brand: {major_brand}")
                    print(f"  Minor version: {minor_version}")
                
                elif box_type == 'moov':
                    parse_moov_box(box_data)
            else:
                f.seek(f.tell() + box_size - 8)

def parse_moov_box(data):
    pos = 0
    while pos < len(data) - 8:
        box_size = struct.unpack('>I', data[pos:pos+4])[0]
        box_type = data[pos+4:pos+8].decode('ascii', errors='replace')
        
        print(f"  Subbox: {box_type}, Size: {box_size}")
        
        if box_type == 'ilst':
            parse_ilst_box(data[pos+8:pos+box_size])
        
        pos += box_size

def parse_ilst_box(data):
    pos = 0
    while pos < len(data) - 8:
        box_size = struct.unpack('>I', data[pos:pos+4])[0]
        box_type = data[pos+4:pos+8]
        
        print(f"    Metadata atom: {box_type}, Size: {box_size}")
        
        if box_size <= 8 or pos + box_size > len(data):
            break
        
        atom_data = data[pos+8:pos+box_size]
        
        ## Parse data box
        if len(atom_data) >= 16 and atom_data[4:8] == b'data':
            data_flags = struct.unpack('>I', atom_data[8:12])[0]
            metadata_value = atom_data[16:].decode('utf-8', errors='replace')
            print(f"      Value: {metadata_value[:100]}")
        
        pos += box_size

parse_m4a('filename.m4a')
```

Use `ffprobe` for M4A analysis:

```bash
ffprobe -show_format -show_streams filename.m4a
ffprobe -show_entries format=tags filename.m4a
```

Use `mp4box` or `mp4info` (from GPAC):

```bash
mp4info filename.m4a
mp4dump filename.m4a
```

Extract metadata with `exiftool`:

```bash
exiftool filename.m4a
exiftool -a filename.m4a
```

#### AAC Audio Analysis

Extract AAC frames for analysis:

```python
def extract_aac_frames(filename, max_frames=10):
    with open(filename, 'rb') as f:
        ## Skip to audio data
        f.seek(0)
        audio_data = None
        
        while True:
            box_header = f.read(8)
            if len(box_header) < 8:
                break
            
            box_size = struct.unpack('>I', box_header[0:4])[0]
            box_type = box_header[4:8]
            
            if box_type == b'mdat':
                audio_data = f.read(box_size - 8)
                break
            else:
                f.seek(f.tell() + box_size - 8)
        
        if not audio_data:
            return
        
        ## Parse AAC frames
        frame_count = 0
        pos = 0
        
        while pos < len(audio_data) - 7 and frame_count < max_frames:
            ## AAC ADTS frame header
            if audio_data[pos:pos+2] == b'\xFF\xF1' or audio_data[pos:pos+2] == b'\xFF\xF9':
                sync_word = (audio_data[pos] << 8) | audio_data[pos+1]
                
                if (sync_word & 0xFFF0) == 0xFFF0:  ## ADTS sync word
                    mpeg_version = (audio_data[pos+1] >> 3) & 0x01
                    profile = (audio_data[pos+2] >> 6) & 0x03
                    sample_rate_index = (audio_data[pos+2] >> 2) & 0x0F
                    private_bit = (audio_data[pos+2] >> 1) & 0x01
                    channel_config = ((audio_data[pos+2] & 0x01) << 2) | ((audio_data[pos+3] >> 6) & 0x03)
                    
                    frame_length = (((audio_data[pos+3] & 0x03) << 11) |
                                  (audio_data[pos+4] << 3) |
                                  ((audio_data[pos+5] >> 5) & 0x07))
                    
                    print(f"Frame {frame_count}: Profile={profile}, Channels={channel_config}, Length={frame_length}")
                    frame_count += 1
                    pos += frame_length
                else:
                    pos += 1
            else:
                pos += 1

extract_aac_frames('filename.m4a')
```

#### M4A Steganography Detection

Extract iTunes-style metadata tags for hidden data:

```python
def extract_m4a_metadata(filename):
    with open(filename, 'rb') as f:
        metadata = {}
        
        while True:
            box_header = f.read(8)
            if len(box_header) < 8:
                break
            
            box_size = struct.unpack('>I', box_header[0:4])[0]
            box_type = box_header[4:8]
            
            if box_size == 1:
                box_size = struct.unpack('>Q', f.read(8))[0]
            elif box_size == 0:
                break
            
            if box_type == b'moov':
                moov_data = f.read(box_size - 8)
                metadata.update(parse_moov_metadata(moov_data))
            else:
                f.seek(f.tell() + box_size - 8)
        
        return metadata

def parse_moov_metadata(data):
    metadata = {}
    pos = 0
    
    while pos < len(data) - 8:
        box_size = struct.unpack('>I', data[pos:pos+4])[0]
        box_type = data[pos+4:pos+8]
        
        if box_type == b'ilst':
            pos_ilst = pos + 8
            end_ilst = pos + box_size
            
            while pos_ilst < end_ilst - 8:
                atom_size = struct.unpack('>I', data[pos_ilst:pos_ilst+4])[0]
                atom_type = data[pos_ilst+4:pos_ilst+8]
                
                if atom_size <= 8 or pos_ilst + atom_size > end_ilst:
                    break
                
                atom_data = data[pos_ilst+8:pos_ilst+atom_size]
                
                ## Parse mean and name atoms for custom metadata
                if len(atom_data) >= 8 and atom_data[4:8] == b'data':
                    data_flags = struct.unpack('>I', atom_data[8:12])[0]
                    value = atom_data[16:].decode('utf-8', errors='replace')
                    metadata[atom_type.decode('ascii', errors='replace')] = value
                
                pos_ilst += atom_size
        
        pos += box_size
    
    return metadata

metadata = extract_m4a_metadata('filename.m4a')
for key, value in metadata.items():
    print(f"{key}: {value[:100]}")
```

Analyze M4A for suspicious metadata:

```python
def find_suspicious_m4a_metadata(filename):
    metadata = extract_m4a_metadata(filename)
    
    suspicious = []
    for key, value in metadata.items():
        ## Check for binary or unusual data
        if '\x00' in value or any(ord(c) > 127 for c in value if c not in '\n\r\t'):
            suspicious.append((key, f"Binary/Non-ASCII: {value[:50].encode('utf-8', errors='replace')}"))
        
        ## Check for unusually long values
        if len(value) > 5000:
            suspicious.append((key, f"Very long value ({len(value)} chars): {value[:100]}..."))
        
        ## Check for base64 or hex patterns
        if len(value) > 20 and all(c in '0123456789ABCDEFabcdef+/=' for c in value[:50]):
            suspicious.append((key, f"Encoded data: {value[:100]}"))
    
    if suspicious:
        print("Suspicious M4A metadata:")
        for key, value in suspicious:
            print(f"  {key}: {value}")
    
    return suspicious

find_suspicious_m4a_metadata('filename.m4a')
```

Detect steganography tools:

```bash
steghide info filename.m4a
steghide extract -sf filename.m4a -xf output.txt -p ""
```

Extract audio from M4A and analyze for LSB steganography:

```bash
ffmpeg -i filename.m4a output.wav
```

Then apply WAV LSB analysis techniques.

Check for hidden data in M4A padding and unused atoms:

```python
def find_unusual_m4a_atoms(filename):
    with open(filename, 'rb') as f:
        unusual = []
        
        while True:
            pos = f.tell()
            box_header = f.read(8)
            if len(box_header) < 8:
                break
            
            box_size = struct.unpack('>I', box_header[0:4])[0]
            box_type = box_header[4:8]
            
            if box_size == 1:
                box_size = struct.unpack('>Q', f.read(8))[0]
            elif box_size == 0:
                break
            
            ## Look for non-standard box types
            if not all(32 <= b < 127 for b in box_type):
                unusual.append((pos, box_type, box_size))
            
            ## Look for unusually large boxes
            if box_size > 100 * 1024 * 1024:
                unusual.append((pos, box_type, f"{box_size} (very large)"))
            
            f.seek(pos + box_size)
        
        if unusual:
            print("Unusual M4A atoms found:")
            for pos, box_type, size in unusual:
                print(f"  Offset {hex(pos)}: {box_type} ({size})")
        
        return unusual

find_unusual_m4a_atoms('filename.m4a')
```

#### Automated Audio Format Analysis Workflow

Create a comprehensive audio file analysis script:

```python
#!/usr/bin/env python3
import os
import struct
import subprocess
from pathlib import Path

class AudioAnalyzer:
    def __init__(self, filepath):
        self.filepath = filepath
        self.format = None
    
    def detect_format(self):
        with open(self.filepath, 'rb') as f:
            signature = f.read(12)
        
        if signature[:4] == b'RIFF' and signature[8:12] == b'WAVE':
            self.format = 'WAV'
        elif signature[:3] == b'ID3' or signature[0:2] == b'\xFF\xFB':
            self.format = 'MP3'
        elif signature[:4] == b'fLaC':
            self.format = 'FLAC'
        elif signature[:4] == b'OggS':
            self.format = 'OGG'
        elif signature[:4] == b'ftyp' or signature[4:8] == b'ftyp':
            ## Check for audio-specific fourcc
            if b'isom' in signature or b'mp42' in signature or b'M4A' in signature:
                self.format = 'M4A'
        
        return self.format
    
    def analyze(self):
        fmt = self.detect_format()
        print(f"Format: {fmt}")
        print(f"File size: {os.path.getsize(self.filepath)} bytes\n")
        
        if fmt == 'WAV':
            self.analyze_wav()
        elif fmt == 'MP3':
            self.analyze_mp3()
        elif fmt == 'FLAC':
            self.analyze_flac()
        elif fmt == 'OGG':
            self.analyze_ogg()
        elif fmt == 'M4A':
            self.analyze_m4a()
        else:
            print("Unknown format")
    
    def analyze_wav(self):
        print("=== WAV Analysis ===")
        subprocess.run(['ffprobe', '-v', 'error', '-show_format', '-show_streams', 
                       self.filepath], timeout=5)
    
    def analyze_mp3(self):
        print("=== MP3 Analysis ===")
        print("ID3v2 Tags:")
        subprocess.run(['exiftool', self.filepath], timeout=5)
    
    def analyze_flac(self):
        print("=== FLAC Analysis ===")
        subprocess.run(['metaflac', '--list', self.filepath], timeout=5)
    
    def analyze_ogg(self):
        print("=== OGG Vorbis Analysis ===")
        subprocess.run(['ogginfo', self.filepath], timeout=5)
    
    def analyze_m4a(self):
        print("=== M4A Analysis ===")
        subprocess.run(['ffprobe', '-show_format', '-show_streams', self.filepath], timeout=5)

if __name__ == '__main__':
    import sys
    if len(sys.argv) > 1:
        analyzer = AudioAnalyzer(sys.argv[1])
        analyzer.analyze()
    else:
        print("Usage: audio_analyzer.py <audiofile>")
```

Create a comprehensive steganography detection script for all audio formats:

```bash
#!/bin/bash
TARGET_FILE="$1"

echo "=== Audio File Format Analysis ==="
file "$TARGET_FILE"
ls -lh "$TARGET_FILE"

echo -e "\n=== General Metadata ==="
exiftool "$TARGET_FILE" 2>/dev/null | head -30

echo -e "\n=== Hex Dump (first 512 bytes) ==="
xxd "$TARGET_FILE" | head -32

echo -e "\n=== Format-Specific Analysis ==="
case "$(file -b "$TARGET_FILE")" in
    *WAV*)
        echo "WAV format detected"
        ffprobe -v error -show_format -show_streams "$TARGET_FILE" 2>/dev/null
        ;;
    *MP3*)
        echo "MP3 format detected"
        ;;
    *FLAC*)
        echo "FLAC format detected"
        metaflac --list "$TARGET_FILE" 2>/dev/null || echo "metaflac not available"
        ;;
    *Ogg*)
        echo "OGG format detected"
        ogginfo "$TARGET_FILE" 2>/dev/null || echo "ogginfo not available"
        ;;
    *)
        echo "Audio format not specifically handled"
        ;;
esac

echo -e "\n=== Steganography Detection ==="
steghide info "$TARGET_FILE" 2>/dev/null || echo "steghide not available"

echo -e "\n=== Audio Properties ==="
ffprobe -v error -select_streams a:0 \
  -show_entries stream=codec_type,codec_name,sample_rate,channels,duration \
  -of default=noprint_wrappers=1:nokey=1 "$TARGET_FILE" 2>/dev/null
```

Related topics for comprehensive audio steganography coverage: **Spectrogram Analysis and Frequency Domain Steganography**, **Phase Coding and Spread Spectrum Techniques**, **Temporal Audio Steganography**, **Codec-Specific Exploitation Methods**.

---

## Audio Analysis Techniques

### Spectral Analysis

Spectral analysis examines the frequency content of audio signals to identify hidden data, encoded patterns, or steganographic information. Audio steganography frequently encodes data in specific frequency ranges or as visual patterns in the frequency domain.

#### Primary Tools for Spectral Analysis

**Audacity**

bash

```bash
# Launch Audacity (GUI-based but scriptable)
audacity audio.wav

# Command-line analysis with sox
sox audio.wav -n spectrogram -o spectrogram.png

# High-resolution spectrogram
sox audio.wav -n spectrogram -x 3000 -y 513 -z 120 -o hires_spec.png

# Adjusting frequency range (useful for finding hidden high-frequency data)
sox audio.wav -n spectrogram -Y 200 -o spectrogram.png  # 200 pixel height
```

**SoX (Sound eXchange) - Advanced Spectral Analysis**

bash

```bash
# Basic spectral analysis
sox audio.wav -n stat

# Detailed statistics including frequency content
sox audio.wav -n stats

# Power spectrum analysis
sox audio.wav -n stat -freq

# Generate spectrogram with specific parameters
sox audio.wav -n spectrogram \
  -x 4000 \          # Width in pixels
  -y 513 \           # Height in pixels (FFT size related)
  -z 120 \           # dB range
  -w Kaiser \        # Window function
  -o output.png

# Spectrogram focusing on specific frequency range
sox audio.wav -n spectrogram -X 0:5000 -o lowfreq_spec.png  # 0-5000 Hz

# High-pass filter then spectrogram (isolate high frequencies)
sox audio.wav -n highpass 10000 spectrogram -o highfreq_spec.png
```

**spek - Acoustic Spectrum Analyzer**

bash

```bash
# Install: apt install spek
spek audio.wav

# Command-line usage [Unverified - spek is primarily GUI]
# Alternative: use sox or python for CLI spectrogram generation
```

#### Python-Based Spectral Analysis

**Using scipy and matplotlib:**

python

```python
#!/usr/bin/env python3
import numpy as np
import matplotlib.pyplot as plt
from scipy import signal
from scipy.io import wavfile

# Read audio file
sample_rate, audio_data = wavfile.read('audio.wav')

# Handle stereo by converting to mono
if len(audio_data.shape) == 2:
    audio_data = audio_data.mean(axis=1)

# Compute spectrogram
frequencies, times, spectrogram = signal.spectrogram(
    audio_data,
    fs=sample_rate,
    window='hann',
    nperseg=1024,
    noverlap=512
)

# Plot spectrogram
plt.figure(figsize=(12, 6))
plt.pcolormesh(times, frequencies, 10 * np.log10(spectrogram), 
               shading='gouraud', cmap='viridis')
plt.ylabel('Frequency [Hz]')
plt.xlabel('Time [sec]')
plt.colorbar(label='Power [dB]')
plt.ylim(0, sample_rate/2)
plt.savefig('spectrogram.png', dpi=300, bbox_inches='tight')
plt.show()

# High-resolution spectrogram for hidden data
frequencies, times, spectrogram = signal.spectrogram(
    audio_data,
    fs=sample_rate,
    window='hann',
    nperseg=4096,  # Larger window for better frequency resolution
    noverlap=3840
)

plt.figure(figsize=(20, 10))
plt.pcolormesh(times, frequencies, 10 * np.log10(spectrogram), 
               shading='gouraud', cmap='hot')
plt.ylim(0, 20000)  # Focus on audible range
plt.savefig('hires_spectrogram.png', dpi=300, bbox_inches='tight')
```

**Full-spectrum analysis script:**

python

```python
#!/usr/bin/env python3
import numpy as np
from scipy.io import wavfile
from scipy.fft import fft, fftfreq
import matplotlib.pyplot as plt

# Read audio
sample_rate, audio_data = wavfile.read('audio.wav')

if len(audio_data.shape) == 2:
    audio_data = audio_data.mean(axis=1)

# Compute FFT
n = len(audio_data)
fft_values = fft(audio_data)
fft_freqs = fftfreq(n, 1/sample_rate)

# Only positive frequencies
positive_freqs = fft_freqs[:n//2]
positive_fft = np.abs(fft_values[:n//2])

# Plot frequency spectrum
plt.figure(figsize=(14, 6))
plt.plot(positive_freqs, positive_fft)
plt.xlabel('Frequency (Hz)')
plt.ylabel('Magnitude')
plt.title('Frequency Spectrum')
plt.xlim(0, sample_rate/2)
plt.grid(True)
plt.savefig('frequency_spectrum.png', dpi=300)

# Find peak frequencies (potential hidden signals)
threshold = np.max(positive_fft) * 0.1  # 10% of max
peaks = positive_freqs[positive_fft > threshold]
print("Significant frequency peaks (Hz):")
for peak in peaks[:20]:  # Top 20 peaks
    print(f"{peak:.2f} Hz")
```

#### Spectral Analysis CTF Techniques

**Looking for Hidden Images in Spectrograms:** Many CTF challenges encode QR codes, text, or images in the frequency domain visible only in spectrograms.

bash

```bash
# Generate multiple spectrogram views
sox audio.wav -n spectrogram -x 4000 -y 1025 -z 120 -o spec_normal.png
sox audio.wav -n spectrogram -x 4000 -y 1025 -z 60 -o spec_bright.png
sox audio.wav -n spectrogram -x 8000 -y 2049 -z 120 -o spec_xlarge.png

# Invert colors (sometimes makes hidden content visible)
convert spec_normal.png -negate spec_inverted.png

# Adjust contrast and brightness
convert spec_normal.png -contrast-stretch 0 spec_enhanced.png
```

**Detecting Frequency Anomalies:**

bash

```bash
# Isolate specific frequency bands
sox audio.wav filtered.wav bandpass 18000 1000  # 17kHz-19kHz band
sox filtered.wav -n spectrogram -o isolated_band.png

# Check for ultrasonic content (above human hearing)
sox audio.wav ultrasonic.wav highpass 20000
sox ultrasonic.wav -n stat  # Check if content exists
```

**Multiple Channel Analysis:**

bash

```bash
# Extract and analyze channels separately for stereo files
sox audio.wav left.wav remix 1
sox audio.wav right.wav remix 2

sox left.wav -n spectrogram -o left_spec.png
sox right.wav -n spectrogram -o right_spec.png

# Difference between channels
sox -M left.wav right.wav -n spectrogram -o diff_spec.png
```

### Spectrogram Visualization

Spectrogram visualization transforms audio into a visual time-frequency representation, revealing hidden patterns, text, images, or encoded data.

#### Advanced Spectrogram Generation

**Sonic Visualiser**

bash

```bash
# Install: apt install sonic-visualiser
sonic-visualiser audio.wav

# [Inference] Command-line usage may require session files
# Primarily GUI-based with extensive analysis layers
```

**SoX Parameter Optimization for CTFs:**

bash

```bash
# Standard high-quality spectrogram
sox audio.wav -n spectrogram \
  -x 4096 \
  -y 1025 \
  -z 120 \
  -w Kaiser \
  -S 0:00 \
  -d 0:00 \
  -o standard.png

# Ultra-high resolution for finding small details
sox audio.wav -n spectrogram \
  -x 8192 \
  -y 2049 \
  -z 100 \
  -o ultrahigh.png

# Linear frequency scale (instead of default log)
sox audio.wav -n spectrogram -y 513 -Z -o linear_freq.png

# Monochrome (sometimes clearer for text/QR codes)
sox audio.wav -n spectrogram -m -o monochrome.png

# Focus on specific time segment (first 30 seconds)
sox audio.wav -n trim 0 30 spectrogram -o first30sec.png
```

#### Python Spectrogram Customization

**Multiple visualization approaches:**

python

```python
#!/usr/bin/env python3
import numpy as np
import matplotlib.pyplot as plt
from scipy import signal
from scipy.io import wavfile

sample_rate, audio = wavfile.read('audio.wav')

if len(audio.shape) == 2:
    audio = audio.mean(axis=1)

# Method 1: Standard spectrogram
f, t, Sxx = signal.spectrogram(audio, sample_rate, nperseg=1024)
plt.figure(figsize=(14, 8))
plt.pcolormesh(t, f, 10*np.log10(Sxx), shading='gouraud')
plt.ylabel('Frequency [Hz]')
plt.xlabel('Time [sec]')
plt.colorbar()
plt.savefig('spec_standard.png', dpi=300)
plt.close()

# Method 2: High frequency resolution (longer window)
f, t, Sxx = signal.spectrogram(audio, sample_rate, nperseg=8192, noverlap=7168)
plt.figure(figsize=(16, 10))
plt.pcolormesh(t, f, 10*np.log10(Sxx), shading='gouraud', cmap='inferno')
plt.ylim(0, 22050)
plt.savefig('spec_high_freq_res.png', dpi=300)
plt.close()

# Method 3: High time resolution (shorter window)
f, t, Sxx = signal.spectrogram(audio, sample_rate, nperseg=256, noverlap=128)
plt.figure(figsize=(16, 10))
plt.pcolormesh(t, f, 10*np.log10(Sxx), shading='gouraud', cmap='plasma')
plt.savefig('spec_high_time_res.png', dpi=300)
plt.close()

# Method 4: Focusing on specific frequency range
f, t, Sxx = signal.spectrogram(audio, sample_rate, nperseg=2048)
freq_mask = (f >= 1000) & (f <= 10000)
plt.figure(figsize=(14, 8))
plt.pcolormesh(t, f[freq_mask], 10*np.log10(Sxx[freq_mask, :]), 
               shading='gouraud', cmap='hot')
plt.ylabel('Frequency [Hz]')
plt.xlabel('Time [sec]')
plt.savefig('spec_1k_10k.png', dpi=300)
plt.close()

# Method 5: Binary/thresholded (for QR codes or text)
f, t, Sxx = signal.spectrogram(audio, sample_rate, nperseg=2048)
threshold = np.percentile(Sxx, 95)  # Top 5% intensity
binary_spec = Sxx > threshold
plt.figure(figsize=(14, 8))
plt.pcolormesh(t, f, binary_spec, shading='nearest', cmap='binary')
plt.savefig('spec_binary.png', dpi=300)
plt.close()
```

**Extracting Images from Spectrograms:**

python

```python
#!/usr/bin/env python3
# When spectrogram contains QR code or image
import numpy as np
from scipy.io import wavfile
from scipy import signal
from PIL import Image

sample_rate, audio = wavfile.read('audio.wav')
if len(audio.shape) == 2:
    audio = audio.mean(axis=1)

f, t, Sxx = signal.spectrogram(audio, sample_rate, nperseg=2048)

# Normalize to 0-255 range
Sxx_normalized = ((Sxx - Sxx.min()) / (Sxx.max() - Sxx.min()) * 255).astype(np.uint8)

# Save as image for analysis
img = Image.fromarray(Sxx_normalized)
img = img.transpose(Image.FLIP_TOP_BOTTOM)  # Flip to correct orientation
img.save('extracted_image.png')

# Try threshold-based extraction
threshold = np.percentile(Sxx_normalized, 80)
binary = (Sxx_normalized > threshold).astype(np.uint8) * 255
binary_img = Image.fromarray(binary)
binary_img = binary_img.transpose(Image.FLIP_TOP_BOTTOM)
binary_img.save('extracted_binary.png')
```

### Waveform Analysis

Waveform analysis examines the audio signal's amplitude over time, revealing patterns in temporal domain that may indicate steganography, encoding schemes, or hidden messages.

#### Waveform Visualization Tools

**SoX Waveform Display:**

bash

```bash
# Generate waveform image
sox audio.wav -n spectrogram -x 4000 -y 200 -z 0 -o waveform.png

# [Inference] SoX spectrogram with -z 0 approximates waveform view
# Alternative method using gnuplot
```

**Python Waveform Analysis:**

python

```python
#!/usr/bin/env python3
import numpy as np
import matplotlib.pyplot as plt
from scipy.io import wavfile

sample_rate, audio = wavfile.read('audio.wav')

# Handle stereo
if len(audio.shape) == 2:
    left = audio[:, 0]
    right = audio[:, 1]
else:
    left = audio
    right = None

# Time array
time = np.arange(len(left)) / sample_rate

# Plot waveform
plt.figure(figsize=(16, 6))
plt.subplot(2, 1, 1)
plt.plot(time, left, linewidth=0.5)
plt.xlabel('Time (s)')
plt.ylabel('Amplitude')
plt.title('Left Channel Waveform')
plt.grid(True, alpha=0.3)

if right is not None:
    plt.subplot(2, 1, 2)
    plt.plot(time, right, linewidth=0.5, color='orange')
    plt.xlabel('Time (s)')
    plt.ylabel('Amplitude')
    plt.title('Right Channel Waveform')
    plt.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('waveform_full.png', dpi=300)
plt.close()

# Zoomed view (first 0.1 seconds)
zoom_samples = int(0.1 * sample_rate)
plt.figure(figsize=(14, 6))
plt.plot(time[:zoom_samples], left[:zoom_samples], linewidth=1)
plt.xlabel('Time (s)')
plt.ylabel('Amplitude')
plt.title('Waveform - First 0.1 seconds (Zoomed)')
plt.grid(True)
plt.savefig('waveform_zoom.png', dpi=300)
```

#### Waveform-Based Steganography Detection

**Amplitude Pattern Analysis:**

python

```python
#!/usr/bin/env python3
import numpy as np
from scipy.io import wavfile
import matplotlib.pyplot as plt

sample_rate, audio = wavfile.read('audio.wav')
if len(audio.shape) == 2:
    audio = audio.mean(axis=1)

# Analyze amplitude distribution
plt.figure(figsize=(12, 5))
plt.hist(audio, bins=256, density=True)
plt.xlabel('Amplitude')
plt.ylabel('Probability Density')
plt.title('Amplitude Distribution')
plt.savefig('amplitude_dist.png', dpi=300)

# Check for unusual patterns in LSB (Least Significant Bit)
lsb = audio & 1  # Extract LSB
print(f"LSB ones ratio: {np.mean(lsb):.4f}")  # Should be ~0.5 for natural audio
print(f"LSB entropy: {-np.sum(np.histogram(lsb, bins=2, density=True)[0] * np.log2(np.histogram(lsb, bins=2, density=True)[0] + 1e-10)):.4f}")

# Extract LSB as potential hidden data
lsb_bytes = np.packbits(lsb.astype(np.uint8))
with open('lsb_data.bin', 'wb') as f:
    f.write(lsb_bytes.tobytes())

# Visualize LSB pattern
plt.figure(figsize=(16, 4))
plt.plot(lsb[:10000])
plt.title('LSB Pattern (First 10000 samples)')
plt.ylabel('LSB Value')
plt.xlabel('Sample')
plt.savefig('lsb_pattern.png', dpi=300)
```

**Envelope Detection:**

python

```python
#!/usr/bin/env python3
from scipy.signal import hilbert, butter, filtfilt
from scipy.io import wavfile
import numpy as np
import matplotlib.pyplot as plt

sample_rate, audio = wavfile.read('audio.wav')
if len(audio.shape) == 2:
    audio = audio.mean(axis=1)

# Normalize
audio = audio / np.max(np.abs(audio))

# Compute envelope using Hilbert transform
analytic_signal = hilbert(audio)
envelope = np.abs(analytic_signal)

# Smooth envelope
b, a = butter(4, 0.01)  # Low-pass filter
envelope_smooth = filtfilt(b, a, envelope)

# Plot
time = np.arange(len(audio)) / sample_rate
plt.figure(figsize=(16, 6))
plt.plot(time, audio, alpha=0.5, label='Waveform')
plt.plot(time, envelope_smooth, 'r', linewidth=2, label='Envelope')
plt.xlabel('Time (s)')
plt.ylabel('Amplitude')
plt.legend()
plt.title('Waveform with Envelope')
plt.savefig('envelope.png', dpi=300)

# Analyze envelope modulation (may contain hidden data)
envelope_fft = np.fft.fft(envelope_smooth)
envelope_freqs = np.fft.fftfreq(len(envelope_smooth), 1/sample_rate)
plt.figure(figsize=(12, 6))
plt.plot(envelope_freqs[:len(envelope_freqs)//2], 
         np.abs(envelope_fft)[:len(envelope_fft)//2])
plt.xlabel('Modulation Frequency (Hz)')
plt.ylabel('Magnitude')
plt.title('Envelope Spectrum (Amplitude Modulation)')
plt.xlim(0, 100)
plt.savefig('envelope_spectrum.png', dpi=300)
```

**Zero-Crossing Analysis:**

python

```python
#!/usr/bin/env python3
import numpy as np
from scipy.io import wavfile

sample_rate, audio = wavfile.read('audio.wav')
if len(audio.shape) == 2:
    audio = audio.mean(axis=1)

# Detect zero crossings
zero_crossings = np.where(np.diff(np.sign(audio)))[0]
zcr = len(zero_crossings) / len(audio)  # Zero crossing rate

print(f"Total zero crossings: {len(zero_crossings)}")
print(f"Zero crossing rate: {zcr:.6f}")
print(f"ZCR per second: {zcr * sample_rate:.2f}")

# Analyze ZCR over time windows
window_size = int(0.1 * sample_rate)  # 100ms windows
num_windows = len(audio) // window_size
zcr_per_window = []

for i in range(num_windows):
    window = audio[i*window_size:(i+1)*window_size]
    zc = np.where(np.diff(np.sign(window)))[0]
    zcr_per_window.append(len(zc) / window_size)

# Plot ZCR over time
import matplotlib.pyplot as plt
plt.figure(figsize=(14, 6))
plt.plot(zcr_per_window)
plt.xlabel('Window Index (100ms windows)')
plt.ylabel('Zero Crossing Rate')
plt.title('Zero Crossing Rate Over Time')
plt.savefig('zcr_analysis.png', dpi=300)
```

### Frequency Domain Analysis

Frequency domain analysis reveals spectral characteristics, hidden tones, and frequency-based encoding schemes used in audio steganography.

#### Fast Fourier Transform (FFT) Analysis

**Basic FFT with NumPy:**

python

```python
#!/usr/bin/env python3
import numpy as np
from scipy.io import wavfile
import matplotlib.pyplot as plt

sample_rate, audio = wavfile.read('audio.wav')
if len(audio.shape) == 2:
    audio = audio.mean(axis=1)

# Compute FFT
fft_values = np.fft.fft(audio)
fft_freqs = np.fft.fftfreq(len(audio), 1/sample_rate)

# Magnitude spectrum
magnitude = np.abs(fft_values)
phase = np.angle(fft_values)

# Plot positive frequencies only
positive_mask = fft_freqs >= 0
plt.figure(figsize=(14, 6))
plt.subplot(2, 1, 1)
plt.plot(fft_freqs[positive_mask], magnitude[positive_mask])
plt.xlabel('Frequency (Hz)')
plt.ylabel('Magnitude')
plt.title('Magnitude Spectrum')
plt.xlim(0, sample_rate/2)
plt.grid(True)

plt.subplot(2, 1, 2)
plt.plot(fft_freqs[positive_mask], phase[positive_mask])
plt.xlabel('Frequency (Hz)')
plt.ylabel('Phase (radians)')
plt.title('Phase Spectrum')
plt.xlim(0, sample_rate/2)
plt.grid(True)

plt.tight_layout()
plt.savefig('fft_analysis.png', dpi=300)
```

**Short-Time Fourier Transform (STFT):**

python

```python
#!/usr/bin/env python3
import numpy as np
from scipy import signal
from scipy.io import wavfile
import matplotlib.pyplot as plt

sample_rate, audio = wavfile.read('audio.wav')
if len(audio.shape) == 2:
    audio = audio.mean(axis=1)

# Compute STFT
f, t, Zxx = signal.stft(audio, fs=sample_rate, nperseg=1024)

# Plot magnitude
plt.figure(figsize=(14, 8))
plt.pcolormesh(t, f, np.abs(Zxx), shading='gouraud', cmap='viridis')
plt.title('STFT Magnitude')
plt.ylabel('Frequency [Hz]')
plt.xlabel('Time [sec]')
plt.colorbar(label='Magnitude')
plt.ylim(0, sample_rate/2)
plt.savefig('stft_magnitude.png', dpi=300)

# Reconstruct to verify
_, reconstructed = signal.istft(Zxx, fs=sample_rate)
reconstruction_error = np.mean((audio[:len(reconstructed)] - reconstructed)**2)
print(f"Reconstruction MSE: {reconstruction_error:.6e}")
```

**Peak Frequency Detection:**

python

```python
#!/usr/bin/env python3
import numpy as np
from scipy import signal
from scipy.io import wavfile

sample_rate, audio = wavfile.read('audio.wav')
if len(audio.shape) == 2:
    audio = audio.mean(axis=1)

# Compute power spectral density
f, Pxx = signal.periodogram(audio, sample_rate)

# Find peaks
peaks, properties = signal.find_peaks(Pxx, height=np.max(Pxx)*0.01, distance=10)

# Sort by prominence
peak_freqs = f[peaks]
peak_powers = Pxx[peaks]
sorted_indices = np.argsort(peak_powers)[::-1]

print("Top 20 frequency peaks:")
print(f"{'Frequency (Hz)':<15} {'Power':<15} {'Note (Approx)'}")
print("-" * 50)

for i in sorted_indices[:20]:
    freq = peak_freqs[i]
    power = peak_powers[i]
    # Convert to musical note [Inference - note calculation]
    if freq > 0:
        note_number = 12 * np.log2(freq / 440) + 69
        note_names = ['C', 'C#', 'D', 'D#', 'E', 'F', 'F#', 'G', 'G#', 'A', 'A#', 'B']
        note = note_names[int(note_number) % 12] + str(int(note_number) // 12 - 1)
    else:
        note = "N/A"
    print(f"{freq:<15.2f} {power:<15.2e} {note}")

# Save peak frequencies to file
np.savetxt('peak_frequencies.txt', 
           np.column_stack((peak_freqs[sorted_indices[:50]], 
                           peak_powers[sorted_indices[:50]])),
           header='Frequency(Hz) Power',
           fmt='%.2f %.6e')
```

#### Band-Pass Filtering for Frequency Isolation

**Isolating Specific Frequency Bands:**

bash

```bash
# Using SoX to isolate frequency ranges
sox audio.wav band1.wav bandpass 1000 100    # 950-1050 Hz
sox audio.wav band2.wav bandpass 2000 100    # 1950-2050 Hz
sox audio.wav band3.wav bandpass 5000 500    # 4750-5250 Hz

# Low-pass filter (frequencies below 3kHz)
sox audio.wav lowpass.wav lowpass 3000

# High-pass filter (frequencies above 15kHz)
sox audio.wav highpass.wav highpass 15000

# Notch filter (remove specific frequency)
sox audio.wav notched.wav sinc 1000-2000    # Remove 1-2 kHz
```

**Python Band-Pass Filtering:**

python

```python
#!/usr/bin/env python3
import numpy as np
from scipy import signal
from scipy.io import wavfile

sample_rate, audio = wavfile.read('audio.wav')
if len(audio.shape) == 2:
    audio = audio.mean(axis=1)

# Design band-pass filter
lowcut = 1000.0
highcut = 5000.0
nyquist = sample_rate / 2
low = lowcut / nyquist
high = highcut / nyquist

b, a = signal.butter(4, [low, high], btype='band')
filtered = signal.filtfilt(b, a, audio)

# Save filtered audio
wavfile.write('bandpass_filtered.wav', sample_rate, 
              filtered.astype(np.int16))

# Analyze what was filtered out
residual = audio - filtered
wavfile.write('residual.wav', sample_rate, 
              residual.astype(np.int16))

print(f"Original RMS: {np.sqrt(np.mean(audio**2)):.2f}")
print(f"Filtered RMS: {np.sqrt(np.mean(filtered**2)):.2f}")
print(f"Residual RMS: {np.sqrt(np.mean(residual**2)):.2f}")
```

### DTMF Tone Decoding

DTMF (Dual-Tone Multi-Frequency) tones are commonly used in telephony and CTF challenges to encode numeric data, phone numbers, or ASCII-encoded messages.

#### DTMF Frequency Table

DTMF tones consist of two simultaneous frequencies:

```
        1209Hz  1336Hz  1477Hz  1633Hz
697Hz     1       2       3       A
770Hz     4       5       6       B
852Hz     7       8       9       C
941Hz     *       0       #       D
```

#### DTMF Decoding Tools

**multimon-ng:**

bash

```bash
# Install: apt install multimon-ng

# Decode DTMF from WAV file
multimon-ng -t wav -a DTMF audio.wav

# Decode from raw audio
sox audio.mp3 -t raw -r 22050 -e signed -b 16 -c 1 - | multimon-ng -t raw -a DTMF -

# Output only decoded digits
multimon-ng -t wav -a DTMF audio.wav 2>/dev/null | grep "DTMF"

# Convert output to clean digit sequence
multimon-ng -t wav -a DTMF audio.wav 2>/dev/null | \
  grep "DTMF" | \
  awk '{print $3}' | \
  tr -d '\n' && echo
```

**dtmf2num (Python script):**

bash

```bash
# Install dependencies
pip3 install numpy scipy

# Using goertzel algorithm for DTMF detection
```

python

```python
#!/usr/bin/env python3
"""
DTMF Decoder using Goertzel Algorithm
"""
import numpy as np
from scipy.io import wavfile
import sys

# DTMF frequency pairs
DTMF_FREQS_LOW = [697, 770, 852, 941]
DTMF_FREQS_HIGH = [1209, 1336, 1477, 1633]

DTMF_TABLE = {
    (697, 1209): '1', (697, 1336): '2', (697, 1477): '3', (697, 1633): 'A',
    (770, 1209): '4', (770, 1336): '5', (770, 1477): '6', (770, 1633): 'B',
    (852, 1209): '7', (852, 1336): '8', (852, 1477): '9', (852, 1633): 'C',
    (941, 1209): '*', (941, 1336): '0', (941, 1477): '#', (941, 1633): 'D',
}

def goertzel(samples, sample_rate, target_freq):
    """Goertzel algorithm for single frequency detection"""
    n = len(samples)
    k = int(0.5 + (n * target_freq) / sample_rate)
    omega = (2.0 * np.pi * k) / n
    coeff = 2.0 * np.cos(omega)
    
    q1, q2 = 0.0, 0.0
    for sample in samples:
        q0 = coeff * q1 - q2 + sample
        q2 = q1
        q1 = q0
    
    magnitude = np.sqrt(q1**2 + q2**2 - q1 * q2 * coeff)
    return magnitude

def decode_dtmf(audio, sample_rate, window_size=0.1, threshold=1000):
    """Decode DTMF tones from audio"""
    window_samples = int(window_size * sample_rate)
    hop_samples = window_samples // 2
    
    decoded = []
    position = 0
    
    while position + window_samples < len(audio):
        window = audio[position:position + window_samples]
        
        # Detect frequencies
        low_mags = [goertzel(window, sample_rate, f) for f in DTMF_FREQS_LOW]
        high_mags = [goertzel(window, sample_rate, f) for f in DTMF_FREQS_HIGH]
        
        max_low_idx = np.argmax(low_mags)
        max_high_idx = np.argmax(high_mags)
        
        max_low_mag = low_mags[max_low_idx]
        max_high_mag = high_mags[max_high_idx]
        
        # Check if both frequencies exceed threshold
        if max_low_mag > threshold and max_high_mag > threshold:
            low_freq = DTMF_FREQS_LOW[max_low_idx]
            high_freq = DTMF_FREQS_HIGH[max_high_idx]
            
            digit = DTMF_TABLE.get((low_freq, high_freq), '?')
            
            # Avoid duplicate detections
            if not decoded or decoded[-1] != digit:
                decoded.append(digit)
                print(f"Time: {position/sample_rate:.2f}s - Detected: {digit} "
                      f"({low_freq}Hz, {high_freq}Hz)")
        
        position += hop_samples
    
    return ''.join(decoded)

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python3 dtmf_decoder.py audio.wav")
        sys.exit(1)
    
    filename = sys.argv[1]
    sample_rate, audio = wavfile.read(filename)
    
    # Convert to mono if stereo
    if len(audio.shape) == 2:
        audio = audio.mean(axis=1)
    
    # Normalize
    audio = audio.astype(float)
    
    print(f"Analyzing {filename}...")
    print(f"Sample rate: {sample_rate} Hz")
    print(f"Duration: {len(audio)/sample_rate:.2f} seconds")
    print("\nDecoding DTMF tones...\n")
    
    result = decode_dtmf(audio, sample_rate)
    
    print(f"\n{'='*50}")
    print(f"Decoded sequence: {result}")
    print(f"{'='*50}")
    
    # Attempt ASCII decoding if applicable
    if all(c.isdigit() for c in result) and len(result) % 2 == 0:
        try:
            ascii_decoded = ''.join(chr(int(result[i:i+2])) 
                                   for i in range(0, len(result), 2))
            print(f"ASCII interpretation: {ascii_decoded}")
        except ValueError:
            pass
    
    # Check for phone number pattern
    if len(result) >= 10 and all(c.isdigit() or c in '*#' for c in result):
        print(f"Possible phone number: {result}")
```

**Alternative: sox + Audacity method:**

bash

```bash
# Normalize and enhance DTMF signal
sox audio.wav normalized.wav norm -3

# Generate spectrogram to visually identify DTMF
sox normalized.wav -n spectrogram -x 4000 -y 800 -z 120 -o dtmf_spec.png

# Use Audacity's Analyze > Plot Spectrum for precise frequency identification
```

#### Manual DTMF Analysis

**Frequency-specific filtering approach:**

python

```python
#!/usr/bin/env python3
"""
Manual DTMF detection by filtering individual frequency components
"""
import numpy as np
from scipy import signal
from scipy.io import wavfile
import matplotlib.pyplot as plt

def bandpass_filter(audio, sample_rate, center_freq, bandwidth=50):
    """Create narrow bandpass filter around DTMF frequency"""
    nyquist = sample_rate / 2
    low = (center_freq - bandwidth) / nyquist
    high = (center_freq + bandwidth) / nyquist
    b, a = signal.butter(4, [low, high], btype='band')
    return signal.filtfilt(b, a, audio)

def detect_tone_presence(filtered_signal, threshold_percentile=90):
    """Detect when a tone is present based on envelope"""
    envelope = np.abs(signal.hilbert(filtered_signal))
    threshold = np.percentile(envelope, threshold_percentile)
    return envelope > threshold

sample_rate, audio = wavfile.read('audio.wav')
if len(audio.shape) == 2:
    audio = audio.mean(axis=1)

audio = audio.astype(float) / np.max(np.abs(audio))

# Filter for each DTMF frequency
dtmf_freqs = [697, 770, 852, 941, 1209, 1336, 1477, 1633]
filtered_signals = {}
tone_presence = {}

for freq in dtmf_freqs:
    filtered = bandpass_filter(audio, sample_rate, freq)
    filtered_signals[freq] = filtered
    tone_presence[freq] = detect_tone_presence(filtered)

# Plot presence of each frequency over time
time = np.arange(len(audio)) / sample_rate
plt.figure(figsize=(16, 10))

for idx, freq in enumerate(dtmf_freqs):
    plt.subplot(len(dtmf_freqs), 1, idx + 1)
    plt.plot(time, tone_presence[freq], linewidth=0.5)
    plt.ylabel(f'{freq}Hz')
    plt.ylim(-0.1, 1.1)
    plt.grid(True, alpha=0.3)
    if idx == 0:
        plt.title('DTMF Frequency Presence Over Time')
    if idx == len(dtmf_freqs) - 1:
        plt.xlabel('Time (s)')

plt.tight_layout()
plt.savefig('dtmf_presence.png', dpi=300)

# Decode based on simultaneous presence
window_size = int(0.05 * sample_rate)  # 50ms windows
hop_size = window_size // 4

print("\nDTMF Decoding Results:")
print(f"{'Time (s)':<10} {'Low Freq':<10} {'High Freq':<10} {'Digit'}")
print("-" * 45)

for i in range(0, len(audio) - window_size, hop_size):
    window_slice = slice(i, i + window_size)
    
    # Check which frequencies are present in this window
    low_present = [f for f in [697, 770, 852, 941] 
                   if np.mean(tone_presence[f][window_slice]) > 0.5]
    high_present = [f for f in [1209, 1336, 1477, 1633] 
                    if np.mean(tone_presence[f][window_slice]) > 0.5]
    
    if len(low_present) == 1 and len(high_present) == 1:
        key = (low_present[0], high_present[0])
        if key in DTMF_TABLE:
            digit = DTMF_TABLE[key]
            time_sec = i / sample_rate
            print(f"{time_sec:<10.2f} {low_present[0]:<10} {high_present[0]:<10} {digit}")
```

### Morse Code Detection

Morse code in audio can be transmitted as tone bursts (CW - Continuous Wave) or as amplitude modulation patterns. Detection requires identifying the timing of dots, dashes, and spaces.

#### Morse Code Decoding Tools

**multimon-ng CW decoder:**

bash

```bash
# Decode Morse code (CW)
multimon-ng -t wav -a MORSE_CW audio.wav

# Adjust for different speeds
multimon-ng -t wav -a MORSE_CW audio.wav 2>/dev/null | grep MORSE
```

**morse-decoder (Python):**

bash

```bash
pip3 install morse-decoder

# [Unverified] Command-line usage may vary by implementation
```

#### Custom Morse Code Decoder

**Envelope-based Morse detection:**

python

```python
#!/usr/bin/env python3
"""
Morse Code Decoder from Audio
"""
import numpy as np
from scipy import signal
from scipy.io import wavfile

MORSE_CODE = {
    '.-': 'A', '-...': 'B', '-.-.': 'C', '-..': 'D', '.': 'E',
    '..-.': 'F', '--.': 'G', '....': 'H', '..': 'I', '.---': 'J',
    '-.-': 'K', '.-..': 'L', '--': 'M', '-.': 'N', '---': 'O',
    '.--.': 'P', '--.-': 'Q', '.-.': 'R', '...': 'S', '-': 'T',
    '..-': 'U', '...-': 'V', '.--': 'W', '-..-': 'X', '-.--': 'Y',
    '--..': 'Z',
    '-----': '0', '.----': '1', '..---': '2', '...--': '3',
    '....-': '4', '.....': '5', '-....': '6', '--...': '7',
    '---..': '8', '----.': '9',
    '.-.-.-': '.', '--..--': ',', '..--..': '?', '.----.': "'",
    '-.-.--': '!', '-..-.': '/', '-.--.': '(', '-.--.-': ')',
    '.-...': '&', '---...': ':', '-.-.-.': ';', '-...-': '=',
    '.-.-.': '+', '-....-': '-', '..--.-': '_', '.-..-.': '"',
    '...-..-': '$', '.--.-.': '@', '/': ' '
}

def extract_envelope(audio, sample_rate, smooth_window=0.01):
    """Extract signal envelope"""
    # Bandpass filter for typical CW frequency (500-1500 Hz)
    nyquist = sample_rate / 2
    b, a = signal.butter(4, [300/nyquist, 2000/nyquist], btype='band')
    filtered = signal.filtfilt(b, a, audio)
    
    # Get envelope via Hilbert transform
    analytic = signal.hilbert(filtered)
    envelope = np.abs(analytic)
    
    # Smooth envelope
    window_samples = int(smooth_window * sample_rate)
    if window_samples % 2 == 0:
        window_samples += 1
    envelope_smooth = signal.medfilt(envelope, window_samples)
    
    return envelope_smooth

def detect_pulses(envelope, sample_rate, threshold_factor=0.3):
    """Detect Morse pulses (on/off periods)"""
    # Threshold detection
    threshold = np.max(envelope) * threshold_factor
    binary = envelope > threshold
    
    # Find transitions
    diff = np.diff(binary.astype(int))
    rising_edges = np.where(diff == 1)[0]
    falling_edges = np.where(diff == -1)[0]
    
    # Extract pulse durations
    pulses = []  # (start_time, duration, is_on)
    
    if len(rising_edges) == 0 or len(falling_edges) == 0:
        return pulses
    
    # Start with first transition
    if rising_edges[0] < falling_edges[0]:
        # Signal starts with ON
        for i in range(min(len(rising_edges), len(falling_edges))):
            start = rising_edges[i] / sample_rate
            duration = (falling_edges[i] - rising_edges[i]) / sample_rate
            pulses.append((start, duration, True))
            
            if i < len(rising_edges) - 1:
                gap_duration = (rising_edges[i+1] - falling_edges[i]) / sample_rate
                pulses.append((falling_edges[i] / sample_rate, gap_duration, False))
    else:
        # Signal starts with OFF
        for i in range(min(len(rising_edges), len(falling_edges))):
            if i > 0:
                gap_duration = (rising_edges[i] - falling_edges[i-1]) / sample_rate
                pulses.append((falling_edges[i-1] / sample_rate, gap_duration, False))
            
            start = rising_edges[i] / sample_rate
            duration = (falling_edges[i] - rising_edges[i]) / sample_rate
            pulses.append((start, duration, True))
    
    return pulses

def decode_morse_timing(pulses):
    """Decode Morse from timing information"""
    if not pulses:
        return ""
    
    # Calculate unit timing (shortest pulse is typically a dot)
    on_durations = [p[1] for p in pulses if p[2]]
    if not on_durations:
        return ""
    
    unit_time = min(on_durations)
    
    # Decode pulses to dots and dashes
    morse_chars = []
    current_char = []
    
    for i, (start, duration, is_on) in enumerate(pulses):
        if is_on:
            # Determine if dot or dash
            units = duration / unit_time
            if units < 2:
                current_char.append('.')
            else:
                current_char.append('-')
        else:
            # Gap determines character or word boundary
            units = duration / unit_time
            if units > 5:  # Word space
                if current_char:
                    morse_chars.append(''.join(current_char))
                morse_chars.append('/')
                current_char = []
            elif units > 2:  # Character space
                if current_char:
                    morse_chars.append(''.join(current_char))
                current_char = []
    
    # Add last character
    if current_char:
        morse_chars.append(''.join(current_char))
    
    # Decode to text
    decoded = []
    for morse_char in morse_chars:
        if morse_char in MORSE_CODE:
            decoded.append(MORSE_CODE[morse_char])
        elif morse_char == '/':
            decoded.append(' ')
        else:
            decoded.append('?')
    
    return ''.join(decoded)

if __name__ == "__main__":
    import sys
    
    if len(sys.argv) < 2:
        print("Usage: python3 morse_decoder.py audio.wav")
        sys.exit(1)
    
    filename = sys.argv[1]
    sample_rate, audio = wavfile.read(filename)
    
    if len(audio.shape) == 2:
        audio = audio.mean(axis=1)
    
    audio = audio.astype(float) / np.max(np.abs(audio))
    
    print(f"Analyzing {filename}...")
    print(f"Sample rate: {sample_rate} Hz\n")
    
    # Extract envelope
    envelope = extract_envelope(audio, sample_rate)
    
    # Detect pulses
    pulses = detect_pulses(envelope, sample_rate)
    
    print(f"Detected {len(pulses)} pulses\n")
    print("Pulse timing:")
    print(f"{'Time (s)':<12} {'Duration (s)':<15} {'Type'}")
    print("-" * 40)
    for start, duration, is_on in pulses[:20]:  # Show first 20
        pulse_type = "ON" if is_on else "OFF"
        print(f"{start:<12.3f} {duration:<15.4f} {pulse_type}")
    if len(pulses) > 20:
        print(f"... and {len(pulses) - 20} more pulses")
    
    # Decode
    decoded = decode_morse_timing(pulses)
    
    print(f"\n{'='*50}")
    print(f"Decoded message: {decoded}")
    print(f"{'='*50}")
    
    # Save envelope visualization
    import matplotlib.pyplot as plt
    time = np.arange(len(envelope)) / sample_rate
    plt.figure(figsize=(16, 6))
    plt.plot(time, envelope)
    plt.xlabel('Time (s)')
    plt.ylabel('Envelope Amplitude')
    plt.title('Morse Code Envelope')
    plt.grid(True, alpha=0.3)
    plt.savefig('morse_envelope.png', dpi=300)
    print("\nEnvelope visualization saved to morse_envelope.png")
```

**Visual Morse Code Analysis:**

python

```python
#!/usr/bin/env python3
"""
Visual analysis of Morse code patterns
"""
import numpy as np
from scipy import signal
from scipy.io import wavfile
import matplotlib.pyplot as plt

sample_rate, audio = wavfile.read('morse_audio.wav')
if len(audio.shape) == 2:
    audio = audio.mean(axis=1)

audio = audio.astype(float) / np.max(np.abs(audio))

# Filter for CW tone
nyquist = sample_rate / 2
b, a = signal.butter(4, [400/nyquist, 1500/nyquist], btype='band')
filtered = signal.filtfilt(b, a, audio)

# Extract envelope
envelope = np.abs(signal.hilbert(filtered))

# Smooth
window = signal.windows.hann(int(0.01 * sample_rate))
envelope_smooth = signal.convolve(envelope, window, mode='same') / sum(window)

# Time array
time = np.arange(len(audio)) / sample_rate

# Plot
fig, axes = plt.subplots(3, 1, figsize=(16, 10))

# Original waveform
axes[0].plot(time, audio, linewidth=0.5)
axes[0].set_title('Original Audio Waveform')
axes[0].set_ylabel('Amplitude')
axes[0].grid(True, alpha=0.3)

# Filtered signal
axes[1].plot(time, filtered, linewidth=0.5)
axes[1].set_title('Bandpass Filtered (CW Tone)')
axes[1].set_ylabel('Amplitude')
axes[1].grid(True, alpha=0.3)

# Envelope with threshold
axes[2].plot(time, envelope_smooth, linewidth=1.5, label='Envelope')
threshold = np.max(envelope_smooth) * 0.3
axes[2].axhline(threshold, color='r', linestyle='--', label='Threshold')
binary = envelope_smooth > threshold
axes[2].fill_between(time, 0, np.max(envelope_smooth), 
                      where=binary, alpha=0.3, label='Detected Pulses')
axes[2].set_title('Envelope and Pulse Detection')
axes[2].set_ylabel('Amplitude')
axes[2].set_xlabel('Time (s)')
axes[2].legend()
axes[2].grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('morse_analysis.png', dpi=300)
print("Analysis saved to morse_analysis.png")
```

#### Spectrogram-based Morse Detection

When Morse code is visually encoded in a spectrogram:

bash

```bash
# Generate high-contrast spectrogram
sox morse_audio.wav -n spectrogram -x 4000 -y 800 -z 120 -m -o morse_spec.png

# Enhance contrast
convert morse_spec.png -contrast-stretch 0 -threshold 50% morse_binary.png
```

python

```python
#!/usr/bin/env python3
"""
Decode Morse from spectrogram image
"""
from PIL import Image
import numpy as np

# Load spectrogram image
img = Image.open('morse_spec.png').convert('L')
img_array = np.array(img)

# Invert if necessary (Morse should be white on black)
if np.mean(img_array) > 128:
    img_array = 255 - img_array

# Threshold to binary
threshold = np.percentile(img_array, 90)
binary = img_array > threshold

# Sum along frequency axis to get time series
time_series = np.sum(binary, axis=0)

# Normalize
time_series = time_series / np.max(time_series)

# Detect on/off periods
threshold = 0.3
on_periods = time_series > threshold

# Find transitions
diff = np.diff(on_periods.astype(int))
rising = np.where(diff == 1)[0]
falling = np.where(diff == -1)[0]

print(f"Detected {len(rising)} Morse elements")

# Convert to dots and dashes based on duration
durations = []
for i in range(min(len(rising), len(falling))):
    duration = falling[i] - rising[i]
    durations.append(duration)

if durations:
    unit = min(durations)
    morse = []
    for dur in durations:
        units = dur / unit
        if units < 2:
            morse.append('.')
        else:
            morse.append('-')
    
    print(f"Morse pattern: {''.join(morse)}")
```

### Comprehensive Audio Analysis Script

bash

```bash
#!/bin/bash
# Complete audio analysis workflow for CTFs

AUDIO_FILE="$1"
OUTPUT_DIR="audio_analysis"

if [ -z "$AUDIO_FILE" ]; then
    echo "Usage: $0 <audio_file>"
    exit 1
fi

mkdir -p "$OUTPUT_DIR"

echo "[*] Starting comprehensive audio analysis..."

# 1. Basic file information
echo "[+] File information:"
file "$AUDIO_FILE"
soxi "$AUDIO_FILE"

# 2. Generate spectrograms
echo "[+] Generating spectrograms..."
sox "$AUDIO_FILE" -n spectrogram -x 4000 -y 1025 -z 120 -o "$OUTPUT_DIR/spectrogram_standard.png"
sox "$AUDIO_FILE" -n spectrogram -x 8000 -y 2049 -z 120 -o "$OUTPUT_DIR/spectrogram_hires.png"
sox "$AUDIO_FILE" -n spectrogram -m -o "$OUTPUT_DIR/spectrogram_mono.png"
sox "$AUDIO_FILE" -n spectrogram -Z -o "$OUTPUT_DIR/spectrogram_linear.png"

# 3. Frequency analysis
echo "[+] Extracting frequency bands..."
sox "$AUDIO_FILE" "$OUTPUT_DIR/lowfreq.wav" lowpass 3000
sox "$AUDIO_FILE" "$OUTPUT_DIR/midfreq.wav" bandpass 3000 5000
sox "$AUDIO_FILE" "$OUTPUT_DIR/highfreq.wav" highpass 8000

# 4. Check for ultrasonic content
sox "$AUDIO_FILE" "$OUTPUT_DIR/ultrasonic.wav" highpass 18000
sox "$OUTPUT_DIR/ultrasonic.wav" -n stat 2>&1 | grep "RMS"

# 5. DTMF detection
echo "[+] Detecting DTMF tones..."
multimon-ng -t wav -a DTMF "$AUDIO_FILE" 2>&1 | tee "$OUTPUT_DIR/dtmf_output.txt"

# 6. Morse code detection
echo "[+] Detecting Morse code..."
multimon-ng -t wav -a MORSE_CW "$AUDIO_FILE" 2>&1 | tee "$OUTPUT_DIR/morse_output.txt"

# 7. Extract metadata
echo "[+] Extracting metadata..."
exiftool "$AUDIO_FILE" > "$OUTPUT_DIR/metadata.txt"

# 8. Strings extraction
echo "[+] Extracting strings..."
strings "$AUDIO_FILE" > "$OUTPUT_DIR/strings.txt"

# 9. Hex dump analysis
xxd "$AUDIO_FILE" > "$OUTPUT_DIR/hexdump.txt"

# 10. Check for embedded files
echo "[+] Checking for embedded files..."
binwalk "$AUDIO_FILE" | tee "$OUTPUT_DIR/binwalk.txt"
foremost -i "$AUDIO_FILE" -o "$OUTPUT_DIR/foremost_output"

echo "[*] Analysis complete. Results in $OUTPUT_DIR/"
```

### Important Subtopics for Further Study

- **Phase Analysis**: Hidden data in phase relationships between stereo channels
- **LSB Audio Steganography**: Least significant bit extraction and analysis
- **Audio Watermarking Detection**: Identifying embedded digital watermarks
- **Binaural Beats Analysis**: Frequency difference encoding between channels
- **Amplitude Modulation Demodulation**: Extracting data from AM-encoded signals
- **SSTV (Slow-Scan Television) Decoding**: Image transmission via audio

---

## Audio Metadata

### ID3 Tags (v1, v2)

ID3 tags are metadata containers primarily used in MP3 files. They store information like artist, title, album, and can be exploited to hide data in CTF challenges.

**ID3v1 Structure**

ID3v1 tags are stored in the last 128 bytes of an MP3 file with a fixed structure:

- Bytes 0-2: "TAG" identifier
- Bytes 3-32: Title (30 bytes)
- Bytes 33-62: Artist (30 bytes)
- Bytes 63-92: Album (30 bytes)
- Bytes 93-96: Year (4 bytes)
- Bytes 97-126: Comment (30 bytes, or 28 bytes + track number in v1.1)
- Byte 127: Genre (1 byte)

**ID3v2 Structure**

ID3v2 tags are located at the beginning of MP3 files and use a frame-based structure. Each frame has:

- Frame ID (4 bytes): TXXX, APIC, COMM, etc.
- Size (4 bytes)
- Flags (2 bytes)
- Data (variable length)

**Extracting ID3 Tags**

Using **id3v2** (command-line):

```bash
# Display all ID3 tags
id3v2 -l audio.mp3

# Display in detailed format
id3v2 -R audio.mp3

# List only ID3v2 tags
id3v2 -L audio.mp3

# Remove all ID3 tags (useful for comparison)
id3v2 -D audio.mp3

# Strip ID3v1 only
id3v2 -s audio.mp3

# Strip ID3v2 only
id3v2 -d audio.mp3
```

Using **exiftool**:

```bash
# Extract all metadata
exiftool audio.mp3

# Extract only ID3 tags
exiftool -ID3* audio.mp3

# Detailed format with group names
exiftool -a -G1 -s audio.mp3

# Extract to text file
exiftool audio.mp3 > metadata.txt

# Extract specific fields
exiftool -Comment -Lyrics -Description audio.mp3

# Show binary data in hex
exiftool -b -ID3 audio.mp3 | xxd
```

Using **ffprobe** (part of FFmpeg):

```bash
# Display all metadata
ffprobe -v quiet -show_format -show_streams audio.mp3

# Extract only metadata
ffprobe -v quiet -show_entries format_tags -of default=noprint_wrappers=1 audio.mp3

# JSON output for parsing
ffprobe -v quiet -print_format json -show_format audio.mp3
```

Using **mutagen-inspect** (Python library):

```bash
# Install mutagen
pip3 install mutagen

# Inspect file
mid3v2 -l audio.mp3

# List all frames
mutagen-inspect audio.mp3
```

**Manual ID3 Extraction with Hexdump**

```bash
# Check for ID3v2 header (first 10 bytes)
xxd -l 10 audio.mp3

# Extract ID3v2 size (bytes 6-9, synchsafe integer)
xxd -l 10 audio.mp3 | head -1

# View last 128 bytes (ID3v1)
xxd -s -128 audio.mp3

# Extract ID3v1 directly
tail -c 128 audio.mp3 | xxd

# Verify "TAG" identifier for ID3v1
tail -c 128 audio.mp3 | head -c 3
```

**Python Script for ID3 Parsing**:

```python
from mutagen.id3 import ID3
from mutagen.mp3 import MP3
import sys

def extract_id3_tags(filename):
    try:
        # Parse ID3v2
        audio = ID3(filename)
        print("[ID3v2 Tags]")
        for tag in audio.keys():
            print(f"{tag}: {audio[tag]}")
            
        # Access specific frames
        if 'TXXX' in audio:
            for txxx in audio.getall('TXXX'):
                print(f"User Text: {txxx.desc} = {txxx.text}")
        
        if 'COMM' in audio:
            for comm in audio.getall('COMM'):
                print(f"Comment: {comm.desc} = {comm.text}")
                
        # Check for unusual frames
        print("\n[Unusual/Custom Frames]")
        standard_frames = ['TIT2', 'TPE1', 'TALB', 'TDRC', 'TRCK', 'APIC']
        for tag in audio.keys():
            if tag not in standard_frames:
                print(f"{tag}: {audio[tag]}")
                
    except Exception as e:
        print(f"Error reading ID3v2: {e}")
    
    # Check for ID3v1
    try:
        with open(filename, 'rb') as f:
            f.seek(-128, 2)
            id3v1_data = f.read(128)
            if id3v1_data[:3] == b'TAG':
                print("\n[ID3v1 Tags]")
                print(f"Title: {id3v1_data[3:33].decode('latin-1').strip()}")
                print(f"Artist: {id3v1_data[33:63].decode('latin-1').strip()}")
                print(f"Album: {id3v1_data[63:93].decode('latin-1').strip()}")
                print(f"Year: {id3v1_data[93:97].decode('latin-1').strip()}")
                print(f"Comment: {id3v1_data[97:127].decode('latin-1').strip()}")
                print(f"Genre: {id3v1_data[127]}")
    except Exception as e:
        print(f"Error reading ID3v1: {e}")

if __name__ == "__main__":
    extract_id3_tags(sys.argv[1])
```

**Extracting Hidden Data from ID3 Tags**

```bash
# Extract raw comment field
exiftool -b -Comment audio.mp3 > comment.txt

# Extract lyrics (often used for hiding data)
exiftool -b -Lyrics audio.mp3 > lyrics.txt

# Extract user-defined text (TXXX frames)
ffmpeg -i audio.mp3 -f ffmetadata metadata.txt

# Check for base64-encoded data in comments
exiftool -Comment audio.mp3 | cut -d: -f2- | base64 -d

# Extract all text frames to files
python3 << 'EOF'
from mutagen.id3 import ID3

audio = ID3('audio.mp3')
for tag in audio.keys():
    if tag.startswith('T') or tag == 'COMM':
        with open(f'tag_{tag}.txt', 'w') as f:
            f.write(str(audio[tag]))
EOF
```

**ID3 Tag Modification/Testing**

```bash
# Add custom comment
id3v2 -c "Hidden message here" audio.mp3

# Add user-defined text
mid3v2 --TXXX "flag:CTF{example}" audio.mp3

# Add lyrics
mid3v2 --USLT "Hidden lyrics content" audio.mp3

# Remove specific frame
python3 << 'EOF'
from mutagen.id3 import ID3

audio = ID3('audio.mp3')
audio.delall('COMM')
audio.save()
EOF
```

**Detecting Anomalies in ID3 Tags**

[Inference] Unusual ID3 characteristics that may indicate hidden data:

- Oversized comment or lyrics fields
- Non-standard frame types (PRIV, UFID, custom TXXX)
- Multiple instances of same frame type
- Binary data in text frames
- Discrepancies between ID3v1 and ID3v2 content

```python
from mutagen.id3 import ID3
import sys

def detect_id3_anomalies(filename):
    audio = ID3(filename)
    
    print("[Anomaly Detection]")
    
    # Check for oversized frames
    for tag in audio.keys():
        frame_size = len(str(audio[tag]))
        if frame_size > 1000:
            print(f"Large frame detected: {tag} ({frame_size} bytes)")
    
    # Check for duplicate frames
    frame_counts = {}
    for tag in audio.keys():
        frame_type = tag[:4]
        frame_counts[frame_type] = frame_counts.get(frame_type, 0) + 1
    
    for frame_type, count in frame_counts.items():
        if count > 1:
            print(f"Duplicate frame type: {frame_type} (x{count})")
    
    # Check for private/unknown frames
    private_frames = ['PRIV', 'UFID', 'GEOB', 'OWNE', 'COMR']
    for frame in private_frames:
        if frame in audio:
            print(f"Private/unusual frame found: {frame}")
    
    # Check for non-ASCII data in text frames
    for tag in audio.keys():
        if tag.startswith('T') or tag == 'COMM':
            try:
                data = str(audio[tag]).encode('ascii')
            except UnicodeEncodeError:
                print(f"Non-ASCII data in {tag}")

detect_id3_anomalies(sys.argv[1])
```

### Vorbis Comments

Vorbis Comments are metadata tags used in OGG Vorbis, FLAC, Opus, and other Xiph.Org formats. They use a simple key=value structure.

**Vorbis Comment Structure**

Vorbis Comments consist of:

- Vendor string (length + UTF-8 string)
- Comment count (32-bit integer)
- Comments (each: length + UTF-8 string in "KEY=value" format)

Standard fields include: TITLE, ARTIST, ALBUM, DATE, TRACKNUMBER, GENRE, DESCRIPTION, COMMENT

**Extracting Vorbis Comments**

Using **vorbiscomment** (vorbis-tools):

```bash
# List all comments
vorbiscomment -l audio.ogg

# List comments from FLAC
metaflac --list --block-type=VORBIS_COMMENT audio.flac

# Export to file
vorbiscomment -l audio.ogg > comments.txt

# Export in raw format
vorbiscomment -R audio.ogg > raw_comments.txt
```

Using **exiftool**:

```bash
# Extract all metadata
exiftool audio.ogg
exiftool audio.flac

# Extract only Vorbis Comments
exiftool -Vorbis* audio.ogg

# Binary extraction
exiftool -b -Comment audio.ogg > comment_data.bin
```

Using **ffprobe**:

```bash
# Extract metadata from OGG
ffprobe -v quiet -show_entries format_tags -of default=noprint_wrappers=1 audio.ogg

# Extract from FLAC
ffprobe -v quiet -print_format json -show_format audio.flac

# Extract specific comment
ffprobe -v error -show_entries format_tags=comment -of default=noprint_wrappers=1:nokey=1 audio.ogg
```

Using **metaflac** (for FLAC files):

```bash
# Show all tags
metaflac --list audio.flac

# Show only Vorbis Comments
metaflac --show-tag=TITLE audio.flac
metaflac --show-tag=COMMENT audio.flac

# Export all tags
metaflac --export-tags-to=tags.txt audio.flac

# Show all comment fields
metaflac --list --block-type=VORBIS_COMMENT audio.flac

# Count comment blocks
metaflac --list --block-number=1 audio.flac
```

**Python Script for Vorbis Comment Extraction**:

```python
from mutagen.oggvorbis import OggVorbis
from mutagen.flac import FLAC
import sys

def extract_vorbis_comments(filename):
    try:
        if filename.endswith('.ogg'):
            audio = OggVorbis(filename)
        elif filename.endswith('.flac'):
            audio = FLAC(filename)
        else:
            print("Unsupported format")
            return
        
        print("[Vorbis Comments]")
        for key, value in audio.items():
            print(f"{key}: {value}")
        
        # Check for unusual or custom fields
        print("\n[Custom/Non-Standard Fields]")
        standard_fields = ['TITLE', 'ARTIST', 'ALBUM', 'DATE', 
                          'TRACKNUMBER', 'GENRE', 'DESCRIPTION']
        
        for key in audio.keys():
            if key.upper() not in standard_fields:
                print(f"{key}: {audio[key]}")
        
        # Check for multiple values in same field
        print("\n[Multi-Value Fields]")
        for key, value in audio.items():
            if isinstance(value, list) and len(value) > 1:
                print(f"{key}: {len(value)} values")
                for idx, val in enumerate(value):
                    print(f"  [{idx}]: {val}")
        
        # Check for base64 or hex patterns
        import re
        print("\n[Encoded Data Detection]")
        for key, value in audio.items():
            val_str = str(value)
            if re.match(r'^[A-Za-z0-9+/]+=*$', val_str) and len(val_str) > 20:
                print(f"Possible base64 in {key}: {val_str[:50]}...")
            elif re.match(r'^[0-9a-fA-F]+$', val_str) and len(val_str) > 20:
                print(f"Possible hex in {key}: {val_str[:50]}...")
                
    except Exception as e:
        print(f"Error: {e}")

if __name__ == "__main__":
    extract_vorbis_comments(sys.argv[1])
```

**Extracting Hidden Data from Vorbis Comments**

```bash
# Extract specific comment to file
vorbiscomment -l audio.ogg | grep "COMMENT=" | cut -d= -f2- > comment.txt

# Extract description field
metaflac --show-tag=DESCRIPTION audio.flac > description.txt

# Try decoding as base64
vorbiscomment -l audio.ogg | grep "FLAG=" | cut -d= -f2- | base64 -d

# Extract all non-standard tags
vorbiscomment -l audio.ogg | grep -v -E "^(TITLE|ARTIST|ALBUM|DATE|GENRE)=" > custom_tags.txt

# Check for binary data in comments
python3 << 'EOF'
from mutagen.oggvorbis import OggVorbis

audio = OggVorbis('audio.ogg')
for key, value in audio.items():
    val_str = str(value)
    # Check for non-printable characters
    if any(ord(c) < 32 or ord(c) > 126 for c in val_str):
        print(f"Binary data in {key}")
        with open(f'comment_{key}.bin', 'wb') as f:
            f.write(val_str.encode('utf-8', errors='surrogateescape'))
EOF
```

**Adding/Modifying Vorbis Comments**

```bash
# Add comment to OGG
vorbiscomment -a -t "FLAG=CTF{example}" audio.ogg

# Add comment to FLAC
metaflac --set-tag="COMMENT=Hidden data" audio.flac

# Write comments from file
vorbiscomment -w -c comments.txt audio.ogg

# Remove all comments
vorbiscomment -w /dev/null audio.ogg
metaflac --remove-all-tags audio.flac

# Replace specific tag
metaflac --remove-tag=COMMENT audio.flac
metaflac --set-tag="COMMENT=New value" audio.flac
```

**Detecting Vorbis Comment Anomalies**

```python
from mutagen.oggvorbis import OggVorbis
from mutagen.flac import FLAC
import sys
import re

def detect_vorbis_anomalies(filename):
    if filename.endswith('.ogg'):
        audio = OggVorbis(filename)
    elif filename.endswith('.flac'):
        audio = FLAC(filename)
    
    print("[Anomaly Detection]")
    
    # Check for oversized fields
    for key, value in audio.items():
        val_size = len(str(value))
        if val_size > 5000:
            print(f"Large field: {key} ({val_size} bytes)")
    
    # Check for unusual field names
    unusual_pattern = re.compile(r'[^A-Z0-9_]')
    for key in audio.keys():
        if unusual_pattern.search(key):
            print(f"Non-standard field name: {key}")
    
    # Check for excessive number of tags
    if len(audio.keys()) > 20:
        print(f"Excessive tag count: {len(audio.keys())}")
    
    # Check for duplicate standard fields
    standard = ['TITLE', 'ARTIST', 'ALBUM']
    for field in standard:
        if field in audio and isinstance(audio[field], list):
            if len(audio[field]) > 1:
                print(f"Duplicate standard field: {field} (x{len(audio[field])})")

detect_vorbis_anomalies(sys.argv[1])
```

### APE Tags

APE (Audio Processing Extension) tags are primarily used in Monkey's Audio (.ape) files but also supported in MP3, MPC, and WavPack formats.

**APE Tag Structure**

APEv2 tags consist of:

- Footer/Header (32 bytes) with "APETAGEX" identifier
- Tag items with key-value pairs
- Each item: length (4 bytes) + flags (4 bytes) + key (null-terminated) + value

**Extracting APE Tags**

Using **apetag** (Python tool):

```bash
# Install apetag
pip3 install apetag

# Display tags
python3 -m apetag list audio.ape

# Show detailed information
python3 -m apetag dump audio.ape
```

Using **exiftool**:

```bash
# Extract APE tags
exiftool audio.ape
exiftool audio.mp3  # APE tags may exist in MP3

# Extract specific APE fields
exiftool -APE* audio.ape

# Show in hex
exiftool -b -APE:all audio.ape | xxd

# Detailed output
exiftool -a -G1 -s audio.ape
```

Using **ffprobe**:

```bash
# Extract metadata
ffprobe -v quiet -show_format -show_streams audio.ape

# Get APE tag data
ffprobe -v quiet -show_entries format_tags -of json audio.ape
```

**Manual APE Tag Extraction**:

```bash
# Check for APEv2 footer (last 32 bytes)
tail -c 32 audio.ape | xxd

# Look for "APETAGEX" identifier
strings audio.ape | grep -i apetagex

# Extract tag data
python3 << 'EOF'
import struct

with open('audio.ape', 'rb') as f:
    # Read footer (last 32 bytes)
    f.seek(-32, 2)
    footer = f.read(32)
    
    if footer[:8] == b'APETAGEX':
        version = struct.unpack('<I', footer[8:12])[0]
        tag_size = struct.unpack('<I', footer[12:16])[0]
        item_count = struct.unpack('<I', footer[16:20])[0]
        
        print(f"APE Version: {version}")
        print(f"Tag Size: {tag_size}")
        print(f"Item Count: {item_count}")
        
        # Read tag data
        f.seek(-(32 + tag_size), 2)
        tag_data = f.read(tag_size)
        
        # Parse items
        offset = 0
        for i in range(item_count):
            item_length = struct.unpack('<I', tag_data[offset:offset+4])[0]
            item_flags = struct.unpack('<I', tag_data[offset+4:offset+8])[0]
            offset += 8
            
            key_end = tag_data.index(b'\x00', offset)
            key = tag_data[offset:key_end].decode('utf-8')
            offset = key_end + 1
            
            value = tag_data[offset:offset+item_length]
            offset += item_length
            
            print(f"{key}: {value[:100]}")  # Print first 100 bytes
EOF
```

**Python Script for APE Tag Extraction**:

```python
import struct
import sys

def extract_ape_tags(filename):
    with open(filename, 'rb') as f:
        # Check for APEv2 footer
        f.seek(-32, 2)
        footer = f.read(32)
        
        if footer[:8] != b'APETAGEX':
            print("No APEv2 tag found")
            return
        
        version = struct.unpack('<I', footer[8:12])[0]
        tag_size = struct.unpack('<I', footer[12:16])[0]
        item_count = struct.unpack('<I', footer[16:20])[0]
        flags = struct.unpack('<I', footer[20:24])[0]
        
        print(f"[APE Tag Header]")
        print(f"Version: {version}")
        print(f"Tag Size: {tag_size} bytes")
        print(f"Item Count: {item_count}")
        print(f"Flags: {flags:08x}")
        
        # Read tag items
        f.seek(-(32 + tag_size), 2)
        tag_data = f.read(tag_size)
        
        print(f"\n[APE Tag Items]")
        offset = 0
        for i in range(item_count):
            if offset + 8 > len(tag_data):
                break
                
            item_length = struct.unpack('<I', tag_data[offset:offset+4])[0]
            item_flags = struct.unpack('<I', tag_data[offset+4:offset+8])[0]
            offset += 8
            
            # Find null terminator for key
            key_end = tag_data.find(b'\x00', offset)
            if key_end == -1:
                break
                
            key = tag_data[offset:key_end].decode('utf-8', errors='replace')
            offset = key_end + 1
            
            # Extract value
            if offset + item_length > len(tag_data):
                break
            value = tag_data[offset:offset+item_length]
            offset += item_length
            
            # Determine value type from flags
            value_type = item_flags & 3
            if value_type == 0:  # UTF-8 text
                try:
                    value_str = value.decode('utf-8')
                    print(f"{key}: {value_str}")
                except:
                    print(f"{key}: [binary data, {len(value)} bytes]")
            elif value_type == 1:  # Binary
                print(f"{key}: [binary data, {len(value)} bytes]")
                with open(f'ape_{key}.bin', 'wb') as out:
                    out.write(value)
            elif value_type == 2:  # External reference
                print(f"{key}: [external reference]")
        
        # Check for header at beginning
        f.seek(0)
        header = f.read(32)
        if header[:8] == b'APETAGEX':
            print("\n[Note] APE header also present at file beginning")

if __name__ == "__main__":
    extract_ape_tags(sys.argv[1])
```

**Extracting Hidden Data from APE Tags**

```bash
# Extract specific tag
exiftool -APE:Comment audio.ape > comment.txt

# Check for binary items
python3 << 'EOF'
import struct

with open('audio.ape', 'rb') as f:
    f.seek(-32, 2)
    footer = f.read(32)
    tag_size = struct.unpack('<I', footer[12:16])[0]
    item_count = struct.unpack('<I', footer[16:20])[0]
    
    f.seek(-(32 + tag_size), 2)
    tag_data = f.read(tag_size)
    
    offset = 0
    for i in range(item_count):
        item_length = struct.unpack('<I', tag_data[offset:offset+4])[0]
        item_flags = struct.unpack('<I', tag_data[offset+4:offset+8])[0]
        offset += 8
        
        key_end = tag_data.find(b'\x00', offset)
        key = tag_data[offset:key_end].decode('utf-8', errors='replace')
        offset = key_end + 1
        
        value = tag_data[offset:offset+item_length]
        offset += item_length
        
        # Extract binary items
        if (item_flags & 3) == 1:  # Binary flag
            print(f"Binary item: {key}")
            with open(f'{key}.bin', 'wb') as out:
                out.write(value)
EOF
```

**APE Tag Manipulation**:

```bash
# Add APE tag using Python
python3 << 'EOF'
from mutagen.apev2 import APEv2, APEv2File

audio = APEv2File('audio.ape')
audio['Comment'] = 'Hidden data here'
audio.save()
EOF

# Remove APE tags
python3 -m apetag remove audio.ape
```

**Detecting APE Tag Anomalies**:

```python
import struct

def detect_ape_anomalies(filename):
    with open(filename, 'rb') as f:
        f.seek(-32, 2)
        footer = f.read(32)
        
        if footer[:8] != b'APETAGEX':
            return
        
        tag_size = struct.unpack('<I', footer[12:16])[0]
        item_count = struct.unpack('<I', footer[16:20])[0]
        
        print("[APE Anomaly Detection]")
        
        # Check for unusually large tag
        if tag_size > 100000:
            print(f"Unusually large tag: {tag_size} bytes")
        
        # Check for excessive item count
        if item_count > 50:
            print(f"Excessive item count: {item_count}")
        
        # Parse and check items
        f.seek(-(32 + tag_size), 2)
        tag_data = f.read(tag_size)
        
        offset = 0
        binary_items = []
        large_items = []
        
        for i in range(item_count):
            item_length = struct.unpack('<I', tag_data[offset:offset+4])[0]
            item_flags = struct.unpack('<I', tag_data[offset+4:offset+8])[0]
            offset += 8
            
            key_end = tag_data.find(b'\x00', offset)
            key = tag_data[offset:key_end].decode('utf-8', errors='replace')
            offset = key_end + 1 + item_length
            
            # Check for binary items
            if (item_flags & 3) == 1:
                binary_items.append(key)
            
            # Check for large items
            if item_length > 10000:
                large_items.append((key, item_length))
        
        if binary_items:
            print(f"Binary items found: {', '.join(binary_items)}")
        
        for key, size in large_items:
            print(f"Large item: {key} ({size} bytes)")

detect_ape_anomalies('audio.ape')
```

### Embedded Cover Art

Cover art (album artwork) embedded in audio files can contain hidden data through steganography or be replaced with images containing hidden information.

**Extracting Cover Art**

Using **exiftool**:

```bash
# Extract cover art from MP3 (ID3 APIC frame)
exiftool -b -Picture audio.mp3 > cover.jpg

# Extract from M4A/MP4
exiftool -b -CoverArt audio.m4a > cover.jpg

# Extract from FLAC
metaflac --export-picture-to=cover.jpg audio.flac

# Extract from OGG (less common)
ffmpeg -i audio.ogg -an -c:v copy cover.jpg

# Check if cover art exists
exiftool -Picture audio.mp3
exiftool -CoverArt audio.m4a
metaflac --list --block-type=PICTURE audio.flac
```

Using **ffmpeg**:

```bash
# Extract cover art (auto-detect format)
ffmpeg -i audio.mp3 -an -c:v copy cover.jpg
ffmpeg -i audio.flac -an -c:v copy cover.png

# Extract all video streams (may include multiple artwork)
ffmpeg -i audio.m4a -map 0:v -c copy cover_%d.jpg

# Get information about embedded images
ffprobe -v error -show_entries stream=index,codec_name,codec_type -of default audio.mp3
```

Using **Python (Mutagen)**:

```python
from mutagen.id3 import ID3, APIC
from mutagen.mp4 import MP4
from mutagen.flac import FLAC, Picture
from mutagen.oggvorbis import OggVorbis
import base64
import sys

def extract_cover_art(filename):
    if filename.endswith('.mp3'):
        # MP3 with ID3
        audio = ID3(filename)
        apic_frames = audio.getall('APIC')
        
        for idx, apic in enumerate(apic_frames):
            print(f"[APIC Frame {idx}]")
            print(f"Type: {apic.type} ({['Other', 'File icon', '32x32 icon', 
                   'Front cover', 'Back cover', 'Leaflet', 'Media', 
                   'Lead artist', 'Artist', 'Conductor', 'Band', 
                   'Composer', 'Lyricist', 'Recording location', 
                   'During recording', 'During performance', 
                   'Video capture', 'Fish', 'Illustration', 
                   'Band logotype', 'Publisher logotype'][apic.type]})")
            print(f"MIME: {apic.mime}")
            print(f"Description: {apic.desc}")
            print(f"Size: {len(apic.data)} bytes")
            
            ext = 'jpg' if 'jpeg' in apic.mime.lower() else 'png'
            with open(f'cover_{idx}.{ext}', 'wb') as f:
                f.write(apic.data)
    
    elif filename.endswith('.m4a') or filename.endswith('.mp4'):
        # M4A/MP4
        audio = MP4(filename)
        if 'covr' in audio:
            for idx, cover in enumerate(audio['covr']):
                print(f"[Cover {idx}]")
                print(f"Format: {cover.imageformat}")
                print(f"Size: {len(cover)} bytes")
                
                ext = 'jpg' if cover.imageformat == MP4Cover.FORMAT_JPEG else 'png'
                with open(f'cover_{idx}.{ext}', 'wb') as f: f.write(cover)

elif filename.endswith('.flac'):
    # FLAC
    audio = FLAC(filename)
    for idx, picture in enumerate(audio.pictures):
        print(f"[Picture {idx}]")
        print(f"Type: {picture.type}")
        print(f"MIME: {picture.mime}")
        print(f"Description: {picture.desc}")
        print(f"Width: {picture.width}x{picture.height}")
        print(f"Depth: {picture.depth} bits")
        print(f"Size: {len(picture.data)} bytes")
        
        ext = picture.mime.split('/')[-1]
        with open(f'cover_{idx}.{ext}', 'wb') as f:
            f.write(picture.data)

elif filename.endswith('.ogg'):
    # OGG Vorbis (base64-encoded in metadata)
    audio = OggVorbis(filename)
    if 'metadata_block_picture' in audio:
        for idx, pic_data in enumerate(audio['metadata_block_picture']):
            pic_bytes = base64.b64decode(pic_data)
            # Parse FLAC picture block
            picture = Picture(pic_bytes)
            print(f"[Picture {idx}]")
            print(f"MIME: {picture.mime}")
            print(f"Size: {len(picture.data)} bytes")
            
            ext = picture.mime.split('/')[-1]
            with open(f'cover_{idx}.{ext}', 'wb') as f:
                f.write(picture.data)

if **name** == "**main**": extract_cover_art(sys.argv[1])
````

**Using metaflac for FLAC**:
```bash
# List all picture blocks
metaflac --list --block-type=PICTURE audio.flac

# Export specific picture block (block number from --list)
metaflac --export-picture-to=cover.jpg audio.flac

# Get picture metadata
metaflac --list --block-type=PICTURE audio.flac | grep -E "(type|MIME|description|width|height|depth|colors)"

# Export all pictures if multiple exist
for i in {0..5}; do
    metaflac --block-number=$i --export-picture-to=cover_$i.jpg audio.flac 2>/dev/null
done
````

**Manual Cover Art Extraction from MP3**:

```bash
# Find APIC frame in ID3v2
xxd audio.mp3 | grep -A 5 "APIC"

# Python script for manual extraction
python3 << 'EOF'
import struct

def find_apic_frames(filename):
    with open(filename, 'rb') as f:
        data = f.read()
        
        # Find ID3v2 header
        if data[:3] != b'ID3':
            print("No ID3v2 tag found")
            return
        
        # Parse ID3v2 size (synchsafe integer)
        size_bytes = data[6:10]
        tag_size = (size_bytes[0] << 21) | (size_bytes[1] << 14) | \
                   (size_bytes[2] << 7) | size_bytes[3]
        
        print(f"ID3v2 tag size: {tag_size} bytes")
        
        # Search for APIC frames
        offset = 10  # After ID3v2 header
        frame_count = 0
        
        while offset < tag_size:
            if offset + 10 > len(data):
                break
            
            frame_id = data[offset:offset+4]
            if frame_id == b'\x00\x00\x00\x00':
                break  # Padding
            
            # Frame size (synchsafe in v2.4, normal in v2.3)
            frame_size_bytes = data[offset+4:offset+8]
            frame_size = struct.unpack('>I', frame_size_bytes)[0]
            
            if frame_id == b'APIC':
                print(f"\n[APIC Frame at offset {offset}]")
                frame_data = data[offset+10:offset+10+frame_size]
                
                # Parse APIC structure
                encoding = frame_data[0]
                mime_end = frame_data.index(b'\x00', 1)
                mime_type = frame_data[1:mime_end].decode('ascii')
                
                picture_type = frame_data[mime_end + 1]
                desc_end = frame_data.index(b'\x00', mime_end + 2)
                description = frame_data[mime_end + 2:desc_end]
                
                image_data = frame_data[desc_end + 1:]
                
                print(f"MIME type: {mime_type}")
                print(f"Picture type: {picture_type}")
                print(f"Description: {description}")
                print(f"Image size: {len(image_data)} bytes")
                
                ext = 'jpg' if 'jpeg' in mime_type.lower() else 'png'
                with open(f'cover_{frame_count}.{ext}', 'wb') as out:
                    out.write(image_data)
                
                frame_count += 1
            
            offset += 10 + frame_size

find_apic_frames('audio.mp3')
EOF
```

**Analyzing Extracted Cover Art**

Once extracted, analyze the cover art image using visual analysis techniques:

```bash
# Check file type and metadata
file cover.jpg
exiftool cover.jpg
identify -verbose cover.jpg

# Run steganography detection tools
zsteg cover.png
steghide info cover.jpg
stegdetect cover.jpg

# Analyze with StegSolve
java -jar stegsolve.jar cover.jpg

# Check for embedded files
binwalk cover.jpg
foremost -i cover.jpg -o cover_extracted

# Extract strings
strings cover.jpg | less

# Check for trailing data
xxd cover.jpg | tail -n 50

# Compare file size with expected size
identify -format "%wx%h %[bit-depth] %m\n" cover.jpg
# Calculate expected size and compare
```

**Detecting Multiple or Suspicious Cover Art**

```python
from mutagen.id3 import ID3
from mutagen.mp4 import MP4
from mutagen.flac import FLAC
import sys

def detect_cover_anomalies(filename):
    print("[Cover Art Anomaly Detection]")
    
    if filename.endswith('.mp3'):
        audio = ID3(filename)
        apic_frames = audio.getall('APIC')
        
        if len(apic_frames) == 0:
            print("No cover art found")
        elif len(apic_frames) > 1:
            print(f"Multiple APIC frames: {len(apic_frames)}")
        
        for idx, apic in enumerate(apic_frames):
            size = len(apic.data)
            
            # Check for unusually large cover art
            if size > 5000000:  # 5MB
                print(f"APIC {idx}: Unusually large ({size} bytes)")
            
            # Check for unusual MIME types
            if apic.mime not in ['image/jpeg', 'image/jpg', 'image/png']:
                print(f"APIC {idx}: Unusual MIME type: {apic.mime}")
            
            # Check for non-standard picture types
            if apic.type not in [0, 3, 4, 6]:  # Common types
                print(f"APIC {idx}: Unusual picture type: {apic.type}")
            
            # Check image header
            header = apic.data[:4]
            if header[:2] == b'\xff\xd8':  # JPEG
                pass
            elif header == b'\x89PNG':  # PNG
                pass
            else:
                print(f"APIC {idx}: Unrecognized image format (header: {header.hex()})")
    
    elif filename.endswith('.flac'):
        audio = FLAC(filename)
        
        if len(audio.pictures) == 0:
            print("No cover art found")
        elif len(audio.pictures) > 1:
            print(f"Multiple pictures: {len(audio.pictures)}")
        
        for idx, picture in enumerate(audio.pictures):
            size = len(picture.data)
            
            if size > 5000000:
                print(f"Picture {idx}: Unusually large ({size} bytes)")
            
            # Check dimensions vs file size
            expected_min_size = picture.width * picture.height * 3 / 10  # Rough estimate
            if size > expected_min_size * 100:
                print(f"Picture {idx}: Size disproportionate to dimensions")
            
            # Check for mismatched MIME and actual format
            header = picture.data[:4]
            if 'jpeg' in picture.mime and header[:2] != b'\xff\xd8':
                print(f"Picture {idx}: MIME/format mismatch")
            elif 'png' in picture.mime and header != b'\x89PNG':
                print(f"Picture {idx}: MIME/format mismatch")

if __name__ == "__main__":
    detect_cover_anomalies(sys.argv[1])
```

**Embedding Cover Art (for testing)**

```bash
# Embed cover art in MP3 using id3v2
eyeD3 --add-image=cover.jpg:FRONT_COVER audio.mp3

# Using mid3v2 (mutagen)
mid3v2 --picture=cover.jpg audio.mp3

# Embed in FLAC
metaflac --import-picture-from=cover.jpg audio.flac

# Embed with description and type
metaflac --import-picture-from="3||||cover.jpg" audio.flac
# Type: 3=Front cover, 4=Back cover, etc.

# Embed in M4A using ffmpeg
ffmpeg -i audio.m4a -i cover.jpg -map 0 -map 1 -c copy -disposition:v:0 attached_pic output.m4a

# Remove cover art
eyeD3 --remove-images audio.mp3
metaflac --remove --block-type=PICTURE audio.flac
```

**Advanced Cover Art Analysis**

```python
from PIL import Image
import io
from mutagen.id3 import ID3
import hashlib

def advanced_cover_analysis(filename):
    audio = ID3(filename)
    apic_frames = audio.getall('APIC')
    
    for idx, apic in enumerate(apic_frames):
        print(f"\n[Advanced Analysis - APIC {idx}]")
        
        # Hash the image data
        img_hash = hashlib.sha256(apic.data).hexdigest()
        print(f"SHA256: {img_hash}")
        
        # Load with PIL for detailed analysis
        try:
            img = Image.open(io.BytesIO(apic.data))
            print(f"Format: {img.format}")
            print(f"Mode: {img.mode}")
            print(f"Size: {img.size}")
            
            # Check for alpha channel
            if img.mode in ('RGBA', 'LA', 'PA'):
                print("Alpha channel present - analyze separately!")
            
            # Check EXIF data in cover art
            if hasattr(img, '_getexif') and img._getexif():
                print("EXIF data present in cover art:")
                exif = img._getexif()
                for tag, value in exif.items():
                    print(f"  {tag}: {value}")
            
            # Check for unusual aspect ratios
            aspect = img.width / img.height
            if aspect > 3 or aspect < 0.33:
                print(f"Unusual aspect ratio: {aspect:.2f}")
            
            # Compare actual vs claimed MIME type
            if apic.mime == 'image/jpeg' and img.format != 'JPEG':
                print(f"MIME mismatch: claimed {apic.mime}, actual {img.format}")
            
            # Check for LSB steganography indicators
            import numpy as np
            img_array = np.array(img)
            if len(img_array.shape) == 3:
                for channel in range(img_array.shape[2]):
                    lsb = img_array[:,:,channel] & 1
                    entropy = -np.sum(lsb * np.log2(lsb + 1e-10)) / lsb.size
                    if entropy > 0.7:  # [Inference] High entropy may indicate hidden data
                        print(f"Channel {channel}: High LSB entropy ({entropy:.3f})")
        
        except Exception as e:
            print(f"Error analyzing image: {e}")
        
        # Check for trailing data after image
        if apic.mime == 'image/jpeg':
            eoi = apic.data.rfind(b'\xff\xd9')  # JPEG End of Image marker
            if eoi > 0 and eoi < len(apic.data) - 2:
                trailing = len(apic.data) - eoi - 2
                print(f"Trailing data after JPEG EOI: {trailing} bytes")
                with open(f'cover_{idx}_trailing.bin', 'wb') as f:
                    f.write(apic.data[eoi+2:])
        
        elif b'\x89PNG' in apic.data:
            iend = apic.data.rfind(b'IEND')
            if iend > 0 and iend < len(apic.data) - 8:
                trailing = len(apic.data) - iend - 8
                print(f"Trailing data after PNG IEND: {trailing} bytes")
                with open(f'cover_{idx}_trailing.bin', 'wb') as f:
                    f.write(apic.data[iend+8:])

advanced_cover_analysis('audio.mp3')
```

**Complete Cover Art Extraction Workflow**

```bash
#!/bin/bash
# Complete workflow for extracting and analyzing cover art

AUDIO_FILE="$1"

echo "[1] Extracting cover art..."
exiftool -b -Picture "$AUDIO_FILE" > cover.jpg 2>/dev/null || \
ffmpeg -i "$AUDIO_FILE" -an -c:v copy cover.jpg 2>/dev/null || \
metaflac --export-picture-to=cover.jpg "$AUDIO_FILE" 2>/dev/null

if [ ! -f cover.jpg ]; then
    echo "No cover art found or extraction failed"
    exit 1
fi

echo "[2] Analyzing image properties..."
file cover.jpg
identify -verbose cover.jpg | grep -E "(Format|Geometry|Depth|Colorspace|Type)"

echo "[3] Checking for hidden data..."
strings cover.jpg | head -n 20
binwalk cover.jpg

echo "[4] Steganography detection..."
zsteg cover.jpg 2>/dev/null || echo "zsteg not available or not PNG"
steghide info cover.jpg 2>/dev/null

echo "[5] Checking for trailing data..."
xxd cover.jpg | tail -n 10

echo "[6] Running StegSolve analysis..."
echo "Manual step: java -jar stegsolve.jar cover.jpg"

echo "[7] Extracting metadata from cover..."
exiftool cover.jpg
```

### Important Related Topics

After mastering audio metadata analysis, explore these related areas:

- **Spectral Analysis** - Frequency domain steganography in audio data
- **LSB Audio Steganography** - Hiding data in audio sample least significant bits
- **File Format Deep Dive** - Understanding MP3, FLAC, OGG container structures
- **Binary Metadata Parsing** - Manual chunk/atom parsing for advanced extraction

---



---

# File & Archive Steganography



---



---



---

# Steganalysis Tools (Kali Linux)



---



---



---



---



---

# CTF-Specific Techniques



---



---



---

# Advanced Topics

# Practical Methodology