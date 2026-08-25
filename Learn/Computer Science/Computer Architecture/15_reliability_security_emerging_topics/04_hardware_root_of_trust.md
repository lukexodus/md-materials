## Hardware Root of Trust


A hardware root of trust (HRoT) is the foundational layer of a security architecture whose correctness is assumed rather than derived — it is the point at which the chain of trust begins. Every higher-level security guarantee in a system depends, transitively, on the integrity of the root of trust. If the root is compromised, no software or firmware mechanism above it can be relied upon. This is why the root must be implemented in hardware: hardware is immutable after fabrication in a way that software and firmware are not.

---

### The Chain of Trust

Security in a computing system is not a property of any single component — it is a property of a sequence of verifications, each component verifying the next before transferring control. This sequence is the **chain of trust**.

<svg viewBox="0 0 620 340" xmlns="http://www.w3.org/2000/svg" font-family="monospace" font-size="12"> <text x="310" y="20" text-anchor="middle" fill="#94a3b8" font-size="13">Chain of Trust — Boot Sequence</text> <!-- Levels --> <!-- Level 0: HRoT --> <rect x="185" y="35" width="250" height="48" rx="6" fill="#450a0a" stroke="#f87171" stroke-width="2"/> <text x="310" y="56" text-anchor="middle" fill="#f87171" font-size="12">Hardware Root of Trust</text> <text x="310" y="73" text-anchor="middle" fill="#fca5a5" font-size="10">Immutable ROM · Fuses · HW crypto engine</text> <!-- Arrow --> <line x1="310" y1="83" x2="310" y2="103" stroke="#64748b" stroke-width="1.5"/> <polygon points="305,100 310,110 315,100" fill="#64748b"/> <text x="370" y="97" fill="#4ade80" font-size="10">verify signature</text> <!-- Level 1: First-stage bootloader --> <rect x="185" y="110" width="250" height="48" rx="6" fill="#1c1a10" stroke="#fbbf24" stroke-width="1.5"/> <text x="310" y="131" text-anchor="middle" fill="#fbbf24" font-size="12">First-Stage Bootloader</text> <text x="310" y="148" text-anchor="middle" fill="#fde68a" font-size="10">ROM / eFuse-locked flash (e.g. BootROM)</text> <line x1="310" y1="158" x2="310" y2="178" stroke="#64748b" stroke-width="1.5"/> <polygon points="305,175 310,185 315,175" fill="#64748b"/> <text x="370" y="172" fill="#4ade80" font-size="10">verify signature</text> <!-- Level 2: Second-stage bootloader --> <rect x="185" y="185" width="250" height="48" rx="6" fill="#1a2535" stroke="#38bdf8" stroke-width="1.5"/> <text x="310" y="206" text-anchor="middle" fill="#38bdf8" font-size="12">Second-Stage Bootloader</text> <text x="310" y="223" text-anchor="middle" fill="#7dd3fc" font-size="10">e.g. U-Boot, UEFI · mutable but verified</text> <line x1="310" y1="233" x2="310" y2="253" stroke="#64748b" stroke-width="1.5"/> <polygon points="305,250 310,260 315,250" fill="#64748b"/> <text x="370" y="247" fill="#4ade80" font-size="10">verify signature</text> <!-- Level 3: OS kernel --> <rect x="185" y="260" width="250" height="48" rx="6" fill="#172032" stroke="#60a5fa" stroke-width="1.5"/> <text x="310" y="281" text-anchor="middle" fill="#60a5fa" font-size="12">OS Kernel / Hypervisor</text> <text x="310" y="298" text-anchor="middle" fill="#93c5fd" font-size="10">Verified kernel image · Signed modules</text> <!-- Left bracket indicating trust derivation --> <line x1="175" y1="35" x2="175" y2="308" stroke="#334155" stroke-width="1.5"/> <line x1="175" y1="35" x2="185" y2="35" stroke="#334155" stroke-width="1.5"/> <line x1="175" y1="308" x2="185" y2="308" stroke="#334155" stroke-width="1.5"/> <text x="20" y="175" fill="#475569" font-size="10" transform="rotate(-90,20,175)">trust derived upward</text> </svg>

