## Configuration File Structure


**Startup-Config**

The startup-config resides in NVRAM (Non-Volatile RAM), persisting through power cycles and reboots. This file contains the configuration loaded during boot. To view: `show startup-config` from privileged EXEC mode. The startup-config only updates when explicitly saved using `copy running-config startup-config` or `write memory` (or abbreviated `wr`). If not saved, configuration changes are lost on reload.

**Running-Config**

The running-config exists in RAM and represents the currently active configuration. All changes made through the CLI immediately affect the running-config and take effect instantly [Inference: though some features may require additional actions]. View with `show running-config` from privileged EXEC mode. This file is volatile—it disappears on power loss or reload unless saved to startup-config.

**Configuration File Contents**

Configuration files are structured text with hierarchical indentation:

```
version 15.7
service timestamps debug datetime msec
service timestamps log datetime msec
no service password-encryption
!
hostname Router1
!
enable secret 5 $1$mERr$hx5rVt7rPNoS4wqbXKX7m0
!
interface GigabitEthernet0/0
 ip address 192.168.1.1 255.255.255.0
 duplex auto
 speed auto
!
ip route 0.0.0.0 0.0.0.0 192.168.1.254
!
line con 0
 logging synchronous
line vty 0 4
 login
 transport input ssh
!
end
```

Exclamation marks (!) serve as section delimiters and comments. Indentation indicates configuration hierarchy—interface commands are indented under the interface declaration.

**Configuration Management Commands**

- `copy running-config startup-config`: Saves current config to NVRAM (also `write` or `wr`)
- `copy startup-config running-config`: Merges startup-config into running-config (additive operation)
- `write erase` or `erase startup-config`: Deletes startup-config from NVRAM
- `reload`: Reboots device (prompts to save if running-config differs from startup-config)
- `show archive`: Displays configuration archive settings
- `copy running-config tftp:`: Backs up configuration to TFTP server
- `copy tftp: running-config`: Restores configuration from TFTP

**Configuration Register**

The configuration register (16-bit value) controls boot behavior. View with `show version` (last line shows register). Common values:

- `0x2102`: Default—boot normally, load startup-config
- `0x2142`: Bypass startup-config (used in password recovery)
- `0x2101`: Boot to ROMMON

Modify with `config-register 0x2102` in global configuration mode (takes effect after reload).

