## Trusted Execution Environments


A Trusted Execution Environment is an isolated execution context provided by hardware — and enforced by hardware — in which code and data are protected from observation or modification by software running outside that environment, including the operating system, hypervisor, and other applications. The isolation guarantee is rooted in hardware mechanisms rather than software privilege levels, which is what distinguishes a TEE from a conventional process sandbox.

---

### Threat Model

A TEE is designed to address a specific class of adversaries that conventional privilege separation does not handle:

|Adversary|Conventional OS isolation|TEE|
|---|---|---|
|Unprivileged process|Blocked|Blocked|
|Privileged process (root)|**Not blocked**|Blocked|
|Operating system kernel|**Not blocked**|Blocked|
|Hypervisor / VMM|**Not blocked**|Blocked (in most designs)|
|Physical DRAM attacker|**Not blocked**|Blocked (with memory encryption)|
|Firmware attacker|**Not blocked**|Partially blocked|
|Hardware attacker (PCB probing)|**Not blocked**|Outside TEE scope|

The fundamental assumption is that the **hardware and the code loaded into the TEE** are trusted; everything else — including all privileged software — is untrusted.

---

### Core Hardware Mechanisms

All TEE implementations rest on a common set of hardware primitives:

#### Isolation

The processor enforces a boundary between trusted and untrusted execution contexts. Transitions across this boundary are controlled — arbitrary jumps from untrusted code into trusted code at arbitrary addresses are prohibited. Entry points are fixed and validated.

#### Memory Protection

Physical memory regions allocated to a TEE are protected by hardware so that accesses from outside the TEE — even from the OS kernel using physical addresses — are blocked or return garbage. This is enforced by:

- A dedicated hardware unit that checks every memory transaction against an access control table
- Memory encryption, which renders DRAM contents unreadable even to physical bus snoopers

#### Attestation

A TEE can produce a cryptographically signed measurement of its initial state — the hash of the code and data loaded at initialization — using a key known only to the hardware. A remote party can verify this measurement to confirm they are communicating with the expected, unmodified code running inside a genuine TEE, rather than a simulation.

#### Sealing

A TEE can encrypt data under a key derived from its own measurement and the hardware identity. Sealed data can only be decrypted by the same code running on the same hardware — or code with a permitted measurement relationship.

---

### Intel SGX (Software Guard Extensions)

SGX, introduced in Skylake (2015), is the most extensively studied TEE implementation. It operates at the application level: the trusted component is a userspace library called an **enclave**, not an entire OS.

#### Enclave Page Cache (EPC)

SGX reserves a region of physical DRAM called **Processor Reserved Memory (PRM)**, within which the **Enclave Page Cache (EPC)** resides. EPC pages are encrypted by the **Memory Encryption Engine (MEE)** using AES-128 with integrity protection (Merkle tree of MACs). Accesses to EPC pages from outside the enclave — including from the OS kernel — return ciphertext or trigger an abort.

