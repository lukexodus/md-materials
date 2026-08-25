## Signal Propagation and Impairments


Physical transmission introduces various impairments that degrade signal quality and limit system performance. Understanding these effects enables proper system design and troubleshooting.

### Attenuation

Signal attenuation represents power loss as signals propagate through transmission media. This loss increases with distance and frequency, requiring careful consideration in system design.

**Copper Cable Attenuation:**

- Resistance losses increase with cable length and temperature
- Skin effect concentrates high-frequency current at conductor surface
- Dielectric losses become significant at higher frequencies
- Typical values range from 2-20 dB per 100 meters depending on frequency

**Fiber Optic Attenuation:**

- Rayleigh scattering causes wavelength-dependent losses
- Absorption peaks occur at specific wavelengths
- Microbending and macrobending increase losses
- Splice and connector losses add discrete attenuation points

### Dispersion Effects

Dispersion causes signal spreading, limiting maximum transmission rates and distances.

**Chromatic Dispersion:**

- Different wavelengths travel at different velocities
- Pulse broadening increases with distance and spectral width
- Compensation techniques using dispersion-shifted fiber
- Critical factor in high-speed fiber optic systems

**Modal Dispersion:**

- Multiple propagation modes in multimode fiber arrive at different times
- Limits bandwidth-distance product
- Reduced by using smaller core diameters
- Eliminated in single-mode fiber systems

### Interference and Noise

External interference and internal noise sources degrade signal quality and increase error rates.

**Electromagnetic Interference (EMI):**

- Power lines and electrical equipment generate interference
- Radio transmitters can couple into cables
- Proper shielding and grounding minimize EMI effects
- Twisted pair cables provide differential noise rejection

**Thermal Noise:**

- Random electron motion in conductors generates noise
- Noise power proportional to temperature and bandwidth
- Fundamental limit on receiver sensitivity
- Reduced through cooling in sensitive applications

