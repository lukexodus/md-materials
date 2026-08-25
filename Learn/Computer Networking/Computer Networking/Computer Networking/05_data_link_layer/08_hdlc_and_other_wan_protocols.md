## HDLC and Other WAN Protocols


Wide Area Network protocols address the unique requirements of long-distance, often unreliable connections.

### High-Level Data Link Control (HDLC)

#### HDLC Characteristics

**Bit-Oriented Protocol:** Works with arbitrary bit patterns rather than character sets **Full-Duplex Operation:** Simultaneous bidirectional communication **Error Recovery:** Built-in acknowledgment and retransmission mechanisms **Flow Control:** Sliding window mechanism prevents buffer overflow

#### HDLC Frame Types

**Information (I) Frames:**

- Carry user data and acknowledgments
- Sequence numbering for reliable delivery
- Piggyback acknowledgments for efficiency

**Supervisory (S) Frames:**

- Flow control and error recovery functions
- **Receive Ready (RR):** Positive acknowledgment
- **Receive Not Ready (RNR):** Flow control indication
- **Reject (REJ):** Request retransmission from specified frame

**Unnumbered (U) Frames:**

- Link management and control functions
- **Set Asynchronous Balanced Mode (SABM):** Initialize connection
- **Disconnect Mode (DISC):** Terminate connection
- **Unnumbered Acknowledgment (UA):** Confirm unnumbered commands

#### HDLC Configurations

**Normal Response Mode (NRM):** Primary-secondary relationship with polling **Asynchronous Balanced Mode (ABM):** Peer-to-peer relationship with equal capabilities **Asynchronous Response Mode (ARM):** Secondary can initiate transmission without polling

### Frame Relay

**Purpose:** Efficient packet switching for bursery LAN-to-LAN traffic **Operation:** Variable-length frames with minimal processing overhead **Addressing:** Data Link Connection Identifiers (DLCIs) identify virtual circuits **Congestion Control:** Forward/Backward Explicit Congestion Notification (FECN/BECN) **Quality of Service:** Committed Information Rate (CIR) guarantees

### X.25 Protocol

**Architecture:** Three-layer protocol stack for unreliable networks **Packet Layer:** Network layer providing virtual circuit services **Data Link Layer:** LAPB (Link Access Procedure Balanced) ensures reliable transmission **Physical Layer:** Various options including V.24, V.35 **Applications:** [Unverified] Still used in some financial and legacy systems despite declining popularity

### Asynchronous Transfer Mode (ATM)

**Cell Structure:** Fixed 53-byte cells (5 bytes header, 48 bytes payload) **Virtual Circuits:** Connection-oriented service with guaranteed bandwidth **Quality of Service Classes:**

- **Constant Bit Rate (CBR):** Guaranteed bandwidth for real-time applications
- **Variable Bit Rate (VBR):** Statistical multiplexing for bursty traffic
- **Available Bit Rate (ABR):** Best-effort service with rate adaptation
- **Unspecified Bit Rate (UBR):** No guarantees, lowest priority

### Synchronous Optical Network (SONET/SDH)

**Purpose:** Standard for optical fiber transmission systems **Hierarchy:** Multiple speed levels from OC-1 (51.84 Mbps) to OC-768 (39.8 Gbps) **Frame Structure:** 810-byte frames transmitted 8000 times per second **Protection Switching:** Automatic recovery from fiber cuts or equipment failures **Applications:** Backbone networks, submarine cables, metropolitan area networks

**Important related topics for advanced understanding:**

- Virtual LAN (VLAN) implementation and trunking protocols
- Spanning Tree Protocol (STP) and its variants
- Link aggregation and bonding techniques
- Quality of Service (QoS) at the Data Link Layer
- Metro Ethernet services and provider protocols
- Data Link Layer security mechanisms and vulnerabilities

---

