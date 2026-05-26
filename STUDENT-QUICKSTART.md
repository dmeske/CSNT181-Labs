# 🐉 Pentest Lab — Student Quickstart

Welcome to the cybersecurity lab! Follow these steps exactly and you'll be hacking in under 15 minutes.

---

## Step 1 — Open Terminal

**Mac:** Press `Cmd + Space`, type `Terminal`, press Enter.

**Windows:** This lab requires macOS or Linux. Ask your instructor if you're on Windows.

---

## Step 2 — Run the Installer

Copy and paste this **one line** into Terminal, then press Enter:

```bash
curl -fsSL https://raw.githubusercontent.com/YOUR_ORG/YOUR_REPO/main/install.sh | bash
```

> The script will walk you through everything. It may take **10–15 minutes** the first time because it downloads several large files. That's normal.

---

## Step 3 — Open Your Targets in a Browser

Once the installer finishes, open these links:

| Target | URL | Login |
|---|---|---|
| DVWA (web app attacks) | http://localhost:8080 | admin / password |
| Juice Shop (CTF) | http://localhost:3000 | admin@juice-sh.op / admin123 |

---

## Step 4 — Enter the Kali Attacker Shell

Open a **new Terminal tab** and run:

```bash
cd ~/pentest-lab
make kali
```

You're now inside the Kali Linux container. Run the setup:

```bash
bash /setup.sh
source ~/.bashrc
targets        # shows all targets and credentials
```

---

## Daily Use

```bash
# Start the lab (do this each time you open your Mac)
cd ~/pentest-lab && make up

# Open Kali shell
make kali

# Stop the lab when done (saves battery/RAM)
make down
```

---

## Something Broke?

**Lab won't start:**
```bash
cd ~/pentest-lab && make down && make up
```

**DVWA shows a database error:**
```bash
docker restart dvwa-target
# Wait 30 seconds, then refresh http://localhost:8080
```

**Kali tools are missing:**
```bash
# Inside the Kali shell:
bash /setup.sh
```

**Everything is broken:**
```bash
cd ~/pentest-lab && make reset
# Then re-run: make up
```

---

## ⚠️ Important Rules

- **Never** run these tools against any machine you don't own or have written permission to test.
- All lab activity must stay within the local Docker network.
- These containers are intentionally insecure — never run the lab on a public Wi-Fi network without a VPN.

---

*Questions? Ask your instructor or post in the class discussion board.*
