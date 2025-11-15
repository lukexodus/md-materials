# Image

## Rationale for the Design of JPEG

### 1. Goal: Balance Between Quality and Compression

JPEG was designed to **efficiently compress photographic images** — not line art or text — by exploiting how **the human visual system (HVS)** perceives brightness and color.
Humans are far more sensitive to changes in brightness than to small color variations.
Thus, JPEG discards information we hardly notice while keeping what’s visually essential.

---

### 2. Why Each Design Choice Exists

#### **a. RGB → YCbCr Color Space Conversion**

**Why:**
The eye perceives brightness (luminance, Y) much more sharply than color (chrominance, Cb, Cr).
**How:**
JPEG converts RGB to YCbCr, then **downsamples** the chroma channels (e.g., 4:2:0), reducing data by half or more with minimal perceptual loss.

---

#### **b. 8×8 Block Division**

**Why:**
A small, fixed block size enables localized processing and fast computation.
**How:**
Each block is transformed and compressed independently, balancing performance and image quality.
Larger blocks would improve compression but risk visible “blocking artifacts.” Smaller blocks increase overhead.

---

#### **c. Discrete Cosine Transform (DCT)**

**Why:**
DCT efficiently represents image energy — most of it ends up concentrated in a few low-frequency coefficients.
**How:**
Each 8×8 block of pixel values is transformed into 64 frequency coefficients.
The DC term encodes the overall brightness; AC terms encode details.

---

#### **d. Quantization**

**Why:**
Human vision is less sensitive to small high-frequency variations.
**How:**
Quantization divides each coefficient by a value from the **quantization table (DQT)** and rounds it off, discarding subtle high-frequency data.
This is the main **lossy** step in JPEG compression.

---

#### **e. Zig-Zag Ordering**

**Why:**
After quantization, most non-zero coefficients cluster in the low-frequency region.
**How:**
The **zig-zag pattern** reorders coefficients from low to high frequency, maximizing runs of zeros for efficient encoding.

---

#### **f. Entropy Coding (Huffman / Arithmetic)**

**Why:**
To remove statistical redundancy.
**How:**
JPEG uses **Huffman coding** (via `DHT` tables) or optionally arithmetic coding to represent frequent symbols (like zero runs) with shorter bit sequences.

---

#### **g. Progressive and Baseline Modes**

**Why:**
To support flexibility in viewing and transmission.
**How:**

* **Baseline JPEG** sends data in a single scan — simple and fast.
* **Progressive JPEG** sends low-quality preview data first, refining detail with later passes — useful for slow networks.

---

#### **h. Optional Features:**

* **Restart markers:** Allow decoding to resume after errors.
* **ICC color profiles:** Ensure consistent color across devices.
* **EXIF/metadata:** Store camera and orientation data.

---

### 3. Analogy

Think of JPEG like a painter simplifying a photograph:

* Converts colors (RGB → YCbCr) to focus on tone and shade.
* Works on small tiles (8×8 blocks).
* Emphasizes broad strokes (low frequencies) and softens fine grain (high frequencies).
* Signs the work with a compressed signature (entropy coding).

---

**Summary**

* JPEG’s design reflects a deep understanding of human vision and data efficiency.
* Each stage (color conversion, DCT, quantization, entropy coding) serves to reduce data while minimizing perceived loss.
* The result is a compact yet visually faithful image — ideal for storage, web, and photography.


---

## **Spatial Domain vs Frequency Domain in Images**

---

### **Spatial Domain**

**Definition:**
The **spatial domain** refers to the image as we normally see it — a grid of pixels, where each pixel has a brightness or color value.

**Characteristics**

* Each pixel value directly represents light intensity at that position.
* Editing in the spatial domain affects pixels individually (e.g., brightening, blurring, sharpening).
* Example operations: convolution filters, cropping, brightness adjustment.

**Analogy**
The spatial domain is like a **map of a city** where each building’s height represents the brightness of that pixel — you see the actual layout directly.

---

### **Frequency Domain**

**Definition:**
The **frequency domain** represents an image in terms of **how brightness changes across space**, instead of direct pixel values.

* **Low frequencies:** represent smooth, gradual changes in brightness (large areas of uniform color).
* **High frequencies:** represent rapid changes, edges, or fine details.

**How It Works**

* Transformation (like **Discrete Cosine Transform, DCT**) converts an 8×8 block of pixels from spatial to frequency domain.
* Each coefficient corresponds to a specific spatial frequency in the block.

**Analogy**
The frequency domain is like a **musical score** for an image:

* The DC term is the main “bass note” (average brightness).
* AC terms are higher notes representing texture and detail.
* Compression removes small high-frequency notes (fine detail) the human eye hardly notices.

---

### **Why JPEG Uses Frequency Domain**

* **Energy compaction:** Most visually important information is concentrated in low-frequency coefficients.
* **Efficient compression:** High-frequency coefficients (edges/noise) can be quantized heavily or discarded without large visible loss.
* **Entropy coding:** Zig-zag ordering groups zeros for better Huffman compression.

---

**Summary**

* **Spatial domain:** Pixels directly define brightness/color.
* **Frequency domain:** Coefficients define **how brightness changes** across pixels.
* JPEG transforms spatial → frequency domain to exploit human vision characteristics and compress efficiently.

---

## JPEG Internal Segments Explained

