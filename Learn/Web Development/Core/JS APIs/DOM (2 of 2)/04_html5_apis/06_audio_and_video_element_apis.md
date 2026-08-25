## Audio and Video Element APIs


### Media Element Interface Hierarchy

Both `<audio>` and `<video>` elements inherit from `HTMLMediaElement`, which provides the core API surface. The `<video>` element extends this through `HTMLVideoElement` with additional properties specific to visual rendering.

### Media Loading and Source Management

#### Source Selection and Network States

The `src` property accepts a single media URL, while the `<source>` element children enable multiple format fallbacks. The browser selects the first compatible source based on MIME type and codec strings.

```javascript
video.src = 'video.mp4';
// or
video.innerHTML = `
  <source src="video.webm" type="video/webm">
  <source src="video.mp4" type="video/mp4">
`;
video.load(); // Initiates resource selection algorithm
```

The `networkState` property tracks loading status:

- `NETWORK_EMPTY` (0): No source set
- `NETWORK_IDLE` (1): Source selected but not loading
- `NETWORK_LOADING` (2): Actively downloading
- `NETWORK_NO_SOURCE` (3): No compatible source found

The `readyState` indicates data availability:

- `HAVE_NOTHING` (0): No data
- `HAVE_METADATA` (1): Dimensions and duration known
- `HAVE_CURRENT_DATA` (2): Current frame available
- `HAVE_FUTURE_DATA` (3): Enough for immediate playback
- `HAVE_ENOUGH_DATA` (4): Enough to play through without stalling

#### Preload Strategies

The `preload` attribute controls resource loading behavior:

- `none`: Load nothing until play requested
- `metadata`: Load only metadata (duration, dimensions, tracks)
- `auto`: Load as much as appropriate (browser discretion)

```javascript
video.preload = 'metadata';
```

### Playback Control

#### Core Playback Methods

`play()` returns a Promise that resolves when playback begins or rejects if prevented:

```javascript
video.play()
  .then(() => console.log('Playing'))
  .catch(err => {
    if (err.name === 'NotAllowedError') {
      // Autoplay blocked by browser policy
    } else if (err.name === 'NotSupportedError') {
      // Source format unsupported
    }
  });
```

`pause()` stops playback synchronously. The `paused` property (boolean) indicates current state.

#### Playback Rate and Time Manipulation

`playbackRate` controls speed as a multiplier (0.5 = half speed, 2.0 = double speed). Negative values enable reverse playback in supporting browsers [Inference].

`currentTime` (in seconds) enables seeking:

```javascript
video.currentTime = 30.5; // Jump to 30.5 seconds
video.currentTime += 10; // Skip forward 10 seconds
```

The `duration` property provides total media length in seconds (NaN if unknown).

`defaultPlaybackRate` sets the initial rate, while `playbackRate` reflects the current rate.

### Buffering and Seeking

#### TimeRanges Interface

`buffered` returns a `TimeRanges` object representing downloaded byte ranges:

```javascript
const buffered = video.buffered;
for (let i = 0; i < buffered.length; i++) {
  console.log(`Range ${i}: ${buffered.start(i)} - ${buffered.end(i)}`);
}
```

`seekable` indicates which time ranges can be seeked to. `played` tracks ranges that have been played.

#### Seeking Operations

`seeking` (boolean) indicates if a seek is in progress. The `fastSeek()` method trades precision for speed:

```javascript
video.fastSeek(60); // Seek near 60s, may land on nearest keyframe
```

Events during seeking:

- `seeking`: Fired when seek begins
- `seeked`: Fired when seek completes
- `timeupdate`: Fires during playback (typically 4-60Hz)

### Audio Control

#### Volume and Muting

`volume` ranges from 0.0 to 1.0:

```javascript
video.volume = 0.5; // 50% volume
```

`muted` (boolean) silences audio without changing `volume`:

```javascript
video.muted = true;
```

[Inference] Setting `muted` likely bypasses volume calculations at a lower level for performance.

#### Audio Track Management

`audioTracks` returns an `AudioTrackList` for multi-audio content:

```javascript
const tracks = video.audioTracks;
for (let track of tracks) {
  console.log(track.label, track.language, track.enabled);
}
// Enable specific track
video.audioTracks[1].enabled = true;
```

### Video-Specific Properties

#### Dimensions and Aspect Ratio

