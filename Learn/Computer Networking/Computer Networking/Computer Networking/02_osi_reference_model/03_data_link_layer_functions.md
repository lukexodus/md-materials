## Data Link Layer Functions


The Data Link Layer (Layer 2) provides reliable data transfer across the physical link by detecting and correcting errors that may occur in the Physical Layer. This layer is subdivided into two sublayers: Logical Link Control (LLC) and Media Access Control (MAC).

**Core functions:**

- **Frame formation**: Organizing data into frames with headers and trailers
- **Error detection and correction**: Using checksums, CRC, and other methods
- **Flow control**: Managing data transmission rate between sender and receiver
- **Media access control**: Coordinating access to shared transmission media
- **Physical addressing**: Using MAC addresses for local network identification

**Key mechanisms:**

- **Frame synchronization**: Establishing frame boundaries using start and end delimiters
- **Acknowledgment systems**: Confirming successful frame receipt
- **Automatic Repeat Request (ARQ)**: Retransmitting corrupted or lost frames
- **Collision detection**: Managing simultaneous transmissions in shared media networks

**Examples** of Data Link Layer protocols include Ethernet (IEEE 802.3), Wi-Fi (IEEE 802.11), Point-to-Point Protocol (PPP), and Frame Relay. Switches operate primarily at this layer, using MAC address tables to forward frames to appropriate destinations.

