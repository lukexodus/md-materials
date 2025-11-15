# Syllabus

## Module 1: Foundations
- FFmpeg architecture and components (ffmpeg, ffprobe, ffplay)
- Installation and environment setup
- Command-line syntax structure
- Input/output file handling
- Basic format conversion
- Getting file information and metadata
- Understanding streams (video, audio, subtitle, data)
- Common file formats and containers
- Codec basics and differences

## Module 2: Video Fundamentals
- Video codecs (H.264, H.265, VP9, AV1, etc.)
- Codec parameters and profiles
- Understanding bitrate vs quality
- CRF (Constant Rate Factor) encoding
- VBR, CBR, and ABR encoding modes
- One-pass vs two-pass encoding
- Resolution and aspect ratio
- Frame rate and frame types (I, P, B frames)
- Pixel formats and color spaces
- Video presets and tuning options

## Module 3: Audio Fundamentals
- Audio codecs (AAC, MP3, Opus, FLAC, etc.)
- Sample rate and bit depth
- Audio bitrate and quality settings
- Mono, stereo, and multichannel audio
- Audio normalization and loudness
- Audio stream selection and mapping
- Audio synchronization issues
- Extracting and replacing audio tracks

## Module 4: Basic Video Operations
- Trimming and cutting video
- Concatenating multiple videos
- Changing video speed (slow motion, fast forward)
- Reversing video
- Creating loops
- Basic quality adjustment
- Format and codec conversion
- Stream copying vs re-encoding

## Module 5: Video Filters - Part 1
- Filter syntax and filter chains
- Scaling and resizing
- Cropping
- Padding
- Rotation and transposition
- Flipping and mirroring
- Deinterlacing
- Denoising filters

## Module 6: Video Filters - Part 2
- Color correction and grading
- Brightness, contrast, saturation
- Color curves and levels
- Color space conversion
- Sharpening and blurring
- Edge detection
- Vignette effects
- Stabilization

## Module 7: Audio Filters
- Volume adjustment
- Audio normalization (loudnorm, dynaudnorm)
- Equalizer and filtering
- Audio mixing and merging
- Delay and echo effects
- Pitch shifting
- Tempo adjustment
- Noise reduction
- Compressor and limiter

## Module 8: Overlay and Composition
- Image watermarking
- Video overlay
- Picture-in-picture effects
- Green screen removal (chroma key)
- Alpha channel handling
- Blending modes
- Multiple input handling
- Complex filter graphs

## Module 9: Subtitles and Text
- Adding subtitle tracks
- Burning subtitles into video
- Subtitle formats (SRT, ASS, WebVTT)
- Subtitle timing and synchronization
- Extracting subtitles
- Text overlay and drawtext filter
- Custom fonts and styling
- Animated text effects

## Module 10: Image Operations
- Extracting frames from video
- Creating thumbnails
- Generating video from images
- Image sequences and slideshows
- Contact sheets and tile generation
- Animated GIF creation
- Optimizing GIF quality
- Converting between image formats

## Module 11: Stream Mapping
- Understanding stream mapping syntax
- Multiple input files
- Selecting specific streams
- Stream disposition flags
- Complex mapping scenarios
- Audio track selection
- Subtitle track management
- Multiple output files

## Module 12: Metadata and Tags
- Reading metadata
- Writing metadata tags
- Chapter markers
- Artwork and thumbnails
- Custom metadata fields
- Metadata removal and privacy
- Format-specific metadata
- Bulk metadata operations

## Module 13: Advanced Encoding
- Codec-specific optimizations
- Rate control modes
- Bitrate targeting strategies
- Quality metrics (PSNR, SSIM, VMAF)
- Psychovisual optimizations
- Adaptive streaming preparation
- Multi-bitrate encoding
- Encoding for specific platforms

## Module 14: Hardware Acceleration
- GPU encoding fundamentals
- NVIDIA NVENC
- Intel Quick Sync Video
- AMD AMF
- Apple VideoToolbox
- Hardware decoding
- Hybrid encoding workflows
- Performance comparison and trade-offs

## Module 15: Batch Processing
- Shell scripting for automation
- Batch file conversion
- Directory traversal
- Error handling in scripts
- Progress monitoring
- Parallel processing
- Log management
- Cross-platform scripting

## Module 16: Live Streaming
- RTMP protocol basics
- Streaming to platforms (Twitch, YouTube, etc.)
- Stream key management
- Live encoding settings
- Buffer management
- Low-latency streaming
- Stream monitoring
- Failover and redundancy

## Module 17: Recording
- Screen recording
- Webcam capture
- Audio recording
- Simultaneous screen and webcam
- Device detection and selection
- Recording with overlays
- Recording optimization
- Platform-specific capture methods

## Module 18: Network Protocols
- HTTP/HTTPS streaming
- HLS (HTTP Live Streaming)
- DASH (Dynamic Adaptive Streaming)
- UDP/RTP streaming
- Network stream recording
- Playlist generation
- Segment management
- CDN optimization

## Module 19: Format-Specific Operations
- MP4 optimization (faststart, fragmentation)
- MKV features (attachments, chapters)
- WebM for web delivery
- FLV handling
- AVI limitations and solutions
- MOV and ProRes workflows
- Raw video formats
- Format conversion best practices

## Module 20: Quality Control
- Quality assessment techniques
- Visual quality metrics
- Audio quality analysis
- Automated QC workflows
- Reference comparison
- Debugging encoding issues
- Artifact identification
- Quality vs file size optimization

