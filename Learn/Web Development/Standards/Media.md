# Syllabus

## Module 1: Media Fundamentals

- Digital media basics
- Media types and formats
- Compression concepts
- Codecs overview
- Container formats
- Bitrate and quality relationship
- Streaming vs progressive download
- Media delivery methods
- Bandwidth considerations
- Media file structure

## Module 2: HTML5 Audio Element

- `<audio>` element syntax
- Audio element attributes
- src attribute
- controls attribute
- autoplay attribute
- loop attribute
- muted attribute
- preload attribute values
- Audio element methods
- play() and pause()
- load() method
- Audio element properties
- currentTime property
- duration property
- volume property
- playbackRate property
- Audio element events
- loadstart, loadedmetadata, loadeddata
- canplay, canplaythrough
- play, pause, ended
- timeupdate event
- error event handling
- Multiple source elements
- Browser codec support detection
- Fallback content strategies

## Module 3: HTML5 Video Element

- `<video>` element syntax
- Video element attributes
- poster attribute
- width and height attributes
- Video-specific attributes
- playsinline attribute
- disablePictureInPicture
- Video element methods
- requestFullscreen()
- exitFullscreen()
- requestPictureInPicture()
- Video element properties
- videoWidth and videoHeight
- readyState property
- networkState property
- Video element events
- Same as audio plus video-specific
- Text track integration
- Responsive video techniques
- Aspect ratio preservation
- Video accessibility

## Module 4: Audio Codecs and Formats

- MP3 (MPEG-1 Audio Layer 3)
- AAC (Advanced Audio Coding)
- Ogg Vorbis
- Opus codec
- FLAC (lossless)
- WAV format
- WebM audio
- Codec licensing considerations
- Browser codec support matrix
- Codec selection criteria
- Transcoding strategies
- Audio quality metrics
- Lossy vs lossless compression

## Module 5: Video Codecs and Formats

- H.264/AVC
- H.265/HEVC
- VP8 codec
- VP9 codec
- AV1 codec
- MPEG-4 formats
- WebM container
- MP4 container
- Ogg container
- Codec profiles and levels
- Hardware acceleration support
- Adaptive codec selection
- Video quality assessment
- Encoding presets and tuning

## Module 6: Media Encoding and Transcoding

- Encoding workflow
- FFmpeg basics
- HandBrake usage
- Cloud encoding services
- AWS Elemental MediaConvert
- Google Transcoder API
- Azure Media Services encoding
- Encoding parameters
- Resolution and scaling
- Frame rate considerations
- Keyframe intervals
- Two-pass encoding
- Variable vs constant bitrate
- Multi-bitrate encoding
- Quality-based encoding
- Adaptive bitrate preparation

## Module 7: Web Audio API

- AudioContext creation
- Audio nodes architecture
- Source nodes
- AudioBufferSourceNode
- MediaElementAudioSourceNode
- OscillatorNode
- MediaStreamAudioSourceNode
- Processing nodes
- GainNode
- BiquadFilterNode
- ConvolverNode
- DynamicsCompressorNode
- DelayNode
- WaveShaperNode
- StereoPannerNode
- ChannelSplitterNode
- ChannelMergerNode
- Destination nodes
- Audio routing and graph creation
- Audio scheduling
- Audio visualization
- AnalyserNode
- Frequency and time domain analysis
- Spatial audio
- PannerNode
- AudioListener
- HRTF (Head-Related Transfer Function)
- Audio worklets
- Custom audio processing
- Web Audio API best practices

## Module 8: Media Source Extensions (MSE)

- MSE architecture overview
- MediaSource object
- SourceBuffer management
- Appending media segments
- Buffer management strategies
- Byte ranges and seeking
- Timestamp handling
- MSE events
- sourceopen, sourceended, sourceclose
- updatestart, update, updateend
- Error handling in MSE
- MSE with adaptive streaming
- MSE browser support
- MSE limitations
- MSE debugging techniques

## Module 9: Adaptive Streaming Technologies

- Adaptive Bitrate Streaming (ABR) concepts
- HTTP Live Streaming (HLS)
- M3U8 manifest format
- HLS playlist types
- HLS variants and renditions
- Dynamic Adaptive Streaming over HTTP (DASH)
- MPD (Media Presentation Description)
- DASH profiles
- Segment formats
- Common Media Application Format (CMAF)
- Smooth Streaming (legacy)
- ABR algorithms
- Bitrate selection logic
- Buffer-based selection
- Bandwidth estimation
- Quality switching strategies

