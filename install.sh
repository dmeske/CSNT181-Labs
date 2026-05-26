#!/usr/bin/env bash
# ============================================================
#  PENTEST LAB — Student Installer
#  Run this once on a fresh Mac or Linux machine.
#  It installs everything and starts the lab automatically.
#
#  Usage (students paste this one line into Terminal):
#    curl -fsSL https://raw.githubusercontent.com/YOUR_ORG/YOUR_REPO/main/install.sh | bash
# ============================================================

set -e   # exit on any error

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
CYAN='\033[0;36m'; BOLD='\033[1m'; NC='\033[0m'

ok()   { echo -e "${GREEN}[✓]${NC} $1"; }
warn() { echo -e "${YELLOW}[!]${NC} $1"; }
fail() { echo -e "${RED}[✗] ERROR: $1${NC}"; exit 1; }
info() { echo -e "${CYAN}[→]${NC} $1"; }

# ── Banner ─────────────────────────────────────────────────
echo -e "${CYAN}${BOLD}"
echo "╔══════════════════════════════════════════════════╗"
echo "║    🐉  PENTEST LAB — STUDENT INSTALLER          ║"
echo "║    This will set up your cybersecurity lab.     ║"
echo "╚══════════════════════════════════════════════════╝"
echo -e "${NC}"
echo "This script will:"
echo "  1. Check your system requirements"
echo "  2. Install Docker Desktop (if needed)"
echo "  3. Download the lab files"
echo "  4. Start all lab containers"
echo ""
read -p "Press ENTER to continue, or Ctrl+C to cancel..."
echo ""

# ── Detect OS ──────────────────────────────────────────────
OS="unknown"
ARCH=$(uname -m)
if [[ "$OSTYPE" == "darwin"* ]]; then
  OS="mac"
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
  OS="linux"
else
  fail "Unsupported OS: $OSTYPE. This lab supports macOS and Linux."
fi
ok "Detected OS: $OS ($ARCH)"

# ── Check RAM ──────────────────────────────────────────────
if [[ "$OS" == "mac" ]]; then
  RAM_GB=$(( $(sysctl -n hw.memsize) / 1024 / 1024 / 1024 ))
else
  RAM_GB=$(( $(grep MemTotal /proc/meminfo | awk '{print $2}') / 1024 / 1024 ))
fi

if (( RAM_GB < 7 )); then
  warn "Your Mac has ${RAM_GB}GB RAM. The full lab needs 8GB."
  warn "We'll start in lite mode (web targets only)."
  LAB_PROFILE="web"
else
  ok "RAM: ${RAM_GB}GB — sufficient for full lab"
  LAB_PROFILE="full"
fi

# ── Check Disk Space ───────────────────────────────────────
DISK_GB=$(df -g "$HOME" 2>/dev/null | tail -1 | awk '{print $4}' || df -BG "$HOME" | tail -1 | awk '{print $4}' | tr -d 'G')
if (( DISK_GB < 20 )); then
  warn "Only ${DISK_GB}GB free disk space. Lab needs ~20GB."
  warn "Free up space and re-run this script."
  read -p "Continue anyway? (y/N) " yn
  [[ "$yn" =~ ^[Yy]$ ]] || exit 1
else
  ok "Disk space: ${DISK_GB}GB free"
fi

# ── Install Docker (macOS) ─────────────────────────────────
install_docker_mac() {
  info "Checking for Homebrew..."
  if ! command -v brew &>/dev/null; then
    info "Installing Homebrew (this takes a few minutes)..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    # Add brew to PATH for Apple Silicon
    if [[ "$ARCH" == "arm64" ]]; then
      echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> "$HOME/.zprofile"
      eval "$(/opt/homebrew/bin/brew shellenv)"
    fi
    ok "Homebrew installed"
  else
    ok "Homebrew already installed"
  fi

  info "Installing Docker Desktop via Homebrew..."
  brew install --cask docker
  ok "Docker Desktop installed"

  info "Launching Docker Desktop — please wait for it to start..."
  open -a Docker
  echo ""
  warn "Docker Desktop is starting up. This can take 30–60 seconds."
  warn "Watch for the 🐳 whale icon in your menu bar to stop animating."
  echo ""
  read -p "Press ENTER once Docker Desktop shows 'Engine running'..."
}

