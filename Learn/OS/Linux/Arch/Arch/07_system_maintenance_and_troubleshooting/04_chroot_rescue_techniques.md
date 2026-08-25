## Chroot Rescue Techniques


### Chroot Concept and Purpose

**Definition**: Chroot (change root) changes the apparent root directory, allowing users to access and modify another filesystem as if it were the root.[1]

**Rescue Use**: Enter an installed system from live environment to fix boot issues, reinstall packages, or repair configuration.[2][1]

**Advantage**: Modify broken system without booting into it.[1]

**Accessibility**: Live environment provides functional kernel and tools.[2]

### Pre-Rescue Preparation

#### Boot Live Medium

**Create Live USB**: Write Arch ISO to USB:[2]

```bash
sudo dd if=archlinux-x86_64-2025.*.iso of=/dev/sdX bs=4M status=progress
```

**Boot From USB**: Restart and select USB from boot menu.[2]

**Live Environment**: Arch boot prompt confirms readiness.[2]

#### Identify Partitions

**List Devices**: `lsblk` shows storage layout:[1][2]

```bash
lsblk
```

**Example Output**:[2]

```
sda
├─sda1 (Boot, likely /boot)
├─sda2 (Root, likely /)
└─sda3 (Home, likely /home)
```

**Filesystem Check**: `fsck` integrity before mounting:[1]

```bash
sudo fsck /dev/sdX#
```

**Caution**: Only on unmounted filesystems.[1]

### Basic Chroot Setup

#### Mount Root Filesystem

**Mount Root**: Mount root partition at `/mnt`:[1][2]

```bash
sudo mount /dev/sdX# /mnt
```

**Replace sdX#** with actual device (e.g., `/dev/sda2`).[2]

#### Mount Boot Partition (UEFI)

**Mount EFI System Partition**:[1][2]

```bash
sudo mount /dev/sdX# /mnt/boot
```

**Example**: If `/boot` on `/dev/sda1`:[2]

```bash
sudo mount /dev/sda1 /mnt/boot
```

#### Mount Home (Optional)

**Separate Home Partition**:[2]

```bash
sudo mount /dev/sdX# /mnt/home
```

**Needed If**: Home stored on separate partition.[2]

### Entering Chroot

#### Using arch-chroot

**Purpose**: Properly configured chroot with essential mounts.[1][2]

**Command**:[1][2]

```bash
sudo arch-chroot /mnt
```

**Automatic Setup**:[1]
- Mounts proc, sys, dev, run filesystems[1]
- Configures resolv.conf for networking[1]
- Sets up necessary environment[1]

**Verification**: Prompt changes to `[root@...]` confirming chroot.[1]

#### Manual Chroot Alternative

**If arch-chroot Unavailable**:[2]

```bash
sudo mount -t proc proc /mnt/proc
sudo mount -t sysfs sys /mnt/sys
sudo mount --rbind /dev /mnt/dev
sudo mount --rbind /run /mnt/run
sudo chroot /mnt
```

**Less Convenient**: Requires manual mount management.[2]

**Limited Functionality**: Some tools may not work properly.[1]

### Common Rescue Scenarios

#### Bootloader Repair

**Symptoms**: System won't boot.[2][1]

**Enter Chroot**:[2]

```bash
sudo arch-chroot /mnt
```

**Systemd-boot Reinstall**:[2]

```bash
bootctl install
bootctl status
```

**GRUB Reinstall**:[2]

```bash
grub-install --target=x86_64-efi --efi-directory=/boot
grub-mkconfig -o /boot/grub/grub.cfg
```

**Verify Boot Files**: Check `/boot` contains kernel and initramfs:[2]

```bash
ls -la /boot/
```

#### Kernel Issues

**Symptoms**: System panics after kernel update.[3][2]

**Check Kernel Status**:[2]

```bash
pacman -Q linux
uname -r  # Show running kernel (from live)
```

**Reinstall Kernel**:[2]

```bash
pacman -S --force linux linux-firmware
mkinitcpio -P
```

**Fallback Boot**: If still failing, boot with fallback initramfs:[4]
1. Select fallback entry in boot menu[4]
2. Fix issues[4]
3. Reboot with main kernel[4]

#### Initramfs Corruption

**Symptoms**: Kernel error about missing initramfs.[4][2]

**Regenerate Initramfs**:[4][2]

```bash
sudo arch-chroot /mnt
mkinitcpio -P
```

**Verify Generation**: Check files created:[2]

```bash
ls -la /boot/initramfs*
```

**Check Hooks**: Ensure mkinitcpio.conf has necessary hooks:[4]

```bash
cat /etc/mkinitcpio.conf | grep HOOKS
```

#### Filesystem Issues

**Symptoms**: Filesystem errors preventing boot.[1][2]

**Check Filesystem**:[1][2]

```bash
sudo fsck /dev/sdX# -y  # Automatic repair
```

**Resize Filesystem**:[2]

```bash
sudo arch-chroot /mnt
resize2fs /dev/sdX#  # For ext4
```

#### Password Reset

**Forgot Root Password**:[1][2]

```bash
sudo arch-chroot /mnt
passwd root
# Enter new password twice
```

**Reset User Password**:[2]

```bash
sudo arch-chroot /mnt
passwd username
```

#### Package Reinstall

**Broken Packages**: System non-functional.[1][2]