## Module 10: HLS (HTTP Live Streaming)

- HLS protocol overview
- Master playlist structure
- Media playlist structure
- Segment duration optimization
- EXT-X-VERSION tag
- EXT-X-STREAM-INF attributes
- BANDWIDTH attribute
- RESOLUTION attribute
- CODECS attribute
- EXT-X-MEDIA tags
- Audio and subtitle tracks
- EXT-X-TARGETDURATION
- EXT-X-PLAYLIST-TYPE
- VOD vs Live playlists
- Low-Latency HLS (LL-HLS)
- HLS server-side requirements
- HLS.js library
- Native HLS support (Safari)

## Module 11: DASH (Dynamic Adaptive Streaming)

- DASH specification overview
- MPD structure and syntax
- Period elements
- AdaptationSet elements
- Representation elements
- SegmentTemplate
- SegmentList
- SegmentBase
- Initialization segments
- Media segments
- DASH profiles
- On-Demand profile
- Live profile
- Main profile
- dash.js library
- Shaka Player integration
- DASH manifest generation

## Module 12: Encrypted Media Extensions (EME)

- EME architecture
- Content Decryption Modules (CDM)
- MediaKeys object
- MediaKeySession
- Key system identification
- License acquisition flow
- DRM integration
- Widevine
- PlayReady
- FairPlay Streaming
- ClearKey system
- Common Encryption (CENC)
- PSSH boxes
- Multi-DRM strategies
- EME events and error handling
- Key rotation
- License persistence
- Offline playback with DRM

## Module 13: Digital Rights Management (DRM)

- DRM concepts and purpose
- DRM systems comparison
- Google Widevine
- Microsoft PlayReady
- Apple FairPlay
- DRM license servers
- License policies
- Rental and purchase models
- Device limits
- Output control
- HDCP requirements
- DRM proxy services
- Multi-DRM implementation
- DRM testing and debugging
- Watermarking integration

## Module 14: Video Player Development

- Custom player architecture
- Player controls UI
- Play/pause button
- Progress bar implementation
- Volume control
- Fullscreen toggle
- Settings menu
- Quality selector
- Playback rate control
- Keyboard shortcuts
- Player state management
- Responsive player design
- Touch controls for mobile
- Accessibility features
- ARIA attributes for players
- Screen reader support
- Player skinning and theming

## Module 15: Popular Video Players

- Video.js
- Video.js architecture
- Plugin system
- Customization options
- Plyr
- Lightweight player features
- JW Player
- Commercial player features
- Shaka Player
- DASH and HLS support
- MSE integration
- Bitmovin Player
- Analytics integration
- hls.js
- HLS playback implementation
- dash.js
- DASH playback implementation
- Player comparison and selection

## Module 16: Media Streaming Protocols

- RTMP (Real-Time Messaging Protocol)
- RTMP vs RTMPS
- RTSP (Real-Time Streaming Protocol)
- WebRTC for streaming
- Low-latency streaming
- SRT (Secure Reliable Transport)
- MPEG-TS over HTTP
- Chunked Transfer Encoding
- Protocol selection criteria
- Latency considerations
- Scalability factors

## Module 17: Live Streaming

- Live streaming workflow
- Encoder setup
- OBS Studio
- FFmpeg for live streaming
- Hardware encoders
- Ingest protocols
- RTMP ingest
- SRT ingest
- WebRTC ingest
- Transcoding for live streams
- DVR functionality
- Time-shifting
- Live-to-VOD recording
- Low-latency live streaming
- Ultra-low-latency techniques
- Live streaming CDN integration

## Module 18: WebRTC (Web Real-Time Communication)

- WebRTC architecture
- Peer-to-peer communication
- Signaling server requirements
- ICE (Interactive Connectivity Establishment)
- STUN servers
- TURN servers
- NAT traversal
- getUserMedia API
- Media stream constraints
- RTCPeerConnection
- Offer/Answer model
- SDP (Session Description Protocol)
- RTCDataChannel
- WebRTC video quality
- Codec negotiation
- Bandwidth management
- WebRTC for live streaming
- Simulcast
- SFU (Selective Forwarding Unit)
- MCU (Multipoint Control Unit)

