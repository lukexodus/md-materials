## What is Piper?

Piper is a fast, local neural text-to-speech system that runs entirely offline. It uses ONNX models trained with VITS to deliver natural-sounding voices across various languages and accents, making it suitable for privacy-conscious applications.

> **Note:** Active development has moved from `rhasspy/piper` to `OHF-Voice/piper1-gpl`. AUR packages currently still provide pre-built binaries from the original project. Verify current package status before installing.

---

## Installation on Arch

### Option 1: AUR binary (recommended)

Install the binary from the AUR with an AUR helper.

```bash
yay -S piper-tts-bin
```

### Option 2: Git build from AUR

```bash
yay -S piper-tts-git
```

> **Conflict warning:** There is a conflict with the `piper` package from the extra repo. You may need to remove it before installing `piper-tts-git`.

### Option 3: pip (Python)

```bash
pip install piper-tts --break-system-packages
# or with pipx:
pipx install piper-tts
```

---

## Installing Voices

Install one of the AUR voice packages for your language, e.g. `piper-voices-en-usAUR`.

```bash
yay -S piper-voices-en-us        # English US voices
yay -S piper-voices-minimal      # Single model (~120MB)
yay -S piper-voices              # Full split-package collection
```

Voices installed via AUR land in `/usr/share/piper-voices/`.

### Manual voice download

Each voice model has two files: a `.onnx` model file and a `.onnx.json` config file. You can store these anywhere, e.g. `/opt/piper-tts/voices/`. Download from the Piper voices page on Hugging Face: `https://huggingface.co/rhasspy/piper-voices`

### Voice quality tiers

Voice models offer varying quality levels from `x_low` to `high` (16kHz to 22.05kHz). Higher quality = larger model, better audio, more CPU usage.

|Quality|Sample Rate|Use case|
|---|---|---|
|`x_low`|16kHz|Low-power devices|
|`low`|16kHz|General use, fast|
|`medium`|22.05kHz|Good balance|
|`high`|22.05kHz|Best quality|

---

## Basic Usage

### Pipe text to a WAV file

```bash
echo "Hello, world!" | piper-tts \
  --model /usr/share/piper-voices/en/en_US/ryan/high/en_US-ryan-high.onnx \
  --output_file hello.wav
```

### Pipe text directly to audio player (no file)

Pipe output directly to your audio player using `--output-raw` or `-f -` for stdin passthrough.

```bash
# PipeWire (pw-play needs the hyphen for stdin)
echo "Hello" | piper-tts -q -m /usr/share/piper-voices/en/en_US/ryan/high/en_US-ryan-high.onnx -f - | pw-play -

# ALSA
echo "Hello" | piper-tts -q -m /path/to/model.onnx --output-raw | aplay -r 22050 -f S16_LE -t raw -

# mpv
echo "Hello" | piper-tts -q -m /path/to/model.onnx -f - | mpv --no-terminal -
```

### Read from a text file

```bash
cat myfile.txt | piper-tts --model /path/to/model.onnx --output_file output.wav
```

---

## CLI Flags

|Flag|Description|
|---|---|
|`-m`, `--model`|Path to `.onnx` model file (required)|
|`--output_file`|Save to WAV file|
|`--output-raw`|Output raw PCM audio to stdout|
|`-f -`|Read from stdin|
|`-s`, `--speaker`|Speaker ID (for multi-speaker models)|
|`-q`, `--quiet`|Suppress progress output|
|`--length_scale`|Speech speed (default: 1.0)|
|`--noise_scale`|Variation/expressiveness (default: model-dependent)|
|`--noise_w`|Phoneme width noise|
|`--sentence_silence`|Pause between sentences in seconds (default: 0.2)|
|`--cuda`|Use CUDA/GPU acceleration|
|`--json-input`|Expect JSON input format|

### Speed and prosody

`--length_scale` controls speed. Normal speed is 1.0; lower values are faster, higher values are slower (e.g. 0.5 = double speed, 2.0 = half speed). `--sentence_silence` sets the pause between sentences in seconds.

```bash
# Faster speech
echo "Fast text" | piper-tts -m /path/to/model.onnx --length_scale 0.8 -f - | pw-play -

# Slower, with longer sentence pauses
echo "Slow text" | piper-tts -m /path/to/model.onnx --length_scale 1.3 --sentence_silence 0.5 -f - | pw-play -
```

### Noise/variation