### DQT — Define Quantization Table

**Purpose:**
Specifies one or more *quantization tables* used to reduce the precision of the DCT (Discrete Cosine Transform) coefficients during compression.

**Explanation:**

* Quantization is the step that discards less visually important information to achieve compression.
* The DQT segment contains up to four tables (numbered 0–3), each holding 64 quantization values for an 8×8 block.
* Lower quantization values preserve more detail (higher quality), while higher values cause stronger compression (more artifacts).

**Analogy:**
Think of DQT like a painter deciding which colors to blend and which details to skip—keeping the essence while reducing unnecessary complexity.

---

### DHT — Define Huffman Table

**Purpose:**
Defines the *Huffman coding tables* used for lossless entropy encoding of the quantized DCT coefficients.

**Explanation:**

* Huffman coding assigns shorter binary codes to more frequent symbols and longer codes to rare ones.
* The DHT segment stores these symbol-length mappings for both DC and AC components of image blocks.
* Typically, JPEG files include separate Huffman tables for luminance (Y) and chrominance (Cb, Cr).

**Analogy:**
DHT is like a shorthand system — common words get shorter abbreviations so your notes take up less space.

---

### SOS — Start of Scan

**Purpose:**
Marks the beginning of the actual *compressed image data*.

**Explanation:**

* SOS indicates which components (e.g., Y, Cb, Cr) are included in this scan and which quantization and Huffman tables apply.
* After the SOS marker, the entropy-coded data follows until an End of Image (EOI) marker is reached.

**Analogy:**
SOS is like the director’s cue: “Action!” — from this point, the movie (actual compressed image stream) begins.

---

**Summary**

* **DQT:** Controls how much detail is discarded (quantization).
* **DHT:** Defines how data is compressed (Huffman coding).
* **SOS:** Marks where actual image data starts (scan begins).


---

## DCT Coefficients

### What They Are

**DCT coefficients** (Discrete Cosine Transform coefficients) represent the frequency components of an image block after applying the DCT during JPEG compression.

JPEG divides the image into 8×8 pixel blocks, then transforms each block from the **spatial domain** (pixel brightness) into the **frequency domain** (how brightness changes). The result is 64 DCT coefficients per block.

---

### Structure of DCT Coefficients

Each 8×8 block produces coefficients $C(u,v)$, where:

$$
C(u,v) = \frac{1}{4} \alpha(u) \alpha(v)
\sum_{x=0}^{7} \sum_{y=0}^{7}
f(x,y)
\cos\left[\frac{(2x+1)u\pi}{16}\right]
\cos\left[\frac{(2y+1)v\pi}{16}\right]
$$

* $f(x,y)$ — pixel intensity at position $(x,y)$
* $\alpha(u), \alpha(v)$ — normalization factors (1/√2 for 0, else 1)

---

### Types of Coefficients

* **DC coefficient ($C(0,0)$):**
  Represents the *average brightness* of the block.
  Usually large in magnitude.

* **AC coefficients ($C(u,v)$ where $u,v ≠ 0$):**
  Represent *high-frequency details* (edges, textures, noise).
  Often small or zero after quantization.

---

### Quantization and Compression

1. The DCT coefficients are divided by values in the **quantization table (DQT)**.
   This reduces precision for high-frequency components that the human eye barely notices.
2. After quantization, most AC coefficients become **zero**.
3. The remaining non-zero values are **zig-zag scanned** and **entropy encoded (using DHT)** for compact storage.

---

### Analogy

Think of the DCT as converting an image into “ingredients” of brightness changes:

* The **DC coefficient** is like the base flavor (average color).
* The **AC coefficients** are like spices (fine variations).
  Compression is like deciding which spices are essential and which can be skipped.

---

**Summary**

* DCT coefficients describe how pixel brightness varies within each 8×8 block.
* The DC term shows the block’s average brightness; AC terms show detail.
* After quantization, many coefficients become zero, allowing efficient compression without large visible loss.

---

## Image Formats

Let’s go over **image formats** — what they are, how they differ, and when to use each one.

---

### **Overview**

An **image format** defines *how* image data (pixels, colors, compression, metadata) is stored inside a file.
It determines **file size**, **image quality**, **transparency support**, **metadata embedding**, and **compatibility**.

---

#### **Two Main Categories**

| Category            | Description                                                | Example Formats                 |
| ------------------- | ---------------------------------------------------------- | ------------------------------- |
| **Raster (bitmap)** | Stores actual pixels — best for photos and detailed images | JPEG, PNG, GIF, BMP, TIFF, WebP |
| **Vector**          | Stores shapes, paths, and text — infinitely scalable       | SVG, EPS, PDF (vector layer)    |

---

### **Common Raster Formats**

#### **1. JPEG / JPG (Joint Photographic Experts Group)**

**Purpose:**
Most common for *photographs and realistic images.*

**Key traits:**

* **Lossy compression** → smaller file, but some quality loss
* No transparency
* Supports **EXIF/IPTC/XMP metadata**
* Best for: web photos, camera images

**Analogy:**
JPEG is like a photo printed on glossy paper — beautiful but can’t be edited repeatedly without losing clarity.

**Example use:**
Photographs, social media posts, digital cameras.

---

#### **2. PNG (Portable Network Graphics)**

**Purpose:**
Designed for *lossless compression* and *transparency.*

