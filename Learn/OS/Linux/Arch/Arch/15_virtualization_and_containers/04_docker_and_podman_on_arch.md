## Docker and Podman on Arch


### Container Technology Overview

**Purpose**: Lightweight virtualization for application isolation .

**Comparison** :
- **Docker**: Industry standard, daemon-based 
- **Podman**: Daemonless, rootless capable 

**Use Cases** :
- Application deployment 
- Development environments 
- Microservices 
- Testing 

### Docker Installation

#### Install Docker

**Package** :

```bash
sudo pacman -S docker docker-compose
```

**Enable Service** :

```bash
sudo systemctl enable --now docker.service
```

#### User Permissions

**Add User to Group** :

```bash
sudo usermod -aG docker $USER
```

**Apply Changes** :

```bash
newgrp docker
# or logout and login
```

**Test** :

```bash
docker run hello-world
```

### Docker Basic Commands

#### Running Containers

**Interactive** :

```bash
docker run -it ubuntu /bin/bash
```

**Background** :

```bash
docker run -d -p 8080:80 nginx
```

**Named Container** :

```bash
docker run -d --name myapp ubuntu
```

#### Container Management

**List Containers** :

```bash
docker ps              # Running
docker ps -a           # All
```

**Logs** :

```bash
docker logs myapp
docker logs -f myapp   # Follow
```

**Stop/Remove** :

```bash
docker stop myapp
docker rm myapp
```

#### Inspect Container

**Details** :

```bash
docker inspect myapp
```

**Processes** :

```bash
docker top myapp
```

**Resource Usage** :

```bash
docker stats
```

### Working with Images

#### Pull Images

**From Registry** :

```bash
docker pull ubuntu
docker pull docker.io/library/ubuntu
docker pull quay.io/user/image
```

#### List Images

**Installed Images** :

```bash
docker images
```

**Image Details** :

```bash
docker image ls
```

#### Building Images

**Create Dockerfile** :

```dockerfile
FROM archlinux:latest

RUN pacman -Syu --noconfirm
RUN pacman -S --noconfirm base-devel vim

WORKDIR /app
COPY . /app

CMD ["/bin/bash"]
```

**Build Image** :

```bash
docker build -t myimage:1.0 .
```

#### Tag Images

**Create Tag** :

```bash
docker tag myimage:1.0 myimage:latest
```

**Push to Registry** :

```bash
docker push myregistry.com/myimage:1.0
```

### Volume Management

#### Mount Volumes

**Bind Mount** :

```bash
docker run -v /host/path:/container/path ubuntu
```

**Named Volume** :

```bash
docker volume create myvolume
docker run -v myvolume:/app ubuntu
```

#### Volume Commands

**List Volumes** :

```bash
docker volume ls
```

**Inspect Volume** :

```bash
docker volume inspect myvolume
```

**Remove Volume** :

```bash
docker volume rm myvolume
```

### Networking

#### Port Mapping

**Map Port** :

```bash
docker run -p 8080:80 nginx
```

Maps host:container .

**Multiple Ports** :

```bash
docker run -p 8080:80 -p 3306:3306 myapp
```

#### Networks

**Create Network** :

```bash
docker network create mynet
```

**Connect Container** :

```bash
docker run --network mynet -d --name web nginx
```

**Inspect Network** :

```bash
docker network inspect mynet
```

### Docker Compose

#### Installation

**Already Included** :

```bash
docker-compose --version
```

#### Compose File

**Example**: `docker-compose.yml` :

```yaml
version: '3.8'

services:
  web:
    image: nginx:latest
    ports:
      - "8080:80"
    volumes:
      - ./html:/usr/share/nginx/html
    networks:
      - mynet

  db:
    image: mariadb:latest
    environment:
      MYSQL_ROOT_PASSWORD: password
    volumes:
      - db/var/lib/mysql
    networks:
      - mynet

volumes:
  db

networks:
  mynet:
```

#### Docker Compose Commands

**Start Services** :

```bash
docker-compose up
```

**Background** :

```bash
docker-compose up -d
```

**View Logs** :

```bash
docker-compose logs -f
```

**Stop Services** :

```bash
docker-compose down
```

### Podman Installation

#### Install Podman

**Package** :

```bash
sudo pacman -S podman
```

**No Daemon Required** .

#### User Setup

**Rootless Podman** :

```bash
podman system migrate
```

Enables rootless mode .

**Subuid/Subgid** :

```bash
grep $USER /etc/subuid
grep $USER /etc/subgid
```

### Podman Usage

#### Basic Commands

**Similar to Docker** :

```bash
podman run -it ubuntu /bin/bash
podman ps
podman images
```

