## Password Encryption and Privilege Levels


### Password Types

**Console Password:**

```
R1(config)# line console 0
R1(config-line)# password cisco123
R1(config-line)# login
```

**Enable Password (Legacy):**

```
R1(config)# enable password cisco123
```

**Enable Secret (Recommended):**

```
R1(config)# enable secret Str0ngP@ss
```

**Key points:**

- Enable secret uses MD5 hashing (Type 5)
- Enable secret takes precedence over enable password
- Enable password stores in plaintext by default
- Never use both enable password and enable secret with the same value

### Password Encryption

**Service Password-Encryption:**

```
R1(config)# service password-encryption
```

This applies Type 7 (Vigenère cipher) encryption to plaintext passwords:

```
R1(config)# do show running-config | include password
enable password 7 0822455D0A16
```

**Key points:**

- Type 7 encryption is weak and easily reversible
- Only encrypts plaintext passwords (Type 0)
- Does not re-encrypt already encrypted passwords
- Does not affect enable secret (Type 5) or Type 8/9 passwords
- Applied to: console, VTY, AUX passwords, and enable password

**Type 8 and Type 9 Encryption:**

```
R1(config)# enable algorithm-type scrypt secret Str0ngP@ss
```

**Output:**

```
R1# show running-config | include enable
enable secret 9 $9$XnKE8vGnEH2KvE$7qKJHKLmnP4RSXvH9KvLnP2QsE
```

**Key points:**

- Type 8 uses PBKDF2-HMAC-SHA256
- Type 9 uses scrypt (strongest, recommended for new configurations)
- Requires IOS 15.3(3)M or later
- Cannot be decrypted (one-way hash)

### Privilege Levels

Cisco IOS supports 16 privilege levels (0-15):

**Default Levels:**

- Level 0: Predefined for minimal access (disable, enable, exit, help, logout)
- Level 1: User EXEC mode (default unprivileged level)
- Level 15: Privileged EXEC mode (enable mode)
- Levels 2-14: Custom privilege levels

**Creating Custom Privilege Levels:**

```
R1(config)# privilege exec level 5 show running-config
R1(config)# privilege exec level 5 configure terminal
R1(config)# privilege configure level 5 interface
R1(config)# privilege interface level 5 ip address
R1(config)# privilege interface level 5 shutdown
R1(config)# privilege interface level 5 no shutdown
```

**Configuring User with Privilege Level:**

```
R1(config)# username admin privilege 15 secret Admin@123
R1(config)# username operator privilege 5 secret Oper@123
R1(config)# username monitor privilege 1 secret Mon@123
```

**Enabling Specific Privilege Level:**

```
R1> enable 5
Password: 
R1#
```

**Setting Enable Password per Level:**

```
R1(config)# enable secret level 5 Level5P@ss
R1(config)# enable secret level 10 Level10P@ss
```

**Verification:**

```
R1# show privilege
Current privilege level is 15

R1# show running-config | section username
username monitor privilege 1 secret 9 $9$1L6E2vGmEH3KuE$7qK...
username operator privilege 5 secret 9 $9$2M7F3wHnFI4LvF$8rL...
username admin privilege 15 secret 9 $9$3N8G4xIoGJ5MwG$9sM...
```

**Key points:**

- Commands assigned to lower privilege levels automatically available to higher levels
- Privilege level 0 cannot be customized
- Must configure commands at multiple configuration levels for full functionality
- Use `show privilege` to verify current level
- Custom levels provide granular access control without AAA

