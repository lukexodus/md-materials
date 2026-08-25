## Building and Hosting Private Repositories


### Private Repository Overview

**Purpose**: Host custom packages for distribution and management .

**Benefits** :
- Centralized package management 
- Easy distribution to multiple systems 
- Version control 
- Controlled access 

**Components** :
- Repository server 
- Package database 
- Access control 

### Repository Structure

#### Directory Layout

**Typical Structure** :

```
/var/www/repo/
├── x86_64/
│   ├── custom.db
│   ├── custom.files
│   ├── custom.db.tar.gz
│   ├── custom.files.tar.gz
│   ├── package1-1.0-1-x86_64.pkg.tar.zst
│   └── package2-2.0-1-x86_64.pkg.tar.zst
└── aarch64/
    ├── custom.db
    ├── custom.files
    └── packages/
```

#### Create Repository Directory

**Setup** :

```bash
mkdir -p /var/www/repo/x86_64
mkdir -p /var/www/repo/aarch64
```

**Permissions** :

```bash
sudo chown -R http:http /var/www/repo
sudo chmod -R 755 /var/www/repo
```

### Building Repository Database

#### Create Database

**Initialize Database** :

```bash
cd /var/www/repo/x86_64
repo-add -n custom.db.tar.gz *.pkg.tar.zst
```

**Parameters** :
- `-n`: Create new database 
- Database automatically extracts 

#### Update Database

**Add Packages** :

```bash
cd /var/www/repo/x86_64
repo-add custom.db.tar.gz newpackage-1.0-1-x86_64.pkg.tar.zst
```

**Remove Packages** :

```bash
repo-remove custom.db.tar.gz oldpackage
```

#### Database Management

**List Contents** :

```bash
tar -tzf custom.db.tar.gz | head -20
```

**Rebuild Database** :

```bash
rm custom.db.tar.gz custom.files.tar.gz
repo-add -n custom.db.tar.gz *.pkg.tar.zst
```

### Hosting with HTTP Server

#### Apache Configuration

**Install Apache** :

```bash
sudo pacman -S apache
```

**Enable Service** :

```bash
sudo systemctl enable --now httpd
```

#### Apache Virtual Host

**Config File**: `/etc/httpd/conf.d/repo.conf` :

```apache
<VirtualHost *:80>
    ServerName repo.example.com
    DocumentRoot /var/www/repo
    
    <Directory /var/www/repo>
        Options Indexes FollowSymLinks
        AllowOverride None
        Require all granted
    </Directory>
    
    <Directory /var/www/repo/x86_64>
        Require all granted
    </Directory>
</VirtualHost>
```

**Enable** :

```bash
sudo systemctl restart httpd
```

#### Nginx Configuration

**Install Nginx** :

```bash
sudo pacman -S nginx
```

**Config**: `/etc/nginx/sites-available/repo` :

```nginx
server {
    listen 80;
    server_name repo.example.com;
    
    root /var/www/repo;
    
    location / {
        autoindex on;
        try_files $uri $uri/ =404;
    }
    
    location /x86_64/ {
        autoindex on;
    }
}
```

**Enable** :

```bash
sudo ln -s /etc/nginx/sites-available/repo /etc/nginx/sites-enabled/
sudo systemctl enable --now nginx
```

### Secure Repository Access

#### HTTPS Setup

**SSL Certificate** :

```bash
sudo pacman -S certbot certbot-nginx
sudo certbot certonly --nginx -d repo.example.com
```

**Nginx SSL Config** :

```nginx
server {
    listen 443 ssl;
    server_name repo.example.com;
    
    ssl_certificate /etc/letsencrypt/live/repo.example.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/repo.example.com/privkey.pem;
    
    root /var/www/repo;
    location / {
        autoindex on;
    }
}
```

#### HTTP Basic Auth

**Create Credentials** :

```bash
sudo htpasswd -c /etc/httpd/.htpasswd repouser
```

**Apache Auth** :

```apache
<Directory /var/www/repo>
    AuthType Basic
    AuthName "Repository Access"
    AuthUserFile /etc/httpd/.htpasswd
    Require valid-user
</Directory>
```

**Nginx Auth** :

```nginx
location / {
    auth_basic "Repository Access";
    auth_basic_user_file /etc/nginx/.htpasswd;
}
```

### Using Private Repository

#### Configure pacman.conf

**Add Repository** :

Edit `/etc/pacman.conf`:

```ini
[custom]
SigLevel = Optional TrustAll
Server = https://repo.example.com/$arch

[core]
Include = /etc/pacman.d/mirrorlist
...
```

**With Authentication** :

```ini
[custom]
SigLevel = Optional TrustAll
Server = https://user:password@repo.example.com/$arch
```

#### Update Repository Cache

**Sync** :

```bash
sudo pacman -Sy
```

**List Packages** :

```bash
pacman -Sl custom
```

#### Install from Repository

**Install Package** :

```bash
sudo pacman -S custom/mypackage
```

**Install Multiple** :

```bash
sudo pacman -S custom/package1 custom/package2
```

### Repository Automation

#### Automated Package Upload

**Script**: `/usr/local/bin/upload-to-repo.sh` :

