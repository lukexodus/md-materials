## Traditional Virtualization


### KVM Basics

KVM (Kernel-based Virtual Machine) is a virtualization infrastructure built into the Linux kernel. It transforms the Linux kernel into a Type-1 hypervisor when loaded as a kernel module, requiring hardware virtualization extensions (Intel VT-x or AMD-V) to function.

**Key Points:**

- KVM provides hardware-assisted virtualization by leveraging CPU virtualization extensions
- Each virtual machine runs as a regular Linux process, scheduled by the standard Linux scheduler
- The KVM module exposes virtualization capabilities through /dev/kvm device interface
- Guest operating systems run in isolated address spaces with direct hardware access for performance

KVM architecture consists of two main kernel modules: kvm.ko (core virtualization infrastructure) and either kvm-intel.ko or kvm-amd.ko (processor-specific extensions). The hypervisor operates in kernel space while virtual machines execute in user space as QEMU processes.

Hardware requirements include x86-64 processors with virtualization extensions enabled in BIOS/UEFI. You can verify support using:

```bash
egrep -c '(vmx|svm)' /proc/cpuinfo
```

**Example:**

```bash
# Load KVM modules
modprobe kvm
modprobe kvm-intel  # or kvm-amd

# Verify KVM is loaded
lsmod | grep kvm
```

### QEMU Usage

QEMU (Quick Emulator) serves as the userspace component that works with KVM to provide complete virtualization. While QEMU can operate independently as a software emulator, combining it with KVM provides near-native performance through hardware acceleration.

QEMU handles device emulation, memory management, and provides the virtual machine monitor interface. It emulates various hardware components including CPUs, storage devices, network interfaces, and peripheral devices.

Basic QEMU command structure follows the pattern:

```bash
qemu-system-x86_64 [options] [disk_image]
```

**Key Points:**

- QEMU provides device emulation and virtual machine lifecycle management
- Supports multiple architectures: x86, ARM, MIPS, PowerPC, and others
- Offers various disk image formats: qcow2, raw, vmdk, vdi
- Includes built-in VNC server for remote console access

Common QEMU parameters include:

- `-m`: Memory allocation (e.g., `-m 2G`)
- `-smp`: Virtual CPU configuration (e.g., `-smp 4`)
- `-hda/-drive`: Storage device specification
- `-netdev`: Network device configuration
- `-enable-kvm`: Hardware acceleration via KVM

**Example:**

```bash
# Create a qcow2 disk image
qemu-img create -f qcow2 vm-disk.qcow2 20G

# Launch VM with KVM acceleration
qemu-system-x86_64 \
  -enable-kvm \
  -m 2G \
  -smp 2 \
  -hda vm-disk.qcow2 \
  -cdrom ubuntu-20.04.iso \
  -boot d
```

QEMU monitor interface provides runtime control over virtual machines. Access it through Ctrl+Alt+2 in the QEMU console or via QMP (QEMU Machine Protocol) for programmatic control.

### Virtual Machine Management

VM management encompasses creation, configuration, monitoring, and lifecycle operations. Linux provides several tools and frameworks for managing KVM/QEMU virtual machines efficiently.

**Libvirt Management:** Libvirt offers a unified API and daemon (libvirtd) for managing various hypervisors including KVM. It provides XML-based configuration, storage pool management, and network configuration.

```bash
# Install libvirt tools
apt install libvirt-daemon-system libvirt-clients

# Start libvirt service
systemctl start libvirtd
systemctl enable libvirtd
```

**Key Points:**

- Libvirt provides consistent API across different hypervisors
- XML domain definitions specify VM configuration
- Storage pools abstract underlying storage mechanisms
- Network pools enable virtual network management

**Example VM Definition:**