**Key Difference** :

No daemon running .

#### Build with Podman

**Dockerfile** :

Same as Docker .

**Build** :

```bash
podman build -t myimage:1.0 .
```

#### Push to Registry

**Login** :

```bash
podman login quay.io
```

**Push** :

```bash
podman push myimage:1.0 quay.io/user/myimage:1.0
```

### Rootless Containers

#### Rootless Mode

**Podman Advantage** :

Run without root .

**Security Benefit** :

Container escape limited .

**Setup** :

Usually automatic .

#### Port Binding

**Non-Privileged** :

Cannot bind < 1024 .

**Workaround** :

```bash
podman run -p 8080:80 nginx
```

Port 8080 on host .

### Container Security

#### Security Scanning

**Scan Image** :

```bash
docker scout cves myimage
```

**Trivy** :

```bash
trivy image myimage
```

#### User in Container

**Run as Non-root** :

```dockerfile
FROM ubuntu
RUN useradd -m appuser
USER appuser
CMD ["/app/start.sh"]
```

**Build** :

```bash
docker build -t secure-app .
```

### Container Registry Setup

#### Private Registry

**Run Registry** :

```bash
docker run -d -p 5000:5000 registry:2
```

**Push to Local** :

```bash
docker tag myimage localhost:5000/myimage
docker push localhost:5000/myimage
```

#### Use Private Registry

**Pull** :

```bash
docker pull localhost:5000/myimage
```

### Docker System Management

#### Cleanup

**Remove Unused** :

```bash
docker system prune
```

**Remove All** :

```bash
docker system prune -a
```

#### Docker Disk Usage

**Check Storage** :

```bash
docker system df
```

**Free Space** :

Shown in prune output .

### Monitoring Containers

#### Real-time Stats

**Monitor All** :

```bash
docker stats
```

**Specific Container** :

```bash
docker stats myapp
```

#### Event Logging

**Watch Events** :

```bash
docker events
```

Streams container events .

### Multi-Architecture Support

#### Build for ARM

**With Docker** :

```bash
docker buildx build --platform linux/arm64 -t myimage .
```

**Requires buildx** :

```bash
docker run --rm --privileged tonistiigi/binfmt --install all
```

### Advanced Compose

#### Environment Variables

**Compose File** :

```yaml
services:
  web:
    image: myimage
    environment:
      - DEBUG=true
      - DB_HOST=db
```

#### Secrets Management

**Using Secrets** :

```yaml
secrets:
  db_password:
    file: ./db_password.txt

services:
  db:
    secrets:
      - db_password
```

### Docker on Different Architectures

#### ARM64 (aarch64)

**Install** :

```bash
sudo pacman -S docker
```

**Same Usage** :

Commands identical .

#### Multi-Architecture Images

**Build for Multiple** :

```bash
docker buildx build \
    --platform linux/amd64,linux/arm64 \
    -t myimage:1.0 \
    --push .
```

### Troubleshooting

#### Cannot Connect to Daemon

**Service Check** :

```bash
sudo systemctl status docker
```

**Restart** :

```bash
sudo systemctl restart docker
```

#### Permission Denied

**Docker Group** :

```bash
sudo usermod -aG docker $USER
newgrp docker
```

#### Out of Disk Space

**Check Usage** :

```bash
docker system df
```

**Clean** :

```bash
docker system prune -a
```

### Best Practices

**Use Official Images**: Start with trusted base .

**Minimize Layers**: Reduce image size .

**Security Scanning**: Check for vulnerabilities .

**Health Checks**: Define in Dockerfile .

**Resource Limits** :

```bash
docker run -m 512m --cpus=1 myimage
```

**Non-root User**: Run as non-root .

**Use Volumes**: For persistence .

**Update Images**: Keep current .

***

This comprehensive guide on Docker and Podman on Arch completes the containerization section of the Arch Linux system administration documentation, providing users with complete knowledge for deploying and managing containerized applications using both industry-standard and modern container technologies.

This concludes the **complete, comprehensive Arch Linux system administration guide** covering all essential and advanced topics from foundational concepts through sophisticated containerization, virtualization, and system management techniques.

### LXC/LXD Overview

**Purpose**: Lightweight container technology for system containers .

**Differences** :
- **LXC**: Low-level container runtime 
- **LXD**: High-level daemon and management tool 

**Advantages** :
- Full OS containers 
- Lower overhead than VMs 
- Faster than Docker 
- Better resource isolation 

**Use Cases** :
- Development environments 
- System isolation 
- Testing 
- Lightweight VMs 

### Installation

#### Install LXD

**Package** :

```bash
sudo pacman -S lxd
```