**Key traits:**

* **Lossless compression** → preserves exact pixels
* Supports **alpha transparency (opacity levels)**
* Larger size than JPEG for photos
* Best for: graphics, screenshots, UI icons, logos

**Analogy:**
PNG is like a *glass sticker* — clean, precise, and can sit transparently over any background.

---

#### **3. GIF (Graphics Interchange Format)**

**Purpose:**
Used for *animations and simple graphics.*

**Key traits:**

* Supports **only 256 colors (8-bit)**
* Supports **simple animation frames**
* Lossless for its limited palette
* Transparency only in **1-bit** (fully transparent or not)

**Analogy:**
GIF is like a *flipbook* — simple frames shown quickly to create movement.

---

#### **4. BMP (Bitmap Image File)**

**Purpose:**
Microsoft’s early format for raw pixel data.

**Key traits:**

* **Uncompressed or lightly compressed** → large file size
* High quality but inefficient
* No transparency (standard BMP)
* Rarely used today except for low-level Windows tasks

**Analogy:**
BMP is like a *pixel-for-pixel blueprint* — exact but heavy and outdated.

---

#### **5. TIFF / TIF (Tagged Image File Format)**

**Purpose:**
Used in *publishing, scanning, and printing* industries.

**Key traits:**

* Supports **lossless or lossy compression**
* Supports **layers**, **multiple pages**, and **metadata**
* Excellent color depth (up to 16-bit per channel)
* Large file size
* Used in photography, medical imaging, and archiving

**Analogy:**
TIFF is like a *master print negative* — detailed, heavy, and used before final publication.

---

#### **6. WebP**

**Purpose:**
Modern format by Google for the *web.*

**Key traits:**

* Supports **both lossy and lossless compression**
* Supports **transparency and animation**
* **Much smaller** than JPEG/PNG at the same visual quality
* Supported by all major browsers

**Analogy:**
WebP is like a *digital hybrid* — as light as JPEG, as clear as PNG, and as flexible as GIF.

---

#### **7. HEIF / HEIC (High Efficiency Image Format / Container)**

**Purpose:**
New-generation format used by Apple (iPhone) and modern devices.

**Key traits:**

* Uses **HEVC (H.265)** compression
* 50% smaller than JPEG with same quality
* Supports **depth maps, transparency, burst photos, and live images**
* Metadata support: **EXIF and XMP**

**Analogy:**
HEIF is like a *smart suitcase* — fits more data in the same space.

---

### **Common Vector Formats**

#### **1. SVG (Scalable Vector Graphics)**

**Purpose:**
For logos, icons, and illustrations on web or apps.

**Key traits:**

* **XML-based** — text-editable and scalable
* Small file size
* Can include animations and interactivity
* Not suited for photos

**Analogy:**
SVG is like *mathematical art* — it redraws itself perfectly at any size.

---

#### **2. EPS (Encapsulated PostScript)**

**Purpose:**
Used for professional publishing and printing.

**Key traits:**

* Vector-based (PostScript language)
* Excellent scalability
* Often replaced by PDF or SVG for modern workflows

**Analogy:**
EPS is like a *blueprint drawing file* for print designers.

---

#### **3. PDF (Portable Document Format)**

**Purpose:**
Can contain **vector + raster** images, plus text.

**Key traits:**

* Preserves exact layout across systems
* Used for **print-ready graphics**
* Can include **metadata and color profiles**

**Analogy:**
PDF is like a *sealed digital paper* — what you see is exactly what prints.

---

### **Comparison Summary**

| Format        | Compression      | Transparency | Animation | Metadata | Typical Use             |
| ------------- | ---------------- | ------------ | --------- | -------- | ----------------------- |
| **JPEG**      | Lossy            | No           | No        | Yes      | Photos                  |
| **PNG**       | Lossless         | Yes          | No        | Yes      | Logos, UI, web graphics |
| **GIF**       | Lossless (8-bit) | 1-bit        | Yes       | Limited  | Animations              |
| **BMP**       | None             | No           | No        | Limited  | Raw bitmaps             |
| **TIFF**      | Lossless/Lossy   | Optional     | No        | Yes      | Archival, scanning      |
| **WebP**      | Lossy/Lossless   | Yes          | Yes       | Yes      | Web media               |
| **HEIF/HEIC** | Lossy/Lossless   | Yes          | Yes       | Yes      | Smartphones             |
| **SVG**       | Vector           | Yes          | Yes       | Yes      | Logos, icons            |
| **PDF**       | Vector + Raster  | Yes          | No        | Yes      | Documents, print        |

---

### **Analogy Summary**

| Format   | Analogy                                              |
| -------- | ---------------------------------------------------- |
| **JPEG** | Glossy printed photo — nice but degrades with copies |
| **PNG**  | Transparent glass sticker — clean and precise        |
| **GIF**  | Flipbook — simple animations                         |
| **BMP**  | Pixel-for-pixel blueprint — heavy, uncompressed      |
| **TIFF** | Master print negative — professional and detailed    |
| **WebP** | Digital hybrid — efficient and modern                |
| **HEIF** | Smart suitcase — compact and advanced                |
| **SVG**  | Mathematical art — scalable infinitely               |
| **PDF**  | Sealed digital paper — exact reproduction            |

---

## Image Metadata

---

### **Overview**

