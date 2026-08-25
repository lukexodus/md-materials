## Media Access Control (MAC)


MAC protocols coordinate access to shared transmission media, preventing collisions and ensuring fair access among multiple devices.

### Contention-Based Access

#### CSMA (Carrier Sense Multiple Access)

**Operation:** Devices listen to the medium before transmitting **Variants:**

- **1-persistent:** Transmit immediately when medium becomes idle
- **Non-persistent:** Wait random time before sensing again if medium busy
- **p-persistent:** Transmit with probability p when medium becomes idle

#### CSMA/CD (Collision Detection)

**Enhancement:** Devices detect collisions during transmission and abort immediately **Collision Handling:**

- Jam signal alerts all stations of collision
- Binary exponential backoff algorithm determines retry timing
- Collision domain size affects efficiency

#### CSMA/CA (Collision Avoidance)

**Purpose:** Prevent collisions in wireless environments where collision detection is difficult **Mechanisms:**

- Inter-frame spacing creates transmission priorities
- Random backoff periods reduce collision probability
- Request-to-Send/Clear-to-Send (RTS/CTS) for hidden node problem

### Controlled Access

#### Token Passing

**Operation:** Special control frame (token) circulates among stations, granting transmission permission **Characteristics:**

- Deterministic access delays
- Fair access distribution
- No collisions possible
- Single point of failure (token loss)

#### Polling

**Central Control:** Master station queries each slave station for transmission requests **Applications:** Networks requiring centralized control and guaranteed response times

### Channelization

**FDMA (Frequency Division):** Divides bandwidth into frequency channels **TDMA (Time Division):** Allocates specific time slots to stations **CDMA (Code Division):** Uses unique spreading codes for simultaneous transmissions

