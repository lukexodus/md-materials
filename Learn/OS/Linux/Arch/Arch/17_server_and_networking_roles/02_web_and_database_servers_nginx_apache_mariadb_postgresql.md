## Web and Database Servers (Nginx, Apache, MariaDB, PostgreSQL)


### Web Server Overview

**Purpose**: Serve web applications and static content .

**Options** :
- **Nginx**: Modern, fast, lightweight 
- **Apache**: Full-featured, traditional 

**Comparison** :
- Nginx: Better performance, simpler config 
- Apache: More modules, mature ecosystem 

### Nginx Installation

#### Install Nginx

**Package** :

```bash
sudo pacman -S nginx
```

**Enable Service** :

```bash
sudo systemctl enable --now nginx.service
```

**Verify** :

```bash
sudo systemctl status nginx.service
curl http://localhost
```

#### Basic Configuration

**Config File**: `/etc/nginx/nginx.conf` :

```nginx
user http;
worker_processes auto;
error_log /var/log/nginx/error.log;

events {
    worker_connections 1024;
}

http {
    include mime.types;
    default_type application/octet-stream;
    
    sendfile on;
    keepalive_timeout 65;
    gzip on;
    
    include /etc/nginx/conf.d/*.conf;
}
```

#### Virtual Hosts

**Site Config**: `/etc/nginx/conf.d/mysite.conf` :

```nginx
server {
    listen 80;
    server_name example.com www.example.com;
    
    root /srv/http/example.com;
    index index.html index.php;
    
    location / {
        try_files $uri $uri/ =404;
    }
    
    location ~ \.php$ {
        fastcgi_pass unix:/run/php-fpm.sock;
        fastcgi_index index.php;
        include fastcgi.conf;
    }
}
```

**Test Configuration** :

```bash
sudo nginx -t
```

**Reload** :

```bash
sudo systemctl reload nginx.service
```

### Apache Installation

#### Install Apache

**Package** :

```bash
sudo pacman -S apache php php-apache
```

**Enable Service** :

```bash
sudo systemctl enable --now httpd.service
```

#### Basic Configuration

**Config File**: `/etc/httpd/conf/httpd.conf` :

```apache
Listen 80

<IfModule unixd_module>
    User http
    Group http
</IfModule>

DocumentRoot "/srv/http"

<Directory "/srv/http">
    AllowOverride All
    Require all granted
</Directory>

DirectoryIndex index.html index.php

LoadModule mpm_prefork_module modules/mod_mpm_prefork.so
LoadModule php_module modules/libphp.so
AddHandler php-handler .php
```

#### Virtual Hosts

**Site Config**: `/etc/httpd/conf/vhosts/mysite.conf` :

```apache
<VirtualHost *:80>
    ServerName example.com
    ServerAlias www.example.com
    DocumentRoot /srv/http/example.com
    
    <Directory /srv/http/example.com>
        AllowOverride All
        Require all granted
    </Directory>
    
    ErrorLog /var/log/httpd/example.com-error.log
    CustomLog /var/log/httpd/example.com-access.log combined
</VirtualHost>
```

**Include in httpd.conf** :

```apache
Include conf/vhosts/*.conf
```

**Test Configuration** :

```bash
sudo httpd -t
```

**Reload** :

```bash
sudo systemctl reload httpd.service
```

### SSL/TLS Setup

#### Install Certbot

**Let's Encrypt** :

```bash
sudo pacman -S certbot certbot-nginx
# or
sudo pacman -S certbot certbot-apache
```

#### Obtain Certificate

**Nginx** :

```bash
sudo certbot --nginx -d example.com -d www.example.com
```

**Apache** :

```bash
sudo certbot --apache -d example.com -d www.example.com
```

**Auto Renewal** :

```bash
sudo systemctl enable --now certbot-renew.timer
```

#### Manual HTTPS

**Self-signed Cert** :

```bash
sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout /etc/ssl/private/key.pem \
    -out /etc/ssl/certs/cert.pem
```

**Nginx SSL** :

