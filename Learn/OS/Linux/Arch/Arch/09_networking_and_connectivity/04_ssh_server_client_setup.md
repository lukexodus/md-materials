## SSH Server/Client Setup


### SSH Overview

**Purpose**: Secure Shell provides encrypted remote access to systems.[1][2]

**Components**:[1]
- SSH server (sshd) - listens for connections[1]
- SSH client - initiates connections[1]
- Keys - authentication credentials[1]

**Security**: Replaces unencrypted telnet with encrypted protocol.[1]

### SSH Server Installation

#### Installation

**Install openssh**: `sudo pacman -S openssh`.[2][1]

**Enable Service**:[2][1]

```bash
sudo systemctl enable --now sshd.service
```

**Verify Running**:[1]

```bash
sudo systemctl status sshd
```

#### Default Configuration

**Config File**: `/etc/ssh/sshd_config`.[2][1]

**Default Settings**:[1]
- Port 22[1]
- Allow password authentication[1]
- Allow root login[1]

### SSH Server Configuration

#### Basic sshd_config

**Common Settings**:[2][1]

```
Port 22
AddressFamily any
ListenAddress 0.0.0.0
ListenAddress ::

# Authentication
PermitRootLogin no
PubkeyAuthentication yes
PasswordAuthentication yes
PermitEmptyPasswords no
```

#### Security Hardening

**Recommended Configuration**:[2][1]

```
# Disable password authentication
PasswordAuthentication no
PubkeyAuthentication yes

# Disable root login
PermitRootLogin no

# Disable empty passwords
PermitEmptyPasswords no

# Limit authentication attempts
MaxAuthTries 3
MaxSessions 5

# Change default port (optional)
Port 2222

# Restrict users
AllowUsers user1 user2

# Disable X11 forwarding if not needed
X11Forwarding no
```

#### Logging

**Increase Verbosity**:[1]

```
SyslogFacility AUTH
LogLevel VERBOSE
```

**Monitor Logs**:[1]

```bash
sudo journalctl -u sshd -f
```

#### Key-Based Authentication

**Enable Public Key**:[1]

```
PubkeyAuthentication yes
AuthorizedKeysFile .ssh/authorized_keys
```

**Location**: User's `~/.ssh/authorized_keys`.[1]

#### Reload Configuration

**Apply Changes**:[2][1]

```bash
sudo systemctl reload sshd
```

**Test Configuration**:[1]

```bash
sudo sshd -t
```

### SSH Client Setup

#### Basic Connection

**Connect to Server**:[2][1]

```bash
ssh username@hostname
ssh username@192.168.1.100
```

**Specify Port**:[1]

```bash
ssh -p 2222 username@hostname
```

#### Client Configuration

**Config File**: `~/.ssh/config`.[2][1]

**Create File**:[1]

```bash
mkdir -p ~/.ssh
chmod 700 ~/.ssh
touch ~/.ssh/config
chmod 600 ~/.ssh/config
```

**Host Alias**:[2][1]

```
Host myserver
    HostName 192.168.1.100
    User username
    Port 22
    IdentityFile ~/.ssh/id_rsa

Host work
    HostName work.example.com
    User workuser
    Port 2222
    IdentityFile ~/.ssh/work_key
```

**Connect Using Alias**:[1]

```bash
ssh myserver
ssh work
```

### SSH Key Generation

#### Generate Key Pair

**Create Keys**:[2][1]

```bash
ssh-keygen -t ed25519 -C "user@hostname"
```

**Parameters**:[2][1]
- `-t ed25519`: Modern key type[1]
- `-C`: Comment for identification[1]

**RSA Alternative**:[1]

```bash
ssh-keygen -t rsa -b 4096 -C "user@hostname"
```

**File Locations**:[1]
- Private key: `~/.ssh/id_ed25519`[1]
- Public key: `~/.ssh/id_ed25519.pub`[1]

**Passphrase**: Prompted during generation.[1]

#### Key File Permissions

**Private Key**:[1]

```bash
chmod 600 ~/.ssh/id_ed25519
```

**Public Key**:[1]

```bash
chmod 644 ~/.ssh/id_ed25519.pub
```

**SSH Directory**:[1]

```bash
chmod 700 ~/.ssh
```

### Public Key Distribution

#### Copy Public Key to Server

**ssh-copy-id Method** (Easiest):[2][1]

```bash
ssh-copy-id -i ~/.ssh/id_ed25519.pub username@hostname
```

**Manual Method**:[1]

```bash
cat ~/.ssh/id_ed25519.pub | ssh username@hostname "cat >> .ssh/authorized_keys"
```

**Direct Copy**:[1]

```bash
scp ~/.ssh/id_ed25519.pub username@hostname:~/.ssh/authorized_keys
```

#### Verify Setup

**Test Connection**:[2][1]

```bash
ssh -i ~/.ssh/id_ed25519 username@hostname
```

**Should Not Prompt for Password**.[1]

### SSH Agent

#### Purpose

**Key Management**: Caches passphrases for convenience.[2][1]

**Security**: Avoids repeatedly entering passphrase.[1]

#### Start SSH Agent

**Automatic in Desktop**: Usually started by display manager.[1]

**Manual Start**:[1]

```bash
eval $(ssh-agent)
```

**Verify Running**:[1]

```bash
echo $SSH_AUTH_SOCK
```

#### Add Keys to Agent

**Add Key**:[2][1]

```bash
ssh-add ~/.ssh/id_ed25519
```

