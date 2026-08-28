## Temperature, Humidity, and Pressure Sensors

### Overview

Temperature, humidity, and pressure sensing form the core of environmental monitoring in embedded systems, spanning applications from consumer weather stations and HVAC control to industrial process monitoring and altitude estimation. These three physical quantities are frequently measured together — often by a single integrated sensor package — because they share overlapping application contexts and because humidity and pressure measurements typically require temperature compensation to achieve their rated accuracy.

### Temperature Sensing Technologies

#### Thermistors

A thermistor is a resistive element whose resistance changes predictably with temperature.

- **NTC (Negative Temperature Coefficient) thermistors**: resistance decreases as temperature increases, the more common type in embedded applications.
- **PTC (Positive Temperature Coefficient) thermistors**: resistance increases with temperature, often used for overcurrent protection rather than precision temperature sensing.
- **Nonlinear response**: thermistor resistance-vs-temperature curves are strongly nonlinear, typically requiring either a lookup table or an approximation equation (commonly the Steinhart-Hart equation) in firmware to convert measured resistance into an accurate temperature value.
- **Simple interfacing**: typically wired as one leg of a voltage divider with a known reference resistor, with the divider's midpoint voltage read by an ADC — inexpensive and simple, but requiring careful reference resistor selection and calibration for good accuracy.
- **Self-heating consideration**: the current flowing through a thermistor during measurement dissipates a small amount of power, which can slightly bias the reading if measurement current is too high or measurements are taken too frequently.

#### RTDs (Resistance Temperature Detectors)