## Module 19: Media Capture and Recording

- getUserMedia API
- Camera access
- Microphone access
- Constraints and capabilities
- Screen capture
- getDisplayMedia API
- MediaRecorder API
- Recording streams
- Output formats
- Blob handling
- Canvas recording
- captureStream() method
- Audio context recording
- Client-side media processing
- Recording permissions
- Device selection UI

## Module 20: Subtitles and Captions

- WebVTT format
- VTT file structure
- Cue syntax
- Timestamp format
- Cue settings
- Line positioning
- Text alignment
- TTML (Timed Text Markup Language)
- SRT (SubRip) format
- Track element
- kind attribute values
- subtitles, captions, descriptions
- chapters, metadata
- srclang attribute
- label attribute
- TextTrack API
- Cue manipulation
- Styling cues
- ::cue pseudo-element
- Multi-language support
- Automatic caption generation
- Caption positioning
- Accessibility requirements

## Module 21: Audio Visualization

- Canvas-based visualization
- AnalyserNode usage
- Frequency data extraction
- Time domain data
- FFT (Fast Fourier Transform)
- Waveform rendering
- Spectrum analyzers
- Bar visualizers
- Circular visualizers
- Particle effects with audio
- WebGL audio visualization
- Three.js audio integration
- Real-time visualization performance
- Visualization libraries
- p5.js for audio
- Peaks.js for waveforms

## Module 22: Media Performance Optimization

- Buffer management strategies
- Preloading techniques
- Lazy loading media
- Progressive enhancement
- Bandwidth detection
- Network Information API
- Adaptive quality selection
- Prefetching segments
- Service Workers for media caching
- Cache API for media
- Offline media playback
- Media compression techniques
- Image optimization for posters
- CDN optimization for media
- HTTP/2 for media delivery
- HTTP/3 benefits

## Module 23: Media CDN and Delivery

- CDN architecture for media
- Origin servers
- Edge servers
- Cache control headers
- Byte-range requests
- Partial content delivery
- CDN token authentication
- Signed URLs
- Geographic restrictions
- CDN providers
- Cloudflare Stream
- AWS CloudFront
- Akamai
- Fastly
- Azure CDN
- Multi-CDN strategies
- CDN failover
- CDN performance monitoring

## Module 24: Video-on-Demand (VOD) Platforms

- VOD architecture
- Media asset management
- Metadata management
- Thumbnail generation
- Preview clips
- Storyboard creation
- Search and discovery
- Recommendation systems
- Playlist management
- Watch history tracking
- Resume playback
- Bookmarking
- VOD analytics
- Engagement metrics
- QoS (Quality of Service) monitoring

## Module 25: Media Analytics

- Playback analytics
- Play rate
- Completion rate
- Engagement metrics
- Buffering events tracking
- Quality metrics
- Video startup time
- Rebuffering ratio
- Bitrate distribution
- Error tracking
- User behavior analytics
- Heatmaps for video content
- A/B testing for players
- Analytics integration
- Google Analytics for media
- Mux Data
- Conviva
- NPAW (Nice People At Work)
- Custom analytics implementation
- Real-time analytics dashboards

## Module 26: Picture-in-Picture (PiP)

- PiP API overview
- requestPictureInPicture()
- exitPictureInPicture()
- PiP events
- enterpictureinpicture
- leavepictureinpicture
- PiP window customization
- PiP browser support
- PiP use cases
- PiP on mobile
- iOS Safari PiP
- Android Chrome PiP
- PiP accessibility
- Disabling PiP

## Module 27: Fullscreen API

- requestFullscreen() method
- exitFullscreen() method
- fullscreenElement property
- fullscreenEnabled property
- Fullscreen events
- fullscreenchange
- fullscreenerror
- Vendor prefixes handling
- Fullscreen styling
- ::backdrop pseudo-element
- Keyboard input in fullscreen
- Fullscreen security considerations
- Mobile fullscreen behavior
- Landscape mode enforcement

## Module 28: Media Session API

- MediaSession interface
- Metadata configuration
- title, artist, album
- artwork array
- Media session actions
- play, pause, stop
- seekbackward, seekforward
- seekto
- previoustrack, nexttrack
- Hardware media keys integration
- Lock screen controls
- Notification controls
- Android Auto integration
- CarPlay integration
- Browser support and polyfills

