## Traffic Classification and Marking


Traffic classification forms the foundation of QoS implementation by identifying different types of network traffic and their requirements.

**Classification Methods**

_Layer 2 Classification_ utilizes IEEE 802.1p Class of Service (CoS) bits within Ethernet frames. The 802.1Q VLAN tag contains a 3-bit Priority Code Point (PCP) field, allowing for 8 different priority levels (0-7).

_Layer 3 Classification_ employs the IP header's Type of Service (ToS) byte, which includes the 6-bit Differentiated Services Code Point (DSCP) and 2-bit Explicit Congestion Notification (ECN) field.

_Layer 4 Classification_ examines TCP/UDP port numbers to identify specific applications or services.

_Deep Packet Inspection (DPI)_ analyzes packet contents beyond standard headers to identify applications that use dynamic ports or encryption.

**Marking Strategies**

Trust boundaries define where traffic markings are accepted or overridden. Typically, markings from end-user devices are not trusted, while markings from IP phones or servers may be trusted.

DSCP markings provide 64 possible values (0-63), with standard markings including:

- Best Effort (BE): DSCP 0
- Assured Forwarding (AF): Classes AF11-AF43
- Expedited Forwarding (EF): DSCP 46
- Class Selector (CS): CS1-CS7