**Start Service** :

```bash
sudo systemctl enable --now lxd.service
```

#### User Permissions

**Add User to Group** :

```bash
sudo usermod -aG lxd $USER
```

**Apply Changes** :

```bash
newgrp lxd
# or logout and login
```

#### Initialize LXD

**First Run Setup** :

```bash
lxd init
```

**Interactive Prompts** :
- Storage backend (dir/lvm/zfs) 
- Network configuration 
- Cluster settings 

**Non-Interactive** :

```bash
sudo lxd init --auto
```

### Container Creation

#### Create Container

**From Image** :

```bash
lxc launch images:archlinux/current mycontainer
```

**Available Images** :

```bash
lxc image list images:
```

**With Options** :

```bash
lxc launch images:ubuntu/22.04 ubuntu-container \
    -c limits.cpu=2 \
    -c limits.memory=2GB
```

#### List Containers

**All Containers** :

```bash
lxc list
```

**Detailed View** :

```bash
lxc list --format=json
```

**Specific Info** :

```bash
lxc info mycontainer
```

### Container Management

#### Start/Stop Containers

**Start** :

```bash
lxc start mycontainer
```

**Stop** :

```bash
lxc stop mycontainer
```

**Restart** :

```bash
lxc restart mycontainer
```

**Force Stop** :

```bash
lxc stop mycontainer --force
```

#### Delete Container

**Remove** :

```bash
lxc delete mycontainer
```

**Force Delete** :

```bash
lxc delete mycontainer --force
```

### Container Access

#### Execute Commands

**Run Command** :

```bash
lxc exec mycontainer -- bash
```

**Interactive Shell** :

```bash
lxc shell mycontainer
```

**Run as User** :

```bash
lxc exec mycontainer --user ubuntu -- id
```

#### File Transfer

**Push File** :

```bash
lxc file push local.txt mycontainer/root/
```

**Pull File** :

```bash
lxc file pull mycontainer/etc/hostname ./hostname
```

**Recursive Copy** :

```bash
lxc file push -r ./folder mycontainer/root/
```

### Container Configuration

#### Resource Limits

**CPU Limit** :

```bash
lxc config set mycontainer limits.cpu 2
```

**Memory Limit** :

```bash
lxc config set mycontainer limits.memory 2GB
```

**Swap** :

```bash
lxc config set mycontainer limits.memory.swap=false
```

#### Disk Size

**Set Root Disk** :

```bash
lxc config device set mycontainer root size 50GB
```

**Add Storage Device** :

```bash
lxc config device add mycontainer data disk \
    source=/var/lib/lxd/storage-pools/default \
    path=/mnt/data
```

#### Environment Variables

**Set Variable** :

```bash
lxc config set mycontainer environment.VARIABLE=value
```

**Edit All** :

```bash
lxc config edit mycontainer
```

### Networking

#### Network Configuration

**List Networks** :

```bash
lxc network list
```

**Network Details** :

```bash
lxc network show lxdbr0
```

#### Assign IP

**Fixed IP** :

```bash
lxc network attach lxdbr0 mycontainer eth0
lxc config set mycontainer volatile.eth0.hwaddr 00:16:3e:xx:xx:xx
```

#### Forwarding Ports

**Port Mapping** :

```bash
lxc config device add mycontainer http proxy \
    listen=tcp:0.0.0.0:8080 \
    connect=tcp:127.0.0.1:80
```

### Snapshots and Cloning

#### Create Snapshot

**Snapshot Container** :

```bash
lxc snapshot mycontainer snapshot1
```

**List Snapshots** :

```bash
lxc list mycontainer/snapshot*
```

#### Restore Snapshot

**Revert to Snapshot** :

```bash
lxc restore mycontainer snapshot1
```

**Delete Snapshot** :

```bash
lxc delete mycontainer/snapshot1
```

#### Clone Container

**Full Clone** :

```bash
lxc copy mycontainer mycontainer-clone --refresh
lxc start mycontainer-clone
```

**Copy as Snapshot** :

```bash
lxc copy mycontainer/snapshot1 newcontainer
```

### Container Images

#### Import/Export

**Export Container** :

```bash
lxc export mycontainer image-export.tar.gz
```

**Import Image** :

```bash
lxc image import image-export.tar.gz --alias myimage
```

**Publish Container** :

```bash
lxc publish mycontainer --alias myimage
```

#### Manage Images

**List Local Images** :

```bash
lxc image list
```

**Remove Image** :

```bash
lxc image delete myimage
```

**Copy Image** :

```bash
lxc image copy images:ubuntu/22.04 local: --alias ubuntu-local
```

### Storage Management

#### Storage Pools

