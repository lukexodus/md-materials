## Web Services on Linux


### Apache HTTP Server Basics

Apache HTTP Server (httpd) is one of the most widely used web servers on Linux systems. It operates as a modular server that can handle multiple concurrent connections through various Multi-Processing Modules (MPMs).

**Key Points:**

- Apache uses configuration files primarily located in `/etc/httpd/` (Red Hat-based) or `/etc/apache2/` (Debian-based)
- The main configuration file is `httpd.conf` or `apache2.conf`
- Apache modules extend functionality and are loaded via `LoadModule` directives
- The server can run in prefork, worker, or event MPM modes

**Basic Installation and Setup:**

```bash
# Red Hat/CentOS/RHEL
sudo yum install httpd
sudo systemctl enable httpd
sudo systemctl start httpd

# Debian/Ubuntu
sudo apt update
sudo apt install apache2
sudo systemctl enable apache2
sudo systemctl start apache2
```

**Essential Configuration Directives:**

- `ServerRoot`: Defines the top-level directory for server files
- `Listen`: Specifies IP addresses and ports for incoming requests
- `DocumentRoot`: Sets the directory containing web content
- `DirectoryIndex`: Defines default files served for directory requests
- `ErrorLog` and `CustomLog`: Configure logging locations and formats

**Module Management:** Apache's modular architecture allows enabling/disabling features:

```bash
# Enable/disable modules (Debian/Ubuntu)
sudo a2enmod rewrite
sudo a2dismod autoindex

# Red Hat systems - edit configuration files directly
LoadModule rewrite_module modules/mod_rewrite.so
```

### Nginx Fundamentals

Nginx is a high-performance web server designed for high concurrency and low resource consumption. It uses an event-driven, asynchronous architecture that handles multiple connections efficiently.

**Key Points:**

- Configuration uses block-based syntax with contexts (main, events, http, server, location)
- Primary configuration file is typically `/etc/nginx/nginx.conf`
- Site configurations often stored in `/etc/nginx/sites-available/` and enabled via symlinks to `/etc/nginx/sites-enabled/`
- Built-in load balancing and reverse proxy capabilities

**Installation and Basic Setup:**

```bash
# Red Hat/CentOS/RHEL
sudo yum install nginx
sudo systemctl enable nginx
sudo systemctl start nginx

# Debian/Ubuntu
sudo apt update
sudo apt install nginx
sudo systemctl enable nginx
sudo systemctl start nginx
```

**Configuration Structure:**

```nginx
# Main context
user nginx;
worker_processes auto;

# Events context
events {
    worker_connections 1024;
}

# HTTP context
http {
    include /etc/nginx/mime.types;
    default_type application/octet-stream;
    
    # Server blocks define virtual hosts
    server {
        listen 80;
        server_name example.com;
        root /var/www/html;
    }
}
```

**Core Directives:**

- `worker_processes`: Number of worker processes (usually set to CPU cores)
- `worker_connections`: Maximum connections per worker
- `server_name`: Defines which requests match this server block
- `location`: Defines how to process requests for specific URIs
- `proxy_pass`: Forwards requests to backend servers

**Location Block Matching:**

```nginx
location / {
    # Matches all requests
}
location /api/ {
    # Matches requests starting with /api/
}
location ~ \.php$ {
    # Regular expression match for PHP files
}
location = /favicon.ico {
    # Exact match for favicon
}
```

### SSL/TLS Configuration

SSL/TLS encryption secures web traffic between clients and servers. Modern implementations use TLS 1.2 and 1.3 protocols with strong cipher suites.

**Key Points:**

- Certificate files typically include a private key, certificate, and certificate chain
- Let's Encrypt provides free SSL certificates with automated renewal
- Strong security requires proper cipher suite selection and protocol configuration
- HTTP Strict Transport Security (HSTS) headers enhance security

**Certificate Acquisition with Let's Encrypt:**

```bash
# Install Certbot
sudo apt install certbot python3-certbot-apache  # For Apache
sudo apt install certbot python3-certbot-nginx   # For Nginx

# Obtain certificate
sudo certbot --apache -d example.com             # Apache
sudo certbot --nginx -d example.com              # Nginx
```

**Apache SSL Configuration:**

```apache
<VirtualHost *:443>
    ServerName example.com
    DocumentRoot /var/www/html
    
    SSLEngine on
    SSLCertificateFile /etc/ssl/certs/example.com.crt
    SSLCertificateKeyFile /etc/ssl/private/example.com.key
    SSLCertificateChainFile /etc/ssl/certs/example.com-chain.crt
    
    # Security headers
    Header always set Strict-Transport-Security "max-age=31536000; includeSubDomains"
    Header always set X-Frame-Options DENY
    Header always set X-Content-Type-Options nosniff
    
    # Strong SSL configuration
    SSLProtocol all -SSLv3 -TLSv1 -TLSv1.1
    SSLCipherSuite ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256
    SSLHonorCipherOrder off
</VirtualHost>
```

**Nginx SSL Configuration:**

