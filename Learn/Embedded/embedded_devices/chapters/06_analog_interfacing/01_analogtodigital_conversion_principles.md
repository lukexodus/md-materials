## Analog-to-Digital Conversion Principles

### Overview

Analog-to-digital conversion (ADC) is the process of translating a continuously-varying analog voltage into a discrete digital value that a microcontroller can store, process, and act upon. Because the physical world — temperature, light, sound, pressure, position — is fundamentally analog, ADCs form the essential bridge that allows digital embedded systems to sense and respond to real-world conditions.

### The Core Conversion Concept

An ADC maps an input voltage within a defined range to one of a finite number of discrete digital output codes. This mapping introduces two fundamental, unavoidable characteristics of any ADC:

- **Quantization**: since only a finite number of discrete output codes exist, any input voltage that doesn't fall exactly on one of the represented levels is rounded to the nearest available code, introducing a small, unavoidable error called quantization error.
- **Sampling**: the ADC captures the input voltage at discrete points in time rather than continuously, meaning information about how the signal behaves *between* samples is lost.

### Resolution

Resolution describes how many discrete output levels an ADC can represent, determined by the number of output bits:

$$Number\ of\ levels = 2^{N}$$

where $N$ is the ADC's bit resolution. A common resolution is 12 bits, yielding:

$$2^{12} = 4096\ \text{discrete levels}$$

The smallest voltage change the ADC can distinguish (one Least Significant Bit, or LSB) is:

$$V_{LSB} = \frac{V_{ref}}{2^N}$$

where $V_{ref}$ is the ADC's reference voltage, defining the top of its measurable input range.

**Example**: for a 12-bit ADC with a 3.3 V reference:

$$V_{LSB} = \frac{3.3\ V}{4096} \approx 0.8\ mV$$

This means the ADC can theoretically distinguish input voltage changes as small as roughly 0.8 mV within its measurement range, before accounting for real-world noise and non-ideal characteristics.

### Quantization Illustration (SVG)

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 700 260">
  <text x="20" y="20" font-family="monospace" font-size="14" fill="#333">Quantization of an Analog Signal (svg_diagram)</text>
  <line x1="50" y1="220" x2="650" y2="220" stroke="#333" stroke-width="1" />
  <line x1="50" y1="220" x2="50" y2="40" stroke="#333" stroke-width="1" />
  <path d="M 50 180 Q 150 60, 250 100 T 450 140 T 650 80" fill="none" stroke="#0066cc" stroke-width="2" />
  <line x1="50" y1="180" x2="650" y2="180" stroke="#ccc" stroke-dasharray="2,2" />
  <line x1="50" y1="150" x2="650" y2="150" stroke="#ccc" stroke-dasharray="2,2" />
  <line x1="50" y1="120" x2="650" y2="120" stroke="#ccc" stroke-dasharray="2,2" />
  <line x1="50" y1="90" x2="650" y2="90" stroke="#ccc" stroke-dasharray="2,2" />
  <line x1="50" y1="60" x2="650" y2="60" stroke="#ccc" stroke-dasharray="2,2" />
  <path d="M 50 180 L 150 90 L 150 90 L 250 120 L 350 150 L 350 150 L 450 120 L 550 90 L 650 90" fill="none" stroke="#a00" stroke-width="2" stroke-dasharray="4,2" />
  <text x="500" y="35" font-family="monospace" font-size="10" fill="#0066cc">— original analog signal</text>
  <text x="500" y="245" font-family="monospace" font-size="10" fill="#a00">- - quantized digital levels</text>
</svg>

### Sampling Rate and the Nyquist Criterion

- **Sampling rate**: the number of times per second the ADC captures the input signal, expressed in samples per second (SPS) or Hz.
- **Nyquist-Shannon sampling theorem**: to accurately capture and reconstruct a signal without ambiguity, the sampling rate must be at least twice the highest frequency component present in the signal being sampled:

$$f_{sample} \geq 2 \times f_{signal,max}$$

- **Aliasing**: if a signal is sampled below its Nyquist rate, higher-frequency components fold back and appear as false, lower-frequency signals in the sampled data — indistinguishable from genuine low-frequency content once sampled, and not correctable after the fact.
- **Anti-aliasing filter**: an analog low-pass filter placed before the ADC input, removing frequency content above the Nyquist frequency before sampling occurs, since aliasing cannot be corrected in the digital domain after an under-sampled signal has already been captured.

