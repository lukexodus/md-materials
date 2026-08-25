## Certificate Management


HTTPS requires valid TLS certificates:

**Certificate types:**

- Domain Validation (DV): Basic identity verification
- Organization Validation (OV): Company verification
- Extended Validation (EV): Rigorous verification [Browser UI indicators vary]

**Certificate acquisition:**

- Let's Encrypt: Free, automated certificates
- Commercial CAs: Paid certificates with support
- Self-signed: Development only (browsers show warnings)

**Certificate renewal:**

- Certificates expire (typically 90 days for Let's Encrypt)
- Automated renewal recommended (certbot, ACME clients)
- Monitor expiration dates to prevent outages

**Example** Let's Encrypt with certbot:

```bash
# Install certbot
apt-get install certbot python3-certbot-nginx

# Obtain and install certificate
certbot --nginx -d example.com -d www.example.com

# Automatic renewal (cron job)
certbot renew --quiet
```

