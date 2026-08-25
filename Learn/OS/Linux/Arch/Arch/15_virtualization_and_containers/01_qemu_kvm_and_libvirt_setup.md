## QEMU, KVM, and libvirt Setup


### Virtualization Overview

**Purpose**: Run multiple operating systems on single hardware .

**Components** :
- **QEMU**: Machine emulator and virtualizer 
- **KVM**: Kernel Virtual Machine 
- **libvirt**: Virtualization management 

**Use Cases** :
- Testing distributions 
- Development environments 
- Server consolidation 
- Security isolation 

### KVM Prerequisites

#### Check Hardware Support

**Virtualization Support** :

```bash
grep -E '(vmx|svm)' /proc/cpuinfo
```

**Output** :
- `vmx`: Intel VT-x 
- `svm`: AMD-V 

**If Present** :

KVM available .

#### Load KVM Module

**Check Status** :

```bash
lsmod | grep kvm
```

**Load Module** :

```bash
sudo modprobe kvm
sudo modprobe kvm_intel   # Intel
# or
sudo modprobe kvm_amd     # AMD
```

**Persistent Loading** :

Create `/etc/modules-load.d/kvm.conf`:

```
kvm
kvm_intel
```

### Installation

#### Install QEMU and KVM

**Base Packages** :

```bash
sudo pacman -S qemu-full libvirt
```

**Includes** :
- QEMU emulator 
- KVM support 
- Various architectures 

**Minimal Installation** :

```bash
sudo pacman -S qemu-system-x86_64 libvirt
```

#### Virtio Drivers

**Windows Compatibility** :

```bash
sudo pacman -S virtio-win
```

**macOS Compatibility** :

```bash
sudo pacman -S qemu-system-ppc64
```

### libvirt Setup

#### Enable Service

**Start libvirt** :

```bash
sudo systemctl enable --now libvirtd.service
```

**Verify Running** :

```bash
sudo systemctl status libvirtd
```

#### User Permissions

**Add User to libvirt Group** :

```bash
sudo usermod -aG libvirt $USER
sudo usermod -aG kvm $USER
```

**Apply Group Change** :

```bash
newgrp libvirt
# or logout and login
```

#### Verify Setup

**Check Connection** :

```bash
virsh list
```

Should work without sudo .

### Creating Virtual Machines

#### Using virt-manager (GUI)

**Installation** :

```bash
sudo pacman -S virt-manager
```

**Launch** :

```bash
virt-manager
```

**Steps** :
1. File → New Virtual Machine 
2. Select Installation Media 
3. Configure Resources 
4. Finish 

#### Command Line: virt-install

**Basic VM Creation** :

```bash
virt-install \
    --name=myvm \
    --vcpus=2 \
    --memory=2048 \
    --cdrom=/path/to/iso \
    --disk size=20 \
    --os-variant=generic
```

**Parameters** :
- `--name`: VM name 
- `--vcpus`: Virtual CPUs 
- `--memory`: RAM in MB 
- `--cdrom`: Installation ISO 
- `--disk`: Virtual disk 

#### Advanced virt-install

**Network Configuration** :

```bash
virt-install \
    --name=myvm \
    --vcpus=4 \
    --memory=4096 \
    --cdrom=/path/to/iso \
    --disk size=50,bus=virtio \
    --network network=default,model=virtio \
    --os-variant=fedora38 \
    --graphics spice \
    --console pty,target_type=virtio
```

**Import Existing Image** :

```bash
virt-install \
    --name=myvm \
    --vcpus=2 \
    --memory=2048 \
    --disk /path/to/image.qcow2,bus=virtio \
    --import \
    --graphics spice
```

### Direct QEMU Usage

#### Basic QEMU Command

**Minimal VM** :

```bash
qemu-system-x86_64 \
    -m 2G \
    -smp 2 \
    -cdrom /path/to/iso \
    -hda disk.img
```

**Parameters** :
- `-m`: Memory 
- `-smp`: CPU cores 
- `-cdrom`: ISO image 
- `-hda`: Hard disk 

#### Create Disk Image

**QCOW2 Format** :

```bash
qemu-img create -f qcow2 disk.img 20G
```

**RAW Format** :

```bash
qemu-img create -f raw disk.img 20G
```

#### Advanced QEMU Options

**Network Bridge** :

```bash
qemu-system-x86_64 \
    -m 2G \
    -smp 2 \
    -net bridge,br=br0 \
    -net nic,model=virtio \
    -hda disk.img \
    -cdrom iso
```

**Virtio Disk** :

```bash
qemu-system-x86_64 \
    -drive file=disk.img,if=virtio \
    -cdrom iso \
    -m 2G
```

**Display Options** :

```bash
-display spice              # SPICE display
-display gtk                # GTK display
-display none               # Headless
```

### Virtual Machine Management

#### List VMs

**Active VMs** :

```bash
virsh list
```

**All VMs** :

```bash
virsh list --all
```

**Details** :

```bash
virsh dominfo myvm
```

#### Control VMs

**Start VM** :

