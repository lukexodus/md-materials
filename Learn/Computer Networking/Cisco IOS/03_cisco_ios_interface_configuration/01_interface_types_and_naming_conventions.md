## Interface Types and Naming Conventions


Cisco devices use standardized naming conventions that identify the interface type, module location, and port number. The format typically follows: **InterfaceType[slot/subslot/]port**.

**Physical Interface Types:**

- **Ethernet**: Et0/0, Et0/1 (older platforms)
- **Fast Ethernet**: Fa0/1, Fa0/2 (100 Mbps)
- **Gigabit Ethernet**: Gi0/0/1, Gi1/0/1 (1 Gbps)
- **Ten Gigabit Ethernet**: Te0/1/0, Te1/1/0 (10 Gbps)
- **Twenty-Five Gigabit Ethernet**: TwentyFiveGigE0/0/1 (25 Gbps)
- **Forty Gigabit Ethernet**: Fo0/1/0 (40 Gbps)
- **Hundred Gigabit Ethernet**: Hu0/1/0 (100 Gbps)
- **Serial**: S0/0/0, S0/1/0 (WAN connections)

**Logical Interface Types:**

- **Loopback**: Lo0, Lo1, Lo100
- **Tunnel**: Tu0, Tu1
- **VLAN**: Vlan1, Vlan10, Vlan100
- **Port-channel**: Po1, Po2 (EtherChannel)
- **Bridge Virtual Interface**: BVI1

**Naming Components:**

- **Slot**: Physical slot in chassis where line card is installed
- **Subslot**: Secondary slot position (modular cards)
- **Port**: Individual port number on the interface card

**Platform Variations:** Different Cisco platforms may use slightly different conventions. ISR routers typically use format Gi0/0/0, while switches might use Gi1/0/1. Catalyst switches often number interfaces starting from 1, while routers commonly start from 0.

