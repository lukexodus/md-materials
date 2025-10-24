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

## Advanced Image Analysis

### Stereogram Decoding

#### Understanding Stereogram Types

Stereograms are images designed to create 3D depth perception through parallax viewing. The primary types encountered in CTF challenges are Random Dot Stereograms (RDS), Single Image Stereograms (SIS), and Autostereograms. RDS consists of two slightly offset versions of the same pattern viewed simultaneously, creating depth illusion. SIS/Autostereograms contain a single image where repeating patterns at varying horizontal offsets encode depth information.

Autostereograms function by repeating a base pattern across the image width with controlled shifts based on depth data. The shift distance is inversely related to perceived depth—smaller shifts create objects appearing further away, larger shifts bring objects closer. The eye-crossing distance and viewing method (crossed-eye vs. wall-eyed) affect the decoded result.

In CTF scenarios, hidden data is embedded in depth maps or the repeating pattern itself, requiring precise stereogram analysis to reveal.

#### Identifying Autostereograms

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
    img_array = np.array(img.convert('L'))  ## Convert to grayscale
    
    height, width = img_array.shape
    print(f"Image dimensions: {width}x{height}")
    
    ## Analyze horizontal line patterns
    ## Autostereograms have repeating patterns horizontally
    middle_row = img_array[height // 2, :]
    
    ## Compute autocorrelation to find repeating pattern period
    autocorr = signal.correlate(middle_row, middle_row, mode='full')
    autocorr = autocorr[len(autocorr)//2:]
    
    ## Find peaks in autocorrelation (indicate pattern repetition)
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
    
    ## Analyze each row for pattern shifts
    is_stereogram, period = detect_autostereogram(image_path)
    
    if not is_stereogram or period is None:
        print("Not a stereogram")
        return None
    
    depth_map = np.zeros((height, width))
    
    ## For each row, calculate pattern shift at each column
    for row in range(height):
        row_data = img_array[row, :]
        
        ## Compare pattern shifts at different positions
        for col in range(width - period):
            ## Extract two windows
            window1 = row_data[col:col+period]
            window2 = row_data[col+period:col+2*period]
            
            ## Calculate correlation
            correlation = np.correlate(window1, window2, mode='valid')
            if len(correlation) > 0:
                depth_map[row, col] = correlation[0]
    
    ## Normalize depth map
    depth_map = ((depth_map - depth_map.min()) / 
                 (depth_map.max() - depth_map.min()) * 255).astype(np.uint8)
    
    ## Save depth map visualization
    depth_img = Image.fromarray(depth_map)
    depth_img.save('depth_map.png')
    print("Depth map saved to depth_map.png")
    
    return depth_map

## Usage
is_stereo, period = detect_autostereogram('image.png')
if is_stereo:
    depth_map = analyze_stereogram_depth('image.png')
```

#### Stereogram Pattern Extraction

Extract the repeating pattern from autostereograms:

```python
def extract_stereogram_pattern(image_path):
    """
    Extract the base repeating pattern from autostereogram
    """
    img = Image.open(image_path)
    img_array = np.array(img.convert('L'))
    
    height, width = img_array.shape
    
    ## Detect pattern period
    middle_row = img_array[height // 2, :]
    autocorr = signal.correlate(middle_row, middle_row, mode='full')
    autocorr = autocorr[len(autocorr)//2:]
    peaks, _ = signal.find_peaks(autocorr[1:], height=np.max(autocorr)*0.5)
    
    if len(peaks) == 0:
        print("No pattern detected")
        return None
    
    period = peaks[0] + 1
    print(f"Pattern period: {period}")
    
    ## Extract pattern from top-left corner
    pattern = img_array[:period, :period]
    
    ## Visualize pattern
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

## Usage
pattern = extract_stereogram_pattern('image.png')
if pattern is not None:
    period = pattern.shape[0]
    variations = analyze_pattern_variations('image.png', period)
```

#### Stereogram Decoding to 2D Image

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
    
    ## Detect base pattern period
    middle_row = img_array[height // 2, :]
    autocorr = signal.correlate(middle_row, middle_row, mode='full')
    autocorr = autocorr[len(autocorr)//2:]
    peaks, _ = signal.find_peaks(autocorr[1:], height=np.max(autocorr)*0.5)
    
    if len(peaks) == 0:
        print("No stereogram detected")
        return None
    
    period = peaks[0] + 1
    print(f"Base period: {period}")
    
    ## Create output image
    decoded = np.zeros((height, width), dtype=np.uint8)
    
    ## For each row
    for row in range(height):
        row_data = img_array[row, :]
        
        ## Extract pattern at this row
        pattern = row_data[:period]
        
        ## Replicate pattern across width
        for col in range(width):
            ## Calculate expected position with depth variation
            pattern_idx = col % period
            decoded[row, col] = pattern[pattern_idx]
    
    ## This creates the baseline; now detect shifts for depth
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
    
    ## Split into left and right halves
    left_half = img.crop((0, 0, width // 2, height))
    right_half = img.crop((width // 2, 0, width, height))
    
    ## Create cross-eye version (swap left and right)
    cross_eye = Image.new('RGB', (width, height))
    cross_eye.paste(right_half, (0, 0))
    cross_eye.paste(left_half, (width // 2, 0))
    
    cross_eye.save('cross_eye_version.png')
    print("Cross-eye version saved")
    
    return cross_eye

## Usage
decoded = decode_autostereogram('stereogram.png')
cross_eye = cross_eye_view_decode('stereogram.png')
```

#### Hidden Data Extraction from Stereograms

Extract hidden data embedded in depth information:

```python
def extract_depth_data(image_path):
    """
    Extract depth map as data for analysis
    """
    img = Image.open(image_path)
    img_array = np.array(img.convert('L'))
    
    height, width = img_array.shape
    
    ## Detect pattern
    middle_row = img_array[height // 2, :]
    autocorr = signal.correlate(middle_row, middle_row, mode='full')
    autocorr = autocorr[len(autocorr)//2:]
    peaks, _ = signal.find_peaks(autocorr[1:], height=np.max(autocorr)*0.5)
    
    if len(peaks) == 0:
        return None
    
    period = peaks[0] + 1
    
    ## Extract shift information
    depth_data = []
    
    for row in range(height):
        row_data = img_array[row, :]
        
        ## For each position, measure pattern shift
        for col in range(0, width - period * 2, period):
            window1 = row_data[col:col+period]
            window2 = row_data[col+period:col+2*period]
            
            ## Find best offset (represents depth)
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
    
    ## Convert depth data to binary
    depth_array = np.array(depth_data)
    binary_data = np.where(depth_array > 0, 1, 0)
    
    print(f"Extracted {len(binary_data)} depth values")
    print(f"Binary sequence (first 100): {''.join(str(b) for b in binary_data[:100])}")
    
    ## Try to decode as ASCII
    for i in range(0, len(binary_data) - 7, 8):
        byte_val = 0
        for j in range(8):
            byte_val = (byte_val << 1) | binary_data[i+j]
        
        if 32 <= byte_val < 127:
            print(f"ASCII: {chr(byte_val)}", end='')
    print()
    
    return depth_data

## Usage
depth_data = extract_depth_data('stereogram.png')
```

#### Stereogram Analysis with Machine Learning

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
    
    ## Calculate entropy in horizontal strips
    strip_height = height // 10
    entropies = []
    
    for i in range(10):
        strip = img_array[i*strip_height:(i+1)*strip_height, :]
        flat = strip.flatten()
        hist, _ = np.histogram(flat, bins=256, range=(0, 256))
        hist = hist / np.sum(hist)  ## Normalize
        ent = scipy_entropy(hist)
        entropies.append(ent)
    
    print("Entropy by strip:")
    for i, ent in enumerate(entropies):
        print(f"  Strip {i}: {ent:.3f}")
    
    ## Stereograms typically have lower entropy than random images
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
    
    ## Compute FFT
    fft_result = np.fft.fft2(img_array)
    fft_shifted = np.fft.fftshift(fft_result)
    magnitude = np.abs(fft_shifted)
    
    ## Log scale for visualization
    log_magnitude = np.log1p(magnitude)
    
    ## Normalize
    normalized = (log_magnitude / log_magnitude.max() * 255).astype(np.uint8)
    
    ## Save FFT visualization
    fft_img = Image.fromarray(normalized)
    fft_img.save('fft_analysis.png')
    print("FFT analysis saved to fft_analysis.png")
    
    ## Check for strong periodic components
    threshold = np.mean(magnitude) + 2 * np.std(magnitude)
    strong_components = np.sum(magnitude > threshold)
    
    print(f"Strong frequency components: {strong_components}")
    
    return fft_result

## Usage
analyze_stereogram_entropy('stereogram.png')
detect_repeating_patterns('stereogram.png')
```

### QR Code Detection

#### QR Code Structure Recognition

QR (Quick Response) codes encode data using a square matrix of black and white modules. The structure includes three position detection patterns (corner squares), timing patterns (alternating lines), and data modules. Version 1 (smallest) is 21x21 modules; larger versions scale up to 177x177 modules.

The format information area contains error correction level and mask pattern. Data is encoded using various schemes (numeric, alphanumeric, byte, kanji) and protected by Reed-Solomon error correction, allowing recovery if up to 30% of the code is damaged.

#### Detecting QR Codes in Images

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
    
    ## Detect QR codes
    qr_codes = pyzbar.decode(img)
    
    print(f"Found {len(qr_codes)} QR code(s)")
    
    results = []
    for i, qr in enumerate(qr_codes):
        ## Extract bounding box
        (x, y, w, h) = qr.rect
        print(f"\nQR Code {i+1}:")
        print(f"  Position: ({x}, {y})")
        print(f"  Size: {w}x{h}")
        print(f"  Type: {qr.type}")
        print(f"  Data: {qr.data.decode('utf-8', errors='replace')}")
        
        ## Draw bounding box
        cv2.rectangle(img, (x, y), (x+w, y+h), (0, 255, 0), 2)
        
        results.append({
            'data': qr.data.decode('utf-8', errors='replace'),
            'rect': qr.rect,
            'type': qr.type
        })
    
    ## Save marked image
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
    
    ## Threshold image
    _, binary = cv2.threshold(img, 127, 255, cv2.THRESH_BINARY)
    
    ## Find contours
    contours, _ = cv2.findContours(binary, cv2.RETR_TREE, cv2.CHAIN_APPROX_SIMPLE)
    
    ## Look for square patterns (position detection patterns are square)
    square_candidates = []
    for contour in contours:
        x, y, w, h = cv2.boundingRect(contour)
        
        ## Position patterns are roughly square
        if 0.8 < w / h < 1.2 and w > 20:
            square_candidates.append((x, y, w, h))
    
    print(f"Found {len(square_candidates)} square candidates")
    for i, (x, y, w, h) in enumerate(square_candidates[:5]):
        print(f"  Square {i+1}: ({x}, {y}), {w}x{h}")
    
    return square_candidates

## Usage
qr_results = detect_qr_codes('image.png')
squares = detect_qr_patterns_opencv('image.png')
```

#### QR Code Data Extraction

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
        
        ## Try different decodings
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
    
    ## Check for URLs
    if 'http://' in decoded or 'https://' in decoded:
        print("URL detected:")
        for part in decoded.split():
            if part.startswith('http'):
                print(f"  {part}")
    
    ## Check for base64 encoding
    try:
        import base64
        decoded_b64 = base64.b64decode(decoded)
        print(f"Base64 decoded ({len(decoded_b64)} bytes): {decoded_b64[:100]}")
    except:
        pass
    
    ## Check for hex encoding
    if all(c in '0123456789ABCDEFabcdef' for c in decoded):
        hex_decoded = bytes.fromhex(decoded)
        print(f"Hex decoded ({len(hex_decoded)} bytes): {hex_decoded[:100]}")

## Usage
qr_data = extract_qr_data('image.png')
for data in qr_data:
    analyze_qr_data(data['raw'])
```

#### Damaged QR Code Recovery

Recover data from partially damaged QR codes using error correction:

```python
def analyze_qr_damage(image_path):
    """
    Analyze QR code damage and error correction capability
    """
    img = cv2.imread(image_path, cv2.IMREAD_GRAYSCALE)
    if img is None:
        return
    
    ## Threshold
    _, binary = cv2.threshold(img, 127, 255, cv2.THRESH_BINARY)
    
    ## Detect QR boundary
    contours, _ = cv2.findContours(binary, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)
    
    if len(contours) == 0:
        print("No QR code detected")
        return
    
    ## Get largest contour (likely the QR code)
    largest = max(contours, key=cv2.contourArea)
    x, y, w, h = cv2.boundingRect(largest)
    
    qr_region = binary[y:y+h, x:x+w]
    
    ## Calculate damage ratio
    total_pixels = qr_region.size
    white_pixels = np.count_nonzero(qr_region)
    black_pixels = total_pixels - white_pixels
    
    print(f"QR Code region: {w}x{h}")
    print(f"Black pixels: {black_pixels} ({100*black_pixels/total_pixels:.1f}%)")
    print(f"White pixels: {white_pixels} ({100*white_pixels/total_pixels:.1f}%)")
    
    ## For QR codes, approximately 50% should be black
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
    
    ## Apply CLAHE (Contrast Limited Adaptive Histogram Equalization)
    clahe = cv2.createCLAHE(clipLimit=2.0, tileGridSize=(8,8))
    enhanced = clahe.apply(img)
    
    ## Apply morphological operations
    kernel = cv2.getStructuringElement(cv2.MORPH_RECT, (3,3))
    cleaned = cv2.morphologyEx(enhanced, cv2.MORPH_CLOSE, kernel)
    cleaned = cv2.morphologyEx(cleaned, cv2.MORPH_OPEN, kernel)
    
    ## Sharpen
    kernel_sharpen = np.array([[-1,-1,-1],
                              [-1, 9,-1],
                              [-1,-1,-1]])
    sharpened = cv2.filter2D(cleaned, -1, kernel_sharpen)
    
    cv2.imwrite('qr_enhanced.png', sharpened)
    print("Enhanced QR code saved to qr_enhanced.png")
    
    ## Try to decode enhanced version
    img_pil = Image.open('qr_enhanced.png')
    qr_codes = pyzbar.decode(img_pil)
    
    if qr_codes:
        print(f"Successfully decoded enhanced QR: {qr_codes[0].data.decode('utf-8', errors='replace')}")
    else:
        print("Still unable to decode enhanced QR")
    
    return sharpened

## Usage
analyze_qr_damage('damaged_qr.png')
enhance_damaged_qr('damaged_qr.png')
```

### Barcode Reading

#### Barcode Format Detection

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
        
        ## Draw bounding box
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
    
    ## Detect vertical edges (bars run vertically)
    sobelx = cv2.Sobel(img, cv2.CV_64F, 1, 0, ksize=3)
    abs_sobelx = np.absolute(sobelx)
    scaled_sx = np.uint8(255 * abs_sobelx / np.max(abs_sobelx))
    
    ## Threshold to find strong vertical edges
    _, barcode_candidates = cv2.threshold(scaled_sx, 127, 255, cv2.THRESH_BINARY)
    
    ## Find contours of bar regions
    contours, _ = cv2.findContours(barcode_candidates, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)
    
    ## Look for elongated rectangles (typical barcode shape)
    barcode_regions = []
    for contour in contours:
        x, y, w, h = cv2.boundingRect(contour)
        
        ## Barcodes are elongated vertically
        if h > 2 * w and h > 50:
            barcode_regions.append((x, y, w, h))
    
    print(f"Found {len(barcode_regions)} potential barcode region(s)")
    for i, (x, y, w, h) in enumerate(barcode_regions):
        print(f"  Barcode {i+1}: ({x}, {y}), {w}x{h}")
    
    return barcode_regions

## Usage
barcodes = detect_barcodes('barcode_image.png')
regions = analyze_barcode_patterns('barcode_image.png')
```

#### Barcode Data Extraction

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
        
        ## Analyze data
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
    ## Remove check digit for validation
    if len(code) in [12, 13, 14]:
        digits = code[:-1]
        check_digit = int(code[-1])
        
        ## Calculate check digit
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
    ## Code128 can encode various character sets
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

## Usage
extracted = extract_barcode_data('barcode_image.png')
```

#### Damaged Barcode Recovery

Recover data from partially damaged or rotated barcodes:

```python
def enhance_barcode_for_reading(image_path):
    """
    Apply enhancement techniques to improve barcode readability
    """
    img = cv2.imread(image_path, cv2.IMREAD_GRAYSCALE)
    if img is None:
        return
    
    ## Try multiple enhancement techniques
    enhancements = {}
    
    ## 1. Contrast stretching
    enhanced1 = cv2.equalizeHist(img)
    
    ## 2. Morphological operations 
    kernel = cv2.getStructuringElement(cv2.MORPH_RECT, (2, 10)) 
    enhanced2 = cv2.morphologyEx(img, cv2.MORPH_CLOSE, kernel)
    
    # 3. Bilateral filtering (preserves edges)
    
    enhanced3 = cv2.bilateralFilter(img, 9, 75, 75)
    
    # 4. Threshold with Otsu's method
    
    _, enhanced4 = cv2.threshold(img, 0, 255, cv2.THRESH_BINARY + cv2.THRESH_OTSU)
    
    # 5. Adaptive threshold
    
    enhanced5 = cv2.adaptiveThreshold(img, 255, cv2.ADAPTIVE_THRESH_GAUSSIAN_C, cv2.THRESH_BINARY, 11, 2)
    
    enhancements = { 'original': img, 'equalized': enhanced1, 'morphological': enhanced2, 'bilateral': enhanced3, 'otsu': enhanced4, 'adaptive': enhanced5 }
    
    # Try to decode each enhancement
    
    from pyzbar import pyzbar
    
    print("Testing barcode decoding with different enhancements:") for name, enhanced_img in enhancements.items(): # Save enhancement cv2.imwrite(f'barcode_enhanced_{name}.png', enhanced_img)
    
     # Try to decode
     barcodes = pyzbar.decode(Image.fromarray(enhanced_img))
     if barcodes:
         print(f"  ✓ {name}: {barcodes[0].data.decode('utf-8', errors='replace')}")
     else:
         print(f"  ✗ {name}: Unable to decode")

def rotate_and_detect_barcode(image_path): """ Try rotating image at various angles to find readable barcode """ from pyzbar import pyzbar

img_original = cv2.imread(image_path)
height, width = img_original.shape[:2]
center = (width // 2, height // 2)

print("Testing various rotation angles:")
for angle in range(0, 360, 15):
    rotation_matrix = cv2.getRotationMatrix2D(center, angle, 1.0)
    rotated = cv2.warpAffine(img_original, rotation_matrix, (width, height))
    
    barcodes = pyzbar.decode(rotated)
    if barcodes:
        print(f"  ✓ {angle}°: {barcodes[0].data.decode('utf-8', errors='replace')}")
        cv2.imwrite(f'barcode_rotated_{angle}.png', rotated)
        return barcodes[0]

print("  No barcode found at any rotation")
return None

# Usage

enhance_barcode_for_reading('damaged_barcode.png') result = rotate_and_detect_barcode('rotated_barcode.png')
````

### Augmented Reality Markers

#### AR Marker Detection (ArUco)

ArUco (Augmented Reality Utility Codes) markers are synthetic square fiducial markers designed for camera pose estimation. Each marker consists of an outer black border, a white border, and a 4x4 grid of black/white modules encoding a unique ID. Standard marker dictionaries exist (4x4, 5x5, 6x6, 7x7 module grids).

```python
import cv2
from cv2 import aruco
import numpy as np

def detect_aruco_markers(image_path):
    """
    Detect and decode ArUco markers in image
    """
    img = cv2.imread(image_path)
    if img is None:
        print("Cannot read image")
        return []
    
    gray = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)
    
    ## Initialize ArUco detector
    ## Try different dictionaries
    dictionaries = [
        aruco.getPredefinedDictionary(aruco.DICT_4X4_50),
        aruco.getPredefinedDictionary(aruco.DICT_5X5_100),
        aruco.getPredefinedDictionary(aruco.DICT_6X6_250),
        aruco.getPredefinedDictionary(aruco.DICT_7X7_1000)
    ]
    
    all_markers = []
    
    for dict_idx, dictionary in enumerate(dictionaries):
        detector = aruco.ArucoDetector(dictionary)
        corners, ids, rejected = detector.detectMarkers(gray)
        
        if ids is not None and len(ids) > 0:
            print(f"Found {len(ids)} marker(s) in dictionary {dict_idx}")
            
            for i, marker_id in enumerate(ids.flatten()):
                corner = corners[i][0]
                print(f"  Marker ID: {marker_id}")
                print(f"  Corners: {corner}")
                
                all_markers.append({
                    'id': marker_id,
                    'corners': corner,
                    'dictionary': dict_idx
                })
            
            ## Draw markers
            img_marked = img.copy()
            img_marked = aruco.drawDetectedMarkers(img_marked, corners, ids)
            cv2.imwrite('aruco_detected.png', img_marked)
            print("Marked image saved to aruco_detected.png")
    
    return all_markers

def analyze_aruco_marker_content(image_path):
    """
    Extract and analyze ArUco marker binary content
    """
    markers = detect_aruco_markers(image_path)
    
    if not markers:
        print("No ArUco markers found")
        return
    
    for marker in markers:
        marker_id = marker['id']
        corners = marker['corners']
        
        print(f"\nMarker ID {marker_id}:")
        print(f"  Binary representation: {bin(marker_id)}")
        print(f"  Hex representation: {hex(marker_id)}")
        
        ## Extract marker region from image
        img = cv2.imread(image_path)
        x_min = int(np.min(corners[:, 0]))
        x_max = int(np.max(corners[:, 0]))
        y_min = int(np.min(corners[:, 1]))
        y_max = int(np.max(corners[:, 1]))
        
        marker_region = img[y_min:y_max, x_min:x_max]
        cv2.imwrite(f'marker_{marker_id}.png', marker_region)
        
        ## Analyze marker pattern
        gray_marker = cv2.cvtColor(marker_region, cv2.COLOR_BGR2GRAY)
        _, binary = cv2.threshold(gray_marker, 127, 255, cv2.THRESH_BINARY)
        
        ## Extract bit pattern
        height, width = binary.shape
        bit_size = height // 8  ## Approximate size of each bit cell
        
        pattern = []
        for row in range(8):
            for col in range(8):
                cell = binary[row*bit_size:(row+1)*bit_size, 
                             col*bit_size:(col+1)*bit_size]
                avg = np.mean(cell)
                pattern.append('1' if avg > 127 else '0')
        
        print(f"  Bit pattern: {''.join(pattern[:32])}")

## Usage
markers = detect_aruco_markers('marker_image.png')
analyze_aruco_marker_content('marker_image.png')
````

#### Custom Marker Detection

Detect and decode custom AR markers:

```python
def detect_custom_markers(image_path, marker_size=50):
    """
    Detect custom square markers in image
    """
    img = cv2.imread(image_path)
    gray = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)
    
    ## Find contours
    _, binary = cv2.threshold(gray, 127, 255, cv2.THRESH_BINARY)
    contours, _ = cv2.findContours(binary, cv2.RETR_TREE, cv2.CHAIN_APPROX_SIMPLE)
    
    markers = []
    
    for contour in contours:
        ## Get bounding rectangle
        x, y, w, h = cv2.boundingRect(contour)
        
        ## Check if roughly square
        if 0.7 < w / h < 1.3 and w > marker_size:
            ## Check if it's a closed contour
            if cv2.contourArea(contour) > (w * h * 0.5):
                markers.append((x, y, w, h))
    
    print(f"Found {len(markers)} potential markers")
    
    ## Draw markers
    img_marked = img.copy()
    for x, y, w, h in markers:
        cv2.rectangle(img_marked, (x, y), (x+w, y+h), (0, 255, 0), 2)
    
    cv2.imwrite('custom_markers_detected.png', img_marked)
    
    return markers

def decode_marker_content(image_path, marker_region):
    """
    Decode binary content from marker region
    """
    x, y, w, h = marker_region
    
    img = cv2.imread(image_path)
    marker_img = img[y:y+h, x:x+w]
    
    gray = cv2.cvtColor(marker_img, cv2.COLOR_BGR2GRAY)
    _, binary = cv2.threshold(gray, 127, 255, cv2.THRESH_BINARY)
    
    ## Extract grid pattern (assuming 4x4 or similar)
    grid_size = 8
    cell_h = h // grid_size
    cell_w = w // grid_size
    
    pattern = np.zeros((grid_size, grid_size), dtype=int)
    
    for row in range(grid_size):
        for col in range(grid_size):
            cell = binary[row*cell_h:(row+1)*cell_h, col*cell_w:(col+1)*cell_w]
            avg = np.mean(cell)
            pattern[row, col] = 1 if avg > 127 else 0
    
    print(f"Marker pattern ({grid_size}x{grid_size}):")
    for row in pattern:
        print(' '.join('█' if bit else '░' for bit in row))
    
    ## Try to extract ID
    ## Skip border (typically 1 cell wide)
    interior = pattern[1:-1, 1:-1]
    marker_id = 0
    for i, bit in enumerate(interior.flatten()):
        marker_id = (marker_id << 1) | bit
    
    print(f"Decoded ID: {marker_id}")
    
    return pattern, marker_id

## Usage
markers = detect_custom_markers('marker_image.png')
if markers:
    pattern, marker_id = decode_marker_content('marker_image.png', markers[0])
```

#### Multiple Marker Detection and Tracking

Track multiple AR markers across frames:

```python
def analyze_marker_relationships(image_path):
    """
    Analyze spatial relationships between multiple markers
    """
    img = cv2.imread(image_path)
    gray = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)
    
    ## Detect ArUco markers
    dictionary = aruco.getPredefinedDictionary(aruco.DICT_5X5_100)
    detector = aruco.ArucoDetector(dictionary)
    corners, ids, _ = detector.detectMarkers(gray)
    
    if ids is None or len(ids) < 2:
        print("Need at least 2 markers for relationship analysis")
        return
    
    print(f"Found {len(ids)} markers")
    
    ## Calculate distances and angles between markers
    marker_centers = []
    for i, marker_id in enumerate(ids.flatten()):
        center = np.mean(corners[i][0], axis=0)
        marker_centers.append((marker_id, center))
        print(f"Marker {marker_id}: {center}")
    
    ## Calculate pairwise distances
    print("\nMarker distances:")
    for i in range(len(marker_centers)):
        for j in range(i+1, len(marker_centers)):
            id1, center1 = marker_centers[i]
            id2, center2 = marker_centers[j]
            distance = np.linalg.norm(center1 - center2)
            
            ## Calculate angle
            dx = center2[0] - center1[0]
            dy = center2[1] - center1[1]
            angle = np.degrees(np.arctan2(dy, dx))
            
            print(f"  {id1} to {id2}: distance={distance:.1f}, angle={angle:.1f}°")

def track_markers_in_video(video_path):
    """
    Track ArUco markers across video frames
    """
    cap = cv2.VideoCapture(video_path)
    
    dictionary = aruco.getPredefinedDictionary(aruco.DICT_5X5_100)
    detector = aruco.ArucoDetector(dictionary)
    
    frame_count = 0
    marker_history = {}
    
    while True:
        ret, frame = cap.read()
        if not ret:
            break
        
        gray = cv2.cvtColor(frame, cv2.COLOR_BGR2GRAY)
        corners, ids, _ = detector.detectMarkers(gray)
        
        if ids is not None:
            for i, marker_id in enumerate(ids.flatten()):
                center = np.mean(corners[i][0], axis=0)
                
                if marker_id not in marker_history:
                    marker_history[marker_id] = []
                
                marker_history[marker_id].append({
                    'frame': frame_count,
                    'center': center,
                    'corners': corners[i][0]
                })
        
        frame_count += 1
    
    cap.release()
    
    print(f"Processed {frame_count} frames")
    print("Marker tracking history:")
    for marker_id, history in marker_history.items():
        print(f"  Marker {marker_id}: {len(history)} detections")
        
        ## Calculate movement
        if len(history) > 1:
            first_center = history[0]['center']
            last_center = history[-1]['center']
            movement = np.linalg.norm(last_center - first_center)
            print(f"    Total movement: {movement:.1f} pixels")

## Usage
analyze_marker_relationships('marker_image.png')
track_markers_in_video('marker_video.mp4')
```

### Steganographic Algorithms Detection

#### LSB Steganalysis

Detect LSB steganography by analyzing bit plane distributions:

```python
def analyze_lsb_distribution(image_path):
    """
    Analyze LSB distribution to detect steganography
    """
    img = Image.open(image_path)
    pixels = np.array(img)
    
    print(f"Image mode: {img.mode}")
    print(f"Dimensions: {img.size}")
    
    if len(pixels.shape) == 3:
        ## Color image - analyze each channel
        for channel_idx in range(pixels.shape[2]):
            channel = pixels[:,:,channel_idx]
            analyze_channel_lsb(channel, f"Channel {channel_idx}")
    else:
        ## Grayscale image
        analyze_channel_lsb(pixels, "Grayscale")

def analyze_channel_lsb(channel, name):
    """
    Analyze single channel for LSB patterns
    """
    flat = channel.flatten()
    
    print(f"\n{name} LSB Analysis:")
    
    ## Analyze each bit plane
    for bit_pos in range(8):
        bit_plane = (flat >> bit_pos) & 1
        ones = np.sum(bit_plane)
        zeros = len(bit_plane) - ones
        
        ## Chi-squared test for randomness
        ## Steganographically embedded data tends to have ~50% 1s and 0s
        expected = len(bit_plane) / 2
        chi_sq = ((ones - expected) ** 2 + (zeros - expected) ** 2) / expected
        
        ratio = ones / len(bit_plane)
        
        print(f"  Bit {bit_pos}: 1s={ratio:.3f}, χ²={chi_sq:.3f}", end="")
        
        if chi_sq < 5:  ## Low chi-squared indicates suspicious randomness
            print(" ⚠ Suspicious pattern")
        else:
            print()

def chi_squared_steganalysis(image_path):
    """
    Perform chi-squared steganalysis to estimate hidden capacity
    """
    img = Image.open(image_path)
    pixels = np.array(img.convert('L'))
    
    flat = pixels.flatten()
    
    ## Analyze LSB pairs
    lsb_values = flat & 1
    second_lsb = (flat >> 1) & 1
    
    ## Count occurrences of each pattern
    pattern_00 = np.sum((lsb_values == 0) & (second_lsb == 0))
    pattern_01 = np.sum((lsb_values == 1) & (second_lsb == 0))
    pattern_10 = np.sum((lsb_values == 0) & (second_lsb == 1))
    pattern_11 = np.sum((lsb_values == 1) & (second_lsb == 1))
    
    total = len(flat)
    
    print(f"LSB pair distribution:")
    print(f"  00: {pattern_00/total:.3f}")
    print(f"  01: {pattern_01/total:.3f}")
    print(f"  10: {pattern_10/total:.3f}")
    print(f"  11: {pattern_11/total:.3f}")
    
    ## Chi-squared test
    expected = total / 4
    chi_sq = ((pattern_00 - expected)**2 + (pattern_01 - expected)**2 +
              (pattern_10 - expected)**2 + (pattern_11 - expected)**2) / expected
    
    print(f"Chi-squared statistic: {chi_sq:.3f}")
    
    if chi_sq > 50:
        print("Likely steganography present (high chi-squared)")
    elif chi_sq < 10:
        print("No steganography detected (low chi-squared)")
    else:
        print("Uncertain - steganography possible")

## Usage
analyze_lsb_distribution('image.png')
chi_squared_steganalysis('image.png')
```

#### Steganalysis Statistical Tests

Perform statistical analysis to detect steganographic modification:

```python
def analyze_pixel_value_distribution(image_path):
    """
    Analyze pixel value distribution for signs of steganography
    """
    img = Image.open(image_path)
    pixels = np.array(img.convert('L'))
    
    flat = pixels.flatten()
    
    ## Histogram analysis
    hist, bins = np.histogram(flat, bins=256, range=(0, 256))
    
    print("Pixel value distribution:")
    print(f"  Mean: {np.mean(flat):.1f}")
    print(f"  Std Dev: {np.std(flat):.1f}")
    print(f"  Min: {np.min(flat)}")
    print(f"  Max: {np.max(flat)}")
    
    ## Check for even/odd pattern
    even_count = np.sum(flat % 2 == 0)
    odd_count = len(flat) - even_count
    
    print(f"Even pixel values: {even_count/len(flat):.3f}")
    print(f"Odd pixel values: {odd_count/len(flat):.3f}")
    
    ## Calculate chi-squared for even/odd distribution
    expected = len(flat) / 2
    chi_sq = ((even_count - expected)**2 + (odd_count - expected)**2) / expected
    
    print(f"Chi-squared (even/odd): {chi_sq:.3f}")
    
    if chi_sq > 100:
        print("⚠ Suspicious even/odd distribution - potential LSB steganography")
    
    ## Visualize histogram
    import matplotlib.pyplot as plt
    plt.figure(figsize=(12, 4))
    
    plt.subplot(1, 2, 1)
    plt.hist(flat, bins=256, range=(0, 256))
    plt.title("Pixel Value Distribution")
    plt.xlabel("Pixel Value")
    plt.ylabel("Frequency")
    
    ## Analyze bit planes
    plt.subplot(1, 2, 2)
    bit_counts = []
    for bit in range(8):
        bit_plane = (flat >> bit) & 1
        bit_counts.append(np.sum(bit_plane) / len(flat))
    
    plt.bar(range(8), bit_counts)
    plt.title("Bit Plane Distribution")
    plt.xlabel("Bit Position")
    plt.ylabel("Proportion of 1s")
    plt.ylim([0, 1])
    plt.axhline(y=0.5, color='r', linestyle='--', label='Expected (50%)')
    plt.legend()
    
    plt.tight_layout()
    plt.savefig('steganalysis_distribution.png', dpi=100)
    print("\nDistribution plot saved to steganalysis_distribution.png")

def perform_rs_steganalysis(image_path):
    """
    Regular and Singular (RS) steganalysis - estimates hidden message length
    [Inference] RS analysis detects LSB steganography by analyzing
    pixel groups for specific patterns, though results are estimates.
    """
    img = Image.open(image_path)
    pixels = np.array(img.convert('L'))
    
    height, width = pixels.shape
    groups = []
    
    ## Group pixels into 2x2 blocks
    for y in range(0, height-1, 2):
        for x in range(0, width-1, 2):
            group = [pixels[y, x], pixels[y, x+1],
                    pixels[y+1, x], pixels[y+1, x+1]]
            groups.append(group)
    
    groups = np.array(groups)
    
    ## Count Regular (R) and Singular (S) groups
    ## R: groups where transitions follow specific pattern
    ## S: groups with irregular pattern
    
    r_count = 0
    s_count = 0
    
    for group in groups:
        ## Simple flipping discrimination function
        flips_normal = 0
        flips_flipped = 0
        
        ## Check standard order
        for i in range(3):
            if group[i] != group[i+1]:
                flips_normal += 1
        
        ## Check LSB-flipped order
        flipped_group = group ^ 1
        for i in range(3):
            if flipped_group[i] != flipped_group[i+1]:
                flips_flipped += 1
        
        if flips_normal < flips_flipped:
            r_count += 1
        elif flips_flipped < flips_normal:
            s_count += 1
    
    print(f"RS Steganalysis Results:")
    print(f"  Regular groups: {r_count}")
    print(f"  Singular groups: {s_count}")
    
    ## Estimate hidden message length
    if r_count > 0:
        ratio = s_count / r_count
        estimated_capacity = 0.5 * np.log2(1 + 2 * ratio)
        print(f"  Estimated hidden capacity: {estimated_capacity:.2f} bits per group")

## Usage
analyze_pixel_value_distribution('image.png')
perform_rs_steganalysis('image.png')
```

#### Stego Tool Signature Detection

Detect signatures of common steganography tools:

```python
def detect_steganography_tools(image_path):
    """
    Detect signatures of common steganography tools
    """
    img = Image.open(image_path)
    pixels = np.array(img)
    
    print("Checking for steganography tool signatures...\n")
    
    ## 1. Check for steghide signature
    check_steghide_signature(img)
    
    ## 2. Check for OpenStego patterns
    check_openstego_patterns(pixels)
    
    ## 3. Check for OutGuess patterns
    check_outguess_patterns(pixels)
    
    ## 4. Check for SilentEye patterns
    check_silenteye_patterns(pixels)

def check_steghide_signature(img):
    """
    Steghide uses specific byte patterns in metadata
    """
    ## Read raw file data
    with open(img.filename, 'rb') as f:
        data = f.read()
    
    ## Steghide leaves markers in certain file types
    if b'steghide' in data.lower():
        print("✓ Steghide marker found in file")
    
    ## Check for steghide's specific encryption/compression headers
    ## Steghide often uses zlib compression
    if b'\x78\x9c' in data or b'\x78\x01' in data:
        print("✓ Potential zlib compression (used by steghide)")

def check_openstego_patterns(pixels):
    """
    OpenStego uses specific LSB patterns
    """
    flat = pixels.flatten()
    
    ## OpenStego patterns in LSB
    lsb = flat & 1
    
    ## Count transitions in LSB sequence
    transitions = np.sum(np.diff(lsb) != 0)
    transition_ratio = transitions / len(lsb)
    
    if transition_ratio > 0.4:
        print(f"⚠ OpenStego-like LSB pattern detected (transition ratio: {transition_ratio:.3f})")

def check_outguess_patterns(pixels):
    """
    OutGuess leaves specific statistical signatures
    """
    flat = pixels.flatten()
    
    ## OutGuess modifies LSBs in specific patterns
    ## Check for bias in LSB vs second LSB correlation
    
    lsb = flat & 1
    second_lsb = (flat >> 1) & 1
    
    correlation = np.correlate(lsb, second_lsb, mode='full')
    if np.max(correlation) / len(flat) > 0.6:
        print("⚠ OutGuess-like LSB/2LSB correlation detected")

def check_silenteye_patterns(pixels):
    """
    SilentEye uses specific encoding
    """
    flat = pixels.flatten()
    
    ## Check for SilentEye's characteristic bit patterns
    ## SilentEye often targets specific color channels
    
    if len(pixels.shape) == 3:
        red = pixels[:,:,0].flatten()
        green = pixels[:,:,1].flatten()
        blue = pixels[:,:,2].flatten()
        
        ## Check if only one channel is modified
        red_changes = np.sum(np.abs(np.diff(red))) / len(red)
        green_changes = np.sum(np.abs(np.diff(green))) / len(green)
        blue_changes = np.sum(np.abs(np.diff(blue))) / len(blue)
        
        changes = [red_changes, green_changes, blue_changes]
        if max(changes) > 2 * min(changes):
            print(f"⚠ Channel bias detected - SilentEye pattern possible")

## Usage
detect_steganography_tools('suspicious_image.png')
```

### Image Diffing

#### Comparing Images for Differences

Detect modifications between images through pixel-level comparison:

```python
def compare_images_basic(image1_path, image2_path):
    """
    Basic image comparison - detect pixel-level differences
    """
    img1 = Image.open(image1_path)
    img2 = Image.open(image2_path)
    
    ## Ensure same size
    if img1.size != img2.size:
        print(f"Size mismatch: {img1.size} vs {img2.size}")
        img2 = img2.resize(img1.size)
    
    arr1 = np.array(img1)
    arr2 = np.array(img2)
    
    ## Calculate difference
    diff = np.abs(arr1.astype(int) - arr2.astype(int))
    
    ## Statistics
    diff_pixels = np.sum(diff > 0)
    total_pixels = diff.size
    difference_percentage = 100 * diff_pixels / total_pixels
    
    print(f"Image 1: {image1_path} ({img1.size})")
    print(f"Image 2: {image2_path} ({img2.size})")
    print(f"\nDifference Statistics:")
    print(f"  Changed pixels: {diff_pixels}/{total_pixels} ({difference_percentage:.3f}%)")
    print(f"  Max difference: {np.max(diff)}")
    print(f"  Mean difference: {np.mean(diff):.2f}")
    print(f"  Median difference: {np.median(diff):.2f}")
    
    ## Create difference visualization
    diff_img = Image.fromarray(np.uint8(np.minimum(diff * 4, 255)))
    diff_img.save('image_diff.png')
    print("\nDifference map saved to image_diff.png")
    
    return diff

def highlight_differences(image1_path, image2_path, threshold=1):
    """
    Create highlighted difference visualization
    """
    img1 = Image.open(image1_path).convert('RGB')
    img2 = Image.open(image2_path).convert('RGB')
    
    if img1.size != img2.size:
        img2 = img2.resize(img1.size)
    
    arr1 = np.array(img1)
    arr2 = np.array(img2)
    
    ## Calculate per-channel differences
    diff = np.abs(arr1.astype(int) - arr2.astype(int))
    
    ## Create highlighted version
    highlighted = arr1.copy()
    diff_mask = np.sum(diff, axis=2) > threshold
    
    ## Color differences in red
    highlighted[diff_mask] = [255, 0, 0]
    
    result_img = Image.fromarray(np.uint8(highlighted))
    result_img.save('differences_highlighted.png')
    print("Highlighted differences saved to differences_highlighted.png")
    
    ## Also create overlay
    overlay = Image.blend(img1, img2, 0.5)
    overlay.save('image_overlay.png')
    print("Overlay saved to image_overlay.png")
    
    return highlighted

def analyze_color_channel_differences(image1_path, image2_path):
    """
    Analyze differences in each color channel separately
    """
    img1 = Image.open(image1_path).convert('RGB')
    img2 = Image.open(image2_path).convert('RGB')
    
    if img1.size != img2.size:
        img2 = img2.resize(img1.size)
    
    arr1 = np.array(img1)
    arr2 = np.array(img2)
    
    channels = ['Red', 'Green', 'Blue']
    
    print("Per-channel analysis:")
    for ch in range(3):
        channel1 = arr1[:,:,ch]
        channel2 = arr2[:,:,ch]
        
        diff = np.abs(channel1.astype(int) - channel2.astype(int))

    changed = np.sum(diff > 0)
    total = channel1.size
    
    print(f"\n{channels[ch]} channel:")
    print(f"  Changed pixels: {changed}/{total} ({100*changed/total:.3f}%)")
    print(f"  Max difference: {np.max(diff)}")
    print(f"  Mean difference: {np.mean(diff):.2f}")
    print(f"  Std dev: {np.std(diff):.2f}")
    
    # Create channel diff visualization
    diff_img = Image.fromarray(np.uint8(np.minimum(diff * 4, 255)))
    diff_img.save(f'diff_{channels[ch].lower()}.png')

# Usage

diff = compare_images_basic('original.png', 'modified.png') highlight_differences('original.png', 'modified.png') analyze_color_channel_differences('original.png', 'modified.png')
````

### Structural Similarity Index (SSIM)

Measure structural similarity between images:

```python
def calculate_ssim(image1_path, image2_path):
    """
    Calculate Structural Similarity Index (SSIM)
    SSIM ranges from -1 to 1, where 1 indicates identical images
    """
    from skimage.metrics import structural_similarity as ssim
    
    img1 = Image.open(image1_path).convert('L')
    img2 = Image.open(image2_path).convert('L')
    
    if img1.size != img2.size:
        img2 = img2.resize(img1.size)
    
    arr1 = np.array(img1)
    arr2 = np.array(img2)
    
    # Calculate SSIM
    ssim_value = ssim(arr1, arr2)
    
    print(f"SSIM: {ssim_value:.4f}")
    
    if ssim_value > 0.95:
        print("Images are nearly identical")
    elif ssim_value > 0.8:
        print("Images are very similar")
    elif ssim_value > 0.5:
        print("Images have moderate similarity")
    else:
        print("Images are significantly different")
    
    # Calculate SSIM with color images
    img1_color = Image.open(image1_path).convert('RGB')
    img2_color = Image.open(image2_path).convert('RGB')
    
    if img1_color.size != img2_color.size:
        img2_color = img2_color.resize(img1_color.size)
    
    arr1_color = np.array(img1_color)
    arr2_color = np.array(img2_color)
    
    # SSIM for color image (average of channels)
    ssim_values = []
    for ch in range(3):
        ssim_ch = ssim(arr1_color[:,:,ch], arr2_color[:,:,ch])
        ssim_values.append(ssim_ch)
    
    print(f"\nColor SSIM:")
    for i, ch_name in enumerate(['Red', 'Green', 'Blue']):
        print(f"  {ch_name}: {ssim_values[i]:.4f}")
    
    avg_ssim = np.mean(ssim_values)
    print(f"  Average: {avg_ssim:.4f}")
    
    return ssim_value, avg_ssim

def calculate_mse_psnr(image1_path, image2_path):
    """
    Calculate Mean Squared Error (MSE) and Peak Signal-to-Noise Ratio (PSNR)
    """
    img1 = Image.open(image1_path).convert('L')
    img2 = Image.open(image2_path).convert('L')
    
    if img1.size != img2.size:
        img2 = img2.resize(img1.size)
    
    arr1 = np.array(img1, dtype=np.float32)
    arr2 = np.array(img2, dtype=np.float32)
    
    # Calculate MSE
    mse = np.mean((arr1 - arr2) ** 2)
    
    print(f"Mean Squared Error (MSE): {mse:.4f}")
    
    if mse == 0:
        print("Images are identical")
        psnr = float('inf')
    else:
        # Calculate PSNR (Peak Signal-to-Noise Ratio)
        # Assumes 8-bit images with max value 255
        max_pixel = 255.0
        psnr = 20 * np.log10(max_pixel / np.sqrt(mse))
        print(f"Peak Signal-to-Noise Ratio (PSNR): {psnr:.2f} dB")
    
    # PSNR interpretation
    if psnr > 40:
        print("Very high quality (nearly imperceptible difference)")
    elif psnr > 30:
        print("High quality")
    elif psnr > 20:
        print("Moderate quality")
    else:
        print("Low quality / Significant differences")
    
    return mse, psnr

# Usage
ssim_val, avg_ssim = calculate_ssim('original.png', 'modified.png')
mse, psnr = calculate_mse_psnr('original.png', 'modified.png')
````

### Histogram and Statistical Comparison

Compare statistical properties:

```python
def compare_histograms(image1_path, image2_path):
    """
    Compare color histograms of two images
    """
    img1 = Image.open(image1_path).convert('RGB')
    img2 = Image.open(image2_path).convert('RGB')
    
    if img1.size != img2.size:
        img2 = img2.resize(img1.size)
    
    arr1 = np.array(img1)
    arr2 = np.array(img2)
    
    print("Histogram Comparison:")
    
    for ch_idx, ch_name in enumerate(['Red', 'Green', 'Blue']):
        hist1, _ = np.histogram(arr1[:,:,ch_idx], bins=256, range=(0, 256))
        hist2, _ = np.histogram(arr2[:,:,ch_idx], bins=256, range=(0, 256))
        
        # Normalize histograms
        hist1 = hist1 / np.sum(hist1)
        hist2 = hist2 / np.sum(hist2)
        
        # Calculate histogram distance (chi-squared)
        chi_squared = np.sum((hist1 - hist2) ** 2 / (hist1 + hist2 + 1e-10))
        
        # Bhattacharyya distance
        bhatt = -np.log(np.sum(np.sqrt(hist1 * hist2)))
        
        print(f"\n{ch_name} channel:")
        print(f"  Chi-squared distance: {chi_squared:.4f}")
        print(f"  Bhattacharyya distance: {bhatt:.4f}")
        
        # Visualize
        import matplotlib.pyplot as plt
        plt.figure(figsize=(10, 4))
        
        plt.subplot(1, 2, 1)
        plt.plot(hist1, label='Image 1', alpha=0.7)
        plt.plot(hist2, label='Image 2', alpha=0.7)
        plt.title(f'{ch_name} Channel Histogram')
        plt.xlabel('Pixel Value')
        plt.ylabel('Frequency')
        plt.legend()
        
        plt.subplot(1, 2, 2)
        plt.bar(range(256), np.abs(hist1 - hist2))
        plt.title(f'{ch_name} Channel Difference')
        plt.xlabel('Pixel Value')
        plt.ylabel('Histogram Difference')
        
        plt.tight_layout()
        plt.savefig(f'histogram_comparison_{ch_name.lower()}.png')
        plt.close()

def analyze_statistical_properties(image_path):
    """
    Analyze statistical properties of image
    """
    img = Image.open(image_path).convert('RGB')
    arr = np.array(img)
    
    print(f"Image: {image_path}")
    print(f"Dimensions: {img.size}")
    print(f"Mode: {img.mode}\n")
    
    print("Statistical Properties:")
    for ch_idx, ch_name in enumerate(['Red', 'Green', 'Blue']):
        channel = arr[:,:,ch_idx].flatten()
        
        print(f"\n{ch_name} channel:")
        print(f"  Mean: {np.mean(channel):.2f}")
        print(f"  Median: {np.median(channel):.2f}")
        print(f"  Std Dev: {np.std(channel):.2f}")
        print(f"  Min: {np.min(channel)}")
        print(f"  Max: {np.max(channel)}")
        print(f"  Skewness: {((np.mean(channel) - np.median(channel)) / np.std(channel)):.3f}")
        
        # Entropy
        hist, _ = np.histogram(channel, bins=256, range=(0, 256))
        hist = hist / np.sum(hist)
        entropy = -np.sum(hist * np.log2(hist + 1e-10))
        print(f"  Entropy: {entropy:.3f}")

# Usage
compare_histograms('original.png', 'modified.png')
analyze_statistical_properties('image.png')
```

### Perceptual Hashing

Use perceptual hashing to detect manipulated or similar images:

```python
def calculate_perceptual_hash(image_path, method='average'):
    """
    Calculate perceptual hash of image
    Methods: 'average', 'difference', 'phash'
    """
    img = Image.open(image_path).convert('L')
    
    if method == 'average':
        return calculate_average_hash(img)
    elif method == 'difference':
        return calculate_difference_hash(img)
    elif method == 'phash':
        return calculate_phash(img)

def calculate_average_hash(img, size=8):
    """
    Average hash - simple perceptual hash
    """
    # Resize to 8x8
    img_small = img.resize((size, size), Image.Resampling.LANCZOS)
    arr = np.array(img_small)
    
    # Calculate average pixel value
    avg = np.mean(arr)
    
    # Create hash
    hash_bits = arr > avg
    hash_value = 0
    for bit in hash_bits.flatten():
        hash_value = (hash_value << 1) | int(bit)
    
    return hash_value, hash_bits

def calculate_difference_hash(img, size=8):
    """
    Difference hash - compares adjacent pixels
    """
    img_small = img.resize((size+1, size), Image.Resampling.LANCZOS)
    arr = np.array(img_small)
    
    # Compare each pixel with the one to the right
    hash_bits = np.zeros((size, size), dtype=bool)
    for i in range(size):
        for j in range(size):
            hash_bits[i, j] = arr[i, j] > arr[i, j+1]
    
    hash_value = 0
    for bit in hash_bits.flatten():
        hash_value = (hash_value << 1) | int(bit)
    
    return hash_value, hash_bits

def calculate_phash(img, size=32):
    """
    Perceptual hash using DCT (Discrete Cosine Transform)
    """
    from scipy.fftpack import dct
    
    # Resize to 32x32
    img_small = img.resize((size, size), Image.Resampling.LANCZOS)
    arr = np.array(img_small, dtype=np.float32)
    
    # Apply DCT
    dct_result = dct(dct(arr, axis=0), axis=1)
    
    # Use top-left 8x8 coefficients
    dct_reduced = dct_result[:8, :8]
    
    # Calculate average of all coefficients
    avg = np.mean(dct_reduced)
    
    # Create hash
    hash_bits = dct_reduced > avg
    hash_value = 0
    for bit in hash_bits.flatten():
        hash_value = (hash_value << 1) | int(bit)
    
    return hash_value, hash_bits

def hamming_distance(hash1, hash2):
    """
    Calculate Hamming distance between two hashes
    """
    xor = hash1 ^ hash2
    distance = 0
    while xor:
        distance += xor & 1
        xor >>= 1
    return distance

def compare_images_by_hash(image1_path, image2_path):
    """
    Compare images using perceptual hashing
    """
    print("Perceptual Hash Comparison:")
    print(f"Image 1: {image1_path}")
    print(f"Image 2: {image2_path}\n")
    
    methods = ['average', 'difference', 'phash']
    
    for method in methods:
        hash1, bits1 = calculate_perceptual_hash(image1_path, method)
        hash2, bits2 = calculate_perceptual_hash(image2_path, method)
        
        distance = hamming_distance(hash1, hash2)
        max_distance = 64  # For 8x8 hash
        
        similarity = 100 * (1 - distance / max_distance)
        
        print(f"{method.upper()} Hash:")
        print(f"  Hash 1: {hash1:064b}")
        print(f"  Hash 2: {hash2:064b}")
        print(f"  Hamming distance: {distance}")
        print(f"  Similarity: {similarity:.1f}%")
        
        if similarity > 90:
            print("  ✓ Images appear to be identical or very similar")
        elif similarity > 75:
            print("  ≈ Images are similar (likely same content)")
        elif similarity > 50:
            print("  ~ Images have some similarity")
        else:
            print("  ✗ Images are different")
        print()

# Usage
compare_images_by_hash('original.png', 'modified.png')
```

### Advanced Diffing with Feature Detection

Use feature matching to find modifications:

```python
def detect_modified_regions(image1_path, image2_path):
    """
    Detect and visualize modified regions between images
    """
    img1 = cv2.imread(image1_path)
    img2 = cv2.imread(image2_path)
    
    if img1.shape != img2.shape:
        img2 = cv2.resize(img2, (img1.shape[1], img1.shape[0]))
    
    # Convert to grayscale
    gray1 = cv2.cvtColor(img1, cv2.COLOR_BGR2GRAY)
    gray2 = cv2.cvtColor(img2, cv2.COLOR_BGR2GRAY)
    
    # Calculate difference
    diff = cv2.absdiff(gray1, gray2)
    
    # Threshold to get binary mask
    _, thresh = cv2.threshold(diff, 30, 255, cv2.THRESH_BINARY)
    
    # Dilate to connect nearby changes
    kernel = cv2.getStructuringElement(cv2.MORPH_ELLIPSE, (5, 5))
    thresh = cv2.dilate(thresh, kernel, iterations=2)
    
    # Find contours of modified regions
    contours, _ = cv2.findContours(thresh, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)
    
    print(f"Found {len(contours)} modified region(s)\n")
    
    # Draw bounding boxes
    img_marked = img1.copy()
    for i, contour in enumerate(contours):
        x, y, w, h = cv2.boundingRect(contour)
        area = cv2.contourArea(contour)
        
        print(f"Region {i+1}: ({x}, {y}), {w}x{h}, area={area:.0f}")
        
        cv2.rectangle(img_marked, (x, y), (x+w, y+h), (0, 255, 0), 2)
        cv2.putText(img_marked, f"Mod {i+1}", (x, y-10),
                   cv2.FONT_HERSHEY_SIMPLEX, 0.5, (0, 255, 0), 2)
    
    cv2.imwrite('modified_regions.png', img_marked)
    print("\nModified regions visualization saved to modified_regions.png")
    
    # Save difference map
    cv2.imwrite('difference_map.png', diff)
    print("Difference map saved to difference_map.png")

def feature_matching_diff(image1_path, image2_path):
    """
    Use feature matching to identify moved/rotated content
    """
    img1 = cv2.imread(image1_path, cv2.IMREAD_GRAYSCALE)
    img2 = cv2.imread(image2_path, cv2.IMREAD_GRAYSCALE)
    
    # Initialize SIFT detector
    sift = cv2.SIFT_create()
    
    # Find keypoints and descriptors
    kp1, des1 = sift.detectAndCompute(img1, None)
    kp2, des2 = sift.detectAndCompute(img2, None)
    
    print(f"Image 1: {len(kp1)} keypoints")
    print(f"Image 2: {len(kp2)} keypoints\n")
    
    if des1 is None or des2 is None:
        print("Unable to extract features")
        return
    
    # Match features
    bf = cv2.BFMatcher()
    matches = bf.knnMatch(des1, des2, k=2)
    
    # Apply Lowe's ratio test
    good_matches = []
    for match_pair in matches:
        if len(match_pair) == 2:
            m, n = match_pair
            if m.distance < 0.75 * n.distance:
                good_matches.append(m)
    
    print(f"Good matches: {len(good_matches)}")
    
    # Draw matches
    img_matches = cv2.drawMatches(img1, kp1, img2, kp2, good_matches[:20],
                                 None, flags=cv2.DrawMatchesFlags_NOT_DRAW_SINGLE_POINTS)
    
    cv2.imwrite('feature_matches.png', img_matches)
    print("Feature matches visualization saved to feature_matches.png")

# Usage
detect_modified_regions('original.png', 'modified.png')
feature_matching_diff('original.png', 'modified.png')
```

### Comprehensive Image Analysis Report

Create an automated comprehensive diffing report:

```python
def generate_image_diff_report(image1_path, image2_path, output_file='diff_report.txt'):
    """
    Generate comprehensive comparison report
    """
    report = []
    
    report.append("=" * 60)
    report.append("IMAGE DIFFERENCE ANALYSIS REPORT")
    report.append("=" * 60)
    report.append(f"\nImage 1: {image1_path}")
    report.append(f"Image 2: {image2_path}\n")
    
    # Basic properties
    img1 = Image.open(image1_path)
    img2 = Image.open(image2_path)
    
    report.append("FILE PROPERTIES")
    report.append("-" * 60)
    report.append(f"Image 1: {img1.size}, Mode: {img1.mode}")
    report.append(f"Image 2: {img2.size}, Mode: {img2.mode}\n")
    
    # Pixel comparison
    if img1.size != img2.size:
        img2 = img2.resize(img1.size)
    
    arr1 = np.array(img1)
    arr2 = np.array(img2)
    
    diff = np.abs(arr1.astype(int) - arr2.astype(int))
    diff_pixels = np.sum(diff > 0)
    total_pixels = diff.size
    diff_percent = 100 * diff_pixels / total_pixels
    
    report.append("PIXEL COMPARISON")
    report.append("-" * 60)
    report.append(f"Changed pixels: {diff_pixels}/{total_pixels} ({diff_percent:.3f}%)")
    report.append(f"Max pixel difference: {np.max(diff)}")
    report.append(f"Mean pixel difference: {np.mean(diff):.2f}")
    report.append(f"Median pixel difference: {np.median(diff):.2f}\n")
    
    # Statistical analysis
    report.append("STATISTICAL ANALYSIS")
    report.append("-" * 60)
    
    # MSE and PSNR
    mse = np.mean((arr1.astype(float) - arr2.astype(float)) ** 2)
    if mse > 0:
        psnr = 20 * np.log10(255.0 / np.sqrt(mse))
        report.append(f"MSE: {mse:.4f}")
        report.append(f"PSNR: {psnr:.2f} dB\n")
    
    # SSIM
    from skimage.metrics import structural_similarity as ssim
    if len(arr1.shape) == 3:
        arr1_gray = np.mean(arr1, axis=2)
        arr2_gray = np.mean(arr2, axis=2)
    else:
        arr1_gray = arr1
        arr2_gray = arr2
    
    ssim_val = ssim(arr1_gray, arr2_gray)
    report.append(f"SSIM: {ssim_val:.4f}\n")
    
    # Histogram analysis
    report.append("HISTOGRAM ANALYSIS")
    report.append("-" * 60)
    
    hist1, _ = np.histogram(arr1.flatten(), bins=256, range=(0, 256))
    hist2, _ = np.histogram(arr2.flatten(), bins=256, range=(0, 256))
    
    hist1_norm = hist1 / np.sum(hist1)
    hist2_norm = hist2 / np.sum(hist2)
    
    chi_squared = np.sum((hist1_norm - hist2_norm) ** 2 / (hist1_norm + hist2_norm + 1e-10))
    report.append(f"Histogram chi-squared: {chi_squared:.4f}\n")
    
    # LSB analysis
    report.append("LSB STEGANOGRAPHY ANALYSIS")
    report.append("-" * 60)
    
    flat1 = arr1.flatten()
    flat2 = arr2.flatten()
    
    lsb1 = flat1 & 1
    lsb2 = flat2 & 1
    
    lsb_diff = np.sum(lsb1 != lsb2)
    lsb_diff_percent = 100 * lsb_diff / len(lsb1)
    
    report.append(f"LSB differences: {lsb_diff}/{len(lsb1)} ({lsb_diff_percent:.3f}%)\n")
    
    # Conclusions
    report.append("ANALYSIS CONCLUSIONS")
    report.append("-" * 60)
    
    if diff_percent < 0.1:
        report.append("✓ Images are virtually identical")
    elif diff_percent < 1:
        report.append("✓ Images are very similar with minor differences")
    elif diff_percent < 5:
        report.append("~ Images have moderate differences")
    else:
        report.append("✗ Images are significantly different")
    
    if lsb_diff_percent > 30:
        report.append("⚠ Significant LSB modifications detected - possible steganography")
    
    report_text = '\n'.join(report)
    
    # Save report
    with open(output_file, 'w') as f:
        f.write(report_text)
    
    print(report_text)
    print(f"\nReport saved to {output_file}")

# Usage
generate_image_diff_report('original.png', 'modified.png')
```

Related topics for comprehensive image analysis coverage: **Frequency Domain Analysis (FFT/DCT)**, **Deep Learning-based Image Authentication**, **Blockchain-based Image Verification**, **Automated Malware Detection in Images**.

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
samples, sample_rate, channels = extract_wav_samples('Wavyou2.wav')
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

analyze_wav_bitplanes('Wavyou2.wav')
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

## Archive Manipulation

### ZIP Structure & Hidden Files

ZIP files contain a centralized directory structure that makes them ideal for steganography. Understanding their internal layout is crucial for CTF exploitation.

#### ZIP File Format Basics

A ZIP file consists of local file headers, compressed data, and a central directory at the end. The central directory contains metadata about all archived files, including compressed size, uncompressed size, CRC-32 checksums, and file flags. This separation means data can be hidden between the local file header and the central directory without breaking the archive's integrity.

#### Identifying Hidden Files and Data Injection

Use `zipinfo` to examine the central directory:

```bash
zipinfo -v target.zip
```

This command displays all file metadata including timestamps, compression methods, and file flags. Compare the output against the actual directory listing to identify undocumented entries.

To extract file headers and identify data injection points, use `xxd` or `hexdump`:

```bash
xxd target.zip | head -100
hexdump -C target.zip | grep -A2 "504b"
```

Look for the ZIP local file header signature `504b0304` (in little-endian) and the central directory signature `504b0102`.

#### Extracting Hidden Streams

ZIP files can contain data appended before or after the central directory. Use `unzip` with verbose output to identify anomalies:

```bash
unzip -l target.zip
unzip -t target.zip
```

Extract the entire file and examine it with `strings`:

```bash
strings target.zip | tail -50
```

To carve out embedded data, calculate offsets using `hexdump` and `dd`:

```bash
hexdump -C target.zip | grep "504b0102" | head -1
dd if=target.zip of=recovered.bin bs=1 skip=[offset] count=[size]
```

#### Exploiting ZIP Comment Fields

ZIP files support comment fields in both local headers (4 bytes max) and the central directory (65,535 bytes max). Extract comments with:

```bash
unzip -z target.zip
```

If standard tools fail, parse comments manually using Python:

```python
import zipfile
with zipfile.ZipFile('target.zip', 'r') as z:
    print(z.comment)
    for info in z.infolist():
        print(f"{info.filename}: {info.comment}")
```

#### Detecting Polyglot Archives

Polyglot files combine ZIP with other formats (e.g., ZIP + PNG). Since ZIP reads from the central directory at the end of the file, prepending data doesn't break the archive. Identify polyglots:

```bash
file target.zip
hexdump -C target.zip | head -10
```

If the file doesn't start with `504b`, it's likely polyglot. Extract the ZIP portion:

```bash
tail -c +[offset] target.zip > extracted.zip
```

Or use Python to find the ZIP signature:

```python
with open('target.zip', 'rb') as f:
    data = f.read()
    offset = data.find(b'PK\x03\x04')
    if offset != -1:
        with open('extracted.zip', 'wb') as out:
            out.write(data[offset:])
```

### RAR Analysis

RAR files use a proprietary format with block-based structure, making them more complex to analyze than ZIP archives.

#### RAR Format Structure

RAR files consist of archive headers, file headers, and file data blocks. The archive header identifies the RAR version (RAR4 vs RAR5). Each file header contains metadata, and compression is applied per-file rather than per-archive.

#### Extracting RAR Archives

Use `unrar` for basic extraction:

```bash
unrar l target.rar
unrar e target.rar
unrar x target.rar
```

The `-l` flag lists contents, `-e` extracts without directory structure, and `-x` preserves directory paths.

For password-protected archives:

```bash
unrar x -pPassword target.rar
unrar x -p target.rar
```

The second command prompts for the password interactively.

#### Analyzing RAR Metadata

`unrar` doesn't provide as much detail as `zipinfo` for ZIP files. Use `hexdump` to examine block headers:

```bash
hexdump -C target.rar | head -50
```

RAR block signatures are `52 61 72 21 1a 07 00` for RAR4 and `52 61 72 21 1a 07 01` for RAR5.

Parse RAR headers with Python:

```python
with open('target.rar', 'rb') as f:
    header = f.read(7)
    if header == b'Rar!\x1a\x07\x00':
        print("RAR4 format")
    elif header == b'Rar!\x1a\x07\x01':
        print("RAR5 format")
```

#### RAR5 Specific Analysis

RAR5 uses stronger encryption and different block structures. The `ugrep` tool can search within RAR5 archives:

```bash
ugrep -r "pattern" target.rar
```

For deeper analysis, extract the RAR file and examine the binary structure:

```bash
dd if=target.rar of=rar_blocks.bin bs=1 skip=7
hexdump -C rar_blocks.bin | head -100
```

### TAR/GZ Extraction

TAR files are sequential, not indexed, making them fundamentally different from ZIP and RAR formats.

#### TAR Format Basics

TAR archives store files sequentially with a 512-byte header for each file, followed by the file data padded to 512-byte boundaries. Compression can be applied as a layer (e.g., TAR.GZ).

#### Extracting TAR Archives

Basic extraction:

```bash
tar -tf archive.tar
tar -xf archive.tar
tar -xvf archive.tar
```

The `-t` flag lists contents, `-x` extracts, and `-v` provides verbose output.

For compressed TAR archives, let `tar` auto-detect compression:

```bash
tar -xf archive.tar.gz
tar -xf archive.tar.bz2
tar -xf archive.tar.xz
```

Manually specify compression format:

```bash
tar -xzf archive.tar.gz
tar -xjf archive.tar.bz2
tar -xJf archive.tar.xz
```

#### Analyzing TAR Headers

Extract and examine TAR headers:

```bash
hexdump -C archive.tar | head -50
```

Each file header is 512 bytes. The filename occupies bytes 0-99, file mode bytes 100-107, and timestamps begin at byte 136.

Parse TAR headers with Python:

```python
with open('archive.tar', 'rb') as f:
    for i in range(0, 10):  # Read first 10 file headers
        header = f.read(512)
        if header[:2] == b'\x00\x00':  # End of archive
            break
        filename = header[:100].rstrip(b'\x00').decode('utf-8', errors='ignore')
        size = int(header[124:136].rstrip(b'\x00'), 8)
        print(f"File: {filename}, Size: {size}")
```

#### Detecting Data Between Archives

TAR files don't enforce strict contiguity. Data can be hidden between the end of one TAR archive and the start of another. Identify TAR boundaries:

```bash
strings archive.tar | tail -20
tail -c 1024 archive.tar | hexdump -C
```

Extract potential hidden sections:

```bash
tar -tf archive.tar | wc -l
dd if=archive.tar of=hidden.bin bs=512 skip=[last_file_block_end]
```

### 7Z Format Analysis

7Z is a modern compression format with strong encryption and complex headers.

#### 7Z Structure

7Z archives begin with the signature `37 7a bc af 27 1c` and contain metadata headers followed by encoded streams. The format supports multiple compression algorithms and encryption methods.

#### Extracting 7Z Archives

Use `7z` command-line tool:

```bash
7z l archive.7z
7z x archive.7z
7z e archive.7z
```

For password-protected archives:

```bash
7z x -pPassword archive.7z
7z x -p archive.7z
```

Attempt extraction with progress information:

```bash
7z x -v archive.7z
```

#### Analyzing 7Z Metadata

Examine the archive structure:

```bash
7z l -slt archive.7z
```

The `-slt` flag provides detailed information including compression method, CRC, and file attributes.

Use `hexdump` to view the header:

```bash
hexdump -C archive.7z | head -20
```

Extract and parse the metadata section with Python using the `py7zr` library:

```python
import py7zr
with py7zr.SevenZipFile('archive.7z', 'r') as archive:
    for name, bio in archive.read_stream().items():
        print(f"File: {name}, Size: {bio.getbuffer().nbytes}")
```

If `py7zr` is unavailable:

```bash
pip install py7zr
```

#### 7Z Encryption and Cracking

7Z supports AES-256 encryption. If a password is required, attempt brute-force attacks with `7z2hashcat`:

```bash
7z2hashcat archive.7z > hash.txt
hashcat -m 11600 hash.txt wordlist.txt
```

Alternatively, use `john`:

```bash
7z2john archive.7z > john_hash.txt
john john_hash.txt --wordlist=wordlist.txt
```

### Nested Archives

CTF scenarios frequently use nested archives (archives within archives) to obscure data.

#### Identifying Nesting Levels

Extract the first archive and check for additional archive files:

```bash
file *
```

This command displays file types. Repeat extraction for each discovered archive.

Automate nested extraction with a bash loop:

```bash
#!/bin/bash
while true; do
    files=$(find . -type f \( -name "*.zip" -o -name "*.rar" -o -name "*.7z" -o -name "*.tar.gz" \))
    if [ -z "$files" ]; then
        break
    fi
    for file in $files; do
        dir="${file%.*}_extracted"
        mkdir -p "$dir"
        case "$file" in
            *.zip) unzip -q "$file" -d "$dir" ;;
            *.rar) unrar x -q "$file" "$dir" ;;
            *.7z) 7z x -q "$file" -o"$dir" ;;
            *.tar.gz) tar -xzf "$file" -C "$dir" ;;
        esac
    done
done
```

#### Handling Mixed Archive Types

When nesting involves different formats, use `file` to identify each layer:

```bash
for archive in *.zip *.rar *.7z; do
    [ -e "$archive" ] && file "$archive"
done
```

Extract each type appropriately based on its file signature.

#### Extracting from Specific Offsets

If nested archives are concatenated, identify boundaries using `hexdump`:

```bash
hexdump -C nested_archive | grep -E "(504b|52 61|37 7a|504b0102)"
```

Extract specific sections:

```bash
dd if=nested_archive of=archive1.zip bs=1 skip=0 count=[size1]
dd if=nested_archive of=archive2.rar bs=1 skip=[offset2] count=[size2]
```

### Password-Protected Archives

Password protection is a common CTF challenge requiring dictionary attacks, brute-force techniques, or analysis of weaker protection mechanisms.

#### ZIP Password Recovery

Use `fcrackzip` for fast ZIP cracking:

```bash
fcrackzip -u -D -p wordlist.txt target.zip
```

Parameters: `-u` updates found passwords, `-D` uses dictionary mode, `-p` specifies the wordlist.

For more aggressive brute-forcing with character sets:

```bash
fcrackzip -u -l 1-4 -c a target.zip
```

This attempts passwords of 1-4 characters using lowercase letters only (`a` includes all lowercase, `A` includes uppercase, `0` includes digits).

Convert ZIP hashes for use with `john` or `hashcat`:

```bash
zip2john target.zip > zip_hash.txt
john zip_hash.txt --wordlist=wordlist.txt
```

#### RAR Password Recovery

Use `unrar` to test passwords:

```bash
unrar t -pPassword target.rar
```

If the password is incorrect, the command fails silently. Integrate into a loop:

```bash
while IFS= read -r password; do
    if unrar x -p"$password" target.rar > /dev/null 2>&1; then
        echo "Password found: $password"
        unrar x -p"$password" target.rar
        break
    fi
done < wordlist.txt
```

For hash extraction:

```bash
rar2john target.rar > rar_hash.txt
john rar_hash.txt --wordlist=wordlist.txt
```

#### 7Z Password Recovery

Extract the hash:

```bash
7z2hashcat target.7z > 7z_hash.txt
```

Use `hashcat`:

```bash
hashcat -m 11600 7z_hash.txt wordlist.txt
```

Or `john`:

```bash
7z2john target.7z > john_7z_hash.txt
john john_7z_hash.txt --wordlist=wordlist.txt
```

#### Weak Encryption Detection

Some password-protected archives use weak encryption schemes. [Unverified] Older ZIP implementations may use PKWARE's traditional encryption, which is vulnerable to known-plaintext attacks if the compressed content is known.

Use `bkcrack` for PKWARE encryption:

```bash
bkcrack -c compressed_file.bin -p known_plaintext.bin target.zip
```

Requires the compressed file and a known plaintext of sufficient length to recover the encryption key.

#### Common Password Patterns in CTF

Many CTF challenges use predictable passwords. Test common patterns:

```bash
cat > common_patterns.txt << EOF
password
123456
admin
flag
ctf
test
EOF

while IFS= read -r password; do
    # Test with appropriate tool
done < common_patterns.txt
```

Additionally, examine archive metadata for clues—file timestamps, creator information in comments, or embedded hints often suggest the password structure.

---

## Filesystem Techniques

### Slack Space Analysis

Slack space refers to the unused portion of allocated disk clusters between the logical end of a file and the physical end of its cluster. When a file is saved, it occupies one or more complete clusters regardless of its actual size. The remaining bytes in the final cluster constitute slack space, providing a covert storage location that persists after file deletion and often escapes standard forensic tools.

**Cluster Size and Slack Space Calculation**

The amount of slack space depends on filesystem type and cluster size. NTFS typically uses 4KB clusters (4096 bytes), while FAT32 varies from 512 bytes to 32KB. Calculate slack space as: `(Cluster Size - (File Size MOD Cluster Size))` when the remainder is not zero. A 5KB file on a 4KB cluster system leaves 3KB of slack space in the second cluster.

**Slack Space Extraction Tools and Techniques**

Use `slacker` to analyze and extract slack space from mounted filesystems:

```bash
slacker -v /dev/sda1 > slack_output.txt
slacker -c /dev/sda1 | strings | grep -i flag
```

For more granular analysis, employ `icat` from the SleuthKit to extract specific inode data including slack:

```bash
icat -r /dev/sda1 inode_number > extracted_file.bin
```

The `-r` flag includes slack space in the output. To identify which inodes contain data:

```bash
ils -r /dev/sda1 | grep -E "r/r|r/.\+|a/a" | head -20
```

**Identifying Slack Space in Live Systems**

For mounted filesystems, `dcfldd` provides forensic dumping with slack space preservation:

```bash
dcfldd if=/dev/sda1 of=partition_image.img log=dcfldd.log
```

Then analyze the image with The Sleuth Kit:

```bash
fls -r -p /dev/loop0 > filelist.txt
istat /dev/loop0 inode_number
```

**Data Recovery from Slack Space**

After extracting slack data, use hex editors and string analysis:

```bash
hexdump -C slack_data.bin | head -100
strings slack_data.bin | grep -E "flag|CTF|password"
```

[Unverified] Slack space may contain remnants from previously deleted files, making it a secondary data source beyond intentional steganographic placement.

### EOF (End of File) Data

Data appended after a file's official end marker exists in a gray zone of filesystem recognition—many applications and tools terminate processing at the declared file size, rendering EOF data invisible to standard access methods yet present on disk.

**EOF Data Characteristics**

The file size recorded in filesystem metadata (inode or MFT entry) does not reflect appended data. A 1000-byte JPEG might have an official size of 1000 bytes while 5000 bytes of actual data exist on disk. Tools that respect file size metadata read only the first 1000 bytes; tools that read raw disk blocks acquire all 6000 bytes.

**Tools for EOF Data Extraction**

`hexdump` and `xxd` read beyond declared file boundaries when operating on raw files:

```bash
hexdump -C largefile.jpg | tail -50
xxd largefile.jpg | tail -100
```

Use `od` (octal dump) for detailed byte-level inspection:

```bash
od -A x -t x1z -v largefile.jpg | tail -50
```

Direct disk block analysis bypasses file size restrictions:

```bash
dd if=/dev/sda1 bs=512 skip=2048 count=10 | hexdump -C
```

**File Size Verification**

Compare declared versus actual file size using `stat`:

```bash
stat largefile.jpg
```

The `Size` field reflects metadata; actual disk consumption appears in `Blocks`. Discrepancies indicate potential EOF data:

```bash
actual_bytes=$(stat -c%s largefile.jpg)
block_bytes=$(($(stat -c%b largefile.jpg) * 512))
echo "Declared: $actual_bytes, Physical: $block_bytes"
```

**Extracting Embedded Data**

Extract data beyond the declared file boundary:

```bash
declared_size=$(stat -c%s largefile.jpg)
dd if=largefile.jpg bs=1 skip=$declared_size | hexdump -C
```

Or using Python for precise extraction:

```python
with open('largefile.jpg', 'rb') as f:
    declared_size = os.path.getsize('largefile.jpg')
    f.seek(declared_size)
    eof_data = f.read()
    with open('eof_extracted.bin', 'wb') as out:
        out.write(eof_data)
```

### File Carving

File carving reconstructs files from raw disk data without relying on filesystem metadata, using magic bytes and structural patterns to identify file boundaries. This technique recovers deleted files and discovers hidden data embedded within unallocated space or within other files.

**Magic Number Recognition**

Every file type begins with specific byte sequences. JPEG files start with `FF D8 FF`, PNG with `89 50 4E 47`, GIF with `47 49 46`, ZIP with `50 4B 03 04`, and ELF binaries with `7F 45 4C 46`. Carving tools search for these signatures and extract contiguous data until finding end-of-file markers or the start of the next file type.

**Manual Carving with Hex Editors**

`hexdump` identifies magic bytes across entire partitions:

```bash
hexdump -C /dev/sda1 | grep -E "ff d8 ff|89 50 4e 47|47 49 46|50 4b 03 04"
```

Once located, calculate the byte offset and extract using `dd`:

```bash
# If magic byte found at hex offset 0x10000 (65536 decimal)
dd if=/dev/sda1 bs=1 skip=65536 count=500000 of=carved_file.jpg
```

**Automated Carving with Foremost**

`foremost` is Kali's primary file carving tool, configured with file type specifications:

```bash
foremost -i /dev/sda1 -o output_directory
```

Restrict carving to specific file types:

```bash
foremost -i /dev/sda1 -t jpeg,png,zip -o carving_output
```

The `-d` flag enables deeper analysis on sector boundaries:

```bash
foremost -i partition_image.img -t all -d -v -o results
```

**Foremost Configuration Customization**

Edit `/etc/foremost.conf` to define custom file signatures. To carve a custom binary format starting with `DEADBEEF`:

```
# Custom format definition
custom  y  8   DEADBEEF    \\x00\\x00\\x00\\x00    50000
```

Then execute:

```bash
foremost -c /etc/foremost.conf -i disk_image -t custom
```

**Scalpel for Precise Carving**

`scalpel` is a high-performance carver supporting fuzzy matching and complex file structures:

```bash
scalpel -c /etc/scalpel/scalpel.conf -i disk_image -o scalpel_output
```

Define carving boundaries in the configuration file to prevent reconstructing corrupted files:

```
# Format: extension, case_sensitive, max_size, header, footer
jpg     y   500K    \\xff\\xd8\\xff      \\xff\\xd9
png     y   10M     \\x89\\x50\\x4e\\x47  \\x00\\x00\\x00\\x00\\x49\\x45\\x4e\\x44\\xae\\x42\\x60\\x82
```

**Analysis of Carved Files**

After carving, verify integrity and extract metadata:

```bash
file carved_file.jpg
exiftool carved_file.jpg
identify -verbose carved_file.png
```

### Magic Number Analysis

Magic numbers (file signatures) are fixed byte sequences at file beginnings that identify file type and structure. Analyzing these bytes reveals file type mismatches, disguised files, and modification attempts.

**Common Magic Numbers and Signatures**

**Images:** JPEG (`FF D8 FF E0` or `FF D8 FF E1`), PNG (`89 50 4E 47 0D 0A 1A 0A`), GIF (`47 49 46 38` for "GIF8"), BMP (`42 4D`), TIFF (`49 49 2A 00` for little-endian, `4D 4D 00 2A` for big-endian)

**Archives:** ZIP (`50 4B 03 04`), RAR (`52 61 72 21`), GZIP (`1F 8B`), 7Z (`37 7A BC AF 27 1C`)

**Documents:** PDF (`25 50 44 46`), Microsoft Office DOCX/XLSX (`50 4B 03 04` followed by specific internal structure)

**Executables:** ELF (`7F 45 4C 46`), PE Windows (`4D 5A` or "MZ"), Mach-O macOS (`FE ED FA` variants)

**Examining Magic Numbers**

Use `hexdump` to inspect file headers:

```bash
hexdump -C suspect_file | head -5
xxd suspect_file | head -20
```

Examine the first 16 bytes specifically:

```bash
od -A x -t x1 -N 16 suspect_file
```

**Detecting Type Mismatches**

Compare file extension with actual magic number:

```bash
file suspect_file.txt
# If file reports "JPEG image data" but extension is .txt, type mismatch detected
```

Create a verification script:

```bash
declared_ext="${1##*.}"
actual_type=$(file -b "$1" | cut -d' ' -f1)
echo "Extension: $declared_ext, Actual: $actual_type"
```

**Extracting Embedded Files via Magic Numbers**

Search for hidden files by scanning for their magic bytes:

```bash
grep -a -b -o $'\\x89PNG' largefile.bin
# Output: 1048576:...  (offset in bytes)
```

Extract file at discovered offset:

```bash
dd if=largefile.bin bs=1 skip=1048576 count=1000000 of=extracted.png
```

**Polyglot Detection Using Magic Analysis**

Polyglot files contain multiple valid file signatures. Inspect sequential magic numbers:

```bash
hexdump -C polyglot_file | head -20
# May reveal both PDF magic (25 50 44 46) and JPEG magic (FF D8 FF)
```

### Alternate Data Streams (ADS)

Alternate Data Streams are a Windows NTFS filesystem feature allowing multiple data forks associated with a single filename. The primary data stream (unnamed) typically contains the visible file content, while additional named streams remain hidden from standard directory listings and file managers. This mechanism originates from Apple's HFS filesystem design and provides steganographic capability in Windows environments.

**ADS Fundamentals**

Access ADS syntax using colons: `filename.ext:stream_name`. A file `document.docx:hidden` refers to the `hidden` stream of `document.docx`. These streams occupy actual disk space and persist independently of the primary file.

**Creating and Accessing ADS on Windows**

From PowerShell or Command Prompt:

```batch
# Create a stream containing sensitive data
echo "Secret message" > visible_file.txt:hidden_stream

# View primary stream (shows no additional data)
type visible_file.txt

# Access the hidden stream (requires explicit stream reference)
type visible_file.txt:hidden_stream
```

From Kali Linux (via mounting NTFS or analyzing images), declare NTFS support:

```bash
sudo mount -t ntfs-3g /dev/sda1 /mnt/windows
cat /mnt/windows/path/to/file.txt:stream_name
```

If direct access fails, use `ntfscat` from ntfs-3g utilities:

```bash
ntfscat -i ntfs_partition.img -f /path/to/file.txt:stream_name
```

**Detecting ADS Streams**

The `dir /s /r` command on Windows lists streams:

```batch
dir /s /r C:\
```

[Unverified] Stream notation appears as `filename.txt:stream_name:$DATA` in comprehensive listings.

From Linux, enumerate streams using `ntfsls` and inspection tools:

```bash
ntfsls -s /dev/sda1 /windows/path
```

Alternatively, analyze the MFT (Master File Table) directly for stream attributes:

```bash
python3 -c "
import struct
with open('mft_dump.bin', 'rb') as f:
    data = f.read()
    # MFT records contain attribute headers; stream attributes appear as type 0x80 (data)
    # Multiple 0x80 attributes indicate multiple streams
"
```

**Extracting ADS Content from Forensic Images**

Use `ntfs-3g` with a raw image:

```bash
sudo mount -o loop,ro ntfs_image.img /mnt/forensic
find /mnt/forensic -type f -exec sh -c 'ntfscat -i "$1" | strings' _ {} \;
```

Or use Python with `ntfs-3g` bindings for automated extraction:

```python
import subprocess
import os

def extract_ads(image_path, mount_point):
    subprocess.run(['mount', '-t', 'ntfs-3g', '-o', 'ro,loop', image_path, mount_point])
    for root, dirs, files in os.walk(mount_point):
        for file in files:
            filepath = os.path.join(root, file)
            result = subprocess.run(['ntfscat', '-i', image_path, '-f', filepath], 
                                   capture_output=True)
            if result.stdout:
                print(f"Content in {filepath}: {result.stdout}")
```

**ADS Tools and Utilities**

`lads.exe` (List Alternate Data Streams) enumerates streams on Windows systems:

```batch
lads.exe C:\path\to\file.txt
```

For Linux-based forensic analysis, use `python-libfsntfs`:

```bash
fsntfsinfo -i ntfs_image.img -t all
```

**Limitations and Detection Considerations**

[Inference] Antivirus and endpoint security solutions increasingly detect and flag ADS activity, limiting steganographic effectiveness in monitored environments.

### Polyglot Files

Polyglot files contain valid data for multiple file types simultaneously, exploiting the structural differences in how various file formats parse their content. A single byte sequence can be simultaneously valid as a PDF, JPEG, and ZIP archive, with each application reading only the portions relevant to its specification.

**Polyglot Construction Principles**

File format parsing prioritizes different aspects: JPEG looks for sequential marker bytes but ignores content between markers; ZIP reads its central directory from the file end; PDF reads objects sequentially but uses cross-reference tables. Construct polyglots by concatenating files such that each parser extracts intended segments.

**PDF-ZIP Polyglots**

A PDF-ZIP polyglot appears as a valid PDF to PDF readers and a valid ZIP to ZIP tools. Construction:

```bash
# Create a minimal valid PDF
cat > base.pdf << 'EOF'
%PDF-1.4
1 0 obj<</Type/Catalog/Pages 2 0 R>>endobj
2 0 obj<</Type/Pages/Kids[3 0 R]/Count 1>>endobj
3 0 obj<</Type/Page/Parent 2 0 R/MediaBox[0 0 612 792]>>endobj
xref
0 4
0000000000 65535 f
0000000009 00000 n
0000000058 00000 n
0000000115 00000 n
trailer<</Size 4/Root 1 0 R>>
startxref
192
%%EOF
EOF

# Create a ZIP file with hidden content
zip -q payload.zip secret.txt

# Concatenate: PDF first, then ZIP
cat base.pdf payload.zip > polyglot.pdf
```

The result opens as a PDF in PDF readers; unzipping `polyglot.pdf` extracts `secret.txt`.

**JPEG-ZIP Polyglots**

JPEG files terminate parsing at the End-of-Image marker (`FF D9`). Data after this marker is ignored by JPEG decoders but accessible to ZIP tools:

```bash
# Create a valid JPEG
convert -size 100x100 xc:blue image.jpg

# Append ZIP data after JPEG's end marker
zip -q payload.zip flag.txt
cat image.jpg payload.zip > polyglot.jpg
```

Verify with:

```bash
file polyglot.jpg          # Reports JPEG
unzip -l polyglot.jpg      # Lists ZIP contents
```

**PNG-PDF Polyglots**

PNG specifies chunk lengths explicitly, allowing arbitrary data after the IEND chunk:

```bash
# Create valid PNG
convert -size 100x100 xc:red image.png

# Extract PNG without IEND chunk
dd if=image.png bs=1 skip=0 of=image_no_iend.png count=$(($(stat -c%s image.png)-8))

# Append PDF content
cat image_no_iend.png payload.pdf > polyglot.png
# Append IEND chunk (8 bytes: 00 00 00 00 49 45 4E 44 AE 42 60 82)
printf '\x00\x00\x00\x00\x49\x45\x4E\x44\xAE\x42\x60\x82' >> polyglot.png
```

**Detection and Analysis of Polyglots**

Use `file` with verbosity to identify multiple types:

```bash
file -k polyglot.jpg
# May report: "JPEG image data... ZIP archive data"
```

Analyze with both specialized tools:

```bash
identify polyglot.jpg      # Image analysis
unzip -t polyglot.jpg      # ZIP validation
pdftotext polyglot.pdf     # PDF extraction (if PDF polyglot)
```

Hex inspection reveals multiple magic numbers:

```bash
hexdump -C polyglot.jpg | head -5
hexdump -C polyglot.jpg | tail -5
```

**Polyglot Extraction Methodology**

Extract individual components by carving at magic number boundaries:

```bash
# Find all magic numbers in file
hexdump -C polyglot.jpg | grep -E "ff d8|50 4b"

# Extract JPEG (FF D8 ... FF D9)
dd if=polyglot.jpg of=extracted.jpg bs=1 skip=0 count=$((zipstart_offset))

# Extract ZIP (50 4B ... at zipstart_offset)
dd if=polyglot.jpg of=extracted.zip bs=1 skip=$((zipstart_offset))
```

**[Unverified]** Some antivirus solutions block or quarantine polyglot files due to multiple valid interpretations, potentially affecting deliverability in real-world scenarios.

---

## Document Steganography

### PDF Hidden Layers

PDF files support multiple layers, objects, and rendering instructions that can conceal data invisible to casual viewing.

**Key Concepts:**

- PDF structure consists of objects referenced by cross-reference tables
- Layers (Optional Content Groups) can be toggled on/off programmatically
- Hidden objects may exist outside visible page boundaries
- Incremental updates allow appending data without modifying original content
- JavaScript and actions can trigger hidden content display

**Essential Tools:**

```bash
# pdfinfo - Extract PDF metadata and structure
pdfinfo document.pdf
pdfinfo -meta document.pdf  # Extract XMP metadata

# pdfimages - Extract all images from PDF
pdfimages -all document.pdf output_prefix
pdfimages -list document.pdf  # List without extracting

# pdftk - PDF manipulation toolkit
pdftk document.pdf dump_data output metadata.txt
pdftk document.pdf burst  # Split into individual pages
pdftk document.pdf uncompress output uncompressed.pdf

# qpdf - PDF transformation and analysis
qpdf --qdf --object-streams=disable input.pdf output.pdf
qpdf --show-object=X input.pdf  # View specific object

# pdfparser.py (from Didier Stevens' tools)
python pdfparser.py document.pdf
python pdfparser.py -s /JavaScript document.pdf  # Search for JavaScript
python pdfparser.py --dump=X document.pdf  # Dump specific object
python pdfparser.py --filter document.pdf  # Show filtered objects
```

**Analysis Workflow:**

1. **Structure Analysis:**

```bash
# Examine PDF structure
pdfinfo document.pdf
strings document.pdf | grep -i "layer\|ocg\|javascript"

# Decompress for inspection
pdftk document.pdf uncompress output uncompressed.pdf
qpdf --qdf input.pdf output.pdf

# Manual inspection
less uncompressed.pdf
# Look for: /OCG, /Layer, /OC, /AA (Additional Actions), /JS (JavaScript)
```

2. **Layer Extraction:**

```bash
# Using QPDF to examine Optional Content Groups
qpdf --json input.pdf | jq '.objects[] | select(."/Type" == "/OCG")'

# Convert to PostScript (may reveal hidden layers)
pdftops document.pdf output.ps
```

3. **Object Analysis:**

```bash
# List all objects
python pdfparser.py document.pdf | grep obj

# Dump suspicious objects
python pdfparser.py --dump=15 document.pdf > object15.bin

# Search for specific streams
python pdfparser.py -s /EmbeddedFile document.pdf
```

**Common Hiding Techniques:**

- White text on white background (select all to reveal)
- Objects positioned outside page boundaries
- Invisible layers with `/Print false` or `/View false`
- Data in deleted but still-present objects
- Embedded files in annotations
- JavaScript-triggered content

**Manual Inspection Points:**

```
/OCG (Optional Content Group) - Layer definitions
/AS /Off - Hidden layer
/Intent /View - Display intent
/AA - Additional Actions (automated triggers)
/JS or /JavaScript - Embedded scripts
/EmbeddedFiles - File attachments
/AcroForm - Form data (can hide information)
```

### Microsoft Office XML Analysis

Modern Office formats (.docx, .xlsx, .pptx) are ZIP archives containing XML files, enabling multiple steganographic vectors.

**File Structure:**

```
document.docx/
├── [Content_Types].xml
├── _rels/
├── docProps/
│   ├── app.xml
│   └── core.xml
└── word/
    ├── document.xml
    ├── fontTable.xml
    ├── media/
    ├── _rels/
    └── settings.xml
```

**Extraction and Analysis:**

```bash
# Unzip Office document
unzip document.docx -d document_extracted
# Or
7z x document.xlsx -odocument_extracted

# Quick inspection of structure
unzip -l document.docx

# Extract specific file
unzip -p document.docx word/document.xml > document_content.xml

# Search for embedded objects
find document_extracted -type f -name "*.bin" -o -name "oleObject*"
```

**Analysis Commands:**

```bash
# Search XML for suspicious content
grep -r "base64\|dataStore\|binData" document_extracted/

# Examine relationships (links between components)
cat document_extracted/word/_rels/document.xml.rels
cat document_extracted/_rels/.rels

# Extract embedded OLE objects
find document_extracted -name "embeddings" -type d
ls -lah document_extracted/word/embeddings/

# OLE object extraction
oleobj document.docx
olevba document.docx  # For macro analysis

# Search for hidden text attributes
grep -r "w:vanish\|w:color.*ffffff" document_extracted/word/
```

**Tools for Office Analysis:**

```bash
# olevba - Macro and OLE analysis (from oletools)
olevba document.docm
olevba --decode document.docm  # Extract and decode

# oleobj - Extract embedded objects
oleobj document.docx

# oleid - Identify file type and characteristics
oleid document.xlsx

# msoffcrypto-tool - Decrypt password-protected files
msoffcrypto-tool document.docx --password=pass123 -o decrypted.docx

# strings with filtering
strings document.docx | grep -E "flag|CTF|hidden"
```

**Key Steganographic Vectors:**

1. **Hidden Text:**

```xml
<!-- In word/document.xml -->
<w:vanish/>  <!-- Invisible text -->
<w:color w:val="FFFFFF"/>  <!-- White text -->
<w:sz w:val="2"/>  <!-- Tiny font size -->
```

2. **Custom XML Data Stores:**

```bash
# Check for custom XML
ls document_extracted/customXml/
cat document_extracted/customXml/item*.xml
```

3. **Document Properties:**

```bash
# Hidden metadata
cat document_extracted/docProps/core.xml
cat document_extracted/docProps/app.xml
cat document_extracted/docProps/custom.xml  # Custom properties
```

4. **Embedded Objects:**

```bash
# ActiveX controls, OLE objects
ls document_extracted/word/embeddings/
ls document_extracted/xl/embeddings/
ls document_extracted/ppt/embeddings/

# Extract and analyze
file document_extracted/word/embeddings/oleObject1.bin
```

5. **Alternative Data Streams:** [Inference - behavior varies by extraction method]

```bash
# Check for NTFS ADS (if file came from Windows)
getfattr -d document.docx
```

### OpenDocument Format

OpenDocument Format (.odt, .ods, .odp) uses similar ZIP-based XML structure with some differences from Microsoft Office.

**Structure:**

```
document.odt/
├── mimetype
├── META-INF/
│   └── manifest.xml
├── content.xml
├── meta.xml
├── settings.xml
├── styles.xml
└── Pictures/
```

**Analysis Process:**

```bash
# Extract ODF document
unzip document.odt -d odt_extracted

# Essential files to examine
cat odt_extracted/mimetype
cat odt_extracted/META-INF/manifest.xml  # Lists all contained files
cat odt_extracted/content.xml  # Main content
cat odt_extracted/meta.xml  # Metadata
cat odt_extracted/settings.xml  # User settings (may contain data)

# Search for embedded objects
grep -r "office:binary-data" odt_extracted/

# Check for embedded images
ls -lah odt_extracted/Pictures/
ls -lah odt_extracted/ObjectReplacements/
```

**Specific Techniques:**

```bash
# Base64-embedded data in XML
grep -A 50 "office:binary-data" odt_extracted/content.xml | \
  sed -n '/<office:binary-data>/,/<\/office:binary-data>/p' | \
  grep -v "office:binary-data" | \
  base64 -d > extracted_object.bin

# Hidden text analysis
grep "text:display=\"none\"" odt_extracted/content.xml
grep "fo:color=\"#ffffff\"" odt_extracted/content.xml

# Examine all manifest entries
xmllint --format odt_extracted/META-INF/manifest.xml
```

**Comparison with MS Office:**

|Feature|MS Office|OpenDocument|
|---|---|---|
|Main content|word/document.xml|content.xml|
|Metadata|docProps/*.xml|meta.xml|
|File list|[Content_Types].xml|META-INF/manifest.xml|
|Binary encoding|Separate files|Often base64 in XML|

### Embedded Objects

Embedded objects include OLE objects, ActiveX controls, and file attachments within documents.

**OLE Object Analysis:**

```bash
# oletools suite installation
sudo apt install python3-oletools

# oleid - Identify file characteristics
oleid suspicious.doc

# olevba - Extract and analyze VBA macros
olevba suspicious.doc
olevba --decode suspicious.doc
olevba --reveal suspicious.doc  # Deobfuscate

# oleobj - Extract embedded objects
oleobj suspicious.doc
oleobj --save-all suspicious.doc -d extracted_objects/

# oledump - Stream analysis
oledump.py suspicious.doc
oledump.py -s 10 -d suspicious.doc  # Dump stream 10
oledump.py -s 10 -v suspicious.doc  # Decompress and dump
```

**RTF Embedded Object Extraction:**

```bash
# RTF files use hexadecimal encoding
rtfobj document.rtf
rtfobj --save-all document.rtf -d extracted/

# Manual extraction
grep "objdata" document.rtf | sed 's/.*objdata//' | xxd -r -p > object.bin

# Check extracted object type
file extracted/*.bin
```

**PDF Embedded Files:**

```bash
# Extract using pdfdetach (from poppler-utils)
pdfdetach -list document.pdf
pdfdetach -saveall -o output_dir document.pdf

# Using qpdf
qpdf --json document.pdf | jq '.objects[] | select(."/Type" == "/EmbeddedFile")'

# Manual extraction with pdfparser
python pdfparser.py -s /EmbeddedFile document.pdf
python pdfparser.py --dump=X document.pdf | sed '1,2d' > embedded.bin
```

**Polyglot File Detection:** [Inference - requires multiple format parsers]

```bash
# A file valid as multiple formats
file -k suspicious_file  # Check all matching types

# Check for multiple file signatures
xxd suspicious_file | head -n 20
binwalk suspicious_file
foremost suspicious_file -o extracted/

# Test parsing as different formats
unzip -t suspicious_file 2>&1
pdf-parser.py suspicious_file 2>&1
```

### Font-Based Hiding

Font manipulation can conceal data through homoglyphs, custom fonts, or font metric modifications.

**Unicode Homoglyphs:**

Characters that appear identical but have different Unicode codepoints can encode data.

```bash
# Detect non-ASCII characters
cat document.txt | LC_ALL=C grep --color='auto' -P '[^\x00-\x7F]'

# List all Unicode codepoints
python3 << 'EOF'
with open('document.txt', 'r', encoding='utf-8') as f:
    content = f.read()
    for char in content:
        if ord(char) > 127:
            print(f"{char} U+{ord(char):04X} {char.encode('utf-8')}")
EOF

# Detect homoglyphs (visually similar characters)
python3 << 'EOF'
import sys
content = sys.stdin.read()
suspicious = []
# Cyrillic 'а' (U+0430) vs Latin 'a' (U+0061)
if '\u0430' in content:
    suspicious.append("Cyrillic 'a' detected")
# Greek 'ο' (U+03BF) vs Latin 'o' (U+006F)  
if '\u03BF' in content:
    suspicious.append("Greek 'o' detected")
for s in suspicious:
    print(s)
EOF
```

**Custom Font Analysis:**

```bash
# Extract fonts from documents
# For PDFs
pdffonts document.pdf

# Extract font files
python pdfparser.py -s /FontFile document.pdf

# For Office documents
unzip document.docx -d extracted/
find extracted/ -name "*.ttf" -o -name "*.otf"

# Analyze font files
fontforge -lang=py -c 'import sys; f=fontforge.open(sys.argv[1]); print(f.glyphs())' font.ttf

# Check for unusual glyphs
ftdump font.ttf
```

**Zero-Width Characters:**

```bash
# Detect zero-width characters
python3 << 'EOF'
zero_width = [
    '\u200B',  # Zero Width Space
    '\u200C',  # Zero Width Non-Joiner
    '\u200D',  # Zero Width Joiner
    '\uFEFF',  # Zero Width No-Break Space
    '\u180E',  # Mongolian Vowel Separator
]
with open('document.txt', 'r', encoding='utf-8') as f:
    content = f.read()
    for i, char in enumerate(content):
        if char in zero_width:
            print(f"Position {i}: {repr(char)} U+{ord(char):04X}")
EOF

# Extract binary data from zero-width encoding
python3 << 'EOF'
with open('document.txt', 'r', encoding='utf-8') as f:
    content = f.read()
    binary = ''
    for char in content:
        if char == '\u200B':  # 0
            binary += '0'
        elif char == '\u200C':  # 1
            binary += '1'
    if binary:
        print(f"Binary: {binary}")
        print(f"ASCII: {bytes(int(binary[i:i+8], 2) for i in range(0, len(binary), 8)).decode()}")
EOF
```

### Whitespace Steganography

Data encoded in whitespace (spaces, tabs, newlines) is invisible to human readers.

**Detection Methods:**

```bash
# Visualize whitespace
cat -A document.txt  # Shows $ for newlines, ^I for tabs

# Show whitespace explicitly
sed 's/ /<SPACE>/g; s/\t/<TAB>/g' document.txt

# Count whitespace patterns
grep -o '[ \t]\+' document.txt | sort | uniq -c

# Check for unusual whitespace at line ends
grep '[ \t]$' document.txt

# Detect ZWSP and other zero-width characters
hexdump -C document.txt | grep -E "e2 80 8[b-f]|ef bb bf"
```

**SNOW (Whitespace Steganography Tool):**

```bash
# Install SNOW
# [Unverified - installation method depends on distribution]
# May need to compile from source or find in repos

# Encode data
snow -C -p "password" -m "secret message" input.txt output.txt

# Decode data
snow -C -p "password" output.txt

# Without password
snow -C -m "secret message" input.txt output.txt
snow -C output.txt
```

**Manual Space/Tab Encoding:**

Common encoding: space = 0, tab = 1 (or vice versa)

```bash
# Extract space/tab pattern
python3 << 'EOF'
with open('document.txt', 'r') as f:
    for line in f:
        # Extract trailing whitespace
        line = line.rstrip('\n\r')
        if len(line) != len(line.rstrip()):
            ws = line[len(line.rstrip()):]
            binary = ws.replace(' ', '0').replace('\t', '1')
            print(f"Binary: {binary}")
            if len(binary) >= 8 and len(binary) % 8 == 0:
                try:
                    text = bytes(int(binary[i:i+8], 2) for i in range(0, len(binary), 8)).decode('ascii')
                    print(f"ASCII: {text}")
                except:
                    pass
EOF
```

**Stegsnow (Alternative Implementation):**

```bash
# Encode
stegsnow -C -p password -m "secret" cover.txt output.txt

# Decode
stegsnow -C -p password output.txt

# Examine without decoding
cat -A output.txt | grep -E '\^I| $'
```

**Line Ending Steganography:**

```bash
# Different line endings: LF (\n) vs CRLF (\r\n)
# LF = 0, CRLF = 1

# Detect line ending types
file document.txt
dos2unix -ih document.txt  # Identify line endings

# Extract pattern
python3 << 'EOF'
with open('document.txt', 'rb') as f:
    content = f.read()
    binary = ''
    i = 0
    while i < len(content):
        if content[i:i+2] == b'\r\n':
            binary += '1'
            i += 2
        elif content[i:i+1] == b'\n':
            binary += '0'
            i += 1
        else:
            i += 1
    print(f"Binary: {binary}")
    if len(binary) >= 8:
        text = bytes(int(binary[i:i+8], 2) for i in range(0, len(binary)-(len(binary)%8), 8))
        print(f"Decoded: {text}")
EOF
```

**Combination Techniques:** [Inference - multiple methods may be layered]

```bash
# Check for multiple steganography types simultaneously
python3 << 'EOF'
import sys

def analyze_whitespace(filename):
    with open(filename, 'rb') as f:
        content = f.read()
    
    # Check trailing whitespace
    lines = content.split(b'\n')
    trailing_ws = []
    for line in lines:
        if line and (line[-1:] == b' ' or line[-1:] == b'\t'):
            trailing_ws.append(line)
    
    # Check line ending patterns
    crlf_count = content.count(b'\r\n')
    lf_count = content.count(b'\n') - crlf_count
    
    print(f"Lines with trailing whitespace: {len(trailing_ws)}")
    print(f"CRLF endings: {crlf_count}")
    print(f"LF endings: {lf_count}")
    
    # Check for zero-width characters
    zwsp_chars = [b'\xe2\x80\x8b', b'\xe2\x80\x8c', b'\xe2\x80\x8d', b'\xef\xbb\xbf']
    for zw in zwsp_chars:
        if zw in content:
            print(f"Found zero-width character: {zw.hex()}")

if len(sys.argv) > 1:
    analyze_whitespace(sys.argv[1])
EOF
# Usage: python3 script.py document.txt
```

---

**Important Related Topics:**

- **XML External Entity (XXE) attacks** in document analysis
- **Macro analysis and deobfuscation** for embedded code
- **Office document encryption** and password recovery techniques

---

# Network & Protocol Steganography

## PCAP File Analysis

### Core Concepts

PCAP (Packet Capture) files contain recorded network traffic that may hide data through timing patterns, unusual protocol usage, payload manipulation, or metadata anomalies. Analysis involves extracting, filtering, and reconstructing hidden information from packet streams.

### Primary Tools

**Wireshark**

```bash
# CLI analysis with tshark
tshark -r capture.pcap -T fields -e frame.number -e ip.src -e ip.dst -e data

# Extract HTTP objects
tshark -r capture.pcap --export-objects http,./extracted_http/

# Follow TCP streams
tshark -r capture.pcap -z follow,tcp,ascii,0

# Filter specific protocols
tshark -r capture.pcap -Y "http or dns or icmp"

# Extract data payloads only
tshark -r capture.pcap -T fields -e data.data -Y "data.len > 0" | xxd -r -p > extracted_data.bin
```

**tcpflow**

```bash
# Reconstruct TCP sessions
tcpflow -r capture.pcap -o output_dir/

# Extract files from specific connection
tcpflow -r capture.pcap -e scanner host 192.168.1.100

# Console output for quick inspection
tcpflow -r capture.pcap -C
```

**NetworkMiner**

```bash
# GUI tool - focus on Files, Images, Parameters tabs
# Extract credentials automatically from captured traffic
networkminer capture.pcap
```

**scapy**

```python
from scapy.all import *

# Load PCAP
packets = rdpcap("capture.pcap")

# Extract specific field data
for pkt in packets:
    if pkt.haslayer(Raw):
        print(pkt[Raw].load)

# Analyze packet timing
for i in range(len(packets)-1):
    time_delta = packets[i+1].time - packets[i].time
    print(f"Packet {i}: {time_delta} seconds")

# Extract LSB from IP IDs
ip_ids = [pkt[IP].id for pkt in packets if IP in pkt]
binary_data = ''.join([str(id & 1) for id in ip_ids])
```

### Analysis Methodology

**Step 1: Initial Reconnaissance**

```bash
# Quick statistics
capinfos capture.pcap

# Protocol hierarchy
tshark -r capture.pcap -q -z io,phs

# Endpoint analysis
tshark -r capture.pcap -q -z endpoints,ip
```

**Step 2: Anomaly Detection**

```bash
# Identify unusual packet sizes
tshark -r capture.pcap -T fields -e frame.number -e frame.len | \
  awk '{if($2 > 1500 || $2 < 60) print $0}'

# Check for non-standard ports
tshark -r capture.pcap -T fields -e tcp.dstport -e udp.dstport | \
  sort -n | uniq -c | sort -rn

# Find suspicious timing patterns
tshark -r capture.pcap -T fields -e frame.time_relative -e frame.len
```

**Step 3: Data Extraction Techniques**

Extract payloads by protocol:

```bash
# HTTP POST data
tshark -r capture.pcap -Y "http.request.method == POST" -T fields -e http.file_data

# DNS query names (potential data exfiltration)
tshark -r capture.pcap -Y "dns.qry.name" -T fields -e dns.qry.name

# TLS SNI fields
tshark -r capture.pcap -Y "tls.handshake.extensions_server_name" \
  -T fields -e tls.handshake.extensions_server_name
```

### Common Hiding Techniques in PCAPs

**Packet Payload Encoding**

```bash
# Look for base64 in payloads
tshark -r capture.pcap -T fields -e data.data | xxd -r -p | strings | grep -E '^[A-Za-z0-9+/=]{20,}$'

# Extract hex payloads and decode
tshark -r capture.pcap -T fields -e data.data -Y "data.len > 0" | \
  tr -d '\n' | xxd -r -p > combined_payload.bin
```

**Fragmented Data Reconstruction**

```bash
# Reassemble fragmented IP packets
tshark -r capture.pcap -Y "ip.flags.mf == 1 or ip.frag_offset > 0" \
  -T fields -e ip.id -e data.data
```

**File Carving from Streams**

```bash
# Use binwalk on extracted stream
tcpflow -r capture.pcap -o streams/
binwalk -e streams/*

# foremost for file recovery
foremost -i streams/192.168.001.100.00080-192.168.001.101.55234 -o carved/
```

---

## TCP/IP Header Analysis

### IP Header Fields for Steganography

**IP Identification Field (16 bits)**

The IP ID field can carry 2 bytes per packet. Tools like Covert_TCP exploit this.

```python
# Extract IP IDs
from scapy.all import *

pcap = rdpcap("capture.pcap")
ip_ids = [pkt[IP].id for pkt in pcap if IP in pkt]

# Convert to bytes
data = b''.join([id.to_bytes(2, 'big') for id in ip_ids])
print(data)

# Check for ASCII patterns
print(data.decode('ascii', errors='ignore'))
```

**IP Flags and Fragment Offset**

Reserved bit (bit 0) can store 1 bit per packet:

```python
# Extract reserved bit
reserved_bits = [(pkt[IP].flags >> 2) & 1 for pkt in pcap if IP in pkt]
binary_string = ''.join(map(str, reserved_bits))

# Convert to bytes
byte_data = bytes(int(binary_string[i:i+8], 2) for i in range(0, len(binary_string), 8))
```

**Type of Service (ToS) Field**

```bash
# Extract ToS values
tshark -r capture.pcap -T fields -e ip.dsfield.dscp -e ip.dsfield.ecn

# Analyze with scapy
tos_values = [pkt[IP].tos for pkt in pcap if IP in pkt]
```

### TCP Header Steganography

**TCP Sequence Number Manipulation**

```python
# Analyze sequence number patterns
seq_nums = [pkt[TCP].seq for pkt in pcap if TCP in pkt]

# Check for LSB encoding
lsb_data = ''.join([str(seq & 1) for seq in seq_nums])
bytes_data = bytes(int(lsb_data[i:i+8], 2) for i in range(0, len(lsb_data)-8, 8))
```

**TCP Initial Sequence Number (ISN)**

```bash
# Extract ISNs (SYN packets only)
tshark -r capture.pcap -Y "tcp.flags.syn == 1 and tcp.flags.ack == 0" \
  -T fields -e tcp.seq
```

**TCP Acknowledgment Numbers**

```python
# ACK number analysis
acks = [pkt[TCP].ack for pkt in pcap if TCP in pkt and pkt[TCP].flags & 0x10]

# Decode if LSB encoded
ack_lsb = ''.join([str(ack & 1) for ack in acks])
```

**TCP Urgent Pointer**

```bash
# Check urgent pointer usage (rarely legitimate)
tshark -r capture.pcap -Y "tcp.urgent_pointer != 0" -T fields -e tcp.urgent_pointer
```

**TCP Options Field**

```python
# Extract TCP options
for pkt in pcap:
    if TCP in pkt and pkt[TCP].options:
        print(f"Options: {pkt[TCP].options}")
        
# Check for custom/unusual options
tshark -r capture.pcap -Y "tcp.options" -T fields -e tcp.options
```

**TCP Window Size Modulation**

```bash
# Extract window sizes for pattern analysis
tshark -r capture.pcap -T fields -e tcp.window_size_value > windows.txt

# Look for patterns (e.g., ASCII range 32-126)
awk '{if($1 >= 32 && $1 <= 126) print $1}' windows.txt | \
  awk '{printf "%c", $1}' 
```

---

## DNS Tunneling Detection

### Concepts

DNS tunneling encodes data in DNS queries/responses. Typically involves:

- Long subdomain names with encoded data
- High volume of queries to single domain
- Unusual record types (TXT, NULL, CNAME chains)
- Large TXT record responses

### Detection Commands

**Query Analysis**

```bash
# Extract all DNS queries
tshark -r capture.pcap -Y "dns.flags.response == 0" \
  -T fields -e dns.qry.name

# Find suspiciously long queries
tshark -r capture.pcap -Y "dns.qry.name" -T fields -e dns.qry.name | \
  awk 'length($0) > 50'

# Query frequency analysis
tshark -r capture.pcap -Y "dns" -T fields -e dns.qry.name | \
  sort | uniq -c | sort -rn
```

**Subdomain Analysis**

```bash
# Count subdomain levels
tshark -r capture.pcap -Y "dns.qry.name" -T fields -e dns.qry.name | \
  awk -F'.' '{print NF-1}' | sort -n | uniq -c

# Extract only subdomain portions
tshark -r capture.pcap -Y "dns.qry.name" -T fields -e dns.qry.name | \
  sed 's/\.[^.]*\.[^.]*$//' 
```

**Record Type Analysis**

```bash
# Check for unusual record types
tshark -r capture.pcap -Y "dns" -T fields -e dns.qry.type | sort | uniq -c

# Extract TXT records
tshark -r capture.pcap -Y "dns.txt" -T fields -e dns.txt
```

### Decoding DNS Tunnels

**Hex-encoded subdomains**

```bash
# Extract and decode hex subdomains
tshark -r capture.pcap -Y "dns.qry.name" -T fields -e dns.qry.name | \
  cut -d'.' -f1 | xxd -r -p

# Base32 encoded (common in DNS exfiltration)
tshark -r capture.pcap -Y "dns.qry.name" -T fields -e dns.qry.name | \
  cut -d'.' -f1 | base32 -d
```

**Python decoder for DNS tunnels**

```python
from scapy.all import *
import base64

pcap = rdpcap("capture.pcap")

dns_queries = []
for pkt in pcap:
    if pkt.haslayer(DNS) and pkt[DNS].qr == 0:  # Query
        if pkt[DNS].qd:
            query = pkt[DNS].qd.qname.decode('utf-8').rstrip('.')
            dns_queries.append(query)

# Extract subdomain data
subdomains = [q.split('.')[0] for q in dns_queries]

# Try hex decoding
try:
    hex_data = ''.join(subdomains)
    decoded = bytes.fromhex(hex_data)
    print(f"Hex decoded: {decoded}")
except:
    pass

# Try base32
try:
    b32_data = ''.join(subdomains).upper()
    decoded = base64.b32decode(b32_data)
    print(f"Base32 decoded: {decoded}")
except:
    pass

# Try base64 (with URL-safe variant)
try:
    b64_data = ''.join(subdomains)
    decoded = base64.urlsafe_b64decode(b64_data + '==')
    print(f"Base64 decoded: {decoded}")
except:
    pass
```

### Known DNS Tunneling Tools

**dnscat2** - Creates encrypted command channel

```bash
# Server indicators
tshark -r capture.pcap -Y "dns.qry.name contains \"dnscat\""

# Characteristic patterns: multiple CNAME records
tshark -r capture.pcap -Y "dns.resp.type == 5" -T fields -e dns.cname
```

**iodine** - IP-over-DNS tunnel

```bash
# Look for NULL record queries (iodine default)
tshark -r capture.pcap -Y "dns.qry.type == 10"

# Base32-encoded subdomains with specific length patterns
tshark -r capture.pcap -Y "dns.qry.name" -T fields -e dns.qry.name | \
  grep -E '^[a-v0-9]{32,}\.'
```

**DNSExfiltrator**

```bash
# High entropy subdomain detection
tshark -r capture.pcap -Y "dns.qry.name" -T fields -e dns.qry.name | \
  awk -F'.' '{print $1}' | while read sub; do
    echo "$sub" | python3 -c "import sys, math; s=sys.stdin.read().strip(); print(s, -sum(s.count(c)/len(s)*math.log2(s.count(c)/len(s)) for c in set(s)))"
done | awk '$2 > 3.5'  # High entropy threshold
```

---

## HTTP Header Analysis

### Custom Header Fields

HTTP allows arbitrary headers which can hide data:

```bash
# Extract all unique headers
tshark -r capture.pcap -Y "http" -T fields -e http.request.line -e http.response.line

# List all header names
tshark -r capture.pcap -Y "http" -V | grep -E "^\s+[A-Z][a-zA-Z-]+:" | \
  cut -d':' -f1 | sort | uniq

# Extract specific suspicious headers
tshark -r capture.pcap -Y "http" -T fields \
  -e http.x_forwarded_for \
  -e http.referer \
  -e http.user_agent
```

**Common steganography headers:**

- X-Custom-*
- X-Data-*
- Cookie (encoded data)
- Referer (manipulated)
- User-Agent (non-standard)

```bash
# Extract custom X- headers
tshark -r capture.pcap -Y "http" -V | grep -i "^[ ]*X-" 

# Cookie analysis
tshark -r capture.pcap -Y "http.cookie" -T fields -e http.cookie | \
  sed 's/; /\n/g' | sort | uniq
```

### HTTP Method Tunneling

Unusual methods or method field manipulation:

```bash
# List all HTTP methods
tshark -r capture.pcap -Y "http.request.method" -T fields -e http.request.method | \
  sort | uniq -c

# Check for non-standard methods
tshark -r capture.pcap -Y "http.request.method" -T fields -e http.request.method | \
  grep -vE '^(GET|POST|PUT|DELETE|HEAD|OPTIONS|PATCH)$'
```

### Response Code Steganography

HTTP status codes could encode data (less common):

```bash
# Extract all response codes
tshark -r capture.pcap -Y "http.response.code" -T fields -e http.response.code

# Look for unusual patterns
tshark -r capture.pcap -Y "http.response.code" -T fields \
  -e frame.time_relative -e http.response.code | \
  awk '{print $2}' > codes.txt
  
# Convert codes to ASCII
awk '{printf "%c", $1}' codes.txt
```

### Content-Type Manipulation

```bash
# Extract Content-Type headers
tshark -r capture.pcap -Y "http.content_type" -T fields -e http.content_type

# Find mismatches between Content-Type and actual data
tshark -r capture.pcap -Y "http.content_type contains \"text\"" \
  --export-objects http,./exported/ 

# Check for uncommon MIME types
tshark -r capture.pcap -Y "http.content_type" -T fields -e http.content_type | \
  sort | uniq -c | sort -rn
```

### HTTP Timing Covert Channels

```bash
# Analyze request/response timing
tshark -r capture.pcap -Y "http" -T fields \
  -e frame.time_relative -e http.request.uri > timings.txt

# Calculate inter-request delays
awk 'NR>1 {print $1 - prev} {prev=$1}' timings.txt
```

---

## ICMP Covert Channels

### ICMP Data Field

ICMP Echo requests/replies contain arbitrary data payloads:

```bash
# Extract ICMP data
tshark -r capture.pcap -Y "icmp" -T fields -e data.data

# Raw data extraction
tshark -r capture.pcap -Y "icmp.type == 8 or icmp.type == 0" \
  -T fields -e data.data | xxd -r -p > icmp_data.bin

# Check for non-random patterns
tshark -r capture.pcap -Y "icmp" -T fields -e data.data | \
  xxd -r -p | strings
```

**Normal vs Covert ICMP:**

- Normal ping: 48-56 bytes, predictable pattern (abcd... or timestamps)
- Covert: Variable sizes, high entropy, or recognizable content

```bash
# Analyze ICMP payload sizes
tshark -r capture.pcap -Y "icmp" -T fields -e data.len | sort -n | uniq -c

# Extract unique payloads
tshark -r capture.pcap -Y "icmp" -T fields -e data.data | sort -u
```

### ICMP Type/Code Encoding

Less common but possible:

```bash
# Extract type/code pairs
tshark -r capture.pcap -Y "icmp" -T fields -e icmp.type -e icmp.code

# Convert to ASCII if patterned
tshark -r capture.pcap -Y "icmp" -T fields -e icmp.type | \
  awk '{printf "%c", $1}'
```

### ICMP Sequence Number Steganography

```bash
# Extract sequence numbers
tshark -r capture.pcap -Y "icmp.type == 8" -T fields -e icmp.seq

# Check for LSB encoding
tshark -r capture.pcap -Y "icmp" -T fields -e icmp.seq | \
  awk '{print $1 % 2}' | tr -d '\n'
```

### ICMP Identifier Field

```bash
# Extract ICMP identifiers
tshark -r capture.pcap -Y "icmp" -T fields -e icmp.ident

# Decode as ASCII
tshark -r capture.pcap -Y "icmp" -T fields -e icmp.ident | \
  awk '{printf "%c", $1}'
```

### Python ICMP Decoder

```python
from scapy.all import *

pcap = rdpcap("capture.pcap")

# Extract ICMP payloads
icmp_data = []
for pkt in pcap:
    if ICMP in pkt and Raw in pkt:
        icmp_data.append(pkt[Raw].load)

# Concatenate and analyze
full_data = b''.join(icmp_data)
print(full_data)

# Try file carving
with open('icmp_extracted.bin', 'wb') as f:
    f.write(full_data)

# Check file type
import subprocess
result = subprocess.run(['file', 'icmp_extracted.bin'], capture_output=True)
print(result.stdout.decode())

# Extract sequence numbers for LSB
seq_nums = [pkt[ICMP].seq for pkt in pcap if ICMP in pkt and pkt[ICMP].type == 8]
lsb_bits = ''.join([str(seq & 1) for seq in seq_nums])
lsb_bytes = bytes(int(lsb_bits[i:i+8], 2) for i in range(0, len(lsb_bits)-8, 8))
print(f"LSB decoded: {lsb_bytes}")
```

---

## Protocol Timing Analysis

### Inter-Packet Delay (IPD) Analysis

Data can be encoded in timing between packets:

```bash
# Extract packet timestamps
tshark -r capture.pcap -T fields -e frame.time_relative -e frame.len > timings.txt

# Calculate delays
awk 'NR>1 {print $1 - prev, $2} {prev=$1; len=$2}' timings.txt > delays.txt

# Statistical analysis
awk '{sum+=$1; sumsq+=$1*$1} END {print "Mean:", sum/NR, "StdDev:", sqrt(sumsq/NR - (sum/NR)^2)}' delays.txt
```

### Binary Encoding via Timing

Short delay = 0, Long delay = 1:

```bash
# Threshold-based binary extraction
awk '{if($1 < 0.1) print "0"; else print "1"}' delays.txt | tr -d '\n'

# Convert to ASCII
awk '{if($1 < 0.1) printf "0"; else printf "1"}' delays.txt | \
  fold -w 8 | while read byte; do
    echo $((2#$byte)) | awk '{printf "%c", $1}'
done
```

### Python Timing Analysis

```python
from scapy.all import *
import numpy as np

pcap = rdpcap("capture.pcap")

# Extract timestamps
timestamps = [float(pkt.time) for pkt in pcap]
delays = np.diff(timestamps)

# Statistics
print(f"Mean delay: {np.mean(delays)}")
print(f"Std deviation: {np.std(delays)}")
print(f"Min/Max: {np.min(delays)}/{np.max(delays)}")

# Binary threshold method
threshold = np.median(delays)
binary_data = ''.join(['0' if d < threshold else '1' for d in delays])

# Convert to bytes
byte_array = [int(binary_data[i:i+8], 2) for i in range(0, len(binary_data)-8, 8)]
decoded = bytes(byte_array)
print(decoded)

# Visualization (requires matplotlib)
import matplotlib.pyplot as plt
plt.plot(delays)
plt.axhline(y=threshold, color='r', linestyle='--')
plt.xlabel('Packet pair')
plt.ylabel('Delay (seconds)')
plt.title('Inter-Packet Delays')
plt.savefig('timing_analysis.png')
```

### Multi-level Timing Encoding

More sophisticated: multiple delay ranges encode different symbols:

```python
import numpy as np

# Define timing ranges
ranges = {
    '00': (0.00, 0.05),
    '01': (0.05, 0.10),
    '10': (0.10, 0.15),
    '11': (0.15, 0.20)
}

def classify_delay(delay, ranges):
    for symbol, (low, high) in ranges.items():
        if low <= delay < high:
            return symbol
    return None

# Decode
symbols = [classify_delay(d, ranges) for d in delays]
binary_string = ''.join([s for s in symbols if s])
decoded = bytes(int(binary_string[i:i+8], 2) for i in range(0, len(binary_string)-8, 8))
```

### Jitter Analysis

```bash
# Calculate jitter (variance in delays)
awk 'NR>1 {delta=$1-prev; if(NR>2) jitter+=(delta-prev_delta)^2} {prev=$1; prev_delta=delta} END {print sqrt(jitter/(NR-2))}' delays.txt
```

### Tools for Timing Analysis

**tshark with statistics**

```bash
# IO graph data export
tshark -r capture.pcap -q -z io,stat,0.001

# Conversation analysis with timing
tshark -r capture.pcap -q -z conv,ip
```

**scapy with visual analysis**

```python
from scapy.all import *
from matplotlib import pyplot as plt

pcap = rdpcap("capture.pcap")

# Packet rate over time
times = [pkt.time for pkt in pcap]
plt.hist(times, bins=100)
plt.xlabel('Time')
plt.ylabel('Packet count')
plt.title('Packet Rate Distribution')
plt.show()
```

---

## Important Related Topics for Network Steganography

**Network Flow Analysis** - Understanding NetFlow/IPFIX records for aggregate traffic pattern analysis

**Deep Packet Inspection (DPI) Evasion** - Techniques to bypass DPI systems that detect covert channels

**IPv6 Extension Headers** - Additional steganography vectors in IPv6 flow labels, routing headers, and extension chains

**Wireless Frame Analysis** - 802.11 frame manipulation (beacons, probe requests, management frames)

**VPN/Tunnel Traffic Analysis** - Identifying secondary covert channels within encrypted tunnels

**Application Layer Protocols** - FTP, SMTP, IRC, and other protocols for command-and-control steganography

---

# Text-Based Steganography

## Unicode Steganography

### Core Concepts

Unicode provides 143,859 characters (Unicode 15.0), creating massive opportunity for data hiding through:

- Character substitution with visually similar glyphs
- Invisible/zero-width characters
- Combining diacritical marks
- Direction override characters
- Private Use Area (PUA) characters

### Unicode Character Categories for Steganography

**Format Characters (Cf)**

```bash
# Common steganographic Unicode ranges
U+200B : Zero Width Space (ZWSP)
U+200C : Zero Width Non-Joiner (ZWNJ)
U+200D : Zero Width Joiner (ZWJ)
U+200E : Left-to-Right Mark (LRM)
U+200F : Right-to-Left Mark (RLM)
U+202A-U+202E : Directional formatting
U+FEFF : Zero Width No-Break Space (BOM)
```

**Detection with hexdump**

```bash
# Check for zero-width characters
hexdump -C suspicious.txt | grep -E "e2 80 (8b|8c|8d|8e|8f|aa|ab|ac|ad|ae)"

# Identify all non-ASCII
hexdump -C suspicious.txt | grep -v "^[0-9a-f]* [ ]*[2-7][0-9a-f] "
```

**Python Unicode analysis**

```python
import unicodedata

def analyze_unicode(text):
    results = []
    for i, char in enumerate(text):
        code = ord(char)
        name = unicodedata.name(char, "UNNAMED")
        category = unicodedata.category(char)
        
        results.append({
            'position': i,
            'char': char,
            'code_point': f"U+{code:04X}",
            'name': name,
            'category': category
        })
    
    return results

# Load text file
with open('suspicious.txt', 'r', encoding='utf-8') as f:
    text = f.read()

analysis = analyze_unicode(text)

# Filter suspicious categories
suspicious = [r for r in analysis if r['category'] in ['Cf', 'Mn', 'Me', 'Co']]
for item in suspicious:
    print(f"{item['position']}: {item['code_point']} - {item['name']} ({item['category']})")
```

**Category meanings:**

- Cf: Format (invisible control characters)
- Mn: Mark, nonspacing (combining characters)
- Me: Mark, enclosing
- Co: Other, private use

### Extracting Data from Unicode Steganography

**Binary encoding detection**

```python
# Common scheme: ZWSP=0, ZWNJ=1
def decode_zero_width(text):
    # Remove all visible characters
    invisible = ''.join([c for c in text if ord(c) in [0x200B, 0x200C]])
    
    # Map to binary
    binary = invisible.replace('\u200B', '0').replace('\u200C', '1')
    
    # Convert to bytes
    bytes_list = [int(binary[i:i+8], 2) for i in range(0, len(binary), 8)]
    try:
        decoded = bytes(bytes_list).decode('utf-8')
        return decoded
    except:
        return bytes(bytes_list)

with open('suspicious.txt', 'r', encoding='utf-8') as f:
    content = f.read()

hidden_message = decode_zero_width(content)
print(f"Decoded: {hidden_message}")
```

**Multi-character encoding schemes**

```python
# More complex: 8 zero-width characters = 8-bit encoding
ZERO_WIDTH_CHARS = [
    '\u200B', '\u200C', '\u200D', '\u200E',
    '\u200F', '\u202A', '\u202B', '\u202C'
]

def decode_multi_zw(text):
    invisible = ''.join([c for c in text if c in ZERO_WIDTH_CHARS])
    
    # Map each character to 3-bit value (0-7)
    bits = ''.join([format(ZERO_WIDTH_CHARS.index(c), '03b') for c in invisible])
    
    bytes_list = [int(bits[i:i+8], 2) for i in range(0, len(bits), 8)]
    return bytes(bytes_list)
```

### Combining Diacritical Marks

Characters U+0300 to U+036F can stack on base characters:

```python
def extract_diacritics(text):
    import unicodedata
    
    diacritics = []
    for char in text:
        if unicodedata.category(char) == 'Mn':  # Mark, nonspacing
            diacritics.append(ord(char) - 0x0300)  # Normalize to 0-base
    
    # Convert to binary (6 bits each, 64 possible marks)
    binary = ''.join([format(d, '06b') for d in diacritics])
    bytes_list = [int(binary[i:i+8], 2) for i in range(0, len(binary), 8)]
    
    return bytes(bytes_list)
```

### Private Use Area (PUA)

Ranges U+E000 to U+F8FF, U+F0000 to U+FFFFD, U+100000 to U+10FFFD:

```bash
# Detect PUA characters
grep -P '[\uE000-\uF8FF]' suspicious.txt

# Python detection
def find_pua(text):
    pua_chars = []
    for i, char in enumerate(text):
        code = ord(char)
        if (0xE000 <= code <= 0xF8FF or 
            0xF0000 <= code <= 0xFFFFD or 
            0x100000 <= code <= 0x10FFFD):
            pua_chars.append((i, char, code))
    return pua_chars
```

### Direction Override Steganography

```python
# Right-to-Left Override (RLO) and Left-to-Right Override (LRO)
def analyze_directional(text):
    directional_chars = {
        '\u202A': 'LRE (Left-to-Right Embedding)',
        '\u202B': 'RLE (Right-to-Left Embedding)',
        '\u202C': 'PDF (Pop Directional Formatting)',
        '\u202D': 'LRO (Left-to-Right Override)',
        '\u202E': 'RLO (Right-to-Left Override)',
        '\u200E': 'LRM (Left-to-Right Mark)',
        '\u200F': 'RLM (Right-to-Left Mark)'
    }
    
    for i, char in enumerate(text):
        if char in directional_chars:
            print(f"Position {i}: {directional_chars[char]} (U+{ord(char):04X})")
```

---

## Zero-Width Characters

### Detection and Extraction

**CLI detection**

```bash
# grep with Perl regex
grep -P '[\x{200B}-\x{200D}\x{FEFF}]' file.txt

# sed to highlight (show as visible markers)
sed 's/\xe2\x80\x8b/<ZWSP>/g; s/\xe2\x80\x8c/<ZWNJ>/g; s/\xe2\x80\x8d/<ZWJ>/g' file.txt

# Count zero-width characters
grep -oP '[\x{200B}-\x{200D}]' file.txt | wc -l
```

**Python comprehensive extractor**

```python
def extract_all_zero_width(filename):
    # Known zero-width and invisible characters
    zero_width = {
        '\u200B': 'ZWSP',
        '\u200C': 'ZWNJ', 
        '\u200D': 'ZWJ',
        '\u200E': 'LRM',
        '\u200F': 'RLM',
        '\u202A': 'LRE',
        '\u202B': 'RLE',
        '\u202C': 'PDF',
        '\u202D': 'LRO',
        '\u202E': 'RLO',
        '\uFEFF': 'ZWNBS',
        '\u2060': 'WJ',
        '\u2061': 'FUNCTION APPLICATION',
        '\u2062': 'INVISIBLE TIMES',
        '\u2063': 'INVISIBLE SEPARATOR',
        '\u2064': 'INVISIBLE PLUS'
    }
    
    with open(filename, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # Extract positions and types
    found = []
    for i, char in enumerate(content):
        if char in zero_width:
            found.append({
                'position': i,
                'type': zero_width[char],
                'char': char,
                'hex': f"{ord(char):04X}"
            })
    
    print(f"Found {len(found)} zero-width characters:")
    for item in found[:20]:  # Show first 20
        print(f"  Position {item['position']}: {item['type']} (U+{item['hex']})")
    
    # Extract sequence
    sequence = ''.join([item['char'] for item in found])
    
    return sequence, found

sequence, details = extract_all_zero_width('suspicious.txt')
```

### Common Encoding Schemes

**Binary (2-character alphabet)**

```python
def decode_binary_zw(text):
    # Extract ZWSP and ZWNJ only
    filtered = ''.join([c for c in text if c in ['\u200B', '\u200C']])
    
    # Convert to binary
    binary_str = filtered.replace('\u200B', '0').replace('\u200C', '1')
    
    # Decode
    result = []
    for i in range(0, len(binary_str), 8):
        byte = binary_str[i:i+8]
        if len(byte) == 8:
            result.append(chr(int(byte, 2)))
    
    return ''.join(result)
```

**Ternary (3-character)**

```python
def decode_ternary_zw(text):
    # ZWSP=0, ZWNJ=1, ZWJ=2
    mapping = {'\u200B': '0', '\u200C': '1', '\u200D': '2'}
    
    filtered = ''.join([c for c in text if c in mapping])
    ternary_str = ''.join([mapping[c] for c in filtered])
    
    # Convert ternary to decimal
    result = []
    for i in range(0, len(ternary_str), 6):  # ~6 ternary = 8 bits
        segment = ternary_str[i:i+6]
        if segment:
            decimal_value = int(segment, 3)
            if decimal_value < 256:
                result.append(chr(decimal_value))
    
    return ''.join(result)
```

**Base-n encoding**

```python
def decode_base_n_zw(text, chars_list):
    """
    Generic decoder for n-character alphabet
    chars_list: list of zero-width characters used
    """
    n = len(chars_list)
    filtered = ''.join([c for c in text if c in chars_list])
    
    # Map to indices
    indices = [chars_list.index(c) for c in filtered]
    
    # Convert from base-n to bytes
    bits_per_char = len(bin(n-1)) - 2  # bits needed for alphabet
    binary = ''.join([format(idx, f'0{bits_per_char}b') for idx in indices])
    
    result = []
    for i in range(0, len(binary), 8):
        byte = binary[i:i+8]
        if len(byte) == 8:
            result.append(chr(int(byte, 2)))
    
    return ''.join(result)

# Example: 4-character alphabet
chars = ['\u200B', '\u200C', '\u200D', '\u200E']
decoded = decode_base_n_zw(text, chars)
```

### Stegsnow-style Encoding

Stegsnow tool traditionally uses whitespace, but adapted for zero-width:

```python
def stegsnow_style_decode(text):
    """
    Decode stegsnow-style encoding where data is at line endings
    """
    lines = text.split('\n')
    extracted = []
    
    for line in lines:
        # Get trailing zero-width chars
        trailing = []
        for char in reversed(line):
            if char in ['\u200B', '\u200C', '\u200D']:
                trailing.insert(0, char)
            elif char.strip():  # Hit visible character
                break
        
        extracted.extend(trailing)
    
    # Decode binary
    binary = ''.join(extracted).replace('\u200B', '0').replace('\u200C', '1')
    
    result = []
    for i in range(0, len(binary), 8):
        byte = binary[i:i+8]
        if len(byte) == 8:
            result.append(chr(int(byte, 2)))
    
    return ''.join(result)
```

---

## Whitespace Encoding

### Traditional Whitespace Steganography

Uses spaces (0x20) and tabs (0x09):

```bash
# Visualize whitespace
cat -A file.txt  # Shows tabs as ^I

# Extract whitespace pattern
sed 's/[^ \t]//g' file.txt > whitespace_only.txt

# Show hex pattern
cat file.txt | xxd | grep -E "(20|09)"
```

### Decoding Space/Tab Binary

```python
def decode_whitespace_binary(filename):
    with open(filename, 'r') as f:
        content = f.read()
    
    # Extract only spaces and tabs
    whitespace = ''.join([c for c in content if c in [' ', '\t']])
    
    # Convert to binary (space=0, tab=1)
    binary = whitespace.replace(' ', '0').replace('\t', '1')
    
    # Decode
    result = []
    for i in range(0, len(binary), 8):
        byte = binary[i:i+8]
        if len(byte) == 8:
            result.append(chr(int(byte, 2)))
    
    return ''.join(result)

decoded = decode_whitespace_binary('secret.txt')
print(decoded)
```

### Line-Ending Whitespace

Data encoded in trailing spaces/tabs at line ends:

```python
def extract_trailing_whitespace(filename):
    with open(filename, 'r') as f:
        lines = f.readlines()
    
    whitespace_data = []
    for line in lines:
        # Get trailing whitespace
        trailing = line.rstrip('\n\r')
        if trailing.endswith((' ', '\t')):
            ws = trailing[len(trailing.rstrip(' \t')):]
            whitespace_data.append(ws)
    
    # Combine and decode
    combined = ''.join(whitespace_data)
    binary = combined.replace(' ', '0').replace('\t', '1')
    
    result = []
    for i in range(0, len(binary), 8):
        byte = binary[i:i+8]
        if len(byte) == 8:
            result.append(chr(int(byte, 2)))
    
    return ''.join(result)
```

### Stegsnow Tool

Original whitespace steganography tool:

```bash
# Install
apt-get install stegsnow

# Encode message
stegsnow -C -m "secret message" -p "password" cover.txt output.txt

# Decode
stegsnow -C -p "password" output.txt

# Without compression
stegsnow -m "secret" cover.txt output.txt

# Extract without password
stegsnow output.txt
```

**Python reimplementation for CTF**

```python
def stegsnow_decode(filename, compressed=False):
    """
    Basic stegsnow decoder without compression/encryption
    """
    with open(filename, 'r') as f:
        lines = f.readlines()
    
    bits = []
    for line in lines:
        # Count trailing spaces (up to 7)
        trailing_spaces = len(line) - len(line.rstrip(' '))
        if trailing_spaces > 0:
            # Each line encodes 3 bits in trailing space count (1-7 spaces)
            bits.append(format(trailing_spaces, '03b'))
    
    binary = ''.join(bits)
    
    result = []
    for i in range(0, len(binary), 8):
        byte = binary[i:i+8]
        if len(byte) == 8:
            value = int(byte, 2)
            if value == 0:  # Null terminator
                break
            result.append(chr(value))
    
    return ''.join(result)
```

### Multi-Space Encoding

Variable numbers of consecutive spaces encode values:

```python
def decode_multispace(text):
    """
    1 space = value 0, 2 spaces = value 1, etc.
    """
    import re
    
    # Find all space sequences between non-space characters
    space_sequences = re.findall(r'(?<=[^ ]) +(?=[^ ])', text)
    
    # Convert to values
    values = [len(seq) - 1 for seq in space_sequences]
    
    # Interpret as bytes (if values < 256)
    result = []
    for val in values:
        if 0 <= val < 256:
            result.append(chr(val))
    
    return ''.join(result)
```

---

## Case-Based Encoding

### Binary Encoding via Capitalization

Uppercase = 1, Lowercase = 0:

```python
def decode_case_binary(text):
    # Extract only letters
    letters = ''.join([c for c in text if c.isalpha()])
    
    # Map to binary
    binary = ''.join(['1' if c.isupper() else '0' for c in letters])
    
    # Decode
    result = []
    for i in range(0, len(binary), 8):
        byte = binary[i:i+8]
        if len(byte) == 8:
            result.append(chr(int(byte, 2)))
    
    return ''.join(result)

# Example
text = "ThIs IS a SeCReT MeSsAGe"
decoded = decode_case_binary(text)
print(decoded)
```

### Word-Based Case Encoding

First letter of each word encodes bit:

```python
def decode_word_case(text):
    words = text.split()
    
    binary = ''.join(['1' if word[0].isupper() else '0' for word in words if word])
    
    result = []
    for i in range(0, len(binary), 8):
        byte = binary[i:i+8]
        if len(byte) == 8:
            result.append(chr(int(byte, 2)))
    
    return ''.join(result)
```

### CamelCase Analysis

```python
def analyze_camelcase(text):
    """
    Extract data from unusual camelCase patterns
    """
    import re
    
    # Find words with internal capitals
    camel_words = re.findall(r'\b[a-z]+[A-Z][a-zA-Z]*\b', text)
    
    for word in camel_words:
        # Extract positions of uppercase letters
        positions = [i for i, c in enumerate(word) if c.isupper()]
        print(f"{word}: uppercase at positions {positions}")
    
    # Could encode data in position patterns
    return camel_words
```

### Case Preservation Encoding

More subtle - encodes in specific words while maintaining readability:

```python
def decode_selective_case(text, keyword_list):
    """
    Only specific words encode data based on case
    """
    words = text.split()
    
    bits = []
    for word in words:
        # Remove punctuation
        clean_word = word.strip('.,!?;:').lower()
        
        if clean_word in keyword_list:
            # This word encodes a bit
            bits.append('1' if word[0].isupper() else '0')
    
    binary = ''.join(bits)
    
    result = []
    for i in range(0, len(binary), 8):
        byte = binary[i:i+8]
        if len(byte) == 8:
            result.append(chr(int(byte, 2)))
    
    return ''.join(result)

# Example keywords that carry data
keywords = ['the', 'and', 'is', 'at', 'to']
```

---

## Homoglyph Detection

### Core Concept

Homoglyphs are characters that appear identical or nearly identical but have different Unicode code points:

Common examples:

- Latin 'a' (U+0061) vs Cyrillic 'а' (U+0430)
- Latin 'o' (U+006F) vs Greek omicron 'ο' (U+03BF)
- Latin 'e' (U+0065) vs Cyrillic 'е' (U+0435)

### Detection Script

```python
def detect_homoglyphs(text):
    """
    Identify characters that look alike but have different code points
    """
    # Common homoglyph mappings (Latin -> look-alikes)
    homoglyph_sets = {
        'a': ['\u0430', '\u00E0', '\u00E1', '\u00E2', '\u1D00'],  # Cyrillic, accented, etc.
        'e': ['\u0435', '\u00E8', '\u00E9', '\u00EA', '\u1D07'],
        'o': ['\u043E', '\u00F6', '\u00F2', '\u00F3', '\u03BF'],  # Cyrillic, umlauts, Greek
        'p': ['\u0440', '\u03C1'],  # Cyrillic, Greek rho
        'c': ['\u0441', '\u03C2'],  # Cyrillic, Greek
        'x': ['\u0445', '\u00D7'],  # Cyrillic, multiplication
        'y': ['\u0443', '\u00FF'],  # Cyrillic
        'i': ['\u0456', '\u00EC', '\u00ED', '\u0131'],  # Cyrillic, accented, dotless
        'j': ['\u0458'],
        'n': ['\u00F1'],
        's': ['\u0455'],
        'A': ['\u0410', '\u0391'],  # Cyrillic, Greek Alpha
        'B': ['\u0412', '\u0392'],  # Cyrillic, Greek Beta
        'C': ['\u0421'],  # Cyrillic
        'E': ['\u0415'],  # Cyrillic
        'H': ['\u041D', '\u0397'],  # Cyrillic, Greek Eta
        'I': ['\u0406', '\u0399'],  # Cyrillic, Greek Iota
        'J': ['\u0408'],
        'K': ['\u041A', '\u039A'],  # Cyrillic, Greek Kappa
        'M': ['\u041C', '\u039C'],  # Cyrillic, Greek Mu
        'N': ['\u039D'],  # Greek Nu
        'O': ['\u041E', '\u039F'],  # Cyrillic, Greek Omicron
        'P': ['\u0420', '\u03A1'],  # Cyrillic, Greek Rho
        'T': ['\u0422', '\u03A4'],  # Cyrillic, Greek Tau
        'X': ['\u0425', '\u03A7'],  # Cyrillic, Greek Chi
        'Y': ['\u03A5'],  # Greek Upsilon
        'Z': ['\u0396'],  # Greek Zeta
    }
    
    found = []
    for i, char in enumerate(text):
        for latin_char, alternatives in homoglyph_sets.items():
            if char in alternatives:
                found.append({
                    'position': i,
                    'char': char,
                    'code_point': f"U+{ord(char):04X}",
                    'looks_like': latin_char,
                    'latin_code': f"U+{ord(latin_char):04X}"
                })
    
    return found

# Usage
with open('suspicious.txt', 'r', encoding='utf-8') as f:
    content = f.read()

homoglyphs = detect_homoglyphs(content)
for item in homoglyphs:
    print(f"Position {item['position']}: '{item['char']}' ({item['code_point']}) looks like '{item['looks_like']}' ({item['latin_code']})")
```

### Extracting Data from Homoglyphs

**Binary encoding:**

```python
def decode_homoglyph_binary(text):
    """
    Latin character = 0, homoglyph = 1
    """
    homoglyph_chars = [
        '\u0430', '\u0435', '\u043E', '\u0440', '\u0441',  # Cyrillic a,e,o,p,c
        '\u03BF', '\u03C1', '\u03C2'  # Greek o, rho, final sigma
    ]
    
    binary = []
    for char in text:
        if char.isalpha():
            if char in homoglyph_chars:
                binary.append('1')
            else:
                binary.append('0')
    
    binary_str = ''.join(binary)
    
    result = []
    for i in range(0, len(binary_str), 8):
        byte = binary_str[i:i+8]
        if len(byte) == 8:
            result.append(chr(int(byte, 2)))
    
    return ''.join(result)
```

**Positional encoding:**

```python
def decode_homoglyph_positional(text):
    """
    Positions of homoglyphs encode data
    """
    homoglyph_chars = ['\u0430', '\u0435', '\u043E', '\u0440', '\u0441']
    
    positions = []
    for i, char in enumerate(text):
        if char in homoglyph_chars:
            positions.append(i)
    
    # Interpret positions as ASCII values
    result = ''.join([chr(pos % 256) for pos in positions if pos < 256])
    
    return result
```

### Confusables Detection

Using Unicode confusables data:

```python
def find_confusables(text):
    """
    Comprehensive confusable detection
    """
    import unicodedata
    
    confusables = []
    
    for i, char in enumerate(text):
        # Normalize and compare
        nfd = unicodedata.normalize('NFD', char)
        nfc = unicodedata.normalize('NFC', char)
        
        if nfd != char or nfc != char:
            confusables.append({
                'position': i,
                'char': char,
                'code': f"U+{ord(char):04X}",
                'name': unicodedata.name(char, 'UNNAMED'),
                'nfd': nfd,
                'nfc': nfc
            })
    
    return confusables
```

### Script Mixing Detection

```python
def detect_script_mixing(text):
    """
    Find mixed scripts (Latin + Cyrillic + Greek, etc.)
    """
    import unicodedata
    
    scripts = {}
    
    for i, char in enumerate(text):
        if char.isalpha():
            code = ord(char)
            
            # Determine script
            if 0x0041 <= code <= 0x007A or 0x0100 <= code <= 0x017F:
                script = 'Latin'
            elif 0x0400 <= code <= 0x04FF:
                script = 'Cyrillic'
            elif 0x0370 <= code <= 0x03FF:
                script = 'Greek'
            elif 0x0600 <= code <= 0x06FF:
                script = 'Arabic'
            else:
                script = 'Other'
            
            if script not in scripts:
                scripts[script] = []
            scripts[script].append((i, char))
    
    if len(scripts) > 1:
        print(f"Mixed scripts detected: {list(scripts.keys())}")
        for script, chars in scripts.items():
            print(f"{script}: {len(chars)} characters")
            print(f"  First 10: {[c[1] for c in chars[:10]]}")
    
    return scripts
```

---

## Markdown/HTML Hidden Content

### HTML Comment Extraction

```bash
# Extract HTML comments
grep -oP '<!--.*?-->' file.html

# Multi-line comments
sed -n '/<!--/,/-->/p' file.html

# Python extraction
```

```python
import re

def extract_html_comments(html):
    comments = re.findall(r'<!--(.*?)-->', html, re.DOTALL)
    return comments

with open('page.html', 'r') as f:
    html = f.read()

comments = extract_html_comments(html)
for i, comment in enumerate(comments):
    print(f"Comment {i}: {comment.strip()}")
```

### Hidden Form Fields

```python
def extract_hidden_inputs(html):
    import re
    
    pattern = r'<input[^>]*type=["\']hidden["\'][^>]*>'
    hidden_fields = re.findall(pattern, html, re.IGNORECASE)
    
    for field in hidden_fields:
        # Extract name and value
        name = re.search(r'name=["\']([^"\']*)["\']', field)
        value = re.search(r'value=["\']([^"\']*)["\']', field)
        
        if name and value:
            print(f"{name.group(1)}: {value.group(1)}")
    
    return hidden_fields
```

### CSS Hidden Content

```python
def extract_css_hidden(html):
    """
    Find elements with display:none or visibility:hidden
    """
    import re
    from html.parser import HTMLParser
    
    class HiddenParser(HTMLParser):
        def __init__(self):
            super().__init__()
            self.hidden_content = []
            self.current_hidden = False
            
        def handle_starttag(self, tag, attrs):
            style = dict(attrs).get('style', '')
            css_class = dict(attrs).get('class', '')
            
            if 'display:none' in style or 'visibility:hidden' in style:
                self.current_hidden = True
                
        def handle_data(self, data):
            if self.current_hidden and data.strip():
                self.hidden_content.append(data.strip())
                
        def handle_endtag(self, tag):
            self.current_hidden = False
    
    parser = HiddenParser()
    parser.feed(html)
    
    return parser.hidden_content

hidden_text = extract_css_hidden(html)
for text in hidden_text:
    print(f"Hidden: {text}")
```

### Markdown Hidden Content

**HTML in Markdown:**

```python
def extract_markdown_html(markdown):
    import re
    
    # HTML comments in markdown
    comments = re.findall(r'<!--(.*?)-->', markdown, re.DOTALL)
    
    # Raw HTML blocks
    html_blocks = re.findall(r'<[^>]+>.*?</[^>]+>', markdown, re.DOTALL)
    
    # Hidden spans/divs
    hidden = re.findall(r'<(?:span|div)[^>]*style=["\'][^"\']*(?:display:\s*none|visibility:\s*hidden)[^"\']*["\'][^>]*>(.*?)</(?:span|div)>', markdown, re.DOTALL | re.IGNORECASE)
    
    return {
        'comments': comments,
        'html_blocks': html_blocks,
        'hidden_elements': hidden
    }

with open('document.md', 'r') as f:
    md_content = f.read()

hidden_data = extract_markdown_html(md_content)
for key, items in hidden_data.items():
    print(f"\n{key}:")
    for item in items:
        print(f"  {item.strip()}")
```

**Link Title/Alt Text:**

```python
def extract_markdown_metadata(markdown):
    import re
    
    # Link titles: [text](url "title")
    link_titles = re.findall(r'\[([^\]]+)\]\([^\)]+\s+"([^"]+)"\)', markdown)
    
    # Image alt text and titles
    images = re.findall(r'!\[([^\]]*)\]\(([^\)]+)\)', markdown)
    
    # Reference-style links
    references = re.findall(r'^\[([^\]]+)\]:\s*(.+)$', markdown, re.MULTILINE)
    
    return {
        'link_titles': link_titles,
        'images': images,
        'references': references
    }

metadata = extract_markdown_metadata(md_content)
for link_text, title in metadata['link_titles']:
    print(f"Link '{link_text}' has title: {title}")
```

**Zero-Width in Markdown:**

```python
def extract_markdown_zerowidth(markdown):
    """
    Extract zero-width characters from markdown content
    """
    zero_width_chars = ['\u200B', '\u200C', '\u200D', '\u200E', '\u200F', '\uFEFF']
    
    extracted = ''.join([c for c in markdown if c in zero_width_chars])
    
    # Try binary decode
    if extracted:
        binary = extracted.replace('\u200B', '0').replace('\u200C', '1')
        
        result = []
        for i in range(0, len(binary), 8):
            byte = binary[i:i+8]
            if len(byte) == 8:
                result.append(chr(int(byte, 2)))
        
        return ''.join(result)
    
    return None
```

### HTML Attribute Steganography

**Data attributes:**

```python
def extract_data_attributes(html):
    import re
    from html.parser import HTMLParser
    
    class DataAttrParser(HTMLParser):
        def __init__(self):
            super().__init__()
            self.data_attrs = []
            
        def handle_starttag(self, tag, attrs):
            for attr, value in attrs:
                if attr.startswith('data-'):
                    self.data_attrs.append({
                        'tag': tag,
                        'attribute': attr,
                        'value': value
                    })
    
    parser = DataAttrParser()
    parser.feed(html)
    
    return parser.data_attrs

data_attrs = extract_data_attributes(html)
for attr in data_attrs:
    print(f"{attr['tag']}.{attr['attribute']}: {attr['value']}")
```

**ID and class name encoding:**

```python
def analyze_id_class_names(html):
    """
    Extract and analyze suspicious ID/class patterns
    """
    import re
    
    # Extract IDs
    ids = re.findall(r'id=["\']([^"\']+)["\']', html)
    
    # Extract classes
    classes = re.findall(r'class=["\']([^"\']+)["\']', html)
    
    # Look for base64-like patterns
    suspicious_ids = [id_val for id_val in ids if re.match(r'^[A-Za-z0-9+/=]{20,}$', id_val)]
    
    # Look for hex patterns
    hex_ids = [id_val for id_val in ids if re.match(r'^[0-9a-fA-F]{16,}$', id_val)]
    
    print("Suspicious IDs (possible base64):")
    for sid in suspicious_ids:
        try:
            import base64
            decoded = base64.b64decode(sid)
            print(f"  {sid} -> {decoded}")
        except:
            pass
    
    print("\nHex-pattern IDs:")
    for hid in hex_ids:
        try:
            decoded = bytes.fromhex(hid)
            print(f"  {hid} -> {decoded}")
        except:
            pass
    
    return {'ids': ids, 'classes': classes, 'suspicious': suspicious_ids}
```

### SVG Hidden Content

```python
def extract_svg_hidden(svg_content):
    """
    Extract hidden data from SVG files
    """
    import re
    import xml.etree.ElementTree as ET
    
    # Parse SVG
    root = ET.fromstring(svg_content)
    
    hidden_data = []
    
    # Check for hidden elements (display:none, opacity:0)
    for elem in root.iter():
        style = elem.get('style', '')
        opacity = elem.get('opacity', '1')
        display = elem.get('display', '')
        
        if 'display:none' in style or display == 'none' or opacity == '0':
            # Extract text content
            if elem.text:
                hidden_data.append({
                    'tag': elem.tag,
                    'text': elem.text,
                    'attributes': elem.attrib
                })
    
    # Check for metadata
    for metadata in root.findall('.//{http://www.w3.org/2000/svg}metadata'):
        if metadata.text:
            hidden_data.append({
                'tag': 'metadata',
                'text': metadata.text
            })
    
    # Check for desc elements
    for desc in root.findall('.//{http://www.w3.org/2000/svg}desc'):
        if desc.text:
            hidden_data.append({
                'tag': 'desc',
                'text': desc.text
            })
    
    # Check for custom data in path definitions
    for path in root.findall('.//{http://www.w3.org/2000/svg}path'):
        d = path.get('d', '')
        # Check if path data contains unusual patterns
        if len(d) > 1000:  # Suspiciously long path
            hidden_data.append({
                'tag': 'path',
                'note': 'Unusually long path data',
                'length': len(d),
                'preview': d[:100]
            })
    
    return hidden_data

with open('image.svg', 'r') as f:
    svg = f.read()

hidden = extract_svg_hidden(svg)
for item in hidden:
    print(f"{item['tag']}: {item.get('text', item.get('note', ''))}")
```

### XML/HTML Entity Encoding

```python
def decode_html_entities(text):
    """
    Decode HTML entities that might hide data
    """
    import html
    import re
    
    # Standard HTML entity decoding
    decoded = html.unescape(text)
    
    # Extract numeric entities
    numeric_entities = re.findall(r'&#(\d+);', text)
    hex_entities = re.findall(r'&#x([0-9a-fA-F]+);', text)
    
    # Decode numeric
    numeric_chars = ''.join([chr(int(num)) for num in numeric_entities])
    
    # Decode hex
    hex_chars = ''.join([chr(int(num, 16)) for num in hex_entities])
    
    return {
        'decoded': decoded,
        'numeric_sequence': numeric_chars,
        'hex_sequence': hex_chars,
        'numeric_values': numeric_entities,
        'hex_values': hex_entities
    }

# Example
html_text = "&#72;&#101;&#108;&#108;&#111; &#x57;&#x6f;&#x72;&#x6c;&#x64;"
result = decode_html_entities(html_text)
print(f"Decoded: {result['decoded']}")
print(f"Numeric: {result['numeric_sequence']}")
print(f"Hex: {result['hex_sequence']}")
```

### JavaScript Hidden in HTML

```python
def extract_javascript_data(html):
    """
    Extract potentially hidden data from JavaScript in HTML
    """
    import re
    
    # Extract script contents
    scripts = re.findall(r'<script[^>]*>(.*?)</script>', html, re.DOTALL | re.IGNORECASE)
    
    findings = []
    
    for script in scripts:
        # Look for base64 strings
        b64_patterns = re.findall(r'["\']([A-Za-z0-9+/]{20,}={0,2})["\']', script)
        
        for b64_str in b64_patterns:
            try:
                import base64
                decoded = base64.b64decode(b64_str)
                findings.append({
                    'type': 'base64',
                    'original': b64_str[:50] + '...' if len(b64_str) > 50 else b64_str,
                    'decoded': decoded
                })
            except:
                pass
        
        # Look for hex strings
        hex_patterns = re.findall(r'["\']([0-9a-fA-F]{32,})["\']', script)
        
        for hex_str in hex_patterns:
            try:
                decoded = bytes.fromhex(hex_str)
                findings.append({
                    'type': 'hex',
                    'original': hex_str[:50] + '...' if len(hex_str) > 50 else hex_str,
                    'decoded': decoded
                })
            except:
                pass
        
        # Look for eval/unescape patterns
        if 'eval(' in script or 'unescape(' in script:
            findings.append({
                'type': 'suspicious_function',
                'note': 'Contains eval() or unescape()',
                'preview': script[:200]
            })
    
    return findings

js_findings = extract_javascript_data(html)
for finding in js_findings:
    print(f"{finding['type']}: {finding.get('decoded', finding.get('note', ''))}")
```

### CSS Content Property

```python
def extract_css_content(html):
    """
    Extract data from CSS content properties
    """
    import re
    
    # Find style tags and inline styles
    styles = re.findall(r'<style[^>]*>(.*?)</style>', html, re.DOTALL | re.IGNORECASE)
    inline_styles = re.findall(r'style=["\']([^"\']+)["\']', html)
    
    all_styles = ' '.join(styles + inline_styles)
    
    # Extract content properties
    content_properties = re.findall(r'content:\s*["\']([^"\']+)["\']', all_styles)
    
    # Also check for ::before and ::after
    pseudo_elements = re.findall(r'::(?:before|after)\s*\{[^}]*content:\s*["\']([^"\']+)["\'][^}]*\}', all_styles)
    
    return {
        'content_values': content_properties,
        'pseudo_elements': pseudo_elements
    }

css_data = extract_css_content(html)
print("CSS content properties:")
for content in css_data['content_values']:
    print(f"  {content}")
```

### Comprehensive HTML/Markdown Extractor

```python
def comprehensive_html_extract(filename):
    """
    Combined extraction of all hidden content types
    """
    with open(filename, 'r', encoding='utf-8') as f:
        content = f.read()
    
    results = {
        'html_comments': extract_html_comments(content),
        'hidden_inputs': extract_hidden_inputs(content),
        'css_hidden': extract_css_hidden(content),
        'data_attributes': extract_data_attributes(content),
        'javascript': extract_javascript_data(content),
        'css_content': extract_css_content(content),
        'html_entities': decode_html_entities(content),
        'zero_width': ''.join([c for c in content if ord(c) in [0x200B, 0x200C, 0x200D, 0x200E, 0x200F, 0xFEFF]])
    }
    
    # Print summary
    print("=== HTML/Markdown Hidden Content Analysis ===\n")
    
    if results['html_comments']:
        print(f"HTML Comments: {len(results['html_comments'])} found")
        for i, comment in enumerate(results['html_comments'][:5]):
            print(f"  [{i}] {comment.strip()[:100]}")
    
    if results['hidden_inputs']:
        print(f"\nHidden Inputs: {len(results['hidden_inputs'])} found")
    
    if results['css_hidden']:
        print(f"\nCSS Hidden Content: {len(results['css_hidden'])} items")
        for item in results['css_hidden'][:5]:
            print(f"  {item[:100]}")
    
    if results['data_attributes']:
        print(f"\nData Attributes: {len(results['data_attributes'])} found")
    
    if results['javascript']:
        print(f"\nJavaScript Findings: {len(results['javascript'])} items")
    
    if results['zero_width']:
        print(f"\nZero-Width Characters: {len(results['zero_width'])} found")
        # Try to decode
        binary = results['zero_width'].replace('\u200B', '0').replace('\u200C', '1')
        if binary:
            try:
                decoded = ''.join([chr(int(binary[i:i+8], 2)) for i in range(0, len(binary), 8)])
                print(f"  Decoded: {decoded}")
            except:
                print("  Could not decode")
    
    return results

# Usage
results = comprehensive_html_extract('suspicious.html')
```

---

## Advanced Text Steganography Techniques

### Synonym Substitution

Encoding data by choosing specific synonyms:

```python
def detect_synonym_encoding(text, word_groups):
    """
    word_groups: dict mapping meaning to list of synonyms
    Example: {'good': ['good', 'great', 'excellent'], 'bad': ['bad', 'poor', 'terrible']}
    Each synonym in list represents a value (index = value)
    """
    words = text.lower().split()
    
    encoded_values = []
    
    for word in words:
        for meaning, synonyms in word_groups.items():
            if word in synonyms:
                value = synonyms.index(word)
                encoded_values.append(value)
    
    # Convert values to bits (if values are 0-1 or 0-3, etc.)
    if all(v in [0, 1] for v in encoded_values):
        # Binary
        binary = ''.join(map(str, encoded_values))
        result = ''.join([chr(int(binary[i:i+8], 2)) for i in range(0, len(binary), 8)])
        return result
    
    return encoded_values
```

### Sentence Structure Encoding

```python
def analyze_sentence_structure(text):
    """
    Analyze sentence patterns that might encode data
    """
    import re
    
    sentences = re.split(r'[.!?]+', text)
    
    patterns = []
    for sent in sentences:
        sent = sent.strip()
        if sent:
            patterns.append({
                'length': len(sent),
                'word_count': len(sent.split()),
                'starts_with_capital': sent[0].isupper(),
                'ends_with_punctuation': sent[-1] in '.!?'
            })
    
    # Check for patterns in sentence lengths
    lengths = [p['word_count'] for p in patterns]
    
    # Try ASCII interpretation
    ascii_attempt = ''.join([chr(l) if l < 128 else '?' for l in lengths])
    
    return {
        'patterns': patterns,
        'lengths': lengths,
        'ascii_attempt': ascii_attempt
    }
```

### Punctuation-Based Encoding

```python
def extract_punctuation_data(text):
    """
    Extract data encoded in punctuation patterns
    """
    import re
    
    # Extract all punctuation
    punctuation = re.findall(r'[^\w\s]', text)
    
    # Map to values
    punct_map = {'.': '0', ',': '1', '!': '2', '?': '3', ';': '4', ':': '5'}
    
    values = [punct_map.get(p, '0') for p in punctuation]
    
    # Try as ternary/quaternary encoding
    if all(v in ['0', '1'] for v in values):
        binary = ''.join(values)
        result = ''.join([chr(int(binary[i:i+8], 2)) for i in range(0, len(binary), 8) if i+8 <= len(binary)])
        return result
    
    return punctuation
```

### Line Length Encoding

```python
def decode_line_lengths(filename):
    """
    Extract data encoded in line lengths
    """
    with open(filename, 'r') as f:
        lines = f.readlines()
    
    lengths = [len(line.rstrip('\n\r')) for line in lines]
    
    # Try direct ASCII
    ascii_result = ''.join([chr(l) if 32 <= l < 127 else '?' for l in lengths])
    
    # Try modulo operations
    mod_256 = ''.join([chr(l % 256) if l % 256 >= 32 else '?' for l in lengths])
    
    # Try as binary (odd=1, even=0)
    binary = ''.join(['1' if l % 2 else '0' for l in lengths])
    binary_result = ''.join([chr(int(binary[i:i+8], 2)) for i in range(0, len(binary), 8) if i+8 <= len(binary)])
    
    return {
        'lengths': lengths,
        'ascii': ascii_result,
        'mod_256': mod_256,
        'binary': binary_result
    }
```

### Automated Multi-Method Decoder

```python
def auto_decode_text(filename):
    """
    Try multiple text steganography techniques automatically
    """
    with open(filename, 'r', encoding='utf-8') as f:
        content = f.read()
    
    print("=== Automated Text Steganography Analysis ===\n")
    
    # 1. Zero-width characters
    print("[1] Zero-Width Characters:")
    zw_chars = [c for c in content if ord(c) in [0x200B, 0x200C, 0x200D, 0x200E, 0x200F, 0xFEFF]]
    if zw_chars:
        binary = ''.join(zw_chars).replace('\u200B', '0').replace('\u200C', '1')
        try:
            decoded = ''.join([chr(int(binary[i:i+8], 2)) for i in range(0, len(binary), 8)])
            print(f"  Found {len(zw_chars)} characters")
            print(f"  Decoded: {decoded}")
        except:
            print(f"  Found {len(zw_chars)} but couldn't decode")
    else:
        print("  None found")
    
    # 2. Unicode homoglyphs
    print("\n[2] Homoglyphs:")
    homoglyphs = detect_homoglyphs(content)
    if homoglyphs:
        print(f"  Found {len(homoglyphs)} homoglyphs")
        for h in homoglyphs[:5]:
            print(f"    Position {h['position']}: {h['char']} ({h['code_point']}) looks like {h['looks_like']}")
    else:
        print("  None found")
    
    # 3. Whitespace encoding
    print("\n[3] Whitespace Encoding:")
    ws_only = ''.join([c for c in content if c in [' ', '\t']])
    if len(ws_only) > 20:
        binary = ws_only.replace(' ', '0').replace('\t', '1')
        try:
            decoded = ''.join([chr(int(binary[i:i+8], 2)) for i in range(0, len(binary), 8)])
            print(f"  Found {len(ws_only)} whitespace chars")
            print(f"  Decoded: {decoded[:100]}")
        except:
            print(f"  Found {len(ws_only)} but couldn't decode")
    else:
        print("  Insufficient whitespace")
    
    # 4. Case-based encoding
    print("\n[4] Case-Based Encoding:")
    letters = [c for c in content if c.isalpha()]
    if letters:
        binary = ''.join(['1' if c.isupper() else '0' for c in letters])
        try:
            decoded = ''.join([chr(int(binary[i:i+8], 2)) for i in range(0, len(binary)-7, 8)])
            if decoded.isprintable():
                print(f"  Decoded: {decoded[:100]}")
        except:
            print("  Could not decode")
    
    # 5. Line lengths
    print("\n[5] Line Length Encoding:")
    lines = content.split('\n')
    lengths = [len(line) for line in lines]
    if lengths:
        # Try ASCII
        ascii_attempt = ''.join([chr(l) if 32 <= l < 127 else '' for l in lengths])
        if len(ascii_attempt) > 5 and ascii_attempt.isprintable():
            print(f"  Possible: {ascii_attempt}")
        else:
            print("  No obvious pattern")
    
    # 6. HTML/Markdown hidden content
    print("\n[6] HTML/Markdown Content:")
    if '<' in content or '<!--' in content:
        comments = extract_html_comments(content)
        if comments:
            print(f"  Found {len(comments)} HTML comments")
            for comment in comments[:3]:
                print(f"    {comment.strip()[:100]}")

# Usage
auto_decode_text('suspicious.txt')
```

---

## Important Related Topics for Text-Based Steganography

**Natural Language Processing (NLP) Steganography** - Using linguistic properties (grammar patterns, POS tagging, semantic selection) for encoding

**Font-Based Steganography** - Microscopic font variations, glyph width modulation, kerning manipulation

**PDF Text Layer Analysis** - Hidden text layers, overlapping transparent text, unusual character spacing in PDFs

**Document Metadata** - EXIF-like metadata in Word/PDF documents, revision history, tracked changes

**Linguistic Steganography** - Acrostics, word position encoding, semantic encoding through word choice

**Typography Steganography** - Letter spacing (tracking), word spacing, line height variations

---

# Video Steganography

## Video Frame Extraction

### Core Concepts

Video files are sequences of frames (images) that can hide data through:

- Individual frame manipulation (LSB, DCT coefficients)
- Inter-frame patterns (frame selection encoding)
- Motion vector manipulation
- Temporal domain encoding

### FFmpeg Frame Extraction

**Basic extraction:**

```bash
# Extract all frames as PNG
ffmpeg -i video.mp4 frames/frame_%04d.png

# Extract as JPEG (faster, smaller)
ffmpeg -i video.mp4 frames/frame_%04d.jpg

# Extract specific frame range
ffmpeg -i video.mp4 -vf "select='between(n\,100\,200)'" -vsync 0 frames/frame_%04d.png

# Extract one frame per second
ffmpeg -i video.mp4 -vf fps=1 frames/frame_%04d.png

# Extract every Nth frame
ffmpeg -i video.mp4 -vf "select='not(mod(n\,10))'" -vsync 0 frames/frame_%04d.png

# Extract keyframes only (I-frames)
ffmpeg -i video.mp4 -vf "select='eq(pict_type\,I)'" -vsync 0 keyframes/frame_%04d.png

# Extract at specific timestamp
ffmpeg -ss 00:01:30 -i video.mp4 -frames:v 1 single_frame.png

# High quality extraction (lossless)
ffmpeg -i video.mp4 -qscale:v 1 frames/frame_%04d.jpg
```

**Python frame extraction with OpenCV:**

```python
import cv2
import os

def extract_frames(video_path, output_dir):
    """
    Extract all frames from video
    """
    os.makedirs(output_dir, exist_ok=True)
    
    cap = cv2.VideoCapture(video_path)
    
    if not cap.isOpened():
        print(f"Error opening video: {video_path}")
        return
    
    fps = cap.get(cv2.CAP_PROP_FPS)
    total_frames = int(cap.get(cv2.CAP_PROP_FRAME_COUNT))
    
    print(f"FPS: {fps}")
    print(f"Total frames: {total_frames}")
    
    frame_count = 0
    
    while True:
        ret, frame = cap.read()
        
        if not ret:
            break
        
        frame_path = os.path.join(output_dir, f"frame_{frame_count:05d}.png")
        cv2.imwrite(frame_path, frame)
        
        frame_count += 1
        
        if frame_count % 100 == 0:
            print(f"Extracted {frame_count}/{total_frames} frames")
    
    cap.release()
    print(f"Extraction complete: {frame_count} frames")
    
    return frame_count

# Usage
extract_frames('video.mp4', 'extracted_frames/')
```

**Selective frame extraction:**

```python
def extract_specific_frames(video_path, frame_numbers, output_dir):
    """
    Extract only specific frame numbers
    """
    os.makedirs(output_dir, exist_ok=True)
    
    cap = cv2.VideoCapture(video_path)
    
    for frame_num in sorted(frame_numbers):
        cap.set(cv2.CAP_PROP_POS_FRAMES, frame_num)
        ret, frame = cap.read()
        
        if ret:
            output_path = os.path.join(output_dir, f"frame_{frame_num:05d}.png")
            cv2.imwrite(output_path, frame)
            print(f"Extracted frame {frame_num}")
    
    cap.release()

# Example: extract every 10th frame
frame_nums = list(range(0, 1000, 10))
extract_specific_frames('video.mp4', frame_nums, 'selected_frames/')
```

### Frame Analysis for Hidden Data

**Compare consecutive frames:**

```python
import cv2
import numpy as np

def compare_consecutive_frames(video_path):
    """
    Analyze differences between consecutive frames
    """
    cap = cv2.VideoCapture(video_path)
    
    ret, prev_frame = cap.read()
    frame_count = 1
    
    differences = []
    
    while True:
        ret, curr_frame = cap.read()
        
        if not ret:
            break
        
        # Calculate absolute difference
        diff = cv2.absdiff(prev_frame, curr_frame)
        diff_sum = np.sum(diff)
        diff_mean = np.mean(diff)
        
        differences.append({
            'frame': frame_count,
            'total_diff': diff_sum,
            'mean_diff': diff_mean
        })
        
        prev_frame = curr_frame
        frame_count += 1
    
    cap.release()
    
    # Identify anomalies
    diffs = [d['mean_diff'] for d in differences]
    mean = np.mean(diffs)
    std = np.std(diffs)
    
    anomalies = [d for d in differences if d['mean_diff'] > mean + 3*std or d['mean_diff'] < mean - 3*std]
    
    print(f"Analyzed {frame_count} frames")
    print(f"Mean difference: {mean:.2f}")
    print(f"Std deviation: {std:.2f}")
    print(f"Anomalies: {len(anomalies)}")
    
    for anom in anomalies[:10]:
        print(f"  Frame {anom['frame']}: diff={anom['mean_diff']:.2f}")
    
    return differences, anomalies

diffs, anoms = compare_consecutive_frames('video.mp4')
```

**LSB extraction from frames:**

```python
def extract_lsb_from_frames(frame_dir):
    """
    Extract LSB from all frames and look for patterns
    """
    import glob
    from PIL import Image
    
    frame_files = sorted(glob.glob(os.path.join(frame_dir, '*.png')))
    
    all_lsb_data = []
    
    for frame_file in frame_files:
        img = Image.open(frame_file)
        pixels = np.array(img)
        
        # Extract LSB from each channel
        lsb_data = pixels & 1
        
        # Flatten to binary string
        binary_string = ''.join(lsb_data.flatten().astype(str))
        all_lsb_data.append(binary_string)
    
    # Combine all LSB data
    combined = ''.join(all_lsb_data)
    
    # Try to decode
    try:
        bytes_list = [int(combined[i:i+8], 2) for i in range(0, len(combined)-7, 8)]
        decoded = bytes(bytes_list)
        
        # Look for file signatures
        if decoded[:4] == b'\x89PNG':
            print("Found PNG signature in LSB data")
        elif decoded[:2] == b'\xFF\xD8':
            print("Found JPEG signature in LSB data")
        elif decoded[:4] == b'PK\x03\x04':
            print("Found ZIP signature in LSB data")
        
        return decoded
    except:
        return None

lsb_data = extract_lsb_from_frames('extracted_frames/')
```

---

## Container Format Analysis (MP4, AVI, MKV)

### Core Concepts

Video containers can hide data in:

- Unused container atoms/chunks
- Padding bytes between structures
- Custom metadata atoms
- Extra data streams
- Container-specific extensions

### MP4 Atom Structure Analysis

**List all atoms:**

```bash
# ffprobe atom structure
ffprobe -v trace video.mp4 2>&1 | grep -i atom

# AtomicParsley for detailed MP4 structure
AtomicParsley video.mp4 -T

# MP4Box structure dump
mp4box -info video.mp4

# Detailed atom tree
mp4box -diso video.mp4
```

**Python MP4 atom parsing:**

```python
import struct

def parse_mp4_atoms(filename):
    """
    Parse MP4 atom structure and identify unusual atoms
    """
    with open(filename, 'rb') as f:
        data = f.read()
    
    atoms = []
    offset = 0
    
    while offset < len(data):
        if offset + 8 > len(data):
            break
        
        # Read atom size and type
        size = struct.unpack('>I', data[offset:offset+4])[0]
        atom_type = data[offset+4:offset+8].decode('ascii', errors='ignore')
        
        if size == 0:  # Atom extends to EOF
            size = len(data) - offset
        elif size == 1:  # Extended size (64-bit)
            if offset + 16 > len(data):
                break
            size = struct.unpack('>Q', data[offset+8:offset+16])[0]
            atom_data_offset = offset + 16
        else:
            atom_data_offset = offset + 8
        
        atoms.append({
            'offset': offset,
            'size': size,
            'type': atom_type,
            'data_offset': atom_data_offset
        })
        
        # Check for custom/unusual atom types
        standard_atoms = ['ftyp', 'moov', 'mdat', 'free', 'skip', 'wide', 
                         'pnot', 'moof', 'mfra', 'udta', 'meta']
        
        if atom_type not in standard_atoms and atom_type.isprintable():
            print(f"[!] Unusual atom: {atom_type} at offset {offset}, size {size}")
        
        offset += size
    
    return atoms

atoms = parse_mp4_atoms('video.mp4')

print(f"Found {len(atoms)} atoms")
for atom in atoms[:20]:
    print(f"  {atom['type']}: {atom['size']} bytes at offset {atom['offset']}")
```

**Extract specific atom data:**

```bash
# Extract 'free' atom (often used for hiding data)
ffmpeg -i video.mp4 -map 0 -c copy -movflags +faststart -f null - 2>&1 | grep free

# Dump metadata atom
mp4box -dump-udta video.mp4

# Extract all metadata
ffmpeg -i video.mp4 -f ffmetadata metadata.txt
```

**Search for hidden data in atoms:**

```python
def search_atoms_for_data(filename):
    """
    Search free/skip atoms and padding for hidden data
    """
    with open(filename, 'rb') as f:
        data = f.read()
    
    atoms = parse_mp4_atoms(filename)
    
    suspicious_findings = []
    
    for atom in atoms:
        if atom['type'] in ['free', 'skip', 'wide']:
            # Extract atom data
            start = atom['data_offset']
            end = atom['offset'] + atom['size']
            
            if end <= len(data):
                atom_data = data[start:end]
                
                # Check if data is not just zeros/padding
                if atom_data.count(b'\x00') < len(atom_data) * 0.9:  # Less than 90% zeros
                    # Look for file signatures
                    signatures = {
                        b'\x89PNG': 'PNG',
                        b'\xFF\xD8\xFF': 'JPEG',
                        b'GIF8': 'GIF',
                        b'PK\x03\x04': 'ZIP',
                        b'Rar!': 'RAR',
                        b'\x1F\x8B': 'GZIP',
                        b'BM': 'BMP'
                    }
                    
                    for sig, file_type in signatures.items():
                        if atom_data.startswith(sig):
                            print(f"[!] Found {file_type} signature in {atom['type']} atom at offset {atom['offset']}")
                            suspicious_findings.append({
                                'atom': atom['type'],
                                'offset': atom['offset'],
                                'file_type': file_type,
                                'data': atom_data
                            })
                            break
                    
                    # Check for high-entropy data (encrypted/compressed)
                    if len(atom_data) > 100:
                        entropy = calculate_entropy(atom_data)
                        if entropy > 7.5:
                            print(f"[!] High entropy ({entropy:.2f}) in {atom['type']} atom at offset {atom['offset']}")
    
    return suspicious_findings

def calculate_entropy(data):
    """Calculate Shannon entropy"""
    import math
    from collections import Counter
    
    if not data:
        return 0
    
    counter = Counter(data)
    length = len(data)
    
    entropy = 0
    for count in counter.values():
        p = count / length
        entropy -= p * math.log2(p)
    
    return entropy

findings = search_atoms_for_data('video.mp4')
```

### AVI Chunk Analysis

**List AVI chunks:**

```bash
# ffprobe for AVI
ffprobe -v trace video.avi 2>&1 | grep chunk

# avidemux can show structure
```

**Python AVI RIFF parsing:**

```python
def parse_avi_riff(filename):
    """
    Parse RIFF/AVI structure
    """
    with open(filename, 'rb') as f:
        data = f.read()
    
    if data[:4] != b'RIFF':
        print("Not a valid RIFF file")
        return None
    
    file_size = struct.unpack('<I', data[4:8])[0]
    file_type = data[8:12]
    
    print(f"RIFF file type: {file_type}")
    
    chunks = []
    offset = 12
    
    while offset < len(data):
        if offset + 8 > len(data):
            break
        
        chunk_id = data[offset:offset+4]
        chunk_size = struct.unpack('<I', data[offset+4:offset+8])[0]
        
        # Handle LIST chunks
        if chunk_id == b'LIST':
            list_type = data[offset+8:offset+12]
            chunks.append({
                'type': 'LIST',
                'list_type': list_type,
                'offset': offset,
                'size': chunk_size
            })
            offset += 8
        else:
            chunks.append({
                'type': chunk_id.decode('ascii', errors='ignore'),
                'offset': offset,
                'size': chunk_size
            })
            offset += 8 + chunk_size
            
            # RIFF chunks are word-aligned
            if chunk_size % 2:
                offset += 1
    
    return chunks

chunks = parse_avi_riff('video.avi')
for chunk in chunks[:20]:
    print(f"  {chunk['type']}: {chunk['size']} bytes at {chunk['offset']}")
```

### MKV (Matroska) Element Analysis

**MKVToolNix analysis:**

```bash
# List all elements
mkvinfo video.mkv

# Extract specific track
mkvextract tracks video.mkv 0:video.h264 1:audio.aac

# Dump attachments
mkvextract attachments video.mkv 1:attachment.bin

# Show detailed structure
mkvinfo -v video.mkv

# Check for unusual elements
mkvinfo video.mkv | grep -i "unknown\|reserved"
```

**Python MKV parsing with ebml:**

```python
def parse_mkv_structure(filename):
    """
    Parse Matroska EBML structure (basic implementation)
    """
    with open(filename, 'rb') as f:
        data = f.read(1000)  # Read first 1KB for header
    
    # Check EBML header
    if data[:4] != b'\x1A\x45\xDF\xA3':
        print("Not a valid EBML/MKV file")
        return None
    
    # For full parsing, use python-ebml library
    try:
        import ebml.core
        
        with open(filename, 'rb') as f:
            doc = ebml.core.MatroskaDocument(f)
            
            for element in doc:
                print(f"Element: {element.name}, Size: {element.size}")
                
                # Check for attachments
                if element.name == 'Attachments':
                    print("[!] Found attachments in MKV")
                
                # Check for tags (can hide data)
                if element.name == 'Tags':
                    print("[!] Found tags in MKV")
        
    except ImportError:
        print("python-ebml not installed. Use: pip install python-ebml")
        return None

parse_mkv_structure('video.mkv')
```

**Extract MKV attachments:**

```bash
# List attachments
mkvmerge -i video.mkv | grep -i attachment

# Extract all attachments
mkvextract attachments video.mkv 1:file1.bin 2:file2.bin

# Extract with auto-naming
for i in $(mkvmerge -i video.mkv | grep "Attachment ID" | cut -d' ' -f4 | tr -d ':'); do
    mkvextract attachments video.mkv $i:attachment_$i.bin
done
```

---

## Frame-by-Frame Analysis

### Temporal Analysis

**Frame difference patterns:**

```python
def analyze_frame_patterns(video_path):
    """
    Analyze temporal patterns in frame changes
    """
    cap = cv2.VideoCapture(video_path)
    
    fps = cap.get(cv2.CAP_PROP_FPS)
    total_frames = int(cap.get(cv2.CAP_PROP_FRAME_COUNT))
    
    ret, prev_frame = cap.read()
    prev_gray = cv2.cvtColor(prev_frame, cv2.COLOR_BGR2GRAY)
    
    differences = []
    frame_num = 1
    
    while frame_num < total_frames:
        ret, curr_frame = cap.read()
        
        if not ret:
            break
        
        curr_gray = cv2.cvtColor(curr_frame, cv2.COLOR_BGR2GRAY)
        
        # Calculate difference
        diff = cv2.absdiff(prev_gray, curr_gray)
        diff_score = np.mean(diff)
        
        differences.append(diff_score)
        
        prev_gray = curr_gray
        frame_num += 1
    
    cap.release()
    
    # Analyze patterns
    differences = np.array(differences)
    
    # Look for periodic patterns (could indicate data encoding)
    from scipy import signal
    
    # Autocorrelation
    autocorr = signal.correlate(differences - np.mean(differences), 
                                differences - np.mean(differences), 
                                mode='full')
    autocorr = autocorr[len(autocorr)//2:]
    
    # Find peaks (periodic patterns)
    peaks, _ = signal.find_peaks(autocorr, height=np.max(autocorr)*0.5)
    
    if len(peaks) > 1:
        period = peaks[1] - peaks[0]
        print(f"[!] Periodic pattern detected with period ~{period} frames")
        print(f"    This could indicate data encoding in frame selection")
    
    return differences

diffs = analyze_frame_patterns('video.mp4')
```

**Frame histogram analysis:**

```python
def analyze_frame_histograms(video_path, sample_rate=10):
    """
    Analyze color histogram patterns across frames
    """
    cap = cv2.VideoCapture(video_path)
    
    frame_num = 0
    histograms = []
    
    while True:
        ret, frame = cap.read()
        
        if not ret:
            break
        
        if frame_num % sample_rate == 0:
            # Calculate histogram for each channel
            hist_b = cv2.calcHist([frame], [0], None, [256], [0, 256])
            hist_g = cv2.calcHist([frame], [1], None, [256], [0, 256])
            hist_r = cv2.calcHist([frame], [2], None, [256], [0, 256])
            
            histograms.append({
                'frame': frame_num,
                'b': hist_b.flatten(),
                'g': hist_g.flatten(),
                'r': hist_r.flatten()
            })
        
        frame_num += 1
    
    cap.release()
    
    # Look for unusual histogram patterns
    for i in range(1, len(histograms)):
        prev_hist = histograms[i-1]
        curr_hist = histograms[i]
        
        # Calculate histogram correlation
        corr_b = cv2.compareHist(prev_hist['b'].reshape(-1, 1).astype(np.float32),
                                  curr_hist['b'].reshape(-1, 1).astype(np.float32),
                                  cv2.HISTCMP_CORREL)
        
        if corr_b < 0.5:  # Low correlation indicates major change
            print(f"[!] Significant histogram change at frame {curr_hist['frame']}")
    
    return histograms

hists = analyze_frame_histograms('video.mp4')
```

### Specific Frame Region Analysis

**Analyze specific regions for data:**

```python
def analyze_frame_regions(frame_path, regions=None):
    """
    Analyze specific regions of a frame for hidden data
    regions: list of (x, y, width, height) tuples
    """
    import cv2
    from PIL import Image
    
    img = cv2.imread(frame_path)
    
    if regions is None:
        # Default: analyze corners (common hiding spots)
        h, w = img.shape[:2]
        regions = [
            (0, 0, 100, 100),  # Top-left
            (w-100, 0, 100, 100),  # Top-right
            (0, h-100, 100, 100),  # Bottom-left
            (w-100, h-100, 100, 100)  # Bottom-right
        ]
    
    for i, (x, y, w, h) in enumerate(regions):
        region = img[y:y+h, x:x+w]
        
        # Calculate statistics
        mean = np.mean(region, axis=(0, 1))
        std = np.std(region, axis=(0, 1))
        
        # Check LSB distribution
        lsb_data = region & 1
        lsb_mean = np.mean(lsb_data)
        
        print(f"Region {i} ({x},{y},{w}x{h}):")
        print(f"  Mean: {mean}")
        print(f"  Std: {std}")
        print(f"  LSB mean: {lsb_mean:.3f} (random~0.5)")
        
        # LSB mean far from 0.5 could indicate hidden data
        if abs(lsb_mean - 0.5) > 0.1:
            print(f"  [!] Unusual LSB distribution")
        
        # Extract LSB for further analysis
        lsb_binary = ''.join(lsb_data.flatten().astype(str))
        try:
            decoded = bytes([int(lsb_binary[i:i+8], 2) for i in range(0, min(800, len(lsb_binary)), 8)])
            if b'flag' in decoded.lower() or b'ctf' in decoded.lower():
                print(f"  [!] Possible flag text in LSB: {decoded[:100]}")
        except:
            pass

analyze_frame_regions('frame_0001.png')
```

### Motion Vector Analysis

**Extract motion vectors:**

```bash
# Extract motion vectors from H.264 video
ffmpeg -flags2 +export_mvs -i video.mp4 -vf codecview=mv=pf+bf+bb -f null -

# Save motion vectors to video visualization
ffmpeg -flags2 +export_mvs -i video.mp4 -vf codecview=mv=pf+bf+bb motion_vectors.mp4

# Extract to data format (requires custom filter)
ffmpeg -flags2 +export_mvs -i video.mp4 -vf "format=yuv420p,codecview=mv_type=fp" -f rawvideo - | xxd > mv_data.hex
```

**Analyze motion vector patterns:**

```python
def analyze_motion_vectors(video_path):
    """
    [Inference] Motion vector extraction requires specialized tools
    This is a conceptual approach - actual implementation needs codec-level access
    """
    # For H.264/H.265, motion vectors are part of compressed stream
    # Tools like x264/x265 debug modes or specialized parsers needed
    
    print("[!] Motion vector analysis requires:")
    print("    - H.264/H.265 bitstream parser")
    print("    - Or ffmpeg with export_mvs flag and custom parsing")
    print("    - Libraries like PyAV or direct codec API access")
    
    # Conceptual: motion vectors could encode data in:
    # - Vector magnitude patterns
    # - Vector direction patterns  
    # - Unusual motion in static regions

# Note: Full implementation requires codec-specific tools
```

---

## Subtitle Track Extraction

### Extract Subtitle Tracks

**FFmpeg subtitle extraction:**

```bash
# List all subtitle streams
ffprobe -v error -select_streams s -show_entries stream=index,codec_name -of csv video.mkv

# Extract subtitle track 0
ffmpeg -i video.mkv -map 0:s:0 subtitles.srt

# Extract all subtitle tracks
ffmpeg -i video.mkv -map 0:s subtitle_%d.srt

# Extract specific subtitle format
ffmpeg -i video.mkv -map 0:s:0 -c:s ass subtitles.ass

# Extract SSA/ASS format
ffmpeg -i video.mkv -map 0:s:0 -c:s copy subtitles.ass

# Extract VobSub (DVD subtitles)
ffmpeg -i video.mkv -map 0:s:0 -c:s copy subtitle.sub

# Extract WebVTT
ffmpeg -i video.mp4 -map 0:s:0 subtitles.vtt

# Extract from specific time range
ffmpeg -ss 00:01:00 -to 00:05:00 -i video.mkv -map 0:s:0 partial_subs.srt
```

**MKV subtitle extraction:**

```bash
# List tracks
mkvmerge -i video.mkv

# Extract subtitle track 2
mkvextract tracks video.mkv 2:subtitles.srt

# Extract all subtitle tracks
for track in $(mkvmerge -i video.mkv | grep subtitles | cut -d':' -f1 | grep -oE '[0-9]+'); do
    mkvextract tracks video.mkv $track:subtitle_$track.srt
done
```

### Analyze Subtitle Content

**Parse SRT files:**

```python
def parse_srt(filename):
    """
    Parse SRT subtitle file
    """
    with open(filename, 'r', encoding='utf-8') as f:
        content = f.read()
    
    import re
    
    # SRT format: number, timecode, text, blank line
    pattern = r'(\d+)\n(\d{2}:\d{2}:\d{2},\d{3}) --> (\d{2}:\d{2}:\d{2},\d{3})\n(.*?)(?=\n\n|\Z)'
    
    matches = re.findall(pattern, content, re.DOTALL)
    
    subtitles = []
    for match in matches:
        subtitles.append({
            'index': int(match[0]),
            'start': match[1],
            'end': match[2],
            'text': match[3].strip()
        })
    
    return subtitles

subs = parse_srt('subtitles.srt')

# Analyze subtitle text
for sub in subs:
    # Check for unusual characters
    if any(ord(c) > 127 for c in sub['text']):
        print(f"[!] Non-ASCII in subtitle {sub['index']}: {sub['text'][:50]}")
    
    # Check for hidden data patterns
    if sub['text'].startswith('{{') or '<!--' in sub['text']:
        print(f"[!] Unusual markup in subtitle {sub['index']}")
```

**Extract hidden data from subtitles:**

```python
def extract_subtitle_steganography(srt_file):
    """
    Check for various steganography techniques in subtitles
    """
    subs = parse_srt(srt_file)
    
    findings = []
    
    # 1. Check timing patterns
    timings = []
    for sub in subs:
        # Parse start time to milliseconds
        h, m, s_ms = sub['start'].split(':')
        s, ms = s_ms.split(',')
        total_ms = int(h)*3600000 + int(m)*60000 + int(s)*1000 + int(ms)
        timings.append(total_ms)
    
    # Check for encoded data in timing
    timing_diffs = [timings[i+1] - timings[i] for i in range(len(timings)-1)]
    
    # Timing differences might encode bits
    median_diff = np.median(timing_diffs)
    binary_from_timing = ''.join(['1' if d > median_diff else '0' for d in timing_diffs])
    
    try:
        decoded_timing = bytes([int(binary_from_timing[i:i+8], 2) for i in range(0, len(binary_from_timing)-7, 8)])
        if b'flag' in decoded_timing.lower() or b'CTF' in decoded_timing:
            print("[!] Possible flag in subtitle timing")
            findings.append(('timing', decoded_timing))
    except:
        pass
    
    # 2. Check for zero-width characters
    all_text = ' '.join([sub['text'] for sub in subs])
    zw_chars = [c for c in all_text if ord(c) in [0x200B, 0x200C, 0x200D, 0x200E, 0x200F, 0xFEFF]]
    
    if zw_chars:
        binary = ''.join(zw_chars).replace('\u200B', '0').replace('\u200C', '1')
        try:
            decoded_zw = bytes([int(binary[i:i+8], 2) for i in range(0, len(binary)-7, 8)])
            print(f"[!] Found {len(zw_chars)} zero-width chars in subtitles")
            findings.append(('zero_width', decoded_zw))
        except:
            pass
    
    # 3. Check first letters of each subtitle (acrostic)
    first_letters = ''.join([sub['text'][0] if sub['text'] else '' for sub in subs])
    print(f"First letters: {first_letters}")
    if 'FLAG' in first_letters.upper() or 'CTF' in first_letters.upper():
        print("[!] Possible acrostic in subtitles")
        findings.append(('acrostic', first_letters))
    
    # 4. Check for base64 in subtitle text
    import re
    import base64
    
    for sub in subs:
        b64_matches = re.findall(r'[A-Za-z0-9+/]{20,}={0,2}', sub['text'])
        
        for match in b64_matches:
            try:
                decoded = base64.b64decode(match)
                if decoded.isprintable() or b'\x89PNG' in decoded or b'\xFF\xD8' in decoded:
                    print(f"[!] Base64 found in subtitle {sub['index']}: {decoded[:50]}")
                    findings.append(('base64', decoded))
            except:
                pass
    
    # 5. Check subtitle index patterns
    indices = [sub['index'] for sub in subs]
    if indices != list(range(1, len(indices)+1)):
        print("[!] Non-sequential subtitle indices detected")
        # Gaps might encode data
        expected = set(range(1, max(indices)+1))
        actual = set(indices)
        missing = expected - actual
        if missing:
            print(f"    Missing indices: {sorted(missing)}")
            # Convert missing indices to ASCII
            ascii_attempt = ''.join([chr(idx) if idx < 128 else '?' for idx in sorted(missing)])
            print(f"    As ASCII: {ascii_attempt}")
            findings.append(('index_gaps', ascii_attempt))
    
    # 6. Check for HTML/XML in subtitles
    for sub in subs:
        if '<' in sub['text'] and '>' in sub['text']:
            # Extract HTML comments
            comments = re.findall(r'<!--(.*?)-->', sub['text'])
            if comments:
                print(f"[!] HTML comment in subtitle {sub['index']}: {comments}")
                findings.append(('html_comment', comments))
    
    return findings

findings = extract_subtitle_steganography('subtitles.srt')
```

### ASS/SSA Format Analysis

**Parse ASS format:**

```python
def parse_ass(filename):
    """
    Parse Advanced SubStation Alpha (ASS) format
    ASS has more metadata and styling that can hide data
    """
    with open(filename, 'r', encoding='utf-8') as f:
        lines = f.readlines()
    
    sections = {
        'script_info': [],
        'styles': [],
        'events': []
    }
    
    current_section = None
    
    for line in lines:
        line = line.strip()
        
        if line.startswith('[') and line.endswith(']'):
            section_name = line[1:-1].lower().replace(' ', '_')
            current_section = section_name
        elif current_section and line and not line.startswith(';'):
            if current_section == 'script_info':
                sections['script_info'].append(line)
            elif current_section == 'v4+_styles' or current_section == 'v4_styles':
                sections['styles'].append(line)
            elif current_section == 'events':
                sections['events'].append(line)
    
    return sections

ass_data = parse_ass('subtitles.ass')

# Check Script Info for hidden data
print("=== Script Info ===")
for info in ass_data['script_info']:
    print(info)
    # Look for custom fields
    if ':' in info:
        key, value = info.split(':', 1)
        if key.strip() not in ['Title', 'ScriptType', 'WrapStyle', 'PlayResX', 'PlayResY', 'ScaledBorderAndShadow', 'Video Aspect Ratio', 'Video Zoom', 'Video Position']:
            print(f"[!] Custom Script Info field: {key}")
```

**Extract dialogue from ASS:**

```python
def extract_ass_dialogue(filename):
    """
    Extract dialogue events from ASS file with full metadata
    """
    ass_data = parse_ass(filename)
    
    dialogues = []
    
    for event_line in ass_data['events']:
        if event_line.startswith('Dialogue:'):
            # Format: Dialogue: Layer,Start,End,Style,Name,MarginL,MarginR,MarginV,Effect,Text
            parts = event_line.split(',', 9)
            
            if len(parts) >= 10:
                dialogues.append({
                    'layer': parts[0].split(':')[1].strip(),
                    'start': parts[1].strip(),
                    'end': parts[2].strip(),
                    'style': parts[3].strip(),
                    'name': parts[4].strip(),
                    'margin_l': parts[5].strip(),
                    'margin_r': parts[6].strip(),
                    'margin_v': parts[7].strip(),
                    'effect': parts[8].strip(),
                    'text': parts[9].strip()
                })
    
    # Analyze for hidden data
    for i, dialogue in enumerate(dialogues):
        # Check Effect field (rarely used, good hiding spot)
        if dialogue['effect']:
            print(f"[!] Dialogue {i} has Effect: {dialogue['effect']}")
        
        # Check Name field
        if dialogue['name']:
            print(f"[!] Dialogue {i} has Name: {dialogue['name']}")
        
        # Check unusual margins
        if dialogue['margin_l'] != '0' or dialogue['margin_r'] != '0' or dialogue['margin_v'] != '0':
            print(f"[!] Non-zero margins: L={dialogue['margin_l']}, R={dialogue['margin_r']}, V={dialogue['margin_v']}")
    
    return dialogues

dialogues = extract_ass_dialogue('subtitles.ass')
```

**Analyze ASS drawing commands:**

```python
def analyze_ass_drawings(filename):
    """
    ASS format supports vector drawings that could hide data
    Drawing commands start with {\p1} or higher
    """
    ass_data = parse_ass(filename)
    
    drawings = []
    
    for event in ass_data['events']:
        if '\\p' in event:  # Drawing mode indicator
            # Extract drawing commands
            import re
            drawing_pattern = r'\{\\p\d+\}(.*?)\{\\p0\}'
            matches = re.findall(drawing_pattern, event)
            
            for match in matches:
                drawings.append(match)
                print(f"[!] Found drawing command: {match[:100]}")
    
    # Drawing commands are sequences of coordinates
    # Could encode data in coordinate values
    for drawing in drawings:
        # Parse coordinates (simplified)
        coords = re.findall(r'\d+', drawing)
        if coords:
            # Try interpreting as ASCII
            ascii_attempt = ''.join([chr(int(c) % 128) if int(c) < 256 else '?' for c in coords])
            print(f"    Coordinates as ASCII: {ascii_attempt[:50]}")
    
    return drawings

drawings = analyze_ass_drawings('subtitles.ass')
```

### WebVTT Analysis

**Parse WebVTT:**

```python
def parse_webvtt(filename):
    """
    Parse WebVTT subtitle format
    """
    with open(filename, 'r', encoding='utf-8') as f:
        content = f.read()
    
    if not content.startswith('WEBVTT'):
        print("Not a valid WebVTT file")
        return None
    
    import re
    
    # WebVTT cue format
    pattern = r'([\d:\.]+)\s*-->\s*([\d:\.]+)\s*(?:.*?)\n(.*?)(?=\n\n|\Z)'
    matches = re.findall(pattern, content, re.DOTALL)
    
    cues = []
    for match in matches:
        cues.append({
            'start': match[0],
            'end': match[1],
            'text': match[2].strip()
        })
    
    return cues

vtt_cues = parse_webvtt('subtitles.vtt')

# Check for WebVTT metadata
def extract_webvtt_metadata(filename):
    """
    Extract NOTE and STYLE blocks from WebVTT
    """
    with open(filename, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # Extract NOTE blocks
    notes = re.findall(r'NOTE\s+(.*?)(?=\n\n|\Z)', content, re.DOTALL)
    
    if notes:
        print("[!] Found NOTE blocks in WebVTT:")
        for note in notes:
            print(f"    {note[:100]}")
    
    # Extract STYLE blocks
    styles = re.findall(r'STYLE\s+(.*?)(?=\n\n|\Z)', content, re.DOTALL)
    
    if styles:
        print("[!] Found STYLE blocks in WebVTT:")
        for style in styles:
            print(f"    {style[:100]}")
    
    return {'notes': notes, 'styles': styles}

vtt_meta = extract_webvtt_metadata('subtitles.vtt')
```

---

## Video Metadata Analysis

### Extract All Metadata

**FFprobe comprehensive metadata:**

```bash
# Full metadata dump
ffprobe -v quiet -print_format json -show_format -show_streams video.mp4 > metadata.json

# Human-readable format
ffprobe -v quiet -print_format flat -show_format -show_streams video.mp4

# Specific metadata tags
ffprobe -v error -show_entries format_tags -of default=noprint_wrappers=1 video.mp4

# Stream-specific metadata
ffprobe -v error -select_streams v:0 -show_entries stream_tags -of default=noprint_wrappers=1 video.mp4

# Show all metadata including private data
ffprobe -v trace video.mp4 2>&1 | grep -i metadata
```

**ExifTool for video:**

```bash
# Install exiftool
apt-get install libimage-exiftool-perl

# Extract all metadata
exiftool video.mp4

# Output to JSON
exiftool -j video.mp4 > exif_metadata.json

# Show only custom/unusual tags
exiftool -s -G video.mp4 | grep -v "File\|ExifTool\|System"

# Extract specific tag groups
exiftool -XMP:All video.mp4
exiftool -QuickTime:All video.mp4

# Binary data extraction
exiftool -b -UserData video.mp4 > userdata.bin
```

**MediaInfo detailed analysis:**

```bash
# Install mediainfo
apt-get install mediainfo

# Full report
mediainfo video.mp4

# XML output
mediainfo --Output=XML video.mp4 > mediainfo.xml

# JSON output
mediainfo --Output=JSON video.mp4

# Specific information
mediainfo --Inform="General;%Title%\n%Comment%" video.mp4
```

### Python Metadata Extraction

**Using ffprobe-python:**

```python
import subprocess
import json

def extract_video_metadata(filename):
    """
    Extract comprehensive video metadata using ffprobe
    """
    cmd = [
        'ffprobe',
        '-v', 'quiet',
        '-print_format', 'json',
        '-show_format',
        '-show_streams',
        '-show_chapters',
        '-show_programs',
        filename
    ]
    
    result = subprocess.run(cmd, capture_output=True, text=True)
    
    if result.returncode != 0:
        print(f"Error: {result.stderr}")
        return None
    
    metadata = json.loads(result.stdout)
    
    return metadata

metadata = extract_video_metadata('video.mp4')

# Analyze metadata
if metadata:
    print("=== Format Metadata ===")
    format_tags = metadata.get('format', {}).get('tags', {})
    for key, value in format_tags.items():
        print(f"{key}: {value}")
        
        # Check for unusual tags
        standard_tags = ['encoder', 'creation_time', 'major_brand', 'minor_version', 'compatible_brands']
        if key.lower() not in standard_tags:
            print(f"[!] Unusual tag: {key}")
    
    print("\n=== Stream Metadata ===")
    for i, stream in enumerate(metadata.get('streams', [])):
        print(f"\nStream {i} ({stream.get('codec_type')}):")
        stream_tags = stream.get('tags', {})
        for key, value in stream_tags.items():
            print(f"  {key}: {value}")
```

**Check for hidden data in metadata:**

```python
def analyze_metadata_for_hidden_data(metadata):
    """
    Analyze metadata fields for hidden/encoded data
    """
    import base64
    import re
    
    findings = []
    
    # Check all text fields
    def check_field(field_name, field_value):
        if not isinstance(field_value, str):
            return
        
        # Check for base64
        if len(field_value) > 20:
            try:
                decoded = base64.b64decode(field_value)
                if decoded.isprintable() or decoded[:4] in [b'\x89PNG', b'\xFF\xD8\xFF', b'PK\x03\x04']:
                    print(f"[!] Base64 in {field_name}: {decoded[:50]}")
                    findings.append(('base64', field_name, decoded))
            except:
                pass
        
        # Check for hex strings
        if re.match(r'^[0-9a-fA-F]{32,}$', field_value):
            try:
                decoded = bytes.fromhex(field_value)
                print(f"[!] Hex string in {field_name}: {decoded[:50]}")
                findings.append(('hex', field_name, decoded))
            except:
                pass
        
        # Check for URLs (data exfiltration)
        urls = re.findall(r'https?://[^\s]+', field_value)
        if urls:
            print(f"[!] URL in {field_name}: {urls}")
            findings.append(('url', field_name, urls))
    
    # Recursively check all fields
    def traverse(obj, path=''):
        if isinstance(obj, dict):
            for key, value in obj.items():
                new_path = f"{path}.{key}" if path else key
                if isinstance(value, str):
                    check_field(new_path, value)
                else:
                    traverse(value, new_path)
        elif isinstance(obj, list):
            for i, item in enumerate(obj):
                traverse(item, f"{path}[{i}]")
    
    traverse(metadata)
    
    return findings

findings = analyze_metadata_for_hidden_data(metadata)
```

### Extract Custom Metadata Atoms

**Extract MP4 'meta' atom:**

```python
def extract_mp4_metadata_atom(filename):
    """
    Extract and parse the 'meta' atom from MP4
    """
    atoms = parse_mp4_atoms(filename)
    
    with open(filename, 'rb') as f:
        data = f.read()
    
    for atom in atoms:
        if atom['type'] == 'meta':
            # Extract meta atom data
            start = atom['data_offset']
            end = atom['offset'] + atom['size']
            
            meta_data = data[start:end]
            
            # Save to file for analysis
            with open('meta_atom.bin', 'wb') as mf:
                mf.write(meta_data)
            
            print(f"[!] Extracted 'meta' atom: {len(meta_data)} bytes")
            
            # Check for embedded data
            # Meta atom can contain ilst (iTunes metadata), hdlr, keys, etc.
            if b'ilst' in meta_data:
                print("    Contains iTunes metadata (ilst)")
            
            if b'keys' in meta_data:
                print("    Contains keys atom")
            
            # Look for custom data
            printable = ''.join([chr(b) if 32 <= b < 127 else '.' for b in meta_data])
            
            # Search for interesting strings
            import re
            strings = re.findall(r'[ -~]{8,}', printable)
            
            print(f"    Found {len(strings)} readable strings")
            for s in strings[:10]:
                print(f"      {s}")
            
            return meta_data
    
    return None

meta_data = extract_mp4_metadata_atom('video.mp4')
```

### GPS and Location Data

**Extract GPS coordinates:**

```bash
# ExifTool GPS extraction
exiftool -GPS:All video.mp4

# FFprobe location data
ffprobe -v error -show_entries format_tags=location -of default=noprint_wrappers=1:nokey=1 video.mp4
```

```python
def extract_gps_data(metadata):
    """
    Extract GPS/location data from video metadata
    """
    gps_data = {}
    
    def search_gps(obj, path=''):
        if isinstance(obj, dict):
            for key, value in obj.items():
                lower_key = key.lower()
                if any(term in lower_key for term in ['gps', 'location', 'latitude', 'longitude', 'coordinates']):
                    gps_data[f"{path}.{key}" if path else key] = value
                elif isinstance(value, (dict, list)):
                    search_gps(value, f"{path}.{key}" if path else key)
        elif isinstance(obj, list):
            for i, item in enumerate(obj):
                search_gps(item, f"{path}[{i}]")
    
    search_gps(metadata)
    
    if gps_data:
        print("[!] GPS/Location data found:")
        for key, value in gps_data.items():
            print(f"    {key}: {value}")
    
    return gps_data

gps = extract_gps_data(metadata)
```

### Creation/Modification Timestamps

**Analyze timestamps for patterns:**

```python
def analyze_timestamps(metadata):
    """
    Extract and analyze all timestamps in metadata
    """
    timestamps = []
    
    def find_timestamps(obj, path=''):
        if isinstance(obj, dict):
            for key, value in obj.items():
                if 'time' in key.lower() or 'date' in key.lower():
                    timestamps.append({
                        'field': f"{path}.{key}" if path else key,
                        'value': value
                    })
                elif isinstance(value, (dict, list)):
                    find_timestamps(value, f"{path}.{key}" if path else key)
        elif isinstance(obj, list):
            for i, item in enumerate(obj):
                find_timestamps(item, f"{path}[{i}]")
    
    find_timestamps(metadata)
    
    print(f"Found {len(timestamps)} timestamp fields:")
    for ts in timestamps:
        print(f"  {ts['field']}: {ts['value']}")
    
    # Check for anomalies
    from datetime import datetime
    
    parsed_times = []
    for ts in timestamps:
        try:
            # Try parsing ISO format
            dt = datetime.fromisoformat(ts['value'].replace('Z', '+00:00'))
            parsed_times.append(dt)
        except:
            pass
    
    if len(parsed_times) >= 2:
        time_diffs = [abs((parsed_times[i+1] - parsed_times[i]).total_seconds()) for i in range(len(parsed_times)-1)]
        if time_diffs:
            print(f"\nTime differences (seconds): {time_diffs}")
            
            # Check if differences encode data
            if all(d < 256 for d in time_diffs):
                ascii_attempt = ''.join([chr(int(d)) if 32 <= d < 127 else '?' for d in time_diffs])
                print(f"Time diffs as ASCII: {ascii_attempt}")
    
    return timestamps

timestamps = analyze_timestamps(metadata)
```

### Comprehensive Video Analysis Script

```python
def comprehensive_video_analysis(video_file):
    """
    Complete video steganography analysis combining all techniques
    """
    print("="*60)
    print(f"COMPREHENSIVE VIDEO ANALYSIS: {video_file}")
    print("="*60)
    
    # 1. Container Analysis
    print("\n[1] CONTAINER STRUCTURE")
    print("-"*60)
    if video_file.endswith('.mp4'):
        atoms = parse_mp4_atoms(video_file)
        print(f"Found {len(atoms)} MP4 atoms")
        search_atoms_for_data(video_file)
    elif video_file.endswith('.avi'):
        chunks = parse_avi_riff(video_file)
        if chunks:
            print(f"Found {len(chunks)} AVI chunks")
    
    # 2. Metadata Analysis
    print("\n[2] METADATA ANALYSIS")
    print("-"*60)
    metadata = extract_video_metadata(video_file)
    if metadata:
        analyze_metadata_for_hidden_data(metadata)
        extract_gps_data(metadata)
        analyze_timestamps(metadata)
    
    # 3. Subtitle Analysis
    print("\n[3] SUBTITLE TRACKS")
    print("-"*60)
    # Extract subtitles
    import os
    os.system(f"ffmpeg -i {video_file} -map 0:s:0 temp_subtitle.srt 2>/dev/null")
    if os.path.exists('temp_subtitle.srt'):
        extract_subtitle_steganography('temp_subtitle.srt')
        os.remove('temp_subtitle.srt')
    else:
        print("No subtitle tracks found")
    
    # 4. Frame Extraction & Analysis
    print("\n[4] FRAME ANALYSIS")
    print("-"*60)
    print("Extracting sample frames...")
    os.makedirs('temp_frames', exist_ok=True)
    os.system(f"ffmpeg -i {video_file} -vf 'select=not(mod(n\\,100))' -vsync 0 temp_frames/frame_%04d.png 2>/dev/null")
    
    # Analyze extracted frames
    frame_files = sorted([f for f in os.listdir('temp_frames') if f.endswith('.png')])
    if frame_files:
        print(f"Extracted {len(frame_files)} sample frames")
        # Analyze first frame for LSB
        analyze_frame_regions(os.path.join('temp_frames', frame_files[0]))
    
    # Cleanup
    import shutil
    if os.path.exists('temp_frames'):
        shutil.rmtree('temp_frames')
    
    # 5. Temporal Analysis
    print("\n[5] TEMPORAL PATTERNS")
    print("-"*60)
    analyze_frame_patterns(video_file)
    
    print("\n" + "="*60)
    print("ANALYSIS COMPLETE")
    print("="*60)

# Usage
comprehensive_video_analysis('suspicious_video.mp4')
```

---

## Important Related Topics for Video Steganography

**Codec-Specific Steganography** - H.264/H.265 quantization parameters, prediction modes, intra-prediction manipulation

**Audio Track Steganography** - LSB in audio samples, phase encoding, echo hiding within video files

**3D Video Analysis** - Stereoscopic video depth map manipulation, parallax-based encoding

**Streaming Protocol Analysis** - HLS/DASH segment manipulation, manifest file analysis

**Video Compression Artifacts** - DCT coefficient analysis, quantization table manipulation in compressed streams

**Live Stream Forensics** - RTMP/RTSP stream analysis, real-time frame injection detection

---

# Cryptographic Integration

## Password-Protected Steganography

Password-protected steganography combines data hiding with encryption, requiring both the correct password and steganographic knowledge to extract embedded content.

### Basic Password-Protected Embedding

Hide encrypted data within images using steghide:

```bash
# Encrypt and embed
echo "secret message" > secret.txt
steghide embed -cf cover.jpg -ef secret.txt -sf stego.jpg -p "mypassword"

# Extract with password
steghide extract -sf stego.jpg -xf extracted.txt -p "mypassword"
cat extracted.txt
```

Python implementation for custom password protection:

```python
from PIL import Image
import hashlib
import os

def encrypt_data(data, password):
    """Simple XOR encryption with password derivation"""
    salt = os.urandom(16)
    key = hashlib.pbkdf2_hmac('sha256', password.encode(), salt, 100000)
    
    # XOR encryption
    encrypted = bytearray()
    for i, byte in enumerate(data):
        encrypted.append(byte ^ key[i % len(key)])
    
    return salt + encrypted

def decrypt_data(encrypted_data, password):
    """Decrypt XOR-encrypted data"""
    salt = encrypted_data[:16]
    ciphertext = encrypted_data[16:]
    
    key = hashlib.pbkdf2_hmac('sha256', password.encode(), salt, 100000)
    
    decrypted = bytearray()
    for i, byte in enumerate(ciphertext):
        decrypted.append(byte ^ key[i % len(key)])
    
    return bytes(decrypted)

def embed_encrypted_lsb(image_path, message, password, output_path):
    """Embed password-protected message in image LSBs"""
    img = Image.open(image_path)
    pixels = img.load()
    
    # Encrypt message
    encrypted = encrypt_data(message.encode(), password)
    
    # Convert to binary
    binary = ''.join(format(byte, '08b') for byte in encrypted)
    
    # Add length header (32 bits)
    length_bits = format(len(encrypted), '032b')
    binary = length_bits + binary
    
    # Embed in LSBs
    bit_index = 0
    for y in range(img.height):
        for x in range(img.width):
            if bit_index >= len(binary):
                break
            
            pixel = list(pixels[x, y])
            pixel[0] = (pixel[0] & 0xFE) | int(binary[bit_index])
            pixels[x, y] = tuple(pixel)
            bit_index += 1
    
    img.save(output_path)
    print(f"Embedded {len(encrypted)} encrypted bytes in {output_path}")

def extract_encrypted_lsb(image_path, password):
    """Extract and decrypt password-protected message"""
    img = Image.open(image_path)
    pixels = img.load()
    
    # Extract LSBs
    binary = ''
    for y in range(img.height):
        for x in range(img.width):
            pixel = pixels[x, y]
            binary += str(pixel[0] & 1)
    
    # Extract length
    length_bits = binary[:32]
    encrypted_length = int(length_bits, 2)
    
    # Extract encrypted data
    encrypted_bits = binary[32:32 + encrypted_length * 8]
    encrypted_bytes = bytearray()
    for i in range(0, len(encrypted_bits), 8):
        encrypted_bytes.append(int(encrypted_bits[i:i+8], 2))
    
    # Decrypt
    try:
        decrypted = decrypt_data(bytes(encrypted_bytes), password)
        return decrypted.decode('utf-8', errors='ignore')
    except:
        return None

# Usage
embed_encrypted_lsb('cover.jpg', 'secret flag', 'password123', 'stego.jpg')
message = extract_encrypted_lsb('stego.jpg', 'password123')
print(f"Extracted: {message}")
```

### Steghide Password Brute-Force

Attack password-protected steghide files:

```bash
# Using stegseek (fastest method)
stegseek --crack stego.jpg wordlist.txt -o output_dir

# Manual brute-force with steghide
#!/bin/bash
while IFS= read -r password; do
    if steghide extract -sf stego.jpg -xf extracted.txt -p "$password" 2>/dev/null; then
        if [ -s extracted.txt ]; then
            echo "Password found: $password"
            cat extracted.txt
            break
        fi
    fi
done < wordlist.txt
```

Python brute-force implementation:

```python
import subprocess
import sys

def brute_force_steghide(stego_file, wordlist_file):
    """Brute-force steghide password"""
    with open(wordlist_file, 'r') as f:
        passwords = f.readlines()
    
    total = len(passwords)
    
    for i, password in enumerate(passwords):
        password = password.strip()
        
        # Display progress
        if i % 100 == 0:
            print(f"Progress: {i}/{total}", file=sys.stderr)
        
        # Try extraction
        try:
            result = subprocess.run(
                ['steghide', 'extract', '-sf', stego_file, 
                 '-xf', '/tmp/extracted.txt', '-p', password],
                capture_output=True,
                timeout=2
            )
            
            if result.returncode == 0:
                # Read extracted file
                with open('/tmp/extracted.txt', 'rb') as f:
                    data = f.read()
                
                print(f"\n✓ Password found: {password}")
                print(f"Extracted data: {data}")
                return password, data
        
        except subprocess.TimeoutExpired:
            continue
        except Exception as e:
            continue
    
    print("No password found")
    return None, None

brute_force_steghide('stego.jpg', 'wordlist.txt')
```

### Multi-Layer Password Protection

Implement cascading password encryption:

```python
import hashlib
from Crypto.Cipher import AES
from Crypto.Random import get_random_bytes
from Crypto.Util.Padding import pad, unpad

def multi_layer_encrypt(data, passwords):
    """
    Apply multiple layers of encryption with different passwords
    """
    current_data = data
    
    for i, password in enumerate(passwords):
        # Derive key from password
        salt = get_random_bytes(16)
        key = hashlib.pbkdf2_hmac('sha256', password.encode(), salt, 100000)
        
        # AES encryption
        cipher = AES.new(key, AES.MODE_CBC)
        iv = cipher.iv
        
        padded_data = pad(current_data, AES.block_size)
        ciphertext = cipher.encrypt(padded_data)
        
        # Prepend salt and IV for next iteration
        current_data = salt + iv + ciphertext
    
    return current_data

def multi_layer_decrypt(encrypted_data, passwords):
    """
    Decrypt multi-layer encryption in reverse order
    """
    current_data = encrypted_data
    
    # Decrypt in reverse order
    for password in reversed(passwords):
        # Extract salt and IV
        salt = current_data[:16]
        iv = current_data[16:32]
        ciphertext = current_data[32:]
        
        # Derive key
        key = hashlib.pbkdf2_hmac('sha256', password.encode(), salt, 100000)
        
        # Decrypt
        cipher = AES.new(key, AES.MODE_CBC, iv)
        decrypted = unpad(cipher.decrypt(ciphertext), AES.block_size)
        
        current_data = decrypted
    
    return current_data

# Usage
passwords = ['password1', 'password2', 'password3']
message = b'Secret message'

encrypted = multi_layer_encrypt(message, passwords)
print(f"Encrypted: {encrypted.hex()}")

decrypted = multi_layer_decrypt(encrypted, passwords)
print(f"Decrypted: {decrypted}")
```

## Encrypted Payloads

Encrypted payloads hide data using cryptographic algorithms, requiring key recovery or brute-force to reveal content.

### Identifying Encrypted Data

Detect encrypted payloads by entropy and structure analysis:

```python
import math

def detect_encryption(file_path, chunk_size=256):
    """
    Detect encrypted payloads through entropy analysis
    Encrypted data typically has entropy > 7.0
    """
    with open(file_path, 'rb') as f:
        data = f.read()
    
    def calculate_entropy(data):
        if len(data) == 0:
            return 0
        byte_counts = {}
        for byte in data:
            byte_counts[byte] = byte_counts.get(byte, 0) + 1
        entropy = 0
        for count in byte_counts.values():
            p = count / len(data)
            entropy -= p * math.log2(p)
        return entropy
    
    print(f"File: {file_path}")
    print(f"Total size: {len(data)} bytes\n")
    
    for i in range(0, len(data), chunk_size):
        chunk = data[i:i+chunk_size]
        entropy = calculate_entropy(chunk)
        
        offset = i
        
        if entropy > 7.0:
            print(f"0x{offset:08x}: HIGH entropy ({entropy:.2f}) - Likely encrypted")
        elif entropy > 5.0:
            print(f"0x{offset:08x}: MEDIUM entropy ({entropy:.2f}) - Possibly encrypted/compressed")
        else:
            print(f"0x{offset:08x}: LOW entropy ({entropy:.2f}) - Likely plaintext")

detect_encryption('target.bin')
```

### Common Encryption Schemes in CTF

Implement and break common CTF encryption schemes:

```python
from Crypto.Cipher import AES, DES, Blowfish
from Crypto.Random import get_random_bytes
import hashlib

def aes_encrypt_ecb(plaintext, key):
    """AES ECB encryption (insecure for large data)"""
    cipher = AES.new(key, AES.MODE_ECB)
    from Crypto.Util.Padding import pad
    return cipher.encrypt(pad(plaintext, AES.block_size))

def aes_decrypt_ecb(ciphertext, key):
    """AES ECB decryption"""
    cipher = AES.new(key, AES.MODE_ECB)
    from Crypto.Util.Padding import unpad
    return unpad(cipher.decrypt(ciphertext), AES.block_size)

def aes_encrypt_cbc(plaintext, key, iv=None):
    """AES CBC encryption"""
    if iv is None:
        iv = get_random_bytes(16)
    cipher = AES.new(key, AES.MODE_CBC, iv)
    from Crypto.Util.Padding import pad
    return iv + cipher.encrypt(pad(plaintext, AES.block_size))

def aes_decrypt_cbc(ciphertext, key):
    """AES CBC decryption"""
    iv = ciphertext[:16]
    ciphertext = ciphertext[16:]
    cipher = AES.new(key, AES.MODE_CBC, iv)
    from Crypto.Util.Padding import unpad
    return unpad(cipher.decrypt(ciphertext), AES.block_size)

def des_encrypt(plaintext, key):
    """DES encryption (56-bit key)"""
    cipher = DES.new(key, DES.MODE_ECB)
    from Crypto.Util.Padding import pad
    return cipher.encrypt(pad(plaintext, DES.block_size))

def des_decrypt(ciphertext, key):
    """DES decryption"""
    cipher = DES.new(key, DES.MODE_ECB)
    from Crypto.Util.Padding import unpad
    return unpad(cipher.decrypt(ciphertext), DES.block_size)

# Usage examples
plaintext = b'Secret message!'
key_16 = get_random_bytes(16)  # 128-bit key
key_8 = get_random_bytes(8)    # 56-bit key for DES

# AES ECB
encrypted_aes = aes_encrypt_ecb(plaintext, key_16)
decrypted_aes = aes_decrypt_ecb(encrypted_aes, key_16)
print(f"AES ECB: {decrypted_aes}")

# AES CBC
encrypted_cbc = aes_encrypt_cbc(plaintext, key_16)
decrypted_cbc = aes_decrypt_cbc(encrypted_cbc, key_16)
print(f"AES CBC: {decrypted_cbc}")

# DES
encrypted_des = des_encrypt(plaintext, key_8)
decrypted_des = des_decrypt(encrypted_des, key_8)
print(f"DES: {decrypted_des}")
```

### Identifying Encryption Mode Vulnerabilities

Detect ECB mode patterns (dangerous due to identical plaintext producing identical ciphertext):

```python
def detect_ecb_mode(ciphertext, block_size=16):
    """
    Detect ECB mode through repeated block pattern analysis
    ECB produces identical ciphertext for identical plaintext blocks
    """
    blocks = [ciphertext[i:i+block_size] for i in range(0, len(ciphertext), block_size)]
    
    block_counts = {}
    for block in blocks:
        block_hex = block.hex()
        block_counts[block_hex] = block_counts.get(block_hex, 0) + 1
    
    repeated_blocks = sum(1 for count in block_counts.values() if count > 1)
    total_blocks = len(blocks)
    
    repetition_ratio = repeated_blocks / total_blocks if total_blocks > 0 else 0
    
    print(f"Ciphertext analysis:")
    print(f"Total blocks: {total_blocks}")
    print(f"Repeated blocks: {repeated_blocks}")
    print(f"Repetition ratio: {repetition_ratio:.2%}")
    
    if repetition_ratio > 0.1:
        print("⚠ ECB mode likely (insecure - identical plaintext blocks produce identical ciphertext)")
        return True
    else:
        print("Likely using CBC, CTR, or other secure mode")
        return False

# Test with ECB (vulnerable)
from Crypto.Cipher import AES
key = b'0123456789abcdef'
plaintext = b'AAAAAAAAAAAAAAAA' * 4  # Repeated blocks
cipher = AES.new(key, AES.MODE_ECB)
ciphertext = cipher.encrypt(plaintext)

detect_ecb_mode(ciphertext)
```

## Key Derivation in Stego

Key derivation functions (KDFs) convert passwords into cryptographic keys suitable for encryption. They prevent dictionary attacks through computational cost and salting.

### PBKDF2 Key Derivation

Implement PBKDF2 for password-to-key conversion:

```python
import hashlib
import os

def derive_key_pbkdf2(password, salt=None, iterations=100000, key_length=32):
    """
    PBKDF2 key derivation
    password: user-provided password
    salt: random salt (generated if not provided)
    iterations: computational cost (higher = slower, more secure)
    key_length: output key length in bytes
    """
    if salt is None:
        salt = os.urandom(16)
    
    key = hashlib.pbkdf2_hmac(
        'sha256',
        password.encode(),
        salt,
        iterations,
        dklen=key_length
    )
    
    return salt, key

def verify_password_pbkdf2(password, stored_salt, stored_key, iterations=100000):
    """Verify password against stored salt and key"""
    _, derived_key = derive_key_pbkdf2(password, stored_salt, iterations)
    return derived_key == stored_key

# Usage
password = "user_password"
salt, key = derive_key_pbkdf2(password)

print(f"Salt: {salt.hex()}")
print(f"Derived key: {key.hex()}")

# Verification
if verify_password_pbkdf2(password, salt, key):
    print("✓ Password verified")
else:
    print("✗ Password incorrect")
```

### Argon2 Key Derivation

Use modern Argon2 for better security:

```bash
pip install argon2-cffi
```

```python
from argon2 import PasswordHasher
from argon2.exceptions import VerifyMismatchError

def derive_key_argon2(password, salt=None):
    """
    Argon2 key derivation (modern alternative to PBKDF2)
    """
    hasher = PasswordHasher()
    
    if salt is None:
        import os
        salt = os.urandom(16)
    
    # Argon2 produces hash directly
    hash_value = hasher.hash(password)
    return hash_value

def verify_password_argon2(password, hash_value):
    """Verify password against Argon2 hash"""
    hasher = PasswordHasher()
    try:
        hasher.verify(hash_value, password)
        return True
    except VerifyMismatchError:
        return False

# Usage
password = "secure_password"
hash_value = derive_key_argon2(password)

print(f"Hash: {hash_value}")

if verify_password_argon2(password, hash_value):
    print("✓ Password verified")
```

### Scrypt Key Derivation

Implement Scrypt for memory-hard key derivation:

```bash
pip install scrypt
```

```python
import scrypt
import os

def derive_key_scrypt(password, salt=None, n=2**14, r=8, p=1, key_length=32):
    """
    Scrypt key derivation (memory-hard, resistant to brute-force)
    n: CPU/memory cost parameter
    r: block size parameter
    p: parallelization parameter
    """
    if salt is None:
        salt = os.urandom(16)
    
    key = scrypt.hash(
        password.encode(),
        salt,
        N=n,
        r=r,
        p=p,
        buflen=key_length
    )
    
    return salt, key

# Usage
password = "ctf_password"
salt, key = derive_key_scrypt(password)

print(f"Salt: {salt.hex()}")
print(f"Derived key: {key.hex()}")
```

### Key Stretching for Weak Passwords

Mitigate weak passwords through computational delay:

```python
import hashlib
import time

def stretch_key(password, iterations=1000000):
    """
    Stretch password through repeated hashing
    Higher iterations = slower but more secure
    """
    key = password.encode()
    
    start = time.time()
    for _ in range(iterations):
        key = hashlib.sha256(key).digest()
    
    elapsed = time.time() - start
    
    print(f"Key stretching: {iterations} iterations in {elapsed:.2f}s")
    return key

# Usage
key = stretch_key("weak_password", iterations=100000)
print(f"Stretched key: {key.hex()}")
```

## Cipher Detection

Identifying the cipher used to encrypt data is essential for attacking encrypted payloads.

### Identifying Common Ciphers

Detect cipher type through ciphertext analysis:

```python
def identify_cipher(ciphertext):
    """
    Attempt to identify encryption cipher
    Based on block size, pattern, and entropy
    """
    length = len(ciphertext)
    
    # Block size analysis
    if length % 16 == 0:
        block_size = 16
        cipher_candidates = ['AES', 'Camellia', 'Serpent']
    elif length % 8 == 0:
        block_size = 8
        cipher_candidates = ['DES', '3DES', 'Blowfish', 'IDEA']
    else:
        cipher_candidates = ['Stream cipher (RC4, ChaCha, etc.)']
    
    # Entropy analysis
    entropy = calculate_entropy(ciphertext)
    if entropy > 7.5:
        print("High entropy - likely strong encryption")
    else:
        print("Medium entropy - possibly weak encryption or compression")
    
    # Pattern analysis
    blocks = [ciphertext[i:i+block_size] for i in range(0, min(len(ciphertext), 256), block_size)]
    unique_blocks = len(set(blocks))
    total_blocks = len(blocks)
    
    repetition_ratio = (total_blocks - unique_blocks) / total_blocks if total_blocks > 0 else 0
    
    print(f"\nCipher identification:")
    print(f"Likely block size: {block_size} bytes")
    print(f"Possible ciphers: {', '.join(cipher_candidates)}")
    print(f"Block repetition: {repetition_ratio:.2%}")
    
    if repetition_ratio > 0.1:
        print("⚠ Potential ECB mode (vulnerable)")
    
    return cipher_candidates

def calculate_entropy(data):
    import math
    if len(data) == 0:
        return 0
    byte_counts = {}
    for byte in data:
        byte_counts[byte] = byte_counts.get(byte, 0) + 1
    entropy = 0
    for count in byte_counts.values():
        p = count / len(data)
        entropy -= p * math.log2(p)
    return entropy

# Usage
identify_cipher(ciphertext)
```

### Breaking Simple Substitution Ciphers

Detect and break substitution-based encryption:

```python
import re
from collections import Counter

def frequency_analysis(ciphertext):
    """
    Perform frequency analysis on ciphertext
    Compare against English language frequencies
    """
    # English letter frequencies (approximate)
    english_freq = {
        'e': 0.127, 't': 0.091, 'a': 0.082, 'o': 0.075, 'i': 0.070,
        'n': 0.067, 's': 0.063, 'h': 0.061, 'r': 0.060, 'd': 0.043,
    }
    
    # Count frequencies in ciphertext
    letters = re.findall(r'[a-z]', ciphertext.lower())
    letter_counts = Counter(letters)
    
    total = len(letters)
    cipher_freq = {letter: count/total for letter, count in letter_counts.items()}
    
    print("Ciphertext frequency analysis:")
    print("Letter | Frequency | English avg")
    print("------- | --------- | -----------")
    
    for letter in sorted(cipher_freq.keys(), key=lambda x: cipher_freq[x], reverse=True)[:10]:
        freq = cipher_freq[letter]
        english_avg = english_freq.get(letter, 0)
        print(f"  {letter}   |  {freq:.3f}    |  {english_avg:.3f}")
    
    return cipher_freq

def caesar_cipher_break(ciphertext, key_space=26):
    """
    Break Caesar cipher through brute-force
    """
    print(f"Attempting Caesar cipher decryption ({key_space} keys):\n")
    
    for shift in range(key_space):
        decrypted = ''
        for char in ciphertext:
            if char.isalpha():
                base = ord('A') if char.isupper() else ord('a')
                decrypted += chr((ord(char) - base - shift) % 26 + base)
            else:
                decrypted += char
        
        # Check if decryption looks like English
        if ' ' in decrypted:
            words = decrypted.split()
            common_words = sum(1 for word in words if word.lower() in 
                             ['the', 'and', 'that', 'with', 'have', 'this', 'will'])
            
            if common_words > 0:
                print(f"Shift {shift}: {decrypted[:100]}")

def vigenere_cipher_analysis(ciphertext):
    """
    Analyze Vigenère cipher for key length using Kasiski examination
    """
    import re
    
    # Find repeated sequences
    sequences = {}
    for i in range(len(ciphertext) - 3):
        seq = ciphertext[i:i+3]
        if seq in sequences:
            sequences[seq].append(i)
        else:
            sequences[seq] = [i]
    
    # Calculate distances between repetitions
    distances = []
    for seq, positions in sequences.items():
        if len(positions) > 1:
            for i in range(len(positions) - 1):
                distances.append(positions[i+1] - positions[i])
    
    print("Kasiski examination results:")
    print(f"Found {len(distances)} repetition distances")
    
    if distances:
        # Find GCD of distances
        from math import gcd
        from functools import reduce
        key_length_candidates = reduce(gcd, distances)
        print(f"Likely key length: {key_length_candidates}")

# Usage
ciphertext = "THEQUICKBROWNFOX"
frequency_analysis(ciphertext)
caesar_cipher_break(ciphertext)
```

## Hash Verification

Hash functions verify data integrity and authenticate content. In CTF challenges, hash verification confirms correct decryption or solution.

### Common Hash Functions

Implement and verify various hash algorithms:

```python
import hashlib

def compute_hashes(data):
    """
    Compute multiple hash types for verification
    """
    if isinstance(data, str):
        data = data.encode()
    
    hashes = {
        'MD5': hashlib.md5(data).hexdigest(),
        'SHA1': hashlib.sha1(data).hexdigest(),
        'SHA256': hashlib.sha256(data).hexdigest(),
        'SHA512': hashlib.sha512(data).hexdigest(),
        'SHA3-256': hashlib.sha3_256(data).hexdigest(),
        'SHA3-512': hashlib.sha3_512(data).hexdigest(),
        'BLAKE2b': hashlib.blake2b(data).hexdigest(),
        'BLAKE2s': hashlib.blake2s(data).hexdigest(),
    }
    
    return hashes

def verify_hash(data, hash_value, hash_type='SHA256'):
    """
    Verify data against provided hash
    """
    if isinstance(data, str):
        data = data.encode()
    
    hash_obj = getattr(hashlib, hash_type.lower())(data)
    computed_hash = hash_obj.hexdigest()
    
    return computed_hash.lower() == hash_value.lower()

# Usage
message = "flag{verification}"
hashes = compute_hashes(message)

for hash_type, hash_value in hashes.items():
    print(f"{hash_type}: {hash_value}")

# Verification
if verify_hash(message, hashes['SHA256'], 'SHA256'):
    print("✓ SHA256 hash verified")
```

### Hash Collision Detection

Identify hash collisions in CTF challenges:

```python
import hashlib
from collections import defaultdict

def find_hash_collisions(data_list, hash_type='SHA256'):
    """
    Find hash collisions in a list of data
    """
    hash_map = defaultdict(list)
    
    for data in data_list:
        if isinstance(data, str):
            data = data.encode()
        
        hash_obj = getattr(hashlib, hash_type.lower())(data)
        hash_value = hash_obj.hexdigest()
        
        hash_map[hash_value].append(data)
    
    collisions = {h: items for h, items in hash_map.items() if len(items) > 1}
    
    print(f"Hash collision analysis ({hash_type}):")
    print(f"Total items: {len(data_list)}")
    print(f"Unique hashes: {len(hash_map)}")
    print(f"Collisions found: {len(collisions)}")
    
    for hash_value, items in collisions.items():
        print(f"\n{hash_value}:")
        for item in items:
            print(f"  {item}")
    
    return collisions

# Usage
data_samples = [b"test1", b"test2", b"test1", b"different"]
find_hash_collisions(data_samples)
```

### Rainbow Table Attacks

Reverse hash lookups using precomputed tables:

```python
import hashlib

def build_rainbow_table(wordlist, hash_type='MD5'):
    """
    Build rainbow table from wordlist
    hash -> plaintext mapping
    """
    table = {}
    
    with open(wordlist, 'r') as f:
        for word in f:
            word = word.strip()
            hash_obj = getattr(hashlib, hash_type.lower())(word.encode())
            hash_value = hash_obj.hexdigest()
            
            if hash_value not in table:
                table[hash_value] = word
    
    print(f"Rainbow table built: {len(table)} entries")
    return table

def lookup_hash_rainbow(hash_value, rainbow_table):
    """
    Reverse lookup hash in rainbow table
    """
    if hash_value in rainbow_table:
        return rainbow_table[hash_value]
    return None

# Usage - efficient for CTF with common wordlists
# table = build_rainbow_table('/usr/share/wordlists/rockyou.txt', 'MD5')
# plaintext = lookup_hash_rainbow('5d41402abc4b2a76b9719d911017c592', table)
# print(f"Found: {plaintext}")
```

### HMAC Verification

Verify data authenticity using HMAC:

```python
import hashlib
import hmac

def compute_hmac(data, key, hash_type='sha256'):
    """
    Compute HMAC for data integrity verification
    """
    if isinstance(data, str):
        data = data.encode()
    if isinstance(key, str):
        key = key.encode()
    
    h = hmac.new(key, data, getattr(hashlib, hash_type))
    return h.hexdigest()

def verify_hmac(data, key, provided_hmac, hash_type='sha256'):
    """
    Verify HMAC against provided value
    """
    computed_hmac = compute_hmac(data, key, hash_type)
    
    # Use constant-time comparison to prevent timing attacks
    return hmac.compare_digest(computed_hmac, provided_hmac)

# Usage
message = b"confidential data"
key = b"secret_key"

mac = compute_hmac(message, key)
print(f"HMAC: {mac}")

if verify_hmac(message, key, mac):
    print("✓ HMAC verified - data integrity confirmed")
```

### Hash-Based Proof of Work

Implement hash-based challenges for CTF:

```python
import hashlib

def find_hash_with_prefix(prefix, target_difficulty=4):
    """
    Find data producing hash with specific prefix
    (Proof-of-work style challenge)
    """
    counter = 0
    
    while True:
        data = f"{prefix}{counter}".encode()
        hash_value = hashlib.sha256(data).hexdigest()
        
        if hash_value.startswith('0' * target_difficulty): print(f"Found: {prefix}{counter}") print(f"Hash: {hash_value}") print(f"Attempts: {counter + 1}") return counter, hash_value

    counter += 1
    
    if counter % 100000 == 0:
        print(f"Attempts: {counter}", end='\r')

# Usage

find_hash_with_prefix("flag", target_difficulty=4)
````

### Salted Hash Verification

Verify passwords with salted hashes:

```python
import hashlib
import os

def hash_password_salted(password, salt=None):
    """
    Hash password with salt for secure storage
    """
    if salt is None:
        salt = os.urandom(16)
    
    if isinstance(password, str):
        password = password.encode()
    
    hash_obj = hashlib.pbkdf2_hmac('sha256', password, salt, 100000)
    return salt + hash_obj

def verify_password_salted(password, stored_hash):
    """
    Verify password against salted hash
    """
    salt = stored_hash[:16]
    stored_key = stored_hash[16:]
    
    if isinstance(password, str):
        password = password.encode()
    
    computed_key = hashlib.pbkdf2_hmac('sha256', password, salt, 100000)
    
    return hmac.compare_digest(computed_key, stored_key)

# Usage
import hmac

password = "user_password"
stored_hash = hash_password_salted(password)

print(f"Stored hash: {stored_hash.hex()}")

if verify_password_salted(password, stored_hash):
    print("✓ Password verified")
else:
    print("✗ Password incorrect")
````

### Hash-Based Content Verification

Verify file integrity through hash chains:

```python
import hashlib
import json

def create_hash_chain(files):
    """
    Create hash chain for multiple files
    Each hash includes previous hash for integrity
    """
    chain = []
    previous_hash = hashlib.sha256(b"").hexdigest()
    
    for filename in files:
        with open(filename, 'rb') as f:
            file_data = f.read()
        
        # Combine previous hash with current file
        combined = previous_hash.encode() + file_data
        current_hash = hashlib.sha256(combined).hexdigest()
        
        chain.append({
            'filename': filename,
            'file_hash': hashlib.sha256(file_data).hexdigest(),
            'chain_hash': current_hash,
            'previous_hash': previous_hash
        })
        
        previous_hash = current_hash
    
    return chain

def verify_hash_chain(chain_data):
    """
    Verify integrity of hash chain
    """
    previous_hash = hashlib.sha256(b"").hexdigest()
    
    for entry in chain_data:
        filename = entry['filename']
        
        with open(filename, 'rb') as f:
            file_data = f.read()
        
        # Verify file hash
        computed_file_hash = hashlib.sha256(file_data).hexdigest()
        if computed_file_hash != entry['file_hash']:
            print(f"✗ {filename} file hash mismatch")
            return False
        
        # Verify chain hash
        combined = previous_hash.encode() + file_data
        computed_chain_hash = hashlib.sha256(combined).hexdigest()
        if computed_chain_hash != entry['chain_hash']:
            print(f"✗ {filename} chain hash mismatch")
            return False
        
        previous_hash = entry['chain_hash']
    
    print("✓ Hash chain verified")
    return True

# Usage
chain = create_hash_chain(['file1.txt', 'file2.txt'])
print(json.dumps(chain, indent=2))

verify_hash_chain(chain)
```

### Digital Signature Verification

Verify authenticity using public-key signatures:

```bash
pip install cryptography
```

```python
from cryptography.hazmat.primitives import hashes, serialization
from cryptography.hazmat.primitives.asymmetric import rsa, padding
from cryptography.hazmat.backends import default_backend

def generate_rsa_keypair():
    """Generate RSA key pair for signing"""
    private_key = rsa.generate_private_key(
        public_exponent=65537,
        key_size=2048,
        backend=default_backend()
    )
    public_key = private_key.public_key()
    return private_key, public_key

def sign_data(data, private_key):
    """Sign data with private key"""
    if isinstance(data, str):
        data = data.encode()
    
    signature = private_key.sign(
        data,
        padding.PSS(
            mgf=padding.MGF1(hashes.SHA256()),
            salt_length=padding.PSS.MAX_LENGTH
        ),
        hashes.SHA256()
    )
    return signature

def verify_signature(data, signature, public_key):
    """Verify signature with public key"""
    if isinstance(data, str):
        data = data.encode()
    
    try:
        public_key.verify(
            signature,
            data,
            padding.PSS(
                mgf=padding.MGF1(hashes.SHA256()),
                salt_length=padding.PSS.MAX_LENGTH
            ),
            hashes.SHA256()
        )
        return True
    except:
        return False

# Usage
private_key, public_key = generate_rsa_keypair()

message = b"Authentic message"
signature = sign_data(message, private_key)

if verify_signature(message, signature, public_key):
    print("✓ Signature verified - message is authentic")
else:
    print("✗ Signature verification failed")
```

---

# Steganalysis Tools (Kali Linux)

## General Purpose Tools

### binwalk

Binwalk is a firmware analysis tool that automatically scans files for embedded signatures and extracts components. It's essential for identifying hidden data and nested file structures within binary files.

#### Basic Scanning and Signature Recognition

Scan a file for known signatures:

```bash
binwalk target.bin
```

This produces output showing file types, offsets, descriptions, and validation status. Each result includes the byte offset where the signature was detected.

For more detailed analysis with extraction:

```bash
binwalk -e target.bin
```

This creates a directory (typically `_target.bin.extracted`) containing all identified components. Binwalk automatically recurses into nested archives.

#### Entropy Analysis

Visualize file entropy to detect encryption or compression:

```bash
binwalk -E target.bin
```

High entropy (0.9+) indicates encryption, compression, or randomness. Low entropy suggests plaintext or structured data. The output includes an ASCII graph showing entropy distribution across the file.

For more detailed entropy visualization:

```bash
binwalk -E -B target.bin
```

The `-B` flag performs a better entropy analysis using larger data blocks.

#### Custom Signature Scanning

Binwalk uses signature definitions from configuration files. View current signatures:

```bash
binwalk -l
```

Create custom signatures in `~/.config/binwalk/binwalk.conf`:

```
[Signature]
magic = 48 65 6c 6c 6f
description = Custom Header
```

Use the custom signature:

```bash
binwalk -C ~/.config/binwalk/binwalk.conf target.bin
```

#### Extracting Specific Offsets

If binwalk identifies data at a specific offset, extract just that section:

```bash
binwalk target.bin | grep -i "offset"
dd if=target.bin of=extracted.bin bs=1 skip=[offset]
```

For more precise extraction with binwalk's built-in method:

```bash
binwalk -e -D '=bin' target.bin
```

The `-D` flag specifies extraction plugins; `=bin` extracts all binary files.

#### Handling Encrypted or Compressed Sections

Binwalk may fail to identify encrypted data. Use entropy analysis to pinpoint suspicious sections:

```bash
binwalk -E target.bin -B
```

Extract high-entropy sections manually:

```bash
dd if=target.bin of=suspicious.bin bs=1 skip=[start_offset] count=[size]
file suspicious.bin
hexdump -C suspicious.bin | head
```

#### Integration with Other Tools

Combine binwalk with `strings` to identify patterns within extracted files:

```bash
binwalk -e target.bin
strings _target.bin.extracted/*/* | grep -i "flag\|password\|hint"
```

For systematic analysis of all extracted components:

```bash
binwalk -e target.bin
find _target.bin.extracted -type f -exec file {} \;
```

### foremost

Foremost is a file carving tool that recovers files from unstructured data by identifying file signatures. It's particularly useful for extracting files from disk images or memory dumps.

#### Basic File Carving

Carve files using the default configuration:

```bash
foremost -i target.bin -o output_dir
```

The `-i` flag specifies the input file, and `-o` designates the output directory. Foremost creates subdirectories for each file type found (e.g., `jpg/`, `png/`, `zip/`).

#### Specifying File Types

Restrict carving to specific file types:

```bash
foremost -i target.bin -o output_dir -t jpg,png,zip
```

Use `-t` followed by a comma-separated list of extensions. View supported types:

```bash
foremost -h | grep -A 20 "Supported File Types"
```

Or check the configuration file:

```bash
cat /etc/foremost.conf | grep -v "^#" | grep -v "^$"
```

#### Custom Configuration

Create a custom foremost configuration file to define new file types. Modify `/etc/foremost.conf` or create a local copy:

```bash
cp /etc/foremost.conf custom_foremost.conf
```

Add custom signatures:

```
jpg    y    200    ÿØÿà    ÿ\x00\x10JFIF    ÿÙ
```

Format: `extension`, `case_sensitive`, `max_size`, `header_signature`, `footer_signature`.

Use the custom configuration:

```bash
foremost -i target.bin -o output_dir -c custom_foremost.conf
```

#### Quiet Mode and Verbose Output

Run foremost silently:

```bash
foremost -i target.bin -o output_dir -q
```

For detailed output:

```bash
foremost -i target.bin -o output_dir -v
```

#### Advanced Carving Options

Resume a previous carving session:

```bash
foremost -i target.bin -o output_dir -s [start_offset]
```

The `-s` flag specifies the byte offset where carving begins, useful for skipping known sections.

Limit carving to a specific number of files per type:

```bash
foremost -i target.bin -o output_dir -T 10
```

This extracts a maximum of 10 files per type, useful for large disk images where thousands of fragmented files exist.

#### Analyzing Carving Results

After carving, examine extracted files systematically:

```bash
find output_dir -type f -exec file {} \;
find output_dir -type f -exec ls -lh {} \;
```

Check for false positives by verifying file integrity:

```bash
for file in output_dir/zip/*.zip; do
    if unzip -t "$file" > /dev/null 2>&1; then
        echo "Valid: $file"
    else
        echo "Invalid: $file"
    fi
done
```

### steghide

Steghide is a steganography tool that hides data within image or audio files. It's commonly used in CTF challenges to embed flags or messages.

#### Embedding Data

Hide a file within an image:

```bash
steghide embed -cf cover.jpg -ef secret.txt -sf stego.jpg
```

Parameters: `-cf` (cover file), `-ef` (embed file), `-sf` (stego file output). Steghide prompts for a passphrase interactively.

Provide the passphrase non-interactively:

```bash
echo "passphrase" | steghide embed -cf cover.jpg -ef secret.txt -sf stego.jpg -p "passphrase"
```

Embed without a passphrase:

```bash
steghide embed -cf cover.jpg -ef secret.txt -sf stego.jpg -p ""
```

#### Extracting Hidden Data

Extract embedded data:

```bash
steghide extract -sf stego.jpg -xf extracted.txt
```

Parameters: `-sf` (stego file), `-xf` (extract file). Steghide prompts for the passphrase.

Provide the passphrase non-interactively:

```bash
steghide extract -sf stego.jpg -xf extracted.txt -p "passphrase"
```

Extract without specifying an output filename (uses the original embedded filename):

```bash
steghide extract -sf stego.jpg -p "passphrase"
```

#### Information Gathering

Check if a file contains steghide-embedded data:

```bash
steghide info stego.jpg
```

This command indicates whether data is embedded without extracting it. [Inference] If embedding fails due to capacity constraints, steghide reports the maximum embeddable file size.

#### Supported File Formats

Steghide supports embedding in JPEG, BMP, WAV, and AU files. Verify compatibility:

```bash
file cover.jpg
steghide info cover.jpg
```

#### Brute-Force Passphrase Attack

Use `stegseek` (detailed below) to attempt passphrase recovery:

```bash
stegseek --crack stego.jpg wordlist.txt
```

Alternatively, create a custom brute-force script:

```bash
#!/bin/bash
while IFS= read -r pass; do
    if steghide extract -sf stego.jpg -xf extracted.txt -p "$pass" 2>/dev/null; then
        echo "Password found: $pass"
        cat extracted.txt
        break
    fi
done < wordlist.txt
```

### stegseek

Stegseek is a fast steganography brute-force tool designed specifically for cracking steghide-protected files. It significantly outperforms manual brute-force attempts.

#### Basic Usage

Attempt to crack a steghide-embedded file:

```bash
stegseek --crack stego.jpg wordlist.txt
```

Stegseek iterates through the wordlist, attempting each passphrase. Successful extraction outputs the recovered file and passphrase.

#### Specifying Output Directory

Direct extracted files to a custom location:

```bash
stegseek --crack stego.jpg wordlist.txt -o output_directory
```

#### Multiple Wordlists

Process multiple wordlists sequentially:

```bash
stegseek --crack stego.jpg wordlist1.txt wordlist2.txt wordlist3.txt
```

#### Verbose Output

Display detailed progress information:

```bash
stegseek --crack stego.jpg wordlist.txt -v
```

This shows each attempted passphrase and the status of extraction attempts.

#### Testing for Embedded Data Without Cracking

Check if stego-capable data exists within a file:

```bash
stegseek stego.jpg
```

Running stegseek without the `--crack` flag performs a quick check.

#### Performance Optimization

Stegseek uses optimized algorithms but can be further accelerated on multi-core systems. The tool automatically uses available CPU threads. Monitor resource usage:

```bash
stegseek --crack stego.jpg wordlist.txt & monitor_pid=$!
top -p $monitor_pid
```

#### Extracting Without Cracking

If the passphrase is known, extract directly using steghide rather than stegseek:

```bash
steghide extract -sf stego.jpg -p "known_passphrase"
```

#### Common Wordlists for CTF

Use common CTF wordlists:

```bash
stegseek --crack stego.jpg /usr/share/wordlists/rockyou.txt
```

If rockyou.txt is unavailable, download it:

```bash
wget https://github.com/danielmiessler/SecLists/raw/master/Passwords/Leaked-Databases/rockyou.txt.tar.gz
tar -xzf rockyou.txt.tar.gz
```

### outguess

Outguess is a steganography tool that uses statistical analysis to hide data in image files. It's less commonly encountered than steghide but appears in some CTF scenarios.

#### Embedding Data

Hide data within an image:

```bash
outguess -d secret.txt -k "passphrase" cover.jpg stego.jpg
```

Parameters: `-d` (data file), `-k` (key/passphrase), input (cover file), output (stego file).

#### Extracting Hidden Data

Extract embedded data:

```bash
outguess -r -k "passphrase" stego.jpg extracted.txt
```

The `-r` flag indicates extraction mode.

#### Analyzing Capacity

Check how much data can be embedded in an image:

```bash
outguess -r stego.jpg
```

This command attempts extraction without a key. If extraction fails, it may indicate either no data is embedded or the key is incorrect.

#### Key Management

Outguess keys support longer passphrases than steghide. Test various key lengths:

```bash
for key in "" "short" "medium_length_key" "very_long_passphrase_with_special_characters"; do
    outguess -r -k "$key" stego.jpg extracted.txt && echo "Success with key: $key"
done
```

#### Brute-Force Attack

Unlike steghide, no dedicated brute-force tool exists for outguess. Create a custom script:

```bash
#!/bin/bash
while IFS= read -r pass; do
    if outguess -r -k "$pass" stego.jpg extracted.txt 2>/dev/null; then
        if [ -s extracted.txt ]; then
            echo "Password found: $pass"
            cat extracted.txt
            break
        fi
    fi
done < wordlist.txt
```

#### Comparing outguess to steghide

[Inference] Outguess uses pseudo-random number generation to determine which bits to modify, potentially offering better security against detection. However, steghide is more widely used in CTF challenges. If steghide extraction fails on a suspicious image, attempt outguess extraction.

### stegsnow

Stegsnow is a steganography tool that hides data within ASCII text files by appending whitespace characters (spaces and tabs). It's particularly useful for embedded messages in text-based CTF challenges.

#### Embedding Data in Text

Hide a message within a text file:

```bash
stegsnow -C -m "Secret message" -p "passphrase" input.txt output.txt
```

Parameters: `-C` (compression enabled), `-m` (message), `-p` (passphrase), input/output files.

Alternatively, embed a file:

```bash
stegsnow -C -f secret.txt -p "passphrase" input.txt output.txt
```

Use `-f` to embed an entire file instead of a message string.

#### Extracting Hidden Data

Recover hidden data from a stegsnow file:

```bash
stegsnow -C -p "passphrase" stego.txt
```

Output is displayed to stdout. [Inference] If the passphrase is incorrect, stegsnow may output garbage or fail silently.

#### No Passphrase

Extract data without a passphrase:

```bash
stegsnow -C stego.txt
```

#### Identifying Stegsnow-Modified Files

Stegsnow uses trailing whitespace, invisible in standard text editors. Detect it:

```bash
cat -A stego.txt
```

The `-A` flag displays whitespace characters: `^I` for tabs and `$` at the end of lines (trailing spaces appear as spaces before `$`).

Alternatively, use `od`:

```bash
od -c stego.txt | tail -20
```

This shows all characters including spaces and tabs.

#### Binary Data Embedding

Stegsnow supports embedding binary data by using the `-b` flag:

```bash
stegsnow -C -b -f secret.bin -p "passphrase" input.txt output.txt
```

Extract binary data:

```bash
stegsnow -C -b -p "passphrase" stego.txt > extracted.bin
```

#### Limitations

Stegsnow requires visible ASCII text as the cover. The tool cannot embed in binary files or images. Additionally, the capacity is limited based on the number of whitespace opportunities in the text.

#### Brute-Force Passphrase Attack

Create a custom brute-force script:

```bash
#!/bin/bash
while IFS= read -r pass; do
    result=$(stegsnow -C -p "$pass" stego.txt 2>/dev/null)
    if [ -n "$result" ] && [ "$result" != "" ]; then
        echo "Password found: $pass"
        echo "Message: $result"
        break
    fi
done < wordlist.txt
```

### exiftool

Exiftool reads and writes metadata (EXIF, IPTC, XMP) in image and multimedia files. It's essential for extracting embedded information from files submitted in CTF challenges.

#### Viewing Metadata

Display all metadata from an image:

```bash
exiftool image.jpg
```

This produces comprehensive output including camera settings, GPS coordinates, timestamps, and custom fields.

#### Extracting Specific Tags

Query specific metadata fields:

```bash
exiftool -Creator image.jpg
exiftool -GPSLatitude image.jpg
exiftool -Make image.jpg
```

Use the tag name (as shown in full output) to extract specific values.

#### Searching for Custom Fields

Hidden data often appears in comment fields or custom EXIF tags:

```bash
exiftool -Comment image.jpg
exiftool -UserComment image.jpg
exiftool -ImageDescription image.jpg
```

#### Bulk Metadata Extraction

Extract metadata from multiple files:

```bash
exiftool *.jpg
```

For more structured output:

```bash
exiftool -csv *.jpg > metadata.csv
```

The `-csv` flag outputs results in comma-separated format, useful for analysis in spreadsheets.

#### JSON Output

Export metadata as JSON:

```bash
exiftool -json image.jpg > metadata.json
```

Parse specific values from JSON:

```bash
exiftool -json image.jpg | jq '.[].Comment'
```

#### Removing Metadata

Delete all EXIF data:

```bash
exiftool -all= image.jpg
```

This creates a copy with metadata removed. The original file is backed up as `image.jpg_original`.

To overwrite the original:

```bash
exiftool -overwrite_original -all= image.jpg
```

#### Writing Metadata

Inject custom metadata:

```bash
exiftool -Comment="Hidden message" -o modified.jpg image.jpg
```

#### Detecting Suspicious Metadata

Compare metadata across multiple files to identify inconsistencies:

```bash
exiftool -T -FileName -Make -Model -DateTime *.jpg > analysis.txt
```

The `-T` flag outputs tab-separated values for easier comparison.

#### Extracting Binary Data from Metadata

Some metadata fields can contain binary data. Extract and examine:

```bash
exiftool -b -ThumbnailImage image.jpg > thumbnail.bin
file thumbnail.bin
```

The `-b` flag outputs binary data without text formatting.

### strings

The `strings` command extracts readable ASCII and Unicode strings from binary files. It's fundamental for identifying embedded text, URLs, paths, and other readable content.

#### Basic String Extraction

Extract all readable strings:

```bash
strings target.bin
```

This outputs all sequences of printable characters (minimum 4 bytes by default).

#### Adjusting Minimum String Length

Change the minimum string length:

```bash
strings -n 3 target.bin
```

Shorter strings (3+ bytes) produce more results but increase false positives.

For longer strings only:

```bash
strings -n 20 target.bin
```

This filters out noise and focuses on substantial text.

#### Unicode String Detection

Include Unicode strings:

```bash
strings -e S target.bin
```

Encoding options: `S` (Unicode 16-bit little-endian), `B` (Unicode 16-bit big-endian), `l` (Unicode 32-bit little-endian), `b` (Unicode 32-bit big-endian).

#### Searching for Specific Patterns

Combine strings with `grep` to locate keywords:

```bash
strings target.bin | grep -i "flag\|password\|secret\|admin"
```

For case-sensitive searches:

```bash
strings target.bin | grep "FLAG\|PASSWORD"
```

#### Offset Information

Display the byte offset of each string:

```bash
strings -t x target.bin | head -20
```

The `-t x` flag shows hexadecimal offsets, useful for locating strings within the file.

Use decimal offsets:

```bash
strings -t d target.bin
```

#### Filtering by Regular Expression

Extract only strings matching a pattern:

```bash
strings target.bin | grep -E "^[A-Z0-9]{32}$"
```

This finds potential MD5 hashes (32 hexadecimal characters).

For URLs:

```bash
strings target.bin | grep -E "https?://"
```

#### Radare2 Integration

Analyze strings within radare2:

```bash
r2 -q target.bin -c "fs strings" -c "f"
```

This lists all detected strings within the radare2 framework.

#### Performance on Large Files

For very large files, use `strings` with limited output:

```bash
strings target.bin | head -100
```

Or redirect to a file for offline analysis:

```bash
strings target.bin > strings_output.txt
wc -l strings_output.txt
```

### xxd/hexdump

These hex viewers display file contents in hexadecimal and ASCII format, essential for identifying file signatures, analyzing binary structures, and spotting embedded data.

#### Basic Hexdump

Display file contents in hex and ASCII:

```bash
hexdump -C target.bin | head -50
```

The `-C` flag uses canonical format: offset, hex, and ASCII. Output lines show 16 bytes per line.

#### Using xxd

Alternative hex viewer with similar functionality:

```bash
xxd target.bin | head -50
```

Display fewer bytes per line:

```bash
xxd -c 8 target.bin
```

The `-c` flag specifies bytes per line (default 16).

#### Searching for Signatures

Find specific byte sequences:

```bash
hexdump -C target.bin | grep "504b"
```

This locates ZIP file signatures (`PK`).

Using xxd with grep:

```bash
xxd target.bin | grep "7a bc af"
```

This searches for 7Z file signatures.

#### Large File Analysis

Display a specific range of a large file:

```bash
hexdump -C -n 512 -s 1024 target.bin
```

Parameters: `-n` (number of bytes to display), `-s` (skip bytes). This shows 512 bytes starting at byte offset 1024.

Using xxd for the same operation:

```bash
xxd -l 512 -s 1024 target.bin
```

#### Exporting Hex for Modification

Export hex for manual editing:

```bash
xxd target.bin > target.hex
# Edit target.hex with a text editor
xxd -r target.hex > modified.bin
```

The `-r` flag reverses hexdump, converting hex back to binary.

#### Comparing Binary Files

Highlight differences between two files:

```bash
diff <(xxd file1.bin) <(xxd file2.bin)
```

Or:

```bash
diff <(hexdump -C file1.bin) <(hexdump -C file2.bin)
```

#### Identifying File Boundaries

Use xxd to identify where files are concatenated:

```bash
xxd target.bin | grep -E "504b|504b0102|52 61 72|37 7a"
```

This shows offsets of archive signatures (ZIP, RAR, 7Z).

#### Converting Hex to Binary

Extract hex strings and convert to binary:

```bash
echo "48656c6c6f" | xxd -r -p > output.bin
```

The `-r -p` flags interpret plain hex (no formatting).

#### Visualizing Patterns

Look for repeated patterns in hex:

```bash
xxd target.bin | awk '{print $2,$3,$4,$5}' | sort | uniq -c | sort -rn | head -20
```

This shows the most frequently occurring 4-byte sequences.

### file

The `file` command identifies file types by analyzing magic bytes and structure. It's crucial for determining the format of extracted or unknown files.

#### Basic File Type Detection

Identify a file's type:

```bash
file target.bin
```

Output includes format, compression, encoding, and other relevant properties.

#### Detailed Analysis

Request more specific information:

```bash
file -v target.bin
```

The `-v` flag provides verbose output with additional details.

#### Analyzing Multiple Files

Check a directory of files:

```bash
file *
```

For recursive analysis:

```bash
file -r directory/
```

#### Custom Magic Database

Use a custom magic file for non-standard formats:

```bash
file -m custom_magic.mgc target.bin
```

Create custom magic definitions in `custom_magic`:

```
0    string    CUSTOM    Custom Archive Format
```

Compile to binary format:

```bash
file -C -m custom_magic
```

#### Mime Type Output

Get MIME type instead of human-readable description:

```bash
file -b --mime-type target.bin
```

Output: `application/x-zip-compressed`, `image/jpeg`, etc.

#### Matching Against Specific Patterns

Check if a file matches a specific type without full analysis:

```bash
file target.bin | grep -q "JPEG" && echo "Is JPEG"
```

#### Detecting Polyglot Files

Polyglot files combine multiple formats. `file` may identify only the first format:

```bash
file target.bin
```

If the output seems incomplete, examine the file manually:

```bash
hexdump -C target.bin | head -20
tail -c 1024 target.bin | hexdump -C
```

#### Scripting with file

Automate file type detection in scripts:

```bash
#!/bin/bash
for file in *; do
    filetype=$(file -b "$file")
    case "$filetype" in
        *ZIP*) unzip "$file" ;;
        *RAR*) unrar x "$file" ;;
        *7z*) 7z x "$file" ;;
        *JPEG*) exiftool "$file" ;;
    esac
done
```

#### Combined Analysis Workflow

Integrate `file` with other tools for comprehensive analysis:

```bash
#!/bin/bash
target="$1"
echo "=== File Type ==="
file "$target"
echo -e "\n=== Magic Bytes ==="
hexdump -C "$target" | head -5
echo -e "\n=== Strings ==="
strings "$target" | head -10
echo -e "\n=== Metadata (if image) ==="
exiftool "$target" 2>/dev/null | head -10
```

---

## Image-Specific Tools

### zsteg

`zsteg` is a command-line steganography detection tool specifically designed for PNG and BMP images. It automates detection of LSB (Least Significant Bit) steganography, zlib-compressed data, and other common PNG embedding techniques. The tool excels at rapid screening and extraction without requiring manual analysis.

**Installation and Initial Setup**

Install via Ruby gems on Kali Linux:

```bash
sudo apt-get install zsteg
# Or via gem if apt package unavailable
gem install zsteg
```

Verify installation:

```bash
zsteg --version
zsteg --help
```

**Basic LSB Detection and Extraction**

Scan a PNG for standard LSB patterns:

```bash
zsteg target.png
```

This produces output indicating detected steganographic techniques, bit planes, and entropy levels. Output format shows:

```
b1,r,lsb,xy         "text content here"
b2,rgb,lsb,xy       [no useful text]
b4,rgba,lsb,xy      "FLAG{...}"
```

The notation means: bit plane (b1-b8), color channel (r/g/b/rgb/rgba), technique (lsb), and order (xy/yx). Extract specific channels:

```bash
zsteg target.png -c rb
```

**Advanced Detection Parameters**

Enable verbose output to see entropy analysis and all candidate detections:

```bash
zsteg target.png -v
```

Limit detection to specific bit planes (faster for targeted analysis):

```bash
zsteg target.png -b 1,2
```

Specify minimum text length to reduce false positives:

```bash
zsteg target.png -l 8
```

**Extracting Data by Channel and Bit Plane**

Extract data from red channel, least significant bit:

```bash
zsteg target.png -c r -b 1 -o extracted_r_b1.bin
```

Extract combined RGB channels:

```bash
zsteg target.png -c rgb -b 1 -o extracted_rgb_b1.bin
```

Extract alpha channel specifically:

```bash
zsteg target.png -c a -b 1 -o extracted_alpha.bin
```

**Handling Compressed and Encoded Data**

`zsteg` automatically detects zlib compression in extracted data:

```bash
zsteg target.png
# Output may show: "zlib compressed"
```

Extract and decompress automatically by saving output and decompressing:

```bash
zsteg target.png -c rgb -b 1 -o compressed.bin
zlib-flate -uncompress < compressed.bin > decompressed.bin
strings decompressed.bin
```

Or use Python:

```python
import zlib
with open('compressed.bin', 'rb') as f:
    compressed = f.read()
    decompressed = zlib.decompress(compressed)
    print(decompressed.decode('utf-8', errors='ignore'))
```

**BMP-Specific Analysis**

`zsteg` handles BMP files with identical syntax:

```bash
zsteg target.bmp
zsteg target.bmp -c all -b 1
```

BMP files often contain more steganographic data due to larger bit depths and fewer compression restrictions than PNG.

**Performance Optimization**

For large images or rapid scanning of multiple files:

```bash
zsteg target.png --fast
```

Batch processing multiple images:

```bash
for img in *.png; do
    echo "=== $img ==="
    zsteg "$img" -l 12 | head -20
done
```

**[Unverified]** `zsteg` may not detect steganography using non-standard LSB patterns or advanced embedding techniques like spread-spectrum or frequency-domain modifications.

### stegsolve

`stegsolve` is a graphical Java application providing interactive pixel-level image analysis. It enables manipulation of color planes, bit planes, and frame extraction, making it essential for complex image steganography scenarios requiring visual inspection and manual data recovery.

**Installation and Launch**

Download the JAR file or install via Kali repositories:

```bash
sudo apt-get install stegsolve
stegsolve.sh
# Or direct JAR execution
java -jar stegsolve.jar
```

**Color Plane Decomposition**

After loading an image, access plane analysis via the menu: `Analyze → Color Spaces`. Cycle through different color models:

- **Red, Green, Blue (RGB):** Individual color channels
- **Cyan, Magenta, Yellow, Black (CMYK):** Print color space
- **Hue, Saturation, Value (HSV):** Perceptual color space
- **YCbCr:** Luminance and chrominance separation

Navigate planes with arrow buttons or keyboard shortcuts. Hidden data often becomes visible when viewing specific color planes or when planes are inverted.

**Bit Plane Analysis**

Access via `Analyze → Data Extract`. The bit plane viewer shows individual bit layers from 0 (LSB) through 7 (MSB):

```
Bit 0 (LSB):  [image showing least significant bit pattern]
Bit 1:        [next bit layer]
...
Bit 7 (MSB):  [most significant bit layer]
```

Visually inspect each plane for patterns, text, or structured data. Planes with repetitive patterns or recognizable shapes indicate embedded content.

**Frame Extraction and Animation**

For animated GIFs or multi-frame images, extract individual frames:

1. Load the image in stegsolve
2. Navigate to `Analyze → Frame Browser`
3. Cycle through frames using navigation controls
4. Export individual frames or extract combined animation data

**Pixel Value Analysis**

Inspect exact RGB values of selected pixels:

1. Enable `Tools → Values`
2. Click pixels to display their RGB values in decimal and hexadecimal
3. Look for suspicious patterns or values that deviate from expected image content

**Histogram and Statistical Analysis**

Access histogram visualization via `Analyze → Histogram`:

```
Red Channel:   [histogram showing distribution]
Green Channel: [distribution]
Blue Channel:  [distribution]
```

Uniform or bimodal distributions may indicate steganographic modification, as natural images typically show specific expected distributions.

**LSB Extraction Workflow**

Manual LSB extraction using stegsolve:

1. Open image
2. Navigate `Analyze → Data Extract`
3. Select bit plane 0 (LSB)
4. Choose "Row Order" or "Bit-Plane Order"
5. Export as binary file

Process exported binary:

```bash
hexdump -C extracted_lsb.bin | head -50
strings extracted_lsb.bin
file extracted_lsb.bin
```

**Data Carving from Extracted Planes**

After extracting bit planes, carve embedded files:

```bash
# Export all planes to binary
# In stegsolve: Data Extract → Save Bit Planes

# Analyze combined data for file signatures
hexdump -C bitplane_output.bin | grep -E "ff d8|89 50|50 4b"

# Extract files at identified offsets
dd if=bitplane_output.bin bs=1 skip=4096 count=100000 of=recovered.zip
```

**Advanced Color Space Manipulation**

Invert colors or adjust levels to reveal hidden patterns:

1. Load image
2. `Tools → Brute Force`
3. Cycle through XOR operations, inversions, and transformations
4. Export frames showing hidden data

**Keyboard Shortcuts for Efficiency**

- **Arrow keys:** Navigate bit planes or color channels
- **< >:** Previous/next frame in multi-frame images
- **Space:** Cycle through analysis modes
- **Export button:** Save current view

### pngcheck

`pngcheck` is a command-line utility validating PNG file structure and detecting corruption or anomalies. It reads PNG specifications strictly and reports deviations, making it essential for identifying deliberately malformed PNG files, hidden chunks, and structural modifications used for steganography.

**Installation and Basic Usage**

Install via package manager:

```bash
sudo apt-get install pngcheck
```

Validate a PNG file:

```bash
pngcheck -v target.png
```

The `-v` flag enables verbose output showing all chunks sequentially.

**Detailed Chunk Analysis**

Standard PNG structure requires specific chunk types in order: IHDR (image header), PLTE (palette), IDAT (image data), IEND (end marker). Additional ancillary chunks (like tEXt, zTXt, iTXt) store metadata. View complete chunk breakdown:

```bash
pngcheck -vvv target.png
```

Output resembles:

```
File: target.png (12345 bytes)
  chunk IHDR at offset 0x0000c, length 13
    width x height = (1920 x 1080)
    bit depth = 8 bits
  chunk tEXt at offset 0x001a0, length 256
    keyword: "Comment"
    text: "Hidden message here"
  chunk tEXt at offset 0x002b5, length 512
  chunk IDAT at offset 0x004c0, length 54321
  chunk IEND at offset 0x0d3e1, length 0
  valid Adler-32 checksum
```

**Identifying Non-Standard Chunks**

Custom or unrecognized chunks appear in output. PNG specification allows ancillary chunks with critical bit flags. Check for unexpected chunk types:

```bash
pngcheck -vvv target.png | grep -E "chunk|unknown"
```

Suspicious chunks might include application-specific data or steganographic markers.

**Detecting Chunk Ordering Violations**

PNG specification enforces strict chunk ordering. `pngcheck` identifies violations:

```bash
pngcheck -v malformed.png
# Output: "out of place IDAT chunk"
```

This may indicate file manipulation or intentional structural modification for data hiding.

**CRC and Checksum Validation**

Each PNG chunk includes a CRC-32 checksum. Verify integrity:

```bash
pngcheck -q target.png
# Silent if valid; reports errors if checksums fail
```

Failed checksums indicate chunk modification (intentional or accidental). Extract chunks before checksum modification:

```bash
pngcheck -v target.png | grep -i "bad crc\|error"
```

**Extracting Text Chunks**

PNG text chunks (tEXt, zTXt, iTXt) often contain embedded data. Extract text:

```bash
pngcheck -t target.png
```

Or use `pngtext` utility (if available):

```bash
strings target.png | grep -i "comment\|author\|title"
```

Decompress zTXt (compressed text) chunks using Python:

```python
import struct
import zlib

with open('target.png', 'rb') as f:
    data = f.read()
    # Locate zTXt chunk (0x7A547874)
    offset = data.find(b'\x7A\x54\x78\x74')
    if offset != -1:
        # Extract chunk data after keyword and compression method
        compressed = data[offset+8:]
        try:
            decompressed = zlib.decompress(compressed)
            print(decompressed.decode('utf-8', errors='ignore'))
        except:
            pass
```

**Comparing Multiple PNG Files**

Rapidly check multiple files for anomalies:

```bash
for png in *.png; do
    echo "=== $png ==="
    pngcheck -v "$png" | head -20
done
```

Identify images with identical structure or suspicious characteristics:

```bash
for png in *.png; do
    echo "$png: $(pngcheck -q "$png" 2>&1 || echo 'ERROR')"
done
```

**Detecting Polyglot PNG Files**

Examine files that claim to be PNG but contain additional data:

```bash
pngcheck -vvv polyglot.png | tail -20
# View bytes after IEND chunk
hexdump -C polyglot.png | tail -50
```

Extract non-PNG data appended after IEND:

```bash
# IEND chunk is always 12 bytes (4-byte length + "IEND" + 4-byte CRC)
pngsize=$(pngcheck -v polyglot.png | grep "bytes" | awk '{print $3}')
# More reliably: find IEND offset
iend_offset=$(python3 -c "
data = open('polyglot.png', 'rb').read()
iend_pos = data.rfind(b'IEND')
print(iend_pos + 12)  # 12 bytes for IEND chunk
")
dd if=polyglot.png bs=1 skip=$iend_offset | file -
```

**[Unverified]** Some steganographic tools intentionally create valid PNG structures with deliberately malformed checksums or out-of-order chunks to trigger specific parser behavior in certain applications.

### jsteg

`jsteg` is a JPEG steganography tool designed for hide-and-seek operations with JPEG files. It manipulates DCT (Discrete Cosine Transform) coefficients in the JPEG compression algorithm, providing subtle data embedding in compressed images with minimal visual degradation.

**Installation and Environment**

`jsteg` is a Go-based tool; install from source:

```bash
sudo apt-get install golang-go
go install github.com/lukechampine/jsteg@latest
# Executable located in ~/go/bin/
export PATH=$PATH:~/go/bin/
```

Or compile from source repository:

```bash
git clone https://github.com/lukechampine/jsteg.git
cd jsteg
go build -o jsteg ./cmd/jsteg
```

**JPEG DCT Coefficient Modification Basics**

JPEG compression divides images into 8x8 pixel blocks, transforms each block via DCT, and quantizes coefficients. `jsteg` manipulates lower-frequency DCT coefficients (less visually significant) to embed data. Higher-frequency coefficients are more resistant to detection but more visible to modification.

**Embedding Data in JPEG**

Embed a file into a JPEG image:

```bash
jsteg hide carrier.jpg message.txt output.jpg
```

Verification shows no visual difference between `carrier.jpg` and `output.jpg`, yet `output.jpg` contains hidden data.

Embed binary data:

```bash
jsteg hide carrier.jpg payload.bin output.jpg
```

Specify DCT coefficient selection with additional parameters (if supported by version):

```bash
jsteg hide -freq carrier.jpg message.txt output.jpg
# -freq may select lower-frequency coefficients for lower detectability
```

**Extracting Embedded Data**

Extract data from JPEG:

```bash
jsteg reveal output.jpg extracted_message.txt
```

If extraction fails or produces garbage, the image may not contain `jsteg`-embedded data, or DCT coefficients were modified by compression, editing, or transcoding.

**Handling Lossy Compression Effects**

JPEG is lossy; re-saving or transcoding may corrupt embedded data. Verify original JPEG quality to maximize embedding capacity:

```bash
identify -verbose carrier.jpg | grep -i quality
```

Lower quality JPEGs have fewer usable DCT coefficients. Create high-quality carrier images:

```bash
convert original.jpg -quality 95 carrier.jpg
```

**Capacity Estimation**

Calculate maximum embeddable data size based on image dimensions and quality:

[Inference] JPEG DCT embedding capacity is approximately 1 byte per 10-20 pixels depending on quality and coefficient selection, though this is not guaranteed and varies by implementation.

For a 1920x1080 JPEG, rough capacity: `(1920 * 1080) / 15 ≈ 138,240 bytes`.

**Batch Processing Multiple JPEGs**

Embed identical messages across multiple images:

```bash
for jpg in *.jpg; do
    output="${jpg%.jpg}_steg.jpg"
    jsteg hide "$jpg" message.txt "$output"
done
```

Extract from multiple JPEGs:

```bash
for jpg in *_steg.jpg; do
    output="${jpg%_steg.jpg}_extracted.txt"
    jsteg reveal "$jpg" "$output" 2>/dev/null && echo "Extracted from $jpg"
done
```

**Combining with Other Techniques**

Layer `jsteg` with compression and encryption:

```bash
# Encrypt message
openssl enc -aes-256-cbc -in message.txt -out message.enc -k "password"

# Embed encrypted message
jsteg hide carrier.jpg message.enc output.jpg

# Extraction workflow
jsteg reveal output.jpg extracted.enc
openssl enc -aes-256-cbc -d -in extracted.enc -out message.txt -k "password"
```

**Detection and Analysis**

`jsteg` is challenging to detect with standard steganography detection tools due to DCT coefficient manipulation subtlety. Statistical analysis may reveal anomalies:

```bash
# Extract DCT coefficients and analyze distribution
# This requires JPEG parsing libraries beyond scope of jsteg tool
```

[Unverified] JPEG files containing `jsteg`-embedded data may exhibit statistical anomalies in DCT coefficient distributions when analyzed by forensic tools like `stegdetect`, though detection is not guaranteed.

### stegdetect

`stegdetect` is a steganography detection tool analyzing JPEG files for statistical anomalies indicative of hidden data. It detects multiple steganography methods including jsteg, outguess, invisible secrets, and appendix techniques by examining DCT coefficient patterns and other JPEG artifacts.

**Installation and Setup**

Install from repositories:

```bash
sudo apt-get install stegdetect
```

Or compile from source:

```bash
git clone https://github.com/abeluck/stegdetect.git
cd stegdetect
./configure && make && sudo make install
stegdetect -V
```

**Basic Detection Scanning**

Scan a JPEG for steganographic content:

```bash
stegdetect target.jpg
```

Output format indicates detected steganography methods:

```
target.jpg : jsteg(*)
# (*) indicates confidence level
```

**Detailed Detection with Output Metrics**

Enable verbose output showing analysis details:

```bash
stegdetect -v target.jpg
```

Displays statistical analysis results for each detection method:

```
Checking for signatures...
jsteg: 0.87
outguess: 0.12
invisible: 0.04
appendix: 0.01
```

Values indicate confidence levels; higher scores suggest likely steganography use.

**Batch Scanning Multiple Files**

Scan entire directory:

```bash
stegdetect -d *.jpg
```

The `-d` flag enables "discover" mode, reporting all detections in a format suitable for parsing:

```bash
stegdetect -d /path/to/images/*.jpg | tee stegdetect_results.txt
```

Filter results for high-confidence detections:

```bash
stegdetect -d *.jpg | grep -E "\(\*\*\*\*\*"
```

**Method-Specific Detection**

Focus detection on specific steganography methods:

```bash
# Detect only jsteg
stegdetect -j target.jpg

# Detect only outguess
stegdetect -o target.jpg
```

**Threshold Configuration**

Adjust sensitivity thresholds (lower values = more sensitive, more false positives):

```bash
stegdetect -t 0.5 target.jpg
# More aggressive detection
```

**Analyzing Detection Statistics**

Extract raw statistical data for manual analysis:

```bash
stegdetect -s target.jpg
```

This outputs detailed coefficient statistics that can be piped to analysis tools:

```bash
stegdetect -s *.jpg | tee statistics.txt
python3 analyze_stats.py statistics.txt
```

**Limitations and False Positives**

[Unverified] `stegdetect` may produce false positives on JPEGs with unusual compression artifacts, artistic content with high entropy, or images compressed with specific algorithms.

Verify detections with manual inspection:

```bash
stegdetect -v target.jpg > detection_report.txt
# Compare multiple detection methods; agreement strengthens confidence
```

**Workflow for CTF Scenarios**

Combine multiple detection methods:

```bash
echo "=== stegdetect ===" 
stegdetect -v target.jpg

echo "=== zsteg (if PNG) ==="
file target.jpg

echo "=== Manual analysis ==="
identify -verbose target.jpg | head -30
```

**Integration with Scripts**

Automate JPEG steganography detection across CTF challenges:

```bash
#!/bin/bash
for jpg in *.jpg; do
    result=$(stegdetect -d "$jpg" 2>/dev/null)
    if [[ $result == *"(*"* ]]; then
        echo "[DETECTED] $jpg: $result"
    fi
done
```

### stegoVeritas

`stegoVeritas` is a comprehensive Python-based steganography analysis framework providing multi-format support (JPEG, PNG, BMP, WAV, GIF), automated layer decomposition, and visual plane extraction. It integrates multiple detection techniques and provides detailed reporting suitable for complex forensic analysis.

**Installation and Dependencies**

Clone and install:

```bash
git clone https://github.com/bannsec/stegoVeritas.git
cd stegoVeritas
sudo pip3 install -r requirements.txt
python3 -m stego_tk.stego_tk --help
```

Or install via pip (if available):

```bash
pip3 install stegoveritas
stegoveritas -h
```

**Basic Analysis Workflow**

Run comprehensive analysis on an image:

```bash
python3 -m stego_tk.stego_tk target.jpg
```

Output structure creates directories containing:

```
target.jpg.d/
├── colormap/
├── frame_0/
├── strings/
├── LSB/
├── XNOR/
├── histograms/
├── decompose/
└── report.html
```

**LSB Extraction and Analysis**

Automatically extract all LSB planes and save visualizations:

```bash
python3 -m stego_tk.stego_tk -lsb target.jpg
```

Generates LSB images for each bit plane (0-7) and color channel (R, G, B, A):

```
target.jpg.d/LSB/
├── Red_0.png
├── Red_1.png
├── Green_0.png
├── Green_1.png
├── Blue_0.png
├── Blue_1.png
└── Alpha_0.png
```

Examine LSB visualizations for patterns or embedded images:

```bash
ls -la target.jpg.d/LSB/
file target.jpg.d/LSB/Red_0.png
convert target.jpg.d/LSB/Red_0.png -negate Red_0_inverted.png  # Try inverted
```

**Decomposing Color Planes**

Extract and visualize individual color channels:

```bash
python3 -m stego_tk.stego_tk -colormap target.jpg
```

Produces individual channel images:

```
target.jpg.d/colormap/
├── R.png
├── G.png
├── B.png
├── HSV/
└── YCbCr/
```

Analyze specific decompositions:

```bash
python3 -m stego_tk.stego_tk -colormap --apply HSV target.jpg
python3 -m stego_tk.stego_tk -colormap --apply YCbCr target.jpg
```

**String and Data Extraction**

Extract all human-readable strings from image data:

```bash
python3 -m stego_tk.stego_tk -strings target.jpg
```

Results saved to:

```
target.jpg.d/strings/
├── Default.txt
├── UTF-8.txt
└── UTF-16.txt
```

Inspect extracted strings:

```bash
cat target.jpg.d/strings/Default.txt | head -50
grep -i "flag\|password\|ctf" target.jpg.d/strings/*.txt
```

**Frame Analysis for Animated Images**

Extract frames from GIF or animated PNG:

```bash
python3 -m stego_tk.stego_tk target.gif
```

Frames extracted to:

```
target.gif.d/frame_0/
target.gif.d/frame_1/
...
```

Each frame analyzed independently:

```bash
ls target.gif.d/frame_*/LSB/Red_0.png | xargs identify
# Check if specific frame contains hidden data
```

**Histogram Analysis**

Generate and analyze color histograms:

```bash
python3 -m stego_tk.stego_tk target.jpg
cat target.jpg.d/histograms/*
```

Suspicious histograms show bimodal distributions or anomalies:

```bash
convert target.jpg.d/histograms/R.png -format "%c" histogram:info: | head -20
```

**Advanced Options and Fine-Tuning**

Specify custom analysis parameters:

```bash
python3 -m stego_tk.stego_tk -lsb -colormap -strings target.jpg
```

Limit analysis to specific bit planes:

```bash
python3 -m stego_tk.stego_tk -lsb --planes 0,1,2 target.jpg
```

Save all output in specific directory:

```bash
python3 -m stego_tk.stego_tk -o /tmp/analysis/ target.jpg
```

**HTML Report Generation**

`stegoVeritas` generates comprehensive HTML reports:

```bash
python3 -m stego_tk.stego_tk target.jpg
# Opens browser or generates report.html
```

Report contains:

- Visual previews of all extracted planes and decompositions
- Extracted strings with line numbers
- Histogram analysis graphs
- Direct links to generated artifacts

**Batch Analysis of Multiple Images**

Automate analysis across multiple files:

```bash
#!/bin/bash
for img in *.{jpg,png,bmp}; do
    echo "Analyzing $img..."
    python3 -m stego_tk.stego_tk "$img"
    # Examine results
    find "${img}.d" -name "*.txt" -exec grep -l "flag\|password" {} \;
done
```

**Extracting Data from Generated Output**

After analysis, extract discovered data:

```bash
# Find LSB patterns that formed recognizable images
identify -verbose target.jpg.d/LSB/Red_0.png | grep -i entropy

# Extract strings programmatically
python3 << 'EOF'
import os
img_dir = "target.jpg.d"
for root, dirs, files in os.walk(img_dir):
    for file in files:
        if file.endswith('.txt'):
            with open(os.path.join(root, file)) as f:
                lines = f.readlines()
                significant_lines = [l for l in lines if len(l) > 8]
                if significant_lines:
                    print(f"{root}/{file}:")
                    for line in significant_lines[:10]:
                        print(f"  {line.strip()}")
EOF
```

**[Unverified]** `stegoVeritas` detection accuracy varies based on steganographic method sophistication; advanced or custom embedding techniques may evade automated detection.

### ImageMagick

ImageMagick is a command-line image manipulation suite providing pixel-level access, format conversion, metadata extraction, and batch processing. While not steganography-specific, it enables forensic analysis, plane extraction, and data visualization critical for steganography investigation.

**Installation and Verification**

Install complete ImageMagick suite:

```bash
sudo apt-get install imagemagick
convert -version
identify -version
display --version
```

Check policy restrictions (important for file processing):

```bash
grep -i policy /etc/ImageMagick-6/policy.xml
```

Relax restrictions if needed (carefully):

```bash
sudo nano /etc/ImageMagick-6/policy.xml
# Comment out restrictive PDF/PS policies if needed
```

**Basic Image Information and Metadata Extraction**

Display comprehensive image information:

```bash
identify -verbose target.jpg | head -100
```

Extract specific metadata fields:

```bash
identify -format "%[profile:exif]\n" target.jpg
identify -format "%[comment]\n" target.jpg
```

Check image dimensions, bit depth, and color space:

```bash
identify -format "%wx%h %b %r\n" target.jpg
```

**Color Channel Separation and Extraction**

Decompose image into individual channels:

```bash
convert target.jpg -colorspace RGB -channel R -separate Red.png
convert target.jpg -colorspace RGB -channel G -separate Green.png
convert target.jpg -colorspace RGB -channel B -separate Blue.png
```

Extract alpha channel:

```bash
convert target.png -alpha extract Alpha.png
```

Convert to different color spaces and extract channels:

```bash
convert target.jpg -colorspace HSV \
  -channel H -separate Hue.png \
  -channel S -separate Saturation.png \
  -channel V -separate Value.png
```

**Bit Plane Extraction**

Extract individual bit planes (LSB extraction):

```bash
# Bit 0 (LSB)
convert target.jpg -format "%[pixel:p{0,0}]" info: | awk '{print $1 & 1}'
```

More practical bit plane extraction using command sequence:

```bash
#!/bin/bash
for bit in {0..7}; do
    convert target.jpg \
      -evaluate Bitwise-and $((255 - (1 << bit) + (1 << bit))) \
      -evaluate Divide $((1 << bit)) \
      -auto-level \
      LSB_${bit}.png
    echo "Extracted bit plane $bit to LSB_${bit}.png"
done
```

Invert extracted planes to reveal patterns:

```bash
convert LSB_0.png -negate LSB_0_inverted.png
```

**Histogram Analysis**

Generate and display histograms:

```bash
convert target.jpg histogram:target_histogram.png
display target_histogram.png
```

Extract histogram data for numerical analysis:

```bash
convert target.jpg -format "%c" histogram:info: > histogram_data.txt
cat histogram_data.txt | head -20
```

Analyze distributions for anomalies:

```bash
python3 << 'EOF'
import subprocess
result = subprocess.run(['convert', 'target.jpg', '-format', '%c', 'histogram:info:'], 
                       capture_output=True, text=True)
lines = result.stdout.strip().split('\n')
for line in lines[:20]:
    parts = line.split()
    if len(parts) >= 2:
        count = int(parts[0])
        color = parts[-1]
        if count > 1000:
            print(f"{color}: {count} pixels")
EOF
```

**Format Conversion and Comparison**

Convert between formats while preserving data:

```bash
convert target.jpg target.png
convert target.jpg target.bmp
convert target.jpg target.gif
```

Compare images for differences:

```bash
convert target1.jpg target2.jpg +append difference.png
convert target1.jpg target2.jpg -compose Difference -composite diff.png
```

**Metadata Stripping and Analysis**

Remove all metadata:

```bash
convert target.jpg -strip target_no_metadata.jpg
```

Extract and preserve specific metadata:

```bash
convert target.jpg \
  -write 'mpr:img' \
  -strip \
  -write target_clean.jpg \
  mpr:img -format "%[exif:*]" info:
```

View metadata in detail:

```bash
identify -verbose target.jpg | grep -E "Exif|Comment|Software|Author"
```

**Batch Image Processing**

Process multiple images with consistent transformations:

```bash
mogrify -format png *.jpg  # Convert all JPEGs to PNG
for img in *.png; do
    convert "$img" -strip "stripped_$img"
done
```

Extract LSB planes from multiple images:

```bash
for img in *.jpg; do
    echo "Processing $img..."
    convert "$img" \
      -evaluate Bitwise-and 1 \
      -auto-level \
      "LSB_${img%.jpg}.png"
done
```

**Frequency Domain and Pattern Analysis**

Apply filters revealing patterns:

```bash
# Edge detection
convert target.jpg -edge 3 edges.png

# Despeckle to reveal underlying structure
convert target.jpg -despeckle despecked.png

# Blur to smooth noise
convert target.jpg -blur 0x2 blurred.png

# High-pass filtering (reveal subtle details)
convert target.jpg \
  \( +clone -blur 0x5 \) \
  +swap -compose Difference -composite \
  highpass.png
```

**Extracting Data via Image Math**

Use ImageMagick's mathematical operations to extract LSB patterns:

```bash
# Extract red channel LSB
convert target.jpg \
  -colorspace RGB \
  -channel R \
  -separate \
  -negate \
  -threshold 50%  
lsb_red_extracted.png

````

Perform XOR operations to compare images:

```bash
convert target1.jpg target2.jpg \
  -compose Difference -composite \
  xor_result.png
````

**Advanced Forensic Workflow**

Complete analysis chain:

```bash
#!/bin/bash
target="$1"
output_dir="${target%.*}_analysis"
mkdir -p "$output_dir"

echo "[*] Extracting metadata..."
identify -verbose "$target" > "$output_dir/metadata.txt"

echo "[*] Extracting color channels..."
convert "$target" -colorspace RGB \
  -channel R -separate "$output_dir/Red.png" \
  -channel G -separate "$output_dir/Green.png" \
  -channel B -separate "$output_dir/Blue.png"

echo "[*] Extracting LSB planes..."
for bit in {0..3}; do
    convert "$target" \
      -evaluate Bitwise-and $((1 << bit)) \
      -evaluate Divide $((1 << bit)) \
      -auto-level \
      "$output_dir/LSB_${bit}.png"
done

echo "[*] Generating histograms..."
convert "$target" histogram:"$output_dir/histogram.png"

echo "[*] Analysis complete. Results in $output_dir"
```

**[Unverified]** ImageMagick's mathematical operations may introduce rounding errors or precision loss when performing complex bit manipulations, potentially corrupting extracted data.

### GIMP

GIMP (GNU Image Manipulation Program) is a graphical image editor providing interactive pixel-level manipulation, layer analysis, and visual steganography investigation. While designed for image creation, its forensic capabilities enable manual inspection, filtering, and data extraction from suspicious images.

**Installation and Interface**

Install GIMP:

```bash
sudo apt-get install gimp gimp-plugins
gimp &
```

Launch with specific image:

```bash
gimp target.jpg &
```

**Loading and Inspecting Images**

Open image: `File → Open → target.jpg`

Access image properties: `Image → Image Properties` displays dimensions, color space, bit depth, and file format details.

**Channel Decomposition and Analysis**

Access channels window: `Windows → Dockable Dialogs → Channels`

Displays individual color channels (Red, Green, Blue, Alpha) as separate layers. Click channels to view individually:

1. Click "Red" channel → view only red information
2. Click "Green" channel → view only green information
3. Click "Blue" channel → view only blue information
4. Enable/disable channels by clicking eye icon

Export individual channels:

1. Right-click channel → "Channel to Selection"
2. `Select → All` (or use current selection)
3. `Edit → Copy`
4. `File → Create → From Clipboard` (creates new image)
5. `File → Export As` → save channel image

**Decompose for Multi-Channel Export**

Automated channel decomposition: `Colors → Components → Decompose`

Select decomposition method:

- **RGB:** Individual R, G, B channels
- **RGBA:** With alpha channel
- **HSV:** Hue, Saturation, Value
- **CMYK:** Print color space
- **YCbCr:** Luminance/chrominance

Decomposition creates new image with layers for each channel:

```
Decomposed image:
├── Red layer
├── Green layer
├── Blue layer
└── Alpha layer
```

Each layer can be exported individually or analyzed visually.

**Levels and Curves Adjustment**

Access: `Colors → Levels` or `Colors → Curves`

Adjust brightness, contrast, and gamma to reveal hidden patterns:

1. Open image
2. `Colors → Levels`
3. Move input/output sliders to stretch or compress tonal range
4. Observe if previously invisible patterns emerge

Use curves for more precise control:

```
1. Colors → Curves
2. Click points on diagonal line to create curve
3. Adjust curve to reveal patterns
4. Preview real-time changes
```

**Threshold and Posterize for Pattern Revelation**

Binary conversion reveals embedded patterns: `Colors → Threshold`

Adjust threshold slider until patterns become visible. Export result.

Posterize reduces color palette: `Colors → Posterize`

Set "Levels" to 2-4 for maximum contrast, revealing structural patterns.

**Histogram Analysis**

Access: `Colors → Auto → Stretch Contrast` or `Windows → Dockable Dialogs → Histogram`

Histogram window displays color distribution across channels. Anomalies (spikes, gaps, unusual patterns) indicate potential steganographic modification.

Take note of:

- Bimodal distributions (two distinct peaks)
- Histogram gaps (missing values)
- Skewed distributions

**Layer and Mask Manipulation**

For multi-layer images (PSD, XCF):

1. `Windows → Dockable Dialogs → Layers`
2. Click each layer to inspect individually
3. Adjust layer opacity to reveal obscured content
4. Use layer blend modes to combine layers differently

Toggle layer visibility by clicking eye icon to compare composite versus individual layers.

**Filters for Pattern Detection**

Apply filters to reveal hidden structures:

**Edge Detection:** `Filters → Edge-Detect → Edge (Sobel/Laplace)`

```
Reveals boundaries and patterns
```

**Sharpen:** `Filters → Enhance → Sharpen`

```
Enhances subtle details
```

**Despeckle:** `Filters → Enhance → Despeckle`

```
Removes noise, clarifies underlying patterns
```

**Emboss:** `Filters → Distorts → Emboss`

```
Reveals texture and elevation patterns
```

**High Pass Filter:** `Filters → Enhance → Unsharp Mask`

```
(Approximate high-pass)
Reveals subtle variations
```

**Invert Colors**

Invert to check if data becomes visible: `Colors → Invert`

Or: `Colors → Value Invert`, `Colors → Hue Rotate`

Export inverted image and compare with original.

**Manual Data Extraction**

Use Eyedropper tool (`Tools → Color Tools → Eyedropper` or `O` key) to inspect pixel values:

1. Click pixels to display RGB values in "Pointer" dialog
2. Note suspicious patterns or anomalies
3. Record coordinates and values

Extract pixel data programmatically via GIMP Python console:

`Filters → Python-Fu → Console`

```python
img = gimp.image_list()[0]
drawable = img.active_layer
for x in range(0, 100):
    for y in range(0, 100):
        pixel = drawable.get_pixel(x, y)
        print(f"({x},{y}): {pixel}")
```

**Selection and Extraction Tools**

Extract specific image regions:

1. `Tools → Selection Tools → Rectangle Select` (or `R`)
2. Drag to select region containing suspected data
3. `Edit → Copy`
4. `File → Create → From Clipboard`
5. Analyze or export extracted region

**Exporting and Format Conversion**

Export with specific settings: `File → Export As`

Choose format (.png, .bmp, .jpg with variable quality) and enable/disable compression options.

Export specific layers as separate files:

```
File → Export Layers
Exports each layer as individual file
```

**Batch Processing via Script-Fu**

Access scripting console: `Filters → Python-Fu → Console`

Example: Extract all color channels from batch of images

```python
import os
from gimpfu import *

input_dir = "/path/to/images"
output_dir = "/path/to/output"

for filename in os.listdir(input_dir):
    if filename.endswith('.jpg'):
        filepath = os.path.join(input_dir, filename)
        img = pdb.file_jpeg_load(filepath, filepath)
        
        # Decompose into RGB
        decomposed = pdb.gimp_image_decompose(img, "RGB")
        
        # Export layers
        for layer_idx, layer in enumerate(decomposed.layers):
            output_path = os.path.join(output_dir, 
                                      f"{filename}_{layer_idx}.png")
            pdb.file_png_save(decomposed, layer, output_path, output_path)
```

**Workflow for Forensic Investigation**

Complete analysis workflow:

1. Open image in GIMP
2. `Colors → Components → Decompose (RGB)` → analyze each channel
3. `Colors → Levels` → adjust to reveal patterns
4. `Colors → Threshold` → convert to binary for pattern visibility
5. `Filters → Edge-Detect` → reveal boundaries
6. `Colors → Invert` → try inverted version
7. Export suspicious regions or full results at each step
8. Compare results with original

**Integration with Automated Tools**

Use GIMP's headless mode for scripted analysis:

```bash
gimp -i -b '(script-fu code here)' -b '(gimp-quit 0)' target.jpg
```

Or export GIMP Python scripts for batch processing:

```bash
gimp --batch-interpreter python-fu-eval \
     --batch 'import batch_analysis; batch_analysis.analyze_directory("/images")'
```

**[Unverified]** GIMP's color decomposition and mathematical operations may introduce minor artifacts or precision differences compared to lower-level binary manipulation tools, potentially affecting extracted data integrity in edge cases.

---

## Audio Tools

### Audacity

Audacity is a multi-track audio editor and recorder providing visual waveform analysis, spectrogram viewing, and audio manipulation capabilities essential for audio steganography detection.

**Installation:**

```bash
sudo apt update
sudo apt install audacity
```

**Key Features for CTF:**

1. **Waveform Analysis** - Visual representation of amplitude over time
2. **Spectrogram View** - Frequency-domain visualization revealing hidden images/text
3. **Spectral Selection** - Isolate specific frequency ranges
4. **Effect Chains** - Apply filters to reveal hidden content

**Opening and Initial Analysis:**

```bash
# Launch from terminal
audacity audio_file.wav

# Command-line batch processing (limited)
audacity -blocksize 512 audio.wav
```

**Manual Spectrogram Analysis:**

1. **Enable Spectrogram View:**
    
    - Click track dropdown (▼) next to track name
    - Select "Spectrogram" or "Multi-view"
    - Adjust settings via "Spectrogram Settings"
2. **Spectrogram Settings Configuration:**
    - **Algorithm:** FFT-based analysis
        - FFT Size: 2048-8192 (higher = better frequency resolution, lower time resolution)
        - Window: Hann (default), Hamming, Blackman
    - **Frequency Scale:** Linear or Logarithmic
    - **Color Scheme:** Grayscale, Inverse grayscale, Color (heat map)
    - **Range:** Adjust min/max frequencies (0-22050 Hz typical)
3. **Common Spectrogram Parameters for Hidden Images:**
    
    ```
    Window Size: 4096 or 8192
    Window Type: Hann
    Zero Padding Factor: 1
    Scale: Linear
    Range: 0-22050 Hz (full range)
    Gain: 20 dB
    Range: 80 dB
    ```
    

**Hidden Image Detection:**

Steganographic images often appear in the spectrogram view:

1. Load audio file
2. Switch to Spectrogram view
3. Adjust contrast/brightness using Preferences → Spectrograms
4. Look for patterns in frequency domain (text, QR codes, images)
5. Screenshot or use Analyze → Plot Spectrum for detailed view

**Spectral Analysis Tools:**

```
Analyze → Plot Spectrum (Frequency Analysis)
- Algorithm: Spectrum, Autocorrelation, Cepstrum
- Size: 65536 for high detail
- Function: Hann window
- Axis: Linear/Log frequency, Linear/dB
```

**Phase Analysis:**

Hidden data may exist in phase information rather than amplitude:

```
Effect → Invert (can reveal phase-based steganography)
Analyze → Contrast Analyzer (check left/right channel differences)
```

**Channel Comparison:**

```bash
# Stereo files may hide data in channel differences
# In Audacity:
Tracks → Stereo Track to Mono (compare behavior)
Effect → Vocal Reduction and Isolation (reveals center-panned vs side differences)

# LSB may differ between channels
Analyze → Contrast... (check waveform differences)
```

**Useful Effects for Revealing Hidden Content:**

```
Effect → Amplify (increase gain to hear quiet sections)
Effect → Normalize (standardize amplitude)
Effect → High-Pass Filter (remove low frequencies)
Effect → Low-Pass Filter (remove high frequencies)
Effect → Notch Filter (remove specific frequency)
Effect → Equalization (boost/cut frequency ranges)
Effect → Reverse (some steganography uses reversed audio)
```

**Exporting Data:**

```
File → Export → Export Audio (various formats)
File → Export → Export Multiple (batch export)

# Export spectrogram as image (requires screenshot)
# Or use Analyze → Plot Spectrum → Export
```

### Sonic Visualiser

Sonic Visualiser is an advanced audio analysis application designed for detailed inspection of audio content, superior to Audacity for forensic analysis.

**Installation:**

```bash
sudo apt install sonic-visualiser
```

**Key Advantages Over Audacity:**

- Multiple simultaneous visualization layers
- Non-destructive analysis
- Advanced time-frequency analysis plugins
- Annotation capabilities
- More precise measurement tools

**Basic Usage:**

```bash
# Launch
sonic-visualiser audio.wav

# Command-line layer addition (batch analysis)
sonic-visualiser audio.wav -transform vamp:qm-vamp-plugins:qm-chromagram
```

**Essential Panes/Views:**

1. **Waveform** - Time-domain amplitude
2. **Spectrogram** - Frequency-domain visualization
3. **Melodic Range Spectrogram** - Focused frequency analysis
4. **Peak Frequency Spectrogram** - Highlights dominant frequencies
5. **Spectrum** - Frequency distribution at playback point

**Adding Layers:**

```
Panes → Add Spectrogram (Ctrl+Shift+G)
Panes → Add Peak Frequency Spectrogram
Panes → Add Melodic Range Spectrogram
Layer → Add New Colour 3D Plot Layer
```

**Spectrogram Configuration:**

```
Right-click spectrogram → Properties:

Window: 4096, 8192, or 16384 samples
Window Overlap: 93.75% (high detail) to 50% (faster)
Frequency Scale: Linear, Log, Mel
Color: Sunset, White on Black, Printer
Normalization: None, Hybrid, Column
Bins Display: All Bins, Peak Frequencies only
```

**Advanced Analysis Techniques:**

1. **DTMF Tone Detection:**

```
Transform → Analysis by Category → Tonal Analysis → Tuning Frequency
Transform → vamp:qm-vamp-plugins:qm-keydetector
```

2. **Spectral Slicing:**

```
Select frequency range in spectrogram
File → Export Annotation Layer (save selected frequencies)
```

3. **Time Stretching (revealing rapid changes):**

```
Transform → Time Stretcher
Set stretch factor: 0.1-0.5 (slow down 2-10x)
```

**Plugin Usage for Hidden Content:**

```bash
# List available transforms
sonic-visualiser --list

# Common transforms for CTF
Transform → vamp:qm-vamp-plugins:qm-chromagram  # Pitch class analysis
Transform → vamp:qm-vamp-plugins:qm-mfcc  # MFCC features
Transform → aubio:aubionotes  # Note detection
Transform → spectral-flux  # Detect sudden changes
```

**Annotation and Measurement:**

```
# Add point annotation
Draw → Add Point (Shift+Click)
Draw → Add Region (mark suspicious sections)

# Measure exact frequency/time
Layer → Edit Layer Data
Right-click → Measure (precise Hz/time values)
```

**Exporting Analysis:**

```bash
# Export image
File → Export Image File (PNG, SVG)

# Export annotation data
File → Export Annotation Layer (CSV, RDF)

# Export selection as audio
File → Export Selection as Audio File
```

### SoX (Sound eXchange)

SoX is the "Swiss Army knife" of audio manipulation, providing command-line processing for format conversion, filtering, and analysis.

**Installation:**

```bash
sudo apt install sox libsox-fmt-all
```

**Basic Information Retrieval:**

```bash
# Display audio file information
sox --info audio.wav
soxi audio.wav

# Detailed statistics
soxi -a audio.wav  # Show all metadata

# Specific properties
soxi -d audio.wav  # Duration
soxi -r audio.wav  # Sample rate
soxi -c audio.wav  # Channels
soxi -b audio.wav  # Bit depth
soxi -e audio.wav  # Encoding
```

**Format Conversion:**

```bash
# Convert between formats
sox input.mp3 output.wav
sox input.wav output.flac

# Change sample rate
sox input.wav -r 44100 output.wav

# Change bit depth
sox input.wav -b 16 output.wav

# Change channels (stereo to mono)
sox input.wav output.wav channels 1

# Extract specific channel
sox stereo.wav left.wav remix 1
sox stereo.wav right.wav remix 2
```

**Audio Analysis:**

```bash
# Generate statistics
sox audio.wav -n stat
sox audio.wav -n stat 2>&1

# Detailed stats (redirecting stderr to stdout)
sox audio.wav -n stat 2>&1 | grep -E "RMS|Maximum|Minimum"

# Frequency spectrum
sox audio.wav -n spectrogram -o spectrogram.png
sox audio.wav -n spectrogram -x 3000 -y 513 -z 120 -o output.png

# High-resolution spectrogram
sox audio.wav -n spectrogram -x 4000 -y 1025 -z 100 -o highres.png
```

**Spectrogram Options:**

```bash
# Full syntax
sox input.wav -n spectrogram [options] -o output.png

# Common options:
-x pixels     # Width (default 800)
-y pixels     # Height (default 513, related to FFT)
-z dB         # Z-axis range in dB (default 120)
-q quality    # Quality 1-249 (higher = slower, more detail)
-m            # Monochrome
-l            # Light background
-r            # Raw spectrogram (no axes)
-a            # Alternative color scheme
-t "text"     # Title
-c "text"     # Comment

# Example: High-detail spectrogram
sox audio.wav -n spectrogram -x 4000 -y 2049 -z 100 -q 249 -o detailed.png
```

**LSB (Least Significant Bit) Analysis:** [Inference - requires extracting raw sample data]

```bash
# Extract raw samples
sox audio.wav audio.raw
sox audio.wav -t raw -b 16 -e signed-integer audio.raw

# Convert to text (sample values)
sox audio.wav -t dat output.dat
# Format: sample_number left_value right_value

# Extract LSB pattern (requires custom script)
sox audio.wav -t dat - | awk '{print $2}' | head -1000
```

**Phase Analysis:**

```bash
# Invert phase (reveals phase-based steganography)
sox input.wav inverted.wav reverse reverse

# Extract phase difference between channels
sox stereo.wav -n remix 1 -2  # Left minus Right
```

**Filtering:**

```bash
# High-pass filter (remove frequencies below X Hz)
sox input.wav output.wav highpass 1000

# Low-pass filter (remove frequencies above X Hz)
sox input.wav output.wav lowpass 1000

# Band-pass filter (keep only frequencies in range)
sox input.wav output.wav bandpass 1000 500  # Center 1000Hz, width 500Hz

# Band-reject (notch filter)
sox input.wav output.wav bandreject 1000 100
```

**Audio Effects for Revealing Hidden Content:**

```bash
# Amplify quiet sections
sox input.wav output.wav gain 10  # +10dB

# Normalize audio
sox input.wav output.wav norm

# Reverse audio
sox input.wav reversed.wav reverse

# Change speed (without pitch shift)
sox input.wav faster.wav speed 2.0  # 2x faster

# Change tempo (preserve pitch)
sox input.wav faster.wav tempo 2.0

# Slow down dramatically (may reveal rapid data encoding)
sox input.wav slow.wav tempo 0.1  # 10x slower

# Pitch shift
sox input.wav shifted.wav pitch 500  # Shift by 500 cents
```

**Splitting and Combining:**

```bash
# Split stereo to separate files
sox stereo.wav left.wav remix 1
sox stereo.wav right.wav remix 2

# Combine mono files to stereo
sox -M left.wav right.wav stereo.wav

# Extract time segment
sox input.wav output.wav trim 10 5  # Start at 10s, duration 5s
sox input.wav output.wav trim 0 30  # First 30 seconds
```

**Generating Test Tones:** [Useful for comparison/baseline]

```bash
# Sine wave (440 Hz, 5 seconds)
sox -n sine440.wav synth 5 sine 440

# Multiple frequencies
sox -n dual.wav synth 5 sine 440 sine 880

# Generate DTMF tones
sox -n dtmf.wav synth 0.1 sine 697 sine 1209  # '1' key
```

### FFmpeg

FFmpeg is a comprehensive multimedia framework for recording, converting, and streaming audio/video, with extensive format support and analysis capabilities.

**Installation:**

```bash
sudo apt install ffmpeg
```

**File Information:**

```bash
# Display detailed stream information
ffmpeg -i audio.mp3

# Hide banner, show only stream info
ffmpeg -i audio.mp3 -hide_banner

# Probe file (cleaner output)
ffprobe audio.mp3
ffprobe -hide_banner audio.mp3

# JSON output (parseable)
ffprobe -v quiet -print_format json -show_format -show_streams audio.mp3

# Specific stream properties
ffprobe -v error -select_streams a:0 -show_entries stream=codec_name,sample_rate,channels audio.mp3
```

**Format Conversion:**

```bash
# Basic conversion
ffmpeg -i input.mp3 output.wav

# Specify codec explicitly
ffmpeg -i input.mp3 -acodec pcm_s16le output.wav

# Change sample rate
ffmpeg -i input.wav -ar 44100 output.wav

# Change bit depth
ffmpeg -i input.wav -sample_fmt s16 output.wav  # 16-bit
ffmpeg -i input.wav -sample_fmt s24 output.wav  # 24-bit

# Change channels
ffmpeg -i stereo.wav -ac 1 mono.wav  # Stereo to mono
```

**Channel Extraction:**

```bash
# Extract left channel
ffmpeg -i stereo.wav -map_channel 0.0.0 left.wav

# Extract right channel
ffmpeg -i stereo.wav -map_channel 0.0.1 right.wav

# Alternative method
ffmpeg -i stereo.wav -af "pan=mono|c0=FL" left.wav
ffmpeg -i stereo.wav -af "pan=mono|c0=FR" right.wav
```

**Spectrogram Generation:**

```bash
# Generate spectrogram video
ffmpeg -i audio.wav -lavfi showspectrumpic=s=1920x1080 spectrogram.png

# Animated spectrogram (video)
ffmpeg -i audio.wav -lavfi showspectrum=s=1280x720:mode=combined:color=channel:scale=log output.mp4

# High-resolution static spectrogram
ffmpeg -i audio.wav -lavfi showspectrumpic=s=4096x2048:legend=1:color=fire spectrogram.png

# Customized spectrogram
ffmpeg -i audio.wav -lavfi \
  "showspectrumpic=s=3840x2160:mode=combined:color=intensity:scale=log:legend=disabled" \
  output.png
```

**Spectrogram Options:**

```bash
showspectrumpic parameters:
- s=WIDTHxHEIGHT (size)
- mode=combined|separate (channels)
- color=channel|intensity|rainbow|moreland|nebulae|fire|fiery|fruit|cool|magma|green|viridis|plasma|cividis|terrain
- scale=lin|sqrt|cbrt|log|4thrt|5thrt
- fscale=lin|log (frequency scale)
- saturation=0.0-10.0
- win_func=rect|bartlett|hann|hanning|hamming|blackman|welch|flattop|bharris|bnuttall|bhann|sine|nuttall|lanczos|gauss|tukey|dolph|cauchy|parzen|poisson|bohman
- legend=0|1 (show color legend)
- rotation=0-1 (orientation)
```

**Waveform Visualization:**

```bash
# Generate waveform image
ffmpeg -i audio.wav -filter_complex showwavespic=s=1920x1080 waveform.png

# Detailed waveform
ffmpeg -i audio.wav -filter_complex \
  "showwavespic=s=3840x2160:colors=blue|red" waveform.png
```

**Audio Filtering:**

```bash
# High-pass filter
ffmpeg -i input.wav -af "highpass=f=1000" output.wav

# Low-pass filter
ffmpeg -i input.wav -af "lowpass=f=1000" output.wav

# Band-pass filter
ffmpeg -i input.wav -af "bandpass=f=1000:width_type=h:width=200" output.wav

# Band-reject (notch)
ffmpeg -i input.wav -af "bandreject=f=1000:width_type=h:width=100" output.wav

# Equalizer
ffmpeg -i input.wav -af "equalizer=f=1000:t=q:w=1:g=10" output.wav

# Volume adjustment
ffmpeg -i input.wav -af "volume=10dB" output.wav

# Reverse audio
ffmpeg -i input.wav -af "areverse" reversed.wav
```

**Advanced Filtering:**

```bash
# Amplify quiet sections (compressor)
ffmpeg -i input.wav -af "compand" output.wav

# Normalize audio
ffmpeg -i input.wav -af "loudnorm" output.wav

# Remove silence
ffmpeg -i input.wav -af "silenceremove=1:0:-50dB" output.wav

# Detect silence
ffmpeg -i input.wav -af "silencedetect=n=-30dB:d=0.5" -f null - 2>&1 | grep silence

# Phase inversion
ffmpeg -i input.wav -af "aeval='0-val(0)'" inverted.wav
```

**Stream Extraction:**

```bash
# Extract audio from video
ffmpeg -i video.mp4 -vn -acodec copy audio.aac
ffmpeg -i video.mp4 -vn audio.wav

# Extract specific stream
ffmpeg -i input.mkv -map 0:a:0 track1.wav  # First audio track
ffmpeg -i input.mkv -map 0:a:1 track2.wav  # Second audio track

# List all streams
ffprobe -v error -show_entries stream=index,codec_type,codec_name input.mkv
```

**Metadata Extraction:**

```bash
# Show all metadata
ffprobe -v quiet -print_format json -show_format input.mp3 | jq '.format.tags'

# Extract specific metadata
ffmpeg -i input.mp3 -f ffmetadata metadata.txt

# Check for hidden data in metadata
ffprobe -v quiet -print_format json -show_format -show_streams input.mp3 | jq
```

**Raw Data Extraction:**

```bash
# Extract raw PCM data
ffmpeg -i input.wav -f s16le -acodec pcm_s16le output.raw

# Extract with specific parameters
ffmpeg -i input.wav -f s16le -ar 44100 -ac 1 output.raw

# Convert raw back to WAV
ffmpeg -f s16le -ar 44100 -ac 1 -i input.raw output.wav
```

**Concatenation and Splitting:**

```bash
# Split audio into segments
ffmpeg -i input.wav -f segment -segment_time 10 -c copy output%03d.wav

# Extract specific time range
ffmpeg -i input.wav -ss 00:01:30 -t 00:00:10 -c copy output.wav
# -ss: start time, -t: duration

# Concatenate files
echo "file 'part1.wav'" > filelist.txt
echo "file 'part2.wav'" >> filelist.txt
ffmpeg -f concat -safe 0 -i filelist.txt -c copy output.wav
```

### MediaInfo

MediaInfo displays comprehensive technical and metadata information about multimedia files.

**Installation:**

```bash
sudo apt install mediainfo mediainfo-gui
```

**Command-Line Usage:**

```bash
# Basic information
mediainfo audio.mp3

# Full detailed output
mediainfo --Full audio.mp3

# Specific output format
mediainfo --Output=XML audio.mp3
mediainfo --Output=JSON audio.mp3
mediainfo --Output=HTML audio.mp3

# Custom output template
mediainfo --Inform="General;%Format%, %FileSize%, %Duration%" audio.mp3

# Audio-specific information
mediainfo --Inform="Audio;%Format%, %SamplingRate%, %BitRate%, %Channels%" audio.mp3
```

**Key Information to Examine:**

```bash
# Check for anomalies
mediainfo audio.mp3 | grep -E "Duration|File size|Bit rate|Format|Encoded"

# Look for unusual metadata
mediainfo --Full audio.mp3 | grep -i "comment\|description\|title\|copyright"

# Encoding details (may reveal modified files)
mediainfo --Full audio.mp3 | grep -i "encoding\|encoder\|library"

# Compare stated vs. actual properties
mediainfo --Inform="General;Duration=%Duration%" audio.mp3
```

**Batch Analysis:**

```bash
# Analyze multiple files
for file in *.wav; do
    echo "=== $file ==="
    mediainfo --Inform="Audio;%Format%, %Duration%, %BitRate%" "$file"
done

# Export to CSV
mediainfo --Output=CSV *.mp3 > analysis.csv
```

**GUI Usage:**

```bash
# Launch GUI
mediainfo-gui audio.mp3
```

GUI provides:

- Tree view of all streams
- Text/HTML/JSON export
- Easy metadata comparison
- Visual stream structure

**Detecting Anomalies:** [Inference - requires domain knowledge]

```bash
# Check for mismatched file extension and actual format
mediainfo audio.mp3 | grep "Format"
# If Format shows WAV but extension is .mp3, investigation needed

# Verify file integrity
mediainfo audio.wav | grep -E "Duration|Stream size"
# Compare stream size to file size (excess data may indicate appended content)

# Check for unusual encoding dates
mediainfo --Full audio.mp3 | grep -i "encoded date\|tagged date"
```

### Wavsteg

Wavsteg is a Python-based LSB steganography tool specifically for WAV files, allowing data hiding and extraction in audio samples.

**Installation:**

```bash
# Clone repository
git clone https://github.com/ragibson/Steganography.git
cd Steganography

# Install dependencies
pip3 install numpy

# Or install directly
pip3 install wavsteg
```

**Basic Usage:**

```bash
# Hide data in WAV file
python3 wavsteg.py -h -i input.wav -o output.wav -s secret.txt -n 1

# Extract hidden data
python3 wavsteg.py -r -i stego.wav -o extracted.txt -n 1

# Using installed package
wavsteg -h -i input.wav -o output.wav -s secret.txt -n 1
wavsteg -r -i stego.wav -o extracted.txt -n 1
```

**Parameters:**

```bash
-h, --hide          Hide mode (encode data)
-r, --recover       Recover mode (extract data)
-i INPUT            Input WAV file
-o OUTPUT           Output file
-s SECRET           File to hide (hide mode)
-n NUM_LSB          Number of LSBs to use (1-8, default 2)
-b BYTES            Number of bytes to recover (if known)
```

**LSB Depth Explanation:**

- **n=1**: Uses only least significant bit (most subtle, smallest capacity)
- **n=2**: Uses 2 LSBs (balanced, common default)
- **n=4**: Uses 4 LSBs (higher capacity, more audible distortion)
- **n=8**: Uses all 8 bits (maximum capacity, significant distortion)

**Example Hiding Workflow:**

```bash
# 1. Prepare cover audio (must be WAV format)
ffmpeg -i cover.mp3 cover.wav

# 2. Hide text message
echo "flag{hidden_message}" > secret.txt
python3 wavsteg.py -h -i cover.wav -o stego.wav -s secret.txt -n 2

# 3. Verify file still plays normally
play stego.wav
```

**Example Extraction Workflow:**

```bash
# Try different LSB depths
python3 wavsteg.py -r -i stego.wav -o output1.txt -n 1
python3 wavsteg.py -r -i stego.wav -o output2.txt -n 2
python3 wavsteg.py -r -i stego.wav -o output3.txt -n 3
python3 wavsteg.py -r -i stego.wav -o output4.txt -n 4

# Check extracted files
file output*.txt
strings output*.txt
cat output*.txt
```

**Specifying Extraction Length:** [Useful when you know data size]

```bash
# Extract specific number of bytes
python3 wavsteg.py -r -i stego.wav -o output.txt -n 2 -b 100

# Extract without length limit (may include garbage)
python3 wavsteg.py -r -i stego.wav -o output.txt -n 2
```

**Manual LSB Analysis (Alternative Approach):**

```bash
# Extract raw audio samples
sox stego.wav -t dat samples.txt

# Python script to extract LSBs manually
python3 << 'EOF'
import wave
import sys

def extract_lsb(wav_file, num_lsb=1):
    with wave.open(wav_file, 'rb') as wav:
        frames = wav.readframes(wav.getnframes())
        data = []
        
        # Extract LSBs from each sample
        for i in range(0, len(frames), 2):  # 16-bit samples
            if i+1 < len(frames):
                sample = int.from_bytes(frames[i:i+2], byteorder='little', signed=True)
                lsb = sample & ((1 << num_lsb) - 1)
                data.append(lsb)
        
        # Convert to bytes
        bit_string = ''.join(format(x, f'0{num_lsb}b') for x in data)
        byte_data = bytes(int(bit_string[i:i+8], 2) for i in range(0, len(bit_string)-(len(bit_string)%8), 8))
        
        return byte_data

if len(sys.argv) > 1:
    result = extract_lsb(sys.argv[1], num_lsb=2)
    sys.stdout.buffer.write(result)
EOF
# Usage: python3 script.py stego.wav > output.bin
```

**Detecting LSB Steganography:** [Inference - statistical analysis]

```bash
# Visual inspection of LSB patterns
python3 << 'EOF'
import wave
import numpy as np
import sys

def analyze_lsb(wav_file):
    with wave.open(wav_file, 'rb') as wav:
        frames = wav.readframes(wav.getnframes())
        samples = np.frombuffer(frames, dtype=np.int16)
        
        # Extract LSBs
        lsbs = samples & 1
        
        # Statistical analysis
        print(f"Total samples: {len(lsbs)}")
        print(f"LSB=0: {np.sum(lsbs == 0)} ({np.sum(lsbs == 0)/len(lsbs)*100:.2f}%)")
        print(f"LSB=1: {np.sum(lsbs == 1)} ({np.sum(lsbs == 1)/len(lsbs)*100:.2f}%)")
        print(f"Chi-squared test for randomness: {np.var(lsbs):.4f}")
        
        # Expected: ~50/50 distribution for natural audio
        # Suspicious: highly skewed or perfectly balanced

if len(sys.argv) > 1:
    analyze_lsb(sys.argv[1])
EOF
# Usage: python3 script.py audio.wav
```

**Bruteforcing Unknown Parameters:**

```bash
# Try all LSB depths
for n in {1..4}; do
    echo "=== Testing n=$n ==="
    python3 wavsteg.py -r -i stego.wav -o output_n${n}.bin -n $n 2>/dev/null
    file output_n${n}.bin
    strings output_n${n}.bin | grep -i "flag\|ctf" || echo "Nothing found"
done

# Check for recognizable file signatures
for n in {1..4}; do
    xxd output_n${n}.bin | head -n 1
done
```

**Comparing Original and Stego Files:**

```bash
# Generate difference visualization
sox original.wav -n stat 2>&1 > original_stats.txt
sox stego.wav -n stat 2>&1 > stego_stats.txt
diff original_stats.txt stego_stats.txt

# Visual waveform comparison
ffmpeg -i original.wav -lavfi showwavespic=s=1920x1080 original_wave.png
ffmpeg -i stego.wav -lavfi showwavespic=s=1920x1080 stego_wave.png
compare original_wave.png stego_wave.png diff.png  # ImageMagick
```

---

**Important Related Topics:**

- **DTMF (Dual-Tone Multi-Frequency) decoding** for telephone keypad tones
- **SSTV (Slow Scan Television)** image transmission in audio
- **Morse code decoding** from audio patterns
- **Deep Sound** and other GUI steganography tools

---

## Analysis & Forensics

### volatility (memory)

Volatility is a memory forensics framework for analyzing volatile memory dumps (RAM). It identifies running processes, network connections, loaded modules, and other runtime artifacts.

#### Memory Dump Acquisition

Before analyzing memory, obtain a dump. On Linux:

```bash
sudo dd if=/dev/mem of=memory.dump bs=1M
```

On Windows (using external tools):

```bash
DumpIt.exe memory.dump
```

Alternatively, use `FTK Imager` or similar forensic tools.

#### Profile Identification

Volatility requires a profile matching the memory dump's OS and kernel version. List available profiles:

```bash
volatility -h | grep -i "profile"
volatility --info | grep "Profiles"
```

For Linux memory dumps, identify the kernel version:

```bash
strings memory.dump | grep -i "linux version"
```

Use the appropriate profile:

```bash
volatility -f memory.dump --profile=LinuxUbuntu_5_4_0-42-generic_x64 pslist
```

#### Process Analysis

List running processes at the time of the dump:

```bash
volatility -f memory.dump --profile=LinuxUbuntu_5_4_0-42-generic_x64 pslist
```

Output includes PID, process name, parent PID, and memory usage.

Show process details with more information:

```bash
volatility -f memory.dump --profile=LinuxUbuntu_5_4_0-42-generic_x64 pstree
```

This displays the process hierarchy in tree format.

#### Detecting Hidden Processes

Compare processes reported by pslist against other detection methods:

```bash
volatility -f memory.dump --profile=LinuxUbuntu_5_4_0-42-generic_x64 pslist > pslist.txt
volatility -f memory.dump --profile=LinuxUbuntu_5_4_0-42-generic_x64 psscan >> psscan.txt
diff pslist.txt psscan.txt
```

[Inference] Processes appearing in psscan but not pslist may indicate rootkits or hidden processes.

#### Network Connection Analysis

Examine active network connections:

```bash
volatility -f memory.dump --profile=LinuxUbuntu_5_4_0-42-generic_x64 netscan
```

Output includes protocol, local address/port, remote address/port, connection state, and associated PID.

For listening sockets:

```bash
volatility -f memory.dump --profile=LinuxUbuntu_5_4_0-42-generic_x64 netstat
```

#### Extracting Process Memory

Dump the memory of a specific process:

```bash
volatility -f memory.dump --profile=LinuxUbuntu_5_4_0-42-generic_x64 memdump -p [PID] -D output_dir/
```

The `-p` flag specifies the PID, `-D` designates the output directory.

Analyze the extracted memory:

```bash
strings output_dir/[PID].dmp | grep -i "flag\|password\|secret"
hexdump -C output_dir/[PID].dmp | head -50
```

#### Module and DLL Analysis

List loaded kernel modules (Linux):

```bash
volatility -f memory.dump --profile=LinuxUbuntu_5_4_0-42-generic_x64 lsmod
```

For Windows systems, list DLLs:

```bash
volatility -f memory.dump --profile=Win7SP1x64 dlllist -p [PID]
```

#### File Descriptor Analysis

Examine open files for a process:

```bash
volatility -f memory.dump --profile=LinuxUbuntu_5_4_0-42-generic_x64 lsof -p [PID]
```

Output includes file descriptors, file types (regular, socket, device), and file paths.

#### Volatility Plugins

Create custom plugins for targeted analysis. Plugin location:

```bash
ls /usr/lib/python3/dist-packages/volatility/plugins/
```

Example custom plugin structure:

```python
import volatility.plugins.common as common
import volatility.utils as utils

class CustomAnalysis(common.AbstractWindowsCommand):
    def render(self, outfd, data):
        for result in data:
            outfd.write(result)
```

#### Analyzing Suspicious Memory Regions

Search for strings in memory indicating malicious activity:

```bash
strings memory.dump | grep -E "nc.exe|cmd.exe|powershell|exploit"
```

For shellcode detection, look for common opcode patterns:

```bash
hexdump -C memory.dump | grep -E "55 89 e5|50 8b 45|ff 15"
```

These represent common x86 prologue and function call instructions.

#### Memory Forensics Workflow for CTF

```bash
#!/bin/bash
DUMP="memory.dump"
PROFILE="LinuxUbuntu_5_4_0-42-generic_x64"

echo "=== Process Analysis ==="
volatility -f $DUMP --profile=$PROFILE pslist

echo -e "\n=== Network Connections ==="
volatility -f $DUMP --profile=$PROFILE netscan

echo -e "\n=== Module Analysis ==="
volatility -f $DUMP --profile=$PROFILE lsmod

echo -e "\n=== Suspicious Strings ==="
strings $DUMP | grep -iE "flag|password|secret|admin"
```

### autopsy

Autopsy is a digital forensics platform with a web-based interface for analyzing file systems, recovering deleted files, and examining file metadata.

#### Installation and Setup

Install Autopsy on Debian/Ubuntu:

```bash
sudo apt-get install autopsy
```

On CentOS/RHEL:

```bash
sudo yum install autopsy
```

Start the Autopsy web server:

```bash
autopsy -d /var/log/autopsy &
```

Access via browser:

```
http://localhost:9999/autopsy
```

#### Creating a New Case

1. Launch Autopsy web interface
2. Click "New Case"
3. Enter case name and base directory
4. Add data source (image, device, or directory)

Alternatively, use command-line interface:

```bash
autopsy -d /var/log/autopsy &
```

#### Adding Data Sources

For forensic images:

1. Click "Add Data Source"
2. Select "Disk Image or VM File"
3. Specify image file path (E01, DD, AFF, etc.)
4. Choose ingest modules

For live file systems:

1. Click "Add Data Source"
2. Select "Local Disk"
3. Choose partition or directory

#### File System Analysis

After ingestion, examine the file system tree:

1. Click "Data Sources" tab
2. Browse directory hierarchy
3. Select files for detailed analysis

View file properties:

- Metadata (size, timestamps, permissions)
- Hash values (MD5, SHA-1, SHA-256)
- File type classification
- Content preview

#### Keyword Search

Search across all ingested data:

1. Click "Tools" → "Keyword Search"
2. Enter search terms
3. Select search scope (all data, specific source)
4. Review results with file context

For CTF challenges, search for common keywords:

```
flag
password
admin
secret
hint
key
```

#### Timeline Analysis

Create timelines of file activity:

1. Click "Timeline" tab
2. Select time range
3. Filter by file type or source
4. Analyze file creation/modification patterns

#### Deleted File Recovery

Autopsy integrates The Sleuth Kit for carving deleted files:

1. Configure ingest modules during data source addition
2. Enable "Carving" modules
3. Review recovered files in "Recovered Files" directory

Recovered files appear with hashed names pending validation.

#### Hash Analysis

Use hash databases to identify known files:

1. Click "Tools" → "Hash Lookup"
2. Configure NIST NSRL database (if available)
3. Files matching known hashes are flagged

Compare hash values against known good or malicious hashes.

#### Artifact Analysis

Autopsy extracts and analyzes artifacts from various file types:

- Image EXIF data
- Archive contents
- Document metadata
- Email headers

Access artifacts:

1. Click "Artifacts" tab
2. Filter by artifact type
3. View detailed information

#### Integration with The Sleuth Kit

Autopsy uses TSK internally. For command-line analysis of the same data:

```bash
istat image.dd [inode_number]
ffind image.dd [inode_number]
```

#### Creating Custom Ingest Modules

Develop Python-based modules for targeted analysis:

```python
from org.sleuthkit.autopsy.ingest import IngestModule
from org.sleuthkit.autopsy.ingest import IngestModuleFactoryAdapter

class CustomModule(IngestModule):
    def process(self, file):
        # Custom analysis logic
        pass
```

Place in Autopsy modules directory:

```bash
~/.autopsy/[case_name]/modules/
```

#### Exporting Analysis Results

Export findings to reports:

1. Click "Report Generation"
2. Select report format (HTML, Excel, PDF)
3. Choose modules and data to include
4. Generate and download report

#### CTF Forensics Workflow

```bash
# Add image to Autopsy case
# Configure ingest modules
# Search for suspicious files
# Recover deleted files
# Extract metadata
# Examine timeline
# Export findings
```

### sleuthkit

The Sleuth Kit (TSK) is a command-line collection of tools for file system analysis and forensic recovery. It provides low-level access to file systems.

#### Basic Image Analysis

List file system details:

```bash
fsstat image.dd
```

Output includes file system type, block size, inode count, and other metadata.

#### Inode Analysis

Display inode information:

```bash
istat image.dd [inode_number]
```

Output includes file permissions, size, timestamps, and block allocation.

Find inodes for a specific file:

```bash
find_inum image.dd -n "filename"
```

This locates all inodes matching the filename.

#### Directory Listing

List files in a directory by inode:

```bash
ils image.dd [directory_inode]
```

Use the root inode (typically 2 for Linux) to start:

```bash
ils image.dd 2
```

For allocated files only:

```bash
ils -a image.dd 2
```

For deleted files:

```bash
ils -d image.dd 2
```

#### File Content Recovery

Extract file contents by inode:

```bash
icat image.dd [inode_number] > recovered_file
```

This reads the actual file data, bypassing directory entries. Useful for extracting deleted files.

#### Block Analysis

Examine unallocated blocks:

```bash
blkstat image.dd [block_number]
```

Display block information including allocation status and content.

List all unallocated blocks:

```bash
blkls image.dd > unallocated.txt
wc -l unallocated.txt
```

#### Carving Deleted Files

Use `blkcat` to extract raw block data:

```bash
blkcat image.dd [start_block] [num_blocks] > recovered_data.bin
```

Analyze the recovered data:

```bash
file recovered_data.bin
strings recovered_data.bin
```

#### Journal Analysis

Examine file system journals (ext3/ext4):

```bash
jcat image.dd > journal.bin
strings journal.bin | grep -i "flag\|password"
```

#### Walking the File System Tree

Recursively list all files:

```bash
fls -r -p image.dd 2 > full_listing.txt
```

The `-r` flag enables recursion, `-p` preserves full paths.

#### Handling Different File Systems

Specify file system type explicitly:

```bash
fsstat -t ext4 image.dd
istat -t ext4 image.dd [inode_number]
```

Supported types: ext2, ext3, ext4, FAT, NTFS, HFS+, ISO9660, UFS.

#### Forensic Analysis Script

```bash
#!/bin/bash
IMAGE="$1"

echo "=== File System Info ==="
fsstat "$IMAGE"

echo -e "\n=== Deleted Files ==="
ils -d "$IMAGE" 2

echo -e "\n=== Unallocated Blocks ==="
blkls "$IMAGE" | head -20

echo -e "\n=== File Listing ==="
fls -r -p "$IMAGE" 2 | head -50
```

#### Integrating with Other Tools

Combine TSK with `strings` for comprehensive analysis:

```bash
for inode in $(ils -d image.dd 2 | awk '{print $1}' | sed 's/[-*]//'); do
    icat image.dd "$inode" | strings | grep -i "flag"
done
```

### scalpel

Scalpel is a file carving utility that recovers deleted files by searching for file signatures and extracting data between them.

#### Configuration

Scalpel uses a configuration file defining file types. View default configuration:

```bash
cat /etc/scalpel/scalpel.conf
```

Configuration format:

```
jpg y 200000 ÿØÿà ÿÙ
png y 500000 ‰PNG\r\n\x1a\n \0\0\0\rIHDR
zip y 100000 PK\x03\x04 PK\x05\x06
```

Columns: extension, case-sensitive, max file size, header signature, footer signature.

#### Basic File Carving

Carve files using default configuration:

```bash
scalpel -i image.dd -o output_dir
```

Parameters: `-i` (input image), `-o` (output directory).

#### Custom Configuration

Create a custom configuration file:

```bash
cat > custom_scalpel.conf << 'EOF'
jpg y 200000 ÿØÿà ÿÙ
flag y 1000 flag{ }
EOF
```

Use custom configuration:

```bash
scalpel -c custom_scalpel.conf -i image.dd -o output_dir
```

#### Specifying File Types

Carve only specific file types:

```bash
scalpel -i image.dd -o output_dir -e jpg,png,zip
```

The `-e` flag lists file extensions to carve.

#### Verbose Output

Display detailed progress:

```bash
scalpel -i image.dd -o output_dir -v
```

#### Quick Preview

Scan without extraction (preview mode):

```bash
scalpel -i image.dd -p
```

This identifies recoverable files without writing output.

#### Analyzing Carved Files

After carving, examine recovered files:

```bash
ls -lR output_dir/
file output_dir/*/*
```

Validate recovered files:

```bash
for file in output_dir/jpg/*.jpg; do
    if identify "$file" > /dev/null 2>&1; then
        echo "Valid: $file"
    else
        echo "Invalid: $file"
        rm "$file"
    fi
done
```

#### Extracting Strings from Carved Data

Search carved files for text:

```bash
find output_dir -type f -exec strings {} \; | grep -i "flag\|password"
```

#### Handling Large Images

For large forensic images, limit carving to specific offsets:

```bash
dd if=image.dd bs=1M skip=100 count=100 | scalpel -i - -o output_dir
```

This carves only bytes 100MB-200MB.

#### Comparing Scalpel to Foremost

[Inference] Scalpel and foremost are similar file carving tools. Scalpel offers more detailed configuration and faster performance on large images, while foremost provides simpler default usage. For CTF challenges, try both if one fails.

#### CTF Carving Workflow

```bash
#!/bin/bash
IMAGE="$1"

echo "Carving files with default config..."
scalpel -i "$IMAGE" -o carved_default/

echo "Carving specific types..."
scalpel -i "$IMAGE" -o carved_text/ -e txt,flag,md5

echo "Examining carved files..."
find carved_default -type f -exec file {} \;
find carved_text -type f -exec strings {} \; | grep -E "^[A-Za-z0-9]{32,}$"
```

### photorec

PhotoRec is a data recovery tool specifically designed for recovering deleted files from media and disk images. Unlike scalpel, it's optimized for photo and media recovery but works with various file types.

#### Basic Recovery

Recover files from a disk image:

```bash
photorec /d output_dir image.dd
```

Parameters: `/d` (output directory), image file. PhotoRec uses an interactive menu.

Non-interactive mode:

```bash
photorec /d output_dir image.dd /cmd
```

The `/cmd` flag runs without interactive prompts using default settings.

#### File Type Selection

Specify which file types to recover:

Create a `.photorec` configuration file:

```bash
cat > ~/.photorec/photorec.cfg << 'EOF'
# Uncomment to enable file type recovery
jpg
png
gif
zip
txt
pdf
EOF
```

Modify through interactive menu:

1. Run `photorec`
2. Select partition/image
3. Choose "File Opt" to configure file types
4. Enable/disable types
5. Start recovery

#### Advanced Options

Log recovery session:

```bash
photorec /d output_dir /log photorec.log image.dd /cmd
```

Specify offset to start recovery:

```bash
photorec /d output_dir /skip N image.dd /cmd
```

The `/skip N` flag starts recovery at offset N blocks.

#### Analyzing Recovered Files

PhotoRec creates a `recup_dir.X/` directory structure. Analyze recovered files:

```bash
find recup_dir.1 -type f -exec file {} \;
```

Search for text content:

```bash
find recup_dir.1 -type f -exec strings {} \; | grep -i "flag"
```

#### Validating Recovered Media

Check integrity of recovered images:

```bash
for file in recup_dir.1/*/*.jpg; do
    if identify "$file" > /dev/null 2>&1; then
        echo "Valid: $file"
    fi
done
```

#### Large-Scale Recovery

For massive recovery operations, use multiple instances on different offsets:

```bash
photorec /d output_dir1 /skip 0 image.dd /cmd &
photorec /d output_dir2 /skip 1000000 image.dd /cmd &
wait
```

Combine results:

```bash
find output_dir1 output_dir2 -type f -name "*" | sort | uniq
```

#### Configuration Optimization

Create optimized recovery configuration for CTF scenarios:

```bash
cat > ctf_photorec.cfg << 'EOF'
zip
txt
md5
flag
jpg
png
gif
exe
elf
EOF
```

Use custom config:

```bash
cp ctf_photorec.cfg ~/.photorec/photorec.cfg
photorec /d output_dir image.dd /cmd
```

#### Searching Recovered Data

Filter recovered files by size or type:

```bash
find recup_dir.1 -type f -size +1k -size -100k -exec file {} \; | grep -i "text"
```

Extract text from recovered files:

```bash
find recup_dir.1 -type f -exec strings {} \; | grep -E "^flag{.*}$"
```

#### Comparing PhotoRec to Other Tools

PhotoRec excels at media recovery and handles unallocated space well. For CTF challenges involving disk images with deleted files, PhotoRec often recovers files that other tools miss. [Inference] Its optimization for common file types makes it particularly effective for mixed-content disk images.

#### CTF Recovery Workflow

```bash
#!/bin/bash
IMAGE="$1"
OUTPUT="recovered_files"

echo "Running PhotoRec recovery..."
photorec /d "$OUTPUT" "$IMAGE" /cmd

echo "Searching for flags..."
find "$OUTPUT" -type f -exec strings {} \; | grep -E "flag{|FLAG{|password|secret"

echo "Analyzing file types..."
find "$OUTPUT" -type f -exec file {} \; | sort | uniq -c | sort -rn
```

### testdisk

TestDisk is a partition recovery tool designed to recover lost partitions and repair partition tables. It's particularly useful for disk images with corrupted MBR or partition table damage.

#### Interactive Mode

Launch TestDisk interactively:

```bash
testdisk
```

Menu-driven interface allows:

1. Select storage device or image
2. Choose partition table type (MBR, GPT, etc.)
3. Analyze for lost partitions
4. Preview recovered partitions
5. Write recovered partitions to disk

#### Non-Interactive Mode

For scripted recovery, use command-line options:

```bash
testdisk -l image.dd
```

The `-l` flag lists all partitions found in the image.

#### Partition Analysis

Detailed partition analysis:

```bash
testdisk /log testdisk.log image.dd
```

Generates a log file with recovery details:

```bash
cat testdisk.log
```

#### Recovering Lost Partitions

Recover and preview partitions without writing:

```bash
testdisk /debug image.dd
```

This runs in debug mode, helpful for understanding recovery issues.

#### MBR Recovery

TestDisk can repair corrupted Master Boot Records. For disk images:

1. Run `testdisk` interactively
2. Select image file
3. Choose "MBR" partition type
4. Select "Analyze"
5. Review found partitions
6. Select "Write" to commit changes to a new image

#### GPT Partition Recovery

For GUID Partition Table (GPT) systems:

1. Select "GPT" in partition type menu
2. Proceed with analysis
3. Preview recovered partitions

#### Extracting Recovered Partitions

After recovery, extract the recovered partition:

```bash
dd if=image.dd of=recovered_partition.img bs=512 skip=[start_sector] count=[num_sectors]
```

Calculate sectors from TestDisk output.

#### Mounting Recovered Partitions

After extraction, mount the recovered partition:

```bash
mkdir -p mount_point
sudo mount -o loop recovered_partition.img mount_point
ls mount_point
```

#### Analyzing Recovered File Systems

Use TSK or Autopsy on the mounted partition:

```bash
ls -la mount_point/
find mount_point -type f -name "*flag*"
strings mount_point/file.bin | grep -i "flag"
```

#### Comparing Disk Images

Verify recovered partition integrity by comparing sectors:

```bash
dd if=original_disk.dd bs=512 skip=[start] count=[size] | md5sum
dd if=recovered_partition.img | md5sum
```

Matching hashes confirm successful recovery.

#### CTF Disk Recovery Workflow

```bash
#!/bin/bash
IMAGE="$1"

echo "=== Analyzing disk image ==="
testdisk -l "$IMAGE"

echo -e "\n=== Detailed analysis ==="
testdisk /debug "$IMAGE" 2>&1 | tee testdisk_analysis.log

# Manually extract partition using dd based on testdisk output
# Then mount and analyze

echo -e "\n=== Searching for flags in recovered data ==="
mount_point="/mnt/recovered"
find "$mount_point" -type f -exec strings {} \; | grep -iE "flag|password"
```

#### Advanced Partition Recovery

For complex scenarios with multiple partition tables or unusual structures, document findings:

```bash
testdisk -l "$IMAGE" > partition_list.txt
cat partition_list.txt
```

Manually parse the output to identify recoverable partitions:

```bash
grep "Primary" partition_list.txt
```

TestDisk excels at recovering partitions deleted from partition tables. For CTF challenges involving disk images with missing partitions, it's an essential tool.

---

## Scripting & Custom Tools

### Python PIL/Pillow

PIL (Python Imaging Library) and its modern fork Pillow are essential for image manipulation, metadata extraction, and pixel-level steganography analysis in CTF challenges.

#### Installation

Install Pillow:

```bash
pip install Pillow
```

Verify installation:

```python
from PIL import Image
print(Image.OPEN)
```

#### Basic Image Loading and Display

Load an image:

```python
from PIL import Image

img = Image.open('target.png')
print(f"Size: {img.size}")
print(f"Format: {img.format}")
print(f"Mode: {img.mode}")
```

Image modes: RGB, RGBA, L (grayscale), 1 (binary), P (palette), CMYK.

Display image properties:

```python
img.show()  # Opens in default viewer
img.save('copy.png')
```

#### Pixel-Level Access

Access individual pixel values:

```python
from PIL import Image

img = Image.open('target.png')
pixels = img.load()

# Get pixel at (x, y)
pixel = pixels[100, 50]
print(pixel)

# Iterate all pixels
for x in range(img.width):
    for y in range(img.height):
        r, g, b = pixels[x, y][:3]
        # Analyze or modify
```

For large images, use `getdata()` for efficiency:

```python
pixel_data = list(img.getdata())
```

#### Extracting Hidden Data from LSBs

Extract least significant bits (LSB) steganography:

```python
from PIL import Image

def extract_lsb(image_path):
    img = Image.open(image_path)
    pixels = img.load()
    
    binary = ''
    for y in range(img.height):
        for x in range(img.width):
            pixel = pixels[x, y]
            r, g, b = pixel[:3]
            binary += str(r & 1)
    
    # Convert binary to text
    message = ''
    for i in range(0, len(binary), 8):
        byte = binary[i:i+8]
        if len(byte) == 8:
            message += chr(int(byte, 2))
    
    return message

hidden_message = extract_lsb('target.png')
print(hidden_message)
```

#### Analyzing Color Channels

Separate and analyze color channels:

```python
from PIL import Image

img = Image.open('target.png')

# Split into R, G, B channels
r, g, b = img.split()

# Analyze channel separately
r_data = list(r.getdata())
print(f"Red channel min: {min(r_data)}, max: {max(r_data)}")

# Save individual channel as grayscale
r.save('red_channel.png')
g.save('green_channel.png')
b.save('blue_channel.png')
```

#### Detecting Steganography Through Statistical Analysis

Analyze pixel distribution for anomalies:

```python
from PIL import Image
import statistics

img = Image.open('target.png')
pixels = list(img.convert('RGB').getdata())

# Extract LSBs
lsbs = [pixel[0] & 1 for pixel in pixels]

# Calculate statistics
lsb_mean = statistics.mean(lsbs)
lsb_stdev = statistics.stdev(lsbs) if len(lsbs) > 1 else 0

print(f"LSB Mean: {lsb_mean}")
print(f"LSB Stdev: {lsb_stdev}")

# Random data has mean ~0.5 and stdev ~0.5
if lsb_mean > 0.6 or lsb_stdev < 0.3:
    print("Potential steganography detected")
```

#### Embedding Data in Images

Hide data in LSBs:

```python
from PIL import Image

def embed_lsb(image_path, message, output_path):
    img = Image.open(image_path)
    pixels = img.load()
    
    # Convert message to binary
    binary = ''.join(format(ord(c), '08b') for c in message)
    
    # Pad binary
    while len(binary) < img.width * img.height:
        binary += '0'
    
    bit_index = 0
    for y in range(img.height):
        for x in range(img.width):
            if bit_index >= len(binary):
                break
            
            pixel = list(pixels[x, y])
            # Modify LSB of red channel
            pixel[0] = (pixel[0] & 0xFE) | int(binary[bit_index])
            pixels[x, y] = tuple(pixel)
            bit_index += 1
    
    img.save(output_path)

embed_lsb('cover.png', 'hidden message', 'stego.png')
```

#### Converting Image Formats

Convert between image formats:

```python
from PIL import Image

img = Image.open('target.jpg')
img.save('target.png')
img.save('target.bmp')
img.convert('RGB').save('target_rgb.png')
```

#### Resizing and Cropping

Manipulate image dimensions:

```python
from PIL import Image

img = Image.open('target.png')

# Resize
resized = img.resize((800, 600))
resized.save('resized.png')

# Crop
cropped = img.crop((100, 100, 300, 300))
cropped.save('cropped.png')

# Tile
tiles = []
for y in range(0, img.height, 64):
    for x in range(0, img.width, 64):
        tile = img.crop((x, y, x+64, y+64))
        tiles.append(tile)
```

#### EXIF Data Extraction

Extract metadata from images:

```python
from PIL import Image
from PIL.ExifTags import TAGS

img = Image.open('target.jpg')
exif_data = img._getexif()

if exif_data:
    for tag_id, value in exif_data.items():
        tag_name = TAGS.get(tag_id, tag_id)
        print(f"{tag_name}: {value}")
```

#### Image Comparison

Compare two images for differences:

```python
from PIL import Image

img1 = Image.open('image1.png')
img2 = Image.open('image2.png')

pixels1 = list(img1.convert('RGB').getdata())
pixels2 = list(img2.convert('RGB').getdata())

differences = 0
for p1, p2 in zip(pixels1, pixels2):
    if p1 != p2:
        differences += 1

print(f"Different pixels: {differences} / {len(pixels1)}")
```

### Python wave/scipy

The `wave` module handles WAV audio files, while `scipy.signal` provides digital signal processing tools for analyzing steganography in audio.

#### Installation

Install scipy:

```bash
pip install scipy numpy
```

#### Reading WAV Files

Load and analyze WAV audio:

```python
import wave

with wave.open('audio.wav', 'rb') as wav_file:
    n_channels = wav_file.getnchannels()
    sample_width = wav_file.getsampwidth()
    frame_rate = wav_file.getframerate()
    n_frames = wav_file.getnframes()
    
    print(f"Channels: {n_channels}")
    print(f"Sample width: {sample_width} bytes")
    print(f"Frame rate: {frame_rate} Hz")
    print(f"Duration: {n_frames / frame_rate:.2f} seconds")
    
    # Read audio data
    audio_data = wav_file.readframes(n_frames)
```

#### Converting WAV to Numpy Array

Process audio data numerically:

```python
import wave
import numpy as np

with wave.open('audio.wav', 'rb') as wav_file:
    n_channels = wav_file.getnchannels()
    sample_width = wav_file.getsampwidth()
    frame_rate = wav_file.getframerate()
    n_frames = wav_file.getnframes()
    
    audio_data = wav_file.readframes(n_frames)
    
    # Convert to numpy array
    audio_array = np.frombuffer(audio_data, dtype=np.int16)
    
    # Reshape for stereo
    if n_channels == 2:
        audio_array = audio_array.reshape(-1, 2)
```

#### Extracting LSBs from Audio

Extract hidden data from audio LSBs:

```python
import wave
import numpy as np

def extract_audio_lsb(wav_file):
    with wave.open(wav_file, 'rb') as f:
        n_channels = f.getnchannels()
        sample_width = f.getsampwidth()
        n_frames = f.getnframes()
        
        audio_data = f.readframes(n_frames)
        audio_array = np.frombuffer(audio_data, dtype=np.int16)
    
    # Extract LSBs
    lsbs = audio_array & 1
    
    # Convert binary to text
    binary = ''.join(str(bit) for bit in lsbs)
    message = ''
    for i in range(0, len(binary), 8):
        byte = binary[i:i+8]
        if len(byte) == 8 and int(byte, 2) != 0:
            message += chr(int(byte, 2))
    
    return message

hidden_message = extract_audio_lsb('audio.wav')
print(hidden_message)
```

#### Frequency Analysis with FFT

Analyze audio frequency spectrum:

```python
import wave
import numpy as np
from scipy.fft import fft

with wave.open('audio.wav', 'rb') as wav_file:
    frame_rate = wav_file.getframerate()
    n_frames = wav_file.getnframes()
    audio_data = wav_file.readframes(n_frames)
    
    audio_array = np.frombuffer(audio_data, dtype=np.int16)

# Compute FFT
fft_result = fft(audio_array)
frequencies = np.fft.fftfreq(len(audio_array), 1/frame_rate)

# Find peak frequencies
magnitude = np.abs(fft_result)
peak_indices = np.argsort(magnitude)[-10:]  # Top 10 peaks

for idx in reversed(peak_indices):
    print(f"Frequency: {frequencies[idx]:.2f} Hz, Magnitude: {magnitude[idx]:.2f}")
```

#### Spectrogram Analysis

Create a spectrogram to visualize hidden data:

```python
import wave
import numpy as np
from scipy import signal
import matplotlib.pyplot as plt

with wave.open('audio.wav', 'rb') as wav_file:
    frame_rate = wav_file.getframerate()
    n_frames = wav_file.getnframes()
    audio_data = wav_file.readframes(n_frames)
    
    audio_array = np.frombuffer(audio_data, dtype=np.int16)

# Generate spectrogram
f, t, Sxx = signal.spectrogram(audio_array, frame_rate)

plt.pcolormesh(t, f, 10 * np.log10(Sxx + 1e-10), shading='gouraud')
plt.ylabel('Frequency [Hz]')
plt.xlabel('Time [sec]')
plt.title('Spectrogram')
plt.savefig('spectrogram.png')
plt.close()

print("Spectrogram saved as spectrogram.png")
```

#### Creating WAV Files

Write audio data to WAV:

```python
import wave
import numpy as np

# Generate a simple tone
sample_rate = 44100
duration = 2
frequency = 440  # A4 note

samples = np.linspace(0, duration, int(sample_rate * duration))
waveform = np.sin(2 * np.pi * frequency * samples)

# Scale to 16-bit range
waveform_int16 = (waveform * 32767).astype(np.int16)

# Write to WAV file
with wave.open('output.wav', 'wb') as wav_file:
    wav_file.setnchannels(1)
    wav_file.setsampwidth(2)
    wav_file.setframerate(sample_rate)
    wav_file.writeframes(waveform_int16.tobytes())
```

#### Embedding Data in Audio

Hide data in audio LSBs:

```python
import wave
import numpy as np

def embed_audio_lsb(wav_file, message, output_file):
    with wave.open(wav_file, 'rb') as f:
        n_channels = f.getnchannels()
        sample_width = f.getsampwidth()
        frame_rate = f.getframerate()
        n_frames = f.getnframes()
        
        audio_data = f.readframes(n_frames)
        audio_array = np.frombuffer(audio_data, dtype=np.int16)
    
    # Convert message to binary
    binary = ''.join(format(ord(c), '08b') for c in message)
    
    # Embed in LSBs
    for i, bit in enumerate(binary):
        if i < len(audio_array):
            audio_array[i] = (audio_array[i] & 0xFFFE) | int(bit)
    
    # Write to new WAV file
    with wave.open(output_file, 'wb') as f:
        f.setnchannels(n_channels)
        f.setsampwidth(sample_width)
        f.setframerate(frame_rate)
        f.writeframes(audio_array.astype(np.int16).tobytes())
```

#### Analyzing Phase Changes

Detect phase-based steganography:

```python
import wave
import numpy as np
from scipy.fft import fft, ifft

with wave.open('audio.wav', 'rb') as wav_file:
    frame_rate = wav_file.getframerate()
    n_frames = wav_file.getnframes()
    audio_data = wav_file.readframes(n_frames)
    
    audio_array = np.frombuffer(audio_data, dtype=np.int16)

# Analyze phase in frequency domain
fft_result = fft(audio_array)
phase = np.angle(fft_result)

# Detect unusual phase patterns
phase_diff = np.diff(phase)
suspicious_indices = np.where(np.abs(phase_diff) > 1.0)[0]

print(f"Suspicious phase transitions at {len(suspicious_indices)} locations")
if len(suspicious_indices) > 0:
    print(f"First few: {suspicious_indices[:10]}")
```

### Python struct

The `struct` module packs and unpacks binary data according to format specifications, essential for parsing binary file formats and manipulating raw bytes.

#### Basic Packing and Unpacking

Pack Python values into binary strings:

```python
import struct

# Pack a 32-bit unsigned integer
data = struct.pack('I', 0x12345678)
print(data)  # b'xV4\x12' (little-endian)

# Pack multiple values
data = struct.pack('IHB', 0x12345678, 0x1234, 0xFF)
print(data)

# Unpack
values = struct.unpack('IHB', data)
print(values)  # (305419896, 4660, 255)
```

#### Format Specifiers

Common format characters:

- `b`: signed char (1 byte)
- `B`: unsigned char (1 byte)
- `h`: signed short (2 bytes)
- `H`: unsigned short (2 bytes)
- `i`: signed int (4 bytes)
- `I`: unsigned int (4 bytes)
- `q`: signed long long (8 bytes)
- `Q`: unsigned long long (8 bytes)
- `f`: float (4 bytes)
- `d`: double (8 bytes)
- `s`: char[] (string of bytes)
- `p`: Pascal string (length-prefixed)

#### Endianness

Specify byte order:

```python
import struct

# Little-endian (default: '@')
data_le = struct.pack('<I', 0x12345678)

# Big-endian
data_be = struct.pack('>I', 0x12345678)

# Network byte order (big-endian)
data_net = struct.pack('!I', 0x12345678)

print(f"Little-endian: {data_le.hex()}")
print(f"Big-endian: {data_be.hex()}")
print(f"Network: {data_net.hex()}")
```

#### Parsing Binary File Headers

Parse file structures using struct:

```python
import struct

def parse_bmp_header(filename):
    with open(filename, 'rb') as f:
        # BMP file header (14 bytes)
        header = f.read(14)
        signature, file_size, reserved, offset = struct.unpack('<2sIHHI', header)
        
        print(f"Signature: {signature}")
        print(f"File size: {file_size} bytes")
        print(f"Pixel data offset: {offset} bytes")
        
        # BMP info header (40 bytes)
        info_header = f.read(40)
        width, height, planes, bits_per_pixel = struct.unpack('<IIHH', info_header[:12])
        
        print(f"Width: {width} pixels")
        print(f"Height: {height} pixels")
        print(f"Bits per pixel: {bits_per_pixel}")

parse_bmp_header('image.bmp')
```

#### Reading Binary Data Sequentially

Process binary files byte-by-byte:

```python
import struct

def extract_shorts(filename):
    with open(filename, 'rb') as f:
        while True:
            data = f.read(2)
            if not data:
                break
            
            value, = struct.unpack('H', data)  # Unpack as unsigned short
            print(f"0x{value:04x}")

extract_shorts('data.bin')
```

#### Constructing Binary Data

Build complex binary structures:

```python
import struct

def create_custom_header(magic, size, version):
    # Pack: magic (4 bytes), size (4 bytes), version (2 bytes)
    header = struct.pack('<4sIH', magic.encode(), size, version)
    return header

header = create_custom_header('FLAG', 1024, 1)
with open('custom.bin', 'wb') as f:
    f.write(header)
```

#### Handling Alignment and Padding

Account for struct alignment:

```python
import struct

# Without alignment (native)
size_native = struct.calcsize('BH')  # char + short
print(f"Native: {size_native} bytes")

# With explicit padding
size_packed = struct.calcsize('=BH')  # Standard
size_native2 = struct.calcsize('@BH')  # Native
size_native3 = struct.calcsize('BH')

print(f"Packed: {size_packed}, Native: {size_native2}")
```

#### Extracting Embedded Data

Parse structured embedded data:

```python
import struct

def extract_embedded_metadata(binary_file):
    with open(binary_file, 'rb') as f:
        # Skip to offset 100
        f.seek(100)
        
        # Read metadata structure
        metadata = f.read(32)
        id_num, timestamp, flags, crc = struct.unpack('<IIHH', metadata[:12])
        
        print(f"ID: {id_num}")
        print(f"Timestamp: {timestamp}")
        print(f"Flags: 0x{flags:04x}")
        print(f"CRC: 0x{crc:04x}")

extract_embedded_metadata('data.bin')
```

### Python binascii

The `binascii` module converts between binary and hexadecimal/ASCII representations, essential for hex string manipulation and encoding operations.

#### Hexadecimal Conversion

Convert between hex strings and binary:

```python
import binascii

# Binary to hex
data = b'Hello'
hex_string = binascii.hexlify(data)
print(hex_string)  # b'48656c6c6f'

# Hex to binary
recovered = binascii.unhexlify(hex_string)
print(recovered)  # b'Hello'
```

#### Base64 Encoding/Decoding

While primarily in `base64` module, binascii supports related operations:

```python
import binascii
import base64

data = b'Secret message'

# Base64 encoding
encoded = base64.b64encode(data)
print(encoded)  # b'U2VjcmV0IG1lc3NhZ2U='

# Base64 decoding
decoded = base64.b64decode(encoded)
print(decoded)  # b'Secret message'

# Hex representation of base64
hex_rep = binascii.hexlify(encoded)
print(hex_rep)
```

#### CRC Checksum Calculation

Compute CRC checksums:

```python
import binascii

data = b'test data'

# CRC-32
crc32_value = binascii.crc32(data)
print(f"CRC-32: 0x{crc32_value:08x}")

# Different data produces different CRC
data2 = b'modified data'
crc32_value2 = binascii.crc32(data2)
print(f"CRC-32 (modified): 0x{crc32_value2:08x}")
```

#### Hex String Parsing

Parse and analyze hex strings:

```python
import binascii

hex_data = "48656c6c6f20466c6167"

# Convert to binary
binary_data = binascii.unhexlify(hex_data)
print(binary_data)  # b'Hello Flag'

# Display as hex
display_hex = binascii.hexlify(binary_data)
print(display_hex)  # b'48656c6c6f20466c6167'

# Search for patterns in hex
if b'666c6167' in display_hex:  # 'flag' in hex
    print("Found 'flag' in hex data")
```

#### Converting Hex to ASCII

Extract readable strings from hex:

```python
import binascii

def hex_to_ascii(hex_string):
    try:
        binary = binascii.unhexlify(hex_string)
        return binary.decode('ascii', errors='ignore')
    except:
        return None

hex_input = "5365637265742046696c6567"
ascii_output = hex_to_ascii(hex_input)
print(ascii_output)  # 'Secret Flag'
```

#### Working with Binary Files

Extract and analyze hex from binary files:

```python
import binascii

def file_to_hex(filename, limit=100):
    with open(filename, 'rb') as f:
        data = f.read(limit)
    
    hex_string = binascii.hexlify(data).decode('ascii')
    return hex_string

def hex_from_file_at_offset(filename, offset, length):
    with open(filename, 'rb') as f:
        f.seek(offset)
        data = f.read(length)
    
    return binascii.hexlify(data).decode('ascii')

# Extract first 64 bytes as hex
hex_data = file_to_hex('target.bin', 64)
print(hex_data)

# Extract 32 bytes starting at offset 256
offset_data = hex_from_file_at_offset('target.bin', 256, 32)
print(offset_data)
```

#### Detecting File Signatures in Hex

Identify file types from hex:

```python
import binascii

file_signatures = {
    'FFD8FF': 'JPEG',
    '89504E47': 'PNG',
    '504B0304': 'ZIP',
    '52617221': 'RAR',
    '7A7A': '7Z',
}

def identify_file_type(filename):
    with open(filename, 'rb') as f:
        header = f.read(4)
    
    hex_header = binascii.hexlify(header).decode('ascii').upper()
    
    for sig, file_type in file_signatures.items():
        if hex_header.startswith(sig):
            return file_type
    
    return "Unknown"

print(identify_file_type('target.bin'))
```

#### Hex String Manipulation

Modify hex strings for analysis:

```python
import binascii

# Swap bytes (endianness)
def swap_endianness(hex_string):
    binary = binascii.unhexlify(hex_string)
    reversed_binary = binary[::-1]
    return binascii.hexlify(reversed_binary).decode('ascii')

original = "12345678"
swapped = swap_endianness(original)
print(f"Original: {original}")
print(f"Swapped: {swapped}")  # 78563412

# Insert bytes
def insert_at_offset(hex_string, offset, insert_hex):
    binary = binascii.unhexlify(hex_string)
    insert_binary = binascii.unhexlify(insert_hex)
    
    modified = binary[:offset] + insert_binary + binary[offset:]
    return binascii.hexlify(modified).decode('ascii')

result = insert_at_offset("0102030405", 2, "AABB")
print(result)  # 0102aabb030405
```

### Bash scripting

Bash scripts automate CTF workflows, combining command-line tools for efficient analysis and data extraction.

#### Basic Script Structure

Create executable scripts:

```bash
#!/bin/bash
# Script description

echo "Processing target.bin..."

# Variables
target="target.bin"
output_dir="output"

# Create directory
mkdir -p "$output_dir"

# Process file
file "$target"
strings "$target" | head -20
```

Make executable:

```bash
chmod +x script.sh
./script.sh
```

#### Iterating Over Files

Process multiple files:

```bash
#!/bin/bash

for file in *.jpg; do
    echo "Processing: $file"
    exiftool "$file" >> metadata.txt
done

# Find and process
find . -name "*.zip" -type f | while read -r archive; do
    echo "Extracting: $archive"
    unzip -q "$archive" -d "${archive%.zip}_extracted"
done
```

#### Conditional Logic

Execute commands conditionally:

```bash
#!/bin/bash

target="$1"

if [ ! -f "$target" ]; then
    echo "Error: File not found"
    exit 1
fi

file_type=$(file -b "$target")

if [[ "$file_type" == *"ZIP"* ]]; then
    echo "Extracting ZIP..."
    unzip "$target"
elif [[ "$file_type" == *"RAR"* ]]; then
    echo "Extracting RAR..."
    unrar x "$target"
else
    echo "Unknown type: $file_type"
fi
```

#### String Manipulation

Parse and extract data:

```bash
#!/bin/bash

# Extract strings matching pattern
strings "$1" | grep -E "flag{|FLAG{" > flags.txt

# Process line by line
while IFS= read -r line; do
    echo "Found: $line"
done < flags.txt

# Extract hex values
hexdump -C "$1" | grep "504b" | awk '{print $1}'
```

#### Parallel Processing

Speed up large operations:

```bash
#!/bin/bash

# Process files in parallel
find . -name "*.png" -type f | parallel stegseek --crack {} wordlist.txt

# Or using GNU parallel with limit
ls *.tar.gz | parallel -j 4 tar -xzf {}

# Using xargs for parallel processing
find . -name "*.jpg" | xargs -P 4 -I {} bash -c 'exiftool {} >> metadata.txt'
```

#### Error Handling

Implement robust error handling:

```bash
#!/bin/bash

set -e  # Exit on error
set -u  # Exit on undefined variable
set -o pipefail  # Fail if any command in pipe fails

function cleanup() {
    echo "Cleaning up..."
    rm -rf temp_*
}

trap cleanup EXIT

# Commands
target="$1" || { echo "Usage: $0 <target>"; exit 1; }

if ! command -v binwalk &> /dev/null; then
    echo "Error: binwalk not installed"
    exit 1
fi

binwalk -e "$target"
```

#### Function Definition

Create reusable functions:

```bash
#!/bin/bash

function extract_archive() {
    local archive="$1"
    local output_dir="${2:-.}"
    
    local file_type=$(file -b "$archive")
    
    case "$file_type" in
        *ZIP*) unzip -q "$archive" -d "$output_dir" ;;
        *RAR*) unrar x -q "$archive" "$output_dir" ;;
        *7-zip*) 7z x -q "$archive" -o"$output_dir" ;;
        *gzip*) tar -xzf "$archive" -C "$output_dir" ;;
        *) echo "Unknown format: $file_type"; return 1 ;;
    esac
}

function search_for_flags() {
    local directory="$1"
    
    find "$directory" -type f -exec strings {} \; | grep -iE "flag{|FLAG{|password|secret"
}

# Usage
extract_archive "archive.zip" "extracted"
search_for_flags "extracted"
```

#### Data Processing Pipeline

Chain tools for complex analysis:

```bash
#!/bin/bash

# Extract archive, search for hidden data, generate report
target="$1"

echo "=== Extracting archive ==="
binwalk -e "$target" -D "=bin"

echo -e "\n=== Searching for strings ==="
find _${target}.extracted -type f -exec strings {} \; | tee strings_output.txt

echo -e "\n=== Analyzing for suspicious patterns ==="
grep -iE "flag|password|admin|secret" strings_output.txt | tee findings.txt

echo -e "\n=== Checking file types ==="
find _${target}.extracted -type f -exec file {} \; | sort | uniq -c

echo -e "\n=== Report ==="
wc -l findings.txt
```

#### CTF Automation Script

Comprehensive automated analysis:

```bash
#!/bin/bash

TARGET="${1:?Error: Provide target file}"
REPORT="ctf_analysis_$(date +%s).txt"

{
    echo "=== CTF Analysis Report ==="
    echo "Target: $TARGET"
    echo "Date: $(date)"
    echo ""
    
    echo "=== File Information ==="
    file "$TARGET"
    ls -lh "$TARGET"
    echo ""
    
    echo "=== Binwalk Analysis ==="
    binwalk "$TARGET"
    echo ""
    
    echo "=== Extract Strings ==="
    strings "$TARGET" | grep -iE "flag|password|secret|key" | head -20
    echo ""
    
    echo "=== Hex Dump (first 256 bytes) ==="
    hexdump -C "$TARGET" | head -20
    echo ""
    
    echo "=== Extract Archive ==="
    binwalk -e "$TARGET" > /dev/null 2>&1 && echo "Extraction successful"
    
    if [ -d "_${TARGET}.extracted" ]; then
        echo -e "\n=== Extracted Contents ==="
        find "_${TARGET}.extracted" -type f | head -20
    fi
} | tee "$REPORT"

echo "Report saved to: $REPORT"
```

### CyberChef

CyberChef is a web-based tool for encoding, decoding, and data transformation. It's available at https://cyberchef.org and is essential for CTF challenges involving multiple encoding layers, data format conversions, and cryptographic operations.

#### Accessing CyberChef

Open in browser:

```
https://cyberchef.org
```

For offline use, clone the repository:

```bash
git clone https://github.com/gchq/CyberChef.git
cd CyberChef
npm install
npm start
```

Access local instance at `http://localhost:8080`.

#### Recipe Building

Create encoding/decoding chains by dragging operations into the recipe panel. Common workflow:

1. Paste input data in "Input" tab
2. Search for operations in left panel
3. Drag operations to recipe area
4. Configure operation parameters
5. View output in real-time

#### Common Encoding Operations

Encode data to Base64:

```
Input: "flag{secret}"
Operation: To Base64
Output: "ZmxhZ3tzZWNyZXR9"
```

Chain multiple encodings:

```
Input: "password"
Operation: To Hex → To Base64 → To Base32
```

#### Decoding Chains

Reverse encoding process:

```
Input: "ZmxhZ3tzZWNyZXR9"
Operation: From Base64
Output: "flag{secret}"
```

For unknown encoding, use "Detect" operation to identify encoding type.

#### Hashing Operations

Generate various hash types:

```
Input: "data"
Operation: MD5 → Output: 8d6e8147f0d31c716f386b137f8ac591
Operation: SHA1 → Output: aaf4c61ddcc5e8a2dabede0f3b482cd9aea9434d
Operation: SHA256 → Output: 8d969eef6ecad3c29a3a873fba8fe62fae77a8577a7ebac4f05fed7e59f389f8
```

#### Encryption/Decryption

Encrypt data with AES:

```
Input: "plaintext"
Operation: AES Encrypt
Parameters:
  - Key: hexadecimal key
  - IV: initialization vector
  - Mode: CBC/ECB/GCM
Output: encrypted hex string
```

Decrypt correspondingly:

```
Operation: AES Decrypt
Parameters: (same as encryption)
```

#### XOR Operations

Apply XOR encryption:

```
Input: "message"
Operation: XOR
Parameters: Key (string or hex)
Output: XORed result
```

Chain with other operations:

```
Input: hex_data
Operation: From Hex → XOR → To Base64
```

#### Regular Expression Operations

Extract patterns from text:

```
Input: "flag{abc123def456}"
Operation: Regular expression
Pattern: flag\{([^}]+)\}
Output: abc123def456
```

Replace patterns:

```
Pattern: [0-9]+
Replacement: X
Output: "flag{abcXdefX}"
```

#### Format Conversions

Convert between data formats:

```
Input: "0x48 0x65 0x6c 0x6c 0x6f"
Operation: From Hex
Output: "Hello"

Input: "Hello"
Operation: To Hex
Output: "48656c6c6f"
```

Data type conversions:

```
Binary ↔ Hex ↔ Base64 ↔ Base32 ↔ Decimal ↔ ASCII
```

#### Compression Operations

Compress/decompress data:

```
Input: large_text
Operation: Gzip
Output: compressed binary

Input: compressed_data
Operation: Gunzip
Output: decompressed text
```

Supported formats: Gzip, Brotli, Deflate, Zlib, LZ4, LZString.

#### Analyzing Ciphertexts

CTF cipher analysis workflow:

```
Input: ciphertext
Operation: Frequency Analysis → Identify language
Operation: Caesar Cipher (brute force all 26 shifts)
Operation: ROT13 (if applicable)
Operation: Vigenère Cipher (with key guessing)
```

#### Substitution Cipher Breaking

Attempt cipher breaking:

```
Input: substituted_text
Operation: Atbash Cipher (reverse alphabet)
Operation: Affine Cipher (try common multipliers)
Operation: Simple Substitution Brute Force
```

#### URL Encoding/Decoding

Handle URL-encoded data:

```
Input: "%66%6c%61%67%7b%73%65%63%72%65%74%7d"
Operation: URL Decode
Output: "flag{secret}"

Input: "flag{secret}"
Operation: URL Encode
Output: "%66%6c%61%67%7b%73%65%63%72%65%74%7d"
```

#### JSON Processing

Parse and extract JSON data:

```
Input: '{"flag":"secret123","key":"value"}'
Operation: JSON Minify (or Pretty)
Operation: JSON to CSV
Output: CSV format
```

#### Power User Features

Save recipes for reuse:

1. Click "Save recipe" button
2. Enter recipe name
3. Share via URL or download

Load saved recipes:

1. Click "Load recipe"
2. Select from library
3. Modify as needed

#### Scripting CyberChef Operations

Use CyberChef's API in custom scripts:

```python
import requests
import json

def cyberchef_transform(input_data, recipe):
    """Send data to CyberChef API for transformation"""
    url = "https://cyberchef.io/api/bake"
    
    payload = {
        "input": input_data,
        "recipe": recipe,
        "output": "string"
    }
    
    response = requests.post(url, json=payload)
    if response.status_code == 200:
        return response.json()['result']
    else:
        return None

# Example: Decode Base64
result = cyberchef_transform("ZmxhZ3tzZWNyZXR9", '[{"op":"From Base64","args":[true,false]}]')
print(result)
```

#### Advanced Recipes for CTF

Multi-layer decoding recipe:

```
1. From Base64
2. From Hex
3. Gunzip
4. From Base32
5. XOR (key: "secret")
```

String manipulation chain:

```
1. Regular expression (extract pattern)
2. To Hex
3. Reverse
4. From Hex
5. ROT13
```

#### Comparing Data with CyberChef

Visual diff of transformed data:

```
Input 1: Original data
Input 2: Transformed data
Operation: Show differences in side-by-side view
```

#### Common CTF Recipes

**Layer 1: Multiple Encoding**

```
Base64 → Hex → Base32 → ROT13
```

**Layer 2: Compression**

```
Gzip → Base64 → ROT13
```

**Layer 3: Encryption**

```
AES Decrypt → Base64 Decode → XOR
```

**Layer 4: Substitution**

```
Caesar Cipher (brute force) → Atbash → Vigenère
```

#### Integration with Automation

Call CyberChef from bash:

```bash
#!/bin/bash

function cyberchef_decode() {
    local input="$1"
    local recipe="$2"
    
    curl -s -X POST "https://cyberchef.io/api/bake" \
        -H "Content-Type: application/json" \
        -d "{\"input\":\"$input\",\"recipe\":$recipe,\"output\":\"string\"}" | \
        jq -r '.result'
}

# Decode Base64
result=$(cyberchef_decode "ZmxhZ3tzZWNyZXR9" '[{"op":"From Base64","args":[true,false]}]')
echo "Result: $result"
```

[Inference] The CyberChef API may have rate limiting or service availability constraints. For reliable automation, consider using local CyberChef instances or Python libraries like `base64`, `binascii`, and `cryptography`.

#### Offline CyberChef Usage

For network-restricted environments, run locally:

```bash
cd CyberChef
npm run build
npm start

# Access at http://localhost:8080
```

Alternatively, use portable build:

```bash
wget https://gchq.github.io/CyberChef/CyberChef_v9.X.X.html
# Open in browser, works offline
```

#### Tips for CTF Scenarios

1. When encoding is unknown, test all common formats sequentially
2. Use "Detect" operation to identify patterns
3. Save successful recipes for similar challenges
4. Chain operations for multi-layer encoding
5. Use regular expressions to extract specific patterns
6. Combine encoding detection with brute-force operations
7. Export results in multiple formats (Base64, Hex, CSV, JSON)

#### Performance Considerations

For large data processing:

- Keep recipe simple to avoid browser slowdowns
- Split large files into chunks
- Use local CyberChef for processing >10MB files
- Consider Python/Bash alternatives for batch operations

---

# CTF-Specific Techniques

## Common CTF Patterns

### Base64 in Images

Base64-encoded data frequently appears embedded in image files through metadata, pixel data, comments, or appended content.

**Detection Methods:**

```bash
# Search for Base64 patterns in image files
strings image.png | grep -E '^[A-Za-z0-9+/]{20,}={0,2}$'

# Extract and decode potential Base64
strings image.jpg | grep -E '^[A-Za-z0-9+/]{40,}={0,2}$' | base64 -d

# Check for Base64 in EXIF metadata
exiftool image.jpg | grep -E '[A-Za-z0-9+/]{20,}={0,2}'

# Decode EXIF Base64
exiftool -b -Comment image.jpg | base64 -d
```

**Common Locations:**

1. **EXIF/Metadata Fields:**

```bash
# Extract all metadata
exiftool -a -G1 image.jpg

# Check specific fields known for Base64
exiftool -Comment -Description -UserComment -ImageDescription image.jpg

# Decode from specific field
exiftool -b -Comment image.jpg | base64 -d > decoded.txt

# Search all fields for Base64 patterns
exiftool -a image.jpg | grep -oE '[A-Za-z0-9+/]{40,}={0,2}' | while read b64; do
    echo "=== Trying: ${b64:0:40}... ==="
    echo "$b64" | base64 -d 2>/dev/null && echo
done
```

2. **PNG Text Chunks:**

```bash
# Extract PNG text chunks
pngcheck -v image.png
pngcheck -t image.png  # Text chunks only

# Using pnginfo
pnginfo image.png

# Manual extraction with strings
strings image.png | grep -A 5 "tEXt\|zTXt\|iTXt"

# Extract and decode
identify -verbose image.png | grep comment
identify -format "%c" image.png | base64 -d
```

3. **JPEG Comments:**

```bash
# Extract JPEG comments
rdjpgcom image.jpg

# Check for Base64 in comment
rdjpgcom image.jpg | base64 -d

# Using exiftool
exiftool -Comment image.jpg | cut -d':' -f2 | base64 -d
```

4. **Appended Data (After Image EOF):**

```bash
# Check file size vs expected image data
identify -format "%b" image.png  # Image data size
ls -l image.png  # Actual file size

# Extract data after image EOF
# PNG ends with IEND chunk (49 45 4E 44)
xxd image.png | grep "4945 4e44"
# Note offset, extract everything after

# For PNG
python3 << 'EOF'
import sys
with open(sys.argv[1], 'rb') as f:
    data = f.read()
    iend = data.find(b'IEND')
    if iend != -1:
        # IEND chunk is 12 bytes: length(4) + IEND(4) + CRC(4)
        extra = data[iend+12:]
        if extra:
            print(extra.decode('utf-8', errors='ignore'))
            # Try Base64 decode
            try:
                import base64
                decoded = base64.b64decode(extra)
                print("\n=== Base64 Decoded ===")
                print(decoded.decode('utf-8', errors='ignore'))
            except:
                pass
EOF
# Usage: python3 script.py image.png

# For JPEG (ends with FFD9)
xxd image.jpg | tail -n 20
dd if=image.jpg bs=1 skip=$((0xOFFSET)) of=extracted.txt
```

5. **LSB Steganography with Base64:**

```bash
# Extract LSB data
zsteg -a image.png > lsb_data.txt

# Check for Base64 in LSB
zsteg image.png | grep -E '[A-Za-z0-9+/]{40,}={0,2}'

# Extract specific LSB plane and decode
zsteg -E b1,rgb,lsb,xy image.png | base64 -d
```

**Automated Base64 Detection Script:**

```bash
#!/bin/bash
# base64_hunt.sh - Search for Base64 in images

IMAGE="$1"

echo "=== Searching for Base64 in $IMAGE ==="

echo -e "\n[*] Checking strings..."
strings "$IMAGE" | grep -oE '[A-Za-z0-9+/]{40,}={0,2}' | head -5

echo -e "\n[*] Checking EXIF metadata..."
exiftool "$IMAGE" | grep -oE '[A-Za-z0-9+/]{40,}={0,2}' | head -3

echo -e "\n[*] Checking for appended data..."
case "$IMAGE" in
    *.png)
        tail -c 1000 "$IMAGE" | strings | grep -oE '[A-Za-z0-9+/]{40,}={0,2}'
        ;;
    *.jpg|*.jpeg)
        tail -c 1000 "$IMAGE" | strings | grep -oE '[A-Za-z0-9+/]{40,}={0,2}'
        ;;
esac

echo -e "\n[*] Attempting automatic decode of found strings..."
strings "$IMAGE" | grep -oE '[A-Za-z0-9+/]{40,}={0,2}' | while read b64; do
    decoded=$(echo "$b64" | base64 -d 2>/dev/null)
    if [ $? -eq 0 ] && [ ! -z "$decoded" ]; then
        echo "Decoded: $decoded"
    fi
done
```

**Common Base64 Variants:**

```bash
# Standard Base64
echo "ZmxhZ3toaWRkZW5fZGF0YX0=" | base64 -d

# URL-safe Base64 (- instead of +, _ instead of /)
echo "ZmxhZ3toaWRkZW5fZGF0YX0=" | base64 -d

# Base64 without padding (missing =)
echo "ZmxhZ3toaWRkZW5fZGF0YX0" | base64 -d 2>/dev/null
# If fails, add padding
echo "ZmxhZ3toaWRkZW5fZGF0YX0=" | base64 -d

# Base32
echo "MZXW6YTBOI======" | base32 -d

# Base85 (ASCII85)
python3 -c "import base64; print(base64.a85decode(b'<~...~>').decode())"
```

**Multi-layer Base64 Encoding:**

```bash
# Decode multiple times
data="WmpaaGRIaDdibWxrWkdWdVgyUmhkR0Y5"
echo "$data" | base64 -d  # First layer
echo "$data" | base64 -d | base64 -d  # Second layer
echo "$data" | base64 -d | base64 -d | base64 -d  # Third layer

# Automated multi-layer decoder
decode_multilayer() {
    local data="$1"
    local count=0
    while [ $count -lt 10 ]; do
        decoded=$(echo "$data" | base64 -d 2>/dev/null)
        if [ $? -ne 0 ]; then
            echo "Final result: $data"
            return
        fi
        echo "Layer $count: $decoded"
        data="$decoded"
        count=$((count + 1))
    done
}
```

### ROT Ciphers

ROT (rotation) ciphers shift letters by a fixed number of positions in the alphabet. ROT13 is most common, but any rotation value may be used.

**ROT13 (Most Common):**

```bash
# Using tr command
echo "synt{ebg_guvegrra}" | tr 'A-Za-z' 'N-ZA-Mn-za-m'

# ROT13 multiple times (ROT13 twice = original)
echo "text" | tr 'A-Za-z' 'N-ZA-Mn-za-m' | tr 'A-Za-z' 'N-ZA-Mn-za-m'

# Using rot13 command (if available)
echo "synt{ebg_guvegrra}" | rot13
```

**ROT-N (Any Rotation):**

```bash
# ROT function for any shift value
rot() {
    local shift=$1
    local text="$2"
    echo "$text" | python3 -c "
import sys
shift = $shift % 26
text = sys.stdin.read()
result = ''
for char in text:
    if char.isalpha():
        base = ord('A') if char.isupper() else ord('a')
        result += chr((ord(char) - base + shift) % 26 + base)
    else:
        result += char
print(result, end='')
"
}

# Test all rotations
for i in {1..25}; do
    echo "ROT$i: $(rot $i 'synt{test}')"
done
```

**Brute Force All ROT Values:**

```bash
#!/bin/bash
# rot_bruteforce.sh

INPUT="$1"

for shift in {1..25}; do
    result=$(echo "$INPUT" | python3 -c "
import sys
shift = $shift
text = sys.stdin.read().strip()
result = ''
for char in text:
    if char.isalpha():
        base = ord('A') if char.isupper() else ord('a')
        result += chr((ord(char) - base + shift) % 26 + base)
    else:
        result += char
print(result)
")
    echo "ROT$shift: $result"
    
    # Auto-detect flag format
    if echo "$result" | grep -qiE 'flag\{|ctf\{|^[a-z0-9_]+\{'; then
        echo "*** POSSIBLE FLAG FOUND ***"
    fi
done
```

**ROT47 (Extended ASCII):**

ROT47 rotates through printable ASCII characters (33-126):

```bash
# ROT47 implementation
rot47() {
    echo "$1" | tr '!-~' 'P-~!-O'
}

# Example
rot47 'uFde9]4@DlQppFmQ:_@?5]'

# Python implementation for more control
python3 << 'EOF'
def rot47(text):
    result = []
    for char in text:
        code = ord(char)
        if 33 <= code <= 126:
            result.append(chr(33 + ((code - 33 + 47) % 94)))
        else:
            result.append(char)
    return ''.join(result)

import sys
print(rot47(sys.argv[1]) if len(sys.argv) > 1 else "")
EOF
```

**Identifying ROT Cipher:**

```bash
# Detect ROT by analyzing letter frequency
# English has high frequency of E, T, A, O, I, N
python3 << 'EOF'
import sys
from collections import Counter

def score_english(text):
    freq = Counter(text.upper())
    # English letter frequencies (simplified)
    english_freq = 'ETAOINSHRDLCUMWFGYPBVKJXQZ'
    score = 0
    for i, letter in enumerate(english_freq[:6]):
        if letter in freq:
            score += (6 - i) * freq[letter]
    return score

text = sys.argv[1] if len(sys.argv) > 1 else sys.stdin.read()

best_score = 0
best_shift = 0
best_result = ""

for shift in range(26):
    result = ''
    for char in text:
        if char.isalpha():
            base = ord('A') if char.isupper() else ord('a')
            result += chr((ord(char) - base + shift) % 26 + base)
        else:
            result += char
    
    score = score_english(result)
    if score > best_score:
        best_score = score
        best_shift = shift
        best_result = result

print(f"Best shift: ROT{best_shift}")
print(f"Result: {best_result}")
EOF
```

**CyberChef Recipe for ROT:**

```
ROT13
ROT47
ROT8000 (Unicode rotation)
```

### XOR Operations

XOR encryption is extremely common in CTFs due to its simplicity and reversibility (A ⊕ B ⊕ B = A).

**Single-Byte XOR:**

```bash
# XOR with single byte key
xor_single() {
    local key=$1
    local input="$2"
    echo -n "$input" | xxd -p | tr -d '\n' | \
    python3 -c "
import sys
data = bytes.fromhex(sys.stdin.read().strip())
key = $key
result = bytes([b ^ key for b in data])
sys.stdout.buffer.write(result)
"
}

# Brute force single-byte XOR
xor_bruteforce() {
    local input="$1"
    for key in {0..255}; do
        result=$(xor_single $key "$input")
        echo "Key $key (0x$(printf %02x $key)): $result"
        # Check for flag pattern
        if echo "$result" | grep -qiE 'flag\{|ctf\{'; then
            echo "*** POSSIBLE FLAG WITH KEY $key ***"
        fi
    done
}

# Example usage
xor_bruteforce "$(cat encrypted.bin)"
```

**Multi-Byte XOR (Repeating Key):**

```bash
# XOR with repeating key
xor_repeat() {
    local key="$1"
    local input_file="$2"
    
    python3 << EOF
key = b"$key"
with open("$input_file", "rb") as f:
    data = f.read()

result = bytes([data[i] ^ key[i % len(key)] for i in range(len(data))])
sys.stdout.buffer.write(result)
EOF
}

# Example
xor_repeat "secret" encrypted.bin > decrypted.bin
```

**XOR with Known Plaintext:**

```bash
# If you know part of the plaintext, extract the key
xor_known_plaintext() {
    local ciphertext_hex="$1"
    local known_plaintext="$2"
    
    python3 << EOF
cipher = bytes.fromhex("$ciphertext_hex")
plain = b"$known_plaintext"

# Extract key bytes
key = bytes([cipher[i] ^ plain[i] for i in range(len(plain))])
print(f"Extracted key: {key}")
print(f"Key (hex): {key.hex()}")

# Try to decrypt full message
if len(key) > 0:
    # Assume repeating key
    decrypted = bytes([cipher[i] ^ key[i % len(key)] for i in range(len(cipher))])
    print(f"Decrypted: {decrypted}")
EOF
}

# Example: if you know ciphertext starts with "flag{"
xor_known_plaintext "2e0d1a425b" "flag{"
```

**XOR Key Length Detection (Hamming Distance):**

```bash
# Detect repeating XOR key length
python3 << 'EOF'
import sys

def hamming_distance(b1, b2):
    return sum(bin(x ^ y).count('1') for x, y in zip(b1, b2))

def detect_keysize(data, max_keysize=40):
    distances = {}
    
    for keysize in range(2, min(max_keysize, len(data) // 4)):
        blocks = [data[i:i+keysize] for i in range(0, len(data), keysize)][:4]
        
        if len(blocks) < 4:
            continue
            
        # Calculate average hamming distance
        total_dist = 0
        comparisons = 0
        for i in range(len(blocks)-1):
            for j in range(i+1, len(blocks)):
                if len(blocks[i]) == len(blocks[j]) == keysize:
                    total_dist += hamming_distance(blocks[i], blocks[j])
                    comparisons += 1
        
        if comparisons > 0:
            normalized = total_dist / comparisons / keysize
            distances[keysize] = normalized
    
    # Sort by distance (lower is better)
    sorted_sizes = sorted(distances.items(), key=lambda x: x[1])
    
    print("Likely key sizes (top 5):")
    for size, dist in sorted_sizes[:5]:
        print(f"  {size}: {dist:.4f}")
    
    return sorted_sizes[0][0] if sorted_sizes else None

# Read from file or stdin
if len(sys.argv) > 1:
    with open(sys.argv[1], 'rb') as f:
        data = f.read()
else:
    data = sys.stdin.buffer.read()

detect_keysize(data)
EOF
# Usage: python3 script.py encrypted.bin
```

**XOR Bruteforce with Frequency Analysis:**

```bash
# Find single-byte XOR key using English character frequency
python3 << 'EOF'
import sys
from collections import Counter

def score_text(text):
    # English letter frequency (simplified scoring)
    freq = 'etaoin shrdlcumwfgypbvkjxqz'
    score = 0
    for char in text.lower():
        if char in freq:
            score += (26 - freq.index(char))
        elif char in ' \n\t':
            score += 10
        elif char.isprintable():
            score += 1
    return score

def xor_single_byte(data, key):
    return bytes([b ^ key for b in data])

# Read input
if len(sys.argv) > 1:
    with open(sys.argv[1], 'rb') as f:
        data = f.read()
else:
    data = sys.stdin.buffer.read()

results = []

for key in range(256):
    decrypted = xor_single_byte(data, key)
    try:
        text = decrypted.decode('ascii', errors='strict')
        score = score_text(text)
        results.append((score, key, text))
    except:
        pass

# Sort by score (highest first)
results.sort(reverse=True)

print("Top 5 candidates:")
for i, (score, key, text) in enumerate(results[:5]):
    print(f"\n=== Rank {i+1} - Key: {key} (0x{key:02x}) - Score: {score} ===")
    print(text[:200])
EOF
```

**XOR File Operation:**

```bash
# XOR two files together
xor_files() {
    python3 << EOF
with open("$1", "rb") as f1, open("$2", "rb") as f2:
    data1 = f1.read()
    data2 = f2.read()
    
    # XOR up to length of shorter file
    result = bytes([data1[i] ^ data2[i] for i in range(min(len(data1), len(data2)))])
    sys.stdout.buffer.write(result)
EOF
}

# Usage: xor_files file1.bin file2.bin > output.bin
```

**CyberChef XOR Recipes:**

```
XOR
XOR Brute Force
From Hex → XOR → To Hex
```

### Reversed/Flipped Content

Content may be reversed at various levels: bit-level, byte-level, line-level, or entire content.

**String Reversal:**

```bash
# Reverse string
echo "reversed" | rev

# Reverse file content
rev file.txt

# Reverse entire file as single string
tac file.txt | rev
```

**Image Flipping:**

```bash
# Using ImageMagick
convert input.png -flip output.png       # Vertical flip
convert input.png -flop output.png       # Horizontal flip
convert input.png -rotate 180 output.png # 180° rotation

# Try all orientations
for operation in flip flop "rotate 180" "rotate 90" "rotate 270"; do
    convert input.png -$operation output_$operation.png
done
```

**Binary Reversal:**

```bash
# Reverse bytes in file
tac file.bin | rev > reversed.bin

# Python byte reversal
python3 << 'EOF'
import sys
with open(sys.argv[1], 'rb') as f:
    data = f.read()
reversed_data = data[::-1]
sys.stdout.buffer.write(reversed_data)
EOF
# Usage: python3 script.py input.bin > output.bin

# Reverse hex dump
xxd -p file.bin | tr -d '\n' | rev | xxd -r -p > reversed.bin
```

**Bit Reversal:**

```bash
# Reverse bits within each byte
python3 << 'EOF'
import sys

def reverse_bits(byte):
    result = 0
    for i in range(8):
        result = (result << 1) | ((byte >> i) & 1)
    return result

with open(sys.argv[1], 'rb') as f:
    data = f.read()

reversed = bytes([reverse_bits(b) for b in data])
sys.stdout.buffer.write(reversed)
EOF
# Usage: python3 script.py input.bin > output.bin
```

**Audio Reversal:**

```bash
# Reverse audio
sox input.wav reversed.wav reverse

# Using ffmpeg
ffmpeg -i input.wav -af "areverse" reversed.wav

# Play reversed (live)
play input.wav reverse
```

**Text Transformations:**

```bash
# Reverse each line
while IFS= read -r line; do
    echo "$line" | rev
done < input.txt

# Reverse line order (last line first)
tac input.txt

# Reverse words in each line
awk '{for(i=NF;i>=1;i--) printf "%s ", $i; print ""}' input.txt

# Reverse characters, keep line order
rev input.txt
```

**Base64 Reversal:**

```bash
# Sometimes Base64 is reversed before encoding
data="==gctFWLpFGYlBXaw"
echo "$data" | rev | base64 -d

# Or reversed after decoding
echo "$data" | base64 -d | rev
```

**LSB Bit Order Reversal:**

```bash
# Extract LSB with reversed bit order
zsteg -E b1,rgb,lsb,xy,msb image.png  # MSB instead of LSB
```

**Automated Reversal Testing:**

```bash
#!/bin/bash
# test_reversals.sh

INPUT="$1"

echo "=== Original ==="
head -c 100 "$INPUT"
echo -e "\n"

echo "=== Byte Reversed ==="
python3 -c "import sys; sys.stdout.buffer.write(open('$INPUT','rb').read()[::-1])" | head -c 100
echo -e "\n"

echo "=== Bit Reversed ==="
python3 << EOF | head -c 100
with open('$INPUT', 'rb') as f:
    data = f.read()
reversed = bytes([int(format(b, '08b')[::-1], 2) for b in data])
sys.stdout.buffer.write(reversed)
EOF
echo -e "\n"

if file "$INPUT" | grep -q "text"; then
    echo "=== String Reversed ==="
    rev "$INPUT" | head -c 100
    echo -e "\n"
fi
```

### Concatenated Flags

Flags may be split across multiple files, channels, or data sources that must be combined.

**File Concatenation:**

```bash
# Simple concatenation
cat part1.txt part2.txt part3.txt > complete.txt

# With sorted order
cat part*.txt > complete.txt

# Concatenate in specific order
for i in {1..10}; do
    cat part$i.txt >> complete.txt
done

# Binary concatenation
cat file1.bin file2.bin file3.bin > combined.bin
```

**Extracting Parts from Multiple Images:**

```bash
# Extract strings from multiple images
for img in *.png; do
    echo "=== $img ==="
    strings "$img" | grep -i "flag\|part"
done | grep -v "^===" > all_parts.txt

# Extract EXIF from multiple images
for img in *.jpg; do
    exiftool -Comment "$img"
done | grep -v "^===\|File Name" > combined_comments.txt

# Combine LSB data from multiple images
for img in image*.png; do
    zsteg -E b1,rgb,lsb,xy "$img"
done > combined_lsb.txt
```

**Channel Combination (Audio/Image):**

```bash
# Extract separate audio channels
sox stereo.wav left.wav remix 1
sox stereo.wav right.wav remix 2

# Combine data from each channel
strings left.wav | grep -E '[A-Za-z0-9]{20,}'
strings right.wav | grep -E '[A-Za-z0-9]{20,}'

# For images: extract RGB channels separately
convert image.png -channel R -separate red.png
convert image.png -channel G -separate green.png
convert image.png -channel B -separate blue.png

# Extract data from each channel
for color in red green blue; do
    echo "=== $color ==="
    zsteg ${color}.png
done
```

**Combining QR Codes:**

```bash
# If QR code is split across multiple images
# Extract each part
for img in qr_part*.png; do
    zbarimg "$img"
done | sort > combined_qr.txt

# Reassemble split QR code image
convert +append qr_part1.png qr_part2.png combined_qr.png  # Horizontal
convert -append qr_part1.png qr_part2.png combined_qr.png  # Vertical

# Read combined QR
zbarimg combined_qr.png
```

**Interleaved Data:**

```bash
# Data may be interleaved (every Nth byte belongs together)
python3 << 'EOF'
import sys

with open(sys.argv[1], 'rb') as f:
    data = f.read()

# Try different interleave patterns
for stride in [2, 3, 4, 5]:
    print(f"\n=== Stride {stride} ===")
    for offset in range(stride):
        part = data[offset::stride]
        print(f"Part {offset}: {part[:50]}")
EOF
# Usage: python3 script.py interleaved.bin
```

**Multi-File XOR:**

```bash
# Flag split across files using XOR
xor_multifile() {
    python3 << EOF
import sys

files = sys.argv[1:]
data_arrays = []

for fname in files:
    with open(fname, 'rb') as f:
        data_arrays.append(f.read())

# XOR all files together
min_len = min(len(d) for d in data_arrays)
result = bytearray(min_len)

for i in range(min_len):
    val = 0
    for data in data_arrays:
        val ^= data[i]
    result[i] = val

sys.stdout.buffer.write(bytes(result))
EOF
}

# Usage: xor_multifile file1.bin file2.bin file3.bin > result.bin
```

**Packet Combination (PCAP):**

```bash
# Extract data from multiple packets
tshark -r capture.pcap -Y "tcp.stream eq 0" -T fields -e data | \
    xxd -r -p > stream0.bin

# Combine multiple TCP streams
for i in {0..10}; do
    tshark -r capture.pcap -Y "tcp.stream eq $i" -T fields -e data | \
        xxd -r -p >> all_streams.bin
done

# Extract and combine HTTP responses
tshark -r capture.pcap -Y "http.response" -T fields -e http.file_data | \
    xxd -r -p > combined_responses.bin
```

**Metadata Concatenation:**

```bash
# Combine metadata from multiple files
for f in file*.png; do
    exiftool -Comment -b "$f"
done | tr -d '\n' > combined_metadata.txt

# Combine specific EXIF field from all images
exiftool -csv -Comment *.jpg | cut -d',' -f2 | tr -d '"' > combined.txt
```

### Multi-Stage Challenges

Multi-stage challenges require solving multiple steps in sequence, where each solution provides input for the next stage.

**Common Multi-Stage Patterns:**

1. **Decoding Chains:**

```bash
#!/bin/bash
# decode_chain.sh - Automated decoding chain

INPUT="$1"

echo "Stage 1: Base64 decode"
STAGE1=$(echo "$INPUT" | base64 -d)
echo "$STAGE1"

echo -e "\nStage 2: ROT13"
STAGE2=$(echo "$STAGE1" | tr 'A-Za-z' 'N-ZA-Mn-za-m')
echo "$STAGE2"

echo -e "\nStage 3: Hex decode"
STAGE3=$(echo "$STAGE2" | xxd -r -p)
echo "$STAGE3"

echo -e "\nStage 4: URL decode"
STAGE4=$(echo "$STAGE3" | python3 -c "import sys, urllib.parse; print(urllib.parse.unquote(sys.stdin.read()))")
echo "$STAGE4"
```

2. **Password/Key Discovery:**

```bash
# Stage 1: Extract password from image
PASSWORD=$(strings image.png | grep -oE 'password:[a-z0-9]+' | cut -d: -f2)
echo "Found password: $PASSWORD"

# Stage 2: Use password to decrypt archive
7z x encrypted.7z -p"$PASSWORD"

# Stage 3: Extract data from decrypted file
FLAG=$(strings decrypted.txt | grep -oE 'flag\{[^}]+\}')
echo "Flag: $FLAG"
```

3. **Progressive Image Reveal:**

```bash
# Stage 1: Extract first clue from metadata
CLUE1=$(exiftool -Comment image1.png | cut -d: -f2 | tr -d ' ')

# Stage 2: Use clue as steghide passphrase
steghide extract -sf image2.jpg -p "$CLUE1" -xf extracted.txt

# Stage 3: Decode extracted data
CLUE2=$(cat extracted.txt | base64 -d)

# Stage 4: Use as LSB extraction parameter
zsteg -E "b$CLUE2,rgb,lsb,xy" image3.png > final_flag.txt
```

**Common Multi-Stage Tool Combinations:**

```bash
# Example: Base64 → Hex → XOR → Gunzip
echo "H4sIAAAAAAAAA..." | base64 -d | xxd -p | tr -d '\n' | \
    python3 -c "import sys; data=bytes.fromhex(sys.stdin.read()); sys.stdout.buffer.write(bytes([b^0x42 for b in data]))" | \
    gunzip

# Example: Image LSB → Base64 → ROT13 → Flag
zsteg -E b1,rgb,lsb,xy image.png | base64 -d | tr 'A-Za-z' 'N-ZA-Mn-za-m'
```

**Recursive Archive Extraction:**

```bash
#!/bin/bash
# recursive_extract.sh - Extract nested archives

extract_recursive() {
    local file="$1"
    local depth="${2:-0}"
    local indent=$(printf '%*s' $((depth * 2)) '')
    
    echo "${indent}Processing: $file"
    
    # Determine file type
    local filetype=$(file -b "$file")
    
    case "$filetype" in
        *"Zip archive"*)
            echo "${indent}→ Extracting ZIP"
            unzip -q "$file" -d "extracted_${depth}"
            cd "extracted_${depth}"
            for f in *; do
                extract_recursive "$f" $((depth + 1))
            done
            cd ..
            ;;
        *"gzip compressed"*)
            echo "${indent}→ Extracting GZIP"
            gunzip -c "$file" > "extracted_${depth}.bin"
            extract_recursive "extracted_${depth}.bin" $((depth + 1))
            ;;
        *"bzip2 compressed"*)
            echo "${indent}→ Extracting BZIP2"
            bunzip2 -c "$file" > "extracted_${depth}.bin"
            extract_recursive "extracted_${depth}.bin" $((depth + 1))
            ;;
        *"XZ compressed"*)
            echo "${indent}→ Extracting XZ"
            xz -dc "$file" > "extracted_${depth}.bin"
            extract_recursive "extracted_${depth}.bin" $((depth + 1))
            ;;
        *"7-zip archive"*)
            echo "${indent}→ Extracting 7Z"
            7z x "$file" -o"extracted_${depth}" >/dev/null
            cd "extracted_${depth}"
            for f in *; do
                extract_recursive "$f" $((depth + 1))
            done
            cd ..
            ;;
        *"RAR archive"*)
            echo "${indent}→ Extracting RAR"
            unrar x "$file" "extracted_${depth}/" >/dev/null
            cd "extracted_${depth}"
            for f in *; do
                extract_recursive "$f" $((depth + 1))
            done
            cd ..
            ;;
        *"tar archive"*)
            echo "${indent}→ Extracting TAR"
            mkdir -p "extracted_${depth}"
            tar -xf "$file" -C "extracted_${depth}"
            cd "extracted_${depth}"
            for f in *; do
                extract_recursive "$f" $((depth + 1))
            done
            cd ..
            ;;
        *)
            echo "${indent}→ Final file: $filetype"
            # Check for flag
            if strings "$file" | grep -iqE 'flag\{|ctf\{'; then
                echo "${indent}*** POSSIBLE FLAG FOUND ***"
                strings "$file" | grep -iE 'flag\{|ctf\{'
            fi
            ;;
    esac
}

extract_recursive "$1" 0
```

**Using binwalk for Nested Extraction:**

```bash
# Extract all embedded files recursively
binwalk -e --dd='.*' file.bin

# Extract with specific depth
binwalk -e -M file.bin  # Matryoshka mode (recursive)

# Manual inspection after extraction
find _file.bin.extracted -type f -exec file {} \; | grep -v "empty"
```

**Multi-Stage Steganography:**

```bash
#!/bin/bash
# multi_steg.sh - Test multiple steganography methods in sequence

IMAGE="$1"

echo "=== Stage 1: Metadata Check ==="
exiftool "$IMAGE" | grep -iE "comment|description|copyright"

echo -e "\n=== Stage 2: String Extraction ==="
STRINGS_DATA=$(strings "$IMAGE" | grep -E '[A-Za-z0-9+/]{40,}={0,2}')
echo "$STRINGS_DATA"

# Try to decode if Base64 found
if [ ! -z "$STRINGS_DATA" ]; then
    echo -e "\n=== Stage 3: Base64 Decode Attempt ==="
    echo "$STRINGS_DATA" | base64 -d 2>/dev/null
fi

echo -e "\n=== Stage 4: LSB Extraction ==="
zsteg -a "$IMAGE" | head -20

echo -e "\n=== Stage 5: Steghide Attempt (no password) ==="
steghide extract -sf "$IMAGE" -p "" 2>/dev/null && \
    echo "Extracted file found!" || echo "No steghide data"

echo -e "\n=== Stage 6: Check for Appended Data ==="
case "$IMAGE" in
    *.png)
        tail -c 1000 "$IMAGE" | strings
        ;;
    *.jpg)
        tail -c 1000 "$IMAGE" | strings
        ;;
esac
```

**Breadcrumb Following:**

```bash
# Stage-based challenge where each stage gives a clue to the next

# Stage 1: Find initial clue
CLUE=$(strings file1.txt | grep -oE 'next:[a-z0-9]+' | cut -d: -f2)
echo "Stage 1 clue: $CLUE"

# Stage 2: Use clue as filename/key
if [ -f "$CLUE.txt" ]; then
    NEXT_CLUE=$(cat "$CLUE.txt" | base64 -d)
    echo "Stage 2 clue: $NEXT_CLUE"
fi

# Stage 3: Use as password or parameter
# Continue pattern...
```

**Common Multi-Stage Challenge Flow:**

```bash
#!/bin/bash
# typical_multistage.sh - Common multi-stage pattern

INPUT="$1"

# Pattern 1: Encoding chain
decode_chain() {
    echo "=== Trying decode chain ==="
    
    # Base64 → Hex → Base64 → ROT13
    result=$(echo "$1" | base64 -d 2>/dev/null | xxd -r -p 2>/dev/null | \
             base64 -d 2>/dev/null | tr 'A-Za-z' 'N-ZA-Mn-za-m')
    
    if echo "$result" | grep -qE 'flag|CTF'; then
        echo "Success: $result"
        return 0
    fi
    return 1
}

# Pattern 2: Steg chain (image → password → archive)
steg_chain() {
    echo "=== Trying steg chain ==="
    
    # Extract password from image
    password=$(exiftool -Comment "$INPUT" | cut -d: -f2 | tr -d ' ')
    
    if [ ! -z "$password" ]; then
        echo "Found password: $password"
        
        # Try to extract steghide data
        steghide extract -sf "$INPUT" -p "$password" -xf extracted.bin 2>/dev/null
        
        if [ -f extracted.bin ]; then
            echo "Extracted file, checking contents..."
            file extracted.bin
            strings extracted.bin | grep -iE 'flag|ctf'
        fi
    fi
}

# Pattern 3: File format confusion
format_confusion() {
    echo "=== Trying format confusion ==="
    
    # Check if file is actually different format
    real_type=$(file -b "$INPUT")
    echo "Real type: $real_type"
    
    # Try as ZIP
    unzip -l "$INPUT" 2>/dev/null
    
    # Try as image
    identify "$INPUT" 2>/dev/null
    
    # Try as archive
    7z l "$INPUT" 2>/dev/null
}

# Execute all patterns
decode_chain "$INPUT"
steg_chain "$INPUT"
format_confusion "$INPUT"
```

**Multi-Stage Script with State Tracking:**

```bash
#!/bin/bash
# stateful_multistage.sh - Track progress through challenge stages

STATE_FILE=".challenge_state"

save_state() {
    echo "$1=$2" >> "$STATE_FILE"
}

get_state() {
    grep "^$1=" "$STATE_FILE" 2>/dev/null | cut -d= -f2 | tail -1
}

# Stage 1
if [ -z "$(get_state stage1)" ]; then
    echo "=== Stage 1: Initial Discovery ==="
    clue1=$(strings image.png | grep -oE 'key:[a-zA-Z0-9]+' | cut -d: -f2)
    echo "Found: $clue1"
    save_state "stage1" "$clue1"
else
    clue1=$(get_state stage1)
    echo "Stage 1 already complete: $clue1"
fi

# Stage 2
if [ -z "$(get_state stage2)" ]; then
    echo "=== Stage 2: Decryption ==="
    openssl enc -d -aes-256-cbc -in encrypted.bin -out decrypted.bin -k "$clue1"
    clue2=$(strings decrypted.bin | head -1)
    echo "Found: $clue2"
    save_state "stage2" "$clue2"
else
    clue2=$(get_state stage2)
    echo "Stage 2 already complete: $clue2"
fi

# Stage 3
if [ -z "$(get_state stage3)" ]; then
    echo "=== Stage 3: Final Extraction ==="
    flag=$(echo "$clue2" | base64 -d | tr 'A-Za-z' 'N-ZA-Mn-za-m')
    echo "FLAG: $flag"
    save_state "stage3" "$flag"
else
    flag=$(get_state stage3)
    echo "Challenge complete! FLAG: $flag"
fi
```

**Network-Based Multi-Stage:**

```bash
# Extract staged data from PCAP

# Stage 1: Find initial packet
tshark -r capture.pcap -Y "http.request.uri contains 'stage1'" \
    -T fields -e http.request.uri

# Stage 2: Extract response data
tshark -r capture.pcap -Y "http.response and tcp.stream eq 5" \
    -T fields -e http.file_data | xxd -r -p > stage2.bin

# Stage 3: Use extracted data as key
KEY=$(strings stage2.bin | head -1)

# Stage 4: Decrypt next stage
tshark -r capture.pcap -Y "tcp.stream eq 8" -T fields -e data | \
    xxd -r -p | openssl enc -d -aes-256-cbc -k "$KEY" -out final.txt
```

**Automated Multi-Stage Solver:**

```bash
#!/bin/bash
# auto_multistage.sh - Attempt common multi-stage patterns

FILE="$1"
MAX_DEPTH=10
current_file="$FILE"
depth=0

while [ $depth -lt $MAX_DEPTH ]; do
    echo "=== Depth $depth: Processing $current_file ==="
    
    filetype=$(file -b "$current_file")
    echo "Type: $filetype"
    
    # Try various operations
    temp_file="temp_${depth}.bin"
    found_next=false
    
    # Try Base64 decode
    if base64 -d "$current_file" > "$temp_file" 2>/dev/null && [ -s "$temp_file" ]; then
        echo "→ Base64 decoded successfully"
        current_file="$temp_file"
        found_next=true
    # Try hex decode
    elif xxd -r -p "$current_file" > "$temp_file" 2>/dev/null && [ -s "$temp_file" ]; then
        echo "→ Hex decoded successfully"
        current_file="$temp_file"
        found_next=true
    # Try decompression
    elif gunzip -c "$current_file" > "$temp_file" 2>/dev/null && [ -s "$temp_file" ]; then
        echo "→ Gunzip successful"
        current_file="$temp_file"
        found_next=true
    # Try ROT13
    elif cat "$current_file" | tr 'A-Za-z' 'N-ZA-Mn-za-m' > "$temp_file" && \
         grep -qE 'flag\{|CTF' "$temp_file" 2>/dev/null; then
        echo "→ ROT13 revealed flag!"
        cat "$temp_file"
        exit 0
    else
        # No more transformations worked
        echo "→ No more transformations applicable"
        break
    fi
    
    # Check if we found a flag
    if strings "$current_file" | grep -iqE 'flag\{|CTF\{'; then
        echo "*** FLAG FOUND ***"
        strings "$current_file" | grep -iE 'flag\{|CTF\{'
        exit 0
    fi
    
    depth=$((depth + 1))
done

echo "Reached depth $depth without finding flag"
echo "Final file contents:"
strings "$current_file" | head -20
```

**Challenge Dependency Graph:**

```bash
# When multiple files depend on each other

#!/bin/bash
# dependency_solver.sh

# Define dependencies
declare -A dependencies
dependencies["file2.bin"]="file1.txt"
dependencies["file3.bin"]="file2.bin"
dependencies["final.txt"]="file3.bin,secret.key"

solve_dependency() {
    local target="$1"
    
    # Check if already solved
    if [ -f "$target" ] && [ -f ".solved_${target}" ]; then
        echo "$target already solved"
        return 0
    fi
    
    # Get dependencies
    local deps="${dependencies[$target]}"
    
    if [ -z "$deps" ]; then
        # No dependencies, base case
        return 0
    fi
    
    # Solve dependencies first
    IFS=',' read -ra DEP_ARRAY <<< "$deps"
    for dep in "${DEP_ARRAY[@]}"; do
        echo "Solving dependency: $dep for $target"
        solve_dependency "$dep"
    done
    
    # Process current file
    echo "Processing: $target"
    # Add actual processing logic here
    
    touch ".solved_${target}"
}

# Solve for final target
solve_dependency "final.txt"
```

**CyberChef Multi-Stage Recipes:**

```
Common multi-stage patterns in CyberChef:

1. From Base64 → From Hex → XOR → Gunzip
2. ROT13 → From Base64 → AES Decrypt
3. From Hex → XOR → From Base64 → ROT13
4. Reverse → From Base64 → From Hex → UTF-8
5. URL Decode → From Base64 → ROT47 → From Hex
```

**Progressive Disclosure Pattern:**

```bash
#!/bin/bash
# progressive_disclosure.sh - Each stage reveals location of next

stage=1
location="start.txt"

while [ $stage -le 10 ]; do
    echo "=== Stage $stage: $location ==="
    
    if [ ! -f "$location" ]; then
        echo "File not found: $location"
        exit 1
    fi
    
    # Extract content
    content=$(cat "$location")
    echo "Content: $content"
    
    # Check for flag
    if echo "$content" | grep -qiE 'flag\{'; then
        echo "*** FLAG FOUND ***"
        echo "$content" | grep -oiE 'flag\{[^}]+\}'
        exit 0
    fi
    
    # Look for next stage indicator
    next=$(echo "$content" | grep -oE 'next:[^ ]+' | cut -d: -f2)
    
    if [ -z "$next" ]; then
        # Try common patterns
        next=$(echo "$content" | base64 -d 2>/dev/null | grep -oE '[a-z0-9_]+\.txt')
    fi
    
    if [ -z "$next" ]; then
        echo "Cannot determine next stage"
        echo "Raw content:"
        xxd "$location" | head
        exit 1
    fi
    
    location="$next"
    stage=$((stage + 1))
done
```

**Timing-Based Multi-Stage:** [Inference - some challenges use timestamps]

```bash
# Extract files in timestamp order
ls -lt challenge_files/ | awk '{print $NF}' | while read file; do
    echo "Processing: $file"
    # Process in chronological order
    strings "challenge_files/$file" | grep -E 'part[0-9]+'
done | sort -t':' -k2 -n
```

**Challenge Checksum Validation:**

```bash
#!/bin/bash
# validate_stages.sh - Ensure each stage completed correctly

validate_stage() {
    local file="$1"
    local expected_hash="$2"
    
    actual_hash=$(sha256sum "$file" | cut -d' ' -f1)
    
    if [ "$actual_hash" = "$expected_hash" ]; then
        echo "✓ $file validated"
        return 0
    else
        echo "✗ $file validation failed"
        echo "  Expected: $expected_hash"
        echo "  Got: $actual_hash"
        return 1
    fi
}

# Define expected hashes for each stage
validate_stage "stage1_output.bin" "abc123..."
validate_stage "stage2_output.bin" "def456..."
validate_stage "stage3_output.bin" "789ghi..."
```

---

**Important Automation Tools:**

- **CyberChef** - Visual multi-stage recipe builder at https://gchq.github.io/CyberChef/
- **dcode.fr** - Online cipher identifier and decoder
- **Ciphey** - Automated decryption tool (usage: `ciphey -f encrypted.txt`)

---

## Reconnaissance

### File Signature Verification

File signatures (magic bytes) identify file types regardless of extension. Verifying signatures is fundamental for detecting polyglot files, misclassified data, and embedded content in CTF challenges.

#### Common File Signatures

Memorize essential signatures for rapid identification:

```
JPEG:     FF D8 FF E0/E1/E8/E9/EC
PNG:      89 50 4E 47 0D 0A 1A 0A
GIF:      47 49 46 38 (GIF8)
BMP:      42 4D (BM)
ZIP:      50 4B 03 04 (PK..)
RAR:      52 61 72 21 1A 07 (Rar!..)
7Z:       37 7A BC AF 27 1C
TAR:      No standard; identified by extension
GZIP:     1F 8B
BZIP2:    42 5A (BZ)
PDF:      25 50 44 46 (%PDF)
ELF:      7F 45 4C 46 (.ELF)
MACH-O:   FE ED FA (Mac executable)
PE/DLL:   4D 5A (MZ - DOS header)
```

#### Verifying File Signatures

Check file signature versus extension:

```bash
# Quick hex dump of first bytes
hexdump -C target.file | head -1

# Using file command
file target.file

# Explicit signature check
xxd target.file | head -5
```

Python verification script:

```python
def verify_signature(filename):
    signatures = {
        b'\xff\xd8\xff': 'JPEG',
        b'\x89PNG': 'PNG',
        b'GIF8': 'GIF',
        b'BM': 'BMP',
        b'PK\x03\x04': 'ZIP',
        b'Rar!\x1a\x07': 'RAR',
        b'7z\xbc\xaf': '7Z',
        b'\x1f\x8b': 'GZIP',
        b'BZ': 'BZIP2',
        b'%PDF': 'PDF',
        b'\x7fELF': 'ELF',
    }
    
    with open(filename, 'rb') as f:
        header = f.read(4)
    
    for sig, file_type in signatures.items():
        if header.startswith(sig):
            return file_type
    
    return "Unknown"

file_type = verify_signature('target.file')
print(f"Detected type: {file_type}")
```

#### Detecting Polyglot Files

Polyglot files contain multiple valid file formats. Detect by examining both beginning and end of file:

```bash
# Check file start
hexdump -C target.file | head -5

# Check file end
tail -c 512 target.file | hexdump -C
```

Python polyglot detection:

```python
def detect_polyglot(filename):
    signatures = {
        b'\xff\xd8\xff': 'JPEG',
        b'\x89PNG': 'PNG',
        b'PK\x03\x04': 'ZIP',
        b'PK\x05\x06': 'ZIP_END',
        b'%PDF': 'PDF',
    }
    
    with open(filename, 'rb') as f:
        file_data = f.read()
    
    detected = []
    
    # Check beginning
    for sig, file_type in signatures.items():
        if file_data.startswith(sig):
            detected.append((0, file_type))
    
    # Check throughout file
    for offset in range(0, len(file_data) - 4):
        for sig, file_type in signatures.items():
            if file_data[offset:offset+len(sig)] == sig:
                detected.append((offset, file_type))
    
    return detected

polyglots = detect_polyglot('target.file')
for offset, file_type in polyglots:
    print(f"0x{offset:08x}: {file_type}")
```

#### Extracting Polyglot Components

Extract individual formats from polyglot files:

```bash
# If PNG + ZIP polyglot exists, PNG reads from start, ZIP from central directory end
# Extract PNG
dd if=polyglot.file of=extracted.png bs=1 skip=0 count=[png_size]

# Extract ZIP (find PK signature location)
zip_offset=$(hexdump -C polyglot.file | grep "504b" | awk '{print $1}' | sed 's/.*0*//' | head -1)
dd if=polyglot.file of=extracted.zip bs=1 skip=$zip_offset
```

#### Verifying Signature Integrity

Validate file integrity using signature patterns:

```python
def validate_file_structure(filename):
    with open(filename, 'rb') as f:
        data = f.read()
    
    # JPEG validation
    if data.startswith(b'\xff\xd8\xff'):
        if data.endswith(b'\xff\xd9'):
            return "JPEG: Valid"
        else:
            return "JPEG: Corrupted or incomplete"
    
    # ZIP validation
    if data.startswith(b'PK\x03\x04'):
        if b'PK\x05\x06' in data[-22:]:
            return "ZIP: Valid"
        else:
            return "ZIP: Potentially corrupted"
    
    # PDF validation
    if data.startswith(b'%PDF'):
        if data.rstrip().endswith(b'%%EOF'):
            return "PDF: Valid"
        else:
            return "PDF: Missing EOF marker"
    
    return "Unknown format"

print(validate_file_structure('target.file'))
```

#### Signature Tampering Detection

Identify files with mismatched signatures:

```python
def detect_signature_tampering(filename):
    file_type_from_extension = filename.split('.')[-1].lower()
    file_type_from_signature = verify_signature(filename)
    
    if file_type_from_signature == "Unknown":
        return "Unable to determine signature type"
    
    # Extension-to-signature mapping
    extension_map = {
        'jpg': 'JPEG', 'jpeg': 'JPEG',
        'png': 'PNG',
        'gif': 'GIF',
        'zip': 'ZIP',
        'pdf': 'PDF',
        'elf': 'ELF',
    }
    
    expected_type = extension_map.get(file_type_from_extension)
    
    if expected_type and expected_type != file_type_from_signature:
        return f"MISMATCH: Extension suggests {expected_type}, signature indicates {file_type_from_signature}"
    
    return "Signature matches extension"

print(detect_signature_tampering('target.bin'))
```

### String Pattern Matching

Extracting strings and identifying patterns within binary data is essential for locating flags, credentials, and hidden messages.

#### Basic String Extraction

Extract readable ASCII strings:

```bash
# Extract strings with default minimum length (4 bytes)
strings target.bin

# Extract with custom minimum length
strings -n 3 target.bin

# Include offsets
strings -t x target.bin

# Search for specific patterns
strings target.bin | grep -i "flag\|password\|secret"
```

#### Pattern Detection Script

Search for common CTF patterns:

```python
import re

def find_ctf_patterns(filename):
    patterns = {
        'flag': r'flag\{[^}]*\}',
        'md5': r'[a-fA-F0-9]{32}',
        'sha1': r'[a-fA-F0-9]{40}',
        'sha256': r'[a-fA-F0-9]{64}',
        'email': r'[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}',
        'ipv4': r'\b(?:\d{1,3}\.){3}\d{1,3}\b',
        'url': r'https?://[^\s]+',
        'base64': r'[A-Za-z0-9+/]{20,}={0,2}',
    }
    
    with open(filename, 'rb') as f:
        content = f.read().decode('utf-8', errors='ignore')
    
    findings = {}
    for pattern_name, pattern in patterns.items():
        matches = re.findall(pattern, content, re.IGNORECASE)
        if matches:
            findings[pattern_name] = list(set(matches))
    
    return findings

results = find_ctf_patterns('target.bin')
for pattern_type, matches in results.items():
    print(f"{pattern_type}:")
    for match in matches[:5]:  # Show first 5
        print(f"  {match}")
```

#### Unicode String Extraction

Extract Unicode (wide-character) strings:

```bash
# Extract Unicode strings
strings -e S target.bin

# Encoding options: S (16-bit little-endian), B (16-bit big-endian)
strings -e B target.bin | grep -i "flag"
```

Python Unicode extraction:

```python
def extract_unicode_strings(filename, min_length=4):
    with open(filename, 'rb') as f:
        data = f.read()
    
    unicode_strings = []
    
    # UTF-16 LE
    try:
        text = data.decode('utf-16-le', errors='ignore')
        strings_list = re.findall(r'.{' + str(min_length) + r',}', text)
        unicode_strings.extend([('UTF-16-LE', s) for s in strings_list if s.isprintable()])
    except:
        pass
    
    # UTF-16 BE
    try:
        text = data.decode('utf-16-be', errors='ignore')
        strings_list = re.findall(r'.{' + str(min_length) + r',}', text)
        unicode_strings.extend([('UTF-16-BE', s) for s in strings_list if s.isprintable()])
    except:
        pass
    
    return unicode_strings

strings = extract_unicode_strings('target.bin')
for encoding, string in strings[:20]:
    print(f"{encoding}: {string}")
```

#### Hex String Pattern Matching

Search for patterns in hexadecimal representation:

```python
def search_hex_patterns(filename):
    patterns = {
        'flag_hex': r'666c61677b[0-9a-f]*7d',  # flag{...}
        'null_terminated': r'00(?:[0-9a-f]{2})*00',
        'repeated_bytes': r'([0-9a-f]{2})\1{4,}',
    }
    
    with open(filename, 'rb') as f:
        hex_data = f.read().hex()
    
    for pattern_name, pattern in patterns.items():
        matches = re.finditer(pattern, hex_data)
        for match in matches:
            offset = match.start() // 2
            value = match.group()
            print(f"{pattern_name} at 0x{offset:08x}: {value}")

search_hex_patterns('target.bin')
```

#### Keyword Context Extraction

Extract strings surrounding keyword matches:

```python
def extract_context(filename, keyword, context_bytes=100):
    with open(filename, 'rb') as f:
        data = f.read()
    
    keyword_encoded = keyword.encode() if isinstance(keyword, str) else keyword
    
    contexts = []
    start = 0
    
    while True:
        pos = data.find(keyword_encoded, start)
        if pos == -1:
            break
        
        context_start = max(0, pos - context_bytes)
        context_end = min(len(data), pos + len(keyword_encoded) + context_bytes)
        
        context = data[context_start:context_end]
        contexts.append({
            'offset': pos,
            'context': context.hex(),
            'ascii': context.decode('utf-8', errors='ignore')
        })
        
        start = pos + 1
    
    return contexts

contexts = extract_context('target.bin', 'flag')
for ctx in contexts:
    print(f"Offset: 0x{ctx['offset']:08x}")
    print(f"ASCII: {ctx['ascii']}\n")
```

#### Multi-Line String Extraction

Identify and extract multi-line readable strings:

```python
def extract_multiline_strings(filename, min_lines=3):
    with open(filename, 'rb') as f:
        content = f.read().decode('utf-8', errors='ignore')
    
    lines = content.split('\n')
    multiline_blocks = []
    current_block = []
    
    for line in lines:
        if len(line) > 10 and line.isprintable():
            current_block.append(line)
        else:
            if len(current_block) >= min_lines:
                multiline_blocks.append('\n'.join(current_block))
            current_block = []
    
    return multiline_blocks

blocks = extract_multiline_strings('target.bin')
for i, block in enumerate(blocks):
    print(f"Block {i}:")
    print(block)
    print("---")
```

### Entropy Analysis

Entropy measures the randomness or disorder in data. High entropy suggests encryption/compression; low entropy indicates structured data or plaintext. This is crucial for detecting steganography and identifying data boundaries.

#### Shannon Entropy Calculation

Calculate entropy of a file:

```python
import math

def calculate_entropy(data):
    """
    Calculate Shannon entropy (0-8 for bytes)
    0: All same byte
    8: Maximum randomness
    """
    if len(data) == 0:
        return 0
    
    # Count byte frequencies
    byte_counts = {}
    for byte in data:
        byte_counts[byte] = byte_counts.get(byte, 0) + 1
    
    # Calculate entropy
    entropy = 0
    for count in byte_counts.values():
        probability = count / len(data)
        entropy -= probability * math.log2(probability)
    
    return entropy

def analyze_file_entropy(filename):
    with open(filename, 'rb') as f:
        data = f.read()
    
    entropy = calculate_entropy(data)
    print(f"File: {filename}")
    print(f"Entropy: {entropy:.4f} bits")
    
    if entropy < 2:
        print("Type: Low entropy (likely plaintext or structured data)")
    elif entropy < 5:
        print("Type: Medium entropy (possibly compressed or encoded)")
    else:
        print("Type: High entropy (likely encrypted or random)")

analyze_file_entropy('target.bin')
```

#### Entropy Mapping

Visualize entropy distribution across a file:

```python
import math

def entropy_map(filename, chunk_size=256):
    """
    Map entropy across file to identify different data regions
    """
    with open(filename, 'rb') as f:
        data = f.read()
    
    entropy_values = []
    
    for i in range(0, len(data), chunk_size):
        chunk = data[i:i+chunk_size]
        entropy = calculate_entropy(chunk)
        entropy_values.append(entropy)
    
    # Display entropy visualization
    print("Entropy Map (chunk_size={})".format(chunk_size))
    print("Offset\t\tEntropy\t\tVisualization")
    
    for i, entropy in enumerate(entropy_values):
        offset = i * chunk_size
        bar = '█' * int(entropy)
        print(f"0x{offset:08x}\t{entropy:.2f}\t\t{bar}")

entropy_map('target.bin')
```

#### Detecting Steganography via Entropy

Identify suspicious entropy patterns indicating embedded data:

```python
def detect_steganography_entropy(filename, chunk_size=256):
    """
    Detect steganography by analyzing entropy anomalies
    LSB steganography typically shows entropy close to 0.5 for the LSB layer
    """
    with open(filename, 'rb') as f:
        data = f.read()
    
    suspicious_regions = []
    
    for i in range(0, len(data) - chunk_size, chunk_size):
        chunk = data[i:i+chunk_size]
        entropy = calculate_entropy(chunk)
        
        # Extract LSBs
        lsbs = [byte & 1 for byte in chunk]
        lsb_entropy = calculate_entropy(bytes(lsbs))
        
        # High LSB entropy + normal overall entropy = suspicious
        if 4.5 < entropy < 7.5 and 0.9 < lsb_entropy < 1.1:
            suspicious_regions.append({
                'offset': i,
                'entropy': entropy,
                'lsb_entropy': lsb_entropy
            })
    
    return suspicious_regions

suspicious = detect_steganography_entropy('target.png')
if suspicious:
    print("Potential steganography detected:")
    for region in suspicious:
        print(f"  Offset: 0x{region['offset']:08x}")
        print(f"  Entropy: {region['entropy']:.4f}")
        print(f"  LSB Entropy: {region['lsb_entropy']:.4f}")
```

#### Entropy Comparison

Compare entropy before and after operations:

```python
def compare_entropy(original_file, processed_file):
    with open(original_file, 'rb') as f:
        original_data = f.read()
    with open(processed_file, 'rb') as f:
        processed_data = f.read()
    
    original_entropy = calculate_entropy(original_data)
    processed_entropy = calculate_entropy(processed_data)
    
    print(f"Original entropy: {original_entropy:.4f}")
    print(f"Processed entropy: {processed_entropy:.4f}")
    print(f"Difference: {processed_entropy - original_entropy:+.4f}")
    
    if processed_entropy > original_entropy + 1:
        print("Result: Data became more random (encryption/compression applied)")
    elif processed_entropy < original_entropy - 1:
        print("Result: Data became more ordered (decompression/decryption)")

compare_entropy('original.bin', 'processed.bin')
```

#### Block Entropy Analysis

Analyze entropy distribution to identify structured regions:

```python
def find_structured_regions(filename, threshold=3.0):
    """
    Find regions with low entropy (structured/readable data)
    """
    with open(filename, 'rb') as f:
        data = f.read()
    
    chunk_size = 512
    low_entropy_regions = []
    
    for i in range(0, len(data) - chunk_size, chunk_size):
        chunk = data[i:i+chunk_size]
        entropy = calculate_entropy(chunk)
        
        if entropy < threshold:
            low_entropy_regions.append({
                'offset': i,
                'entropy': entropy,
                'data': chunk
            })
    
    return low_entropy_regions

regions = find_structured_regions('target.bin')
for region in regions:
    print(f"Low entropy region at 0x{region['offset']:08x} (entropy: {region['entropy']:.2f})")
    try:
        readable = region['data'].decode('utf-8', errors='ignore')[:50]
        print(f"  Content: {readable}")
    except:
        pass
```

### Size Anomaly Detection

File size anomalies often indicate hidden data, padding, or tampering. Comparing expected versus actual file sizes reveals discrepancies.

#### Calculating Expected vs. Actual Sizes

Compare file dimensions with file size:

```python
from PIL import Image

def check_image_size_anomaly(image_file):
    """
    Detect size anomalies in image files
    Expected size = width × height × bytes_per_pixel
    """
    img = Image.open(image_file)
    width, height = img.size
    mode = img.mode
    
    # Bytes per pixel for different modes
    bytes_per_pixel = {
        'RGB': 3,
        'RGBA': 4,
        'L': 1,
        'P': 1,
        '1': 0.125,
    }
    
    bpp = bytes_per_pixel.get(mode, 3)
    expected_size = width * height * bpp
    
    # Add header overhead
    actual_size = os.path.getsize(image_file)
    
    print(f"Image: {image_file}")
    print(f"Dimensions: {width}x{height}")
    print(f"Expected size: {expected_size:.0f} bytes")
    print(f"Actual size: {actual_size} bytes")
    print(f"Overhead: {actual_size - expected_size:.0f} bytes ({(actual_size - expected_size) / actual_size * 100:.1f}%)")
    
    if actual_size - expected_size > expected_size * 0.1:
        print("⚠ Significant size anomaly detected!")
        return True
    
    return False

import os
check_image_size_anomaly('suspicious.png')
```

#### Archive Size Analysis

Detect padding or hidden data in archives:

```python
import zipfile
import os

def analyze_archive_size(archive_file):
    """
    Detect size anomalies in archives
    """
    total_uncompressed = 0
    total_compressed = 0
    
    with zipfile.ZipFile(archive_file, 'r') as zf:
        for info in zf.infolist():
            total_uncompressed += info.file_size
            total_compressed += info.compress_size
    
    actual_size = os.path.getsize(archive_file)
    expected_size = total_compressed + 1000  # Add ~1KB for directory
    
    print(f"Archive: {archive_file}")
    print(f"Uncompressed total: {total_uncompressed} bytes")
    print(f"Compressed total: {total_compressed} bytes")
    print(f"Expected archive size: {expected_size} bytes")
    print(f"Actual archive size: {actual_size} bytes")
    print(f"Unexplained difference: {actual_size - expected_size} bytes")
    
    if actual_size - expected_size > 1000:
        print("⚠ Archive contains hidden data!")
        return actual_size - expected_size

analyze_archive_size('archive.zip')
```

#### Detecting Null Byte Padding

Identify files with excessive null byte padding:

```python
def detect_null_padding(filename):
    """
    Detect files padded with null bytes (common CTF technique)
    """
    with open(filename, 'rb') as f:
        data = f.read()
    
    # Count null bytes
    null_count = data.count(b'\x00')
    total_size = len(data)
    null_percentage = (null_count / total_size) * 100
    
    print(f"File: {filename}")
    print(f"Total size: {total_size} bytes")
    print(f"Null bytes: {null_count} ({null_percentage:.1f}%)")
    
    if null_percentage > 10:
        print("⚠ Excessive null byte padding detected!")
        
        # Find the last non-null byte
        for i in range(total_size - 1, -1, -1):
            if data[i] != 0x00:
                actual_content_size = i + 1
                padding_size = total_size - actual_content_size
                print(f"  Actual content: {actual_content_size} bytes")
                print(f"  Padding: {padding_size} bytes")
                
                # Extract content
                return data[:actual_content_size]
    
    return data

content = detect_null_padding('padded.bin')
```

#### Compression Ratio Analysis

Analyze compression efficiency to detect anomalies:

```python
import gzip
import os

def analyze_compression(filename):
    """
    Analyze compression ratio anomalies
    High compression ratio = highly compressible = likely plaintext/repetitive
    Low compression ratio = already compressed or random
    """
    with open(filename, 'rb') as f:
        original_data = f.read()
    
    original_size = len(original_data)
    
    # Try compression
    compressed_data = gzip.compress(original_data)
    compressed_size = len(compressed_data)
    
    compression_ratio = (1 - compressed_size / original_size) * 100
    
    print(f"File: {filename}")
    print(f"Original size: {original_size} bytes")
    print(f"Compressed size: {compressed_size} bytes")
    print(f"Compression ratio: {compression_ratio:.1f}%")
    
    if compression_ratio > 80:
        print("⚠ Highly compressible (likely plaintext or structured data)")
    elif compression_ratio < 5:
        print("⚠ Incompressible (likely already compressed or encrypted)")

analyze_compression('target.bin')
```

#### Size Pattern Detection

Identify files with suspicious size patterns:

```python
import os
import glob

def analyze_directory_sizes(directory):
    """
    Detect files with unusual sizes in a directory
    """
    files = glob.glob(os.path.join(directory, '*'))
    sizes = []
    
    for file in files:
        if os.path.isfile(file):
            size = os.path.getsize(file)
            sizes.append((file, size))
    
    # Sort by size
    sizes.sort(key=lambda x: x[1])
    
    print("File size analysis:")
    for filename, size in sizes:
        print(f"{os.path.basename(filename):30} {size:10} bytes")
    
    # Detect outliers
    if len(sizes) > 2:
        avg_size = sum(s[1] for s in sizes) / len(sizes)
        for filename, size in sizes:
            if size > avg_size * 2 or size < avg_size / 2:
                print(f"\n⚠ Anomaly: {os.path.basename(filename)} ({size} bytes)")

analyze_directory_sizes('.')
```

### Timestamp Analysis

File timestamps (creation, modification, access times) reveal file history, suspicious activity, and data processing sequences. This is critical for forensic CTF challenges.

#### Extracting File Timestamps

Retrieve and display file metadata:

```python
import os
import time
from datetime import datetime

def analyze_timestamps(filename):
    """
    Extract and display file timestamp information
    """
    stat_info = os.stat(filename)
    
    # Timestamps in Unix epoch format
    atime = stat_info.st_atime  # Access time
    mtime = stat_info.st_mtime  # Modification time
    ctime = stat_info.st_ctime  # Change time (metadata change on Unix, creation on Windows)
    
    # Convert to readable format
    atime_str = datetime.fromtimestamp(atime).strftime('%Y-%m-%d %H:%M:%S')
    mtime_str = datetime.fromtimestamp(mtime).strftime('%Y-%m-%d %H:%M:%S')
    ctime_str = datetime.fromtimestamp(ctime).strftime('%Y-%m-%d %H:%M:%S')
    
    print(f"File: {filename}")
    print(f"Access time (atime): {atime_str} ({atime})")
    print(f"Modification time (mtime): {mtime_str} ({mtime})")
    print(f"Change time (ctime): {ctime_str} ({ctime})")
    print(f"File size: {stat_info.st_size} bytes")

analyze_timestamps('target.file')
```

#### Image EXIF Timestamp Analysis

Extract metadata from images including timestamps:

```python
from PIL import Image
from PIL.ExifTags import TAGS
from datetime import datetime

def analyze_image_timestamps(image_file):
    """
    Extract EXIF timestamps from images
    """
    img = Image.open(image_file)
    exif_data = img._getexif()
    
    if not exif_data:
        print("No EXIF data found")
        return
    
    print(f"Image: {image_file}")
    
    # Common EXIF timestamp tags
    timestamp_tags = {
        306: 'DateTime',
        36867: 'DateTimeOriginal',
        36868: 'DateTimeDigitized',
        306: 'DateTime',
    }
    
    for tag_id, tag_name in timestamp_tags.items():
        if tag_id in exif_data:
            timestamp = exif_data[tag_id]
            print(f"{tag_name}: {timestamp}")
    
    # GPS timestamp if available
    if 36867 in exif_data:
        original_time = exif_data[36867]
        print(f"Photo taken: {original_time}")

analyze_image_timestamps('suspicious.jpg')
```

#### Archive Timestamp Pattern Analysis

Analyze timestamps within archives:

```python
import zipfile
from datetime import datetime

def analyze_archive_timestamps(archive_file):
    """
    Extract and analyze timestamps from archived files
    """
    with zipfile.ZipFile(archive_file, 'r') as zf:
        print(f"Archive: {archive_file}")
        print("File timestamps within archive:")
        print(f"{'Filename':<40} {'Timestamp':<20}")
        print("-" * 60)
        
        timestamps = []
        
        for info in zf.infolist():
            # ZIP timestamps are DOS format (date + time)
            dt = datetime(*info.date_time)
            timestamps.append((info.filename, dt))
            print(f"{info.filename:<40} {dt.strftime('%Y-%m-%d %H:%M:%S')}")
        
        # Detect timestamp anomalies
        if len(timestamps) > 1:
            times = [t[1] for t in timestamps]
            time_diff = max(times) - min(times)
            
            print(f"\nTime span: {time_diff}")
            
            if time_diff.total_seconds() == 0:
                print("⚠ All files have identical timestamps (suspicious)")

analyze_archive_timestamps('suspicious.zip')
```

#### Detecting Timestamp Tampering

Identify inconsistent or suspicious timestamp patterns:

```python
import os
from datetime import datetime, timedelta

def detect_timestamp_tampering(directory):
    """
    Detect suspicious timestamp patterns
    """
    files = []
    
    for filename in os.listdir(directory):
        filepath = os.path.join(directory, filename)
        if os.path.isfile(filepath):
            stat_info = os.stat(filepath)
            files.append({
                'name': filename,
                'atime': stat_info.st_atime,
                'mtime': stat_info.st_mtime,
                'ctime': stat_info.st_ctime,
            })
    
    print("Timestamp analysis:")
    suspicious = False
    
    for file_info in files:
        atime = datetime.fromtimestamp(file_info['atime'])
        mtime = datetime.fromtimestamp(file_info['mtime'])
        ctime = datetime.fromtimestamp(file_info['ctime'])
        
        # Check for suspicious patterns
        atime_mtime_diff = abs((atime - mtime).total_seconds())
        mtime_ctime_diff = abs((mtime - ctime).total_seconds())
        
        print(f"\n{file_info['name']}:")
        print(f"  atime: {atime}")
        print(f"  mtime: {mtime}")
        print(f"  ctime: {ctime}")
        
        # atime should typically be after or equal to mtime
        if atime < mtime and atime_mtime_diff > 86400: # More than 1 day difference print(f" ⚠ atime is {atime_mtime_diff / 86400:.1f} days before mtime (suspicious)") suspicious = True

    # ctime should equal mtime for regular file operations
    if mtime_ctime_diff > 300:  # More than 5 minutes
        print(f"  ⚠ ctime differs from mtime by {mtime_ctime_diff}s (possible tampering)")
        suspicious = True

return suspicious

is_suspicious = detect_timestamp_tampering('.')
````

#### Timeline Reconstruction

Build a chronological timeline of file events:

```python
from datetime import datetime
import os

def build_file_timeline(directory):
    """
    Create timeline of file modifications
    """
    events = []
    
    for root, dirs, files in os.walk(directory):
        for filename in files:
            filepath = os.path.join(root, filename)
            stat_info = os.stat(filepath)
            
            events.append({
                'timestamp': stat_info.st_mtime,
                'type': 'modification',
                'file': filepath,
                'size': stat_info.st_size,
            })
    
    # Sort by timestamp
    events.sort(key=lambda x: x['timestamp'])
    
    print("File Timeline:")
    print(f"{'Time':<20} {'Type':<15} {'File':<40} {'Size'}")
    print("-" * 80)
    
    for event in events:
        dt = datetime.fromtimestamp(event['timestamp']).strftime('%Y-%m-%d %H:%M:%S')
        print(f"{dt} {event['type']:<15} {event['file']:<40} {event['size']:>10}")
    
    return events

build_file_timeline('.')
````

#### Relative Timestamp Analysis

Identify related files by timestamp proximity:

```python
from datetime import datetime, timedelta
import os

def find_related_files(directory, time_window=60):
    """
    Find files created/modified within a specific time window
    Useful for identifying files processed together
    """
    files = []
    
    for filename in os.listdir(directory):
        filepath = os.path.join(directory, filename)
        if os.path.isfile(filepath):
            mtime = os.path.getmtime(filepath)
            files.append((filename, mtime))
    
    # Sort by modification time
    files.sort(key=lambda x: x[1])
    
    clusters = []
    current_cluster = []
    last_time = None
    
    for filename, mtime in files:
        if last_time and (mtime - last_time) > time_window:
            if current_cluster:
                clusters.append(current_cluster)
            current_cluster = []
        
        current_cluster.append((filename, mtime))
        last_time = mtime
    
    if current_cluster:
        clusters.append(current_cluster)
    
    print(f"Files grouped by {time_window}s modification time window:")
    
    for i, cluster in enumerate(clusters):
        print(f"\nCluster {i+1}:")
        for filename, mtime in cluster:
            dt = datetime.fromtimestamp(mtime).strftime('%Y-%m-%d %H:%M:%S')
            print(f"  {filename:<30} {dt}")

find_related_files('.', time_window=300)
```

#### Detecting Timestamp Consistency

Verify consistency between file timestamps and content:

```python
import os
from datetime import datetime
import hashlib

def verify_timestamp_consistency(file1, file2):
    """
    Compare files with different timestamps
    If content is identical but timestamps differ, may indicate copies
    """
    # Read files
    with open(file1, 'rb') as f:
        data1 = f.read()
    with open(file2, 'rb') as f:
        data2 = f.read()
    
    # Calculate hashes
    hash1 = hashlib.sha256(data1).hexdigest()
    hash2 = hashlib.sha256(data2).hexdigest()
    
    # Get timestamps
    stat1 = os.stat(file1)
    stat2 = os.stat(file2)
    
    mtime1 = datetime.fromtimestamp(stat1.st_mtime).strftime('%Y-%m-%d %H:%M:%S')
    mtime2 = datetime.fromtimestamp(stat2.st_mtime).strftime('%Y-%m-%d %H:%M:%S')
    
    print(f"File 1: {file1}")
    print(f"  Modified: {mtime1}")
    print(f"  SHA256: {hash1}")
    
    print(f"\nFile 2: {file2}")
    print(f"  Modified: {mtime2}")
    print(f"  SHA256: {hash2}")
    
    if hash1 == hash2:
        if stat1.st_mtime != stat2.st_mtime:
            print("\n⚠ Identical content but different timestamps (likely copies)")
        else:
            print("\nIdentical files with same timestamp (likely hard links)")
    else:
        print("\nFiles differ in content")

verify_timestamp_consistency('file1.bin', 'file2.bin')
```

#### Forensic Timeline Output

Generate forensic-grade timeline reports:

```python
import os
from datetime import datetime
import csv

def generate_forensic_timeline(directory, output_csv):
    """
    Generate timeline in forensic analysis format
    """
    events = []
    
    for root, dirs, files in os.walk(directory):
        for filename in files:
            filepath = os.path.join(root, filename)
            try:
                stat_info = os.stat(filepath)
                
                # Get all timestamps
                atime = datetime.fromtimestamp(stat_info.st_atime)
                mtime = datetime.fromtimestamp(stat_info.st_mtime)
                ctime = datetime.fromtimestamp(stat_info.st_ctime)
                
                events.append({
                    'date': mtime.date(),
                    'time': mtime.time(),
                    'timestamp': mtime.isoformat(),
                    'timezone': 'UTC',
                    'macb': f"M.A.C.B: {mtime}/{atime}/{ctime}/{mtime}",
                    'source': 'FILE',
                    'sourcetype': 'FILE STAT',
                    'type': 'FILE',
                    'user': 'N/A',
                    'host': 'N/A',
                    'shortdesc': f"Modified: {filepath}",
                    'desc': f"File modified at {mtime.isoformat()}",
                    'version': 2,
                    'filename': filepath,
                    'size': stat_info.st_size,
                })
            except Exception as e:
                print(f"Error processing {filepath}: {e}")
    
    # Sort by timestamp
    events.sort(key=lambda x: x['timestamp'])
    
    # Write to CSV
    with open(output_csv, 'w', newline='') as f:
        writer = csv.DictWriter(f, fieldnames=events[0].keys() if events else [])
        writer.writeheader()
        writer.writerows(events)
    
    print(f"Timeline written to {output_csv}")
    print(f"Total events: {len(events)}")

generate_forensic_timeline('.', 'timeline.csv')
```

#### Timestamp Anomaly Scoring

Calculate anomaly scores for suspicious timestamp patterns:

```python
import os
from datetime import datetime
import statistics

def score_timestamp_anomalies(directory):
    """
    Score files for timestamp anomalies
    Higher score = more suspicious
    """
    files = []
    
    for filename in os.listdir(directory):
        filepath = os.path.join(directory, filename)
        if os.path.isfile(filepath):
            stat_info = os.stat(filepath)
            files.append({
                'name': filename,
                'atime': stat_info.st_atime,
                'mtime': stat_info.st_mtime,
                'ctime': stat_info.st_ctime,
                'size': stat_info.st_size,
            })
    
    # Calculate statistics
    mtimes = [f['mtime'] for f in files]
    sizes = [f['size'] for f in files]
    
    if len(mtimes) > 1:
        mtime_mean = statistics.mean(mtimes)
        mtime_stdev = statistics.stdev(mtimes)
    
    if len(sizes) > 1:
        size_mean = statistics.mean(sizes)
        size_stdev = statistics.stdev(sizes)
    
    print("Timestamp Anomaly Scores:")
    print(f"{'File':<30} {'Score':<8} {'Anomalies'}")
    print("-" * 50)
    
    for file_info in files:
        score = 0
        anomalies = []
        
        # Check mtime deviation
        if len(mtimes) > 1:
            mtime_z_score = abs((file_info['mtime'] - mtime_mean) / mtime_stdev) if mtime_stdev > 0 else 0
            if mtime_z_score > 2:
                score += 25
                anomalies.append(f"mtime_z={mtime_z_score:.1f}")
        
        # Check size deviation
        if len(sizes) > 1:
            size_z_score = abs((file_info['size'] - size_mean) / size_stdev) if size_stdev > 0 else 0
            if size_z_score > 2:
                score += 25
                anomalies.append(f"size_z={size_z_score:.1f}")
        
        # Check timestamp ordering
        if file_info['atime'] < file_info['mtime']:
            score += 10
            anomalies.append("atime<mtime")
        
        if file_info['ctime'] < file_info['mtime']:
            score += 15
            anomalies.append("ctime<mtime")
        
        anomaly_str = ", ".join(anomalies) if anomalies else "None"
        print(f"{file_info['name']:<30} {score:<8} {anomaly_str}")

score_timestamp_anomalies('.')
```

[Inference] In CTF forensic challenges, timestamp analysis often reveals processing sequences, file relationships, and potential manipulation attempts. Inconsistencies between atime, mtime, and ctime are strong indicators of tampering or artificial modification.

---

## Automated Workflows

### Tool Chaining

Tool chaining integrates multiple specialized steganography tools into sequential workflows, automating the progression from initial analysis through data extraction and validation. Effective chaining reduces manual repetition, systematically explores multiple detection vectors, and prioritizes results based on confidence levels.

**Sequential Analysis Pipeline Architecture**

Design chains to progress from fast, broad detection to targeted extraction:

```
Initial Scan (zsteg, stegdetect) 
    ↓ (confidence threshold)
Detailed Analysis (stegoVeritas, stegsolve)
    ↓ (pattern identification)
Data Extraction (file carving, LSB recovery)
    ↓ (format detection)
Post-Processing (decompression, decryption)
    ↓
Validation & Output
```

**Basic Tool Chain Example: PNG Analysis**

Orchestrate PNG steganography analysis:

```bash
#!/bin/bash
target="$1"

echo "[*] Stage 1: Quick Detection with zsteg"
zsteg_output=$(zsteg "$target" -l 12 2>/dev/null | head -20)
if [[ -n "$zsteg_output" ]]; then
    echo "[+] zsteg detected data:"
    echo "$zsteg_output"
    extraction_method="zsteg"
else
    echo "[-] zsteg found nothing obvious"
    extraction_method="detailed"
fi

echo ""
echo "[*] Stage 2: Detailed Analysis with pngcheck"
pngcheck -vvv "$target" | grep -E "chunk|unknown|bad" > pngcheck_report.txt
if grep -q "unknown" pngcheck_report.txt; then
    echo "[+] Suspicious chunks detected"
    cat pngcheck_report.txt
fi

echo ""
echo "[*] Stage 3: Channel Decomposition"
convert "$target" -colorspace RGB \
    -channel R -separate "Red_channel.png" \
    -channel G -separate "Green_channel.png" \
    -channel B -separate "Blue_channel.png"
echo "[+] Channels extracted: Red_channel.png, Green_channel.png, Blue_channel.png"

if [[ "$extraction_method" == "zsteg" ]]; then
    echo ""
    echo "[*] Stage 4: Extract with zsteg"
    zsteg "$target" -c rgb -b 1 -o extracted_rgb_b1.bin
    file extracted_rgb_b1.bin
    strings extracted_rgb_b1.bin | grep -i "flag\|ctf"
fi

echo ""
echo "[*] Analysis complete"
```

Execute:

```bash
chmod +x png_chain.sh
./png_chain.sh target.png
```

**JPEG Analysis Chain**

Multi-stage JPEG steganography detection and extraction:

```bash
#!/bin/bash
target="$1"

echo "[*] Stage 1: stegdetect Quick Scan"
stegdetect -d "$target" 2>/dev/null | tee jpeg_detection.txt

echo ""
echo "[*] Stage 2: Extract Metadata"
identify -verbose "$target" | grep -E "Exif|Comment|Description" > metadata.txt
if [[ -s metadata.txt ]]; then
    echo "[+] Metadata found:"
    cat metadata.txt
fi

echo ""
echo "[*] Stage 3: Color Channel Analysis"
for channel in R G B; do
    convert "$target" -colorspace RGB \
        -channel "$channel" -separate \
        "${channel}_channel.png"
done
echo "[+] Channels extracted"

echo ""
echo "[*] Stage 4: LSB Extraction (Manual)"
convert "$target" \
    -evaluate Bitwise-and 1 \
    -auto-level \
    lsb_layer_0.png
echo "[+] LSB layer 0 extracted to lsb_layer_0.png"

echo ""
echo "[*] Stage 5: jsteg Extraction Attempt"
jsteg reveal "$target" jsteg_extracted.bin 2>/dev/null
if [[ -f jsteg_extracted.bin ]] && [[ -s jsteg_extracted.bin ]]; then
    echo "[+] jsteg data extracted:"
    file jsteg_extracted.bin
    strings jsteg_extracted.bin | head -10
fi

echo ""
echo "[*] Complete. Check: jpeg_detection.txt, metadata.txt, *_channel.png, lsb_layer_0.png"
```

**Multi-Format Universal Chain**

Detect file type and apply appropriate tools:

```bash
#!/bin/bash
target="$1"
target_type=$(file -b "$target" | cut -d' ' -f1)

echo "[*] Detected type: $target_type"

case "$target_type" in
    "PNG")
        echo "[+] Running PNG chain..."
        zsteg "$target" -v
        pngcheck -vvv "$target" | head -30
        ;;
    "JPEG")
        echo "[+] Running JPEG chain..."
        stegdetect -v "$target"
        identify -verbose "$target" | grep -i comment
        ;;
    "GIF")
        echo "[+] Running GIF chain..."
        identify -verbose "$target" | grep -i delay
        convert "$target" frame_%d.png  # Extract all frames
        ;;
    "BMP")
        echo "[+] Running BMP chain..."
        zsteg "$target" -v
        ;;
    *)
        echo "[!] Unknown type, running generic analysis..."
        hexdump -C "$target" | head -20
        strings "$target" | grep -i "flag\|password"
        ;;
esac
```

**Conditional Branching Based on Results**

Chain decisions based on intermediate findings:

```bash
#!/bin/bash
target="$1"

# Stage 1: Quick scan
quick_result=$(zsteg "$target" -l 12 2>/dev/null)
confidence=$(echo "$quick_result" | wc -l)

if [[ $confidence -gt 5 ]]; then
    echo "[+] High confidence detection, proceeding to extraction"
    zsteg "$target" -c rgb -b 1 -o data_rgb_b1.bin
    zsteg "$target" -c a -b 1 -o data_alpha_b1.bin
elif [[ $confidence -gt 1 ]]; then
    echo "[+] Medium confidence, detailed analysis"
    python3 -m stego_tk.stego_tk "$target"
    # Examine stegoVeritas output
    ls -la "${target}.d/LSB/"
else
    echo "[*] Low/no quick detection, trying specialized tools"
    stegdetect -v "$target"
    pngcheck -vvv "$target"
    strings "$target" | grep -E "flag|FLAG|CTF"
fi
```

**Error Handling and Fallback Mechanisms**

Gracefully handle tool failures and missing dependencies:

```bash
#!/bin/bash
target="$1"

run_tool() {
    local tool=$1
    local args=$2
    
    if ! command -v "$tool" &> /dev/null; then
        echo "[-] $tool not installed, skipping"
        return 1
    fi
    
    if $tool $args "$target" 2>/dev/null; then
        echo "[+] $tool succeeded"
        return 0
    else
        echo "[-] $tool failed"
        return 1
    fi
}

echo "[*] Attempting analysis chain..."
run_tool "zsteg" "-v" || true
run_tool "stegdetect" "-v" || true
run_tool "pngcheck" "-vvv" || true

echo "[*] Chain complete (some tools may have failed)"
```

**Output Aggregation and Reporting**

Consolidate results from multiple tools:

```bash
#!/bin/bash
target="$1"
report_file="${target%.jpg}_analysis_report.txt"

{
    echo "=== Steganography Analysis Report ==="
    echo "File: $target"
    echo "Date: $(date)"
    echo ""
    
    echo "--- File Information ---"
    file "$target"
    identify "$target"
    echo ""
    
    echo "--- zsteg Results ---"
    zsteg "$target" -v 2>/dev/null | head -30
    echo ""
    
    echo "--- stegdetect Results ---"
    stegdetect -d "$target" 2>/dev/null
    echo ""
    
    echo "--- Metadata Strings ---"
    strings "$target" | grep -i -E "flag|password|secret|ctf" | head -20
    echo ""
    
} | tee "$report_file"

echo "[+] Report saved to: $report_file"
```

**Performance Optimization for Large Datasets**

Parallelize tool chaining for multiple images:

```bash
#!/bin/bash
image_dir="$1"
thread_count=4

echo "[*] Processing images in $image_dir with $thread_count threads"

find "$image_dir" -type f \( -name "*.jpg" -o -name "*.png" \) | \
    xargs -P "$thread_count" -I {} bash -c '
        target="{}"
        echo "[*] Processing $target"
        zsteg "$target" -l 12 2>/dev/null | head -5
        stegdetect -d "$target" 2>/dev/null
    '
```

### Script Automation

Automation scripts encapsulate entire workflows into reusable, configurable tools. Well-designed automation reduces setup time between CTF challenges, maintains consistency across analyses, and captures institutional knowledge about steganography patterns.

**Foundational Automation Framework**

Create a master automation framework:

```bash
#!/bin/bash
# stego_master.sh - Comprehensive steganography analysis framework

set -e
trap 'echo "[!] Script interrupted"; exit 1' INT TERM

# Configuration
DEBUG=0
VERBOSE=1
OUTPUT_DIR="stego_analysis_$(date +%Y%m%d_%H%M%S)"
MAX_THREADS=4

# Logging functions
log_info() {
    echo "[*] $1"
}

log_success() {
    echo "[+] $1"
}

log_error() {
    echo "[-] $1" >&2
}

log_debug() {
    if [[ $DEBUG -eq 1 ]]; then
        echo "[D] $1"
    fi
}

# Tool availability check
check_tools() {
    local required_tools=("zsteg" "stegdetect" "pngcheck" "convert" "strings" "file")
    local missing_tools=()
    
    for tool in "${required_tools[@]}"; do
        if ! command -v "$tool" &> /dev/null; then
            missing_tools+=("$tool")
        fi
    done
    
    if [[ ${#missing_tools[@]} -gt 0 ]]; then
        log_error "Missing tools: ${missing_tools[*]}"
        return 1
    fi
    return 0
}

# Main analysis function
analyze_image() {
    local target="$1"
    local analysis_dir="$OUTPUT_DIR/$(basename "$target")"
    
    mkdir -p "$analysis_dir"
    log_info "Analyzing $target → $analysis_dir"
    
    # Determine file type
    local file_type=$(file -b "$target" | cut -d' ' -f1-2)
    log_debug "File type: $file_type"
    
    # Common analysis
    {
        echo "=== Analysis for: $target ==="
        echo "Type: $file_type"
        echo "Analysis Time: $(date)"
        echo ""
    } > "$analysis_dir/report.txt"
    
    # File info
    {
        echo "--- File Information ---"
        file "$target"
        identify "$target" 2>/dev/null || echo "identify not available"
        stat "$target"
        echo ""
    } >> "$analysis_dir/report.txt"
    
    # Extract strings
    {
        echo "--- Embedded Strings ---"
        strings "$target" | grep -E -i "flag|password|secret|ctf|flag{" | head -20
        echo ""
    } >> "$analysis_dir/report.txt"
    
    # Format-specific analysis
    case "$file_type" in
        "PNG"*)
            log_info "Running PNG-specific analysis"
            
            # pngcheck
            pngcheck -vvv "$target" >> "$analysis_dir/pngcheck.txt" 2>&1 || true
            
            # zsteg
            zsteg "$target" -v > "$analysis_dir/zsteg_output.txt" 2>&1 || true
            
            # Extract channels
            convert "$target" -colorspace RGB \
                -channel R -separate "$analysis_dir/channel_R.png" \
                -channel G -separate "$analysis_dir/channel_G.png" \
                -channel B -separate "$analysis_dir/channel_B.png" 2>/dev/null || true
            
            # Extract LSB
            convert "$target" \
                -evaluate Bitwise-and 1 \
                -auto-level \
                "$analysis_dir/lsb_layer_0.png" 2>/dev/null || true
            
            {
                echo "--- PNG Analysis ---"
                cat "$analysis_dir/zsteg_output.txt" | head -30
                echo ""
            } >> "$analysis_dir/report.txt"
            ;;
            
        "JPEG"*)
            log_info "Running JPEG-specific analysis"
            
            # stegdetect
            stegdetect -v "$target" > "$analysis_dir/stegdetect.txt" 2>&1 || true
            
            # Metadata
            identify -verbose "$target" > "$analysis_dir/metadata.txt" 2>&1 || true
            
            # jsteg attempt
            jsteg reveal "$target" "$analysis_dir/jsteg_extracted.bin" 2>/dev/null || true
            
            # Color channels
            for channel in R G B; do
                convert "$target" -colorspace RGB \
                    -channel "$channel" -separate \
                    "$analysis_dir/channel_${channel}.png" 2>/dev/null || true
            done
            
            {
                echo "--- JPEG Analysis ---"
                cat "$analysis_dir/stegdetect.txt" 2>/dev/null || echo "stegdetect unavailable"
                echo ""
            } >> "$analysis_dir/report.txt"
            ;;
            
        "GIF"*)
            log_info "Running GIF-specific analysis"
            
            # Extract frames
            convert "$target" +adjoin "$analysis_dir/frame_%d.png" 2>/dev/null || true
            frame_count=$(ls "$analysis_dir"/frame_*.png 2>/dev/null | wc -l)
            
            {
                echo "--- GIF Analysis ---"
                echo "Frames extracted: $frame_count"
                echo ""
            } >> "$analysis_dir/report.txt"
            ;;
            
        *)
            log_info "Running generic analysis"
            hexdump -C "$target" | head -50 > "$analysis_dir/hex_dump.txt"
            ;;
    esac
    
    log_success "Analysis complete: $analysis_dir"
}

# Main execution
main() {
    if [[ $# -eq 0 ]]; then
        log_error "Usage: $0 <image> [image2] [image3] ..."
        exit 1
    fi
    
    log_info "Steganography Analysis Framework"
    
    if ! check_tools; then
        log_error "Required tools missing. Install missing dependencies."
        exit 1
    fi
    
    mkdir -p "$OUTPUT_DIR"
    
    for target in "$@"; do
        if [[ ! -f "$target" ]]; then
            log_error "File not found: $target"
            continue
        fi
        analyze_image "$target"
    done
    
    log_success "All analysis complete. Results in: $OUTPUT_DIR"
    log_info "Summary report: $OUTPUT_DIR/SUMMARY.txt"
    
    # Generate summary
    {
        echo "=== Analysis Summary ==="
        echo "Generated: $(date)"
        echo ""
        echo "Images analyzed: $#"
        for target in "$@"; do
            echo "  - $target"
        done
    } > "$OUTPUT_DIR/SUMMARY.txt"
}

main "$@"
```

Execute and analyze multiple images:

```bash
chmod +x stego_master.sh
./stego_master.sh image1.png image2.jpg image3.gif
ls -la stego_analysis_*/
```

**Specialized Python Automation Framework**

Python-based framework for complex logic and data manipulation:

```python
#!/usr/bin/env python3
"""
steganography_automation.py - Advanced steganography analysis automation
"""

import os
import sys
import json
import subprocess
import hashlib
from pathlib import Path
from datetime import datetime
from typing import Dict, List, Optional

class StegoAnalyzer:
    """Automated steganography analysis framework"""
    
    def __init__(self, output_dir: str = None):
        self.output_dir = Path(output_dir or f"analysis_{datetime.now().strftime('%Y%m%d_%H%M%S')}")
        self.output_dir.mkdir(exist_ok=True)
        self.results = {
            'timestamp': datetime.now().isoformat(),
            'images': []
        }
    
    def run_command(self, cmd: List[str], capture: bool = True) -> Optional[str]:
        """Execute shell command safely"""
        try:
            result = subprocess.run(
                cmd,
                capture_output=capture,
                text=True,
                timeout=30
            )
            return result.stdout if capture else None
        except subprocess.TimeoutExpired:
            print(f"[-] Command timed out: {' '.join(cmd)}")
            return None
        except Exception as e:
            print(f"[-] Command failed: {e}")
            return None
    
    def check_file_type(self, filepath: str) -> str:
        """Determine file type"""
        output = self.run_command(['file', '-b', filepath])
        return output.split('\n')[0] if output else 'Unknown'
    
    def extract_strings(self, filepath: str) -> List[str]:
        """Extract relevant strings from file"""
        output = self.run_command(['strings', filepath])
        if not output:
            return []
        
        lines = output.split('\n')
        keywords = ['flag', 'FLAG', 'password', 'secret', 'ctf', 'FLAG{']
        relevant = [l for l in lines if any(k in l for k in keywords)]
        return relevant[:20]
    
    def analyze_png(self, filepath: str) -> Dict:
        """PNG-specific analysis"""
        result_dir = self.output_dir / Path(filepath).stem / 'png_analysis'
        result_dir.mkdir(parents=True, exist_ok=True)
        
        analysis = {
            'type': 'PNG',
            'tools_run': []
        }
        
        # zsteg analysis
        zsteg_output = self.run_command(['zsteg', filepath, '-v'])
        if zsteg_output:
            (result_dir / 'zsteg.txt').write_text(zsteg_output)
            analysis['tools_run'].append('zsteg')
        
        # pngcheck analysis
        pngcheck_output = self.run_command(['pngcheck', '-vvv', filepath])
        if pngcheck_output:
            (result_dir / 'pngcheck.txt').write_text(pngcheck_output)
            analysis['tools_run'].append('pngcheck')
        
        # Channel extraction
        channels = ['R', 'G', 'B', 'A']
        for channel in channels:
            cmd = [
                'convert', filepath,
                '-colorspace', 'RGB',
                '-channel', channel,
                '-separate',
                str(result_dir / f'channel_{channel}.png')
            ]
            if self.run_command(cmd, capture=False):
                pass  # Silent success
        
        # LSB extraction
        cmd = [
            'convert', filepath,
            '-evaluate', 'Bitwise-and', '1',
            '-auto-level',
            str(result_dir / 'lsb_0.png')
        ]
        self.run_command(cmd, capture=False)
        
        return analysis
    
    def analyze_jpeg(self, filepath: str) -> Dict:
        """JPEG-specific analysis"""
        result_dir = self.output_dir / Path(filepath).stem / 'jpeg_analysis'
        result_dir.mkdir(parents=True, exist_ok=True)
        
        analysis = {
            'type': 'JPEG',
            'tools_run': []
        }
        
        # stegdetect
        stegdetect_output = self.run_command(['stegdetect', '-v', filepath])
        if stegdetect_output:
            (result_dir / 'stegdetect.txt').write_text(stegdetect_output)
            analysis['tools_run'].append('stegdetect')
        
        # Metadata
        metadata_output = self.run_command(['identify', '-verbose', filepath])
        if metadata_output:
            (result_dir / 'metadata.txt').write_text(metadata_output)
            analysis['tools_run'].append('identify')
        
        # jsteg extraction
        jsteg_result = self.run_command(
            ['jsteg', 'reveal', filepath, str(result_dir / 'jsteg_extracted.bin')]
        )
        if jsteg_result is not None:
            analysis['tools_run'].append('jsteg')
        
        # Color channels
        for channel in ['R', 'G', 'B']:
            cmd = [
                'convert', filepath,
                '-colorspace', 'RGB',
                '-channel', channel,
                '-separate',
                str(result_dir / f'channel_{channel}.png')
            ]
            self.run_command(cmd, capture=False)
        
        return analysis
    
    def analyze_gif(self, filepath: str) -> Dict:
        """GIF-specific analysis"""
        result_dir = self.output_dir / Path(filepath).stem / 'gif_analysis'
        result_dir.mkdir(parents=True, exist_ok=True)
        
        # Extract frames
        frame_pattern = str(result_dir / 'frame_%d.png')
        self.run_command(['convert', filepath, '+adjoin', frame_pattern], capture=False)
        
        frame_count = len(list(result_dir.glob('frame_*.png')))
        
        return {
            'type': 'GIF',
            'frames_extracted': frame_count
        }
    
    def analyze_image(self, filepath: str):
        """Main analysis dispatcher"""
        if not os.path.exists(filepath):
            print(f"[-] File not found: {filepath}")
            return
        
        print(f"[*] Analyzing {filepath}")
        file_type = self.check_file_type(filepath)
        
        img_analysis = {
            'filename': Path(filepath).name,
            'file_type': file_type,
            'hash': hashlib.sha256(open(filepath, 'rb').read()).hexdigest(),
            'strings_found': self.extract_strings(filepath),
            'specific_analysis': None
        }
        
        if 'PNG' in file_type:
            img_analysis['specific_analysis'] = self.analyze_png(filepath)
        elif 'JPEG' in file_type:
            img_analysis['specific_analysis'] = self.analyze_jpeg(filepath)
        elif 'GIF' in file_type:
            img_analysis['specific_analysis'] = self.analyze_gif(filepath)
        
        self.results['images'].append(img_analysis)
        print(f"[+] Analysis complete: {filepath}")
    
    def generate_report(self):
        """Generate JSON report"""
        report_path = self.output_dir / 'analysis_report.json'
        report_path.write_text(json.dumps(self.results, indent=2))
        print(f"[+] Report saved: {report_path}")
        
        # HTML report
        self._generate_html_report()
    
    def _generate_html_report(self):
        """Generate HTML report"""
        html_content = f"""
        <html>
        <head>
            <title>Steganography Analysis Report</title>
            <style>
                body {{ font-family: Arial; margin: 20px; }}
                .image {{ margin: 20px 0; padding: 10px; border: 1px solid #ccc; }}
                .result {{ margin: 10px 0; padding: 5px; background: #f0f0f0; }}
            </style>
        </head>
        <body>
            <h1>Steganography Analysis Report</h1>
            <p>Generated: {self.results['timestamp']}</p>
            <hr>
        """
        
        for img in self.results['images']:
            html_content += f"""
            <div class="image">
                <h2>{img['filename']}</h2>
                <p><strong>Type:</strong> {img['file_type']}</p>
                <p><strong>SHA256:</strong> {img['hash']}</p>
                <p><strong>Strings Found:</strong></p>
                <ul>
            """
            for s in img['strings_found']:
                html_content += f"<li>{s}</li>"
            html_content += "</ul></div>"
        
        html_content += """
        </body>
        </html>
        """
        
        report_path = self.output_dir / 'analysis_report.html'
        report_path.write_text(html_content)
        print(f"[+] HTML report: {report_path}")

def main():
    if len(sys.argv) < 2:
        print(f"Usage: {sys.argv[0]} <image> [image2] [image3] ...")
        sys.exit(1)
    
    analyzer = StegoAnalyzer()
    
    for filepath in sys.argv[1:]:
        analyzer.analyze_image(filepath)
    
    analyzer.generate_report()

if __name__ == '__main__':
    main()
```

Execute:

```bash
chmod +x steganography_automation.py
python3 steganography_automation.py image1.png image2.jpg image3.gif
ls -la analysis_*/analysis_report.json
```

### Flag Format Recognition

Recognizing flag formats accelerates identification of successful data extraction and reduces time spent analyzing irrelevant output. CTF platforms use standardized formats that enable programmatic validation.

**Standard CTF Flag Formats**

**Common Formats:**

- `FLAG{...}` - Standard CTF format (uppercase, curly braces)
- `flag{...}` - Lowercase variant
- `CTF{...}` - Challenge-specific prefix
- `FLAG[...]` - Square bracket variant
- `FLAG:...` - Colon delimiter
- `flagid{...}` - Event-specific format
- `picoCTF{...}` - Platform-specific (picoCTF)
- `HTB{...}` - Platform-specific (HackTheBox)
- `ctf2024{...}` - Year-based format

**Base64 and Encoded Variants:**

- `RkxBR3suLi59` - Base64-encoded flag
- `666c6167{...}` - Hexadecimal representation
- `Zmxhd3s=` - Base64 with padding

**Regular Expression Patterns**

Create regex patterns for flag detection:

```python
#!/usr/bin/env python3
"""
flag_detector.py - Flag format recognition and extraction
"""

import re
import sys
from pathlib import Path

class FlagDetector:
    """Flag format recognition engine"""
    
    def __init__(self):
        # Comprehensive flag patterns
        self.patterns = {
            'standard_flag': r'FLAG\{[^}]+\}',
            'lowercase_flag': r'flag\{[^}]+\}',
            'ctf_prefix': r'(?:CTF|CTF2024|picoCTF|HTB|FLAG)\{[^}]+\}',
            'bracket_variant': r'FLAG\[[^\]]+\]',
            'colon_variant': r'FLAG:[^\s]+',
            'base64_encoded': r'(?:[A-Za-z0-9+/]{4})*(?:[A-Za-z0-9+/]{2}==|[A-Za-z0-9+/]{3}=)?',
            'hex_encoded': r'([0-9a-fA-F]{2})+',
            'custom_format': r'(?:password|secret|answer|key)\s*[=:]\s*[^\s]+',
        }
        
        # Compiled patterns
        self.compiled = {name: re.compile(pattern) 
                        for name, pattern in self.patterns.items()}
    
    def detect_in_text(self, text: str) -> dict:
        """Detect flags in text"""
        findings = {}
        
        for pattern_name, pattern in self.compiled.items():
            matches = pattern.findall(text)
            if matches:
                findings[pattern_name] = list(set(matches))  # Unique matches
        
        return findings
    
    def detect_in_file(self, filepath: str) -> dict:
        """Detect flags in file"""
        try:
            with open(filepath, 'rb') as f:
                data = f.read()
            
            # Try UTF-8 first
            try:
                text = data.decode('utf-8')
            except:
                # Fallback to latin-1
                text = data.decode('latin-1', errors='ignore')
            
            return self.detect_in_text(text)
        except Exception as e:
            print(f"[-] Error reading {filepath}: {e}")
            return {}
    
    def validate_flag(self, candidate: str) -> bool:
        """Validate flag format"""
        for pattern in self.compiled.values():
            if pattern.search(candidate):
                return True
        return False
    
    def extract_and_decode(self, flag_candidate: str) -> dict:
        """Attempt to extract and decode flag"""
        result = {
            'original': flag_candidate,
            'decoded_variants': []
        }
        
        # Try base64 decode
        import base64
        try:
            decoded = base64.b64decode(flag_candidate).decode('utf-8')
            if decoded != flag_candidate:
                result['decoded_variants'].append(('base64', decoded))
        except:
            pass
        
        # Try hex decode
        try:
            if len(flag_candidate) % 2 == 0:
                decoded = bytes.fromhex(flag_candidate).decode('utf-8')
                if decoded != flag_candidate:
                    result['decoded_variants'].append(('hex', decoded))
        except:
            pass
        
        return result

def main():
    if len(sys.argv) < 2:
        print(f"Usage: {sys.argv[0]} <file_or_text>")
        sys.exit(1)
    
    detector = FlagDetector()
    
    # Check if argument is file
    if Path(sys.argv[1]).exists():
        findings = detector.detect_in_file(sys.argv[1])
        print(f"[*] Analyzing file: {sys.argv[1]}")
    else:
        # Treat as text
        findings = detector.detect_in_text(sys.argv[1])
        print(f"[*] Analyzing text")
    
    if findings:
        print("[+] Flags detected:")
        for pattern_name, matches in findings.items():
            print(f"\n  {pattern_name}:")
            for match in matches:
                print(f"    - {match}")
                decoded = detector.extract_and_decode(match)
                if decoded['decoded_variants']:
                    for enc_type, decoded_val in decoded['decoded_variants']:
                        print(f"      [{enc_type}]: {decoded_val}")
    else:
        print("[-] No flags detected")

if __name__ == '__main__' : 
	main()
````

Execute:

```bash
chmod +x flag_detector.py
python3 flag_detector.py "FLAG{this_is_a_test_flag}"
python3 flag_detector.py extracted_data.txt
````

**Integration into Automation Pipelines**

Incorporate flag detection into analysis workflows:

```bash
#!/bin/bash
# auto_flag_extractor.sh - Extract and validate flags from analysis output

output_dir="$1"

if [[ ! -d "$output_dir" ]]; then
    echo "[-] Directory not found: $output_dir"
    exit 1
fi

echo "[*] Scanning for flags in: $output_dir"

# Search all text files for flag patterns
find "$output_dir" -type f \( -name "*.txt" -o -name "*.bin" -o -name "*.dat" \) | while read file; do
    echo "[*] Checking: $file"
    
    # Extract strings and search
    strings "$file" 2>/dev/null | grep -E "FLAG\{|flag\{|CTF\{|HTB\{" | while read line; do
        echo "[+] FOUND: $line"
        echo "$line" >> "${output_dir}/FOUND_FLAGS.txt"
    done
done

if [[ -f "${output_dir}/FOUND_FLAGS.txt" ]]; then
    echo ""
    echo "[+] Discovered flags:"
    cat "${output_dir}/FOUND_FLAGS.txt"
else
    echo "[-] No flags discovered"
fi
```

**Binary Data Analysis for Encoded Flags**

Extract and decode flags from binary analysis output:

```python
#!/usr/bin/env python3
"""
binary_flag_extractor.py - Extract flags from binary data
"""

import sys
import base64
import re
from binascii import hexlify, unhexlify

def extract_from_binary(binary_data: bytes) -> list:
    """Extract potential flags from binary data"""
    flags = []
    
    # Convert to hex string for pattern matching
    hex_str = hexlify(binary_data).decode('ascii')
    
    # Search for flag patterns in hex
    # FLAG{ = 464C4147{
    flag_hex_pattern = re.finditer(r'464c4147\{[0-9a-f]+\}', hex_str, re.IGNORECASE)
    for match in flag_hex_pattern:
        try:
            decoded = unhexlify(match.group()).decode('utf-8')
            flags.append(('hex_encoded', decoded))
        except:
            pass
    
    # Try to extract strings
    text_data = binary_data.decode('utf-8', errors='ignore')
    pattern_matches = re.finditer(r'(?:FLAG|flag|CTF)\{[^}]+\}', text_data)
    for match in pattern_matches:
        flags.append(('ascii', match.group()))
    
    # Try base64 encoded flags
    b64_pattern = re.finditer(r'(?:[A-Za-z0-9+/]{4})*(?:[A-Za-z0-9+/]{2}==|[A-Za-z0-9+/]{3}=)?', text_data)
    for match in b64_pattern:
        try:
            decoded = base64.b64decode(match.group()).decode('utf-8')
            if re.search(r'(?:FLAG|flag|CTF)\{[^}]+\}', decoded):
                flags.append(('base64', decoded))
        except:
            pass
    
    return flags

def main():
    if len(sys.argv) < 2:
        print(f"Usage: {sys.argv[0]} <binary_file>")
        sys.exit(1)
    
    with open(sys.argv[1], 'rb') as f:
        binary_data = f.read()
    
    flags = extract_from_binary(binary_data)
    
    if flags:
        print(f"[+] Extracted {len(flags)} potential flag(s):")
        for encoding, flag_text in flags:
            print(f"  [{encoding}] {flag_text}")
    else:
        print("[-] No flags extracted")

if __name__ == '__main__':
    main()
```

### Batch Processing

Batch processing enables efficient analysis of multiple files simultaneously, reducing total time and systematizing CTF challenge workflows.

**Parallel Processing Framework**

Maximize CPU utilization across multiple images:

```bash
#!/bin/bash
# batch_stego_analyzer.sh - Parallel batch analysis

input_dir="$1"
thread_count="${2:-4}"
output_dir="batch_analysis_$(date +%Y%m%d_%H%M%S)"

if [[ ! -d "$input_dir" ]]; then
    echo "[-] Directory not found: $input_dir"
    exit 1
fi

mkdir -p "$output_dir"

echo "[*] Starting batch analysis with $thread_count threads"
echo "[*] Input: $input_dir"
echo "[*] Output: $output_dir"

# Find all images and process in parallel
find "$input_dir" -type f \( -iname "*.jpg" -o -iname "*.png" -o -iname "*.bmp" -o -iname "*.gif" \) | \
    sort | \
    xargs -P "$thread_count" -I {} bash -c '
        target="{}"
        filename=$(basename "$target")
        analysis_dir="'"$output_dir"'/${filename%.*}"
        mkdir -p "$analysis_dir"
        
        echo "[*] Processing: $target"
        
        # Determine type and run appropriate tools
        file_type=$(file -b "$target" | cut -d" " -f1-2)
        
        case "$file_type" in
            *PNG*)
                zsteg "$target" -v > "$analysis_dir/zsteg.txt" 2>&1
                pngcheck -vvv "$target" > "$analysis_dir/pngcheck.txt" 2>&1
                ;;
            *JPEG*|*JPG*)
                stegdetect -v "$target" > "$analysis_dir/stegdetect.txt" 2>&1
                identify -verbose "$target" > "$analysis_dir/metadata.txt" 2>&1
                ;;
            *GIF*)
                convert "$target" +adjoin "$analysis_dir/frame_%d.png" 2>/dev/null
                ;;
        esac
        
        # Extract strings
        strings "$target" | grep -iE "flag|password|secret|ctf" > "$analysis_dir/strings.txt" 2>&1
        
        echo "[+] Complete: $filename"
    '

echo ""
echo "[+] Batch analysis complete"
echo "[*] Results directory: $output_dir"
echo "[*] Result summary:"
find "$output_dir" -type f -name "*.txt" | head -20
```

Execute:

```bash
chmod +x batch_stego_analyzer.sh
./batch_stego_analyzer.sh /path/to/images 8
```

**Distributed Processing with GNU Parallel**

For even larger datasets:

```bash
# Install GNU Parallel
sudo apt-get install parallel

# Process with distribution across threads
find images/ -type f -name "*.png" | \
    parallel -j 8 'zsteg {} -v > analysis/{/.}_zsteg.txt'

find images/ -type f -name "*.jpg" | \
    parallel -j 8 'stegdetect -d {} > analysis/{/.}_detect.txt'
```

**Database Aggregation from Batch Results**

Consolidate results into searchable database:

```python
#!/usr/bin/env python3
"""
batch_results_aggregator.py - Aggregate batch analysis into database
"""

import sqlite3
import json
import os
from pathlib import Path
from datetime import datetime

class ResultsAggregator:
    """Aggregate batch processing results"""
    
    def __init__(self, db_path: str = 'stego_results.db'):
        self.db_path = db_path
        self.conn = sqlite3.connect(db_path)
        self.cursor = self.conn.cursor()
        self._init_database()
    
    def _init_database(self):
        """Initialize database schema"""
        self.cursor.execute('''
            CREATE TABLE IF NOT EXISTS images (
                id INTEGER PRIMARY KEY,
                filename TEXT UNIQUE,
                file_type TEXT,
                hash TEXT,
                analysis_date TIMESTAMP,
                results_dir TEXT
            )
        ''')
        
        self.cursor.execute('''
            CREATE TABLE IF NOT EXISTS detections (
                id INTEGER PRIMARY KEY,
                image_id INTEGER,
                tool_name TEXT,
                detection_type TEXT,
                confidence REAL,
                data TEXT,
                FOREIGN KEY(image_id) REFERENCES images(id)
            )
        ''')
        
        self.cursor.execute('''
            CREATE TABLE IF NOT EXISTS extracted_strings (
                id INTEGER PRIMARY KEY,
                image_id INTEGER,
                string_text TEXT,
                source_file TEXT,
                FOREIGN KEY(image_id) REFERENCES images(id)
            )
        ''')
        
        self.conn.commit()
    
    def add_image_analysis(self, filename: str, file_type: str, 
                          file_hash: str, results_dir: str):
        """Add image analysis results"""
        try:
            self.cursor.execute('''
                INSERT INTO images (filename, file_type, hash, analysis_date, results_dir)
                VALUES (?, ?, ?, ?, ?)
            ''', (filename, file_type, file_hash, datetime.now(), results_dir))
            self.conn.commit()
            return self.cursor.lastrowid
        except sqlite3.IntegrityError:
            print(f"[-] Duplicate image: {filename}")
            return None
    
    def add_detection(self, image_id: int, tool: str, detection_type: str, 
                     confidence: float, data: str):
        """Add detection result"""
        self.cursor.execute('''
            INSERT INTO detections (image_id, tool_name, detection_type, confidence, data)
            VALUES (?, ?, ?, ?, ?)
        ''', (image_id, tool, detection_type, confidence, data))
        self.conn.commit()
    
    def add_string(self, image_id: int, string_text: str, source: str):
        """Add extracted string"""
        self.cursor.execute('''
            INSERT INTO extracted_strings (image_id, string_text, source_file)
            VALUES (?, ?, ?)
        ''', (image_id, string_text, source))
        self.conn.commit()
    
    def process_batch_results(self, batch_dir: str):
        """Process entire batch directory"""
        batch_path = Path(batch_dir)
        
        for img_dir in batch_path.iterdir():
            if not img_dir.is_dir():
                continue
            
            filename = img_dir.name
            print(f"[*] Processing: {filename}")
            
            # Get image file hash and type
            # (In real scenario, would compute from original file)
            file_type = "Unknown"
            file_hash = "unknown"
            
            image_id = self.add_image_analysis(filename, file_type, file_hash, str(img_dir))
            if not image_id:
                continue
            
            # Process zsteg results
            zsteg_file = img_dir / 'zsteg.txt'
            if zsteg_file.exists():
                content = zsteg_file.read_text()
                if 'b1,r,lsb' in content or 'detected' in content.lower():
                    self.add_detection(image_id, 'zsteg', 'LSB', 0.8, content[:500])
            
            # Process stegdetect results
            detect_file = img_dir / 'stegdetect.txt'
            if detect_file.exists():
                content = detect_file.read_text()
                if 'jsteg' in content or 'outguess' in content:
                    self.add_detection(image_id, 'stegdetect', 'DCT', 0.7, content[:500])
            
            # Process strings
            strings_file = img_dir / 'strings.txt'
            if strings_file.exists():
                for line in strings_file.read_text().split('\n'):
                    if line.strip():
                        self.add_string(image_id, line.strip(), 'strings.txt')
        
        print(f"[+] Batch processing complete")
    
    def query_detections(self) -> list:
        """Query all detections"""
        self.cursor.execute('''
            SELECT i.filename, d.tool_name, d.detection_type, d.confidence
            FROM detections d
            JOIN images i ON d.image_id = i.id
            ORDER BY d.confidence DESC
        ''')
        return self.cursor.fetchall()
    
    def query_flagged_strings(self) -> list:
        """Query strings containing potential flags"""
        self.cursor.execute('''
            SELECT i.filename, es.string_text
            FROM extracted_strings es
            JOIN images i ON es.image_id = i.id
            WHERE es.string_text LIKE '%FLAG%' OR es.string_text LIKE '%flag%'
        ''')
        return self.cursor.fetchall()
    
    def generate_report(self) -> str:
        """Generate summary report"""
        self.cursor.execute('SELECT COUNT(*) FROM images')
        img_count = self.cursor.fetchone()[0]
        
        self.cursor.execute('SELECT COUNT(*) FROM detections')
        detection_count = self.cursor.fetchone()[0]
        
        self.cursor.execute('SELECT COUNT(*) FROM extracted_strings')
        string_count = self.cursor.fetchone()[0]
        
        report = f"""
=== Batch Analysis Report ===
Images Analyzed: {img_count}
Detections Found: {detection_count}
Strings Extracted: {string_count}

=== High Confidence Detections ===
"""
        
        for filename, tool, det_type, confidence in self.query_detections():
            if confidence > 0.7:
                report += f"{filename}: {tool} ({det_type}) [{confidence:.2f}]\n"
        
        report += "\n=== Potential Flags ===\n"
        for filename, string_text in self.query_flagged_strings():
            report += f"{filename}: {string_text}\n"
        
        return report

def main():
    import sys
    
    if len(sys.argv) < 2:
        print(f"Usage: {sys.argv[0]} <batch_results_dir>")
        sys.exit(1)
    
    aggregator = ResultsAggregator()
    aggregator.process_batch_results(sys.argv[1])
    
    print(aggregator.generate_report())

if __name__ == '__main__':
    main()
```

Execute:

```bash
chmod +x batch_results_aggregator.py
python3 batch_results_aggregator.py batch_analysis_20250101_120000/
```

### Result Validation

Validate extraction results to confirm successful data recovery and eliminate false positives.

**Multi-Level Validation Framework**

Implement hierarchical validation:

```python
#!/usr/bin/env python3
"""
result_validator.py - Multi-level result validation
"""

import os
import hashlib
import magic
from pathlib import Path

class ResultValidator:
    """Validate extraction results"""
    
    @staticmethod
    def validate_file_integrity(filepath: str) -> dict:
        """Validate extracted file integrity"""
        if not os.path.exists(filepath):
            return {'valid': False, 'reason': 'File not found'}
        
        result = {'valid': True, 'checks': []}
        
        # Check file size
        file_size = os.path.getsize(filepath)
        result['checks'].append({
            'check': 'file_size',
            'size_bytes': file_size,
            'status': 'pass' if file_size > 0 else 'fail'
        })
        
        # Check file type
        try:
            mime = magic.from_file(filepath, mime=True)
            result['checks'].append({
                'check': 'mime_type',
                'mime': mime,
                'status': 'pass'
            })
        except:
            result['checks'].append({
                'check': 'mime_type',
                'status': 'fail'
            })
        
        # Calculate hash
        sha256_hash = hashlib.sha256()
        with open(filepath, 'rb') as f:
            for chunk in iter(lambda: f.read(4096), b''):
                sha256_hash.update(chunk)
        
        result['checks'].append({
            'check': 'sha256',
            'hash': sha256_hash.hexdigest(),
            'status': 'pass'
        })
        
        return result
    
    @staticmethod
    def validate_text_content(filepath: str) -> dict:
        """Validate text content quality"""
        result = {'valid': True, 'metrics': {}}
        
        try:
            with open(filepath, 'r', encoding='utf-8', errors='ignore') as f:
                content = f.read()
        except:
            return {'valid': False, 'reason': 'Cannot read file'}
        
        # Entropy analysis
        entropy = ResultValidator._calculate_entropy(content.encode())
        result['metrics']['entropy'] = entropy
        result['metrics']['entropy_status'] = \
            'high' if entropy > 4.5 else 'medium' if entropy > 3 else 'low'
        
        # Printable character ratio
        printable = sum(1 for c in content if c.isprintable() or c.isspace())
        printable_ratio = printable / len(content) if content else 0
        result['metrics']['printable_ratio'] = printable_ratio
        result['metrics']['printable_status'] = \
            'pass' if printable_ratio > 0.7 else 'fail'
        
        # Flag pattern detection
        import re
        flag_pattern = r'(?:FLAG|flag|CTF|HTB)\{[^}]+\}'
        if re.search(flag_pattern, content):
            result['metrics']['flag_detected'] = True
            result['valid'] = True
        
        return result
    
    @staticmethod
    def validate_binary_content(filepath: str) -> dict:
        """Validate binary data quality"""
        result = {'valid': True, 'metrics': {}}
        
        with open(filepath, 'rb') as f:
            data = f.read()
        
        # Check for known file signatures
        signatures = {
            b'\x89PNG': 'PNG',
            b'\xff\xd8\xff': 'JPEG',
            b'PK\x03\x04': 'ZIP',
            b'\x1f\x8b': 'GZIP',
            b'%PDF': 'PDF'
        }
        
        detected_type = 'Unknown'
        for sig, file_type in signatures.items():
            if data.startswith(sig):
                detected_type = file_type
                break
        
        result['metrics']['file_signature'] = detected_type
        result['metrics']['signature_valid'] = detected_type != 'Unknown'
        
        # Entropy check
        entropy = ResultValidator._calculate_entropy(data)
        result['metrics']['entropy'] = entropy
        
        return result
    
    @staticmethod
    def _calculate_entropy(data: bytes) -> float:
        """Calculate Shannon entropy"""
        if not data:
            return 0.0
        
        entropy = 0.0
        for i in range(256):
            freq = data.count(bytes([i])) / len(data)
            if freq > 0:
                import math
                entropy -= freq * math.log2(freq)
        
        return entropy
    
    @staticmethod
    def validate_extraction_consistency(original: str, extracted: str) -> dict:
        """Compare original vs extracted to validate method"""
        result = {'consistent': False, 'metrics': {}}
        
        # If checking against known original
        if not os.path.exists(original) or not os.path.exists(extracted):
            return {'consistent': False, 'reason': 'Files not found'}
        
        with open(original, 'rb') as f:
            orig_hash = hashlib.sha256(f.read()).hexdigest()
        
        with open(extracted, 'rb') as f:
            ext_hash = hashlib.sha256(f.read()).hexdigest()
        
        result['metrics']['original_hash'] = orig_hash
        result['metrics']['extracted_hash'] = ext_hash
        result['consistent'] = orig_hash == ext_hash
        
        return result

def validate_extraction_batch(results_dir: str) -> dict:
    """Validate all extractions in batch"""
    validator = ResultValidator()
    batch_validation = {}
    
    results_path = Path(results_dir)
    
    for extracted_file in results_path.rglob('*extracted*'):
        if extracted_file.is_file():
            print(f"[*] Validating: {extracted_file.name}")
            
            if extracted_file.suffix in ['.txt', '.csv']:
                validation = validator.validate_text_content(str(extracted_file))
            else:
                validation = validator.validate_binary_content(str(extracted_file))
            
            batch_validation[extracted_file.name] = validation
            
            # Print result
            if validation.get('valid', False):
                print(f"  [+] Valid")
            else:
                print(f"  [-] Invalid: {validation.get('reason', 'Unknown')}")
    
    return batch_validation

def main():
    import sys
    
    if len(sys.argv) < 2:
        print(f"Usage: {sys.argv[0]} <extracted_file_or_directory>")
        sys.exit(1)
    
    target = sys.argv[1]
    
    if os.path.isdir(target):
        print(f"[*] Validating batch: {target}")
        results = validate_extraction_batch(target)
        
        valid_count = sum(1 for v in results.values() if v.get('valid', False))
        print(f"\n[+] Validation complete: {valid_count}/{len(results)} valid")
    else:
        print(f"[*] Validating: {target}")
        validator = ResultValidator()
        
        # Determine if text or binary
        try:
            with open(target, 'r'):
                result = validator.validate_text_content(target)
        except:
            result = validator.validate_binary_content(target)
        
        # File integrity
        integrity = validator.validate_file_integrity(target)
        
        print(f"[+] Integrity: {integrity}")
        print(f"[+] Content: {result}")

if __name__ == '__main__':
    main()
```

**Automated Validation in Extraction Workflow**

Integrate validation into complete extraction chain:

```bash
#!/bin/bash
# extract_and_validate.sh - Extract with validation

source_image="$1"
output_file="$2"

if [[ ! -f "$source_image" ]]; then
    echo "[-] Source image not found: $source_image"
    exit 1
fi

echo "[*] Extracting from: $source_image"

# Determine file type and extract
file_type=$(file -b "$source_image" | cut -d' ' -f1)

case "$file_type" in
    PNG)
        echo "[*] PNG extraction..."
        zsteg "$source_image" -c rgb -b 1 -o "$output_file"
        ;;
    JPEG)
        echo "[*] JPEG extraction..."
        jsteg reveal "$source_image" "$output_file" || \
        stegdetect -d "$source_image" > "$output_file"
        ;;
    *)
        echo "[-] Unsupported file type: $file_type"
        exit 1
        ;;
esac

# Validate extraction
echo ""
echo "[*] Validating extraction..."

if [[ ! -f "$output_file" ]]; then
    echo "[-] Extraction failed"
    exit 1
fi

output_size=$(stat -c%s "$output_file")
echo "[+] Output file size: $output_size bytes"

if [[ $output_size -eq 0 ]]; then
    echo "[-] Output is empty"
    exit 1
fi

# Check for flags
echo "[*] Searching for flags..."
flag_count=$(strings "$output_file" | grep -icE "flag\{|ctf\{" || echo 0)

if [[ $flag_count -gt 0 ]]; then
    echo "[+] Found $flag_count potential flag(s):"
    strings "$output_file" | grep -iE "flag\{|ctf\{"
else
    echo "[*] No obvious flags found"
fi

# Entropy analysis
entropy=$(python3 -c "
import math
data = open('$output_file', 'rb').read()
entropy = 0.0
for i in range(256):
    freq = data.count(bytes([i])) / len(data)
    if freq > 0:
        entropy -= freq * math.log2(freq)
print(f'{entropy:.2f}')
")

echo "[*] Entropy: $entropy"

echo ""
echo "[+] Extraction and validation complete"
echo "[*] Output file: $output_file"
```

**Quality Scoring for Batch Results**

Rank results by quality for prioritization:

```python
#!/usr/bin/env python3
"""
result_quality_scorer.py - Score extraction quality
"""

import os
import math
from pathlib import Path

class ResultQualityScorer:
    """Score extraction quality for prioritization"""
    
    @staticmethod
    def calculate_entropy(data: bytes) -> float:
        """Calculate Shannon entropy (0-8)"""
        if not data:
            return 0.0
        entropy = 0.0
        for i in range(256):
            freq = data.count(bytes([i])) / len(data)
            if freq > 0:
                entropy -= freq * math.log2(freq)
        return entropy
    
    @staticmethod
    def score_extraction(filepath: str) -> float:
        """Score extraction quality (0-100)"""
        score = 0.0
        
        if not os.path.exists(filepath):
            return 0.0
        
        with open(filepath, 'rb') as f:
            data = f.read()
        
        file_size = len(data)
        
        # Size score (up to 20 points)
        if file_size > 100:
            score += 20
        elif file_size > 10:
            score += 10
        
        # Entropy score (up to 25 points)
        # Compressed/encrypted data has high entropy (~7-8)
        # Text data has lower entropy (~4-5)
        entropy = ResultQualityScorer.calculate_entropy(data)
        entropy_score = min(25, (entropy / 8) * 25)
        score += entropy_score
        
        # Text content score (up to 30 points)
        try:
            text_data = data.decode('utf-8')
            printable = sum(1 for c in text_data if c.isprintable() or c.isspace())
            text_ratio = printable / len(text_data) if text_data else 0
            
            if text_ratio > 0.9:
                score += 30
            elif text_ratio > 0.7:
                score += 20
            elif text_ratio > 0.5:
                score += 10
        except:
            pass
        
        # Flag detection (up to 25 points)
        import re
        try:
            if re.search(r'(?:FLAG|flag|CTF|HTB)\{[^}]+\}', text_data):
                score += 25
        except:
            pass
        
        # Structured data detection (file signatures)
        signatures = [b'\x89PNG', b'\xff\xd8\xff', b'PK\x03\x04', b'%PDF']
        for sig in signatures:
            if data.startswith(sig):
                score += 10
                break
        
        return min(100, score)
    
    @staticmethod
    def rank_batch_results(results_dir: str) -> list:
        """Rank all results in batch by quality"""
        scores = []
        
        for filepath in Path(results_dir).rglob('*'):
            if filepath.is_file() and filepath.stat().st_size > 0:
                score = ResultQualityScorer.score_extraction(str(filepath))
                scores.append((filepath.name, str(filepath), score))
        
        # Sort by score descending
        scores.sort(key=lambda x: x[2], reverse=True)
        return scores

def main():
    import sys
    
    if len(sys.argv) < 2:
        print(f"Usage: {sys.argv[0]} <results_directory>")
        sys.exit(1)
    
    scorer = ResultQualityScorer()
    ranked = scorer.rank_batch_results(sys.argv[1])
    
    print(f"[*] Ranked {len(ranked)} extraction(s) by quality:\n")
    
    for i, (name, path, score) in enumerate(ranked, 1):
        quality = "Excellent" if score > 80 else "Good" if score > 60 else "Fair" if score > 40 else "Poor"
        print(f"{i:3d}. [{score:6.1f}] {quality:10s} {name}")

if __name__ == '__main__':
    main()
```

Execute:

```bash
chmod +x result_quality_scorer.py
python3 result_quality_scorer.py batch_analysis_20250101_120000/
```

[Unverified] Quality scoring algorithms may not accurately represent extraction success in all scenarios; manual verification of high-scoring results remains necessary for comprehensive validation.

---

# Advanced Topics

## Machine Learning for Steganalysis

Machine learning approaches detect steganographic content by identifying statistical anomalies that manual analysis might miss. These techniques analyze feature sets extracted from media files to classify content as clean or containing hidden data.

**Key Concepts:**

- **Steganalysis** - The practice of detecting hidden information in media
- **Feature Extraction** - Converting media into numerical representations for analysis
- **Statistical Detection** - Identifying deviations from expected distributions
- **Supervised Learning** - Training models on known clean/stego samples
- **Unsupervised Learning** - Detecting anomalies without labeled training data

**Python-Based Steganalysis Framework:**

```bash
# Install dependencies
pip3 install numpy scipy scikit-learn pillow opencv-python

# Install aletheia (steganalysis toolkit)
pip3 install aletheia
```

**Aletheia - ML-Based Steganalysis Tool:**

```bash
# Basic steganalysis scan
aletheia spa image.png

# Deep learning detection
aletheia brute-force-dnn image.png

# Statistical attacks
aletheia ws image.png  # Weighted Stego attack
aletheia rs image.png  # RS analysis

# Compare images
aletheia similarity image1.png image2.png

# Batch analysis
for img in *.png; do
    echo "=== $img ==="
    aletheia spa "$img"
done
```

**Feature Extraction for Custom Analysis:**

```python
# feature_extraction.py
import numpy as np
from PIL import Image
from scipy import stats
import sys

def extract_lsb_features(image_path):
    """Extract statistical features from LSB plane"""
    img = Image.open(image_path)
    pixels = np.array(img)
    
    # Extract LSB from each channel
    if len(pixels.shape) == 3:
        lsb_r = pixels[:,:,0] & 1
        lsb_g = pixels[:,:,1] & 1
        lsb_b = pixels[:,:,2] & 1
    else:
        lsb_r = pixels & 1
        lsb_g = lsb_b = None
    
    features = {}
    
    # Statistical features
    features['lsb_mean_r'] = np.mean(lsb_r)
    features['lsb_std_r'] = np.std(lsb_r)
    features['lsb_entropy_r'] = stats.entropy(np.histogram(lsb_r.flatten(), bins=2)[0])
    
    # Spatial correlation
    features['correlation_h'] = np.corrcoef(lsb_r[:-1].flatten(), lsb_r[1:].flatten())[0,1]
    features['correlation_v'] = np.corrcoef(lsb_r[:,:-1].flatten(), lsb_r[:,1:].flatten())[0,1]
    
    # Chi-square test for randomness
    observed = np.histogram(lsb_r.flatten(), bins=2)[0]
    expected = np.array([lsb_r.size / 2, lsb_r.size / 2])
    chi2, p_value = stats.chisquare(observed, expected)
    features['chi2_statistic'] = chi2
    features['chi2_pvalue'] = p_value
    
    return features

if __name__ == "__main__":
    features = extract_lsb_features(sys.argv[1])
    for key, value in features.items():
        print(f"{key}: {value:.6f}")
```

**Usage:**

```bash
python3 feature_extraction.py image.png
```

**RS (Regular-Singular) Analysis:**

[Inference - detects LSB embedding by analyzing pixel group statistics]

```python
# rs_analysis.py
import numpy as np
from PIL import Image
import sys

def rs_analysis(image_path):
    """RS steganalysis for LSB detection"""
    img = Image.open(image_path).convert('L')
    pixels = np.array(img, dtype=np.int32)
    
    def flip_lsb(pixels):
        return pixels ^ 1
    
    def measure_smoothness(pixels):
        """Calculate variation function"""
        diff = np.abs(np.diff(pixels.astype(np.float64)))
        return np.sum(diff)
    
    # Divide into groups
    h, w = pixels.shape
    groups = []
    for i in range(0, h-1, 2):
        for j in range(0, w-1, 2):
            groups.append(pixels[i:i+2, j:j+2].flatten())
    
    R_M = 0  # Regular groups with mask
    S_M = 0  # Singular groups with mask
    
    for group in groups[:1000]:  # Sample
        original_smooth = measure_smoothness(group)
        flipped_smooth = measure_smoothness(flip_lsb(group))
        
        if flipped_smooth > original_smooth:
            R_M += 1
        elif flipped_smooth < original_smooth:
            S_M += 1
    
    total = R_M + S_M
    if total > 0:
        ratio = (R_M - S_M) / total
        print(f"RS Analysis Result: {ratio:.4f}")
        if abs(ratio) < 0.1:
            print("Likely contains LSB steganography")
        else:
            print("Likely clean")
    
    return ratio

if __name__ == "__main__":
    rs_analysis(sys.argv[1])
```

**Training Simple ML Classifier:**

```python
# train_classifier.py
from sklearn.ensemble import RandomForestClassifier
from sklearn.model_selection import train_test_split
from sklearn.metrics import classification_report
import numpy as np
import os
from PIL import Image

def extract_simple_features(image_path):
    """Extract basic statistical features"""
    img = Image.open(image_path)
    pixels = np.array(img)
    
    features = []
    
    # LSB statistics
    if len(pixels.shape) == 3:
        for channel in range(3):
            lsb = pixels[:,:,channel] & 1
            features.extend([
                np.mean(lsb),
                np.std(lsb),
                np.var(lsb)
            ])
    else:
        lsb = pixels & 1
        features.extend([np.mean(lsb), np.std(lsb), np.var(lsb)])
    
    return features

# Prepare training data
clean_images = []  # List of paths to clean images
stego_images = []  # List of paths to stego images

X = []
y = []

for img_path in clean_images:
    X.append(extract_simple_features(img_path))
    y.append(0)  # Clean

for img_path in stego_images:
    X.append(extract_simple_features(img_path))
    y.append(1)  # Stego

X = np.array(X)
y = np.array(y)

# Split and train
X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.3)

clf = RandomForestClassifier(n_estimators=100)
clf.fit(X_train, y_train)

# Evaluate
y_pred = clf.predict(X_test)
print(classification_report(y_test, y_pred))

# Save model
import joblib
joblib.dump(clf, 'stego_classifier.pkl')
```

**Using Pre-trained Deep Learning Models:**

```bash
# Using StegExpose (Java-based)
# [Unverified - requires separate installation]
java -jar StegExpose.jar image.png

# TensorFlow-based detection (example pseudocode)
python3 << 'EOF'
# [Inference - conceptual implementation]
import tensorflow as tf
import numpy as np
from PIL import Image

# Load pre-trained model (would need actual model file)
# model = tf.keras.models.load_model('stego_detector.h5')

def predict_stego(image_path):
    img = Image.open(image_path).resize((256, 256))
    img_array = np.array(img) / 255.0
    img_array = np.expand_dims(img_array, axis=0)
    
    # prediction = model.predict(img_array)
    # return prediction[0][0]
    pass
EOF
```

**Batch Steganalysis Pipeline:**

```bash
#!/bin/bash
# batch_steganalysis.sh

OUTPUT="steganalysis_results.csv"
echo "filename,lsb_mean,lsb_entropy,chi2_stat,verdict" > "$OUTPUT"

for img in *.png *.jpg; do
    echo "Analyzing: $img"
    
    # Extract features
    features=$(python3 feature_extraction.py "$img" 2>/dev/null)
    
    # Run RS analysis
    rs_result=$(python3 rs_analysis.py "$img" 2>/dev/null | grep "ratio")
    
    # Combine results
    echo "$img,$features,$rs_result" >> "$OUTPUT"
done

echo "Results saved to $OUTPUT"
```

## Blockchain Steganography

Blockchain systems provide multiple vectors for steganographic data hiding due to their public, immutable nature and transaction metadata fields.

**Key Concepts:**

- **Transaction Metadata** - Extra data fields in blockchain transactions
- **OP_RETURN** - Bitcoin opcode allowing arbitrary data storage
- **Smart Contract Storage** - Data embedded in contract bytecode or state
- **NFT Metadata** - Hidden data in token metadata or linked resources
- **Wallet Addresses** - Steganographic encoding in address generation

**Bitcoin OP_RETURN Analysis:**

```bash
# Install bitcoin-cli (Bitcoin Core)
# [Unverified - requires Bitcoin node]

# Search for OP_RETURN outputs
bitcoin-cli getrawtransaction TXID true | jq '.vout[] | select(.scriptPubKey.asm | startswith("OP_RETURN"))'

# Decode OP_RETURN data
bitcoin-cli getrawtransaction TXID true | \
    jq -r '.vout[] | select(.scriptPubKey.asm | startswith("OP_RETURN")) | .scriptPubKey.hex' | \
    cut -c7- | xxd -r -p

# Example: Extract text from OP_RETURN
decode_opreturn() {
    local txid="$1"
    bitcoin-cli getrawtransaction "$txid" true 2>/dev/null | \
        jq -r '.vout[] | select(.scriptPubKey.type == "nulldata") | .scriptPubKey.hex' | \
        sed 's/^6a..//' | xxd -r -p
}
```

**Ethereum Transaction Input Data:**

```bash
# Using etherscan API (requires API key)
TXHASH="0x..."
API_KEY="YOUR_API_KEY"

curl "https://api.etherscan.io/api?module=proxy&action=eth_getTransactionByHash&txhash=$TXHASH&apikey=$API_KEY" | \
    jq -r '.result.input' | cut -c3- | xxd -r -p

# Decode input data
decode_eth_input() {
    local input_data="$1"
    # Remove 0x prefix
    echo "${input_data:2}" | xxd -r -p
}
```

**Using web3.py for Ethereum Analysis:**

```python
# eth_steg_analysis.py
from web3 import Web3
import sys

# Connect to node
w3 = Web3(Web3.HTTPProvider('https://mainnet.infura.io/v3/YOUR_PROJECT_ID'))

def extract_tx_data(tx_hash):
    """Extract hidden data from transaction"""
    tx = w3.eth.get_transaction(tx_hash)
    
    # Input data
    input_data = tx['input']
    if input_data and input_data != '0x':
        print(f"Input data: {input_data}")
        try:
            decoded = bytes.fromhex(input_data[2:])
            print(f"Decoded: {decoded}")
        except:
            pass
    
    # Get transaction receipt for logs
    receipt = w3.eth.get_transaction_receipt(tx_hash)
    for log in receipt['logs']:
        print(f"Log data: {log['data']}")

def scan_contract_storage(contract_address):
    """Scan contract storage slots"""
    print(f"Scanning storage for {contract_address}")
    
    for i in range(10):  # Check first 10 slots
        storage = w3.eth.get_storage_at(contract_address, i)
        if storage != b'\x00' * 32:
            print(f"Slot {i}: {storage.hex()}")
            # Try to decode
            try:
                text = storage.rstrip(b'\x00').decode('utf-8')
                if text.isprintable():
                    print(f"  Decoded: {text}")
            except:
                pass

if __name__ == "__main__":
    if len(sys.argv) > 1:
        if sys.argv[1].startswith('0x') and len(sys.argv[1]) == 66:
            extract_tx_data(sys.argv[1])
        elif sys.argv[1].startswith('0x') and len(sys.argv[1]) == 42:
            scan_contract_storage(sys.argv[1])
```

**NFT Metadata Extraction:**

```bash
# Extract NFT metadata URI
TOKEN_ID=1234
CONTRACT="0x..."

# Using etherscan API
curl "https://api.etherscan.io/api?module=contract&action=getabi&address=$CONTRACT&apikey=$API_KEY"

# Download metadata
wget -O metadata.json "ipfs://QmHash"  # Requires IPFS gateway

# Check for hidden data in NFT image
wget -O nft_image.png "https://ipfs.io/ipfs/QmImageHash"
strings nft_image.png | grep -E 'flag|secret|hidden'
exiftool nft_image.png
```

**Bitcoin Address Steganography Detection:**

```python
# btc_address_analysis.py
import hashlib
import base58

def analyze_address(address):
    """Check for non-random patterns in Bitcoin address"""
    # Decode address
    decoded = base58.b58decode(address)
    
    # Analyze entropy
    entropy = len(set(decoded)) / len(decoded)
    print(f"Entropy: {entropy:.4f}")
    
    # Check for patterns
    hex_addr = decoded.hex()
    print(f"Hex: {hex_addr}")
    
    # Look for repeated sequences
    for length in [2, 3, 4]:
        for i in range(len(hex_addr) - length):
            pattern = hex_addr[i:i+length]
            if hex_addr.count(pattern) > 2:
                print(f"Repeated pattern ({length} chars): {pattern}")

if __name__ == "__main__":
    import sys
    analyze_address(sys.argv[1])
```

**Solana Transaction Memo Analysis:**

```bash
# Solana transactions can include memo instructions

# Using Solana CLI
solana transaction-history WALLET_ADDRESS --limit 100 | grep -i "memo"

# Extract memos from transactions
solana confirm TRANSACTION_SIGNATURE -v | grep -A 5 "Memo"
```

**Blockchain Explorers for Manual Analysis:**

```bash
# Bitcoin
# blockchain.com/explorer
# blockchair.com

# Ethereum
# etherscan.io

# Check transaction input data
curl -s "https://blockchair.com/bitcoin/transaction/TXID" | \
    jq '.data[].transaction.input'
```

## Biological Sequence Steganography

DNA sequences and protein structures can encode arbitrary data, used in synthetic biology and bioinformatics CTF challenges.

**Key Concepts:**

- **DNA Encoding** - Mapping binary data to nucleotide sequences (A, T, G, C)
- **Codon Usage** - Using redundant genetic code for steganography
- **Non-coding Regions** - Hiding data in introns or UTRs
- **Amino Acid Encoding** - Using protein sequences for data storage

**DNA Encoding Schemes:**

```python
# dna_steganography.py
import sys

# Standard encoding: A=00, T=01, G=10, C=11
DNA_MAP = {'A': '00', 'T': '01', 'G': '10', 'C': '11'}
DNA_MAP_REV = {v: k for k, v in DNA_MAP.items()}

def text_to_dna(text):
    """Encode text as DNA sequence"""
    binary = ''.join(format(ord(c), '08b') for c in text)
    dna = ''.join(DNA_MAP_REV[binary[i:i+2]] for i in range(0, len(binary), 2))
    return dna

def dna_to_text(dna):
    """Decode DNA sequence to text"""
    binary = ''.join(DNA_MAP[base] for base in dna.upper())
    chars = [chr(int(binary[i:i+8], 2)) for i in range(0, len(binary), 8)]
    return ''.join(chars)

if __name__ == "__main__":
    if len(sys.argv) > 2:
        if sys.argv[1] == '-e':
            print(text_to_dna(sys.argv[2]))
        elif sys.argv[1] == '-d':
            print(dna_to_text(sys.argv[2]))
```

**Usage:**

```bash
# Encode message
python3 dna_steganography.py -e "flag{dna_stego}"

# Decode sequence
python3 dna_steganography.py -d "ATGCATGC..."
```

**Alternative DNA Encoding (Three-Bit):**

```python
# dna_3bit.py
# Using 3 of 4 bases for each position allows ternary encoding

BASES = ['A', 'T', 'G', 'C']

def base3_to_dna(text):
    """Encode using base-3 representation"""
    result = []
    for char in text:
        val = ord(char)
        # Convert to base 3
        base3 = []
        temp = val
        while temp > 0:
            base3.append(temp % 3)
            temp //= 3
        base3 += [0] * (6 - len(base3))  # Pad to 6 digits
        
        # Map to DNA (0=A, 1=T, 2=G)
        dna = ''.join(['ATG'[d] for d in reversed(base3)])
        result.append(dna)
    
    return ''.join(result)

def dna_to_base3(dna):
    """Decode base-3 DNA sequence"""
    mapping = {'A': 0, 'T': 1, 'G': 2, 'C': 0}
    result = []
    
    for i in range(0, len(dna), 6):
        chunk = dna[i:i+6]
        if len(chunk) == 6:
            val = 0
            for base in chunk:
                val = val * 3 + mapping[base]
            if val < 256:
                result.append(chr(val))
    
    return ''.join(result)
```

**FASTA File Analysis:**

```bash
# FASTA format commonly used for sequences

# Extract sequence from FASTA
grep -v "^>" sequence.fasta | tr -d '\n' > sequence.txt

# Analyze sequence composition
cat sequence.txt | fold -w1 | sort | uniq -c

# Look for unusual patterns
python3 << 'EOF'
import sys
seq = open('sequence.txt').read().strip()

# Check for repeating patterns
for length in [3, 6, 9, 12]:
    for i in range(0, len(seq) - length, length):
        codon = seq[i:i+length]
        if seq.count(codon) > 5:
            print(f"Frequent pattern ({length}bp): {codon}")
EOF
```

**Codon Table Steganography:**

```python
# codon_stego.py
# Using redundant codons to encode additional data

CODON_TABLE = {
    'TTT': 'F', 'TTC': 'F', 'TTA': 'L', 'TTG': 'L',
    'TCT': 'S', 'TCC': 'S', 'TCA': 'S', 'TCG': 'S',
    # ... (standard genetic code)
}

# Redundant codons for same amino acid
REDUNDANT = {
    'F': ['TTT', 'TTC'],  # 0, 1
    'L': ['TTA', 'TTG', 'CTT', 'CTC', 'CTA', 'CTG'],  # 0-5
    'S': ['TCT', 'TCC', 'TCA', 'TCG', 'AGT', 'AGC'],  # 0-5
}

def encode_in_synonymous_codons(protein_seq, hidden_data):
    """Encode data using synonymous codon choices"""
    # [Inference - requires careful selection of redundant codons]
    binary_data = ''.join(format(ord(c), '08b') for c in hidden_data)
    dna_seq = []
    bit_idx = 0
    
    for aa in protein_seq:
        if aa in REDUNDANT and bit_idx < len(binary_data):
            # Use LSB to select codon variant
            bit = int(binary_data[bit_idx])
            codon = REDUNDANT[aa][bit % len(REDUNDANT[aa])]
            bit_idx += 1
        else:
            codon = REDUNDANT.get(aa, ['NNN'])[0]
        dna_seq.append(codon)
    
    return ''.join(dna_seq)
```

**Detecting Hidden Data in Biological Sequences:**

```python
# bio_steg_detect.py
import sys

def analyze_sequence(seq):
    """Detect potential steganography in DNA sequence"""
    
    # Check nucleotide distribution
    counts = {'A': 0, 'T': 0, 'G': 0, 'C': 0}
    for base in seq.upper():
        if base in counts:
            counts[base] += 1
    
    total = sum(counts.values())
    print("Nucleotide distribution:")
    for base, count in counts.items():
        print(f"  {base}: {count} ({count/total*100:.2f}%)")
    
    # Natural DNA has roughly equal distribution
    # Significant deviation may indicate encoding
    
    # Check for reading frames
    print("\nTrying DNA to text decoding:")
    try:
        DNA_MAP = {'A': '00', 'T': '01', 'G': '10', 'C': '11'}
        binary = ''.join(DNA_MAP.get(b, '00') for b in seq.upper())
        text = ''.join(chr(int(binary[i:i+8], 2)) for i in range(0, len(binary)-(len(binary)%8), 8))
        if text.isprintable():
            print(f"Decoded: {text[:100]}")
    except:
        pass

if __name__ == "__main__":
    with open(sys.argv[1]) as f:
        seq = ''.join(line.strip() for line in f if not line.startswith('>'))
    analyze_sequence(seq)
```

**Using BioPython for Analysis:**

```bash
# Install BioPython
pip3 install biopython
```

```python
# biopython_analysis.py
from Bio import SeqIO
from Bio.Seq import Seq
import sys

def analyze_fasta(filename):
    """Analyze FASTA file for hidden data"""
    for record in SeqIO.parse(filename, "fasta"):
        print(f"ID: {record.id}")
        print(f"Length: {len(record.seq)}")
        
        # Try translation in all frames
        for frame in range(3):
            subseq = record.seq[frame:]
            try:
                protein = subseq.translate(to_stop=False)
                if any(c in str(protein) for c in 'flag{CTF'):
                    print(f"Frame {frame}: {protein[:100]}")
            except:
                pass
        
        # Check for open reading frames (ORFs)
        # [Inference - ORFs may contain encoded messages]

if __name__ == "__main__":
    analyze_fasta(sys.argv[1])
```

**GenBank Format Analysis:**

```bash
# GenBank files contain annotations and metadata

# Extract sequence
grep -v "^LOCUS\|^DEFINITION\|^ACCESSION\|^ORIGIN\|^//\|^[0-9]" sequence.gb | tr -d ' \n'

# Check for suspicious annotations
grep -i "comment\|note" sequence.gb
```

## 3D Model Steganography

3D models provide unique steganographic vectors through vertex positions, texture coordinates, metadata, and embedded textures.

**Key Concepts:**

- **Vertex Manipulation** - Subtly moving vertices to encode data
- **Texture Maps** - Hiding data in model textures
- **Model Metadata** - Information in file headers/comments
- **Mesh Topology** - Encoding in connectivity patterns
- **UV Coordinates** - Using texture mapping coordinates

**Common 3D Formats:**

- **OBJ** - Plain text, easily inspectable
- **STL** - Binary or ASCII, used in 3D printing
- **FBX** - Autodesk format, binary
- **GLTF/GLB** - JSON-based, web-friendly
- **PLY** - Versatile, supports metadata

**OBJ File Analysis:**

```bash
# OBJ is plain text format
cat model.obj

# Extract vertices (v lines)
grep "^v " model.obj > vertices.txt

# Extract texture coordinates (vt lines)
grep "^vt " model.obj > texcoords.txt

# Extract normals (vn lines)
grep "^vn " model.obj > normals.txt

# Check for comments (may contain hidden data)
grep "^#" model.obj

# Look for unusual precision in coordinates
# Natural models typically have 4-6 decimal places
# LSB steganography may use more precision
grep "^v " model.obj | awk '{print $2}' | sed 's/.*\.\(.*\)/\1/' | awk '{print length}'
```

**Extracting Textures from 3D Models:**

```bash
# OBJ texture reference
grep "^mtllib" model.obj  # Material library file
cat referenced_material.mtl

# Extract texture filenames
grep "map_Kd" material.mtl  # Diffuse map
grep "map_Ks" material.mtl  # Specular map
grep "map_bump" material.mtl  # Bump map

# Analyze textures normally
strings texture.png
exiftool texture.png
zsteg texture.png
```

**STL File Analysis:**

```bash
# Check if ASCII or binary
file model.stl

# For ASCII STL
grep -i "solid" model.stl  # Header
grep "vertex" model.stl | head -10

# For binary STL
# Header: 80 bytes
# Triangle count: 4 bytes (little-endian)
# Each triangle: 50 bytes (12 floats + 2 byte attribute)

# Extract header (may contain hidden data)
head -c 80 model.stl
strings -n 8 model.stl

# Check attribute bytes (often unused, good for steganography)
xxd model.stl | grep -A 1 "triangle"
```

**Binary STL Parser:**

```python
# stl_parser.py
import struct
import sys

def parse_stl(filename):
    """Parse binary STL and check for hidden data"""
    with open(filename, 'rb') as f:
        # Read header (80 bytes)
        header = f.read(80)
        print(f"Header: {header}")
        try:
            print(f"Header (ASCII): {header.decode('ascii', errors='ignore')}")
        except:
            pass
        
        # Read triangle count
        tri_count = struct.unpack('<I', f.read(4))[0]
        print(f"Triangle count: {tri_count}")
        
        # Read triangles
        suspicious_attrs = []
        for i in range(tri_count):
            # Normal (3 floats)
            normal = struct.unpack('<fff', f.read(12))
            
            # Vertices (9 floats)
            v1 = struct.unpack('<fff', f.read(12))
            v2 = struct.unpack('<fff', f.read(12))
            v3 = struct.unpack('<fff', f.read(12))
            
            # Attribute byte count (usually 0)
            attr = struct.unpack('<H', f.read(2))[0]
            if attr != 0:
                suspicious_attrs.append((i, attr))
        
        if suspicious_attrs:
            print(f"\nTriangles with non-zero attributes: {len(suspicious_attrs)}")
            for idx, attr in suspicious_attrs[:10]:
                print(f"  Triangle {idx}: attribute={attr} (0x{attr:04x})")
            
            # Extract attribute bits
            attr_bits = ''.join(format(attr, '016b') for idx, attr in suspicious_attrs)
            print(f"\nAttribute bits: {attr_bits[:100]}...")
            
            # Try to decode as ASCII
            try:
                chars = [chr(int(attr_bits[i:i+8], 2)) for i in range(0, len(attr_bits)-(len(attr_bits)%8), 8)]
                decoded = ''.join(chars)
                if decoded.isprintable():
                    print(f"Decoded: {decoded}")
            except:
                pass

if __name__ == "__main__":
    parse_stl(sys.argv[1])
```

**GLTF/GLB Analysis:**

```bash
# GLTF is JSON-based
cat model.gltf | jq '.'

# Check for embedded data
cat model.gltf | jq '.buffers'

# Extract base64-encoded buffers
cat model.gltf | jq -r '.buffers[].uri' | grep "^data:" | cut -d',' -f2 | base64 -d > buffer.bin

# For GLB (binary GLTF)
# GLB structure: Header (12 bytes) + JSON chunk + Binary chunk

# Extract JSON from GLB
python3 << 'EOF'
import struct
import json
import sys

with open(sys.argv[1], 'rb') as f:
    # Header
    magic = f.read(4)  # Should be b'glTF'
    version = struct.unpack('<I', f.read(4))[0]
    length = struct.unpack('<I', f.read(4))[0]
    
    print(f"Magic: {magic}, Version: {version}, Length: {length}")
    
    # JSON chunk
    chunk0_len = struct.unpack('<I', f.read(4))[0]
    chunk0_type = f.read(4)  # Should be b'JSON'
    json_data = f.read(chunk0_len)
    
    print("\nJSON content:")
    print(json.dumps(json.loads(json_data), indent=2))
    
    # Binary chunk
    if f.tell() < length:
        chunk1_len = struct.unpack('<I', f.read(4))[0]
        chunk1_type = f.read(4)  # Should be b'BIN\x00'
        binary_data = f.read(chunk1_len)
        
        print(f"\nBinary chunk size: {chunk1_len} bytes")

    # Check for text in binary data
    try:
        text = binary_data.decode('utf-8', errors='ignore')
        if 'flag' in text.lower() or 'ctf' in text.lower():
            print("Suspicious text in binary data:")
            print(text[:500])
    except:
        pass
    
    # Save binary chunk
    with open('extracted_binary.bin', 'wb') as out:
        out.write(binary_data)
    print("Binary data saved to extracted_binary.bin")

EOF

# Usage: python3 script.py model.glb
````

**PLY File Analysis:**

```bash
# PLY format supports custom properties and comments

# Check header
head -20 model.ply

# Look for custom properties
grep "property" model.ply

# PLY can be ASCII or binary
grep "format ascii" model.ply && echo "ASCII format" || echo "Binary format"

# Extract comments
grep "comment" model.ply

# For ASCII PLY, extract vertex data
awk '/end_header/,0' model.ply | tail -n +2 | head -1000
````

**Vertex LSB Steganography Detection:**

```python
# vertex_lsb_detect.py
import sys
import re

def analyze_obj_vertices(filename):
    """Check for LSB steganography in vertex coordinates"""
    vertices = []
    
    with open(filename, 'r') as f:
        for line in f:
            if line.startswith('v '):
                parts = line.split()
                if len(parts) >= 4:
                    x, y, z = float(parts[1]), float(parts[2]), float(parts[3])
                    vertices.append((x, y, z))
    
    print(f"Total vertices: {len(vertices)}")
    
    # Check precision (LSB stego often uses high precision)
    precisions = []
    for v in vertices[:100]:
        for coord in v:
            str_coord = str(coord)
            if '.' in str_coord:
                decimal_places = len(str_coord.split('.')[1])
                precisions.append(decimal_places)
    
    if precisions:
        avg_precision = sum(precisions) / len(precisions)
        print(f"Average decimal precision: {avg_precision:.2f}")
        if avg_precision > 8:
            print("Unusually high precision - possible LSB steganography")
    
    # Extract LSBs from coordinates
    print("\nExtracting LSBs from last decimal place...")
    lsb_data = []
    for v in vertices:
        for coord in v:
            # Get last decimal digit
            str_coord = f"{coord:.10f}"
            last_digit = int(str_coord[-1])
            lsb_data.append(last_digit % 2)  # LSB of last digit
    
    # Try to decode as binary
    binary_str = ''.join(str(b) for b in lsb_data)
    try:
        chars = [chr(int(binary_str[i:i+8], 2)) for i in range(0, len(binary_str)-(len(binary_str)%8), 8)]
        decoded = ''.join(c for c in chars if c.isprintable())
        if len(decoded) > 10:
            print(f"Possible decoded text: {decoded[:200]}")
    except:
        pass

if __name__ == "__main__":
    analyze_obj_vertices(sys.argv[1])
```

**Mesh Topology Analysis:**

```python
# mesh_topology.py
import sys

def analyze_mesh_topology(filename):
    """Analyze face connectivity patterns"""
    faces = []
    
    with open(filename, 'r') as f:
        for line in f:
            if line.startswith('f '):
                parts = line.split()[1:]
                # Parse face indices (handle v/vt/vn format)
                indices = []
                for p in parts:
                    idx = int(p.split('/')[0])
                    indices.append(idx)
                faces.append(indices)
    
    print(f"Total faces: {len(faces)}")
    
    # Analyze face sizes
    face_sizes = [len(f) for f in faces]
    print(f"Face types: {set(face_sizes)}")
    
    # Look for unusual patterns in face indices
    # Some steganography encodes data in vertex reference order
    
    # Check for sequential vs. non-sequential indices
    sequential = 0
    non_sequential = 0
    for face in faces:
        if face == sorted(face):
            sequential += 1
        else:
            non_sequential += 1
    
    print(f"Sequential faces: {sequential}, Non-sequential: {non_sequential}")
    
    if non_sequential > sequential * 2:
        print("Unusual face ordering - possible encoding")

if __name__ == "__main__":
    analyze_mesh_topology(sys.argv[1])
```

**3D Model Viewer Tools:**

```bash
# MeshLab (GUI tool for 3D analysis)
meshlab model.obj

# Blender (scripting possible)
blender --background --python analysis_script.py -- model.obj

# Online viewers
# threejs.org/editor
# clara.io
```

**Extracting All Data from FBX:**

```bash
# FBX is binary, use FBX SDK or converter

# Convert FBX to OBJ (preserves geometry, loses some metadata)
# [Unverified - requires FBX converter installation]
fbx2obj model.fbx model.obj

# Extract with Blender Python
blender --background --python << 'EOF'
import bpy
import sys

# Load FBX
bpy.ops.import_scene.fbx(filepath='model.fbx')

# Export as OBJ (easier to analyze)
bpy.ops.export_scene.obj(filepath='converted.obj')

# Check for text objects or metadata
for obj in bpy.data.objects:
    print(f"Object: {obj.name}, Type: {obj.type}")
    if obj.type == 'FONT':
        print(f"  Text: {obj.data.body}")
EOF
```

## Executable File Steganography

Executable files offer numerous steganographic vectors including unused header fields, padding sections, resource data, and code caves.

**Key Concepts:**

- **Code Caves** - Unused spaces between sections filled with null bytes
- **Resource Section** - Icons, strings, version info that can hide data
- **Overlay Data** - Data appended after the executable
- **Relocations** - Unused relocation entries
- **Certificate Section** - PE files can have signatures with extra data

**PE (Windows) File Analysis:**

```bash
# Install pefile
pip3 install pefile

# Basic PE inspection
file executable.exe
strings executable.exe | grep -i "flag\|ctf"

# Check for overlay (data after PE structure)
python3 << 'EOF'
import pefile
import sys

pe = pefile.PE(sys.argv[1])

# Calculate where PE ends
pe_end = 0
for section in pe.sections:
    section_end = section.PointerToRawData + section.SizeOfRawData
    if section_end > pe_end:
        pe_end = section_end

# Check file size
import os
file_size = os.path.getsize(sys.argv[1])

if file_size > pe_end:
    overlay_size = file_size - pe_end
    print(f"Overlay detected: {overlay_size} bytes at offset {pe_end}")
    
    # Extract overlay
    with open(sys.argv[1], 'rb') as f:
        f.seek(pe_end)
        overlay = f.read()
    
    with open('overlay.bin', 'wb') as out:
        out.write(overlay)
    
    print("Overlay saved to overlay.bin")
    
    # Check overlay content
    print("\nOverlay preview:")
    print(overlay[:200])
    
    # Try to identify overlay type
    import subprocess
    result = subprocess.run(['file', '-'], input=overlay, capture_output=True)
    print(f"\nFile type: {result.stdout.decode()}")
else:
    print("No overlay detected")
EOF
# Usage: python3 script.py executable.exe
```

**Extracting PE Resources:**

```bash
# Using pefile to extract resources
python3 << 'EOF'
import pefile
import sys

pe = pefile.PE(sys.argv[1])

# Check for resources
if hasattr(pe, 'DIRECTORY_ENTRY_RESOURCE'):
    print("Resources found:")
    
    def explore_resource(entry, level=0):
        indent = "  " * level
        if hasattr(entry, 'data'):
            # Leaf node - actual resource data
            print(f"{indent}Data: offset={entry.data.struct.OffsetToData}, size={entry.data.struct.Size}")
            
            # Extract resource data
            data_rva = entry.data.struct.OffsetToData
            size = entry.data.struct.Size
            data = pe.get_data(data_rva, size)
            
            # Check for text
            try:
                text = data.decode('utf-8', errors='ignore')
                if 'flag' in text.lower() or 'ctf' in text.lower():
                    print(f"{indent}Suspicious text found: {text[:100]}")
            except:
                pass
            
            # Save large resources
            if size > 1000:
                filename = f"resource_{data_rva}_{size}.bin"
                with open(filename, 'wb') as f:
                    f.write(data)
                print(f"{indent}Saved to {filename}")
        
        if hasattr(entry, 'directory'):
            for subentry in entry.directory.entries:
                if hasattr(subentry, 'name'):
                    print(f"{indent}{subentry.name}")
                else:
                    print(f"{indent}ID: {subentry.id}")
                explore_resource(subentry, level + 1)
    
    explore_resource(pe.DIRECTORY_ENTRY_RESOURCE)
else:
    print("No resources found")
EOF
# Usage: python3 script.py executable.exe
```

**Code Cave Detection:**

```bash
# Find sections of null bytes (potential code caves)
python3 << 'EOF'
import sys

def find_code_caves(filename, min_size=100):
    """Find sequences of null bytes"""
    with open(filename, 'rb') as f:
        data = f.read()
    
    caves = []
    start = None
    current_size = 0
    
    for i, byte in enumerate(data):
        if byte == 0:
            if start is None:
                start = i
            current_size += 1
        else:
            if current_size >= min_size:
                caves.append((start, current_size))
            start = None
            current_size = 0
    
    print(f"Found {len(caves)} code caves >= {min_size} bytes:")
    for offset, size in caves[:20]:
        print(f"  Offset 0x{offset:08x}: {size} bytes")
        
        # Check what's after the cave
        with open(filename, 'rb') as f:
            f.seek(offset + size)
            after = f.read(50)
            if any(b != 0 for b in after):
                try:
                    print(f"    Followed by: {after.decode('utf-8', errors='ignore')[:30]}")
                except:
                    print(f"    Followed by: {after[:20].hex()}")

if __name__ == "__main__":
    find_code_caves(sys.argv[1])
EOF
# Usage: python3 script.py executable.exe
```

**Section Analysis:**

```bash
# Analyze PE sections for anomalies
python3 << 'EOF'
import pefile
import sys

pe = pefile.PE(sys.argv[1])

print("PE Sections:")
print(f"{'Name':<10} {'VirtAddr':<12} {'VirtSize':<12} {'RawSize':<12} {'Entropy':<8} {'Flags'}")
print("-" * 80)

for section in pe.sections:
    name = section.Name.decode('utf-8', errors='ignore').rstrip('\x00')
    vaddr = section.VirtualAddress
    vsize = section.Misc_VirtualSize
    rsize = section.SizeOfRawData
    entropy = section.get_entropy()
    flags = hex(section.Characteristics)
    
    print(f"{name:<10} {vaddr:<12x} {vsize:<12} {rsize:<12} {entropy:<8.2f} {flags}")
    
    # High entropy might indicate encryption/compression/data
    if entropy > 7.0:
        print(f"  ^ High entropy - possibly packed/encrypted")
    
    # Large difference between virtual and raw size
    if vsize > 0 and abs(vsize - rsize) > 1000:
        print(f"  ^ Size mismatch: virtual={vsize}, raw={rsize}")
    
    # Unusual section names
    if not name.startswith('.') and name not in ['TEXT', 'DATA', 'BSS']:
        print(f"  ^ Unusual section name")
EOF
# Usage: python3 script.py executable.exe
```

**ELF (Linux) File Analysis:**

```bash
# Check for overlays in ELF
readelf -S executable | tail -1
# Compare with file size

# Extract sections
objcopy --dump-section .text=text.bin executable
objcopy --dump-section .data=data.bin executable
objcopy --dump-section .rodata=rodata.bin executable

# Check for extra data after ELF structure
python3 << 'EOF'
from elftools.elf.elffile import ELFFile
import sys
import os

with open(sys.argv[1], 'rb') as f:
    elf = ELFFile(f)
    
    # Find end of ELF structure
    max_offset = 0
    for section in elf.iter_sections():
        section_end = section['sh_offset'] + section['sh_size']
        if section_end > max_offset:
            max_offset = section_end
    
    # Check file size
    file_size = os.path.getsize(sys.argv[1])
    
    if file_size > max_offset:
        overlay_size = file_size - max_offset
        print(f"Overlay detected: {overlay_size} bytes at offset {max_offset}")
        
        f.seek(max_offset)
        overlay = f.read()
        
        with open('elf_overlay.bin', 'wb') as out:
            out.write(overlay)
        
        print(f"Overlay saved to elf_overlay.bin")
        print(f"Preview: {overlay[:100]}")
    else:
        print("No overlay detected")
EOF
# Usage: python3 script.py executable
```

**Steganography in Icon Resources:**

```bash
# Extract icon from PE
wrestool -x -t 14 executable.exe > icon.ico

# Convert ICO to PNG
convert icon.ico icon.png

# Analyze as normal image
zsteg icon.png
exiftool icon.ico
strings icon.ico
```

**Digital Signature Analysis:**

```bash
# PE files can have PKCS#7 signatures with extra data

# Using osslsigncode
osslsigncode verify executable.exe

# Extract certificate
osslsigncode extract-signature -in executable.exe -out signature.der

# Analyze certificate
openssl pkcs7 -inform DER -in signature.der -print_certs -text

# Check for unsigned attributes (can hide data)
openssl asn1parse -inform DER -in signature.der | grep -A 5 "unsignedAttrs"
```

**Executable Metadata Extraction:**

```bash
# PE file metadata
exiftool executable.exe

# Check for unusual metadata
exiftool -a -G1 executable.exe | grep -i "comment\|description\|copyright"

# Extract version information
python3 << 'EOF'
import pefile
import sys

pe = pefile.PE(sys.argv[1])

if hasattr(pe, 'VS_VERSIONINFO'):
    print("Version Information:")
    for entry in pe.FileInfo:
        if hasattr(entry, 'StringTable'):
            for st in entry.StringTable:
                for key, value in st.entries.items():
                    print(f"  {key.decode()}: {value.decode()}")
EOF
# Usage: python3 script.py executable.exe
```

**Packed Executable Detection:**

```bash
# Detect common packers
# [Unverified - requires DIE installation]
diec executable.exe  # Detect It Easy

# Using entropy analysis
python3 << 'EOF'
import math
from collections import Counter
import sys

def calculate_entropy(data):
    if not data:
        return 0
    
    counter = Counter(data)
    entropy = 0
    length = len(data)
    
    for count in counter.values():
        probability = count / length
        entropy -= probability * math.log2(probability)
    
    return entropy

with open(sys.argv[1], 'rb') as f:
    data = f.read()

entropy = calculate_entropy(data)
print(f"File entropy: {entropy:.4f}")

if entropy > 7.5:
    print("High entropy - likely packed/encrypted")
elif entropy < 5.0:
    print("Low entropy - likely not packed")
else:
    print("Moderate entropy")
EOF
# Usage: python3 script.py executable.exe
```

## Cloud Storage Metadata

Cloud storage platforms provide metadata and versioning features that can conceal steganographic data.

**Key Concepts:**

- **Object Metadata** - Custom key-value pairs attached to files
- **Version History** - Previous versions may contain hidden data
- **Access Logs** - Timing patterns can encode information
- **Multipart Upload Tags** - Metadata in chunked uploads
- **Pre-signed URL Parameters** - Data in URL query strings

**AWS S3 Metadata Analysis:**

```bash
# Install AWS CLI
sudo apt install awscli
aws configure

# List objects with metadata
aws s3api list-objects-v2 --bucket BUCKET_NAME

# Get object metadata
aws s3api head-object --bucket BUCKET_NAME --key file.jpg

# Extract custom metadata (x-amz-meta-*)
aws s3api head-object --bucket BUCKET_NAME --key file.jpg | \
    jq '.Metadata'

# Download object with metadata
aws s3 cp s3://BUCKET_NAME/file.jpg file.jpg --metadata-directive COPY

# List object versions
aws s3api list-object-versions --bucket BUCKET_NAME --prefix file.jpg

# Download specific version
aws s3api get-object --bucket BUCKET_NAME --key file.jpg --version-id VERSION_ID output.jpg
```

**S3 Metadata Extraction Script:**

```python
# s3_metadata_extract.py
import boto3
import sys

s3 = boto3.client('s3')

def extract_all_metadata(bucket, key):
    """Extract all metadata from S3 object"""
    
    # Get object metadata
    response = s3.head_object(Bucket=bucket, Key=key)
    
    print(f"=== Metadata for s3://{bucket}/{key} ===")
    print(f"Content-Type: {response.get('ContentType')}")
    print(f"Content-Length: {response.get('ContentLength')}")
    print(f"ETag: {response.get('ETag')}")
    print(f"Last-Modified: {response.get('LastModified')}")
    
    # Custom metadata
    if 'Metadata' in response and response['Metadata']:
        print("\nCustom Metadata:")
        for key, value in response['Metadata'].items():
            print(f"  {key}: {value}")
            
            # Try to decode if Base64
            try:
                import base64
                decoded = base64.b64decode(value).decode('utf-8')
                print(f"    Decoded: {decoded}")
            except:
                pass
    
    # Check for versions
    versions = s3.list_object_versions(Bucket=bucket, Prefix=key)
    
    if 'Versions' in versions and len(versions['Versions']) > 1:
        print(f"\nMultiple versions found: {len(versions['Versions'])}")
        for v in versions['Versions']:
            print(f"  Version {v['VersionId']}: {v['LastModified']}")

if __name__ == "__main__":
    if len(sys.argv) >= 3:
        extract_all_metadata(sys.argv[1], sys.argv[2])
    else:
        print("Usage: python3 s3_metadata_extract.py BUCKET KEY")
```

**Google Cloud Storage Metadata:**

```bash
# Install gsutil
curl https://sdk.cloud.google.com | bash

# List objects with metadata
gsutil ls -L gs://BUCKET_NAME/file.jpg

# Get custom metadata
gsutil stat gs://BUCKET_NAME/file.jpg

# Extract metadata programmatically
gsutil ls -L gs://BUCKET_NAME/** | grep -E "metadata|Meta-"

# Download with metadata preservation
gsutil cp -P gs://BUCKET_NAME/file.jpg ./
```

**Azure Blob Storage Metadata:**

```bash
# Install Azure CLI
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash

# Login
az login

# Get blob metadata
az storage blob metadata show \
    --account-name ACCOUNT_NAME \
    --container-name CONTAINER_NAME \
    --name file.jpg

# List all blobs with metadata
az storage blob list \
    --account-name ACCOUNT_NAME \
    --container-name CONTAINER_NAME \
    --output table
```

**Dropbox Metadata Extraction:**

```python
# dropbox_metadata.py
import dropbox
import sys

# Requires Dropbox API token
dbx = dropbox.Dropbox('ACCESS_TOKEN')

def get_file_metadata(path):
    """Extract Dropbox file metadata"""
    try:
        metadata = dbx.files_get_metadata(path)
        
        print(f"Name: {metadata.name}")
        print(f"Path: {metadata.path_display}")
        print(f"Size: {metadata.size}")
        print(f"Modified: {metadata.client_modified}")
        print(f"Rev: {metadata.rev}")
        
        # Get revisions
        revisions = dbx.files_list_revisions(path)
        if len(revisions.entries) > 1:
            print(f"\nRevisions: {len(revisions.entries)}")
            for rev in revisions.entries:
                print(f"  {rev.rev}: {rev.client_modified}")
        
    except dropbox.exceptions.ApiError as e:
        print(f"Error: {e}")

if __name__ == "__main__":
    get_file_metadata(sys.argv[1])
```

**OneDrive/SharePoint Metadata:**

```bash
# Using Microsoft Graph API
ACCESS_TOKEN="YOUR_TOKEN"

# Get file metadata
curl -H "Authorization: Bearer $ACCESS_TOKEN" \
    "https://graph.microsoft.com/v1.0/me/drive/items/ITEM_ID"

# Get file versions
curl -H "Authorization: Bearer $ACCESS_TOKEN" \
    "https://graph.microsoft.com/v1.0/me/drive/items/ITEM_ID/versions"

# Extract custom properties
curl -H "Authorization: Bearer $ACCESS_TOKEN" \
    "https://graph.microsoft.com/v1.0/me/drive/items/ITEM_ID" | \
    jq '.listItem.fields'
```

**Generic Cloud Metadata Harvester:**

```bash
#!/bin/bash
# cloud_metadata_harvest.sh

URL="$1"

echo "=== Analyzing URL: $URL ==="

# HTTP headers
echo -e "\n[*] HTTP Headers:"
curl -sI "$URL" | grep -iE "x-amz|x-goog|x-ms|etag|content-type"

# Download file
FILENAME=$(basename "$URL" | cut -d'?' -f1)
curl -sL "$URL" -o "$FILENAME"

echo -e "\n[*] File Analysis:"
file "$FILENAME"
exiftool "$FILENAME" | head -20

# Check for cloud-specific metadata in file
strings "$FILENAME" | grep -iE "amazon|google|azure|dropbox|metadata"

# Check URL parameters
echo -e "\n[*] URL Parameters:"
echo "$URL" | grep -oE '\?.*' | tr '&' '\n'
```

**Timing-Based Steganography Detection:**

```python
# timing_analysis.py
# [Inference - analyzes access patterns for encoded data]
import sys
from datetime import datetime

def analyze_timestamps(log_file):
    """Look for patterns in access timestamps"""
    timestamps = []
    
    with open(log_file) as f:
        for line in f:
            # Parse timestamp (format varies by platform)
            # Example: 2025-10-12T15:30:45Z
            try:
                ts_str = line.split()[0]
                ts = datetime.fromisoformat(ts_str.replace('Z', '+00:00'))
                timestamps.append(ts)
            except:
                pass
    
    if len(timestamps) < 2:
        return
    
    # Calculate intervals
    intervals = []
    for i in range(1, len(timestamps)):
        delta = (timestamps[i] - timestamps[i-1]).total_seconds()
        intervals.append(int(delta))
    
    print(f"Access intervals (seconds): {intervals[:20]}")
    
    # Look for patterns (e.g., binary encoding in intervals)
    # Intervals < threshold = 0, >= threshold = 1
    threshold = 60
    binary = ''.join('1' if i >= threshold else '0' for i in intervals)
    print(f"Binary pattern: {binary[:100]}")
    
    # Try to decode
    try:
        chars = [chr(int(binary[i:i+8], 2)) for i in range(0, len(binary)-(len(binary)%8), 8)]
        decoded = ''.join(c for c in chars if c.isprintable())
        if len(decoded) > 5:
            print(f"Decoded: {decoded}")
    except:
        pass

if __name__ == "__main__":
    analyze_timestamps(sys.argv[1])
```

---

**Important Related Topics:**

- **Container Image Steganography** (Docker layer manipulation)
- **Git Repository Steganography** (commit messages, refs, orphaned commits)
- **Database Steganography** (hidden columns, triggers, stored procedures)
- **IoT Device Steganography** (firmware metadata, sensor data encoding)

---

# Practical Methodology

## Initial File Assessment

### First Contact with Unknown Files

**Universal file identification:**

```bash
# Basic file type detection
file suspicious_file
file -b suspicious_file  # Brief output
file -i suspicious_file  # MIME type

# Deep file analysis
file -z suspicious_file  # Look inside compressed files
file --extension suspicious_file  # Suggest file extension

# Multiple files at once
file *
find . -type f -exec file {} \;

# Check for polyglot files (multiple valid formats)
file -k suspicious_file  # Keep going after first match
```

**Calculate file hashes:**

```bash
# Generate multiple hashes
md5sum file.bin
sha1sum file.bin
sha256sum file.bin

# All at once
md5sum file.bin && sha1sum file.bin && sha256sum file.bin

# Check against known good/bad hashes
echo "expected_hash  file.bin" | sha256sum -c

# Hash directory of files
find . -type f -exec sha256sum {} \; > hashes.txt
```

**Binary inspection:**

```bash
# Hex dump (first 512 bytes)
xxd file.bin | head -n 32

# Show only printable strings
strings file.bin
strings -n 8 file.bin  # Minimum 8 characters
strings -a file.bin  # Scan entire file
strings -e l file.bin  # Little-endian 16-bit
strings -e b file.bin  # Big-endian 16-bit

# With offsets
strings -t x file.bin  # Hex offsets
strings -t d file.bin  # Decimal offsets

# Binary comparison
cmp file1.bin file2.bin
diff <(xxd file1.bin) <(xxd file2.bin)
```

**File size analysis:**

```bash
# Detailed size information
ls -lh file.bin
stat file.bin
du -h file.bin

# Check for unusual sizes
# Image: size doesn't match resolution × channels × bit_depth
# Audio: size doesn't match duration × sample_rate × bit_depth
# Archive: compressed size unusually large
```

### Comprehensive Initial Triage Script

```python
#!/usr/bin/env python3
import os
import subprocess
import hashlib
import magic
import binascii

def initial_assessment(filename):
    """
    Comprehensive first-pass analysis of unknown file
    """
    print("="*70)
    print(f"INITIAL ASSESSMENT: {filename}")
    print("="*70)
    
    if not os.path.exists(filename):
        print(f"[!] File not found: {filename}")
        return
    
    # 1. Basic Properties
    print("\n[1] BASIC PROPERTIES")
    print("-"*70)
    
    file_stats = os.stat(filename)
    print(f"Size: {file_stats.st_size} bytes ({file_stats.st_size/1024:.2f} KB)")
    print(f"Permissions: {oct(file_stats.st_mode)[-3:]}")
    print(f"Modified: {subprocess.run(['date', '-r', filename], capture_output=True, text=True).stdout.strip()}")
    
    # 2. File Type Detection
    print("\n[2] FILE TYPE DETECTION")
    print("-"*70)
    
    # Using file command
    file_type = subprocess.run(['file', '-b', filename], capture_output=True, text=True).stdout.strip()
    print(f"file command: {file_type}")
    
    # MIME type
    mime_type = subprocess.run(['file', '-b', '--mime-type', filename], capture_output=True, text=True).stdout.strip()
    print(f"MIME type: {mime_type}")
    
    # Python-magic
    try:
        mime = magic.Magic(mime=True)
        magic_mime = mime.from_file(filename)
        print(f"python-magic: {magic_mime}")
    except:
        pass
    
    # 3. Hash Values
    print("\n[3] HASH VALUES")
    print("-"*70)
    
    with open(filename, 'rb') as f:
        content = f.read()
        
        md5 = hashlib.md5(content).hexdigest()
        sha1 = hashlib.sha1(content).hexdigest()
        sha256 = hashlib.sha256(content).hexdigest()
        
        print(f"MD5:    {md5}")
        print(f"SHA1:   {sha1}")
        print(f"SHA256: {sha256}")
    
    # 4. File Signature Analysis
    print("\n[4] FILE SIGNATURE")
    print("-"*70)
    
    with open(filename, 'rb') as f:
        header = f.read(16)
        hex_header = binascii.hexlify(header).decode()
        
        print(f"First 16 bytes (hex): {hex_header}")
        print(f"First 16 bytes (raw): {header}")
        
        # Check common signatures
        signatures = {
            b'\x89PNG\r\n\x1a\n': 'PNG image',
            b'\xFF\xD8\xFF': 'JPEG image',
            b'GIF89a': 'GIF image (89a)',
            b'GIF87a': 'GIF image (87a)',
            b'PK\x03\x04': 'ZIP archive',
            b'PK\x05\x06': 'ZIP archive (empty)',
            b'Rar!\x1a\x07': 'RAR archive',
            b'\x1f\x8b': 'GZIP compressed',
            b'BM': 'BMP image',
            b'%PDF': 'PDF document',
            b'\x7fELF': 'ELF executable',
            b'MZ': 'DOS/Windows executable',
            b'RIFF': 'RIFF container (AVI/WAV)',
            b'\x00\x00\x00\x18ftypmp4': 'MP4 video',
            b'\x1a\x45\xdf\xa3': 'Matroska/MKV video',
            b'fLaC': 'FLAC audio',
            b'ID3': 'MP3 audio (with ID3)',
        }
        
        detected = False
        for sig, desc in signatures.items():
            if header.startswith(sig):
                print(f"[!] Recognized signature: {desc}")
                detected = True
                break
        
        if not detected:
            print("[?] Unknown or non-standard signature")
    
    # 5. Entropy Analysis
    print("\n[5] ENTROPY ANALYSIS")
    print("-"*70)
    
    entropy = calculate_entropy(content)
    print(f"Shannon Entropy: {entropy:.4f} bits/byte")
    
    if entropy > 7.9:
        print("[!] Very high entropy - likely encrypted or compressed")
    elif entropy > 7.5:
        print("[!] High entropy - possibly compressed or encoded")
    elif entropy < 4.0:
        print("[!] Low entropy - highly structured or repetitive data")
    else:
        print("[*] Normal entropy range")
    
    # 6. Strings Preview
    print("\n[6] STRINGS PREVIEW (first 20)")
    print("-"*70)
    
    strings_output = subprocess.run(['strings', '-n', '6', filename], 
                                   capture_output=True, text=True).stdout
    strings_list = strings_output.split('\n')[:20]
    
    for s in strings_list:
        if s:
            print(f"  {s[:70]}")
    
    print(f"\nTotal strings (6+ chars): {len([s for s in strings_output.split('\n') if s])}")
    
    # 7. Embedded File Detection
    print("\n[7] EMBEDDED FILE DETECTION")
    print("-"*70)
    
    # Quick binwalk check
    binwalk_output = subprocess.run(['binwalk', filename], 
                                   capture_output=True, text=True).stdout
    
    embedded_count = len([line for line in binwalk_output.split('\n') if line.strip() and not line.startswith('DECIMAL')])
    
    if embedded_count > 1:
        print(f"[!] binwalk found {embedded_count} embedded files/signatures")
        print(binwalk_output)
    else:
        print("[*] No obvious embedded files detected")
    
    # 8. Initial Recommendations
    print("\n[8] RECOMMENDED NEXT STEPS")
    print("-"*70)
    
    recommendations = []
    
    if 'image' in file_type.lower() or 'image' in mime_type.lower():
        recommendations.append("- Image analysis: exiftool, zsteg, steghide, stegsolve")
        recommendations.append("- Check EXIF metadata: exiftool -a file")
        recommendations.append("- LSB analysis: zsteg -a file")
    
    if 'pdf' in file_type.lower():
        recommendations.append("- PDF analysis: pdfinfo, pdfimages, pdf-parser")
        recommendations.append("- Check for JavaScript: pdf-parser -a javascript")
    
    if 'zip' in file_type.lower() or 'archive' in file_type.lower():
        recommendations.append("- Extract and analyze: unzip -l, 7z l")
        recommendations.append("- Check for password protection")
        recommendations.append("- Look for hidden files: zipinfo -v")
    
    if 'audio' in file_type.lower():
        recommendations.append("- Audio analysis: sonic-visualizer, audacity")
        recommendations.append("- Spectrogram analysis for hidden images")
        recommendations.append("- Check LSB: steghide, deepsound")
    
    if 'video' in file_type.lower():
        recommendations.append("- Video analysis: ffmpeg, mediainfo, exiftool")
        recommendations.append("- Extract frames: ffmpeg -i file frames/frame_%04d.png")
        recommendations.append("- Check metadata: exiftool -a file")
    
    if 'text' in file_type.lower() or 'ascii' in file_type.lower():
        recommendations.append("- Text stego: check for zero-width chars, whitespace encoding")
        recommendations.append("- Unicode analysis: look for homoglyphs, format characters")
    
    if entropy > 7.5:
        recommendations.append("- High entropy suggests encryption/compression")
        recommendations.append("- Try: file carving, known plaintext attack")
    
    if embedded_count > 1:
        recommendations.append("- Extract embedded files: binwalk -e file")
        recommendations.append("- Manual extraction using offsets")
    
    for rec in recommendations:
        print(rec)
    
    if not recommendations:
        print("- Try generic tools: strings, binwalk, hexdump")
        print("- Manual hex analysis for patterns")
        print("- Check for encoding: base64, hex, ROT13")
    
    print("\n" + "="*70)
    print("ASSESSMENT COMPLETE")
    print("="*70)

def calculate_entropy(data):
    """Calculate Shannon entropy of data"""
    import math
    from collections import Counter
    
    if not data:
        return 0
    
    counter = Counter(data)
    length = len(data)
    
    entropy = 0
    for count in counter.values():
        p = count / length
        entropy -= p * math.log2(p)
    
    return entropy

# Usage
if __name__ == "__main__":
    import sys
    
    if len(sys.argv) < 2:
        print("Usage: python3 assess.py <filename>")
        sys.exit(1)
    
    initial_assessment(sys.argv[1])
```

### Quick Triage Checklist

```bash
#!/bin/bash
# quick_triage.sh - Fast initial assessment

FILE="$1"

if [ -z "$FILE" ]; then
    echo "Usage: $0 <filename>"
    exit 1
fi

echo "=== QUICK TRIAGE: $FILE ==="
echo

echo "[*] File type:"
file -b "$FILE"
echo

echo "[*] Size:"
ls -lh "$FILE" | awk '{print $5}'
echo

echo "[*] MD5:"
md5sum "$FILE" | awk '{print $1}'
echo

echo "[*] First 32 bytes (hex):"
xxd -l 32 "$FILE"
echo

echo "[*] Entropy:"
ent "$FILE" | grep Entropy
echo

echo "[*] Strings sample (first 10):"
strings -n 8 "$FILE" | head -10
echo

echo "[*] Binwalk quick scan:"
binwalk "$FILE" | head -20
echo

echo "=== END TRIAGE ==="
```

---

## Tool Selection Strategy

### Tool Categories and Selection Matrix

**Category-based tool selection:**

```python
TOOL_MATRIX = {
    'image': {
        'metadata': ['exiftool', 'identify', 'pngcheck'],
        'lsb': ['zsteg', 'stegsolve', 'steghide'],
        'visual': ['stegsolve', 'gimp', 'imagemagick'],
        'analysis': ['binwalk', 'foremost', 'strings'],
        'specialized': {
            'png': ['pngcheck', 'tweakpng', 'zsteg'],
            'jpg': ['jsteg', 'outguess', 'steghide', 'stegseek'],
            'gif': ['gifsicle', 'identify'],
            'bmp': ['steghide', 'custom_scripts']
        }
    },
    'audio': {
        'metadata': ['exiftool', 'mediainfo', 'ffprobe'],
        'analysis': ['sonic-visualiser', 'audacity', 'spek'],
        'lsb': ['steghide', 'deepsound', 'hideme'],
        'spectrogram': ['sox', 'audacity', 'spek']
    },
    'video': {
        'metadata': ['exiftool', 'mediainfo', 'ffprobe'],
        'extraction': ['ffmpeg', 'mkvtoolnix', 'mp4box'],
        'frame_analysis': ['opencv', 'ffmpeg', 'imagemagick'],
        'container': ['mp4box', 'mkvinfo', 'atomicparsley']
    },
    'document': {
        'pdf': ['pdfinfo', 'pdfimages', 'pdf-parser', 'qpdf'],
        'office': ['olevba', 'oletools', 'officeparser', 'unzip'],
        'text': ['grep', 'sed', 'awk', 'custom_scripts']
    },
    'archive': {
        'extraction': ['7z', 'unzip', 'tar', 'unrar'],
        'analysis': ['zipinfo', '7z l', 'tar -tvf'],
        'password': ['fcrackzip', 'john', 'hashcat']
    },
    'network': {
        'pcap': ['wireshark', 'tshark', 'tcpdump', 'scapy'],
        'analysis': ['networkminer', 'tcpflow', 'ngrep']
    },
    'generic': {
        'hex': ['xxd', 'hexdump', 'hexedit', 'ghex'],
        'strings': ['strings', 'rabin2', 'floss'],
        'carving': ['binwalk', 'foremost', 'scalpel', 'photorec'],
        'encoding': ['base64', 'basenc', 'cyberchef']
    }
}
```

**Tool selection decision tree:**

```python
def select_tools(file_path):
    """
    Intelligently select tools based on file characteristics
    """
    import subprocess
    import os
    
    # Detect file type
    file_output = subprocess.run(['file', '-b', file_path], 
                                capture_output=True, text=True).stdout.lower()
    
    mime_type = subprocess.run(['file', '-b', '--mime-type', file_path],
                              capture_output=True, text=True).stdout.strip()
    
    selected_tools = []
    
    # Image files
    if 'image' in file_output or mime_type.startswith('image/'):
        selected_tools.extend(TOOL_MATRIX['image']['metadata'])
        selected_tools.extend(TOOL_MATRIX['image']['lsb'])
        
        # Specific image types
        if 'png' in file_output:
            selected_tools.extend(TOOL_MATRIX['image']['specialized']['png'])
        elif 'jpeg' in file_output or 'jpg' in file_output:
            selected_tools.extend(TOOL_MATRIX['image']['specialized']['jpg'])
    
    # Audio files
    elif 'audio' in file_output or mime_type.startswith('audio/'):
        selected_tools.extend(TOOL_MATRIX['audio']['metadata'])
        selected_tools.extend(TOOL_MATRIX['audio']['analysis'])
        selected_tools.append('sox')  # For spectrogram
    
    # Video files
    elif 'video' in file_output or mime_type.startswith('video/'):
        selected_tools.extend(TOOL_MATRIX['video']['metadata'])
        selected_tools.extend(TOOL_MATRIX['video']['extraction'])
    
    # PDF
    elif 'pdf' in file_output:
        selected_tools.extend(TOOL_MATRIX['document']['pdf'])
    
    # Archives
    elif 'zip' in file_output or 'archive' in file_output or 'compressed' in file_output:
        selected_tools.extend(TOOL_MATRIX['archive']['extraction'])
        selected_tools.extend(TOOL_MATRIX['archive']['analysis'])
    
    # Network captures
    elif 'pcap' in file_output or 'capture' in file_output:
        selected_tools.extend(TOOL_MATRIX['network']['pcap'])
    
    # Always add generic tools
    selected_tools.extend(['strings', 'binwalk', 'xxd'])
    
    # Remove duplicates
    selected_tools = list(dict.fromkeys(selected_tools))
    
    # Check which tools are installed
    available_tools = []
    unavailable_tools = []
    
    for tool in selected_tools:
        if subprocess.run(['which', tool], capture_output=True).returncode == 0:
            available_tools.append(tool)
        else:
            unavailable_tools.append(tool)
    
    print(f"[*] Recommended tools for {os.path.basename(file_path)}:")
    print(f"    Available ({len(available_tools)}): {', '.join(available_tools)}")
    
    if unavailable_tools:
        print(f"    Not installed ({len(unavailable_tools)}): {', '.join(unavailable_tools)}")
    
    return available_tools, unavailable_tools

# Usage
available, missing = select_tools('challenge.png')
```

### Tool Priority System

```python
TOOL_PRIORITY = {
    'image': [
        ('exiftool', 10, 'Always check metadata first'),
        ('zsteg', 9, 'Comprehensive LSB/metadata for PNG/BMP'),
        ('binwalk', 8, 'Check for embedded files'),
        ('strings', 8, 'Quick text extraction'),
        ('stegsolve', 7, 'Visual analysis and bit planes'),
        ('steghide', 6, 'Common passphrase-based stego'),
        ('stegseek', 6, 'Fast steghide cracking'),
    ],
    'audio': [
        ('exiftool', 10, 'Metadata examination'),
        ('sox', 9, 'Spectrogram generation'),
        ('sonic-visualiser', 8, 'Advanced audio analysis'),
        ('steghide', 7, 'Common audio stego'),
        ('binwalk', 7, 'Embedded file detection'),
    ],
    'video': [
        ('exiftool', 10, 'Comprehensive metadata'),
        ('ffprobe', 9, 'Detailed stream information'),
        ('ffmpeg', 9, 'Frame/audio extraction'),
        ('mediainfo', 8, 'Container analysis'),
        ('binwalk', 7, 'Embedded file detection'),
    ]
}

def get_prioritized_tools(file_type):
    """
    Return tools in priority order for given file type
    """
    if file_type in TOOL_PRIORITY:
        sorted_tools = sorted(TOOL_PRIORITY[file_type], 
                            key=lambda x: x[1], 
                            reverse=True)
        
        print(f"[*] Prioritized tool list for {file_type}:")
        for tool, priority, reason in sorted_tools:
            print(f"    [{priority:2d}] {tool:20s} - {reason}")
        
        return [tool[0] for tool in sorted_tools]
    
    return []
```

---

## Systematic Enumeration

### Layered Enumeration Approach

**Layer 1: Passive Analysis (no modification)**

```bash
#!/bin/bash
# layer1_passive.sh - Non-destructive analysis

FILE="$1"
OUTDIR="analysis_$(basename $FILE)_$(date +%s)"

mkdir -p "$OUTDIR"

echo "[Layer 1] Passive Analysis: $FILE"
echo "Output directory: $OUTDIR"
echo

# 1. File identification
echo "[1.1] File Identification" | tee "$OUTDIR/01_fileinfo.txt"
file -b "$FILE" | tee -a "$OUTDIR/01_fileinfo.txt"
file -b --mime-type "$FILE" | tee -a "$OUTDIR/01_fileinfo.txt"
echo | tee -a "$OUTDIR/01_fileinfo.txt"

# 2. Hashes
echo "[1.2] Hash Values" | tee "$OUTDIR/02_hashes.txt"
md5sum "$FILE" | tee -a "$OUTDIR/02_hashes.txt"
sha1sum "$FILE" | tee -a "$OUTDIR/02_hashes.txt"
sha256sum "$FILE" | tee -a "$OUTDIR/02_hashes.txt"
echo | tee -a "$OUTDIR/02_hashes.txt"

# 3. Metadata
echo "[1.3] Metadata Extraction" | tee "$OUTDIR/03_metadata.txt"
exiftool "$FILE" | tee -a "$OUTDIR/03_metadata.txt"
echo | tee -a "$OUTDIR/03_metadata.txt"

# 4. Strings
echo "[1.4] String Extraction" | tee "$OUTDIR/04_strings.txt"
strings -n 6 "$FILE" > "$OUTDIR/04_strings_all.txt"
strings -n 6 "$FILE" | head -100 | tee -a "$OUTDIR/04_strings.txt"
echo "... (full output in 04_strings_all.txt)" | tee -a "$OUTDIR/04_strings.txt"

# 5. Binwalk scan
echo "[1.5] Binwalk Scan" | tee "$OUTDIR/05_binwalk.txt"
binwalk "$FILE" | tee -a "$OUTDIR/05_binwalk.txt"
echo | tee -a "$OUTDIR/05_binwalk.txt"

# 6. Hex dump (first 1KB)
echo "[1.6] Hex Dump (first 1KB)" | tee "$OUTDIR/06_hexdump.txt"
xxd -l 1024 "$FILE" > "$OUTDIR/06_hexdump_head.txt"
xxd -l 1024 "$FILE" | head -20 | tee -a "$OUTDIR/06_hexdump.txt"

# 7. Entropy
echo "[1.7] Entropy Analysis" | tee "$OUTDIR/07_entropy.txt"
ent "$FILE" | tee -a "$OUTDIR/07_entropy.txt"

echo
echo "[*] Layer 1 complete. Results in: $OUTDIR"
```

**Layer 2: Active Extraction**

```bash
#!/bin/bash
# layer2_extraction.sh - Extract embedded content

FILE="$1"
OUTDIR="$2"

if [ -z "$OUTDIR" ]; then
    OUTDIR="extraction_$(basename $FILE)_$(date +%s)"
fi

mkdir -p "$OUTDIR"

echo "[Layer 2] Active Extraction: $FILE"
echo "Output directory: $OUTDIR"
echo

# 1. Binwalk extraction
echo "[2.1] Binwalk Extraction"
binwalk -e -C "$OUTDIR/binwalk_extracted" "$FILE"

# 2. Foremost carving
echo "[2.2] Foremost File Carving"
foremost -t all -i "$FILE" -o "$OUTDIR/foremost_carved"

# 3. Scalpel carving
echo "[2.3] Scalpel File Carving"
scalpel -o "$OUTDIR/scalpel_carved" "$FILE" 2>/dev/null

# 4. File-type specific extraction
FILETYPE=$(file -b --mime-type "$FILE")

if [[ "$FILETYPE" == image/* ]]; then
    echo "[2.4] Image-specific extraction"
    
    # zsteg for PNG/BMP
    if [[ "$FILETYPE" == "image/png" ]] || [[ "$FILETYPE" == "image/bmp" ]]; then
        zsteg -a "$FILE" > "$OUTDIR/zsteg_output.txt"
    fi
    
    # Steghide extraction attempts
    echo "[2.5] Steghide extraction (passwordless)"
    steghide extract -sf "$FILE" -xf "$OUTDIR/steghide_extracted.bin" -p "" 2>/dev/null
    
elif [[ "$FILETYPE" == application/pdf ]]; then
    echo "[2.4] PDF-specific extraction"
    pdfimages "$FILE" "$OUTDIR/pdf_images"
    pdf-parser --search javascript "$FILE" > "$OUTDIR/pdf_javascript.txt"
    
elif [[ "$FILETYPE" == application/zip ]] || [[ "$FILETYPE" == "application/x-zip-compressed" ]]; then
    echo "[2.4] Archive extraction"
    unzip -d "$OUTDIR/archive_contents" "$FILE" 2>/dev/null || \
    7z x -o"$OUTDIR/archive_contents" "$FILE" 2>/dev/null
fi

echo
echo "[*] Layer 2 complete. Results in: $OUTDIR"
```

**Layer 3: Deep Analysis**

```python
#!/usr/bin/env python3
# layer3_deep_analysis.py

import os
import sys
import subprocess
from pathlib import Path

def layer3_deep_analysis(file_path, output_dir):
    """
    Deep analysis using specialized techniques
    """
    print(f"[Layer 3] Deep Analysis: {file_path}")
    print(f"Output directory: {output_dir}")
    print()
    
    os.makedirs(output_dir, exist_ok=True)
    
    # Detect file type
    file_type = subprocess.run(['file', '-b', '--mime-type', file_path],
                              capture_output=True, text=True).stdout.strip()
    
    # 3.1 LSB Analysis
    print("[3.1] LSB Analysis")
    if file_type.startswith('image/'):
        lsb_analysis_image(file_path, output_dir)
    
    # 3.2 Frequency Analysis
    print("[3.2] Frequency/Statistical Analysis")
    frequency_analysis(file_path, output_dir)
    
    # 3.3 Pattern Detection
    print("[3.3] Pattern Detection")
    pattern_detection(file_path, output_dir)
    
    # 3.4 Encoding Detection
    print("[3.4] Encoding Detection")
    encoding_detection(file_path, output_dir)
    
    # 3.5 Cryptographic Analysis
    print("[3.5] Cryptographic Indicators")
    crypto_analysis(file_path, output_dir)
    
    print()
    print(f"[*] Layer 3 complete. Results in: {output_dir}")

def lsb_analysis_image(file_path, output_dir):
    """Extract and analyze LSB data from images"""
    import cv2
    import numpy as np
    from PIL import Image
    
    img = cv2.imread(file_path)
    if img is None:
        print("    [!] Could not load image")
        return
    
    # Extract LSB from each channel
    for i, channel_name in enumerate(['Blue', 'Green', 'Red']):
        channel = img[:,:,i]
        lsb = channel & 1
        
        # Save LSB as image
        lsb_img = lsb * 255
        cv2.imwrite(os.path.join(output_dir, f'lsb_{channel_name.lower()}.png'), lsb_img)
        
        # Convert to binary string and try decode
        binary = ''.join(lsb.flatten().astype(str))
        
        try:
            # Try first 10KB
            bytes_data = bytes([int(binary[i:i+8], 2) for i in range(0, min(80000, len(binary)), 8)])
            
            output_file = os.path.join(output_dir, f'lsb_{channel_name.lower()}_data.bin')
            with open(output_file, 'wb') as f:
                f.write(bytes_data)
            
            # Check for file signatures
            if bytes_data[:4] == b'\x89PNG':
                print(f"    [!] PNG signature in {channel_name} LSB")
            elif bytes_data[:2] == b'\xFF\xD8':
                print(f"    [!] JPEG signature in {channel_name} LSB")
            
        except Exception as e:
            pass

def frequency_analysis(file_path, output_dir):
    """Analyze byte frequency distribution"""
    from collections import Counter
    import json
    
    with open(file_path, 'rb') as f:
        data = f.read()
    
    counter = Counter(data)
    
    # Save frequency data
    freq_file = os.path.join(output_dir, 'byte_frequency.json')
    with open(freq_file, 'w') as f:
        json.dump(dict(counter.most_common()), f, indent=2)
    
    # Statistical analysis
    unique_bytes = len(counter)
    total_bytes = len(data)
    
    print(f"    Unique bytes: {unique_bytes}/256")
    print(f"    Total bytes: {total_bytes}")
    
    # Check for unusual distributions
    if unique_bytes < 50:
        print(f"    [!] Low byte diversity - possible encoding")
    elif unique_bytes > 250:
        print(f"    [!] High byte diversity - possibly encrypted/compressed")

def pattern_detection(file_path, output_dir):
    """Detect repeating patterns"""
    with open(file_path, 'rb') as f:
        data = f.read()
    
    # Look for repeating sequences
    pattern_lengths = [4, 8, 16, 32]
    
    for length in pattern_lengths:
        patterns = {}
        for i in range(len(data) - length):
            pattern = data[i:i+length]
            if pattern not in patterns:
                patterns[pattern] = []
            patterns[pattern].append(i)
        
        # Find patterns that repeat
        repeating = {p: offsets for p, offsets in patterns.items() if len(offsets) > 5}
        
        if repeating:
            print(f"    [!] Found {len(repeating)} patterns of length {length} that repeat 5+ times")
            
            # Save top patterns
            pattern_file = os.path.join(output_dir, f'patterns_{length}byte.txt')
            with open(pattern_file, 'w') as f:
                sorted_patterns = sorted(repeating.items(), key=lambda x: len(x[1]), reverse=True)
                for pattern, offsets in sorted_patterns[:10]:
                    f.write(f"Pattern (hex): {pattern.hex()}\n")
                    f.write(f"Occurrences: {len(offsets)}\n")
                    f.write(f"Offsets: {offsets[:20]}\n\n")

def encoding_detection(file_path, output_dir):
    """Detect common encodings"""
    import base64
    import re
    
    with open(file_path, 'rb') as f:
        data = f.read()
    
    # Try to decode as text
    try:
        text = data.decode('utf-8', errors='ignore')
    except:
        text = data.decode('latin-1', errors='ignore')
    
    findings = []
    
    # Base64 detection
    b64_pattern = re.compile(rb'[A-Za-z0-9+/]{20,}={0,2}')
    b64_matches = b64_pattern.findall(data)
    
    if b64_matches:
        print(f"    [!] Found {len(b64_matches)} potential base64 strings")
        
        for i, match in enumerate(b64_matches[:5]):
            try:
                decoded = base64.b64decode(match)
                if len(decoded) > 10 and (decoded.isprintable() or decoded[:4] in [b'\x89PNG', b'\xFF\xD8']):
                    findings.append(f"Base64 #{i}: {decoded[:50]}")
            except:
                pass
    
    # Hex string detection
    hex_pattern = re.compile(rb'[0-9a-fA-F]{32,}')
    hex_matches = hex_pattern.findall(data)
    
    if hex_matches:
        print(f"    [!] Found {len(hex_matches)} potential hex strings")
        
        for i, match in enumerate(hex_matches[:5]):
            try:
                decoded = bytes.fromhex(match.decode('ascii'))
                if len(decoded) > 10 and decoded.isprintable():
                    findings.append(f"Hex #{i}: {decoded[:50]}")
            except:
                pass
    
    # Save findings
    if findings:
        findings_file = os.path.join(output_dir, 'encoding_findings.txt')
        with open(findings_file, 'w') as f:
            f.write('\n'.join(findings))

def crypto_analysis(file_path, output_dir):
    """Look for cryptographic indicators"""
    with open(file_path, 'rb') as f:
        data = f.read()
    
    indicators = []
    
    # High entropy check
    from collections import Counter
    import math
    
    counter = Counter(data)
    length = len(data)
    entropy = -sum((count/length) * math.log2(count/length) for count in counter.values())
    
    print(f"    Entropy: {entropy:.4f} bits/byte")
    
    if entropy > 7.9:
        indicators.append("Very high entropy - likely encrypted")
    
    # Look for crypto keywords in strings
    crypto_keywords = [b'AES', b'RSA', b'encrypted', b'cipher', b'key', b'IV', b'salt']
    
    for keyword in crypto_keywords:
        if keyword in data:
            indicators.append(f"Found keyword: {keyword.decode()}")
    
    # Check for common encrypted file headers
    encrypted_signatures = {
        b'Salted__': 'OpenSSL encrypted',
        b'-----BEGIN': 'PEM format (possibly encrypted)',
    }
    
    for sig, desc in encrypted_signatures.items():
        if data.startswith(sig):
            indicators.append(f"Signature: {desc}")
    
    if indicators:
        print(f"    [!] Cryptographic indicators:")
        for indicator in indicators:
            print(f"        - {indicator}")

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python3 layer3_deep_analysis.py <file> [output_dir]")
        sys.exit(1)
    
    file_path = sys.argv[1]
    output_dir = sys.argv[2] if len(sys.argv) > 2 else f"deep_analysis_{Path(file_path).stem}"
    
    layer3_deep_analysis(file_path, output_dir)
```

### Enumeration Checklist System

```python
#!/usr/bin/env python3
# enumeration_checklist.py

class EnumerationChecklist:
    def __init__(self, file_path):
        self.file_path = file_path
        self.checklist = {
            'basic_info': {
                'File type identified': False,
                'Hash calculated': False,
                'File size analyzed': False,
                'Magic bytes checked': False,
            },
            'metadata': {
                'EXIF/metadata extracted': False,
                'Timestamps analyzed': False,
                'GPS data checked': False,
                'Custom metadata fields reviewed': False,
            },
            'embedded_content': {
                'Binwalk scan completed': False,
                'Foremost carving done': False,
                'Strings extracted': False,
                'File signatures searched': False,
            },
            'steganography': {
                'LSB analysis performed': False,
                'Visual inspection done': False,
                'Bit plane analysis completed': False,
                'Tool-specific checks run': False,
            },
            'encoding': {
                'Base64 checked': False,
                'Hex encoding checked': False,
                'ROT13/Caesar checked': False,
                'Custom encoding investigated': False,
            },
            'structure': {
                'Container format analyzed': False,
                'File structure validated': False,
                'Padding/free space examined': False,
                'Concatenated files checked': False,
            }
        }
        self.notes = {}
    
    def mark_complete(self, category, item, note=None):
        """Mark checklist item as complete"""
        if category in self.checklist and item in self.checklist[category]:
            self.checklist[category][item] = True
            if note:
                self.notes[f"{category}.{item}"] = note
            return True
        return False
    
    def add_note(self, category, item, note):
        """Add note to specific item"""
        key = f"{category}.{item}"
        if key not in self.notes:
            self.notes[key] = []
        self.notes[key].append(note)
    
    def print_status(self):
        """Print current checklist status"""
        print(f"\n{'='*70}")
        print(f"ENUMERATION CHECKLIST: {self.file_path}")
        print(f"{'='*70}\n")
        
        total_items = 0
        completed_items = 0
        
        for category, items in self.checklist.items():
            print(f"[{category.upper().replace('_', ' ')}]")
            
            for item, status in items.items():
                total_items += 1
                symbol = '[✓]' if status else '[ ]'
                print(f"  {symbol} {item}")
                
                if status:
                    completed_items += 1
                    
                # Print notes if any
                key = f"{category}.{item}"
                if key in self.notes:
                    if isinstance(self.notes[key], list):
                        for note in self.notes[key]:
                            print(f"      → {note}")
                    else:
                        print(f"      → {self.notes[key]}")
            
            print()
        
        completion = (completed_items / total_items) * 100
        print(f"{'='*70}")
        print(f"Completion: {completed_items}/{total_items} ({completion:.1f}%)")
        print(f"{'='*70}\n")
    
    def save_checklist(self, output_file):
        """Save checklist to file"""
        import json
        
        data = {
            'file': self.file_path,
            'checklist': self.checklist,
            'notes': self.notes
        }
        
        with open(output_file, 'w') as f:
            json.dump(data, f, indent=2)
    
    def load_checklist(self, input_file):
        """Load checklist from file"""
        import json
        
        with open(input_file, 'r') as f:
            data = json.load(f)
        
        self.checklist = data['checklist']
        self.notes = data['notes']

# Usage example
if __name__ == "__main__":
    import sys
    
    if len(sys.argv) < 2:
        print("Usage: python3 enumeration_checklist.py <file>")
        sys.exit(1)
    
    checklist = EnumerationChecklist(sys.argv[1])
    
    # Example: mark items as you complete them
    checklist.mark_complete('basic_info', 'File type identified', 'PNG image')
    checklist.mark_complete('basic_info', 'Hash calculated', 'MD5: abc123...')
    checklist.mark_complete('metadata', 'EXIF/metadata extracted', 'Found camera make/model')
    
    # Print status
    checklist.print_status()
    
    # Save progress
    checklist.save_checklist('progress.json')
```

---

## Documentation & Note-Taking

### Structured Note Template

```markdown
# CTF Challenge Analysis: [CHALLENGE_NAME]

**Date:** YYYY-MM-DD
**Analyst:** [Your Name]
**Category:** Steganography
**Difficulty:** [Easy/Medium/Hard]

---

## Challenge Information

- **Challenge Name:** 
- **Points:** 
- **Description:**
```

[Paste challenge description here]

````
- **Provided Files:**
- `file1.png` (MD5: abc123..., Size: 1.2MB)
- `file2.txt` (MD5: def456..., Size: 512B)

---

## Initial Assessment

### File Identification
```bash
$ file challenge.png
PNG image data, 1920 x 1080, 8-bit/color RGB, non-interlaced

$ md5sum challenge.png
a1b2c3d4e5f6... challenge.png
````

### First Observations

- Large file size for resolution (expected ~6MB, actual 8MB)
- EXIF data contains unusual comment field
- File opens normally in image viewers

---

## Timeline of Analysis

### [HH:MM] Initial Reconnaissance

**Actions:**

- Ran `exiftool`, found GPS coordinates in metadata
- Checked GPS location: points to [Location]
- Comment field contains base64-looking string

**Findings:**

- EXIF Comment: `VGhpcyBpcyBhIGNsdWU=`
- Decoded: "This is a clue"

### [HH:MM] Metadata Analysis

**Tools Used:** `exiftool`, `pngcheck`

**Commands:**

```bash
exiftool -a challenge.png > metadata.txt
pngcheck -v challenge.png
```

**Findings:**

- Multiple EXIF fields with suspicious values
- PNG chunks appear normal
- [!] Found non-standard chunk: "tEXt" with key "secret"

### [HH:MM] LSB Analysis

**Tools Used:** `zsteg`

**Commands:**

```bash
zsteg -a challenge.png > zsteg_output.txt
```

**Findings:**

- LSB in red channel contains repeating pattern
- Blue channel LSB appears random (high entropy)
- Green channel LSB shows structured data

**[!] BREAKTHROUGH:** Green LSB contains PNG header signature

### [HH:MM] Extraction

**Commands:**

```bash
zsteg -E b1,g,lsb,xy challenge.png > extracted.bin
file extracted.bin
# Output: PNG image data
```

**Result:** Successfully extracted hidden PNG image

### [HH:MM] Analysis of Hidden Image

- Hidden image contains QR code
- QR code decodes to: `flag{h1dd3n_1n_gr33n_LSB}`

---

## Tools Used

|Tool|Purpose|Result|
|---|---|---|
|file|File type identification|Confirmed PNG|
|exiftool|Metadata extraction|Found GPS + comments|
|pngcheck|PNG structure validation|Identified custom chunk|
|zsteg|LSB analysis|Found hidden PNG in green LSB|
|qr-decoder|QR code reading|Extracted flag|

---

## Techniques Applied

1. **Metadata Analysis**
    
    - Extracted all EXIF fields
    - Decoded base64 hints
    - Analyzed GPS coordinates
2. **LSB Steganography**
    
    - Checked all color channels
    - Identified green channel as carrier
    - Extracted embedded PNG
3. **QR Code Analysis**
    
    - Scanned hidden image
    - Decoded QR to flag

---

## Dead Ends / Failed Attempts

1. ❌ Tried `steghide` with common passwords
    - Tool reported incompatible format
2. ❌ Analyzed red/blue LSB thinking XOR pattern
    - Was just noise, actual data in green
3. ❌ Attempted spectral analysis
    - Not applicable to static images

---

## Key Insights / Lessons Learned

- Always check ALL color channels separately in LSB analysis
- EXIF comment fields often contain hints
- File size discrepancies are strong indicators
- QR codes are common final encoding in CTFs

---

## Solution Summary

**Flag:** `flag{h1dd3n_1n_gr33n_LSB}`

**Attack Chain:**

```
challenge.png
  → EXIF metadata analysis (hint found)
  → LSB analysis with zsteg
  → Green channel extraction
  → Hidden PNG discovered
  → QR code scanned
  → Flag retrieved
```

**Time Spent:** 45 minutes **Difficulty Rating:** Medium (3/5)

---

## Files Generated

- `metadata.txt` - Full EXIF output
- `zsteg_output.txt` - Complete zsteg analysis
- `extracted.bin` - Hidden PNG image
- `flag.txt` - Final flag

---

## References / Resources

- [zsteg documentation](https://github.com/zed-0xff/zsteg)
- PNG LSB steganography techniques
- QR code specification ISO/IEC 18004

---

## Tags

`#steganography` `#lsb` `#png` `#metadata` `#qr-code`

````

### Automated Note Generator

```python
#!/usr/bin/env python3
# note_generator.py

from datetime import datetime
import subprocess
import os

class CTFNoteGenerator:
    def __init__(self, challenge_name, files):
        self.challenge_name = challenge_name
        self.files = files
        self.timeline = []
        self.tools_used = []
        self.findings = []
        self.dead_ends = []
        
    def add_timeline_entry(self, action, commands=None, findings=None):
        """Add entry to analysis timeline"""
        entry = {
            'timestamp': datetime.now().strftime("%H:%M"),
            'action': action,
            'commands': commands or [],
            'findings': findings or []
        }
        self.timeline.append(entry)
    
    def add_tool(self, tool_name, purpose, result):
        """Record tool usage"""
        self.tools_used.append({
            'tool': tool_name,
            'purpose': purpose,
            'result': result
        })
    
    def add_finding(self, finding, is_breakthrough=False):
        """Add finding"""
        self.findings.append({
            'text': finding,
            'breakthrough': is_breakthrough,
            'timestamp': datetime.now().strftime("%H:%M")
        })
    
    def add_dead_end(self, attempt, reason):
        """Record failed attempts"""
        self.dead_ends.append({
            'attempt': attempt,
            'reason': reason
        })
    
    def generate_initial_assessment(self):
        """Generate initial assessment section"""
        assessment = []
        
        for file_path in self.files:
            if not os.path.exists(file_path):
                continue
            
            # File command
            file_type = subprocess.run(['file', '-b', file_path],
                                      capture_output=True, text=True).stdout.strip()
            
            # Hash
            md5 = subprocess.run(['md5sum', file_path],
                                capture_output=True, text=True).stdout.split()[0]
            
            # Size
            size = os.path.getsize(file_path)
            size_kb = size / 1024
            
            assessment.append({
                'filename': os.path.basename(file_path),
                'type': file_type,
                'md5': md5,
                'size': f"{size_kb:.2f}KB"
            })
        
        return assessment
    
    def generate_markdown(self, output_file=None):
        """Generate complete markdown notes"""
        md = []
        
        # Header
        md.append(f"# CTF Challenge Analysis: {self.challenge_name}\n")
        md.append(f"**Date:** {datetime.now().strftime('%Y-%m-%d')}")
        md.append(f"**Category:** Steganography\n")
        md.append("---\n")
        
        # Challenge Information
        md.append("## Challenge Information\n")
        md.append(f"- **Challenge Name:** {self.challenge_name}")
        md.append("- **Provided Files:**")
        
        initial = self.generate_initial_assessment()
        for item in initial:
            md.append(f"  - `{item['filename']}` (MD5: {item['md5'][:16]}..., Size: {item['size']})")
        
        md.append("\n---\n")
        
        # Timeline
        md.append("## Timeline of Analysis\n")
        
        for entry in self.timeline:
            md.append(f"### [{entry['timestamp']}] {entry['action']}\n")
            
            if entry['commands']:
                md.append("**Commands:**")
                md.append("```bash")
                for cmd in entry['commands']:
                    md.append(cmd)
                md.append("```\n")
            
            if entry['findings']:
                md.append("**Findings:**")
                for finding in entry['findings']:
                    prefix = "[!]" if isinstance(finding, dict) and finding.get('important') else "-"
                    text = finding if isinstance(finding, str) else finding.get('text', '')
                    md.append(f"{prefix} {text}")
                md.append("")
        
        md.append("---\n")
        
        # Tools Used
        md.append("## Tools Used\n")
        md.append("| Tool | Purpose | Result |")
        md.append("|------|---------|--------|")
        
        for tool in self.tools_used:
            md.append(f"| {tool['tool']} | {tool['purpose']} | {tool['result']} |")
        
        md.append("\n---\n")
        
        # Dead Ends
        if self.dead_ends:
            md.append("## Dead Ends / Failed Attempts\n")
            
            for i, dead_end in enumerate(self.dead_ends, 1):
                md.append(f"{i}. ❌ {dead_end['attempt']}")
                md.append(f"   - {dead_end['reason']}\n")
        
        md.append("---\n")
        
        # Join and return
        markdown_content = '\n'.join(md)
        
        if output_file:
            with open(output_file, 'w') as f:
                f.write(markdown_content)
            print(f"[*] Notes saved to: {output_file}")
        
        return markdown_content

# Usage example
if __name__ == "__main__":
    import sys
    
    if len(sys.argv) < 3:
        print("Usage: python3 note_generator.py <challenge_name> <file1> [file2] ...")
        sys.exit(1)
    
    challenge = sys.argv[1]
    files = sys.argv[2:]
    
    notes = CTFNoteGenerator(challenge, files)
    
    # Example usage during analysis
    notes.add_timeline_entry(
        "Initial Reconnaissance",
        commands=["file challenge.png", "exiftool challenge.png"],
        findings=["PNG image confirmed", "Unusual EXIF comment field"]
    )
    
    notes.add_tool("exiftool", "Metadata extraction", "Found GPS coordinates")
    notes.add_dead_end("Tried steghide with common passwords", "Incompatible format")
    
    # Generate markdown
    notes.generate_markdown(f"notes_{challenge}.md")
````

### Quick Command Logger

```bash
#!/bin/bash
# command_logger.sh - Log commands with timestamps

LOGFILE="ctf_commands_$(date +%Y%m%d_%H%M%S).log"

echo "=== CTF Command Log ===" > "$LOGFILE"
echo "Started: $(date)" >> "$LOGFILE"
echo "" >> "$LOGFILE"

# Function to log command
log_cmd() {
    echo "[$(date +%H:%M:%S)] $ $@" >> "$LOGFILE"
    eval "$@"
    echo "" >> "$LOGFILE"
}

# Export function for subshells
export -f log_cmd
export LOGFILE

echo "Command logging active. Log file: $LOGFILE"
echo "Use: log_cmd <command>"
echo "Or run: script -a $LOGFILE for full session recording"

# Example usage:
# log_cmd file challenge.png
# log_cmd exiftool challenge.png
# log_cmd zsteg -a challenge.png
```

---

## Time Management

### Challenge Time Allocation Matrix

```python
TIME_ALLOCATION = {
    'easy': {
        'initial_assessment': 5,    # minutes
        'basic_tools': 10,
        'extraction': 5,
        'analysis': 10,
        'total_target': 30
    },
    'medium': {
        'initial_assessment': 10,
        'basic_tools': 15,
        'extraction': 20,
        'deep_analysis': 25,
        'documentation': 10,
        'total_target': 80
    },
    'hard': {
        'initial_assessment': 15,
        'basic_tools': 20,
        'deep_analysis': 45,
        'custom_tools': 60,
        'documentation': 20,
        'total_target': 160
    }
}
```

### Time Tracking Tool

```python
#!/usr/bin/env python3
# time_tracker.py

import time
from datetime import datetime, timedelta

class CTFTimeTracker:
    def __init__(self, challenge_name, difficulty='medium'):
        self.challenge_name = challenge_name
        self.difficulty = difficulty
        self.start_time = datetime.now()
        self.phases = {}
        self.current_phase = None
        self.phase_start = None
        
        self.target_time = TIME_ALLOCATION.get(difficulty, {}).get('total_target', 60)
    
    def start_phase(self, phase_name):
        """Start timing a phase"""
        if self.current_phase:
            self.end_phase()
        
        self.current_phase = phase_name
        self.phase_start = datetime.now()
        print(f"\n[{self.phase_start.strftime('%H:%M:%S')}] Starting phase: {phase_name}")
    
    def end_phase(self):
        """End current phase"""
        if not self.current_phase:
            return
        
        end_time = datetime.now()
        duration = (end_time - self.phase_start).total_seconds() / 60  # minutes
        
        self.phases[self.current_phase] = {
            'start': self.phase_start,
            'end': end_time,
            'duration': duration
        }
        
        print(f"[{end_time.strftime('%H:%M:%S')}] Completed: {self.current_phase} ({duration:.1f} min)")
        
        self.current_phase = None
        self.phase_start = None
    
    def print_summary(self):
        """Print time summary"""
        if self.current_phase:
            self.end_phase()
        
        total_time = (datetime.now() - self.start_time).total_seconds() / 60
        
        print("\n" + "="*70)
        print(f"TIME SUMMARY: {self.challenge_name}")
        print("="*70)
        print(f"Difficulty: {self.difficulty}")
        print(f"Target Time: {self.target_time} minutes")
        print(f"Actual Time: {total_time:.1f} minutes")
        
        if total_time > self.target_time:
            print(f"[!] Over target by {total_time - self.target_time:.1f} minutes")
        else:
            print(f"[✓] Under target by {self.target_time - total_time:.1f} minutes")
        
        print("\nPhase Breakdown:")
        print("-"*70)
        
        for phase, data in self.phases.items():
            percentage = (data['duration'] / total_time) * 100
            print(f"{phase:30s} {data['duration']:6.1f} min ({percentage:5.1f}%)")
        
        print("="*70 + "\n")
    
    def check_progress(self):
        """Check if on track"""
        elapsed = (datetime.now() - self.start_time).total_seconds() / 60
        progress_pct = (elapsed / self.target_time) * 100
        
        print(f"\n[Progress Check]")
        print(f"  Elapsed: {elapsed:.1f} / {self.target_time} minutes ({progress_pct:.1f}%)")
        
        if progress_pct > 75 and not self.phases:
            print(f"  [!] WARNING: 75% of time used with no completed phases")
        elif progress_pct > 50:
            print(f"  [!] Halfway through target time")

# Usage
if __name__ == "__main__":
    import sys
    
    if len(sys.argv) < 2:
        print("Usage: python3 time_tracker.py <challenge_name> [difficulty]")
        sys.exit(1)
    
    challenge = sys.argv[1]
    difficulty = sys.argv[2] if len(sys.argv) > 2 else 'medium'
    
    tracker = CTFTimeTracker(challenge, difficulty)
    
    # Example usage:
    tracker.start_phase("Initial Assessment")
    time.sleep(2)  # Simulate work
    
    tracker.start_phase("Tool Execution")
    time.sleep(3)
    
    tracker.start_phase("Analysis")
    time.sleep(2)
    
    tracker.print_summary()
```

### Decision Tree for Time Management

```python
def should_continue_approach(time_spent_minutes, progress_made, total_budget_minutes):
    """
    Decide whether to continue current approach or pivot
    
    Returns: ('continue'|'pivot'|'ask_hint', reason)
    """
    time_pct = (time_spent_minutes / total_budget_minutes) * 100
    
    # Early stage (0-25% of time)
    if time_pct < 25:
        if progress_made > 0:
            return ('continue', "Early stage with progress - keep going")
        else:
            return ('continue', "Still early - try more basic techniques")
    
    # Mid stage (25-50% of time)
    elif time_pct < 50:
        if progress_made >= 2:
            return ('continue', "Good progress - on right track")
        elif progress_made == 1:
            return ('continue', "Some progress - give it more time")
        else:
            return ('pivot', "No progress at 40% time - try different approach")
    
    # Late stage (50-75% of time)
    elif time_pct < 75:
        if progress_made >= 3:
            return ('continue', "Significant progress - finish it")
        elif progress_made >= 1:
            return ('continue', "Have leads - push through")
        else:
            return ('ask_hint', "Past halfway with no progress - consider hint")
    
    # Critical stage (75%+ of time)
    else:
        if progress_made >= 3:
            return ('continue', "Almost done - finish strong")
        else:
            return ('ask_hint', "Running out of time - need guidance")

# Example usage
time_spent = 35
progress = 1  # Found one clue
budget = 80

action, reason = should_continue_approach(time_spent, progress, budget)
print(f"Decision: {action}")
print(f"Reason: {reason}")
```

---

## Team Collaboration

### Challenge Assignment Strategy

```python
TEAM_ROLES = {
    'metadata_specialist': {
        'tools': ['exiftool', 'mediainfo', 'pdfinfo'],
        'focus': 'Extract and analyze all metadata'
    },
    'image_analyst': {
        'tools': ['zsteg', 'stegsolve', 'steghide', 'gimp'],
        'focus': 'Visual and LSB analysis of images'
    },
    'binary_analyst': {
        'tools': ['binwalk', 'foremost', 'ghex', 'radare2'],
        'focus': 'Binary structure and embedded files'
    },
    'crypto_specialist': {
        'tools': ['hashcat', 'john', 'cyberchef'],
        'focus': 'Encryption, encoding, ciphers'
    },
    'automation_expert': {
        'tools': ['python', 'bash', 'custom_scripts'],
        'focus': 'Scripting and bulk analysis'
    }
}

def assign_challenge(file_type, team_size):
    """
    Suggest role assignments based on file type
    """
    assignments = []
    
    if 'image' in file_type:
        assignments.append(('metadata_specialist', 'priority'))
        assignments.append(('image_analyst', 'priority'))
        assignments.append(('binary_analyst', 'secondary'))
    
    elif 'audio' in file_type or 'video' in file_type:
        assignments.append(('metadata_specialist', 'priority'))
        assignments.append(('binary_analyst', 'priority'))
        assignments.append(('automation_expert', 'secondary'))
    
    elif 'archive' in file_type:
        assignments.append(('binary_analyst', 'priority'))
        assignments.append(('crypto_specialist', 'priority'))
    
    else:
        assignments.append(('binary_analyst', 'priority'))
        assignments.append(('automation_expert', 'secondary'))
    
    return assignments[:team_size]
```

### Shared Progress Tracker

```python
#!/usr/bin/env python3
# shared_tracker.py - Multi-user progress tracking

import json
import os
from datetime import datetime

class SharedTracker:
    def __init__(self, challenge_name, tracker_file='progress.json'):
        self.challenge_name = challenge_name
        self.tracker_file = tracker_file
        self.load_or_create()
    
    def load_or_create(self):
        """Load existing tracker or create new"""
        if os.path.exists(self.tracker_file):
            with open(self.tracker_file, 'r') as f:
                self.data = json.load(f)
        else:
            self.data = {
                'challenge': self.challenge_name,
                'started': datetime.now().isoformat(),
                'team_members': [],
                'findings': [],
                'tasks': [],
                'tools_tried': [],
                'dead_ends': [],
                'flag': None
            }
            self.save()
    
    def save(self):
        """Save tracker to file"""
        with open(self.tracker_file, 'w') as f:
            json.dump(self.data, f, indent=2)
    
    def add_team_member(self, name, role):
        """Register team member"""
        member = {
            'name': name,
            'role': role,
            'joined': datetime.now().isoformat()
        }
        
        if member not in self.data['team_members']:
            self.data['team_members'].append(member)
            self.save()
            print(f"[*] {name} joined as {role}")
    
    def add_finding(self, finder, finding, importance='normal'):
        """Add finding to shared tracker"""
        entry = {
            'timestamp': datetime.now().isoformat(),
            'finder': finder,
            'finding': finding,
            'importance': importance
        }
        
        self.data['findings'].append(entry)
        self.save()
        
        symbol = '[!]' if importance == 'critical' else '[*]'
        print(f"{symbol} {finder}: {finding}")
    
    def claim_task(self, person, task_description):
        """Claim a task to avoid duplicate work"""
        task = {
            'task': task_description,
            'claimed_by': person,
            'claimed_at': datetime.now().isoformat(),
            'status': 'in_progress'
        }
        
        self.data['tasks'].append(task)
        self.save()
        print(f"[*] {person} is now working on: {task_description}")
    
    def complete_task(self, person, task_description, result=None):
        """Mark task as complete"""
        for task in self.data['tasks']:
            if task['claimed_by'] == person and task['task'] == task_description:
                task['status'] = 'completed'
                task['completed_at'] = datetime.now().isoformat()
                if result:
                    task['result'] = result
                break
        
        self.save()
        print(f"[✓] {person} completed: {task_description}")
    
    def add_tool_tried(self, person, tool, result):
        """Record tool usage"""
        entry = {
            'timestamp': datetime.now().isoformat(),
            'person': person,
            'tool': tool,
            'result': result
        }
        
        self.data['tools_tried'].append(entry)
        self.save()
    
    def add_dead_end(self, person, approach, reason):
        """Record failed attempts to save team time"""
        entry = {
            'timestamp': datetime.now().isoformat(),
            'person': person,
            'approach': approach,
            'reason': reason
        }
        
        self.data['dead_ends'].append(entry)
        self.save()
        print(f"[X] {person} reports dead end: {approach} - {reason}")
    
    def submit_flag(self, person, flag):
        """Submit flag"""
        self.data['flag'] = {
            'flag': flag,
            'submitted_by': person,
            'submitted_at': datetime.now().isoformat()
        }
        self.save()
        print(f"[FLAG] {person} submitted: {flag}")
    
    def print_status(self):
        """Print current status"""
        print("\n" + "="*70)
        print(f"TEAM PROGRESS: {self.challenge_name}")
        print("="*70 + "\n")
        
        # Team members
        print(f"Team Members ({len(self.data['team_members'])}):")
        for member in self.data['team_members']:
            print(f"  - {member['name']} ({member['role']})")
        print()
        
        # Active tasks
        active_tasks = [t for t in self.data['tasks'] if t['status'] == 'in_progress']
        if active_tasks:
            print(f"Active Tasks ({len(active_tasks)}):")
            for task in active_tasks:
                print(f"  - {task['claimed_by']}: {task['task']}")
            print()
        
        # Recent findings
        if self.data['findings']:
            print(f"Recent Findings ({len(self.data['findings'])} total):")
            for finding in self.data['findings'][-5:]:
                time = datetime.fromisoformat(finding['timestamp']).strftime('%H:%M')
                symbol = '[!]' if finding['importance'] == 'critical' else '[*]'
                print(f"  {symbol} [{time}] {finding['finder']}: {finding['finding']}")
            print()
        
        # Dead ends (help others avoid)
        if self.data['dead_ends']:
            print(f"Dead Ends ({len(self.data['dead_ends'])}):")
            for dead in self.data['dead_ends'][-3:]:
                print(f"  ✗ {dead['approach']} - {dead['reason']}")
            print()
        
        # Flag status
        if self.data['flag']:
            print(f"[FLAG FOUND] {self.data['flag']['flag']}")
            print(f"  by {self.data['flag']['submitted_by']}")
        else:
            print("[...] Flag not yet found")
        
        print("\n" + "="*70 + "\n")
    
    def get_next_task(self):
        """Suggest next unclaimed task"""
        # Define standard task checklist
        standard_tasks = [
            'Run initial file assessment',
            'Extract metadata with exiftool',
            'Run binwalk scan',
            'Extract strings',
            'Check LSB with zsteg/stegsolve',
            'Try steghide with common passwords',
            'Analyze hex dump for patterns',
            'Check for file concatenation',
            'Search for encoding (base64/hex)',
            'Deep analysis of embedded files'
        ]
        
        claimed_tasks = [t['task'] for t in self.data['tasks']]
        
        for task in standard_tasks:
            if task not in claimed_tasks:
                return task
        
        return None

# Usage example
if __name__ == "__main__":
    import sys
    
    if len(sys.argv) < 2:
        print("Usage: python3 shared_tracker.py <action> [args]")
        print("\nActions:")
        print("  init <challenge_name>")
        print("  join <your_name> <role>")
        print("  claim <your_name> <task_description>")
        print("  finding <your_name> <finding> [critical|normal]")
        print("  complete <your_name> <task_description> [result]")
        print("  dead <your_name> <approach> <reason>")
        print("  flag <your_name> <flag>")
        print("  status")
        print("  next")
        sys.exit(1)
    
    action = sys.argv[1]
    
    if action == 'init':
        challenge = sys.argv[2]
        tracker = SharedTracker(challenge)
        print(f"[*] Initialized tracker for: {challenge}")
    
    elif action == 'status':
        tracker = SharedTracker('current_challenge')
        tracker.print_status()
    
    elif action == 'join':
        name, role = sys.argv[2], sys.argv[3]
        tracker = SharedTracker('current_challenge')
        tracker.add_team_member(name, role)
    
    elif action == 'claim':
        name, task = sys.argv[2], ' '.join(sys.argv[3:])
        tracker = SharedTracker('current_challenge')
        tracker.claim_task(name, task)
    
    elif action == 'finding':
        name, finding = sys.argv[2], sys.argv[3]
        importance = sys.argv[4] if len(sys.argv) > 4 else 'normal'
        tracker = SharedTracker('current_challenge')
        tracker.add_finding(name, finding, importance)
    
    elif action == 'complete':
        name, task = sys.argv[2], sys.argv[3]
        result = sys.argv[4] if len(sys.argv) > 4 else None
        tracker = SharedTracker('current_challenge')
        tracker.complete_task(name, task, result)
    
    elif action == 'dead':
        name, approach, reason = sys.argv[2], sys.argv[3], sys.argv[4]
        tracker = SharedTracker('current_challenge')
        tracker.add_dead_end(name, approach, reason)
    
    elif action == 'flag':
        name, flag = sys.argv[2], sys.argv[3]
        tracker = SharedTracker('current_challenge')
        tracker.submit_flag(name, flag)
    
    elif action == 'next':
        tracker = SharedTracker('current_challenge')
        next_task = tracker.get_next_task()
        if next_task:
            print(f"[*] Suggested next task: {next_task}")
        else:
            print("[*] All standard tasks claimed. Check status for details.")
```

### Real-time Collaboration Setup

````bash
#!/bin/bash
# setup_collaboration.sh - Set up shared workspace

CHALLENGE_NAME="$1"

if [ -z "$CHALLENGE_NAME" ]; then
    echo "Usage: $0 <challenge_name>"
    exit 1
fi

WORKSPACE="${CHALLENGE_NAME}_workspace"

echo "[*] Setting up collaboration workspace: $WORKSPACE"

# Create directory structure
mkdir -p "$WORKSPACE"/{findings,tools_output,extracted_files,notes,scripts}

# Initialize shared tracker
cd "$WORKSPACE"
python3 /path/to/shared_tracker.py init "$CHALLENGE_NAME"

# Create README
cat > README.md << 'EOF'
# Team Collaboration Workspace

## Quick Commands

### Claim a task:
```bash
python3 shared_tracker.py claim "YourName" "Task description"
````

### Report finding:

```bash
python3 shared_tracker.py finding "YourName" "What you found" [critical|normal]
```

### Mark complete:

```bash
python3 shared_tracker.py complete "YourName" "Task description"
```

### Check status:

```bash
python3 shared_tracker.py status
```

## Directory Structure

- `findings/` - Store evidence of findings here
- `tools_output/` - Save tool outputs here
- `extracted_files/` - Place extracted/carved files here
- `notes/` - Personal notes and analysis
- `scripts/` - Custom scripts for this challenge

## Communication Protocol

1. **Always claim tasks before starting** - prevents duplicate work
2. **Report dead ends immediately** - saves team time
3. **Document all findings with evidence** - save outputs to findings/
4. **Use importance levels** - mark breakthroughs as 'critical'
5. **Update status regularly** - at least every 15 minutes

## Tool Assignment

Check `progress.json` for current assignments and avoid tool conflicts. EOF

# Create quick command aliases

cat > aliases.sh << 'EOF' #!/bin/bash

# Source this file: source aliases.sh

alias tl="python3 shared_tracker.py status" # Team List alias tc="python3 shared_tracker.py claim "$USER"" # Team Claim alias tf="python3 shared_tracker.py finding "$USER"" # Team Finding alias td="python3 shared_tracker.py dead "$USER"" # Team Dead-end alias tn="python3 shared_tracker.py next" # Team Next task

echo "[*] Collaboration aliases loaded:" echo " tl - Show team status" echo " tc - Claim task" echo " tf - Report finding" echo " td - Report dead end" echo " tn - Get next task" EOF

chmod +x aliases.sh

# Create template for tool output

cat > tools_output/TEMPLATE.md << 'EOF'

# Tool Output Template

**Tool:** [tool name] **Run by:** [your name] **Timestamp:** [timestamp] **Command:**

```bash
[exact command used]
```

## Output:

```
[paste output here]
```

## Analysis:

[your interpretation of the output]

## Next Steps:

- [ ] Action item 1
- [ ] Action item 2 EOF

echo echo "[_] Workspace created: $WORKSPACE" echo "[_] Next steps:" echo " 1. cd $WORKSPACE" echo " 2. source aliases.sh" echo " 3. python3 shared_tracker.py join "YourName" "YourRole"" echo " 4. python3 shared_tracker.py status" echo " 5. Start analyzing!"

````

### Communication Best Practices

```python
COMMUNICATION_GUIDELINES = {
    'finding_formats': {
        'breakthrough': "[!] BREAKTHROUGH: Found {what} in {where} using {tool}",
        'clue': "[*] CLUE: {observation} - might indicate {hypothesis}",
        'data': "[+] DATA: Extracted {type} from {source} - saved to {location}",
        'dead_end': "[X] DEAD END: {approach} failed because {reason}",
        'question': "[?] QUESTION: {what} - anyone tried this?",
        'tool_result': "[T] {tool}: {result}",
    },
    
    'priority_levels': {
        'critical': 'Breakthrough finding - likely leads to flag',
        'high': 'Important clue or significant progress',
        'normal': 'Useful information or negative result',
        'low': 'FYI or general observation'
    },
    
    'update_frequency': {
        'active_work': 'Every 10-15 minutes',
        'stuck': 'Immediately when stuck > 30 min',
        'breakthrough': 'Immediately',
        'task_complete': 'As soon as done'
    }
}

def format_finding(finding_type, **kwargs):
    """Format finding message"""
    template = COMMUNICATION_GUIDELINES['finding_formats'].get(finding_type)
    if template:
        return template.format(**kwargs)
    return str(kwargs)

# Examples:
print(format_finding('breakthrough', 
                    what='hidden PNG', 
                    where='LSB of green channel', 
                    tool='zsteg'))

print(format_finding('clue',
                    observation='File size 2x expected',
                    hypothesis='concatenated files or embedded data'))

print(format_finding('dead_end',
                    approach='Steghide with rockyou.txt',
                    reason='wrong file format'))
````

### Parallel Analysis Strategy

```python
def parallel_analysis_plan(file_path, num_team_members):
    """
    Generate parallel work plan for team
    """
    plans = []
    
    # Person 1: Metadata and basic analysis
    plans.append({
        'member': 1,
        'role': 'Metadata Analyst',
        'tasks': [
            f'exiftool -a {file_path} > metadata.txt',
            f'file -b {file_path}',
            f'strings -n 8 {file_path} > strings.txt',
            'Analyze metadata for clues/hints',
            'Document all findings in findings/metadata/'
        ],
        'estimated_time': '10-15 min'
    })
    
    # Person 2: Binary analysis and extraction
    plans.append({
        'member': 2,
        'role': 'Binary Analyst',
        'tasks': [
            f'binwalk {file_path}',
            f'binwalk -e {file_path}',
            f'foremost -t all -i {file_path} -o carved/',
            'Analyze extracted files',
            'Document in findings/binary/'
        ],
        'estimated_time': '15-20 min'
    })
    
    # Person 3: Format-specific tools
    plans.append({
        'member': 3,
        'role': 'Format Specialist',
        'tasks': [
            'Identify specific file type',
            'Run format-specific tools (zsteg/steghide/etc)',
            'Visual/spectral analysis if applicable',
            'Try common passwords if encrypted',
            'Document in findings/format_specific/'
        ],
        'estimated_time': '20-30 min'
    })
    
    # Person 4+: Deep analysis and scripting
    if num_team_members >= 4:
        plans.append({
            'member': 4,
            'role': 'Automation & Deep Analysis',
            'tasks': [
                'Write custom extraction scripts',
                'Statistical analysis (entropy, patterns)',
                'Automated encoding detection',
                'Cross-reference all findings',
                'Document in findings/deep_analysis/'
            ],
            'estimated_time': '30+ min'
        })
    
    print("="*70)
    print(f"PARALLEL ANALYSIS PLAN ({num_team_members} team members)")
    print("="*70 + "\n")
    
    for plan in plans[:num_team_members]:
        print(f"=== MEMBER {plan['member']}: {plan['role']} ===")
        print(f"Estimated time: {plan['estimated_time']}\n")
        print("Tasks:")
        for i, task in enumerate(plan['tasks'], 1):
            print(f"  {i}. {task}")
        print()
    
    print("="*70)
    print("SYNCHRONIZATION POINTS:")
    print("  - 15 min: Quick status update from all members")
    print("  - 30 min: Regroup and share findings")
    print("  - 45 min: If no progress, pivot strategy")
    print("="*70 + "\n")
    
    return plans

# Usage
parallel_analysis_plan('challenge.png', 3)
```

### Master Checklist for Team Leads

```python
#!/usr/bin/env python3
# team_lead_checklist.py

TEAM_LEAD_CHECKLIST = {
    'before_start': [
        'Confirm all team members have necessary tools installed',
        'Set up shared workspace with proper permissions',
        'Initialize shared tracker',
        'Assign roles based on expertise',
        'Brief team on challenge description',
        'Set time expectations and milestones',
        'Establish communication protocol',
    ],
    
    'during_analysis': [
        'Monitor progress every 15 minutes',
        'Prevent duplicate work',
        'Cross-check findings from different members',
        'Identify and resolve blockers quickly',
        'Synthesize information from all sources',
        'Call pivots when approaches aren\'t working',
        'Keep team motivated and on track',
    ],
    
    'when_stuck': [
        'Gather all findings and review',
        'Check if any tools were missed',
        'Review challenge description again',
        'Look for connections between findings',
        'Consider asking for hint',
        'Take short break and approach fresh',
        'Try explaining the problem to each other',
    ],
    
    'before_submission': [
        'Verify flag format',
        'Test flag if possible',
        'Document solution path',
        'Save all evidence',
        'Prepare write-up structure',
    ],
    
    'after_completion': [
        'Debrief with team',
        'Document what worked/didn\'t work',
        'Archive workspace',
        'Share learnings',
        'Update team playbook',
    ]
}

def print_checklist(phase):
    """Print checklist for specific phase"""
    if phase in TEAM_LEAD_CHECKLIST:
        print(f"\n{'='*70}")
        print(f"TEAM LEAD CHECKLIST: {phase.upper().replace('_', ' ')}")
        print(f"{'='*70}\n")
        
        for i, item in enumerate(TEAM_LEAD_CHECKLIST[phase], 1):
            print(f"  [ ] {i}. {item}")
        
        print(f"\n{'='*70}\n")

# Usage
if __name__ == "__main__":
    import sys
    
    if len(sys.argv) > 1:
        print_checklist(sys.argv[1])
    else:
        print("Available checklists:")
        for phase in TEAM_LEAD_CHECKLIST.keys():
            print(f"  - {phase}")
        print("\nUsage: python3 team_lead_checklist.py <phase>")
```

---

## Important Related Topics for Practical Methodology

**Automated Workflow Systems** - CI/CD-style pipelines for CTF challenge analysis, automated tool chaining

**Evidence Chain Management** - Forensically sound evidence collection and chain-of-custody for competition integrity

**Knowledge Base Development** - Building personal/team wikis of techniques, tool usage, and past solutions

**Challenge Difficulty Estimation** - Heuristics for quickly assessing challenge difficulty to optimize time allocation

**Post-Competition Analysis** - Structured review methodology for learning from both solved and unsolved challenges

**Tool Development Methodology** - When and how to write custom tools vs. using existing solutions