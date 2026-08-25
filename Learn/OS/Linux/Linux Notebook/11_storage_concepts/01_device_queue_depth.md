## Device Queue Depth


**Device queue depth** is the number of pending input/output (I/O) requests that a storage resource can handle simultaneously. It represents the maximum capacity of commands that a storage device can accept at any one time before requiring the host to retry or queue additional requests.[1]

### How It Works

When applications generate I/O requests, these requests enter a queue on the storage device. If the number of pending I/O requests exceeds the device's supported queue depth, the storage device returns a failure message, and the host operating system must resend the I/O. The host OS is responsible for scheduling and optimizing these requests and handling any failure messages.[1]

### Queue Depth by Storage Interface

Different storage interfaces support varying maximum queue depths:[1]

- **SATA devices**: Up to 32 commands[1]
- **SAS devices**: Up to 256 commands[1]
- **NVMe devices**: Much higher queue depth (typically 64,000+ queues with 64,000 commands each)[1]

### Performance Impact

Greater queue depth values help avoid I/O request failures and bottlenecks. When multiple hosts connect to a SATA or SAS drive with lower queue depth limits, the queue can quickly fill up, reducing throughput and increasing latency. This is one reason why NVMe-based solid-state drives typically outperform SATA and SAS drives—they support substantially higher queue depths.[1]

### Checking and Modifying in Linux

On Linux systems, you can query device queue depth using the sysfs interface. For example, you can check the current queue depth with:[3]

```
cat /sys/bus/scsi/devices/<SCSI_device>/queue_depth
```

You can modify it by writing a new value:

```
echo <new_value> > /sys/bus/scsi/devices/<SCSI_device>/queue_depth
```

The Linux SCSI code automatically adjusts queue depth as necessary, though changing it is usually a storage server requirement. You can also set a queue ramp-up period to allow the system to gradually increase queue depth if no resource problems occur.[3]

Sources
[1] How does queue depth work? https://www.techtarget.com/searchstorage/definition/queue-depth
[2] Checking the queue depth of the storage adapter and the ... https://knowledge.broadcom.com/external/article/311610/checking-the-queue-depth-of-the-storage.html
[3] Setting the queue depth for a SCSI device ... https://www.ibm.com/docs/en/linux-on-systems?topic=devices-setting-queue-depth
[4] Understanding VMware ESXi Queuing and the FlashArray https://www.codyhosterman.com/2017/02/understanding-vmware-esxi-queuing-and-the-flasharray/
[5] StorPortSetDeviceQueueDepth function (storport.h) https://learn.microsoft.com/en-us/windows-hardware/drivers/ddi/storport/nf-storport-storportsetdevicequeuedepth
[6] What is the max value for Device Queue Depth? | VMware ... https://community.broadcom.com/vmware-cloud-foundation/discussion/what-is-the-max-value-for-device-queue-depth
[7] Queues | Dell PowerStore: VMware vSphere Best Practices https://infohub.delltechnologies.com/sv-se/l/dell-powerstore-vmware-vsphere-best-practices-2/queues/
[8] Why Queue Depth matters! https://www.yellow-bricks.com/2014/06/09/queue-depth-matters/
[9] Updating QLogic HBA queue depths on a Linux host https://pubs.lenovo.com/san_configuration_guide/2412E94E-CA5B-4231-A837-420349C58D80_

