## Integrating Non-Arch Software


### Integration Overview

**Purpose**: Install and manage software not in official repositories.[1]

**Methods** :
- Building from source 
- Using containers 
- FlatPak/AppImage 
- Manual installation 

**Challenges** :
- Dependency management 
- Integration with system 
- Updates and maintenance 

### Building from Source

#### Download Source

**Get Tarball** :

```bash
mkdir -p ~/build
cd ~/build
wget https://example.com/software-1.0.tar.gz
tar -xzf software-1.0.tar.gz
cd software-1.0
```

#### Configure and Build

**Standard Build** :

```bash
./configure
make -j$(nproc)
sudo make install
```

**Custom Prefix** :

```bash
./configure --prefix=/opt/software
make -j$(nproc)
sudo make install
```

**Install to Home** :

```bash
./configure --prefix=$HOME/.local
make -j$(nproc)
make install
```

#### Create PKGBUILD Wrapper

**Pacify Installation** :

Create `PKGBUILD`:

```bash
pkgname=external-software
pkgver=1.0
pkgrel=1
pkgdesc="External software from source"
arch=('x86_64')
url="https://example.com"
license=('MIT')
depends=()

source=("https://example.com/software-1.0.tar.gz")
sha256sums=('...')

build() {
    cd software-$pkgver
    ./configure --prefix=/usr
    make -j$(nproc)
}

package() {
    cd software-$pkgver
    make DESTDIR="$pkgdir/" install
}
```

**Build and Install** :

```bash
makepkg -si
```

### FlatPak Integration

#### Installation

**Install FlatPak** :

```bash
sudo pacman -S flatpak
sudo systemctl enable --now flatpak
```

#### Add Repository

**Flathub** :

```bash
flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
```

#### Install Applications

**Search** :

```bash
flatpak search application
```

**Install** :

```bash
flatpak install flathub org.example.application
```

**Run** :

```bash
flatpak run org.example.application
```

#### Permissions Management

**Check Permissions** :

```bash
flatpak info org.example.application
```

**Override Permissions** :

```bash
flatpak override --filesystem=host org.example.application
```

### AppImage Integration

#### Download AppImage

**Get AppImage** :

```bash
mkdir -p ~/AppImages
cd ~/AppImages
wget https://example.com/application.AppImage
chmod +x application.AppImage
```

#### Create Desktop Entry

**Desktop File**: `~/.local/share/applications/appimage.desktop` :

```ini
[Desktop Entry]
Version=1.0
Type=Application
Name=My Application
Exec=/home/user/AppImages/application.AppImage
Icon=application
Categories=Utility;
```

**Update Menu** :

```bash
update-desktop-database ~/.local/share/applications
```

#### System Integration

**Install to System** :

```bash
sudo mkdir -p /opt/appimages
sudo cp ~/AppImages/application.AppImage /opt/appimages/
sudo chmod +x /opt/appimages/application.AppImage
```

**Create Link** :

```bash
sudo ln -s /opt/appimages/application.AppImage /usr/local/bin/application
```

### Snap Package Support

#### Enable Snapd

**Install** :

```bash
yay -S snapd
sudo systemctl enable --now snapd.service
```

#### Install Snap

**Search** :

```bash
snap search application
```

**Install** :

```bash
sudo snap install application
```

**Run** :

```bash
application
```

### Docker Container Integration

#### Install Docker

**Setup** :

```bash
sudo pacman -S docker
sudo systemctl enable --now docker.service
sudo usermod -aG docker $USER
```

#### Run Containers

**Pull Image** :

```bash
docker pull ubuntu
```

**Interactive Shell** :

```bash
docker run -it ubuntu /bin/bash
```

**Mount Volumes** :

```bash
docker run -v /home/user:/workspace -it ubuntu /bin/bash
```

#### Create Custom Container

**Dockerfile** :

```dockerfile
FROM archlinux:latest

RUN pacman -Syu --noconfirm
RUN pacman -S --noconfirm base-devel git

WORKDIR /app
CMD ["/bin/bash"]
```

**Build** :

```bash
docker build -t myimage .
docker run -it myimage
```

### Manual Installation

#### Install to /opt

**Create Directory** :

```bash
sudo mkdir -p /opt/myapp
sudo chown $USER:$USER /opt/myapp
```

**Extract Software** :

```bash
tar -xzf myapp-1.0.tar.gz -C /opt/myapp
```

**Create Symlink** :

```bash
sudo ln -s /opt/myapp/bin/myapp /usr/local/bin/myapp
```

#### Install to /usr/local

**Manual Installation** :

```bash
sudo mkdir -p /usr/local/{bin,lib,share}
cp binary /usr/local/bin/
cp library.so /usr/local/lib/
cp config /usr/local/share/myapp/
```

**Update Library Cache** :

```bash
sudo ldconfig
```

### Dependency Management

#### Find Dependencies

**Check Requirements** :

```bash
ldd /path/to/binary
```

Shows required libraries .

**Missing Libraries** :

```bash
ldd /path/to/binary | grep "not found"
```

#### Install Dependencies

**Research Package** :

```bash
pacman -Ss library_name
```

**Install Required** :

```bash
sudo pacman -S library-package
```

#### Custom Library Paths

**Set LD_LIBRARY_PATH** :

