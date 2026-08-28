## Passive Components: Resistors, Capacitors, Inductors


### Overview

Resistors, capacitors, and inductors are the three fundamental passive components underlying essentially every embedded hardware circuit — passive meaning they do not require an external power source to perform their basic function and cannot amplify a signal (unlike active components such as transistors and op-amps, covered previously). While their core electrical relationships were introduced in Voltage, Current, Resistance, and Power and Analog Circuit Basics, this topic focuses specifically on the *physical component* considerations embedded engineers must handle: package types, tolerance, ratings, real-world parasitic behavior, and practical selection criteria for PCB design.

### Resistors

#### Physical Types and Construction

| Type | Construction | Typical Characteristics |
| --- | --- | --- |
| Carbon film | Carbon deposited on ceramic core | Low cost, moderate tolerance and noise |
| Metal film | Metal alloy deposited on ceramic core | Better tolerance and lower noise than carbon film |
| Wirewound | Resistive wire wound on a core | High power handling, but with parasitic inductance |
| Thick/thin film (SMD chip) | Resistive film on ceramic substrate, surface-mount | Dominant in modern embedded PCB design; compact, consistent |

**Key Points**

- Surface-mount (SMD) chip resistors in standard package sizes (e.g., 0402, 0603, 0805 — referring to physical dimensions in hundredths of an inch) dominate modern embedded PCB design due to compact size and automated assembly compatibility
- Through-hole resistors remain common in prototyping (breadboards), low-volume production, and higher-power applications where SMD packages cannot dissipate sufficient heat

#### Key Specifications

**Tolerance**

The maximum permissible deviation from the nominal (labeled) resistance value, expressed as a percentage. Common values: ±20% (rare in modern designs), ±5% (general-purpose), ±1% (precision applications).

**Key Points**

- Precision analog circuits (voltage dividers for reference generation, differential amplifier gain-setting resistors, current-sense applications) typically require ±1% or tighter tolerance to meet accuracy requirements
- Tolerance directly affects worst-case circuit analysis — a design should be verified to function correctly across the full tolerance range of all involved resistors, not just at nominal values

**Power Rating**

The maximum power a resistor can safely dissipate as heat without damage, commonly specified in fractions of a watt for small embedded-scale resistors (1/8W, 1/4W, 1/2W being common through-hole and SMD ratings).

$$P_{dissipated} = I^2 R \leq P_{rated}$$

**Key Points**

- Exceeding the power rating causes overheating, which can lead to resistance drift, physical damage, or fire risk in extreme cases
- A safety margin (commonly derating to 50-70% of rated power in the actual application) is standard practice to account for temperature variation, tolerance stack-up, and long-term reliability [Inference — specific derating guidelines vary by industry standard, application criticality, and thermal environment, and formal derating standards (where applicable, e.g., in safety-critical or aerospace contexts) should be consulted for critical designs]

**Temperature Coefficient**

Describes how resistance changes with temperature, expressed in parts-per-million per degree Celsius (ppm/°C). Lower values indicate more stable resistance across temperature variation, relevant for precision analog circuits operating across a wide temperature range.

#### Resistor Color Code (Through-Hole Reference)

Through-hole resistors traditionally encode their value using colored bands rather than printed numbers:

| Color | Digit Value | Multiplier | Tolerance |
| --- | --- | --- | --- |
| Black | 0 | ×1 | — |
| Brown | 1 | ×10 | ±1% |
| Red | 2 | ×100 | ±2% |
| Orange | 3 | ×1k | — |
| Yellow | 4 | ×10k | — |
| Green | 5 | ×100k | — |
| Blue | 6 | ×1M | — |
| Violet | 7 | ×10M | — |
| Gold | — | ×0.1 | ±5% |
| Silver | — | ×0.01 | ±10% |

**Example**: A resistor banded Brown-Black-Red-Gold reads $1, 0, \times100$, giving $10 \times 100 = 1000\,\Omega = 1\text{k}\Omega$, with ±5% tolerance.

