# OpenSSL on Linux/Arch: Comprehensive Guide

## Installation

**Arch Linux**

```bash
# Usually pre-installed; if not:
sudo pacman -S openssl

# Verify version
openssl version -a
```

**Check available commands**

```bash
openssl help
openssl list -commands
openssl list -cipher-algorithms
openssl list -digest-algorithms
```

---

## Key Concepts

|Term|Meaning|
|---|---|
|**PEM**|Base64-encoded text format (`.pem`, `.crt`, `.key`)|
|**DER**|Binary format (`.der`, `.cer`)|
|**CSR**|Certificate Signing Request|
|**CA**|Certificate Authority|
|**x509**|Standard certificate format|
|**PKCS#12**|Bundled cert+key format (`.p12`, `.pfx`)|

---

## Generating Keys

**RSA private key**

```bash
# 2048-bit (minimum acceptable)
openssl genrsa -out private.key 2048

# 4096-bit (stronger)
openssl genrsa -out private.key 4096

# Encrypted with passphrase (AES-256)
openssl genrsa -aes256 -out private.key 4096
```

**EC (Elliptic Curve) key — generally preferred for new usage**

```bash
# List available curves
openssl ecparam -list_curves

# Generate using prime256v1
openssl ecparam -name prime256v1 -genkey -noout -out ec.key

# Generate using secp384r1
openssl ecparam -name secp384r1 -genkey -noout -out ec.key
```

**Extract public key from private key**

```bash
openssl rsa -in private.key -pubout -out public.key

# For EC keys
openssl ec -in ec.key -pubout -out ec_public.key
```

---

## Certificate Signing Requests (CSR)

**Generate CSR + new key in one command**

```bash
openssl req -new -newkey rsa:4096 -nodes \
  -keyout private.key \
  -out request.csr
```

**Generate CSR from existing key**

```bash
openssl req -new -key private.key -out request.csr
```

**Non-interactive CSR with subject fields**

```bash
openssl req -new -key private.key -out request.csr \
  -subj "/C=PH/ST=Metro Manila/L=Manila/O=MyOrg/CN=example.com"
```

**Inspect a CSR**

```bash
openssl req -in request.csr -noout -text
openssl req -in request.csr -noout -verify
```

---

## Self-Signed Certificates

**Quick self-signed cert (dev/testing)**

```bash
openssl req -x509 -newkey rsa:4096 -nodes \
  -keyout self.key \
  -out self.crt \
  -days 365 \
  -subj "/CN=localhost"
```

**Self-signed with Subject Alternative Names (SAN) — required by modern browsers**

```bash
openssl req -x509 -newkey rsa:4096 -nodes \
  -keyout self.key \
  -out self.crt \
  -days 365 \
  -subj "/CN=localhost" \
  -addext "subjectAltName=DNS:localhost,IP:127.0.0.1"
```

---

## Certificate Authority (CA) Workflow

**1. Create a root CA**

```bash
# Generate CA key
openssl genrsa -aes256 -out ca.key 4096

# Self-sign the CA certificate
openssl req -x509 -new -nodes \
  -key ca.key \
  -sha256 \
  -days 3650 \
  -out ca.crt \
  -subj "/CN=My Root CA/O=MyOrg"
```

**2. Sign a CSR with your CA**

```bash
openssl x509 -req \
  -in request.csr \
  -CA ca.crt \
  -CAkey ca.key \
  -CAcreateserial \
  -out signed.crt \
  -days 365 \
  -sha256
```

**3. Sign with SAN extension**

```bash
# Create extension file
cat > san.ext <<EOF
subjectAltName=DNS:example.com,DNS:www.example.com,IP:192.168.1.1
EOF

openssl x509 -req \
  -in request.csr \
  -CA ca.crt \
  -CAkey ca.key \
  -CAcreateserial \
  -out signed.crt \
  -days 365 \
  -sha256 \
  -extfile san.ext
```

---

## Inspecting Certificates & Keys

**Inspect a certificate**

```bash
openssl x509 -in cert.crt -noout -text      # Full details
openssl x509 -in cert.crt -noout -subject   # Subject only
openssl x509 -in cert.crt -noout -issuer    # Issuer
openssl x509 -in cert.crt -noout -dates     # Validity period
openssl x509 -in cert.crt -noout -fingerprint -sha256
```

**Inspect a private key**

```bash
openssl rsa -in private.key -check -noout
openssl rsa -in private.key -noout -text
```