The chain has a critical property: **trust does not transfer without verification**. Each stage must cryptographically verify the next before executing it. A break anywhere in the chain — a stage that executes without verifying its successor — severs the chain. The HRoT is the only stage that is trusted unconditionally; every other stage earns its trust by being verified.

---

### What Makes a Root of Trust "Hardware"

Software can be replaced, patched, or subverted. A hardware root of trust derives its trustworthiness from physical properties that resist modification:

- **Immutable code storage** — the initial code executing at reset is stored in mask ROM or one-time-programmable (OTP) memory that cannot be written after fabrication or provisioning. An attacker cannot alter what executes first.
- **Hardware-enforced isolation** — the RoT has access to secrets and capabilities that no software, regardless of privilege level, can directly read or modify.
- **Physical tamper resistance** — the substrate, packaging, and metal layers resist physical probing, decapping, and side-channel observation.
- **Non-software-visible keys** — cryptographic keys are generated or stored in hardware registers that software cannot read directly; they are only usable by hardware cryptographic engines that accept commands but never expose key material.

---

### Core Hardware Components

#### Secure Boot ROM

The first code to execute after reset is fetched from a **mask ROM** — read-only memory whose contents are defined at chip fabrication and are physically unalterable thereafter. This code:

- Initializes the minimum hardware necessary to verify the next stage.
- Loads the next stage from flash or persistent storage.
- Verifies its cryptographic signature against a public key whose hash is stored in fuses.
- Transfers control only if verification succeeds; halts or enters a recovery mode if it fails.

The BootROM is the innermost link of the chain. Its correctness is the foundational assumption — bugs in the BootROM are unfixable without hardware replacement.

#### One-Time Programmable (OTP) Fuses

**eFuses** (electrical fuses) or **antifuses** are non-volatile bits that can be programmed once — irreversibly — during manufacturing or initial provisioning. They store:

- The hash of the public key used to verify the first-stage bootloader.
- Device identity and serial number.
- Security configuration bits (debug disable, secure boot enable, production vs. development mode).
- Manufacturing test results.

Fuse state is readable by the BootROM at startup to configure the verification process. Critically, **debug interfaces are typically disabled by fuse** in production devices — a fuse that locks JTAG cannot be unset by software.

#### Hardware Cryptographic Engine

Signature verification during secure boot requires asymmetric cryptography (typically RSA-2048/4096 or ECDSA P-256/P-384). Performing this in software on the main CPU is possible but:

- Exposes key operations to software inspection.
- Is slow without hardware acceleration.
- Requires the CPU to be initialized first, expanding the attack surface.

A dedicated hardware crypto engine performs the verification with the key material held in hardware registers inaccessible to software. The engine accepts a command ("verify this signature with this key") and returns a pass/fail result without ever exposing the key.

#### True Random Number Generator (TRNG)

Cryptographic operations require unpredictable randomness. A **TRNG** harvests entropy from physical phenomena — thermal noise in resistors, metastability in latches, jitter in ring oscillators — that are fundamentally non-deterministic. Software pseudo-random number generators seeded from a TRNG cannot be predicted by an attacker who does not have access to the physical device.

#### Secure Key Storage

Long-lived cryptographic keys (device identity keys, attestation keys) must survive power cycles. Options in increasing security:

- **Battery-backed SRAM** — keys held in SRAM powered by a small battery. Physical removal of the battery destroys the keys (used in HSMs and payment terminals with active tamper response).
- **eFuse storage** — keys burned into fuses. Readable by hardware only; [Inference] fuse bits may be partially recoverable by physical attacks at sufficient cost, though this is not confirmed for specific products.
- **Physically Unclonable Functions (PUFs)** — described below.

#### Physically Unclonable Function (PUF)

A PUF exploits uncontrollable manufacturing variation to generate a key that is unique to each die and reproducible without storage. Identical circuits on different dies respond differently to the same challenge due to random transistor threshold variation, wire resistance variation, and interconnect capacitance differences.

A **ring oscillator PUF** compares the frequencies of two identically-designed oscillator chains; the faster one encodes a bit. The comparison is reproducible on the same die but differs between dice.

**Key Points:**

