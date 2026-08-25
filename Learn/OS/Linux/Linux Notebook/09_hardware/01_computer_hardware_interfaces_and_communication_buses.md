## Computer Hardware Interfaces and Communication Buses


### 1. Internal Computer Buses

Used for communication between internal components (CPU, GPU, RAM, storage, etc.).
	•	PCI (Peripheral Component Interconnect) – General-purpose expansion bus for adding hardware (sound cards, network cards, etc.)
	•	PCIe (PCI Express) – High-speed serial successor to PCI; used for GPUs, SSDs, and NICs
	•	ISA (Industry Standard Architecture) – Old expansion bus, replaced by PCI
	•	AGP (Accelerated Graphics Port) – Older graphics-specific interface, replaced by PCIe
	•	LPC (Low Pin Count) – Simplified bus for legacy I/O devices like BIOS or TPM
	•	Front-Side Bus (FSB) – Connects CPU to main memory controller (used in older systems)
	•	QPI (QuickPath Interconnect) – Intel’s replacement for FSB
	•	HyperTransport – AMD’s equivalent to Intel’s QPI
	•	DMI (Direct Media Interface) – Intel bus between CPU and chipset

⸻

### 2. Peripheral Interfaces

Used to connect external or removable devices.
	•	USB (Universal Serial Bus) – Standard for external devices (keyboards, storage, etc.)
	•	Thunderbolt – High-speed interface combining PCIe and DisplayPort (for data, power, video)
	•	FireWire (IEEE 1394) – Used for multimedia and video devices (legacy)
	•	Serial Port (RS-232) – Legacy interface for modems and industrial devices
	•	Parallel Port (IEEE 1284) – Old printer/scanner interface
	•	PS/2 – Keyboard and mouse interface (legacy)

⸻

### 3. Storage Interfaces

Used for connecting hard drives, SSDs, and optical drives.
	•	SATA (Serial ATA) – Common interface for HDDs and SSDs
	•	PATA (Parallel ATA / IDE) – Older version of SATA
	•	NVMe (Non-Volatile Memory Express) – Protocol for high-speed SSDs over PCIe
	•	SCSI (Small Computer System Interface) – Used in servers and enterprise storage
	•	SAS (Serial Attached SCSI) – Serial version of SCSI
	•	eSATA – External version of SATA

⸻

### 4. Network and Communication Interfaces

For networking and inter-device data exchange.
	•	Ethernet – Wired LAN communication
	•	Wi-Fi (IEEE 802.11) – Wireless networking
	•	Bluetooth – Short-range wireless connection
	•	CAN (Controller Area Network) – Used in automotive and industrial systems
	•	LIN (Local Interconnect Network) – Simpler automotive network bus
	•	Modbus – Industrial serial communication protocol

⸻

### 5. Low-Level Embedded and Sensor Buses

Used in microcontrollers, sensors, and small electronic systems.
	•	I²C (Inter-Integrated Circuit) – Two-wire communication between chips
	•	SPI (Serial Peripheral Interface) – High-speed serial interface for sensors, displays, etc.
	•	UART (Universal Asynchronous Receiver-Transmitter) – Serial communication via TX/RX lines
	•	1-Wire – Simple, single-wire protocol (e.g., temperature sensors)
	•	PWM (Pulse-Width Modulation) – Control signals for motors, LEDs, etc.
	•	GPIO (General Purpose Input/Output) – Basic digital input/output pins

⸻

### 6. Display and Audio Interfaces

For connecting screens, projectors, and audio devices.
	•	HDMI (High-Definition Multimedia Interface) – Video and audio interface
	•	DisplayPort – Modern digital video interface (alternative to HDMI)
	•	DVI (Digital Visual Interface) – Legacy video interface
	•	VGA (Video Graphics Array) – Analog video interface (old)
	•	MIPI DSI/CSI – Mobile display and camera serial interfaces
	•	Audio Jack (TRS/TRRS) – Analog audio connection
	•	S/PDIF (Sony/Philips Digital Interface) – Digital audio connection

⸻

### 7. Power and Management Interfaces

For power delivery and system control.
	•	SMBus (System Management Bus) – Derived from I²C, used for system monitoring
	•	PMBus (Power Management Bus) – Based on SMBus for power supply control
	•	IPMI (Intelligent Platform Management Interface) – Server hardware management
	•	ACPI (Advanced Configuration and Power Interface) – Power management standard

⸻

### 8. Specialized/Modern Interfaces

Used in specific or emerging hardware technologies.
	•	M.2 – Connector for SSDs, Wi-Fi, LTE cards (often carries PCIe/SATA signals)
	•	U.2 – Enterprise SSD interface (PCIe-based)
	•	CFExpress / XQD – High-speed camera and storage cards
	•	SD / microSD – Flash memory card interface
	•	eMMC / UFS – Embedded storage interfaces for smartphones
	•	JTAG (Joint Test Action Group) – Debug and programming interface for chips

⸻

Summary:
	•	Internal buses: PCIe, QPI, HyperTransport
	•	Peripheral buses: USB, Thunderbolt, FireWire
	•	Storage: SATA, NVMe, SCSI
	•	Networking: Ethernet, Wi-Fi, Bluetooth
	•	Embedded: I²C, SPI, UART
	•	Display/audio: HDMI, DisplayPort
	•	Power/control: SMBus, ACPI