<svg viewBox="0 0 680 340" xmlns="http://www.w3.org/2000/svg" font-family="monospace" font-size="11"> <defs> <marker id="asgx" markerWidth="7" markerHeight="7" refX="5" refY="3" orient="auto"> <path d="M0,0 L0,6 L7,3 z" fill="#aaa"/> </marker> </defs> <!-- Untrusted region --> <rect x="10" y="10" width="300" height="300" rx="4" fill="#1a1a1a" stroke="#555" stroke-width="1.5" stroke-dasharray="6,3"/> <text x="160" y="28" fill="#555" text-anchor="middle" font-size="10">Untrusted Address Space</text> <!-- OS / Kernel box --> <rect x="25" y="35" width="270" height="45" rx="3" fill="#2a1a1a" stroke="#ef9a9a" stroke-width="1"/> <text x="160" y="57" fill="#ef9a9a" text-anchor="middle">OS Kernel / Hypervisor</text> <text x="160" y="71" fill="#888" text-anchor="middle" font-size="9">Cannot read EPC · Can manage page assignments</text> <!-- Untrusted app --> <rect x="25" y="90" width="270" height="45" rx="3" fill="#1a2a1a" stroke="#888" stroke-width="1"/> <text x="160" y="112" fill="#aaa" text-anchor="middle">Untrusted Application</text> <text x="160" y="126" fill="#666" text-anchor="middle" font-size="9">ECALL → enclave · OCALL ← enclave</text> <!-- Enclave --> <rect x="25" y="150" width="270" height="140" rx="3" fill="#1a2a3a" stroke="#4fc3f7" stroke-width="2"/> <text x="160" y="170" fill="#4fc3f7" text-anchor="middle">Enclave (EPC pages)</text> <rect x="40" y="180" width="110" height="30" rx="2" fill="#0d1a2a" stroke="#4fc3f7" stroke-width="1"/> <text x="95" y="197" fill="#aaa" text-anchor="middle" font-size="9">Enclave Code</text> <text x="95" y="208" fill="#555" text-anchor="middle" font-size="8">(measured at load)</text> <rect x="165" y="180" width="110" height="30" rx="2" fill="#0d1a2a" stroke="#4fc3f7" stroke-width="1"/> <text x="220" y="197" fill="#aaa" text-anchor="middle" font-size="9">Enclave Data</text> <text x="220" y="208" fill="#555" text-anchor="middle" font-size="8">(confidential)</text> <rect x="40" y="225" width="235" height="25" rx="2" fill="#0a1020" stroke="#ce93d8" stroke-width="1"/> <text x="157" y="241" fill="#ce93d8" text-anchor="middle" font-size="9">Thread Control Structures (TCS) · SSA frames</text> <rect x="40" y="258" width="235" height="20" rx="2" fill="#0a1020" stroke="#66bb6a" stroke-width="1"/> <text x="157" y="271" fill="#66bb6a" text-anchor="middle" font-size="9">SECS · local attestation keys</text> <!-- MEE box --> <rect x="370" y="130" width="140" height="80" rx="3" fill="#2a1a2a" stroke="#ce93d8" stroke-width="1.5"/> <text x="440" y="155" fill="#ce93d8" text-anchor="middle">Memory</text> <text x="440" y="168" fill="#ce93d8" text-anchor="middle">Encryption</text> <text x="440" y="181" fill="#ce93d8" text-anchor="middle">Engine (MEE)</text> <text x="440" y="196" fill="#888" text-anchor="middle" font-size="9">AES-CTR + Merkle MAC</text> <!-- DRAM --> <rect x="370" y="230" width="140" height="50" rx="3" fill="#2a2a1a" stroke="#f9a825" stroke-width="1.5"/> <text x="440" y="255" fill="#f9a825" text-anchor="middle">DRAM (EPC)</text> <text x="440" y="270" fill="#888" text-anchor="middle" font-size="9">Ciphertext on bus</text> <!-- CPU die --> <rect x="370" y="20" width="140" height="90" rx="3" fill="#1a3a1a" stroke="#66bb6a" stroke-width="1.5"/> <text x="440" y="40" fill="#66bb6a" text-anchor="middle">CPU Die</text> <text x="440" y="58" fill="#aaa" text-anchor="middle" font-size="9">Plaintext inside</text> <text x="440" y="70" fill="#aaa" text-anchor="middle" font-size="9">processor package</text> <text x="440" y="85" fill="#888" text-anchor="middle" font-size="9">Keys never leave die</text> <!-- Arrows --> <line x1="295" y1="220" x2="370" y2="170" stroke="#ce93d8" stroke-width="1.5" marker-end="url(#asgx)"/> <line x1="440" y1="210" x2="440" y2="230" stroke="#f9a825" stroke-width="1.5" marker-end="url(#asgx)"/> <line x1="440" y1="110" x2="440" y2="130" stroke="#66bb6a" stroke-width="1.5" marker-end="url(#asgx)"/> </svg>

#### SGX Measurement and MRENCLAVE

