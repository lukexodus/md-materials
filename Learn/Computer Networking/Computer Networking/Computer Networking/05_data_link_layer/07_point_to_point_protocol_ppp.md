## Point-to-Point Protocol (PPP)


PPP provides a standard method for transporting multi-protocol datagrams over point-to-point links.

### PPP Architecture

#### Three Components

**High-Level Data Link Control (HDLC):** Frame encapsulation method **Link Control Protocol (LCP):** Establishes, configures, and maintains connections **Network Control Protocols (NCPs):** Configure network layer protocols

### PPP Frame Format

**Flag:** 1 byte frame delimiter (01111110) **Address:** 1 byte (always 11111111 in point-to-point) **Control:** 1 byte (always 00000011 for unnumbered information) **Protocol:** 2 bytes identifying encapsulated protocol **Information:** Variable length data field **Frame Check Sequence:** 2 or 4 bytes for error detection **Flag:** 1 byte frame delimiter

### PPP Connection Phases

#### Link Dead Phase

**State:** Physical layer connection not established **Transition:** Physical layer becomes available

#### Link Establishment Phase

**Process:** LCP negotiation occurs **Options Negotiated:**

- Maximum Receive Unit (MRU)
- Authentication protocol requirements
- Compression protocols
- Link quality monitoring

#### Authentication Phase (Optional)

**Protocols:**

- **Password Authentication Protocol (PAP):** Plain text password transmission
- **Challenge Handshake Authentication Protocol (CHAP):** Encrypted challenge-response **Process:** Peer identity verification before network access

#### Network Layer Protocol Phase

**NCP Negotiation:** Configure network protocols (IP, IPX, etc.) **IP Control Protocol (IPCP):** Negotiates IP addresses, DNS servers, compression options

#### Link Termination Phase

**Triggers:** Administrative command, link quality degradation, authentication failure **Process:** Orderly connection shutdown with notification

### PPP Applications

**Dial-up Internet Access:** Traditional modem connections to ISPs **DSL Connections:** PPP over Ethernet (PPPoE) for broadband authentication **VPN Implementations:** Point-to-Point Tunneling Protocol (PPTP) **Serial Line Connections:** Router-to-router dedicated circuits

