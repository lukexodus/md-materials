## Screen Recording


Screen recording captures display content and audio for documentation, tutorials, and content creation on Hyprland. Wayland-native solutions offer compositor-level integration without X11 dependency issues.[1][2]

### Wf-Recorder (Lightweight)

**Wf-Recorder** is a minimal screen recorder designed specifically for Wayland. Install on Arch Linux with `sudo pacman -S wf-recorder`.[2][1]

Record entire screen:[1]
```bash
wf-recorder -o output.mp4
```


Stop recording by pressing Ctrl+C or sending SIGINT.[1]

Record specific region:[1]
```bash
wf-recorder -g "$(slurp)" -o output.mp4
```


Record specific monitor:[1]
```bash
wf-recorder -o DP-1 -o output.mp4
```


### Wf-Recorder with Audio

Capture system audio during recording:[1]

List available audio sources:[1]
```bash
pactl list sources
```


Record with audio:[1]
```bash
wf-recorder --audio=alsa_output.pci-0000_00_1f.3.analog-stereo -o output.mp4
```


Record microphone only:[1]
```bash
wf-recorder --audio=alsa_input.usb-0c0ef00d_USB_Microphone-00.mono-fallback -o output.mp4
```


### Wf-Recorder Codec Options

Change video codec and quality:[1]
```bash
wf-recorder -c h264 -o output.mp4  # H.264 codec
wf-recorder -c vp9 -o output.webm  # VP9 codec (WebM)
```


Adjust bitrate for file size/quality:[1]
```bash
wf-recorder -b 5000k -o output.mp4  # 5000 kbps
wf-recorder -b 10000k -o output.mp4  # 10000 kbps (higher quality)
```


### Keybinds for Recording

Start/stop recording with keybinds:[1]
```
bind = SUPER, R, exec, wf-recorder -o ~/Videos/recording-$(date +%Y%m%d-%H%M%S).mp4 & echo $! > /tmp/wf-recorder.pid && notify-send "Recording started"

bind = SUPER+SHIFT, R, exec, kill $(cat /tmp/wf-recorder.pid) && notify-send "Recording stopped"
```


### OBS Studio (Professional)

**OBS Studio** provides professional-grade recording with extensive features. Install with `sudo pacman -S obs-studio`.[2][1]

Configure Wayland video source via PipeWire:[1]
1. Launch OBS Studio
2. Settings → Output → Recording
3. Source → Add → PipeWire Audio/Video Source
4. Select monitor and audio source

Record with OBS keybind:[1]
```
bind = SUPER+SHIFT, R, exec, obs --profile=streaming --scene=recording --startrecording
```


### SimpleScreenRecorder (GUI)

**SimpleScreenRecorder** provides graphical recording interface. Install with `sudo pacman -S simplescreenrecorder`.[1]

Launch with keybind:[1]
```
bind = SUPER, R, exec, simplescreenrecorder
```


Select recording region, audio sources, and codec through GUI.[1]

### Screencast Recording with ffmpeg

**ffmpeg** records screen directly from PipeWire:[1]
```bash
ffmpeg -f pipewire -i default -f pulse -i default output.mp4
```


Record with audio and video:[1]
```bash
ffmpeg -f pipewire -framerate 30 -i default -f pulse -i default -c:v h264 -c:a aac output.mp4
```


### Recording Scripts

Create comprehensive recording script:[1]

