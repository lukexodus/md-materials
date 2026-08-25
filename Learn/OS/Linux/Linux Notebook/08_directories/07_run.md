## `/run`


The `/run` directory in Linux is a temporary filesystem used to store volatile runtime data created since the system was last booted. It is typically mounted as a `tmpfs` (a temporary filesystem residing in RAM), ensuring its contents are always cleared on reboot.[1][2][3][5]

### Purpose and Usage

- **Storing Runtime Data:** `/run` is used for files needed during the current running session but not meant to persist across reboots. These include process ID (PID) files, sockets, lock files, application state files, and other runtime metadata required by system services and user sessions.[3][1]
- **Replacement of Earlier Locations:** Previously, transient runtime data was stored in directories like `/var/run` or `/tmp`. Modern systems use `/run` because it is guaranteed to be available early in the boot process and is always empty when the system starts, reducing the risk of stale data causing issues for system daemons or user applications.[5][6]
- **User and Application Subdirectories:** Under `/run/user`, each user session gets a dedicated directory (e.g., `/run/user/1000`) for user-specific runtime files, such as sockets and session data.[3]

### Summary

The `/run` directory ensures a clean environment for runtime data with every system boot, which is essential for both system services and user processes that rely on up-to-date, non-persistent operational files.[2][5][3]

Sources
[1] what is the run directory? : r/linuxadmin https://www.reddit.com/r/linuxadmin/comments/18bu49j/what_is_the_run_directory/
[2] /run (runtime data) - Amazon Linux 2023 https://docs.aws.amazon.com/linux/al2023/ug/filesystem-slash-run.html
[3] What Is the /run/user/$UID Directory? https://www.baeldung.com/linux/run-user-uid-directory
[4] Linux Directory Structure https://www.geeksforgeeks.org/linux-unix/linux-directory-structure/
[5] The Linux / run directory https://www.linuxadictos.com/en/the-linux-run-directory.html
[6] The /run directory: how to create it at first boot to store ... https://stackoverflow.com/questions/13023153/the-run-directory-how-to-create-it-at-first-boot-to-store-runtime-data
[7] run Directory https://backup.education/showthread.php?tid=12772

