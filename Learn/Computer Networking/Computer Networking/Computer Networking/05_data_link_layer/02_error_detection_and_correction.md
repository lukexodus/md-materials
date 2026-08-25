## Error Detection and Correction


The Data Link Layer implements mechanisms to detect and potentially correct transmission errors that occur in the Physical Layer.

### Error Detection Techniques

#### Parity Checking

Simple error detection method adding one bit to ensure even or odd number of 1s. **Limitations:** Can only detect single-bit errors and some multiple-bit errors

#### Checksums

Mathematical calculation performed on data bits to create a verification value. **Process:** Sender calculates checksum and includes it in frame; receiver recalculates and compares

#### Cyclic Redundancy Check (CRC)

Advanced polynomial-based error detection providing high reliability. **Characteristics:**

- Detects all single-bit errors
- Detects all double-bit errors
- Detects odd numbers of bit errors
- Detects burst errors up to CRC length
- Common implementations: CRC-16, CRC-32

### Error Correction Techniques

#### Forward Error Correction (FEC)

Adds redundant information allowing receivers to detect and correct errors without retransmission. **Applications:** Satellite communications, broadcast systems, real-time applications

#### Automatic Repeat Request (ARQ)

Error correction through retransmission of corrupted frames.

**Stop-and-Wait ARQ:**

- Sender transmits one frame and waits for acknowledgment
- Simple but inefficient for high-latency connections
- Timeout mechanisms handle lost acknowledgments

**Go-Back-N ARQ:**

- Sender can transmit multiple frames before receiving acknowledgments
- Receiver discards all frames following an error
- Sender retransmits from the erroneous frame onward

**Selective Repeat ARQ:**

- Receiver accepts correct frames even after detecting errors
- Only erroneous frames require retransmission
- More complex but efficient bandwidth utilization