### Capacitors

#### Physical Types and Construction

| Type | Dielectric | Typical Characteristics |
| --- | --- | --- |
| Ceramic | Ceramic dielectric | Small, low cost, good high-frequency behavior; capacitance can vary with applied voltage and temperature depending on dielectric class |
| Tantalum | Tantalum oxide | Compact for given capacitance, stable, but historically prone to catastrophic (sometimes short-circuit) failure if overstressed |
| Aluminum electrolytic | Aluminum oxide, polarized | High capacitance per volume, commonly used for bulk power supply filtering; polarized (must observe correct polarity) |
| Film | Plastic film dielectric | Good stability and low loss, larger physical size for a given capacitance than ceramic |

**Key Points**

- Ceramic capacitors are further classified by dielectric class (e.g., C0G/NP0 for stable, precise applications; X7R/X5R for general-purpose bypass/decoupling with more capacitance-vs-voltage/temperature variation) — class selection matters for timing circuits or filters requiring stable capacitance
- Electrolytic and tantalum capacitors are **polarized**: reversing polarity can cause damage or, particularly for tantalum and aluminum electrolytic types, hazardous failure; correct orientation on the PCB is essential
- Ceramic capacitors dominate embedded decoupling/bypass applications (values commonly 0.1µF to 10µF) due to low cost, small size, and good high-frequency performance

#### Key Specifications

**Capacitance and Tolerance**

Nominal capacitance value with an associated tolerance, similar in concept to resistor tolerance. Ceramic capacitor tolerance can vary substantially by dielectric class, with some general-purpose types exhibiting significant capacitance variation with applied DC voltage — a non-ideality sometimes overlooked in simple design.

**Voltage Rating**

The maximum voltage the capacitor can safely withstand across its terminals. Exceeding this rating risks dielectric breakdown and component failure.

**Key Points**

- A safety margin (commonly using a capacitor rated for meaningfully higher than the maximum expected circuit voltage) is standard practice, particularly for ceramic capacitors where effective capacitance can decrease as the applied voltage approaches the rated maximum
- Electrolytic capacitor voltage ratings must never be exceeded, and reverse voltage must be avoided entirely for polarized types

**Equivalent Series Resistance (ESR) and Equivalent Series Inductance (ESL)**

Real capacitors are not ideal — parasitic resistance (ESR) and inductance (ESL) in series with the ideal capacitance limit high-frequency performance and cause power dissipation under ripple current.

**Key Points**

- Lower ESR is important in power supply filtering applications, where high ripple currents flow through the capacitor; excessive ESR causes heating and reduced filtering effectiveness
- ESL causes capacitor impedance to actually *increase* at sufficiently high frequencies (beyond the capacitor's self-resonant frequency), which is why multiple parallel capacitors of different values are often used together for broadband decoupling (e.g., a larger bulk capacitor alongside a smaller high-frequency ceramic capacitor near an IC's power pins)

### Inductors

#### Physical Types and Construction

| Type | Construction | Typical Characteristics |
| --- | --- | --- |
| Air-core | Coil with no magnetic core material | Low inductance, minimal core losses, used at high frequencies |
| Ferrite-core | Coil wound on/around ferrite material | Higher inductance for given size, common in switching power supplies |
| Multilayer/chip inductor | Small SMD package, ceramic or ferrite-based | Compact, common for signal-level embedded applications |
| Toroidal | Coil wound on a ring-shaped core | Good magnetic field containment, reduced EMI radiation |

**Key Points**

- Inductors are less commonly used as simple discrete components in low-frequency embedded signal circuits compared to resistors and capacitors, but are essential in switch-mode power supply (buck/boost converter) design and EMI filtering
- Core material saturation is an important consideration in power inductor selection: exceeding the rated saturation current causes a sharp, undesirable drop in effective inductance

