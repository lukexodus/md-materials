## DDR Standards


DDR (Double Data Rate) SDRAM transfers data on both the rising and falling edges of the clock signal, doubling throughput relative to SDR SDRAM at the same clock frequency. DDR4 and DDR5 represent the two current mainstream generations, with DDR5 in active deployment across server and consumer platforms as of 2025.

---

### Fundamental DDR Concepts

Before contrasting DDR4 and DDR5, the underlying mechanisms common to both:

**Double data rate:** Data is sampled on both clock edges. A 1600 MHz clock yields an effective 3200 MT/s (megatransfers per second). Published speeds are always in MT/s — "DDR4-3200" means 3200 MT/s at 1600 MHz actual clock.

**Prefetch architecture:** DRAM internal arrays operate much slower than the I/O bus. To feed the bus, DDR reads multiple bits per internal cycle from the array and serializes them onto the bus. The prefetch width determines how many bits are fetched from the array per access:

|Generation|Prefetch width|
|---|---|
|DDR3|8n|
|DDR4|8n|
|DDR5|16n|

DDR5's 16n prefetch doubles the internal burst length, enabling higher bus speeds without proportionally increasing array access frequency.

**Burst length:** The number of consecutive transfers per command. DDR4 default burst length is 8 (BL8). DDR5 default is 16 (BL16), consistent with its wider prefetch.

**Bank and rank structure:** A DIMM contains one or more ranks (independently selectable chip groups), each containing multiple banks. Parallelism across banks hides row activation latency (tRCD, tRP) by pipelining access to different banks.

---

### Voltage and Signaling

|Parameter|DDR4|DDR5|
|---|---|---|
|VDD (core + I/O)|1.2 V|1.1 V|
|VDDQ (I/O)|1.2 V|1.1 V|
|Signaling|SSTL-12 (single-ended)|POD12 (Pseudo Open Drain)|
|On-die termination|Yes|Yes (improved)|

DDR5 adopts POD (Pseudo Open Drain) signaling. In POD, the high state is maintained by termination to VDDQ rather than by an active driver, while the low state is driven actively. This reduces power during high-level periods and improves signal integrity at higher frequencies.

DDR5's lower operating voltage (1.1 V vs. 1.2 V) reduces dynamic power consumption quadratically — power scales as V². The reduction from 1.2 V to 1.1 V yields approximately a 16% reduction in dynamic power at equivalent switching frequency.

---

### Channel Architecture

The most structurally significant change in DDR5 is the **channel split**:

**DDR4:** A single 64-bit data channel per DIMM (72-bit with ECC). All banks share one channel.

**DDR5:** Each DIMM contains **two independent 32-bit sub-channels** (40-bit each with ECC). Each sub-channel has its own command/address bus, data bus, and can operate independently.

<svg viewBox="0 0 540 220" xmlns="http://www.w3.org/2000/svg" font-family="monospace" font-size="10"> <!-- DDR4 --> <text x="120" y="18" text-anchor="middle" fill="#cdd6f4" font-size="12" font-weight="bold">DDR4 DIMM</text> <rect x="20" y="25" width="200" height="60" rx="3" fill="#1e1e2e" stroke="#89b4fa" stroke-width="1.3"/> <text x="120" y="50" text-anchor="middle" fill="#89b4fa">Single 64-bit channel</text> <text x="120" y="66" text-anchor="middle" fill="#6c7086">(72-bit w/ ECC)</text> <!-- DDR4 banks --> <rect x="30" y="100" width="40" height="30" rx="2" fill="#313244" stroke="#6c7086" stroke-width="0.9"/> <text x="50" y="120" text-anchor="middle" fill="#cdd6f4">B0</text> <rect x="80" y="100" width="40" height="30" rx="2" fill="#313244" stroke="#6c7086" stroke-width="0.9"/> <text x="100" y="120" text-anchor="middle" fill="#cdd6f4">B1</text> <rect x="130" y="100" width="40" height="30" rx="2" fill="#313244" stroke="#6c7086" stroke-width="0.9"/> <text x="150" y="120" text-anchor="middle" fill="#cdd6f4">B2</text> <rect x="180" y="100" width="40" height="30" rx="2" fill="#313244" stroke="#6c7086" stroke-width="0.9"/> <text x="200" y="120" text-anchor="middle" fill="#cdd6f4">B3</text> <line x1="120" y1="85" x2="120" y2="100" stroke="#89b4fa" stroke-width="1.1" stroke-dasharray="3,2"/> <!-- DDR5 -->