When an enclave is loaded, the processor constructs a running hash (SHA-256) of every page added to the enclave — its contents, position, and permissions. The final value is stored in the hardware-maintained **MRENCLAVE** register. This measurement is:

- Deterministic: the same code loaded identically produces the same MRENCLAVE
- Tamper-evident: any modification to enclave code or data changes the measurement
- Sealed: data sealed to an MRENCLAVE can only be unsealed by the same enclave

A second register, **MRSIGNER**, records the hash of the enclave developer's public key, permitting policy based on the signing identity rather than exact code version.

#### ECALL / OCALL Interface

```
Untrusted app                    Enclave
     |                               |
     |──── ECALL(function_id) ──────►|
     |     (enters via fixed gate)   |
     |                               |── processes in isolated memory
     |                               |
     |◄─── OCALL(syscall request) ───|   (enclave cannot syscall directly)
     |     OS performs syscall       |
     |──── OCALL return ────────────►|
     |                               |
     |◄─── ECALL return ─────────────|
```

The enclave cannot issue system calls directly — all interactions with the OS are mediated through an OCALL to untrusted code. The enclave must therefore treat all data returned via OCALL as potentially adversarial.

#### SGX Limitations

- **EPC size constraint:** Early SGX limited EPC to 128 MiB (SGX2 extended this, but paging encrypted EPC out to DRAM incurs overhead).
- **Side-channel vulnerability:** [Unverified — behavior depends on specific hardware revision and microcode version] SGX enclaves have been shown to be susceptible to cache-timing attacks, page-fault side channels, and speculative execution attacks (see Foreshadow/L1TF). The hardware trust model does not cover software side channels.
- **Deprecated in client CPUs:** Intel announced deprecation of SGX on 11th and 12th gen client processors; SGX continues on Xeon server platforms.

> [Inference] The side-channel vulnerability class undermines the confidentiality guarantee in practice for certain adversary models. This does not invalidate the architectural model but must be factored into deployment decisions. Behavior under any specific attack scenario is not guaranteed.

---

### ARM TrustZone

TrustZone, available since ARMv6 (2004) and present in virtually all ARM application processors, partitions the system into two worlds rather than isolating a single enclave.

#### Two-World Architecture

<svg viewBox="0 0 680 280" xmlns="http://www.w3.org/2000/svg" font-family="monospace" font-size="11"> <defs> <marker id="atz" markerWidth="7" markerHeight="7" refX="5" refY="3" orient="auto"> <path d="M0,0 L0,6 L7,3 z" fill="#aaa"/> </marker> </defs> <!-- Normal World --> <rect x="10" y="30" width="290" height="220" rx="4" fill="#1a1a2a" stroke="#4fc3f7" stroke-width="1.5"/> <text x="155" y="52" fill="#4fc3f7" text-anchor="middle">Normal World (NS=1)</text> <rect x="25" y="60" width="260" height="40" rx="3" fill="#0d1a2a" stroke="#4fc3f7" stroke-width="1"/> <text x="155" y="83" fill="#aaa" text-anchor="middle">Rich OS (Linux / Android)</text> <rect x="25" y="110" width="260" height="35" rx="3" fill="#0d1a2a" stroke="#555" stroke-width="1"/> <text x="155" y="131" fill="#777" text-anchor="middle">User Applications</text> <rect x="25" y="155" width="260" height="35" rx="3" fill="#0d1a2a" stroke="#555" stroke-width="1"/> <text x="155" y="176" fill="#777" text-anchor="middle">Normal World Drivers</text> <rect x="25" y="200" width="260" height="35" rx="3" fill="#0d1020" stroke="#ce93d8" stroke-width="1"/> <text x="155" y="222" fill="#ce93d8" text-anchor="middle">TEE Client API (libteec)</text> <!-- Secure World --> <rect x="380" y="30" width="290" height="220" rx="4" fill="#1a2a1a" stroke="#66bb6a" stroke-width="2"/> <text x="525" y="52" fill="#66bb6a" text-anchor="middle">Secure World (NS=0)</text> <rect x="395" y="60" width="260" height="40" rx="3" fill="#0d2a0d" stroke="#66bb6a" stroke-width="1"/> <text x="525" y="83" fill="#aaa" text-anchor="middle">Trusted OS (OP-TEE / proprietary)</text> <rect x="395" y="110" width="260" height="35" rx="3" fill="#0d2a0d" stroke="#66bb6a" stroke-width="1"/> <text x="525" y="131" fill="#aaa" text-anchor="middle">Trusted Applications (TAs)</text> <text x="525" y="143" fill="#555" text-anchor="middle" font-size="9">DRM · biometric · payment · keystore</text> <rect x="395" y="155" width="260" height="35" rx="3" fill="#0d2a0d" stroke="#555" stroke-width="1"/> <text x="525" y="173" fill="#777" text-anchor="middle">Secure Drivers (display, crypto HW)</text> <rect x="395" y="200" width="260" height="35" rx="3" fill="#0a1a0a" stroke="#f9a825" stroke-width="1"/> <text x="525" y="222" fill="#f9a825" text-anchor="middle">Secure Monitor (EL3)</text> <!-- Monitor / SMC boundary --> <rect x="305" y="30" width="70" height="220" rx="3" fill="#0a0a0a" stroke="#f9a825" stroke-width="2"/> <text x="340" y="100" fill="#f9a825" text-anchor="middle" font-size="10" transform="rotate(90,340,100)">Secure Monitor</text> <text x="340" y="170" fill="#888" text-anchor="middle" font-size="9" transform="rotate(90,340,170)">SMC instruction</text> <!-- SMC arrow --> <line x1="300" y1="215" x2="310" y2="215" stroke="#f9a825" stroke-width="2" marker-end="url(#atz)"/> <line x1="370" y1="215" x2="395" y2="215" stroke="#f9a825" stroke-width="2" marker-end="url(#atz)"/> <!-- NS bit label -->