#### Key Specifications

**Inductance and Tolerance**

Nominal inductance value (in henries, typically µH or mH range for embedded applications) with associated tolerance.

**Rated (Saturation) Current**

The maximum current the inductor can carry before core saturation significantly degrades its inductance, critical in power supply inductor selection where DC bias current flows continuously.

**DC Resistance (DCR)**

The inherent resistance of the wire winding, causing $I^2R$ power loss and voltage drop; important in efficiency-sensitive power supply designs.

**Self-Resonant Frequency (SRF)**

Due to parasitic capacitance between winding turns, every real inductor exhibits a self-resonant frequency above which it behaves capacitively rather than inductively, limiting its usable frequency range.

### Combining Passive Components: Series and Parallel

The series/parallel combination rules differ meaningfully between resistors, capacitors, and inductors, a common point of confusion:

| Component | Series Combination | Parallel Combination |
| --- | --- | --- |
| Resistors | $R_1 + R_2 + \dots$ | $\left(\frac{1}{R_1}+\frac{1}{R_2}+\dots\right)^{-1}$ |
| Capacitors | $\left(\frac{1}{C_1}+\frac{1}{C_2}+\dots\right)^{-1}$ | $C_1 + C_2 + \dots$ |
| Inductors (no mutual coupling) | $L_1 + L_2 + \dots$ | $\left(\frac{1}{L_1}+\frac{1}{L_2}+\dots\right)^{-1}$ |

**Key Points**

- Capacitor combination rules are the *inverse* pattern of resistor rules — series capacitors combine like parallel resistors, and vice versa — a frequent source of error for those newer to circuit design
- Inductor combination rules (absent mutual coupling/mutual inductance between coils) follow the same pattern as resistors
- Mutual inductance between physically close inductors (transformers, poorly separated PCB inductor placement) complicates the simple series/parallel formulas and is a distinct topic

### PCB Layout Considerations for Passive Components

**Key Points**

- **Decoupling capacitor placement**: placing bypass/decoupling capacitors as physically close as possible to an IC's power pins minimizes parasitic trace inductance in the current loop, preserving high-frequency filtering effectiveness
- **Resistor/capacitor footprint selection**: smaller SMD packages (0402, 0201) save board space but are more difficult to hand-solder and rework, and have lower power/voltage ratings than larger packages (0805, 1206) — a practical trade-off in embedded PCB design between board density and manufacturability/rework ease
- **Trace routing near inductors**: inductors generate magnetic fields that can couple into nearby sensitive analog traces; physical separation or shielding is often necessary, especially for switching power supply inductors near analog sensor circuitry
- **Thermal considerations**: higher-power resistors may require additional PCB copper area (as a heatsink) or specific footprint/thermal via design to dissipate heat effectively within their rating

### Practical Selection Summary

| Component | Primary Selection Criteria | Common Embedded Values |
| --- | --- | --- |
| Resistor | Resistance, tolerance, power rating | 1Ω – 10MΩ; 1/8W–1/4W typical |
| Capacitor | Capacitance, voltage rating, dielectric type, ESR | 10pF – 1000µF; 0.1µF common for decoupling |
| Inductor | Inductance, saturation current, DCR, SRF | 1µH – 100µH common for switching supplies |

[Inference] These value ranges represent common embedded design practice across typical low-voltage digital and mixed-signal boards; specific applications (high-voltage, high-power, RF, or precision analog) may require values and component types well outside these general ranges, and selection should always be driven by the specific circuit's calculated requirements and target component datasheets.

**Related Topics**

- Analog Circuit Basics
- Ohm's Law and Kirchhoff's Laws
- Voltage, Current, Resistance, and Power
- Operational Amplifiers
- Power Supply Design (Linear and Switching Regulators)
- PCB Layout Fundamentals and Design Rules
- EMI/EMC Design Practices for Embedded PCBs
- Component Derating and Reliability Engineering