## Module 29: Background Audio

- Audio playback when tab is inactive
- Page Visibility API integration
- Background tab throttling
- Mobile background playback
- iOS audio session management
- Android audio focus
- Background playback best practices
- Battery consumption considerations
- Background sync for media
- Offline audio playback
- Audio routing

## Module 30: 360-Degree Video

- 360-degree video concepts
- Equirectangular projection
- Cubemap projection
- Monoscopic vs stereoscopic
- 360-degree video encoding
- Metadata injection
- Spatial audio for 360 video
- Ambisonic audio
- 360-degree video players
- Three.js for 360 video
- A-Frame for 360 video
- Gyroscope integration
- Touch controls for panning
- VR headset support
- 360-degree video streaming

## Module 31: WebXR (Extended Reality)

- WebXR Device API
- XR session types
- Immersive VR sessions
- Immersive AR sessions
- Inline sessions
- XR reference spaces
- Viewer reference space
- Local reference space
- Bounded-floor reference space
- Unbounded reference space
- XR input sources
- Controllers and hands
- Gaze-based interaction
- WebXR rendering
- XRWebGLLayer
- WebXR pose tracking
- Room-scale experiences
- WebXR browser support
- WebXR polyfills

## Module 32: WebVR (Deprecated)

- WebVR API overview (legacy)
- VR display detection
- VRDisplay interface
- Requesting present
- VR pose information
- Migration from WebVR to WebXR
- Legacy browser support
- Polyfill strategies

## Module 33: Augmented Reality (AR)

- WebXR AR features
- Hit testing
- Plane detection
- Anchors
- Light estimation
- DOM overlay
- AR.js library
- Marker-based AR
- Location-based AR
- 8th Wall platform
- ARCore and ARKit web integration
- AR content creation
- 3D model formats for AR
- GLTF and GLB files

## Module 34: Spatial Audio

- Spatial audio concepts
- Binaural audio
- HRTF processing
- Audio spatialization APIs
- PannerNode for 3D audio
- Distance modeling
- Cone properties
- Doppler effect
- Ambisonic audio
- First-order ambisonics
- Higher-order ambisonics
- Ambisonics decoding
- Resonance Audio SDK
- Spatial audio for VR/AR
- Head tracking integration

## Module 35: Media Metadata

- ID3 tags
- ID3v1 and ID3v2
- Vorbis comments
- MP4 metadata atoms
- Metadata extraction
- MediaInfo library
- FFprobe for metadata
- Metadata editing
- Album art embedding
- Metadata standards
- MusicBrainz
- Schema.org media markup
- Open Graph for media
- Twitter Cards for media
- Metadata APIs

## Module 36: Thumbnail Generation

- Video thumbnail extraction
- Canvas-based thumbnail creation
- Server-side thumbnail generation
- FFmpeg thumbnail extraction
- Sprite sheets for seeking
- Thumbnail preview on hover
- VTT thumbnails
- Responsive thumbnails
- Thumbnail optimization
- Lazy loading thumbnails
- Thumbnail CDN delivery
- Animated thumbnails
- GIF vs video formats
- Thumbnail caching strategies

## Module 37: Video Editing in Browser

- Client-side video editing
- Canvas manipulation
- Video filters and effects
- Trimming and cutting
- Concatenating videos
- Transitions between clips
- Text and graphics overlay
- Chroma keying
- Color correction
- FFmpeg.js for browser editing
- WebAssembly video processing
- Real-time editing preview
- Export and rendering
- Browser editing limitations
- Video editing libraries
- Remotion for programmatic video

## Module 38: Media Accessibility

- WCAG media guidelines
- Audio descriptions
- Descriptive audio tracks
- Sign language interpretation
- Closed captions requirements
- Open captions
- Caption styling options
- High contrast captions
- Caption synchronization
- Keyboard navigation for players
- Focus management
- ARIA live regions for media
- Accessible player controls
- Transcript provision
- Audio-only alternatives
- Motion sensitivity considerations
- Prefers-reduced-motion
- Seizure and photosensitivity
- Accessible media forms

## Module 39: Progressive Web Apps (PWA) Media

- Media in PWA context
- Offline media playback
- Service Worker caching strategies
- Cache-first for media
- Network-first with fallback
- Background fetch API
- Large file downloads
- Media notifications
- Badging API for media apps
- Share Target API
- Receiving shared media
- Install prompts for media apps
- Standalone display mode
- Media session in PWA

