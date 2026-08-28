## I2C Multi-Master and Clock Stretching

### Overview

I2C's bus structure natively supports two capabilities that distinguish it from simpler serial protocols like SPI: multiple devices can independently initiate bus transactions as masters without external arbitration hardware, and slave devices can pause an in-progress transaction to buy themselves processing time. Both mechanisms rely entirely on the open-drain electrical structure of SCL and SDA — the same property that makes any device on the bus capable of pulling either line low at any moment is what makes non-destructive arbitration and clock stretching possible without dedicated control lines.

### Multi-Master Arbitration Mechanism

#### The Core Principle: Wired-AND Logic

Because SDA and SCL are open-drain lines with passive pull-up resistors, the logical state of each line at any instant is the AND of all connected devices' output states — any single device pulling a line low overrides all others attempting to release it high. This wired-AND property is the foundation of I2C arbitration: a master can transmit its intended bit and, on the same clock cycle, read back the actual bus state to check whether another master overrode it.

#### Arbitration Procedure

When two or more masters begin a transaction simultaneously (both issue a START condition before either detects the bus is busy), arbitration proceeds bit-by-bit during the address phase:

1. Each competing master drives its intended address bit onto SDA.
2. Each master then reads back the actual SDA level while SCL is high.
3. If a master intended to drive a "1" (release the line) but reads back a "0" (line held low), it concludes another master is transmitting a "0" at that bit position and has therefore lost arbitration.
4. The losing master immediately ceases driving SDA and switches to a listening/slave-monitoring role for the remainder of that transaction, without corrupting the winning master's data.
5. The winning master continues its transaction, unaware at the protocol level that arbitration even occurred (aside from the bus being contended).

Because a dominant "0" always overrides a released "1" in open-drain wired-AND logic, arbitration inherently favors whichever competing master is transmitting the numerically lower address (more leading zero bits) at the point where the bit patterns diverge. This is a deterministic, non-destructive outcome — no data is corrupted on the winning transaction, and the losing master simply retries its transaction later.