- Typically constructed from a pure metal (platinum is common, e.g., PT100 and PT1000 designations referring to 100Ω and 1000Ω resistance at 0°C) whose resistance changes with temperature in a well-characterized, more linear manner than a thermistor.
- **Higher accuracy and stability** than thermistors, but at higher cost and requiring more careful signal conditioning (often a 3-wire or 4-wire connection scheme to cancel out lead wire resistance error, particularly important given the RTD's relatively low absolute resistance values).
- **Common in industrial and precision applications** where thermistor accuracy is insufficient and cost is a secondary concern relative to measurement precision.

#### Thermocouples

- Generate a small voltage (the Seebeck effect) at the junction of two dissimilar metals, with the voltage magnitude related to the temperature difference between the measurement junction and a reference junction.
- **Require cold-junction compensation**: because a thermocouple only measures a temperature *difference*, accurate absolute temperature measurement requires knowing the reference junction's temperature (often measured separately with a local temperature sensor) and compensating for it in firmware or dedicated thermocouple interface ICs.
- **Wide temperature range capability**: thermocouples are commonly used for very high-temperature measurement (industrial furnaces, exhaust systems) beyond the practical range of thermistors, RTDs, or integrated silicon sensors.
- **Low output signal requiring amplification**: the generated voltage is typically in the microvolt-to-millivolt range, requiring a precision instrumentation amplifier and careful noise-immune signal routing for accurate measurement.

#### Integrated Digital Temperature Sensor ICs

- Combine a sensing element (often a bandgap or diode-based silicon temperature sensor) with onboard signal conditioning and an ADC, providing a direct digital temperature reading over I2C, SPI, or similar interfaces.
- **Simplifies system design significantly**: no external signal conditioning, reference resistor, or linearization firmware is required, at the cost of less flexibility than a raw sensing element and typically a narrower usable temperature range than RTDs or thermocouples.
- **Widely used in consumer and general embedded applications** where moderate accuracy (often ±0.5°C or better in a typical operating range) and ease of interfacing outweigh the need for extreme precision or extended temperature range.

### Humidity Sensing

- **Capacitive humidity sensors** are the dominant technology in modern embedded applications: a hygroscopic polymer dielectric absorbs or releases moisture based on ambient relative humidity, changing the capacitance of a simple parallel-plate or interdigitated capacitor structure.
- **Relative humidity (RH) measurement**: capacitive humidity sensors inherently measure relative humidity (moisture content relative to what the air could hold at the current temperature) rather than absolute moisture content, which is why accurate RH measurement requires simultaneous, accurate temperature measurement.
- **Temperature compensation requirement**: because relative humidity is fundamentally temperature-dependent (the same absolute moisture content corresponds to different RH values at different temperatures), accurate humidity sensing essentially always requires a paired or co-located temperature measurement — a major reason combined humidity/temperature sensor ICs are so common.
- **Response time considerations**: capacitive humidity sensors typically have a finite response time to a step change in ambient humidity (ranging from seconds to tens of seconds depending on the specific sensor and any protective membrane/filter), a consideration for applications requiring fast-changing humidity tracking.
- **Contamination sensitivity**: some humidity sensor types are sensitive to contamination from volatile organic compounds, dust, or condensation, which can degrade accuracy or response time over the product's operating life; some sensors include a protective filter membrane to mitigate this at the cost of slightly slower response time.

### Pressure Sensing

#### MEMS Pressure Sensor Principles

Most modern integrated pressure sensors use a MEMS structure — a thin, flexible diaphragm that deflects under applied pressure, with the deflection converted to an electrical signal through one of two common transduction methods:

- **Piezoresistive sensing**: strain-sensitive resistive elements (often arranged in a Wheatstone bridge configuration) are integrated into or bonded to the flexible diaphragm; diaphragm deflection changes the resistors' strain and thus their resistance, producing a bridge output voltage proportional to applied pressure.
- **Capacitive sensing**: the flexible diaphragm forms one plate of a capacitor, with diaphragm deflection under pressure changing the capacitor gap and thus its capacitance; capacitive sensing generally offers lower power consumption and better temperature stability than piezoresistive sensing, though piezoresistive designs remain common and cost-effective.

#### Pressure Measurement Types

- **Absolute pressure**: measured relative to a sealed vacuum reference, commonly used for barometric/atmospheric pressure measurement and altitude estimation.
- **Gauge pressure**: measured relative to ambient atmospheric pressure (i.e., zero reading at ambient pressure), common in applications measuring pressure relative to the surrounding environment (e.g., tire pressure, some industrial process pressure).
- **Differential pressure**: measures the pressure difference between two separate points/ports, used in applications like airflow measurement (via a venturi or orifice, where differential pressure correlates with flow rate) or filter clog detection.

#### Barometric Altitude Estimation

A common embedded application of absolute pressure sensing is estimating altitude from atmospheric pressure, using the relationship between pressure and altitude in the atmosphere. A commonly used approximation (the barometric formula, in one common simplified form) is:

$$h \approx 44330 \times \left(1 - \left(\frac{P}{P_0}\right)^{\frac{1}{5.255}}\right)$$

where $h$ is altitude in meters, $P$ is the measured pressure, and $P_0$ is the reference sea-level pressure (standard atmosphere: 1013.25 hPa, though actual local sea-level pressure varies with weather conditions and should be used for best accuracy where available).

Altitude estimates derived purely from barometric pressure are subject to error from local weather-driven pressure variation (a change in weather can shift the pressure-altitude relationship independent of actual altitude change), so barometric altitude is generally treated as a relative or short-term-accurate measurement rather than an absolute, weather-independent one unless referenced against a known, current local sea-level pressure value. [Inference — the magnitude of weather-induced error varies by location and conditions and is not a fixed, universally quotable figure]

### Interfacing Considerations for Environmental Sensors

- **Digital I2C/SPI integration**: the large majority of modern integrated temperature, humidity, and pressure sensor ICs provide digital I2C or SPI output with onboard ADC and calibration compensation applied internally, simplifying firmware interfacing compared to raw analog sensing elements.
- **Factory calibration coefficients**: many integrated sensor ICs store factory-measured calibration coefficients in onboard non-volatile memory, which the host firmware reads once at startup and applies to raw sensor readings to achieve the sensor's specified accuracy — a step that is easy to overlook if a driver implementation only reads raw uncompensated values.
- **Combined sensor packages**: pressure sensors frequently include an onboard temperature sensor (needed for the pressure measurement's own internal temperature compensation), which can sometimes be exposed as a usable general-purpose temperature reading, though its placement and thermal mass characteristics may make it less representative of true ambient temperature than a dedicated, well-placed temperature sensor.
- **Enclosure and venting considerations**: pressure and humidity sensors require some path for ambient air/pressure to reach the sensing element, meaning a fully sealed enclosure will prevent accurate environmental sensing unless a vent, membrane, or gasket specifically designed to allow pressure/humidity equalization (while excluding liquid water or dust, depending on the required ingress protection rating) is included in the mechanical design.

### Placement and Layout Considerations

- **Thermal isolation from heat-generating components**: temperature sensors intended to measure ambient or enclosure temperature (rather than a specific component's temperature) should be placed away from heat-generating components (regulators, high-current ICs, processors under load) to avoid a biased reading skewed by nearby self-heating rather than true ambient conditions.
- **Copper pour and thermal mass around the sensor**: large copper pours or thermal vias near a temperature sensor can slow its thermal response time (increasing its effective thermal mass) and potentially couple heat from elsewhere on the board, both of which can degrade the sensor's ability to track fast ambient temperature changes accurately.
- **Airflow/vent path proximity for humidity and pressure sensors**: sensors requiring ambient air/pressure exposure should be placed near the enclosure's vent or membrane path, since a sensor sealed away from any air path — even if nominally "exposed" on the PCB — will respond slowly or inaccurately to actual ambient changes.
- **Avoiding condensation risk on humidity-sensitive locations**: in applications with significant temperature cycling or high-humidity environments, condensation directly on a humidity sensor's sensing element can cause temporary saturation or slow recovery, a consideration for both sensor placement and enclosure thermal design.

### Calibration and Accuracy Considerations

- **Factory calibration vs. field/system-level calibration**: while most modern integrated sensors include factory calibration compensating for manufacturing variation, system-level effects (self-heating from the specific PCB/enclosure design, mounting-induced pressure sensor offset from case stress) may still require an additional system-level calibration or offset correction applied by the product's firmware.
- **Long-term drift**: some sensor technologies (particularly certain humidity sensor designs) can exhibit gradual accuracy drift over extended operating life or after exposure to contamination/extreme conditions, a consideration for products with long deployment lifetimes or that require sustained calibration accuracy.
- **Cross-sensitivity effects**: pressure sensors can exhibit minor sensitivity to temperature beyond what onboard compensation fully corrects, and humidity sensors' accuracy is fundamentally dependent on accurate paired temperature measurement — meaning errors in one measured quantity can propagate into apparent errors in another, compensated quantity.

### Common Pitfalls in Temperature/Humidity/Pressure Sensor Design

- **Placing a temperature sensor too close to a heat-generating component**, biasing readings that are meant to represent true ambient conditions.
- **Sealing the enclosure without a vent/membrane path**, preventing humidity and pressure sensors from accurately tracking ambient conditions regardless of the sensor's intrinsic accuracy.
- **Neglecting to apply factory calibration coefficients** stored in the sensor's non-volatile memory, resulting in raw, uncompensated (and often significantly less accurate) readings.
- **Assuming barometric altitude is absolute and weather-independent**, without accounting for local sea-level pressure reference changes over time.
- **Using a thermistor without proper linearization**, applying a simple linear approximation across a temperature range where the thermistor's actual response is meaningfully nonlinear.
- **Ignoring RTD lead wire resistance error** in a 2-wire connection scheme where a 3- or 4-wire scheme was warranted for the required accuracy, particularly with longer wire runs.

**Related Topics**
- Common Sensor Types and Interfaces
- Calibration — Sensor offset, scale, and temperature compensation techniques
- Thermal Management on PCBs
- Communication Protocols — I2C, SPI, and UART fundamentals
- Firmware — Interrupt-driven design and low-power sleep strategies
- Enclosure Design — Ingress protection and environmental sealing considerations