### Aliasing Illustration (SVG)

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 700 220">
  <text x="20" y="20" font-family="monospace" font-size="14" fill="#333">Aliasing from Undersampling (svg_diagram)</text>
  <line x1="50" y1="180" x2="650" y2="180" stroke="#333" stroke-width="1" />
  <path d="M 50 100 Q 75 40, 100 100 T 150 100 T 200 100 T 250 100 T 300 100 T 350 100 T 400 100 T 450 100 T 500 100 T 550 100 T 600 100 T 650 100" fill="none" stroke="#0066cc" stroke-width="1.5" />
  <circle cx="50" cy="100" r="4" fill="#a00" />
  <circle cx="150" cy="100" r="4" fill="#a00" />
  <circle cx="250" cy="100" r="4" fill="#a00" />
  <circle cx="350" cy="100" r="4" fill="#a00" />
  <circle cx="450" cy="100" r="4" fill="#a00" />
  <circle cx="550" cy="100" r="4" fill="#a00" />
  <path d="M 50 100 L 150 100 L 250 100 L 350 100 L 450 100 L 550 100" fill="none" stroke="#a00" stroke-width="2" stroke-dasharray="5,3" />
  <text x="60" y="205" font-family="monospace" font-size="10" fill="#333">Sparse samples (red dots) of a fast signal (blue) can misleadingly suggest a flat/false reading</text>
</svg>

### Common ADC Architectures

**Successive Approximation Register (SAR) ADC**

Performs a binary-search-like comparison process: an internal DAC generates a trial voltage, compared against the input, with each successive bit resolved from most-significant to least-significant based on the comparison result. Widely used in microcontroller-integrated ADCs due to a good balance of speed, resolution, and moderate circuit complexity/cost.

- Conversion time is roughly proportional to the number of bits of resolution (one comparison cycle per bit, generally), making SAR ADCs well-suited to moderate-speed, moderate-resolution applications. [Inference — exact cycle count and timing model varies by specific SAR implementation]

**Sigma-Delta (ΔΣ) ADC**

Uses oversampling (sampling far faster than the Nyquist minimum) combined with noise-shaping techniques to achieve very high effective resolution, at the cost of a comparatively low effective output data rate relative to its internal sampling rate. Commonly used in precision, low-speed measurement applications (e.g., precision temperature or weight measurement) where high resolution matters more than conversion speed.

**Flash ADC**

Uses a bank of parallel comparators (one per possible output level, roughly) to determine the digital output essentially instantaneously in a single clock cycle, providing very high conversion speed at the cost of exponentially increasing hardware complexity (and cost/power) as resolution increases, since the number of comparators required scales with $2^N - 1$. Typically used in high-speed, lower-resolution applications (e.g., high-speed data acquisition, some RF applications) rather than general-purpose microcontroller peripherals.

**Dual-Slope (Integrating) ADC**

Charges an integrator circuit for a fixed time proportional to the input voltage, then discharges at a fixed known rate, measuring the discharge time to determine the input value. Known for good noise rejection and accuracy at the cost of slow conversion speed, historically common in digital multimeters. [Inference — dual-slope ADCs are less commonly integrated directly into general-purpose microcontrollers compared to SAR, appearing more often in dedicated precision instrumentation]

### ADC Architecture Comparison

| Architecture | Speed | Resolution | Typical Use Case |
|---|---|---|---|
| SAR | Moderate–fast | Moderate–high (8–18 bit common) | General-purpose MCU-integrated ADC |
| Sigma-Delta | Slow (low output rate) | Very high effective resolution | Precision, low-speed measurement |
| Flash | Very fast | Low–moderate | High-speed data acquisition, RF |
| Dual-Slope | Slow | High accuracy | Precision instrumentation (e.g., DMMs) |

### Reference Voltage Considerations

- The ADC's reference voltage ($V_{ref}$) defines the input voltage that corresponds to the maximum digital output code, directly determining measurement resolution in volts-per-code as shown in the LSB formula above.
- **Internal reference**: many MCUs provide a built-in reference voltage (often around 1.2 V, 2.5 V, or tied to the supply rail, depending on device), convenient but sometimes less precise/stable than an external option.
- **External reference**: a dedicated precision voltage reference IC can provide better accuracy, lower temperature drift, and lower noise than an internal reference, at the cost of additional board components — commonly used when measurement accuracy requirements exceed what the internal reference can reliably provide.
- **Supply-derived reference (Vdd/Vcc as reference)**: using the supply rail itself as the ADC reference is simple but ties measurement accuracy directly to supply voltage stability — any noise or variation on the supply rail directly translates into measurement error, which is a particular concern in systems with noisy digital switching activity sharing the same supply.