<text x="400" y="18" text-anchor="middle" fill="#cdd6f4" font-size="12" font-weight="bold">DDR5 DIMM</text>

<!-- Channel A --> <rect x="300" y="25" width="90" height="60" rx="3" fill="#1e1e2e" stroke="#a6e3a1" stroke-width="1.3"/> <text x="345" y="46" text-anchor="middle" fill="#a6e3a1">Channel A</text> <text x="345" y="60" text-anchor="middle" fill="#6c7086">32-bit</text> <text x="345" y="74" text-anchor="middle" fill="#6c7086">(40 w/ ECC)</text> <!-- Channel B --> <rect x="410" y="25" width="90" height="60" rx="3" fill="#1e1e2e" stroke="#cba6f7" stroke-width="1.3"/> <text x="455" y="46" text-anchor="middle" fill="#cba6f7">Channel B</text> <text x="455" y="60" text-anchor="middle" fill="#6c7086">32-bit</text> <text x="455" y="74" text-anchor="middle" fill="#6c7086">(40 w/ ECC)</text> <!-- DDR5 banks A --> <rect x="300" y="105" width="35" height="25" rx="2" fill="#313244" stroke="#6c7086" stroke-width="0.9"/> <text x="317" y="122" text-anchor="middle" fill="#cdd6f4">B0</text> <rect x="345" y="105" width="35" height="25" rx="2" fill="#313244" stroke="#6c7086" stroke-width="0.9"/> <text x="362" y="122" text-anchor="middle" fill="#cdd6f4">B1</text> <!-- DDR5 banks B --> <rect x="410" y="105" width="35" height="25" rx="2" fill="#313244" stroke="#6c7086" stroke-width="0.9"/> <text x="427" y="122" text-anchor="middle" fill="#cdd6f4">B0</text> <rect x="455" y="105" width="35" height="25" rx="2" fill="#313244" stroke="#6c7086" stroke-width="0.9"/> <text x="472" y="122" text-anchor="middle" fill="#cdd6f4">B1</text> <line x1="345" y1="85" x2="345" y2="105" stroke="#a6e3a1" stroke-width="1.1" stroke-dasharray="3,2"/> <line x1="455" y1="85" x2="455" y2="105" stroke="#cba6f7" stroke-width="1.1" stroke-dasharray="3,2"/> <!-- Labels -->

<text x="120" y="175" text-anchor="middle" fill="#6c7086" font-size="9">All banks share one bus</text> <text x="400" y="175" text-anchor="middle" fill="#6c7086" font-size="9">Channels operate independently</text>

<!-- Bandwidth arrows -->

<text x="120" y="195" text-anchor="middle" fill="#89b4fa" font-size="9">max 1 command/cycle</text> <text x="400" y="195" text-anchor="middle" fill="#a6e3a1" font-size="9">2 commands/cycle (one per channel)</text> </svg>

The two DDR5 sub-channels can service different requests simultaneously. For a memory controller issuing requests to both channels in parallel, this doubles command bandwidth and improves utilization under mixed read/write traffic — particularly relevant for server workloads with multiple independent memory streams.

---

### Bank Group Architecture

**DDR4** introduced bank groups. A DDR4 device contains 4 bank groups × 4 banks = 16 banks total. Accesses to different bank groups can be pipelined with a shorter inter-command gap (tCCD_S = short) than accesses within the same bank group (tCCD_L = long).

**DDR5** extends this: 8 bank groups × 2 banks = 16 banks per sub-channel (per JEDEC DDR5 base spec), with optional bank group configurations depending on density. The increased bank group count improves bank-level parallelism for latency hiding.

---

### Speed Grades and Bandwidth

