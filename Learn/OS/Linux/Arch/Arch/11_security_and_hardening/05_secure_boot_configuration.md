## Secure Boot Configuration


### Secure Boot Overview

**Purpose**: UEFI security feature that ensures only authorized bootloaders execute .

**Components** :
- UEFI firmware 
- Secure Boot keys 
- Signed bootloader 
- Verified kernel and initramfs 

**Benefits** :
- Prevents unauthorized boot 
- Protection against rootkits 
- Firmware integrity verification 

**Considerations** :
- Requires UEFI firmware 
- May limit boot options 
- Needs proper key management 

### Checking Secure Boot Status

#### Current State

**Check Enabled** :

```bash
bootctl status
```

**Output** :

```
System boot loader entry: arch
Firmware: UEFI
Secure Boot: enabled
```

**Alternative** :

```bash
cat /sys/firmware/efi/fw_platform_size
```

**SecureBoot Variable** :

```bash
efivar -d -n 8be4df61-93ca-11d2-aa0d-00e098032b8c-SecureBoot
```

#### UEFI vs BIOS

**UEFI Firmware** :

```bash
[ -d /sys/firmware/efi ] && echo "UEFI" || echo "BIOS"
```

**Secure Boot Requires**: UEFI firmware .

### Disabling Secure Boot

#### Temporary Disable (BIOS)

**Purpose**: Troubleshooting .

**Method** :
1. Reboot system 
2. Enter BIOS/UEFI setup 
3. Locate Security → Secure Boot 
4. Disable Secure Boot 
5. Save and exit 

**Verify** :

```bash
bootctl status | grep "Secure Boot"
```

#### Operating System Control

**systemd-boot Support** :

Some systems allow disabling from OS .

**Not Recommended**: Security implications .

### Enabling Secure Boot with Arch

#### Prerequisites

**Requirements** :
- UEFI firmware with Secure Boot 
- Signed bootloader 
- Signed kernel 

**Arch Bootloaders** :
- systemd-boot: Supports Secure Boot 
- GRUB: Signed versions available 

#### systemd-boot Secure Boot

**Installation** :

```bash
sudo bootctl install
```

**Status** :

```bash
bootctl status
```

#### Create Signed Bootloader

**Generate Keys** :

```bash
sudo mkdir -p /etc/efi-keys
cd /etc/efi-keys

# Create private key
sudo openssl req -new -x509 -newkey rsa:4096 -keyout PK.key -out PK.crt -days 3650
sudo openssl req -new -x509 -newkey rsa:4096 -keyout KEK.key -out KEK.crt -days 3650
sudo openssl req -new -x509 -newkey rsa:4096 -keyout db.key -out db.crt -days 3650
```

**Convert to DER** :

```bash
sudo openssl x509 -in PK.crt -outform DER -out PK.der
sudo openssl x509 -in KEK.crt -outform DER -out KEK.der
sudo openssl x509 -in db.crt -outform DER -out db.der
```

#### Sign Bootloader

**Sign EFI Binary** :

```bash
sudo sbsign --key /etc/efi-keys/db.key --cert /etc/efi-keys/db.crt \
    /boot/EFI/systemd/systemd-bootx64.efi \
    --output /boot/EFI/systemd/systemd-bootx64.efi.signed
```

#### Set UEFI Variables

**Enroll Keys** :

```bash
sudo efi-updatevar -e -f /etc/efi-keys/KEK.der KEK
sudo efi-updatevar -e -f /etc/efi-keys/db.der db
sudo efi-updatevar -f /etc/efi-keys/PK.der PK
```

**Verify** :

```bash
efivar -l | grep -i secure
```

### Kernel Signing

#### Sign Kernel Image

**Create Signature** :

```bash
sudo sbsign --key /etc/efi-keys/db.key --cert /etc/efi-keys/db.crt \
    /boot/vmlinuz-linux \
    --output /boot/vmlinuz-linux.signed
```

#### Automated Signing

**Post-Install Hook** :

Create `/etc/kernel/post-install.d/zz-sign-kernel.sh`:

```bash
#!/bin/bash
KERNEL="${1:?kernel path not provided}"
KEYDIR=/etc/efi-keys

sbsign --key "$KEYDIR/db.key" --cert "$KEYDIR/db.crt" \
    "$KERNEL" --output "$KERNEL.signed"

# Restore original name
mv "$KERNEL.signed" "$KERNEL"
```

**Make Executable** :

