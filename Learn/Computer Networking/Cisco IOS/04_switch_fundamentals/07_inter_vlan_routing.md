## Inter-VLAN Routing


VLANs create isolated broadcast domains that cannot communicate without Layer 3 routing. Inter-VLAN routing enables traffic to flow between different VLANs through a router or Layer 3 switch.

**Router-on-a-Stick (Legacy Method):** A single router interface connects to a switch trunk, with subinterfaces configured for each VLAN. Each subinterface has an IP address serving as the default gateway for its respective VLAN.

```
! Router configuration
Router(config)# interface gigabitethernet 0/0
Router(config-if)# no shutdown
Router(config-if)# exit

Router(config)# interface gigabitethernet 0/0.10
Router(config-subif)# encapsulation dot1q 10
Router(config-subif)# ip address 192.168.10.1 255.255.255.0
Router(config-subif)# exit

Router(config)# interface gigabitethernet 0/0.20
Router(config-subif)# encapsulation dot1q 20
Router(config-subif)# ip address 192.168.20.1 255.255.255.0
Router(config-subif)# exit

! Switch trunk configuration
Switch(config)# interface gigabitethernet 0/1
Switch(config-if)# switchport mode trunk
Switch(config-if)# switchport trunk allowed vlan 10,20
```

Each subinterface uses 802.1Q encapsulation to tag frames with the appropriate VLAN ID. Traffic from VLAN 10 arrives at subinterface 0/0.10, gets routed by the router, and returns through the appropriate subinterface.

**Layer 3 Switch (Modern Method):** Multilayer switches perform routing directly in hardware using ASICs (Application-Specific Integrated Circuits), providing wire-speed inter-VLAN routing without the bottleneck of an external router.

```
! Enable IP routing
Switch(config)# ip routing

! Configure SVIs for each VLAN
Switch(config)# interface vlan 10
Switch(config-if)# ip address 192.168.10.1 255.255.255.0
Switch(config-if)# no shutdown
Switch(config-if)# exit

Switch(config)# interface vlan 20
Switch(config-if)# ip address 192.168.20.1 255.255.255.0
Switch(config-if)# no shutdown
Switch(config-if)# exit

! Configure access ports
Switch(config)# interface range gigabitethernet 0/1-10
Switch(config-if-range)# switchport mode access
Switch(config-if-range)# switchport access vlan 10

Switch(config)# interface range gigabitethernet 0/11-20
Switch(config-if-range)# switchport mode access
Switch(config-if-range)# switchport access vlan 20
```

**Routed Ports on Layer 3 Switches:** Physical switch ports can be configured as routed interfaces (no switching), functioning like router interfaces:

```
Switch(config)# interface gigabitethernet 0/1
Switch(config-if)# no switchport
Switch(config-if)# ip address 10.1.1.1 255.255.255.0
Switch(config-if)# no shutdown
```

**Routing Protocol Configuration:** Layer 3 switches can run routing protocols to exchange routes with other Layer 3 devices:

```
Switch(config)# router ospf 1
Switch(config-router)# network 192.168.10.0 0.0.0.255 area 0
Switch(config-router)# network 192.168.20.0 0.0.0.255 area 0
```

**Verification Commands:**

```
Switch# show ip interface brief
Switch# show ip route
Switch# show interfaces trunk
Switch# show vlan brief
Router# show ip interface brief
Router# show ip route
```