**Reinstall Core Packages**:[2]

```bash
sudo arch-chroot /mnt
pacman -S --force base systemd
```

**Rebuild Initramfs**:[2]

```bash
mkinitcpio -P
```

**Full Reconstruction**:[2]

```bash
pacman -Syu
```

### Filesystem Management in Chroot

#### Mounting Additional Filesystems

**Check fstab**:[2]

```bash
cat /etc/fstab
```

**Mount All Filesystems**:[2]

```bash
mount -a
```

**Mount Specific**:[2]

```bash
mount /dev/sdX# /mnt/point
```

#### LVM Management

**Activate Logical Volumes**:[2]

```bash
sudo lvm lvdisplay
sudo lvm vgchange -a y
```

**Mount LVM Volumes**:[2]

```bash
sudo mount /dev/mapper/vg-lv /mnt
```

#### Encrypted Filesystems

**Unlock LUKS**:[2]

```bash
sudo cryptsetup open /dev/sdX# crypt_name
sudo mount /dev/mapper/crypt_name /mnt
```

**Password Prompt**: Enter encryption password.[2]

### Network in Chroot

#### Enable Networking

**Check Network**:[2]

```bash
ip link show
ping archlinux.org
```

**Enable Interface**:[2]

```bash
ip link set wlan0 up
iwctl  # Connect to WiFi
```

**DHCP Configuration**:[2]

```bash
dhcpcd enp0s3
```

#### Package Operations with Network

**Download Packages**:[2]

```bash
pacman -Sy
pacman -S package_name
```

**Build from AUR**:[2]

```bash
cd /tmp
git clone https://aur.archlinux.org/package.git
cd package
makepkg -si
```

### Logging and Diagnostics in Chroot

#### View System Logs

**Journal Access**:[2]

```bash
journalctl -n 50  # Last 50 lines
journalctl -p err  # Errors only
journalctl --boot=0  # Current boot
```

**Previous Boot Logs**:[2]

```bash
journalctl --boot=-1
```

#### System Information

**Kernel Messages**:[2]

```bash
dmesg
```

**Hardware Status**:[2]

```bash
lspci
lsusb
```

#### Package Database Check

**Verify Database**:[2]

```bash
pacman -Dk  # Check dependencies
pacman -Qk  # Check file integrity
```

**Fix Database**:[2]

```bash
pacman -Fyy  # Rebuild file database
```

### Exiting Chroot

#### Proper Exit

**Exit Command**:[1][2]

```bash
exit
```

**Return to Live Environment**: Prompt returns to live shell.[1]

#### Unmounting Filesystems

**Unmount All**:[1][2]

```bash
sudo umount -R /mnt
```

**Manual Unmounting**:[2]

```bash
sudo umount /mnt/boot
sudo umount /mnt/home
sudo umount /mnt
```

**Verify**:[2]

```bash
lsblk
```

### Advanced Chroot Scenarios

#### Multi-Disk Systems

**Mount Multiple Disks**:[2]

```bash
sudo mount /dev/sda1 /mnt
sudo mount /dev/sdb1 /mnt/home
sudo mount /dev/sdc1 /mnt/backup
sudo arch-chroot /mnt
```

#### RAID Array Recovery

**Detect RAID**:[2]

```bash
sudo mdadm --assemble --scan
sudo mount /dev/md0 /mnt
```

**Fix RAID**:[2]

```bash
sudo arch-chroot /mnt
mdadm --detail /dev/md0
```

#### Btrfs Subvolumes

**Mount Subvolumes**:[2]

```bash
sudo mount -o subvol=@ /dev/sdX# /mnt
sudo mount -o subvol=@home /dev/sdX# /mnt/home
```

### Troubleshooting Chroot Issues

#### arch-chroot Fails

**Error**: arch-chroot not found.[2]

**Solution**: Use manual chroot:[2]

```bash
sudo mount --rbind /dev /mnt/dev
sudo chroot /mnt
```

#### Permission Denied

**Error**: Files not accessible.[1]

**Cause**: SELinux or file permissions.[1]

**Solution**: Verify mounting as root:[2]

```bash
sudo arch-chroot /mnt
```

#### Network Unavailable

**Error**: No internet access.[2]

**Solution**: Configure network:[2]

```bash
ip link set wlan0 up
iwctl station wlan0 connect SSID
```

#### Filesystem Locked

**Error**: Device busy.[2]

**Cause**: Filesystem already mounted.[2]

**Solution**: Unmount first:[2]

```bash
sudo umount /mnt -R
```

### Best Practices

**Back Up First**: Backup critical data before repairs.[1][2]

**Test Commands**: Try recovery in VM first.[2]

**Document Steps**: Record what you do.[2]

**Verify Mounts**: Check with `mount` or `lsblk`.[2]

**Keep Live Media**: Always have Arch ISO available.[2]

**Test Boot**: After fixes, verify system boots.[2]

**Proper Shutdown**: Exit chroot and unmount cleanly.[1][2]

Sources
[1] chroot - ArchWiki https://wiki.archlinux.org/title/Chroot
[2] pacman - ArchWiki https://wiki.archlinux.org/title/Pacman
[3] Kernel or mkinitcpio update: do i have to reboot? ... https://bbs.archlinux.org/viewtopic.php?id=295811
[4] mkinitcpio - ArchWiki https://wiki.archlinux.org/title/Mkinitcpio