| Type     | Full Name                                      | Main Purpose                           | Typical Use                                  | Format                   |
| -------- | ---------------------------------------------- | -------------------------------------- | -------------------------------------------- | ------------------------ |
| **EXIF** | Exchangeable Image File Format                 | Technical data from the camera/device  | Camera settings, date/time, GPS, orientation | Binary (structured tags) |
| **IPTC** | International Press Telecommunications Council | Descriptive info for journalists/media | Title, caption, author, copyright            | Key-value text fields    |
| **XMP**  | Extensible Metadata Platform                   | Modern, flexible metadata standard     | Combines EXIF + IPTC + custom data           | XML (human-readable)     |

---

### **1. EXIF (Exchangeable Image File Format)**

**Purpose:**
Stores *technical and contextual* data about how the image was captured.

**Common fields:**

* Camera make and model (`Make`, `Model`)
* Exposure time (`ExposureTime`)
* F-number (`FNumber`)
* ISO speed (`ISOSpeedRatings`)
* Date and time taken (`DateTimeOriginal`)
* GPS location (`GPSLatitude`, `GPSLongitude`)
* Orientation (`Orientation`)
* Thumbnail preview

**Analogy:**
Think of EXIF as a *digital “black box”* of the camera — it automatically records what the device did and how.

**Example (simplified):**

```
Camera Model: Nikon D3500
Exposure Time: 1/250 sec
Aperture: f/5.6
ISO: 200
Date Taken: 2025-10-22 13:45:10
GPS: 14.5995° N, 120.9842° E
```

---

### **2. IPTC (International Press Telecommunications Council)**

**Purpose:**
Stores *human-created descriptive information* — originally for news agencies and media workflows.

**Common fields:**

* Title (`ObjectName`)
* Description or caption (`Caption-Abstract`)
* Photographer (`By-line`)
* Copyright notice (`CopyrightNotice`)
* Keywords (`Keywords`)
* City, country, location
* Credit, source, contact info

**Analogy:**
IPTC is like a *newspaper caption card* — added by editors, photographers, or agencies to describe and credit the photo.

**Example (simplified):**

```
Title: Sunrise over Manila Bay
Photographer: Juan Dela Cruz
Copyright: © 2025 Juan Dela Cruz
Keywords: Manila, sunrise, Philippines
```

---

### **3. XMP (Extensible Metadata Platform)**

**Purpose:**
Developed by Adobe — it’s a flexible and extensible way to store *any* metadata, including EXIF and IPTC equivalents.

**Key traits:**

* Uses **XML syntax**
* Can store **custom namespaces** (for example, Lightroom edits, Photoshop adjustments)
* Supported by many file types: JPEG, PNG, PDF, PSD, MP4, etc.

**Analogy:**
XMP is like a *digital notebook* attached to the file — you can include standard info plus your own custom sections.

**Example (snippet in XML):**

```xml
<x:xmpmeta xmlns:x="adobe:ns:meta/">
  <rdf:Description xmlns:dc="http://purl.org/dc/elements/1.1/">
    <dc:title><rdf:Alt><rdf:li xml:lang="x-default">Sunrise over Manila Bay</rdf:li></rdf:Alt></dc:title>
    <dc:creator><rdf:Seq><rdf:li>Juan Dela Cruz</rdf:li></rdf:Seq></dc:creator>
  </rdf:Description>
</x:xmpmeta>
```

---

### **How They Coexist**

Most modern images (like JPEGs) may include **all three**:

* **EXIF**: recorded by the camera
* **IPTC**: added later by editors
* **XMP**: manages or replaces the two with a modern XML-based version

In many workflows, **XMP mirrors or overrides IPTC and EXIF** fields for compatibility.

---

### **Viewing or Editing Metadata**

**Tools (cross-platform):**

* `exiftool` — most powerful CLI tool

  ```bash
  exiftool photo.jpg
  ```
* Adobe Photoshop / Lightroom (Metadata panel)
* Windows: Right-click → Properties → Details
* macOS: Preview → Tools → Show Inspector → Info tab
* Online viewers: exifmeta.com, metapicz.com

---

### **Security Note**

Metadata may expose:

* Exact **GPS coordinates** (if location tagging is on)
* **Date/time** and **device info**
* Personal or organizational details in IPTC/XMP

So before sharing photos publicly, it’s wise to **strip metadata** using:

```bash
exiftool -all= photo.jpg
```

---

### **Summary Analogy**

| Concept | Analogy                                                        |
| ------- | -------------------------------------------------------------- |
| EXIF    | Automatic “black box” recorder from the camera                 |
| IPTC    | Manual “caption card” from the editor or journalist            |
| XMP     | Digital “metadata notebook” — flexible, modern, and extendable |

---

## Image Channels

In the context of images, a **channel** refers to a single component or layer that contains specific information about the image's pixels. Most images are composed of multiple channels that, when combined, produce the full color or grayscale image.

### Common types of image channels

1. **Color Images (RGB)**:
   - **Red channel**: Contains intensity information for the red component.
   - **Green channel**: Contains intensity information for the green component.
   - **Blue channel**: Contains intensity information for the blue component.
   
   When these three channels are combined, they produce the full-color image. Each pixel's color is determined by the combination of red, green, and blue intensities.

2. **Grayscale Images**:
   - Typically have a **single channel** representing luminance or brightness.
   