### Sample-and-Hold

Before and during the conversion process, most ADC architectures require the input voltage to remain stable; a sample-and-hold circuit (often integrated into the ADC peripheral itself) captures and holds the input voltage constant for the duration of the conversion, since most conversion techniques (SAR in particular) would produce an inaccurate result if the input changed mid-conversion.

- **Sample time**: the ADC's internal sampling capacitor requires a certain amount of time to charge to accurately reflect the input voltage, particularly influenced by the source impedance of whatever is driving the ADC input — a high-impedance source may require a longer configured sample time (or an external buffer amplifier) to avoid measurement error from incomplete charging.

### ADC Errors and Non-Idealities

- **Offset error**: a constant deviation between the ideal and actual output code across the entire input range, shifting all readings by a fixed amount.
- **Gain error**: a deviation in the slope of the actual transfer function relative to ideal, causing the error to grow proportionally with input voltage magnitude.
- **Integral Non-Linearity (INL)**: the maximum deviation of the actual transfer function from an ideal straight line, across the full input range.
- **Differential Non-Linearity (DNL)**: the deviation in the width of each individual code step from the ideal single-LSB width; a DNL error severe enough can result in a "missing code" that the ADC never outputs at all.
- **Noise**: random variation in output readings for a constant, unchanging input voltage, often addressed in practice through averaging multiple samples (oversampling and averaging), though this trades conversion speed for reduced noise.

### Multiplexed Multi-Channel ADCs

Many microcontrollers include a single physical ADC core shared across multiple input channels via an internal analog multiplexer, meaning only one channel can be actively converted at any given instant — sequentially scanning through configured channels rather than converting them all in true parallel/simultaneous fashion.

- **Channel switching settling time**: after the multiplexer switches to a new channel, some settling time may be required before an accurate conversion of the new channel can occur, particularly relevant when switching between channels with very different signal characteristics or source impedances. [Inference — the specific settling time requirement depends on the ADC architecture and the specific signal sources involved]
- Simultaneous-sampling ADCs (with genuinely separate conversion hardware per channel) exist on some higher-end parts specifically to avoid this sequential-scanning limitation, useful in applications requiring precisely time-aligned readings across multiple channels (e.g., three-phase power measurement).

### Common ADC Usage Patterns

- **Single conversion, on-demand**: software triggers one conversion, waits (via polling or interrupt) for completion, reads the result.
- **Continuous/scan mode**: the ADC repeatedly converts across a configured sequence of channels automatically, often paired with DMA (see direct memory access fundamentals) to move results into a buffer without CPU intervention per conversion.
- **Triggered by timer**: conversions initiated at precise, regular intervals by a hardware timer event rather than software polling loops, providing more consistent sample timing than software-triggered conversions, which are subject to code execution jitter.

### Common Pitfalls

- Ignoring source impedance effects on sample time, leading to inaccurate readings from high-impedance sensors without an appropriate buffer amplifier or extended sample time configuration.
- Failing to include an anti-aliasing filter when sampling signals with meaningful high-frequency content, risking aliased, misleading readings that cannot be corrected after the fact.
- Using the noisy digital supply rail directly as the ADC reference in a design where measurement precision matters, introducing reference-induced measurement error correlated with digital switching activity.
- Not accounting for multiplexer channel-switching settling time when rapidly scanning across channels with very different source characteristics.
- Assuming a stated bit resolution directly equals real-world measurement accuracy, without accounting for noise, INL/DNL, offset, and gain errors that reduce the *effective* number of usable bits below the nominal resolution.
- Sampling below the Nyquist rate for a given signal's frequency content, introducing aliasing artifacts that are indistinguishable from genuine signal content after the fact.

**Related Topics**
- Direct memory access fundamentals
- Digital-to-analog conversion techniques
- Sensor interfacing and signal conditioning
- Timer and counter peripherals (timer-triggered conversions)
- Noise reduction and filtering techniques in embedded systems
- Voltage reference circuit design