- The key is never stored — it is regenerated from physics each time it is needed.
- An attacker who obtains the chip cannot extract the key by reading memory; they would need to reproduce the physical die.
- PUFs require **error correction** (fuzzy extractors) because the raw response has small random variations due to temperature and voltage; the error corrector reproduces the exact key from a noisy measurement.
- [Inference] Physical attacks that precisely measure transistor characteristics might recover PUF responses, though the difficulty depends on the specific implementation and attacker capability. This is not confirmed for deployed systems.

<svg viewBox="0 0 560 200" xmlns="http://www.w3.org/2000/svg" font-family="monospace" font-size="11"> <text x="280" y="18" text-anchor="middle" fill="#94a3b8" font-size="12">Ring Oscillator PUF — Key Bit Generation</text> <!-- Die outline --> <rect x="10" y="28" width="540" height="160" rx="6" fill="#0f172a" stroke="#334155" stroke-width="1.5"/> <!-- Oscillator pair A -->

<text x="100" y="52" text-anchor="middle" fill="#94a3b8">Oscillator Pair</text>

<rect x="30" y="60" width="140" height="30" rx="4" fill="#1e3a5f" stroke="#60a5fa" stroke-width="1"/> <text x="100" y="79" text-anchor="middle" fill="#93c5fd">Ring Osc A₁ (fast: +δ)</text> <rect x="30" y="100" width="140" height="30" rx="4" fill="#1e3a5f" stroke="#60a5fa" stroke-width="1"/> <text x="100" y="119" text-anchor="middle" fill="#93c5fd">Ring Osc A₂ (slow: −δ)</text> <!-- Comparator --> <polygon points="200,68 240,95 200,122" fill="#172032" stroke="#4ade80" stroke-width="1.5"/> <text x="208" y="99" fill="#4ade80" font-size="10">CMP</text> <line x1="170" y1="75" x2="200" y2="80" stroke="#60a5fa" stroke-width="1.5"/> <line x1="170" y1="115" x2="200" y2="110" stroke="#60a5fa" stroke-width="1.5"/> <!-- Output bit --> <line x1="240" y1="95" x2="280" y2="95" stroke="#4ade80" stroke-width="1.5"/> <rect x="280" y="82" width="30" height="26" rx="3" fill="#14532d" stroke="#4ade80" stroke-width="1"/> <text x="295" y="99" text-anchor="middle" fill="#bbf7d0">1</text> <!-- Arrow to key --> <line x1="310" y1="95" x2="350" y2="95" stroke="#94a3b8" stroke-width="1" stroke-dasharray="3,2"/> <!-- Key accumulator --> <rect x="350" y="65" width="170" height="80" rx="4" fill="#1c1a10" stroke="#fbbf24" stroke-width="1.5"/> <text x="435" y="88" text-anchor="middle" fill="#fbbf24">Raw PUF Response</text> <text x="435" y="108" text-anchor="middle" fill="#fde68a">1 0 1 1 0 0 1 0 …</text> <text x="435" y="128" text-anchor="middle" fill="#78350f" font-size="10">→ fuzzy extractor → stable key</text> <!-- Die variation label -->

<text x="100" y="155" text-anchor="middle" fill="#475569" font-size="10">δ arises from uncontrolled</text> <text x="100" y="168" text-anchor="middle" fill="#475569" font-size="10">manufacturing variation per die</text> </svg>

---

### Trusted Execution Environments (TEE)

A TEE is an isolated execution environment whose integrity is rooted in the HRoT. It runs concurrently with the normal OS but in a separate security domain that the normal OS cannot observe or modify.

#### ARM TrustZone

TrustZone partitions the processor, memory, and peripherals into two worlds at the hardware level:

- **Secure World** — runs the Trusted OS and trusted applications (TAs). Has access to secure memory, secure peripherals, and cryptographic keys.
- **Normal World** — runs the untrusted OS (Linux, Android). Cannot access secure memory or issue operations to secure peripherals.

Separation is enforced by a hardware bit — the **NS (Non-Secure) bit** — propagated on every bus transaction. Memory controllers and peripheral controllers check this bit and deny access from the Normal World to Secure World resources. No software in the Normal World, regardless of privilege level, can override this; the separation is hardware-enforced.

World switching is performed through the **Secure Monitor Call (SMC)** instruction, which enters Secure Monitor Mode — the highest privilege level, executing code loaded and verified during secure boot.