|Specification|Data Rate|Bandwidth (single channel)|
|---|---|---|
|DDR4-2133|2133 MT/s|17.0 GB/s|
|DDR4-3200|3200 MT/s|25.6 GB/s|
|DDR4-4800 (OC)|4800 MT/s|38.4 GB/s|
|DDR5-4800|4800 MT/s|38.4 GB/s|
|DDR5-6400|6400 MT/s|51.2 GB/s|
|DDR5-7200|7200 MT/s|57.6 GB/s|
|DDR5-8400 (XMP/EXPO)|8400 MT/s|67.2 GB/s|

Bandwidth = (data rate in MT/s × bus width in bytes). For DDR5 with two 32-bit (4-byte) sub-channels: effective bus width is still 8 bytes per DIMM, so bandwidth calculation is unchanged relative to DDR4 at equivalent MT/s. The benefit of dual sub-channels is latency and concurrency, not raw bandwidth per DIMM.

---

### Latency: Absolute vs. Relative

DDR5 launches at higher CAS latency (CL) numbers than DDR4:

|Module|CL|tCK (ns)|Absolute CAS latency|
|---|---|---|---|
|DDR4-3200 CL22|22|0.625 ns|13.75 ns|
|DDR5-4800 CL40|40|0.417 ns|16.67 ns|
|DDR5-6400 CL32|32|0.313 ns|10.0 ns|
|DDR5-8400 CL38|38|0.238 ns|9.05 ns|

CL numbers in DDR5 are larger because they are measured in clock cycles, and DDR5 clock cycles are shorter. Absolute latency (CL × tCK) is what matters for access time. Early DDR5-4800 had higher absolute latency than DDR4-3200; higher-speed DDR5 grades recover and surpass DDR4 in absolute latency.

Key timing parameters:

|Parameter|Meaning|
|---|---|
|tCL|CAS latency — read command to first data|
|tRCD|RAS to CAS delay — row activate to column access|
|tRP|Row precharge — precharge to next activate|
|tRAS|Row active time — minimum row open time|
|tRFC|Refresh cycle time — time for a refresh operation|
|tCCD_L|CAS to CAS delay, same bank group|
|tCCD_S|CAS to CAS delay, different bank group|

---

### On-DIMM Power Management

**DDR4:** Power management (voltage regulation) is handled on the motherboard by discrete VRMs (Voltage Regulator Modules) external to the DIMM.

**DDR5:** Integrates a **PMIC (Power Management IC)** directly onto the DIMM. The PMIC receives 12 V from the motherboard and generates the required 1.1 V VDD, VDDQ, and VPP rails on-DIMM.

Consequences:

- Simpler motherboard power delivery design
- Better voltage regulation at the point of load — reduced impedance between regulator and DRAM dies
- PMIC adds cost and a failure point to the DIMM itself
- Allows more precise per-DIMM power state management

---

### Refresh Architecture

DRAM capacitors leak charge and require periodic refresh. Refresh operations occupy the memory bus and add latency.

**DDR4 refresh:** All-bank refresh (REFab) refreshes all banks simultaneously. tRFC for a 16 Gb DDR4 device is approximately 350 ns. Refresh commands are issued every tREFI = 7.8 µs (at 85°C operating range).

**DDR5 refresh improvements:**

**Same Bank Refresh (REFsb):** DDR5 introduces per-bank refresh, allowing one bank to refresh while others remain accessible. This reduces the effective refresh penalty by distributing it across the bank population rather than stalling all accesses.

**Per-Bank Refresh (PBR):** A further refinement allowing the memory controller to schedule refresh at finer granularity, improving latency predictability for real-time workloads.

**Extended temperature range:** DDR5 specifies operation up to 95°C (vs. 85°C for DDR4 standard), with doubled refresh rate (tREFI halved) above 85°C — relevant for dense server DIMMs.

**tRFC scaling:** As die density increases, refresh time increases because more rows must be refreshed. DDR5 at 64 Gb die density has tRFC values exceeding 600 ns — a non-trivial fraction of the 7.8 µs inter-refresh interval.

---

### ECC Architecture

**DDR4 (non-ECC):** 64-bit data bus, no error correction on the DIMM itself. ECC requires 72-bit RDIMM/UDIMM with 8 check bits per 64-bit word, handled by the memory controller.

**DDR5:** Introduces **on-die ECC (ODECC)** as a mandatory feature on all DDR5 devices, regardless of DIMM type. Each 128-bit internal word has check bits computed and verified by logic within the DRAM die itself before data reaches the I/O bus.