# ── Install Docker (Linux) ─────────────────────────────────
install_docker_linux() {
  info "Installing Docker Engine..."
  curl -fsSL https://get.docker.com | sh
  sudo usermod -aG docker "$USER"
  ok "Docker installed. You may need to log out and back in."
}

# ── Check / Install Docker ─────────────────────────────────
if command -v docker &>/dev/null && docker info &>/dev/null 2>&1; then
  ok "Docker is already installed and running"
else
  warn "Docker not found or not running."
  if [[ "$OS" == "mac" ]]; then
    install_docker_mac
  else
    install_docker_linux
  fi
fi

# ── Verify Docker Compose ──────────────────────────────────
if ! docker compose version &>/dev/null 2>&1; then
  fail "Docker Compose v2 not found. Please update Docker Desktop."
fi
ok "Docker Compose v2 detected"

# ── Configure Docker Resources (macOS only) ────────────────
if [[ "$OS" == "mac" ]]; then
  SETTINGS="$HOME/Library/Group Containers/group.com.docker/settings.json"
  if [[ -f "$SETTINGS" ]]; then
    info "Checking Docker Desktop memory allocation..."
    CURRENT_MEM=$(python3 -c "import json; d=json.load(open('$SETTINGS')); print(d.get('memoryMiB', 0))" 2>/dev/null || echo 0)
    if (( CURRENT_MEM < 6144 )); then
      warn "Docker Desktop memory is set to ${CURRENT_MEM}MB. Recommended: 8192MB (8GB)."
      warn "Go to: Docker Desktop → Settings → Resources → Memory → set to 8 GB → Apply & Restart"
      read -p "Press ENTER once you've updated memory settings (or skip with Ctrl+C)..."
    else
      ok "Docker memory: ${CURRENT_MEM}MB"
    fi
  fi
fi

# ── Download Lab Files ─────────────────────────────────────
LAB_DIR="$HOME/pentest-lab"
REPO_URL="https://github.com/YOUR_ORG/YOUR_REPO"  # ← update this

info "Setting up lab directory at $LAB_DIR ..."

if [[ -d "$LAB_DIR" ]]; then
  warn "Lab folder already exists at $LAB_DIR"
  read -p "Overwrite with fresh copy? (y/N) " yn
  if [[ "$yn" =~ ^[Yy]$ ]]; then
    rm -rf "$LAB_DIR"
  else
    info "Keeping existing files — skipping download."
  fi
fi

if [[ ! -d "$LAB_DIR" ]]; then
  if command -v git &>/dev/null; then
    git clone "$REPO_URL" "$LAB_DIR"
    ok "Lab files downloaded via git"
  else
    info "git not found — downloading zip instead..."
    curl -fsSL "${REPO_URL}/archive/refs/heads/main.zip" -o /tmp/lab.zip
    unzip -q /tmp/lab.zip -d /tmp/
    mv /tmp/YOUR_REPO-main "$LAB_DIR"
    rm /tmp/lab.zip
    ok "Lab files downloaded and extracted"
  fi
fi

chmod +x "$LAB_DIR/kali-config/setup.sh"

# ── Pull Docker Images ─────────────────────────────────────
echo ""
info "Pulling Docker images (this downloads ~3–5 GB — go make a coffee ☕)..."
echo ""
cd "$LAB_DIR"
docker compose --profile "$LAB_PROFILE" pull
ok "All images downloaded"

# ── Start the Lab ──────────────────────────────────────────
echo ""
info "Starting lab containers..."
docker compose --profile "$LAB_PROFILE" up -d
ok "Lab is running!"

# ── Final Instructions ─────────────────────────────────────
echo ""
echo -e "${GREEN}${BOLD}╔══════════════════════════════════════════════════════╗"
echo "║   ✅  YOUR PENTEST LAB IS READY!                    ║"
echo "╚══════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "  ${BOLD}Open in your browser:${NC}"
echo "    DVWA       → http://localhost:8080   (admin / password)"
echo "    Juice Shop → http://localhost:3000   (admin@juice-sh.op / admin123)"
echo ""
echo -e "  ${BOLD}Open the Kali attacker shell:${NC}"
echo "    cd ~/pentest-lab && make kali"
echo ""
echo -e "  ${BOLD}First time in Kali? Run:${NC}"
echo "    bash /setup.sh"
echo ""
echo -e "  ${BOLD}Stop the lab when done:${NC}"
echo "    cd ~/pentest-lab && make down"
echo ""
echo "  📖 Full docs: ~/pentest-lab/README.md"
echo ""