```bash
virsh start myvm
```

**Stop VM** :

```bash
virsh shutdown myvm
```

**Force Stop** :

```bash
virsh destroy myvm
```

**Pause/Resume** :

```bash
virsh pause myvm
virsh resume myvm
```

#### VM Configuration

**Edit XML** :

```bash
virsh edit myvm
```

Opens VM configuration in editor .

**Dump Configuration** :

```bash
virsh dumpxml myvm
```

**Export Configuration** :

```bash
virsh dumpxml myvm > myvm.xml
```

### Network Configuration

#### Virtual Networks

**List Networks** :

```bash
virsh net-list
```

**Network Details** :

```bash
virsh net-info default
```

**Bridge Configuration** :

```bash
virsh net-dumpxml default
```

#### Create Custom Network

**Define Network** :

```bash
virsh net-define network.xml
virsh net-start mynetwork
virsh net-autostart mynetwork
```

**Network XML Template** :

```xml
<network>
  <name>mynetwork</name>
  <forward mode='nat'/>
  <bridge name='virbr0' stp='off' delay='0'/>
  <ip address='192.168.122.1' netmask='255.255.255.0'>
    <dhcp>
      <range start='192.168.122.2' end='192.168.122.254'/>
    </dhcp>
  </ip>
</network>
```

### Storage Management

#### Storage Pools

**List Pools** :

```bash
virsh pool-list
```

**Pool Details** :

```bash
virsh pool-info default
```

#### Create Storage Pool

**Directory Pool** :

```bash
virsh pool-create-as mypool dir --target /var/lib/libvirt/images/mypool
```

**Start Pool** :

```bash
virsh pool-start mypool
virsh pool-autostart mypool
```

#### Volume Management

**List Volumes** :

```bash
virsh vol-list mypool
```

**Create Volume** :

```bash
virsh vol-create-as mypool myvol 20G
```

**Delete Volume** :

```bash
virsh vol-delete myvol mypool
```

### Snapshots and Cloning

#### Create Snapshot

**Snapshot VM** :

```bash
virsh snapshot-create-as myvm snapshot1 "First snapshot"
```

#### List Snapshots

**View Snapshots** :

```bash
virsh snapshot-list myvm
```

#### Revert Snapshot

**Restore State** :

```bash
virsh snapshot-revert myvm snapshot1
```

#### Clone VM

**Full Clone** :

```bash
virt-clone \
    --original myvm \
    --name myvm-clone \
    --file /var/lib/libvirt/images/myvm-clone.qcow2
```

### VM Backups

#### Backup VM

**Export Configuration** :

```bash
virsh dumpxml myvm > backup/myvm.xml
```

**Copy Disk** :

```bash
cp /var/lib/libvirt/images/myvm.qcow2 backup/
```

**Script Backup** :

```bash
#!/bin/bash

VM_NAME=$1
BACKUP_DIR="~/vm-backups/$VM_NAME"

mkdir -p "$BACKUP_DIR"

# Export config
virsh dumpxml "$VM_NAME" > "$BACKUP_DIR/config.xml"

# Backup disk (if running)
if virsh list --running | grep -q "$VM_NAME"; then
    virsh shutdown "$VM_NAME"
    sleep 5
fi

cp /var/lib/libvirt/images/$VM_NAME.qcow2 "$BACKUP_DIR/"

echo "Backup complete: $BACKUP_DIR"
```

### Performance Tuning

#### CPU Configuration

**Pin vCPUs** :

```bash
virsh vcpupin myvm 0 0
virsh vcpupin myvm 1 1
```

Pins virtual CPU to physical CPU .

**Edit vcpu** :

```bash
virsh edit myvm
# Modify <vcpu> section
```

#### Memory Ballooning

**Allow Dynamic Memory** :

Edit VM XML to include:

```xml
<memballoon model='virtio'/>
```

#### Disk Optimization

**Use Virtio** :

```xml
<disk type='file' device='disk'>
  <driver name='qemu' type='qcow2' cache='writeback'/>
  <target bus='virtio' dev='vda'/>
</disk>
```

### Troubleshooting

#### VM Won't Start

**Check Logs** :

```bash
journalctl -u libvirtd -f
```

**Verbose Output** :

```bash
virsh start myvm --debug
```

#### Connection Issues

**Reset Connection** :

```bash
virsh connect qemu:///system
```

**Permissions** :

Ensure user in libvirt group .

#### Performance Issues

**Monitor VM** :

```bash
virt-top
```

Real-time VM monitoring .

**Check Host Load** :

```bash
top
htop
```

### Best Practices

**Use Virtio**: Better performance .

**Allocate Resources**: Match needs .

**Take Snapshots**: Before major changes .

**Regular Backups**: Protect VMs .

**Update Guests**: Keep current .

**Monitor Resources**: Watch usage .

**Document Setup**: Record configuration .

***

This comprehensive guide on QEMU, KVM, and libvirt setup completes the virtualization section of the Arch Linux system administration documentation, providing users with complete knowledge for creating, managing, and optimizing virtual machines on their systems.