## Module 40: Media on Mobile Web

- Mobile video formats
- Mobile codec support
- Autoplay policies on mobile
- iOS autoplay restrictions
- Android autoplay behavior
- Inline playback on iOS
- playsinline attribute
- Mobile data saving
- Save-Data header
- Reduced motion preferences
- Mobile battery considerations
- Touch gesture controls
- Mobile fullscreen APIs
- Mobile network conditions
- Cellular vs WiFi detection
- Mobile-specific player UX

## Module 41: Media Compression Techniques

- Lossy vs lossless compression
- Intra-frame compression
- Inter-frame compression
- Motion compensation
- Transform coding
- Quantization
- Entropy coding
- Chroma subsampling
- 4:2:0, 4:2:2, 4:4:4
- Perceptual coding
- Psychoacoustic modeling
- Rate-distortion optimization
- Compression artifacts
- Blockiness and banding
- Compression quality metrics
- PSNR (Peak Signal-to-Noise Ratio)
- SSIM (Structural Similarity Index)
- VMAF (Video Multimethod Assessment Fusion)

## Module 42: Media Color Science

- Color spaces
- RGB color space
- YUV color space
- Color primaries
- Rec. 601
- Rec. 709
- Rec. 2020
- DCI-P3
- Transfer functions
- Gamma correction
- PQ (Perceptual Quantizer)
- HLG (Hybrid Log-Gamma)
- HDR (High Dynamic Range)
- HDR10
- Dolby Vision
- HLG for HDR
- SDR to HDR conversion
- Color grading for web
- Wide color gamut support

## Module 43: Video Resolution and Formats

- Standard Definition (SD)
- 720p (HD)
- 1080p (Full HD)
- 1440p (2K)
- 2160p (4K/UHD)
- 4320p (8K)
- Aspect ratios
- 16:9 widescreen
- 4:3 standard
- 21:9 ultrawide
- 1:1 square video
- Vertical video (9:16)
- Frame rates
- 24fps (cinema)
- 30fps and 29.97fps
- 60fps and high frame rate
- Variable frame rate
- Interlaced vs progressive
- Deinterlacing techniques

## Module 44: Audio Mixing and Mastering

- Audio mixing concepts
- Multi-track audio
- Panning and stereo imaging
- EQ (Equalization)
- Compression and limiting
- Normalization
- Loudness standards
- LUFS (Loudness Units Full Scale)
- EBU R128
- ATSC A/85
- Mastering for web delivery
- Peak vs RMS levels
- Dynamic range considerations
- Audio ducking
- Crossfading
- Audio transitions

## Module 45: Media Testing and QA

- Cross-browser testing
- BrowserStack for media
- Device testing matrix
- Codec support testing
- Playback quality testing
- Buffering and stuttering detection
- Audio/video synchronization testing
- Automated media testing
- Selenium for media tests
- Puppeteer for media automation
- Performance testing
- Load testing media servers
- Stress testing players
- Network throttling tests
- Accessibility testing for media
- Caption accuracy verification

## Module 46: Media Monetization

- Video advertising
- Pre-roll ads
- Mid-roll ads
- Post-roll ads
- Ad pods
- VAST (Video Ad Serving Template)
- VPAID (Video Player-Ad Interface)
- VMAP (Video Multiple Ad Playlist)
- IMA SDK (Interactive Media Ads)
- Client-side ad insertion
- Server-side ad insertion (SSAI)
- Ad stitching
- Ad blockers detection
- Ad-free subscription models
- Paywall implementation
- Token-based access control
- Transactional video-on-demand (TVOD)
- Subscription video-on-demand (SVOD)

## Module 47: Media SEO

- Video SEO best practices
- Video sitemaps
- VideoObject schema markup
- Thumbnail optimization for SEO
- Video titles and descriptions
- Transcript for SEO
- Video hosting considerations
- Self-hosted vs YouTube
- Embedding and SEO impact
- Social media video optimization
- Open Graph video tags
- Twitter Card video
- Rich snippets for video
- Video in search results
- YouTube optimization
- Vimeo optimization

## Module 48: Media Workflows and Automation