#### Arbitration Bit-by-Bit Comparison (svg_diagram)

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 740 340">
\<style\>
.lbl { font-family: monospace; font-size: 13px; fill: #1a1a1a; }
.small { font-family: monospace; font-size: 11px; fill: #444; }
.wire { stroke: #1a1a1a; stroke-width: 2; fill: none; }
.losewire { stroke: #888; stroke-width: 2; stroke-dasharray: 4,3; fill: none; }
.title { font-family: monospace; font-size: 15px; fill: #000; font-weight: bold; }
\</style\>

<text x="370" y="20" text-anchor="middle" class="title">I2C Arbitration: Master A (0x28) vs Master B (0x2C) (svg_diagram)</text>

<text x="20" y="60" class="lbl">Master A intends:</text>

<text x="220" y="60" class="small">0 0 1 0 1 0 0 0</text>

<text x="20" y="90" class="lbl">Master B intends:</text>

<text x="220" y="90" class="small">0 0 1 0 1 1 0 0</text>

<text x="20" y="130" class="lbl">Actual bus (SDA):</text>

<text x="220" y="130" class="small">0 0 1 0 1 0 0 0</text>

<line x1="380" y1="45" x2="380" y2="140" class="losewire" />
<text x="390" y="170" class="small">Bit 5 diverges: A drives 0, B drives 1</text>
<text x="390" y="190" class="small">B reads back actual bus = 0 (not its own 1)</text>
<text x="390" y="210" class="small">B detects arbitration loss, stops driving</text>
<text x="390" y="230" class="small">A continues transaction uncontested</text>

<text x="20" y="280" class="lbl">Result:</text>

<text x="20" y="300" class="small">Master A wins (lower address value at divergence bit)</text>

<text x="20" y="320" class="small">Master B retries transaction after bus is free</text>

</svg>

#### Practical Implications for Embedded Design

- **No data corruption risk**: Unlike a naive collision on a shared line, I2C arbitration guarantees the winning transaction proceeds with correct data; the mechanism only ever silently drops the losing master's attempt.
- **Losing master must implement retry logic**: Firmware on a multi-master node must detect an arbitration-lost condition (typically flagged by the I2C peripheral hardware status register) and requeue the transaction rather than treating it as a fatal bus error.
- **Address value affects arbitration priority**: A master that will frequently need to win contention (e.g., a time-critical control node) can be assigned a lower address value, since lower addresses have arbitration priority — though this is a soft, informal design consideration rather than a documented I2C best practice for priority assignment.
- **True multi-master designs are relatively uncommon in typical embedded sensor/peripheral work**: Most embedded I2C buses use a single MCU as the sole master with multiple passive slave peripherals; genuine multi-master scenarios arise mainly in systems with multiple independent processing nodes sharing a bus (e.g., a main MCU and a coprocessor both needing to initiate transactions to shared peripherals).

### Clock Stretching Mechanism

#### The Core Principle: Slave Control Over SCL

While SCL is nominally "master-driven," its open-drain nature means any device — including a slave — can also pull it low. Clock stretching exploits this: after the master releases SCL high at the end of a clock pulse, a slave that needs more time before it can accept or supply the next bit holds SCL low, preventing the master from proceeding to the next clock transition until the slave releases it.

#### When Clock Stretching Occurs

- **Slave needs processing time before ACK**: A sensor that has just received a command and needs to begin an internal operation (e.g., starting an ADC conversion) before it can meaningfully acknowledge may stretch the clock during the ACK bit.
- **Slave needs time to prepare read data**: When a master reads from a slave, the slave may not have the next data byte immediately ready (e.g., it must fetch from internal memory or complete a computation) and stretches the clock at the start of that byte until the data is ready to shift out.
- **Byte-level pacing on slower devices**: Some low-power or simple microcontroller-based I2C slaves stretch the clock on every byte boundary as a matter of course, since their firmware-based (rather than hardware-buffered) I2C handling needs time between bytes to service the transaction in software.

#### Master-Side Handling Requirement

For clock stretching to work correctly, the master must not simply toggle SCL on a fixed internal timer — it must actively read back the SCL line state after releasing it and wait until SCL is observed to actually be high before considering the clock pulse to have occurred. A master that assumes SCL follows its own output timing unconditionally will violate the protocol against any slave that stretches, leading to bit misalignment or missed data.

$$t_{LOW,actual} = t_{LOW,nominal} + t_{stretch}$$

The low period of the clock is extended by however long the slave holds the line, with no fixed upper bound defined by the base I2C specification itself (though individual master implementations, bus timeout watchdogs, or higher-layer protocols built on I2C may impose a practical maximum stretch duration).

#### Clock Stretching Timing Sequence (svg_diagram)

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 700 260">
\<style\>
.lbl { font-family: monospace; font-size: 13px; fill: #1a1a1a; }
.small { font-family: monospace; font-size: 11px; fill: #444; }
.wire { stroke: #1a1a1a; stroke-width: 2; fill: none; }
.dash { stroke: #888; stroke-width: 1; stroke-dasharray: 3,3; fill: none; }
.title { font-family: monospace; font-size: 15px; fill: #000; font-weight: bold; }
\</style\>

<text x="350" y="20" text-anchor="middle" class="title">Clock Stretching by Slave (svg_diagram)</text>

<text x="20" y="60" class="lbl">Master intends SCL:</text>

<path class="wire" d="M220,70 L260,70 L260,50 L300,50 L300,70 L340,70 L340,50 L380,50" />

<text x="390" y="55" class="small">normal clocking</text>

<text x="20" y="130" class="lbl">Actual SCL (bus):</text>

<path class="wire" d="M220,140 L260,140 L260,120 L300,120 L300,140 L440,140 L440,120 L480,120" />

<text x="310" y="160" class="small">slave holds SCL low (stretch period)</text>

<path class="dash" d="M300,180 L300,140" />
<path class="dash" d="M440,180 L440,140" />
<text x="330" y="200" class="small">extended LOW period</text>

<text x="20" y="240" class="small">Master must poll actual SCL level before proceeding to next clock edge</text>

</svg>

### Combined Consideration: Multi-Master Buses With Clock Stretching

When both features are in use on the same bus, a small additional subtlety applies: during arbitration, competing masters must also each independently respect clock stretching from any slave being addressed, since a stretched clock affects all devices on the bus equally (SCL is shared). A master involved in arbitration cannot proceed to its next bit until it observes SCL has actually returned high, regardless of whether it is currently winning or about to lose arbitration — the clock-stretch wait is a bus-wide gating condition that happens independently of, and prior to, the address-bit comparison for that clock cycle.

### Hardware and Firmware Support Considerations

- **Not all I2C peripheral hardware fully implements SCL readback and stretch-waiting**: Some simplified or bit-banged (GPIO-toggled) I2C master implementations assume a fixed clock timing and do not check the actual SCL line state before proceeding, which will cause communication failures against any slave that stretches — this should be verified against the specific MCU's I2C peripheral documentation or driver implementation rather than assumed. [Inference — the extent of correct clock-stretch handling varies significantly across hardware peripheral designs and software/bit-banged implementations, and is not guaranteed by the mere presence of an "I2C" label on a peripheral.]
- **Multi-master support is similarly peripheral-dependent**: Not every MCU's hardware I2C peripheral supports the arbitration-lost detection and automatic backoff needed for robust multi-master operation; some peripherals only support master-only or slave-only modes, or require significant firmware-level handling to behave correctly in a multi-master role.
- **Bus timeout watchdogs**: Because clock stretching has no protocol-mandated maximum duration, systems in safety- or reliability-sensitive contexts often implement a firmware or hardware timeout that aborts a transaction and initiates bus recovery if a slave stretches the clock for an unreasonably long period, protecting against a faulty slave hanging the entire bus indefinitely.
- **SMBus timeout addition**: The System Management Bus (SMBus) specification, an I2C-derived protocol, explicitly adds a maximum clock-low timeout (commonly cited around 35 ms) that base I2C does not mandate — a detail relevant when working with SMBus-compliant devices on an otherwise generic I2C bus, since some SMBus devices may interpret an excessively long stretch (from another cause) as a fault condition. [Unverified — exact timeout value should be confirmed against the specific SMBus specification revision and device datasheet in use.]

### Firmware-Side Considerations

- **Arbitration-lost interrupt/status handling**: On MCUs with hardware I2C peripherals supporting multi-master mode, an arbitration-lost condition typically sets a dedicated status flag or triggers an interrupt; firmware should catch this distinctly from a NACK or bus error and requeue the pending transaction rather than treating it as a hard failure.
- **Bounded wait when stretching is expected**: When communicating with a slave device known to stretch the clock for a bounded but non-trivial duration (per its datasheet), firmware-side transaction timeout values should be set generously enough to avoid falsely aborting a valid, if slow, transaction.
- **Bus recovery procedure applicability**: The same stuck-bus recovery technique used for a hung slave (manually clocking SCL to force release, per general I2C fault handling) applies if a slave clock-stretches indefinitely due to a fault; firmware should distinguish "slave is legitimately still stretching within expected bounds" from "slave appears to be stuck" using a timeout threshold.
- **Testing multi-master and stretching behavior in isolation**: Because both behaviors are relatively rare in simple embedded designs and easy to overlook during bring-up (a bus with only well-behaved, fast slaves may never exercise stretching, and a single-master design never exercises arbitration), dedicated test cases or a bus analyzer capture exercising these conditions are advisable before deploying a design that depends on either feature working correctly.

### Related Topics

- I2C protocol and addressing fundamentals
- Bus recovery procedures for stuck SDA/SCL conditions
- SMBus and PMBus as I2C-derived protocols with added timing constraints
- I2C bus analyzer and logic analyzer capture techniques for protocol debugging
- Hardware vs. bit-banged I2C peripheral implementation tradeoffs
- Interrupt-driven I2C driver architecture for multi-master firmware
- Bus fault detection and timeout watchdog design in serial communication stacks