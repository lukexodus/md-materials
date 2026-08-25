## Signal Encoding and Modulation


Digital data must be converted into analog signals suitable for transmission over physical media. Encoding schemes define how binary data maps to signal characteristics, while modulation techniques adapt signals for specific transmission media.

### Digital Encoding Schemes

**Non-Return-to-Zero (NRZ):**

- Simple encoding where high voltage represents 1 and low voltage represents 0
- Prone to synchronization issues with long sequences of identical bits
- DC component can cause problems with AC-coupled transmission systems
- Limited self-clocking capability requires separate timing recovery

**Return-to-Zero (RZ):**

- Signal returns to zero between each bit period
- Better synchronization than NRZ due to regular transitions
- Requires twice the bandwidth of NRZ encoding
- Self-clocking properties simplify receiver design

**Manchester Encoding:**

- Each bit period contains a transition: high-to-low for 0, low-to-high for 1
- Guaranteed transitions provide excellent clock recovery
- DC balance eliminates baseline wander problems
- Used in 10 Mbps Ethernet and other legacy systems
- Requires double the bandwidth of simple NRZ

**Differential Manchester:**

- Transition at beginning of bit period indicates data value
- Presence of transition represents 0, absence represents 1
- Superior noise immunity compared to absolute encoding schemes
- Used in Token Ring networks and some wireless systems

### Analog Modulation Techniques

**Amplitude Shift Keying (ASK):**

- Digital data modulates carrier amplitude
- Simple implementation but susceptible to amplitude variations
- Poor noise performance compared to other modulation schemes
- Rarely used alone in modern high-speed systems

**Frequency Shift Keying (FSK):**

- Different frequencies represent different digital values
- Better noise immunity than ASK
- Constant amplitude reduces amplifier distortion requirements
- Used in low-speed modem applications and some wireless systems

**Phase Shift Keying (PSK):**

- Digital data modulates carrier phase
- BPSK uses two phase states 180 degrees apart
- QPSK encodes two bits per symbol using four phase states
- Higher-order PSK (8-PSK, 16-PSK) increases spectral efficiency
- Excellent noise performance and bandwidth efficiency

**Quadrature Amplitude Modulation (QAM):**

- Combines amplitude and phase modulation
- 16-QAM encodes 4 bits per symbol
- 64-QAM and 256-QAM provide higher data rates
- Widely used in cable modems, DSL, and wireless systems
- Requires linear amplifiers and precise carrier recovery