<text x="340" y="270" fill="#555" text-anchor="middle" font-size="9">NS bit on AXI bus controls memory routing</text> </svg>

#### NS Bit and Memory Routing

The ARM bus architecture (AXI / ACE) propagates a **Non-Secure (NS) bit** with every memory transaction. The **TrustZone Address Space Controller (TZASC)** and **TrustZone Memory Adapter (TZMA)** check this bit against their configuration:

- Secure-world transactions (NS=0) can access both secure and non-secure memory
- Normal-world transactions (NS=1) are blocked from secure memory regions by hardware

This protection is enforced on the interconnect, not in software, so a compromised Linux kernel cannot read secure-world memory regardless of privilege level.

#### SMC — Secure Monitor Call

Transition between worlds is initiated by the `SMC` instruction (similar to a system call but crossing the world boundary). The Secure Monitor, running at EL3 (the highest ARM privilege level), saves world state and transfers control to the other world. The Normal World cannot jump directly into the Secure World at arbitrary addresses.

#### TrustZone vs SGX

|Property|SGX|TrustZone|
|---|---|---|
|Isolation granularity|Per-enclave (library-level)|Two worlds (OS-level)|
|Trusted OS inside TEE|No|Yes (Trusted OS manages TAs)|
|Number of isolated contexts|Many enclaves simultaneously|One secure world|
|Attack surface of trusted component|Enclave code only|Entire trusted OS + all TAs|
|Hardware attestation|MRENCLAVE-based, per-enclave|Platform-level, implementation-dependent|
|Deployment|Server workloads, confidential compute|Mobile, IoT, embedded, SoC|

---

### AMD SEV (Secure Encrypted Virtualization)

SEV targets a different threat model from SGX and TrustZone: it protects **entire virtual machines** from the hypervisor. It is relevant in cloud scenarios where the cloud provider controls the hypervisor but the tenant does not wish to trust it.

#### SEV Variants

|Variant|Protection|
|---|---|
|**SEV**|Each VM encrypted with a unique AES-128 key; hypervisor sees ciphertext|
|**SEV-ES** (Encrypted State)|CPU register state also encrypted on VM exit; hypervisor cannot read registers|
|**SEV-SNP** (Secure Nested Paging)|Adds integrity protection; prevents hypervisor from remapping guest physical pages (replay, aliasing attacks)|

