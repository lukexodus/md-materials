## What is Tailscale?

Tailscale is a software-defined mesh VPN and web-based management service developed by a Toronto-based company. It was founded in 2019 by former Google engineers.

At its core, Tailscale creates encrypted point-to-point connections using the open-source WireGuard protocol, meaning only devices on your private network can communicate with each other. It creates a peer-to-peer mesh network called a "tailnet."

The key differentiator from a traditional VPN: traditional VPNs route all traffic through a central gateway, which can result in higher latency and act as a bottleneck. With Tailscale, each device connects directly to the others, resulting in lower latency and no single point of failure.

---

## What Problem Does It Solve?

The founders observed that teams were spending 90% of their time just dealing with connectivity and security when building internal tools, and only 10% actually building the tool itself. Their goal was to remove that obstacle — to "make easy things easy."

Traditional VPN setups like OpenVPN or raw WireGuard take hours or days to configure, often break with firewalls or DNS issues, and require ongoing management. Tailscale handles all of this automatically — no touching firewalls or routers required.

You sign in with an existing identity provider like Google, Microsoft, or Okta. This means one fewer password, and you can require multi-factor authentication to access resources on your network.

---

## Who Is It For?

It genuinely spans all three audiences you mentioned:

**Enterprises and IT teams** Tailscale is positioned as a Zero Trust connectivity platform that can replace legacy VPNs, and is described as an ideal solution for DevOps, IT, and Security teams. It connects remote teams, multi-cloud environments, CI/CD pipelines, and IoT devices.

By January 2025, Tailscale surpassed 10,000 business customers ranging from small firms to Fortune 500 companies, with over 500,000 weekly active users. AI companies like Cohere, Mistral, Hugging Face, and Perplexity are among its users.

**Developers** Tailscale was built for developers, not security teams. Developers were using it at home, bringing it into work to solve engineering problems, and quietly rolling it out across teams.

**Ordinary / Home Users** Home users use it to access their home network remotely, protect devices from guests on shared Wi-Fi, stream from a self-hosted media server like Jellyfin without exposing it to the internet, and manage smart home devices more securely — all without complex configuration.

The free tier covers up to 100 devices, with paid plans starting at $6/user/month.

---

## Quick Summary

|Use Case|Relevant?|
|---|---|
|Remote access to your own devices|✅ Yes|
|Secure team networking for companies|✅ Yes|
|Developer infrastructure (servers, CI/CD, containers)|✅ Yes|
|Home lab / self-hosting|✅ Yes|
|Replacing a public VPN service (like NordVPN)|⚠️ [Inference] Partially — it has an "exit node" feature for routing internet traffic, but its primary design is private device-to-device networking, not anonymizing public browsing|

In short, Tailscale is unusually broad in appeal — it is genuinely useful whether you're a solo home user, a developer, or a large enterprise IT team.

---

# Tailscale: Concepts & Setup by Use Case

---

## Part 1 — Core Concepts (Everyone Needs These)

Before tackling use cases, you need to understand the building blocks. Every feature below builds on these.

---

### 1. Tailnet

Your **tailnet** is your private Tailscale network. It is the collection of all devices that join the same Tailscale account. Each device gets a unique IP address in the `100.x.x.x` range. Think of it as your own personal LAN that spans the entire internet.

---

### 2. Nodes

A **node** is any device you add to your tailnet — your laptop, phone, home server, cloud VM, Raspberry Pi, etc. Once installed, the Tailscale client runs in the background to keep your device connected to the tailnet.

---

### 3. How Connections Actually Work

When a Tailscale client starts, it first connects to the **control server** to authenticate and fetch information about other nodes, including each device's public IP, port, and NAT type. The control server does not relay any traffic — it only coordinates connections, acting like a dispatcher.

After that, Tailscale tries connections in priority order:

Direct Connection → STUN Hole-punching → Peer Relay → **DERP Relay** (final fallback)

