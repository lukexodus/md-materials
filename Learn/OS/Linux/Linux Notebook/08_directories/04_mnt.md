## `/mnt`


The `/mnt` directory in Linux is a standard location used as a temporary mount point for filesystems or storage devices that are mounted manually by the system administrator. When you want to access data from an external device (such as a USB drive or a separate hard drive partition), you typically attach or "mount" it to a directory within `/mnt`.[1][2][4]

### Key Points About `/mnt`

- **Temporary Mount Point:** `/mnt` is intended for the temporary mounting of filesystems. For example, mounting a USB drive might create a subdirectory like `/mnt/usb`.[4]
- **Manual Use:** By convention, users or administrators use `/mnt` for mount operations they perform manually, not for system-automated or permanent mounts.[2]
- **Accessing Files:** Once a storage device is mounted to a directory in `/mnt`, its contents become accessible at that location as if they were part of the main filesystem.[1][4]
- **Unmounting:** When the device is unmounted, its files are no longer accessible via the mount point.

### Example Usage

Suppose you insert a USB stick and want to access its data:
- Create a mount point: `mkdir /mnt/usb`
- Mount the device: `mount /dev/sdb1 /mnt/usb`
- Access files at `/mnt/usb`
- Unmount when done: `umount /mnt/usb`

Traditionally, `/mnt` is reserved for these temporary tasks, while `/media` or other directories might be used for devices mounted automatically by the system.[4][1]

Sources
[1] What is a mount point? https://www.techtarget.com/whatis/definition/mount-point
[2] /mnt https://tldp.org/LDP/Linux-Filesystem-Hierarchy/html/mnt.html
[3] What is "mount point" in the context of an installation? https://www.reddit.com/r/linux4noobs/comments/aa5444/what_is_mount_point_in_the_context_of_an/
[4] What Is Mount Point In Linux? - Pune https://technogeekscs.com/mount-point-in-linux/
[5] Mount points https://www.ibm.com/docs/en/aix/7.3.0?topic=mounting-mount-points