**Prompt for Passphrase**: Required once.[1]

**List Added Keys**:[1]

```bash
ssh-add -l
```

**Remove Key**:[1]

```bash
ssh-add -d ~/.ssh/id_ed25519
```

**Remove All Keys**:[1]

```bash
ssh-add -D
```

### Advanced SSH Features

#### Port Forwarding (Tunneling)

**Local Forward**: Access remote service locally:[1]

```bash
ssh -L 8080:internal-server:80 username@gateway
```

Connect to `localhost:8080` reaches `internal-server:80` through gateway.[1]

**Remote Forward**: Remote access to local service:[1]

```bash
ssh -R 3000:localhost:3000 username@remote-server
```

Allows remote server to access local service.[1]

#### SOCKS Proxy

**Create Proxy**:[1]

```bash
ssh -D 1080 username@gateway
```

**Configure Application**: Point to `localhost:1080` as SOCKS proxy.[1]

#### File Transfer (SCP)

**Copy File to Remote**:[2][1]

```bash
scp file.txt username@hostname:~/
```

**Copy File from Remote**:[1]

```bash
scp username@hostname:~/file.txt .
```

**Recursive Directory**:[1]

```bash
scp -r folder/ username@hostname:~/
```

#### SFTP

**Interactive File Transfer**:[2][1]

```bash
sftp username@hostname
```

**SFTP Commands**:[1]

```
sftp> ls              # List remote files
sftp> cd dir          # Change directory
sftp> get file.txt    # Download
sftp> put file.txt    # Upload
sftp> exit            # Quit
```

### SSH Troubleshooting

#### Connection Refused

**Symptoms**: Cannot connect to SSH server.[1]

**Verify Service Running**:[1]

```bash
sudo systemctl status sshd
sudo ss -tlnp | grep 22
```

**Start Service**:[1]

```bash
sudo systemctl start sshd
```

**Check Firewall**:[1]

```bash
sudo ufw allow 22/tcp
```

#### Permission Denied (Publickey)

**Issue**: Authentication fails with public key.[1]

**Verify Key File**:[1]

```bash
cat ~/.ssh/authorized_keys
```

**Check Permissions**:[1]

```bash
ls -la ~/.ssh/
```

**Must Be**:[1]
- `.ssh`: 700[1]
- `authorized_keys`: 600[1]
- Private key: 600[1]

**Debug Connection**:[1]

```bash
ssh -v username@hostname
```

#### SSH Agent Issues

**Key Not Found**:[1]

```bash
ssh-add -l
ssh-add ~/.ssh/id_rsa
```

**Passphrase Not Cached**:[1]

```bash
eval $(ssh-agent)
ssh-add
```

#### Slow Connection

**Disable DNS Lookup**:[1]

```
UseDNS no
```

in `/etc/ssh/sshd_config`.[1]

**Reload**: `sudo systemctl reload sshd`.[1]

### SSH Security Best Practices

**Use Key-Based Auth**: More secure than passwords.[2][1]

**Disable Root Login**: Set `PermitRootLogin no`.[2][1]

**Disable Password Auth**: Force public key authentication.[1]

**Change Default Port**: Move from standard port 22.[1]

**Limit Login Attempts**: Reduce brute force risk.[1]

**Monitor Logs**: Check `/var/log/auth.log` regularly.[1]

**Keep Systems Updated**: Apply security patches.[1]

**Use Strong Keys**: ed25519 preferred over RSA.[1]

**Protect Private Keys**: Keep passphrases secure.[1]

### SSH Automation

#### Passwordless Sudo for Scripts

**NOPASSWD Entry**: `/etc/sudoers` via `visudo`:[1]

```
username ALL=(ALL) NOPASSWD: /usr/bin/systemctl
```

**Caution**: Security risk, use sparingly.[1]

#### SSH Key for Automation

**Dedicated Key**: Create separate key for scripts:[1]

```bash
ssh-keygen -t ed25519 -f ~/.ssh/automation_key -N ""
```

**No Passphrase**: Empty `-N ""`.[1]

**Deploy to Servers**: Add `automation_key.pub` to authorized_keys.[1]

#### Script Example

**Automated Backup**:[1]

```bash
#!/bin/bash
ssh -i ~/.ssh/backup_key backup@server "tar -czf /tmp/backup.tar.gz /data"
scp -i ~/.ssh/backup_key backup@server:/tmp/backup.tar.gz /local/backups/
```

### Common SSH Issues

**Too Many Failed Attempts**: Temporarily locked:[1]

Wait or check `sshd_config` for `MaxAuthTries`.[1]

**Connection Timeout**: Network unreachable:[1]

Verify routing and firewall rules.[1]

**Stale SSH Keys**: After system reimaging:[1]

Remove from `~/.ssh/known_hosts`:[1]

```bash
ssh-keygen -R hostname
```

### Best Practices Summary

**Setup**: Generate keys, copy to server, test connection.[2][1]

**Harden Server**: Disable password auth, disable root login.[2][1]

**Use Aliases**: Configure ~/.ssh/config for convenience.[1]

**Monitor Logs**: Regularly review authentication logs.[1]

**Keep Keys Safe**: Protect private keys with passphrases.[1]

**Use SSH Agent**: Cache passphrases for convenience.[1]

Sources
[1] pacman - ArchWiki https://wiki.archlinux.org/title/Pacman
[2] Which should I use, x11 or wayland? - openSUSE Forums https://forums.opensuse.org/t/which-should-i-use-x11-or-wayland/166824

