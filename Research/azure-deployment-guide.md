# Chenda — Azure VPS Deployment Guide

> **Stack:** Next.js (frontend) · Node.js/Express (backend) · PostgreSQL 16 + PostGIS 3.4  
> **Method:** Docker Compose on an Azure Ubuntu VM  
> **Credits:** Azure for Students — $100 free credit (no credit card required)

Each section has two paths: **Portal** (browser UI) and **CLI** (Azure Cloud Shell). Choose one and stick with it — they produce the same result.

> **Azure Cloud Shell:** The CLI commands run inside Azure Cloud Shell — the `>_` button in the top bar of the Azure portal. No local install needed. It already has `az` pre-installed and authenticated.

---

## Table of Contents

1. [Prerequisites](#1-prerequisites)
2. [Provision the Azure VM](#2-provision-the-azure-vm)
3. [Configure Networking (NSG Rules)](#3-configure-networking-nsg-rules)
4. [Connect to the VM via SSH](#4-connect-to-the-vm-via-ssh)
5. [Server Setup — Install Docker](#5-server-setup--install-docker)
6. [Clone the Repository](#6-clone-the-repository)
7. [Configure Environment Variables](#7-configure-environment-variables)
8. [Build and Start All Services](#8-build-and-start-all-services)
9. [Run Database Migrations](#9-run-database-migrations)
10. [Verify the Deployment](#10-verify-the-deployment)
11. [Optional: Nginx Reverse Proxy (Port 80)](#11-optional-nginx-reverse-proxy-port-80)
12. [Ongoing Operations](#12-ongoing-operations)
13. [Backup Volumes](#13-backup-volumes)
14. [Troubleshooting](#14-troubleshooting)
15. [Credit Usage Estimates](#15-credit-usage-estimates)

---

## 1. Prerequisites

Before you begin, make sure you have:

- An **Azure for Students** account activated at [azure.microsoft.com/free/students](https://azure.microsoft.com/en-us/free/students/). You get $100 in free credits for 12 months — no credit card required.
- Your **Chenda monorepo** pushed to GitHub (private or public).
- A **GitHub Personal Access Token (PAT)** if the repo is private — you will need it to clone on the server. Generate one at: GitHub → Settings → Developer Settings → Personal access tokens → Tokens (classic) → `repo` scope.
- An SSH client on your local machine (Terminal on macOS/Linux; PowerShell or PuTTY on Windows).

---

## 2. Provision the Azure VM

> **VM size reality for Azure for Students:** The portal may only show expensive D/E-series sizes due to quota restrictions. If that happens, use the CLI path — it bypasses portal UI bugs and lets you specify exact sizes. If a size fails with `SkuNotAvailable`, check what is actually available to your subscription first:
> ```bash
> az vm list-skus --location <region> --size Standard_B --output table | grep None
> ```

---

### → Portal

1. Log in at [portal.azure.com](https://portal.azure.com).
2. Search for **"Virtual machines"** in the top search bar and click it.
3. Click **"Create" → "Azure virtual machine"**.

**Basics Tab:**

| Field | Value |
|---|---|
| **Subscription** | Azure for Students |
| **Resource group** | Create new → `chenda-rg` |
| **VM name** | `chenda-vm` |
| **Region** | `Southeast Asia` *(try Malaysia West or Korea Central if unavailable)* |
| **Availability options** | No infrastructure redundancy required |
| **Image** | **Ubuntu Server 22.04 LTS — x64 Gen2** |
| **Size** | **Standard_B2s_v2** *(2 vCPUs, 4 GB RAM)* |
| **Authentication type** | SSH public key |
| **Username** | `azureuser` |
| **SSH public key source** | Generate new key pair |
| **Key pair name** | `chenda-key` |

**Disks Tab:**

| Field | Value |
|---|---|
| **OS disk size** | 64 GiB |
| **OS disk type** | Standard SSD (locally-redundant storage) |

**Management Tab:**
- Set **Auto-shutdown** to a time when the server is not in use (e.g., 11:59 PM) to conserve credits. Disable when you want 24/7 uptime.

**Monitoring Tab:**
- Set **Boot diagnostics** to **Disable** to avoid extra storage charges.

**Review + Create:**

Click **"Review + Create"**. When validation passes, click **"Create"**. A popup will appear — click **"Download private key and create resource"** and save the `.pem` file to `~/.ssh/chenda-key.pem`. **You cannot download it again.**

Wait 1–2 minutes, then click **"Go to resource"** and copy your **Public IP address** from the overview panel. Save it — you will use it throughout the rest of this guide.

---

### → CLI (Azure Cloud Shell)

Open Cloud Shell from the `>_` button in the Azure portal top bar.

**Step 1 — Find an available region and size for your subscription.**

This command scans all regions for B-series sizes your subscription can use (takes 2–3 minutes):
```bash
az vm list-skus --size Standard_B --all --output table | grep None
```

From the output, pick a region + size with `None` in the Restrictions column. For the Philippines, closest options are typically `malaysiawest` or `koreacentral` with `Standard_B2s_v2`.

**Step 2 — Create the resource group.**
```bash
az group create --name chenda-rg --location malaysiawest
```
Replace `malaysiawest` with your chosen region using the exact lowercase name from the SKUs output.

**Step 3 — Create the VM.**
```bash
az vm create \
  --resource-group chenda-rg \
  --name chenda-vm \
  --image Ubuntu2204 \
  --size Standard_B2s_v2 \
  --admin-username azureuser \
  --generate-ssh-keys
```

Replace `Standard_B2s_v2` with whichever size was available in your chosen region.

When it succeeds, the output will include `"publicIpAddress": "X.X.X.X"`. Save that IP.

> **If you get `SkuNotAvailable`:** Delete the group with `az group delete --name chenda-rg --yes`, create it in a different region, and retry from Step 2.

> **If you get `RequestDisallowedByAzure`:** The region is blocked for your subscription. List allowed regions with:
> ```bash
> az account list-locations --output table
> ```
> Pick a different region from that list and retry from Step 2.

> **If Ctrl+C to cancel a running command:** Partially created resources may remain. Clean up with:
> ```bash
> az group delete --name chenda-rg --yes --no-wait
> ```
> Wait about a minute, then start again from Step 2.

---

## 3. Configure Networking (NSG Rules)

You need to open ports so the app is reachable from the internet.

### → Portal

1. From your VM's page, click **"Networking"** in the left sidebar.
2. Click **"Add inbound port rule"** and add these rules one by one:

| Port | Protocol | Name | Purpose |
|---|---|---|---|
| `22` | TCP | `SSH` | Already exists by default |
| `80` | TCP | `HTTP` | Nginx (if added later) |
| `3000` | TCP | `Frontend` | Next.js app |
| `3001` | TCP | `Backend-API` | Node.js API |

Set **Priority** to any unique number (e.g., 310, 320, 330) and **Action** to **Allow**.

---

### → CLI (Azure Cloud Shell)

```bash
az vm open-port --resource-group chenda-rg --name chenda-vm --port 80   --priority 310
az vm open-port --resource-group chenda-rg --name chenda-vm --port 3000 --priority 320
az vm open-port --resource-group chenda-rg --name chenda-vm --port 3001 --priority 330
```

Port 22 (SSH) is already open by default when a VM is created via CLI.

---

## 4. Connect to the VM via SSH

### → Portal

After downloading `chenda-key.pem`, fix permissions (macOS/Linux only):

```bash
chmod 600 ~/.ssh/chenda-key.pem
ssh -i ~/.ssh/chenda-key.pem azureuser@<YOUR_VM_PUBLIC_IP>
```

**Windows (PowerShell):** Skip the `chmod` step. Run the `ssh` command directly.

---

### → CLI (Azure Cloud Shell)

If you used `--generate-ssh-keys`, the key was saved in Cloud Shell's home directory automatically. Connect directly:

```bash
ssh azureuser@<YOUR_VM_PUBLIC_IP>
```

If prompted about the fingerprint, type `yes`.

> **Forgot your public IP?** Retrieve it anytime with:
> ```bash
> az vm show --resource-group chenda-rg --name chenda-vm --show-details --query publicIps -o tsv
> ```

---

## 5. Server Setup — Install Docker

**All commands from this point forward run on the VM itself (after SSH-ing in), not in Cloud Shell.**

### 5a. Update the system

```bash
sudo apt-get update && sudo apt-get upgrade -y
```

### 5b. Install Docker (official Docker repository)

```bash
# Install dependencies
sudo apt-get install -y ca-certificates curl gnupg

# Add Docker's official GPG key
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | \
  sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

# Add Docker's repository
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
  https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Install Docker Engine + Compose plugin
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
```

### 5c. Allow your user to run Docker without `sudo`

```bash
sudo usermod -aG docker $USER
newgrp docker
```

### 5d. Verify installation

```bash
docker --version
docker compose version
```

Both should print version numbers. [Inference: exact versions depend on what Docker releases at install time.]

---

## 6. Clone the Repository

```bash
cd ~
git clone https://github.com/<your-username>/chenda.git
cd chenda
```

**If the repo is private**, use your Personal Access Token:

```bash
git clone https://<YOUR_PAT>@github.com/<your-username>/chenda.git
```

Replace `<YOUR_PAT>` with your token and `<your-username>` with your GitHub username.

---

## 7. Configure Environment Variables

The app uses a single `.env.docker` file at the repo root, loaded by all three services (`db`, `backend`, `frontend`).

```bash
cp .env.example .env.docker
nano .env.docker
```

Edit these values — **everything marked REQUIRED must be changed**:

```dotenv
# --- Database ---
DB_HOST_PORT=5433
DB_HOST=db
DB_PORT=5432
DB_NAME=chenda
DB_USER=postgres
DB_PASSWORD=<CHANGE_THIS_TO_A_STRONG_PASSWORD>   # REQUIRED

# --- Backend ---
SESSION_SECRET=<GENERATE_A_LONG_RANDOM_STRING>   # REQUIRED — min 32 characters

# --- URLs ---
# NEXT_PUBLIC_API_URL runs in the USER'S BROWSER — must be public IP, not localhost.
NEXT_PUBLIC_API_URL=http://<YOUR_VM_PUBLIC_IP>:3001

# Container-to-container — do NOT change this.
INTERNAL_API_URL=http://backend:3001

# Backend CORS origin — point at your frontend's public address.
FRONTEND_URL=http://<YOUR_VM_PUBLIC_IP>:3000
```

**Generate a strong SESSION_SECRET:**

```bash
openssl rand -hex 32
```

Copy the output and paste it as the `SESSION_SECRET` value.

Save and exit nano: `Ctrl+O` → `Enter` → `Ctrl+X`.

> **Important:** `NEXT_PUBLIC_API_URL` is baked into the Next.js JavaScript bundle at **build time**. If your VM's public IP ever changes, update this value and rebuild: `docker compose up -d --build frontend`.

---

## 8. Build and Start All Services

```bash
docker compose up -d --build
```

This builds the backend image from `./server/Dockerfile`, builds the frontend image from `./chenda-frontend/Dockerfile`, pulls the PostGIS database image, and starts all three containers in the background.

The first build can take **5–15 minutes** — Next.js compilation is slow.

Monitor progress:
```bash
docker compose logs -f
```
Press `Ctrl+C` to stop following logs (containers keep running).

Check all services are up:
```bash
docker compose ps
```
All three — `db`, `backend`, `frontend` — should show `running` or `healthy`.

---

## 9. Run Database Migrations

Wait until `db` shows `healthy` status, then run:

```bash
docker compose exec backend node migrations/migrate.js up
```

Expected output:
```
🔗 Connecting to database...
✓ Connected to chenda@db
✓ Migrations tracking table ready
🚀 Running N pending migration(s)...
✓ Successfully applied: 001_....sql
✅ All migrations completed successfully!
```

Check migration status at any time:
```bash
docker compose exec backend node migrations/migrate.js status
```

---

## 10. Verify the Deployment

Open a browser and navigate to:

- **Frontend:** `http://<YOUR_VM_PUBLIC_IP>:3000`
- **Backend:** `http://<YOUR_VM_PUBLIC_IP>:3001`

Quick API test from the VM:
```bash
curl http://localhost:3001
```
Should return a response from your Node.js server — not a connection refused error.

---

## 11. Optional: Nginx Reverse Proxy (Port 80)

Serves the app on port 80 so users visit `http://<IP>` instead of `http://<IP>:3000`.

```bash
sudo apt-get install -y nginx
sudo nano /etc/nginx/sites-available/chenda
```

Paste this config:

```nginx
server {
    listen 80;
    server_name _;

    location / {
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_cache_bypass $http_upgrade;
    }

    location /api {
        proxy_pass http://localhost:3001;
        proxy_http_version 1.1;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    }
}
```

Enable and start:

```bash
sudo ln -s /etc/nginx/sites-available/chenda /etc/nginx/sites-enabled/
sudo rm /etc/nginx/sites-enabled/default
sudo nginx -t                    # should say "test is successful"
sudo systemctl enable nginx
sudo systemctl start nginx
```

Then update `.env.docker`:

```dotenv
NEXT_PUBLIC_API_URL=http://<YOUR_VM_PUBLIC_IP>/api
FRONTEND_URL=http://<YOUR_VM_PUBLIC_IP>
```

Rebuild the frontend to bake in the new URL:
```bash
docker compose up -d --build frontend
```

---

## 12. Ongoing Operations

### Pull new code and redeploy

```bash
cd ~/chenda
git pull origin main
docker compose up -d --build
# Run if there are new migration files:
docker compose exec backend node migrations/migrate.js up
```

### View logs

```bash
docker compose logs -f           # all services
docker compose logs -f backend   # backend only
docker compose logs -f frontend  # frontend only
docker compose logs -f db        # database only
```

### Stop / restart services

```bash
docker compose down              # stop all (keeps volumes/data)
docker compose down -v           # DESTRUCTIVE — also deletes volumes and database
docker compose restart backend   # restart one service
```

### Check container resource usage

```bash
docker stats
```

### Auto-start containers on VM reboot

Docker Engine starts on boot by default. Confirm:

```bash
sudo systemctl is-enabled docker
# Should output: enabled
```

To auto-start your containers on reboot:

```bash
crontab -e
# Add this line:
@reboot cd /home/azureuser/chenda && docker compose up -d
```

### Stop / start the VM to save credits

**Portal:** Virtual Machines → `chenda-vm` → Stop / Start.

**CLI (from Cloud Shell):**
```bash
# Stop and deallocate (stops compute billing)
az vm deallocate --resource-group chenda-rg --name chenda-vm

# Start again
az vm start --resource-group chenda-rg --name chenda-vm

# Check current power state
az vm show --resource-group chenda-rg --name chenda-vm --query powerState -o tsv
```

> **Important:** Shutting down from inside the OS (`sudo shutdown`) keeps the VM allocated and still charges compute. Always use the portal Stop button or `az vm deallocate` to stop billing.

---

## 13. Backup Volumes

Back up before any major changes.

### Backup the PostgreSQL database

```bash
docker compose exec db pg_dump -U postgres chenda > ~/chenda-backup-$(date +%Y%m%d).sql
```

### Backup uploaded files

```bash
mkdir -p ~/backups
docker run --rm \
  -v chenda_uploads_data:/data \
  -v ~/backups:/backup \
  alpine tar czf /backup/uploads-$(date +%Y%m%d).tar.gz -C /data .
```

### Restore the database

```bash
cat ~/chenda-backup-<DATE>.sql | docker compose exec -T db psql -U postgres chenda
```

---

## 14. Troubleshooting

### Backend fails — "Connection refused" to database

```bash
docker compose ps db       # check if db is "healthy"
docker compose logs db     # view db startup errors
```

The healthcheck runs `pg_isready -U postgres -d chenda` every 10 seconds with 5 retries. Wait up to 60 seconds before concluding the DB failed.

### Frontend shows blank page or API calls fail

Almost always a wrong `NEXT_PUBLIC_API_URL`. Verify:

```bash
grep NEXT_PUBLIC_API_URL .env.docker
```

Must be `http://<YOUR_ACTUAL_PUBLIC_IP>:3001` — not `localhost`, not `backend`. After fixing, rebuild:

```bash
docker compose up -d --build frontend
```

### VM size / quota errors during creation

Run this to find what is actually available to your subscription across all regions:
```bash
az vm list-skus --size Standard_B --all --output table | grep None
```

Also verify resource providers are registered: Portal → Subscriptions → Your subscription → Resource Providers → confirm `Microsoft.Compute`, `Microsoft.Storage`, `Microsoft.Network` are all **Registered**.

### Build runs out of memory

Add a 2 GB swap file on the VM before building:

```bash
sudo fallocate -l 2G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile
echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab
```

Then retry: `docker compose up -d --build`

### Port not reachable from browser

1. Confirm the NSG inbound rule exists for that port (Portal → Networking).
2. Confirm the container is running: `docker compose ps`
3. Confirm the port is bound on the host: `sudo ss -tlnp | grep 3000`

### Get the VM's public IP (forgot it)

```bash
# CLI
az vm show --resource-group chenda-rg --name chenda-vm --show-details --query publicIps -o tsv

# Portal
Virtual Machines → chenda-vm → Overview → Public IP address
```

The `VMAccessForLinux` extension is failing because there's no key to push. Let's fix this step by step — generate a fresh key first, then push it.

---

## 15. Login From Azure CLI

#### Step 1 — Generate a new SSH keypair in Cloud Shell

```bash
ssh-keygen -t rsa -b 4096 -f ~/.ssh/id_rsa -N ""
```

- `-N ""` means no passphrase
- Say `y` if it asks to overwrite

Verify it worked:
```bash
cat ~/.ssh/id_rsa.pub
```
You should see a long line starting with `ssh-rsa AAAA...`. If you do, proceed.

---

#### Step 2 — Push the public key to the VM

```bash
az vm user update \
  --resource-group chenda-rg \
  --name chenda-vm \
  --username azureuser \
  --ssh-key-value "$(cat ~/.ssh/id_rsa.pub)"
```

Wait for it to complete (takes ~30–60 seconds). You should see a JSON response — **not** an error.

---

#### Step 3 — Connect

```bash
ssh azureuser@85.211.245.61
```

---

#### If Step 2 still fails with `VMExtensionProvisioningError`

The VM extension agent itself may be broken or the VM may be in a bad state. Check the VM's power state first:

```bash
az vm show \
  --resource-group chenda-rg \
  --name chenda-vm \
  --query powerState \
  -o tsv
```

- If it says `VM stopped` or `VM deallocated` → start it first:
  ```bash
  az vm start --resource-group chenda-rg --name chenda-vm
  ```
  Then wait ~2 minutes and retry Step 2.

- If it says `VM running` but Step 2 keeps failing → reboot the VM to reset the extension agent:
  ```bash
  az vm restart --resource-group chenda-rg --name chenda-vm
  ```
  Wait ~2 minutes, then retry Step 2.

---

Run Step 1 first and paste what `cat ~/.ssh/id_rsa.pub` outputs — that'll confirm whether the key generation succeeded before we try pushing it again.

---

## 15. Credit Usage Estimates

**[Inference]** — estimates based on Azure published pricing as of mid-2025. Actual costs vary by region, disk type, and traffic. Verify at the [Azure pricing calculator](https://azure.microsoft.com/en-us/pricing/calculator/).

| Resource | Estimated Monthly Cost |
|---|---|
| Standard_B2s_v2 VM (730 hrs) | ~$30–40/month |
| Standard SSD 64 GiB OS disk | ~$5/month |
| Public IP address | ~$3–4/month |
| Outbound bandwidth (first 100 GB free) | ~$0 |
| **Total** | **~$38–49/month** |

With $100 in credit this gives approximately **2–2.5 months** of always-on runtime.

**Tips to extend credits:**

- Use `az vm deallocate` or the portal Stop button when not testing — stops compute billing immediately.
- Set auto-shutdown in the portal for nights and weekends.
- Monitor your spend in Cloud Shell: `az consumption usage list --output table`

---

*Last updated: April 2026. Azure portal UI and pricing may change — verify current pricing at [azure.microsoft.com/pricing/calculator](https://azure.microsoft.com/en-us/pricing/calculator/).*
