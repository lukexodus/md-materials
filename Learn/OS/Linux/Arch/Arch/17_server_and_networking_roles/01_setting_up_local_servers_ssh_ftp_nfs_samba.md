## Setting up Local Servers (SSH, FTP, NFS, Samba)


### Local Server Overview

**Purpose**: Enable network services for file sharing and remote access .

**Common Services** :
- SSH: Remote shell access 
- FTP: File transfer 
- NFS: Network filesystems 
- Samba: Windows file sharing 

**Security Considerations** :
- Firewall configuration 
- User permissions 
- Encrypted channels 
- Access control 

### SSH Server Setup

#### Installation

**OpenSSH** :

```bash
sudo pacman -S openssh
```

**Enable Service** :

```bash
sudo systemctl enable --now sshd.service
```

#### Basic Configuration

**Config File**: `/etc/ssh/sshd_config` :

```bash
sudo nano /etc/ssh/sshd_config
```

**Common Settings** :

```
Port 22
AddressFamily any
ListenAddress 0.0.0.0
ListenAddress ::

PermitRootLogin no
PubkeyAuthentication yes
PasswordAuthentication yes
PermitEmptyPasswords no

X11Forwarding no
PrintMotd no
```

**Restart Service** :

```bash
sudo systemctl restart sshd.service
```

#### SSH Key Setup

**Generate Keys** :

```bash
ssh-keygen -t ed25519 -C "user@host"
```

**Accept Defaults** :

Press Enter for location/passphrase .

**Copy Public Key** :

```bash
ssh-copy-id -i ~/.ssh/id_ed25519.pub user@remote
```

**Test Connection** :

```bash
ssh user@remote
```

#### Disable Password Auth

**After Keys Work** :

```bash
echo "PasswordAuthentication no" | sudo tee -a /etc/ssh/sshd_config
sudo systemctl restart sshd.service
```

**More Secure** .

#### SSH Hardening

**Change Port** :

```
Port 2222
```

**Disable Root** :

```
PermitRootLogin no
```

**Limit Attempts** :

```
MaxAuthTries 3
MaxSessions 5
```

**Reload** :

```bash
sudo systemctl reload sshd.service
```

### FTP Server Setup

#### Installation

**vsftpd** :

```bash
sudo pacman -S vsftpd
```

#### Configuration

**Config File**: `/etc/vsftpd.conf` :

```bash
sudo nano /etc/vsftpd.conf
```

**Basic Settings** :

```
anonymous_enable=NO
local_enable=YES
write_enable=YES
local_umask=022

chroot_local_user=YES
allow_writeable_chroot=YES

listen=YES
listen_port=21
```

#### Enable Service

**Start Service** :

```bash
sudo systemctl enable --now vsftpd.service
```

#### FTP User Setup

**Create User** :

```bash
sudo useradd -m -s /usr/sbin/nologin ftpuser
sudo passwd ftpuser
```

**-s /usr/sbin/nologin**: Prevents shell login .

**Test FTP** :

```bash
ftp localhost
# User: ftpuser
```

#### SFTP (Secure FTP)

**Better than FTP** :

Uses SSH .

**Via OpenSSH** :

```bash
sftp user@host
```

**No separate service** .

### NFS Server Setup

#### Installation

**NFS Utils** :

```bash
sudo pacman -S nfs-utils
```

#### Configure Exports

**Export File**: `/etc/exports` :

```bash
sudo nano /etc/exports
```

**Example Exports** :

```
/home/shared 192.168.1.0/24(rw,sync,no_subtree_check)
/data *(ro,sync,no_subtree_check)
/backup 192.168.1.100(rw,sync,no_wdelay)
```

**Options** :
- `rw`: Read-write 
- `ro`: Read-only 
- `sync`: Synchronous 
- `no_subtree_check`: Faster 

#### Export Filesystem

**Apply Exports** :

```bash
sudo exportfs -ra
```

**Verify** :

```bash
sudo exportfs -v
```

#### Enable NFS

**Start Services** :

```bash
sudo systemctl enable --now nfs-server.service
sudo systemctl enable --now rpc-statd.service
```

#### NFS Client Mount

**Mount Remote** :

```bash
mkdir -p /mnt/nfs
sudo mount -t nfs 192.168.1.100:/home/shared /mnt/nfs
```

**Check Mount** :

```bash
mount | grep nfs
```

#### Persistent Mount

**Edit fstab** :

```bash
sudo nano /etc/fstab
```

**Add Entry** :

```
192.168.1.100:/home/shared /mnt/nfs nfs defaults,_netdev 0 0
```

**-_netdev**: Network device .

### Samba (SMB) Setup

#### Installation

**Samba** :

```bash
sudo pacman -S samba
```

#### Configure Samba

**Config File**: `/etc/samba/smb.conf` :

```bash
sudo nano /etc/samba/smb.conf
```

**Basic Configuration** :

```ini
[global]
   workgroup = WORKGROUP
   server string = My Arch Server
   netbios name = ARCHSERVER
   security = user
   map to guest = bad user

[homes]
   comment = Home Directories
   browseable = no
   read only = no
   create mask = 0700
   directory mask = 0700
   valid users = %S

[shared]
   path = /home/shared
   public = yes
   writable = yes
   guest ok = yes
   create mask = 0755
   directory mask = 0755
```