**DERP** (Designated Encrypted Relay for Packets) is the fallback relay. All clients initially connect via DERP (relay mode), meaning the connection is established instantly with no waiting, but Tailscale always tries to upgrade to a faster direct connection afterward.

**Why this matters to you:** In most home and developer setups, you'll get direct connections and low latency. DERP only kicks in when firewalls block everything else.

---

### 4. MagicDNS

Instead of memorizing `100.84.23.17`, you use device names.

MagicDNS automatically registers DNS names for devices in your network. If you add a new web server called `my-server` to your network, you no longer need to use its Tailscale IP — using the name `my-server` in your browser's address bar or on the command line will work.

Tailnets created on or after October 20, 2022 have MagicDNS enabled by default. So most users get this for free without setup.

---

### 5. ACLs (Access Control Lists)

An ACL manages system access using rules in the tailnet policy file. You can use ACLs to filter traffic and enhance security by managing who and what can use which resources.

ACLs are JSON-formatted rules. The default is **deny** — access must be explicitly granted. For a single personal user, the default policy is wide open (all your devices can reach each other). ACLs become important for teams and enterprises.

Example rule (plain English): "Allow devices tagged `mobile` to reach devices tagged `home-base` on any port."

---

### 6. Tags

A tag lets you assign an identity — separate from human users — to devices. You can use tags in your access rules to restrict access. For example, you might tag a server `tag:server` and a laptop `tag:workstation`, then write ACL rules based on those tags rather than individual users.

---

### 7. Exit Nodes vs. Subnet Routers (Commonly Confused)

These are two distinct routing features:

**Exit nodes** route outbound internet traffic from your tailnet devices, effectively functioning as VPN servers. When you connect to an exit node, your internet traffic appears to come from the exit node's location. This is useful for accessing geo-restricted content or improving privacy.

**Subnet routers**, in contrast, provide access to specific private subnets. They enable tailnet devices to reach non-Tailscale devices within those subnets, but don't affect internet traffic routing. If you need to access private networks like office LANs or cloud VPCs, subnet routers are the appropriate solution.

In short:

- **Exit node** = route your internet traffic through another machine (like a VPN)
- **Subnet router** = access an entire network segment (like a whole office LAN) through one Tailscale device

---

## Part 2 — Use Cases and Setup

---

### Use Case A: Personal / Home User

**Goal:** Access your home devices (NAS, desktop, Pi) from anywhere, securely.

**Setup steps:**

1. Create a free account at `tailscale.com` — sign in with Google, Microsoft, or GitHub.
2. Install the Tailscale client on your home machine (the one you want to reach remotely).
3. Install the Tailscale client on your phone or laptop (the device you travel with).
4. Both devices will appear in your admin console at `login.tailscale.com`.
5. You can now reach your home machine by name (e.g., `ping my-desktop`) or by its `100.x.x.x` IP from anywhere.

**No port forwarding. No firewall rules. No static IP required.**

**Useful extras for home users:**

- **Taildrop** — Taildrop allows seamless file and data transfers between two devices. Its concept is similar to Apple's AirDrop, but unlike AirDrop which relies on Wi-Fi or Bluetooth, Taildrop uses Tailscale's secure encrypted tunnel, meaning files can be transferred regardless of device proximity.
    
- **Exit node from home** — Prepare a device at home that stays on 24/7 — a Raspberry Pi or a Mac Mini. Install Tailscale and declare it as an exit node. Once enabled in the Tailscale console, this device becomes a free VPN, allowing you to securely access the internet from unfamiliar networks.
    
- **Ad blocking everywhere** — If you have a Pi-hole or AdGuard Home running as a subnet router on your tailnet, you can point all your tailnet devices' DNS queries at it — effectively getting network-wide ad blocking on your phone, even in a coffeeshop.
    

---

### Use Case B: Developer / Self-Hoster

**Goal:** Securely access dev servers, home labs, databases, and self-hosted services without exposing them to the public internet.

**Key concepts to add: Tailscale SSH, Serve, and Funnel**

**Tailscale SSH**

Normally, SSH requires you to manage key files, open port 22 to the internet, and worry about brute-force attacks. Tailscale SSH bypasses all of that.