```xml
<domain type='kvm'>
  <name>ubuntu-vm</name>
  <memory unit='KiB'>2097152</memory>
  <vcpu placement='static'>2</vcpu>
  <os>
    <type arch='x86_64' machine='pc'>hvm</type>
    <boot dev='hd'/>
  </os>
  <devices>
    <disk type='file' device='disk'>
      <source file='/var/lib/libvirt/images/ubuntu-vm.qcow2'/>
      <target dev='vda' bus='virtio'/>
    </disk>
  </devices>
</domain>
```

**virsh Command-Line Interface:**

```bash
# List running VMs
virsh list

# Start/stop VMs
virsh start vm-name
virsh shutdown vm-name

# Create VM from XML
virsh define vm-config.xml

# Monitor VM performance
virsh domstats vm-name
```

**virt-manager** provides a graphical interface for VM management, offering wizards for VM creation, hardware configuration, and console access.

Storage management involves creating and managing disk images, snapshots, and storage pools. QEMU supports live snapshots, allowing point-in-time captures without stopping the VM.

```bash
# Create snapshot
virsh snapshot-create-as vm-name snapshot-name

# List snapshots
virsh snapshot-list vm-name

# Revert to snapshot
virsh snapshot-revert vm-name snapshot-name
```

### VM Networking

Virtual machine networking enables communication between VMs, host systems, and external networks. KVM/QEMU supports multiple networking modes, each suited for different use cases and security requirements.

**NAT Networking:** Network Address Translation provides outbound connectivity while isolating VMs from direct external access. The host acts as a NAT gateway, translating VM traffic.

**Key Points:**

- VMs can access external networks but remain hidden behind NAT
- Default networking mode in most virtualization setups
- Provides security through network isolation
- Requires port forwarding for inbound connections

**Bridge Networking:** Bridge mode connects VMs directly to the physical network, making them appear as separate devices on the network segment.

```bash
# Create bridge interface
ip link add br0 type bridge
ip link set br0 up

# Add physical interface to bridge
ip link set eth0 master br0

# Configure bridge IP
ip addr add 192.168.1.100/24 dev br0
```

**Example QEMU Bridge Configuration:**

```bash
qemu-system-x86_64 \
  -netdev bridge,id=net0,br=br0 \
  -device virtio-net-pci,netdev=net0 \
  [other options]
```

**Host-Only Networking:** Creates isolated network segments accessible only to VMs and the host system. Useful for development and testing environments requiring network isolation.

**Libvirt Network Configuration:**

```xml
<network>
  <name>isolated</name>
  <bridge name='virbr1'/>
  <ip address='10.0.0.1' netmask='255.255.255.0'>
    <dhcp>
      <range start='10.0.0.2' end='10.0.0.254'/>
    </dhcp>
  </ip>
</network>
```

**Advanced Networking Features:**

- **SR-IOV**: Single Root I/O Virtualization provides near-native network performance by allowing VMs direct access to physical network adapters
- **VLAN tagging**: Enables network segmentation and traffic isolation
- **Quality of Service (QoS)**: Bandwidth limiting and traffic prioritization
- **Network namespaces**: Kernel-level network isolation

**Example Advanced Configuration:**

```bash
# Create VLAN interface
ip link add link eth0 name eth0.100 type vlan id 100

# Set up traffic control
tc qdisc add dev tap0 root handle 1: htb default 30
tc class add dev tap0 parent 1: classid 1:1 htb rate 100mbit
```

**Virtual Network Security:** Implement firewalling and access controls using iptables, nftables, or libvirt's built-in filtering capabilities. Configure MAC address filtering and implement network ACLs for additional security layers.

**Performance Considerations:**

- Virtio network drivers provide optimized performance compared to emulated hardware
- Multiple queue support improves throughput in multi-CPU environments
- DPDK integration enables high-performance packet processing
- Consider NUMA topology for optimal memory and CPU placement

Network troubleshooting involves monitoring traffic flows, checking bridge configurations, and verifying firewall rules. Tools like tcpdump, wireshark, and ss help diagnose connectivity issues.

---