- Media pipeline architecture
- Automated transcoding workflows
- AWS MediaConvert workflows
- Cloud Functions for media processing
- Webhook-based automation
- Media asset versioning
- Automated quality control
- Automated metadata extraction
- Batch processing
- Parallel processing strategies
- Queue management
- Job scheduling
- Error handling and retries
- Workflow monitoring
- Media workflow orchestration tools

## Module 49: Media Storage Solutions

- Object storage for media
- Amazon S3
- Google Cloud Storage
- Azure Blob Storage
- Storage classes and tiers
- Hot, cool, cold storage
- Lifecycle policies
- Storage cost optimization
- Deduplication
- Versioning
- Replication strategies
- Cross-region replication
- Backup and disaster recovery
- Media archive solutions
- Glacier and deep archive
- Database for media metadata
- Content management systems (CMS)

## Module 50: WebCodecs API

- WebCodecs API overview
- VideoEncoder interface
- VideoDecoder interface
- AudioEncoder interface
- AudioDecoder interface
- Encoded video chunks
- Encoded audio chunks
- VideoFrame interface
- AudioData interface
- Low-level codec access
- Custom encoding pipelines
- Real-time encoding/decoding
- WebCodecs use cases
- WebCodecs browser support
- Performance considerations

## Module 51: Web Assembly for Media

- WebAssembly (WASM) basics
- FFmpeg.wasm
- Video transcoding in browser
- Audio processing with WASM
- Codec implementations in WASM
- H.264 encoding/decoding
- Performance optimization with WASM
- SIMD support in WASM
- Threading in WASM
- Emscripten for media libraries
- WASM module loading
- Memory management in WASM
- JavaScript and WASM interop
- WASM for media filters

## Module 52: Media AI and Machine Learning

- AI-powered video analysis
- Object detection in video
- Face recognition
- Scene detection
- Content moderation
- Automated tagging
- Thumbnail selection with AI
- AI-based transcoding optimization
- Speech-to-text for captions
- Translation services
- Content recommendation engines
- Personalization with ML
- TensorFlow.js for media
- ML model deployment
- Edge AI for media processing

## Module 53: Cloud Media Services

- AWS Media Services
- MediaConvert
- MediaLive
- MediaPackage
- MediaStore
- MediaTailor
- Google Cloud Media
- Transcoder API
- Live Stream API
- Video Stitcher API
- Azure Media Services
- Encoding
- Streaming Endpoints
- Content Protection
- Cloudflare Stream
- Mux Video Platform
- Brightcove
- JW Player Platform

## Module 54: Media Standards Organizations

- W3C media specifications
- WHATWG media standards
- MPEG standards body
- ISO/IEC media standards
- ITU standards
- CTA (Consumer Technology Association)
- SMPTE standards
- EBU standards
- DVB Project
- HbbTV standards
- Standards compliance testing
- Certification programs

## Module 55: Emerging Media Technologies

- AV1 adoption
- VVC (Versatile Video Coding)
- LCEVC (Low Complexity Enhancement Video Coding)
- Next-generation codecs
- Immersive audio formats
- MPEG-H 3D Audio
- Dolby Atmos for web
- Volumetric video
- Point cloud compression
- Neural video compression
- AI-based codecs
- Cloud gaming streaming
- Interactive video technologies
- Shoppable video
- Branching narratives

## Module 56: Media Compliance and Regulations

- Copyright compliance
- DMCA takedown procedures
- Content ID systems
- Rights management
- Broadcast standards compliance
- FCC regulations
- Accessibility regulations (508, ADA)
- GDPR for media data
- Age-appropriate content
- Content rating systems
- Geographical restrictions
- Export control for codecs
- Patent licensing
- Royalty-free codecs
- Industry self-regulation

## Module 57: Media Documentation

- API documentation for media
- Player integration guides
- Encoding guides
- Troubleshooting documentation
- Performance tuning guides
- Security guidelines
- Best practices documentation
- Architecture diagrams
- Data flow documentation
- Code examples and samples
- Video tutorials
- Knowledge base articles
- Change logs and release notes
- Migration guides

## Module 58: Media Community and Resources

- Industry conferences
- NAB Show
- IBC (International Broadcasting Convention)
- Demuxed
- Online communities
- Stack Overflow for media
- Reddit communities
- Discord servers
- Open-source projects
- FFmpeg project
- Video.js community
- Shaka Player development
- Research papers and journals
- Blogs and newsletters
- Streaming Media
- Video standards mailing lists