3. **Other Color Spaces**:
   - For example, **CMYK** (Cyan, Magenta, Yellow, Key/Black) images have four channels.
   - **HSV** (Hue, Saturation, Value) images have three channels.

**Additional context**

- **Channels** are stored as separate matrices (2D arrays) of pixel values within an image data structure.
- The **number of channels** depends on the image type (e.g., RGB has 3 channels, RGBA has 4, grayscale has 1).
- In image processing, manipulating individual channels can be useful for tasks like color correction, filtering, or feature extraction.

**Summary**

In essence, a **channel** in images is a single layer of pixel data that contributes to the overall appearance of the image, often representing a specific color component or a specific aspect like luminance.

---

## Image Chunks

### **Understanding “Chunks” in Image Formats**

A **chunk** is a structured block of data inside an image file that contains information such as:

* Image pixels
* Color information
* Metadata (like EXIF)
* Software notes or custom data

Each chunk usually has:

```
[Length] [Type] [Data] [CRC]
```

For example, a PNG file is composed of many such chunks stacked sequentially.

---

### **1. PNG Chunks**

The PNG format is a **chunk-based format** — meaning, everything inside it (pixels, metadata, etc.) is stored as labeled chunks.

#### **Structure of a PNG File**

```
Signature (8 bytes)
┌────────────┬──────────────┬──────────────┐
│ IHDR chunk │ Other chunks │ IEND chunk   │
└────────────┴──────────────┴──────────────┘
```

Each **chunk** follows:

```
4 bytes → Length
4 bytes → Type (name like IHDR, IDAT)
N bytes → Data
4 bytes → CRC (error checking)
```

---

#### **Two Types of Chunks**

| Type                 | Meaning                                 | Importance                        |
| -------------------- | --------------------------------------- | --------------------------------- |
| **Critical chunks**  | Required for displaying the image       | Must be present                   |
| **Ancillary chunks** | Optional — for metadata, comments, etc. | Can be safely ignored by decoders |

---

#### **Critical Chunks (Must-have)**

| Chunk    | Description                                               |
| -------- | --------------------------------------------------------- |
| **IHDR** | Header — image width, height, bit depth, color type, etc. |
| **PLTE** | Palette — color table (only for indexed color images)     |
| **IDAT** | Image data — the actual compressed pixel data             |
| **IEND** | Marks end of PNG file                                     |

---

#### **Ancillary (Optional / “Unused”) Chunks**

These chunks aren’t needed to render the image — hence often referred to as **unused** or **non-critical**.
They can hold metadata, color info, comments, or custom data.

| Chunk             | Purpose                                       | Notes                                |
| ----------------- | --------------------------------------------- | ------------------------------------ |
| **tEXt**          | Plain text metadata (`Keyword=Value`)         | e.g. “Author=Shiiro”                 |
| **zTXt**          | Compressed text metadata                      | Same as tEXt but compressed          |
| **iTXt**          | International text (UTF-8) + language support | Replaces tEXt/zTXt                   |
| **tIME**          | Last modification time                        | Not always used                      |
| **pHYs**          | Pixel density or aspect ratio info            | Optional for display scaling         |
| **sRGB**          | Specifies the standard RGB color space        | Helps consistent color rendering     |
| **gAMA**          | Gamma correction data                         | Adjusts brightness perception        |
| **cHRM**          | Chromaticity data (color calibration)         | Rarely used directly                 |
| **iCCP**          | Embedded ICC color profile                    | Color management (used in print/web) |
| **bKGD**          | Background color suggestion                   | Ignored by most viewers              |
| **hIST**          | Histogram of palette usage                    | Optional and often unused            |
| **tRNS**          | Transparency data                             | Used only for certain image types    |
| **sPLT**          | Suggested palette                             | Optional for non-indexed images      |
| **eXIf**          | Embedded EXIF metadata                        | Added for camera/photos support      |
| **iDOT** (custom) | Custom chunk (non-standard)                   | Used by apps for proprietary data    |

**Unused chunks** usually refer to any **non-critical chunk not interpreted** by a particular viewer.
They stay inside the file but are ignored during display.

---

#### **Example: PNG Chunk Sequence**

```
IHDR
sRGB
gAMA
pHYs
tIME
IDAT
tEXt
IEND
```

Here:

* Only **IHDR**, **IDAT**, and **IEND** are required.
* Others (like `sRGB`, `tIME`, `tEXt`) are **ancillary** — sometimes unused by software.

---

#### **Custom / Unknown Chunks**

* Developers can add **private chunks**, e.g. `vpAg`, `meTa`, `faCe`.
* The **case** of the letters in the chunk name indicates its type.

| Letter Position | Meaning                                      |
| --------------- | -------------------------------------------- |
| 1st             | Uppercase → critical, lowercase → ancillary  |
| 2nd             | Uppercase → public, lowercase → private      |
| 3rd             | Reserved (should be uppercase)               |
| 4th             | Uppercase → safe to copy, lowercase → unsafe |

**Example:**
`tEXt` → ancillary, public, safe to copy.
`faCe` → ancillary, private, unsafe to copy.

---

### **2. JPEG Segments (for comparison)**

JPEG doesn’t use “chunks” but similar **markers** called **segments**.
Each starts with `0xFF` followed by a marker code.

