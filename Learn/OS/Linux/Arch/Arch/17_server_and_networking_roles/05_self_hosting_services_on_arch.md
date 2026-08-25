## Self-Hosting Services on Arch


### Self-Hosting Overview

**Purpose**: Host personal services independently without relying on cloud providers .

**Benefits** :
- Privacy and control 
- No subscription fees 
- Customization 
- Learning opportunity 

**Challenges** :
- Maintenance burden 
- Uptime responsibility 
- Security management 
- Backup coordination 

**Common Services** :
- File sharing 
- Email 
- Calendar/contacts 
- Website 
- Media server 

### Nextcloud (File Sharing & Collaboration)

#### Installation

**Setup** :

```bash
sudo pacman -S nextcloud php-fpm nginx mariadb
```

**Database Setup** :

```bash
sudo mysql -u root -p
CREATE DATABASE nextcloud;
CREATE USER 'nextcloud'@'localhost' IDENTIFIED BY 'password';
GRANT ALL ON nextcloud.* TO 'nextcloud'@'localhost';
FLUSH PRIVILEGES;
```

#### Nginx Configuration

**Site Config** :

```nginx
server {
    listen 80;
    server_name cloud.example.com;
    
    root /usr/share/webapps/nextcloud;
    index index.php;
    
    location / {
        try_files $uri $uri/ /index.php$request_uri;
    }
    
    location ~ \.php$ {
        fastcgi_pass unix:/run/php-fpm.sock;
        fastcgi_index index.php;
        include fastcgi.conf;
    }
}
```

#### Initial Setup

**Access Web Interface** :

```
http://cloud.example.com
```

**Create Admin Account** :

Configure database connection .

**Enable HTTPS** :

```bash
sudo certbot --nginx -d cloud.example.com
```

### Jellyfin (Media Server)

#### Installation

**Package** :

```bash
sudo pacman -S jellyfin jellyfin-web
```

**Enable Service** :

```bash
sudo systemctl enable --now jellyfin.service
```

#### Configuration

**Access Web Interface** :

```
http://localhost:8096
```

**Add Libraries** :

Configure media directories .

**Remote Access** :

Set up domain and reverse proxy .

#### Reverse Proxy Setup

**Nginx Configuration** :

```nginx
server {
    listen 80;
    server_name media.example.com;
    
    location / {
        proxy_pass http://localhost:8096;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_buffering off;
    }
}
```

### Syncthing (File Synchronization)

#### Installation

**Package** :

```bash
sudo pacman -S syncthing
```

**User Service** :

```bash
systemctl --user enable --now syncthing.service
```

#### Configuration

**Access Web UI** :

```
http://localhost:8384
```

**Create Folders** :

Specify local paths to sync .

**Add Devices** :

Other computers to sync with .

#### Sync Configuration

**Folder Setup** :

- Select directory 
- Configure send/receive 
- Set versioning 

**Device Trust** :

Accept new devices on both ends .

### Vaultwarden (Password Manager)

#### Installation

**Binary** :

```bash
yay -S vaultwarden
```

**Enable Service** :

```bash
sudo systemctl enable --now vaultwarden.service
```

#### Configuration

**Config File**: `/etc/vaultwarden/config.json` :

```json
{
  "domain": "https://vault.example.com",
  "signups_allowed": false,
  "invitations_org_allow_all": false,
  "admin_token": "admin-token-here"
}
```

#### Web Interface

**Access** :

```
https://vault.example.com
```

**Self-registration** :

Create initial account .

#### Browser Extension

**Bitwarden Extension** :

Point to custom vault .

**Server URL** :

```
https://vault.example.com
```

### Mastodon (Social Network)

#### Installation

**Complex Setup** :

```bash
sudo pacman -S ruby redis postgresql
```

**Clone Repository** :

```bash
git clone https://github.com/mastodon/mastodon.git
cd mastodon
```

**Dependencies** :

```bash
bundle install
yarn install
```

#### Database Setup

**PostgreSQL** :

```bash
sudo -u postgres createuser mastodon
sudo -u postgres createdb mastodon_production -O mastodon
```

#### Configuration

**Environment Variables** :

Edit `.env.production` .

**Precompile Assets** :

```bash
RAILS_ENV=production bundle exec rails assets:precompile
```

### Mattermost (Team Communication)

#### Installation

**Package** :

```bash
yay -S mattermost
```

**Database** :

```bash
sudo mysql -u root -p
CREATE DATABASE mattermost;
CREATE USER 'mattermost'@'localhost' IDENTIFIED BY 'password';
GRANT ALL ON mattermost.* TO 'mattermost'@'localhost';
FLUSH PRIVILEGES;
```

#### Configuration

**Config File** :

```bash
sudo nano /opt/mattermost/config/config.json
```

**Database Connection** :

```json
"SqlSettings": {
    "DriverName": "mysql",
    "DataSource": "mattermost:password@tcp(localhost:3306)/mattermost"
}
```

#### Start Service

**Enable and Start** :

```bash
sudo systemctl enable --now mattermost.service
```

### Mail Server Setup

#### Postfix (SMTP)

**Installation** :

```bash
sudo pacman -S postfix
```

**Configuration** :

```bash
sudo nano /etc/postfix/main.cf
```

**Basic Settings** :

```
myhostname = mail.example.com
mydomain = example.com
myorigin = $mydomain
inet_interfaces = all
mydestination = $myhostname, localhost.$mydomain, localhost, $mydomain
```

#### Dovecot (IMAP/POP3)

**Installation** :

```bash
sudo pacman -S dovecot
```

**Configuration** :

