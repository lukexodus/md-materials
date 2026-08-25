## Asynchronous Transfer Mode (ATM)


ATM is a cell-switched networking technology that uses fixed-length 53-byte cells to provide guaranteed Quality of Service for various types of traffic including voice, video, and data.

**Cell Structure and Switching:** ATM cells consist of a 5-byte header and 48-byte payload. The fixed cell size eliminates variable delay jitter and enables predictable switching performance. The small cell size minimizes serialization delay, making ATM suitable for real-time applications.

**Virtual Circuit Architecture:** ATM implements both Permanent Virtual Circuits (PVCs) and Switched Virtual Circuits (SVCs). Virtual Path Identifiers (VPIs) and Virtual Channel Identifiers (VCIs) create hierarchical addressing that enables efficient traffic management and network scaling.

**Service Categories:**

- **Constant Bit Rate (CBR)**: Provides guaranteed bandwidth with fixed timing for applications such as voice and video
- **Variable Bit Rate (VBR)**: Offers two subcategories - real-time VBR for variable rate real-time applications and non-real-time VBR for data applications
- **Available Bit Rate (ABR)**: Provides minimum guaranteed rate with ability to use additional bandwidth when available
- **Unspecified Bit Rate (UBR)**: Best-effort service without bandwidth guarantees

**Traffic Parameters:** ATM defines various traffic parameters including Peak Cell Rate (PCR), Sustained Cell Rate (SCR), Maximum Burst Size (MBS), and Cell Delay Variation Tolerance (CDVT) to characterize traffic flows and enable precise resource allocation.

**Adaptation Layers:** ATM Adaptation Layers (AAL) provide protocol conversion between different traffic types and ATM cells. AAL1 serves circuit emulation, AAL2 handles variable bit rate real-time traffic, AAL3/4 supports connectionless data, and AAL5 provides simplified data transmission.