| Marker              | Description       | Optional                |
| ------------------- | ----------------- | ----------------------- |
| `SOI`               | Start of Image    | Required                |
| `APP0`              | JFIF header       | Common                  |
| `APP1`              | EXIF or XMP data  | Optional                |
| `APP2`              | ICC color profile | Optional                |
| `DQT`, `DHT`, `SOS` | Image data        | Required                |
| `COM`               | Comment segment   | Optional (often unused) |
| `EOI`               | End of Image      | Required                |

Unused JPEG segments (like `COM` or `APPn` not recognized) are usually **skipped** by viewers.

---

### **3. GIF and WebP Chunks**

### **GIF**

GIF files have “blocks” instead of chunks:

* Header, Logical Screen Descriptor
* Global Color Table
* Image Descriptors
* Extension Blocks (like comments, application data)

Unused ones: **Comment Extension Block**, **Application Extension** (custom data).

#### **WebP**

WebP uses **RIFF** container chunks:

```
RIFF ('WEBP')
 ├─ VP8 / VP8L / VP8X (image data)
 ├─ EXIF / XMP (metadata)
 └─ ALPH / ANIM / ANMF (transparency or animation)
```

Non-critical chunks (like EXIF or XMP) are *optional* and can be removed without affecting rendering.

---

### **4. Why Unused Chunks Matter**

**Pros:**

* Can store metadata, editing history, software info
* Extensible for new features (e.g. HDR data)

**Cons:**

* Increase file size
* May leak sensitive info (metadata)
* Some apps remove them for optimization

---

### **5. Viewing Chunks**

You can inspect them using:

**Command line:**

```bash
pngcheck -v image.png
```

or

```bash
exiftool -v image.png
```

**Example output:**

```
Chunk IHDR at offset 0x0000: 1920x1080, 8-bit/color RGB
Chunk sRGB at offset 0x0025: rendering intent 0
Chunk tIME at offset 0x0045: 2025-10-22 13:02:55
Chunk IDAT at offset 0x0060: 8192 bytes
Chunk IEND at offset 0x2040
```

---

### **Analogy**

Think of an image file like a **shipping box**:

* **Critical chunks** = the product itself
* **Ancillary chunks** = stickers, manuals, or receipts — optional but helpful
* **Unused chunks** = extra labels your customer doesn’t read — they’re ignored but still in the box

---

## Image-related Concepts

---

### **Global Color Table in GIF**

A **Global Color Table (GCT)** is a palette of colors stored near the beginning of a GIF file.
Since GIF supports only **256 colors (8-bit indexed)**, each pixel in the image refers to one of the colors in this table.

**Key points**

* Defined in the **Logical Screen Descriptor** section of the GIF.
* Applies to **all frames** in the GIF if a **Local Color Table (LCT)** is not provided.
* Each entry in the table stores a color as **RGB (Red, Green, Blue)**, typically 3 bytes (1 byte per channel).
* The table size is determined by `2^(N+1)` where `N` is a 3-bit value from the descriptor.

**Analogy**
The GCT is like a shared “paint palette” that all GIF frames can borrow colors from.

---

### **ICC Color Profile in JPEG and PNG**

An **ICC profile (International Color Consortium profile)** describes *how colors should appear* on a given device (camera, monitor, printer).
It ensures **color consistency** across different devices.

#### **In JPEG**

* Stored in the **APP2 (Application Marker 2)** segment.
* Segment header: `ICC_PROFILE`
* Can span multiple APP2 segments if large.
* Used for accurate color reproduction in printing and web rendering.

#### **In PNG**

* Stored in the **iCCP (ICC Profile)** chunk.
* The chunk contains:

  1. Profile name (string)
  2. Compression method (usually 0 = deflate)
  3. Compressed ICC profile data
* Can coexist with `sRGB` or `gAMA` chunks, though `iCCP` takes precedence.

**Analogy**
An ICC profile is like a “translator” that ensures the red you see on your monitor looks the same when printed or displayed elsewhere.

---

### **HDR Data (High Dynamic Range Data)**

**HDR (High Dynamic Range)** represents image data with a **wider range of brightness and color** than standard images (SDR, Standard Dynamic Range).

#### **Standard Dynamic Range (SDR)**

* Typically uses **8 bits per channel** (256 brightness levels per color).
* Cannot capture extreme brightness or deep shadows simultaneously.

#### **High Dynamic Range (HDR)**

* Uses **10-bit, 12-bit, or 16-bit** channels (up to 65,536 brightness levels).
* Stores **luminance** and **color intensity** more precisely.
* Preserves detail in both highlights and shadows.
* Common HDR formats:

  * **HDR / Radiance (.hdr, .pic)** — used for light maps
  * **EXR (.exr)** — Industrial Light & Magic’s format for film
  * **HEIF/HEIC** — supports HDR metadata
  * **JPEG XL** — includes HDR and wide color gamut support
  * **AVIF** — based on AV1 codec, supports HDR

**Analogy**
HDR is like seeing the world through your eyes instead of through an old camera — your eyes adjust to both bright sunlight and dark shade at once.

---

**Summary**