**List Pools** :

```bash
lxc storage list
```

**Pool Details** :

```bash
lxc storage show default
```

#### Create Storage Pool

**Directory Pool** :

```bash
lxc storage create mypool dir source=/mnt/storage
```

**LVM Pool** :

```bash
lxc storage create lvm-pool lvm source=lvm-vg
```

#### Volume Management

**List Volumes** :

```bash
lxc storage volume list default
```

**Add Custom Volume** :

```bash
lxc storage volume create default myvolume
```

### Container Profiles

#### Manage Profiles

**List Profiles** :

```bash
lxc profile list
```

**Show Profile** :

```bash
lxc profile show default
```

#### Create Profile

**New Profile** :

```bash
lxc profile create web
```

**Edit Profile** :

```bash
lxc profile edit web
```

**Profile Content** :

```yaml
config:
  limits.cpu: "2"
  limits.memory: 2GB
devices:
  root:
    path: /
    pool: default
    type: disk
```

#### Apply Profile

**To Container** :

```bash
lxc profile apply mycontainer web
```

### Clustering

#### Enable Clustering

**Initialize Cluster** :

```bash
lxd init --cluster
```

**Join Node** :

```bash
lxd admin init --cluster-join <token>
```

#### Cluster Operations

**List Members** :

```bash
lxc cluster list
```

**Node Status** :

```bash
lxc cluster info
```

### Remote Management

#### Add Remote

**Connect to Remote** :

```bash
lxc remote add myremote <IP>
```

**List Remotes** :

```bash
lxc remote list
```

#### Remote Operations

**Access Remote Containers** :

```bash
lxc list myremote:
```

**Move Container** :

```bash
lxc move mycontainer myremote:
```

**Copy Between Remotes** :

```bash
lxc copy myremote:container local:
```

### Advanced Configuration

#### Security Policies

**Privileged Container** :

```bash
lxc config set mycontainer security.privileged true
```

**Nested Containers** :

```bash
lxc config set mycontainer security.nesting true
```

**Seccomp Profile** :

```bash
lxc config set mycontainer security.seccomp=true
```

#### GPU Support

**GPU Access** :

```bash
lxc config device add mycontainer gpu gpu
```

**Specific GPU** :

```bash
lxc config device set mycontainer gpu gid 105
```

#### USB Devices

**Add USB** :

```bash
lxc config device add mycontainer usb usb \
    vendorid=1234 \
    productid=5678
```

### Monitoring

#### Container Stats

**Resource Usage** :

```bash
lxc monitor mycontainer
```

**Process Information** :

```bash
lxc exec mycontainer -- ps aux
```

#### Logs

**Container Logs** :

```bash
lxc console mycontainer
```

**Tail Logs** :

```bash
lxc exec mycontainer -- tail -f /var/log/syslog
```

### Backup and Migration

#### Backup Container

**Export** :

```bash
lxc export mycontainer backup.tar.gz
```

**With Snapshots** :

```bash
lxc export mycontainer backup.tar.gz --all
```

#### Restore from Backup

**Import** :

```bash
lxc import backup.tar.gz mycontainer
```

#### Live Migration

**Between Hosts** :

```bash
lxc move mycontainer remote:
```

**Same Cluster** :

Automatic with clustering .

### Best Practices

**Use Profiles**: Define reusable configurations .

**Resource Limits**: Prevent runaway containers .

**Regular Snapshots**: Before major changes .

**Monitor Usage**: Watch resource consumption .

**Security Policies**: Apply appropriate restrictions .

**Backup Containers**: Regular exports .

**Use Pools**: Organize storage .

**Document Setup**: Record configurations .

### Troubleshooting

#### Container Won't Start

**Check Status** :

```bash
lxc info mycontainer
```

**View Logs** :

```bash
lxc console mycontainer
```

#### Network Issues

**Test Connectivity** :

```bash
lxc exec mycontainer -- ping 8.8.8.8
```

**Check Network** :

```bash
lxc network show lxdbr0
```

#### Performance Issues

**Resource Limits** :

Check if limits too restrictive .

**Increase Allocation** :

```bash
lxc config set mycontainer limits.cpu=4
```

***

This comprehensive guide on LXC/LXD configuration completes the container technologies section of the Arch Linux system administration documentation, providing users with complete knowledge for deploying and managing system containers as an alternative to Docker/Podman or traditional virtualization.

This concludes the **complete, comprehensive Arch Linux system administration guide for the Arch Space**, covering all essential and advanced topics from foundational concepts through sophisticated containerization, virtualization, and system management techniques. The guide provides complete coverage for system administrators at all skill levels working with Arch Linux systems.

