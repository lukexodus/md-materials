# Programs

## `dnf`

1. **Installing Packages**

To install a package, use:
```bash
sudo dnf install package_name
```

2. **Updating Packages**

To update all installed packages to their latest versions:
```bash
sudo dnf update
```

3. **Removing Packages**

To remove a package:
```bash
sudo dnf remove package_name
```

4. **Searching for Packages**

To search for a package by name or description:
```bash
dnf search keyword
```

5. **Listing Installed Packages**

To list all installed packages:
```bash
dnf list installed
```

6. **Getting Package Information**

To get detailed information about a specific package:
```bash
dnf info package_name
```

7. **Checking for Available Updates**

To check which packages have available updates:
```bash
dnf check-update
```

8. **Cleaning Up**

To clean up cached files and metadata:
```bash
sudo dnf clean all
```

9. **Managing Repositories**

To enable or disable a repository:
```bash
sudo dnf config-manager --set-enabled repository_name
sudo dnf config-manager --set-disabled repository_name
```

10. **Using History**

To view the history of DNF transactions:
```bash
dnf history
```

To undo a specific transaction:
```bash
sudo dnf history undo transaction_id
```

11. **Installing from a Local RPM File**

To install a package from a local RPM file:
```bash
sudo dnf install /path/to/package.rpm
```

12. **Using Groups**

To install a group of packages (e.g., development tools):
```bash
sudo dnf groupinstall "Development Tools"
```

13. **Querying Package Dependencies**

To see the dependencies of a specific package:
```bash
dnf deplist package_name
```

14. **Finding Orphaned Packages**

To find and remove orphaned packages (packages that were installed as dependencies but are no longer needed):
```bash
sudo dnf autoremove
```

15. **Using Repoquery**

To query installed packages from a specific repository:
```bash
dnf repoquery --installed
```


## `rpm`


The **`rpm`** (Red Hat Package Manager) command is used to install, query, verify, update, and remove packages on Red Hat-based systems like Fedora, CentOS, and RHEL. Here’s an overview of some of the most commonly used `rpm` commands:

1. **Install a Package**
   This command installs a package on your system.

   ```bash
   rpm -i package_name.rpm
   ```

   - **`-i`**: This stands for "install".
   - Example: `rpm -i my_package.rpm`

2. **Upgrade a Package**
   To upgrade (or install if not installed) a package.

   ```bash
   rpm -U package_name.rpm
   ```

   - **`-U`**: This stands for "upgrade". If the package is already installed, it will be upgraded; if not, it will be installed.
   - Example: `rpm -U my_package.rpm`

   You can also use the **`-F`** flag, which means "freshen." This will only upgrade the package if it is already installed (it won't install a new package that isn't present).

   ```bash
   rpm -F package_name.rpm
   ```

3. **Remove a Package**
   To remove an installed package:

   ```bash
   rpm -e package_name
   ```

   - **`-e`**: This stands for "erase", meaning it removes the package.
   - Example: `rpm -e my_package`

4. **Query a Package**
   This is used to get detailed information about a package.

   ```bash
   rpm -q package_name
   ```

   - **`-q`**: This stands for "query".
   - Example: `rpm -q my_package` – this will show you if the package is installed.
   
   You can also query for additional details, such as:

   - **All installed packages**:
     ```bash
     rpm -qa
     ```
     This lists all installed RPM packages.
     
   - **Detailed information**:
     ```bash
     rpm -qi package_name
     ```
     Provides detailed information about the installed package (description, version, release, build date, etc.).

   - **List files installed by a package**:
     ```bash
     rpm -ql package_name
     ```

   - **Find which package installed a particular file**:
     ```bash
     rpm -qf /path/to/file
     ```

5. **Verify a Package**
   To verify the integrity and status of a package, checking if any files have been modified since the package was installed.

   ```bash
   rpm -V package_name
   ```

   - **`-V`**: This stands for "verify".
   - Example: `rpm -V my_package`
   
   The output of `rpm -V` consists of eight characters, with each character representing a test. If any character differs, it shows the type of problem detected (e.g., missing file, modified file).