## Module 21: Advanced Filters
- Custom filter development concepts
- Temporal filters
- Motion detection
- Object tracking
- Morphological operations
- FFT-based filters
- Machine learning filters
- Filter performance optimization

## Module 22: Timecode and Synchronization
- Timecode formats
- Frame-accurate editing
- Audio/video sync correction
- Multiple camera synchronization
- Dropped frame handling
- Variable frame rate handling
- Timestamp manipulation
- PTS/DTS understanding

## Module 23: Professional Workflows
- Broadcast specifications
- Cinema/DCP workflows
- Archive formats and standards
- Proxy generation
- Intermediate codecs (ProRes, DNxHD)
- Color space workflows (HDR, Rec.709, Rec.2020)
- Professional audio workflows
- Quality assurance procedures

## Module 24: Optimization and Performance
- Encoding speed optimization
- Memory management
- CPU utilization strategies
- Threading and parallel processing
- Disk I/O optimization
- Network optimization
- Power consumption considerations
- Benchmarking and profiling

## Module 25: Troubleshooting and Debugging
- Common error messages
- Log analysis
- Verbose output interpretation
- Stream analysis tools
- Compatibility issues
- Codec support problems
- Filter chain debugging
- Performance bottleneck identification

## Module 26: API and Integration
- FFmpeg libraries (libav*)
- Programming language bindings
- Building custom applications
- FFmpeg in Python (ffmpeg-python)
- Node.js integration
- Web application integration
- Microservices architecture
- Containerization (Docker)

## Module 27: Advanced Scripting
- Complex automation workflows
- Conditional processing
- Dynamic parameter generation
- Database integration
- Queue management systems
- Distributed processing
- Cloud integration (AWS, GCP, Azure)
- Webhook and API integration

## Module 28: Specialized Use Cases
- Video game recording
- Security camera processing
- Medical imaging
- Scientific visualization
- VR/360° video
- Multi-angle video
- Time-lapse creation
- Stop motion processing

## Module 29: Emerging Technologies
- AV1 codec mastery
- HDR and Dolby Vision
- 8K and high resolution workflows
- Immersive audio (Dolby Atmos)
- AI-enhanced processing
- Cloud encoding services
- Real-time processing
- Low-latency protocols (SRT, WebRTC)

## Module 30: Best Practices and Standards
- Naming conventions
- Project organization
- Documentation standards
- Version control for media
- Backup strategies
- Security considerations
- Licensing and legal compliance
- Industry standards and specifications

---

## Recommended Learning Path

**Beginner:** Modules 1-4, 8, 10
**Intermediate:** Modules 5-7, 9, 11-14
**Advanced:** Modules 15-20, 22-25
**Expert:** Modules 21, 23, 26-30

# Quick Guide & Cheatsheet

## Installation

**Linux (Debian/Ubuntu):**
```bash
sudo apt update
sudo apt install ffmpeg
```

**macOS:**
```bash
brew install ffmpeg
```