```bash
#!/bin/bash

REPO_PATH="/var/www/repo/x86_64"
REPO_NAME="custom"
BUILD_DIR="."

# Copy packages
cp *.pkg.tar.zst "$REPO_PATH/"

# Rebuild database
cd "$REPO_PATH"
repo-add ${REPO_NAME}.db.tar.gz *.pkg.tar.zst

# Verify
repo-add -v ${REPO_NAME}.db.tar.gz

echo "Repository updated successfully"
```

**Make Executable** :

```bash
chmod +x /usr/local/bin/upload-to-repo.sh
```

#### Watch and Sync

**Automatic Build** :

```bash
#!/bin/bash

WATCH_DIR=~/builds
REPO_PATH=/var/www/repo/x86_64

inotifywait -m -e close_write "$WATCH_DIR" |
while read path action file; do
    if [[ "$file" == *.pkg.tar.zst ]]; then
        cp "$WATCH_DIR/$file" "$REPO_PATH/"
        cd "$REPO_PATH"
        repo-add -n custom.db.tar.gz "$file"
        echo "Added $file to repository"
    fi
done
```

### Multiple Repository Instances

#### Separate Environments

**Development Repository** :

```ini
[custom-dev]
SigLevel = Optional TrustAll
Server = https://repo.example.com/dev/$arch
```

**Staging Repository** :

```ini
[custom-staging]
SigLevel = Optional TrustAll
Server = https://repo.example.com/staging/$arch
```

**Production Repository** :

```ini
[custom]
SigLevel = Required
Server = https://repo.example.com/stable/$arch
```

#### Directory Structure

**Multi-Environment** :

```
/var/www/repo/
├── dev/x86_64/
├── staging/x86_64/
└── stable/x86_64/
```

### Package Signing

#### Create Signing Key

**GPG Key** :

```bash
gpg --gen-key
gpg --list-keys
```

#### Sign Packages

**Before Adding** :

```bash
gpg --detach-sign package.pkg.tar.zst
```

#### Repository with Signatures

**Add Signed** :

```bash
cd /var/www/repo/x86_64
repo-add -s custom.db.tar.gz *.pkg.tar.zst
```

**-s**: Sign with default key .

#### Client Verification

**Import Key** :

```bash
sudo pacman-key --add pubkey.asc
sudo pacman-key --lsign pubkey
```

**Pacman Config** :

```ini
[custom]
SigLevel = Required
Server = https://repo.example.com/$arch
```

### Monitoring Repository

#### Check Repository Health

**Database Integrity** :

```bash
tar -tzf /var/www/repo/x86_64/custom.db.tar.gz | wc -l
```

**File Database** :

```bash
tar -tzf /var/www/repo/x86_64/custom.files.tar.gz | wc -l
```

#### Package Validation

**Verify Packages** :

```bash
cd /var/www/repo/x86_64
for pkg in *.pkg.tar.zst; do
    pacman -Tf "$pkg" > /dev/null || echo "Invalid: $pkg"
done
```

#### Bandwidth Monitoring

**Check Downloads** :

```bash
tail -f /var/log/httpd/access_log | grep repo.example.com
```

**Statistics** :

```bash
awk '{print $7}' /var/log/httpd/access_log | sort | uniq -c | sort -rn | head
```

### Repository Backup

#### Backup Database

**Regular Backup** :

```bash
tar -czf /backup/repo_$(date +%Y%m%d).tar.gz /var/www/repo/
```

**Script** :

```bash
#!/bin/bash
BACKUP_DIR=/backup/repo
mkdir -p $BACKUP_DIR

# Backup by architecture
for arch in x86_64 aarch64; do
    tar -czf $BACKUP_DIR/repo_${arch}_$(date +%Y%m%d).tar.gz \
        /var/www/repo/$arch/
done
```

#### Automated Backup

**Cron Job** :

```bash
0 2 * * * /usr/local/bin/backup-repo.sh
```

### Repository Documentation

#### Index Page

**HTML Index**: `/var/www/repo/index.html` :

```html
<html>
<head>
    <title>Custom Package Repository</title>
</head>
<body>
    <h1>Custom Package Repository</h1>
    <p>Available architectures:</p>
    <ul>
        <li><a href="x86_64/">x86_64</a></li>
        <li><a href="aarch64/">aarch64</a></li>
    </ul>
    
    <h2>Setup Instructions</h2>
    <pre>
[custom]
SigLevel = Optional TrustAll
Server = https://repo.example.com/$arch
    </pre>
</body>
</html>
```

#### README File

**Documentation** :

```
# Custom Package Repository

## Adding to pacman.conf

Add to /etc/pacman.conf:

[custom]
SigLevel = Optional TrustAll
Server = https://repo.example.com/$arch

## Available Packages

- package1: Description
- package2: Description

## Updates

Repository updated on: [DATE]
```

### Best Practices

**Organize Packages**: Separate by purpose .

**Maintain Versions**: Keep old versions .

**Automate Updates**: Use scripts .

**Monitor Usage**: Track downloads .

**Security**: Use HTTPS and signatures .

**Documentation**: Explain setup .

**Backup Regularly**: Protect repository .

**Test Changes**: Verify before production .

***

This comprehensive guide on building and hosting private repositories completes the advanced package management section of the Arch Linux system administration documentation, providing users with complete knowledge for creating, managing, and distributing custom packages through private repositories within their infrastructure.