`videoWidth` and `videoHeight` provide intrinsic video dimensions (readonly):

```javascript
const aspectRatio = video.videoWidth / video.videoHeight;
```

These differ from `width`/`height` attributes which set display size.

`poster` specifies an image URL displayed before playback:

```javascript
video.poster = 'thumbnail.jpg';
```

#### Presentation Modes

`requestFullscreen()` enters fullscreen mode (returns Promise):

```javascript
video.requestFullscreen()
  .catch(err => console.error('Fullscreen failed:', err));
```

`requestPictureInPicture()` creates floating video window:

```javascript
video.requestPictureInPicture()
  .then(pipWindow => {
    pipWindow.addEventListener('resize', () => {
      console.log(`PiP size: ${pipWindow.width}x${pipWindow.height}`);
    });
  });
```

Exit via `document.exitPictureInPicture()` or `document.exitFullscreen()`.

`disablePictureInPicture` attribute prevents PiP:

```javascript
video.disablePictureInPicture = true;
```

#### Playback Quality

`getVideoPlaybackQuality()` returns quality metrics:

```javascript
const quality = video.getVideoPlaybackQuality();
console.log({
  totalFrames: quality.totalVideoFrames,
  droppedFrames: quality.droppedVideoFrames,
  corruptedFrames: quality.corruptedVideoFrames,
  creationTime: quality.creationTime
});
```

### Text Track Management

#### TextTrack API

`textTracks` provides access to subtitles, captions, and descriptions:

```javascript
const tracks = video.textTracks;

// Add track dynamically
const track = video.addTextTrack('subtitles', 'English', 'en');
track.mode = 'showing'; // 'disabled', 'hidden', or 'showing'

// Add cues
const cue = new VTTCue(0, 5, 'First subtitle text');
track.addCue(cue);
```

Track `mode` values:

- `disabled`: Not loaded
- `hidden`: Loaded but not displayed (accessible to JS)
- `showing`: Displayed to user

Listen to cue changes:

```javascript
track.addEventListener('cuechange', () => {
  const activeCues = track.activeCues;
  for (let cue of activeCues) {
    console.log(cue.text);
  }
});
```

### Media Streams and Capture

#### Capturing to Canvas

`drawImage()` can render video frames to canvas:

```javascript
const canvas = document.createElement('canvas');
const ctx = canvas.getContext('2d');
canvas.width = video.videoWidth;
canvas.height = video.videoHeight;

function captureFrame() {
  ctx.drawImage(video, 0, 0);
  return canvas.toDataURL('image/png');
}
```

#### MediaStream Integration

`captureStream()` creates a live `MediaStream` from the media element:

```javascript
const stream = video.captureStream(); // or audio.captureStream()
const mediaRecorder = new MediaRecorder(stream);

mediaRecorder.ondataavailable = e => {
  // e.data contains recorded Blob chunks
};
mediaRecorder.start();
```

`srcObject` accepts `MediaStream` for WebRTC/getUserMedia:

```javascript
navigator.mediaDevices.getUserMedia({ video: true })
  .then(stream => {
    video.srcObject = stream;
  });
```

### Media Session API Integration

Control media notification UI and hardware keys:

```javascript
navigator.mediaSession.metadata = new MediaMetadata({
  title: 'Track Title',
  artist: 'Artist Name',
  album: 'Album Name',
  artwork: [
    { src: 'cover-96.png', sizes: '96x96', type: 'image/png' },
    { src: 'cover-512.png', sizes: '512x512', type: 'image/png' }
  ]
});

navigator.mediaSession.setActionHandler('play', () => video.play());
navigator.mediaSession.setActionHandler('pause', () => video.pause());
navigator.mediaSession.setActionHandler('seekbackward', () => {
  video.currentTime = Math.max(0, video.currentTime - 10);
});
navigator.mediaSession.setActionHandler('seekforward', () => {
  video.currentTime = Math.min(video.duration, video.currentTime + 10);
});
```

Supported actions include: `play`, `pause`, `seekbackward`, `seekforward`, `previoustrack`, `nexttrack`, `skipad`, `stop`, `seekto`, `togglemicrophone`, `togglecamera`, `hangup`.

### Media Events Lifecycle

#### Loading Events