| Concept                      | Purpose                                    | Where Stored                          | Bit Depth / Scope                  |
| ---------------------------- | ------------------------------------------ | ------------------------------------- | ---------------------------------- |
| **Global Color Table (GIF)** | Palette of up to 256 shared colors         | GIF header                            | 8-bit indexed                      |
| **ICC Profile (JPEG, PNG)**  | Color translation for consistent rendering | JPEG: APP2 segment<br>PNG: iCCP chunk | Varies (depends on device profile) |
| **HDR Data**                 | Extended brightness and color range        | HDR, EXR, HEIF, JPEG XL, AVIF         | 10–16 bit per channel              |


---

### **Pixel Density or Aspect Ratio Information**

**Chunk/Segment:** `pHYs` (PNG)
**Purpose:** Indicates the **physical pixel density** or intended **aspect ratio** of the image.

**Details**

* Contains pixels-per-unit values:

  * `Pixels per unit, X axis`
  * `Pixels per unit, Y axis`
  * `Unit specifier` (0 = unspecified, 1 = meter)
* Used to scale or print images at the correct physical size.

**Example**

```
pHYs: 2835 x 2835 pixels/meter  (≈72 DPI)
```

**Analogy**
This is like telling a printer how “tightly” to pack pixels — similar to specifying the dots-per-inch (DPI) of a print.

---

### **Specifies the Standard RGB Color Space**

**Chunk/Segment:** `sRGB` (PNG)
**Purpose:** Declares that the image uses the **standard RGB color space**, which defines how red, green, and blue values should appear.

**Details**

* Contains one byte: **rendering intent**, describing how colors should be adjusted when displayed.
* Typical rendering intents:

  * 0 = Perceptual
  * 1 = Relative colorimetric
  * 2 = Saturation
  * 3 = Absolute colorimetric

**Function**
When present, it overrides or simplifies color management by signaling:
“This image conforms to the sRGB standard; display it accordingly.”

**Analogy**
`sRGB` is like a universal “language setting” for colors — it ensures your reds and blues look the same across most screens.

---

### **Gamma Correction Data**

**Chunk/Segment:** `gAMA` (PNG)
**Purpose:** Describes how to adjust brightness so that the image appears consistently on different monitors.

**Details**

* Stores a single integer: **gamma × 100,000**.
  Example: `gAMA = 45455` → actual gamma = 0.45455.
* The gamma value defines how input pixel brightness translates to output luminance.

**Function**
Corrects nonlinear brightness response between displays and encoded image data.

**Analogy**
If brightness is like sound volume, gamma correction ensures that turning up brightness affects all tones evenly — not just shadows or highlights.

---

### **Chromaticity Data (Color Calibration)**

**Chunk/Segment:** `cHRM` (PNG)
**Purpose:** Specifies the **precise chromaticity coordinates** (x, y) of the red, green, blue primaries and the white point used to encode the image.

**Details**

* Contains 8 pairs of 4-byte integers (scaled by 100,000):

  * `white_point_x`, `white_point_y`
  * `red_x`, `red_y`
  * `green_x`, `green_y`
  * `blue_x`, `blue_y`
* Helps color-managed systems reproduce colors accurately across calibrated devices.

**Function**
Used mostly in scientific or professional workflows where exact color matching is required.

**Analogy**
`cHRM` is like a detailed recipe specifying the exact “ingredients” of each color — ensuring your red on one monitor is the same precise hue on another.

---

**Summary**

| Metadata                         | Identifier | Purpose                                   | Analogy                              |
| -------------------------------- | ---------- | ----------------------------------------- | ------------------------------------ |
| **Pixel density / aspect ratio** | `pHYs`     | Defines image resolution or print scaling | Packing density of pixels (like DPI) |
| **Standard RGB color space**     | `sRGB`     | Declares use of the sRGB color model      | Universal color language             |
| **Gamma correction**             | `gAMA`     | Adjusts brightness for consistent display | Balances tone response               |
| **Chromaticity data**            | `cHRM`     | Specifies color calibration coordinates   | Recipe for exact color composition   |


# Audio

---

## **Time-Domain vs Frequency-Domain in Audio**

---

### **Time-Domain**

**Definition:**
The **time-domain** represents audio as a **signal varying over time**.

* Each sample corresponds to the **amplitude of the sound wave** at a specific instant.
* Displayed as a waveform: amplitude (y-axis) vs. time (x-axis).

**Characteristics**

* Shows loudness and duration clearly.
* Does not directly reveal the pitches or harmonic content.
* Editing in the time domain: volume adjustment, trimming, adding effects.

**Analogy**
Time-domain is like reading a **speech transcript with volume annotations** — you see exactly what happens at each moment.

---

### **Frequency-Domain**

**Definition:**
The **frequency-domain** represents audio in terms of **its constituent frequencies** (pitches) rather than time.

* Transformations like **Fourier Transform (FT) or Short-Time Fourier Transform (STFT)** convert time signals into frequency spectra.
* Each value shows **amplitude or energy** at a specific frequency.

**Characteristics**

* Reveals **pitch, harmonics, and timbre**.
* Editing in the frequency domain: equalization, filtering, spectral noise reduction.

**Analogy**
Frequency-domain is like a **musical score of the sound** — you see which notes are played and how loud they are, but not exactly when in time (unless using STFT).

---

### **Why Frequency Domain Matters**

* Humans perceive sound primarily by frequency (pitch and timbre).
* Compression (MP3, AAC) relies on frequency-domain representation to remove inaudible components.
* Signal processing like filters, reverb, or pitch correction works efficiently in frequency domain.

---

**Summary**

