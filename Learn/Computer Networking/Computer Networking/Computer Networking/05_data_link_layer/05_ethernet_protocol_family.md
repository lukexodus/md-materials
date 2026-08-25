## Ethernet Protocol Family


Ethernet represents the dominant LAN technology family, evolving from shared medium systems to switched networks.

### Ethernet Evolution

#### Classic Ethernet (10 Mbps)

**10BASE5 (Thick Ethernet):**

- Coaxial cable backbone
- Bus topology with vampire taps
- Maximum segment length: 500 meters
- Maximum network diameter: 2.5 kilometers

**10BASE2 (Thin Ethernet):**

- Thinner coaxial cable
- BNC connectors and T-connectors
- Maximum segment length: 185 meters
- More flexible but lower performance

**10BASE-T:**

- Twisted pair copper cables
- Star topology with central hub
- Maximum cable length: 100 meters
- Foundation for modern Ethernet

#### Fast Ethernet (100 Mbps)

**100BASE-TX:** Two-pair Category 5 UTP cable **100BASE-FX:** Multimode fiber optic cable **100BASE-T4:** Four-pair Category 3 cable (obsolete)

#### Gigabit Ethernet (1000 Mbps)

**1000BASE-T:** Four-pair Category 5e/6 cable **1000BASE-SX:** Short-wavelength multimode fiber **1000BASE-LX:** Long-wavelength single/multimode fiber **1000BASE-CX:** Short copper cables for equipment rooms

#### 10 Gigabit Ethernet and Beyond

**10GBASE-T:** Category 6a/7 copper cables **10GBASE-SR/LR:** Short/long reach fiber optic **25/40/100 Gigabit Ethernet:** Data center and backbone applications

### Ethernet Frame Format (IEEE 802.3)

**Preamble:** 7 bytes of alternating 1s and 0s for synchronization **Start Frame Delimiter (SFD):** 1 byte marking frame start (10101011) **Destination Address:** 6 bytes identifying receiving station **Source Address:** 6 bytes identifying transmitting station **Length/Type:** 2 bytes indicating payload length or protocol type **Data and Padding:** 46-1500 bytes of actual information **Frame Check Sequence:** 4 bytes CRC for error detection

### MAC Address Structure

**Format:** 48-bit hexadecimal identifier (XX:XX:XX:XX:XX:XX) **Organization:** First 24 bits identify manufacturer (OUI - Organizationally Unique Identifier) **Assignment:** Last 24 bits uniquely identify device within manufacturer space **Special Addresses:** Broadcast (FF:FF:FF:FF:FF:FF), multicast (first bit = 1)

### Switching vs. Hubs

**Hubs:** Physical layer devices creating single collision domain **Switches:** Data Link layer devices creating separate collision domain per port **Benefits of Switching:**

- Eliminates collisions in full-duplex mode
- Dedicated bandwidth per port
- MAC address learning and forwarding
- Increased network security through unicast forwarding

