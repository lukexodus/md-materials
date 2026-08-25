## Interface Configuration Modes


Cisco IOS uses hierarchical configuration modes to manage interface settings.

**Global Configuration Mode:**

```
Router> enable
Router# configure terminal
Router(config)#
```

**Interface Configuration Mode:**

```
Router(config)# interface gigabitethernet 0/0/1
Router(config-if)#
```

**Multiple Interface Configuration:**

```
Router(config)# interface range gigabitethernet 0/0/1-4
Router(config-if-range)#
```

**Interface Configuration Commands:** All interface-specific commands are entered in interface configuration mode. Changes take effect immediately unless the interface is administratively down.

**Sub-interface Configuration:**

```
Router(config)# interface gigabitethernet 0/0/1.10
Router(config-subif)#
```

Sub-interfaces enable VLAN tagging and multiple logical interfaces on a single physical port.

