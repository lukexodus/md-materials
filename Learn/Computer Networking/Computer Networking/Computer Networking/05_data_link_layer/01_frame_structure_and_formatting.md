## Frame Structure and Formatting


The Data Link Layer organizes raw bits from the Physical Layer into structured units called frames. Frames provide the fundamental format for reliable data transmission between directly connected network devices.

### Generic Frame Structure

A typical frame contains several essential components arranged in a specific order:

**Frame Components:**

- **Preamble/Start Delimiter:** Synchronization pattern to identify frame beginning
- **Header:** Contains addressing and control information
- **Payload/Data:** The actual information being transmitted
- **Frame Check Sequence (FCS):** Error detection mechanism
- **End Delimiter:** Marks the frame boundary (in some protocols)

### Frame Delimiting Methods

**Length-based delimiting:** Frame header specifies the exact number of bytes in the frame **Character-based delimiting:** Special characters mark frame boundaries **Bit-pattern delimiting:** Unique bit sequences identify frame start and end **Violation-based delimiting:** Physical layer violations signal frame boundaries

### Frame Addressing

**Unicast:** Frame destined for a single recipient **Broadcast:** Frame intended for all devices on the network segment **Multicast:** Frame directed to a specific group of devices

