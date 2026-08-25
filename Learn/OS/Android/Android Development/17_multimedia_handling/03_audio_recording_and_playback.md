## Audio Recording and Playback


Android audio handling encompasses recording, processing, and playback through multiple APIs designed for different use cases and performance requirements.

**Audio Recording**

MediaRecorder provides high-level audio recording functionality suitable for most applications. It handles encoding and file management automatically while supporting various audio formats and quality settings.

```kotlin
val mediaRecorder = MediaRecorder().apply {
    setAudioSource(MediaRecorder.AudioSource.MIC)
    setOutputFormat(MediaRecorder.OutputFormat.AAC_ADTS)
    setAudioEncoder(MediaRecorder.AudioEncoder.AAC)
    setOutputFile(outputFile)
}
```

AudioRecord offers low-level access to audio data streams, enabling real-time processing and custom encoding. This approach requires manual buffer management but provides maximum flexibility.

**Audio Playback**

MediaPlayer handles high-level audio playback with automatic format detection and decoding. It supports streaming audio and local files while managing buffering and playback state.

AudioTrack provides low-level audio output for applications requiring precise timing or custom audio processing. It operates with raw PCM data and offers minimal latency.

**Real-time Audio Processing**

Applications requiring low-latency audio processing use AudioTrack and AudioRecord with small buffer sizes. The AAudio API, introduced in Android 8.0, provides the lowest possible latency for professional audio applications.

**Audio Focus Management**

Proper audio focus handling ensures applications coexist respectfully with other audio sources. The AudioFocusRequest system manages audio priority and handles interruptions from calls, notifications, and other applications.

**Key Points:**

- Use MediaRecorder for standard recording requirements
- Implement AudioRecord for real-time processing needs
- Handle audio focus changes appropriately
- Consider background recording limitations and permissions
- Optimize buffer sizes for latency requirements