- `loadstart`: Resource loading begins
- `durationchange`: `duration` attribute updated
- `loadedmetadata`: Metadata loaded (`readyState` ≥ HAVE_METADATA)
- `loadeddata`: First frame loaded (`readyState` ≥ HAVE_CURRENT_DATA)
- `progress`: Browser receiving data
- `canplay`: Playback can start (`readyState` ≥ HAVE_FUTURE_DATA)
- `canplaythrough`: Can play through without buffering (`readyState` = HAVE_ENOUGH_DATA)

#### Playback Events

- `play`: Playback requested (via `play()` or autoplay)
- `playing`: Playback started after being paused or delayed
- `pause`: Paused
- `ended`: Playback reached the end
- `timeupdate`: `currentTime` changed
- `waiting`: Playback stopped due to buffering
- `stalled`: Browser attempting to fetch but not receiving data

#### State Change Events

- `volumechange`: Volume or muted state changed
- `ratechange`: `playbackRate` changed
- `seeking`: Seek operation started
- `seeked`: Seek operation completed
- `suspend`: Loading suspended (browser discretion)
- `abort`: Resource loading aborted (not due to error)
- `error`: Fatal error occurred
- `emptied`: Media element reset to empty state

### Error Handling

#### MediaError Interface

`error` property contains a `MediaError` object on failure:

```javascript
video.addEventListener('error', () => {
  const error = video.error;
  
  switch(error.code) {
    case MediaError.MEDIA_ERR_ABORTED:
      console.error('Fetch aborted by user');
      break;
    case MediaError.MEDIA_ERR_NETWORK:
      console.error('Network error during download');
      break;
    case MediaError.MEDIA_ERR_DECODE:
      console.error('Decoding error');
      break;
    case MediaError.MEDIA_ERR_SRC_NOT_SUPPORTED:
      console.error('Format not supported');
      break;
  }
  
  console.error('Message:', error.message);
});
```

Error codes:

- `MEDIA_ERR_ABORTED` (1): User aborted
- `MEDIA_ERR_NETWORK` (2): Network failure
- `MEDIA_ERR_DECODE` (3): Decode error
- `MEDIA_ERR_SRC_NOT_SUPPORTED` (4): Unsupported format

### Remote Playback API

Control casting to remote devices:

```javascript
video.remote.watchAvailability(available => {
  if (available) {
    // Show cast button
  }
});

video.remote.prompt()
  .then(() => console.log('Connected to remote device'))
  .catch(err => console.error('Connection failed:', err));

video.remote.addEventListener('connecting', () => {
  console.log('Connecting...');
});

video.remote.addEventListener('connect', () => {
  console.log('Connected');
});

video.remote.addEventListener('disconnect', () => {
  console.log('Disconnected');
});

console.log(video.remote.state); // 'disconnected', 'connecting', or 'connected'
```

### Encrypted Media Extensions (EME)

Handle DRM-protected content:

```javascript
video.addEventListener('encrypted', e => {
  const config = [{
    initDataTypes: ['cenc'],
    videoCapabilities: [{
      contentType: 'video/mp4;codecs="avc1.42E01E"'
    }]
  }];
  
  navigator.requestMediaKeySystemAccess('com.widevine.alpha', config)
    .then(keySystemAccess => keySystemAccess.createMediaKeys())
    .then(mediaKeys => {
      video.setMediaKeys(mediaKeys);
      const session = mediaKeys.createSession();
      
      session.addEventListener('message', event => {
        // Send event.message to license server
        // Receive license response
        // session.update(licenseResponse);
      });
      
      return session.generateRequest(e.initDataType, e.initData);
    });
});
```

Key system identifiers [Unverified - these may vary]:

- `com.widevine.alpha`: Widevine
- `com.microsoft.playready`: PlayReady
- `com.apple.fps`: FairPlay

### Media Source Extensions (MSE)

Programmatic media stream construction:

```javascript
const mediaSource = new MediaSource();
video.src = URL.createObjectURL(mediaSource);

mediaSource.addEventListener('sourceopen', () => {
  const sourceBuffer = mediaSource.addSourceBuffer('video/mp4; codecs="avc1.42E01E"');
  
  fetch('segment1.m4s')
    .then(response => response.arrayBuffer())
    .then(data => {
      sourceBuffer.appendBuffer(data);
    });
  
  sourceBuffer.addEventListener('updateend', () => {
    if (!sourceBuffer.updating && mediaSource.readyState === 'open') {
      // Can append more segments or call mediaSource.endOfStream()
    }
  });
});
```

