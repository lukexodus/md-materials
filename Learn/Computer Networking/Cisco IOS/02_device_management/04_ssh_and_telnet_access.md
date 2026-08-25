## SSH and Telnet Access


### Telnet Configuration

Telnet provides unencrypted remote access (not recommended for production):

```
R1(config)# hostname R1
R1(config)# interface gigabitEthernet 0/0
R1(config-if)# ip address 192.168.1.1 255.255.255.0
R1(config-if)# no shutdown
R1(config-if)# exit
R1(config)#
R1(config)# line vty 0 4
R1(config-line)# password Telnet@123
R1(config-line)# login
R1(config-line)# transport input telnet
```

**Testing Telnet:**

```
PC> telnet 192.168.1.1
Trying 192.168.1.1 ... Open

User Access Verification

Password: 
R1>
```

**Key points:**

- Transmits credentials in plaintext
- Should only be used in isolated lab environments
- Blocked by many security policies
- No encryption of session data
- Use SSH instead for production networks

### SSH Configuration

SSH provides encrypted remote access and authentication.

**Prerequisites:**

- Hostname configured
- Domain name configured
- RSA key pair generated
- Local user accounts or AAA configured
- IOS image with cryptographic features (k9)

**SSH Version 2 Configuration:**

```
R1(config)# hostname R1
R1(config)# ip domain-name example.com
R1(config)# crypto key generate rsa modulus 2048
The name for the keys will be: R1.example.com
% The key modulus size is 2048 bits
% Generating 2048 bit RSA keys, keys will be non-exportable...
[OK] (elapsed time was 1 seconds)

R1(config)# ip ssh version 2
R1(config)# ip ssh time-out 60
R1(config)# ip ssh authentication-retries 3
R1(config)# 
R1(config)# username admin privilege 15 secret Admin@SSH123
R1(config)# 
R1(config)# line vty 0 4
R1(config-line)# login local
R1(config-line)# transport input ssh
R1(config-line)# exit
```

**Verification:**

```
R1# show ip ssh
SSH Enabled - version 2.0
Authentication timeout: 60 secs; Authentication retries: 3
Minimum expected Diffie Hellman key size : 1024 bits
IOS Keys in SECSH format(ssh-rsa, base64 encoded):
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAAAgQC8...

R1# show ssh
Connection Version Mode Encryption  Hmac         State           Username
0          2.0     IN   aes128-cbc  hmac-sha1    Session started admin
0          2.0     OUT  aes128-cbc  hmac-sha1    Session started admin

R1# show crypto key mypubkey rsa
% Key pair was generated at: 10:25:30 UTC Jan 15 2025
Key name: R1.example.com
 Storage Device: not specified
 Usage: General Purpose Key
 Key is not exportable.
 Key Data:
  30819F30 0D06092A 864886F7 0D010101 05000381 8D003081 89028181 00BC...
% Key pair was generated at: 10:25:30 UTC Jan 15 2025
Key name: R1.example.com.server
 Temporary key
 Usage: Encryption Key
 Key is not exportable.
 Key Data:
  307C300D 06092A86 4886F70D 01010105 00036B00 30680261 00D4E8F3 C2B9...
```

**Configuring SSH with Stronger Parameters:**

```
R1(config)# ip ssh version 2
R1(config)# ip ssh dh min size 2048
R1(config)# ip ssh server algorithm encryption aes256-ctr aes192-ctr aes128-ctr
R1(config)# ip ssh server algorithm mac hmac-sha2-256 hmac-sha2-512
R1(config)# ip ssh server algorithm kex diffie-hellman-group14-sha1
```

**SSH Client Usage:**

```
R2# ssh -l admin 192.168.1.1
Password: 

R1>
```

**Alternative SSH Client Syntax:**

```
R2# ssh -v 2 -c aes256-ctr admin@192.168.1.1
```

**Key points:**

- RSA key modulus minimum: 1024 bits (2048+ recommended)
- SSH version 2 is more secure than version 1
- Domain name required for RSA key generation
- Keys named: `hostname.domain-name`
- `transport input ssh` disables Telnet
- Delete keys: `crypto key zeroize rsa`
- Regenerate keys after hostname or domain change
- IOS image must support cryptography (k9 designation)

### SSH Public Key Authentication

**Generating User Keys (on client):**

```
client$ ssh-keygen -t rsa -b 2048
Generating public/private rsa key pair.
Enter file in which to save the key (/home/user/.ssh/id_rsa): 
Enter passphrase (empty for no passphrase): 
Your identification has been saved in /home/user/.ssh/id_rsa.
Your public key has been saved in /home/user/.ssh/id_rsa.pub.
```

**Configuring Router for Public Key Authentication:**

```
R1(config)# ip ssh pubkey-chain
R1(conf-ssh-pubkey)# username admin
R1(conf-ssh-pubkey-user)# key-string
R1(conf-ssh-pubkey-data)# AAAAB3NzaC1yc2EAAAADAQABAAABAQC8...
R1(conf-ssh-pubkey-data)# exit
R1(conf-ssh-pubkey-user)# exit
R1(conf-ssh-pubkey)# exit
```

**Key points:**

- Public key authentication more secure than passwords
- User still needs entry in local database
- Can combine with password authentication
- Supports RSA and DSA key types