**~/.config/hypr/scripts/record.sh:**
```bash
#!/bin/bash
RECORDING_DIR=~/Videos
mkdir -p "$RECORDING_DIR"
FILENAME="$RECORDING_DIR/recording-$(date +%Y-%m-%d_%H-%M-%S).mp4"

case $1 in
  start-full)
    wf-recorder -o "$FILENAME" > /tmp/wf-recorder.pid 2>&1 &
    echo $! > /tmp/wf-recorder.pid
    notify-send "Recording" "Full screen recording started"
    ;;
  start-region)
    wf-recorder -g "$(slurp)" -o "$FILENAME" > /tmp/wf-recorder.pid 2>&1 &
    echo $! > /tmp/wf-recorder.pid
    notify-send "Recording" "Region recording started"
    ;;
  start-audio)
    AUDIO=$(pactl list sources | grep -m1 "Name:" | cut -d' ' -f2)
    wf-recorder --audio="$AUDIO" -o "$FILENAME" > /tmp/wf-recorder.pid 2>&1 &
    echo $! > /tmp/wf-recorder.pid
    notify-send "Recording" "Recording with audio started"
    ;;
  stop)
    if [ -f /tmp/wf-recorder.pid ]; then
      kill $(cat /tmp/wf-recorder.pid) 2>/dev/null
      rm /tmp/wf-recorder.pid
      notify-send "Recording" "Recording stopped"
    fi
    ;;
esac
```


Make executable:[1]
```bash
chmod +x ~/.config/hypr/scripts/record.sh
```


### Video Post-Processing

Trim recordings:[1]
```bash
ffmpeg -i input.mp4 -ss 00:00:10 -to 00:01:30 -c copy output.mp4
```


Compress for sharing:[1]
```bash
ffmpeg -i input.mp4 -c:v libx264 -crf 28 output.mp4
```


Convert to WebM:[1]
```bash
ffmpeg -i input.mp4 -c:v libvpx-vp9 -c:a libopus output.webm
```


### Recording Notifications

Show recording status with notifications:[1]
```bash
# During recording
notify-send -t 0 "Recording" "Recording in progress... $(date +%H:%M:%S)"
```


Display recording time periodically:[1]
```bash
while pgrep wf-recorder > /dev/null; do
  DURATION=$(ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1:noprint_wrappers=1 /tmp/current-recording.mp4 2>/dev/null || echo "0")
  notify-send -r 9999 "Recording" "Duration: $(date -d@${DURATION%.*} -u +%H:%M:%S)"
  sleep 5
done
```


### Streaming Integration

Stream to platforms like Twitch while recording:[1]

**OBS Studio configuration:**
1. Settings → Stream
2. Service: Twitch
3. Server: Auto
4. Stream Key: From Twitch dashboard

Start streaming and recording simultaneously.[1]

### Example Comprehensive Recording Configuration

Add to `hyprland.conf`:
```
# Simple recording scripts
bind = SUPER, R, exec, ~/.config/hypr/scripts/record.sh start-full
bind = SUPER+SHIFT, R, exec, ~/.config/hypr/scripts/record.sh stop
bind = SUPER+ALT, R, exec, ~/.config/hypr/scripts/record.sh start-region
bind = SUPER+CTRL, R, exec, ~/.config/hypr/scripts/record.sh start-audio

# Direct wf-recorder
bind = SUPER+SHIFT, Print, exec, wf-recorder -g "$(slurp)" -o ~/Videos/recording-$(date +%Y%m%d-%H%M%S).mp4 & notify-send "Recording region"

# Launch OBS
bind = SUPER+CTRL+R, exec, obs --profile=streaming --startrecording
```


Create `~/.config/hypr/scripts/record.sh` as shown above.[1]

### Best Practices

**File formats:** Use MP4 for compatibility, WebM for web, MOV for editing.[1]

**Codecs:** H.264 for general use, VP9 for web, ProRes for professional editing.[1]

**Audio:** Always record system audio if demonstrating software; use separate microphone for voice-over.[1]

**Storage:** Recordings consume significant disk space; use external drives for large projects.[1]

**Quality vs Size:** Higher bitrate increases file size exponentially; 5000-8000 kbps provides good quality for tutorials.[1]

Wf-recorder provides the most efficient Wayland-native recording for Hyprland with minimal resource overhead.[1]

Sources
[1] Hyprland - ArchWiki https://wiki.archlinux.org/title/Hyprland
[2] Variables - Hyprland Wiki https://wiki.hypr.land/Configuring/Variables/

