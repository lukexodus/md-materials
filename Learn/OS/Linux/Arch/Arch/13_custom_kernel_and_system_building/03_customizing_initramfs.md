## Customizing Initramfs


### Initramfs Fundamentals

**Purpose**: Initial RAM filesystem loaded at boot before root filesystem .

**Functions** :
- Load kernel modules 
- Set up devices 
- Mount filesystems 
- Handle encryption 
- Enable LVM 

**Default Tool**: mkinitcpio on Arch Linux .

**Configuration**: `/etc/mkinitcpio.conf` .

### mkinitcpio Overview

#### Understanding mkinitcpio

**Configuration File** :

```bash
cat /etc/mkinitcpio.conf
```

**Main Sections** :
- MODULES 
- BINARIES 
- FILES 
- HOOKS 

#### Check Current Initramfs

**List Files** :

```bash
lsinitcpio /boot/initramfs-linux.img
```

**Detailed View** :

```bash
lsinitcpio -a /boot/initramfs-linux.img
```

### mkinitcpio Configuration

#### MODULES Section

**Purpose**: Kernel modules to include .

**Default** :

```
MODULES=()
```

**Add Modules** :

```
MODULES=(e1000 dm-crypt)
```

**Common Modules** :
- Storage: `ata_piix`, `ahci`, `nvme` 
- Filesystems: `ext4`, `btrfs`, `xfs` 
- Encryption: `dm-crypt`, `dm-verity` 

#### BINARIES Section

**Included Utilities** :

```
BINARIES=(cryptsetup)
```

**Example** :

```
BINARIES=(udev systemd-udevd)
```

**Include Binary** :

```bash
BINARIES=(/usr/bin/my-binary)
```

#### FILES Section

**Custom Files** :

```
FILES=(/etc/config /usr/lib/libcustom.so)
```

**Include Files** :

```bash
FILES=(/root/.ssh/id_rsa)
```

**Configuration** :

```bash
FILES=(/etc/modprobe.d/custom.conf)
```

#### HOOKS Section

**Processing Order** :

```
HOOKS=(base udev autodetect modconf block filesystems keyboard fsck)
```

**Default Hooks** :
- `base`: Basic utilities 
- `udev`: Device management 
- `autodetect`: Auto-detect hardware 
- `modconf`: Module configuration 
- `block`: Storage drivers 
- `filesystems`: Filesystem support 
- `keyboard`: Keyboard input 
- `fsck`: Filesystem check 

### Common Hook Additions

#### LVM Support

**Add LVM Hook** :

```
HOOKS=(base udev autodetect modconf block lvm2 filesystems keyboard fsck)
```

**Enable Encryption** :

```
HOOKS=(base udev autodetect modconf block encrypt lvm2 filesystems keyboard fsck)
```

#### Encrypted Root

**Add Encryption** :

```
HOOKS=(base udev autodetect modconf block encrypt filesystems keyboard fsck)
```

**LUKS Parameters** :

```
options root=/dev/mapper/crypt_root
```

#### Btrfs Snapshots

**Add btrfs** :

```
HOOKS=(base udev autodetect modconf block btrfs filesystems fsck)
```

#### Plymouth Boot Splash

**Add Plymouth** :

```
HOOKS=(base udev autodetect modconf block encrypt lvm2 filesystems keyboard fsck plymouth-encrypt)
```

### Custom Hooks

#### Creating Custom Hook

**Hook Directory** :

```bash
mkdir -p /etc/initcpio/hooks
mkdir -p /etc/initcpio/install
```

**Install Hook**: `/etc/initcpio/install/custom` :

```bash
#!/bin/bash

build() {
    # Add files to initramfs
    add_file /usr/bin/custom-script /bin/custom-script
    add_file /etc/custom.conf /etc/custom.conf
}

help() {
    cat <<EOFHELP
    My custom hook for initramfs
EOFHELP
}
```

**Runtime Hook**: `/etc/initcpio/hooks/custom` :

```bash
#!/bin/bash

run_hook() {
    msg "Running custom hook..."
    /bin/custom-script
}
```

**Make Executable** :

```bash
chmod +x /etc/initcpio/install/custom
chmod +x /etc/initcpio/hooks/custom
```

**Add to Config** :

```
HOOKS=(base udev ... custom ... fsck)
```

### Early User Space Customization

#### Pre-Boot Script

**Create Hook** :

```bash
# /etc/initcpio/hooks/early-boot

run_hook() {
    msg "Performing early boot tasks..."
    
    # Custom commands here
    modprobe firmware_loader
    
    /bin/sleep 2
}
```

#### Build Early Script

**Install Hook** :

```bash
# /etc/initcpio/install/early-boot

build() {
    add_file /usr/bin/early-script /bin/early-script
}

help() {
    cat <<EOFHELP
    Early boot customization
EOFHELP
}
```

### Emergency Shell

#### Enable Emergency Shell

**Add to HOOKS** :

```
HOOKS=(base udev ... emergency)
```

**Trigger on Boot** :

Add kernel parameter:

```
break=postmount
```

**Interactive Debug** :

System provides shell for troubleshooting .

#### Custom Emergency Commands

**Emergency Hook** :

```bash
# /etc/initcpio/hooks/emergency-custom

run_hook() {
    if [ "$break" = "postmount" ]; then
        msg "Launching emergency shell with custom tools"
        /bin/sh
    fi
}
```

### Reducing Initramfs Size

#### Remove Unnecessary Hooks

**Current Hooks** :

```
HOOKS=(base udev autodetect modconf block filesystems fsck)
```

