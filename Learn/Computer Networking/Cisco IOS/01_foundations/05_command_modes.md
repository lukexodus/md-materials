## Command Modes


**User EXEC Mode**

Indicated by the `>` prompt (e.g., `Router>`). This is the initial mode upon login, providing limited monitoring commands with no configuration capability. Available commands include ping, traceroute, show commands (limited set), telnet/ssh to other devices, and enable (to enter privileged EXEC). This mode prevents accidental configuration changes and restricts access to sensitive information.

**Privileged EXEC Mode**

Indicated by the `#` prompt (e.g., `Router#`). Accessed from user EXEC mode by typing `enable` and providing the enable password/secret if configured. This mode grants full access to all show commands, configuration modes, debugging commands, file system operations, and device reload/restart commands. Exit to user EXEC mode with `disable` or `exit`.

**Global Configuration Mode**

Indicated by `(config)#` prompt (e.g., `Router(config)#`). Entered from privileged EXEC with `configure terminal` (or `conf t`). This mode allows device-wide configuration settings including hostname, passwords, user accounts, DNS settings, system time, global routing parameters, and access to specific configuration modes. Exit with `exit` (returns to privileged EXEC) or `Ctrl+Z` or `end` (saves and returns to privileged EXEC).

**Specific Configuration Modes**

From global configuration mode, you enter specific configuration contexts:

- **Interface Configuration**: `interface gigabitethernet0/0` produces `(config-if)#` prompt for configuring specific interfaces
- **Line Configuration**: `line console 0` or `line vty 0 4` produces `(config-line)#` for configuring console or virtual terminal lines
- **Router Configuration**: `router ospf 1` produces `(config-router)#` for routing protocol configuration
- **Subinterface Configuration**: `interface gi0/0.10` produces `(config-subif)#` for 802.1Q subinterfaces
- **VLAN Configuration**: `vlan 10` produces `(config-vlan)#` on switches
- **Access List Configuration**: `ip access-list extended ACL_NAME` produces `(config-ext-nacl)#`

Navigation between modes uses `exit` to move up one level, `end` or `Ctrl+Z` to return directly to privileged EXEC, and typing the desired command to move laterally (automatically exits current mode and enters new one).

**ROMMON Mode**

Indicated by `rommon 1 >` prompt. This is a minimal recovery environment accessed during boot interruption (Ctrl+Break during bootup) or when no valid IOS image loads. ROMMON allows manual boot commands, TFTP recovery (tftpdnld on some platforms), password recovery procedures, and basic hardware diagnostics. This mode is critical for disaster recovery scenarios.