<svg viewBox="0 0 580 240" xmlns="http://www.w3.org/2000/svg" font-family="monospace" font-size="11"> <text x="290" y="18" text-anchor="middle" fill="#94a3b8" font-size="12">ARM TrustZone World Separation</text> <!-- Normal World --> <rect x="20" y="30" width="240" height="185" rx="6" fill="#172032" stroke="#60a5fa" stroke-width="1.5"/> <text x="140" y="52" text-anchor="middle" fill="#60a5fa">Normal World</text> <rect x="35" y="62" width="210" height="28" rx="3" fill="#1e3a5f" stroke="#3b82f6" stroke-width="1"/> <text x="140" y="80" text-anchor="middle" fill="#93c5fd">User Apps</text> <rect x="35" y="98" width="210" height="28" rx="3" fill="#1e3a5f" stroke="#3b82f6" stroke-width="1"/> <text x="140" y="116" text-anchor="middle" fill="#93c5fd">Linux / Android OS</text> <rect x="35" y="134" width="210" height="28" rx="3" fill="#1e3a5f" stroke="#3b82f6" stroke-width="1"/> <text x="140" y="152" text-anchor="middle" fill="#93c5fd">Hypervisor (EL2)</text> <rect x="35" y="170" width="210" height="35" rx="3" fill="#0f2744" stroke="#1d4ed8" stroke-width="1"/> <text x="140" y="190" text-anchor="middle" fill="#7dd3fc">NS-bit = 1 on all</text> <text x="140" y="204" text-anchor="middle" fill="#7dd3fc">bus transactions</text> <!-- Secure World --> <rect x="320" y="30" width="240" height="185" rx="6" fill="#2d1a1a" stroke="#f87171" stroke-width="1.5"/> <text x="440" y="52" text-anchor="middle" fill="#f87171">Secure World</text> <rect x="335" y="62" width="210" height="28" rx="3" fill="#450a0a" stroke="#dc2626" stroke-width="1"/> <text x="440" y="80" text-anchor="middle" fill="#fca5a5">Trusted Applications</text> <rect x="335" y="98" width="210" height="28" rx="3" fill="#450a0a" stroke="#dc2626" stroke-width="1"/> <text x="440" y="116" text-anchor="middle" fill="#fca5a5">Trusted OS (e.g. OP-TEE)</text> <rect x="335" y="134" width="210" height="28" rx="3" fill="#450a0a" stroke="#dc2626" stroke-width="1"/> <text x="440" y="152" text-anchor="middle" fill="#fca5a5">Secure Monitor (EL3)</text> <rect x="335" y="170" width="210" height="35" rx="3" fill="#3b0000" stroke="#7f1d1d" stroke-width="1"/> <text x="440" y="190" text-anchor="middle" fill="#fda4af">NS-bit = 0 · HW keys</text> <text x="440" y="204" text-anchor="middle" fill="#fda4af">secure peripherals</text> <!-- SMC barrier --> <rect x="263" y="30" width="54" height="185" rx="0" fill="#1a1a1a" stroke="#475569" stroke-width="1"/> <text x="290" y="90" text-anchor="middle" fill="#64748b" font-size="10" transform="rotate(-90,290,90)">SMC</text> <text x="290" y="155" text-anchor="middle" fill="#64748b" font-size="10" transform="rotate(-90,290,155)">boundary</text> <!-- Arrow --> <line x1="263" y1="122" x2="253" y2="122" stroke="#fbbf24" stroke-width="1.5" stroke-dasharray="3,2"/> <line x1="317" y1="122" x2="327" y2="122" stroke="#fbbf24" stroke-width="1.5" stroke-dasharray="3,2"/> <text x="290" y="118" text-anchor="middle" fill="#fbbf24" font-size="9">SMC</text> </svg>

---

### Remote Attestation

Remote attestation allows a device to prove to an external party that it is running the expected, unmodified software stack. This is only meaningful if the attestation report is rooted in hardware.

**Operation:**