**Minimal Hooks** :

```
HOOKS=(base udev block filesystems fsck)
```

**Remove** :
- `autodetect`: If specific hardware 
- `modconf`: If no custom modules 
- `keyboard`: If not needed 

#### Compression

**Compression Method** :

```bash
# In mkinitcpio.conf
COMPRESSION="zstd"
```

**Options** :
- `zstd`: Fast, modern 
- `gzip`: Universal 
- `lz4`: Very fast 
- `lzma`: Maximum compression 

**Aggressive Compression** :

```bash
COMPRESSION="lzma"
COMPRESSION_OPTIONS=(-9e)
```

### Performance Optimization

#### Preload Modules

**Load at Boot** :

```
MODULES=(e1000 nvme dm-crypt)
```

Prevents module loading delays .

#### Parallel Loading

**Modern mkinitcpio** :

Automatically parallelizes where possible .

**Enable in Config** :

```
HOOKS=(base udev autodetect modconf block ...)
```

### Rebuilding Initramfs

#### Regenerate After Changes

**Rebuild All** :

```bash
sudo mkinitcpio -P
```

**Rebuild Specific** :

```bash
sudo mkinitcpio -p linux
```

**Verbose Output** :

```bash
sudo mkinitcpio -v -p linux
```

**Dry Run** :

```bash
sudo mkinitcpio -M -p linux
```

#### Monitor Rebuild

**Check Progress** :

```bash
sudo mkinitcpio -p linux 2>&1 | tee rebuild.log
```

**Verify Generation** :

```bash
ls -la /boot/initramfs*
```

### Encrypted Root Customization

#### LUKS Encryption

**Enable in Hooks** :

```
HOOKS=(base udev autodetect modconf block encrypt filesystems keyboard fsck)
```

**Kernel Parameters** :

```
cryptdevice=/dev/sdX#:crypt:allow-discards
root=/dev/mapper/crypt
```

**Allow Discards for SSD** :

```
options ... cryptdevice=/dev/nvme0n1p2:crypt:allow-discards
```

#### Custom Encryption Script

**Create Hook** :

```bash
# /etc/initcpio/hooks/custom-crypt

run_hook() {
    msg "Setting up custom encryption..."
    
    # Custom encryption commands
    cryptsetup open /dev/sdX# crypt --key-file=/path/to/key
}
```

### LVM Customization

#### LVM Boot Support

**Add LVM Hook** :

```
HOOKS=(base udev autodetect modconf block lvm2 filesystems keyboard fsck)
```

**Activate Volumes** :

Automatically done by lvm2 hook .

#### Custom LVM Script

**Hook Configuration** :

```bash
# /etc/initcpio/hooks/custom-lvm

run_hook() {
    msg "Activating custom logical volumes..."
    lvm vgchange -ay
}
```

### Network Boot Customization

#### NFS Root

**Add NFS Hook** :

```
HOOKS=(base udev autodetect modconf block net filesystems nfs keyboard fsck)
```

**Network Configuration** :

Add network drivers to MODULES .

**Kernel Parameters** :

```
root=/dev/nfs nfsroot=server:/path ip=dhcp
```

### Debugging Initramfs

#### Extract and Examine

**Extract Contents** :

```bash
mkdir initramfs-content
cd initramfs-content
zcat /boot/initramfs-linux.img | cpio -idmv
```

**List Structure** :

```bash
find . -type f | head -20
```

#### Verify Files

**Check Binaries** :

```bash
file bin/*
```

**Check Modules** :

```bash
find lib/modules -name "*.ko" | wc -l
```

#### Boot Debugging

**Enable Debug Output** :

Add kernel parameter:

```
debug
```

**Verbose mkinitcpio** :

```bash
sudo mkinitcpio -v -p linux
```

### Custom Initramfs Examples

#### Minimal Initramfs

**Configuration** :

```
MODULES=()
BINARIES=()
FILES=()
HOOKS=(base udev block filesystems fsck)
```

**Size**: ~10-20MB .

#### Full-Featured Initramfs

**Configuration** :

```
MODULES=(ext4 dm-crypt)
BINARIES=(cryptsetup)
FILES=(/etc/crypttab)
HOOKS=(base udev autodetect modconf block encrypt lvm2 filesystems keyboard fsck)
```

**Size**: ~30-50MB .

#### Network Boot

**Configuration** :

```
MODULES=(e1000)
BINARIES=(dhclient)
HOOKS=(base udev autodetect modconf block net nfs keyboard fsck)
```

### Best Practices

**Backup Before Changes**: Save working initramfs .

**Test in VM**: Verify changes work .

**Minimal Hooks**: Only include needed .

**Document Changes**: Record modifications .

**Monitor Size**: Keep reasonable size .

**Update After Kernel**: Rebuild after kernel updates .

**Use Verbose Mode**: Debug issues with -v .

### Troubleshooting

#### Won't Boot

**Boot Fallback** :

Select fallback initramfs .

**Check Hooks** :

Ensure required hooks included .

**Verify Configuration** :

Review `/etc/mkinitcpio.conf` .

#### Missing Modules

**Add to Config** :

```
MODULES=(missing_module)
```

**Rebuild** :

```bash
sudo mkinitcpio -P
```

#### Size Issues

**Reduce Size** :

Remove unnecessary hooks .

**Compression** :

```
COMPRESSION="zstd"
```

***

This comprehensive guide on customizing initramfs completes the advanced Arch Linux system administration documentation, providing users with detailed knowledge for creating optimized boot environments tailored to their specific system requirements and use cases.