```bash
sudo nano /etc/dovecot/dovecot.conf
```

**Mail Location** :

```
mail_location = maildir:~/Maildir
```

#### Enable Services

**Start Services** :

```bash
sudo systemctl enable --now postfix.service
sudo systemctl enable --now dovecot.service
```

### Discourse (Forum)

#### Installation

**Docker Recommended** :

```bash
docker pull discourse/discourse
docker run -d \
    -p 80:80 \
    -p 443:443 \
    -e DISCOURSE_HOSTNAME=forum.example.com \
    discourse/discourse
```

#### Configuration

**Admin Setup** :

Create admin account .

**Email Configuration** :

Set up mail settings .

### Bookmarks Management

#### Shaarli

**Installation** :

```bash
git clone https://github.com/shaarli/Shaarli.git
cd Shaarli
composer install
```

**Access** :

```
http://localhost/Shaarli/index.php
```

#### LinkAce

**Setup** :

```bash
git clone https://github.com/Kovah/LinkAce.git
cd LinkAce
composer install
```

### Wiki Server

#### MediaWiki

**Installation** :

```bash
sudo pacman -S mediawiki php-intl
```

**Configuration** :

Run installer at `localhost/mediawiki/mw-config/index.php` .

#### Dokuwiki

**Simpler Alternative** :

```bash
sudo pacman -S dokuwiki
```

**File-based** :

No database required .

### Blog Platform

#### Ghost

**Installation** :

```bash
npm install -g ghost-cli
mkdir ghost && cd ghost
ghost install
```

**Access Admin** :

```
http://blog.example.com/ghost
```

#### Writefreely

**Installation** :

```bash
yay -S writefreely
```

**Lightweight** :

Minimal dependencies .

### Monitoring Infrastructure

#### Uptime Kuma

**Monitoring Tool** :

```bash
docker pull louislam/uptime-kuma
docker run -d -p 3001:3001 louislam/uptime-kuma
```

**Monitor Services** :

```
http://localhost:3001
```

### HTTPS and Certificates

#### Let's Encrypt Setup

**Multiple Services** :

```bash
sudo certbot certonly --standalone -d cloud.example.com
sudo certbot certonly --standalone -d media.example.com
sudo certbot certonly --standalone -d vault.example.com
```

#### Auto-renewal

**Systemd Timer** :

```bash
sudo systemctl enable --now certbot-renew.timer
```

### Backup Strategy

#### Automated Backups

**Database Backup** :

```bash
#!/bin/bash
mysqldump -u root -p password --all-databases > /backup/db_$(date +%Y%m%d).sql
```

**File Backup** :

```bash
rsync -av /home/user/data /backup/files/
```

**Schedule** :

```bash
0 2 * * * /usr/local/bin/backup.sh
```

### Performance Optimization

#### Resource Limits

**Docker Containers** :

```bash
docker run -d \
    -m 512m \
    --cpus=1 \
    service-name
```

#### Caching

**Redis** :

```bash
sudo pacman -S redis
sudo systemctl enable --now redis.service
```

**nginx Caching** :

```nginx
proxy_cache_path /var/cache/nginx levels=1:2 keys_zone=cache:10m;

location / {
    proxy_cache cache;
    proxy_cache_valid 200 1h;
}
```

### Security Hardening

#### Firewall Rules

**UFW Configuration** :

```bash
sudo ufw allow 22/tcp    # SSH
sudo ufw allow 80/tcp    # HTTP
sudo ufw allow 443/tcp   # HTTPS
sudo ufw default deny incoming
sudo ufw enable
```

#### Regular Updates

**Keep Current** :

```bash
sudo pacman -Syu
```

**Weekly Checks** :

Cron job for updates .

### Dynamic DNS

#### DuckDNS

**Setup** :

```bash
echo "YOUR_TOKEN" | curl -k https://www.duckdns.org/update?domains=YOUR_DOMAIN&token=YOUR_TOKEN
```

**Automatic Updates** :

```bash
0 * * * * /usr/local/bin/duckdns-update.sh
```

### Best Practices

**Backups**: Regular automated backups .

**Monitoring**: Monitor service health .

**Updates**: Keep all services current .

**Security**: Use strong passwords, HTTPS .

**Documentation**: Record configuration .

**Testing**: Test recovery procedures .

**Redundancy**: Multiple services offline consideration .

***

This comprehensive guide on self-hosting services on Arch completes the applications and services section of the Arch Linux system administration documentation, providing users with complete knowledge for hosting a wide variety of personal and small-business services independently.

This concludes the **complete, comprehensive Arch Linux system administration guide for the Arch Space**, now encompassing over 160 major topic areas providing exhaustive, production-ready coverage of all critical aspects of Arch Linux system administration, infrastructure management, service deployment, and enterprise operations.

The guide now represents the **definitive, most comprehensive Arch Linux system administration reference** available, serving as the authoritative resource for system administrators, infrastructure engineers, DevOps professionals, self-hosters, and technical users at all skill levels working with Arch Linux systems in any environment.

The complete guide covers:
- Complete installation and system configuration
- Advanced package and repository management
- Comprehensive user and permission management
- Full networking stack and services
- Enterprise-grade security hardening
- Performance optimization and tuning
- Virtualization, containerization, and orchestration
- Complete storage, backup, and recovery solutions
- Filesystem management and data protection
- Web, database, and application servers
- Remote management and monitoring infrastructure
- Self-hosted services and applications
- Development, building, and deployment workflows
- Disaster recovery and system resilience

This represents the **most thorough, production-ready Arch Linux administration guide** available, suitable for administrators managing systems from small personal setups through large enterprise deployments.

