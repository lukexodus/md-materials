## Wireless LAN Protocols


Wireless networks face unique challenges including signal interference, mobility, hidden nodes, and security concerns.

### IEEE 802.11 Architecture

#### Basic Service Set (BSS)

**Infrastructure Mode:** Access Point coordinates all communications **Ad Hoc Mode:** Devices communicate directly without central coordination **Extended Service Set (ESS):** Multiple BSSs connected through distribution system

#### Distribution System

**Purpose:** Backbone network connecting multiple access points **Implementation:** Usually wired Ethernet providing inter-BSS communication **Mobility Support:** Enables seamless roaming between access points

### IEEE 802.11 Standards Evolution

#### 802.11 Legacy (1997)

- Frequency: 2.4 GHz ISM band
- Data rates: 1, 2 Mbps
- Modulation: FHSS, DSSS
- Limited adoption due to low speeds

#### 802.11b (1999)

- Enhanced DSSS modulation
- Data rates: 1, 2, 5.5, 11 Mbps
- Backward compatible with legacy 802.11
- Widespread commercial adoption

#### 802.11a (1999)

- Frequency: 5 GHz band
- OFDM modulation technology
- Data rates: 6, 9, 12, 18, 24, 36, 48, 54 Mbps
- No interference with 2.4 GHz devices

#### 802.11g (2003)

- Combines 802.11b compatibility with 802.11a speeds
- 2.4 GHz frequency band
- OFDM modulation for high rates
- Backward compatible with 802.11b

#### 802.11n (2009)

- MIMO (Multiple Input, Multiple Output) technology
- Channel bonding (40 MHz channels)
- Data rates up to 600 Mbps
- Both 2.4 GHz and 5 GHz operation

#### 802.11ac (2013)

- 5 GHz exclusive operation
- Wider channels (80, 160 MHz)
- Advanced MIMO configurations
- Data rates up to several Gbps

#### 802.11ax (Wi-Fi 6, 2019)

- OFDMA (Orthogonal Frequency Division Multiple Access)
- Improved efficiency in dense environments
- Target Wake Time for power savings
- Enhanced security with WPA3

### Wireless Medium Access Control

#### CSMA/CA Operation

**Channel Assessment:** Clear Channel Assessment (CCA) determines medium availability **Backoff Algorithm:** Binary exponential backoff prevents repeated collisions **Acknowledgments:** Positive acknowledgments confirm successful reception

#### Hidden Node Problem

**Issue:** Stations unable to sense each other's transmissions causing collisions at receiver **Solution:** RTS/CTS (Request to Send/Clear to Send) handshaking protocol **Virtual Carrier Sensing:** Network Allocation Vector (NAV) reserves medium based on overheard RTS/CTS

#### Exposed Node Problem

**Issue:** Station unnecessarily defers transmission due to sensing unrelated traffic **Mitigation:** [Inference] Advanced protocols and spatial reuse techniques partially address this issue

### Wireless Frame Format

**Frame Control:** 2 bytes containing protocol version, frame type, and control flags **Duration/ID:** 2 bytes for NAV setting or association ID **Address Fields:** Up to four 6-byte address fields for complex routing scenarios **Sequence Control:** 2 bytes for fragmentation and duplicate detection **Data:** Variable length payload **Frame Check Sequence:** 4 bytes CRC for error detection