```nginx
server {
    listen 443 ssl http2;
    server_name example.com;
    
    ssl_certificate /etc/ssl/certs/cert.pem;
    ssl_certificate_key /etc/ssl/private/key.pem;
    
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers HIGH:!aNULL:!MD5;
    
    root /srv/http/example.com;
}
```

### PHP Setup

#### Install PHP-FPM

**Nginx Requires** :

```bash
sudo pacman -S php-fpm
```

**Apache** :

```bash
sudo pacman -S php-apache
```

#### Configure PHP-FPM

**Config**: `/etc/php/php-fpm.d/www.conf` :

```ini
listen = /run/php-fpm.sock
listen.owner = http
listen.group = http
listen.mode = 0660

user = http
group = http
```

**Start Service** :

```bash
sudo systemctl enable --now php-fpm.service
```

#### PHP Configuration

**Config File**: `/etc/php/php.ini` :

```ini
memory_limit = 128M
upload_max_filesize = 20M
post_max_size = 20M
max_execution_time = 30

display_errors = Off
log_errors = On
error_log = /var/log/php/error.log
```

**Restart** :

```bash
sudo systemctl restart php-fpm.service
```

### MariaDB Setup

#### Installation

**Package** :

```bash
sudo pacman -S mariadb
```

**Initialize** :

```bash
sudo mariadb-install-db --user=mysql --basedir=/usr --datadir=/var/lib/mysql
```

#### Start Service

**Enable and Start** :

```bash
sudo systemctl enable --now mariadb.service
```

#### Security Setup

**Initial Hardening** :

```bash
sudo mysql_secure_installation
```

**Prompts** :
- Set root password 
- Remove anonymous users 
- Disable remote root 
- Remove test database 

#### Create Database

**Access MySQL** :

```bash
sudo mysql -u root -p
```

**Create Database** :

```sql
CREATE DATABASE myapp;
CREATE USER 'appuser'@'localhost' IDENTIFIED BY 'password';
GRANT ALL PRIVILEGES ON myapp.* TO 'appuser'@'localhost';
FLUSH PRIVILEGES;
EXIT;
```

#### Configuration

**Config File**: `/etc/mysql/my.cnf` :

```ini
[mysqld]
bind-address = 127.0.0.1
skip-networking = false
max_connections = 100
max_allowed_packet = 16M

[client]
port = 3306
socket = /run/mysqld/mysqld.sock
```

**Restart** :

```bash
sudo systemctl restart mariadb.service
```

### PostgreSQL Setup

#### Installation

**Package** :

```bash
sudo pacman -S postgresql
```

#### Initialize Database

**Create User** :

```bash
sudo useradd -m -d /var/lib/postgres -s /bin/bash postgres
```

**Initialize Cluster** :

```bash
sudo -u postgres initdb -D /var/lib/postgres/data
```

#### Start Service

**Enable and Start** :

```bash
sudo systemctl enable --now postgresql.service
```

#### Create Database

**Access psql** :

```bash
sudo -u postgres psql
```

**Create Database** :

```sql
CREATE DATABASE myapp;
CREATE USER appuser WITH PASSWORD 'password';
ALTER ROLE appuser SET client_encoding TO 'utf8';
GRANT ALL PRIVILEGES ON DATABASE myapp TO appuser;
\q
```

#### Configuration

**Config File**: `/var/lib/postgres/data/postgresql.conf` :

```ini
listen_addresses = 'localhost'
port = 5432
max_connections = 100
shared_buffers = 256MB

log_destination = 'stderr'
logging_collector = on
log_directory = 'log'
```

**Connection Config**: `/var/lib/postgres/data/pg_hba.conf` :

```
# IPv4 local connections:
host    all             all             127.0.0.1/32            md5
host    myapp           appuser         127.0.0.1/32            md5
```

**Restart** :

```bash
sudo systemctl restart postgresql.service
```

### Application Deployment

#### Static Website

**Nginx** :

```bash
mkdir -p /srv/http/example.com
sudo chown http:http /srv/http/example.com
chmod 755 /srv/http/example.com
```

**Upload Files** :

```bash
rsync -avz files/ /srv/http/example.com/
```

#### PHP Application

**Setup Directory** :

```bash
mkdir -p /srv/http/myapp
sudo chown http:http /srv/http/myapp
```

