## Interface Descriptions


Interface descriptions provide documentation and identification for network interfaces.

**Configuration:**

```
Router(config-if)# description Link to Core Switch - Vlan 100
Router(config-if)# description WAN Connection to ISP - Circuit ID: 12345
Router(config-if)# description Management Interface - VLAN 999
```

**Best Practices:**

- Include connected device information
- Reference circuit IDs for WAN links
- Specify VLAN information
- Include contact information for third-party circuits
- Use consistent naming conventions across the organization

**Character Limitations:** Descriptions support up to 240 characters on most platforms. Special characters and spaces are supported.

**Verification:**

```
Router# show interfaces description
Router# show ip interface brief
```