`--noise_scale` controls variation in delivery. With `--noise_scale 0` speech sounds consistent but robotic. Higher values introduce more variation but can occasionally produce odd results. This behavior varies by model. [Unverified — exact defaults differ per model; test with your specific voice.]

### Multi-speaker models

Some models include multiple speakers. Use `-s` with a numeric ID:

```bash
echo "Hello" | piper-tts -m /path/to/multi.onnx -s 21 -f - | pw-play -
```

---

## Integrating with Speech Dispatcher

Speech Dispatcher allows Piper to serve as the system-wide TTS backend for accessibility tools (screen readers, Orca, etc.).

### 1. Set up user config

```bash
mkdir -p ~/.config/speech-dispatcher/modules
```

### 2. Edit `~/.config/speech-dispatcher/speechd.conf`

Add the module line to your speech-dispatcher config:

```
AddModule "piper-tts-generic" "sd_generic" "piper-tts-generic.conf"
DefaultModule piper-tts-generic
```

### 3. Create `~/.config/speech-dispatcher/modules/piper-tts-generic.conf`

The shell command needs to filter out newlines, since piper-tts exits on newline:

```
GenericExecuteSynth "export XDATA='$DATA'; echo \"$XDATA\" | sed -z 's/\\n/ /g' | piper-tts -q -m \"/usr/share/piper-voices/en/en_US/ryan/high/en_US-ryan-high.onnx\" -s 21 -f - | pw-play -"
AddVoice "en-US" "MALE1" "en_US-ryan-high"
```

Replace `pw-play -` with `aplay -r 22050 -f S16_LE -t raw -` if using ALSA instead of PipeWire.

### Fix for long pauses between sentences

Add these two lines to your `piper.conf` to prevent chunking delays:

```
GenericDelimiters "|"
GenericMaxChunkLength 99999
```

### Multiple voices in speech-dispatcher

```
AddVoice "en-US" "MALE1" "en_US-ryan-high"
AddVoice "en-US" "FEMALE1" "en_US-lessac-medium"
AddVoice "de-DE" "MALE1" "de_DE-thorsten-high.onnx"
DefaultVoice "en_US-lessac-medium"
```

`$VOICE` equals the third argument of `AddVoice` and must match the `.onnx` filename. Set `DefaultVoice` as a fallback for clients that don't specify a voice.

### Restart speech-dispatcher

```bash
systemctl --user restart speech-dispatcher
# or kill and let it auto-restart:
speech-dispatcher --kill
```

---

## GPU Acceleration

To use a GPU, install `onnxruntime-gpu` and run Piper with `--cuda`. A working CUDA environment is required.

```bash
pip install onnxruntime-gpu --break-system-packages
echo "Hello" | piper-tts -m /path/to/model.onnx --cuda --output_file out.wav
```

---

## Useful Scripts

### Quick speak alias (`~/.bashrc` or `~/.zshrc`)

```bash
alias speak='piper-tts -q -m /usr/share/piper-voices/en/en_US/ryan/high/en_US-ryan-high.onnx -f - | pw-play -'
# Usage:
echo "Your text here" | speak
```

### Read clipboard aloud

```bash
wl-paste | piper-tts -q -m /path/to/model.onnx -f - | pw-play -   # Wayland
xclip -o    | piper-tts -q -m /path/to/model.onnx -f - | pw-play - # X11
```

### Read a file aloud

```bash
cat article.txt | piper-tts -q -m /path/to/model.onnx -f - | pw-play -
```

---

## Troubleshooting

**Protobuf parsing error loading `.onnx`** The `.onnx` and `.onnx.json` config files must both be present in the same directory. Missing the JSON config will cause a load failure.

**`piper` conflicts with `piper-tts-git`** There is a known conflict between `piper` (from extra) and `piper-tts-git`. Remove `piper` before installing the TTS version.

**No audio output with `pw-play`** `pw-play` needs a hyphen (`-`) to read from stdin. Omitting it causes silent failure.

**Speech-dispatcher not picking up Piper** Verify the module conf path matches exactly, and that `speechd.conf` has `DefaultModule piper-tts-generic` set.

**Check version / confirm install**

```bash
piper-tts --version
which piper-tts
```

---

## AUR Package Reference

|Package|Purpose|
|---|---|
|`piper-tts-bin`|Pre-built binary (most stable)|
|`piper-tts-git`|Git build (latest, may conflict)|
|`piper-voices-minimal`|Single voice model (~120MB)|
|`piper-voices-en-us`|English US voice pack|
|`piper-voices`|Full multi-language split package|