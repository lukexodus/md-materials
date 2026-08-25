## Managing VMs with virt-manager


### virt-manager Overview

**Purpose**: GUI for managing QEMU/KVM virtual machines .

**Features** :
- Visual VM management 
- Network configuration 
- Storage management 
- Remote connections 

**Installation**: `sudo pacman -S virt-manager` .

### Initial Setup

#### Installation Requirements

**Dependencies** :

```bash
sudo pacman -S virt-manager libvirt qemu
sudo systemctl enable --now libvirtd.service
```

#### User Permissions

**Group Membership** :

```bash
sudo usermod -aG libvirt $USER
sudo usermod -aG kvm $USER
```

**Apply Changes** :

```bash
newgrp libvirt
# or logout and login
```

#### Verify Setup

**Connection Test** :

```bash
virsh list
```

Should work without sudo .

### Launching virt-manager

#### Start Application

**From Terminal** :

```bash
virt-manager
```

**From Menu** :

Applications → System → Virtual Machine Manager .

#### Main Window

**Components** :
- Left panel: VM list 
- Center: VM details 
- Top toolbar: Common actions 

### Creating Virtual Machines

#### New VM Wizard

**Launch Wizard** :

File → New Virtual Machine .

**Step 1: Installation Method** :

- Local ISO image 
- Network installation 
- Existing disk image 

**Step 2: OS Selection** :

Choose operating system .

**Step 3: Resource Allocation** :

- vCPU count 
- Memory amount 

**Step 4: Storage** :

- Create new disk 
- Use existing disk 

**Step 5: Network** :

- Network device 
- Connection type 

#### Detailed Configuration

**Choose ISO** :

Browse and select installation ISO .

**OS Detection** :

Auto-detects from ISO or manual selection .

**CPU Allocation** :

```
Number of vCPUs: [slider]
Threads: [dropdown]
```

**Memory Setting** :

In MB, typically 2048-4096 .

**Disk Configuration** :

Create disk in `/var/lib/libvirt/images/` .

### Virtual Machine Console

#### Access VM Console

**Double-click VM** :

Opens console window .

**Graphical Console** :

VNC or SPICE connection .

#### Console Features

**Keyboard/Mouse** :

Click to capture input .

**Ctrl+Alt+Del** :

Send to guest .

**Full Screen** :

View → Full Screen .

**Resize Console** :

Automatically resizes with window .

### Virtual Machine Control

#### Power Management

**Start VM** :

Select VM → Click Start button .

**Pause VM** :

Pause button in toolbar .

**Resume VM** :

Resume button .

**Stop VM** :

Stop button (graceful shutdown) .

**Force Stop** :

Right-click VM → Force Off .

#### VM Details

**View Information** :

Right-click VM → Open .

Shows:
- CPU usage 
- Memory usage 
- Disk I/O 
- Network I/O 

### Hardware Configuration

#### Virtual Hardware Editor

**Access Settings** :

Right-click VM → Edit → Virtual Machine .

**Available Settings** :
- Processors 
- Memory 
- Disks 
- Network interfaces 
- Graphics 
- Serial devices 

#### CPU Configuration

**Change vCPU Count** :

1. Highlight CPU section 
2. Modify vCPU value 
3. Click Apply 

**CPU Model** :

- Host passthrough 
- Specific models (Penryn, etc.) 

#### Memory Management

**Modify RAM** :

1. Select Memory section 
2. Adjust maximum memory 
3. Set current allocation 

**Memory Ballooning** :

Enable for dynamic adjustment .

#### Disk Management

**Add Disk** :

1. Click "Add Hardware" 
2. Select "Storage" 
3. Create new or use existing 

**Modify Disk** :

- Change bus type (SATA, Virtio) 
- Cache settings 
- I/O throttling 

### Network Configuration

#### Default Network

**NAT Network** :

Guests behind NAT .

**Communication** :

- Guests can reach host 
- Host can reach guests 
- External network restricted 

#### Bridged Network

**Direct Access** :

Guests on same network as host .

**Setup** :

1. Virtual Networks 
2. Create new bridge 
3. Assign to VM 

#### Network Interface Configuration

**Add Interface** :

1. Click "Add Hardware" 
2. Select "Network" 
3. Choose network source 

**Interface Options** :
- Model: virtio for performance 
- Source: network or bridge 
- MAC address: auto or custom 

#### Multi-Network VM

**Multiple NICs** :

1. Add Hardware → Network 
2. Add second interface 
3. Configure separately 

### Storage Management

#### Virtual Disk Types