You can SSH to a node using its MagicDNS hostname. The MagicDNS hostname is automatically generated from the machine's name. So instead of `ssh user@203.0.113.45`, you just do `ssh user@my-server` — and it just works, with no keys to manage and no port exposed.

To enable it on Linux:

```bash
sudo tailscale set --ssh=true
```

**Subnet Router for your home lab**

If you have multiple devices on a home lab network (e.g., a NAS, a router, old devices that can't run Tailscale), you don't need to install Tailscale on all of them. Install it on one device (like a Raspberry Pi) and make it a subnet router.

Setting up a subnet router involves installing Tailscale on a device that will act as the gateway, configuring it to advertise routes, and ensuring proper access controls.

```bash
# Enable IP forwarding first, then:
sudo tailscale set --advertise-routes=192.168.1.0/24
```

Then approve the route in the admin console. Now every device on `192.168.1.0/24` is reachable from your tailnet, even without Tailscale installed on them.

**Serve and Funnel** (advanced, developer-focused)

- **Tailscale Serve** — expose a local service (e.g., `localhost:3000`) to other devices on your tailnet only. Useful for sharing a dev server with a teammate.
- **Tailscale Funnel** — expose a service publicly over HTTPS without a domain name or reverse proxy setup. Useful for webhooks, demos, or testing.

```bash
tailscale serve 3000          # share to tailnet only
tailscale funnel 3000         # expose to public internet
```

---

### Use Case C: Enterprise / IT Teams

**Goal:** Replace a legacy corporate VPN, connect cloud infrastructure, enforce Zero Trust access policies.

**Key additions: ACL policies, Tags, Subnet Routers for cloud VPCs**

**Replacing the corporate VPN**

Instead of routing all employee traffic through a central server (slow, single point of failure), Tailscale operates as a mesh topology where each device talks directly to others using NAT traversal, rather than a hub-and-spoke model where all traffic goes through a central gateway.

Employees install the Tailscale client and sign in with their company's identity provider (Google Workspace, Okta, Microsoft Azure AD). Their devices automatically join the corporate tailnet.

**Connecting cloud infrastructure (e.g., AWS VPC)**

For IP-based connectivity, a Tailscale subnet router connects to managed AWS resources such as Amazon RDS or Redshift. This is recommended where you cannot run Tailscale on the resource you are connecting to, or want to expose an existing subnet or services in a VPC to your tailnet.

**Enforcing Zero Trust with ACLs and Tags**

Rather than "everyone on the VPN can reach everything," you define precise rules:

```json
{
  "acls": [
    {
      "action": "accept",
      "src": ["tag:developer"],
      "dst": ["tag:dev-server:*"]
    }
  ]
}
```

This means only devices tagged `developer` can reach servers tagged `dev-server`. Everything else is denied by default.

An important note for organizations: devices behind subnet routers don't count toward your pricing plan's device limit.

---

## Part 3 — Quick Reference

|Concept|What it is|When you need it|
|---|---|---|
|**Tailnet**|Your private Tailscale network|Always — it's the foundation|
|**Node**|Any device joined to the tailnet|Always|
|**MagicDNS**|Human-readable device names|Always — enabled by default|
|**Exit Node**|Route all internet traffic through a specific device|Privacy on public Wi-Fi, geo-access|
|**Subnet Router**|Access a whole network segment through one device|Home lab, office LAN, cloud VPC|
|**ACL**|Rules for who can talk to what|Teams, enterprises, multi-user setups|
|**Tags**|Identity labels for devices (not users)|Enforcing access rules in ACLs|
|**Tailscale SSH**|SSH without key management or open ports|Developers, sysadmins|
|**Taildrop**|Encrypted file transfer between tailnet devices|Personal, cross-OS file sharing|
|**DERP**|Encrypted relay fallback when P2P fails|Automatic — you don't configure this manually|
|**Serve / Funnel**|Expose local services to tailnet or public web|Developers, demos, webhooks|