1. During manufacturing, a unique **Device Identity Key** (often an asymmetric key pair) is provisioned into the HRoT. The private key never leaves the device.
2. The HRoT measures each boot stage — computes a cryptographic hash of its code — and records these measurements in **Platform Configuration Registers (PCRs)** inside the TPM or secure enclave.
3. When an external verifier requests attestation, the HRoT signs the PCR values with the device identity key.
4. The verifier checks the signature (proving it came from a genuine device) and checks the PCR values against known-good reference values (proving the software is unmodified).

If any boot stage was tampered with, its hash differs from the expected value. The attestation report will reflect this, and the verifier can deny access or trust.

---

### Trusted Platform Module (TPM)

The TPM is a standardized (ISO/IEC 11889) discrete or integrated security chip that provides a defined set of HRoT services:

|Function|Description|
|---|---|
|**PCR banks**|24 registers holding cumulative hash measurements of boot stages|
|**Key generation**|Hardware key generation with keys sealed to PCR state|
|**Key sealing**|A key can only be unsealed if PCRs match the state at sealing time|
|**Attestation**|Sign PCR contents with the device's endorsement key|
|**NVRAM**|Small non-volatile storage for secrets and policy|
|**TRNG**|Hardware random number generation|

**PCR extension** is one-way: `PCR[n] = Hash(PCR[n] || new_measurement)`. This means the final PCR value reflects the entire sequence of measurements in order. An attacker cannot reorder or substitute measurements without producing a different final value.

**Key sealing** is the most powerful TPM feature: a key is encrypted to a specific PCR state. If the system boots into an unexpected state (modified bootloader, different OS), the PCR values will not match, and the sealed key cannot be recovered. This is the mechanism behind BitLocker full-disk encryption on Windows — the volume key is sealed to the expected boot state.

---

### Secure Enclaves

A **secure enclave** provides a hardware-isolated execution environment for user-level code, without requiring a separate OS or privilege level. The CPU hardware itself enforces isolation.

#### Intel SGX (Software Guard Extensions)

SGX allows user-space applications to create **enclaves** — memory regions encrypted and integrity-protected by the CPU. The CPU holds the encryption keys in hardware; even the OS, hypervisor, and SMM code cannot read enclave memory.

- **EPID (Enhanced Privacy ID)** and **DCAP (Data Center Attestation Primitives)** provide attestation: the CPU can prove to a remote party that a specific enclave binary is running on genuine Intel hardware.
- The enclave memory is backed by **Enclave Page Cache (EPC)** — a reserved physical memory region that the CPU encrypts using a key generated at boot and never exposed.
- [Inference] SGX's threat model assumes the CPU package boundary as the trust boundary; attacks exploiting speculative execution (Spectre-class) have demonstrated that this boundary is harder to maintain than the architecture originally implied, though the specific security properties of current SGX implementations are subject to ongoing research.

#### Apple Secure Enclave Processor (SEP)

Apple's SEP is a dedicated processor core on Apple SoCs (A-series, M-series) with its own OS, memory, and storage, isolated from the Application Processor by hardware. It manages:

- Biometric data (Touch ID, Face ID templates) — the AP never receives raw biometric data.
- The UID key — a device-unique AES key fused into the SEP at manufacturing that never leaves the SEP; all file system encryption is ultimately rooted in this key.
- Secure storage for cryptographic keys used by the Keychain.

The SEP boots from its own verified ROM and maintains its own chain of trust independent of the Application Processor's chain.

---

### Measured Boot vs. Verified Boot

These are related but distinct concepts that are frequently conflated:

|Property|Measured Boot|Verified Boot|
|---|---|---|
|**Action on tampered image**|Records the measurement; proceeds|Halts or enters recovery|
|**Trust enforcement**|Deferred to remote verifier|Enforced locally at boot time|
|**Mechanism**|TPM PCR extension|Signature verification before execution|
|**Flexibility**|Allows any software; audit trail preserved|Only signed software executes|
|**Use case**|Enterprise attestation, cloud VMs|Consumer devices, secure enclaves|

Android Verified Boot (AVB) and UEFI Secure Boot implement verified boot. TPM-based attestation in servers implements measured boot. Many production systems implement both.

---

### Cryptographic Agility and Key Hierarchy

A production HRoT manages not a single key but a **key hierarchy**:

```
Device Root Key (HW, never leaves chip)
    └── Device Identity Key  (attestation, certified by manufacturer CA)
    └── Storage Root Key     (seals/unseals storage encryption keys)
            └── Volume Encryption Key  (sealed to PCR state)
            └── Application Keys       (sealed to PCR state + app identity)
```

**Key Points:**

- The Device Root Key is the anchor. All other keys derive their trustworthiness from it.
- Derived keys are scoped — a key sealed for one application cannot be used by another.
- Key derivation is performed in hardware; derived keys may be exposed to software, but the root is not.
- **Cryptographic agility** — the ability to replace algorithms — is a design concern: if SHA-1 PCR banks are deprecated, the system needs SHA-256 banks in parallel. TPM 2.0 addressed this by supporting multiple algorithm banks simultaneously.

---

### Physical Attack Resistance

The HRoT must resist not only software attacks but physical ones. The threat model determines the required level of physical security:

|Attack Class|Example|Defense|
|---|---|---|
|**Non-invasive**|Power analysis, EM side-channel|Constant-time crypto, power supply filtering, EM shielding|
|**Semi-invasive**|Fault injection (voltage glitch, laser)|Redundant computation, voltage/frequency monitors, sensors|
|**Invasive**|Decapping, microprobing|Metal mesh shield layers, active tamper detection, key zeroization|
|**Cold boot**|RAM imaging after power removal|Key storage in registers only; zeroize on tamper detect|

Dedicated security chips (TPMs, smartcard ICs, Hardware Security Modules) are evaluated against attack resistance standards: **Common Criteria** (up to EAL 6+) and **FIPS 140-3** (Levels 1–4). Level 4 requires active tamper response — physical intrusion triggers immediate key destruction.

---

### Hardware Security Modules (HSMs)

An HSM is a dedicated, certified physical device providing cryptographic services and secure key storage to servers and infrastructure. It extends the HRoT concept to the data center:

- Keys are generated inside the HSM and [Inference] are designed to be non-exportable in plaintext, though the specific assurances depend on the implementation and certification level.
- Cryptographic operations are performed inside the HSM; the host system sends data in and receives results out without receiving key material.
- Physical tamper response (zeroization) is required at FIPS 140-3 Level 3 and above.
- PKI certificate authorities, payment networks (HSMs in ATMs and POS terminals), and cloud key management services (AWS CloudHSM, Azure Dedicated HSM) rely on HSMs as their trust anchors.

---

### Limitations and Trust Assumptions

**Key Points:**

- The HRoT is trusted by assumption, not by proof. A bug in the BootROM is a permanent, unfixable vulnerability in all devices using that ROM. [Unverified: specific BootROM vulnerability disclosures exist in the public record, but their details and scope vary by vendor and are not confirmed here.]
- The chain of trust verifies **integrity** (the code has not been modified) but not **correctness** (the code does what it claims). A signed malicious image passes verification.
- Hardware isolation boundaries have been challenged by microarchitectural side-channel attacks (Spectre, Meltdown, Foreshadow targeting SGX). The HRoT provides a defined trust boundary; whether that boundary holds against a specific attack depends on the microarchitectural implementation and the attack's applicability.
- Supply chain attacks — introducing malicious modifications during chip manufacturing or provisioning — operate below the HRoT's threat model. The HRoT assumes a trusted manufacturing process.

---

**Conclusion**

The hardware root of trust is the point at which security becomes physical rather than logical — it is trusted because it cannot be altered, not because it has been verified. Every security property a system claims above the firmware level — verified boot, attestation, sealed storage, trusted execution — derives its validity from the integrity of this hardware foundation. The design of an HRoT is therefore an exercise in threat modeling: identifying precisely what attacks must be resisted, at what cost, and accepting that the root itself will always rest on a set of physical and manufacturing assumptions that cannot be eliminated, only carefully managed.

**Next Steps**

- Study **side-channel attacks and Spectre/Meltdown** as the class of attacks that challenge hardware isolation boundaries (Module 15)
- Examine **Trusted Execution Environments** in depth, particularly the SGX and TrustZone programming models
- Connect to **SoC design** to understand how security subsystems are integrated with the power domain and boot architecture (Module 13)
- Review **fault tolerance and redundancy** for the hardware mechanisms that defend against fault injection attacks (Module 15)

---