```nginx
server {
    listen 443 ssl http2;
    server_name example.com;
    root /var/www/html;
    
    ssl_certificate /etc/ssl/certs/example.com.crt;
    ssl_certificate_key /etc/ssl/private/example.com.key;
    
    # Modern SSL configuration
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256;
    ssl_prefer_server_ciphers off;
    
    # Security headers
    add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;
    add_header X-Frame-Options DENY always;
    add_header X-Content-Type-Options nosniff always;
}
```

**SSL Security Best Practices:**

- Disable weak protocols (SSLv3, TLS 1.0, TLS 1.1)
- Use forward secrecy cipher suites (ECDHE)
- Implement HSTS headers
- Configure OCSP stapling for certificate validation
- Regular certificate renewal and monitoring

### Virtual Hosts

Virtual hosts enable a single web server to serve multiple websites or applications from the same physical server by using different domain names, IP addresses, or ports.

**Key Points:**

- Name-based virtual hosts use the HTTP Host header to determine which site to serve
- IP-based virtual hosts require separate IP addresses for each site
- Port-based virtual hosts use different ports for each site
- Virtual hosts allow resource isolation and independent configuration

**Apache Virtual Hosts:**

Name-based virtual host configuration:

```apache
# /etc/httpd/conf.d/example.com.conf (Red Hat)
# /etc/apache2/sites-available/example.com.conf (Debian)

<VirtualHost *:80>
    ServerName example.com
    ServerAlias www.example.com
    DocumentRoot /var/www/example.com/html
    ErrorLog /var/log/httpd/example.com_error.log
    CustomLog /var/log/httpd/example.com_access.log combined
    
    <Directory "/var/www/example.com/html">
        AllowOverride All
        Require all granted
    </Directory>
</VirtualHost>

<VirtualHost *:80>
    ServerName test.com
    DocumentRoot /var/www/test.com/html
    ErrorLog /var/log/httpd/test.com_error.log
    CustomLog /var/log/httpd/test.com_access.log combined
</VirtualHost>
```

**Enabling Apache Virtual Hosts:**

```bash
# Debian/Ubuntu
sudo a2ensite example.com.conf
sudo systemctl reload apache2

# Red Hat - configuration files in conf.d are automatically loaded
sudo systemctl reload httpd
```

**Nginx Virtual Hosts (Server Blocks):**

```nginx
# /etc/nginx/sites-available/example.com
server {
    listen 80;
    server_name example.com www.example.com;
    root /var/www/example.com/html;
    index index.html index.php;
    
    access_log /var/log/nginx/example.com_access.log;
    error_log /var/log/nginx/example.com_error.log;
    
    location / {
        try_files $uri $uri/ =404;
    }
    
    location ~ \.php$ {
        fastcgi_pass unix:/var/run/php/php7.4-fpm.sock;
        fastcgi_index index.php;
        include fastcgi_params;
    }
}

# /etc/nginx/sites-available/test.com
server {
    listen 80;
    server_name test.com;
    root /var/www/test.com/html;
    index index.html;
    
    access_log /var/log/nginx/test.com_access.log;
    error_log /var/log/nginx/test.com_error.log;
}
```

**Enabling Nginx Server Blocks:**

```bash
# Create symlink to enable site
sudo ln -s /etc/nginx/sites-available/example.com /etc/nginx/sites-enabled/
sudo nginx -t  # Test configuration
sudo systemctl reload nginx
```

**Advanced Virtual Host Features:**

**Directory-based separation:**

```bash
# Create directory structure
sudo mkdir -p /var/www/example.com/{html,logs}
sudo mkdir -p /var/www/test.com/{html,logs}
sudo chown -R www-data:www-data /var/www/  # Debian/Ubuntu
sudo chown -R apache:apache /var/www/      # Red Hat
```

**Subdomain handling:**

```apache
# Apache wildcard subdomain
<VirtualHost *:80>
    ServerName example.com
    ServerAlias *.example.com
    VirtualDocumentRoot /var/www/example.com/%1/html
</VirtualHost>
```

```nginx
# Nginx subdomain handling
server {
    listen 80;
    server_name ~^(?<subdomain>.+)\.example\.com$;
    root /var/www/example.com/$subdomain/html;
}
```

**Load Balancing with Virtual Hosts:**

```nginx
upstream backend {
    server 192.168.1.10:8080;
    server 192.168.1.11:8080;
    server 192.168.1.12:8080;
}

server {
    listen 80;
    server_name api.example.com;
    
    location / {
        proxy_pass http://backend;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
}
```

**Troubleshooting Web Services:**

**Common diagnostic commands:**

```bash
# Check service status
sudo systemctl status apache2  # or httpd
sudo systemctl status nginx

# Test configuration syntax
sudo apache2ctl configtest  # or httpd -t
sudo nginx -t

# View logs
sudo tail -f /var/log/apache2/error.log
sudo tail -f /var/log/nginx/error.log

# Check listening ports
sudo netstat -tlnp | grep :80
sudo ss -tlnp | grep :443
```

**Performance tuning considerations:**

- Configure appropriate worker processes/connections
- Enable compression (gzip/brotli)
- Set proper cache headers
- Optimize SSL session handling
- Monitor resource usage and connection limits

**Security hardening:**

- Remove server version headers
- Disable unnecessary modules
- Implement rate limiting
- Configure proper file permissions
- Regular security updates
- Web Application Firewall (WAF) implementation

---