#### AMD Secure Processor (ASP)

SEV key management is handled by a dedicated ARM Cortex-A5 core embedded in the AMD SoC, called the **AMD Secure Processor (ASP)**. The ASP:

- Generates and stores per-VM encryption keys
- Never exposes keys to x86 cores or the hypervisor
- Handles attestation requests and signs measurements with a device-unique key provisioned at manufacturing

#### SEV-SNP Reverse Map Table (RMP)

SEV-SNP introduces the **Reverse Map Table (RMP)**: a hardware-maintained table with one entry per 4 KiB physical page, recording which VM (ASID) owns that page and at what guest physical address. On every memory access, hardware checks the RMP:

- A page owned by VM A cannot be accessed by VM B or the hypervisor
- A page cannot be double-mapped to different guest physical addresses within the same VM
- Violation triggers a page fault, not a silent data corruption

This prevents the hypervisor from performing remapping attacks that would be possible under SEV and SEV-ES.

---

### RISC-V Physical Memory Protection (PMP)

RISC-V does not yet have a standardized full TEE specification equivalent to SGX or TrustZone, but the base ISA includes **Physical Memory Protection (PMP)** as a building block.

PMP provides up to 64 configurable regions, each with:

- A base address and size (power-of-two aligned or NAPOT encoded)
- Permission bits: R (read), W (write), X (execute)
- A lock bit (L) making the entry immutable until reset

PMP entries are checked in priority order (entry 0 highest). Rules apply to machine-mode accesses when the L bit is set, and to all lower-privilege accesses otherwise.

RISC-V TEE proposals — including Keystone (research) and the RISC-V AP-TEE TG specification — build on PMP plus an additional Security Monitor running at M-mode to implement enclave-like isolation.

---

### Attestation in Detail

Attestation is the mechanism by which a relying party verifies the integrity of a TEE before sending it secrets. Two forms:

#### Local Attestation

Two enclaves on the same physical platform verify each other using a platform-shared secret (EPID-derived or ECDH-based). No third party is involved. Used for inter-enclave communication.

#### Remote Attestation

```
Enclave                  Platform Hardware           Relying Party (remote)
   |                           |                            |
   |── EREPORT ──────────────► |                            |
   |   (local measurement)     |                            |
   |                           |── EGETKEY (Report Key) ──► |  (via Quoting Enclave)
   |                           |── sign with device key ──► |
   |                                                         |
   |                           signed Quote ───────────────► |
   |                                                         |── verify with Intel/AMD CA
   |                                                         |── check MRENCLAVE
   |                                                         |── send secret if valid
```

The chain of trust terminates at hardware: the device key is burned into fuses at manufacturing and is not accessible to software. Intel's attestation infrastructure (EPID, then DCAP) and AMD's SEV attestation both follow this structure.

#### Attestation Trust Chain

|Layer|Who vouches|
|---|---|
|Hardware key|Manufacturer (burned at fabrication)|
|Platform certificate|Manufacturer CA signs device key cert|
|TEE measurement|Hardware measures code at load time|
|Application identity|TEE measurement signed by platform key|
|Relying party policy|Verifier checks measurement against known-good values|

---

### Sealing

Sealing binds encrypted data to a specific TEE identity so that only the correct code on the correct hardware can decrypt it.

|Sealing policy|Bound to|Use case|
|---|---|---|
|MRENCLAVE|Exact code version|High-security; breaks on any code update|
|MRSIGNER|Developer signing key|Permits version upgrades within same developer|
|Policy-based (SEV-SNP)|Measurement + platform policy|Cloud VM migration with verified state|

Sealed blobs are stored outside the TEE (e.g., on disk). If the TEE is compromised, its sealing key is not exposed — the sealed data remains unreadable. If the hardware is replaced, sealed data from the old hardware cannot be unsealed on new hardware unless the manufacturer provides a migration key.