**QCOW2** :

Most common, sparse, snapshot support .

**RAW** :

Direct access, no overhead .

**VDI** :

VirtualBox format .

#### Create New Disk

**Via virt-manager** :

1. Edit VM → Add Hardware 
2. Select Storage 
3. Create new volume 

**Configure** :
- Size in GB 
- Format (QCOW2 preferred) 
- Storage pool 

#### Resize Disk

**Increase Size** :

```bash
virsh blockresize myvm /path/to/disk 50G
```

Then resize filesystem inside guest .

### Snapshot Management

#### Create Snapshot

**Via virt-manager** :

1. Select VM 
2. Right-click → Snapshots 
3. Click "+" to create 

**Name and Describe** :

Provide snapshot name and description .

#### List Snapshots

**View Snapshots** :

VM Detail → Snapshots tab .

Shows all snapshots with dates .

#### Revert Snapshot

**Restore State** :

1. Select snapshot 
2. Click "Restore Snapshot" 
3. Confirm 

**Resets to** :

State when snapshot was taken .

#### Delete Snapshot

**Remove Snapshot** :

1. Select snapshot 
2. Click Delete button 
3. Confirm 

### Import Existing Images

#### Import Disk Image

**Import Wizard** :

File → Import Virtual Machine .

**Select Image** :

Browse to disk file .

**OS Detection** :

Auto-detect or manual selection .

**Resource Allocation** :

Set CPU and memory .

#### Import from File

**Manual Import** :

```bash
virt-manager
# File → Import
# Select VM disk image
```

### Clone Virtual Machine

#### Clone VM

**Via virt-manager** :

1. Right-click VM 
2. Clone 
3. Confirm details 

**New VM Created** :

- Independent disk 
- New MAC address 
- Ready to start 

### Remote Connections

#### Add Remote Host

**New Connection** :

File → Add Connection .

**Connection Type** :
- SSH 
- TLS 
- TCP 

**Connection Details** :

Hostname, port, credentials .

#### Remote VM Management

**Manage Remote VMs** :

Connect to remote libvirtd .

**Create VMs** :

Same workflow on remote .

**Storage** :

Remote storage pools .

### Console Options

#### Display Settings

**Graphics Type** :

- VNC: Remote access 
- SPICE: Better performance 
- QXL: Enhanced graphics 

**Modify** :

Edit VM → Graphics .

#### Serial Console

**Enable Serial** :

1. Edit VM 
2. Add Hardware → Serial 
3. Select console type 

**Access** :

Can use `virsh console` .

### Cloning and Templates

#### Template VM

**Create Template** :

1. Set up base VM 
2. Clone for each instance 
3. Customize as needed 

**Clone Process** :

Right-click → Clone .

**Customize Clone** :

- Change hostname 
- Update network 
- Adjust resources 

### Performance Monitoring

#### View Performance

**Real-time Stats** :

VM Details → Performance tab .

**Metrics** :
- CPU usage 
- Memory usage 
- Disk I/O 
- Network I/O 

#### Optimize Performance

**CPU Pinning** :

Edit VM → Processors → Pin vCPUs .

**Cache Settings** :

Edit VM → Disk → Cache .

Use "writeback" for performance .

### Backup and Export

#### Export VM

**Export Configuration** :

File → Export XML .

**Exported File** :

Can recreate VM .

#### Backup Disk

**Via virt-manager** :

- Copy disk file manually 
- Or use export/import .

**Command Line** :

```bash
cp /var/lib/libvirt/images/vm.qcow2 backup/
```

### Troubleshooting

#### VM Won't Start

**Check Logs** :

Recent Events at bottom .

**Details** :

Right-click → Details .

**Common Issues** :
- Insufficient resources 
- Invalid ISO path 
- Network not running 

#### Console Issues

**Can't Connect** :

Check VM is running .

**Frozen Display** :

Try refresh or restart console .

#### Network Problems

**No Network** :

Check virtual network running .

**Edit → Virtual Networks** .

Start if stopped .

### Best Practices

**Use Templates**: Clone from template .

**Resource Allocation**: Match VM needs .

**Regular Snapshots**: Before changes .

**Monitor Performance**: Watch metrics .

**Use Virtio**: Better performance .

**Backup VMs**: Regular backups .

**Document VMs**: Note purposes and configs .

***

This comprehensive guide on managing VMs with virt-manager completes the virtual machine management documentation, providing users with complete knowledge for creating, configuring, and managing virtual machines through the graphical interface, complementing the command-line tools covered earlier.