**Windows:**
Download from [ffmpeg.org](https://ffmpeg.org/download.html) and add to PATH.

**Verify installation:**
```bash
ffmpeg -version
```

---

## Basic Syntax

```bash
ffmpeg [global_options] [input_options] -i input_file [output_options] output_file
```

---

## Essential Concepts

### Common Codecs
- **Video:** H.264 (libx264), H.265 (libx265), VP9, AV1
- **Audio:** AAC, MP3 (libmp3lame), Opus, FLAC, Vorbis

### Container Formats
- **MP4** (.mp4) - Universal, web-friendly
- **MKV** (.mkv) - Flexible, supports many codecs
- **WebM** (.webm) - Web-optimized (VP9/Opus)
- **AVI** (.avi) - Older format
- **MOV** (.mov) - QuickTime format

---

## Basic Operations

### 1. **Convert Format**
```bash
# Convert video format
ffmpeg -i input.avi output.mp4

# Convert audio format
ffmpeg -i input.wav output.mp3
```

### 2. **Extract Audio from Video**
```bash
# Extract as MP3
ffmpeg -i video.mp4 -vn -acodec libmp3lame -q:a 2 audio.mp3

# Extract as WAV (lossless)
ffmpeg -i video.mp4 -vn -acodec pcm_s16le audio.wav

# Extract original audio codec (no re-encoding)
ffmpeg -i video.mp4 -vn -acodec copy audio.aac
```

### 3. **Get File Information**
```bash
# Detailed info
ffmpeg -i input.mp4

# Shorter info
ffprobe input.mp4
```

---

## Video Encoding & Quality

### 4. **Adjust Video Quality**

**H.264 (most common):**
```bash
# Constant Rate Factor (CRF) - recommended
# CRF range: 0-51 (lower = better quality, 18-28 is typical)
ffmpeg -i input.mp4 -c:v libx264 -crf 23 -c:a copy output.mp4

# Two-pass encoding (better quality/size ratio)
ffmpeg -i input.mp4 -c:v libx264 -b:v 1M -pass 1 -f null /dev/null
ffmpeg -i input.mp4 -c:v libx264 -b:v 1M -pass 2 output.mp4

# Specific bitrate
ffmpeg -i input.mp4 -b:v 2M -b:a 192k output.mp4
```

**H.265/HEVC (better compression):**
```bash
ffmpeg -i input.mp4 -c:v libx265 -crf 28 -c:a copy output.mp4
```

### 5. **Change Resolution**
```bash
# Scale to specific dimensions
ffmpeg -i input.mp4 -vf scale=1280:720 output.mp4

# Scale by width (keep aspect ratio)
ffmpeg -i input.mp4 -vf scale=1920:-1 output.mp4

# Scale by height (keep aspect ratio)
ffmpeg -i input.mp4 -vf scale=-1:1080 output.mp4

# Scale to 50%
ffmpeg -i input.mp4 -vf scale=iw*0.5:ih*0.5 output.mp4
```

### 6. **Change Frame Rate**
```bash
# Set frame rate
ffmpeg -i input.mp4 -r 30 output.mp4

# Convert to 60fps (interpolation)
ffmpeg -i input.mp4 -filter:v "minterpolate='fps=60'" output.mp4
```

---

## Trimming & Cutting

### 7. **Trim Video**
```bash
# Cut from timestamp (with re-encoding)
ffmpeg -i input.mp4 -ss 00:01:30 -t 00:00:45 output.mp4
# -ss: start time (1min 30sec)
# -t: duration (45 seconds)

# Cut without re-encoding (faster, less precise)
ffmpeg -ss 00:01:30 -i input.mp4 -t 00:00:45 -c copy output.mp4

# Cut to end time instead of duration
ffmpeg -i input.mp4 -ss 00:01:00 -to 00:05:00 output.mp4
```

### 8. **Split Video into Segments**
```bash
# Split into 10-minute chunks
ffmpeg -i input.mp4 -c copy -map 0 -segment_time 00:10:00 -f segment output%03d.mp4

# Split at specific times
ffmpeg -i input.mp4 -c copy -t 00:05:00 part1.mp4
ffmpeg -i input.mp4 -c copy -ss 00:05:00 part2.mp4
```

---

## Concatenating & Merging

### 9. **Concatenate Videos**

**Method 1: Concat filter (re-encodes)**
```bash
ffmpeg -i input1.mp4 -i input2.mp4 -filter_complex "[0:v][0:a][1:v][1:a]concat=n=2:v=1:a=1[outv][outa]" -map "[outv]" -map "[outa]" output.mp4
```

**Method 2: Concat demuxer (no re-encoding)**
```bash
# Create file list
echo "file 'input1.mp4'" > list.txt
echo "file 'input2.mp4'" >> list.txt

# Concatenate
ffmpeg -f concat -safe 0 -i list.txt -c copy output.mp4
```

### 10. **Add Audio to Video**
```bash
# Replace audio
ffmpeg -i video.mp4 -i audio.mp3 -c:v copy -c:a aac -map 0:v:0 -map 1:a:0 output.mp4

# Mix audio tracks
ffmpeg -i video.mp4 -i audio.mp3 -filter_complex "[0:a][1:a]amix=inputs=2[a]" -map 0:v -map "[a]" output.mp4
```

---

## Audio Operations

### 11. **Adjust Audio**
```bash
# Change volume (256 = 100%, 512 = 200%, 128 = 50%)
ffmpeg -i input.mp4 -af "volume=2.0" output.mp4

# Normalize audio
ffmpeg -i input.mp4 -af "loudnorm" output.mp4

# Change audio bitrate
ffmpeg -i input.mp4 -b:a 192k output.mp4

# Change audio sample rate
ffmpeg -i input.mp3 -ar 44100 output.mp3
```

### 12. **Remove Audio**
```bash
ffmpeg -i input.mp4 -an output.mp4
```

---

## Advanced Filters

### 13. **Watermark**
```bash
# Add image watermark
ffmpeg -i input.mp4 -i logo.png -filter_complex "[0:v][1:v]overlay=10:10" output.mp4

# Position watermark (bottom-right with 10px padding)
ffmpeg -i input.mp4 -i logo.png -filter_complex "[0:v][1:v]overlay=W-w-10:H-h-10" output.mp4
```

### 14. **Crop Video**
```bash
# Crop: out_w:out_h:x:y
ffmpeg -i input.mp4 -vf "crop=1280:720:0:0" output.mp4

# Auto-crop black borders
ffmpeg -i input.mp4 -vf "cropdetect" -f null -
# Then use detected values with crop filter
```

### 15. **Rotate/Flip Video**
```bash
# Rotate 90 degrees clockwise
ffmpeg -i input.mp4 -vf "transpose=1" output.mp4
# transpose values: 0=90°CCW, 1=90°CW, 2=90°CCW+flip, 3=90°CW+flip

# Rotate 180 degrees
ffmpeg -i input.mp4 -vf "transpose=1,transpose=1" output.mp4

# Flip horizontal
ffmpeg -i input.mp4 -vf "hflip" output.mp4

# Flip vertical
ffmpeg -i input.mp4 -vf "vflip" output.mp4
```

### 16. **Add Subtitles**
```bash
# Burn subtitles into video
ffmpeg -i input.mp4 -vf "subtitles=subs.srt" output.mp4

# Add subtitle track (without burning)
ffmpeg -i input.mp4 -i subs.srt -c copy -c:s mov_text output.mp4
```

### 17. **Create GIF**
```bash
# Basic GIF
ffmpeg -i input.mp4 -vf "fps=10,scale=320:-1:flags=lanczos" output.gif

# High-quality GIF with palette
ffmpeg -i input.mp4 -vf "fps=15,scale=480:-1:flags=lanczos,palettegen" palette.png
ffmpeg -i input.mp4 -i palette.png -filter_complex "fps=15,scale=480:-1:flags=lanczos[x];[x][1:v]paletteuse" output.gif
```

---

## Recording & Streaming

### 18. **Record Screen (Linux)**
```bash
# Record X11 display
ffmpeg -f x11grab -s 1920x1080 -i :0.0 output.mp4

# Record with audio
ffmpeg -f x11grab -s 1920x1080 -i :0.0 -f alsa -i default output.mp4
```

### 19. **Record Webcam**
```bash
# Linux
ffmpeg -f v4l2 -i /dev/video0 webcam.mp4

# macOS
ffmpeg -f avfoundation -i "0:0" webcam.mp4
```

### 20. **Stream to RTMP**
```bash
# Stream to Twitch/YouTube
ffmpeg -re -i input.mp4 -c:v libx264 -preset veryfast -maxrate 3000k -bufsize 6000k -c:a aac -b:a 128k -f flv rtmp://live.twitch.tv/app/your_stream_key
```

---

## Batch Processing

### 21. **Convert Multiple Files**

**Bash (Linux/Mac):**
```bash
# Convert all AVI to MP4
for i in *.avi; do ffmpeg -i "$i" "${i%.*}.mp4"; done

# Batch resize
for i in *.mp4; do ffmpeg -i "$i" -vf scale=1280:720 "resized_$i"; done
```

**PowerShell (Windows):**
```powershell
Get-ChildItem *.avi | ForEach-Object { ffmpeg -i $_.Name "$($_.BaseName).mp4" }
```

---

## Optimization & Compression

### 22. **Compress Video**
```bash
# Balanced compression (H.264)
ffmpeg -i input.mp4 -c:v libx264 -crf 23 -preset medium -c:a aac -b:a 128k output.mp4

# Maximum compression (slower)
ffmpeg -i input.mp4 -c:v libx264 -crf 28 -preset veryslow output.mp4

# Fast compression
ffmpeg -i input.mp4 -c:v libx264 -crf 23 -preset ultrafast output.mp4
```

### 23. **Web Optimization**
```bash
# Optimize for web (MP4)
ffmpeg -i input.mp4 -c:v libx264 -crf 23 -preset medium -movflags +faststart -c:a aac -b:a 128k output.mp4
# -movflags +faststart: enables streaming before full download
```

---

## Image Operations

### 24. **Extract Frames**
```bash
# Extract every frame
ffmpeg -i input.mp4 frame%04d.png

# Extract 1 frame per second
ffmpeg -i input.mp4 -vf "fps=1" frame%04d.png

# Extract single frame at timestamp
ffmpeg -ss 00:00:10 -i input.mp4 -frames:v 1 thumbnail.png
```

### 25. **Create Video from Images**
```bash
# From numbered images
ffmpeg -framerate 30 -i frame%04d.png -c:v libx264 -pix_fmt yuv420p output.mp4

# From pattern
ffmpeg -pattern_type glob -i '*.png' -c:v libx264 output.mp4
```

---

## Useful Options & Flags

### Common Flags
```bash
-c copy          # Copy streams without re-encoding
-c:v codec       # Video codec
-c:a codec       # Audio codec
-b:v bitrate     # Video bitrate (e.g., 2M)
-b:a bitrate     # Audio bitrate (e.g., 192k)
-r fps           # Frame rate
-s resolution    # Resolution (e.g., 1920x1080)
-vf filter       # Video filter
-af filter       # Audio filter
-an              # Remove audio
-vn              # Remove video
-y               # Overwrite output without asking
-n               # Never overwrite
-t duration      # Duration (e.g., 00:01:30)
-ss position     # Start position
-to position     # End position
```

### Presets (speed vs compression)
```bash
-preset ultrafast  # Fastest encoding
-preset superfast
-preset veryfast
-preset faster
-preset fast
-preset medium     # Default balance
-preset slow
-preset slower
-preset veryslow   # Best compression
```

---

## Hardware Acceleration

### 26. **GPU Encoding**

**NVIDIA (NVENC):**
```bash
ffmpeg -i input.mp4 -c:v h264_nvenc -preset fast -crf 23 output.mp4
```

**Intel Quick Sync:**
```bash
ffmpeg -i input.mp4 -c:v h264_qsv -preset fast output.mp4
```

**AMD (AMF):**
```bash
ffmpeg -i input.mp4 -c:v h264_amf output.mp4
```

---

## Troubleshooting Tips

1. **Check available codecs:**
   ```bash
   ffmpeg -codecs
   ```

2. **Check available formats:**
   ```bash
   ffmpeg -formats
   ```

3. **Verbose output for debugging:**
   ```bash
   ffmpeg -v verbose -i input.mp4
   ```

4. **Test filters without encoding:**
   ```bash
   ffmpeg -i input.mp4 -vf scale=640:480 -f null -
   ```

---

## Performance Tips

- Use `-c copy` when possible to avoid re-encoding
- Put `-ss` before `-i` for faster seeking (less precise)
- Use hardware acceleration for faster encoding
- Use appropriate presets based on your needs
- Consider two-pass encoding for better quality/size ratio

---

This guide covers the most common FFmpeg operations. For more specific use cases, consult the official documentation at [ffmpeg.org/documentation.html](https://ffmpeg.org/documentation.html).

---

# Image Processing

## Table of Contents
1. [Introduction](#introduction)
2. [Basic Image Operations](#basic-image-operations)
3. [Extracting Images from Video](#extracting-images-from-video)
4. [Creating Videos from Images](#creating-videos-from-images)
5. [Image Format Conversion](#image-format-conversion)
6. [Image Scaling and Resizing](#image-scaling-and-resizing)
7. [Image Cropping](#image-cropping)
8. [Image Rotation and Flipping](#image-rotation-and-flipping)
9. [Image Filters and Effects](#image-filters-and-effects)
10. [Watermarking and Overlays](#watermarking-and-overlays)
11. [Creating Thumbnails](#creating-thumbnails)
12. [GIF Creation and Optimization](#gif-creation-and-optimization)
13. [Contact Sheets and Tiles](#contact-sheets-and-tiles)
14. [Batch Image Processing](#batch-image-processing)
15. [Advanced Techniques](#advanced-techniques)

---

## Introduction

FFmpeg is primarily known as a video processing tool, but it's also a powerful image manipulation utility. This guide covers everything from basic image operations to advanced batch processing techniques.

### Why Use FFmpeg for Images?

- **Command-line efficiency** - Fast batch processing
- **Format versatility** - Supports hundreds of image formats
- **No GUI overhead** - Ideal for servers and automation
- **Consistent toolchain** - Same tool for images and videos
- **Scriptable** - Easy to integrate into workflows
- **Cross-platform** - Works on Linux, macOS, Windows

### Prerequisites

```bash
# Check if FFmpeg is installed
ffmpeg -version

# Check supported image formats
ffmpeg -formats | grep image
```

---

## Basic Image Operations

### 1. Get Image Information

```bash
# Basic information
ffmpeg -i image.jpg

# Detailed information with ffprobe
ffprobe -v quiet -print_format json -show_format -show_streams image.jpg

# Get just dimensions
ffprobe -v error -select_streams v:0 -show_entries stream=width,height -of csv=s=x:p=0 image.jpg
```

**Example output:**
```
Input #0, image2, from 'image.jpg':
  Duration: 00:00:00.04, start: 0.000000, bitrate: N/A
  Stream #0:0: Video: mjpeg (Baseline), yuvj420p(pc, bt470bg/unknown/unknown), 
  1920x1080, 25 tbr, 25 tbn
```

### 2. View Image in FFplay

```bash
# Display image
ffplay image.jpg

# Display with specific window size
ffplay -x 800 -y 600 image.jpg

# Slideshow from directory
ffplay -f image2 -framerate 1 'image%03d.jpg'
```

---

## Extracting Images from Video

### 3. Extract All Frames

```bash
# Extract every frame as PNG
ffmpeg -i video.mp4 frame%04d.png

# Extract every frame as JPEG with quality
ffmpeg -i video.mp4 -qscale:v 2 frame%04d.jpg
# qscale:v range: 2-31 (2 = best quality, 31 = worst)

# Extract frames with padding
ffmpeg -i video.mp4 frame%08d.png
# Creates: frame00000001.png, frame00000002.png, etc.
```

### 4. Extract Frames at Specific Intervals

```bash
# Extract 1 frame per second
ffmpeg -i video.mp4 -vf fps=1 frame%04d.png

# Extract 1 frame every 5 seconds
ffmpeg -i video.mp4 -vf fps=1/5 frame%04d.png

# Extract 1 frame per minute
ffmpeg -i video.mp4 -vf fps=1/60 frame%04d.png

# Extract 10 frames per second
ffmpeg -i video.mp4 -vf fps=10 frame%04d.png
```

### 5. Extract Single Frame at Specific Time

```bash
# Extract frame at 5 seconds
ffmpeg -ss 00:00:05 -i video.mp4 -frames:v 1 frame.png

# Extract frame at specific timestamp
ffmpeg -ss 00:02:30.5 -i video.mp4 -frames:v 1 frame.jpg

# Extract frame at 50% of video
ffmpeg -i video.mp4 -vf "select=eq(n\,$(ffprobe -v error -count_frames \
  -select_streams v:0 -show_entries stream=nb_read_frames \
  -of default=nokey=1:noprint_wrappers=1 video.mp4)/2)" \
  -frames:v 1 middle_frame.png
```

### 6. Extract High-Quality Frames

```bash
# Extract as lossless PNG
ffmpeg -i video.mp4 -vf fps=1 -compression_level 0 frame%04d.png

# Extract as high-quality JPEG
ffmpeg -i video.mp4 -qscale:v 1 -qmin 1 -qmax 1 frame%04d.jpg

# Extract as TIFF (lossless)
ffmpeg -i video.mp4 -vf fps=1 frame%04d.tiff
```

### 7. Extract with Original Resolution

```bash
# Maintain original quality and size
ffmpeg -i video.mp4 -vf fps=1 -c:v png frame%04d.png

# For specific codec videos
ffmpeg -i video.mp4 -vf fps=1 -pix_fmt rgb24 frame%04d.png
```

---

## Creating Videos from Images

### 8. Basic Image Sequence to Video

```bash
# From numbered sequence (image001.jpg, image002.jpg, etc.)
ffmpeg -framerate 30 -i image%03d.jpg -c:v libx264 -pix_fmt yuv420p output.mp4

# From numbered sequence with start number
ffmpeg -framerate 30 -start_number 100 -i image%03d.jpg output.mp4

# From specific pattern
ffmpeg -framerate 24 -pattern_type glob -i '*.jpg' -c:v libx264 output.mp4
```

### 9. Control Video Quality from Images

```bash
# High quality H.264
ffmpeg -framerate 30 -i image%03d.jpg -c:v libx264 -crf 18 -preset slow output.mp4

# Lossless video
ffmpeg -framerate 30 -i image%03d.jpg -c:v libx264 -crf 0 -preset veryslow output.mp4

# Specific bitrate
ffmpeg -framerate 30 -i image%03d.jpg -c:v libx264 -b:v 5M output.mp4
```

### 10. Slideshow with Transitions

```bash
# Simple crossfade between images (3 seconds each, 1 second fade)
ffmpeg -loop 1 -t 3 -i image1.jpg \
       -loop 1 -t 3 -i image2.jpg \
       -loop 1 -t 3 -i image3.jpg \
       -filter_complex \
       "[0][1]xfade=transition=fade:duration=1:offset=2[f1]; \
        [f1][2]xfade=transition=fade:duration=1:offset=5[out]" \
       -map "[out]" -c:v libx264 -pix_fmt yuv420p slideshow.mp4
```

### 11. Images with Different Durations

```bash
# Create video with specific duration per image
ffmpeg -loop 1 -t 5 -i image1.jpg \
       -loop 1 -t 3 -i image2.jpg \
       -loop 1 -t 4 -i image3.jpg \
       -filter_complex "[0][1][2]concat=n=3:v=1:a=0" \
       output.mp4
```

### 12. Add Audio to Image Slideshow

```bash
# Single image with audio
ffmpeg -loop 1 -i image.jpg -i audio.mp3 -c:v libx264 -tune stillimage \
       -c:a aac -b:a 192k -shortest output.mp4

# Multiple images with audio
ffmpeg -framerate 1/3 -i image%03d.jpg -i audio.mp3 \
       -c:v libx264 -c:a aac -shortest output.mp4
```

---

## Image Format Conversion

### 13. Convert Between Formats

```bash
# JPEG to PNG
ffmpeg -i input.jpg output.png

# PNG to JPEG with quality
ffmpeg -i input.png -qscale:v 2 output.jpg

# TIFF to PNG
ffmpeg -i input.tiff output.png

# BMP to JPEG
ffmpeg -i input.bmp -qscale:v 2 output.jpg

# WebP to PNG
ffmpeg -i input.webp output.png

# PNG to WebP
ffmpeg -i input.png -c:v libwebp -quality 80 output.webp
```

### 14. Batch Format Conversion

```bash
# Convert all JPEGs to PNG (Bash)
for i in *.jpg; do ffmpeg -i "$i" "${i%.*}.png"; done

# Convert all PNGs to JPEG with quality (Bash)
for i in *.png; do ffmpeg -i "$i" -qscale:v 2 "${i%.*}.jpg"; done

# Batch convert with specific settings
for i in *.tiff; do 
  ffmpeg -i "$i" -qscale:v 1 -qmin 1 -qmax 1 "${i%.*}.jpg"
done
```

### 15. Convert with Color Space Changes

```bash
# Convert to grayscale
ffmpeg -i input.jpg -vf format=gray output.jpg

# Convert color space
ffmpeg -i input.jpg -vf colorspace=bt709:bt2020 output.jpg

# Convert to specific pixel format
ffmpeg -i input.png -pix_fmt rgb24 output.png
```

---

## Image Scaling and Resizing

### 16. Basic Scaling

```bash
# Scale to specific dimensions
ffmpeg -i input.jpg -vf scale=800:600 output.jpg

# Scale by width, maintain aspect ratio
ffmpeg -i input.jpg -vf scale=1920:-1 output.jpg

# Scale by height, maintain aspect ratio
ffmpeg -i input.jpg -vf scale=-1:1080 output.jpg

# Scale to 50% of original size
ffmpeg -i input.jpg -vf scale=iw*0.5:ih*0.5 output.jpg

# Scale to 200% of original size
ffmpeg -i input.jpg -vf scale=iw*2:ih*2 output.jpg
```

### 17. Scaling with Quality Control

```bash
# Lanczos scaling (highest quality)
ffmpeg -i input.jpg -vf scale=1920:1080:flags=lanczos output.jpg

# Bicubic scaling (good quality)
ffmpeg -i input.jpg -vf scale=1920:1080:flags=bicubic output.jpg

# Fast bilinear scaling
ffmpeg -i input.jpg -vf scale=1920:1080:flags=fast_bilinear output.jpg

# Experimental scaling algorithms
ffmpeg -i input.jpg -vf scale=1920:1080:flags=experimental output.jpg
```

### 18. Fit Within Dimensions

```bash
# Fit within box (maintain aspect ratio, no upscaling)
ffmpeg -i input.jpg -vf "scale='min(1920,iw)':'min(1080,ih)':force_original_aspect_ratio=decrease" output.jpg

# Fit within box with padding
ffmpeg -i input.jpg -vf "scale=1920:1080:force_original_aspect_ratio=decrease,pad=1920:1080:(ow-iw)/2:(oh-ih)/2" output.jpg

# Fit and fill with blur background
ffmpeg -i input.jpg -filter_complex \
  "[0:v]scale=1920:1080:force_original_aspect_ratio=increase,crop=1920:1080[bg]; \
   [0:v]scale=1920:1080:force_original_aspect_ratio=decrease[fg]; \
   [bg][fg]overlay=(W-w)/2:(H-h)/2" \
  output.jpg
```

### 19. Aspect Ratio Adjustments

```bash
# Force aspect ratio (may distort)
ffmpeg -i input.jpg -vf scale=1920:1080 output.jpg

# Maintain aspect ratio with letterboxing
ffmpeg -i input.jpg -vf "scale=1920:1080:force_original_aspect_ratio=decrease,pad=1920:1080:(ow-iw)/2:(oh-ih)/2:color=black" output.jpg

# Convert 4:3 to 16:9
ffmpeg -i input.jpg -vf "scale=1920:1080,setsar=1" output.jpg
```

### 20. Batch Resize

```bash
# Resize all images to max width 1920px
for i in *.jpg; do
  ffmpeg -i "$i" -vf "scale='min(1920,iw)':-1" "resized_$i"
done

# Create thumbnails for all images
for i in *.jpg; do
  ffmpeg -i "$i" -vf scale=320:-1 "thumb_$i"
done
```

---

## Image Cropping

### 21. Basic Cropping

```bash
# Crop: width:height:x:y
ffmpeg -i input.jpg -vf "crop=800:600:0:0" output.jpg

# Crop from center
ffmpeg -i input.jpg -vf "crop=800:600" output.jpg

# Crop to square (centered)
ffmpeg -i input.jpg -vf "crop=min(iw\,ih):min(iw\,ih)" output.jpg

# Crop bottom half
ffmpeg -i input.jpg -vf "crop=iw:ih/2:0:ih/2" output.jpg

# Crop right half
ffmpeg -i input.jpg -vf "crop=iw/2:ih:iw/2:0" output.jpg
```

### 22. Aspect Ratio Cropping

```bash
# Crop to 16:9 (centered)
ffmpeg -i input.jpg -vf "crop=ih*16/9:ih" output.jpg

# Crop to 1:1 (square, centered)
ffmpeg -i input.jpg -vf "crop=min(iw\,ih):min(iw\,ih)" output.jpg

# Crop to 4:3
ffmpeg -i input.jpg -vf "crop=ih*4/3:ih" output.jpg

# Crop to 21:9 (ultrawide)
ffmpeg -i input.jpg -vf "crop=ih*21/9:ih" output.jpg
```

### 23. Auto-Crop Detection

```bash
# Detect crop parameters (run first)
ffmpeg -i input.jpg -vf cropdetect -f null -

# Example output: crop=1920:800:0:140
# Then use detected values:
ffmpeg -i input.jpg -vf "crop=1920:800:0:140" output.jpg

# Auto-crop black borders in batch
for i in *.jpg; do
  CROP=$(ffmpeg -i "$i" -vf cropdetect -f null - 2>&1 | grep -o 'crop=[0-9:]*' | tail -1)
  ffmpeg -i "$i" -vf "$CROP" "cropped_$i"
done
```

### 24. Multiple Crop Regions

```bash
# Extract multiple regions from one image
ffmpeg -i input.jpg -filter_complex \
  "[0:v]crop=400:300:0:0[tl]; \
   [0:v]crop=400:300:400:0[tr]; \
   [0:v]crop=400:300:0:300[bl]; \
   [0:v]crop=400:300:400:300[br]" \
  -map "[tl]" topleft.jpg \
  -map "[tr]" topright.jpg \
  -map "[bl]" bottomleft.jpg \
  -map "[br]" bottomright.jpg
```

---

## Image Rotation and Flipping

### 25. Rotation

```bash
# Rotate 90 degrees clockwise
ffmpeg -i input.jpg -vf "transpose=1" output.jpg

# Rotate 90 degrees counter-clockwise
ffmpeg -i input.jpg -vf "transpose=2" output.jpg

# Rotate 180 degrees
ffmpeg -i input.jpg -vf "transpose=1,transpose=1" output.jpg
# OR
ffmpeg -i input.jpg -vf "hflip,vflip" output.jpg

# Rotate 270 degrees clockwise (90 CCW)
ffmpeg -i input.jpg -vf "transpose=2" output.jpg

# Arbitrary angle rotation (45 degrees)
ffmpeg -i input.jpg -vf "rotate=45*PI/180" output.jpg

# Rotate with black background
ffmpeg -i input.jpg -vf "rotate=30*PI/180:fillcolor=black" output.jpg
```

### 26. Flipping

```bash
# Flip horizontally (mirror)
ffmpeg -i input.jpg -vf "hflip" output.jpg

# Flip vertically
ffmpeg -i input.jpg -vf "vflip" output.jpg

# Flip both (same as 180° rotation)
ffmpeg -i input.jpg -vf "hflip,vflip" output.jpg
```

### 27. Auto-Rotate Using EXIF

```bash
# Auto-rotate based on EXIF orientation
ffmpeg -i input.jpg -vf "transpose=1" output.jpg

# Preserve EXIF while rotating
ffmpeg -i input.jpg -vf "transpose=1" -map_metadata 0 output.jpg
```

---

## Image Filters and Effects

### 28. Color Adjustments

```bash
# Adjust brightness (-1.0 to 1.0, 0 = unchanged)
ffmpeg -i input.jpg -vf "eq=brightness=0.1" output.jpg

# Adjust contrast (-2.0 to 2.0, 1 = unchanged)
ffmpeg -i input.jpg -vf "eq=contrast=1.5" output.jpg

# Adjust saturation (0 = grayscale, 1 = unchanged, >1 = more saturated)
ffmpeg -i input.jpg -vf "eq=saturation=1.5" output.jpg

# Adjust gamma (0.1 to 10, 1 = unchanged)
ffmpeg -i input.jpg -vf "eq=gamma=1.2" output.jpg

# Multiple adjustments
ffmpeg -i input.jpg -vf "eq=brightness=0.05:contrast=1.2:saturation=1.3" output.jpg
```

### 29. Color Effects

```bash
# Convert to grayscale
ffmpeg -i input.jpg -vf "format=gray" output.jpg

# Sepia tone
ffmpeg -i input.jpg -vf "colorchannelmixer=.393:.769:.189:0:.349:.686:.168:0:.272:.534:.131" output.jpg

# Negative/Invert colors
ffmpeg -i input.jpg -vf "negate" output.jpg

# Color temperature adjustment (warming)
ffmpeg -i input.jpg -vf "colortemperature=5500" output.jpg

# Vibrance boost
ffmpeg -i input.jpg -vf "vibrance=intensity=0.5" output.jpg
```

### 30. Blur and Sharpen

```bash
# Gaussian blur
ffmpeg -i input.jpg -vf "gblur=sigma=5" output.jpg

# Box blur
ffmpeg -i input.jpg -vf "boxblur=5:1" output.jpg

# Sharpen image
ffmpeg -i input.jpg -vf "unsharp=5:5:1.0:5:5:0.0" output.jpg

# Strong sharpen
ffmpeg -i input.jpg -vf "unsharp=7:7:2.5" output.jpg

# Smart blur (preserves edges)
ffmpeg -i input.jpg -vf "smartblur=lr=1:ls=-0.5" output.jpg
```

### 31. Noise and Grain

```bash
# Add noise
ffmpeg -i input.jpg -vf "noise=alls=20:allf=t+u" output.jpg

# Remove noise
ffmpeg -i input.jpg -vf "hqdn3d=4:3:6:4.5" output.jpg

# Add film grain
ffmpeg -i input.jpg -vf "noise=c0s=7:c0f=t" output.jpg

# Denoise (temporal - for sequences)
ffmpeg -i input%03d.jpg -vf "nlmeans=s=2.0" output%03d.jpg
```

### 32. Edge Detection and Artistic Effects

```bash
# Edge detection
ffmpeg -i input.jpg -vf "edgedetect=low=0.1:high=0.4" output.jpg

# Cartoon effect
ffmpeg -i input.jpg -vf "edgedetect,negate" edges.jpg
ffmpeg -i input.jpg -i edges.jpg -filter_complex "[0][1]blend=all_mode=multiply" output.jpg

# Vignette effect
ffmpeg -i input.jpg -vf "vignette=angle=PI/4" output.jpg

# Emboss effect
ffmpeg -i input.jpg -vf "convolution='0 -1 0 -1 4 -1 0 -1 0:0 -1 0 -1 4 -1 0 -1 0:0 -1 0 -1 4 -1 0 -1 0:0 -1 0 -1 4 -1 0 -1 0'" output.jpg
```

### 33. Advanced Color Grading

```bash
# Color curves adjustment
ffmpeg -i input.jpg -vf "curves=preset=darker" output.jpg

# Available presets: lighter, darker, increase_contrast, vintage, etc.

# Custom LUT (Look-Up Table)
ffmpeg -i input.jpg -vf "lut3d=file=lut.cube" output.jpg

# Color balance
ffmpeg -i input.jpg -vf "colorbalance=rs=0.3:gs=-0.1:bs=-0.2" output.jpg

# Hue/saturation by color range
ffmpeg -i input.jpg -vf "hue=s=1.5:h=30" output.jpg
```

---

## Watermarking and Overlays

### 34. Basic Watermark

```bash
# Add watermark (top-left)
ffmpeg -i input.jpg -i watermark.png -filter_complex "overlay=10:10" output.jpg

# Add watermark (top-right)
ffmpeg -i input.jpg -i watermark.png -filter_complex "overlay=W-w-10:10" output.jpg

# Add watermark (bottom-right)
ffmpeg -i input.jpg -i watermark.png -filter_complex "overlay=W-w-10:H-h-10" output.jpg

# Add watermark (bottom-left)
ffmpeg -i input.jpg -i watermark.png -filter_complex "overlay=10:H-h-10" output.jpg

# Add watermark (centered)
ffmpeg -i input.jpg -i watermark.png -filter_complex "overlay=(W-w)/2:(H-h)/2" output.jpg
```

### 35. Watermark with Transparency

```bash
# Semi-transparent watermark
ffmpeg -i input.jpg -i watermark.png -filter_complex \
  "[1:v]format=rgba,colorchannelmixer=aa=0.5[logo]; \
   [0:v][logo]overlay=W-w-10:H-h-10" \
  output.jpg

# Fade watermark
ffmpeg -i input.jpg -i watermark.png -filter_complex \
  "[1:v]fade=in:0:30:alpha=1[logo]; \
   [0:v][logo]overlay=W-w-10:10" \
  output.jpg
```

### 36. Text Watermark

```bash
# Simple text watermark
ffmpeg -i input.jpg -vf "drawtext=text='Copyright 2025':x=10:y=H-th-10:fontsize=24:fontcolor=white" output.jpg

# Text with background box
ffmpeg -i input.jpg -vf \
  "drawtext=text='Copyright 2025':x=10:y=H-th-10:fontsize=24:fontcolor=white:box=1:boxcolor=black@0.5:boxborderw=5" \
  output.jpg

# Text with shadow
ffmpeg -i input.jpg -vf \
  "drawtext=text='Copyright 2025':x=10:y=H-th-10:fontsize=24:fontcolor=white:shadowcolor=black:shadowx=2:shadowy=2" \
  output.jpg

# Timestamp watermark
ffmpeg -i input.jpg -vf \
  "drawtext=text='%{localtime\:%Y-%m-%d %H\\\\\:%M\\\\\:%S}':x=10:y=10:fontsize=20:fontcolor=white:box=1:boxcolor=black@0.5" \
  output.jpg
```

### 37. Batch Watermarking

```bash
# Add watermark to all images
for i in *.jpg; do
  ffmpeg -i "$i" -i watermark.png -filter_complex \
    "overlay=W-w-10:H-h-10" \