* **Time-domain:** Amplitude over time; shows loudness and temporal changes.
* **Frequency-domain:** Amplitude over frequency; shows pitch, harmonics, and spectral content.
* Audio processing often converts signals to frequency domain for compression, filtering, and analysis.


---

## **Core Audio Concepts**

---

### **1. Sound Wave**

**Definition:**
Sound is a mechanical wave — vibrations in air (or another medium) that our ears perceive as pressure changes.

**Characteristics:**

* **Amplitude:** Determines loudness.
* **Frequency:** Determines pitch.
* **Phase:** Position of the wave relative to time zero.

**Analogy:**
Sound waves are like **ripples in a pond**; bigger ripples are louder, closer ripples oscillate faster (higher pitch).

---

### **2. Time-Domain Representation**

**Definition:**
Audio shown as amplitude vs. time.

**Characteristics:**

* Shows **waveform** directly.
* Useful for editing: trimming, fades, amplitude adjustments.

---

### **3. Frequency-Domain Representation**

**Definition:**
Audio represented by **frequencies and amplitudes**, using Fourier Transform.

**Characteristics:**

* Shows **pitch and harmonic content**.
* Used for EQ, compression, filtering, spectral analysis.

**Analogy:**
Frequency-domain is like a **musical score**, revealing notes and harmonics.

---

### **4. Sampling**

**Definition:**
Process of converting continuous audio into discrete **digital samples**.

**Key Parameters:**

* **Sampling rate (Hz):** Number of samples per second (CD: 44.1 kHz).
* **Bit depth:** Number of bits per sample (CD: 16-bit) — affects dynamic range.

**Analogy:**
Sampling is like **taking snapshots** of a moving car at regular intervals.

---

### **5. Quantization**

**Definition:**
Mapping sampled amplitudes to the nearest digital value according to bit depth.

**Effect:**

* Introduces **quantization noise** if bit depth is low.
* Higher bit depth → more precise amplitude representation.

---

### **6. Dynamic Range**

**Definition:**
Difference between the **loudest and softest sounds** a system can reproduce.

**Formula:**
$$
\text{Dynamic Range (dB)} = 6.02 \times \text{Bit Depth}
$$

**Analogy:**
Dynamic range is like a **camera’s exposure range** — capturing both shadows and highlights.

---

### **7. Channels**

**Definition:**
Separate streams of audio.

* **Mono:** 1 channel.
* **Stereo:** 2 channels (left and right).
* **Surround:** 5.1, 7.1 channels for spatial sound.

**Analogy:**
Channels are like **separate instruments in an orchestra**, each contributing to the final sound.

---

### **8. Sampling Theorems**

* **Nyquist Theorem:** Sampling rate must be at least **twice the maximum frequency** to avoid aliasing.
* **Aliasing:** High-frequency content folding into lower frequencies due to undersampling.

---

### **9. Time-Frequency Analysis**

* **STFT (Short-Time Fourier Transform):** Captures frequency content over short time windows.
* **Wavelets:** Alternative transform for multi-resolution analysis.

**Use:** Audio analysis, noise reduction, spectrogram visualization.

---

### **10. Audio Compression**

* **Lossless:** FLAC, ALAC — exact reconstruction.
* **Lossy:** MP3, AAC — discards imperceptible frequencies.
* **Frequency-domain compression:** Uses psychoacoustic models to remove sounds humans can’t hear.

---

### **11. Filtering**

* **Low-pass:** Removes high frequencies.
* **High-pass:** Removes low frequencies.
* **Band-pass:** Keeps a range of frequencies.

**Analogy:** Filters are like **sieves for sound** — letting certain pitches pass and blocking others.

---

### **12. Reverberation and Echo**

* **Reverb:** Multiple reflections that blend together → sense of space.
* **Echo:** Distinct reflection with perceptible delay.

**Analogy:**
Reverb is like being in a cathedral; echo is like shouting in a canyon.

---

### **13. Modulation Effects**

* **Tremolo:** Amplitude modulation.
* **Vibrato:** Frequency modulation.
* **Chorus / Flanger / Phaser:** Slight pitch/delay shifts for richness.

---

### **14. Envelope**

Describes how amplitude changes over time, usually **ADSR**:

* **Attack:** Time to reach max amplitude.
* **Decay:** Time to fall to sustain level.
* **Sustain:** Steady amplitude while held.
* **Release:** Time to fade after note ends.

---

### **15. Spectrogram**

Visual representation of **frequency vs time** with amplitude as intensity/color.

**Use:**

* Audio analysis, speech recognition, noise detection.

---

### **16. Audio File Formats**

* **Uncompressed:** WAV, AIFF
* **Lossless compressed:** FLAC, ALAC
* **Lossy compressed:** MP3, AAC, OGG, Opus

---

### **17. Psychoacoustics**

* Human hearing characteristics used for compression and mixing.
* Masking effect: louder sounds hide quieter ones at nearby frequencies.

---

**Summary**

* Audio can be understood in **time domain (waveform)** and **frequency domain (spectrum)**.
* **Sampling, quantization, and bit depth** define digital representation.
* **Channels, dynamic range, filtering, and effects** shape the listening experience.
* **Compression and psychoacoustics** allow efficient storage without perceptible loss.
* Time-frequency analysis and spectrograms reveal both temporal and spectral structure for processing or analysis.