`MediaSource` properties:

- `duration`: Media duration (writable)
- `readyState`: 'closed', 'open', or 'ended'
- `sourceBuffers`: List of `SourceBuffer` objects
- `activeSourceBuffers`: Currently selected buffers

`SourceBuffer` methods:

- `appendBuffer(data)`: Add media data
- `remove(start, end)`: Remove time range
- `abort()`: Abort current segment append
- `changeType(type)`: Change codec mid-stream

### Audio-Specific Features

#### Spatial Audio

[Inference] The `AudioContext` integration provides advanced spatial audio, though this typically requires the Web Audio API rather than direct media element methods.

Create an audio source node from the element:

```javascript
const audioCtx = new AudioContext();
const source = audioCtx.createMediaElementSource(audio);
const panner = audioCtx.createPanner();

panner.panningModel = 'HRTF';
panner.setPosition(1, 0, 0); // Right speaker

source.connect(panner);
panner.connect(audioCtx.destination);
```

### Looping and Playback Control

`loop` (boolean) enables continuous playback:

```javascript
audio.loop = true;
```

`ended` property indicates playback completion:

```javascript
video.addEventListener('ended', () => {
  console.log('Video finished');
  if (!video.loop) {
    // Show replay button
  }
});
```

### Autoplay Policies

Autoplay behavior varies by browser and user interaction:

```javascript
video.autoplay = true;
video.muted = true; // Muted autoplay more likely to succeed

video.play().catch(err => {
  if (err.name === 'NotAllowedError') {
    // Show play button, require user interaction
    playButton.addEventListener('click', () => {
      video.play();
    });
  }
});
```

[Inference] Browsers generally allow muted autoplay but block unmuted autoplay without user interaction to prevent disruptive experiences.

### CORS and Credentials

`crossOrigin` attribute controls CORS behavior:

```javascript
video.crossOrigin = 'anonymous'; // or 'use-credentials'
```

Without proper CORS headers, canvas tainting occurs [Inference], preventing `toDataURL()` and `getImageData()` on canvases containing the video.

### Performance Considerations

#### Hardware Acceleration

[Unverified] Browsers typically use hardware decoding for supported codecs, but forcing software fallback isn't standardized in the API.

#### Memory Management

`load()` resets the element and releases resources:

```javascript
video.pause();
video.removeAttribute('src');
video.load(); // Releases memory
```

Setting `srcObject = null` or `src = ''` alone may not immediately free resources [Inference].

### Controls and UI

`controls` (boolean) shows browser default controls:

```javascript
video.controls = true;
```

`controlsList` restricts specific controls (Chrome/Edge):

```javascript
video.controlsList = 'nodownload nofullscreen noremoteplayback';
```

[Unverified] The `controlsList` feature may not be standardized across all browsers.

### Mobile-Specific Behavior

`playsInline` prevents fullscreen on iOS:

```javascript
video.playsInline = true;
```

Without this, iOS Safari automatically enters fullscreen on play [Inference based on historical iOS behavior, though policies may have changed].

### Codec Support Detection

Query format support before loading:

```javascript
const canPlayMP4 = video.canPlayType('video/mp4; codecs="avc1.42E01E"');
// Returns: '', 'maybe', or 'probably'

if (canPlayMP4 === 'probably' || canPlayMP4 === 'maybe') {
  video.src = 'video.mp4';
}
```

`MediaSource.isTypeSupported()` for MSE compatibility:

```javascript
if (MediaSource.isTypeSupported('video/mp4; codecs="avc1.42E01E"')) {
  // Use MSE with this codec
}
```

### Advanced Synchronization

Multiple media elements can be synchronized via `currentTime` manipulation:

```javascript
const videos = [video1, video2];
let syncing = false;

videos.forEach(v => {
  v.addEventListener('timeupdate', () => {
    if (!syncing) {
      syncing = true;
      const targetTime = v.currentTime;
      videos.forEach(other => {
        if (other !== v && Math.abs(other.currentTime - targetTime) > 0.1) {
          other.currentTime = targetTime;
        }
      });
      syncing = false;
    }
  });
});
```

[Inference] Perfect frame-level synchronization across separate elements is difficult to achieve due to independent decode pipelines and rendering timing.

---

