#!/usr/bin/env bash
# ============================================================
#  Kali Lab Setup Script
#  Run inside the kali container: bash /setup.sh
# ============================================================

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
CYAN='\033[0;36m'; BOLD='\033[1m'; NC='\033[0m'

banner() {
  echo -e "${CYAN}${BOLD}"
  echo "╔══════════════════════════════════════════╗"
  echo "║   🐉 KALI PENTEST LAB — SETUP SCRIPT    ║"
  echo "║      Isolated Lab Network: 10.10.0.0/24  ║"
  echo "╚══════════════════════════════════════════╝"
  echo -e "${NC}"
}

check_tool() {
  if command -v "$1" &>/dev/null; then
    echo -e "  ${GREEN}[✓]${NC} $1"
  else
    echo -e "  ${RED}[✗]${NC} $1 — NOT FOUND"
  fi
}

ping_target() {
  local name=$1; local ip=$2
  if ping -c1 -W2 "$ip" &>/dev/null; then
    echo -e "  ${GREEN}[UP]${NC}   $name ($ip)"
  else
    echo -e "  ${YELLOW}[DOWN]${NC} $name ($ip) — may still be starting"
  fi
}

setup_aliases() {
  cat >> /root/.bashrc << 'ALIASES'

# ── Lab Aliases ─────────────────────────────────────────
alias dvwa='echo "DVWA       → http://10.10.0.20  (admin/password)"'
alias juice='echo "JuiceShop  → http://10.10.0.40:3000"'
alias ms2='echo "Metasploit → ssh msfadmin@10.10.0.30  (msfadmin/msfadmin)"'

alias scan-dvwa='nmap -sV -sC -p- 10.10.0.20'
alias scan-ms='nmap -sV -sC -p- 10.10.0.30'
alias scan-juice='nmap -sV -sC -p- 10.10.0.40'
alias scan-all='nmap -sV --open 10.10.0.0/24'

alias msfconsole='msfconsole -q'
alias targets='cat /root/lab-notes/targets.txt'
alias labs='ls /root/lab-notes/'

# Add rockyou to PATH convenience
alias rockyou='ls /usr/share/wordlists/rockyou.txt* 2>/dev/null || echo "Run: gzip -d /usr/share/wordlists/rockyou.txt.gz"'
ALIASES
  echo -e "${GREEN}[✓]${NC} Aliases added to ~/.bashrc"
}

write_targets_file() {
  mkdir -p /root/lab-notes
  cat > /root/lab-notes/targets.txt << 'TARGETS'
╔════════════════════════════════════════════════════════════════╗
║              LAB TARGET CHEAT SHEET                           ║
╠════════════════════════════════════════════════════════════════╣
║  DVWA (Web)          10.10.0.20       http://10.10.0.20       ║
║    Credentials:      admin / password                         ║
║    Covers:           SQLi, XSS, CSRF, File Upload, LFI        ║
║                                                               ║
║  Juice Shop (Web)    10.10.0.40:3000  http://10.10.0.40:3000  ║
║    Credentials:      admin@juice-sh.op / admin123             ║
║    Covers:           OWASP Top 10, JWT, GraphQL               ║
║                                                               ║
║  Metasploitable 2    10.10.0.30                               ║
║    SSH:              msfadmin / msfadmin  (port 22)           ║
║    FTP:              anonymous login (port 21)                 ║
║    HTTP:             http://10.10.0.30   (port 80)            ║
║    Covers:           Network services, CVEs, post-exploit     ║
║                                                               ║
║  Attacker (You)      10.10.0.10                               ║
╚════════════════════════════════════════════════════════════════╝
TARGETS
  echo -e "${GREEN}[✓]${NC} Target sheet written to /root/lab-notes/targets.txt"
}

# ── Run Setup ──────────────────────────────────────────────────
banner

echo -e "${BOLD}[1/4] Checking installed tools...${NC}"
for tool in nmap masscan nikto sqlmap hydra john hashcat \
            gobuster dirb tshark msfconsole curl wget python3; do
  check_tool "$tool"
done

echo ""
echo -e "${BOLD}[2/4] Pinging lab targets...${NC}"
ping_target "DVWA"           10.10.0.20
ping_target "Metasploitable" 10.10.0.30
ping_target "Juice Shop"     10.10.0.40
ping_target "MySQL (DVWA)"   10.10.0.50

echo ""
echo -e "${BOLD}[3/4] Writing lab notes & aliases...${NC}"
setup_aliases
write_targets_file

echo ""
echo -e "${BOLD}[4/4] Unpacking wordlists...${NC}"
if [ -f /usr/share/wordlists/rockyou.txt.gz ]; then
  gzip -dk /usr/share/wordlists/rockyou.txt.gz 2>/dev/null && \
    echo -e "  ${GREEN}[✓]${NC} rockyou.txt ready"
else
  echo -e "  ${YELLOW}[~]${NC} rockyou.txt already unpacked or not found"
fi

echo ""
echo -e "${GREEN}${BOLD}════════════════════════════════════════"
echo " ✅  SETUP COMPLETE — Happy Hacking! "
echo " Run: source ~/.bashrc && targets"
echo "════════════════════════════════════════${NC}"