```bash
export LD_LIBRARY_PATH=/opt/myapp/lib:$LD_LIBRARY_PATH
/opt/myapp/bin/myapp
```

**Persistent** :

```bash
echo 'export LD_LIBRARY_PATH=/opt/myapp/lib:$LD_LIBRARY_PATH' >> ~/.bashrc
```

### Wrapper Scripts

#### Create Launcher Script

**Script**: `/usr/local/bin/myapp` :

```bash
#!/bin/bash

export LD_LIBRARY_PATH=/opt/myapp/lib:$LD_LIBRARY_PATH
export PATH=/opt/myapp/bin:$PATH

exec /opt/myapp/bin/myapp-real "$@"
```

**Make Executable** :

```bash
chmod +x /usr/local/bin/myapp
```

#### Environment Setup

**Source Configuration** :

```bash
#!/bin/bash

# Setup environment
source /opt/myapp/config.sh

# Add to PATH
export PATH="/opt/myapp/bin:$PATH"

# Run application
exec /opt/myapp/bin/myapp "$@"
```

### System Integration

#### Desktop Integration

**Desktop Entry**: `/usr/share/applications/myapp.desktop` :

```ini
[Desktop Entry]
Version=1.0
Type=Application
Name=My Application
Comment=External application
Exec=/usr/local/bin/myapp %F
Icon=myapp
Categories=Utility;
Keywords=app;
```

**Icon**: `/usr/share/icons/myapp.png` .

#### MIME Types

**Register MIME** :

```ini
[Desktop Entry]
MimeType=application/x-myformat;
```

**Update Database** :

```bash
update-desktop-database /usr/share/applications
```

#### Service Integration

**Systemd Service** :

```ini
[Unit]
Description=My External Application
After=network.target

[Service]
Type=simple
User=myuser
ExecStart=/opt/myapp/bin/myapp

[Install]
WantedBy=multi-user.target
```

**Enable** :

```bash
sudo systemctl enable myapp.service
```

### Version Management

#### Keep Multiple Versions

**Directory Structure** :

```
/opt/myapp/
├── 1.0/
├── 1.5/
└── 2.0/ -> current
```

**Symbolic Link** :

```bash
ln -s /opt/myapp/2.0 /opt/myapp/current
```

#### Update Script

**Upgrade Script** :

```bash
#!/bin/bash

NEW_VERSION=2.0
cd /opt/myapp

# Download and extract
wget https://example.com/myapp-${NEW_VERSION}.tar.gz
tar -xzf myapp-${NEW_VERSION}.tar.gz

# Test new version
./${NEW_VERSION}/bin/myapp --version

# Update symlink
ln -sf /opt/myapp/${NEW_VERSION} /opt/myapp/current
```

### Sandboxing Non-Arch Software

#### Firejail Integration

**Create Profile** :

```bash
# /etc/firejail/myapp.profile

noprofile
caps.drop all
seccomp
private-tmp
private-dev
read-only /etc
```

**Run Sandboxed** :

```bash
firejail --profile=/etc/firejail/myapp.profile /opt/myapp/bin/myapp
```

### Updates and Maintenance

#### Monitor Updates

**Check Upstream** :

```bash
# Manual check
curl https://example.com/latest-version
```

**Automated Check** :

```bash
#!/bin/bash

CURRENT=$(cat /opt/myapp/VERSION)
LATEST=$(curl -s https://example.com/latest)

if [ "$CURRENT" != "$LATEST" ]; then
    echo "Update available: $LATEST"
fi
```

#### Auto-Update Script

**Systemd Service** :

```ini
[Unit]
Description=Check for myapp updates

[Service]
Type=oneshot
ExecStart=/usr/local/bin/check-myapp-update.sh

[Timer]
OnCalendar=daily
OnBootSec=1h

[Install]
WantedBy=timers.target
```

### Troubleshooting Integration

#### Library Issues

**Missing Library** :

```bash
ldd /opt/myapp/bin/myapp | grep "not found"
```

**Install Library** :

```bash
sudo pacman -S missing-lib
```

#### Permission Issues

**Fix Permissions** :

```bash
sudo chmod +x /opt/myapp/bin/myapp
sudo chown root:root /opt/myapp
```

#### Path Issues

**Find Executable** :

```bash
which myapp
type myapp
```

**Update PATH** :

```bash
export PATH="/opt/myapp/bin:$PATH"
```

### Best Practices

**Organize Installation**: Use `/opt` for third-party .

**Document Setup**: Record installation steps .

**Create Wrapper**: Use scripts for consistency .

**Monitor Updates**: Stay informed of new versions .

**Test Before Deployment**: Verify functionality .

**Maintain Integration**: Keep desktop entry current .

**Security**: Verify sources and checksums .

***

This comprehensive guide on integrating non-Arch software completes the Arch Linux system administration documentation, providing users with diverse methods to install, manage, and maintain software from multiple sources while maintaining system consistency and security.

This concludes the **complete, comprehensive Arch Linux system administration guide** for the Arch Space, covering all essential and advanced topics from foundational concepts through sophisticated integration and management techniques. The guide provides complete coverage for system administrators at all skill levels working with Arch Linux systems.

Sources
[1] Which should I use, x11 or wayland? - openSUSE Forums https://forums.opensuse.org/t/which-should-i-use-x11-or-wayland/166824