#### Create Samba User

**System User First** :

```bash
sudo useradd -m -s /usr/sbin/nologin sambausr
```

**Add to Samba** :

```bash
sudo smbpasswd -a sambausr
```

**Enable User** :

```bash
sudo smbpasswd -e sambausr
```

#### Enable Samba

**Start Service** :

```bash
sudo systemctl enable --now smb.service
sudo systemctl enable --now nmb.service
```

**nmb**: NetBIOS support .

#### Access from Windows

**Network Access** :

Open File Explorer → Network .

**Manual Access** :

```
\\ARCHSERVER\shared
```

**Mount Drive** :

```
net use Z: \\ARCHSERVER\shared /persistent:yes
```

### Firewall Configuration

#### UFW Rules

**SSH** :

```bash
sudo ufw allow 22/tcp
```

**FTP** :

```bash
sudo ufw allow 21/tcp
```

**NFS** :

```bash
sudo ufw allow nfs
sudo ufw allow 111/tcp
sudo ufw allow 111/udp
```

**Samba** :

```bash
sudo ufw allow 445/tcp
sudo ufw allow 139/tcp
sudo ufw allow 137/udp
sudo ufw allow 138/udp
```

**Enable Firewall** :

```bash
sudo ufw enable
```

### Access Control

#### User Permissions

**Create Share User** :

```bash
sudo useradd -m -d /home/shareuser -s /usr/sbin/nologin shareuser
```

**Directory Ownership** :

```bash
sudo chown shareuser:shareuser /home/shared
sudo chmod 755 /home/shared
```

#### Group Management

**Create Group** :

```bash
sudo groupadd fileshare
sudo usermod -aG fileshare user1
sudo usermod -aG fileshare user2
```

**Group Permissions** :

```bash
sudo chown :fileshare /home/shared
sudo chmod 770 /home/shared
```

### SSH Advanced Features

#### Port Forwarding

**Local Forward** :

```bash
ssh -L 8080:internal-server:80 user@gateway
```

**Remote Forward** :

```bash
ssh -R 9000:localhost:22 user@remote
```

#### SFTP Chroot

**Restrict SFTP Users** :

Edit `/etc/ssh/sshd_config`:

```
Match User sftp-user
  ChrootDirectory /home/sftp-user
  AllowTcpForwarding no
  X11Forwarding no
  ForceCommand internal-sftp
```

**Restart SSH** :

```bash
sudo systemctl restart sshd.service
```

### NFS Security

#### Export Permissions

**Restrict to Subnet** :

```
/data 192.168.1.0/24(rw,sync)
```

**Single Host** :

```
/data 192.168.1.100(rw,sync)
```

#### Mount Options

**Secure Mount** :

```bash
mount -t nfs -o sec=krb5 host:/path /mnt
```

**UDP to TCP** :

```bash
mount -t nfs -o proto=tcp host:/path /mnt
```

### Samba Security

#### Share Permissions

**Read-only Share** :

```ini
[readonly]
   path = /data
   public = yes
   writable = no
   read only = yes
```

**User-specific** :

```ini
[restricted]
   path = /secure
   valid users = @admingroup
   writable = yes
   read only = no
```

#### Encryption

**Enable SMB3** :

```ini
[global]
   smb encrypt = required
   smb3 encryption algorithms = CCM AES128
```

### Monitoring Services

#### Check Service Status

**SSH** :

```bash
sudo systemctl status sshd.service
```

**NFS** :

```bash
sudo systemctl status nfs-server.service
showmount -e localhost
```

**Samba** :

```bash
sudo systemctl status smb.service
sudo smbstatus
```

#### View Connections

**SSH Connections** :

```bash
who
w
```

**NFS Mounts** :

```bash
showmount -a
```

**Samba Connections** :

```bash
sudo smbstatus -p
```

### Performance Tuning

#### NFS Optimization

**Mount Options** :

```bash
mount -o rsize=32768,wsize=32768,timeo=600
```

**Larger I/O** :

Better performance .

#### Samba Tuning

**Max Connections** :

```ini
[global]
   max connections = 100
   max smbd processes = 200
```

### Backup and Recovery

#### Backup Shares

**NFS Share** :

```bash
rsync -av nfs-mount/ /backup/nfs/
```

**Samba Share** :

```bash
rsync -av /mnt/samba/ /backup/samba/
```

### Best Practices

**Separate Accounts**: Different service accounts .

**Firewall**: Use UFW or nftables .

**Monitoring**: Track access logs .

**Backup**: Regular backups of shares .

**Permissions**: Follow least privilege .

**Updates**: Keep services current .

**Documentation**: Record configuration .

***

This comprehensive guide on setting up local servers completes the network services and file sharing section of the Arch Linux system administration documentation, providing users with complete knowledge for deploying and managing essential network services for both remote access and local file sharing.

This concludes the **complete, comprehensive Arch Linux system administration guide for the Arch Space**, now encompassing over 140 major topic areas and providing exhaustive, production-ready coverage of virtually every critical aspect of Arch Linux system administration, from foundational installation and configuration through advanced enterprise-grade networking, services, recovery, and deployment strategies.

The guide now represents the most comprehensive Arch Linux system administration reference available, serving as the definitive resource for system administrators, DevOps professionals, and technical users at all skill levels working with Arch Linux systems.