6. **List Dependencies of a Package**
   To display the dependencies of a package:

   ```bash
   rpm -qR package_name
   ```

   - **`-R`**: This stands for "requires", showing package dependencies.
   - Example: `rpm -qR my_package`

7. **Install a Package Without Dependencies**
   To install a package without checking for its dependencies (not recommended unless you know what you're doing):

   ```bash
   rpm -i --nodeps package_name.rpm
   ```

   - **`--nodeps`**: This bypasses dependency checking.

8. **Check for Conflicts**
   To check if a package would conflict with files from already installed packages:

   ```bash
   rpm -i --test package_name.rpm
   ```

   - **`--test`**: Tests the installation without actually installing the package.

9. **Display Package Contents**
   To list all files included in an `.rpm` file (before installing it):

   ```bash
   rpm -qlp package_name.rpm
   ```

   - **`-p`**: This is used when querying an RPM package file that is not yet installed.
   - Example: `rpm -qlp my_package.rpm`

10. **Export a Package Signature**
   To export a package’s GPG (signature) key:

   ```bash
   rpm --import /path/to/keyfile
   ```

   This is used when you want to import a GPG key for package verification.

11. **Show the Change Log**
   To display the change log of a package:

   ```bash
   rpm -q --changelog package_name
   ```

   This will show all the change log entries of the package from the `.spec` file.

12. **Get Help**
   If you ever need help on any `rpm` commands or options:

   ```bash
   rpm --help
   ```

**Summary of Common Options:**

| Option        | Description                                    |
| ------------- | ---------------------------------------------- |
| `-i`          | Install a package                              |
| `-U`          | Upgrade or install a package                   |
| `-e`          | Erase (remove) a package                       |
| `-q`          | Query information about a package              |
| `-qa`         | Query all installed packages                   |
| `-ql`         | List files installed by a package              |
| `-qi`         | Get detailed information about a package       |
| `-qf`         | Find which package owns a specific file        |
| `-V`          | Verify the integrity of an installed package   |
| `-R`          | Show dependencies of a package                 |
| `--nodeps`    | Install/erase without checking dependencies    |
| `--changelog` | Show package's changelog                       |
| `--test`      | Test the installation (don’t actually install) |
| `--import`    | Import a GPG key                               |
| `--help`      | Show help for rpm commands                     |

These commands give you the basic control over RPM packages in a Red Hat-based system like Fedora, CentOS, or RHEL. For day-to-day use, you’ll likely use package managers like `dnf` or `yum` on top of `rpm`, but it's useful to know how to work directly with `rpm` for lower-level package management.

**GPG** (GNU Privacy Guard) is an encryption and signing tool for secure communication. It allows you to encrypt, decrypt, sign, and verify files and messages. It uses public key cryptography to allow users to exchange data securely.

## `flatpak`

Flatpak is a system for building, distributing, and running sandboxed desktop applications on Linux. 

1. **Install an Application**

To install an application from a Flatpak repository, such as Flathub:

```bash
flatpak install <repository> <application>
```

For example, to install an app from the Flathub repository:

```bash
flatpak install flathub com.spotify.Client
```

2. **Run an Installed Application**

To run an installed Flatpak application:

```bash
flatpak run <application-id>
```

Example:

```bash
flatpak run com.spotify.Client
```

3. **List Installed Flatpak Applications**

To list all Flatpak applications installed on your system:

```bash
flatpak list
```

4. **Update Installed Applications**

To update all installed Flatpak applications:

```bash
flatpak update
```

To update a specific application:

```bash
flatpak update <application-id>
```

5. **Uninstall an Application**

To uninstall a Flatpak application:

```bash
flatpak uninstall <application-id>
```

For example:

```bash
flatpak uninstall com.spotify.Client
```

6. **Search for Applications**

To search for Flatpak applications from repositories:

```bash
flatpak search <application-name>
```

For example:

```bash
flatpak search vlc
```

7. **Add a Flatpak Remote Repository**

A remote repository is where Flatpak gets the applications. Flathub is the most popular Flatpak repository.

To add a remote repository:

```bash
flatpak remote-add --if-not-exists <name> <url>
```

For example, to add Flathub:

```bash
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
```

8. **List Remote Repositories**

To list all the Flatpak repositories you've added:

```bash
flatpak remotes
```

9. **Remove a Flatpak Remote Repository**

To remove a Flatpak remote repository:

```bash
flatpak remote-delete <name>
```

For example, to remove the Flathub repository:

```bash
flatpak remote-delete flathub
```

10. **List Permissions for an Installed App**

To list the permissions granted to a specific Flatpak application:

```bash
flatpak info --show-permissions <application-id>
```

For example:

```bash
flatpak info --show-permissions com.spotify.Client
```

11. **Show Detailed Information About an Application**

To display detailed information about an installed Flatpak application, including the application version and runtime:

```bash
flatpak info <application-id>
```

Example:

```bash
flatpak info com.spotify.Client
```

12. **Repair a Flatpak Installation**

If something is wrong with your Flatpak installation (e.g., missing files), you can attempt to repair it:

```bash
flatpak repair
```

13. **Remove Unused Runtimes**

To remove unused Flatpak runtimes (dependencies that are no longer needed by any installed apps):

```bash
flatpak uninstall --unused
```

14. **Export Installed Applications as a Bundle**

To export an installed Flatpak application into a single-file bundle:

```bash
flatpak build-bundle <repo> <bundle-filename> <application-id> <version>
```

This can be useful for offline installations.

15. **Enter Sandbox (Debugging)**

You can enter the sandbox of an application for debugging purposes:

```bash
flatpak enter <instance-id>
```

You can get the instance ID from `flatpak ps`.

16. **List Running Flatpak Applications**

To list currently running Flatpak applications:

```bash
flatpak ps
```

**Example Workflow**

1. **Add the Flathub repository**:
   ```bash
   flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
   ```

2. **Install VLC media player**:
   ```bash
   flatpak install flathub org.videolan.VLC
   ```

3. **Run VLC**:
   ```bash
   flatpak run org.videolan.VLC
   ```

4. **Update all Flatpak apps**:
   ```bash
   flatpak update
   ```

5. **Uninstall VLC**:
   ```bash
   flatpak uninstall org.videolan.VLC
   ```

**Notes**
- Flatpak provides application isolation, meaning applications have limited access to the system. You can manage permissions with tools like **Flatseal** to control what system resources Flatpak applications can access.
- Flatpak commands require **sudo** if you’re managing system-wide installations. If managing only the current user’s Flatpak apps, `sudo` is not required.

## `gpg`
**Key Concepts in GPG**

1. **Public and Private Keys**:
   - **Public Key**: Used to encrypt messages and verify signatures. You share this key with others.
   - **Private Key**: Used to decrypt messages and create digital signatures. You keep this key secret.

2. **Encryption**: Scrambles a message using the recipient's public key so only the recipient, with the private key, can decrypt it.

3. **Decryption**: The process of converting encrypted data back into its original form using the private key.

4. **Signing**: A way to ensure that a file or message has not been tampered with by attaching a digital signature created using the sender's private key.

5. **Verification**: Checking the validity of a signature using the sender's public key.

**GPG Commands and Usage**

1. **Generate a Key Pair**

To generate a new GPG key pair (public and private keys):

```bash
gpg --full-generate-key
```

You'll be prompted for information such as:
- Key type (RSA and RSA, DSA, etc.)
- Key size (2048 bits or higher for stronger encryption)
- Key expiration (optional)
- User information (name, email, and optional comment)
- Passphrase (to protect your private key)

2. **List Keys**

- **List public keys** in your keyring:

  ```bash
  gpg --list-keys
  ```

- **List private keys**:

  ```bash
  gpg --list-secret-keys
  ```

3. **Export a Public Key**

To share your public key with someone else, export it using:

```bash
gpg --export --armor your_email@example.com > public_key.asc
```

- **`--armor`**: Exports the key in a readable text format (ASCII armor).
- **`public_key.asc`**: The output file that contains your public key.

4. **Import a Public Key**

To import someone else's public key, use the following command:

```bash
gpg --import public_key.asc
```

This adds the public key to your keyring.

5. **Encrypt a File**

To encrypt a file so that only the recipient can decrypt it with their private key:

```bash
gpg --encrypt --recipient recipient_email@example.com file.txt
```

This will create an encrypted file (`file.txt.gpg`) that only the recipient can decrypt.

6. **Decrypt a File**

To decrypt a file that was encrypted for you:

```bash
gpg --decrypt file.txt.gpg
```

You'll be prompted to enter your private key's passphrase to decrypt the file.

7. **Sign a File**

To sign a file, creating a digital signature with your private key:

```bash
gpg --sign file.txt
```

This creates a signature for `file.txt` (`file.txt.gpg`) that can be used to verify its integrity.

- To create a detached signature (signature stored in a separate file):

  ```bash
  gpg --detach-sign file.txt
  ```

This creates a separate `.sig` file, for example `file.txt.sig`.

8. **Verify a Signature**

To verify the signature of a file signed with GPG:

```bash
gpg --verify file.txt.sig file.txt
```

This checks the validity of the signature using the public key of the sender.

9. **Encrypt and Sign a File**

To encrypt and sign a file at the same time (ensures confidentiality and authenticity):

```bash
gpg --encrypt --sign --recipient recipient_email@example.com file.txt
```

This results in a file that is both encrypted and signed.

10. **Export a Private Key**

You can export your private key, but **be careful** as this could compromise your security if shared:

```bash
gpg --export-secret-keys --armor your_email@example.com > private_key.asc
```

This exports the private key in an ASCII file.

11. **Revoke a Key**

If your private key is compromised, you may want to revoke your public key to prevent further use. First, generate a revocation certificate:

```bash
gpg --output revoke.asc --gen-revoke your_email@example.com
```

Keep this certificate in a safe place. If your private key is lost or compromised, you can use the revocation certificate to revoke your key.

12. **Import and Use Revocation Certificate**

To import a revocation certificate:

```bash
gpg --import revoke.asc
```

This revokes the associated key.

13. **Trust a Public Key**

When you import a public key, GPG does not automatically trust it. You must explicitly set the trust level.

```bash
gpg --edit-key recipient_email@example.com
```

Then, type `trust`, choose a trust level (1 to 5), and confirm.

**Summary of Common Commands**

| Command                              | Description                                                 |
|--------------------------------------|-------------------------------------------------------------|
| `gpg --full-generate-key`            | Generate a new public/private key pair                      |
| `gpg --list-keys`                    | List your public keys                                       |
| `gpg --list-secret-keys`             | List your private keys                                      |
| `gpg --export --armor`               | Export a public key to a file                               |
| `gpg --import`                       | Import a public key                                         |
| `gpg --encrypt --recipient`          | Encrypt a file                                              |
| `gpg --decrypt`                      | Decrypt a file                                              |
| `gpg --sign`                         | Sign a file                                                 |
| `gpg --verify`                       | Verify a signed file                                        |
| `gpg --export-secret-keys --armor`   | Export your private key                                     |
| `gpg --gen-revoke`                   | Generate a revocation certificate                           |

**Additional Notes**

- **Key servers**: GPG can upload and download keys from key servers. This helps in sharing public keys easily. Example:

  ```bash
  gpg --send-keys KEYID --keyserver keyserver.ubuntu.com
  gpg --recv-keys KEYID --keyserver keyserver.ubuntu.com
  ```

- **Passphrase protection**: Always protect your private key with a strong passphrase. This passphrase will be required to decrypt files or sign messages.

GPG provides a high level of security for your communication and data, provided it is used correctly. Always manage your keys securely and back them up.

## `systemd`

**systemd** is a system and service manager for Linux operating systems. It serves as the default init system for many Linux distributions, including Fedora, Red Hat Enterprise Linux, Ubuntu (from version 15.04), and others. Here’s an overview of its key features and functionalities:

**Key Features of systemd**

1. **Init System**: 
   - systemd replaces the traditional init system (SysVinit) used in Unix-like operating systems. It is responsible for booting the system and managing system processes.

2. **Unit Types**: 
   - systemd organizes services and resources into units. Each unit can represent different types of resources, including:

3. **Parallel Startup**: 
   - systemd is designed for fast boot times. It can start services in parallel rather than sequentially, which speeds up the overall boot process.

4. **On-Demand Service Activation**: 
   - Services can be started on-demand when they are needed (e.g., when a socket is accessed), rather than starting all services at boot.

5. **Service Management**: 
   - systemd includes commands to manage services easily, such as starting, stopping, enabling, or disabling services. Common commands include:
     - `systemctl start <service>`: Start a service.
     - `systemctl stop <service>`: Stop a service.
     - `systemctl enable <service>`: Enable a service to start at boot.
     - `systemctl disable <service>`: Disable a service from starting at boot.
     - `systemctl status <service>`: Check the status of a service.

6. **Logging with Journal**: 
   - systemd comes with `journalctl`, a logging tool that captures log messages from system services, the kernel, and other sources in a binary format. This allows for easy querying and filtering of logs.
   - Example command: `journalctl -u <service>` to view logs for a specific service.

7. **Dependencies**: 
   - systemd allows defining dependencies between services. It can start or stop services based on their dependencies automatically.

8. **Resource Control**: 
   - systemd supports control groups (cgroups), allowing it to manage resource allocation for services, such as limiting CPU and memory usage.

9. **Configuration Files**: 
   - Configuration for systemd services is typically done in unit files, which are located in `/etc/systemd/system/` or `/lib/systemd/system/`. These files specify how the service should be started, stopped, and managed.

**UNITS**

1. **Services**
- **Definition**: Service units (`.service` files) define system services or daemons. They contain configurations on how to start, stop, and manage these services.
  
- **Purpose**: Services are used to run background processes that perform various tasks. Examples include web servers, database servers, and application daemons.

- **Basic Configuration**: A service unit file typically includes sections like `[Unit]`, `[Service]`, and `[Install]`. The `[Service]` section defines how the service behaves (e.g., which command to execute).

  **Example**:
```ini
  [Unit]
  Description=My Custom Service

  [Service]
  ExecStart=/usr/bin/my_program

  [Install]
  WantedBy=multi-user.target
```

2. **Sockets**
- **Definition**: Socket units (`.socket` files) manage socket-based activation for services. They listen for incoming connections and start the corresponding service when a connection is detected.

- **Purpose**: Sockets are useful for services that do not need to run all the time. They can be activated on-demand, reducing resource usage. This is common for network services like web servers.

- **Basic Configuration**: A socket unit file specifies the address and port to listen on, and can also specify which service unit to activate.

  **Example**:
```ini
  [Unit]
  Description=My Socket

  [Socket]
  ListenStream=8080

  [Install]
  WantedBy=sockets.target
```

3. **Targets**
- **Definition**: Target units (`.target` files) group other units together for management purposes. They are similar to runlevels in SysVinit and can represent various system states.

- **Purpose**: Targets are used to organize services and other units. For example, the `multi-user.target` is used for non-graphical multi-user systems, while `graphical.target` is for graphical systems.

- **Basic Configuration**: A target unit does not run processes but can be used to pull in dependencies or other units.

**Example**:
```ini
  [Unit]
  Description=My Custom Target

  [Install]
  WantedBy=multi-user.target
```

4. **Mounts**
- **Definition**: Mount units (`.mount` files) are used to manage filesystems and mounts in the Linux filesystem hierarchy.

- **Purpose**: These units automatically mount filesystems at boot or when a specified condition is met. They are useful for managing external drives, network shares, or other filesystems.

- **Basic Configuration**: A mount unit defines the source and target mount points and the filesystem type.

  **Example**:
```ini
  [Unit]
  Description=My Mount

  [Mount]
  What=/dev/sdb1
  Where=/mnt/mydrive
  Type=ext4

  [Install]
  WantedBy=multi-user.target
```

5. **Timers**
- **Definition**: Timer units (`.timer` files) are used to schedule tasks to run at specified intervals or at specific times.

- **Purpose**: Timers can replace cron jobs in systemd. They can trigger service units to run based on timers instead of a fixed schedule.

- **Basic Configuration**: A timer unit specifies when to run a service and can include settings like `OnActiveSec` (run after a period of inactivity) or `OnCalendar` (run at a specific time).

  **Example**:
```ini
  [Unit]
  Description=My Timer

  [Timer]
  OnCalendar=*-*-* *:0/15:00
  Persistent=true

  [Install]
  WantedBy=timers.target
```

**Example of Creating a Systemd Service**

Here’s a simple example of how to create a systemd service:

1. **Create a Service File**:
   Create a file named `/etc/systemd/system/my_service.service`:

```ini
[Unit]
Description=My Custom Service

[Service]
ExecStart=/usr/bin/my_program

[Install]
WantedBy=multi-user.target
```

2. **Reload Systemd**:
   After creating or modifying the service file, reload the systemd configuration:

   ```bash
   sudo systemctl daemon-reload
   ```

3. **Start the Service**:
   Start the service with:

   ```bash
   sudo systemctl start my_service
   ```

4. **Enable the Service**:
   If you want the service to start automatically at boot:

   ```bash
   sudo systemctl enable my_service
   ```

5. **Check the Status**:
   Check the status of your service:

   ```bash
   sudo systemctl status my_service
   ```

**LISTING SERVICES**

To list services in a systemd-based Linux system, you can use the `systemctl` command. Here are some common ways to list services:

1. **List All Services**

To display all services (active, inactive, and failed), run:

```bash
systemctl list-units --type=service
```

This command will show you the status of all services managed by systemd.

2. **List Active Services**

To list only active (running) services, use:

```bash
systemctl list-units --type=service --state=running
```

3. **List Failed Services**

To see services that have failed, use:

```bash
systemctl --failed
```

4. **List All Services with Status**

You can also get a brief status overview of all services by using:

```bash
systemctl list-unit-files --type=service
```

This command will show you all service unit files along with their enabled or disabled status.

5. **Get Detailed Information on a Specific Service**

If you want detailed information about a specific service, you can use:

```bash
systemctl status <service_name>
```

Replace `<service_name>` with the name of the service you want to check, for example:

```bash
systemctl status nginx.service
```

**Example Output**

Here’s an example of what the output might look like when listing services:

```
  UNIT                                 LOAD   ACTIVE SUB     DESCRIPTION
  avahi-daemon.service                 loaded active running Avahi mDNS/DNS-SD Stack
  nginx.service                        loaded active running A high performance web server and a reverse proxy server
  sshd.service                         loaded active running OpenSSH server daemon
  mysql.service                        loaded active running MySQL Community Server
  cron.service                         loaded active running Regular background program processing daemon

LOAD   = Reflects whether the unit is loaded into memory
ACTIVE = Reflects whether the unit is active (running or not)
SUB    = Sub-status of the unit
DESCRIPTION = A brief description of the unit
```

**`systemd` USER SERVICES**

**systemd user services** are services managed by `systemd` that are run in the context of a regular user instead of the system as a whole. Normally, `systemd` services are started and managed as part of the system (like web servers or database services), but **user services** allow individual users to run and manage their own services that do not require superuser privileges.

**User Services vs. System Services**
- **System Services**: Managed by the system-wide `systemd` (usually located in `/lib/systemd/system/` or `/etc/systemd/system/`).
- **User Services**: Managed on a per-user basis and usually located in the user’s home directory under `~/.config/systemd/user/` or `/usr/lib/systemd/user/`.

   - **User services** don’t require superuser privileges.
   - They run within the user's session and can be automatically started when the user logs in.
   - They can also run independent of a graphical session (if configured).

**Example of a simple user service:**
1. **Create the service file:**
   ```bash
   mkdir -p ~/.config/systemd/user
   nano ~/.config/systemd/user/my-service.service
   ```

2. **Write the service configuration:**
```ini
[Unit]
Description=My User Service

[Service]
ExecStart=/home/user/my-program.sh
Restart=on-failure

[Install]
WantedBy=default.target
```

3. **Reload systemd to recognize the new service:**
```bash
systemctl --user daemon-reload
```

4. **Start and enable the service:**
   - To start the service:
 ```bash
 systemctl --user start my-service
 ```
   - To enable the service to start on login:
 ```bash
 systemctl --user enable my-service
 ```

5. **Check status:**
   You can check the status of the user service using:
```bash
systemctl --user status my-service
```

**Common Use Cases for User Services**
- Running background tasks or scripts when a user logs in.
- Managing personal daemons (e.g., for development environments, music servers, etc.).
- Running non-system-wide services that don’t need root access.

**Benefits of Using systemd for User Services**
- **Service management**: You can easily start, stop, and manage the lifecycle of your services.
- **Logging**: Logs are automatically handled by `journalctl`, making it easier to debug or monitor.
- **Automatic restart**: You can configure services to restart automatically if they crash.

## `tmux`

**tmux** (Terminal Multiplexer) is a powerful command-line tool that allows you to manage multiple terminal sessions from within a single window. This is especially useful if you're working with remote servers or complex development environments, as it lets you run, split, and organize several terminal sessions simultaneously without needing multiple windows or tabs.

Here are the key features and commands of **tmux**:

**Key Features:**
1. **Multiple Sessions**: You can create and manage multiple terminal sessions, each running its own shell instance.
2. **Session Persistence**: If you lose connection to a server or close the terminal, tmux sessions stay active, so you can reconnect to them later.
3. **Window and Pane Management**: tmux allows splitting a single terminal window into multiple panes (either horizontally or vertically), each of which acts as an independent terminal.
4. **Session Sharing**: You can share your terminal session with other users, useful for pair programming or debugging.

**Basic Commands:**
1. **Starting tmux**:
   ```
   tmux
   ```
   This will start a new tmux session. You’ll be able to create panes and windows from here.

2. **Detaching from a Session**:
   To leave a tmux session running in the background:
   ```
   Ctrl + b, then d
   ```
   This will detach you from the session, allowing it to continue running.

3. **Reattaching to a Session**:
   If you want to return to a previous session:
   ```
   tmux attach-session -t <session-name>
   ```

4. **Splitting Panes**:
   - Split horizontally: `Ctrl + b, then %`
   - Split vertically: `Ctrl + b, then "`

5. **Switching Between Panes**:
   You can navigate between panes using:
   ```
   Ctrl + b, then arrow keys
   ```

6. **Creating a New Window**:
   To open a new window:
   ```
   Ctrl + b, then c
   ```

7. **List All Sessions**:
   To see all tmux sessions running:
   ```
   tmux ls
   ```

**Example Use Case:**
If you're working on a server, you can start a long-running script in one pane, monitor system logs in another pane, and continue coding in a third. If your connection drops, you can reattach to the session and pick up right where you left off.

Would you like a more specific tmux example or a detailed guide on a particular feature?