```bash
sudo chmod +x /etc/kernel/post-install.d/zz-sign-kernel.sh
```

### systemd-boot Configuration

#### Boot Entry Setup

**Entry File** :

`/boot/loader/entries/arch.conf`:

```
title   Arch Linux
linux   /vmlinuz-linux
initrd  /initramfs-linux.img
options root=PARTUUID=... rw
```

**Signed Kernel** :

```
title   Arch Linux
linux   /vmlinuz-linux.signed
initrd  /initramfs-linux.img
options root=PARTUUID=... rw
```

### GRUB with Secure Boot

#### Installation

**Install GRUB** :

```bash
sudo pacman -S grub efibootmgr
sudo grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB
```

#### Sign GRUB

**Sign Binary** :

```bash
sudo sbsign --key /etc/efi-keys/db.key --cert /etc/efi-keys/db.crt \
    /boot/EFI/GRUB/grubx64.efi \
    --output /boot/EFI/GRUB/grubx64.efi
```

#### GRUB Configuration

**Config File** :

`/etc/default/grub`:

```
GRUB_CMDLINE_LINUX="root=PARTUUID=... rw"
```

**Generate** :

```bash
sudo grub-mkconfig -o /boot/grub/grub.cfg
```

### Secure Boot on Encrypted Systems

#### LUKS Integration

**Encrypted Root** :

Boot process verifies before unlock .

**Initramfs** :

Must be signed if encrypted .

#### Create Signed Initramfs

**Generate** :

```bash
sudo mkinitcpio -p linux
```

**Sign** :

```bash
sudo sbsign --key /etc/efi-keys/db.key --cert /etc/efi-keys/db.crt \
    /boot/initramfs-linux.img \
    --output /boot/initramfs-linux.img.signed
```

### Troubleshooting Secure Boot

#### Boot Fails with Secure Boot

**Issue**: System won't boot .

**Causes** :
- Unsigned bootloader 
- Missing keys 
- Corrupted signatures 

**Recovery** :
1. Boot into BIOS 
2. Disable Secure Boot temporarily 
3. Fix signing issues 
4. Re-enable Secure Boot 

#### Invalid Signature Error

**Message** :

```
Signature not found
```

**Solution** :
1. Verify key enrollment 
2. Re-sign bootloader 
3. Update UEFI variables 

#### Keys Not Recognized

**Check Enrollment** :

```bash
efivar -l | grep -i db
```

**Re-enroll Keys** :

```bash
sudo efi-updatevar -f /etc/efi-keys/db.der db
```

### Security Considerations

#### Key Management

**Protect Keys** :

```bash
sudo chmod 700 /etc/efi-keys
sudo chmod 600 /etc/efi-keys/*.key
```

**Backup Keys** :

Securely store key files .

**Key Compromise** :

Regenerate and re-enroll if exposed .

#### BIOS Password

**Add BIOS Protection** :

Prevents disabling Secure Boot .

**Set in BIOS**: Security → Set Administrator Password .

#### UEFI Firmware Updates

**Caution**: Updates may reset Secure Boot .

**After Update** :
1. Verify Secure Boot status 
2. Re-enroll keys if needed 
3. Verify bootloader 

### Verification

#### Boot Integrity Check

**Verify Signature** :

```bash
sbverify --cert /etc/efi-keys/db.crt /boot/vmlinuz-linux
```

**Output** :

```
Signature verification OK
```

#### UEFI Variable Check

**List Variables** :

```bash
efivar -l
```

**Secure Boot Status** :

```bash
efivar -d -n 8be4df61-93ca-11d2-aa0d-00e098032b8c-SecureBoot
```

### Best Practices

**Enable Secure Boot**: Recommended for security .

**Manage Keys Carefully**: Protect private keys .

**Sign All Boot Components**: Bootloader, kernel, initramfs .

**Automate Signing**: Use post-install hooks .

**Document Process**: Record key locations and procedures .

**Regular Updates**: Keep bootloader and keys current .

**Test Recovery**: Verify Secure Boot doesn't prevent legitimate boots .

### Disabling Secure Boot Permanently

**If Needed** :

```bash
# From BIOS/UEFI
# Security → Secure Boot → Disabled
```

**Verify** :

```bash
bootctl status
```

**Consequence**: Loss of boot verification .

***

This completes the comprehensive Arch Linux administration guide covering all major aspects of system management, from foundational concepts through advanced security configuration including Secure Boot setup.