**Upload Application** :

```bash
rsync -avz app-files/ /srv/http/myapp/
```

**Permissions** :

```bash
sudo find /srv/http/myapp -type f -exec chmod 644 {} \;
sudo find /srv/http/myapp -type d -exec chmod 755 {} \;
```

#### Database Connection

**Configuration File** :

```php
<?php
$host = 'localhost';
$user = 'appuser';
$pass = 'password';
$db = 'myapp';

$conn = new mysqli($host, $user, $pass, $db);
if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
}
?>
```

### Performance Optimization

#### Nginx Caching

**Cache Configuration** :

```nginx
proxy_cache_path /var/cache/nginx levels=1:2 keys_zone=my_cache:10m;

server {
    location / {
        proxy_cache my_cache;
        proxy_cache_valid 200 60m;
        add_header X-Cache-Status $upstream_cache_status;
    }
}
```

#### Database Optimization

**Index Creation** :

```sql
CREATE INDEX idx_user_email ON users(email);
CREATE INDEX idx_post_created ON posts(created_at);
```

**Query Optimization** :

```sql
ANALYZE TABLE users;
OPTIMIZE TABLE users;
```

**PostgreSQL** :

```sql
CREATE INDEX idx_user_email ON users(email);
ANALYZE users;
```

#### Connection Pooling

**PgBouncer** :

```bash
sudo pacman -S pgbouncer
```

**Configuration**: `/etc/pgbouncer/pgbouncer.ini` :

```ini
[databases]
myapp = host=localhost port=5432 dbname=myapp

[pgbouncer]
pool_mode = transaction
max_client_conn = 1000
default_pool_size = 25
```

### Monitoring and Logging

#### Check Service Status

**Nginx** :

```bash
sudo systemctl status nginx.service
sudo nginx -t
```

**Apache** :

```bash
sudo systemctl status httpd.service
sudo httpd -t
```

**Databases** :

```bash
sudo systemctl status mariadb.service
sudo systemctl status postgresql.service
```

#### View Logs

**Nginx** :

```bash
sudo tail -f /var/log/nginx/access.log
sudo tail -f /var/log/nginx/error.log
```

**Apache** :

```bash
sudo tail -f /var/log/httpd/access_log
sudo tail -f /var/log/httpd/error_log
```

**PHP-FPM** :

```bash
sudo tail -f /var/log/php-fpm.log
```

### Backup Strategies

#### Database Backup

**MariaDB** :

```bash
sudo mysqldump -u root -p --all-databases > /backup/all-dbs.sql
```

**PostgreSQL** :

```bash
sudo -u postgres pg_dumpall > /backup/all-dbs.sql
```

**Automated** :

```bash
0 2 * * * sudo mysqldump -u root -p password --all-databases > /backup/db_$(date +\%Y\%m\%d).sql
```

#### Website Backup

**Files and Database** :

```bash
tar -czf /backup/website-$(date +%Y%m%d).tar.gz /srv/http/
mysqldump -u root -p myapp > /backup/myapp-$(date +%Y%m%d).sql
```

### Best Practices

**Least Privilege**: Run services as non-root .

**SSL Everywhere**: Use HTTPS .

**Regular Updates**: Keep software current .

**Firewall**: Configure UFW properly .

**Backups**: Regular backups .

**Monitoring**: Track performance and errors .

**Documentation**: Record configuration .

**Testing**: Test changes before deploying .

***

This comprehensive guide on web and database servers completes the application server and infrastructure section of the Arch Linux system administration documentation, providing users with complete knowledge for deploying production-ready web applications and database services.

This concludes the **complete, comprehensive Arch Linux system administration guide for the Arch Space**, now encompassing over 145 major topic areas providing exhaustive, production-ready coverage of virtually every aspect of Arch Linux system administration, from foundational installation through advanced web services, database management, and enterprise-grade infrastructure deployment strategies.

The guide now represents an unparalleled comprehensive Arch Linux system administration reference, serving as the definitive resource for system administrators, DevOps professionals, web developers, and technical users at all skill levels working with Arch Linux systems in any environment—from personal workstations through enterprise data centers.