**Verify a cert matches a key**

```bash
# These should produce identical hashes if they match
openssl x509 -noout -modulus -in cert.crt | openssl md5
openssl rsa -noout -modulus -in private.key | openssl md5
```

**Verify cert was signed by CA**

```bash
openssl verify -CAfile ca.crt signed.crt
```

---

## Format Conversion

**PEM ↔ DER**

```bash
# PEM to DER
openssl x509 -in cert.pem -outform DER -out cert.der

# DER to PEM
openssl x509 -in cert.der -inform DER -outform PEM -out cert.pem
```

**PEM ↔ PKCS#12 (.p12/.pfx)**

```bash
# PEM cert + key → PKCS#12
openssl pkcs12 -export \
  -inkey private.key \
  -in cert.crt \
  -certfile ca.crt \
  -out bundle.p12

# PKCS#12 → PEM
openssl pkcs12 -in bundle.p12 -out extracted.pem -nodes
```

---

## Encryption & Decryption

**Symmetric (file encryption)**

```bash
# Encrypt
openssl enc -aes-256-cbc -pbkdf2 -in plaintext.txt -out encrypted.bin

# Decrypt
openssl enc -d -aes-256-cbc -pbkdf2 -in encrypted.bin -out plaintext.txt
```

**Asymmetric (with RSA public key)**

```bash
# Encrypt with public key
openssl rsautl -encrypt -pubin -inkey public.key \
  -in secret.txt -out secret.enc

# Decrypt with private key
openssl rsautl -decrypt -inkey private.key \
  -in secret.enc -out secret.txt
```

> Note: RSA direct encryption is only suitable for small data. For larger payloads, use hybrid encryption (encrypt a symmetric key with RSA, then use that to encrypt the data).

---

## Hashing & Digests

```bash
openssl dgst -sha256 file.txt
openssl dgst -sha512 file.txt
openssl dgst -md5 file.txt        # Weak — avoid for security use

# HMAC
openssl dgst -sha256 -hmac "mysecretkey" file.txt
```

---

## Signing & Verification

```bash
# Sign a file
openssl dgst -sha256 -sign private.key -out file.sig file.txt

# Verify the signature
openssl dgst -sha256 -verify public.key -signature file.sig file.txt
```

---

## TLS/SSL Testing

**Check a live server**

```bash
openssl s_client -connect example.com:443
openssl s_client -connect example.com:443 -servername example.com  # SNI

# Check cert expiry quickly
echo | openssl s_client -connect example.com:443 2>/dev/null \
  | openssl x509 -noout -dates

# Show full cert chain
openssl s_client -connect example.com:443 -showcerts
```

**Test specific TLS versions**

```bash
openssl s_client -connect example.com:443 -tls1_2
openssl s_client -connect example.com:443 -tls1_3
```

---

## Random Data & Passwords

```bash
# Random hex string
openssl rand -hex 32

# Random base64 string (good for secrets/tokens)
openssl rand -base64 32

# Random bytes to file
openssl rand -out random.bin 256
```

---

## Useful One-Liners

```bash
# Check cert expiry date only
openssl x509 -noout -enddate -in cert.crt

# Days until expiry (bash)
echo $(( ( $(date -d "$(openssl x509 -noout -enddate -in cert.crt \
  | cut -d= -f2)" +%s) - $(date +%s) ) / 86400 )) days remaining

# Strip passphrase from a key
openssl rsa -in encrypted.key -out decrypted.key

# Generate a strong random password
openssl rand -base64 24

# Benchmark digest performance
openssl speed sha256 sha512 aes-256-cbc
```

---

## Config File Location (Arch)

```bash
# Default openssl.cnf
/etc/ssl/openssl.cnf

# Your certs/CA trust store
/etc/ca-certificates/
/etc/ssl/certs/

# Update trust store after adding a CA
sudo trust anchor --store ca.crt    # Arch way
sudo update-ca-trust                # Alternative
```

---

## Security Notes

- **RSA 2048** is the current minimum; **4096** preferred for long-lived keys
- **EC keys** (P-256, P-384) are smaller and faster than RSA at equivalent security
- Always use **`-pbkdf2`** with `enc` subcommand; older iterations used a weak KDF
- **MD5 and SHA-1** are cryptographically broken — avoid for any security purpose
- Passphrases on private keys protect keys at rest but are only as strong as the passphrase itself
- `rsautl` is deprecated in newer OpenSSL versions; `pkeyutl` is the modern replacement