---

### Side-Channel Attacks on TEEs

The hardware memory and execution isolation provided by TEEs does not address side channels — information leakage through shared microarchitectural resources.

|Attack class|Channel|Example|
|---|---|---|
|Cache timing|Shared L3 cache|Prime+Probe, Flush+Reload against SGX|
|Page fault|OS observes enclave page access pattern|Controlled-channel attack on SGX|
|Speculative execution|Transient out-of-bounds loads|Foreshadow (L1TF) — reads SGX EPC via L1 cache|
|Branch predictor|Shared BTB/BHT|BranchScope against SGX|
|Power / frequency|RAPL interface|Hertzbleed, PLATYPUS|
|Rowhammer|DRAM electrical coupling|[Inference] May interact with EPC mapping in some configurations|

> [Unverified] The precise exploitability of each attack depends on microarchitecture version, microcode patch level, and OS configuration. Specific mitigations exist for many of the above but may impose performance cost. Confirmed exploitability on a given platform requires independent verification.

The key implication: a TEE provides **isolation** but not **information-theoretic confidentiality** against an attacker who controls the platform and can observe microarchitectural state.

---

### Trusted Execution in the Cloud — Confidential Computing

The Confidential Computing Consortium (CCC), hosted by the Linux Foundation, coordinates standardization of TEE-based cloud primitives. The primary use cases:

|Use case|TEE mechanism|
|---|---|
|Confidential VM|AMD SEV-SNP, Intel TDX|
|Confidential container|SGX enclave, SEV-SNP VM + container runtime|
|Secure ML inference|Enclave-hosted model weights; input/output encrypted|
|Multi-party computation|Enclaves as trusted computation intermediaries|
|Regulated data processing|HIPAA/GDPR workloads processed without exposing plaintext to provider|

**Intel TDX (Trust Domain Extensions)** is a VM-granularity TEE analogous to AMD SEV-SNP, introduced in 4th generation Xeon Scalable. TDX isolates **Trust Domains** (TDs) from the hypervisor using architectural extensions and a dedicated **TDX Module** that acts as a security monitor for TD transitions.

---

### Hardware Root of Trust

TEEs depend on a **Hardware Root of Trust (HRoT)** — a set of hardware components whose trustworthiness is assumed rather than derived from software:

|Component|Role|
|---|---|
|Device fuse key (EPID / CEK)|Unique per-device identity; cannot be extracted by software|
|Secure boot ROM|First code executed; measures and verifies boot chain|
|Dedicated security processor|AMD ASP, Apple Secure Enclave Processor, Google Titan|
|Trusted Platform Module (TPM)|Discrete or firmware; stores measurements (PCRs), performs attestation|

The HRoT measures and verifies each subsequent boot stage; any modification to firmware, bootloader, or OS is reflected in the TPM's Platform Configuration Registers (PCRs), which can be included in an attestation report.

---

**Key Points**

- A TEE provides hardware-enforced isolation against privileged software adversaries — OS, hypervisor, and other processes — through memory access control and optional memory encryption.
- SGX isolates individual enclaves at library granularity; TrustZone partitions the entire system into two worlds; AMD SEV protects full VMs from the hypervisor.
- Attestation produces a hardware-signed measurement of TEE contents, allowing a remote party to verify identity and integrity before provisioning secrets.
- Sealing binds encrypted data to a TEE identity so that it can only be decrypted by the correct code on the correct hardware.
- Side-channel attacks — cache timing, speculative execution, page faults — operate outside the isolation boundary and are not addressed by the core TEE memory protection model.
- Confidential computing extends TEEs to cloud deployments, enabling workloads on untrusted infrastructure with hardware-enforced data confidentiality.
- All TEE security guarantees are rooted in a Hardware Root of Trust whose integrity is assumed at the hardware level and cannot be further verified in software.

**Next Steps** Proceed to hardware security attacks in depth (Spectre, Meltdown, and the class of transient execution vulnerabilities) or to hardware root of trust and secure boot chain architecture.

---

