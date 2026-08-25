## Multiplexing Techniques


Multiplexing allows multiple data streams to share a single transmission medium, maximizing channel utilization and reducing infrastructure costs.

### Time Division Multiplexing (TDM)

TDM allocates specific time slots to individual data streams within a repeating frame structure. Each input channel receives dedicated time intervals for transmission.

**Synchronous TDM:**

- Fixed time slots assigned regardless of channel activity
- Simple implementation with predictable delay characteristics
- Inefficient utilization when channels are inactive
- Used in traditional telephony systems (T1/E1 carriers)

**Statistical TDM:**

- Dynamic time slot allocation based on channel activity
- Higher efficiency than synchronous TDM
- Variable delay depending on traffic load
- Requires buffering and flow control mechanisms

**Applications:**

- T1 carriers multiplex 24 voice channels at 64 kbps each
- E1 systems support 30 voice channels plus signaling
- SONET/SDH hierarchical multiplexing for optical networks
- Ethernet over TDM for circuit emulation services

### Frequency Division Multiplexing (FDM)

FDM assigns different frequency bands to individual channels, allowing simultaneous transmission without time-based coordination.

**Implementation Requirements:**

- Guard bands prevent interference between adjacent channels
- Bandpass filters separate individual channels at receivers
- Frequency stability critical for proper channel separation
- Linear amplifiers required to prevent intermodulation distortion

**Applications:**

- Radio and television broadcasting
- Analog telephone carrier systems
- Cable television distribution
- Satellite communication transponders

### Wavelength Division Multiplexing (WDM)

WDM applies frequency division principles to optical fiber systems, using different light wavelengths to carry independent data streams.

**Dense WDM (DWDM):**

- Channel spacing as low as 12.5 GHz (0.1 nm)
- Supports 160 or more channels per fiber
- Requires precise laser wavelength control
- Used in long-haul and metropolitan networks

**Coarse WDM (CWDM):**

- Wider channel spacing reduces component costs
- Typically supports 8-18 channels
- Less stringent wavelength accuracy requirements
- Suitable for shorter distances and lower channel counts

### Code Division Multiple Access (CDMA)

CDMA uses unique spreading codes to allow multiple users to share the same frequency spectrum simultaneously.

**Spread Spectrum Principles:**

- Spreading codes expand signal bandwidth
- Processing gain improves signal-to-noise ratio
- Multiple access through code orthogonality
- Inherent resistance to interference and interception

**Implementation Characteristics:**

- Requires precise power control for all users
- Near-far problem affects system capacity
- Soft handoff capabilities in cellular systems
- Used in 3G cellular networks and GPS systems