ODECC corrects single-bit errors within the die — primarily targeting soft errors from charge leakage in the dense DDR5 cell arrays. It is transparent to the memory controller.

ODECC does **not** replace system-level ECC (RDIMM / LRDIMM). System ECC corrects errors on the bus and in multi-die packages. The two operate at different granularities and are complementary.

---

### Decision Register and SPD

Both DDR4 and DDR5 DIMMs contain an **SPD (Serial Presence Detect)** EEPROM storing timing parameters, manufacturer data, and XMP/EXPO profiles.

DDR5 replaces the SPD Hub with a more capable **SPD5118** hub supporting:

- I3C interface (replacing I2C used in DDR4 SPD)
- Write protection and security features
- Temperature sensor integration
- Support for XMP 3.0 (Intel) and EXPO (AMD) overclock profiles, which can store up to 5 profiles per DIMM (DDR5) vs. 2 (DDR4 XMP 2.0)

---

### RCD (Registering Clock Driver) Changes

Registered DIMMs (RDIMMs) used in servers place a **Register Clock Driver (RCD)** on the DIMM to buffer the command/address bus, allowing larger DIMM counts per channel.

**DDR4 RCD:** RCD01 — single copy of command/address signals, rebuffered.

**DDR5 RCD:** RCD03 — independently buffers command/address for each of the two sub-channels. Also integrates the SPD hub function and supports additional error checking on the command bus (Command/Address Parity improvements).

---

### Platform Support

|Platform|DDR4|DDR5|
|---|---|---|
|Intel Alder Lake (12th gen)|Yes|Yes (mixed, platform-dependent)|
|Intel Raptor Lake (13th/14th gen)|Yes|Yes|
|Intel Meteor Lake / Arrow Lake|No|Yes only|
|AMD Zen 3 (Ryzen 5000)|Yes|No|
|AMD Zen 4 (Ryzen 7000)|No|Yes only|
|AMD Zen 5 (Ryzen 9000)|No|Yes only|
|Intel Sapphire Rapids (server)|No|Yes only (DDR5 / HBM)|
|AMD Genoa / Bergamo (EPYC)|No|Yes only|

DDR4 and DDR5 are physically and electrically incompatible — different pin counts (288-pin DDR4 vs. 288-pin DDR5 with different keying), different voltages, different signaling. A DDR5 DIMM cannot be inserted into a DDR4 slot.

---

### Summary Comparison

|Parameter|DDR4|DDR5|
|---|---|---|
|Voltage|1.2 V|1.1 V|
|Signaling|SSTL-12|POD12|
|Prefetch|8n|16n|
|Default burst length|BL8|BL16|
|Channel width per DIMM|64-bit (×1)|32-bit (×2)|
|Max speed (JEDEC)|3200 MT/s|6400 MT/s (base); higher with profiles|
|Banks|16 (4 groups × 4)|32 (8 groups × 4, per DIMM)|
|On-die ECC|No|Yes (mandatory)|
|On-DIMM PMIC|No|Yes|
|Same-bank refresh|No|Yes|
|SPD interface|I2C|I3C|
|Power management|Motherboard VRM|On-DIMM PMIC|

---

**Key Points**

- DDR5's dual sub-channel architecture is its most structurally significant change — it doubles command-bus concurrency per DIMM, improving utilization under mixed workloads more than raw MT/s alone suggests
- The 16n prefetch in DDR5 (vs. 8n in DDR4) is what enables higher bus speeds without requiring proportionally faster DRAM array access times
- Absolute CAS latency (CL × tCK), not the CL number, determines actual access time — early DDR5 grades had worse absolute latency than DDR4-3200, a gap that higher-speed DDR5 grades close and surpass
- On-die ECC in DDR5 corrects errors within the DRAM die and is complementary to, not a replacement for, system-level ECC on RDIMMs
- Same-bank refresh in DDR5 reduces the latency penalty of refresh operations by allowing non-refreshing banks to remain accessible during a per-bank refresh cycle
- DDR4 and DDR5 are physically incompatible despite sharing the same pin count — keying and electrical specifications differ
---

