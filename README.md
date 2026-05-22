# 🐉 Cybersecurity Student Pentest Lab

A fully isolated Docker-based penetration testing environment featuring Kali Linux
alongside three intentionally vulnerable targets. Designed for educational use only.

---

## ⚠️ Legal & Ethical Notice

> All activities in this lab environment must remain **strictly within the isolated
> Docker network**. These containers are intentionally vulnerable and must **never**
> be exposed to the public internet or your production network.
>
> Unauthorized access to computer systems is illegal under the Computer Fraud and
> Abuse Act (CFAA), GDPR, and equivalent laws worldwide. This lab is for
> **authorized educational use only**.

---

## 🏗️ Architecture

```
  ┌─────────────────────────────────────────────────────┐
  │           lab_net  (10.10.0.0/24)                   │
  │                                                     │
  │  ┌──────────────┐     ┌──────────────────────────┐  │
  │  │  KALI LINUX  │────▶│       DVWA               │  │
  │  │  10.10.0.10  │     │  10.10.0.20  port 80     │  │
  │  │  (Attacker)  │     └──────────────────────────┘  │
  │  └──────────────┘                                   │
  │         │           ┌──────────────────────────┐    │
  │         ├──────────▶│   METASPLOITABLE 2       │    │
  │         │           │  10.10.0.30  multi-port  │    │
  │         │           └──────────────────────────┘    │
  │         │                                           │
  │         │           ┌──────────────────────────┐    │
  │         └──────────▶│    OWASP JUICE SHOP      │    │
  │                     │  10.10.0.40  port 3000   │    │
  │                     └──────────────────────────┘    │
  │                                                     │
  │         (MySQL 10.10.0.50 — internal DVWA backend)  │
  └─────────────────────────────────────────────────────┘
```

---

## 📋 Prerequisites

- Docker Desktop 4.x+ (Mac/Windows) or Docker Engine 24+ (Linux)
- Docker Compose v2 (included with Docker Desktop)
- 8 GB RAM minimum (16 GB recommended)
- 20 GB free disk space

```bash
# Verify prerequisites
docker --version          # Docker version 24+
docker compose version    # Docker Compose v2+
```

---

## 🚀 Quick Start

```bash
# 1. Clone or download this repo
git clone <your-repo-url> pentest-lab && cd pentest-lab

# 2. Start the full lab
make up
# or: docker compose --profile full up -d

# 3. Drop into Kali
make kali
# or: docker exec -it kali-attacker bash

# 4. Inside Kali — run setup script
bash /setup.sh

# 5. Start hacking!
targets       # Show all IPs and credentials
scan-all      # Nmap sweep of the network
```

---

## 🎯 Target Quick Reference

| Target           | IP           | Host Port     | Credentials              |
|------------------|--------------|---------------|--------------------------|
| DVWA             | 10.10.0.20   | 8080 → 80     | admin / password         |
| Metasploitable 2 | 10.10.0.30   | 2222 → 22     | msfadmin / msfadmin      |
| Juice Shop       | 10.10.0.40   | 3000 → 3000   | admin@juice-sh.op/admin123|
| Portainer (Mgmt) | 10.10.0.60   | 9443 → 9443   | Set on first launch       |

---

## 🧪 Lab Exercises

### Module 1 — Reconnaissance
```bash
# Inside Kali container
nmap -sV -sC 10.10.0.0/24        # Network discovery
nmap -p- --open 10.10.0.20       # Full port scan on DVWA
nikto -h http://10.10.0.20       # Web vulnerability scan
```

### Module 2 — Web App: DVWA
```
URL: http://localhost:8080
Login: admin / password
Set Security Level: Low (Setup → DVWA Security)

Exercises:
  - SQL Injection: ' OR '1'='1
  - Command Injection: 127.0.0.1 && whoami
  - File Upload: upload a PHP webshell
  - XSS: <script>alert(document.cookie)</script>
```

### Module 3 — Web App: Juice Shop
```
URL: http://localhost:3000
Self-guided CTF with score tracking built in.
Hint: Open DevTools → Application → Local Storage for clues.
```

### Module 4 — Network: Metasploitable
```bash
# VSFTPd 2.3.4 Backdoor
msfconsole -q
use exploit/unix/ftp/vsftpd_234_backdoor
set RHOSTS 10.10.0.30
run

# SSH Brute Force
hydra -l msfadmin -P /usr/share/wordlists/rockyou.txt \
  ssh://10.10.0.30 -t 4

# Samba Exploit
use exploit/multi/samba/usermap_script
```

### Module 5 — Password Cracking
```bash
# Extract hashes from Metasploitable
ssh msfadmin@10.10.0.30 "sudo cat /etc/shadow" > shadow.txt

# Crack with John
john --wordlist=/usr/share/wordlists/rockyou.txt shadow.txt
john --show shadow.txt
```

---

## 🐚 Profiles

Start only the services you need:

```bash
# Full lab (all services)
docker compose --profile full up -d

# Web targets only
docker compose --profile web up -d

# Network targets + Kali
docker compose --profile network up -d
docker compose --profile kali up -d
```

---

## 💾 Student Progress Snapshots

Save and restore student work between sessions:

```bash
make snapshot    # Commit current Kali state to a named image
make restore     # Restore from a previous snapshot
```

---

## 🛑 Stopping the Lab

```bash
make down        # Stop containers (keep data volumes)
make clean       # Stop and remove containers
make reset       # ⚠️ Full wipe including all student data
```

---

## 🔧 Troubleshooting

**DVWA won't load?**
```bash
# Check MySQL health
docker logs dvwa-mysql
# Wait ~30 seconds for MySQL to initialize, then restart DVWA
docker restart dvwa-target
```

**Kali tools missing?**
```bash
docker exec -it kali-attacker bash /setup.sh
```

**Port already in use?**
```bash
# Change host port in docker-compose.yml, e.g. "8080:80" → "8888:80"
```

**Out of memory?**
```bash
# Start only web targets
docker compose --profile web up -d
```
